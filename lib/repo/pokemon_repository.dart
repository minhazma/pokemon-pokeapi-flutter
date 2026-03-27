import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pokemon/api/api.dart';
import 'package:pokemon/cache/app_database.dart';
import 'package:pokemon/models/detail.dart';
import 'package:pokemon/models/list.dart';
import 'package:drift/drift.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pokemon/repo/fuzzy_search.dart';
import 'package:pokemon/utils/audio_cache_manager.dart';
import 'package:pokemon/utils/constants.dart';

const _cacheMaxAge = AppConfig.cacheMaxAge;

class PokemonRepository {
  PokemonRepository({required AppDatabase db, required PokemonApiService api}) : _api = api, _listDao = db.pokemonListDao, _detailDao = db.pokemonDetailDao, _paginator = PokemonPaginator(api: api);

  final PokemonApiService _api;
  final PokemonListDao _listDao;
  final PokemonDetailDao _detailDao;
  final PokemonPaginator _paginator;

  List<({int id, String name})>? _namesCache;
  int _namesCacheSize = 0;

  Future<List<PokemonListItem>> getPokemonPage({int limit = AppConfig.apiDefaultLimit, int offset = 0}) async {
    final cachedCount = await _listDao.totalCount();
    final needsApiLoad = cachedCount < (offset + limit);

    if (needsApiLoad) {
      final response = await _paginator.fetchPage(offset);
      await _cacheListResponse(response);
    }

    final rows = await _listDao.getPage(limit: limit, offset: offset);
    return rows.map(_listRowToItem).toList();
  }

  Future<PaginatedPokemon> getPaginatedPokemon({int offset = 0}) async {
    final limit = _paginator.pageSize;
    final cachedCount = await _listDao.totalCount();

    if (cachedCount == 0) {
      final response = await _paginator.fetchPage(0);
      await _cacheListResponse(response);
    }

    final rows = await _listDao.getPage(limit: limit, offset: offset);
    final items = rows.map(_listRowToItem).toList();
    final currentTotal = await _listDao.totalCount();

    final apiTotal = _paginator.totalCount ?? currentTotal;

    return PaginatedPokemon(items: items, nextOffset: offset + items.length, hasMore: offset + items.length < apiTotal, totalCount: apiTotal);
  }

  Future<List<({int id, String name})>> _getNamesCache() async {
    final count = await _listDao.totalCount();
    if (_namesCache == null || count != _namesCacheSize) {
      _namesCache = await _listDao.getAllNames();
      _namesCacheSize = count;
    }
    return _namesCache!;
  }

  Future<List<PokemonListItem>> searchByName(String query, {int limit = AppConfig.apiDefaultLimit, int offset = 0}) async {
    if (query.trim().isEmpty) {
      return getPokemonPage(limit: limit, offset: offset);
    }
    final rows = await _listDao.searchByName(query, limit: limit, offset: offset);
    return rows.map(_listRowToItem).toList();
  }

  Future<List<PokemonListItem>> fuzzySearchByName(String query, {int limit = AppConfig.apiDefaultLimit, int offset = 0}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final corpus = await _getNamesCache();
    if (corpus.isEmpty) return [];

    final rankedIds = await compute(runFuzzySearch, FuzzySearchArgs(query: trimmed, corpus: corpus));

    if (rankedIds.isEmpty) return [];

    final pageIds = rankedIds.skip(offset).take(limit).toList();
    if (pageIds.isEmpty) return [];

    final rows = await _listDao.getByIds(pageIds);
    final rowById = {for (final r in rows) r.id: r};
    return pageIds.where(rowById.containsKey).map((id) => _listRowToItem(rowById[id]!)).toList();
  }

  Future<PokemonDetail> getPokemonDetail(int id) async {
    final cached = await _detailDao.getById(id);
    if (cached != null && _isFresh(cached.cachedAt)) {
      return PokemonDetail.fromJson(jsonDecode(cached.detailJson) as Map<String, dynamic>);
    }

    final detail = await _api.getPokemonById(id);
    await _cacheDetail(detail);
    return detail;
  }

  Future<PokemonDetail> refreshPokemonDetail(int id) async {
    final detail = await _api.getPokemonById(id);
    await _cacheDetail(detail);
    return detail;
  }

  Future<List<PokemonDetail>> searchWithFacets(PokemonFilter filter) async {
    final rows = await _detailDao.search(filter);
    return rows.map((r) => PokemonDetail.fromJson(jsonDecode(r.detailJson) as Map<String, dynamic>)).toList();
  }

  Future<int> countSearchResults(PokemonFilter filter) => _detailDao.countSearch(filter);

  Future<List<String>> getAvailableTypes() => _detailDao.availableTypes();

  Future<StatSummary> getStatSummary() => _detailDao.statSummary();

  Future<void> ensureDetailsCached(int targetCount, {void Function(int loaded, int total)? onProgress}) async {
    int offset = 0;
    const batchSize = PokemonApiService.maxLimit;

    while (offset < targetCount) {
      final listResponse = await _api.getPokemonList(limit: batchSize, offset: offset);

      final total = listResponse.count;
      final items = listResponse.results;
      if (items.isEmpty) break;

      await _cacheListResponse(listResponse);

      final companions = <CachedPokemonDetailCompanion>[];
      for (final item in items) {
        if (!await _detailDao.isCached(item.id)) {
          try {
            final detail = await _api.getPokemonById(item.id);
            companions.add(_detailToCompanion(detail));
          } catch (_) {}
        }
      }
      if (companions.isNotEmpty) {
        await _detailDao.upsertAll(companions);
      }

      offset = (offset + items.length).toInt();
      onProgress?.call(offset.clamp(0, total), total);

      if (items.length < batchSize) break;
    }
  }

  Future<void> precacheDetail(int id) async {
    try {
      final detail = await getPokemonDetail(id);

      if (detail.cries != null) {
        if (detail.cries!.latest != null) {
          AudioCacheManager().preCache(id, detail.cries!.latest!, 'latest');
        }
        if (detail.cries!.legacy != null) {
          AudioCacheManager().preCache(id, detail.cries!.legacy!, 'legacy');
        }
      }

      final artworkUrl = detail.sprites.officialArtwork?.frontDefault;
      if (artworkUrl != null) {
        DefaultCacheManager().downloadFile(artworkUrl).then((_) {}, onError: (_) {});
      }
    } catch (_) {}
  }

  Future<void> evictStaleDetails() => _detailDao.evictStale(_cacheMaxAge);

  Future<void> clearAll() async {
    _namesCache = null;
    _namesCacheSize = 0;
    await _listDao.clearAll();
    await _detailDao.clearAll();
  }

  Stream<List<PokemonListItem>> watchPokemonList({String? query}) {
    final trimmed = query?.trim().toLowerCase() ?? '';
    if (trimmed.isEmpty) {
      return _listDao.watchAll().map((rows) => rows.map(_listRowToItem).toList());
    }

    int latestUpdateId = 0;

    return _listDao.watchAll().asyncExpand((rows) async* {
      final updateId = ++latestUpdateId;

      if (rows.isEmpty) {
        yield <PokemonListItem>[];
        return;
      }

      if (trimmed.length < 2) {
        yield rows.where((r) => r.name.toLowerCase().contains(trimmed)).map(_listRowToItem).toList();
        return;
      }

      final corpus = rows.map((r) => (id: r.id, name: r.name)).toList();
      final rankedIds = await compute(runFuzzySearch, FuzzySearchArgs(query: trimmed, corpus: corpus));

      if (updateId == latestUpdateId) {
        final rowById = {for (final r in rows) r.id: r};
        yield rankedIds.where(rowById.containsKey).map((id) => _listRowToItem(rowById[id]!)).toList();
      }
    });
  }

  Stream<PokemonDetail?> watchDetail(int id) {
    return _detailDao.watchById(id).map((row) {
      if (row == null) return null;
      return PokemonDetail.fromJson(jsonDecode(row.detailJson) as Map<String, dynamic>);
    });
  }

  Future<void> _cacheListResponse(PokemonListResponse response) async {
    final companions = response.results.map((item) {
      return CachedPokemonListCompanion.insert(id: Value(item.id), name: item.name, url: item.url, spriteUrl: item.spriteUrl, cachedAt: Value(DateTime.now().millisecondsSinceEpoch));
    }).toList();
    await _listDao.upsertAll(companions);
  }

  Future<void> _cacheDetail(PokemonDetail detail) async {
    await _detailDao.upsert(_detailToCompanion(detail));

    final artworkUrl = detail.sprites.officialArtwork?.frontDefault;
    if (artworkUrl != null) {
      await _listDao.setOfficialArtworkUrl(detail.id, artworkUrl);
    }
  }

  CachedPokemonDetailCompanion _detailToCompanion(PokemonDetail d) {
    final statMap = {for (final s in d.stats) s.stat.name: s.baseStat};

    return CachedPokemonDetailCompanion.insert(
      id: Value(d.id),
      name: d.name,
      detailJson: jsonEncode(d.toJson()),
      types: Value(d.types.map((t) => t.type.name).join(',')),
      abilities: Value(d.abilities.map((a) => a.ability.name).join(',')),
      statHp: Value(statMap['hp'] ?? 0),
      statAttack: Value(statMap['attack'] ?? 0),
      statDefense: Value(statMap['defense'] ?? 0),
      statSpecialAttack: Value(statMap['special-attack'] ?? 0),
      statSpecialDefense: Value(statMap['special-defense'] ?? 0),
      statSpeed: Value(statMap['speed'] ?? 0),
      height: Value(d.height),
      weight: Value(d.weight),
      baseExperience: Value(d.baseExperience),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
  }

  PokemonListItem _listRowToItem(CachedPokemonListData row) => PokemonListItem(name: row.name, url: row.url, officialArtworkUrl: row.officialArtworkUrl);

  bool _isFresh(int cachedAtMs) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedAtMs;
    return age < _cacheMaxAge.inMilliseconds;
  }
}

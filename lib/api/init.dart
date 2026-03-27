import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pokemon/api/api.dart';
import 'package:pokemon/cache/app_database.dart';
import 'package:pokemon/models/detail.dart';
import 'package:drift/drift.dart';

enum SyncPhase { idle, fetchingList, fetchingDetails, complete, error }

class SyncProgress {
  const SyncProgress({this.phase = SyncPhase.idle, this.listLoaded = 0, this.listTotal = 0, this.detailLoaded = 0, this.detailTotal = 0, this.errorMessage});

  final SyncPhase phase;

  final int listLoaded;

  final int listTotal;

  final int detailLoaded;

  final int detailTotal;

  final String? errorMessage;

  double get listFraction => listTotal == 0 ? 0 : (listLoaded / listTotal).clamp(0.0, 1.0);

  double get detailFraction => detailTotal == 0 ? 0 : (detailLoaded / detailTotal).clamp(0.0, 1.0);

  bool get isRunning => phase == SyncPhase.fetchingList || phase == SyncPhase.fetchingDetails;

  bool get isComplete => phase == SyncPhase.complete;

  SyncProgress copyWith({SyncPhase? phase, int? listLoaded, int? listTotal, int? detailLoaded, int? detailTotal, String? errorMessage}) {
    return SyncProgress(
      phase: phase ?? this.phase,
      listLoaded: listLoaded ?? this.listLoaded,
      listTotal: listTotal ?? this.listTotal,
      detailLoaded: detailLoaded ?? this.detailLoaded,
      detailTotal: detailTotal ?? this.detailTotal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() => 'SyncProgress($phase list=$listLoaded/$listTotal detail=$detailLoaded/$detailTotal)';
}

class AppInitializer {
  AppInitializer({required PokemonApiService api, required AppDatabase db, int detailSyncTarget = 151, bool syncDetails = true})
    : _api = api,
      _listDao = db.pokemonListDao,
      _detailDao = db.pokemonDetailDao,
      _detailSyncTarget = detailSyncTarget,
      _syncDetails = syncDetails;

  final PokemonApiService _api;
  final PokemonListDao _listDao;
  final PokemonDetailDao _detailDao;
  final int _detailSyncTarget;
  final bool _syncDetails;

  final ValueNotifier<SyncProgress> progress = ValueNotifier(const SyncProgress());

  bool _running = false;

  bool _cancelled = false;

  void init() {
    if (_running) return;

    unawaited(_run());
  }

  Future<void> initAndWait() => _run();

  void cancel() => _cancelled = true;

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    _cancelled = false;

    try {
      await _syncList();
      if (_cancelled) return;

      if (_syncDetails) {
        await _syncDetailsBatched();
      }

      if (!_cancelled) {
        _emit(progress.value.copyWith(phase: SyncPhase.complete));
      }
    } catch (e, stack) {
      debugPrint('[AppInitializer] fatal error: $e\n$stack');
      _emit(progress.value.copyWith(phase: SyncPhase.error, errorMessage: e.toString()));
    } finally {
      _running = false;
    }
  }

  Future<void> _syncList() async {
    final isStale = await _listDao.isCacheStale(const Duration(hours: 24), minCount: 500);
    if (!isStale) {
      final cachedCount = await _listDao.totalCount();
      debugPrint('[AppInitializer] List cache fresh ($cachedCount rows). Skipping Phase 1.');
      _emit(SyncProgress(phase: SyncPhase.fetchingList, listLoaded: cachedCount, listTotal: cachedCount));
      return;
    }

    _emit(const SyncProgress(phase: SyncPhase.fetchingList));

    int offset = 0;
    int apiTotal = 0;
    const batchSize = PokemonApiService.maxLimit;

    debugPrint('[AppInitializer] Phase 1 — syncing list...');

    while (!_cancelled) {
      final response = await _api.getPokemonList(limit: batchSize, offset: offset);

      apiTotal = response.count;
      final items = response.results;
      if (items.isEmpty) break;

      final companions = items.map((item) {
        return CachedPokemonListCompanion.insert(id: Value(item.id), name: item.name, url: item.url, spriteUrl: item.spriteUrl, cachedAt: Value(DateTime.now().millisecondsSinceEpoch));
      }).toList();
      await _listDao.upsertAll(companions);

      offset = (offset + items.length).toInt();

      _emit(progress.value.copyWith(phase: SyncPhase.fetchingList, listLoaded: offset, listTotal: apiTotal));

      debugPrint('[AppInitializer] List: $offset / $apiTotal');

      if (items.length < batchSize) break;
    }

    debugPrint('[AppInitializer] Phase 1 complete. $offset names cached.');
  }

  Future<void> _syncDetailsBatched() async {
    final listRows = await _listDao.getPage(limit: _detailSyncTarget, offset: 0);

    if (listRows.isEmpty) return;

    final total = listRows.length;

    _emit(progress.value.copyWith(phase: SyncPhase.fetchingDetails, detailLoaded: 0, detailTotal: total));

    debugPrint('[AppInitializer] Phase 2 — syncing $total details...');

    int loaded = 0;

    const batchSize = 20;
    for (int start = 0; start < listRows.length && !_cancelled; start += batchSize) {
      final end = (start + batchSize).clamp(0, listRows.length);
      final batch = listRows.sublist(start, end);

      final companions = <CachedPokemonDetailCompanion>[];

      for (final row in batch) {
        if (_cancelled) break;

        final existing = await _detailDao.getById(row.id);
        if (existing != null && _isFresh(existing.cachedAt)) {
          loaded++;
          continue;
        }

        try {
          final detail = await _api.getPokemonById(row.id);
          companions.add(_detailToCompanion(detail));
        } catch (e) {
          debugPrint('[AppInitializer] Failed to fetch detail for #${row.id}: $e');
        }

        loaded++;
      }

      if (companions.isNotEmpty) {
        await _detailDao.upsertAll(companions);
      }

      _emit(progress.value.copyWith(phase: SyncPhase.fetchingDetails, detailLoaded: loaded, detailTotal: total));

      debugPrint('[AppInitializer] Details: $loaded / $total');
    }

    debugPrint('[AppInitializer] Phase 2 complete.');
  }

  void _emit(SyncProgress state) => progress.value = state;

  bool _isFresh(int cachedAtMs) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedAtMs;
    return age < const Duration(hours: 24).inMilliseconds;
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
}

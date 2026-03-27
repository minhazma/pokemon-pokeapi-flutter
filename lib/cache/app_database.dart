import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class CachedPokemonList extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get spriteUrl => text()();

  TextColumn get officialArtworkUrl => text().nullable()();

  IntColumn get cachedAt => integer().withDefault(currentDateAndTime.unixepoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedPokemonDetail extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  TextColumn get detailJson => text()();

  TextColumn get types => text().withDefault(const Constant(''))();

  TextColumn get abilities => text().withDefault(const Constant(''))();

  IntColumn get statHp => integer().withDefault(const Constant(0))();
  IntColumn get statAttack => integer().withDefault(const Constant(0))();
  IntColumn get statDefense => integer().withDefault(const Constant(0))();
  IntColumn get statSpecialAttack => integer().withDefault(const Constant(0))();
  IntColumn get statSpecialDefense => integer().withDefault(const Constant(0))();
  IntColumn get statSpeed => integer().withDefault(const Constant(0))();

  IntColumn get height => integer().withDefault(const Constant(0))();
  IntColumn get weight => integer().withDefault(const Constant(0))();
  IntColumn get baseExperience => integer().withDefault(const Constant(0))();

  IntColumn get cachedAt => integer().withDefault(currentDateAndTime.unixepoch)();

  @override
  Set<Column> get primaryKey => {id};
}

class PokemonFilter {
  const PokemonFilter({this.nameQuery, this.types, this.minHp, this.maxHp, this.minAttack, this.maxAttack, this.minSpeed, this.maxSpeed, this.minWeight, this.maxWeight, this.limit = 20, this.offset = 0});

  final String? nameQuery;

  final List<String>? types;

  final int? minHp;
  final int? maxHp;
  final int? minAttack;
  final int? maxAttack;
  final int? minSpeed;
  final int? maxSpeed;

  final int? minWeight;
  final int? maxWeight;

  final int limit;
  final int offset;

  bool get isEmpty => nameQuery == null && (types == null || types!.isEmpty) && minHp == null && maxHp == null && minAttack == null && maxAttack == null && minSpeed == null && maxSpeed == null && minWeight == null && maxWeight == null;
}

@DriftAccessor(tables: [CachedPokemonList])
class PokemonListDao extends DatabaseAccessor<AppDatabase> with _$PokemonListDaoMixin {
  PokemonListDao(super.db);

  Future<void> upsertAll(List<CachedPokemonListCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedPokemonList, items);
    });
  }

  Future<void> upsert(CachedPokemonListCompanion item) => into(cachedPokemonList).insertOnConflictUpdate(item);

  Future<List<CachedPokemonListData>> getPage({int limit = 20, int offset = 0}) {
    return (select(cachedPokemonList)
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<CachedPokemonListData>> searchByName(String query, {int limit = 20, int offset = 0}) {
    final pattern = '%${query.toLowerCase()}%';
    return (select(cachedPokemonList)
          ..where((t) => t.name.lower().like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> totalCount() async {
    final countExpr = cachedPokemonList.id.count();
    final query = selectOnly(cachedPokemonList)..addColumns([countExpr]);
    return (await query.getSingle()).read(countExpr) ?? 0;
  }

  Future<bool> isCacheStale(Duration maxAge, {int minCount = 0}) async {
    final count = await totalCount();
    if (count < minCount) return true;

    final query = selectOnly(cachedPokemonList)
      ..addColumns([cachedPokemonList.cachedAt])
      ..orderBy([OrderingTerm.asc(cachedPokemonList.cachedAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return true;
    final oldest = row.read(cachedPokemonList.cachedAt) ?? 0;
    final ageMs = DateTime.now().millisecondsSinceEpoch - oldest;
    return ageMs > maxAge.inMilliseconds;
  }

  Future<void> setOfficialArtworkUrl(int id, String artworkUrl) {
    return (update(cachedPokemonList)..where((t) => t.id.equals(id))).write(CachedPokemonListCompanion(officialArtworkUrl: Value(artworkUrl)));
  }

  Future<List<({int id, String name})>> getAllNames() async {
    final query = selectOnly(cachedPokemonList)
      ..addColumns([cachedPokemonList.id, cachedPokemonList.name])
      ..orderBy([OrderingTerm.asc(cachedPokemonList.id)]);
    final rows = await query.get();
    return rows.map((r) => (id: r.read(cachedPokemonList.id)!, name: r.read(cachedPokemonList.name)!)).toList();
  }

  Future<List<CachedPokemonListData>> getByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(cachedPokemonList)..where((t) => t.id.isIn(ids))).get();
  }

  Future<int> clearAll() => delete(cachedPokemonList).go();

  Stream<List<CachedPokemonListData>> watchAll() {
    return (select(cachedPokemonList)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Stream<List<CachedPokemonListData>> watchSearchByName(String query) {
    if (query.trim().isEmpty) return watchAll();
    final pattern = '%${query.toLowerCase()}%';
    return (select(cachedPokemonList)
          ..where((t) => t.name.lower().like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }
}

@DriftAccessor(tables: [CachedPokemonDetail])
class PokemonDetailDao extends DatabaseAccessor<AppDatabase> with _$PokemonDetailDaoMixin {
  PokemonDetailDao(super.db);

  Future<void> upsert(CachedPokemonDetailCompanion detail) => into(cachedPokemonDetail).insertOnConflictUpdate(detail);

  Future<void> upsertAll(List<CachedPokemonDetailCompanion> details) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedPokemonDetail, details);
    });
  }

  Future<CachedPokemonDetailData?> getById(int id) {
    return (select(cachedPokemonDetail)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> isCached(int id) async => (await getById(id)) != null;

  ///

  Future<List<CachedPokemonDetailData>> search(PokemonFilter filter) {
    final query = select(cachedPokemonDetail);

    query.where((t) {
      Expression<bool> where = const Constant(true);

      if (filter.nameQuery != null && filter.nameQuery!.isNotEmpty) {
        final pattern = '%${filter.nameQuery!.toLowerCase()}%';
        where = where & t.name.lower().like(pattern);
      }

      if (filter.types != null && filter.types!.isNotEmpty) {
        Expression<bool> typeExpr = const Constant(false);
        for (final type in filter.types!) {
          typeExpr = typeExpr | t.types.lower().contains(type.toLowerCase());
        }
        where = where & typeExpr;
      }

      if (filter.minHp != null) {
        where = where & t.statHp.isBiggerOrEqualValue(filter.minHp!);
      }
      if (filter.maxHp != null) {
        where = where & t.statHp.isSmallerOrEqualValue(filter.maxHp!);
      }
      if (filter.minAttack != null) {
        where = where & t.statAttack.isBiggerOrEqualValue(filter.minAttack!);
      }
      if (filter.maxAttack != null) {
        where = where & t.statAttack.isSmallerOrEqualValue(filter.maxAttack!);
      }
      if (filter.minSpeed != null) {
        where = where & t.statSpeed.isBiggerOrEqualValue(filter.minSpeed!);
      }
      if (filter.maxSpeed != null) {
        where = where & t.statSpeed.isSmallerOrEqualValue(filter.maxSpeed!);
      }

      if (filter.minWeight != null) {
        where = where & t.weight.isBiggerOrEqualValue(filter.minWeight!);
      }
      if (filter.maxWeight != null) {
        where = where & t.weight.isSmallerOrEqualValue(filter.maxWeight!);
      }

      return where;
    });

    query
      ..orderBy([(t) => OrderingTerm.asc(t.id)])
      ..limit(filter.limit, offset: filter.offset);

    return query.get();
  }

  Future<int> countSearch(PokemonFilter filter) async {
    final results = await search(
      PokemonFilter(
        nameQuery: filter.nameQuery,
        types: filter.types,
        minHp: filter.minHp,
        maxHp: filter.maxHp,
        minAttack: filter.minAttack,
        maxAttack: filter.maxAttack,
        minSpeed: filter.minSpeed,
        maxSpeed: filter.maxSpeed,
        minWeight: filter.minWeight,
        maxWeight: filter.maxWeight,
        limit: 999999,
        offset: 0,
      ),
    );
    return results.length;
  }

  Future<List<String>> availableTypes() async {
    final rows = await (selectOnly(cachedPokemonDetail)..addColumns([cachedPokemonDetail.types])).get();

    final typeSet = <String>{};
    for (final row in rows) {
      final raw = row.read(cachedPokemonDetail.types) ?? '';
      if (raw.isNotEmpty) typeSet.addAll(raw.split(','));
    }
    return typeSet.toList()..sort();
  }

  Future<StatSummary> statSummary() async {
    int minHp = 999, maxHp = 0;
    int minAtk = 999, maxAtk = 0;
    int minSpd = 999, maxSpd = 0;
    int minWt = 999999, maxWt = 0;

    final rows = await (selectOnly(cachedPokemonDetail)..addColumns([cachedPokemonDetail.statHp, cachedPokemonDetail.statAttack, cachedPokemonDetail.statSpeed, cachedPokemonDetail.weight])).get();

    for (final row in rows) {
      final hp = row.read(cachedPokemonDetail.statHp) ?? 0;
      final atk = row.read(cachedPokemonDetail.statAttack) ?? 0;
      final spd = row.read(cachedPokemonDetail.statSpeed) ?? 0;
      final wt = row.read(cachedPokemonDetail.weight) ?? 0;

      if (hp < minHp) minHp = hp;
      if (hp > maxHp) maxHp = hp;
      if (atk < minAtk) minAtk = atk;
      if (atk > maxAtk) maxAtk = atk;
      if (spd < minSpd) minSpd = spd;
      if (spd > maxSpd) maxSpd = spd;
      if (wt < minWt) minWt = wt;
      if (wt > maxWt) maxWt = wt;
    }

    return StatSummary(minHp: minHp, maxHp: maxHp, minAttack: minAtk, maxAttack: maxAtk, minSpeed: minSpd, maxSpeed: maxSpd, minWeight: minWt, maxWeight: maxWt);
  }

  Stream<CachedPokemonDetailData?> watchById(int id) {
    return (select(cachedPokemonDetail)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> clearAll() => delete(cachedPokemonDetail).go();

  Future<int> evictStale(Duration maxAge) {
    final cutoff = DateTime.now().millisecondsSinceEpoch - maxAge.inMilliseconds;
    return (delete(cachedPokemonDetail)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}

class StatSummary {
  const StatSummary({required this.minHp, required this.maxHp, required this.minAttack, required this.maxAttack, required this.minSpeed, required this.maxSpeed, required this.minWeight, required this.maxWeight});

  final int minHp, maxHp;
  final int minAttack, maxAttack;
  final int minSpeed, maxSpeed;

  final int minWeight, maxWeight;
}

@DriftDatabase(tables: [CachedPokemonList, CachedPokemonDetail], daos: [PokemonListDao, PokemonDetailDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pokemons.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

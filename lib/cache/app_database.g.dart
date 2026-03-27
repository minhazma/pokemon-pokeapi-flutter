// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$PokemonListDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedPokemonListTable get cachedPokemonList => attachedDatabase.cachedPokemonList;
  PokemonListDaoManager get managers => PokemonListDaoManager(this);
}

class PokemonListDaoManager {
  final _$PokemonListDaoMixin _db;
  PokemonListDaoManager(this._db);
  $$CachedPokemonListTableTableManager get cachedPokemonList => $$CachedPokemonListTableTableManager(_db.attachedDatabase, _db.cachedPokemonList);
}

mixin _$PokemonDetailDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedPokemonDetailTable get cachedPokemonDetail => attachedDatabase.cachedPokemonDetail;
  PokemonDetailDaoManager get managers => PokemonDetailDaoManager(this);
}

class PokemonDetailDaoManager {
  final _$PokemonDetailDaoMixin _db;
  PokemonDetailDaoManager(this._db);
  $$CachedPokemonDetailTableTableManager get cachedPokemonDetail => $$CachedPokemonDetailTableTableManager(_db.attachedDatabase, _db.cachedPokemonDetail);
}

class $CachedPokemonListTable extends CachedPokemonList with TableInfo<$CachedPokemonListTable, CachedPokemonListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPokemonListTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>('url', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spriteUrlMeta = const VerificationMeta('spriteUrl');
  @override
  late final GeneratedColumn<String> spriteUrl = GeneratedColumn<String>('sprite_url', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _officialArtworkUrlMeta = const VerificationMeta('officialArtworkUrl');
  @override
  late final GeneratedColumn<String> officialArtworkUrl = GeneratedColumn<String>('official_artwork_url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta = const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>('cached_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: currentDateAndTime.unixepoch);
  @override
  List<GeneratedColumn> get $columns => [id, name, url, spriteUrl, officialArtworkUrl, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pokemon_list';
  @override
  VerificationContext validateIntegrity(Insertable<CachedPokemonListData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(_urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('sprite_url')) {
      context.handle(_spriteUrlMeta, spriteUrl.isAcceptableOrUnknown(data['sprite_url']!, _spriteUrlMeta));
    } else if (isInserting) {
      context.missing(_spriteUrlMeta);
    }
    if (data.containsKey('official_artwork_url')) {
      context.handle(_officialArtworkUrlMeta, officialArtworkUrl.isAcceptableOrUnknown(data['official_artwork_url']!, _officialArtworkUrlMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta, cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPokemonListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPokemonListData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      spriteUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sprite_url'])!,
      officialArtworkUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}official_artwork_url']),
      cachedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedPokemonListTable createAlias(String alias) {
    return $CachedPokemonListTable(attachedDatabase, alias);
  }
}

class CachedPokemonListData extends DataClass implements Insertable<CachedPokemonListData> {
  final int id;
  final String name;
  final String url;
  final String spriteUrl;
  final String? officialArtworkUrl;
  final int cachedAt;
  const CachedPokemonListData({required this.id, required this.name, required this.url, required this.spriteUrl, this.officialArtworkUrl, required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['sprite_url'] = Variable<String>(spriteUrl);
    if (!nullToAbsent || officialArtworkUrl != null) {
      map['official_artwork_url'] = Variable<String>(officialArtworkUrl);
    }
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  CachedPokemonListCompanion toCompanion(bool nullToAbsent) {
    return CachedPokemonListCompanion(
      id: Value(id),
      name: Value(name),
      url: Value(url),
      spriteUrl: Value(spriteUrl),
      officialArtworkUrl: officialArtworkUrl == null && nullToAbsent ? const Value.absent() : Value(officialArtworkUrl),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPokemonListData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPokemonListData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      spriteUrl: serializer.fromJson<String>(json['spriteUrl']),
      officialArtworkUrl: serializer.fromJson<String?>(json['officialArtworkUrl']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'spriteUrl': serializer.toJson<String>(spriteUrl),
      'officialArtworkUrl': serializer.toJson<String?>(officialArtworkUrl),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  CachedPokemonListData copyWith({int? id, String? name, String? url, String? spriteUrl, Value<String?> officialArtworkUrl = const Value.absent(), int? cachedAt}) => CachedPokemonListData(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    spriteUrl: spriteUrl ?? this.spriteUrl,
    officialArtworkUrl: officialArtworkUrl.present ? officialArtworkUrl.value : this.officialArtworkUrl,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedPokemonListData copyWithCompanion(CachedPokemonListCompanion data) {
    return CachedPokemonListData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      spriteUrl: data.spriteUrl.present ? data.spriteUrl.value : this.spriteUrl,
      officialArtworkUrl: data.officialArtworkUrl.present ? data.officialArtworkUrl.value : this.officialArtworkUrl,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonListData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('officialArtworkUrl: $officialArtworkUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, url, spriteUrl, officialArtworkUrl, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPokemonListData && other.id == this.id && other.name == this.name && other.url == this.url && other.spriteUrl == this.spriteUrl && other.officialArtworkUrl == this.officialArtworkUrl && other.cachedAt == this.cachedAt);
}

class CachedPokemonListCompanion extends UpdateCompanion<CachedPokemonListData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> url;
  final Value<String> spriteUrl;
  final Value<String?> officialArtworkUrl;
  final Value<int> cachedAt;
  const CachedPokemonListCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.spriteUrl = const Value.absent(),
    this.officialArtworkUrl = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedPokemonListCompanion.insert({this.id = const Value.absent(), required String name, required String url, required String spriteUrl, this.officialArtworkUrl = const Value.absent(), this.cachedAt = const Value.absent()})
    : name = Value(name),
      url = Value(url),
      spriteUrl = Value(spriteUrl);
  static Insertable<CachedPokemonListData> custom({Expression<int>? id, Expression<String>? name, Expression<String>? url, Expression<String>? spriteUrl, Expression<String>? officialArtworkUrl, Expression<int>? cachedAt}) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (spriteUrl != null) 'sprite_url': spriteUrl,
      if (officialArtworkUrl != null) 'official_artwork_url': officialArtworkUrl,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedPokemonListCompanion copyWith({Value<int>? id, Value<String>? name, Value<String>? url, Value<String>? spriteUrl, Value<String?>? officialArtworkUrl, Value<int>? cachedAt}) {
    return CachedPokemonListCompanion(id: id ?? this.id, name: name ?? this.name, url: url ?? this.url, spriteUrl: spriteUrl ?? this.spriteUrl, officialArtworkUrl: officialArtworkUrl ?? this.officialArtworkUrl, cachedAt: cachedAt ?? this.cachedAt);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (spriteUrl.present) {
      map['sprite_url'] = Variable<String>(spriteUrl.value);
    }
    if (officialArtworkUrl.present) {
      map['official_artwork_url'] = Variable<String>(officialArtworkUrl.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonListCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('officialArtworkUrl: $officialArtworkUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedPokemonDetailTable extends CachedPokemonDetail with TableInfo<$CachedPokemonDetailTable, CachedPokemonDetailData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPokemonDetailTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailJsonMeta = const VerificationMeta('detailJson');
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>('detail_json', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typesMeta = const VerificationMeta('types');
  @override
  late final GeneratedColumn<String> types = GeneratedColumn<String>('types', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant(''));
  static const VerificationMeta _abilitiesMeta = const VerificationMeta('abilities');
  @override
  late final GeneratedColumn<String> abilities = GeneratedColumn<String>('abilities', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant(''));
  static const VerificationMeta _statHpMeta = const VerificationMeta('statHp');
  @override
  late final GeneratedColumn<int> statHp = GeneratedColumn<int>('stat_hp', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _statAttackMeta = const VerificationMeta('statAttack');
  @override
  late final GeneratedColumn<int> statAttack = GeneratedColumn<int>('stat_attack', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _statDefenseMeta = const VerificationMeta('statDefense');
  @override
  late final GeneratedColumn<int> statDefense = GeneratedColumn<int>('stat_defense', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _statSpecialAttackMeta = const VerificationMeta('statSpecialAttack');
  @override
  late final GeneratedColumn<int> statSpecialAttack = GeneratedColumn<int>('stat_special_attack', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _statSpecialDefenseMeta = const VerificationMeta('statSpecialDefense');
  @override
  late final GeneratedColumn<int> statSpecialDefense = GeneratedColumn<int>('stat_special_defense', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _statSpeedMeta = const VerificationMeta('statSpeed');
  @override
  late final GeneratedColumn<int> statSpeed = GeneratedColumn<int>('stat_speed', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>('height', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>('weight', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _baseExperienceMeta = const VerificationMeta('baseExperience');
  @override
  late final GeneratedColumn<int> baseExperience = GeneratedColumn<int>('base_experience', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _cachedAtMeta = const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>('cached_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: currentDateAndTime.unixepoch);
  @override
  List<GeneratedColumn> get $columns => [id, name, detailJson, types, abilities, statHp, statAttack, statDefense, statSpecialAttack, statSpecialDefense, statSpeed, height, weight, baseExperience, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pokemon_detail';
  @override
  VerificationContext validateIntegrity(Insertable<CachedPokemonDetailData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('detail_json')) {
      context.handle(_detailJsonMeta, detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta));
    } else if (isInserting) {
      context.missing(_detailJsonMeta);
    }
    if (data.containsKey('types')) {
      context.handle(_typesMeta, types.isAcceptableOrUnknown(data['types']!, _typesMeta));
    }
    if (data.containsKey('abilities')) {
      context.handle(_abilitiesMeta, abilities.isAcceptableOrUnknown(data['abilities']!, _abilitiesMeta));
    }
    if (data.containsKey('stat_hp')) {
      context.handle(_statHpMeta, statHp.isAcceptableOrUnknown(data['stat_hp']!, _statHpMeta));
    }
    if (data.containsKey('stat_attack')) {
      context.handle(_statAttackMeta, statAttack.isAcceptableOrUnknown(data['stat_attack']!, _statAttackMeta));
    }
    if (data.containsKey('stat_defense')) {
      context.handle(_statDefenseMeta, statDefense.isAcceptableOrUnknown(data['stat_defense']!, _statDefenseMeta));
    }
    if (data.containsKey('stat_special_attack')) {
      context.handle(_statSpecialAttackMeta, statSpecialAttack.isAcceptableOrUnknown(data['stat_special_attack']!, _statSpecialAttackMeta));
    }
    if (data.containsKey('stat_special_defense')) {
      context.handle(_statSpecialDefenseMeta, statSpecialDefense.isAcceptableOrUnknown(data['stat_special_defense']!, _statSpecialDefenseMeta));
    }
    if (data.containsKey('stat_speed')) {
      context.handle(_statSpeedMeta, statSpeed.isAcceptableOrUnknown(data['stat_speed']!, _statSpeedMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta, height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta, weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('base_experience')) {
      context.handle(_baseExperienceMeta, baseExperience.isAcceptableOrUnknown(data['base_experience']!, _baseExperienceMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta, cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPokemonDetailData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPokemonDetailData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      detailJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}detail_json'])!,
      types: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}types'])!,
      abilities: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}abilities'])!,
      statHp: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_hp'])!,
      statAttack: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_attack'])!,
      statDefense: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_defense'])!,
      statSpecialAttack: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_special_attack'])!,
      statSpecialDefense: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_special_defense'])!,
      statSpeed: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stat_speed'])!,
      height: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      weight: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}weight'])!,
      baseExperience: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}base_experience'])!,
      cachedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedPokemonDetailTable createAlias(String alias) {
    return $CachedPokemonDetailTable(attachedDatabase, alias);
  }
}

class CachedPokemonDetailData extends DataClass implements Insertable<CachedPokemonDetailData> {
  final int id;
  final String name;
  final String detailJson;
  final String types;
  final String abilities;
  final int statHp;
  final int statAttack;
  final int statDefense;
  final int statSpecialAttack;
  final int statSpecialDefense;
  final int statSpeed;
  final int height;
  final int weight;
  final int baseExperience;
  final int cachedAt;
  const CachedPokemonDetailData({
    required this.id,
    required this.name,
    required this.detailJson,
    required this.types,
    required this.abilities,
    required this.statHp,
    required this.statAttack,
    required this.statDefense,
    required this.statSpecialAttack,
    required this.statSpecialDefense,
    required this.statSpeed,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['detail_json'] = Variable<String>(detailJson);
    map['types'] = Variable<String>(types);
    map['abilities'] = Variable<String>(abilities);
    map['stat_hp'] = Variable<int>(statHp);
    map['stat_attack'] = Variable<int>(statAttack);
    map['stat_defense'] = Variable<int>(statDefense);
    map['stat_special_attack'] = Variable<int>(statSpecialAttack);
    map['stat_special_defense'] = Variable<int>(statSpecialDefense);
    map['stat_speed'] = Variable<int>(statSpeed);
    map['height'] = Variable<int>(height);
    map['weight'] = Variable<int>(weight);
    map['base_experience'] = Variable<int>(baseExperience);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  CachedPokemonDetailCompanion toCompanion(bool nullToAbsent) {
    return CachedPokemonDetailCompanion(
      id: Value(id),
      name: Value(name),
      detailJson: Value(detailJson),
      types: Value(types),
      abilities: Value(abilities),
      statHp: Value(statHp),
      statAttack: Value(statAttack),
      statDefense: Value(statDefense),
      statSpecialAttack: Value(statSpecialAttack),
      statSpecialDefense: Value(statSpecialDefense),
      statSpeed: Value(statSpeed),
      height: Value(height),
      weight: Value(weight),
      baseExperience: Value(baseExperience),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPokemonDetailData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPokemonDetailData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      detailJson: serializer.fromJson<String>(json['detailJson']),
      types: serializer.fromJson<String>(json['types']),
      abilities: serializer.fromJson<String>(json['abilities']),
      statHp: serializer.fromJson<int>(json['statHp']),
      statAttack: serializer.fromJson<int>(json['statAttack']),
      statDefense: serializer.fromJson<int>(json['statDefense']),
      statSpecialAttack: serializer.fromJson<int>(json['statSpecialAttack']),
      statSpecialDefense: serializer.fromJson<int>(json['statSpecialDefense']),
      statSpeed: serializer.fromJson<int>(json['statSpeed']),
      height: serializer.fromJson<int>(json['height']),
      weight: serializer.fromJson<int>(json['weight']),
      baseExperience: serializer.fromJson<int>(json['baseExperience']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'detailJson': serializer.toJson<String>(detailJson),
      'types': serializer.toJson<String>(types),
      'abilities': serializer.toJson<String>(abilities),
      'statHp': serializer.toJson<int>(statHp),
      'statAttack': serializer.toJson<int>(statAttack),
      'statDefense': serializer.toJson<int>(statDefense),
      'statSpecialAttack': serializer.toJson<int>(statSpecialAttack),
      'statSpecialDefense': serializer.toJson<int>(statSpecialDefense),
      'statSpeed': serializer.toJson<int>(statSpeed),
      'height': serializer.toJson<int>(height),
      'weight': serializer.toJson<int>(weight),
      'baseExperience': serializer.toJson<int>(baseExperience),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  CachedPokemonDetailData copyWith({
    int? id,
    String? name,
    String? detailJson,
    String? types,
    String? abilities,
    int? statHp,
    int? statAttack,
    int? statDefense,
    int? statSpecialAttack,
    int? statSpecialDefense,
    int? statSpeed,
    int? height,
    int? weight,
    int? baseExperience,
    int? cachedAt,
  }) => CachedPokemonDetailData(
    id: id ?? this.id,
    name: name ?? this.name,
    detailJson: detailJson ?? this.detailJson,
    types: types ?? this.types,
    abilities: abilities ?? this.abilities,
    statHp: statHp ?? this.statHp,
    statAttack: statAttack ?? this.statAttack,
    statDefense: statDefense ?? this.statDefense,
    statSpecialAttack: statSpecialAttack ?? this.statSpecialAttack,
    statSpecialDefense: statSpecialDefense ?? this.statSpecialDefense,
    statSpeed: statSpeed ?? this.statSpeed,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    baseExperience: baseExperience ?? this.baseExperience,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedPokemonDetailData copyWithCompanion(CachedPokemonDetailCompanion data) {
    return CachedPokemonDetailData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      detailJson: data.detailJson.present ? data.detailJson.value : this.detailJson,
      types: data.types.present ? data.types.value : this.types,
      abilities: data.abilities.present ? data.abilities.value : this.abilities,
      statHp: data.statHp.present ? data.statHp.value : this.statHp,
      statAttack: data.statAttack.present ? data.statAttack.value : this.statAttack,
      statDefense: data.statDefense.present ? data.statDefense.value : this.statDefense,
      statSpecialAttack: data.statSpecialAttack.present ? data.statSpecialAttack.value : this.statSpecialAttack,
      statSpecialDefense: data.statSpecialDefense.present ? data.statSpecialDefense.value : this.statSpecialDefense,
      statSpeed: data.statSpeed.present ? data.statSpeed.value : this.statSpeed,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      baseExperience: data.baseExperience.present ? data.baseExperience.value : this.baseExperience,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonDetailData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detailJson: $detailJson, ')
          ..write('types: $types, ')
          ..write('abilities: $abilities, ')
          ..write('statHp: $statHp, ')
          ..write('statAttack: $statAttack, ')
          ..write('statDefense: $statDefense, ')
          ..write('statSpecialAttack: $statSpecialAttack, ')
          ..write('statSpecialDefense: $statSpecialDefense, ')
          ..write('statSpeed: $statSpeed, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('baseExperience: $baseExperience, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, detailJson, types, abilities, statHp, statAttack, statDefense, statSpecialAttack, statSpecialDefense, statSpeed, height, weight, baseExperience, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPokemonDetailData &&
          other.id == this.id &&
          other.name == this.name &&
          other.detailJson == this.detailJson &&
          other.types == this.types &&
          other.abilities == this.abilities &&
          other.statHp == this.statHp &&
          other.statAttack == this.statAttack &&
          other.statDefense == this.statDefense &&
          other.statSpecialAttack == this.statSpecialAttack &&
          other.statSpecialDefense == this.statSpecialDefense &&
          other.statSpeed == this.statSpeed &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.baseExperience == this.baseExperience &&
          other.cachedAt == this.cachedAt);
}

class CachedPokemonDetailCompanion extends UpdateCompanion<CachedPokemonDetailData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> detailJson;
  final Value<String> types;
  final Value<String> abilities;
  final Value<int> statHp;
  final Value<int> statAttack;
  final Value<int> statDefense;
  final Value<int> statSpecialAttack;
  final Value<int> statSpecialDefense;
  final Value<int> statSpeed;
  final Value<int> height;
  final Value<int> weight;
  final Value<int> baseExperience;
  final Value<int> cachedAt;
  const CachedPokemonDetailCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.types = const Value.absent(),
    this.abilities = const Value.absent(),
    this.statHp = const Value.absent(),
    this.statAttack = const Value.absent(),
    this.statDefense = const Value.absent(),
    this.statSpecialAttack = const Value.absent(),
    this.statSpecialDefense = const Value.absent(),
    this.statSpeed = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.baseExperience = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedPokemonDetailCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String detailJson,
    this.types = const Value.absent(),
    this.abilities = const Value.absent(),
    this.statHp = const Value.absent(),
    this.statAttack = const Value.absent(),
    this.statDefense = const Value.absent(),
    this.statSpecialAttack = const Value.absent(),
    this.statSpecialDefense = const Value.absent(),
    this.statSpeed = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.baseExperience = const Value.absent(),
    this.cachedAt = const Value.absent(),
  }) : name = Value(name),
       detailJson = Value(detailJson);
  static Insertable<CachedPokemonDetailData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? detailJson,
    Expression<String>? types,
    Expression<String>? abilities,
    Expression<int>? statHp,
    Expression<int>? statAttack,
    Expression<int>? statDefense,
    Expression<int>? statSpecialAttack,
    Expression<int>? statSpecialDefense,
    Expression<int>? statSpeed,
    Expression<int>? height,
    Expression<int>? weight,
    Expression<int>? baseExperience,
    Expression<int>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (detailJson != null) 'detail_json': detailJson,
      if (types != null) 'types': types,
      if (abilities != null) 'abilities': abilities,
      if (statHp != null) 'stat_hp': statHp,
      if (statAttack != null) 'stat_attack': statAttack,
      if (statDefense != null) 'stat_defense': statDefense,
      if (statSpecialAttack != null) 'stat_special_attack': statSpecialAttack,
      if (statSpecialDefense != null) 'stat_special_defense': statSpecialDefense,
      if (statSpeed != null) 'stat_speed': statSpeed,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (baseExperience != null) 'base_experience': baseExperience,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedPokemonDetailCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? detailJson,
    Value<String>? types,
    Value<String>? abilities,
    Value<int>? statHp,
    Value<int>? statAttack,
    Value<int>? statDefense,
    Value<int>? statSpecialAttack,
    Value<int>? statSpecialDefense,
    Value<int>? statSpeed,
    Value<int>? height,
    Value<int>? weight,
    Value<int>? baseExperience,
    Value<int>? cachedAt,
  }) {
    return CachedPokemonDetailCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      detailJson: detailJson ?? this.detailJson,
      types: types ?? this.types,
      abilities: abilities ?? this.abilities,
      statHp: statHp ?? this.statHp,
      statAttack: statAttack ?? this.statAttack,
      statDefense: statDefense ?? this.statDefense,
      statSpecialAttack: statSpecialAttack ?? this.statSpecialAttack,
      statSpecialDefense: statSpecialDefense ?? this.statSpecialDefense,
      statSpeed: statSpeed ?? this.statSpeed,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      baseExperience: baseExperience ?? this.baseExperience,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    if (types.present) {
      map['types'] = Variable<String>(types.value);
    }
    if (abilities.present) {
      map['abilities'] = Variable<String>(abilities.value);
    }
    if (statHp.present) {
      map['stat_hp'] = Variable<int>(statHp.value);
    }
    if (statAttack.present) {
      map['stat_attack'] = Variable<int>(statAttack.value);
    }
    if (statDefense.present) {
      map['stat_defense'] = Variable<int>(statDefense.value);
    }
    if (statSpecialAttack.present) {
      map['stat_special_attack'] = Variable<int>(statSpecialAttack.value);
    }
    if (statSpecialDefense.present) {
      map['stat_special_defense'] = Variable<int>(statSpecialDefense.value);
    }
    if (statSpeed.present) {
      map['stat_speed'] = Variable<int>(statSpeed.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (baseExperience.present) {
      map['base_experience'] = Variable<int>(baseExperience.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPokemonDetailCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('detailJson: $detailJson, ')
          ..write('types: $types, ')
          ..write('abilities: $abilities, ')
          ..write('statHp: $statHp, ')
          ..write('statAttack: $statAttack, ')
          ..write('statDefense: $statDefense, ')
          ..write('statSpecialAttack: $statSpecialAttack, ')
          ..write('statSpecialDefense: $statSpecialDefense, ')
          ..write('statSpeed: $statSpeed, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('baseExperience: $baseExperience, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedPokemonListTable cachedPokemonList = $CachedPokemonListTable(this);
  late final $CachedPokemonDetailTable cachedPokemonDetail = $CachedPokemonDetailTable(this);
  late final PokemonListDao pokemonListDao = PokemonListDao(this as AppDatabase);
  late final PokemonDetailDao pokemonDetailDao = PokemonDetailDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedPokemonList, cachedPokemonDetail];
}

typedef $$CachedPokemonListTableCreateCompanionBuilder = CachedPokemonListCompanion Function({Value<int> id, required String name, required String url, required String spriteUrl, Value<String?> officialArtworkUrl, Value<int> cachedAt});
typedef $$CachedPokemonListTableUpdateCompanionBuilder = CachedPokemonListCompanion Function({Value<int> id, Value<String> name, Value<String> url, Value<String> spriteUrl, Value<String?> officialArtworkUrl, Value<int> cachedAt});

class $$CachedPokemonListTableFilterComposer extends Composer<_$AppDatabase, $CachedPokemonListTable> {
  $$CachedPokemonListTableFilterComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spriteUrl => $composableBuilder(column: $table.spriteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get officialArtworkUrl => $composableBuilder(column: $table.officialArtworkUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedPokemonListTableOrderingComposer extends Composer<_$AppDatabase, $CachedPokemonListTable> {
  $$CachedPokemonListTableOrderingComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spriteUrl => $composableBuilder(column: $table.spriteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get officialArtworkUrl => $composableBuilder(column: $table.officialArtworkUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedPokemonListTableAnnotationComposer extends Composer<_$AppDatabase, $CachedPokemonListTable> {
  $$CachedPokemonListTableAnnotationComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url => $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get spriteUrl => $composableBuilder(column: $table.spriteUrl, builder: (column) => column);

  GeneratedColumn<String> get officialArtworkUrl => $composableBuilder(column: $table.officialArtworkUrl, builder: (column) => column);

  GeneratedColumn<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPokemonListTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPokemonListTable,
          CachedPokemonListData,
          $$CachedPokemonListTableFilterComposer,
          $$CachedPokemonListTableOrderingComposer,
          $$CachedPokemonListTableAnnotationComposer,
          $$CachedPokemonListTableCreateCompanionBuilder,
          $$CachedPokemonListTableUpdateCompanionBuilder,
          (CachedPokemonListData, BaseReferences<_$AppDatabase, $CachedPokemonListTable, CachedPokemonListData>),
          CachedPokemonListData,
          PrefetchHooks Function()
        > {
  $$CachedPokemonListTableTableManager(_$AppDatabase db, $CachedPokemonListTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CachedPokemonListTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CachedPokemonListTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CachedPokemonListTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> spriteUrl = const Value.absent(),
                Value<String?> officialArtworkUrl = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
              }) => CachedPokemonListCompanion(id: id, name: name, url: url, spriteUrl: spriteUrl, officialArtworkUrl: officialArtworkUrl, cachedAt: cachedAt),
          createCompanionCallback: ({Value<int> id = const Value.absent(), required String name, required String url, required String spriteUrl, Value<String?> officialArtworkUrl = const Value.absent(), Value<int> cachedAt = const Value.absent()}) =>
              CachedPokemonListCompanion.insert(id: id, name: name, url: url, spriteUrl: spriteUrl, officialArtworkUrl: officialArtworkUrl, cachedAt: cachedAt),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPokemonListTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPokemonListTable,
      CachedPokemonListData,
      $$CachedPokemonListTableFilterComposer,
      $$CachedPokemonListTableOrderingComposer,
      $$CachedPokemonListTableAnnotationComposer,
      $$CachedPokemonListTableCreateCompanionBuilder,
      $$CachedPokemonListTableUpdateCompanionBuilder,
      (CachedPokemonListData, BaseReferences<_$AppDatabase, $CachedPokemonListTable, CachedPokemonListData>),
      CachedPokemonListData,
      PrefetchHooks Function()
    >;
typedef $$CachedPokemonDetailTableCreateCompanionBuilder =
    CachedPokemonDetailCompanion Function({
      Value<int> id,
      required String name,
      required String detailJson,
      Value<String> types,
      Value<String> abilities,
      Value<int> statHp,
      Value<int> statAttack,
      Value<int> statDefense,
      Value<int> statSpecialAttack,
      Value<int> statSpecialDefense,
      Value<int> statSpeed,
      Value<int> height,
      Value<int> weight,
      Value<int> baseExperience,
      Value<int> cachedAt,
    });
typedef $$CachedPokemonDetailTableUpdateCompanionBuilder =
    CachedPokemonDetailCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> detailJson,
      Value<String> types,
      Value<String> abilities,
      Value<int> statHp,
      Value<int> statAttack,
      Value<int> statDefense,
      Value<int> statSpecialAttack,
      Value<int> statSpecialDefense,
      Value<int> statSpeed,
      Value<int> height,
      Value<int> weight,
      Value<int> baseExperience,
      Value<int> cachedAt,
    });

class $$CachedPokemonDetailTableFilterComposer extends Composer<_$AppDatabase, $CachedPokemonDetailTable> {
  $$CachedPokemonDetailTableFilterComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailJson => $composableBuilder(column: $table.detailJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get types => $composableBuilder(column: $table.types, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abilities => $composableBuilder(column: $table.abilities, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statHp => $composableBuilder(column: $table.statHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statAttack => $composableBuilder(column: $table.statAttack, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statDefense => $composableBuilder(column: $table.statDefense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statSpecialAttack => $composableBuilder(column: $table.statSpecialAttack, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statSpecialDefense => $composableBuilder(column: $table.statSpecialDefense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statSpeed => $composableBuilder(column: $table.statSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baseExperience => $composableBuilder(column: $table.baseExperience, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedPokemonDetailTableOrderingComposer extends Composer<_$AppDatabase, $CachedPokemonDetailTable> {
  $$CachedPokemonDetailTableOrderingComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailJson => $composableBuilder(column: $table.detailJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get types => $composableBuilder(column: $table.types, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abilities => $composableBuilder(column: $table.abilities, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statHp => $composableBuilder(column: $table.statHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statAttack => $composableBuilder(column: $table.statAttack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statDefense => $composableBuilder(column: $table.statDefense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statSpecialAttack => $composableBuilder(column: $table.statSpecialAttack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statSpecialDefense => $composableBuilder(column: $table.statSpecialDefense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statSpeed => $composableBuilder(column: $table.statSpeed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baseExperience => $composableBuilder(column: $table.baseExperience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedPokemonDetailTableAnnotationComposer extends Composer<_$AppDatabase, $CachedPokemonDetailTable> {
  $$CachedPokemonDetailTableAnnotationComposer({required super.$db, required super.$table, super.joinBuilder, super.$addJoinBuilderToRootComposer, super.$removeJoinBuilderFromRootComposer});
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get detailJson => $composableBuilder(column: $table.detailJson, builder: (column) => column);

  GeneratedColumn<String> get types => $composableBuilder(column: $table.types, builder: (column) => column);

  GeneratedColumn<String> get abilities => $composableBuilder(column: $table.abilities, builder: (column) => column);

  GeneratedColumn<int> get statHp => $composableBuilder(column: $table.statHp, builder: (column) => column);

  GeneratedColumn<int> get statAttack => $composableBuilder(column: $table.statAttack, builder: (column) => column);

  GeneratedColumn<int> get statDefense => $composableBuilder(column: $table.statDefense, builder: (column) => column);

  GeneratedColumn<int> get statSpecialAttack => $composableBuilder(column: $table.statSpecialAttack, builder: (column) => column);

  GeneratedColumn<int> get statSpecialDefense => $composableBuilder(column: $table.statSpecialDefense, builder: (column) => column);

  GeneratedColumn<int> get statSpeed => $composableBuilder(column: $table.statSpeed, builder: (column) => column);

  GeneratedColumn<int> get height => $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get weight => $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get baseExperience => $composableBuilder(column: $table.baseExperience, builder: (column) => column);

  GeneratedColumn<int> get cachedAt => $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPokemonDetailTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPokemonDetailTable,
          CachedPokemonDetailData,
          $$CachedPokemonDetailTableFilterComposer,
          $$CachedPokemonDetailTableOrderingComposer,
          $$CachedPokemonDetailTableAnnotationComposer,
          $$CachedPokemonDetailTableCreateCompanionBuilder,
          $$CachedPokemonDetailTableUpdateCompanionBuilder,
          (CachedPokemonDetailData, BaseReferences<_$AppDatabase, $CachedPokemonDetailTable, CachedPokemonDetailData>),
          CachedPokemonDetailData,
          PrefetchHooks Function()
        > {
  $$CachedPokemonDetailTableTableManager(_$AppDatabase db, $CachedPokemonDetailTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CachedPokemonDetailTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CachedPokemonDetailTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CachedPokemonDetailTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> detailJson = const Value.absent(),
                Value<String> types = const Value.absent(),
                Value<String> abilities = const Value.absent(),
                Value<int> statHp = const Value.absent(),
                Value<int> statAttack = const Value.absent(),
                Value<int> statDefense = const Value.absent(),
                Value<int> statSpecialAttack = const Value.absent(),
                Value<int> statSpecialDefense = const Value.absent(),
                Value<int> statSpeed = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<int> baseExperience = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
              }) => CachedPokemonDetailCompanion(
                id: id,
                name: name,
                detailJson: detailJson,
                types: types,
                abilities: abilities,
                statHp: statHp,
                statAttack: statAttack,
                statDefense: statDefense,
                statSpecialAttack: statSpecialAttack,
                statSpecialDefense: statSpecialDefense,
                statSpeed: statSpeed,
                height: height,
                weight: weight,
                baseExperience: baseExperience,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String detailJson,
                Value<String> types = const Value.absent(),
                Value<String> abilities = const Value.absent(),
                Value<int> statHp = const Value.absent(),
                Value<int> statAttack = const Value.absent(),
                Value<int> statDefense = const Value.absent(),
                Value<int> statSpecialAttack = const Value.absent(),
                Value<int> statSpecialDefense = const Value.absent(),
                Value<int> statSpeed = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<int> baseExperience = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
              }) => CachedPokemonDetailCompanion.insert(
                id: id,
                name: name,
                detailJson: detailJson,
                types: types,
                abilities: abilities,
                statHp: statHp,
                statAttack: statAttack,
                statDefense: statDefense,
                statSpecialAttack: statSpecialAttack,
                statSpecialDefense: statSpecialDefense,
                statSpeed: statSpeed,
                height: height,
                weight: weight,
                baseExperience: baseExperience,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPokemonDetailTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPokemonDetailTable,
      CachedPokemonDetailData,
      $$CachedPokemonDetailTableFilterComposer,
      $$CachedPokemonDetailTableOrderingComposer,
      $$CachedPokemonDetailTableAnnotationComposer,
      $$CachedPokemonDetailTableCreateCompanionBuilder,
      $$CachedPokemonDetailTableUpdateCompanionBuilder,
      (CachedPokemonDetailData, BaseReferences<_$AppDatabase, $CachedPokemonDetailTable, CachedPokemonDetailData>),
      CachedPokemonDetailData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedPokemonListTableTableManager get cachedPokemonList => $$CachedPokemonListTableTableManager(_db, _db.cachedPokemonList);
  $$CachedPokemonDetailTableTableManager get cachedPokemonDetail => $$CachedPokemonDetailTableTableManager(_db, _db.cachedPokemonDetail);
}

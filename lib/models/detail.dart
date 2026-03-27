class PokemonDetail {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final bool isDefault;
  final int order;
  final PokemonSprites sprites;
  final List<PokemonType> types;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final PokemonSpeciesRef species;

  final List<NamedResource> forms;
  final List<GameIndex> gameIndices;
  final List<HeldItem> heldItems;
  final String locationAreaEncounters;
  final List<PokemonMove> moves;
  final PokemonCries? cries;
  final List<PastTypeEntry> pastTypes;
  final List<PastAbilityEntry> pastAbilities;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.isDefault,
    required this.order,
    required this.sprites,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.species,
    this.forms = const [],
    this.gameIndices = const [],
    this.heldItems = const [],
    this.locationAreaEncounters = '',
    this.moves = const [],
    this.cries,
    this.pastTypes = const [],
    this.pastAbilities = const [],
  });

  double get heightMetres => height / 10;

  double get weightKg => weight / 10;

  String get primaryType => types.firstWhere((t) => t.slot == 1, orElse: () => types.first).type.name;

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      baseExperience: json['base_experience'] as int? ?? 0,
      height: json['height'] as int,
      weight: json['weight'] as int,
      isDefault: json['is_default'] as bool,
      order: json['order'] as int,
      sprites: PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
      types: (json['types'] as List<dynamic>).map((e) => PokemonType.fromJson(e as Map<String, dynamic>)).toList(),
      abilities: (json['abilities'] as List<dynamic>).map((e) => PokemonAbility.fromJson(e as Map<String, dynamic>)).toList(),
      stats: (json['stats'] as List<dynamic>).map((e) => PokemonStat.fromJson(e as Map<String, dynamic>)).toList(),
      species: PokemonSpeciesRef.fromJson(json['species'] as Map<String, dynamic>),
      forms: (json['forms'] as List<dynamic>? ?? []).map((e) => NamedResource.fromJson(e as Map<String, dynamic>)).toList(),
      gameIndices: (json['game_indices'] as List<dynamic>? ?? []).map((e) => GameIndex.fromJson(e as Map<String, dynamic>)).toList(),
      heldItems: (json['held_items'] as List<dynamic>? ?? []).map((e) => HeldItem.fromJson(e as Map<String, dynamic>)).toList(),
      locationAreaEncounters: json['location_area_encounters'] as String? ?? '',
      moves: (json['moves'] as List<dynamic>? ?? []).map((e) => PokemonMove.fromJson(e as Map<String, dynamic>)).toList(),
      cries: json['cries'] != null ? PokemonCries.fromJson(json['cries'] as Map<String, dynamic>) : null,
      pastTypes: (json['past_types'] as List<dynamic>? ?? []).map((e) => PastTypeEntry.fromJson(e as Map<String, dynamic>)).toList(),
      pastAbilities: (json['past_abilities'] as List<dynamic>? ?? []).map((e) => PastAbilityEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'base_experience': baseExperience,
    'height': height,
    'weight': weight,
    'is_default': isDefault,
    'order': order,
    'sprites': sprites.toJson(),
    'types': types.map((t) => t.toJson()).toList(),
    'abilities': abilities.map((a) => a.toJson()).toList(),
    'stats': stats.map((s) => s.toJson()).toList(),
    'species': species.toJson(),
    'forms': forms.map((f) => f.toJson()).toList(),
    'game_indices': gameIndices.map((g) => g.toJson()).toList(),
    'held_items': heldItems.map((h) => h.toJson()).toList(),
    'location_area_encounters': locationAreaEncounters,
    'moves': moves.map((m) => m.toJson()).toList(),
    'cries': cries?.toJson(),
    'past_types': pastTypes.map((p) => p.toJson()).toList(),
    'past_abilities': pastAbilities.map((p) => p.toJson()).toList(),
  };
}

class PokemonSprites {
  final String? frontDefault;
  final String? frontShiny;
  final String? frontFemale;
  final String? frontShinyFemale;
  final String? backDefault;
  final String? backShiny;
  final String? backFemale;
  final String? backShinyFemale;
  final OfficialArtwork? officialArtwork;
  final DreamWorldSprites? dreamWorld;
  final HomeSprites? home;
  final ShowdownSprites? showdown;

  final Map<String, dynamic>? versions;

  const PokemonSprites({this.frontDefault, this.frontShiny, this.frontFemale, this.frontShinyFemale, this.backDefault, this.backShiny, this.backFemale, this.backShinyFemale, this.officialArtwork, this.dreamWorld, this.home, this.showdown, this.versions});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;
    final dreamWorldRaw = other?['dream_world'] as Map<String, dynamic>?;
    final homeRaw = other?['home'] as Map<String, dynamic>?;
    final showdownRaw = other?['showdown'] as Map<String, dynamic>?;

    return PokemonSprites(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      frontFemale: json['front_female'] as String?,
      frontShinyFemale: json['front_shiny_female'] as String?,
      backDefault: json['back_default'] as String?,
      backShiny: json['back_shiny'] as String?,
      backFemale: json['back_female'] as String?,
      backShinyFemale: json['back_shiny_female'] as String?,
      officialArtwork: artwork != null ? OfficialArtwork.fromJson(artwork) : null,
      dreamWorld: dreamWorldRaw != null ? DreamWorldSprites.fromJson(dreamWorldRaw) : null,
      home: homeRaw != null ? HomeSprites.fromJson(homeRaw) : null,
      showdown: showdownRaw != null ? ShowdownSprites.fromJson(showdownRaw) : null,
      versions: json['versions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'front_default': frontDefault,
    'front_shiny': frontShiny,
    'front_female': frontFemale,
    'front_shiny_female': frontShinyFemale,
    'back_default': backDefault,
    'back_shiny': backShiny,
    'back_female': backFemale,
    'back_shiny_female': backShinyFemale,
    'other': {'official-artwork': officialArtwork?.toJson(), 'dream_world': dreamWorld?.toJson(), 'home': home?.toJson(), 'showdown': showdown?.toJson()},
    'versions': versions,
  };
}

class OfficialArtwork {
  final String? frontDefault;
  final String? frontShiny;

  const OfficialArtwork({this.frontDefault, this.frontShiny});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) => OfficialArtwork(frontDefault: json['front_default'] as String?, frontShiny: json['front_shiny'] as String?);

  Map<String, dynamic> toJson() => {'front_default': frontDefault, 'front_shiny': frontShiny};
}

class DreamWorldSprites {
  final String? frontDefault;
  final String? frontFemale;

  const DreamWorldSprites({this.frontDefault, this.frontFemale});

  factory DreamWorldSprites.fromJson(Map<String, dynamic> json) => DreamWorldSprites(frontDefault: json['front_default'] as String?, frontFemale: json['front_female'] as String?);

  Map<String, dynamic> toJson() => {'front_default': frontDefault, 'front_female': frontFemale};
}

class HomeSprites {
  final String? frontDefault;
  final String? frontFemale;
  final String? frontShiny;
  final String? frontShinyFemale;

  const HomeSprites({this.frontDefault, this.frontFemale, this.frontShiny, this.frontShinyFemale});

  factory HomeSprites.fromJson(Map<String, dynamic> json) =>
      HomeSprites(frontDefault: json['front_default'] as String?, frontFemale: json['front_female'] as String?, frontShiny: json['front_shiny'] as String?, frontShinyFemale: json['front_shiny_female'] as String?);

  Map<String, dynamic> toJson() => {'front_default': frontDefault, 'front_female': frontFemale, 'front_shiny': frontShiny, 'front_shiny_female': frontShinyFemale};
}

class ShowdownSprites {
  final String? frontDefault;
  final String? frontShiny;
  final String? frontFemale;
  final String? frontShinyFemale;
  final String? backDefault;
  final String? backShiny;
  final String? backFemale;
  final String? backShinyFemale;

  const ShowdownSprites({this.frontDefault, this.frontShiny, this.frontFemale, this.frontShinyFemale, this.backDefault, this.backShiny, this.backFemale, this.backShinyFemale});

  factory ShowdownSprites.fromJson(Map<String, dynamic> json) => ShowdownSprites(
    frontDefault: json['front_default'] as String?,
    frontShiny: json['front_shiny'] as String?,
    frontFemale: json['front_female'] as String?,
    frontShinyFemale: json['front_shiny_female'] as String?,
    backDefault: json['back_default'] as String?,
    backShiny: json['back_shiny'] as String?,
    backFemale: json['back_female'] as String?,
    backShinyFemale: json['back_shiny_female'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'front_default': frontDefault,
    'front_shiny': frontShiny,
    'front_female': frontFemale,
    'front_shiny_female': frontShinyFemale,
    'back_default': backDefault,
    'back_shiny': backShiny,
    'back_female': backFemale,
    'back_shiny_female': backShinyFemale,
  };
}

class PokemonCries {
  final String? latest;
  final String? legacy;

  const PokemonCries({this.latest, this.legacy});

  factory PokemonCries.fromJson(Map<String, dynamic> json) => PokemonCries(latest: json['latest'] as String?, legacy: json['legacy'] as String?);

  Map<String, dynamic> toJson() => {'latest': latest, 'legacy': legacy};
}

class GameIndex {
  final int gameIndex;
  final NamedResource version;

  const GameIndex({required this.gameIndex, required this.version});

  factory GameIndex.fromJson(Map<String, dynamic> json) => GameIndex(gameIndex: json['game_index'] as int, version: NamedResource.fromJson(json['version'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'game_index': gameIndex, 'version': version.toJson()};
}

class HeldItemVersionDetail {
  final int rarity;
  final NamedResource version;

  const HeldItemVersionDetail({required this.rarity, required this.version});

  factory HeldItemVersionDetail.fromJson(Map<String, dynamic> json) => HeldItemVersionDetail(rarity: json['rarity'] as int, version: NamedResource.fromJson(json['version'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'rarity': rarity, 'version': version.toJson()};
}

class HeldItem {
  final NamedResource item;
  final List<HeldItemVersionDetail> versionDetails;

  const HeldItem({required this.item, required this.versionDetails});

  factory HeldItem.fromJson(Map<String, dynamic> json) =>
      HeldItem(item: NamedResource.fromJson(json['item'] as Map<String, dynamic>), versionDetails: (json['version_details'] as List<dynamic>).map((e) => HeldItemVersionDetail.fromJson(e as Map<String, dynamic>)).toList());

  Map<String, dynamic> toJson() => {'item': item.toJson(), 'version_details': versionDetails.map((v) => v.toJson()).toList()};
}

class MoveVersionGroupDetail {
  final int levelLearnedAt;
  final NamedResource versionGroup;
  final NamedResource moveLearnMethod;
  final int? order;

  const MoveVersionGroupDetail({required this.levelLearnedAt, required this.versionGroup, required this.moveLearnMethod, this.order});

  factory MoveVersionGroupDetail.fromJson(Map<String, dynamic> json) => MoveVersionGroupDetail(
    levelLearnedAt: json['level_learned_at'] as int,
    versionGroup: NamedResource.fromJson(json['version_group'] as Map<String, dynamic>),
    moveLearnMethod: NamedResource.fromJson(json['move_learn_method'] as Map<String, dynamic>),
    order: json['order'] as int?,
  );

  Map<String, dynamic> toJson() => {'level_learned_at': levelLearnedAt, 'version_group': versionGroup.toJson(), 'move_learn_method': moveLearnMethod.toJson(), 'order': order};
}

class PokemonMove {
  final NamedResource move;
  final List<MoveVersionGroupDetail> versionGroupDetails;

  const PokemonMove({required this.move, required this.versionGroupDetails});

  factory PokemonMove.fromJson(Map<String, dynamic> json) =>
      PokemonMove(move: NamedResource.fromJson(json['move'] as Map<String, dynamic>), versionGroupDetails: (json['version_group_details'] as List<dynamic>).map((e) => MoveVersionGroupDetail.fromJson(e as Map<String, dynamic>)).toList());

  Map<String, dynamic> toJson() => {'move': move.toJson(), 'version_group_details': versionGroupDetails.map((v) => v.toJson()).toList()};
}

class PastTypeEntry {
  final NamedResource generation;
  final List<PokemonType> types;

  const PastTypeEntry({required this.generation, required this.types});

  factory PastTypeEntry.fromJson(Map<String, dynamic> json) =>
      PastTypeEntry(generation: NamedResource.fromJson(json['generation'] as Map<String, dynamic>), types: (json['types'] as List<dynamic>).map((e) => PokemonType.fromJson(e as Map<String, dynamic>)).toList());

  Map<String, dynamic> toJson() => {'generation': generation.toJson(), 'types': types.map((t) => t.toJson()).toList()};
}

class PastAbilityRef {
  final NamedResource? ability;
  final bool isHidden;
  final int slot;

  const PastAbilityRef({required this.ability, required this.isHidden, required this.slot});

  factory PastAbilityRef.fromJson(Map<String, dynamic> json) {
    final abilityRaw = json['ability'];
    return PastAbilityRef(ability: abilityRaw != null ? NamedResource.fromJson(abilityRaw as Map<String, dynamic>) : null, isHidden: json['is_hidden'] as bool, slot: json['slot'] as int);
  }

  Map<String, dynamic> toJson() => {'ability': ability?.toJson(), 'is_hidden': isHidden, 'slot': slot};
}

class PastAbilityEntry {
  final NamedResource generation;
  final List<PastAbilityRef> abilities;

  const PastAbilityEntry({required this.generation, required this.abilities});

  factory PastAbilityEntry.fromJson(Map<String, dynamic> json) =>
      PastAbilityEntry(generation: NamedResource.fromJson(json['generation'] as Map<String, dynamic>), abilities: (json['abilities'] as List<dynamic>).map((e) => PastAbilityRef.fromJson(e as Map<String, dynamic>)).toList());

  Map<String, dynamic> toJson() => {'generation': generation.toJson(), 'abilities': abilities.map((a) => a.toJson()).toList()};
}

class PokemonType {
  final int slot;
  final NamedResource type;

  const PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) => PokemonType(slot: json['slot'] as int, type: NamedResource.fromJson(json['type'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'slot': slot, 'type': type.toJson()};
}

class PokemonAbility {
  final bool isHidden;
  final int slot;
  final NamedResource ability;

  const PokemonAbility({required this.isHidden, required this.slot, required this.ability});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) => PokemonAbility(isHidden: json['is_hidden'] as bool, slot: json['slot'] as int, ability: NamedResource.fromJson(json['ability'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'is_hidden': isHidden, 'slot': slot, 'ability': ability.toJson()};
}

class PokemonStat {
  final int baseStat;
  final int effort;
  final NamedResource stat;

  const PokemonStat({required this.baseStat, required this.effort, required this.stat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) => PokemonStat(baseStat: json['base_stat'] as int, effort: json['effort'] as int, stat: NamedResource.fromJson(json['stat'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {'base_stat': baseStat, 'effort': effort, 'stat': stat.toJson()};
}

class NamedResource {
  final String name;
  final String url;

  const NamedResource({required this.name, required this.url});

  factory NamedResource.fromJson(Map<String, dynamic> json) => NamedResource(name: json['name'] as String, url: json['url'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

class PokemonSpeciesRef {
  final String name;
  final String url;

  const PokemonSpeciesRef({required this.name, required this.url});

  factory PokemonSpeciesRef.fromJson(Map<String, dynamic> json) => PokemonSpeciesRef(name: json['name'] as String, url: json['url'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

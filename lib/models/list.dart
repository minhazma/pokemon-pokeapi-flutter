class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  const PokemonListResponse({required this.count, required this.next, required this.previous, required this.results});

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(count: json['count'] as int, next: json['next'] as String?, previous: json['previous'] as String?, results: (json['results'] as List<dynamic>).map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() => {'count': count, 'next': next, 'previous': previous, 'results': results.map((e) => e.toJson()).toList()};
}

class PokemonListItem {
  final String name;
  final String url;

  final String? officialArtworkUrl;

  const PokemonListItem({required this.name, required this.url, this.officialArtworkUrl});

  int get id {
    final segments = url.split('/')..removeWhere((s) => s.isEmpty);
    return int.tryParse(segments.last) ?? 0;
  }

  String get spriteUrl => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  String get officialArtworkUrlConstructed => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  List<String> get candidateSpriteUrls => [
    officialArtworkUrl,
    officialArtworkUrlConstructed,
    spriteUrl,
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/$id.svg',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif',
  ].whereType<String>().toList();

  String get displayImageUrl => officialArtworkUrl ?? officialArtworkUrlConstructed;

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(name: json['name'] as String, url: json['url'] as String);
  }

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

class PaginatedPokemon {
  final List<PokemonListItem> items;
  final int nextOffset;
  final bool hasMore;
  final int totalCount;

  const PaginatedPokemon({required this.items, required this.nextOffset, required this.hasMore, required this.totalCount});

  const PaginatedPokemon.initial() : items = const [], nextOffset = 0, hasMore = true, totalCount = 0;

  PaginatedPokemon copyWith({List<PokemonListItem>? items, int? nextOffset, bool? hasMore, int? totalCount}) {
    return PaginatedPokemon(items: items ?? this.items, nextOffset: nextOffset ?? this.nextOffset, hasMore: hasMore ?? this.hasMore, totalCount: totalCount ?? this.totalCount);
  }
}

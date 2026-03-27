import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/models/list.dart';

void main() {
  group('PokemonListItem', () {
    test('id - should extract ID from PokeAPI URL', () {
      const item = PokemonListItem(
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon/1/',
      );
      expect(item.id, 1);
    });

    test('id - should handle trailing/leading slashes correctly', () {
      const item = PokemonListItem(
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25',
      );
      expect(item.id, 25);
    });

    test('spriteUrl - should construct correct sprite URL', () {
      const item = PokemonListItem(
        name: 'squirtle',
        url: 'https://pokeapi.co/api/v2/pokemon/7/',
      );
      expect(item.spriteUrl, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png');
    });

    test('fromJson - should parse correctly', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };
      final item = PokemonListItem.fromJson(json);
      expect(item.name, 'bulbasaur');
      expect(item.url, 'https://pokeapi.co/api/v2/pokemon/1/');
    });
  });

  group('PokemonListResponse', () {
    test('fromJson - should parse multiple items correctly', () {
      final json = {
        'count': 1302,
        'next': 'https://pokeapi.co/api/v2/pokemon/?offset=20&limit=20',
        'previous': null,
        'results': [
          {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
          {'name': 'ivysaur', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
        ],
      };
      final response = PokemonListResponse.fromJson(json);
      expect(response.count, 1302);
      expect(response.results, hasLength(2));
      expect(response.results[0].name, 'bulbasaur');
      expect(response.results[1].id, 2);
    });
  });
}

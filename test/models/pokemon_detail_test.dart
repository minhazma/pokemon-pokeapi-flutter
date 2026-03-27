import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/models/detail.dart';

void main() {
  group('PokemonDetail', () {
    final sampleJson = {
      'id': 1,
      'name': 'bulbasaur',
      'base_experience': 64,
      'height': 7,
      'weight': 69,
      'is_default': true,
      'order': 1,
      'sprites': {
        'front_default': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
          }
        }
      },
      'types': [
        {
          'slot': 1,
          'type': {'name': 'grass', 'url': 'https://pokeapi.co/api/v2/type/12/'}
        },
        {
          'slot': 2,
          'type': {'name': 'poison', 'url': 'https://pokeapi.co/api/v2/type/4/'}
        }
      ],
      'abilities': [],
      'stats': [],
      'species': {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon-species/1/'},
    };

    test('fromJson - should parse basic fields correctly', () {
      final detail = PokemonDetail.fromJson(sampleJson);
      expect(detail.id, 1);
      expect(detail.name, 'bulbasaur');
      expect(detail.height, 7);
      expect(detail.weight, 69);
    });

    test('heightMetres - should convert decimetres to metres', () {
      final detail = PokemonDetail.fromJson(sampleJson);
      expect(detail.heightMetres, 0.7);
    });

    test('weightKg - should convert hectograms to kilograms', () {
      final detail = PokemonDetail.fromJson(sampleJson);
      expect(detail.weightKg, 6.9);
    });

    test('primaryType - should return the type in slot 1', () {
      final detail = PokemonDetail.fromJson(sampleJson);
      expect(detail.primaryType, 'grass');
    });

    test('sprites - should parse official artwork correctly', () {
      final detail = PokemonDetail.fromJson(sampleJson);
      expect(detail.sprites.officialArtwork?.frontDefault, contains('official-artwork/1.png'));
    });
  });
}

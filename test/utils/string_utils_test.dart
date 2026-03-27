import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/utils/string_utils.dart';

void main() {
  group('StringUtils Extension', () {
    test('capitalize - should capitalize the first letter', () {
      expect('pikachu'.capitalize, 'Pikachu');
      expect('BULBASAUR'.capitalize, 'BULBASAUR');
      expect(''.capitalize, '');
      expect('a'.capitalize, 'A');
    });

    test('formatName - should capitalize each word separated by hyphen', () {
      expect('charizard-mega-x'.formatName, 'Charizard Mega X');
      expect('mewtwo'.formatName, 'Mewtwo');
      expect('iron-valiant'.formatName, 'Iron Valiant');
    });

    test('formatGenerationName - should capitalize first part and uppercase second part if hyphenated', () {
      expect('generation-i'.formatGenerationName, 'Generation I');
      expect('generation-ix'.formatGenerationName, 'Generation IX');
      expect('national-dex'.formatGenerationName, 'National DEX');
      expect('kanto'.formatGenerationName, 'Kanto');
    });
  });
}

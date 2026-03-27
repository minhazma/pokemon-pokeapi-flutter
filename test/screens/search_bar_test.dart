import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/screens/pokemon_list_screen.dart';
import 'package:pokemon/utils/providers.dart';

void main() {
  testWidgets('Search bar clear button visibility test', (WidgetTester tester) async {
    // Override the provider to return an empty list immediately
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonListStreamProvider.overrideWith((ref, query) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: PokemonListScreen(),
        ),
      ),
    );

    // Rebuild to handle the loading state
    await tester.pump();

    // Initially, the clear button should not be visible
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    // Enter some text
    await tester.enterText(find.byType(TextField), 'bulba');
    await tester.pumpAndSettle();

    // The clear button should now be visible
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Clear the text using the clear button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // The text should be cleared and the button should disappear
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '');
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}

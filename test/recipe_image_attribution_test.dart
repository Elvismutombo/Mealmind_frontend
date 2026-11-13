import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recipes/presentation/widgets/recipe_image_attribution.dart';

void main() {
  testWidgets('shows a Pexels photo credit for a valid photo page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RecipeImageAttribution(
          photographer: 'Camille Dupont',
          sourceUrl: 'https://www.pexels.com/photo/recipe-123/',
        ),
      ),
    );

    expect(find.text('Photo par Camille Dupont sur Pexels'), findsOneWidget);
  });

  testWidgets('does not make untrusted URLs clickable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RecipeImageAttribution(
          photographer: 'Camille Dupont',
          sourceUrl: 'https://example.com/photo',
        ),
      ),
    );

    expect(find.text('Photo par Camille Dupont sur Pexels'), findsNothing);
  });
}

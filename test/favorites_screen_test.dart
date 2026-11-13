import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/favorites/presentation/screens/favorites_screen.dart';

void main() {
  testWidgets('inherits the parent scaffold background', (tester) async {
    final theme = AppTheme.lightTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: FavoritesScreen(
            recipes: const [],
            loading: false,
            error: null,
            onRecipeTap: (_) {},
            onFavorite: (_) {},
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(FavoritesScreen),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });
}

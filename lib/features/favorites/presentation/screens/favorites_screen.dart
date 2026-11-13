import 'package:flutter/material.dart';

import '/features/recipes/presentation/widgets/recipe_card.dart';
import '/features/recipes/presentation/widgets/recipe_shimmer.dart';
import '/core/widgets/empty_state.dart';
import '/core/widgets/load_error.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.recipes,
    required this.loading,
    required this.error,
    required this.onRecipeTap,
    required this.onFavorite,
    required this.onRetry,
    super.key,
  });

  final List<Map<String, dynamic>> recipes;
  final bool loading;
  final String? error;
  final ValueChanged<Map<String, dynamic>> onRecipeTap;
  final ValueChanged<Map<String, dynamic>> onFavorite;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    if (loading) {
      return const RecipeShimmerList();
    }

    if (error != null && recipes.isEmpty) {
      return LoadError(message: error!, onRetry: onRetry);
    }

    if (recipes.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Aucun favori pour le moment',
        detail: 'Ajoute tes recettes préférées pour les retrouver ici.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      itemCount: recipes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return RecipeCard(
          recipe: recipe,
          onTap: () => onRecipeTap(recipe),
          onFavorite: () => onFavorite(recipe),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';
import '/core/widgets/shimmer_image.dart';
import 'recipe_image_attribution.dart';
import 'recipe_info_chip.dart';

class RecipeDetails extends StatelessWidget {
  const RecipeDetails({
    required this.recipe,
    required this.onFavorite,
    required this.onAddIngredients,
    super.key,
  });

  final Map<String, dynamic> recipe;
  final VoidCallback onFavorite;
  final VoidCallback onAddIngredients;

  int get _totalMinutes {
    final preparation = (recipe['preparationMinutes'] as num? ?? 0).toInt();
    final cooking = (recipe['cookingMinutes'] as num? ?? 0).toInt();

    return preparation + cooking;
  }

  @override
  Widget build(BuildContext context) {
    final rawIngredients = recipe['ingredients'];
    final ingredients = rawIngredients is List
        ? rawIngredients.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final rawInstructions = recipe['instructions'];
    final instructions = rawInstructions is List
        ? rawInstructions.whereType<String>().toList()
        : <String>[];

    final imageUrl =
        recipe['imageUrl'] as String? ??
        recipe['image'] as String? ??
        recipe['photo'] as String?;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              ShimmerImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 190,
                borderRadius: 24,
              ),
              RecipeImageAttribution(
                photographer: recipe['imagePhotographer'] as String?,
                sourceUrl: recipe['imageSourceUrl'] as String?,
              ),
              const SizedBox(height: 18),
              Text(
                recipe['title'] as String? ?? 'Recette',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                recipe['description'] as String? ?? '',
                style: TextStyle(color: context.appColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  RecipeInfoChip(
                    icon: Icons.schedule_rounded,
                    label: '$_totalMinutes min',
                  ),
                  RecipeInfoChip(
                    icon: Icons.people_outline_rounded,
                    label: '${recipe['servings'] ?? 2} portions',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAddIngredients,
                      icon: const Icon(Icons.shopping_basket_outlined),
                      label: const Text('Ajouter les ingrédients'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Ajouter ou retirer des favoris',
                    onPressed: onFavorite,
                    icon: Icon(
                      recipe['isFavorite'] == true
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Ingrédients',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (ingredients.isEmpty)
                const Text('Aucun ingrédient renseigné.')
              else
                ...ingredients.map((ingredient) {
                  final name = ingredient['name'] as String? ?? '';
                  final quantity = ingredient['quantity'] as String? ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: context.appColors.success,
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Text(name)),
                        Text(
                          quantity,
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 22),
              Text(
                'Préparation',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (instructions.isEmpty)
                const Text('Aucune instruction renseignée.')
              else
                ...instructions.indexed.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            '${entry.$1 + 1}',
                            style: TextStyle(
                              color: context.appColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.$2)),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

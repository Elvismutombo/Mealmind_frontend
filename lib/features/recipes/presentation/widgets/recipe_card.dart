import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';
import '/core/widgets/shimmer_image.dart';
import 'recipe_image_attribution.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });

  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  int get _totalMinutes {
    final preparation = (recipe['preparationMinutes'] as num? ?? 0).toInt();
    final cooking = (recipe['cookingMinutes'] as num? ?? 0).toInt();

    return preparation + cooking;
  }

  String? get _imageUrl {
    return recipe['imageUrl'] as String? ??
        recipe['image'] as String? ??
        recipe['photo'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final favorite = recipe['isFavorite'] == true;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ShimmerImage(
                imageUrl: _imageUrl,
                width: 82,
                height: 82,
                borderRadius: 16,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['title'] as String? ?? 'Recette sans titre',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe['description'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (recipe['imageSourceUrl'] is String) ...[
                      const SizedBox(height: 2),
                      RecipeImageAttribution(
                        photographer: recipe['imagePhotographer'] as String?,
                        sourceUrl: recipe['imageSourceUrl'] as String?,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: context.appColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalMinutes min',
                          style: TextStyle(
                            color: context.appColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: context.appColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe['servings'] ?? 2} portions',
                          style: TextStyle(
                            color: context.appColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: favorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                onPressed: onFavorite,
                icon: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite
                      ? context.appColors.error
                      : context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

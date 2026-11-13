import '/core/api_client.dart';

class RecipeRepository {
  RecipeRepository(this._api);

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> getRecipes({bool favorites = false}) {
    return _api.recipes(favorites: favorites);
  }

  Future<Map<String, dynamic>> generate({
    required List<String> ingredients,
    String preferences = '',
    int servings = 2,
  }) {
    return _api.generateRecipe(
      ingredients: ingredients,
      preferences: preferences,
      servings: servings,
    );
  }

  Future<void> setFavorite({required String recipeId, required bool favorite}) {
    return _api.setFavorite(recipeId, favorite);
  }

  Future<void> addIngredients(List<Map<String, dynamic>> ingredients) async {
    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String? ?? '';

      if (name.trim().isEmpty) continue;

      await _api.addShoppingItem(name, ingredient['quantity'] as String? ?? '');
    }
  }
}

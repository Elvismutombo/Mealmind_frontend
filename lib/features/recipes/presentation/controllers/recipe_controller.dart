import 'package:flutter/foundation.dart';

import '../../data/recipe_repository.dart';

class RecipeController extends ChangeNotifier {
  RecipeController(this._repository);

  final RecipeRepository _repository;

  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> favorites = [];

  bool loading = false;
  bool generating = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getRecipes(),
        _repository.getRecipes(favorites: true),
      ]);

      recipes = results[0];
      favorites = results[1];
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>? generate({
    required List<String> ingredients,
    String preferences = '',
    int servings = 2,
  }) async {
    if (generating) return null;

    generating = true;
    error = null;
    notifyListeners();

    try {
      final recipe = await _repository.generate(
        ingredients: ingredients,
        preferences: preferences,
        servings: servings,
      );

      await loadSilently();

      return recipe;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      generating = false;
      notifyListeners();
    }
  }

  Future<void> loadSilently() async {
    try {
      final results = await Future.wait([
        _repository.getRecipes(),
        _repository.getRecipes(favorites: true),
      ]);

      recipes = results[0];
      favorites = results[1];
      notifyListeners();
    } catch (_) {
      // Une actualisation secondaire ne doit pas effacer les données.
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> recipe) async {
    final id = _id(recipe);
    if (id.isEmpty) return;

    final previous = recipe['isFavorite'] == true;
    recipe['isFavorite'] = !previous;
    notifyListeners();

    try {
      await _repository.setFavorite(recipeId: id, favorite: !previous);

      await loadSilently();
    } catch (exception) {
      recipe['isFavorite'] = previous;
      error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addIngredients(Map<String, dynamic> recipe) async {
    final rawIngredients = recipe['ingredients'];

    if (rawIngredients is! List) return;

    final ingredients = rawIngredients
        .whereType<Map<String, dynamic>>()
        .toList();

    await _repository.addIngredients(ingredients);
  }

  String _id(Map<String, dynamic> recipe) {
    return recipe['_id']?.toString() ?? recipe['id']?.toString() ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }
}

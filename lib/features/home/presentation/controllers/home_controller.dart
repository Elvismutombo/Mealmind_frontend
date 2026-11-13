import 'package:flutter/foundation.dart';

import '/core/api_client.dart';
import '/features/recipes/presentation/controllers/recipe_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController({required ApiClient api, required this.recipeController})
    : _api = api;

  final ApiClient _api;
  final RecipeController recipeController;

  bool loading = false;
  String? error;

  Map<String, dynamic> shoppingList = {};
  Map<String, dynamic> quota = {};
  Map<String, dynamic> subscription = {};

  Future<void> load() async {
    if (loading) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _api.shoppingList(),
        _api.quota(),
        _api.subscription(),
      ]);

      shoppingList = results[0] as Map<String, dynamic>;
      quota = results[1] as Map<String, dynamic>;
      subscription = results[2] as Map<String, dynamic>;

      await recipeController.load();
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait<Object>([
        _api.shoppingList(),
        _api.quota(),
        _api.subscription(),
      ]);

      shoppingList = results[0] as Map<String, dynamic>;
      quota = results[1] as Map<String, dynamic>;
      subscription = results[2] as Map<String, dynamic>;

      await recipeController.loadSilently();

      notifyListeners();
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addShoppingItem(String name, String quantity) async {
    await _api.addShoppingItem(name, quantity);
    await refresh();
  }

  Future<void> toggleShoppingItem(String id, bool checked) async {
    await _api.updateShoppingItem(id, {'isChecked': checked});
    await refresh();
  }

  Future<void> deleteShoppingItem(String id) async {
    await _api.deleteShoppingItem(id);
    await refresh();
  }

  Future<void> logout() async {
    await _api.logout();
  }
}

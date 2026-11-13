import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/core/api_client.dart';
import '/core/widgets/custom_app_bar.dart';
import '/core/widgets/custom_bottom_bar.dart';
import '/core/widgets/empty_state.dart';

import '/features/home/presentation/controllers/home_controller.dart';
import '/features/home/presentation/widgets/home_greeting.dart';
import '/features/home/presentation/widgets/quota_card.dart';
import '/features/home/presentation/widgets/recipe_search.dart';
import '/features/home/presentation/widgets/generate_recipe_dialog.dart';

import '/features/recipes/data/recipe_repository.dart';
import '/features/recipes/presentation/controllers/recipe_controller.dart';
import '/features/recipes/presentation/utils/recipe_filter.dart';
import '/features/recipes/presentation/widgets/recipe_card.dart';
import '/features/recipes/presentation/widgets/recipe_details.dart';
import '/features/recipes/presentation/widgets/recipe_shimmer.dart';

import '/features/favorites/presentation/screens/favorites_screen.dart';
import '/features/shopping/presentation/screens/shopping_screen.dart';
import '/features/profile/presentation/screens/profile_screen.dart';

import '/services/purchases_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.api,
    required this.purchases,
    required this.user,
    required this.onSignedOut,
    super.key,
  });

  final ApiClient api;
  final PurchasesService purchases;
  final Map<String, dynamic> user;
  final VoidCallback onSignedOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final RecipeController _recipeController;
  late final HomeController _homeController;

  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _selectedTab = 0;
  bool _initialized = false;
  bool _busy = false;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _recipeController = RecipeController(RecipeRepository(widget.api));

    _homeController = HomeController(
      api: widget.api,
      recipeController: _recipeController,
    );

    _homeController.addListener(_onControllerChanged);
    _recipeController.addListener(_onControllerChanged);

    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();

    _homeController.removeListener(_onControllerChanged);
    _recipeController.removeListener(_onControllerChanged);

    _homeController.dispose();
    _recipeController.dispose();

    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _homeController.load();

    if (!mounted) return;

    setState(() => _initialized = true);
  }

  Future<void> _refresh() async {
    try {
      await _homeController.refresh();
    } catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  String get _userName {
    return (widget.user['name'] ?? 'Utilisateur').toString();
  }

  String? get _avatar {
    final value = widget.user['avatar']?.toString();

    if (value == null || value.isEmpty) return null;

    return value;
  }

  String get _appBarTitle {
    switch (_selectedTab) {
      case 1:
        return 'Mes favoris';
      case 2:
        return 'Mes courses';
      case 3:
        return 'Mon profil';
      default:
        return 'MealMind';
    }
  }

  List<Map<String, dynamic>> get _shoppingItems {
    final raw = _homeController.shoppingList['items'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  List<Map<String, dynamic>> get _visibleRecipes {
    return RecipeFilter.filter(
      recipes: _recipeController.recipes,
      query: _searchQuery,
    );
  }

  // --------------------------------------------------
  // NAVIGATION
  // --------------------------------------------------

  void _changeTab(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });

    if (index == 1) {
      _recipeController.loadSilently();
    }
  }

  // --------------------------------------------------
  // RECIPE DETAILS
  // --------------------------------------------------

  void _showRecipe(Map<String, dynamic> recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return RecipeDetails(
          recipe: recipe,
          onFavorite: () async {
            Navigator.of(context).pop();
            await _toggleFavorite(recipe);
          },
          onAddIngredients: () async {
            Navigator.of(context).pop();
            await _addRecipeIngredients(recipe);
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
    try {
      await _recipeController.toggleFavorite(recipe);

      if (mounted) {
        _showMessage(
          recipe['isFavorite'] == true
              ? 'Recette ajoutée aux favoris'
              : 'Recette retirée des favoris',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  Future<void> _addRecipeIngredients(Map<String, dynamic> recipe) async {
    try {
      await _recipeController.addIngredients(recipe);
      await _homeController.refresh();

      if (mounted) {
        _showMessage('Ingrédients ajoutés à ta liste de courses');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  // --------------------------------------------------
  // GENERATE RECIPE WITH AI
  // --------------------------------------------------

  Future<void> _showGenerateDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const GenerateRecipeDialog(),
    );

    if (result == null || !mounted) return;

    await _generateRecipe(
      ingredients: result['ingredients'] as List<String>,
      preferences: result['preferences'] as String,
    );
  }

  Future<void> _generateRecipe({
    required List<String> ingredients,
    required String preferences,
  }) async {
    if (_recipeController.generating) return;

    try {
      final recipe = await _recipeController.generate(
        ingredients: ingredients,
        preferences: preferences,
        servings: 2,
      );

      if (recipe == null || !mounted) return;

      _showMessage('Ta recette a été générée !');
      _showRecipe(recipe);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  // --------------------------------------------------
  // SHOPPING LIST
  // --------------------------------------------------

  Future<void> _addShoppingItem(String name, String quantity) async {
    try {
      await _homeController.addShoppingItem(name, quantity);

      if (mounted) {
        _showMessage('Article ajouté');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
      rethrow;
    }
  }

  Future<void> _toggleShoppingItem(Map<String, dynamic> item) async {
    final id = _shoppingItemId(item);
    if (id.isEmpty) {
      _showMessage('Impossible d’identifier cet article.', isError: true);
      return;
    }

    final isChecked = item['isChecked'] == true || item['completed'] == true;

    try {
      await _homeController.toggleShoppingItem(id, !isChecked);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  Future<void> _deleteShoppingItem(Map<String, dynamic> item) async {
    final id = _shoppingItemId(item);
    if (id.isEmpty) {
      _showMessage('Impossible d’identifier cet article.', isError: true);
      return;
    }

    try {
      await _homeController.deleteShoppingItem(id);

      if (mounted) {
        _showMessage('Article supprimé');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  String _shoppingItemId(Map<String, dynamic> item) {
    return (item['id'] ?? item['_id'] ?? '').toString();
  }

  // --------------------------------------------------
  // PROFILE: EDIT NAME
  // --------------------------------------------------

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier ton nom'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 2) return;

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null || !mounted) return;

    try {
      await widget.api.updateProfile(name);

      widget.user['name'] = name;

      if (mounted) {
        setState(() {});
        _showMessage('Nom modifié avec succès');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  // --------------------------------------------------
  // PROFILE: CHANGE PASSWORD
  // --------------------------------------------------

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  helperText: '8 caractères minimum',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final current = currentController.text;
                final password = newController.text;

                if (current.isEmpty || password.length < 8) return;

                Navigator.pop(dialogContext, {
                  'current': current,
                  'new': password,
                });
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();

    if (values == null || !mounted) return;

    try {
      await widget.api.changePassword(
        currentPassword: values['current']!,
        newPassword: values['new']!,
      );

      if (mounted) {
        _showMessage('Mot de passe modifié avec succès');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  // --------------------------------------------------
  // PROFILE: AVATAR / CLOUDINARY
  // --------------------------------------------------

  Future<void> _changeAvatar() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (image == null || !mounted) return;

      setState(() => _busy = true);

      final response = await widget.api.uploadAvatar(image);

      final data = response['data'];

      if (data is Map) {
        final updatedUser = data['user'];

        if (updatedUser is Map && updatedUser['avatar'] != null) {
          widget.user['avatar'] = updatedUser['avatar'];
        } else if (data['avatar'] != null) {
          widget.user['avatar'] = data['avatar'];
        }
      }

      if (mounted) {
        setState(() {});
        _showMessage('Photo de profil mise à jour');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // --------------------------------------------------
  // REVENUECAT
  // --------------------------------------------------

  Future<void> _showPaywall() async {
    final userId = (widget.user['id'] ?? widget.user['_id'] ?? '').toString();

    if (userId.isEmpty) {
      _showMessage('Impossible d’identifier ton compte.', isError: true);
      return;
    }

    try {
      await widget.purchases.logIn(userId);

      final packages = await widget.purchases.offerings();

      if (!mounted) return;

      if (packages.isEmpty) {
        _showMessage('Aucune offre Premium disponible.');
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          final colors = Theme.of(sheetContext).colorScheme;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passe à MealMind Premium',
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profite d’une expérience de cuisine plus complète.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  const _PremiumFeature(
                    icon: Icons.auto_awesome_rounded,
                    text: 'Plus de générations de recettes IA',
                  ),
                  const _PremiumFeature(
                    icon: Icons.restaurant_menu_rounded,
                    text: 'Une expérience sans limites réduites',
                  ),
                  const _PremiumFeature(
                    icon: Icons.workspace_premium_rounded,
                    text: 'Accès aux fonctionnalités Premium',
                  ),
                  const SizedBox(height: 20),
                  ...packages.map((package) {
                    final product = package.storeProduct;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            try {
                              await widget.purchases.purchase(package);

                              if (!mounted) return;

                              Navigator.of(sheetContext).pop();
                              await _refresh();

                              if (mounted) {
                                _showMessage('Achat effectué avec succès');
                              }
                            } catch (error) {
                              if (mounted) {
                                _showMessage(error.toString(), isError: true);
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              children: [
                                Text(product.title),
                                Text(
                                  product.priceString,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final userId = (widget.user['id'] ?? widget.user['_id'] ?? '').toString();

      if (userId.isNotEmpty) {
        await widget.purchases.logIn(userId);
      }

      await widget.purchases.restore();
      await _refresh();

      if (mounted) {
        _showMessage('Restauration des achats terminée');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Veux-tu vraiment te déconnecter de MealMind ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _homeController.logout();
      await widget.purchases.logOut();
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), isError: true);
      }
    } finally {
      if (mounted) widget.onSignedOut();
    }
  }

  // --------------------------------------------------
  // EXPLORE SCREEN
  // --------------------------------------------------

  Widget _buildExplore() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!_initialized || _homeController.loading) {
      return const RecipeShimmerList(itemCount: 4);
    }

    if (_homeController.error != null && _recipeController.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(_homeController.error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          HomeGreeting(name: _userName),
          const SizedBox(height: 20),

          QuotaCard(quota: _homeController.quota, onUpgrade: _showPaywall),

          const SizedBox(height: 22),

          RecipeSearch(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: Text(
                  _searchQuery.isEmpty
                      ? 'Tes recettes récentes'
                      : 'Résultats de recherche',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_visibleRecipes.length}',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_recipeController.loading)
            const RecipeShimmerList(itemCount: 3)
          else if (_visibleRecipes.isEmpty)
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: _searchQuery.isEmpty ? 'Aucune recette' : 'Aucun résultat',
              detail: _searchQuery.isEmpty
                  ? 'Génère ta première recette avec l’intelligence artificielle.'
                  : 'Essaie avec un autre ingrédient ou un autre nom.',
            )
          else
            ..._visibleRecipes.map(
              (recipe) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecipeCard(
                  recipe: recipe,
                  onTap: () => _showRecipe(recipe),
                  onFavorite: () => _toggleFavorite(recipe),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MAIN BUILD
  // --------------------------------------------------

  Widget _buildCurrentScreen() {
    switch (_selectedTab) {
      case 1:
        return FavoritesScreen(
          recipes: _recipeController.favorites,
          loading: _recipeController.loading,
          error: _recipeController.error,
          onRecipeTap: _showRecipe,
          onFavorite: _toggleFavorite,
          onRetry: _recipeController.load,
        );

      case 2:
        return ShoppingScreen(
          items: _shoppingItems,
          onAdd: _addShoppingItem,
          onToggle: _toggleShoppingItem,
          onDelete: _deleteShoppingItem,
        );

      case 3:
        return ProfileScreen(
          user: widget.user,
          quota: _homeController.quota,
          subscription: _homeController.subscription,
          onEditName: _editName,
          onChangeAvatar: _changeAvatar,
          onChangePassword: _changePassword,
          onUpgrade: _showPaywall,
          onRestorePurchases: _restorePurchases,
          onLogout: _logout,
        );

      default:
        return _buildExplore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _appBarTitle,
        name: _userName,
        avatar: _avatar,
        actions: _selectedTab == 0
            ? [
                IconButton(
                  tooltip: 'Actualiser',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ]
            : [],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildCurrentScreen()),

          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: .12),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              heroTag: 'generate-recipe',
              tooltip: 'Générer une recette avec l’IA',
              onPressed: _recipeController.generating
                  ? null
                  : _showGenerateDialog,
              icon: _recipeController.generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _recipeController.generating
                    ? 'Génération...'
                    : 'Créer une recette',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _changeTab,
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

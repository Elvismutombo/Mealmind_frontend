class RecipeFilter {
  static List<Map<String, dynamic>> filter({
    required List<Map<String, dynamic>> recipes,
    required String query,
  }) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return recipes;

    return recipes.where((recipe) {
      final ingredients = recipe['ingredients'];

      final searchable = [
        recipe['title'],
        recipe['description'],
        if (ingredients is List)
          ...ingredients.whereType<Map<String, dynamic>>().map(
            (ingredient) => ingredient['name'],
          ),
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(search);
    }).toList();
  }
}

import 'package:flutter/material.dart';

class GenerateRecipeDialog extends StatefulWidget {
  const GenerateRecipeDialog({super.key});

  @override
  State<GenerateRecipeDialog> createState() => _GenerateRecipeDialogState();
}

class _GenerateRecipeDialogState extends State<GenerateRecipeDialog> {
  final _ingredientsController = TextEditingController();
  final _preferencesController = TextEditingController();

  @override
  void dispose() {
    _ingredientsController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  void _submit() {
    final ingredients = _ingredientsController.text
        .split(RegExp(r'[,;\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) return;

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop({
      'ingredients': ingredients,
      'preferences': _preferencesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Créer une recette'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Indique les ingrédients que tu as disponibles.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ingrédients',
                hintText: 'Tomates, riz, oignons...',
                prefixIcon: Icon(Icons.restaurant_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _preferencesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Préférences (facultatif)',
                hintText: 'Sans piment, végétarien...',
                prefixIcon: Icon(Icons.tune_rounded),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Générer')),
      ],
    );
  }
}

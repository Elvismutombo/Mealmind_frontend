import 'package:flutter/material.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({
    required this.items,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final List<Map<String, dynamic>> items;
  final Future<void> Function(String name, String quantity) onAdd;
  final Future<void> Function(Map<String, dynamic> item) onToggle;
  final Future<void> Function(Map<String, dynamic> item) onDelete;

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty || _adding) return;

    setState(() => _adding = true);

    try {
      await widget.onAdd(name, quantity);
      _nameController.clear();
      _quantityController.clear();
    } finally {
      if (mounted) {
        setState(() => _adding = false);
      }
    }
  }

  String _id(Map<String, dynamic> item) {
    return (item['id'] ?? item['_id'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text(
          'Ta liste de courses',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Garde une trace de ce dont tu as besoin.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addItem(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        hintText: 'Ex. : 500 g',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _adding ? null : _addItem,
                      child: _adding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Text(
              'Articles',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.items.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.items.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 38,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ta liste est vide',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ajoute un article ou importe les ingrédients d’une recette.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ...widget.items.map((item) {
            final checked =
                item['isChecked'] == true || item['completed'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 9),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .4),
                ),
              ),
              child: ListTile(
                leading: Checkbox(
                  value: checked,
                  onChanged: (_) => widget.onToggle(item),
                ),
                title: Text(
                  (item['name'] ?? 'Article').toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color: checked ? colors.onSurfaceVariant : null,
                  ),
                ),
                subtitle: (item['quantity'] ?? '').toString().isEmpty
                    ? null
                    : Text(item['quantity'].toString()),
                trailing: IconButton(
                  tooltip: 'Supprimer',
                  onPressed: () => widget.onDelete(item),
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                ),
              ),
            );
          }),
      ],
    );
  }
}

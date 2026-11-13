import 'package:flutter/material.dart';

import '/features/shopping/presentation/widgets/shopping_list_view.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({
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
  Widget build(BuildContext context) {
    return ShoppingListView(
      items: items,
      onAdd: onAdd,
      onToggle: onToggle,
      onDelete: onDelete,
    );
  }
}

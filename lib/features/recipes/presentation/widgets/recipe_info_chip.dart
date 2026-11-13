import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';

class RecipeInfoChip extends StatelessWidget {
  const RecipeInfoChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: context.appColors.primary),
      label: Text(label),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}

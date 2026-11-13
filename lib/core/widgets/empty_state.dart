import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 38, color: context.appColors.secondary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
            if (action != null && onPressed != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onPressed, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour $name 👋',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Qu’est-ce qu’on cuisine aujourd’hui ?',
          style: TextStyle(color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}

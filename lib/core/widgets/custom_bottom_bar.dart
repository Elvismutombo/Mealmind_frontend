import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    _Destination(
      icon: Icons.restaurant_menu_rounded,
      activeIcon: Icons.restaurant_rounded,
      label: 'Explorer',
    ),
    _Destination(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Favoris',
    ),
    _Destination(
      icon: Icons.shopping_basket_outlined,
      activeIcon: Icons.shopping_basket_rounded,
      label: 'Courses',
    ),
    _Destination(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_destinations.length, (index) {
            final destination = _destinations[index];
            final selected = selectedIndex == index;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onDestinationSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primaryContainer.withValues(alpha: 0.7)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? destination.activeIcon : destination.icon,
                        size: 22,
                        color: selected
                            ? context.appColors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: selected
                              ? context.appColors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

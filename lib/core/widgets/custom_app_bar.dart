import 'package:flutter/material.dart';

import '/core/theme/app_theme_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.avatar,
    this.name,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? avatar;
  final String? name;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Icon(Icons.eco_rounded, color: context.appColors.primary, size: 25),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: CircleAvatar(
            radius: 19,
            backgroundColor: colors.primaryContainer,
            backgroundImage: avatar != null && avatar!.isNotEmpty
                ? NetworkImage(avatar!)
                : null,
            child: avatar == null || avatar!.isEmpty
                ? Text(
                    name != null && name!.isNotEmpty
                        ? name![0].toUpperCase()
                        : 'M',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 0.7,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

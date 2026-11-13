import 'package:flutter/material.dart';

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showArrow = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (iconColor ?? colors.primary).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor ?? colors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: showArrow ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
    );
  }
}

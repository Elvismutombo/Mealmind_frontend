import 'package:flutter/material.dart';

import '/core/widgets/shimmer_image.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.email,
    required this.avatar,
    required this.onEditName,
    required this.onChangeAvatar,
    super.key,
  });

  final String name;
  final String email;
  final String? avatar;
  final VoidCallback onEditName;
  final VoidCallback onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipOval(
              child: avatar != null && avatar!.isNotEmpty
                  ? ShimmerImage(
                      imageUrl: avatar!,
                      width: 104,
                      height: 104,
                      borderRadius: 100,
                    )
                  : Container(
                      width: 104,
                      height: 104,
                      color: colors.primaryContainer,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
            ),
            Material(
              color: colors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onChangeAvatar,
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 17,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name.isEmpty ? 'Utilisateur' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Modifier le nom',
              onPressed: onEditName,
              icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
            ),
          ],
        ),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '/features/profile/presentation/widgets/profile_header.dart';
import '/features/profile/presentation/widgets/profile_actions.dart';
import '/features/home/presentation/widgets/quota_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.user,
    required this.quota,
    required this.subscription,
    required this.onEditName,
    required this.onChangeAvatar,
    required this.onChangePassword,
    required this.onUpgrade,
    required this.onRestorePurchases,
    required this.onLogout,
    super.key,
  });

  final Map<String, dynamic> user;
  final Map<String, dynamic> quota;
  final Map<String, dynamic> subscription;

  final VoidCallback onEditName;
  final VoidCallback onChangeAvatar;
  final VoidCallback onChangePassword;
  final VoidCallback onUpgrade;
  final VoidCallback onRestorePurchases;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = (user['name'] ?? '').toString();
    final email = (user['email'] ?? '').toString();
    final avatar = user['avatar']?.toString();

    final isPremium =
        subscription['isPremium'] == true || subscription['status'] == 'active';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text(
          'Mon profil',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),

        ProfileHeader(
          name: name,
          email: email,
          avatar: avatar,
          onEditName: onEditName,
          onChangeAvatar: onChangeAvatar,
        ),

        const SizedBox(height: 28),

        QuotaCard(quota: quota, onUpgrade: onUpgrade),

        const SizedBox(height: 28),

        Text(
          'Mon compte',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),

        ProfileActionTile(
          icon: Icons.lock_outline_rounded,
          title: 'Mot de passe',
          subtitle: 'Modifier ton mot de passe',
          onTap: onChangePassword,
        ),

        const SizedBox(height: 20),

        Text(
          'Abonnement',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),

        ProfileActionTile(
          icon: Icons.workspace_premium_outlined,
          title: isPremium ? 'Abonnement Premium' : 'Passer à Premium',
          subtitle: isPremium
              ? 'Profite de toutes les fonctionnalités'
              : 'Débloque davantage de générations',
          onTap: onUpgrade,
        ),

        ProfileActionTile(
          icon: Icons.restore_rounded,
          title: 'Restaurer les achats',
          subtitle: 'Retrouver un abonnement existant',
          onTap: onRestorePurchases,
        ),

        const SizedBox(height: 20),

        Text(
          'Session',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),

        ProfileActionTile(
          icon: Icons.logout_rounded,
          title: 'Déconnexion',
          subtitle: 'Se déconnecter de MealMind',
          iconColor: colors.error,
          showArrow: false,
          onTap: onLogout,
        ),

        const SizedBox(height: 24),

        Center(
          child: Text(
            'MealMind • Cuisiner plus intelligemment',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import '../../domain/auth_mode.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.mode, super.key});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppThemeExtension>()!;
    final colorScheme = theme.colorScheme;

    final (title, subtitle) = switch (mode) {
      AuthMode.login => (
        'Ravie de te revoir',
        'Retrouve tes recettes et tes inspirations culinaires.',
      ),
      AuthMode.register => (
        'Bienvenue chez toi',
        'Crée ton compte et découvre une nouvelle façon de cuisiner.',
      ),
      AuthMode.verifyEmail => (
        'Vérifie ton e-mail',
        'Saisis le code à 6 chiffres que nous t’avons envoyé.',
      ),
      AuthMode.forgotPassword => (
        'Mot de passe oublié ?',
        'Nous allons t’aider à retrouver l’accès à ton compte.',
      ),
      AuthMode.resetPassword => (
        'Nouveau mot de passe',
        'Saisis le code reçu et définis ton nouveau mot de passe.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'MEALMIND',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            letterSpacing: 3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

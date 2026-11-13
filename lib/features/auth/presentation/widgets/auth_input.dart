import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_theme_extensions.dart';

class AuthInput extends StatelessWidget {
  const AuthInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeExtension>()!;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(
            color: colors.textSecondary.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
    );
  }
}

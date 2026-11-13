import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        side: BorderSide(color: Theme.of(context).dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'G',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          const Text('Continuer avec Google'),
        ],
      ),
    );
  }
}

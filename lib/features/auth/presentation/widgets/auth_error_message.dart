import 'package:flutter/material.dart';

class AuthFeedback extends StatelessWidget {
  const AuthFeedback({required this.message, this.isError = true, super.key});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final background = isError
        ? scheme.errorContainer
        : scheme.primaryContainer;

    final foreground = isError
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

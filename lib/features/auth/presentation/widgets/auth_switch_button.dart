import 'package:flutter/material.dart';

class AuthSwitchButton extends StatelessWidget {
  const AuthSwitchButton({
    required this.question,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question),
        TextButton(
          onPressed: onPressed,
          child: Text(
            action,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';

import '../../../../core/api_client.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../data/auth_repository.dart';
import '../../domain/auth_mode.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_switch_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.api,
    required this.onAuthenticated,
    super.key,
  });

  final ApiClient api;
  final ValueChanged<Map<String, dynamic>> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();

  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(AuthRepository(widget.api));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _needsEmail => _controller.mode != AuthMode.verifyEmail;

  bool get _needsPassword =>
      _controller.mode == AuthMode.login ||
      _controller.mode == AuthMode.register ||
      _controller.mode == AuthMode.resetPassword;

  bool get _needsCode =>
      _controller.mode == AuthMode.verifyEmail ||
      _controller.mode == AuthMode.resetPassword;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.submit(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      code: _code.text,
    );

    if (!mounted) return;

    if (result != null) {
      widget.onAuthenticated(result);
      return;
    }

    // Effacer les champs temporaires après une opération réussie.
    if (_controller.error == null) {
      _code.clear();

      if (_controller.mode == AuthMode.login) {
        _password.clear();
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    final result = await _controller.continueWithGoogle();

    if (!mounted || result == null) return;

    widget.onAuthenticated(result);
  }

  void _changeMode(AuthMode mode) {
    _controller.setMode(mode);
    _password.clear();
    _code.clear();
  }

  String _primaryLabel(AuthMode mode) {
    return switch (mode) {
      AuthMode.login => 'Me connecter',
      AuthMode.register => 'Créer mon compte',
      AuthMode.verifyEmail => 'Vérifier mon adresse',
      AuthMode.forgotPassword => 'Envoyer le code',
      AuthMode.resetPassword => 'Changer mon mot de passe',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final mode = _controller.mode;
                  final isLogin = mode == AuthMode.login;
                  final isRegister = mode == AuthMode.register;
                  final isVerification = mode == AuthMode.verifyEmail;
                  final isForgot = mode == AuthMode.forgotPassword;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        AuthHeader(mode: mode),

                        const SizedBox(height: AppSpacing.xl),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (isRegister) ...[
                                AuthInput(
                                  controller: _name,
                                  label: 'Ton prénom',
                                  icon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if ((value?.trim().length ?? 0) < 2) {
                                      return 'Entre au moins 2 caractères';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              if (_needsEmail) ...[
                                AuthInput(
                                  controller: _email,
                                  label: 'Adresse e-mail',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';

                                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(email)) {
                                      return 'Adresse e-mail invalide';
                                    }

                                    return null;
                                  },
                                ),
                              ],

                              if (_needsPassword) ...[
                                const SizedBox(height: AppSpacing.md),
                                AuthInput(
                                  controller: _password,
                                  label: mode == AuthMode.resetPassword
                                      ? 'Nouveau mot de passe'
                                      : 'Mot de passe',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _controller.obscurePassword,
                                  textInputAction: _needsCode
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  suffix: IconButton(
                                    onPressed:
                                        _controller.togglePasswordVisibility,
                                    icon: Icon(
                                      _controller.obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value?.length ?? 0) < 8) {
                                      return '8 caractères minimum';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              if (_needsCode) ...[
                                const SizedBox(height: AppSpacing.md),
                                AuthInput(
                                  controller: _code,
                                  label: isVerification
                                      ? 'Code de vérification'
                                      : 'Code de réinitialisation',
                                  icon: Icons.verified_user_outlined,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (!RegExp(r'^\d{6}$')
                                        .hasMatch(value?.trim() ?? '')) {
                                      return 'Entre le code à 6 chiffres';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (_controller.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AuthFeedback(message: _controller.error!),
                        ],

                        if (_controller.message != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AuthFeedback(
                            message: _controller.message!,
                            isError: false,
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        AuthPrimaryButton(
                          label: _primaryLabel(mode),
                          loading: _controller.busy,
                          onPressed: _controller.busy ? null : _submit,
                        ),

                        if (isVerification) ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: _controller.busy
                                ? null
                                : () => _controller.resendVerification(
                                    _email.text,
                                  ),
                            child: const Text('Renvoyer le code'),
                          ),
                          TextButton(
                            onPressed: _controller.busy
                                ? null
                                : () => _changeMode(AuthMode.login),
                            child: const Text('Retour à la connexion'),
                          ),
                        ] else if (isForgot ||
                            mode == AuthMode.resetPassword) ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: _controller.busy
                                ? null
                                : () => _changeMode(AuthMode.login),
                            child: const Text('Retour à la connexion'),
                          ),
                        ] else ...[
                          const SizedBox(height: AppSpacing.lg),

                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Text(
                                  'OU',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          AuthGoogleButton(
                            loading: _controller.busy,
                            onPressed: _controller.busy
                                ? null
                                : _continueWithGoogle,
                          ),

                          if (isLogin) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: _controller.busy
                                  ? null
                                  : () => _changeMode(AuthMode.forgotPassword),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          AuthSwitchButton(
                            question: isRegister
                                ? 'Tu as déjà un compte ?'
                                : 'Nouveau chez MealMind ?',
                            action: isRegister
                                ? 'Se connecter'
                                : 'Créer un compte',
                            onPressed: _controller.busy
                                ? () {}
                                : () => _changeMode(
                                    isRegister
                                        ? AuthMode.login
                                        : AuthMode.register,
                                  ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'En continuant, tu acceptes nos conditions '
                          'd’utilisation et notre politique de confidentialité.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

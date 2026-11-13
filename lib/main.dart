import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bloc/app_bloc.dart';
import 'app/bloc/app_event.dart';
import 'app/bloc/app_state.dart';
import 'app/data/app_session_repository.dart';
import 'core/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'services/purchases_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MealMindApp(preferences: preferences));
}

class MealMindApp extends StatelessWidget {
  MealMindApp({
    required this.preferences,
    ApiClient? api,
    PurchasesService? purchases,
    super.key,
  }) : api = api ?? ApiClient(),
       purchases = purchases ?? PurchasesService();

  final SharedPreferences preferences;
  final ApiClient api;
  final PurchasesService purchases;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(
        sessionRepository: ApiAppSessionRepository(api),
        preferences: preferences,
      )..add(const AppStarted()),
      child: MaterialApp(
        title: 'MealMind IA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return switch (state.status) {
              AppStatus.initializing => const _SplashScreen(),
              AppStatus.onboarding => OnboardingScreen(
                onCompleted: () =>
                    context.read<AppBloc>().add(const OnboardingCompleted()),
              ),
              AppStatus.unauthenticated => AuthScreen(
                api: api,
                onAuthenticated: (result) => context.read<AppBloc>().add(
                  AuthenticationSucceeded(result),
                ),
              ),
              AppStatus.authenticated => HomeScreen(
                api: api,
                purchases: purchases,
                user: state.user ?? const <String, dynamic>{},
                onSignedOut: () =>
                    context.read<AppBloc>().add(const AppSignedOut()),
              ),
              AppStatus.failure => _ConnectionError(
                message: state.errorMessage ?? 'Une erreur est survenue.',
                onRetry: () =>
                    context.read<AppBloc>().add(const AppRetryRequested()),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class _ConnectionError extends StatelessWidget {
  const _ConnectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Impossible de joindre MealMind',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    ),
  );
}

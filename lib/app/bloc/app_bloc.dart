import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_session_repository.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required this.sessionRepository, required this.preferences})
    : super(const AppState.initializing()) {
    on<AppStarted>(_initialize);
    on<AppRetryRequested>(_initialize);
    on<OnboardingCompleted>(_completeOnboarding);
    on<AuthenticationSucceeded>((event, emit) {
      final user = event.result['user'] is Map<String, dynamic>
          ? event.result['user'] as Map<String, dynamic>
          : <String, dynamic>{};
      emit(AppState.authenticated(user));
    });
    on<AppSignedOut>((event, emit) {
      emit(const AppState.unauthenticated());
    });
  }

  static const onboardingPreferenceKey = 'onboarding_seen_v1';

  final AppSessionRepository sessionRepository;
  final SharedPreferences preferences;

  Future<void> _initialize(AppEvent event, Emitter<AppState> emit) async {
    emit(const AppState.initializing());

    try {
      if (preferences.getBool(onboardingPreferenceKey) != true) {
        emit(const AppState.onboarding());
        return;
      }

      await _restoreSession(emit);
    } catch (error) {
      emit(AppState.failure(error.toString()));
    }
  }

  Future<void> _completeOnboarding(
    OnboardingCompleted event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppState.initializing());

    try {
      final saved = await preferences.setBool(onboardingPreferenceKey, true);
      if (!saved) {
        throw StateError('Impossible d’enregistrer la fin de l’onboarding.');
      }

      await _restoreSession(emit);
    } catch (error) {
      emit(AppState.failure(error.toString()));
    }
  }

  Future<void> _restoreSession(Emitter<AppState> emit) async {
    final user = await sessionRepository.restoreSession();
    if (user == null) {
      emit(const AppState.unauthenticated());
      return;
    }

    emit(AppState.authenticated(user));
  }
}

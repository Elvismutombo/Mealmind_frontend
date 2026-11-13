sealed class AppEvent {
  const AppEvent();
}

final class AppStarted extends AppEvent {
  const AppStarted();
}

final class AppRetryRequested extends AppEvent {
  const AppRetryRequested();
}

final class OnboardingCompleted extends AppEvent {
  const OnboardingCompleted();
}

final class AuthenticationSucceeded extends AppEvent {
  const AuthenticationSucceeded(this.result);

  final Map<String, dynamic> result;
}

final class AppSignedOut extends AppEvent {
  const AppSignedOut();
}

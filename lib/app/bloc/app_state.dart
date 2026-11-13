enum AppStatus {
  initializing,
  onboarding,
  unauthenticated,
  authenticated,
  failure,
}

class AppState {
  const AppState({required this.status, this.user, this.errorMessage});

  const AppState.initializing() : this(status: AppStatus.initializing);

  const AppState.onboarding() : this(status: AppStatus.onboarding);

  const AppState.unauthenticated() : this(status: AppStatus.unauthenticated);

  const AppState.authenticated(Map<String, dynamic> user)
    : this(status: AppStatus.authenticated, user: user);

  const AppState.failure(String message)
    : this(status: AppStatus.failure, errorMessage: message);

  final AppStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;
}

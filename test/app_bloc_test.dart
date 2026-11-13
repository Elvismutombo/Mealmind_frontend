import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/bloc/app_bloc.dart';
import 'package:mobile/app/bloc/app_event.dart';
import 'package:mobile/app/bloc/app_state.dart';
import 'package:mobile/app/data/app_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionRepository implements AppSessionRepository {
  int restoreCalls = 0;
  Map<String, dynamic>? restoredUser;

  @override
  Future<Map<String, dynamic>?> restoreSession() async {
    restoreCalls++;
    return restoredUser;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('shows onboarding on first launch and stores completion', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeSessionRepository();
    final bloc = AppBloc(
      sessionRepository: repository,
      preferences: preferences,
    );
    addTearDown(bloc.close);

    bloc.add(const AppStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AppStatus.onboarding,
    );

    expect(repository.restoreCalls, 0);

    bloc.add(const OnboardingCompleted());
    await bloc.stream.firstWhere(
      (state) => state.status == AppStatus.unauthenticated,
    );

    expect(preferences.getBool(AppBloc.onboardingPreferenceKey), isTrue);
    expect(repository.restoreCalls, 1);
  });

  test('skips onboarding after it has already been completed', () async {
    SharedPreferences.setMockInitialValues({
      AppBloc.onboardingPreferenceKey: true,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeSessionRepository()
      ..restoredUser = {'name': 'Amina'};
    final bloc = AppBloc(
      sessionRepository: repository,
      preferences: preferences,
    );
    addTearDown(bloc.close);

    bloc.add(const AppStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AppStatus.authenticated,
    );

    expect(bloc.state.user, {'name': 'Amina'});
    expect(repository.restoreCalls, 1);
  });
}

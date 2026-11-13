import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('skip completes onboarding', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onCompleted: () => completed = true)),
    );

    expect(find.text('La cuisine commence avec une idée.'), findsOneWidget);
    await tester.tap(find.text('Passer'));

    expect(completed, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/presentation/widgets/generate_recipe_dialog.dart';

class _DialogHarness extends StatefulWidget {
  const _DialogHarness();

  @override
  State<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends State<_DialogHarness> {
  Map<String, dynamic>? result;

  Future<void> _openDialog() async {
    final dialogResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const GenerateRecipeDialog(),
    );

    if (!mounted || dialogResult == null) return;
    setState(() => result = dialogResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(onPressed: _openDialog, child: const Text('Ouvrir')),
          if (result != null)
            Text((result!['ingredients'] as List<String>).join(', ')),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('keeps text controllers alive until the dialog is dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _DialogHarness()));

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Tomates, riz');
    await tester.tap(find.text('Générer'));
    await tester.pumpAndSettle();

    expect(find.text('Tomates, riz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can dismiss the dialog with a focused text field', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _DialogHarness()));

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

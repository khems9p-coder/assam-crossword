import 'package:assamcrossword/services/score_service.dart';
import 'package:assamcrossword/theme/app_theme.dart';
import 'package:assamcrossword/widgets/celebration_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the celebration lets the player look at the solved puzzle',
      (tester) async {
    FinishChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  choice = await CelebrationDialog.show(
                    context,
                    title: 'Test #1',
                    result: const GameResult(
                      seconds: 60,
                      points: 150,
                      stars: 3,
                      countsForBestTime: true,
                      isNewBest: false,
                      previousBest: null,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('View solved puzzle'), findsOneWidget);

    await tester.ensureVisible(find.text('View solved puzzle'));
    await tester.tap(find.text('View solved puzzle'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(choice, FinishChoice.review);
    expect(find.text('View solved puzzle'), findsNothing);
  });
}

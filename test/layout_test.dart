import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assamcrossword/data/question_bank.dart';
import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/models/difficulty.dart';
import 'package:assamcrossword/services/app_state.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:assamcrossword/widgets/clue_panel.dart';
import 'package:assamcrossword/widgets/menu_button.dart';

void main() {
  testWidgets('clues are visible in portrait, landscape and on phones',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    await AppState.instance.resetLocalData();
    await tester.runAsync(() => QuestionBank.instance.load());
    AppState.instance.selectTopic('assam_wildlife');
    AppState.instance.selectDifficulty(Difficulty.easy);

    // A tablet held upright.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AssamCrosswordApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play as Guest'));
    await tester.pumpAndSettle();
    final Finder play = find.widgetWithText(MenuButton, 'Play Game');
    await tester.ensureVisible(play);
    await tester.pumpAndSettle();
    await tester.tap(play);
    await tester.pumpAndSettle();

    // Upright tablet: Across / Down tabs under the grid.
    expect(find.byType(ClueTabs), findsOneWidget);
    expect(find.byType(ClueList), findsNothing);

    // Tablet turned sideways: clue list at the side.
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(find.byType(ClueList), findsOneWidget);
    expect(find.byType(ClueTabs), findsNothing);

    // Phone held upright: a Clues button opens the list.
    tester.view.physicalSize = const Size(400, 760);
    await tester.pumpAndSettle();
    expect(find.byType(ClueTabs), findsNothing);
    await tester.tap(find.text('Clues'));
    await tester.pumpAndSettle();
    expect(find.byType(ClueList), findsOneWidget);
  });
}

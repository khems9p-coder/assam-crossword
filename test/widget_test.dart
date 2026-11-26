import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/services/app_state.dart';
import 'package:assamcrossword/widgets/menu_button.dart';

Future<void> goToDashboard(WidgetTester tester) async {
  await tester.pumpWidget(const AssamCrosswordApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Play as Guest'));
  await tester.pumpAndSettle();
}

Future<void> openMenu(WidgetTester tester, String label) async {
  final Finder button = find.widgetWithText(MenuButton, label);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Guest picks a topic and difficulty, then opens the game',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AssamCrosswordApp());
    expect(find.text('Assam Crossword'), findsOneWidget);
    expect(find.text('Developed by KBX Studios'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play as Guest'));
    await tester.pumpAndSettle();
    expect(find.text('Guest Player'), findsOneWidget);
    expect(find.text('No topic chosen · Easy'), findsOneWidget);

    await openMenu(tester, 'Select Category');
    await tester.tap(find.text('Assam General Knowledge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assam History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next: Choose Difficulty'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(find.text('Assam History'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);

    await goBack(tester);
    expect(find.text('Assam History · Hard'), findsOneWidget);
  });

  testWidgets('Daily Challenge, Progress, Achievements and Leaderboard open',
      (WidgetTester tester) async {
    await goToDashboard(tester);

    await openMenu(tester, 'Daily Challenge');
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text("Start Today's Puzzle"), findsOneWidget);
    await goBack(tester);

    await openMenu(tester, 'My Progress');
    expect(find.text('Puzzles completed'), findsOneWidget);
    expect(find.text('By category'), findsOneWidget);
    await goBack(tester);

    await openMenu(tester, 'Achievements');
    expect(find.text('0 of 11 unlocked'), findsOneWidget);
    expect(find.text('First Puzzle'), findsOneWidget);
    await goBack(tester);

    await openMenu(tester, 'Leaderboard');
    expect(find.text('No scores yet'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Medium puzzles'), findsOneWidget);
    await goBack(tester);

    expect(find.text('Guest Player'), findsOneWidget);
  });

  testWidgets('Profile, Settings, Feedback and About Us open',
      (WidgetTester tester) async {
    await goToDashboard(tester);

    await openMenu(tester, 'My Profile');
    expect(find.text('Playing without an account'), findsOneWidget);
    await goBack(tester);

    await openMenu(tester, 'Settings');
    expect(AppState.instance.soundOn, isTrue);
    await tester.tap(find.text('Sound effects'));
    await tester.pumpAndSettle();
    expect(AppState.instance.soundOn, isFalse);
    await goBack(tester);

    await openMenu(tester, 'Feedback');
    final Finder send = find.text('Send Feedback');
    await tester.ensureVisible(send);
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    await goBack(tester);

    await openMenu(tester, 'About Us');
    expect(find.text('Version 1.0.0'), findsOneWidget);
    await goBack(tester);

    expect(find.text('Guest Player'), findsOneWidget);
  });
}

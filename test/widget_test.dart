import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:assamcrossword/data/question_bank.dart';
import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/models/difficulty.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    await tester.runAsync(() => QuestionBank.instance.load());
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

    expect(find.textContaining('Assam History'), findsOneWidget);
    expect(find.textContaining('Hard'), findsOneWidget);

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

  testWidgets('Login, register and forgot-password forms check input',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AssamCrosswordApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login / Register'));
    await tester.pumpAndSettle();
    final Finder loginButton = find.widgetWithText(FilledButton, 'Log In');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send Reset Link'), findsOneWidget);
    await goBack(tester);

    final Finder createLink = find.text('Create an account');
    await tester.ensureVisible(createLink);
    await tester.pumpAndSettle();
    await tester.tap(createLink);
    await tester.pumpAndSettle();
    final Finder createButton =
        find.widgetWithText(FilledButton, 'Create Account');
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
  });

  testWidgets('Choices and settings are saved on the device',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();

    AppState.instance.selectTopic('india_polity');
    AppState.instance.selectDifficulty(Difficulty.medium);
    AppState.instance.setTextScale(1.15);

    final Map<String, dynamic>? selection =
        LocalStore.instance.readJson(LocalStore.keySelection);
    expect(selection?['topicId'], 'india_polity');
    expect(selection?['difficulty'], 'medium');
    final Map<String, dynamic>? settings =
        LocalStore.instance.readJson(LocalStore.keySettings);
    expect(settings?['textScale'], 1.15);

    await AppState.instance.resetLocalData();
    expect(AppState.instance.topicId, isNull);
    expect(LocalStore.instance.readJson(LocalStore.keySelection), isNull);
  });

  testWidgets('The crossword can be played with the on-screen keyboard',
      (WidgetTester tester) async {
    await tester.runAsync(() => QuestionBank.instance.load());
    AppState.instance.selectTopic('assam_wildlife');
    AppState.instance.selectDifficulty(Difficulty.easy);
    await goToDashboard(tester);
    await openMenu(tester, 'Play Game');
    expect(find.textContaining('Birds and Animals'), findsOneWidget);

    await tester.tap(find.text('T'));
    await tester.pump();
    await tester.tap(find.text('E'));
    await tester.pump();
    await tester.tap(find.text('A'));
    await tester.pump();

    expect(find.text('T'), findsNWidgets(2));
    expect(find.text('E'), findsNWidgets(2));
    expect(find.textContaining('%'), findsOneWidget);
  });
}

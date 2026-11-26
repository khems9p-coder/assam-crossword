import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/main.dart';

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

    await tester.tap(find.text('Select Category'));
    await tester.pumpAndSettle();
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

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Assam History · Hard'), findsOneWidget);
  });
}

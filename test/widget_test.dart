import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/main.dart';

void main() {
  testWidgets('Welcome screen shows title and opens Setup Check',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AssamCrosswordApp());

    expect(find.text('Assam Crossword'), findsOneWidget);
    expect(find.text('Developed by KBX Studios'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Setup Check'), findsOneWidget);
    expect(find.text('Flutter app is running'), findsOneWidget);
  });
}

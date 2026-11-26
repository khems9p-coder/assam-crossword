import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/main.dart';

void main() {
  testWidgets('Splash -> Welcome -> Dashboard -> menu screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AssamCrosswordApp());

    expect(find.text('Assam Crossword'), findsOneWidget);
    expect(find.text('Developed by KBX Studios'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Play as Guest'), findsOneWidget);
    expect(find.text('Login / Register'), findsOneWidget);

    await tester.tap(find.text('Play as Guest'));
    await tester.pumpAndSettle();
    expect(find.text('Guest Player'), findsOneWidget);
    expect(find.text('Play Game'), findsOneWidget);
    expect(find.text('About Us'), findsOneWidget);

    await tester.tap(find.text('Play Game'));
    await tester.pumpAndSettle();
    expect(find.text('This screen will be built soon.'), findsOneWidget);
  });
}

import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:assamcrossword/utils/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
  });

  // The game screens run a clock and the legal pages read files, so they
  // have tests of their own. Every other screen is opened here, as a
  // guest, to make sure none of them breaks.
  const Set<String> testedElsewhere = {
    AppRoutes.game,
    AppRoutes.dailyGame,
    AppRoutes.privacy,
    AppRoutes.terms,
  };

  testWidgets('every screen opens without an error', (tester) async {
    await tester.pumpWidget(const AssamCrosswordApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play as Guest'));
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    for (final String route in AppRoutes.routes.keys) {
      if (testedElsewhere.contains(route)) {
        continue;
      }
      navigator.pushNamed(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      expect(find.byType(Scaffold), findsWidgets, reason: route);
      navigator.pop();
      await tester.pumpAndSettle();
    }
  });
}

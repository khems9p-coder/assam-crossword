import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/services/app_state.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:assamcrossword/theme/app_theme.dart';

void main() {
  testWidgets('dark mode switches the colours and is remembered',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    await AppState.instance.resetLocalData();

    AppState.instance.setThemeChoice('dark');
    await tester.pumpWidget(const AssamCrosswordApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(AppColors.isDark, isTrue);
    expect(
      LocalStore.instance.readJson(LocalStore.keySettings)?['theme'],
      'dark',
    );

    AppState.instance.setThemeChoice('light');
    // The theme fades over a few frames: start it, then let it finish.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(AppColors.isDark, isFalse);

    // Let the splash screen finish before the test ends.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assamcrossword/main.dart';
import 'package:assamcrossword/services/app_state.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:assamcrossword/theme/app_theme.dart';

void main() {
  testWidgets('a colour theme changes the colours and is remembered',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    await AppState.instance.resetLocalData();

    AppState.instance.setPalette(AppPalette.twilight);
    await tester.pumpWidget(const AssamCrosswordApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(AppColors.palette, AppPalette.twilight);
    expect(AppColors.brand, AppPalette.twilight.brand);
    expect(find.byType(GlassBackground), findsWidgets);
    expect(
      LocalStore.instance.readJson(LocalStore.keySettings)?['palette'],
      'twilight',
    );

    AppState.instance.setPalette(AppPalette.classic);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(AppColors.brand, AppPalette.classic.brand);

    // Let the splash screen finish before the test ends.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('an unknown saved theme falls back to Classic', () {
    expect(AppPalette.fromName('sunrise'), AppPalette.sunrise);
    expect(AppPalette.fromName('rainbow'), AppPalette.classic);
    expect(AppPalette.fromName(null), AppPalette.classic);
  });
}

import 'package:material_ui/material_ui.dart';

/// The app's colours.
///
/// [brand], [brandLight] and [gold] never change. The others are slightly
/// different in dark mode so text stays easy to read; the app sets
/// [isDark] whenever the theme changes.
class AppColors {
  AppColors._();

  /// True while the dark theme is showing.
  static bool isDark = false;

  // Fixed brand colours: backgrounds with white text or icons on them.
  static const Color brand = Color(0xFF1B5E20);
  static const Color brandLight = Color(0xFF2E7D32);
  static const Color gold = Color(0xFFF2B705);

  // Colours that adapt to light and dark mode.
  static Color get forestGreen =>
      isDark ? const Color(0xFF81C784) : brand;
  static Color get forestGreenLight =>
      isDark ? const Color(0xFFA5D6A7) : brandLight;
  static Color get cream =>
      isDark ? const Color(0xFF101810) : const Color(0xFFFFF8E7);
  static Color get grey =>
      isDark ? const Color(0xFFB4B4B4) : const Color(0xFF6B6B6B);

  /// Cards, keys and empty squares.
  static Color get surface => isDark ? const Color(0xFF1C2A1D) : Colors.white;

  /// Main text, such as letters in the grid.
  static Color get ink => isDark ? const Color(0xFFEDEDED) : Colors.black87;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final Color background =
        dark ? const Color(0xFF101810) : const Color(0xFFFFF8E7);
    final Color card = dark ? const Color(0xFF1C2A1D) : Colors.white;
    final Color accent = dark ? const Color(0xFF81C784) : AppColors.brand;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      primary: accent,
      onPrimary: dark ? const Color(0xFF0B2A0D) : Colors.white,
      secondary: AppColors.gold,
      surface: background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: accent, width: 1.5),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: card),
    );
  }
}

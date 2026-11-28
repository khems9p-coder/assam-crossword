import 'package:material_ui/material_ui.dart';

/// The colour themes a player can choose in Settings.
enum AppPalette {
  classic(
    label: 'Classic',
    brand: Color(0xFF1B5E20),
    brandLight: Color(0xFF2E7D32),
    accent: Color(0xFFF2B705),
    darkTint: Color(0xFF81C784),
    lightGradient: null,
    darkGradient: null,
  ),
  twilight(
    label: 'Twilight',
    brand: Color(0xFF534AB7),
    brandLight: Color(0xFF7F77DD),
    accent: Color(0xFFEF9F27),
    darkTint: Color(0xFFAFA9EC),
    lightGradient: [Color(0xFFCECBF6), Color(0xFFEEEDFE), Color(0xFF9FE1CB)],
    darkGradient: [Color(0xFF26215C), Color(0xFF3C3489), Color(0xFF04342C)],
  ),
  teaGarden(
    label: 'Tea Garden',
    brand: Color(0xFF0F6E56),
    brandLight: Color(0xFF1D9E75),
    accent: Color(0xFFF0997B),
    darkTint: Color(0xFF9FE1CB),
    lightGradient: [Color(0xFF9FE1CB), Color(0xFFEAF3DE), Color(0xFFC0DD97)],
    darkGradient: [Color(0xFF04342C), Color(0xFF085041), Color(0xFF173404)],
  ),
  sunrise(
    label: 'Sunrise',
    brand: Color(0xFF993556),
    brandLight: Color(0xFFD4537E),
    accent: Color(0xFFEF9F27),
    darkTint: Color(0xFFF4C0D1),
    lightGradient: [Color(0xFFF5C4B3), Color(0xFFFBEAF0), Color(0xFFCECBF6)],
    darkGradient: [Color(0xFF4A1B0C), Color(0xFF4B1528), Color(0xFF26215C)],
  );

  const AppPalette({
    required this.label,
    required this.brand,
    required this.brandLight,
    required this.accent,
    required this.darkTint,
    required this.lightGradient,
    required this.darkGradient,
  });

  final String label;

  /// Bars, buttons and black squares, always with white text on top.
  final Color brand;
  final Color brandLight;

  /// Highlights: the selected square, progress bar, stars.
  final Color accent;

  /// The brand colour made light enough to read on a dark background.
  final Color darkTint;

  /// The background behind every screen. Null means a plain colour.
  final List<Color>? lightGradient;
  final List<Color>? darkGradient;

  /// Glass themes draw see-through cards over a colourful gradient.
  bool get isGlass => lightGradient != null;

  /// Finds a palette by its saved name, or Classic.
  static AppPalette fromName(Object? name) {
    for (final AppPalette p in values) {
      if (p.name == name) {
        return p;
      }
    }
    return classic;
  }
}

/// The app's colours. They follow the chosen [palette] and whether the
/// dark theme is showing; the app sets both whenever they change.
class AppColors {
  AppColors._();

  /// True while the dark theme is showing.
  static bool isDark = false;

  /// The colour theme chosen in Settings.
  static AppPalette palette = AppPalette.classic;

  static bool get _glass => palette.isGlass;

  // Brand colours: backgrounds with white text or icons on them.
  static Color get brand => palette.brand;
  static Color get brandLight => palette.brandLight;
  static Color get gold => palette.accent;

  // Colours that adapt to light and dark mode.
  static Color get forestGreen => isDark ? palette.darkTint : palette.brand;
  static Color get forestGreenLight =>
      isDark ? palette.darkTint : palette.brandLight;
  static Color get cream =>
      isDark ? const Color(0xFF101810) : const Color(0xFFFFF8E7);
  static Color get grey =>
      isDark ? const Color(0xFFB4B4B4) : const Color(0xFF5E5E5E);

  /// Cards, keys and menu buttons. See-through in glass themes.
  static Color get surface {
    if (_glass) {
      return isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.62);
    }
    return isDark ? const Color(0xFF1C2A1D) : Colors.white;
  }

  /// Squares of the crossword: always solid, so letters stay clear.
  static Color get cell {
    if (_glass) {
      return isDark ? const Color(0xFF221F33) : Colors.white;
    }
    return isDark ? const Color(0xFF1C2A1D) : Colors.white;
  }

  /// The thin bright edge of a glass card.
  static Color get glassEdge => isDark
      ? Colors.white.withValues(alpha: 0.16)
      : Colors.white.withValues(alpha: 0.75);

  /// Main text, such as letters in the grid.
  static Color get ink => isDark ? const Color(0xFFEDEDED) : Colors.black87;

  /// The colours behind every screen, or null for a plain background.
  static List<Color>? get backgroundGradient =>
      isDark ? palette.darkGradient : palette.lightGradient;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final AppPalette p = AppColors.palette;
    final bool dark = brightness == Brightness.dark;
    final bool glass = p.isGlass;
    final Color plain =
        dark ? const Color(0xFF101810) : const Color(0xFFFFF8E7);
    final Color solidCard = glass
        ? (dark ? const Color(0xFF221F33) : Colors.white)
        : (dark ? const Color(0xFF1C2A1D) : Colors.white);
    final Color card = glass
        ? (dark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.62))
        : solidCard;
    final Color accent = dark ? p.darkTint : p.brand;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: p.brand,
      brightness: brightness,
      primary: accent,
      onPrimary: dark ? Colors.black : Colors.white,
      secondary: p.accent,
      surface: glass ? solidCard : plain,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      // Glass themes paint the gradient behind each page (see GlassPage).
      scaffoldBackgroundColor: glass ? Colors.transparent : plain,
      pageTransitionsTheme: glass
          ? PageTransitionsTheme(
              builders: {
                for (final TargetPlatform platform in TargetPlatform.values)
                  platform: const GlassPageTransitions(
                    ZoomPageTransitionsBuilder(),
                  ),
              },
            )
          : null,
      appBarTheme: AppBarTheme(
        backgroundColor:
            glass ? p.brand.withValues(alpha: dark ? 0.55 : 0.85) : p.brand,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brand,
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
        elevation: glass ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: glass
              ? BorderSide(
                  color: Colors.white.withValues(alpha: dark ? 0.16 : 0.75),
                )
              : BorderSide.none,
        ),
      ),
      // Pop-ups stay solid so they are easy to read over anything.
      dialogTheme: DialogThemeData(backgroundColor: solidCard),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: solidCard),
    );
  }
}

/// Paints the theme's gradient behind each page, so pages stay solid
/// while they slide in and out.
class GlassPageTransitions extends PageTransitionsBuilder {
  const GlassPageTransitions(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      GlassBackground(child: child),
    );
  }
}

/// The colourful gradient used by glass themes.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final List<Color>? colors = AppColors.backgroundGradient;
    if (colors == null) {
      return child;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

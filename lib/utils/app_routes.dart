import 'package:material_ui/material_ui.dart';

import '../screens/category_screen.dart';
import '../screens/difficulty_screen.dart';
import '../screens/game_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String category = '/category';
  static const String difficulty = '/difficulty';
  static const String game = '/game';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    category: (_) => const CategoryScreen(),
    difficulty: (_) => const DifficultyScreen(),
    game: (_) => const GameScreen(),
  };

  /// Opens the game screen and clears the category/difficulty pages
  /// behind it, so the Back button returns straight to the dashboard.
  static void startGame(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      game,
      ModalRoute.withName(home),
    );
  }
}

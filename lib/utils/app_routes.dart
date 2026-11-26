import 'package:material_ui/material_ui.dart';

import '../screens/about_screen.dart';
import '../screens/achievement_screen.dart';
import '../screens/category_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/daily_challenge_screen.dart';
import '../screens/delete_account_screen.dart';
import '../screens/difficulty_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/game_screen.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String category = '/category';
  static const String difficulty = '/difficulty';
  static const String game = '/game';
  static const String dailyChallenge = '/daily-challenge';
  static const String progress = '/progress';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String feedback = '/feedback';
  static const String about = '/about';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    category: (_) => const CategoryScreen(),
    difficulty: (_) => const DifficultyScreen(),
    game: (_) => const GameScreen(),
    dailyChallenge: (_) => const DailyChallengeScreen(),
    progress: (_) => const ProgressScreen(),
    achievements: (_) => const AchievementScreen(),
    leaderboard: (_) => const LeaderboardScreen(),
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    feedback: (_) => const FeedbackScreen(),
    about: (_) => const AboutScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    editProfile: (_) => const EditProfileScreen(),
    changePassword: (_) => const ChangePasswordScreen(),
    deleteAccount: (_) => const DeleteAccountScreen(),
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

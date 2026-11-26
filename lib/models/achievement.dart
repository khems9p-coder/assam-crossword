import 'package:material_ui/material_ui.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<Achievement> all = [
    Achievement(
      id: 'first_puzzle',
      title: 'First Puzzle',
      description: 'Complete your first crossword.',
      icon: Icons.flag_circle_rounded,
    ),
    Achievement(
      id: 'first_perfect',
      title: 'First Perfect Score',
      description: 'Finish a puzzle with no mistakes and no hints.',
      icon: Icons.verified_rounded,
    ),
    Achievement(
      id: 'vocab_beginner',
      title: 'Vocabulary Beginner',
      description: 'Complete 5 English vocabulary puzzles.',
      icon: Icons.menu_book_rounded,
    ),
    Achievement(
      id: 'geography_explorer',
      title: 'Geography Explorer',
      description: 'Complete 10 geography puzzles (Assam or India).',
      icon: Icons.public_rounded,
    ),
    Achievement(
      id: 'assam_history_expert',
      title: 'Assam History Expert',
      description: 'Complete 10 Assam History puzzles.',
      icon: Icons.account_balance_rounded,
    ),
    Achievement(
      id: 'india_gk_champion',
      title: 'India GK Champion',
      description: 'Complete 25 India General Knowledge puzzles.',
      icon: Icons.military_tech_rounded,
    ),
    Achievement(
      id: 'speed_solver',
      title: 'Speed Solver',
      description: 'Finish a Medium or Hard puzzle in under 5 minutes.',
      icon: Icons.bolt_rounded,
    ),
    Achievement(
      id: 'puzzles_10',
      title: '10 Puzzles Completed',
      description: 'Complete 10 puzzles in any category.',
      icon: Icons.star_rounded,
    ),
    Achievement(
      id: 'puzzles_50',
      title: '50 Puzzles Completed',
      description: 'Complete 50 puzzles in any category.',
      icon: Icons.stars_rounded,
    ),
    Achievement(
      id: 'puzzles_100',
      title: '100 Puzzles Completed',
      description: 'Complete 100 puzzles in any category.',
      icon: Icons.workspace_premium_rounded,
    ),
    Achievement(
      id: 'daily_master',
      title: 'Daily Challenge Master',
      description: 'Complete the Daily Challenge 7 days in a row.',
      icon: Icons.local_fire_department_rounded,
    ),
  ];
}

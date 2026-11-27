import 'package:material_ui/material_ui.dart';

enum Difficulty {
  easy(
    label: 'Easy',
    description:
        'Short, familiar words and simple clues on a small grid. Great for children and beginners.',
    icon: Icons.sentiment_satisfied_rounded,
    gridSize: 9,
  ),
  medium(
    label: 'Medium',
    description:
        'Moderate vocabulary, more detailed clues and general knowledge on a medium grid.',
    icon: Icons.psychology_rounded,
    gridSize: 11,
  ),
  hard(
    label: 'Hard',
    description:
        'Longer answers, advanced vocabulary and exam-level clues on a large grid.',
    icon: Icons.local_fire_department_rounded,
    gridSize: 13,
  );

  const Difficulty({
    required this.label,
    required this.description,
    required this.icon,
    required this.gridSize,
  });

  final String label;
  final String description;
  final IconData icon;
  final int gridSize;
}

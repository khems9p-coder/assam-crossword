import 'package:material_ui/material_ui.dart';

import '../models/difficulty.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final Difficulty selected = state.difficulty;

        return Scaffold(
          appBar: AppBar(title: const Text('Difficulty Levels')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Pick how challenging your crossword should be.',
                style: TextStyle(fontSize: 15, color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              for (final Difficulty level in Difficulty.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DifficultyCard(
                    level: level,
                    selected: level == selected,
                    onTap: () => state.selectDifficulty(level),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => AppRoutes.startGame(context),
                child: const Text('Start Game'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty level;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.forestGreen : Colors.black12,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(level.icon, size: 40, color: AppColors.forestGreen),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${level.gridSize} × ${level.gridSize} grid',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.forestGreen : AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

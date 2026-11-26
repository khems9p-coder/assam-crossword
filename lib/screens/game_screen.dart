import 'package:material_ui/material_ui.dart';

import '../data/category_data.dart';
import '../models/difficulty.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final Topic? topic = state.topic;
        final Difficulty level = state.difficulty;

        return Scaffold(
          appBar: AppBar(title: const Text('Play Game')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your game',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SelectionRow(
                              icon: Icons.category_rounded,
                              label: 'Topic',
                              value: topic?.name ?? 'Not chosen yet',
                              onChange: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.category),
                            ),
                            const Divider(height: 24),
                            _SelectionRow(
                              icon: level.icon,
                              label: 'Difficulty',
                              value: level.label,
                              onChange: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.difficulty),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.construction_rounded,
                              size: 56,
                              color: AppColors.gold,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Crossword board coming soon',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The playable ${level.gridSize} × ${level.gridSize} '
                              'crossword will appear here. Your topic and '
                              'difficulty are already set.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onChange;

  const _SelectionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.forestGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onChange, child: const Text('Change')),
      ],
    );
  }
}

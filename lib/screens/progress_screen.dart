import 'package:material_ui/material_ui.dart';

import '../data/category_data.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/stat_tile.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerStats stats = AppState.instance.stats;
    final double? accuracy = stats.accuracy;

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle('Overview'),
                StatGrid(
                  children: [
                    StatTile(
                      label: 'Games played',
                      value: '${stats.gamesPlayed}',
                      icon: Icons.sports_esports_rounded,
                    ),
                    StatTile(
                      label: 'Puzzles completed',
                      value: '${stats.puzzlesCompleted}',
                      icon: Icons.task_alt_rounded,
                    ),
                    StatTile(
                      label: 'Total points',
                      value: '${stats.totalPoints}',
                      icon: Icons.star_rounded,
                    ),
                    StatTile(
                      label: 'Current level',
                      value: '${stats.level}',
                      icon: Icons.trending_up_rounded,
                    ),
                    StatTile(
                      label: 'Best time',
                      value: Helpers.formatDuration(stats.bestTimeSeconds),
                      icon: Icons.timer_rounded,
                    ),
                    StatTile(
                      label: 'Average time',
                      value: Helpers.formatDuration(stats.averageTimeSeconds),
                      icon: Icons.av_timer_rounded,
                    ),
                    StatTile(
                      label: 'Accuracy',
                      value: accuracy == null
                          ? '—'
                          : '${(accuracy * 100).round()}%',
                      icon: Icons.gps_fixed_rounded,
                    ),
                    StatTile(
                      label: 'Daily streak',
                      value: '${stats.currentStreak}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle('By category'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final SubjectArea area in CategoryData.areas)
                        ListTile(
                          leading: Icon(
                            area.icon,
                            color: AppColors.forestGreen,
                          ),
                          title: Text(area.name),
                          subtitle: Text(
                            '${stats.completedByArea[area.id] ?? 0} '
                            'puzzles completed',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('By difficulty'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final Difficulty level in Difficulty.values)
                        ListTile(
                          leading: Icon(
                            level.icon,
                            color: AppColors.forestGreen,
                          ),
                          title: Text(level.label),
                          trailing: Text(
                            '${stats.completedByDifficulty[level] ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (stats.puzzlesCompleted == 0)
                  const Text(
                    'Complete your first puzzle to start filling these '
                    'numbers in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/stat_tile.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final PlayerStats stats = AppState.instance.stats;
    final List<DateTime> lastWeek = List<DateTime>.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.forestGreen,
                        AppColors.forestGreenLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Puzzle",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatLongDate(today),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Solve one featured crossword each day to earn bonus '
                        'points and build your streak.',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StatGrid(
                  children: [
                    StatTile(
                      label: 'Current streak',
                      value: '${stats.currentStreak} days',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    StatTile(
                      label: 'Best streak',
                      value: '${stats.bestStreak} days',
                      icon: Icons.emoji_events_rounded,
                    ),
                    StatTile(
                      label: 'Daily puzzles done',
                      value: '${stats.dailyCompleted}',
                      icon: Icons.task_alt_rounded,
                    ),
                    const StatTile(
                      label: 'Today',
                      value: 'Not started',
                      icon: Icons.today_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('This week'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < lastWeek.length; i++)
                              _DayDot(
                                label: Helpers.shortWeekday(lastWeek[i]),
                                isToday: i == lastWeek.length - 1,
                                done: false,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const FilledButton(
                  onPressed: null,
                  child: Text("Start Today's Puzzle"),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daily puzzles unlock when the crossword board is ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool isToday;
  final bool done;

  const _DayDot({
    required this.label,
    required this.isToday,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.forestGreen
                : (isToday
                    ? AppColors.gold.withValues(alpha: 0.25)
                    : Colors.black12),
            border: isToday
                ? Border.all(color: AppColors.gold, width: 2)
                : null,
          ),
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

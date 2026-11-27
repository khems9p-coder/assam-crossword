import 'package:material_ui/material_ui.dart';

import '../data/category_data.dart';
import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../services/daily_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/helpers.dart';
import '../widgets/stat_tile.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      // Rebuilds when stats change, e.g. after finishing today's puzzle.
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final DateTime today = DailyService.today();
    final PlayerStats stats = AppState.instance.stats;
    final Set<String> done = DailyService.completedDates();
    final bool doneToday = done.contains(DailyService.dateKey(today));
    final int streak = DailyService.streak(done, today);
    final Topic topic = DailyService.topicFor(today);
    final List<DateTime> lastWeek = List<DateTime>.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day - (6 - i)),
    );

    return SingleChildScrollView(
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
                    Text(
                      '${topic.name} · ${DailyService.difficulty.label}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'One new crossword every day, on a different topic. '
                      'Finish it for +50 bonus points and to keep your '
                      'streak going.',
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
                    value: '$streak ${streak == 1 ? 'day' : 'days'}',
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
                  StatTile(
                    label: 'Today',
                    value: doneToday ? 'Done ✓' : 'Not started',
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
                              done: done.contains(
                                DailyService.dateKey(lastWeek[i]),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.dailyGame),
                child: Text(
                  doneToday ? 'Play Again' : "Start Today's Puzzle",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doneToday
                    ? 'Well done! Come back tomorrow for a new puzzle.'
                    : 'The streak counts days in a row with the Daily '
                        'Challenge finished.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
            ],
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

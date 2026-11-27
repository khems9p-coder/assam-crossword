import 'package:material_ui/material_ui.dart';

import '../models/achievement.dart';
import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerStats stats = AppState.instance.stats;
    final int total = Achievement.all.length;
    final int unlockedCount = Achievement.all
        .where((a) => stats.unlockedAchievements.contains(a.id))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockedCount of $total unlocked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: unlockedCount / total,
                      minHeight: 10,
                      backgroundColor: Colors.black12,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete puzzles to unlock badges.',
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final Achievement achievement in Achievement.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AchievementTile(
                achievement: achievement,
                unlocked: stats.unlockedAchievements.contains(achievement.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementTile({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: unlocked ? AppColors.gold : Colors.black12,
          child: Icon(
            achievement.icon,
            color: unlocked ? AppColors.forestGreen : AppColors.grey,
          ),
        ),
        title: Text(
          achievement.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(achievement.description),
        trailing: Icon(
          unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
          color: unlocked ? AppColors.forestGreen : AppColors.grey,
        ),
      ),
    );
  }
}

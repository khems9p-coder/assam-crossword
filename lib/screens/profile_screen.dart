import 'package:material_ui/material_ui.dart';

import '../models/achievement.dart';
import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/stat_tile.dart';
import 'coming_soon_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _needsAccount = 'Available after you create an account';

  @override
  Widget build(BuildContext context) {
    final PlayerStats stats = AppState.instance.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.forestGreen,
                          child: Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Guest Player',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Playing without an account',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ComingSoonScreen(
                                  title: 'Login / Register',
                                  icon: Icons.lock_rounded,
                                ),
                              ),
                            );
                          },
                          child: const Text('Login / Register'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'An account keeps your progress safe if you change '
                          'or reset your phone.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Your stats'),
                StatGrid(
                  children: [
                    StatTile(
                      label: 'Total points',
                      value: '${stats.totalPoints}',
                      icon: Icons.star_rounded,
                    ),
                    StatTile(
                      label: 'Puzzles completed',
                      value: '${stats.puzzlesCompleted}',
                      icon: Icons.task_alt_rounded,
                    ),
                    StatTile(
                      label: 'Best time',
                      value: Helpers.formatDuration(stats.bestTimeSeconds),
                      icon: Icons.timer_rounded,
                    ),
                    StatTile(
                      label: 'Achievements',
                      value: '${stats.unlockedAchievements.length}'
                          '/${Achievement.all.length}',
                      icon: Icons.emoji_events_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle('Account'),
                const Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.edit_rounded),
                        title: Text('Edit profile'),
                        subtitle: Text(_needsAccount),
                      ),
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.lock_reset_rounded),
                        title: Text('Change password'),
                        subtitle: Text(_needsAccount),
                      ),
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.delete_forever_rounded),
                        title: Text('Delete account'),
                        subtitle: Text(_needsAccount),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

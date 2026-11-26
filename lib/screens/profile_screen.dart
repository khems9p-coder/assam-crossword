import 'package:material_ui/material_ui.dart';

import '../models/achievement.dart';
import '../models/player_stats.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/helpers.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You can log back in any time with your email and password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (yes != true) {
      return;
    }
    await AuthService.instance.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have logged out.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService.instance;

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final PlayerStats stats = AppState.instance.stats;
        final bool signedIn = auth.isSignedIn;
        final String name = auth.displayName;
        final DateTime? since = auth.memberSince;
        final String accountNote = signedIn
            ? 'Coming in the next update'
            : 'Available after you create an account';

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
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.forestGreen,
                              child: signedIn
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              signedIn
                                  ? auth.email
                                  : 'Playing without an account',
                              style: const TextStyle(color: AppColors.grey),
                            ),
                            if (signedIn && since != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Member since ${Helpers.formatLongDate(since)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (signedIn)
                              OutlinedButton.icon(
                                onPressed: () => _confirmLogout(context),
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Log Out'),
                              )
                            else ...[
                              FilledButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.login),
                                child: const Text('Login / Register'),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'An account keeps your progress safe if you '
                                'change or reset your phone.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
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
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            enabled: false,
                            leading: const Icon(Icons.edit_rounded),
                            title: const Text('Edit profile'),
                            subtitle: Text(accountNote),
                          ),
                          ListTile(
                            enabled: false,
                            leading: const Icon(Icons.lock_reset_rounded),
                            title: const Text('Change password'),
                            subtitle: Text(accountNote),
                          ),
                          ListTile(
                            enabled: false,
                            leading: const Icon(Icons.delete_forever_rounded),
                            title: const Text('Delete account'),
                            subtitle: Text(accountNote),
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
      },
    );
  }
}

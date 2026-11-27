import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/daily_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/menu_button.dart';
import '../widgets/offline_badge.dart';
import 'coming_soon_screen.dart';

class _MenuItem {
  final String label;
  final IconData icon;
  final String? route;

  const _MenuItem(this.label, this.icon, [this.route]);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_MenuItem> _items = [
    _MenuItem('Play Game', Icons.play_circle_fill_rounded, AppRoutes.game),
    _MenuItem('Select Category', Icons.category_rounded, AppRoutes.category),
    _MenuItem('Difficulty Levels', Icons.signal_cellular_alt_rounded,
        AppRoutes.difficulty),
    _MenuItem('Daily Challenge', Icons.today_rounded, AppRoutes.dailyChallenge),
    _MenuItem('My Progress', Icons.insights_rounded, AppRoutes.progress),
    _MenuItem('Achievements', Icons.emoji_events_rounded, AppRoutes.achievements),
    _MenuItem('Leaderboard', Icons.leaderboard_rounded, AppRoutes.leaderboard),
    _MenuItem('My Profile', Icons.person_rounded, AppRoutes.profile),
    _MenuItem('Settings', Icons.settings_rounded, AppRoutes.settings),
    _MenuItem('Feedback', Icons.feedback_rounded, AppRoutes.feedback),
    _MenuItem('About Us', Icons.info_rounded, AppRoutes.about),
  ];

  void _open(BuildContext context, _MenuItem item) {
    final String? route = item.route;
    if (route != null) {
      Navigator.of(context).pushNamed(route);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(title: item.label, icon: item.icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: const [OfflineBadge()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _WelcomeHeader(),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: AppState.instance,
                    builder: (context, _) {
                      final bool dailyDone =
                          DailyService.isDone(DailyService.today());
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Points',
                              value: '${AppState.instance.stats.totalPoints}',
                              icon: Icons.star_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Level',
                              value: '${AppState.instance.stats.level}',
                              icon: Icons.trending_up_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Daily Challenge',
                              value: dailyDone ? 'Done ✓' : 'Not done',
                              icon: Icons.today_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const _CurrentGameCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final int columns =
                          width >= 700 ? 4 : (width >= 450 ? 3 : 2);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final _MenuItem item = _items[index];
                          return MenuButton(
                            label: item.label,
                            icon: item.icon,
                            onTap: () => _open(context, item),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Developed by ${AppConstants.developer}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentGameCard extends StatelessWidget {
  const _CurrentGameCard();

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final String topicName = state.topic?.name ?? 'No topic chosen';
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(
              Icons.tune_rounded,
              color: AppColors.forestGreen,
            ),
            title: const Text(
              'Current game',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$topicName · ${state.difficulty.label}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.game),
          ),
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService.instance;

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.forestGreen, AppColors.forestGreenLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const AppLogo(
                size: 56,
                backgroundColor: AppColors.cream,
                iconColor: AppColors.forestGreen,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome,',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      auth.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.isSignedIn
                          ? 'Signed in as ${auth.email}'
                          : 'Create an account later to save progress online.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 26),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

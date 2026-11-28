import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/contact_service.dart';
import '../services/daily_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/menu_button.dart';
import '../widgets/offline_badge.dart';

class _MenuItem {
  final String label;
  final IconData icon;
  final String route;

  const _MenuItem(this.label, this.icon, this.route);
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
  ];

  /// Account and app pages, kept in the side menu (the icon at top left).
  static const List<_MenuItem> _drawerItems = [
    _MenuItem('My Profile', Icons.person_rounded, AppRoutes.profile),
    _MenuItem('Settings', Icons.settings_rounded, AppRoutes.settings),
    _MenuItem('Feedback', Icons.feedback_rounded, AppRoutes.feedback),
    _MenuItem('About Us', Icons.info_rounded, AppRoutes.about),
  ];

  void _open(BuildContext context, _MenuItem item) {
    Navigator.of(context).pushNamed(item.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: const [OfflineBadge()],
      ),
      drawer: const _AppDrawer(items: _drawerItems),
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
                  Text(
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
                  Text(
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
            leading: Icon(
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

/// The side menu opened from the icon at the top left of the dashboard.
class _AppDrawer extends StatelessWidget {
  final List<_MenuItem> items;

  const _AppDrawer({required this.items});

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop(); // close the menu first
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: AppColors.brand,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  AppLogo(
                    size: 56,
                    backgroundColor: AppColors.cream,
                    iconColor: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService.instance.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final _MenuItem item in items)
              ListTile(
                leading: Icon(item.icon, color: AppColors.forestGreen),
                title: Text(item.label),
                onTap: () => _go(context, item.route),
              ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.share_rounded, color: AppColors.forestGreen),
              title: const Text('Share the app'),
              onTap: () {
                Navigator.of(context).pop();
                ContactService.shareApp();
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Developed by ${AppConstants.developer}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
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
            gradient: LinearGradient(
              colors: [AppColors.brand, AppColors.brandLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              AppLogo(
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
                style: TextStyle(
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
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

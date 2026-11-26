import 'package:material_ui/material_ui.dart';

import '../models/difficulty.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Difficulty? _filter;

  @override
  Widget build(BuildContext context) {
    final String filterLabel =
        _filter == null ? 'all levels' : '${_filter!.label} puzzles';

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              for (final Difficulty level in Difficulty.values)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _filter == level,
                  onSelected: (_) => setState(() => _filter = level),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.forestGreen,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              title: Text(
                'Your rank',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Guest players are not ranked'),
              trailing: Text(
                '—',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            Icons.leaderboard_rounded,
            size: 72,
            color: AppColors.forestGreen.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'No scores yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Top players for $filterLabel will appear here once online '
            'accounts and score syncing are added. Create an account later '
            'to compete.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../models/difficulty.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Difficulty? _filter;
  Future<List<LeaderEntry>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (AuthService.instance.available) {
      // Upload this player's latest scores first, then read the board.
      _future = CloudService.instance
          .push()
          .then((_) => CloudService.instance.top(_filter));
    } else {
      _future = null;
    }
  }

  void _select(Difficulty? filter) {
    setState(() {
      _filter = filter;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<LeaderEntry>>? future = _future;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          if (future != null)
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(_load),
            ),
        ],
      ),
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
                onSelected: (_) => _select(null),
              ),
              for (final Difficulty level in Difficulty.values)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _filter == level,
                  onSelected: (_) => _select(level),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _filter == null
                ? 'Ranked by total points'
                : 'Ranked by puzzles completed on ${_filter!.label}',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          if (future == null)
            _emptyState(null)
          else
            FutureBuilder<List<LeaderEntry>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _emptyState(
                    'Could not load the leaderboard. Check your internet '
                    'connection and tap refresh.',
                  );
                }
                final List<LeaderEntry> entries = snapshot.data ?? const [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _yourRank(entries),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      _emptyState(null)
                    else
                      for (int i = 0; i < entries.length; i++)
                        _row(i + 1, entries[i]),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _yourRank(List<LeaderEntry> entries) {
    final String? uid = AuthService.instance.user?.uid;
    String subtitle;
    String rank = '—';
    if (uid == null) {
      subtitle = 'Log in to appear on the leaderboard';
    } else {
      final int index = entries.indexWhere((e) => e.uid == uid);
      if (index >= 0) {
        rank = '#${index + 1}';
        subtitle = 'Keep playing to climb higher';
      } else {
        subtitle = 'Not in the top 50 yet';
      }
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.brand,
          child: const Icon(Icons.person_rounded, color: Colors.white),
        ),
        title: const Text(
          'Your rank',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          rank,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onTap: uid == null
            ? () => Navigator.of(context).pushNamed(AppRoutes.login)
            : null,
      ),
    );
  }

  Widget _row(int rank, LeaderEntry entry) {
    final bool me = entry.uid == AuthService.instance.user?.uid;
    final Color medal = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFB0BEC5),
      3 => const Color(0xFFCD7F32),
      _ => Colors.black12,
    };
    final int value = entry.valueFor(_filter);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: me ? AppColors.gold.withValues(alpha: 0.2) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: medal,
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          me ? '${entry.name} (you)' : entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Level ${entry.level} · ${entry.puzzles} puzzles'),
        trailing: Text(
          _filter == null ? '$value pts' : '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.forestGreen,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String? message) {
    final String filterLabel =
        _filter == null ? 'all levels' : '${_filter!.label} puzzles';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          message ??
              'Top players for $filterLabel will appear here. Log in and '
                  'finish puzzles to get on the board.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey),
        ),
      ],
    );
  }
}

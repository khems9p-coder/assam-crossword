import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';

class SetupCheckScreen extends StatelessWidget {
  const SetupCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String platform =
        kIsWeb ? 'Web preview (Chrome)' : defaultTargetPlatform.name;

    final List<_CheckItem> items = [
      const _CheckItem('Flutter app is running', true),
      _CheckItem('Running on: $platform', true),
      const _CheckItem('Package ID: com.kbxstudios.assamcrossword', true),
      const _CheckItem('Theme and dashboard (Phase 2)', false),
      const _CheckItem('Firebase connection (Phase 4)', false),
      const _CheckItem('Crossword engine (Phase 7)', false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Check'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(
              item.done ? Icons.check_circle : Icons.schedule,
              color: item.done ? Colors.green : Colors.grey,
            ),
            title: Text(item.label),
            subtitle: Text(item.done ? 'Done' : 'Coming later'),
          );
        },
      ),
    );
  }
}

class _CheckItem {
  final String label;
  final bool done;

  const _CheckItem(this.label, this.done);
}

import 'package:material_ui/material_ui.dart';

import '../services/connectivity_service.dart';

/// Shows a small "Offline" chip when there is no internet.
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectivityService connectivity = ConnectivityService.instance;

    return ListenableBuilder(
      listenable: connectivity,
      builder: (context, _) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink();
        }
        return const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Chip(
            avatar: Icon(Icons.cloud_off_rounded, size: 18),
            label: Text('Offline'),
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}

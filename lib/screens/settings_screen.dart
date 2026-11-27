import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/stat_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<double> _sizes = [0.85, 1.0, 1.15, 1.3];
  static const List<String> _sizeNames = [
    'Small',
    'Normal',
    'Large',
    'Extra large',
  ];

  Future<void> _confirmClear(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear local data?'),
        content: const Text(
          'This removes your settings, chosen topic and progress saved on '
          'this device. Your online account is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (yes != true) {
      return;
    }
    await AppState.instance.resetLocalData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local data cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        int sizeIndex = _sizes.indexOf(state.textScale);
        if (sizeIndex < 0) {
          sizeIndex = 1;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle('Sound and feel'),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up_rounded),
                      title: const Text('Sound effects'),
                      subtitle: const Text(
                        'Clicks, correct letters and completion sounds',
                      ),
                      value: state.soundOn,
                      onChanged: state.setSoundOn,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.music_note_rounded),
                      title: const Text('Background music'),
                      subtitle: const Text('Calm music while you play'),
                      value: state.musicOn,
                      onChanged: state.setMusicOn,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Vibration'),
                      subtitle: const Text(
                        'Short buzz on mistakes and completion',
                      ),
                      value: state.vibrationOn,
                      onChanged: state.setVibrationOn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Appearance'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'light',
                            icon: Icon(Icons.light_mode_rounded),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: 'dark',
                            icon: Icon(Icons.dark_mode_rounded),
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: 'system',
                            icon: Icon(Icons.settings_suggest_rounded),
                            label: Text('Auto'),
                          ),
                        ],
                        selected: {state.themeChoice},
                        onSelectionChanged: (Set<String> choice) =>
                            state.setThemeChoice(choice.first),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Auto follows your device setting.',
                        style: TextStyle(fontSize: 13, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Text size'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sizeNames[sizeIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: sizeIndex.toDouble(),
                        min: 0,
                        max: 3,
                        divisions: 3,
                        label: _sizeNames[sizeIndex],
                        onChanged: (v) => state.setTextScale(_sizes[v.round()]),
                      ),
                      Text(
                        'This is how text will look in the app.',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Account and information'),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: const Text('Account'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.profile),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cleaning_services_rounded),
                      title: const Text('Clear local data'),
                      subtitle: const Text(
                        'Remove settings and progress saved on this device',
                      ),
                      onTap: () => _confirmClear(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_rounded),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.privacy),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_rounded),
                      title: const Text('Terms and Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.terms),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_rounded),
                      title: const Text('About the app'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.about),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your settings are saved on this device. Background music '
                'is coming in a later update.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

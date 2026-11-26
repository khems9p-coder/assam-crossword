import 'package:material_ui/material_ui.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/stat_tile.dart';
import 'coming_soon_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<double> _sizes = [0.85, 1.0, 1.15, 1.3];
  static const List<String> _sizeNames = [
    'Small',
    'Normal',
    'Large',
    'Extra large',
  ];

  void _openComingSoon(BuildContext context, String title, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(title: title, icon: icon),
      ),
    );
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
                      const Text(
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
                      leading: const Icon(Icons.privacy_tip_rounded),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _openComingSoon(
                        context,
                        'Privacy Policy',
                        Icons.privacy_tip_rounded,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_rounded),
                      title: const Text('Terms and Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _openComingSoon(
                        context,
                        'Terms and Conditions',
                        Icons.description_rounded,
                      ),
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
              const Text(
                'Sounds, music and vibration are added in a later phase and '
                'will follow these choices. Settings are kept while the app '
                'is open and will be saved on the device in Phase 6.',
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

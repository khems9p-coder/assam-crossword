import 'package:material_ui/material_ui.dart';

import '../data/category_data.dart';
import '../services/contact_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/stat_tile.dart';
import 'coming_soon_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _emailUs(BuildContext context) async {
    final bool opened = await ContactService.openEmail(
      subject: '${AppConstants.appName} enquiry',
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't open an email app. Please write to "
            '${AppConstants.contactEmail}.',
          ),
        ),
      );
    }
  }

  void _openComingSoon(BuildContext context, String title, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(title: title, icon: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 96)),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
                Text(
                  'Version ${AppConstants.appVersion}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                const SectionTitle("What's inside"),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final SubjectArea area in CategoryData.areas)
                        ListTile(
                          leading: Icon(
                            area.icon,
                            color: AppColors.forestGreen,
                          ),
                          title: Text(area.name),
                          subtitle: Text('${area.topics.length} topics'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Developer'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.business_rounded,
                          color: AppColors.forestGreen,
                        ),
                        title: Text(AppConstants.developer),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email_rounded,
                          color: AppColors.forestGreen,
                        ),
                        title: const Text('Contact us'),
                        subtitle: const Text(AppConstants.contactEmail),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _emailUs(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Legal'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
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
                        leading: const Icon(Icons.article_rounded),
                        title: const Text('Open-source licences'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}

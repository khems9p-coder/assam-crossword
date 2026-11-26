import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 120),
                  const SizedBox(height: 24),
                  const Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppConstants.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.home);
                    },
                    child: const Text('Play as Guest'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.login);
                    },
                    child: const Text('Login / Register'),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Developed by ${AppConstants.developer}',
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
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

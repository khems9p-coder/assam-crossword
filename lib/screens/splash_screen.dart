import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import '../services/startup.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Show the splash for its usual time, and longer only if the
    // questions or Firebase are still loading.
    unawaited(
      Future.wait<void>([
        Future<void>.delayed(AppConstants.splashDuration),
        Startup.ready,
      ]).then((_) => _goNext()),
    );
  }

  void _goNext() {
    if (!mounted) {
      return;
    }
    if (AuthService.instance.isSignedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                AppLogo(
                  size: 120,
                  backgroundColor: AppColors.cream,
                  iconColor: AppColors.forestGreen,
                ),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const Spacer(),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Developed by ${AppConstants.developer}',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

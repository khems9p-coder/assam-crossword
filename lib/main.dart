import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'data/question_bank.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/cloud_service.dart';
import 'services/connectivity_service.dart';
import 'services/daily_service.dart';
import 'services/local_store.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load everything saved on this device (works offline).
  try {
    await LocalStore.instance.init();
    await AppState.instance.loadFromDevice();
    DailyService.refreshStreak();
  } catch (error) {
    debugPrint('Local storage not available: $error');
  }

  // Load the sound effects (the game stays quiet if this fails).
  unawaited(SoundService.instance.init());

  // Load the built-in question bank (works offline).
  await QuestionBank.instance.load();

  // 2. Start watching the internet connection.
  unawaited(ConnectivityService.instance.start());

  // 3. Connect to Firebase (accounts). The game still works without it.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.instance.start();
    CloudService.instance.start();
    debugPrint('Firebase connected: ${Firebase.app().options.projectId}');
  } catch (error) {
    debugPrint('Firebase not available: $error');
  }

  runApp(const AssamCrosswordApp());
}

class AssamCrosswordApp extends StatelessWidget {
  const AssamCrosswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: switch (state.themeChoice) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          home: const SplashScreen(),
          routes: AppRoutes.routes,
          builder: (context, child) {
            // Tell AppColors which mode is showing. When it changes,
            // repaint every screen so all colours switch together.
            final bool dark = Theme.of(context).brightness == Brightness.dark;
            if (dark != AppColors.isDark) {
              AppColors.isDark = dark;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                void rebuild(Element element) {
                  element.markNeedsBuild();
                  element.visitChildren(rebuild);
                }

                WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
              });
            }
            final MediaQueryData media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(state.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

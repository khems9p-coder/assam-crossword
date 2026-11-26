import 'package:material_ui/material_ui.dart';

import 'setup_check_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color gold = Color(0xFFF2B705);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: forestGreen,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.grid_on_rounded,
                      size: 72,
                      color: gold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Assam Crossword',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: forestGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Learn words. Explore Assam. Sharpen your mind.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: forestGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SetupCheckScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Developed by KBX Studios',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
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

import 'package:material_ui/material_ui.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const AssamCrosswordApp());
}

class AssamCrosswordApp extends StatelessWidget {
  const AssamCrosswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assam Crossword',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/workout_service.dart';
import 'screens/workout_screen.dart';
import 'screens/tools_hub_screen.dart';
import 'screens/water_tracker_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await WorkoutService().init();
  runApp(const FitPulseApp());
}

class FitPulseApp extends StatelessWidget {
  const FitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        fontFamily: 'Roboto',
      ),
      home: const FitPulseShell(),
    );
  }
}

class FitPulseShell extends StatefulWidget {
  const FitPulseShell({super.key});

  @override
  State<FitPulseShell> createState() => _FitPulseShellState();
}

class _FitPulseShellState extends State<FitPulseShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WorkoutScreen(),
    FitnessToolsHubScreen(),
    WaterTrackerScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('⚡ FitPulse', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF06B6D4), width: 1),
              ),
              child: const Text('Gym & Fitness Koçu', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0A0E17),
          indicatorColor: const Color(0xFF06B6D4).withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF06B6D4), fontSize: 11, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.white54, fontSize: 11);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.fitness_center, color: Color(0xFF06B6D4)),
              label: 'Antrenman',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.calculate, color: Color(0xFF06B6D4)),
              label: '1RM & Plaka',
            ),
            NavigationDestination(
              icon: Icon(Icons.water_drop_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.water_drop, color: Color(0xFF06B6D4)),
              label: 'Su Takibi',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.history, color: Color(0xFF06B6D4)),
              label: 'Geçmiş',
            ),
          ],
        ),
      ),
    );
  }
}

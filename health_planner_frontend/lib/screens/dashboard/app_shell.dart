import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/data_providers.dart';
import '../dashboard/dashboard_screen.dart';
import '../workouts/workouts_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../weight/weight_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    WorkoutsScreen(),
    NutritionScreen(),
    WeightScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load all data when shell initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkouts();
      context.read<NutritionProvider>().fetchLogs();
      context.read<WeightProvider>().fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_weight_outlined),
              activeIcon: Icon(Icons.monitor_weight),
              label: 'Weight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

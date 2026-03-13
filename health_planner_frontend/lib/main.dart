import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/data_providers.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/app_shell.dart';

void main() {
  runApp(const HealthPlannerApp());
}

class HealthPlannerApp extends StatelessWidget {
  const HealthPlannerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
      ],
      child: MaterialApp(
        title: 'Health Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Watches auth state and routes to the right screen
class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            );
          case AuthStatus.authenticated:
            return const AppShell();
          case AuthStatus.unauthenticated:
            return const AuthScreen();
        }
      },
    );
  }
}

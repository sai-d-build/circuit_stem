import 'package:flutter/material.dart';
import 'routes.dart';
import 'presentation/core/theme/app_theme.dart';
import 'presentation/features/onboarding/screens/onboarding_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showOnboarding = false; // TODO: Check from preferences

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuit STEM',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: _showOnboarding ? '/onboarding' : AppRoutes.mainMenu,
      onGenerateRoute: (settings) {
        // Handle onboarding route
        if (settings.name == '/onboarding') {
          return MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          );
        }
        return AppRoutes.onGenerateRoute(settings);
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

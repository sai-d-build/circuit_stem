import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/menus/screens/main_menu.dart';
import 'package:sparkcircuit/presentation/features/game/screens/game_screen.dart';
import 'package:sparkcircuit/presentation/features/menus/screens/settings_screen.dart';
import 'package:sparkcircuit/presentation/features/onboarding/screens/onboarding_screen.dart';
import 'package:sparkcircuit/presentation/features/menus/screens/level_select.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainMenu(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/level-select',
        name: 'level-select',
        builder: (context, state) => const LevelSelect(),
      ),
      GoRoute(
        path: '/game/:levelId',
        name: 'game',
        builder: (context, state) {
          final levelId = state.pathParameters['levelId'] ?? '1';
          return GameScreen(levelId: levelId);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class CircuitStemApp extends ConsumerWidget {
  const CircuitStemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Circuit STEM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
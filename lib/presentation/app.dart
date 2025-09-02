import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/game_engine_v3/providers_v3.dart';
import 'core/theme/app_theme.dart';
import 'features/menus/screens/main_menu.dart';
import 'features/game/screens/game_screen.dart';
import 'features/menus/screens/settings_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/menus/screens/level_select.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final onboardingCompleted = storageService.readData<bool>('onboarding_completed') ?? false;
  final showOnboarding = !onboardingCompleted;

  return GoRouter(
    initialLocation: showOnboarding ? '/onboarding' : '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/level-select',
        name: 'level-select',
        builder: (context, state) => const LevelSelectScreen(),
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
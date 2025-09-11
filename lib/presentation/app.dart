import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/game_engine/v3/providers_v3.dart';
import '../../core/debug/structured_logger.dart';
import 'core/theme/app_theme.dart';
import 'features/menus/screens/main_menu.dart';
import 'features/game/screens/game_screen.dart';
import 'features/menus/screens/settings_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/menus/screens/level_select.dart';

final routerProvider = Provider<GoRouter>((ref) {
  StructuredLogger.info('🛣️ CREATING ROUTER PROVIDER', context: {
    'timestamp': DateTime.now().toIso8601String(),
  });

  final storageService = ref.watch(storageServiceProvider);
  final onboardingCompleted = storageService.readData<bool>('onboarding_completed') ?? false;
  final showOnboarding = !onboardingCompleted;

  StructuredLogger.info('📊 Router configuration determined', context: {
    'onboardingCompleted': onboardingCompleted,
    'showOnboarding': showOnboarding,
    'initialLocation': showOnboarding ? '/onboarding' : '/',
    'timestamp': DateTime.now().toIso8601String(),
  });

  final router = GoRouter(
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
          StructuredLogger.info('🎮 Creating GameScreen for level', context: {
            'levelId': levelId,
            'path': state.pathParameters['levelId'],
            'timestamp': DateTime.now().toIso8601String(),
          });
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

  StructuredLogger.info('✅ Router provider created successfully', context: {
    'routesCount': 5, // We have 5 routes defined
    'initialLocation': showOnboarding ? '/onboarding' : '/',
    'timestamp': DateTime.now().toIso8601String(),
  });

  return router;
});

class CircuitStemApp extends ConsumerWidget {
  const CircuitStemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StructuredLogger.info('🏗️ BUILDING CircuitStemApp', context: {
      'timestamp': DateTime.now().toIso8601String(),
      'contextType': context.runtimeType.toString(),
    });

    final router = ref.watch(routerProvider);

    StructuredLogger.info('🎨 Creating MaterialApp.router', context: {
      'title': 'Circuit STEM',
      'routerType': router.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });

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
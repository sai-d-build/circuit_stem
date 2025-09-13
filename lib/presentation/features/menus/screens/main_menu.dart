// Main menu screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_button.dart';

import '../../../core/theme/app_theme.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For neon to look best, we assume a dark theme is active.
    // This should be handled by the MaterialApp themeMode.
    final colors = Theme.of(context).extension<CircuitColorScheme>() ??
        const CircuitColorScheme(
          primary: Color(0xFF1E88E5),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFE3F2FD),
          onPrimaryContainer: Color(0xFF0D47A1),
          secondary: Color(0xFF43A047),
          onSecondary: Color(0xFFFFFFFF),
          tertiary: Color(0xFFFF8F00),
          onTertiary: Color(0xFFFFFFFF),
          error: Color(0xFFD32F2F),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFFEBEE),
          onErrorContainer: Color(0xFFB71C1C),
          surface: Color(0xFFFAFAFA),
          onSurface: Color(0xFF1C1C1C),
          surfaceContainer: Color(0xFFEFEFEF),
          onSurfaceVariant: Color(0xFF424242),
          shadow: Color(0xFF000000),
          outline: Color(0xFFBDBDBD),
          wireActive: Color(0xFF00E676),
          wireInactive: Color(0xFF616161),
          componentBase: Color(0xFF2196F3),
          gridLine: Color(0xFFE0E0E0),
          glowEffect: Color(0xFF00E5FF),
          neonPrimary: Color(0xFF00FFFF),
          neonAccent: Color(0xFFFF00FF),
          errorGlow: Color(0xFFFF0040),
          energyPulse: Color(0xFF39FF14),
          highlightAccent: Color(0xFFFFFF00),
        );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface, // Use dark surface for neon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SparkCircuit',
              style: textTheme.displayLarge
                  ?.copyWith(color: colors.onSurface, shadows: [
                BoxShadow(
                  color: colors.neonPrimary.withValues(alpha: 0.8),
                  blurRadius: 18,
                  spreadRadius: 6,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text(
              'Learn Electronics Through Play',
              style: textTheme.headlineMedium
                  ?.copyWith(color: colors.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 64),
            NeonButton(
              text: 'Start Learning',
              onPressed: () {
                StructuredLogger.info('MainMenu: Navigation to level select',
                    context: {
                      'destination': '/level-select',
                      'button': 'Start Learning',
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                context.push('/level-select');
              },
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: 'Settings',
              onPressed: () {
                StructuredLogger.info('MainMenu: Navigation to settings',
                    context: {
                      'destination': '/settings',
                      'button': 'Settings',
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

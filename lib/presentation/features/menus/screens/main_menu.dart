// Main menu screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_button.dart';
import '../../../../routes.dart';
import '../../../theme/app_theme.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For neon to look best, we assume a dark theme is active.
    // This should be handled by the MaterialApp themeMode.
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface, // Use dark surface for neon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SparkCircuit',
              style: textTheme.displayLarge?.copyWith(
                color: colors.onSurface,
                shadows: [
                  BoxShadow(
                    color: colors.neonPrimary.withOpacity(0.8),
                    blurRadius: 18.0,
                    spreadRadius: 6.0,
                  ),
                ]
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Learn Electronics Through Play',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.8)
              ),
            ),
            const SizedBox(height: 64),
            NeonButton(
              text: 'Start Learning',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.levelSelect);
              },
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: 'Settings',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}

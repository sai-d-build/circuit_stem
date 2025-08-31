// Main menu screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SparkCircuit',
              style: AppTheme.lightTheme.textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Learn Electronics Through Play',
              style: AppTheme.lightTheme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.go('/level-select');
              },
              style: AppTheme.lightTheme.elevatedButtonTheme.style,
              child: const Text('Start Learning'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.go('/settings');
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
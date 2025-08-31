// Level select screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Challenge',
              style: AppTheme.lightTheme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Start with basic circuits and work your way up to advanced challenges!',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 15, // 15 levels as per design
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  return _buildLevelCard(context, levelNumber);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int levelNumber) {
    final isLocked = levelNumber > 5; // First 5 levels unlocked by default

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isLocked ? null : () {
          context.go('/game/$levelNumber');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isLocked
                ? Colors.grey.shade300
                : AppTheme.lightTheme.colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                levelNumber.toString(),
                style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                  color: isLocked
                      ? Colors.grey
                      : AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLocked ? 'Locked' : 'Play',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isLocked
                      ? Colors.grey
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
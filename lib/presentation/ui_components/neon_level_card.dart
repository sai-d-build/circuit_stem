
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class NeonLevelCard extends StatelessWidget {
  final String levelName;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onPressed;

  const NeonLevelCard({
    super.key,
    required this.levelName,
    this.isUnlocked = false,
    this.isCompleted = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    Color borderColor;
    if (isCompleted) {
      borderColor = colors.highlightAccent; // Gold for completed
    } else if (isUnlocked) {
      borderColor = colors.neonPrimary; // Cyan for unlocked
    } else {
      borderColor = colors.outline; // Grey for locked
    }

    return GestureDetector(
      onTap: isUnlocked ? onPressed : null,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.5),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                levelName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isUnlocked ? colors.onSurface : colors.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!isUnlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.lock,
                    color: colors.onSurface.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.check_circle,
                    color: colors.highlightAccent,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

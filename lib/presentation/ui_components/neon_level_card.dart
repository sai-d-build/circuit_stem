
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

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
    final colors = Theme.of(context).extension<CircuitColorScheme>() ?? const CircuitColorScheme(
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
          color: colors.surface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.5),
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
                      color: isUnlocked ? colors.onSurface : colors.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!isUnlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.lock,
                    color: colors.onSurface.withValues(alpha: 0.5),
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;

  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.neonPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

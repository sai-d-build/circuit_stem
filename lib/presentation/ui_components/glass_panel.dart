
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;

  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: colors.neonPrimary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

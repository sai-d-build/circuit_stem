import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class NeonSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? label;

  const NeonSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.label,
  });

  @override
  State<NeonSlider> createState() => _NeonSliderState();
}

class _NeonSliderState extends State<NeonSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  shadows: [
                    BoxShadow(
                      color: colors.neonPrimary.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colors.neonPrimary
                        .withValues(alpha: _glowAnimation.value * 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colors.neonPrimary,
                  inactiveTrackColor: colors.outline.withValues(alpha: 0.3),
                  thumbColor: colors.surface,
                  overlayColor: colors.neonPrimary.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 4,
                  ),
                  trackHeight: 4,
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20),
                  valueIndicatorColor: colors.neonPrimary,
                  valueIndicatorTextStyle: textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: widget.value,
                  min: widget.min,
                  max: widget.max,
                  divisions: widget.divisions,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

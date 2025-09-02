import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

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

class _NeonSliderState extends State<NeonSlider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween(begin: 0.5, end: 1.0).animate(
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
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
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
                      color: colors.neonPrimary.withOpacity(0.3),
                      blurRadius: 4.0,
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
                    color: colors.neonPrimary.withOpacity(_glowAnimation.value * 0.4),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colors.neonPrimary,
                  inactiveTrackColor: colors.outline.withOpacity(0.3),
                  thumbColor: colors.surface,
                  overlayColor: colors.neonPrimary.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12.0,
                    elevation: 4.0,
                  ),
                  trackHeight: 4.0,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
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
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class NeonProgressBar extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;

  const NeonProgressBar({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.showPercentage = false,
  });

  @override
  State<NeonProgressBar> createState() => _NeonProgressBarState();
}

class _NeonProgressBarState extends State<NeonProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween(begin: 0.6, end: 1.0).animate(
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

    final progressValue = (widget.value - widget.min) / (widget.max - widget.min);
    final clampedValue = progressValue.clamp(0.0, 1.0);

    final progressColor = widget.progressColor ?? colors.energyPulse;
    final bgColor = widget.backgroundColor ?? colors.outline.withOpacity(0.3);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null || widget.showPercentage) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        shadows: [
                          BoxShadow(
                            color: colors.neonPrimary.withOpacity(0.3),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  if (widget.showPercentage)
                    Text(
                      '${(clampedValue * 100).round()}%',
                      style: textTheme.bodyMedium?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.5),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                color: bgColor,
                border: Border.all(
                  color: colors.neonPrimary.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: Stack(
                  children: [
                    // Progress fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: clampedValue,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor.withOpacity(0.8),
                              progressColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: progressColor.withOpacity(_glowAnimation.value * 0.8),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Animated glow overlay
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: clampedValue,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              progressColor.withOpacity(_glowAnimation.value * 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class PlacementGlow extends StatefulWidget {
  final Offset position;
  final bool isValid;
  final double size;
  final Duration duration;

  const PlacementGlow({
    super.key,
    required this.position,
    required this.isValid,
    this.size = 60.0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<PlacementGlow> createState() => _PlacementGlowState();
}

class _PlacementGlowState extends State<PlacementGlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(PlacementGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isValid != widget.isValid) {
      // Restart animation when validity changes
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    final glowColor = widget.isValid ? colors.energyPulse : colors.errorGlow;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - widget.size / 2,
          top: widget.position.dy - widget.size / 2,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: _opacityAnimation.value * 0.6),
                  blurRadius: 20.0 * _scaleAnimation.value,
                  spreadRadius: 5.0 * _scaleAnimation.value,
                ),
                BoxShadow(
                  color: glowColor.withValues(alpha: _opacityAnimation.value * 0.3),
                  blurRadius: 40.0 * _scaleAnimation.value,
                  spreadRadius: 10.0 * _scaleAnimation.value,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor.withValues(alpha: _opacityAnimation.value * 0.2),
                  border: Border.all(
                    color: glowColor.withValues(alpha: _opacityAnimation.value * 0.8),
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  widget.isValid ? Icons.check : Icons.close,
                  color: glowColor.withValues(alpha: _opacityAnimation.value),
                  size: widget.size * 0.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Grid highlight component for showing valid/invalid placement zones
class GridHighlight extends StatefulWidget {
  final List<Offset> validPositions;
  final List<Offset> invalidPositions;
  final double cellSize;

  const GridHighlight({
    super.key,
    required this.validPositions,
    required this.invalidPositions,
    this.cellSize = 60.0,
  });

  @override
  State<GridHighlight> createState() => _GridHighlightState();
}

class _GridHighlightState extends State<GridHighlight> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Valid positions
            ...widget.validPositions.map((position) {
              return Positioned(
                left: position.dx - widget.cellSize / 2,
                top: position.dy - widget.cellSize / 2,
                child: Container(
                  width: widget.cellSize,
                  height: widget.cellSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.energyPulse.withValues(alpha: _pulseAnimation.value),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              );
            }),

            // Invalid positions
            ...widget.invalidPositions.map((position) {
              return Positioned(
                left: position.dx - widget.cellSize / 2,
                top: position.dy - widget.cellSize / 2,
                child: Container(
                  width: widget.cellSize,
                  height: widget.cellSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.errorGlow.withValues(alpha: _pulseAnimation.value),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.block,
                      color: colors.errorGlow.withValues(alpha: _pulseAnimation.value * 0.7),
                      size: widget.cellSize * 0.4,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
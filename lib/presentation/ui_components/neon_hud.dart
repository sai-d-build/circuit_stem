import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class NeonHUD extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double opacity;
  final bool showGlow;

  const NeonHUD({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.opacity = 0.8,
    this.showGlow = true,
  });

  @override
  State<NeonHUD> createState() => _NeonHUDState();
}

class _NeonHUDState extends State<NeonHUD> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween(begin: 0.3, end: 0.7).animate(
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

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: colors.surface.withValues(alpha: widget.opacity),
            border: Border.all(
              color: colors.neonPrimary.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: widget.showGlow ? [
              BoxShadow(
                color: colors.neonPrimary.withValues(alpha: _glowAnimation.value * 0.4),
                blurRadius: 15.0,
                spreadRadius: 2.0,
              ),
              BoxShadow(
                color: colors.neonAccent.withValues(alpha: _glowAnimation.value * 0.2),
                blurRadius: 25.0,
                spreadRadius: 1.0,
              ),
            ] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}
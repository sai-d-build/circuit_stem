import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class ParallaxBackground extends StatefulWidget {
  final List<Widget> layers;
  final List<double> speeds;
  final double? height;
  final bool animate;

  const ParallaxBackground({
    super.key,
    required this.layers,
    required this.speeds,
    this.height,
    this.animate = true,
  }) : assert(layers.length == speeds.length, 'Layers and speeds must have the same length');

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.animate) {
      _controller.repeat();
    }

    _animations = widget.speeds.map((speed) {
      return Tween<double>(
        begin: 0.0,
        end: 2 * pi,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surface,
            colors.surface.withOpacity(0.8),
            colors.surface.withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: List.generate(widget.layers.length, (index) {
          return AnimatedBuilder(
            animation: widget.animate ? _animations[index] : AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              final speed = widget.speeds[index];
              final offset = widget.animate ? sin(_animations[index].value) * speed * 20 : 0.0;

              return Positioned(
                left: offset,
                right: -offset,
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.3 + (index * 0.2).clamp(0.0, 0.7),
                  child: widget.layers[index],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Pre-built circuit pattern layer
class CircuitPatternLayer extends StatelessWidget {
  final Color? color;
  final double opacity;

  const CircuitPatternLayer({
    super.key,
    this.color,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    final patternColor = color ?? colors.neonPrimary;

    return CustomPaint(
      painter: CircuitPatternPainter(
        color: patternColor.withOpacity(opacity),
      ),
    );
  }
}

class CircuitPatternPainter extends CustomPainter {
  final Color color;

  CircuitPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final random = Random(42); // Fixed seed for consistent pattern

    // Draw circuit-like patterns
    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = startY + (random.nextDouble() - 0.5) * 100;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Add some nodes
      if (random.nextDouble() < 0.3) {
        canvas.drawCircle(Offset(startX, startY), 2.0, paint..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(endX, endY), 2.0, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(CircuitPatternPainter oldDelegate) => false;
}
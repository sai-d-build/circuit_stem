import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class EnergyFlowEffect extends StatefulWidget {
  final Offset start;
  final Offset end;
  final bool isActive;
  final Color? flowColor;
  final double thickness;
  final Duration cycleDuration;

  const EnergyFlowEffect({
    super.key,
    required this.start,
    required this.end,
    required this.isActive,
    this.flowColor,
    this.thickness = 3.0,
    this.cycleDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<EnergyFlowEffect> createState() => _EnergyFlowEffectState();
}

class _EnergyFlowEffectState extends State<EnergyFlowEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    );

    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EnergyFlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    final flowColor = widget.flowColor ?? colors.energyPulse;

    return AnimatedBuilder(
      animation: _flowAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _EnergyFlowPainter(
            start: widget.start,
            end: widget.end,
            flowProgress: _flowAnimation.value,
            flowColor: flowColor,
            thickness: widget.thickness,
          ),
        );
      },
    );
  }
}

class _EnergyFlowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double flowProgress;
  final Color flowColor;
  final double thickness;

  _EnergyFlowPainter({
    required this.start,
    required this.end,
    required this.flowProgress,
    required this.flowColor,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineVector = end - start;
    final lineLength = lineVector.distance;
    final lineDirection = lineVector / lineLength;

    // Draw base wire
    final basePaint = Paint()
      ..color = flowColor.withOpacity(0.3)
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, basePaint);

    // Draw flowing energy particles
    final particleSpacing = thickness * 3;
    final numParticles = (lineLength / particleSpacing).floor();

    for (int i = 0; i < numParticles; i++) {
      final particleProgress = (flowProgress + i / numParticles) % 1.0;
      final particlePosition = start + lineVector * particleProgress;

      // Particle glow
      final glowPaint = Paint()
        ..color = flowColor.withOpacity(0.8 * (1 - particleProgress.abs()))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, thickness * 2);

      canvas.drawCircle(particlePosition, thickness * 1.5, glowPaint);

      // Particle core
      final particlePaint = Paint()
        ..color = flowColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particlePosition, thickness * 0.8, particlePaint);
    }

    // Draw energy wave effect
    final wavePaint = Paint()
      ..color = flowColor.withOpacity(0.4)
      ..strokeWidth = thickness * 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveAmplitude = thickness * 0.5;
    final waveFrequency = 4;

    for (double t = 0; t <= 1; t += 0.01) {
      final basePoint = start + lineVector * t;
      final perpendicular = Offset(-lineDirection.dy, lineDirection.dx);
      final waveOffset = sin((t + flowProgress) * waveFrequency * 2 * pi) * waveAmplitude;

      final wavePoint = basePoint + perpendicular * waveOffset;

      if (t == 0) {
        path.moveTo(wavePoint.dx, wavePoint.dy);
      } else {
        path.lineTo(wavePoint.dx, wavePoint.dy);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_EnergyFlowPainter oldDelegate) {
    return oldDelegate.flowProgress != flowProgress ||
           oldDelegate.start != start ||
           oldDelegate.end != end ||
           oldDelegate.flowColor != flowColor ||
           oldDelegate.thickness != thickness;
  }
}

// Pre-configured wire effect for circuit connections
class CircuitWireEffect extends StatelessWidget {
  final Offset start;
  final Offset end;
  final bool isPowered;
  final bool isActive;

  const CircuitWireEffect({
    super.key,
    required this.start,
    required this.end,
    this.isPowered = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;

    return Stack(
      children: [
        // Base wire
        CustomPaint(
          painter: _BaseWirePainter(
            start: start,
            end: end,
            color: isPowered ? colors.wireActive : colors.wireInactive,
          ),
        ),

        // Energy flow effect when active
        if (isActive && isPowered)
          EnergyFlowEffect(
            start: start,
            end: end,
            isActive: true,
            flowColor: colors.energyPulse,
          ),

        // Glow effect for powered wires
        if (isPowered)
          CustomPaint(
            painter: _WireGlowPainter(
              start: start,
              end: end,
              glowColor: colors.wireActive,
            ),
          ),
      ],
    );
  }
}

class _BaseWirePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _BaseWirePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(_BaseWirePainter oldDelegate) => false;
}

class _WireGlowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color glowColor;

  _WireGlowPainter({
    required this.start,
    required this.end,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.4)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawLine(start, end, glowPaint);
  }

  @override
  bool shouldRepaint(_WireGlowPainter oldDelegate) => false;
}
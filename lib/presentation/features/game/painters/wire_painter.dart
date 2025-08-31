import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart'; // Import CircuitWire

class WirePainter extends CustomPainter {
  final List<CircuitWire> wires;
  final CircuitColorScheme circuitColors;
  final double scale;

  WirePainter({
    required this.wires,
    required this.circuitColors,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0 * scale;

    for (final wire in wires) {
      paint.color = wire.isActive ? circuitColors.wireActive : circuitColors.wireInactive;
      canvas.drawLine(
        Offset(wire.startX * 60.0 * scale, wire.startY * 60.0 * scale),
        Offset(wire.endX * 60.0 * scale, wire.endY * 60.0 * scale),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WirePainter oldDelegate) {
    return oldDelegate.wires != wires || oldDelegate.scale != scale;
  }
}
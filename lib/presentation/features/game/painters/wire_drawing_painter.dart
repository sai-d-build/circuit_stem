import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

/// WireDrawingPainter handles the visual rendering of wires being drawn.
/// This painter extracts the wire drawing logic from GameCanvas.
class WireDrawingPainter extends CustomPainter {
  final Offset? startPosition;
  final Offset? endPosition;
  final CircuitColorScheme circuitColors;

  WireDrawingPainter({
    required this.startPosition,
    required this.endPosition,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (startPosition == null || endPosition == null) return;

    final paint = Paint()
      ..color = circuitColors.wireInactive
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(startPosition!, endPosition!, paint);

    // Draw connection points
    final pointPaint = Paint()
      ..color = circuitColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startPosition!, 6, pointPaint);
    canvas.drawCircle(endPosition!, 6, pointPaint);
  }

  @override
  bool shouldRepaint(WireDrawingPainter oldDelegate) {
    return oldDelegate.startPosition != startPosition ||
        oldDelegate.endPosition != endPosition;
  }
}

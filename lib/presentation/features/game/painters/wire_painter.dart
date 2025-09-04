import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart'; // Import CircuitWire
import 'package:sparkcircuit/core/debug/structured_logger.dart';

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
      ..strokeWidth = UIConstants.wireThickness * scale;

    for (final wire in wires) {
      final startOffset = Offset(wire.startX * GameConstants.gridCellSize * scale, wire.startY * GameConstants.gridCellSize * scale);
      final endOffset = Offset(wire.endX * GameConstants.gridCellSize * scale, wire.endY * GameConstants.gridCellSize * scale);

      // Draw glow effect for active wires
      if (wire.isActive) {
        final glowPaint = Paint()
          ..color = circuitColors.glowEffect.withValues(alpha: GameConstants.highOpacity) // Use glowEffect color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = GameConstants.wireGlowRadius * scale // Wider for glow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, GameConstants.selectionGlowRadius * scale);
        canvas.drawLine(startOffset, endOffset, glowPaint);
      }

      // Draw main wire
      paint.color = wire.isActive ? circuitColors.wireActive : circuitColors.wireInactive;
      canvas.drawLine(
        startOffset,
        endOffset,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WirePainter oldDelegate) {
    return oldDelegate.wires != wires || oldDelegate.scale != scale;
  }
}
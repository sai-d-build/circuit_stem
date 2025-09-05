import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart'; // Import CircuitWire
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';

class WirePainter extends CustomPainter {
  final List<CircuitWire> wires;
  final CircuitColorScheme circuitColors;
  final CoordinateService coordinateService;

  WirePainter({
    required this.wires,
    required this.circuitColors,
    required this.coordinateService,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = UIConstants.wireThickness * coordinateService.scale;

    for (final wire in wires) {
      final startOffset = coordinateService.gridToScreen(Offset(wire.startX, wire.startY));
      final endOffset = coordinateService.gridToScreen(Offset(wire.endX, wire.endY));

      // Draw glow effect for active wires
      if (wire.isActive) {
        final glowPaint = Paint()
          ..color = circuitColors.glowEffect.withValues(alpha: GameConstants.highOpacity) // Use glowEffect color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = GameConstants.wireGlowRadius * coordinateService.scale // Wider for glow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, GameConstants.selectionGlowRadius * coordinateService.scale);
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
    return oldDelegate.wires != wires || oldDelegate.coordinateService != coordinateService;
  }
}
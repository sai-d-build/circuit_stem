import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart' show GameConstants;

class CanvasPainter extends CustomPainter {
  final GameCanvasController controller;
  final CircuitColorScheme circuitColors;

  CanvasPainter({
    required this.controller,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = circuitColors.surface
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: GameConstants.lowOpacity)
      ..strokeWidth = GameConstants.gridLineStroke
      ..style = PaintingStyle.stroke;

    final majorGridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: GameConstants.mediumOpacity)
      ..strokeWidth = GameConstants.majorGridStroke
      ..style = PaintingStyle.stroke;

    final cellSize = controller.scaledCellSize;
    final panOffset = controller.panOffset;

    // Calculate visible bounds
    final startX = (-panOffset.dx / cellSize).floor();
    final endX = ((size.width - panOffset.dx) / cellSize).ceil();
    final startY = (-panOffset.dy / cellSize).floor();
    final endY = ((size.height - panOffset.dy) / cellSize).ceil();

    // Draw vertical lines
    for (int i = startX; i <= endX; i++) {
      final x = i * cellSize + panOffset.dx;
      if (x >= -GameConstants.gridBoundsOffset && x <= size.width + GameConstants.gridBoundsOffset) {
        final paint = (i % GameConstants.majorGridInterval == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Draw horizontal lines
    for (int i = startY; i <= endY; i++) {
      final y = i * cellSize + panOffset.dy;
      if (y >= -GameConstants.gridBoundsOffset && y <= size.height + GameConstants.gridBoundsOffset) {
        final paint = (i % GameConstants.majorGridInterval == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.controller != controller ||
           oldDelegate.circuitColors != circuitColors;
  }
}
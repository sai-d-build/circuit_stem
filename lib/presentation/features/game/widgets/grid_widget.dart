import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A reusable grid widget for drawing grid patterns
class GridWidget extends StatelessWidget {
  final double cellSize;
  final Color gridColor;
  final Color majorGridColor;
  final double strokeWidth;
  final double majorStrokeWidth;
  final int majorGridInterval;
  final Offset offset;
  final Size gridSize;
  final bool showOrigin;
  final bool showCoordinates;

  const GridWidget({
    super.key,
    required this.cellSize,
    required this.gridColor,
    this.majorGridColor = Colors.green,
    this.strokeWidth = 0.5,
    this.majorStrokeWidth = 1.0,
    this.majorGridInterval = 5,
    this.offset = Offset.zero,
    this.gridSize = const Size(50, 50),
    this.showOrigin = true,
    this.showCoordinates = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(
        cellSize: cellSize,
        gridColor: gridColor,
        majorGridColor: majorGridColor,
        strokeWidth: strokeWidth,
        majorStrokeWidth: majorStrokeWidth,
        majorGridInterval: majorGridInterval,
        offset: offset,
        gridSize: gridSize,
        showOrigin: showOrigin,
        showCoordinates: showCoordinates,
      ),
      child: Container(),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  final Color gridColor;
  final Color majorGridColor;
  final double strokeWidth;
  final double majorStrokeWidth;
  final int majorGridInterval;
  final Offset offset;
  final Size gridSize;
  final bool showOrigin;
  final bool showCoordinates;

  GridPainter({
    required this.cellSize,
    required this.gridColor,
    required this.majorGridColor,
    required this.strokeWidth,
    required this.majorStrokeWidth,
    required this.majorGridInterval,
    required this.offset,
    required this.gridSize,
    required this.showOrigin,
    required this.showCoordinates,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    
    if (showOrigin) {
      _drawOrigin(canvas, size);
    }
    
    if (showCoordinates) {
      _drawCoordinates(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final regularPaint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final majorPaint = Paint()
      ..color = majorGridColor
      ..strokeWidth = majorStrokeWidth
      ..style = PaintingStyle.stroke;

    // Calculate visible range
    final startX = math.max(0, (-offset.dx / cellSize).floor());
    final endX = math.min(gridSize.width.toInt(), ((size.width - offset.dx) / cellSize).ceil());
    final startY = math.max(0, (-offset.dy / cellSize).floor());
    final endY = math.min(gridSize.height.toInt(), ((size.height - offset.dy) / cellSize).ceil());

    // Draw vertical lines
    for (int i = startX; i <= endX; i++) {
      final x = i * cellSize + offset.dx;
      if (x >= -strokeWidth && x <= size.width + strokeWidth) {
        final paint = (i % majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw horizontal lines
    for (int i = startY; i <= endY; i++) {
      final y = i * cellSize + offset.dy;
      if (y >= -strokeWidth && y <= size.height + strokeWidth) {
        final paint = (i % majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  void _drawOrigin(Canvas canvas, Size size) {
    final originX = offset.dx;
    final originY = offset.dy;

    // Only draw if origin is visible
    if (originX >= -20 && originX <= size.width + 20 &&
        originY >= -20 && originY <= size.height + 20) {
      
      final originPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final originCenter = Paint()
        ..color = Colors.red.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      // Draw origin point
      canvas.drawCircle(Offset(originX, originY), 4, originCenter);
      canvas.drawCircle(Offset(originX, originY), 4, originPaint);

      // Draw axes indicators
      const axisLength = 15.0;
      canvas.drawLine(
        Offset(originX - axisLength, originY),
        Offset(originX + axisLength, originY),
        originPaint,
      );
      canvas.drawLine(
        Offset(originX, originY - axisLength),
        Offset(originX, originY + axisLength),
        originPaint,
      );
    }
  }

  void _drawCoordinates(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate visible major grid lines for coordinate display
    final startX = math.max(0, (-offset.dx / cellSize / majorGridInterval).floor() * majorGridInterval);
    final endX = math.min(
      gridSize.width.toInt(),
      ((size.width - offset.dx) / cellSize / majorGridInterval).ceil() * majorGridInterval,
    );
    final startY = math.max(0, (-offset.dy / cellSize / majorGridInterval).floor() * majorGridInterval);
    final endY = math.min(
      gridSize.height.toInt(),
      ((size.height - offset.dy) / cellSize / majorGridInterval).ceil() * majorGridInterval,
    );

    // Draw X coordinates
    for (int i = startX; i <= endX; i += majorGridInterval) {
      if (i == 0) continue; // Skip origin
      
      final x = i * cellSize + offset.dx;
      if (x >= 20 && x <= size.width - 20) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: gridColor.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        
        // Draw background
        final bgRect = Rect.fromCenter(
          center: Offset(x, 15),
          width: textPainter.width + 6,
          height: textPainter.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
        
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, 15 - textPainter.height / 2),
        );
      }
    }

    // Draw Y coordinates
    for (int i = startY; i <= endY; i += majorGridInterval) {
      if (i == 0) continue; // Skip origin
      
      final y = i * cellSize + offset.dy;
      if (y >= 20 && y <= size.height - 20) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: gridColor.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        
        // Draw background
        final bgRect = Rect.fromCenter(
          center: Offset(15, y),
          width: textPainter.width + 6,
          height: textPainter.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
        
        textPainter.paint(
          canvas,
          Offset(15 - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    // Draw origin coordinate
    final originX = offset.dx;
    final originY = offset.dy;
    if (originX >= 10 && originX <= size.width - 30 &&
        originY >= 10 && originY <= size.height - 30) {
      textPainter.text = const TextSpan(
        text: '(0,0)',
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      
      final bgRect = Rect.fromCenter(
        center: Offset(originX + 15, originY - 15),
        width: textPainter.width + 6,
        height: textPainter.height + 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
      
      textPainter.paint(
        canvas,
        Offset(
          originX + 15 - textPainter.width / 2,
          originY - 15 - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize ||
           oldDelegate.gridColor != gridColor ||
           oldDelegate.majorGridColor != majorGridColor ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.majorStrokeWidth != majorStrokeWidth ||
           oldDelegate.majorGridInterval != majorGridInterval ||
           oldDelegate.offset != offset ||
           oldDelegate.gridSize != gridSize ||
           oldDelegate.showOrigin != showOrigin ||
           oldDelegate.showCoordinates != showCoordinates;
  }
}
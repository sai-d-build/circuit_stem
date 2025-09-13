import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/services/bounds_manager.dart';

// Enhanced visual feedback system for bounds
class BoundsVisualizer extends StatelessWidget {
  final UnifiedBoundsManager boundsManager;
  final double cellSize;
  final Offset panOffset;
  final int? hoveredRow;
  final int? hoveredCol;
  final Set<String>? occupiedPositions;

  const BoundsVisualizer({
    super.key,
    required this.boundsManager,
    required this.cellSize,
    required this.panOffset,
    this.hoveredRow,
    this.hoveredCol,
    this.occupiedPositions,
  });

  @override
  Widget build(BuildContext context) {
    final config = boundsManager.getConfiguration();

    if (!config.showBoundaryIndicators) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: BoundsPainter(
        boundsManager: boundsManager,
        cellSize: cellSize,
        panOffset: panOffset,
        hoveredRow: hoveredRow,
        hoveredCol: hoveredCol,
        occupiedPositions: occupiedPositions,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class BoundsPainter extends CustomPainter {
  final UnifiedBoundsManager boundsManager;
  final double cellSize;
  final Offset panOffset;
  final int? hoveredRow;
  final int? hoveredCol;
  final Set<String>? occupiedPositions;

  BoundsPainter({
    required this.boundsManager,
    required this.cellSize,
    required this.panOffset,
    this.hoveredRow,
    this.hoveredCol,
    this.occupiedPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final config = boundsManager.getConfiguration();

    // Draw boundaries in order from back to front
    _drawVisualBounds(canvas, config);
    _drawLevelBounds(canvas, config);
    _drawExtendedBounds(canvas, config);
    _drawHoverFeedback(canvas, config);
    _drawPlacementZones(canvas, config);
  }

  void _drawVisualBounds(Canvas canvas, BoundsConfiguration config) {
    if (config.visualBounds == config.levelBounds) return;

    final visualRect = boundsManager.getVisualBoundsRect(cellSize, panOffset);

    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed visual boundary
    _drawDashedRect(canvas, visualRect, paint, dashLength: 5, gapLength: 5);

    // Add corner markers for visual bounds
    _drawCornerMarkers(canvas, visualRect, Colors.grey.withValues(alpha: 0.6), 8.0);
  }

  void _drawLevelBounds(Canvas canvas, BoundsConfiguration config) {
    final levelRect = boundsManager.getLevelBoundsRect(cellSize, panOffset);

    // Apply boundary style based on configuration
    switch (config.boundaryStyle) {
      case BoundaryStyle.solid:
        _drawSolidBoundary(canvas, levelRect, config);
        break;
      case BoundaryStyle.dashed:
        _drawDashedBoundary(canvas, levelRect, config);
        break;
      case BoundaryStyle.dotted:
        _drawDottedBoundary(canvas, levelRect, config);
        break;
      case BoundaryStyle.gradient:
        _drawGradientBoundary(canvas, levelRect, config);
        break;
      case BoundaryStyle.animated:
        _drawAnimatedBoundary(canvas, levelRect, config);
        break;
    }

    // Add corner markers for level bounds
    _drawCornerMarkers(canvas, levelRect, config.boundaryColor.withValues(alpha: 0.8), 12.0);
  }

  void _drawSolidBoundary(Canvas canvas, Rect rect, BoundsConfiguration config) {
    final paint = Paint()
      ..color = config.boundaryColor
      ..strokeWidth = config.boundaryWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(rect, paint);

    // Add subtle fill for level area
    final fillPaint = Paint()
      ..color = config.boundaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawDashedBoundary(Canvas canvas, Rect rect, BoundsConfiguration config) {
    final paint = Paint()
      ..color = config.boundaryColor
      ..strokeWidth = config.boundaryWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedRect(canvas, rect, paint, dashLength: 8, gapLength: 4);

    // Add subtle fill for level area
    final fillPaint = Paint()
      ..color = config.boundaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawDottedBoundary(Canvas canvas, Rect rect, BoundsConfiguration config) {
    final paint = Paint()
      ..color = config.boundaryColor
      ..style = PaintingStyle.fill;

    _drawDottedRect(canvas, rect, paint, dotRadius: config.boundaryWidth / 2, dotSpacing: 6);

    // Add subtle fill for level area
    final fillPaint = Paint()
      ..color = config.boundaryColor.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawGradientBoundary(Canvas canvas, Rect rect, BoundsConfiguration config) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          config.boundaryColor,
          config.boundaryColor.withValues(alpha: 0.3),
          config.boundaryColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..strokeWidth = config.boundaryWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(rect, gradientPaint);

    // Add gradient fill for level area
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          config.boundaryColor.withValues(alpha: 0.1),
          config.boundaryColor.withValues(alpha: 0.05),
          config.boundaryColor.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawAnimatedBoundary(Canvas canvas, Rect rect, BoundsConfiguration config) {
    // For animation, we'll use a pulsing effect
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulseOpacity = (math.sin(time * 2) + 1) / 2; // 0 to 1

    final paint = Paint()
      ..color = config.boundaryColor.withValues(alpha: 0.5 + pulseOpacity * 0.5)
      ..strokeWidth = config.boundaryWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(rect, paint);

    // Add animated fill for level area
    final fillPaint = Paint()
      ..color = config.boundaryColor.withValues(alpha: pulseOpacity * 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawExtendedBounds(Canvas canvas, BoundsConfiguration config) {
    if (config.extendedBounds == null) return;

    final extendedRect = Rect.fromLTWH(
      panOffset.dx,
      panOffset.dy,
      config.extendedBounds!.width * cellSize,
      config.extendedBounds!.height * cellSize,
    );

    final paint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dotted extended boundary
    _drawDottedRect(canvas, extendedRect, paint, dotRadius: 2, dotSpacing: 8);
  }

  void _drawHoverFeedback(Canvas canvas, BoundsConfiguration config) {
    if (hoveredRow == null || hoveredCol == null) return;

    final hoverPos = boundsManager.gridToScreen(hoveredRow!, hoveredCol!, cellSize, panOffset);
    final hoverRect = Rect.fromLTWH(hoverPos.dx, hoverPos.dy, cellSize, cellSize);

    // Check bounds status for hover position
    final validation = boundsManager.validatePosition(
      hoveredRow!,
      hoveredCol!,
      occupiedPositions: occupiedPositions,
    );

    Color hoverColor;
    if (!validation.isValid) {
      hoverColor = Colors.red.withValues(alpha: 0.3);
    } else if (!validation.isWithinLevelBounds && validation.isWithinVisualBounds) {
      hoverColor = Colors.orange.withValues(alpha: 0.3);
    } else {
      hoverColor = Colors.green.withValues(alpha: 0.3);
    }

    final hoverPaint = Paint()
      ..color = hoverColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(hoverRect, hoverPaint);

    // Draw hover border
    final borderPaint = Paint()
      ..color = hoverColor.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(hoverRect, borderPaint);

    // Draw corner markers for hover
    _drawCornerMarkers(canvas, hoverRect, hoverColor.withValues(alpha: 0.9), cellSize * 0.15);
  }

  void _drawPlacementZones(Canvas canvas, BoundsConfiguration config) {
    if (!config.showBoundaryWarnings) return;

    final levelRect = boundsManager.getLevelBoundsRect(cellSize, panOffset);
    final visualRect = boundsManager.getVisualBoundsRect(cellSize, panOffset);

    // Draw warning zone (between level and visual bounds)
    if (levelRect != visualRect) {
      final warningPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      final warningRect = Rect.fromLTRB(
        levelRect.right,
        levelRect.top,
        visualRect.right,
        visualRect.bottom,
      );

      if (warningRect.width > 0 && warningRect.height > 0) {
        canvas.drawRect(warningRect, warningPaint);

        // Add warning pattern
        _drawWarningPattern(canvas, warningRect);
      }
    }
  }

  void _drawWarningPattern(Canvas canvas, Rect rect) {
    final patternPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const patternSize = 20.0;
    for (double x = rect.left; x < rect.right; x += patternSize) {
      for (double y = rect.top; y < rect.bottom; y += patternSize) {
        // Draw diagonal lines for warning pattern
        canvas.drawLine(
          Offset(x, y),
          Offset(x + patternSize * 0.5, y + patternSize * 0.5),
          patternPaint,
        );
        canvas.drawLine(
          Offset(x + patternSize * 0.5, y),
          Offset(x, y + patternSize * 0.5),
          patternPaint,
        );
      }
    }
  }

  void _drawCornerMarkers(Canvas canvas, Rect rect, Color color, double size) {
    final markerPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    _drawCorner(canvas, markerPaint, rect.left, rect.top, size, true, true);
    // Top-right corner
    _drawCorner(canvas, markerPaint, rect.right, rect.top, size, false, true);
    // Bottom-left corner
    _drawCorner(canvas, markerPaint, rect.left, rect.bottom, size, true, false);
    // Bottom-right corner
    _drawCorner(canvas, markerPaint, rect.right, rect.bottom, size, false, false);
  }

  void _drawCorner(Canvas canvas, Paint paint, double x, double y, double size, bool left, bool top) {
    final dx = left ? size : -size;
    final dy = top ? size : -size;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint, {double dashLength = 5, double gapLength = 5}) {
    final path = Path();
    final totalLength = (rect.width + rect.height) * 2;
    final dashGapLength = dashLength + gapLength;

    double distance = 0;
    while (distance < totalLength) {
      final segmentStart = distance;
      final segmentEnd = math.min(distance + dashLength, totalLength);

      if (segmentStart < rect.width) {
        // Top edge
        final startX = rect.left + segmentStart;
        final endX = rect.left + math.min(segmentEnd, rect.width);
        path.moveTo(startX, rect.top);
        path.lineTo(endX, rect.top);
      } else if (segmentStart < rect.width + rect.height) {
        // Right edge
        final edgePos = segmentStart - rect.width;
        final startY = rect.top + edgePos;
        final endY = rect.top + math.min(segmentEnd - rect.width, rect.height);
        path.moveTo(rect.right, startY);
        path.lineTo(rect.right, endY);
      } else if (segmentStart < rect.width * 2 + rect.height) {
        // Bottom edge
        final edgePos = segmentStart - rect.width - rect.height;
        final startX = rect.right - edgePos;
        final endX = rect.right - math.min(segmentEnd - rect.width - rect.height, rect.width);
        path.moveTo(startX, rect.bottom);
        path.lineTo(endX, rect.bottom);
      } else {
        // Left edge
        final edgePos = segmentStart - rect.width * 2 - rect.height;
        final startY = rect.bottom - edgePos;
        final endY = rect.bottom - math.min(segmentEnd - rect.width * 2 - rect.height, rect.height);
        path.moveTo(rect.left, startY);
        path.lineTo(rect.left, endY);
      }

      distance += dashGapLength;
    }

    canvas.drawPath(path, paint);
  }

  void _drawDottedRect(Canvas canvas, Rect rect, Paint paint, {double dotRadius = 2, double dotSpacing = 8}) {
    // Draw dots around the rectangle perimeter
    final perimeter = (rect.width + rect.height) * 2;
    final numDots = (perimeter / dotSpacing).round();

    for (int i = 0; i < numDots; i++) {
      final distance = i * dotSpacing;
      Offset dotPosition;

      if (distance < rect.width) {
        // Top edge
        dotPosition = Offset(rect.left + distance, rect.top);
      } else if (distance < rect.width + rect.height) {
        // Right edge
        dotPosition = Offset(rect.right, rect.top + (distance - rect.width));
      } else if (distance < rect.width * 2 + rect.height) {
        // Bottom edge
        dotPosition = Offset(rect.right - (distance - rect.width - rect.height), rect.bottom);
      } else {
        // Left edge
        dotPosition = Offset(rect.left, rect.bottom - (distance - rect.width * 2 - rect.height));
      }

      canvas.drawCircle(dotPosition, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(BoundsPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize ||
           oldDelegate.panOffset != panOffset ||
           oldDelegate.hoveredRow != hoveredRow ||
           oldDelegate.hoveredCol != hoveredCol ||
           oldDelegate.occupiedPositions != occupiedPositions;
  }
}

// Utility widget for bounds information display
class BoundsInfoPanel extends StatelessWidget {
  final UnifiedBoundsManager boundsManager;
  final int? currentRow;
  final int? currentCol;

  const BoundsInfoPanel({
    super.key,
    required this.boundsManager,
    this.currentRow,
    this.currentCol,
  });

  @override
  Widget build(BuildContext context) {
    final config = boundsManager.getConfiguration();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bounds Information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          _buildBoundsInfo('Level Bounds', config.levelBounds),
          _buildBoundsInfo('Visual Bounds', config.visualBounds),
          if (config.extendedBounds != null)
            _buildBoundsInfo('Extended Bounds', config.extendedBounds!),
          const SizedBox(height: 4),
          Text(
            'Strategy: ${config.strategy.name}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          if (currentRow != null && currentCol != null)
            _buildPositionInfo(currentRow!, currentCol!),
        ],
      ),
    );
  }

  Widget _buildBoundsInfo(String label, Size bounds) {
    return Text(
      '$label: ${bounds.width.toInt()}x${bounds.height.toInt()}',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );
  }

  Widget _buildPositionInfo(int row, int col) {
    final validation = boundsManager.validatePosition(row, col);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position: ($row, $col)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Level: ${validation.isWithinLevelBounds ? '✓' : '✗'}',
          style: TextStyle(
            color: validation.isWithinLevelBounds ? Colors.green : Colors.red,
            fontSize: 11,
          ),
        ),
        Text(
          'Visual: ${validation.isWithinVisualBounds ? '✓' : '✗'}',
          style: TextStyle(
            color: validation.isWithinVisualBounds ? Colors.green : Colors.red,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
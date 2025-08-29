import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/game_state.dart';

class WirePainter extends CustomPainter {
  final List<CircuitConnection> connections;
  final List<CircuitComponent> components;
  final CircuitColorScheme circuitColors;
  final bool isSimulating;
  final double scale;
  final double animationProgress;

  WirePainter({
    required this.connections,
    required this.components,
    required this.circuitColors,
    required this.isSimulating,
    this.scale = 1.0,
    this.animationProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }
  }

  void _drawConnection(Canvas canvas, CircuitConnection connection) {
    final fromComponent = _findComponent(connection.fromComponentId);
    final toComponent = _findComponent(connection.toComponentId);
    
    if (fromComponent == null || toComponent == null) return;

    final fromPos = _getComponentCenter(fromComponent);
    final toPos = _getComponentCenter(toComponent);

    // Draw wire
    _drawWire(canvas, fromPos, toPos, connection);
    
    // Draw current flow if active
    if (connection.isActive && isSimulating && connection.current > 0) {
      _drawCurrentFlow(canvas, fromPos, toPos, connection.current);
    }
  }

  void _drawWire(Canvas canvas, Offset start, Offset end, CircuitConnection connection) {
    final wirePaint = Paint()
      ..color = connection.isActive && isSimulating
          ? circuitColors.wireActive
          : circuitColors.wireInactive
      ..strokeWidth = 3.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // For now, draw straight lines
    // In a more advanced implementation, we could draw curved or routed paths
    canvas.drawLine(start, end, wirePaint);

    // Draw connection points
    final connectionPaint = Paint()
      ..color = wirePaint.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(start, 3.0 * scale, connectionPaint);
    canvas.drawCircle(end, 3.0 * scale, connectionPaint);
  }

  void _drawCurrentFlow(Canvas canvas, Offset start, Offset end, double current) {
    final direction = (end - start).normalize();
    final distance = (end - start).distance;
    
    // Calculate number of flow indicators based on distance
    final indicatorCount = (distance / (20 * scale)).round().clamp(2, 10);
    final spacing = distance / indicatorCount;
    
    final flowPaint = Paint()
      ..color = circuitColors.wireActive
      ..style = PaintingStyle.fill;

    for (int i = 0; i < indicatorCount; i++) {
      // Animate the flow by offsetting based on time
      final baseOffset = i * spacing;
      final animatedOffset = (baseOffset + (animationProgress * spacing * 2)) % distance;
      final position = start + direction * animatedOffset;
      
      // Draw flow indicator (small circle)
      canvas.drawCircle(position, 2.0 * scale, flowPaint);
    }

    // Draw current direction arrow near the middle
    _drawCurrentArrow(canvas, start, end, direction, current);
  }

  void _drawCurrentArrow(Canvas canvas, Offset start, Offset end, Offset direction, double current) {
    final midPoint = start + (end - start) * 0.5;
    final arrowSize = 8.0 * scale;
    
    final arrowPaint = Paint()
      ..color = circuitColors.wireActive
      ..style = PaintingStyle.fill;

    // Calculate arrow points
    final perpendicular = Offset(-direction.dy, direction.dx);
    final arrowTip = midPoint + direction * arrowSize;
    final arrowBase1 = midPoint - direction * arrowSize/2 + perpendicular * arrowSize/2;
    final arrowBase2 = midPoint - direction * arrowSize/2 - perpendicular * arrowSize/2;

    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBase1.dx, arrowBase1.dy)
      ..lineTo(arrowBase2.dx, arrowBase2.dy)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
    
    // Draw current value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${current.toStringAsFixed(1)}A',
        style: TextStyle(
          color: circuitColors.wireActive,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final textOffset = midPoint + perpendicular * (arrowSize + 5 * scale) - 
                     Offset(textPainter.width / 2, textPainter.height / 2);
    
    // Draw background for text
    final textBgRect = Rect.fromCenter(
      center: textOffset + Offset(textPainter.width / 2, textPainter.height / 2),
      width: textPainter.width + 4,
      height: textPainter.height + 2,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(textBgRect, Radius.circular(2)),
      Paint()..color = circuitColors.surface.withValues(alpha: 0.8),
    );
    
    textPainter.paint(canvas, textOffset);
  }

  CircuitComponent? _findComponent(String componentId) {
    try {
      return components.firstWhere((c) => c.id == componentId);
    } catch (e) {
      return null;
    }
  }

  Offset _getComponentCenter(CircuitComponent component) {
    return Offset(
      component.posX * 60.0 * scale + 30.0 * scale,
      component.posY * 60.0 * scale + 30.0 * scale,
    );
  }

  @override
  bool shouldRepaint(WirePainter oldDelegate) {
    return oldDelegate.connections != connections ||
           oldDelegate.components != components ||
           oldDelegate.isSimulating != isSimulating ||
           oldDelegate.scale != scale ||
           oldDelegate.animationProgress != animationProgress;
  }
}

extension on Offset {
  Offset normalize() {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
}
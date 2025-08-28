import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/presentation/state/game_state.dart';
import 'package:sparkcircuit/presentation/core/animations/glow_effect.dart';

class CircuitComponentDisplay extends ConsumerWidget {
  final GameCanvasController controller;
  final String levelId;

  const CircuitComponentDisplay({
    super.key,
    required this.controller,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final gameState = ref.watch(gameStateProvider(levelId));
    
    return CustomPaint(
      painter: ComponentDisplayPainter(
        controller: controller,
        circuitColors: circuitColors,
        components: gameState.components,
        connections: gameState.connections,
        selectedComponentId: gameState.selectedComponentId,
        isSimulating: gameState.isSimulating,
      ),
      child: Container(),
    );
  }
}

class ComponentDisplayPainter extends CustomPainter {
  final GameCanvasController controller;
  final CircuitColorScheme circuitColors;
  final List<CircuitComponent> components;
  final List<CircuitConnection> connections;
  final String? selectedComponentId;
  final bool isSimulating;

  ComponentDisplayPainter({
    required this.controller,
    required this.circuitColors,
    required this.components,
    required this.connections,
    this.selectedComponentId,
    required this.isSimulating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections (wires) first
    _drawConnections(canvas);
    
    // Draw components on top
    _drawComponents(canvas);
    
    // Draw selection highlights
    _drawSelectionHighlights(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final wirePaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      final fromComponent = _findComponent(connection.fromComponentId);
      final toComponent = _findComponent(connection.toComponentId);
      
      if (fromComponent != null && toComponent != null) {
        final fromPos = controller.gridToScreen(Offset(fromComponent.posX, fromComponent.posY));
        final toPos = controller.gridToScreen(Offset(toComponent.posX, toComponent.posY));
        
        // Set wire color based on current flow
        wirePaint.color = connection.isActive && isSimulating
            ? circuitColors.wireActive
            : circuitColors.wireInactive;
        
        canvas.drawLine(fromPos, toPos, wirePaint);
        
        // Draw current flow animation if active
        if (connection.isActive && isSimulating && connection.current > 0) {
          _drawCurrentFlow(canvas, fromPos, toPos, connection.current);
        }
      }
    }
  }

  void _drawComponents(Canvas canvas) {
    for (final component in components) {
      final screenPos = controller.gridToScreen(Offset(component.posX, component.posY));
      final isSelected = component.id == selectedComponentId;
      
      _drawComponent(canvas, component, screenPos, isSelected);
    }
  }

  void _drawComponent(Canvas canvas, CircuitComponent component, Offset position, bool isSelected) {
    final componentSize = 40.0 * controller.scale;
    final rect = Rect.fromCenter(center: position, width: componentSize, height: componentSize);
    
    final componentPaint = Paint()
      ..color = component.isActive && isSimulating
          ? circuitColors.componentBase
          : circuitColors.componentBase.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected
          ? circuitColors.primary
          : circuitColors.outline
      ..strokeWidth = isSelected ? 3.0 : 1.5
      ..style = PaintingStyle.stroke;

    // Draw component background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * controller.scale)),
      componentPaint,
    );

    // Draw component border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * controller.scale)),
      borderPaint,
    );

    // Draw component-specific details
    _drawComponentDetails(canvas, component, rect);

    // Draw component label
    _drawComponentLabel(canvas, component, position, componentSize);
  }

  void _drawComponentDetails(Canvas canvas, CircuitComponent component, Rect rect) {
    final detailPaint = Paint()
      ..color = circuitColors.onSurface
      ..strokeWidth = 2.0 * controller.scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (component.type) {
      case 'battery':
        _drawBatteryDetails(canvas, rect, detailPaint);
        break;
      case 'resistor':
        _drawResistorDetails(canvas, rect, detailPaint);
        break;
      case 'led':
        _drawLEDDetails(canvas, rect, detailPaint, component.isActive);
        break;
      case 'switch':
        _drawSwitchDetails(canvas, rect, detailPaint, component.properties['state'] == 'closed');
        break;
      case 'capacitor':
        _drawCapacitorDetails(canvas, rect, detailPaint);
        break;
    }
  }

  void _drawBatteryDetails(Canvas canvas, Rect rect, Paint paint) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final size = rect.width * 0.3;
    
    // Draw + and - terminals
    canvas.drawLine(
      Offset(centerX - size/2, centerY - size/3),
      Offset(centerX - size/2, centerY + size/3),
      paint..strokeWidth = 3.0 * controller.scale,
    );
    canvas.drawLine(
      Offset(centerX + size/2, centerY - size/6),
      Offset(centerX + size/2, centerY + size/6),
      paint..strokeWidth = 2.0 * controller.scale,
    );
  }

  void _drawResistorDetails(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final size = rect.width * 0.4;
    
    // Draw zigzag pattern
    path.moveTo(centerX - size/2, centerY);
    for (int i = 0; i < 4; i++) {
      path.lineTo(centerX - size/2 + (i + 0.5) * size/4, centerY + (i % 2 == 0 ? -size/4 : size/4));
      path.lineTo(centerX - size/2 + (i + 1) * size/4, centerY);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawLEDDetails(Canvas canvas, Rect rect, Paint paint, bool isActive) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final size = rect.width * 0.3;
    
    // Draw LED symbol (triangle with line)
    final path = Path();
    path.moveTo(centerX - size/3, centerY - size/3);
    path.lineTo(centerX + size/3, centerY);
    path.lineTo(centerX - size/3, centerY + size/3);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(centerX + size/3, centerY - size/3),
      Offset(centerX + size/3, centerY + size/3),
      paint,
    );
    
    // Draw glow effect if active
    if (isActive) {
      final glowPaint = Paint()
        ..color = circuitColors.wireActive.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rect.center, size/2, glowPaint);
    }
  }

  void _drawSwitchDetails(Canvas canvas, Rect rect, Paint paint, bool isClosed) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final size = rect.width * 0.4;
    
    // Draw switch contacts
    canvas.drawCircle(Offset(centerX - size/2, centerY), 2 * controller.scale, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(centerX + size/2, centerY), 2 * controller.scale, paint);
    
    // Draw switch lever
    final leverEnd = isClosed
        ? Offset(centerX + size/2, centerY)
        : Offset(centerX + size/3, centerY - size/3);
    
    canvas.drawLine(
      Offset(centerX - size/2, centerY),
      leverEnd,
      paint..style = PaintingStyle.stroke,
    );
  }

  void _drawCapacitorDetails(Canvas canvas, Rect rect, Paint paint) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final size = rect.width * 0.3;
    
    // Draw parallel plates
    canvas.drawLine(
      Offset(centerX - size/6, centerY - size/2),
      Offset(centerX - size/6, centerY + size/2),
      paint..strokeWidth = 3.0 * controller.scale,
    );
    canvas.drawLine(
      Offset(centerX + size/6, centerY - size/2),
      Offset(centerX + size/6, centerY + size/2),
      paint,
    );
  }

  void _drawComponentLabel(Canvas canvas, CircuitComponent component, Offset position, double componentSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getComponentLabel(component),
        style: TextStyle(
          color: circuitColors.onSurface,
          fontSize: 10 * controller.scale,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    final labelPosition = Offset(
      position.dx - textPainter.width / 2,
      position.dy + componentSize/2 + 4 * controller.scale,
    );
    
    textPainter.paint(canvas, labelPosition);
  }

  String _getComponentLabel(CircuitComponent component) {
    switch (component.type) {
      case 'battery':
        final voltage = component.properties['voltage'] ?? 9.0;
        return '${voltage}V';
      case 'resistor':
        final resistance = component.properties['resistance'] ?? 1000.0;
        return '${resistance.toInt()}Ω';
      case 'led':
        return 'LED';
      case 'switch':
        final state = component.properties['state'] ?? 'open';
        return state.toUpperCase();
      case 'capacitor':
        final capacitance = component.properties['capacitance'] ?? 0.001;
        return '${capacitance}F';
      default:
        return component.type.toUpperCase();
    }
  }

  void _drawCurrentFlow(Canvas canvas, Offset start, Offset end, double current) {
    // Animate current flow with moving dots
    final flowPaint = Paint()
      ..color = circuitColors.wireActive
      ..style = PaintingStyle.fill;
    
    final direction = (end - start).normalized;
    final distance = (end - start).distance;
    final dotCount = (distance / 20).round();
    
    for (int i = 0; i < dotCount; i++) {
      final t = (i / dotCount) + (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
      final dotPosition = start + direction * (distance * (t % 1.0));
      canvas.drawCircle(dotPosition, 2 * controller.scale, flowPaint);
    }
  }

  void _drawSelectionHighlights(Canvas canvas) {
    for (final component in components) {
      if (component.id == selectedComponentId) {
        final screenPos = controller.gridToScreen(Offset(component.posX, component.posY));
        final componentSize = 40.0 * controller.scale;
        final rect = Rect.fromCenter(center: screenPos, width: componentSize + 8, height: componentSize + 8);
        
        final highlightPaint = Paint()
          ..color = circuitColors.primary.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(12 * controller.scale)),
          highlightPaint,
        );
      }
    }
  }

  CircuitComponent? _findComponent(String componentId) {
    try {
      return components.firstWhere((c) => c.id == componentId);
    } catch (e) {
      return null;
    }
  }

  @override
  bool shouldRepaint(ComponentDisplayPainter oldDelegate) {
    return oldDelegate.components != components ||
           oldDelegate.connections != connections ||
           oldDelegate.selectedComponentId != selectedComponentId ||
           oldDelegate.isSimulating != isSimulating ||
           oldDelegate.controller != controller;
  }
}

extension on Offset {
  Offset get normalized {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
}
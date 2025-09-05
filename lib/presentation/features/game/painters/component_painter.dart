import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';

class ComponentPainter extends CustomPainter {
  final List<CircuitComponent> components;
  final CircuitColorScheme circuitColors;
  final String? selectedComponentId;
  final CoordinateService? coordinateService;
  final double scale;

  ComponentPainter({
    required this.components,
    required this.circuitColors,
    this.selectedComponentId,
    this.coordinateService,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use optimized rendering with caching for performance
    // Phase 1 MVP: Basic component rendering with architecture foundation
    for (final component in components) {
      _drawComponent(canvas, component);
    }
  }

  void _drawComponent(Canvas canvas, CircuitComponent component) {
    final isSelected = component.id == selectedComponentId;
    final scale = coordinateService?.scale ?? 1.0;
    final componentSize = GameConstants.componentWidth * scale;

    final center = coordinateService?.gridToScreen(Offset(component.col.toDouble(), component.row.toDouble())) ??
                   Offset(component.col * GameConstants.gridCellSize * scale,
                          component.row * GameConstants.gridCellSize * scale);

    final rect = Rect.fromCenter(
      center: center,
      width: componentSize,
      height: componentSize,
    );

    // Save canvas state before rotation
    canvas.save();

    // Apply rotation transformation if needed
    if (component.rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(component.rotation * (GameConstants.piRadians / 180.0)); // Convert degrees to radians
      canvas.translate(-center.dx, -center.dy);
    }

    // Determine glow color based on component state
    Color glowColor = Colors.transparent;
    if (component.state == ComponentState.powered) {
      glowColor = circuitColors.energyPulse; // Green glow for powered
    }
    else if (component.state == ComponentState.error) {
      glowColor = circuitColors.errorGlow; // Red glow for overloaded/error
    }

    // Draw component background
    final backgroundPaint = Paint()
      ..color = circuitColors.componentBase.withValues(alpha: GameConstants.mediumOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(GameConstants.componentBorderRadius * scale)),
      backgroundPaint,
    );

    // Draw glow effect
    if (glowColor != Colors.transparent) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: GameConstants.highOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, GameConstants.glowRadius * scale);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(GameConstants.componentBorderRadius * scale)),
        glowPaint,
      );
    }

    // Draw component border
    final borderPaint = Paint()
      ..color = isSelected ? circuitColors.neonPrimary : circuitColors.outline
      ..strokeWidth = isSelected ? GameConstants.extraThickStroke * scale : GameConstants.normalStroke * scale
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(GameConstants.componentBorderRadius * scale)),
      borderPaint,
    );

    // Draw component-specific details
    drawComponentDetails(canvas, component, rect, scale);

    // Restore canvas state after rotation
    canvas.restore();
  }

  void drawComponentDetails(Canvas canvas, CircuitComponent component, Rect rect, double scale) {
    final detailPaint = Paint()
      ..color = circuitColors.onSurface
      ..strokeWidth = GameConstants.thickStroke * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (component.type) {
      case ComponentType.battery:
        _drawBatterySymbol(canvas, rect, detailPaint);
        break;
      case ComponentType.resistor:
        _drawResistorSymbol(canvas, rect, detailPaint);
        break;
      case ComponentType.bulb:
        _drawLEDSymbol(canvas, rect, detailPaint, component.state == ComponentState.powered);
        break;
      case ComponentType.switch_:
        _drawSwitchSymbol(canvas, rect, detailPaint, component.properties['isOn'] == true);
        break;
      case ComponentType.capacitor:
        _drawCapacitorSymbol(canvas, rect, detailPaint);
        break;
      case ComponentType.wire:
        _drawWireSymbol(canvas, rect, detailPaint);
        break;
      case ComponentType.buzzer:
        _drawBuzzerSymbol(canvas, rect, detailPaint);
        break;
      default:
        // Draw generic component symbol
        _drawGenericSymbol(canvas, rect, detailPaint);
        break;
    }
  }

  void _drawBatterySymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.3;
    
    // Positive terminal (longer line)
    canvas.drawLine(
      Offset(center.dx - size/4, center.dy - size/2),
      Offset(center.dx - size/4, center.dy + size/2),
      paint..strokeWidth = 3.0 * scale,
    );
    
    // Negative terminal (shorter line)
    canvas.drawLine(
      Offset(center.dx + size/4, center.dy - size/3),
      Offset(center.dx + size/4, center.dy + size/3),
      paint..strokeWidth = 2.0 * scale,
    );
  }

  void _drawResistorSymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.4;
    
    final path = Path();
    path.moveTo(center.dx - size/2, center.dy);
    
    // Zigzag pattern
    for (int i = 0; i < 4; i++) {
      final x = center.dx - size/2 + (i + 0.5) * size/4;
      final y = center.dy + (i % 2 == 0 ? -size/4 : size/4);
      path.lineTo(x, y);
      path.lineTo(center.dx - size/2 + (i + 1) * size/4, center.dy);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawLEDSymbol(Canvas canvas, Rect rect, Paint paint, bool isActive) {
    final center = rect.center;
    final size = rect.width * 0.3;
    
    // Triangle (diode)
    final path = Path();
    path.moveTo(center.dx - size/3, center.dy - size/3);
    path.lineTo(center.dx + size/3, center.dy);
    path.lineTo(center.dx - size/3, center.dy + size/3);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Cathode line
    canvas.drawLine(
      Offset(center.dx + size/3, center.dy - size/3),
      Offset(center.dx + size/3, center.dy + size/3),
      paint,
    );
    
    // Light rays if active
    if (isActive) {
      final glowPaint = Paint()
        ..color = circuitColors.energyPulse.withValues(alpha: 0.6) // Use energyPulse for LED glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale;
      
      for (int i = 0; i < 3; i++) {
        final angle = (i - 1) * 0.3;
        final startX = center.dx + size/2;
        final startY = center.dy + angle * size/2;
        final endX = startX + size/3;
        final endY = startY + angle * size/3;
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), glowPaint);
      }
    }
  }

  void _drawSwitchSymbol(Canvas canvas, Rect rect, Paint paint, bool isClosed) {
    final center = rect.center;
    final size = rect.width * 0.4;
    
    // Contacts
    final contactPaint = Paint()
      ..color = circuitColors.onSurface
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - size/2, center.dy),
      2.5 * scale,
      contactPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size/2, center.dy),
      2.5 * scale,
      contactPaint,
    );
    
    // Switch lever
    final leverEnd = isClosed
        ? Offset(center.dx + size/2, center.dy)
        : Offset(center.dx + size/3, center.dy - size/3);
    
    canvas.drawLine(
      Offset(center.dx - size/2, center.dy),
      leverEnd,
      paint..strokeWidth = 3.0 * scale,
    );
  }

  void _drawCapacitorSymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.3;
    
    // Parallel plates
    canvas.drawLine(
      Offset(center.dx - size/6, center.dy - size/2),
      Offset(center.dx - size/6, center.dy + size/2),
      paint..strokeWidth = 3.0 * scale,
    );
    canvas.drawLine(
      Offset(center.dx + size/6, center.dy - size/2),
      Offset(center.dx + size/6, center.dy + size/2),
      paint,
    );
  }

  void _drawWireSymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.4;

    // Simple wire connection points
    canvas.drawCircle(
      Offset(center.dx - size/2, center.dy),
      3.0 * scale,
      paint..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(center.dx + size/2, center.dy),
      3.0 * scale,
      paint..style = PaintingStyle.fill,
    );

    // Wire line
    canvas.drawLine(
      Offset(center.dx - size/2, center.dy),
      Offset(center.dx + size/2, center.dy),
      paint..strokeWidth = 2.0 * scale,
    );
  }

  void _drawBuzzerSymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.3;

    // Buzzer coil (spiral)
    final path = Path();
    path.moveTo(center.dx - size/2, center.dy);
    for (int i = 0; i < 3; i++) {
      final radius = (size/6) * (i + 1);
      path.arcToPoint(
        Offset(center.dx - size/2 + radius * 2, center.dy),
        radius: Radius.circular(radius),
        clockwise: i % 2 == 0,
      );
    }

    canvas.drawPath(path, paint);

    // Sound waves
    for (int i = 0; i < 2; i++) {
      final waveX = center.dx + size/2 + (i + 1) * size/4;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(waveX, center.dy),
          width: size/2,
          height: size/3,
        ),
        -1.57, // -π/2
        3.14, // π
        false,
        paint..strokeWidth = 1.5 * scale,
      );
    }
  }

  void _drawGenericSymbol(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final size = rect.width * 0.3;

    // Simple square for unknown components
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size,
        height: size,
      ),
      paint..strokeWidth = 2.0 * scale,
    );

    // Question mark inside
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: circuitColors.onSurface,
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ComponentPainter oldDelegate) {
    // Granular repaint detection for performance
    if (oldDelegate.selectedComponentId != selectedComponentId) {
      return true; // Selection change requires repaint
    }

    if (oldDelegate.scale != scale) {
      return true; // Scale change affects all components
    }

    if (oldDelegate.components.length != components.length) {
      return true; // Component count changed
    }

    // Check for component state changes (more efficient than full equality)
    for (int i = 0; i < components.length; i++) {
      final newComp = components[i];
      final oldComp = oldDelegate.components[i];

      if (newComp.id != oldComp.id ||
          newComp.state != oldComp.state ||
          newComp.rotation != oldComp.rotation ||
          newComp.properties != oldComp.properties) {
        return true; // Component changed
      }
    }

    return false; // No changes detected
  }
}
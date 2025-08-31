import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart'; // Import CircuitComponent

class ComponentPainter extends CustomPainter {
  final List<CircuitComponent> components;
  final CircuitColorScheme circuitColors;
  final String? selectedComponentId;
  final double scale;

  ComponentPainter({
    required this.components,
    required this.circuitColors,
    this.selectedComponentId,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final component in components) {
      _drawComponent(canvas, component);
    }
  }

  void _drawComponent(Canvas canvas, CircuitComponent component) {
    final isSelected = component.id == selectedComponentId;
    final componentSize = 40.0 * scale;
    
    final center = Offset(
      component.posX * 60.0 * scale,
      component.posY * 60.0 * scale,
    );
    
    final rect = Rect.fromCenter(
      center: center,
      width: componentSize,
      height: componentSize,
    );

    // Draw component background
    final backgroundPaint = Paint()
      ..color = component.isActive
          ? circuitColors.componentBase.withValues(alpha: 0.8)
          : circuitColors.componentBase.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      backgroundPaint,
    );

    // Draw component border
    final borderPaint = Paint()
      ..color = isSelected ? circuitColors.primary : circuitColors.outline
      ..strokeWidth = isSelected ? 3.0 * scale : 1.5 * scale
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      borderPaint,
    );

    // Draw component-specific details
    _drawComponentDetails(canvas, component, rect);
  }

  void _drawComponentDetails(Canvas canvas, CircuitComponent component, Rect rect) {
    final detailPaint = Paint()
      ..color = circuitColors.onSurface
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (component.type) {
      case 'battery':
        _drawBatterySymbol(canvas, rect, detailPaint);
        break;
      case 'resistor':
        _drawResistorSymbol(canvas, rect, detailPaint);
        break;
      case 'led':
        _drawLEDSymbol(canvas, rect, detailPaint, component.isActive);
        break;
      case 'switch':
        _drawSwitchSymbol(canvas, rect, detailPaint, component.properties['state'] == 'closed');
        break;
      case 'capacitor':
        _drawCapacitorSymbol(canvas, rect, detailPaint);
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
        ..color = circuitColors.wireActive.withValues(alpha: 0.6)
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

  @override
  bool shouldRepaint(ComponentPainter oldDelegate) {
    return oldDelegate.components != components ||
           oldDelegate.selectedComponentId != selectedComponentId ||
           oldDelegate.scale != scale;
  }
}
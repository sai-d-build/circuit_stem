
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../behaviors/drawing_behavior.dart';
import '../behaviors/logic_behavior.dart';
import '../core/component_registry.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';
import '../common/theme.dart';

// --- Battery --- //

class BatteryDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final isDark = assets.isDark;
    final componentColor = isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive;

    paint.color = componentColor;
    fillPaint.color = componentColor;

    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw battery body
    final batteryRect =
        Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)), paint);

    // Draw terminals
    final terminalHeight = size.height * 0.2;
    final terminalWidth = size.width * 0.1;

    // Positive terminal
    canvas.drawRect(
      Rect.fromLTWH(
          batteryRect.right, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          batteryRect.right, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      paint,
    );

    // Negative terminal
    canvas.drawRect(
      Rect.fromLTWH(
          batteryRect.left - terminalWidth, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          batteryRect.left - terminalWidth, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      paint,
    );

    // Add + and - symbols
    final textPainterPlus = TextPainter(
      text: TextSpan(
        text: '+',
        style: TextStyle(
            color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterPlus.layout();
    textPainterPlus.paint(canvas,
        Offset(batteryRect.right + terminalWidth / 2 - textPainterPlus.width / 2, center.dy - textPainterPlus.height / 2));

    final textPainterMinus = TextPainter(
      text: TextSpan(
        text: '−',
        style: TextStyle(
            color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMinus.layout();
    textPainterMinus.paint(canvas,
        Offset(batteryRect.left - terminalWidth / 2 - textPainterMinus.width / 2, center.dy - textPainterMinus.height / 2));

    canvas.restore();
  }
}

class BatteryLogicBehavior implements LogicBehavior {
  @override
  void evaluate(Grid grid, ComponentModel component) {
    // The battery is the source of power, its logic is handled by the main engine.
  }
}

void registerBattery() {
  registerBehavior<BatteryDrawingBehavior>(() => BatteryDrawingBehavior());
  registerBehavior<BatteryLogicBehavior>(() => BatteryLogicBehavior());

  ComponentRegistry.register(
    type: "Component.Battery",
    displayName: "Battery",
    behaviors: [BatteryDrawingBehavior, BatteryLogicBehavior],
    isDraggable: false,
  );
}

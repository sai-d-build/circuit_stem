import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';
import '../application/services/component_registry.dart';
import '../application/services/component_factory.dart';
import '../domain/entities/component.dart';
import '../domain/entities/grid.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';
import '../common/logger.dart';

// --- Battery --- //

class BatteryDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final isDark = assets.isDark;
    final componentColor = isDark
        ? DarkModeColors.componentInactive
        : LightModeColors.componentInactive;

    paint.color = componentColor;
    fillPaint.color = componentColor;

    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw battery body
    final batteryWidth = size.width * 0.8;
    final batteryHeight = size.height * 0.8;
    final batteryRect = Rect.fromCenter(
        center: center, width: batteryWidth, height: batteryHeight);
    canvas.drawRRect(
        RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)),
        fillPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)), paint);

    // Draw terminals
    final terminalHeight = size.height * 0.1; // 10% of total height
    final terminalWidth = size.width * 0.2; // 20% of total width

    // Positive terminal (top)
    canvas.drawRect(
      Rect.fromLTWH(center.dx - terminalWidth / 2, // Center horizontally
          batteryRect.top, // Align with battery body top
          terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - terminalWidth / 2,
          batteryRect.top,
          terminalWidth, terminalHeight),
      paint,
    );

    // Negative terminal (bottom)
    canvas.drawRect(
      Rect.fromLTWH(center.dx - terminalWidth / 2, // Center horizontally
          batteryRect.bottom - terminalHeight, // Align with battery body bottom
          terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - terminalWidth / 2,
          batteryRect.bottom - terminalHeight,
          terminalWidth, terminalHeight),
      paint,
    );

    // Add + and - symbols
    final textPainterPlus = TextPainter(
      text: TextSpan(
        text: '+',
        style: TextStyle(
            color: isDark
                ? DarkModeColors.darkOnPrimary
                : LightModeColors.lightOnPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterPlus.layout();
    textPainterPlus.paint(
        canvas,
        Offset(
            center.dx - textPainterPlus.width / 2,
            batteryRect.top + terminalHeight / 2 - textPainterPlus.height / 2));

    final textPainterMinus = TextPainter(
      text: TextSpan(
        text: '−',
        style: TextStyle(
            color: isDark
                ? DarkModeColors.darkOnPrimary
                : LightModeColors.lightOnPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMinus.layout();
    textPainterMinus.paint(
        canvas,
        Offset(
            center.dx - textPainterMinus.width / 2,
            batteryRect.bottom - terminalHeight / 2 - textPainterMinus.height / 2));

    canvas.restore();
  }
}

class BatteryLogicBehavior extends BaseLogicBehavior {
  @override
  void execute(ComponentModel component) {
    Logger.log('BatteryLogicBehavior: Evaluating battery \${component.id}');
    // The battery is the source of power, its logic is handled by the main engine.
  }

  @override
  String get behaviorType => 'battery';
}

void registerBattery(ComponentFactory factory) {
  Logger.log('registerBattery() called.');
  factory.registerBehavior<BatteryDrawingBehavior>(() => BatteryDrawingBehavior());
  factory.registerBehavior<BatteryLogicBehavior>(() => BatteryLogicBehavior());

  factory.register(
    type: 'Component.Battery',
    displayName: 'Battery',
    behaviors: [BatteryDrawingBehavior, BatteryLogicBehavior],
    isDraggable: false,
  );
  Logger.log('registerBattery() completed.');
}

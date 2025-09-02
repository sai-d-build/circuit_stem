import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';
import '../application/services/component_factory.dart';
import '../domain/entities/component.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';
import '../common/logger.dart';

// --- Timer --- //

class TimerDrawingBehavior implements DrawingBehavior {
  const TimerDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final isDark = assets.isDark;
    final componentColor = component.isPowered
        ? (isDark
            ? DarkModeColors.componentActive
            : LightModeColors.componentActive)
        : (isDark
            ? DarkModeColors.componentInactive
            : LightModeColors.componentInactive);

    paint.color = componentColor;
    fillPaint.color = componentColor.withAlpha(51);

    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw clock face
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, paint);

    // Draw clock hands (simplified)
    paint.strokeWidth = 2.0;
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.6),
        paint); // Minute hand
    canvas.drawLine(center, Offset(center.dx + radius * 0.4, center.dy),
        paint); // Hour hand

    // Draw center dot
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);

    canvas.restore();
  }
}

class TimerLogicBehavior extends BaseLogicBehavior {
  TimerLogicBehavior();

  @override
  void execute(ComponentModel component) {
    Logger.log('TimerLogicBehavior: Evaluating timer \${component.id}');
    // Timer logic is handled by the main engine.
  }

  @override
  String get behaviorType => 'timer';
}

void registerTimer(ComponentFactory factory) {
  Logger.log('registerTimer() called.');
  factory.registerBehavior<TimerDrawingBehavior>(() => const TimerDrawingBehavior());
  factory.registerBehavior<TimerLogicBehavior>(() => TimerLogicBehavior());
  // Note: MoveBehavior is abstract and can't be instantiated directly
  // factory.registerBehavior<MoveBehavior>(() => MoveBehavior());

  factory.register(
    type: 'Component.Timer',
    displayName: 'Timer',
    behaviors: [TimerDrawingBehavior, TimerLogicBehavior],
    isDraggable: true,
  );
  Logger.log('registerTimer() completed.');
}
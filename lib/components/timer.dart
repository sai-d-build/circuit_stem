import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../application/services/component_factory.dart';
import '../common/logger.dart';
import '../common/theme.dart';
import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';
import '../infrastructure/rendering/asset_manager.dart';

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
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(rotationAngle)
      ..translate(-center.dx, -center.dy);

    // Draw clock face
    canvas.drawCircle( // ignore: cascade_invocations
        center, radius, fillPaint);
    canvas.drawCircle( // ignore: cascade_invocations
        center, radius, paint);

    // Draw clock hands (simplified)
    paint.strokeWidth = 2.0;
    canvas.drawLine( // ignore: cascade_invocations
        center, Offset(center.dx, center.dy - radius * 0.6),
        paint); // Minute hand
    canvas.drawLine( // ignore: cascade_invocations
        center, Offset(center.dx + radius * 0.4, center.dy),
        paint); // Hour hand

    // Draw center dot
    canvas.drawCircle( // ignore: cascade_invocations
        center, 2, paint..style = PaintingStyle.fill);

    canvas.restore(); // ignore: cascade_invocations
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
  factory
    ..registerBehavior<TimerDrawingBehavior>(
        () => const TimerDrawingBehavior())
    ..registerBehavior<TimerLogicBehavior>(TimerLogicBehavior.new)
    ..register(
      type: 'Component.Timer',
      displayName: 'Timer',
      behaviors: [TimerDrawingBehavior, TimerLogicBehavior],
      isDraggable: true,
    );
  Logger.log('registerTimer() completed.');
}

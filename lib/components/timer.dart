import 'package:circuit_stem/domain/entities/grid.dart';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:circuit_stem/domain/behaviors/drawing_behavior.dart';
import 'package:circuit_stem/domain/behaviors/logic_behavior.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import 'package:circuit_stem/application/services/component_registry.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';
import '../common/logger.dart';

// --- Timer --- //

class TimerDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final isDark = assets.isDark;
    final componentColor = component.isPowered
        ? (isDark ? DarkModeColors.componentActive : LightModeColors.componentActive)
        : (isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive);

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
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.6), paint); // Minute hand
    canvas.drawLine(center, Offset(center.dx + radius * 0.4, center.dy), paint); // Hour hand

    // Draw center dot
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);

    canvas.restore();
  }
}

class TimerLogicBehavior implements LogicBehavior {
  @override
  void evaluate(Grid grid, ComponentModel component) {
    Logger.log('TimerLogicBehavior: Evaluating timer \${component.id}');
    // Timer logic is handled by the main engine.
  }
}

void registerTimer() {
  Logger.log('registerTimer() called.');
  registerBehavior<TimerDrawingBehavior>(() => TimerDrawingBehavior());
  registerBehavior<TimerLogicBehavior>(() => TimerLogicBehavior());
  registerBehavior<MoveBehavior>(() => MoveBehavior());

  ComponentRegistry.register(
    type: 'Component.Timer',
    displayName: 'Timer',
    behaviors: [
      TimerDrawingBehavior,
      TimerLogicBehavior,
      MoveBehavior
    ],
    isDraggable: true,
  );
  Logger.log('registerTimer() completed.');
}

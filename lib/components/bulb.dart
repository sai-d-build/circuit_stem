import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../application/services/component_factory.dart';
import '../common/logger.dart';
import '../common/theme.dart';
import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';
import '../infrastructure/rendering/asset_manager.dart';

// --- Bulb --- //

class BulbDrawingBehavior implements DrawingBehavior {
  const BulbDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final isDark = assets.isDark;
    final componentColor = component.isPowered
        ? (isDark
            ? DarkModeColors.componentActive
            : LightModeColors.componentActive)
        : (isDark
            ? DarkModeColors.componentInactive
            : LightModeColors.componentInactive);

    // Draw bulb circle
    paint.color = componentColor;
    canvas.drawCircle(center, radius, paint);

    if (component.isPowered) {
      // Fill with light color when powered
      fillPaint.color = componentColor.withAlpha(77);
      canvas.drawCircle(center, radius, fillPaint);

      // Add light rays
      paint.strokeWidth = 1.0;
      for (var i = 0; i < 8; i++) {
        final angle = (i * 45) * (math.pi / 180);
        final start = Offset(
          center.dx + (radius + 2) * math.cos(angle),
          center.dy + (radius + 2) * math.sin(angle),
        );
        final end = Offset(
          center.dx + (radius + 8) * math.cos(angle),
          center.dy + (radius + 8) * math.sin(angle),
        );
        canvas.drawLine(start, end, paint);
      }
    }

    // Draw filament
    paint.strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      paint,
    );
    canvas.drawLine( // ignore: cascade_invocations
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      paint,
    );
  }
}

class BulbLogicBehavior extends BaseLogicBehavior {
  BulbLogicBehavior();

  @override
  void execute(ComponentModel component) {
    Logger.log('BulbLogicBehavior: Evaluating bulb \${component.id}');
    // Bulbs are passive. Their powered state is determined by the main logic engine's evaluation.
    // No specific evaluation logic is needed here.
  }

  @override
  String get behaviorType => 'bulb';
}

void registerBulb(ComponentFactory factory) {
  Logger.log('registerBulb() called.');
  factory
    ..registerBehavior<BulbDrawingBehavior>(() => const BulbDrawingBehavior())
    ..registerBehavior<BulbLogicBehavior>(BulbLogicBehavior.new)
    ..register(
      type: 'Component.Bulb',
      displayName: 'Bulb',
      behaviors: [BulbDrawingBehavior, BulbLogicBehavior],
      isDraggable: true, // Bulbs are draggable in the palette
    );
  Logger.log('registerBulb() completed.');
}

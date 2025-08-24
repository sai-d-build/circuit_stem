import '../domain/entities/grid.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';
import '../application/services/component_registry.dart';
import '../domain/entities/component.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';
import '../infrastructure/audio/audio_service.dart';
import '../common/assets.dart';
import '../common/logger.dart';

// --- Buzzer --- //

class BuzzerDrawingBehavior implements DrawingBehavior {
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
    fillPaint.color = componentColor;

    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw buzzer body
    final buzzerRect =
        Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(buzzerRect, const Radius.circular(4)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(buzzerRect, const Radius.circular(4)), paint);

    // Draw sound waves when powered
    if (component.isPowered) {
      paint.strokeWidth = 1.0;
      for (int i = 1; i < 4; i++) {
        canvas.drawCircle(center, radius + i * 3, paint..style = PaintingStyle.stroke);
      }
    }

    canvas.restore();
  }
}

class BuzzerLogicBehavior implements LogicBehavior {
  final AudioService _audioService = AudioService(); // In a real app, inject this

  @override
  void evaluate(Grid grid, ComponentModel component) {
    Logger.log('BuzzerLogicBehavior: Evaluating buzzer \${component.id}');
    // This is a simplified logic. A more robust implementation would use the main game
    // engine to track state changes and avoid playing the sound on every evaluation.
    if (component.isPowered) {
      _audioService.play(AppAssets.audioSwitch);
    }
  }
}

void registerBuzzer() {
  Logger.log('registerBuzzer() called.');
  registerBehavior<BuzzerDrawingBehavior>(() => BuzzerDrawingBehavior());
  registerBehavior<BuzzerLogicBehavior>(() => BuzzerLogicBehavior());

  ComponentRegistry.register(
    type: 'Component.Buzzer',
    displayName: 'Buzzer',
    behaviors: [BuzzerDrawingBehavior, BuzzerLogicBehavior],
    isDraggable: true,
  );
  Logger.log('registerBuzzer() completed.');
}

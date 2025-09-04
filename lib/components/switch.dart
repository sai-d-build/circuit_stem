import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/interaction_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';

import '../application/services/component_factory.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';


import '../common/logger.dart';

// --- Switch --- //

class SwitchDrawingBehavior implements DrawingBehavior {
  const SwitchDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final isDark = assets.isDark;
    final isSwitchClosed = component.state['closed'] as bool? ?? false;

    final componentColor = component.isPowered
        ? (isDark
            ? DarkModeColors.componentActive
            : LightModeColors.componentActive)
        : (isDark
            ? DarkModeColors.componentInactive
            : LightModeColors.componentInactive);

    paint.color = componentColor;

    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw switch contacts
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 3, paint);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3, paint);

    // Draw switch arm
    final armEnd = isSwitchClosed
        ? Offset(center.dx + radius, center.dy)
        : Offset(center.dx + radius * 0.5, center.dy - radius * 0.8);

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      armEnd,
      paint,
    );

    canvas.restore();
  }
}

class SwitchLogicBehavior extends BaseLogicBehavior {
  SwitchLogicBehavior();

  @override
  void execute(ComponentModel component) {
    Logger.log('SwitchLogicBehavior: Evaluating switch ${component.id}');
    // Logic is handled by the main engine based on the 'closed' state and terminals.
  }

  @override
  String get behaviorType => 'switch';
}

void registerSwitch(ComponentFactory factory) {
  Logger.log('registerSwitch() called.');
  factory.registerBehavior<SwitchDrawingBehavior>(() {
    return const SwitchDrawingBehavior();
  });
  Logger.log('registerBehavior<SwitchDrawingBehavior> called.');
  factory.registerBehavior<ToggleBehavior>(() {
    return ToggleBehavior();
  });
  Logger.log('registerBehavior<ToggleBehavior> called.');
  factory.registerBehavior<SwitchLogicBehavior>(() {
    return SwitchLogicBehavior();
  });
  Logger.log('registerBehavior<SwitchLogicBehavior> called.');

  factory.register(
    type: 'Component.Switch',
    displayName: 'Switch',
    behaviors: [SwitchDrawingBehavior, ToggleBehavior, SwitchLogicBehavior],
    isDraggable: false, // Switches are not draggable
  );
  Logger.log('registerSwitch() completed.');
}

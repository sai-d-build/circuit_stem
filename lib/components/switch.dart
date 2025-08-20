
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../behaviors/drawing_behavior.dart';
import '../behaviors/interaction_behavior.dart';
import '../behaviors/logic_behavior.dart';
import '../core/component_registry.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';
import '../common/theme.dart';
import '../engine/game_engine_notifier.dart';
import '../services/audio_service.dart';
import '../common/assets.dart';
import '../models/grid.dart';
import '../common/logger.dart';

// --- Switch --- //

class SwitchDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final isDark = assets.isDark;
    final isSwitchClosed = component.state['closed'] as bool? ?? false;

    final componentColor = component.isPowered
        ? (isDark ? DarkModeColors.componentActive : LightModeColors.componentActive)
        : (isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive);

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

class SwitchInteractionBehavior implements InteractionBehavior {
  final AudioService _audioService = AudioService(); // In a real app, inject this

  @override
  void onTap(GameEngineNotifier notifier, ComponentModel component) {
    Logger.log('SwitchInteractionBehavior: onTap called for switch \${component.id}');
    final currentState = component.state['closed'] as bool? ?? false;
    final newComponentState = Map<String, dynamic>.from(component.state);
    newComponentState['closed'] = !currentState;

    final updatedComponent = component.copyWith(state: newComponentState);
    
    notifier.updateComponent(updatedComponent);
    _audioService.play(AppAssets.audioToggle);
  }

  @override
  void onDragStart(GameEngineNotifier notifier, ComponentModel component) {}

  @override
  void onDragUpdate(GameEngineNotifier notifier, ComponentModel component) {}

  @override
  void onDragEnd(GameEngineNotifier notifier, ComponentModel component) {}
}

class SwitchLogicBehavior implements LogicBehavior {
  @override
  void evaluate(Grid grid, ComponentModel component) {
    Logger.log('SwitchLogicBehavior: Evaluating switch \${component.id}');
    // Logic is handled by the main engine based on the 'closed' state and terminals.
  }
}

void registerSwitch() {
  Logger.log('registerSwitch() called.');
  registerBehavior<SwitchDrawingBehavior>(() => SwitchDrawingBehavior());
  registerBehavior<SwitchInteractionBehavior>(() => SwitchInteractionBehavior());
  registerBehavior<SwitchLogicBehavior>(() => SwitchLogicBehavior());

  ComponentRegistry.register(
    type: 'Component.Switch',
    displayName: 'Switch',
    behaviors: [SwitchDrawingBehavior, SwitchInteractionBehavior, SwitchLogicBehavior],
    isDraggable: false, // Switches are not draggable
  );
  Logger.log('registerSwitch() completed.');
}

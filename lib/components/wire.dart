import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../domain/behaviors/drawing_behavior.dart';
import '../domain/behaviors/logic_behavior.dart';


import '../application/services/component_factory.dart';
import '../domain/entities/component.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../common/theme.dart';

import '../common/logger.dart';

// --- Straight Wire --- //

class WireStraightDrawingBehavior implements DrawingBehavior {
  const WireStraightDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark
            ? DarkModeColors.wireUnpowered
            : LightModeColors.wireUnpowered);

    paint.color = wireColor;

    // Apply rotation
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    canvas.restore();
  }
}

class WireLogicBehavior extends BaseLogicBehavior {
  WireLogicBehavior();

  @override
  void execute(ComponentModel component) {
    Logger.log('WireLogicBehavior: Evaluating wire \${component.id}');
    // Wires are passive conductors. No specific logic needed.
  }

  @override
  String get behaviorType => 'wire';
}

void registerWireStraight(ComponentFactory factory) {
  Logger.log('registerWireStraight() called.');
  factory.registerBehavior<WireStraightDrawingBehavior>(
      () => const WireStraightDrawingBehavior());
  factory.registerBehavior<WireLogicBehavior>(
      () => WireLogicBehavior()); // Can be shared
  // Note: MoveBehavior is abstract and can't be instantiated directly
  // factory.registerBehavior<MoveBehavior>(() => MoveBehavior());

  factory.register(
    type: 'Component.WireStraight',
    displayName: 'Wire',
    behaviors: [WireStraightDrawingBehavior, WireLogicBehavior],
    isDraggable: true,
  );
  Logger.log('registerWireStraight() completed.');
}

// --- Corner Wire --- //

class WireCornerDrawingBehavior implements DrawingBehavior {
  const WireCornerDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark
            ? DarkModeColors.wireUnpowered
            : LightModeColors.wireUnpowered);

    paint.color = wireColor;

    // Apply rotation
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw L-shaped corner
    canvas.drawLine(center, Offset(size.width, center.dy), paint);
    canvas.drawLine(center, Offset(center.dx, size.height), paint);

    canvas.restore();
  }
}

void registerWireCorner(ComponentFactory factory) {
  Logger.log('registerWireCorner() called.');
  factory.registerBehavior<WireCornerDrawingBehavior>(
      () => const WireCornerDrawingBehavior());
  // Note: MoveBehavior is abstract and can't be instantiated directly
  // factory.registerBehavior<MoveBehavior>(() => MoveBehavior());

  factory.register(
    type: 'Component.WireCorner',
    displayName: 'Corner Wire',
    behaviors: [
      WireCornerDrawingBehavior,
      WireLogicBehavior,
    ], // Re-use same logic behavior
    isDraggable: true,
  );
  Logger.log('registerWireCorner() completed.');
}

// --- T-Junction Wire --- //

class WireTDrawingBehavior implements DrawingBehavior {
  const WireTDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark
            ? DarkModeColors.wireUnpowered
            : LightModeColors.wireUnpowered);

    paint.color = wireColor;

    // Apply rotation
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dx);

    // Draw T-junction
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(center, Offset(size.width, center.dy), paint);

    canvas.restore();
  }
}

void registerWireT(ComponentFactory factory) {
  Logger.log('registerWireT() called.');
  factory.registerBehavior<WireTDrawingBehavior>(() => const WireTDrawingBehavior());
  // Note: MoveBehavior is abstract and can't be instantiated directly
  // factory.registerBehavior<MoveBehavior>(() => MoveBehavior());

  factory.register(
    type: 'Component.WireT',
    displayName: 'T-Wire',
    behaviors: [
      WireTDrawingBehavior,
      WireLogicBehavior,
    ], // Re-use same logic behavior
    isDraggable: true,
  );
  Logger.log('registerWireT() completed.');
}

// --- Cross Wire --- //

class CrossWireDrawingBehavior implements DrawingBehavior {
  const CrossWireDrawingBehavior();
  @override
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark
            ? DarkModeColors.wireUnpowered
            : LightModeColors.wireUnpowered);

    paint.color = wireColor;

    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Vertical line with a gap
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height / 2 - 5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 + 5),
      Offset(size.width / 2, size.height),
      paint,
    );
  }
}

void registerCrossWire(ComponentFactory factory) {
  Logger.log('registerCrossWire() called.');
  factory.registerBehavior<CrossWireDrawingBehavior>(
      () => const CrossWireDrawingBehavior());
  // Note: MoveBehavior is abstract and can't be instantiated directly
  // factory.registerBehavior<MoveBehavior>(() => MoveBehavior());

  factory.register(
    type: 'Component.CrossWire',
    displayName: 'Cross Wire',
    behaviors: [
      CrossWireDrawingBehavior,
      WireLogicBehavior,
    ], // Re-use same logic behavior
    isDraggable: true,
  );
  Logger.log('registerCrossWire() completed.');
}

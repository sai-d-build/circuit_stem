
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../behaviors/drawing_behavior.dart';
import '../behaviors/logic_behavior.dart';
import '../core/component_registry.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';
import '../common/theme.dart';

// --- Straight Wire --- //

class WireStraightDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);

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

class WireLogicBehavior implements LogicBehavior {
  @override
  void evaluate(Grid grid, ComponentModel component) {
    // Wires are passive conductors. No specific logic needed.
  }
}

void registerWireStraight() {
  registerBehavior<WireStraightDrawingBehavior>(() => WireStraightDrawingBehavior());
  registerBehavior<WireLogicBehavior>(() => WireLogicBehavior()); // Can be shared

  ComponentRegistry.register(
    type: "Component.WireStraight",
    behaviors: [WireStraightDrawingBehavior, WireLogicBehavior],
    isDraggable: true,
  );
}


// --- Corner Wire --- //

class WireCornerDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);

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

void registerWireCorner() {
  registerBehavior<WireCornerDrawingBehavior>(() => WireCornerDrawingBehavior());

  ComponentRegistry.register(
    type: "Component.WireCorner",
    behaviors: [WireCornerDrawingBehavior, WireLogicBehavior], // Re-use same logic behavior
    isDraggable: true,
  );
}


// --- T-Junction Wire --- //

class WireTDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);

    paint.color = wireColor;

    // Apply rotation
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw T-junction
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(center, Offset(size.width, center.dy), paint);

    canvas.restore();
  }
}

void registerWireT() {
  registerBehavior<WireTDrawingBehavior>(() => WireTDrawingBehavior());

  ComponentRegistry.register(
    type: "Component.WireT",
    behaviors: [WireTDrawingBehavior, WireLogicBehavior], // Re-use same logic behavior
    isDraggable: true,
  );
}


// --- Cross Wire --- //

class CrossWireDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final isDark = assets.isDark;
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);

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

void registerCrossWire() {
  registerBehavior<CrossWireDrawingBehavior>(() => CrossWireDrawingBehavior());

  ComponentRegistry.register(
    type: "Component.CrossWire",
    displayName: "Wire",
    behaviors: [CrossWireDrawingBehavior, WireLogicBehavior], // Re-use same logic behavior
    isDraggable: true,
  );
}

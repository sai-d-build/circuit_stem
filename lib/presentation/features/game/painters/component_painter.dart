import 'package:flutter/material.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/domain/behaviors/drawing_behavior.dart';

class ComponentPainter extends CustomPainter {
  final ComponentModel component;
  final AssetManagerNotifier assetManager;
  final bool isDark;

  ComponentPainter({
    required this.component,
    required this.assetManager,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawingBehavior = component.getBehavior<DrawingBehavior>();
    if (drawingBehavior != null) {
      drawingBehavior.draw(canvas, size, component, assetManager);
    }
  }

  @override
  bool shouldRepaint(covariant ComponentPainter oldDelegate) {
    return oldDelegate.component != component || oldDelegate.isDark != isDark;
  }
}

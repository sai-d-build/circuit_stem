import 'package:flutter/material.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';

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
    final drawingBehavior = getDrawingBehavior(component.type);
    if (drawingBehavior != null) {
      drawingBehavior.draw(canvas, size, component, assetManager);
    }
  }

  @override
  bool shouldRepaint(covariant ComponentPainter oldDelegate) {
    return oldDelegate.component != component || oldDelegate.isDark != isDark;
  }
}

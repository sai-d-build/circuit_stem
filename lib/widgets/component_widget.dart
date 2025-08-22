import 'package:flutter/material.dart';
import '../models/component.dart';
import '../behaviors/drag_behavior.dart';
import 'component_painter.dart';
import '../services/asset_manager.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentModel component;
  final DragBehavior dragBehavior;
  final AssetManagerNotifier assetManager;
  final VoidCallback onTap;

  const ComponentWidget({
    super.key,
    required this.component,
    required this.dragBehavior,
    required this.assetManager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final componentSize = Size(component.shape.first.c * 100.0, component.shape.first.r * 100.0);

    final child = GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: ComponentPainter(
          component: component,
          assetManager: assetManager,
          isDark: isDark,
        ),
        size: componentSize,
      ),
    );

    if (!component.isDraggable) {
      return child;
    }

    return Draggable<ComponentModel>(
      data: component,
      feedback: SizedBox(
        width: componentSize.width,
        height: componentSize.height,
        child: Material(
          elevation: 4.0,
          child: CustomPaint(
            painter: ComponentPainter(
              component: component,
              assetManager: assetManager,
              isDark: isDark,
            ),
            size: componentSize,
          ),
        ),
      ),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        dragBehavior.onDragEnd(details, component.id);
      },
      child: child,
    );
  }
}

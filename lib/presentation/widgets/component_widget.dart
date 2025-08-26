import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/providers.dart';
import '../../application/use_cases/component_action.dart';
import '../../domain/entities/component.dart';
import 'component_painter.dart';
import '../../infrastructure/rendering/asset_manager.dart';

class ComponentWidget extends ConsumerWidget {
  final ComponentModel component;
  final AssetManagerNotifier assetManager;
  final VoidCallback onTap;

  const ComponentWidget({
    super.key,
    required this.component,
    required this.assetManager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedComponentId = ref.watch(gameEngineProvider.select((state) => state.selectedComponentId));
    final isSelected = component.id == selectedComponentId;

    final componentSize = component.displaySize;

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

    final stack = Stack(
      children: [
        child,
        if (isSelected)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () {
                final newRotation = (component.rotation + 1) % 4;
                ref.read(gameEngineProvider.notifier).rotateComponent(component.id, newRotation);
              },
            ),
          ),
      ],
    );

    if (!component.isDraggable) {
      return stack;
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
      child: stack,
    );
  }
}

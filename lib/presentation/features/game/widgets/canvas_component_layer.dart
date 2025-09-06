import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';

/// CanvasComponentLayer handles the rendering and interaction of circuit components.
/// This layer extracts component rendering logic from GameCanvas.
class CanvasComponentLayer extends ConsumerWidget {
  final String levelId;

  const CanvasComponentLayer({
    super.key,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);

    return Stack(
      children: gameState.grid.components.values.map((component) {
        return CircuitComponentWidget(component: component);
      }).toList(),
    );
  }
}

/// Component rendering utilities
class ComponentRenderingUtils {
  /// Get the screen position for a component
  static Offset getComponentScreenPosition(ComponentModel component, GridConfiguration gridConfig) {
    return GridService.gridToScreen(
      Offset(component.col.toDouble() + 0.5, component.row.toDouble() + 0.5),
      gridConfig,
    );
  }

  /// Get the bounds of a component in screen coordinates
  static Rect getComponentBounds(ComponentModel component, GridConfiguration gridConfig, Size componentSize) {
    final screenPos = getComponentScreenPosition(component, gridConfig);
    final scaledSize = Size(
      componentSize.width * gridConfig.scale,
      componentSize.height * gridConfig.scale,
    );

    return Rect.fromCenter(
      center: screenPos,
      width: scaledSize.width,
      height: scaledSize.height,
    );
  }

  /// Check if a component is currently selected
  static bool isComponentSelected(ComponentModel component, String? selectedComponentId) {
    return component.id == selectedComponentId;
  }

  /// Get the appropriate color for a component based on its state
  static Color getComponentColor(
    ComponentModel component,
    CircuitColorScheme circuitColors,
    bool isSelected,
    bool isHovered,
  ) {
    if (isSelected) {
      return circuitColors.primary;
    } else if (isHovered) {
      return circuitColors.secondary;
    } else {
      return circuitColors.componentBase;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

/// CanvasInteractionLayer handles mouse interactions, hover states, and selection feedback.
/// This layer extracts interaction logic from GameCanvas.
class CanvasInteractionLayer extends ConsumerStatefulWidget {
  final Widget child;

  const CanvasInteractionLayer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<CanvasInteractionLayer> createState() => _CanvasInteractionLayerState();
}

class _CanvasInteractionLayerState extends ConsumerState<CanvasInteractionLayer> {
  Offset? _mousePosition;
  String? _hoveredComponentId;

  @override
  Widget build(BuildContext context) {
    MigrationTracker.markFileMigrated('canvas_interaction_layer.dart', DateTime.now().toIso8601String());
    final gameState = ref.watch(unifiedGameStateProvider);

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });

        // Check if hovering over a component
        final gridConfig = GridConfiguration(
          rows: gameState.grid.rows,
          cols: gameState.grid.cols,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );

        final unifiedService = UnifiedCoordinateService();
        final gridPos = unifiedService.screenToGrid(event.localPosition, gridConfig);
        final component = _getComponentAtPosition(gridPos, gameState);

        if (component != null && component.id != _hoveredComponentId) {
          setState(() {
            _hoveredComponentId = component.id;
          });
          StructuredLogger.debug('Component hover started', context: {
            'componentId': component.id,
            'componentType': component.type.toString(),
            'gridPosition': '${component.row}, ${component.col}',
          });
        } else if (component == null && _hoveredComponentId != null) {
          setState(() {
            _hoveredComponentId = null;
          });
          StructuredLogger.debug('Component hover ended');
        }

        debugPrint('🖱️ MOUSE POSITION: ${event.localPosition} -> Grid: (${(event.localPosition.dx / 60).floor()}, ${(event.localPosition.dy / 60).floor()})');
      },
      onExit: (event) {
        setState(() {
          _mousePosition = null;
          _hoveredComponentId = null;
        });
        StructuredLogger.debug('Mouse exited canvas area');
      },
      child: Stack(
        children: [
          widget.child,
          // Hover indicator
          if (_mousePosition != null)
            Positioned(
              left: _mousePosition!.dx - 15,
              top: _mousePosition!.dy - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.3),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
            ),
          // Component hover highlight
          if (_hoveredComponentId != null)
            Positioned.fill(
              child: CustomPaint(
                painter: ComponentHoverPainter(
                  hoveredComponentId: _hoveredComponentId!,
                  gameState: gameState,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ComponentModel? _getComponentAtPosition(Offset gridPosition, GameState gameState) {
    // Find component at this exact grid position
    for (final component in gameState.grid.components.values) {
      if (component.col == gridPosition.dx.toInt() && component.row == gridPosition.dy.toInt()) {
        return component;
      }
    }
    return null;
  }
}

/// ComponentHoverPainter provides visual feedback for hovered components
class ComponentHoverPainter extends CustomPainter {
  final String hoveredComponentId;
  final GameState gameState;

  ComponentHoverPainter({
    required this.hoveredComponentId,
    required this.gameState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final component = gameState.grid.components[hoveredComponentId];
    if (component == null) return;

    final gridConfig = GridConfiguration(
      rows: gameState.grid.rows,
      cols: gameState.grid.cols,
      cellSize: 60.0,
      scale: 1.0,
      panOffset: Offset.zero,
    );

    final unifiedService = UnifiedCoordinateService();
    final screenPos = unifiedService.gridToScreen(
      Offset(component.col.toDouble() + 0.5, component.row.toDouble() + 0.5),
      gridConfig,
    );

    // Draw hover highlight
    final hoverPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final hoverRect = Rect.fromCenter(
      center: screenPos,
      width: gridConfig.cellSize,
      height: gridConfig.cellSize,
    );

    canvas.drawRect(hoverRect, hoverPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(hoverRect, borderPaint);
  }

  @override
  bool shouldRepaint(ComponentHoverPainter oldDelegate) {
    return oldDelegate.hoveredComponentId != hoveredComponentId ||
           oldDelegate.gameState != gameState;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart' as canvas_state;
import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart' as orchestrator;
import 'package:sparkcircuit/presentation/core/utils/feedback_utils.dart';

/// CanvasDragDropLayer handles all drag and drop operations for the game canvas.
/// This layer extracts the complex drag/drop logic from GameCanvas into a dedicated component.
class CanvasDragDropLayer extends ConsumerStatefulWidget {
  final Widget child;
  final String levelId;

  const CanvasDragDropLayer({
    super.key,
    required this.child,
    required this.levelId,
  });

  @override
  ConsumerState<CanvasDragDropLayer> createState() => _CanvasDragDropLayerState();
}

class _CanvasDragDropLayerState extends ConsumerState<CanvasDragDropLayer> {
  @override
  Widget build(BuildContext context) {
    print('🚧 CanvasDragDropLayer: Building for level ${widget.levelId}');

    // Debug drag target bounds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          print('🚧 CanvasDragDropLayer: Bounds = ${renderBox.paintBounds}, Size = ${renderBox.size}');
        }
      } catch (e) {
        print('🚧 CanvasDragDropLayer: Render box not ready yet');
      }
    });

    StructuredLogger.trace('CanvasDragDropLayer: Building drag drop layer', context: {
      'levelId': widget.levelId,
      'hasContext': context != null,
    });

    final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
    final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);
    final paletteState = ref.watch(paletteStateProvider(widget.levelId));

    StructuredLogger.trace('CanvasDragDropLayer: State watchers resolved', context: {
      'canvasState_type': canvasState.runtimeType.toString(),
      'gameState_type': gameState.runtimeType.toString(),
      'paletteState_type': paletteState.runtimeType.toString(),
      'gameState_grid_rows': gameState.grid.rows,
      'gameState_grid_cols': gameState.grid.cols,
      'componentCount': gameState.grid.components.length,
      'viewportCellSize': canvasState.viewportState.gridConfiguration.cellSize,
      'viewportScale': canvasState.viewportState.scale,
      'viewportPanOffset': canvasState.viewportState.panOffset.toString(),
    });

    StructuredLogger.trace('CanvasDragDropLayer: Creating DragTarget', context: {
      'dragTargetReady': true,
    });

    return DragTarget<ComponentDragData>(
      onAcceptWithDetails: (details) async {
        debugPrint('🚧 CanvasDragDropLayer: 🔥 DROP ACCEPTED! ${details.offset}');
        StructuredLogger.info('CanvasDragDropLayer: Drop accepted with details', context: {
          'details_offset': details.offset.toString(),
          'data_componentName': details.data.componentName,
          'data_componentType': details.data.componentType.toString(),
          'data_cost': details.data.cost,
        });
        await _handleComponentDrop(details, gameState, paletteState);
      },
      onWillAcceptWithDetails: (details) {
        // Debug coordinate transformation
        final renderBox = context.findRenderObject() as RenderBox?;
        final localCoords = renderBox?.globalToLocal(details.offset);
        debugPrint('🚧 CanvasDragDropLayer: ❓ onWillAccept called');
        debugPrint('🚧   GLOBAL: ${details.offset}');
        debugPrint('🚧   LOCAL: ${localCoords}');
        debugPrint('🚧   GRID: Size(1678.0, 598.0)');

        StructuredLogger.debug('CanvasDragDropLayer: Will accept called', context: {
          'details_offset': details.offset.toString(),
          'local_coords': localCoords.toString(),
          'data_componentName': details.data.componentName,
          'data_componentType': details.data.componentType.toString(),
        });
        return _canAcceptComponentDrop(details, gameState, paletteState);
      },
      onMove: (details) {
        debugPrint('🚧 CanvasDragDropLayer: ➡️ onMove called: ${details.offset}');
        StructuredLogger.trace('CanvasDragDropLayer: Drag move detected', context: {
          'globalPosition': details.offset.toString(),
          'componentName': details.data.componentName,
          'componentType': details.data.componentType.toString(),
        });
      },
      onLeave: (details) {
        debugPrint('🚧 CanvasDragDropLayer: 👋 onLeave called');
        StructuredLogger.debug('CanvasDragDropLayer: Drag leave detected');
      },
      builder: (context, candidateData, rejectedData) {
        // Debug coordinate space for builder
        if (candidateData.isNotEmpty) {
          final renderBox = context.findRenderObject() as RenderBox?;
          debugPrint('🚧 CanvasDragDropLayer: 🔄 builder called');
          debugPrint('🚧   Candidates: ${candidateData.length}');
          debugPrint('🚧   RenderBox available: ${renderBox != null}');
          if (renderBox != null) {
            debugPrint('🚧   Bounds: ${renderBox.paintBounds}');
          }
        }

        StructuredLogger.trace('CanvasDragDropLayer: DragTarget builder called', context: {
          'candidateData_count': candidateData.length,
          'rejectedData_count': rejectedData.length,
          'hasCandidateData': candidateData.isNotEmpty,
          'candidateData_componentNames': candidateData.where((d) => d != null).map((d) => d!.componentName).toList(),
        });
        return widget.child;
      },
    );
  }

  Future<void> _handleComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    GameState gameState,
    PaletteState paletteState,
  ) async {
    StructuredLogger.info('CanvasDragDropLayer: Starting component drop handling', context: {
      'gameState_type': gameState.runtimeType.toString(),
      'paletteState_type': paletteState.runtimeType.toString(),
      'context_mounted': context.mounted,
      'hasRenderObject': context.findRenderObject() != null,
    });

    final canvasState = ref.read(gameCanvasOrchestratorProvider(widget.levelId));
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.offset);

    StructuredLogger.debug('CanvasDragDropLayer: Coordinate transformation', context: {
      'globalOffset': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'renderBox_size': renderBox.size.toString(),
      'renderBox_paintBounds': renderBox.paintBounds.toString(),
    });

    StructuredLogger.info('Component drop initiated', context: {
      'globalPosition': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'cost': details.data.cost,
    });

    // Get valid grid position using orchestrator's viewport state
    final validGridPosition = _getValidGridPosition(localPosition, canvasState);
    if (validGridPosition == null) {
      StructuredLogger.warning('Component drop rejected - invalid grid position', context: {
        'dropPosition': localPosition.toString(),
        'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot place component outside grid'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Convert component type string to enum
    final componentType = ComponentType.values.firstWhere(
      (e) => e.toString().split('.').last == details.data.componentType.toString().split('.').last,
      orElse: () => ComponentType.wire,
    );

    StructuredLogger.debug('Component placement details', context: {
      'componentType': componentType.toString(),
      'gridPosition': '${validGridPosition.dx.round()}, ${validGridPosition.dy.round()}',
      'levelId': widget.levelId,
    });

    try {
      StructuredLogger.debug('CanvasDragDropLayer: Attempting component placement', context: {
        'componentType': componentType.toString(),
        'gridPosition_row': validGridPosition.dy.round(),
        'gridPosition_col': validGridPosition.dx.round(),
        'gameStateNotifier_available': ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier) != null,
      });

      // Place component directly in game state (simplified approach)
      ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier).placeComponent(
        componentType,
        validGridPosition.dy.round(),
        validGridPosition.dx.round(),
      );

      StructuredLogger.info('CanvasDragDropLayer: Component placement successful', context: {
        'componentType': componentType.toString(),
        'gridPosition': '${validGridPosition.dx.round()}, ${validGridPosition.dy.round()}',
        'placedSuccessfully': true,
      });

      // Update palette state
      ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();

      // Provide haptic feedback
      FeedbackUtils.provideHapticFeedback(FeedbackType.success);

    } catch (e) {
      StructuredLogger.error('Component placement error', context: {
        'componentType': componentType.toString(),
        'gridPosition': '${validGridPosition.dx.round()}, ${validGridPosition.dy.round()}',
        'error': e.toString(),
      }, error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing component: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _canAcceptComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    GameState gameState,
    PaletteState paletteState,
  ) {
    debugPrint('🚧 CanvasDragDropLayer: 🔍 DROP VALIDATION START');
    debugPrint('🚧   Global offset: ${details.offset}');
    debugPrint('🚧   Grid dimensions: ${gameState.grid.rows}x${gameState.grid.cols}');

    StructuredLogger.debug('CanvasDragDropLayer: Starting drop validation', context: {
      'gameState_grid_rows': gameState.grid.rows,
      'gameState_grid_cols': gameState.grid.cols,
      'gameState_components_count': gameState.grid.components.length,
      'paletteState_type': paletteState.runtimeType.toString(),
      'hasContext': context.findRenderObject() != null,
    });

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.offset);

    debugPrint('🚧 CanvasDragDropLayer: 💫 Coordinate translation');
    debugPrint('🚧   Global position: ${details.offset}');
    debugPrint('🚧   Local position: ${localPosition}');
    debugPrint('🚧   Canvas bounds: ${renderBox.paintBounds}');

    StructuredLogger.trace('CanvasDragDropLayer: Validation position calculation', context: {
      'globalOffset': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'renderBox_size': renderBox.size.toString(),
    });

    StructuredLogger.debug('Component drop validation', context: {
      'globalPosition': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
    });

    // Create grid configuration
    final canvasState = ref.read(gameCanvasOrchestratorProvider(widget.levelId));
    final viewportConfig = canvasState.viewportState.gridConfiguration;
    final gridConfig = GridConfiguration(
      rows: gameState.grid.rows,
      cols: gameState.grid.cols,
      cellSize: viewportConfig.cellSize,
      scale: canvasState.viewportState.scale,
      panOffset: canvasState.viewportState.panOffset,
    );

    StructuredLogger.trace('CanvasDragDropLayer: Grid configuration created', context: {
      'gridConfig_rows': gridConfig.rows,
      'gridConfig_cols': gridConfig.cols,
      'gridConfig_cellSize': gridConfig.cellSize,
      'gridConfig_scale': gridConfig.scale,
      'gridConfig_panOffset': gridConfig.panOffset.toString(),
    });

    // Get valid grid position
    final validGridPosition = GridService.getValidGridPosition(localPosition, gridConfig);

    StructuredLogger.debug('CanvasDragDropLayer: Valid grid position check', context: {
      'inputLocalPosition': localPosition.toString(),
      'validGridPosition': validGridPosition?.toString() ?? 'null',
      'gridService_available': GridService != null,
    });

    if (validGridPosition == null) {
      StructuredLogger.debug('Drop validation failed - invalid grid position', context: {
        'dropPosition': localPosition.toString(),
        'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
      });
      return false;
    }

    // Check if position is occupied
    final existingComponent = gameState.grid.components.values
        .where((component) => component.row == validGridPosition.dy.toInt() &&
                              component.col == validGridPosition.dx.toInt())
        .isNotEmpty;

    StructuredLogger.trace('CanvasDragDropLayer: Position occupancy check', context: {
      'checkingPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
      'existingComponent_found': existingComponent,
      'totalComponents': gameState.grid.components.length,
      'componentsAtCheckedPosition': gameState.grid.components.values
        .where((component) => component.row == validGridPosition.dy.toInt() &&
                              component.col == validGridPosition.dx.toInt())
        .map((c) => '${c.runtimeType} at (${c.row},${c.col})')
        .toList(),
    });

    if (existingComponent) {
      StructuredLogger.debug('CanvasDragDropLayer: Drop validation failed - position occupied', context: {
        'gridPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
        'reason': 'position_occupied',
      });
      return false;
    }

    // Check if component is available in inventory
    final componentTypeString = details.data.componentType.toString().split('.').last;
    final canUse = paletteState.canUseComponent(componentTypeString);

    StructuredLogger.debug('CanvasDragDropLayer: Inventory validation check', context: {
      'componentTypeString': componentTypeString,
      'paletteState_canUseComponent_result': canUse,
      'paletteState_inventory': paletteState.inventory,
      'paletteState_inventoryKeys': paletteState.inventory?.keys.toList() ?? [],
      'componentInInventory': paletteState.inventory?.containsKey(componentTypeString) ?? false,
    });

    if (!canUse) {
      StructuredLogger.debug('CanvasDragDropLayer: Drop validation failed - insufficient inventory', context: {
        'componentTypeString': componentTypeString,
        'availableInventory': paletteState.inventory,
        'paletteState_canUseComponent': canUse,
        'reason': 'insufficient_inventory',
      });
      return false;
    }

    StructuredLogger.info('CanvasDragDropLayer: Drop validation PASSED', context: {
      'componentName': details.data.componentName,
      'gridPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
      'validationResults': {
        'grid_position_valid': validGridPosition != null,
        'position_available': !existingComponent,
        'inventory_available': canUse,
      },
    });

    return true;
  }

  /// Get valid grid position using orchestrator's viewport state
  Offset? _getValidGridPosition(Offset localPosition, canvas_state.GameCanvasState canvasState) {
    StructuredLogger.trace('CanvasDragDropLayer: Starting valid grid position calculation', context: {
      'inputLocalPosition': localPosition.toString(),
      'canvasState_available': canvasState != null,
    });

    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);

    // Create GridService-compatible configuration from canvas viewport state
    final viewportConfig = canvasState.viewportState.gridConfiguration;
    final gridConfig = GridConfiguration(
      rows: gameState.grid.rows,
      cols: gameState.grid.cols,
      cellSize: viewportConfig.cellSize,
      scale: canvasState.viewportState.scale,
      panOffset: canvasState.viewportState.panOffset,
    );

    StructuredLogger.debug('CanvasDragDropLayer: Using grid configuration for position calculation', context: {
      'gridConfig_fromCanvasState': {
        'rows': gridConfig.rows,
        'cols': gridConfig.cols,
        'cellSize': gridConfig.cellSize,
        'scale': gridConfig.scale,
        'panOffset_dx': gridConfig.panOffset.dx,
        'panOffset_dy': gridConfig.panOffset.dy,
      },
      'viewportConfig_cellSize': viewportConfig.cellSize,
      'inputLocalPosition': localPosition.toString(),
    });

    // Convert screen to grid coordinates using the same logic as CircuitGrid
    final gridPosition = GridService.screenToGrid(localPosition, gridConfig);
    final row = gridPosition.dy.round();
    final col = gridPosition.dx.round();

    StructuredLogger.debug('CanvasDragDropLayer: Grid position conversion result', context: {
      'rawGridPosition_dx': gridPosition.dx,
      'rawGridPosition_dy': gridPosition.dy,
      'roundedRow': row,
      'roundedCol': col,
      'gameState_grid_rows': gameState.grid.rows,
      'gameState_grid_cols': gameState.grid.cols,
    });

    // Check bounds
    if (row >= 0 && row < gameState.grid.rows && col >= 0 && col < gameState.grid.cols) {
      StructuredLogger.debug('Valid grid position found', context: {
        'gridPosition': '$col, $row',
      });
      return Offset(col.toDouble(), row.toDouble());
    }

    StructuredLogger.debug('Grid position out of bounds', context: {
      'returnedPosition': null,
      'bounds': '0-${gameState.grid.rows-1}, 0-${gameState.grid.cols-1}',
      'actualPosition': '$row, $col',
    });

    return null;
  }
}
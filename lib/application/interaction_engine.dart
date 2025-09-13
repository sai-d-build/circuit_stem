import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/services/bounds_manager.dart' as bounds_manager;
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/domain/entities/levels/level_definition.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/application/services/interfaces/component_inventory_service.dart';
import 'package:sparkcircuit/application/services/implementations/component_inventory_service_impl.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// ✅ EVOLVED: From passive use case to active state engine
final interactionEngineProvider = StateNotifierProvider.family<InteractionEngine, GameState, String>(
  (ref, levelId) => InteractionEngine(
    levelId,
    inventoryService: ref.watch(
      Provider.family<ComponentInventoryService, String>((ref, lvlId) {
        final paletteStateNotifier = ref.watch(paletteStateProvider(lvlId).notifier);
        return DefaultComponentInventoryService(
          paletteStateNotifier: paletteStateNotifier,
          levelId: lvlId,
        );
      })(levelId),
    ),
  ),
);

class InteractionEngine extends StateNotifier<GameState> {
  final String _levelId;
  final ComponentInventoryService _inventoryService;

  // Dependencies are injected as before
  late final CoordinateSystemService _coordinateService;

  InteractionEngine(this._levelId, {required ComponentInventoryService inventoryService})
      : _inventoryService = inventoryService,
        super(GameState.initial(null)) {
    // Initialize dependencies using ref
    _coordinateService = CoordinateSystemService();

    // Load initial state
    _loadInitialState();
  }

  // Add method to update state when level is loaded
  void updateLevelState(LevelDefinition level) {
    state = GameState.initial(level);
    StructuredLogger.info('InteractionEngine: Level state updated', context: {
      'levelId': level.levelId,
      'gridDimensions': '${level.grid.height}x${level.grid.width}',
    });
  }

  void _loadInitialState() {
    // Load level and set initial GameState
    // This would integrate with your level loading logic
    StructuredLogger.info('InteractionEngine: Initialized for level $_levelId');
  }

  // CENTRALIZED VALIDATION - Enhanced for full-screen mode
  bool _isValidPlacement(GridPosition position) {
    // Check if we're in full-screen mode (allow placement anywhere in visual grid)
    final boundsManager = bounds_manager.UnifiedBoundsManager();
    final boundsConfig = boundsManager.getConfiguration();

    // Use visual bounds (50x50) in full-screen mode, otherwise use level bounds
    final useVisualBounds = boundsConfig.levelSpecificSettings?['disableBoundsChecking'] == true ||
                           boundsConfig.levelSpecificSettings?['allowFullScreen'] == true;

    final maxRows = useVisualBounds ? boundsConfig.visualBounds.height.toInt() : state.grid.rows;
    final maxCols = useVisualBounds ? boundsConfig.visualBounds.width.toInt() : state.grid.cols;

    // Check boundaries
    if (position.row < 0 || position.row >= maxRows ||
        position.col < 0 || position.col >= maxCols) {
      StructuredLogger.warning('PLACEMENT BLOCKED: Coordinate out of bounds', context: {
        'requestedPosition': {'row': position.row, 'col': position.col},
        'boundsMode': useVisualBounds ? 'visual' : 'level',
        'maxDimensions': {'rows': maxRows, 'cols': maxCols},
        'levelGridDimensions': {'rows': state.grid.rows, 'cols': state.grid.cols},
        'visualGridDimensions': {'rows': boundsConfig.visualBounds.height.toInt(), 'cols': boundsConfig.visualBounds.width.toInt()},
        'validRanges': {'rows': '0-${maxRows - 1}', 'cols': '0-${maxCols - 1}'},
        'error': _getBoundsError(position, maxRows, maxCols),
      });
      return false;
    }

    // Check if position is occupied
    final isOccupied = state.grid.components.values.any((c) =>
      c.row == position.row && c.col == position.col);
    if (isOccupied) {
      StructuredLogger.warning('PLACEMENT BLOCKED: Position occupied', context: {
        'requestedPosition': {'row': position.row, 'col': position.col},
        'occupied': true,
      });
      return false;
    }

    return true; // Valid placement
  }

  // Enhanced bounds error reporting
  String _getBoundsError(GridPosition position, [int? maxRows, int? maxCols]) {
    final rows = maxRows ?? state.grid.rows;
    final cols = maxCols ?? state.grid.cols;

    if (position.row < 0) return 'Row below 0';
    if (position.row >= rows) return 'Row ${position.row} exceeds max ${rows - 1}';
    if (position.col < 0) return 'Col below 0';
    if (position.col >= cols) return 'Col ${position.col} exceeds max ${cols - 1}';
    return 'Unknown bounds error';
  }

  // Check if component is available in inventory
  bool _inventoryHas(ComponentType type) {
    final inventoryCheck = _inventoryService.checkAvailability(type);

    if (enableInventoryDetailed && isDevelopment) {
      StructuredLogger.debug('🔍 INVENTORY CHECK', context: {
        'componentType': type.toString(),
        'inventoryCheckResult': inventoryCheck.isAvailable,
        'availableCount': inventoryCheck.availableCount,
        'totalCount': inventoryCheck.totalCount,
        'reason': inventoryCheck.reason,
        'state': inventoryCheck.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
      });
    }

    return inventoryCheck.isAvailable;
  }

  // ✅ PUBLIC API: Check inventory availability for drag validation
  bool checkInventoryAvailability(ComponentType type) {
    return _inventoryHas(type);
  }

  // ATOMIC STATE UPDATE
  // 🔥 ENHANCED DEBUG LOGGING FOR COMPONENT PLACEMENT DIAGNOSTICS
  // 🛠️ FIXED: Accept viewport parameters as method arguments to avoid provider access issues
  Future<void> handlePaletteDragEnd(ComponentDragData dragData, Offset globalPosition, {
    double cellSize = 60.0,
    double scale = 1.0,
    Offset panOffset = Offset.zero,
    Size canvasSize = const Size(1440, 788),
    double devicePixelRatio = 2.0,
  }) async {

    StructuredLogger.info('PLACEMENT REQUEST: Coordinate conversion starting', context: {
      'screenPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
      'viewportParams': {
        'cellSize': cellSize,
        'scale': scale,
        'panOffset': {'dx': panOffset.dx, 'dy': panOffset.dy},
        'levelBounds': {'rows': state.grid.rows, 'cols': state.grid.cols},
      },
    });

    // ✅ FIXED: Use visual grid dimensions (20x20) for coordinate calculation
    if (enableCoordinateValidation && isDevelopment) {
      StructuredLogger.debug('🔍 COORDINATE CONVERSION: About to call screenToGrid', context: {
        'inputPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
        'coordinateContext': {
          'gridDimensions': Size(20.0, 20.0).toString(),
          'cellSize': cellSize,
          'scale': scale,
          'panOffset': {'dx': panOffset.dx, 'dy': panOffset.dy},
          'canvasSize': canvasSize.toString(),
          'devicePixelRatio': devicePixelRatio,
        },
      });
    }

    final dropPosition = _coordinateService.screenToGrid(globalPosition, CoordinateContext(
      gridDimensions: Size(20.0, 20.0), // Visual grid bounds (20x20) - CORRECT
      cellSize: cellSize,          // ✅ From actual viewport
      scale: scale,               // ✅ From actual viewport
      panOffset: panOffset,       // ✅ From actual viewport
      canvasSize: canvasSize,     // ✅ From actual canvas
      devicePixelRatio: devicePixelRatio,
    ));

    if (enableCoordinateValidation && isDevelopment) {
      StructuredLogger.debug('🔍 COORDINATE CONVERSION: Result from screenToGrid', context: {
        'inputPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
        'calculatedPosition': dropPosition != null ? {'row': dropPosition.row, 'col': dropPosition.col} : 'null',
        'conversion_success': dropPosition != null,
      });
    }

    // ✅ FIXED: Allow placement anywhere in visual grid (20x20) but warn about visibility
    if (dropPosition != null && (dropPosition.row >= state.grid.rows || dropPosition.col >= state.grid.cols)) {
      StructuredLogger.info('🔔 COMPONENT PLACEMENT WARNING: Outside level boundary', context: {
        'calculatedPosition': {'row': dropPosition.row, 'col': dropPosition.col},
        'levelBounds': {'rows': state.grid.rows, 'cols': state.grid.cols},
        'visualBounds': {'rows': 20, 'cols': 20},
        'screenPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
        'warning': 'Component may be invisible but placement will proceed (visual grid allows it)',
      });
      // 🔧 REMOVED: Don't block placement - let users place anywhere in visual grid (20x20)
      // state = state.copyWith(error: 'Component placement outside level bounds would be invisible');
      // return;
    }

    if (dropPosition == null) {
      StructuredLogger.warning('PLACEMENT BLOCKED: Coordinate conversion returned null', context: {
        'reason': 'screenToGrid failed',
        'screenPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
      });
      state = state.copyWith(error: 'Coordinate conversion failed');
      return;
    }

    // CENTRALIZED VALIDATION - Enhanced with detailed logging
    if (!_isValidPlacement(dropPosition)) {
      StructuredLogger.warning('PLACEMENT BLOCKED: Validation failed', context: {
        'calculatedPosition': {'row': dropPosition.row, 'col': dropPosition.col},
        'levelBounds': {'rows': state.grid.rows, 'cols': state.grid.cols},
      });
      state = state.copyWith(error: 'Invalid placement location');
      return;
    }

    if (!_inventoryHas(dragData.componentType)) {
      StructuredLogger.warning('PLACEMENT BLOCKED: Component not available', context: {
        'componentType': dragData.componentType,
      });
      state = state.copyWith(error: 'Component not available in inventory');
      // 🔧 CRITICAL FIX: Ensure UI updates by resetting hovered state and preventing any further placement
      setHoveredCell(null);
      return;
    }

    // ATOMIC STATE UPDATE
    final newComponent = ComponentModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      type: dragData.componentType,
      row: dropPosition.row,
      col: dropPosition.col,
    );

    final updatedComponents = {...state.grid.components, newComponent.id: newComponent};
    state = state.copyWith(
      grid: state.grid.copyWith(
        components: updatedComponents
      ),
      // Update inventory here when implemented
    );

    // 🔧 CONSUME INVENTORY: Decrement available component count after successful placement
    try {
      final consumptionResult = await _inventoryService.consumeComponent(dragData.componentType);
      if (!consumptionResult.isSuccess) {
        StructuredLogger.warning('⚠️ INVENTORY CONSUMPTION FAILED', context: {
          'componentType': dragData.componentType.toString(),
          'error': consumptionResult.errorMessage,
          'remainingCount': consumptionResult.remainingCount,
        });
        // Log the error but don't fail the placement since component is already placed
      } else {
        StructuredLogger.debug('📦 INVENTORY CONSUMED', context: {
          'componentType': dragData.componentType.toString(),
          'remainingCount': consumptionResult.remainingCount,
        });
      }
    } catch (e) {
      StructuredLogger.error('❌ INVENTORY CONSUMPTION ERROR', context: {
        'componentType': dragData.componentType.toString(),
        'error': e.toString(),
      });
    }

    StructuredLogger.info('✅ COMPONENT SUCCESSFULLY PLACED', context: {
      'componentType': dragData.componentType.toString(),
      'position': {'row': dropPosition.row, 'col': dropPosition.col},
      'componentId': newComponent.id,
      'totalComponents': updatedComponents.length,
      'inventoryConsumed': true,
      'viewportParams': {
        'cellSize': cellSize,
        'scale': scale,
        'panOffset': panOffset.toString(),
        'canvasSize': '${canvasSize.width.toInt()}x${canvasSize.height.toInt()}',
        'levelBoundsUsed': '${state.grid.rows}x${state.grid.cols}',
        'visualBoundsMaintained': '20x20'
      },
      'levelId': _levelId,
    });
  }

  // Wire drawing methods
  void onWireDrawStart(Offset globalStart) {
    // Update state to show wire drawing has started
    StructuredLogger.info('Wire drawing started', context: {
      'startPosition': globalStart.toString(),
      'levelId': _levelId,
    });
  }

  void onWireDrawEnd(Offset globalEnd) {
    // This will be implemented with WireRoutingService in Step 2.2
    StructuredLogger.info('Wire drawing ended', context: {
      'endPosition': globalEnd.toString(),
      'levelId': _levelId,
    });
  }

  /// ✅ REQUIRED: Hover management (from REFACTORING_GUIDE.md line 105)
  void setHoveredCell(int? index) {
    // Validate bounds before setting
    if (index != null) {
      final rows = state.grid.rows;
      final cols = state.grid.cols;
      final maxIndex = rows * cols - 1;
      if (index < 0 || index > maxIndex) {
        StructuredLogger.warning('Invalid hover cell index', context: {
          'index': index,
          'maxIndex': maxIndex,
        });
        return;
      }
    }

    state = state.copyWith(hoveredCellIndex: index);
    StructuredLogger.debug('Hover cell updated', context: {
      'index': index,
      'levelId': _levelId,
    });
  }
}
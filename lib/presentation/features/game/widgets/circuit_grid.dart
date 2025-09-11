import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/application/use_cases/create_component_use_case.dart';
import 'package:sparkcircuit/application/use_cases/notifier_integrated_use_case.dart';
import 'package:sparkcircuit/application/use_cases/interaction_use_case.dart';
import 'package:sparkcircuit/application/transaction.dart';
import 'package:sparkcircuit/application/services/component_palette_manager.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/canvas_component_layer.dart';

// ✅ FIXED: Coordinate Transformation Service
class GridCoordinateService {
  static GridPosition? calculateGridPosition({
    required Offset globalPosition,
    required RenderBox gridRenderBox,
    required ViewportState viewportState,
    required GridConfiguration gridConfig,
  }) {
    try {
      // ✅ FIX: Add size validation guard
      if (gridRenderBox.size.width <= 0 || gridRenderBox.size.height <= 0) {
        StructuredLogger.error('Invalid render box size for coordinate calculation', context: {
          'renderBoxSize': gridRenderBox.size.toString(),
          'globalPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
        });
        return null; // Fail gracefully instead of rejecting all positions
      }

      // Step 1: Convert global position to local position relative to the grid
      final localPosition = gridRenderBox.globalToLocal(globalPosition);
      
      StructuredLogger.debug('Coordinate transformation', context: {
        'globalPosition': {'dx': globalPosition.dx, 'dy': globalPosition.dy},
        'localPosition': {'dx': localPosition.dx, 'dy': localPosition.dy},
        'gridRenderBoxSize': gridRenderBox.size.toString(),
      });
      
      // Step 2: Check if the position is within the render box bounds
      if (localPosition.dx < 0 || localPosition.dy < 0 ||
          localPosition.dx > gridRenderBox.size.width ||
          localPosition.dy > gridRenderBox.size.height) {
        StructuredLogger.debug('Position outside render box bounds', context: {
          'localPosition': {'dx': localPosition.dx, 'dy': localPosition.dy},
          'renderBoxSize': gridRenderBox.size.toString(),
        });
        return null;
      }
      
      // Step 3: Calculate grid cell coordinates
      // Since the GridView.builder is inside Transform widgets, we need to account for them
      // The localPosition is already in the coordinate system of the MouseRegion/GridView
      
      // Apply inverse transforms to get the actual grid coordinates
      final adjustedX = (localPosition.dx - viewportState.panOffset.dx) / viewportState.scale;
      final adjustedY = (localPosition.dy - viewportState.panOffset.dy) / viewportState.scale;
      
      final col = (adjustedX / gridConfig.cellSize).floor();
      final row = (adjustedY / gridConfig.cellSize).floor();
      
      StructuredLogger.debug('Grid coordinate calculation', context: {
        'adjustedX': adjustedX,
        'adjustedY': adjustedY,
        'calculatedRow': row,
        'calculatedCol': col,
        'cellSize': gridConfig.cellSize,
        'scale': viewportState.scale,
        'panOffset': {'dx': viewportState.panOffset.dx, 'dy': viewportState.panOffset.dy},
      });
      
      // Step 4: Validate bounds
      if (row >= 0 && row < gridConfig.rows && col >= 0 && col < gridConfig.cols) {
        return GridPosition(row: row, col: col);
      } else {
        StructuredLogger.debug('Calculated position out of grid bounds', context: {
          'row': row,
          'col': col,
          'gridBounds': {'rows': gridConfig.rows, 'cols': gridConfig.cols},
        });
        return null;
      }
    } catch (e, stackTrace) {
      StructuredLogger.error('Error in coordinate calculation', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      return null;
    }
  }
}

// ✅ FIXED: Grid Interaction Service with proper error handling
class GridInteractionService {
  final StateController<int?> _hoveredCellController;
  final dynamic _paletteNotifier;
  final dynamic _interactionUseCase;

  GridInteractionService(this._hoveredCellController, this._paletteNotifier, this._interactionUseCase);

  void setHoveredCell(int? index) {
    try {
      _hoveredCellController.state = index;
    } catch (e) {
      StructuredLogger.error('Failed to set hovered cell', context: {'error': e.toString(), 'index': index});
    }
  }

  void clearHover() {
    try {
      _hoveredCellController.state = null;
    } catch (e) {
      StructuredLogger.error('Failed to clear hover', context: {'error': e.toString()});
    }
  }

  bool canUseComponent(String componentType) {
    try {
      return _paletteNotifier.canUseComponent(componentType);
    } catch (e) {
      StructuredLogger.error('Failed to check component availability', context: {'error': e.toString(), 'componentType': componentType});
      return false;
    }
  }

  void useComponent(String componentType) {
    try {
      _paletteNotifier.useComponent(componentType);
    } catch (e) {
      StructuredLogger.error('Failed to use component', context: {'error': e.toString(), 'componentType': componentType});
    }
  }

  void returnComponent(String componentType) {
    try {
      _paletteNotifier.returnComponent(componentType);
    } catch (e) {
      StructuredLogger.error('Failed to return component', context: {'error': e.toString(), 'componentType': componentType});
    }
  }

  dynamic getInteractionUseCase() {
    return _interactionUseCase;
  }
}

final gridInteractionServiceProvider = Provider.family<GridInteractionService, String>((ref, levelId) {
  final hoveredCellController = ref.watch(hoveredCellProvider.notifier);
  final paletteNotifier = ref.watch(paletteStateProvider(levelId).notifier);
  final interactionUseCase = ref.watch(interactionUseCaseProvider(levelId));
  return GridInteractionService(hoveredCellController, paletteNotifier, interactionUseCase);
});

final hoveredCellProvider = StateProvider<int?>((ref) => null);

class CircuitGrid extends ConsumerStatefulWidget {
  final String levelId;

  const CircuitGrid({
    super.key,
    required this.levelId,
  });

  @override
  ConsumerState<CircuitGrid> createState() => _CircuitGridState();
}

// ✅ FIX: Create injected service to eliminate ref.read() anti-pattern
class CircuitGridService {
  final StateController<int?> _hoveredCellController;
  final dynamic _paletteNotifier;
  final dynamic _interactionUseCase;

  CircuitGridService(
    this._hoveredCellController,
    this._paletteNotifier,
    this._interactionUseCase,
  );

  // Delegate methods to eliminate ref.read() calls
  void setHoveredCell(int? index) => _hoveredCellController.state = index;
  void clearHover() => _hoveredCellController.state = null;
  int? getCurrentHovered() => _hoveredCellController.state;
  bool canUseComponent(String componentType) => _paletteNotifier.canUseComponent(componentType);
  void useComponent(String componentType) => _paletteNotifier.useComponent(componentType);
  dynamic getInteractionUseCase() => _interactionUseCase;
  Map<String, dynamic> getComponents() => _interactionUseCase.getGameState().grid.components;

  NotifierContext createNotifierContext(String levelId) {
    return NotifierContext(
      grid: _interactionUseCase.getGameStateNotifier(),
      history: _interactionUseCase.getHistoryNotifier(),
      progress: _interactionUseCase.getProgressNotifier(),
      selection: _interactionUseCase.getSelectionNotifier(),
      interaction: _interactionUseCase.getInteractionStateNotifier(levelId),
      paletteManager: _paletteNotifier,
    );
  }
}

class _CircuitGridState extends ConsumerState<CircuitGrid> {
  final _gridKey = GlobalKey();
  Timer? _hoverThrottleTimer;
  CircuitGridService? _gridService; // ✅ FIX: Injected service, made nullable for error handling

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Initialize injected service to eliminate ref.read() calls
    _initializeService();
  }

  void _initializeService() {
    try {
      _gridService = CircuitGridService(
        ref.read(hoveredCellProvider.notifier), // Only ref.read() in init - acceptable
        ref.read(paletteStateProvider(widget.levelId).notifier),
        ref.read(interactionUseCaseProvider(widget.levelId)),
      );
      StructuredLogger.debug('CircuitGridService initialized successfully', context: {'levelId': widget.levelId});
    } catch (e, stackTrace) {
      StructuredLogger.error('Failed to initialize CircuitGridService', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'levelId': widget.levelId,
      });
      _gridService = null;
    }
  }

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircuitGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_gridService == null || oldWidget.levelId != widget.levelId) {
      _initializeService();
    }
  }

  @override
  Widget build(BuildContext context) {
    MigrationTracker.markFileMigrated('circuit_grid.dart', DateTime.now().toIso8601String());

    StructuredLogger.trace('CircuitGrid build() called', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));

    // Ensure viewport is synchronized with level dimensions
    final gridConfig = canvasState.viewportState.gridConfiguration;
    final hoveredCellIndex = ref.watch(hoveredCellProvider);
    final components = _gridService?.getComponents() ?? {}; // ✅ FIX: Use injected service with null safety
    final gridService = ref.watch(gridInteractionServiceProvider(widget.levelId));

    // Log synchronization status
    StructuredLogger.debug('CircuitGrid viewport synchronization check', context: {
      'levelId': widget.levelId,
      'viewport_rows': gridConfig.rows,
      'viewport_cols': gridConfig.cols,
      'has_current_level': canvasState.currentLevel != null,
      'level_grid_height': canvasState.currentLevel?.grid.height ?? 'null',
      'level_grid_width': canvasState.currentLevel?.grid.width ?? 'null',
      'is_synchronized': canvasState.currentLevel != null &&
                       gridConfig.rows == canvasState.currentLevel!.grid.height &&
                       gridConfig.cols == canvasState.currentLevel!.grid.width,
    });

    StructuredLogger.debug('Provider watch results', context: {
      'gridConfig': {'rows': gridConfig.rows, 'cols': gridConfig.cols, 'cellSize': gridConfig.cellSize},
      'hoveredCellIndex': hoveredCellIndex,
      'components_count': components.length,
      'levelId': widget.levelId,
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,    // ✅ Propagate width constraints
          height: constraints.maxHeight,  // ✅ Propagate height constraints
          child: Stack(
            children: [
              // Layer 1: Visual grid painter
              RepaintBoundary(
                child: CustomPaint(
                  painter: GridPainter(
                    canvasState: canvasState,
                    circuitColors: Theme.of(context).extension<CircuitColorScheme>() ?? _getDefaultCircuitColors(),
                    hoveredCellIndex: hoveredCellIndex,
                    gridConfig: gridConfig,
                  ),
                  child: Container(),
                ),
              ),

              // Layer 2: Component rendering layer
              Transform.scale(
                scale: canvasState.viewportState.scale,
                child: Transform.translate(
                  offset: canvasState.viewportState.panOffset,
                  child: CanvasComponentLayer(levelId: widget.levelId),
                ),
              ),

              // Layer 3: Interactive drag target grid
              Transform.scale(
                scale: canvasState.viewportState.scale,
                child: Transform.translate(
                  offset: canvasState.viewportState.panOffset,
                  child: MouseRegion(
                    key: _gridKey,
                    onHover: (event) => _handleHover(event, canvasState, gridConfig, gridService),
                    onExit: (event) => gridService.clearHover(),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridConfig.cols,
                      ),
                      itemCount: gridConfig.rows * gridConfig.cols,
                      itemBuilder: (context, index) => _buildGridCell(
                        context,
                        index,
                        gridConfig,
                        hoveredCellIndex,
                        components,
                        canvasState,
                        gridService,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleHover(PointerHoverEvent event, GameCanvasState canvasState, GridConfiguration gridConfig, GridInteractionService gridService) {
    _hoverThrottleTimer?.cancel();
    _hoverThrottleTimer = Timer(const Duration(milliseconds: 16), () {
      final gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) return;

      // CONSISTENT COORDINATE TRANSFORMATION (same as drop handling)
      // 1. Convert to MouseRegion local coordinates
      final localPosition = gridRenderBox.globalToLocal(event.position);
      
      // 2. Apply transforms to match GridView coordinate space
      final scale = canvasState.viewportState.scale;
      final panOffset = canvasState.viewportState.panOffset;
      
      final transformedX = (localPosition.dx - panOffset.dx) / scale;
      final transformedY = (localPosition.dy - panOffset.dy) / scale;
      
      // 3. Calculate grid cell coordinates
      final col = (transformedX / gridConfig.cellSize).floor();
      final row = (transformedY / gridConfig.cellSize).floor();

      StructuredLogger.debug('Hover coordinate calculation', context: {
        'localPosition': {'dx': localPosition.dx, 'dy': localPosition.dy},
        'transformed': {'x': transformedX, 'y': transformedY},
        'calculatedRow': row,
        'calculatedCol': col,
        'cellSize': gridConfig.cellSize,
        'scale': scale,
        'panOffset': {'dx': panOffset.dx, 'dy': panOffset.dy},
        'levelId': widget.levelId,
      });

      // Validate bounds and update hover state
      if (row >= 0 && row < gridConfig.rows && col >= 0 && col < gridConfig.cols) {
        final cellIndex = row * gridConfig.cols + col;
        final currentHovered = _gridService?.getCurrentHovered();
        
        if (currentHovered != cellIndex) {
          gridService.setHoveredCell(cellIndex);
          StructuredLogger.debug('Non-drag hover at cell', context: {
            'row': row,
            'col': col,
            'index': cellIndex,
            'levelId': widget.levelId,
          });
        }
      } else {
        // Clear hover if outside bounds
        gridService.clearHover();
      }
    });
  }

  Widget _buildGridCell(
    BuildContext context,
    int index,
    GridConfiguration gridConfig,
    int? hoveredCellIndex,
    Map<String, dynamic> components,
    GameCanvasState canvasState,
    GridInteractionService gridService,
  ) {
    final logicalRow = index ~/ gridConfig.cols;
    final logicalCol = index % gridConfig.cols;
    final isHovered = hoveredCellIndex == index;
    final isOccupied = components.values.any((c) => c.row == logicalRow && c.col == logicalCol);

    return DragTarget<ComponentDragData>(
      onWillAccept: (data) {
        try {
          StructuredLogger.debug('🎯 DRAG ACCEPT CHECK - CircuitGrid', context: {
            'cellIndex': index,
            'cellRow': logicalRow,
            'cellCol': logicalCol,
            'isOccupied': isOccupied,
            'dataAvailable': data != null,
            'levelId': widget.levelId,
          });

          if (isOccupied) {
            StructuredLogger.info('🎯 DRAG REJECTED - Cell Occupied', context: {
              'cellIndex': index,
              'reason': 'position_occupied',
              'components': components.values.toList(),
            });
            gridService.clearHover();
            return false;
          }

          gridService.setHoveredCell(index);

          StructuredLogger.info('🎯 DRAG ACCEPTED - Valid Grid Cell', context: {
            'cellIndex': index,
            'cellRow': logicalRow,
            'cellCol': logicalCol,
            'componentType': data?.componentType.toString(),
          });
          return true;
        } catch (e, stackTrace) {
          StructuredLogger.error('🎯 CRITICAL: Drag Accept Check Failed', context: {
            'cellIndex': index,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
            'levelId': widget.levelId,
          });
          return false;
        }
      },
      onLeave: (data) {
        try {
          StructuredLogger.debug('🎯 DRAG LEAVE - CircuitGrid', context: {
            'cellIndex': index,
            'reason': 'user_abandoned_drop',
            'levelId': widget.levelId,
          });
          gridService.clearHover();
        } catch (e) {
          StructuredLogger.error('🎯 DRAG LEAVE ERROR', context: {
            'cellIndex': index,
            'error': e.toString(),
            'levelId': widget.levelId,
          });
        }
      },
      onAcceptWithDetails: (details) {
        try {
          StructuredLogger.info('🎯 ===== CIRCUIT GRID DROP TRIGGERED =====', context: {
            'cellIndex': index,
            'cellRow': logicalRow,
            'cellCol': logicalCol,
            'componentType': details.data.componentType.toString(),
            'componentName': details.data.componentName,
            'dragOffset': {'dx': details.offset.dx, 'dy': details.offset.dy},
            'levelId': widget.levelId,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

          _handleDrop(details, canvasState, gridConfig, gridService, context);
        } catch (e, stackTrace) {
          StructuredLogger.error('🎯 CRITICAL: Circuit Grid Drop Trigger Failed', context: {
            'cellIndex': index,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
            'componentType': details.data.componentType.toString(),
            'levelId': widget.levelId,
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasCandidateData = candidateData.isNotEmpty;
        final showHover = hasCandidateData && isHovered;
        
        return Container(
          decoration: BoxDecoration(
            color: showHover ? (isOccupied ? Colors.red.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4)) : Colors.transparent,
            border: Border.all(
              color: showHover ? (isOccupied ? Colors.red : Colors.green) : Colors.transparent,
              width: 2,
            ),
          ),
          child: showHover ? Center(
            child: Icon(
              candidateData.first?.icon ?? Icons.help_outline,
              size: 24,
              color: isOccupied ? Colors.red : Colors.green,
            ),
          ) : null,
        );
      },
    );
  }

  // ✅ FIXED: Proper coordinate transformation and error handling
  Future<void> _handleDrop(
    DragTargetDetails<ComponentDragData> details,
    GameCanvasState canvasState,
    GridConfiguration gridConfig,
    GridInteractionService gridService,
    BuildContext context,
  ) async {
    StructuredLogger.info('Component drop initiated', context: {
      'globalOffset': {'dx': details.offset.dx, 'dy': details.offset.dy},
      'componentType': details.data.componentType.toString(),
      'levelId': widget.levelId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      final gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) {
        StructuredLogger.error('Grid render box is null - cannot process drop');
        _showErrorSnackBar(context, 'Internal error: Cannot process drop');
        return;
      }

      // Use the robust coordinate calculation service
      final gridPosition = GridCoordinateService.calculateGridPosition(
        globalPosition: details.offset,
        gridRenderBox: gridRenderBox,
        viewportState: canvasState.viewportState,
        gridConfig: gridConfig,
      );

      if (gridPosition == null) {
        StructuredLogger.warning('Drop position is outside valid grid bounds');
        _showErrorSnackBar(context, 'Cannot place component: Position is outside the grid');
        return;
      }

      final row = gridPosition.row;
      final col = gridPosition.col;
      final data = details.data;
      final componentTypeString = data.componentType.toString().split('.').last;

      StructuredLogger.info('Component placement start', context: {
        'componentType': data.componentType,
        'componentName': data.componentName,
        'dropPosition': {'row': row, 'col': col},
        'levelId': widget.levelId,
      });

      // Validate component availability
      if (!gridService.canUseComponent(componentTypeString)) {
        StructuredLogger.warning('Component placement aborted - insufficient inventory');
        _showErrorSnackBar(context, 'No items left in inventory!');
        return;
      }

      // Check for occupied cell
      final components = _gridService?.getComponents() ?? {}; // ✅ FIX: Use injected service with null safety
      final isCellOccupied = components.values.any((c) => c.row == row && c.col == col);
      if (isCellOccupied) {
        StructuredLogger.warning('Drop position occupied', context: {'row': row, 'col': col});
        _showErrorSnackBar(context, 'Cannot place component here: position is occupied');
        return;
      }

      // Clear hover state
      gridService.clearHover();
      Future.delayed(const Duration(milliseconds: 100), () => gridService.clearHover());

      // ✅ FIXED: Create proper NotifierContext using WidgetRef
      // 🔧 REMOVED: Inventory decrement moved to atomic transaction in _placeComponentSafely
      final result = await _placeComponentSafely(data.componentType, row, col, componentTypeString, gridService);

      if (result) {
        StructuredLogger.info('Component placement successful', context: {
          'componentType': data.componentType,
          'position': {'row': row, 'col': col},
          'levelId': widget.levelId,
        });
        _showSuccessSnackBar(context, '${data.componentName} placed at ($row, $col)!');
      } else {
        gridService.returnComponent(componentTypeString);
        StructuredLogger.error('Component placement failed');
        _showErrorSnackBar(context, 'Failed to place component');
      }

    } catch (e, stackTrace) {
      StructuredLogger.error('Unexpected error in component placement', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'levelId': widget.levelId,
      }, error: e);
      _showErrorSnackBar(context, 'Unexpected error: $e');
    }
  }

  // ✅ FIXED: Safe component placement with proper error handling
  Future<bool> _placeComponentSafely(
    ComponentType componentType,
    int row,
    int col,
    String componentTypeString,
    GridInteractionService gridService,
  ) async {
    try {
      final transaction = GameTransaction();

      // Check if service is null and attempt reinitialization
      if (_gridService == null) {
        StructuredLogger.error('CircuitGridService is null, attempting reinitialization', context: {'levelId': widget.levelId});
        _initializeService();
        if (_gridService == null) {
          StructuredLogger.error('Failed to reinitialize CircuitGridService', context: {'levelId': widget.levelId});
          return false;
        }
      }

      // Create NotifierContext with proper WidgetRef usage
      final notifierContext = _gridService!.createNotifierContext(widget.levelId); // ✅ FIX: Use injected service

      StructuredLogger.debug('NotifierContext created successfully', context: {
        'grid_type': notifierContext.grid.runtimeType.toString(),
        'levelId': widget.levelId,
      });

      // 🔧 ATOMIC INVENTORY UPDATE: Include inventory decrement in transaction
      // This ensures inventory is only decremented if grid placement succeeds
      transaction.onCommit(() async {
        StructuredLogger.debug('🔧 Transaction: Decrementing inventory atomically', context: {
          'componentType': componentTypeString,
          'position': {'row': row, 'col': col},
          'levelId': widget.levelId,
        });
        gridService.useComponent(componentTypeString);
      });

      // 🔧 ATOMIC ROLLBACK: Restore inventory if placement fails
      transaction.onRollback(() {
        StructuredLogger.debug('🔧 Transaction: Restoring inventory on rollback', context: {
          'componentType': componentTypeString,
          'position': {'row': row, 'col': col},
          'levelId': widget.levelId,
        });
        gridService.returnComponent(componentTypeString);
      });

      final result = await CreateComponentUseCase.placeComponent(
        componentType,
        row,
        col,
        notifierContext,
        transaction,
      );

      if (result.isSuccess) {
        await transaction.commit();
        return true;
      } else {
        transaction.rollback();
        StructuredLogger.error('Component placement failed', context: {
          'error': result.error,
          'position': {'row': row, 'col': col},
        });
        return false;
      }
    } catch (e, stackTrace) {
      StructuredLogger.error('Error in safe component placement', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      return false;
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    StructuredLogger.info('✅ SUCCESS FEEDBACK SHOWN', context: {
      'message': message,
      'type': 'success_snackbar',
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    StructuredLogger.error('❌ ERROR FEEDBACK SHOWN', context: {
      'message': message,
      'type': 'error_snackbar',
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  CircuitColorScheme _getDefaultCircuitColors() {
    return const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00FFFF),
      neonAccent: Color(0xFFFF00FF),
      errorGlow: Color(0xFFFF0040),
      energyPulse: Color(0xFF39FF14),
      highlightAccent: Color(0xFFFFFF00),
    );
  }
}

// ✅ OPTIMIZED: GridPainter with better performance
class GridPainter extends CustomPainter {
  final GameCanvasState canvasState;
  final CircuitColorScheme circuitColors;
  final int? hoveredCellIndex;
  final dynamic gridConfig;

  GridPainter({
    required this.canvasState,
    required this.circuitColors,
    this.hoveredCellIndex,
    this.gridConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    StructuredLogger.trace('GridPainter painting', context: {
      'canvasSize': '${size.width}x${size.height}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final config = canvasState.viewportState.gridConfiguration;
    final cellSize = config.cellSize * canvasState.viewportState.scale;
    final panOffset = canvasState.viewportState.panOffset;

    // Calculate visible bounds with buffer
    final startX = ((-panOffset.dx / cellSize).floor() - 1).clamp(0, config.cols);
    final endX = (((size.width - panOffset.dx) / cellSize).ceil() + 1).clamp(0, config.cols);
    final startY = ((-panOffset.dy / cellSize).floor() - 1).clamp(0, config.rows);
    final endY = (((size.height - panOffset.dy) / cellSize).ceil() + 1).clamp(0, config.rows);

    final gridPaint = Paint()
      ..color = circuitColors.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    final majorGridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    // Clip to canvas bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw vertical lines (optimized for visible area only)
    for (int i = startX; i <= endX; i++) {
      final x = (i * cellSize + panOffset.dx).roundToDouble();
      if (x >= -2 && x <= size.width + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(x, -2), Offset(x, size.height + 2), paint);
      }
    }

    // Draw horizontal lines (optimized for visible area only)
    for (int i = startY; i <= endY; i++) {
      final y = (i * cellSize + panOffset.dy).roundToDouble();
      if (y >= -2 && y <= size.height + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(-2, y), Offset(size.width + 2, y), paint);
      }
    }

    // Draw hover feedback (optimized corner markers)
    if (hoveredCellIndex != null && gridConfig != null) {
      _drawHoverFeedback(canvas, cellSize, panOffset);
    }
  }

  void _drawHoverFeedback(Canvas canvas, double cellSize, Offset panOffset) {
    final hoveredRow = hoveredCellIndex! ~/ gridConfig.cols;
    final hoveredCol = hoveredCellIndex! % gridConfig.cols;

    if (hoveredRow >= 0 && hoveredRow < gridConfig.rows &&
        hoveredCol >= 0 && hoveredCol < gridConfig.cols) {

      final hoverX = hoveredCol * cellSize + panOffset.dx;
      final hoverY = hoveredRow * cellSize + panOffset.dy;

      // Subtle hover highlight
      final hoverPaint = Paint()
        ..color = circuitColors.primary.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize),
        hoverPaint
      );

      // Corner markers
      final cornerPaint = Paint()
        ..color = circuitColors.primary.withValues(alpha: 0.7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final cornerSize = cellSize * 0.2;

      // Draw all four corners
      _drawCorner(canvas, cornerPaint, hoverX, hoverY, cornerSize, true, true);
      _drawCorner(canvas, cornerPaint, hoverX + cellSize, hoverY, cornerSize, false, true);
      _drawCorner(canvas, cornerPaint, hoverX, hoverY + cellSize, cornerSize, true, false);
      _drawCorner(canvas, cornerPaint, hoverX + cellSize, hoverY + cellSize, cornerSize, false, false);
    }
  }

  void _drawCorner(Canvas canvas, Paint paint, double x, double y, double size, bool left, bool top) {
    final dx = left ? size : -size;
    final dy = top ? size : -size;
    
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.canvasState.viewportState != canvasState.viewportState ||
           oldDelegate.circuitColors != circuitColors ||
           oldDelegate.hoveredCellIndex != hoveredCellIndex;
  }
}
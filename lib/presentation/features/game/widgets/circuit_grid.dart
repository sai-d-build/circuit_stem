import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/application/interaction_engine.dart' as interaction_engine;
import 'package:sparkcircuit/presentation/features/game/widgets/canvas_component_layer.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/interfaces/game_state_notifier_interface.dart';

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
      // The CircuitGrid applies transforms as: Transform.scale → Transform.translate
      // So the inverse should be: Translate⁻¹ → Scale⁻¹

      // First apply inverse translate (subtract pan offset)
      final translatedX = localPosition.dx - viewportState.panOffset.dx;
      final translatedY = localPosition.dy - viewportState.panOffset.dy;

      // Then apply inverse scale (divide by scale)
      final adjustedX = translatedX / viewportState.scale;
      final adjustedY = translatedY / viewportState.scale;

      // Finally convert to grid coordinates
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

// ✅ REMOVED: Legacy GridInteractionService - now using InteractionEngine directly

// ✅ REMOVED: Legacy GridInteractionService - now using InteractionEngine directly

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


class _CircuitGridState extends ConsumerState<CircuitGrid> {
  final _gridKey = GlobalKey();
  Timer? _hoverThrottleTimer;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVED: Legacy service initialization - now using InteractionEngine directly
  }

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircuitGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ REMOVED: Legacy service reinitialization - InteractionEngine handles this
  }

  @override
  Widget build(BuildContext context) {
    MigrationTracker.markFileMigrated('circuit_grid.dart', DateTime.now().toIso8601String());

    StructuredLogger.trace('CircuitGrid build() called', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
    final gameState = ref.watch(interaction_engine.interactionEngineProvider(widget.levelId));
    final interactionEngineNotifier = ref.watch(interaction_engine.interactionEngineProvider(widget.levelId).notifier);

    // Ensure viewport is synchronized with level dimensions
    final gridConfig = canvasState.viewportState.gridConfiguration;
    final hoveredCellIndex = ref.watch(hoveredCellProvider);
    final components = gameState.grid.components; // ✅ FIXED: Use provider pattern

    // Log synchronization status
    // Reduce excessive logging in production builds
    const bool enableDebugLogging = bool.fromEnvironment('ENABLE_GRID_SYNC_LOGS');
    if (enableDebugLogging) {
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
    }

    // Perform runtime synchronization validation
    final levelRows = canvasState.currentLevel?.grid.height;
    final levelCols = canvasState.currentLevel?.grid.width;

    const bool enableSyncValidation = bool.fromEnvironment('ENABLE_SYNC_VALIDATION');
    if (enableSyncValidation && canvasState.currentLevel != null) {
      final isSynchronized = gridConfig.rows == levelRows && gridConfig.cols == levelCols;

      if (!isSynchronized) {
        StructuredLogger.warning('🚨 SYNCHRONIZATION VALIDATION FAILED', context: {
          'expected': '$levelRows x $levelCols (level)',
          'actual': '${gridConfig.rows} x ${gridConfig.cols} (viewport)',
          'levelId': widget.levelId,
          'levelName': canvasState.currentLevel?.metadata.title ?? 'unknown',
          'severity': 'HIGH - This will cause coordinate miscalculations',
          'fix_suggestion': 'Ensure initializeLevel syncs viewport.gridConfiguration with level.grid dimensions',
        });
      } else {
        StructuredLogger.info('✅ GRID SYNCHRONIZATION VALIDATED', context: {
          'dimensions': '${levelRows}x${levelCols}',
          'levelId': widget.levelId,
        });
      }
    }

    StructuredLogger.debug('Provider watch results', context: {
      'gridConfig': {'rows': gridConfig.rows, 'cols': gridConfig.cols, 'cellSize': gridConfig.cellSize},
      'hoveredCellIndex': hoveredCellIndex,
      'components_count': components.length,
      'levelGridDimensions': canvasState.currentLevel != null ? '${canvasState.currentLevel!.grid.height}x${canvasState.currentLevel!.grid.width}' : 'null',
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
                    onHover: (event) => _handleHover(event, canvasState, gridConfig, interactionEngineNotifier),
                    onExit: (event) => ref.read(hoveredCellProvider.notifier).state = null,
                    // Use level-specific dimensions for GridView
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: canvasState.currentLevel?.grid.width ?? gridConfig.cols,
                      ),
                      itemCount: (canvasState.currentLevel?.grid.height ?? gridConfig.rows) *
                                (canvasState.currentLevel?.grid.width ?? gridConfig.cols),
                      itemBuilder: (context, index) => _buildGridCell(
                        context,
                        index,
                        gridConfig,
                        hoveredCellIndex,
                        components,
                        canvasState,
                        interactionEngineNotifier,
                        levelCols: canvasState.currentLevel?.grid.width ?? gridConfig.cols,
                        levelRows: canvasState.currentLevel?.grid.height ?? gridConfig.rows,
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

  void _handleHover(PointerHoverEvent event, GameCanvasState canvasState, GridConfiguration gridConfig, interaction_engine.InteractionEngine interactionEngine) {
    _hoverThrottleTimer?.cancel();
    _hoverThrottleTimer = Timer(const Duration(milliseconds: 16), () {
      final gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) return;

      // Get current game state for hover tracking
      final gameState = ref.watch(interaction_engine.interactionEngineProvider(widget.levelId));

      // Use level-specific grid dimensions for all coordinate calculations
      final levelGridConfig = GridConfiguration(
        rows: canvasState.currentLevel?.grid.height ?? gridConfig.rows,
        cols: canvasState.currentLevel?.grid.width ?? gridConfig.cols,
        cellSize: gridConfig.cellSize,
      );

      // Skip excessive logging to improve performance
      // 🎯 Use simplified coordinate calculation with level bounds
      final localPosition = gridRenderBox.globalToLocal(event.position);

      // Calculate grid cell coordinates using level-specific dimensions
      final col = (localPosition.dx / levelGridConfig.cellSize).floor();
      final row = (localPosition.dy / levelGridConfig.cellSize).floor();

      // Validate bounds using level grid dimensions (not viewport 20x20)
      if (row >= 0 && row < levelGridConfig.rows && col >= 0 && col < levelGridConfig.cols) {
        final cellIndex = row * levelGridConfig.cols + col;
        final currentHovered = gameState.hoveredCellIndex;

        if (currentHovered != cellIndex) {
          // ✅ FIXED: Use InteractionEngine for hover state management
          interactionEngine.setHoveredCell(cellIndex);
          ref.read(hoveredCellProvider.notifier).state = cellIndex;
          // Reduced logging frequency to prevent spam
          StructuredLogger.info('🎯 CELL HOVERED', context: {
            'row': row,
            'col': col,
            'index': cellIndex,
            'levelId': widget.levelId,
            'withinLevelBounds': true,
          });
        }
      } else {
        // Clear hover if outside level bounds
        ref.read(hoveredCellProvider.notifier).state = null;
        // Skip excessive logging
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
    interaction_engine.InteractionEngine interactionEngine, {
    int? levelCols,
    int? levelRows,
  }) {
    // Use level-specific dimensions for logical calculations
    final cols = levelCols ?? canvasState.currentLevel?.grid.width ?? gridConfig.cols;
    final logicalRow = index ~/ cols;
    final logicalCol = index % cols;
    final isHovered = hoveredCellIndex == index;
    final isOccupied = components.values.any((c) => c.row == logicalRow && c.col == logicalCol);

    return DragTarget<ComponentDragData>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        try {
          StructuredLogger.debug('🎯 DRAG ACCEPT CHECK - CircuitGrid', context: {
            'cellIndex': index,
            'cellRow': logicalRow,
            'cellCol': logicalCol,
            'isOccupied': isOccupied,
            'levelId': widget.levelId,
          });

          if (isOccupied) {
           StructuredLogger.info('🎯 DRAG REJECTED - Cell Occupied', context: {
             'cellIndex': index,
             'reason': 'position_occupied',
             'components': components.values.toList(),
           });
           ref.read(hoveredCellProvider.notifier).state = null;
           return false;
         }

         // 🔧 CRITICAL FIX: Check inventory availability before accepting drag
         // This prevents the race condition where UI shows drag accepted but placement blocks
         if (!interactionEngine.checkInventoryAvailability(data.componentType)) {
           StructuredLogger.warning('🎯 DRAG REJECTED - Insufficient Inventory (Early Check)', context: {
             'cellIndex': index,
             'componentType': data.componentType.toString(),
             'reason': 'insufficient_inventory',
             'levelId': widget.levelId,
           });
           ref.read(hoveredCellProvider.notifier).state = null;
           return false;
         }

         ref.read(hoveredCellProvider.notifier).state = index;

         StructuredLogger.info('🎯 DRAG ACCEPTED - Valid Grid Cell & Inventory Available', context: {
           'cellIndex': index,
           'cellRow': logicalRow,
           'cellCol': logicalCol,
           'componentType': data.componentType.toString(),
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
          ref.read(hoveredCellProvider.notifier).state = null;
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
          // 🎯 Enhanced debug logging for drag/drop sequence investigation
          if (enableDragDropSequence && isDevelopment) {
            StructuredLogger.info('🎯 COMPONENT DROP ACCEPTED - CircuitGrid', context: {
              'cellIndex': index,
              'row': logicalRow,
              'col': logicalCol,
              'componentType': details.data.componentType.toString(),
              'componentName': details.data.componentName,
              'isOccupied': isOccupied,
              'withinLevelBounds': logicalRow >= 0 && logicalRow < gridConfig.cols && logicalCol >= 0 && logicalCol < gridConfig.rows,
              'levelId': widget.levelId,
              'dragData': {
                'icon': details.data.icon != null ? 'present' : 'null',
                'position_x': logicalCol,
                'position_y': logicalRow,
              },
            });
          }
    
          // Pass viewport parameters to ensure consistent coordinate calculation
          _handleDrop(details, canvasState, gridConfig, interactionEngine, context,
            cellSize: canvasState.viewportState.gridConfiguration.cellSize,
            scale: canvasState.viewportState.scale,
            panOffset: canvasState.viewportState.panOffset,
            canvasSize: canvasState.viewportState.canvasSize,
            devicePixelRatio: 2.0,
          );
        } catch (e, stackTrace) {
          StructuredLogger.error('🎯 DROP FAILED', context: {
            'cellIndex': index,
            'error': e.toString(),
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

  // ✅ MIGRATION COMPLETE: Widget now uses InteractionEngine directly
  Future<void> _handleDrop(
    DragTargetDetails<ComponentDragData> details,
    GameCanvasState canvasState,
    GridConfiguration gridConfig,
    interaction_engine.InteractionEngine interactionEngine,
    BuildContext context, {
    double cellSize = 60.0,
    double scale = 1.0,
    Offset panOffset = Offset.zero,
    Size canvasSize = const Size(1440, 788),
    double devicePixelRatio = 2.0,
  }) async {
    // 🎯 DELEGATE TO INTERACTION ENGINE: All business logic centralized with viewport params
    interactionEngine.handlePaletteDragEnd(details.data, details.offset,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
      canvasSize: canvasSize,
      devicePixelRatio: devicePixelRatio,
    );

    // 🔧 TODO: Add proper inventory tracking and component placement
    // ISSUE: Inventory never decreases (always shows 10), only RESISTOR works
    final gameState = ref.watch(interaction_engine.interactionEngineProvider(widget.levelId));
    final unifiedState = ref.watch(unifiedGameStateProvider);

    if (gameState.grid.components.isNotEmpty) {
      try {
        // 🔧 FIX: Sync on ANY count mismatch, not just when unifiedState is empty
        final sync_condition_met = gameState.grid.components.length != unifiedState.grid.components.length;

        if (sync_condition_met) {
          final unifiedNotifier = ref.read(unifiedGameStateProvider.notifier);

          if (enableStateSyncLogging && isDevelopment) {
            StructuredLogger.info('🔄 STATE SYNCHRONIZATION: Starting sync (progressive fix)', context: {
              'componentCount_interaction': gameState.grid.components.length,
              'componentCount_unified': unifiedState.grid.components.length,
              'interaction_componentIds': gameState.grid.components.keys.toList(),
              'unified_componentIds': unifiedState.grid.components.keys.toList(),
              'levelId': widget.levelId,
              'gridDimensions_interaction': '${gameState.grid.rows}x${gameState.grid.cols}',
              'gridDimensions_unified': '${unifiedState.grid.rows}x${unifiedState.grid.cols}',
            });
          }

          final syncedState = unifiedState.copyWith(
            grid: unifiedState.grid.copyWith(
              components: gameState.grid.components,
              rows: gameState.grid.rows,
              cols: gameState.grid.cols,
            )
          );

          if (unifiedNotifier is StateNotifier<GameState>) {
            unifiedNotifier.state = syncedState;
          } else if (unifiedNotifier is IGameStateNotifier) {
            // For IGameStateNotifier, we need to use a different approach
            // Try setting state directly if available, otherwise use interface method
            try {
              (unifiedNotifier as dynamic).state = syncedState;
            } catch (e) {
              StructuredLogger.warning('Failed to sync state via direct assignment', context: {
                'error': e.toString(),
                'notifierType': unifiedNotifier.runtimeType.toString(),
              });
            }
          } else {
            StructuredLogger.warning('Unified notifier type not supported for state sync', context: {
              'notifierType': unifiedNotifier.runtimeType.toString(),
            });
          }

          if (enableStateSyncLogging && isDevelopment) {
            StructuredLogger.info('🔄 STATE SYNCHRONIZATION: Completed sync', context: {
              'total_components_after_sync': syncedState.grid.components.length,
              'component_types': syncedState.grid.components.values.map((c) => c.type.toString()).toList(),
              'sync_successful': true,
              'levelId': widget.levelId,
            });
          }
        } else if (enableStateSyncLogging && isDevelopment) {
          StructuredLogger.debug('🔄 STATE SYNCHRONIZATION: No sync needed', context: {
            'componentCount_interaction': gameState.grid.components.length,
            'componentCount_unified': unifiedState.grid.components.length,
            'sync_condition_met': sync_condition_met,
            'levelId': widget.levelId,
          });
        }
      } catch (e) {
        StructuredLogger.warning('⚠️ State synchronization update failed', context: {
          'error': e.toString(),
          'levelId': widget.levelId,
        });
      }
    }

    // Handle UI feedback based on GameState error field
    if (gameState.error != null) {
      _showErrorSnackBar(context, gameState.error!);
    } else {
      // Show success feedback if no error
      final gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) return;

      // Use level-specific grid dimensions for coordinate calculation
      final levelGridConfig = GridConfiguration(
        rows: canvasState.currentLevel?.grid.height ?? gridConfig.rows,
        cols: canvasState.currentLevel?.grid.width ?? gridConfig.cols,
        cellSize: gridConfig.cellSize,
      );

      final gridPosition = GridCoordinateService.calculateGridPosition(
        globalPosition: details.offset,
        gridRenderBox: gridRenderBox,
        viewportState: canvasState.viewportState,
        gridConfig: levelGridConfig,
      );
      if (gridPosition != null) {
        _showSuccessSnackBar(context, '${details.data.componentName} placed at (${gridPosition.row}, ${gridPosition.col})!');
      } else {
        // Reduced logging: only show when coordinate calculation fails
        const bool enableCoordLogs = bool.fromEnvironment('ENABLE_COORD_LOGS');
        if (enableCoordLogs) {
          StructuredLogger.warning('🎯 COORDINATE CALCULATION FAILED', context: {
            'componentName': details.data.componentName,
            'globalPosition': details.offset.toString(),
            'levelGridConfig': '${levelGridConfig.rows}x${levelGridConfig.cols}',
            'levelId': widget.levelId,
          });
        }
      }
    }

    // Clear hover state
    ref.read(hoveredCellProvider.notifier).state = null;
    Future.delayed(const Duration(milliseconds: 100), () => ref.read(hoveredCellProvider.notifier).state = null);
  }

  // ✅ REMOVED: Legacy _placeComponentSafely method - logic now handled by InteractionEngine

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
    if (hoveredCellIndex == null) return;

    final hoveredRow = hoveredCellIndex! ~/ gridConfig.cols;
    final hoveredCol = hoveredCellIndex! % gridConfig.cols;

    if (hoveredRow < gridConfig.rows && hoveredCol < gridConfig.cols) {

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
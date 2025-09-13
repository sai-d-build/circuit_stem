import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/interaction_engine.dart'
    as interaction_engine;
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart' hide GridPosition;
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/core/services/bounds_manager.dart';
import 'package:sparkcircuit/core/services/interactive_mechanics.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/bounds_visualizer.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/canvas_component_layer.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

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
        StructuredLogger.error(
            'Invalid render box size for coordinate calculation',
            context: {
              'renderBoxSize': gridRenderBox.size.toString(),
              'globalPosition': {
                'dx': globalPosition.dx,
                'dy': globalPosition.dy
              },
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
      if (localPosition.dx < 0 ||
          localPosition.dy < 0 ||
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
        'panOffset': {
          'dx': viewportState.panOffset.dx,
          'dy': viewportState.panOffset.dy
        },
      });

      // Step 4: Allow any position (full-screen mode) - bounds checking handled elsewhere
      return GridPosition(row: row, col: col);
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
    MigrationTracker.markFileMigrated(
        'circuit_grid.dart', DateTime.now().toIso8601String());

    // ✅ OPTIMIZED: Reduce logging frequency to improve performance
    const enableBuildLogging = bool.fromEnvironment('ENABLE_GRID_BUILD_LOGS');
    if (enableBuildLogging) {
      StructuredLogger.trace('CircuitGrid build() called', context: {
        'levelId': widget.levelId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // ✅ OPTIMIZED: Single provider watch with selector to reduce rebuilds
    final canvasState =
        ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
    final gameState =
        ref.watch(interaction_engine.interactionEngineProvider(widget.levelId));
    final interactionEngineNotifier = ref.watch(
        interaction_engine.interactionEngineProvider(widget.levelId).notifier);

    // Ensure viewport is synchronized with level dimensions
    final gridConfig = canvasState.viewportState.gridConfiguration;
    final hoveredCellIndex = ref.watch(hoveredCellProvider);
    final components =
        gameState.grid.components; // ✅ FIXED: Use provider pattern

    // Log synchronization status
    // Reduce excessive logging in production builds
    const enableDebugLogging = bool.fromEnvironment('ENABLE_GRID_SYNC_LOGS');
    if (enableDebugLogging) {
      StructuredLogger.debug('CircuitGrid viewport synchronization check',
          context: {
            'levelId': widget.levelId,
            'viewport_rows': gridConfig.rows,
            'viewport_cols': gridConfig.cols,
            'has_current_level': canvasState.currentLevel != null,
            'level_grid_height':
                canvasState.currentLevel?.grid.height ?? 'null',
            'level_grid_width': canvasState.currentLevel?.grid.width ?? 'null',
            'is_synchronized': canvasState.currentLevel != null &&
                gridConfig.rows == canvasState.currentLevel!.grid.height &&
                gridConfig.cols == canvasState.currentLevel!.grid.width,
          });
    }

    // Perform runtime synchronization validation
    final levelRows = canvasState.currentLevel?.grid.height;
    final levelCols = canvasState.currentLevel?.grid.width;

    const enableSyncValidation = bool.fromEnvironment('ENABLE_SYNC_VALIDATION');
    if (enableSyncValidation && canvasState.currentLevel != null) {
      final isSynchronized =
          gridConfig.rows == levelRows && gridConfig.cols == levelCols;

      if (!isSynchronized) {
        StructuredLogger.warning('🚨 SYNCHRONIZATION VALIDATION FAILED',
            context: {
              'expected': '$levelRows x $levelCols (level)',
              'actual': '${gridConfig.rows} x ${gridConfig.cols} (viewport)',
              'levelId': widget.levelId,
              'levelName':
                  canvasState.currentLevel?.metadata.title ?? 'unknown',
              'severity': 'HIGH - This will cause coordinate miscalculations',
              'fix_suggestion':
                  'Ensure initializeLevel syncs viewport.gridConfiguration with level.grid dimensions',
            });
      } else {
        StructuredLogger.info('✅ GRID SYNCHRONIZATION VALIDATED', context: {
          'dimensions': '${levelRows}x$levelCols',
          'levelId': widget.levelId,
        });
      }
    }

    StructuredLogger.debug('Provider watch results', context: {
      'gridConfig': {
        'rows': gridConfig.rows,
        'cols': gridConfig.cols,
        'cellSize': gridConfig.cellSize
      },
      'hoveredCellIndex': hoveredCellIndex,
      'components_count': components.length,
      'levelGridDimensions': canvasState.currentLevel != null
          ? '${canvasState.currentLevel!.grid.height}x${canvasState.currentLevel!.grid.width}'
          : 'null',
      'levelId': widget.levelId,
    });

    // Initialize bounds manager with appropriate configuration
    final boundsManager = UnifiedBoundsManager();
    final boundsConfig = canvasState.currentLevel != null
        ? BoundsConfiguration.advanced() // Use advanced config for full-screen boundaries
        : const BoundsConfiguration(); // Use default for no level
    boundsManager.updateConfiguration(boundsConfig);

    return LayoutBuilder(
      key: ValueKey('layout_${widget.levelId}'), // ✅ OPTIMIZED: Add key to prevent unnecessary rebuilds
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth, // ✅ Propagate width constraints
          height: constraints.maxHeight, // ✅ Propagate height constraints
          child: Stack(
            children: [
              // Layer 1: Visual grid painter
              RepaintBoundary(
                child: CustomPaint(
                  painter: GridPainter(
                    canvasState: canvasState,
                    circuitColors:
                        Theme.of(context).extension<CircuitColorScheme>() ??
                            _getDefaultCircuitColors(),
                    hoveredCellIndex: hoveredCellIndex,
                    gridConfig: gridConfig,
                  ),
                  child: const SizedBox.expand(), // ✅ OPTIMIZED: Use const SizedBox
                ),
              ),

              // Layer 2: Bounds visualizer (NEW: Enhanced visual feedback)
              BoundsVisualizer(
                boundsManager: boundsManager,
                cellSize: gridConfig.cellSize,
                panOffset: canvasState.viewportState.panOffset,
                hoveredRow: hoveredCellIndex != null && canvasState.currentLevel != null
                    ? hoveredCellIndex ~/ (canvasState.currentLevel?.grid.width ?? 1)
                    : null,
                hoveredCol: hoveredCellIndex != null && canvasState.currentLevel != null
                    ? hoveredCellIndex % (canvasState.currentLevel?.grid.width ?? 1)
                    : null,
                occupiedPositions: components.keys.toSet(),
              ),

              // Layer 3: Component rendering layer
              Transform.scale(
                key: ValueKey('component_layer_${widget.levelId}_${canvasState.viewportState.scale}'), // ✅ OPTIMIZED: Add key
                scale: canvasState.viewportState.scale,
                child: Transform.translate(
                  offset: canvasState.viewportState.panOffset,
                  child: CanvasComponentLayer(levelId: widget.levelId),
                ),
              ),

              // Layer 4: Interactive drag target grid
              Transform.scale(
                key: ValueKey('interactive_layer_${widget.levelId}_${canvasState.viewportState.scale}'), // ✅ OPTIMIZED: Add key
                scale: canvasState.viewportState.scale,
                child: Transform.translate(
                  offset: canvasState.viewportState.panOffset,
                  child: MouseRegion(
                    key: _gridKey,
                    onHover: (event) => _handleHover(event, canvasState,
                        gridConfig, interactionEngineNotifier),
                    onExit: (event) =>
                        ref.read(hoveredCellProvider.notifier).state = null,
                    // Use expanded dimensions for full-screen GridView
                    child: GridView.builder(
                      key: ValueKey('grid_view_${widget.levelId}_fullscreen'), // ✅ OPTIMIZED: Add key
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 50, // Large grid for full-screen coverage
                      ),
                      itemCount: 50 * 30, // 50x30 grid for full-screen coverage
                      itemBuilder: (context, index) => _buildGridCell(
                        context,
                        index,
                        gridConfig,
                        hoveredCellIndex,
                        components,
                        canvasState,
                        interactionEngineNotifier,
                        boundsManager: boundsManager, // NEW: Pass bounds manager
                        levelCols: 50, // Use expanded grid dimensions
                        levelRows: 30,
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

  void _handleHover(
      PointerHoverEvent event,
      GameCanvasState canvasState,
      GridConfiguration gridConfig,
      interaction_engine.InteractionEngine interactionEngine) {
    _hoverThrottleTimer?.cancel();
    _hoverThrottleTimer = Timer(const Duration(milliseconds: 16), () {
      final gridRenderBox =
          _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) return;

      // Get current game state for hover tracking
      final gameState = ref
          .watch(interaction_engine.interactionEngineProvider(widget.levelId));

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

      // Allow hovering anywhere (full-screen mode) - calculate cell index
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
          'fullScreenMode': true,
        });
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
    UnifiedBoundsManager? boundsManager,
    int? levelCols,
    int? levelRows,
  }) {
    // Use level-specific dimensions for logical calculations
    final cols =
        levelCols ?? canvasState.currentLevel?.grid.width ?? gridConfig.cols;
    final logicalRow = index ~/ cols;
    final logicalCol = index % cols;
    final isHovered = hoveredCellIndex == index;
    final isOccupied = components.values
        .any((c) => c.row == logicalRow && c.col == logicalCol);

    return DragTarget<ComponentDragData>(
      key: ValueKey('drag_target_${widget.levelId}_${index}_${isOccupied}_${isHovered}'), // ✅ OPTIMIZED: Add key to prevent unnecessary rebuilds
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        try {
          // ✅ OPTIMIZED: Reduce logging frequency for better performance
          const enableDragLogging = bool.fromEnvironment('ENABLE_DRAG_LOGS');
          if (enableDragLogging) {
            StructuredLogger.debug('🎯 DRAG ACCEPT CHECK - CircuitGrid',
                context: {
                  'cellIndex': index,
                  'cellRow': logicalRow,
                  'cellCol': logicalCol,
                  'isOccupied': isOccupied,
                  'levelId': widget.levelId,
                });
          }

          if (isOccupied) {
            if (enableDragLogging) {
              StructuredLogger.info('🎯 DRAG REJECTED - Cell Occupied', context: {
                'cellIndex': index,
                'reason': 'position_occupied',
                'components': components.values.toList(),
              });
            }
            ref.read(hoveredCellProvider.notifier).state = null;
            return false;
          }

          // 🔧 ENHANCED: Use unified bounds manager for comprehensive validation
          if (boundsManager != null) {
            final boundsValidation = boundsManager.validatePosition(
              logicalRow,
              logicalCol,
              occupiedPositions: components.keys.toSet(),
            );

            // Only reject if position is occupied, allow anywhere else in full-screen mode
            if (!boundsValidation.isValid && boundsValidation.errorMessage?.contains('occupied') != true) {
              // Allow placement anywhere except occupied positions
              StructuredLogger.debug(
                  '🎯 DRAG ALLOWED - Full Screen Mode',
                  context: {
                    'cellIndex': index,
                    'position': {'row': logicalRow, 'col': logicalCol},
                    'fullScreenMode': true,
                    'levelId': widget.levelId,
                  });
            } else if (!boundsValidation.isValid) {
              StructuredLogger.warning(
                  '🎯 DRAG REJECTED - Position Occupied',
                  context: {
                    'cellIndex': index,
                    'position': {'row': logicalRow, 'col': logicalCol},
                    'reason': 'position_occupied',
                    'levelId': widget.levelId,
                  });
              ref.read(hoveredCellProvider.notifier).state = null;
              return false;
            }
          }

          // Check inventory availability
          if (!interactionEngine.checkInventoryAvailability(data.componentType)) {
            StructuredLogger.warning(
                '🎯 DRAG REJECTED - Insufficient Inventory (Early Check)',
                context: {
                  'cellIndex': index,
                  'componentType': data.componentType.toString(),
                  'reason': 'insufficient_inventory',
                  'levelId': widget.levelId,
                });
            ref.read(hoveredCellProvider.notifier).state = null;
            return false;
          }

          ref.read(hoveredCellProvider.notifier).state = index;

          if (enableDragLogging) {
            StructuredLogger.info(
                '🎯 DRAG ACCEPTED - Valid Grid Cell & Inventory Available',
                context: {
                  'cellIndex': index,
                  'cellRow': logicalRow,
                  'cellCol': logicalCol,
                  'componentType': data.componentType.toString(),
                });
          }
          return true;
        } catch (e, stackTrace) {
          StructuredLogger.error('🎯 CRITICAL: Drag Accept Check Failed',
              context: {
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
          const enableDragLogging = bool.fromEnvironment('ENABLE_DRAG_LOGS');
          if (enableDragLogging) {
            StructuredLogger.debug('🎯 DRAG LEAVE - CircuitGrid', context: {
              'cellIndex': index,
              'reason': 'user_abandoned_drop',
              'levelId': widget.levelId,
            });
          }
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
            StructuredLogger.info('🎯 COMPONENT DROP ACCEPTED - CircuitGrid',
                context: {
                  'cellIndex': index,
                  'row': logicalRow,
                  'col': logicalCol,
                  'componentType': details.data.componentType.toString(),
                  'componentName': details.data.componentName,
                  'isOccupied': isOccupied,
                  'withinLevelBounds': logicalRow >= 0 &&
                      logicalRow < gridConfig.cols &&
                      logicalCol >= 0 &&
                      logicalCol < gridConfig.rows,
                  'levelId': widget.levelId,
                  'dragData': {
                    'icon': 'present', // details.data.icon is never null
                    'position_x': logicalCol,
                    'position_y': logicalRow,
                  },
                });
          }

          // Pass viewport parameters to ensure consistent coordinate calculation
          _handleDrop(
            details,
            canvasState,
            gridConfig,
            interactionEngine,
            context,
            cellSize: canvasState.viewportState.gridConfiguration.cellSize,
            scale: canvasState.viewportState.scale,
            panOffset: canvasState.viewportState.panOffset,
            canvasSize: canvasState.viewportState.canvasSize,
            devicePixelRatio: 2,
          );
        } catch (e) {
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
          key: ValueKey('cell_container_${widget.levelId}_${index}_${showHover}_${isOccupied}'), // ✅ OPTIMIZED: Add key
          decoration: BoxDecoration(
            color: showHover
                ? (isOccupied
                    ? Colors.red.withValues(alpha: 0.4)
                    : Colors.green.withValues(alpha: 0.4))
                : Colors.transparent,
            border: Border.all(
              color: showHover
                  ? (isOccupied ? Colors.red : Colors.green)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: showHover
              ? Center(
                  child: Icon(
                    candidateData.first?.icon ?? Icons.help_outline,
                    size: 24,
                    color: isOccupied ? Colors.red : Colors.green,
                  ),
                )
              : const SizedBox.shrink(), // ✅ OPTIMIZED: Use const SizedBox instead of null
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
    // Store context-dependent values before await to avoid async gap issues
    final componentName = details.data.componentName;
    final globalOffset = details.offset;

    // 🎯 DELEGATE TO INTERACTION ENGINE: All business logic centralized with viewport params
    await interactionEngine.handlePaletteDragEnd(
      details.data,
      details.offset,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
      canvasSize: canvasSize,
      devicePixelRatio: devicePixelRatio,
    );

    // 🔧 TODO: Add proper inventory tracking and component placement
    // ISSUE: Inventory never decreases (always shows 10), only RESISTOR works
    final gameState =
        ref.watch(interaction_engine.interactionEngineProvider(widget.levelId));
    final unifiedState = ref.watch(unifiedGameStateProvider);

    if (gameState.grid.components.isNotEmpty) {
      try {
        // 🔧 FIX: Sync on ANY count mismatch, not just when unifiedState is empty
        final syncConditionMet = gameState.grid.components.length !=
            unifiedState.grid.components.length;

        if (syncConditionMet) {
          final unifiedNotifier = ref.read(unifiedGameStateProvider.notifier);

          if (enableStateSyncLogging && isDevelopment) {
            StructuredLogger.info(
                '🔄 STATE SYNCHRONIZATION: Starting sync (progressive fix)',
                context: {
                  'componentCount_interaction':
                      gameState.grid.components.length,
                  'componentCount_unified': unifiedState.grid.components.length,
                  'interaction_componentIds':
                      gameState.grid.components.keys.toList(),
                  'unified_componentIds':
                      unifiedState.grid.components.keys.toList(),
                  'levelId': widget.levelId,
                  'gridDimensions_interaction':
                      '${gameState.grid.rows}x${gameState.grid.cols}',
                  'gridDimensions_unified':
                      '${unifiedState.grid.rows}x${unifiedState.grid.cols}',
                });
          }

          final syncedState = unifiedState.copyWith(
              grid: unifiedState.grid.copyWith(
            components: gameState.grid.components,
            rows: gameState.grid.rows,
            cols: gameState.grid.cols,
          ));

          unifiedNotifier.state = syncedState; // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

          if (enableStateSyncLogging && isDevelopment) {
            StructuredLogger.info('🔄 STATE SYNCHRONIZATION: Completed sync',
                context: {
                  'total_components_after_sync':
                      syncedState.grid.components.length,
                  'component_types': syncedState.grid.components.values
                      .map((c) => c.type.toString())
                      .toList(),
                  'sync_successful': true,
                  'levelId': widget.levelId,
                });
          }
        } else if (enableStateSyncLogging && isDevelopment) {
          StructuredLogger.debug('🔄 STATE SYNCHRONIZATION: No sync needed',
              context: {
                'componentCount_interaction': gameState.grid.components.length,
                'componentCount_unified': unifiedState.grid.components.length,
                'sync_condition_met': syncConditionMet,
                'levelId': widget.levelId,
              });
        }
      } catch (e) {
        StructuredLogger.warning('⚠️ State synchronization update failed',
            context: {
              'error': e.toString(),
              'levelId': widget.levelId,
            });
      }
    }

    // Handle UI feedback based on GameState error field
    if (!mounted) return;

    if (gameState.error != null) {
      _showErrorSnackBar(context, gameState.error!); // ignore: use_build_context_synchronously
    } else {
      // Show success feedback if no error
      final gridRenderBox =
          _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (gridRenderBox == null) return;

      // Use level-specific grid dimensions for coordinate calculation
      final levelGridConfig = GridConfiguration(
        rows: canvasState.currentLevel?.grid.height ?? gridConfig.rows,
        cols: canvasState.currentLevel?.grid.width ?? gridConfig.cols,
        cellSize: gridConfig.cellSize,
      );

      final gridPosition = GridCoordinateService.calculateGridPosition(
        globalPosition: globalOffset,
        gridRenderBox: gridRenderBox,
        viewportState: canvasState.viewportState,
        gridConfig: levelGridConfig,
      );
      if (gridPosition != null) {
        _showSuccessSnackBar(context, // ignore: use_build_context_synchronously
            '$componentName placed at (${gridPosition.row}, ${gridPosition.col})!');
      } else {
        // Reduced logging: only show when coordinate calculation fails
        const enableCoordLogs = bool.fromEnvironment('ENABLE_COORD_LOGS');
        if (enableCoordLogs) {
          StructuredLogger.warning('🎯 COORDINATE CALCULATION FAILED',
              context: {
                'componentName': componentName,
                'globalPosition': globalOffset.toString(),
                'levelGridConfig':
                    '${levelGridConfig.rows}x${levelGridConfig.cols}',
                'levelId': widget.levelId,
              });
        }
      }
    }

    // Clear hover state
    ref.read(hoveredCellProvider.notifier).state = null;
    Future.delayed(const Duration(milliseconds: 100),
        () => ref.read(hoveredCellProvider.notifier).state = null);
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
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    StructuredLogger.error('❌ ERROR FEEDBACK SHOWN', context: {
      'message': message,
      'type': 'error_snackbar',
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
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

// ✅ UNIFIED: GridPainter with centralized logic for all grid rendering
class GridPainter extends CustomPainter {
  final GameCanvasState? canvasState;
  final CircuitColorScheme? circuitColors;
  final int? hoveredCellIndex;
  final dynamic gridConfig;

  // Legacy GridWidget compatibility parameters
  final double? legacyCellSize;
  final Color? legacyGridColor;
  final Color? legacyMajorGridColor;
  final double? legacyStrokeWidth;
  final double? legacyMajorStrokeWidth;
  final int? legacyMajorGridInterval;
  final Offset? legacyOffset;
  final Size? legacyGridSize;
  final bool? legacyShowOrigin;
  final bool? legacyShowCoordinates;

  GridPainter({
    this.canvasState,
    this.circuitColors,
    this.hoveredCellIndex,
    this.gridConfig,
    // Legacy parameters for backward compatibility
    this.legacyCellSize,
    this.legacyGridColor,
    this.legacyMajorGridColor,
    this.legacyStrokeWidth,
    this.legacyMajorStrokeWidth,
    this.legacyMajorGridInterval,
    this.legacyOffset,
    this.legacyGridSize,
    this.legacyShowOrigin,
    this.legacyShowCoordinates,
  });

  @override
  void paint(Canvas canvas, Size size) {
    StructuredLogger.trace('GridPainter painting', context: {
      'canvasSize': '${size.width}x${size.height}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Handle legacy GridWidget mode
    if (canvasState == null) {
      _paintLegacyGrid(canvas, size);
      return;
    }

    // Handle CircuitGrid mode
    final config = canvasState!.viewportState.gridConfiguration;
    final cellSize = config.cellSize * canvasState!.viewportState.scale;
    final panOffset = canvasState!.viewportState.panOffset;

    // Calculate visible bounds with buffer
    final startX =
        ((-panOffset.dx / cellSize).floor() - 1).clamp(0, config.cols);
    final endX = (((size.width - panOffset.dx) / cellSize).ceil() + 1)
        .clamp(0, config.cols);
    final startY =
        ((-panOffset.dy / cellSize).floor() - 1).clamp(0, config.rows);
    final endY = (((size.height - panOffset.dy) / cellSize).ceil() + 1)
        .clamp(0, config.rows);

    final gridPaint = Paint() // ignore: cascade_invocations
      ..color = (circuitColors?.gridLine ?? Colors.grey)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    final majorGridPaint = Paint() // ignore: cascade_invocations
      ..color = (circuitColors?.gridLine ?? Colors.grey).withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    // Clip to canvas bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 🎯 PHASE 2: Draw playable area boundary first (behind grid lines)
    _drawPlayableAreaBoundary(canvas, config, cellSize, panOffset);

    // Draw vertical lines (optimized for visible area only)
    for (var i = startX; i <= endX; i++) {
      final x = (i * cellSize + panOffset.dx).roundToDouble();
      if (x >= -2 && x <= size.width + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(x, -2), Offset(x, size.height + 2), paint);
      }
    }

    // Draw horizontal lines (optimized for visible area only)
    for (var i = startY; i <= endY; i++) {
      final y = (i * cellSize + panOffset.dy).roundToDouble();
      if (y >= -2 && y <= size.height + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(Offset(-2, y), Offset(size.width + 2, y), paint);
      }
    }

    // Draw hover feedback (optimized corner markers)
    if (hoveredCellIndex != null && gridConfig != null) {
      _drawHoverFeedback(canvas, cellSize, panOffset, circuitColors);
      _drawNearBoundaryWarning(canvas, cellSize, panOffset);
      _drawNearnessViolations(canvas, cellSize, panOffset);
    }
  }

  void _drawHoverFeedback(Canvas canvas, double cellSize, Offset panOffset,
      CircuitColorScheme? circuitColors) {
    if (hoveredCellIndex == null || gridConfig == null) return;

    final hoveredRow = hoveredCellIndex! ~/ gridConfig.cols;
    final hoveredCol = hoveredCellIndex! % gridConfig.cols;

    if (hoveredRow < gridConfig.rows && hoveredCol < gridConfig.cols) {
      final hoverX = hoveredCol * cellSize + panOffset.dx;
      final hoverY = hoveredRow * cellSize + panOffset.dy;

      // Subtle hover highlight
      final hoverPaint = Paint() // ignore: cascade_invocations
        ..color =
            (circuitColors?.primary ?? Colors.blue).withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
          Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize), hoverPaint);

      // Corner markers
      final cornerPaint = Paint() // ignore: cascade_invocations
        ..color = (circuitColors?.primary ?? Colors.blue).withValues(alpha: 0.7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final cornerSize = cellSize * 0.2;

      // Draw all four corners
      _drawCorner(canvas, cornerPaint, hoverX, hoverY, cornerSize, true, true);
      _drawCorner(canvas, cornerPaint, hoverX + cellSize, hoverY, cornerSize,
          false, true);
      _drawCorner(canvas, cornerPaint, hoverX, hoverY + cellSize, cornerSize,
          true, false);
      _drawCorner(canvas, cornerPaint, hoverX + cellSize, hoverY + cellSize,
          cornerSize, false, false);
    }
  }

  void _drawCorner(Canvas canvas, Paint paint, double x, double y, double size,
      bool left, bool top) {
    final dx = left ? size : -size;
    final dy = top ? size : -size;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint); // ignore: cascade_invocations
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint); // ignore: cascade_invocations
  }

  /// 🎯 PHASE 2: Draw visual boundary for playable area
  void _drawPlayableAreaBoundary(Canvas canvas, GridConfiguration config,
      double cellSize, Offset panOffset) {
    // Get level-specific playable area dimensions
    final playableRows = canvasState!.currentLevel?.grid.height ?? config.rows;
    final playableCols = canvasState!.currentLevel?.grid.width ?? config.cols;

    // Only draw boundary if playable area is smaller than visual grid
    if (playableRows >= config.rows && playableCols >= config.cols) {
      return; // No boundary needed if they match
    }

    // Calculate playable area rectangle in screen coordinates
    final playableWidth = playableCols * cellSize;
    final playableHeight = playableRows * cellSize;
    final playableRect = Rect.fromLTWH(
      panOffset.dx,
      panOffset.dy,
      playableWidth,
      playableHeight,
    );

    // Draw boundary with distinctive styling
    final boundaryPaint = Paint() // ignore: cascade_invocations
      ..color = (circuitColors?.primary ?? Colors.blue).withValues(alpha: 0.3)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw boundary rectangle
    canvas.drawRect(playableRect, boundaryPaint);

    // Add subtle fill to make playable area more obvious
    final fillPaint = Paint()
      ..color = (circuitColors?.primary ?? Colors.blue).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRect(playableRect, fillPaint);

    // Add corner markers for better visibility
    final cornerPaint = Paint()
      ..color = (circuitColors?.primary ?? Colors.blue).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 12.0;

    // Draw corner markers at playable area boundaries
    _drawCorner(canvas, cornerPaint, playableRect.left, playableRect.top,
        cornerSize, true, true);
    _drawCorner(canvas, cornerPaint, playableRect.right, playableRect.top,
        cornerSize, false, true);
    _drawCorner(canvas, cornerPaint, playableRect.left, playableRect.bottom,
        cornerSize, true, false);
    _drawCorner(canvas, cornerPaint, playableRect.right, playableRect.bottom,
        cornerSize, false, false);

    StructuredLogger.debug('🎯 PLAYABLE AREA BOUNDARY DRAWN', context: {
      'playableArea': '${playableCols}x$playableRows',
      'visualGrid': '${config.cols}x${config.rows}',
      'boundaryRect': playableRect.toString(),
      'boundaryVisible': true,
    });
  }

  /// 🎯 PHASE 2: Draw warning for near-boundary placement
  void _drawNearBoundaryWarning(
      Canvas canvas, double cellSize, Offset panOffset) {
    if (hoveredCellIndex == null || gridConfig == null || canvasState == null) {
      return;
    }

    final hoveredRow = hoveredCellIndex! ~/ gridConfig.cols;
    final hoveredCol = hoveredCellIndex! % gridConfig.cols;

    // Get level-specific playable area dimensions
    final playableRows =
        canvasState!.currentLevel?.grid.height ?? gridConfig.rows;
    final playableCols =
        canvasState!.currentLevel?.grid.width ?? gridConfig.cols;

    // Check if hover position is near boundary (within 1 cell)
    const boundaryThreshold = 1;
    final nearBoundary = hoveredRow < boundaryThreshold ||
        hoveredRow >= playableRows - boundaryThreshold ||
        hoveredCol < boundaryThreshold ||
        hoveredCol >= playableCols - boundaryThreshold;

    if (!nearBoundary) return;

    // Calculate hover cell rectangle
    final hoverX = hoveredCol * cellSize + panOffset.dx;
    final hoverY = hoveredRow * cellSize + panOffset.dy;

    // Draw warning highlight
    final warningPaint = Paint()
      ..color = (circuitColors?.error ?? Colors.red).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize), warningPaint);

    // Draw warning border
    final borderPaint = Paint()
      ..color = (circuitColors?.error ?? Colors.red).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(
        Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize), borderPaint);

    // Add warning icon in center
    final iconPaint = Paint()
      ..color = circuitColors?.error ?? Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = hoverX + cellSize / 2;
    final centerY = hoverY + cellSize / 2;
    final iconSize = cellSize * 0.3;

    // Draw warning triangle
    final path = Path();
    path.moveTo(centerX, centerY - iconSize / 2); // ignore: cascade_invocations
    path.lineTo(centerX - iconSize / 2, centerY + iconSize / 2); // ignore: cascade_invocations
    path.lineTo(centerX + iconSize / 2, centerY + iconSize / 2); // ignore: cascade_invocations
    path.close(); // ignore: cascade_invocations

    canvas.drawPath(path, iconPaint);

    // Draw exclamation mark
    canvas.drawLine(Offset(centerX, centerY - iconSize / 4), // ignore: cascade_invocations
        Offset(centerX, centerY + iconSize / 6), iconPaint);
    canvas.drawCircle(Offset(centerX, centerY + iconSize / 3), 1.5, iconPaint); // ignore: cascade_invocations

    StructuredLogger.debug('🎯 NEAR-BOUNDARY WARNING DISPLAYED', context: {
      'hoveredCell': '$hoveredCol,$hoveredRow',
      'playableArea': '${playableCols}x$playableRows',
      'nearBoundary': true,
      'boundaryThreshold': boundaryThreshold,
    });
  }

  /// Draw nearness violation indicators for component placement
  void _drawNearnessViolations(
      Canvas canvas, double cellSize, Offset panOffset) {
    if (hoveredCellIndex == null || gridConfig == null || canvasState == null) {
      return;
    }

    final hoveredRow = (hoveredCellIndex! ~/ gridConfig.cols).toInt();
    final hoveredCol = (hoveredCellIndex! % gridConfig.cols).toInt();

    // Get existing components from rendering data
    final existingComponents = canvasState!.renderingData.components
        .map((comp) => ComponentModel(
              id: comp.id,
              type: comp.type,
              row: comp.row,
              col: comp.col,
              properties: comp.properties,
            ))
        .toList();

    // Check if this position would violate nearness rules
    final nearnessRule = NearnessRule(
      ruleId: 'hover_check',
      minDistance: 1,
      includeDiagonals: true,
    );

    final wouldViolate = nearnessRule.violatesNearness(
        hoveredRow, hoveredCol, existingComponents);

    if (!wouldViolate) return;

    // Calculate hover cell rectangle
    final hoverX = hoveredCol * cellSize + panOffset.dx;
    final hoverY = hoveredRow * cellSize + panOffset.dy;

    // Draw nearness violation highlight (different from boundary warning)
    final violationPaint = Paint()
      ..color =
          (circuitColors?.tertiary ?? Colors.orange).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize), violationPaint);

    // Draw violation border
    final borderPaint = Paint()
      ..color =
          (circuitColors?.tertiary ?? Colors.orange).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(
        Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize), borderPaint);

    // Add distance indicator icon
    final iconPaint = Paint()
      ..color = circuitColors?.tertiary ?? Colors.orange
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = hoverX + cellSize / 2;
    final centerY = hoverY + cellSize / 2;
    final iconSize = cellSize * 0.25;

    // Draw distance circles to show minimum distance requirement
    for (var i = 1; i <= 2; i++) {
      final radius = iconSize * i * 0.5;
      canvas.drawCircle(Offset(centerX, centerY), radius, iconPaint);
    }

    StructuredLogger.debug('📏 NEARNESS VIOLATION INDICATED', context: {
      'hoveredCell': '$hoveredCol,$hoveredRow',
      'existingComponents': existingComponents.length,
      'minDistance': 1,
      'wouldViolate': true,
    });
  }

  /// Legacy grid painting for backward compatibility with GridWidget
  void _paintLegacyGrid(Canvas canvas, Size size) {
    final cellSize = legacyCellSize ?? 60.0;
    final gridColor = legacyGridColor ?? Colors.grey;
    final majorGridColor = legacyMajorGridColor ?? Colors.green;
    final strokeWidth = legacyStrokeWidth ?? 0.5;
    final majorStrokeWidth = legacyMajorStrokeWidth ?? 1.0;
    final majorGridInterval = legacyMajorGridInterval ?? 5;
    final offset = legacyOffset ?? Offset.zero;
    final gridSize = legacyGridSize ?? const Size(50, 50);
    final showOrigin = legacyShowOrigin ?? true;
    final showCoordinates = legacyShowCoordinates ?? false;

    _drawLegacyGrid(canvas, size, cellSize, gridColor, majorGridColor,
        strokeWidth, majorStrokeWidth, majorGridInterval, offset, gridSize);

    if (showOrigin) {
      _drawLegacyOrigin(canvas, size, offset);
    }

    if (showCoordinates) {
      _drawLegacyCoordinates(canvas, size, cellSize, gridColor,
          majorGridInterval, offset, gridSize);
    }
  }

  void _drawLegacyGrid(
      Canvas canvas,
      Size size,
      double cellSize,
      Color gridColor,
      Color majorGridColor,
      double strokeWidth,
      double majorStrokeWidth,
      int majorGridInterval,
      Offset offset,
      Size gridSize) {
    final regularPaint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final majorPaint = Paint()
      ..color = majorGridColor
      ..strokeWidth = majorStrokeWidth
      ..style = PaintingStyle.stroke;

    // Calculate visible range
    final startX = math.max(0, (-offset.dx / cellSize).floor());
    final endX = math.min(
        gridSize.width.toInt(), ((size.width - offset.dx) / cellSize).ceil());
    final startY = math.max(0, (-offset.dy / cellSize).floor());
    final endY = math.min(
        gridSize.height.toInt(), ((size.height - offset.dy) / cellSize).ceil());

    // Draw vertical lines
    for (var i = startX; i <= endX; i++) {
      final x = i * cellSize + offset.dx;
      if (x >= -strokeWidth && x <= size.width + strokeWidth) {
        final paint = (i % majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw horizontal lines
    for (var i = startY; i <= endY; i++) {
      final y = i * cellSize + offset.dy;
      if (y >= -strokeWidth && y <= size.height + strokeWidth) {
        final paint = (i % majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  void _drawLegacyOrigin(Canvas canvas, Size size, Offset offset) {
    final originX = offset.dx;
    final originY = offset.dy;

    // Only draw if origin is visible
    if (originX >= -20 &&
        originX <= size.width + 20 &&
        originY >= -20 &&
        originY <= size.height + 20) {
      final originPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final originCenter = Paint()
        ..color = Colors.red.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      // Draw origin point
      canvas.drawCircle(Offset(originX, originY), 4, originCenter); // ignore: cascade_invocations
      canvas.drawCircle(Offset(originX, originY), 4, originPaint); // ignore: cascade_invocations

      // Draw axes indicators
      const axisLength = 15.0;
      canvas.drawLine( // ignore: cascade_invocations
        Offset(originX - axisLength, originY),
        Offset(originX + axisLength, originY),
        originPaint,
      );
      canvas.drawLine( // ignore: cascade_invocations
        Offset(originX, originY - axisLength),
        Offset(originX, originY + axisLength),
        originPaint,
      );
    }
  }

  void _drawLegacyCoordinates(Canvas canvas, Size size, double cellSize,
      Color gridColor, int majorGridInterval, Offset offset, Size gridSize) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate visible major grid lines for coordinate display
    final startX = math.max(
        0,
        (-offset.dx / cellSize / majorGridInterval).floor() *
            majorGridInterval);
    final endX = math.min(
      gridSize.width.toInt(),
      ((size.width - offset.dx) / cellSize / majorGridInterval).ceil() *
          majorGridInterval,
    );
    final startY = math.max(
        0,
        (-offset.dy / cellSize / majorGridInterval).floor() *
            majorGridInterval);
    final endY = math.min(
      gridSize.height.toInt(),
      ((size.height - offset.dy) / cellSize / majorGridInterval).ceil() *
          majorGridInterval,
    );

    // Draw X coordinates
    for (var i = startX; i <= endX; i += majorGridInterval) {
      if (i == 0) continue; // Skip origin

      final x = i * cellSize + offset.dx;
      if (x >= 20 && x <= size.width - 20) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: gridColor.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout(); // ignore: cascade_invocations

        // Draw background
        final bgRect = Rect.fromCenter(
          center: Offset(x, 15),
          width: textPainter.width + 6,
          height: textPainter.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );

        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, 15 - textPainter.height / 2),
        );
      }
    }

    // Draw Y coordinates
    for (var i = startY; i <= endY; i += majorGridInterval) {
      if (i == 0) continue; // Skip origin

      final y = i * cellSize + offset.dy;
      if (y >= 20 && y <= size.height - 20) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: gridColor.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout(); // ignore: cascade_invocations

        // Draw background
        final bgRect = Rect.fromCenter(
          center: Offset(15, y),
          width: textPainter.width + 6,
          height: textPainter.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );

        textPainter.paint(
          canvas,
          Offset(15 - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    // Draw origin coordinate
    final originX = offset.dx;
    final originY = offset.dy;
    if (originX >= 10 &&
        originX <= size.width - 30 &&
        originY >= 10 &&
        originY <= size.height - 30) {
      textPainter.text = const TextSpan(
        text: '(0,0)',
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(); // ignore: cascade_invocations

      final bgRect = Rect.fromCenter(
        center: Offset(originX + 15, originY - 15),
        width: textPainter.width + 6,
        height: textPainter.height + 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );

      textPainter.paint(
        canvas,
        Offset(
          originX + 15 - textPainter.width / 2,
          originY - 15 - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    // Handle legacy mode comparison
    if (canvasState == null && oldDelegate.canvasState == null) {
      return oldDelegate.legacyCellSize != legacyCellSize ||
          oldDelegate.legacyGridColor != legacyGridColor ||
          oldDelegate.legacyMajorGridColor != legacyMajorGridColor ||
          oldDelegate.legacyStrokeWidth != legacyStrokeWidth ||
          oldDelegate.legacyMajorStrokeWidth != legacyMajorStrokeWidth ||
          oldDelegate.legacyMajorGridInterval != legacyMajorGridInterval ||
          oldDelegate.legacyOffset != legacyOffset ||
          oldDelegate.legacyGridSize != legacyGridSize ||
          oldDelegate.legacyShowOrigin != legacyShowOrigin ||
          oldDelegate.legacyShowCoordinates != legacyShowCoordinates;
    }

    // Handle CircuitGrid mode comparison
    if (canvasState != null && oldDelegate.canvasState != null) {
      return oldDelegate.canvasState!.viewportState !=
              canvasState!.viewportState ||
          oldDelegate.circuitColors != circuitColors ||
          oldDelegate.hoveredCellIndex != hoveredCellIndex;
    }

    // Different modes - always repaint
    return true;
  }
}

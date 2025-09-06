import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import '../../../../application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;

import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/features/game/painters/circuit_components_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/component_context_menu.dart';
import 'package:sparkcircuit/presentation/core/utils/feedback_utils.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';


class GameCanvas extends ConsumerStatefulWidget {
  final String levelId;

  const GameCanvas({super.key, required this.levelId});

  @override
  ConsumerState<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas>
    with TickerProviderStateMixin {
  late GameCanvasController _canvasController;
  String? _draggedComponentType;
  Offset? _dragPosition;
  Offset? _mousePosition;
  LevelDefinition? _levelDefinition;

  // Wire connection state
  final bool _isDrawingWire = false;
  Offset? _wireStartPosition;
  Offset? _wireEndPosition;

  // Pan state management
  bool _isDraggingComponent = false;
  bool _isPanningCanvas = false;

  // Context menu state
  bool _isContextMenuVisible = false;
  Offset? _contextMenuPosition;
  String? _contextMenuComponentId;

  @override
  void initState() {
    super.initState();
    _canvasController = GameCanvasController();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    StructuredLogger.info('GameCanvas: Starting level load process', context: {
      'levelId': widget.levelId,
      'canvasController': _canvasController.toString(),
    });

    try {
      final levelService = ref.read(core_providers.levelServiceProvider);
      StructuredLogger.debug('GameCanvas: Retrieved level service', context: {
        'levelService': levelService.toString(),
      });

      final level = await levelService.loadLevel(widget.levelId);
      StructuredLogger.info('GameCanvas: Level service returned result', context: {
        'levelId': widget.levelId,
        'levelLoaded': level != null,
        'levelType': level?.runtimeType.toString(),
      });

      if (level != null) {
        StructuredLogger.info('GameCanvas: Level data received', context: {
          'levelId': level.levelId,
          'levelTitle': level.metadata.title,
          'gridSize': '${level.grid.width}x${level.grid.height}',
          'componentCount': level.components.available.length,
          'tutorialEnabled': level.tutorial?.enabled,
          'scoringAvailable': level.scoring != null,
        });

        setState(() {
          _levelDefinition = level;
        });

        // Update canvas controller with level's grid dimensions
        _canvasController.updateGridSize(level.grid.width, level.grid.height);
        StructuredLogger.debug('GameCanvas: Canvas controller updated', context: {
          'gridWidth': level.grid.width,
          'gridHeight': level.grid.height,
        });

        // Center the grid after the next frame when canvas size is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Wait for another frame to ensure canvas size is updated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _canvasController.centerGrid();
            StructuredLogger.debug('GameCanvas: Grid centered');
          });
        });

        // Initialize game state with the loaded level
        StructuredLogger.debug('GameCanvas: Initializing game state with level data');
        debugPrint('🎨 ===== LEVEL LOAD DEBUG =====');
        debugPrint('🎨 Level tutorial config:');
        debugPrint('🎨   - Tutorial enabled: ${level.tutorial?.enabled}');
        debugPrint('🎨   - Level components count: ${level.components.available.length}');
        debugPrint('🎨 ===== END LEVEL LOAD DEBUG =====');
        ref.read(enhancedGameStateNotifierProvider.notifier).loadLevel(level);

        StructuredLogger.info('GameCanvas: Level load process completed successfully', context: {
          'levelId': level.levelId,
          'levelTitle': level.metadata.title,
        });
      } else {
        StructuredLogger.warning('GameCanvas: Level not found, using default grid', context: {
          'levelId': widget.levelId,
        });
      }
    } catch (e) {
      StructuredLogger.error('GameCanvas: Error loading level', context: {
        'levelId': widget.levelId,
        'errorType': e.runtimeType.toString(),
        'errorMessage': e.toString(),
      }, error: e);
    }
  }

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>() ?? _getDefaultCircuitColors();
    final gameState = ref.watch(enhancedGameStateNotifierProvider);
    final paletteState = ref.watch(paletteStateProvider(widget.levelId));

    // If we have a loaded level but the game state doesn't have it, initialize with level
    if (_levelDefinition != null && gameState.currentLevel == null) {
      StructuredLogger.info('GameCanvas: Level data available but game state not initialized', context: {
        'levelId': _levelDefinition!.levelId,
        'levelTitle': _levelDefinition!.metadata.title,
        'gameStateLevel': gameState.currentLevel,
        'gridComponents': gameState.grid.components.length,
        'gridConnections': gameState.grid.connections.length,
      });

      // Initialize game state with the loaded level
      WidgetsBinding.instance.addPostFrameCallback((_) {
        StructuredLogger.debug('GameCanvas: Attempting to initialize game state with level data');
        // Note: Level initialization will be handled by the game engine
        // The level data is available for use in the build method
      });
    } else if (_levelDefinition != null) {
      StructuredLogger.debug('GameCanvas: Level data and game state both available', context: {
        'levelId': _levelDefinition!.levelId,
        'gameStateLevel': gameState.currentLevel,
        'gridComponents': gameState.grid.components.length,
        'gridConnections': gameState.grid.connections.length,
      });
    } else {
      StructuredLogger.debug('GameCanvas: No level data loaded yet', context: {
        'levelId': widget.levelId,
        'gameStateLevel': gameState.currentLevel,
      });
    }

    // Convert ComponentModel to CircuitComponent for painter
    final List<CircuitComponent> circuitComponents = gameState.grid.components.values
        .map((c) => CircuitComponent.fromComponentModel(c))
        .toList()
        .cast<CircuitComponent>();

    debugPrint('🎨 Build: Converting components for painter');
    debugPrint('🎨 Build: Game state components count: ${gameState.grid.components.length}');
    debugPrint('🎨 Build: Circuit components count: ${circuitComponents.length}');

    // 🔍 DEBUG: Comprehensive build-time component tracking
    debugPrint('🎨 📊 BUILD-TIME COMPONENT TRACKING:');
    debugPrint('🎨   - Grid dimensions: ${gameState.grid.rows}x${gameState.grid.cols}');

    if (gameState.grid.components.isNotEmpty) {
      debugPrint('🎨 🗺️ CURRENT GRID COMPONENT MAP (Row,Col:Type):');
      gameState.grid.components.forEach((id, component) {
        final side = (component.col < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
        debugPrint('🎨   - $id: ${component.type.toString().split('.').last} at (${component.row},${component.col}) [$side]');
      });

      // 🔍 DEBUG: Grid occupancy analysis
      debugPrint('🎨 📈 GRID OCCUPANCY ANALYSIS:');
      final totalCells = gameState.grid.rows * gameState.grid.cols;
      final occupiedCells = gameState.grid.components.length;
      final occupancyPercent = (occupiedCells / totalCells * 100).round();
      debugPrint('🎨   - Total grid cells: $totalCells');
      debugPrint('🎨   - Occupied cells: $occupiedCells');
      debugPrint('🎨   - Grid occupancy: ${occupancyPercent}%');

    } else {
      debugPrint('🎨 📭 GRID IS EMPTY');
    }

    // Convert Grid connections to CircuitWire for painter
    final List<drawing_models.CircuitWire> circuitWires = [];
    gameState.grid.connections.forEach((sourceId, connectedIds) {
      final sourceComponent = gameState.grid.getComponentById(sourceId);
      if (sourceComponent != null) {
        for (final targetId in connectedIds) {
          final targetComponent = gameState.grid.getComponentById(targetId);
          if (targetComponent != null) {
            // Ensure each wire is added only once (e.g., A-B, not B-A)
            if (sourceId.hashCode < targetId.hashCode) {
              circuitWires.add(drawing_models.CircuitWire(
                id: '\${sourceId}_\${targetId}',
                startX: sourceComponent.col.toDouble(),
                startY: sourceComponent.row.toDouble(),
                endX: targetComponent.col.toDouble(),
                endY: targetComponent.row.toDouble(),
                isActive: false, // TODO: Determine active state from simulationResult
              ));
            }
          }
        }
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: circuitColors.surface,
        border: Border.all(
          color: circuitColors.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DragTarget<ComponentDragData>(
          onAcceptWithDetails: (details) {
            // Get the RenderBox to convert global coordinates to local coordinates
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.offset);

            debugPrint('🎯 ===== CANVAS DRAG ACCEPTED =====');
            debugPrint('🎯 Global Position: ${details.offset}');
            debugPrint('🎯 Local Position: $localPosition');
            debugPrint('🎯 Component: ${details.data.componentName} (${details.data.componentType})');
            debugPrint('🎯 Cost: ${details.data.cost}');
            debugPrint('🎯 Component properties: ${details.data.defaultProperties}');

            // 🔍 DEBUG: Comprehensive Pre-placement state verification
            debugPrint('🎯 📊 PRE-PLACEMENT STATE VERIFICATION:');
            debugPrint('🎯   - Total components in grid: ${gameState.grid.components.length}');
            final componentTypeString = details.data.componentType.toString().split('.').last;
            debugPrint('🎯   - Palette inventory before drop: ${paletteState.inventory[componentTypeString]?.available ?? 0}');

            // 🔍 DEBUG: Detailed grid occupancy map
            debugPrint('🎯 📍 CURRENT GRID OCCUPANCY (Row,Col:Type):');
            if (gameState.grid.components.isEmpty) {
              debugPrint('🎯     [EMPTY GRID]');
            } else {
              gameState.grid.components.forEach((id, component) {
                final rightLeft = (component.col < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
                debugPrint('🎯     (${component.row},${component.col}):${component.type.toString().split('.').last} [$rightLeft]');
              });
            }

            // 🔍 DEBUG: Requested drop position analysis
            debugPrint('🎯 🎯 REQUESTED DROP POSITION ANALYSIS:');
            final coordService = _canvasController.coordinateService;
            final requestedGridPos = coordService.screenToGrid(localPosition);
            final snappedGridPos = Offset(requestedGridPos.dx.round().toDouble(), requestedGridPos.dy.round().toDouble());
            final rightLeft = (snappedGridPos.dx < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
            debugPrint('🎯   - Requested local position: $localPosition');
            debugPrint('🎯   - Converted grid position: $snappedGridPos');
            debugPrint('🎯   - Position side: $rightLeft side of grid');
            debugPrint('🎯   - Grid bounds: ${gameState.grid.rows}x${gameState.grid.cols}');

            // 🔍 DEBUG: Position validity check
            final isValidDrop = snappedGridPos.dx >= 0 && snappedGridPos.dx < gameState.grid.cols &&
                               snappedGridPos.dy >= 0 && snappedGridPos.dy < gameState.grid.rows;
            debugPrint('🎯   - Is requested position valid: $isValidDrop');

            // Process the component drop directly instead of recursive call
            debugPrint('🎯 🔄 PROCEEDING TO COMPONENT DROP...');
            _processComponentDrop(details, localPosition, gameState, paletteState);
          },
          onWillAcceptWithDetails: (details) {
            // Get the RenderBox to convert global coordinates to local coordinates
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.offset);

            debugPrint('🎯 ===== CANVAS DRAG WILL ACCEPT =====');
            debugPrint('🎯 Component: ${details.data.componentName} (${details.data.componentType})');
            debugPrint('🎯 Global Position: ${details.offset}');
            debugPrint('🎯 Local Position: $localPosition');
            debugPrint('🎯 Grid bounds: ${gameState.grid.rows}x${gameState.grid.cols}');

            final canAccept = _canAcceptComponentDrop(details, gameState);
            debugPrint('🎯 Can accept: $canAccept');

            if (!canAccept) {
              debugPrint('🎯 ❌ Drag rejected - checking detailed reasons...');
            } else {
              debugPrint('🎯 ✅ Drag accepted - proceeding with validation');
            }

            return canAccept;
          },
          onMove: (details) {
            // Get the RenderBox to convert global coordinates to local coordinates
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.offset);

            debugPrint('🎯 DRAG MOVE - Global: ${details.offset}, Local: $localPosition, Component: ${details.data.componentName}');
            StructuredLogger.trace('Drag move detected', context: {
              'globalPosition': details.offset.toString(),
              'localPosition': localPosition.toString(),
              'componentName': details.data.componentName,
              'componentType': details.data.componentType.toString(),
            });
          },
          onLeave: (details) {
            debugPrint('🎯 DRAG LEAVE - Drag left the target area');
            StructuredLogger.debug('Drag leave detected');
          },
          builder: (context, candidateData, rejectedData) {
            if (candidateData.isNotEmpty) {
              StructuredLogger.debug('Candidate drag data available', context: {
                'componentName': candidateData.first!.componentName,
                'componentType': candidateData.first!.componentType.toString(),
                'dataCount': candidateData.length,
              });
            }
            return MouseRegion(
              onHover: (event) {
                setState(() {
                  _mousePosition = event.localPosition;
                });
                debugPrint('🖱️ MOUSE POSITION: ${event.localPosition} -> Grid: (${(event.localPosition.dx / 60).floor()}, ${(event.localPosition.dy / 60).floor()})');
              },
              onExit: (event) {
                setState(() {
                  _mousePosition = null;
                });
              },
              child: Stack(
                children: [
                  // Grid background
                  Positioned.fill(
                    child: CircuitGrid(
                      controller: _canvasController,
                      levelId: widget.levelId,
                    ),
                  ),

                  // Drop zone highlight
                  if (candidateData.isNotEmpty)
                    Positioned.fill(
                      child: _buildDropZoneHighlight(circuitColors, candidateData.first!, gameState),
                    ),

                  // Components and connections display
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: CircuitComponentsPainter(
                          components: circuitComponents,
                          wires: circuitWires,
                          circuitColors: circuitColors,
                          selectedComponentId: gameState.interactionState.selectedComponentId,
                          coordinateService: _canvasController.coordinateService,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),

                  // Interaction layer
                  Positioned.fill(
                    child: _buildInteractionLayer(gameState, paletteState, circuitColors),
                  ),

                  // Drag preview
                  if (_draggedComponentType != null && _dragPosition != null)
                    Positioned(
                      left: _dragPosition!.dx - 25,
                      top: _dragPosition!.dy - 25,
                      child: _buildDragPreview(_draggedComponentType!, circuitColors),
                    ),

                  // Wire drawing overlay
                  if (_isDrawingWire && _wireStartPosition != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WireDrawingPainter(
                          startPosition: _wireStartPosition,
                          endPosition: _wireEndPosition,
                          circuitColors: circuitColors,
                        ),
                      ),
                    ),

                  // Render actual component widgets for interaction
                  ...gameState.grid.components.values.map((component) => CircuitComponentWidget(component: component)),

                  // Context menu overlay
                  if (_isContextMenuVisible && _contextMenuPosition != null && _contextMenuComponentId != null)
                    ComponentContextMenu(
                      componentId: _contextMenuComponentId!,
                      position: _contextMenuPosition!,
                      onDismiss: _hideComponentContextMenu,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInteractionLayer(
    GameState gameState,
    PaletteState paletteState,
    CircuitColorScheme circuitColors,
  ) {
    // If drawing wire, use wire-specific gesture handling
    if (_isDrawingWire) {
      return CustomPaint(
        painter: WireDrawingPainter(
          startPosition: _wireStartPosition,
          endPosition: _wireEndPosition,
          circuitColors: circuitColors,
        ),
      );
    }

    // Check if a palette drag is active
    final isPaletteDragActive = ref.watch(core_providers.paletteDragActiveProvider);

    return IgnorePointer(
      ignoring: isPaletteDragActive,
      child: GestureDetector(
        onTapDown: (details) {
          // Dismiss context menu if visible
          if (_isContextMenuVisible) {
            _hideComponentContextMenu();
            return;
          }
          _handleTapDown(details, gameState);
        },
        onLongPressStart: (details) => _handleLongPressStart(details, gameState),
        // Use only scale gestures to avoid pan/scale conflict
        // Scale gestures handle both single-touch (pan) and multi-touch (zoom/pan) scenarios
        onScaleStart: (details) => _handleScaleStart(details),
        onScaleUpdate: (details) => _handleUnifiedGestureUpdate(details, gameState, paletteState),
        onScaleEnd: (details) => _handleScaleEnd(details, gameState, paletteState),
        child: Container(
          color: Colors.transparent,
          child: paletteState.isPlacingComponent
              ? _buildPlacementOverlay(paletteState, circuitColors)
              : null,
        ),
      ),
    );
  }

  Widget _buildPlacementOverlay(
    PaletteState paletteState,
    CircuitColorScheme circuitColors,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: circuitColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: circuitColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to place ${paletteState.placingComponentType}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: circuitColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZoneHighlight(CircuitColorScheme circuitColors, ComponentDragData dragData, GameState gameState) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: circuitColors.primary.withValues(alpha: 0.8),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: circuitColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Debug overlay at the top of stack
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🐛 Debug Info',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  if (_mousePosition != null) ...[
                    Text(
                      'Mouse: (${_mousePosition!.dx.toStringAsFixed(1)}, ${_mousePosition!.dy.toStringAsFixed(1)})',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                    ),
                    Text(
                      'Grid: (${(_mousePosition!.dx / 60).floor()}, ${(_mousePosition!.dy / 60).floor()})',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Background overlay to make drop zones more visible
          Container(
            color: circuitColors.primary.withValues(alpha: 0.1),
          ),
          CustomPaint(
            painter: DropZoneHighlightPainter(
              circuitColors: circuitColors,
              dragData: dragData,
              gameState: gameState,
              canvasController: _canvasController,
            ),
            size: Size.infinite,
          ),
          // Add instruction text overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: circuitColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: circuitColors.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Drop ${dragData.componentName} on a highlighted grid cell',
                style: TextStyle(
                  color: circuitColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragPreview(String componentType, CircuitColorScheme circuitColors) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: circuitColors.primary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: circuitColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: circuitColors.shadow.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: _getComponentIcon(componentType, circuitColors.onPrimary),
      ),
    );
  }

  Icon _getComponentIcon(String componentType, Color color) {
    switch (componentType) {
      case 'battery':
        return Icon(Icons.battery_full, color: color, size: 24);
      case 'resistor':
        return Icon(Icons.linear_scale, color: color, size: 24);
      case 'led':
        return Icon(Icons.lightbulb, color: color, size: 24);
      case 'wire':
        return Icon(Icons.horizontal_rule, color: color, size: 24);
      case 'switch':
        return Icon(Icons.power, color: color, size: 24);
      case 'capacitor':
        return Icon(Icons.battery_charging_full, color: color, size: 24);
      case 'inductor':
        return Icon(Icons.settings_ethernet, color: color, size: 24);
      default:
        return Icon(Icons.electrical_services, color: color, size: 24);
    }
  }




  void _handleTapDown(TapDownDetails details, GameState gameState) {
    StructuredLogger.debug('Tap detected on canvas', context: {
      'position': details.localPosition.toString(),
    });

    // Check if we're in placement mode first
    final paletteState = ref.read(paletteStateProvider(widget.levelId));
    if (paletteState.isPlacingComponent && paletteState.placingComponentType != null) {
      StructuredLogger.info('Component placement mode active', context: {
        'componentType': paletteState.placingComponentType,
      });
      _placeComponent(paletteState.placingComponentType!, details.localPosition, gameState, paletteState);
      return;
    }

    final gridPos = _canvasController.screenToGrid(details.localPosition);
    final snappedGridPos = Offset(gridPos.dx.round().toDouble(), gridPos.dy.round().toDouble());
    final component = _getComponentAtPosition(snappedGridPos, gameState);
    if (component != null) {
      StructuredLogger.info('Component tapped', context: {
        'componentId': component.id,
        'componentType': component.type.toString(),
        'gridPosition': '${component.row}, ${component.col}',
      });

      // Check if this component is already selected
      final isCurrentlySelected = gameState.interactionState.selectedComponentId == component.id;

      if (isCurrentlySelected) {
        StructuredLogger.debug('Component already selected, keeping selection', context: {
          'componentId': component.id,
        });
        // Component is already selected, keep it selected for context menu
      } else {
        // Select the new component
        ref.read(enhancedGameStateNotifierProvider.notifier).selectComponent(component.id);
        StructuredLogger.debug('Component selected', context: {
          'componentId': component.id,
        });
      }

      // Provide haptic feedback for component selection
      FeedbackUtils.provideHapticFeedback(FeedbackType.selection);
    } else {
      StructuredLogger.debug('Tap on empty space', context: {
        'hadSelection': gameState.interactionState.selectedComponentId != null,
      });
      // Only deselect if there was a selection
      if (gameState.interactionState.selectedComponentId != null) {
        ref.read(enhancedGameStateNotifierProvider.notifier).selectComponent(null);
        FeedbackUtils.provideHapticFeedback(FeedbackType.light);
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    debugPrint('🔄 ===== SCALE START =====');
    debugPrint('🔄 Pointer count: ${details.pointerCount}');
    debugPrint('🔄 Local focal point: ${details.localFocalPoint}');

    _canvasController.startScale();

    // Initialize pan state for single-touch gestures
    if (details.pointerCount == 1) {
      final localPosition = details.localFocalPoint;
      debugPrint('🔄 Single touch detected at: $localPosition');

      // Check if starting drag from an existing component
      final gridPos = _canvasController.screenToGrid(localPosition);
      final snappedGridPos = Offset(gridPos.dx.round().toDouble(), gridPos.dy.round().toDouble());

      debugPrint('🔄 Screen to grid conversion:');
      debugPrint('🔄   - Screen pos: $localPosition');
      debugPrint('🔄   - Grid pos: $gridPos');
      debugPrint('🔄   - Snapped grid pos: $snappedGridPos');

      final currentGameState = ref.read(enhancedGameStateNotifierProvider);
      ComponentModel? component = _getComponentAtPosition(snappedGridPos, currentGameState);

      // If no component at exact position, search nearby (within 1 cell radius)
      if (component == null) {
        debugPrint('🔄 Searching nearby positions for component...');
        const int searchRadius = 1;
        for (int rowOffset = -searchRadius; rowOffset <= searchRadius; rowOffset++) {
          for (int colOffset = -searchRadius; colOffset <= searchRadius; colOffset++) {
            if (rowOffset == 0 && colOffset == 0) continue; // Skip exact position

            final searchGridPos = Offset(
              snappedGridPos.dx + colOffset,
              snappedGridPos.dy + rowOffset
            );

            // Check bounds
            if (searchGridPos.dx >= 0 && searchGridPos.dx < currentGameState.grid.cols &&
                searchGridPos.dy >= 0 && searchGridPos.dy < currentGameState.grid.rows) {
              debugPrint('🔄 Checking nearby position (${searchGridPos.dy.toInt()}, ${searchGridPos.dx.toInt()})');
              component = _getComponentAtPosition(searchGridPos, currentGameState);
              if (component != null) {
                debugPrint('🔄 ✅ FOUND COMPONENT NEARBY at (${searchGridPos.dy.toInt()}, ${searchGridPos.dx.toInt()})');
                break;
              }
            }
          }
          if (component != null) break;
        }
      }

      if (component != null) {
        debugPrint('🔄 ✅ FOUND COMPONENT TO DRAG!');
        debugPrint('🔄   - Component ID: ${component.id}');
        debugPrint('🔄   - Component type: ${component.type}');
        debugPrint('🔄   - Component position: (${component.row}, ${component.col})');

        // Start dragging existing component
        _isDraggingComponent = true;
        _isPanningCanvas = false;
        ref.read(enhancedGameStateNotifierProvider.notifier).startDragging(component!.id, localPosition);
        setState(() {
        _draggedComponentType = component!.type.toString();
          _dragPosition = localPosition;
        });
        debugPrint('🔄 Component drag state initialized successfully');
        return;
      } else {
        debugPrint('🔄 ❌ NO COMPONENT FOUND AT POSITION!');
        debugPrint('🔄 Available components:');
        currentGameState.grid.components.forEach((id, comp) {
          debugPrint('🔄   - $id: ${comp.type} at (${comp.row}, ${comp.col})');
        });
      }

      // Starting pan on empty canvas
      debugPrint('🔄 Starting canvas pan (no component found)');
      _isDraggingComponent = false;
      _isPanningCanvas = true;

      // Check if placing a new component
      final paletteState = ref.read(paletteStateProvider(widget.levelId));
      if (paletteState.selectedComponentType != null) {
        setState(() {
          _draggedComponentType = paletteState.selectedComponentType;
          _dragPosition = localPosition;
        });
        debugPrint('🔄 Palette drag initiated: ${paletteState.selectedComponentType}');
      }
    }
    debugPrint('🔄 ===== SCALE START END =====');
  }

  void _handleUnifiedGestureUpdate(ScaleUpdateDetails details, GameState gameState, PaletteState paletteState) {
    if (details.pointerCount > 1) {
      // Multi-touch: handle scaling and panning
      _canvasController.updateScale(details.scale);
      _canvasController.updatePan(details.focalPointDelta);
    } else {
      // Single-touch: handle as pan gesture for component interaction
      _handleSingleTouchGesture(details, gameState, paletteState);
    }
  }

  void _handleSingleTouchGesture(ScaleUpdateDetails details, GameState gameState, PaletteState paletteState) {
    // Convert scale update to pan update for single-touch gestures
    final delta = details.focalPointDelta;

    debugPrint('🖱️ ===== SINGLE TOUCH GESTURE =====');
    debugPrint('🖱️ Local focal point: ${details.localFocalPoint}');
    debugPrint('🖱️ Delta: $delta');
    debugPrint('🖱️ Is dragging component: $_isDraggingComponent');
    debugPrint('🖱️ Is panning canvas: $_isPanningCanvas');
    debugPrint('🖱️ Dragged component type: $_draggedComponentType');
    debugPrint('🖱️ Game state dragged ID: ${gameState.interactionState.draggedComponentId}');

    if (_isDraggingComponent && _draggedComponentType != null) {
      debugPrint('🖱️ ✅ DRAGGING COMPONENT MODE');
      // Update drag preview position
      setState(() {
        _dragPosition = details.localFocalPoint;
      });

      // If dragging an existing component, update its position in real-time
      if (gameState.interactionState.draggedComponentId != null) {
        debugPrint('🖱️ MOVING EXISTING COMPONENT');
        final gridPosition = _canvasController.screenToGrid(details.localFocalPoint);
        final snappedPosition = Offset(
          gridPosition.dx.round().toDouble(),
          gridPosition.dy.round().toDouble(),
        );

        debugPrint('🖱️ Coordinate conversion:');
        debugPrint('🖱️   - Screen: ${details.localFocalPoint}');
        debugPrint('🖱️   - Grid: $gridPosition');
        debugPrint('🖱️   - Snapped: $snappedPosition');
        // Get the current component being dragged to check its position
        final currentComponent = gameState.grid.getComponentById(gameState.interactionState.draggedComponentId!);
        debugPrint('🖱️   - Current component position: (${currentComponent?.row ?? 'unknown'}, ${currentComponent?.col ?? 'unknown'})');

        // Verify the component exists at current position
        debugPrint('🖱️   - Current component: ${currentComponent?.id ?? 'unknown'}');
        debugPrint('🖱️   - Current position: (${currentComponent?.row ?? 'unknown'}, ${currentComponent?.col ?? 'unknown'})');

        // FIXED: Use correct row/column ordering for moveComponent
        // moveComponent expects (componentId, row, col) - not (id, col, row)
        final newRow = snappedPosition.dy.toInt();
        final newCol = snappedPosition.dx.toInt();
        debugPrint('🖱️   - MOVING component ${gameState.interactionState.draggedComponentId} to ROW:$newRow, COL:$newCol');

        // Move component to new position - ensure proper row/col order
        if (newRow != currentComponent?.row || newCol != currentComponent?.col) {
          ref.read(enhancedGameStateNotifierProvider.notifier).moveComponent(
            gameState.interactionState.draggedComponentId!,
            newRow, // row
            newCol, // col
          );
          debugPrint('🖱️ ✅ Component move request sent to game state');
        } else {
          debugPrint('🖱️ ⚠️ Component already at target position, skipping move');
        }
      } else {
        debugPrint('🖱️ ❌ No dragged component ID found');
      }
    } else if (_isPanningCanvas) {
      debugPrint('🖱️ CANVAS PANNING MODE');
      // Handle canvas panning
      _canvasController.updatePan(delta);
    } else {
      debugPrint('🖱️ UNKNOWN STATE - not dragging or panning');
    }
    debugPrint('🖱️ ===== GESTURE END =====');
  }

  void _handleScaleEnd(ScaleEndDetails details, GameState gameState, PaletteState paletteState) {
    _canvasController.endScale();

    // Handle end of single-touch gestures (component placement/dropping)
    if (details.pointerCount == 1) {
      if (_isDraggingComponent && _draggedComponentType != null && _dragPosition != null) {
        // If we were dragging an existing component, end the drag
        if (gameState.interactionState.draggedComponentId != null) {
          ref.read(enhancedGameStateNotifierProvider.notifier).endDragging();
        } else {
          // Otherwise, place a new component
          _placeComponent(_draggedComponentType!, _dragPosition!, gameState, paletteState);
        }
      }

      // Reset drag state
      setState(() {
        _isDraggingComponent = false;
        _isPanningCanvas = false;
        _draggedComponentType = null;
        _dragPosition = null;
      });
    }
  }

  void _handleLongPressStart(LongPressStartDetails details, GameState gameState) {
    StructuredLogger.info('Long press gesture initiated', context: {
      'position': details.localPosition.toString(),
    });

    final gridPos = _canvasController.screenToGrid(details.localPosition);
    final snappedGridPos = Offset(gridPos.dx.round().toDouble(), gridPos.dy.round().toDouble());
    final component = _getComponentAtPosition(snappedGridPos, gameState);

    if (component != null) {
      StructuredLogger.debug('Long press on component', context: {
        'componentId': component.id,
        'componentType': component.type.toString(),
        'gridPosition': '${component.row}, ${component.col}',
      });

      // Check if this component is already selected
      final isCurrentlySelected = gameState.interactionState.selectedComponentId == component.id;

      if (!isCurrentlySelected) {
        // Select the component first
        ref.read(enhancedGameStateNotifierProvider.notifier).selectComponent(component.id);
        StructuredLogger.debug('Component auto-selected for context menu', context: {
          'componentId': component.id,
        });
      }

      // Show context menu for the component
      _showComponentContextMenu(component.id, details.localPosition);

      // Provide haptic feedback
      FeedbackUtils.provideHapticFeedback(FeedbackType.medium);
    } else {
      StructuredLogger.debug('Long press on empty canvas area');
      // Could potentially show canvas context menu here in the future
    }
  }

  void _showComponentContextMenu(String componentId, Offset position) {
    setState(() {
      _isContextMenuVisible = true;
      _contextMenuPosition = position;
      _contextMenuComponentId = componentId;
    });
    StructuredLogger.info('Context menu displayed', context: {
      'componentId': componentId,
      'position': position.toString(),
    });
  }

  void _hideComponentContextMenu() {
    setState(() {
      _isContextMenuVisible = false;
      _contextMenuPosition = null;
      _contextMenuComponentId = null;
    });
    StructuredLogger.debug('Context menu hidden');
  }

  ComponentModel? _getComponentAtPosition(Offset gridPosition, GameState gameState) {
    debugPrint('🔍 ====== COMPONENT SEARCH =======');
    debugPrint('🔍 Searching at grid position: (${gridPosition.dx.toInt()}, ${gridPosition.dy.toInt()})');
    debugPrint('🔍 Grid bounds: ${gameState.grid.rows}x${gameState.grid.cols}');
    debugPrint('🔍 Total components: ${gameState.grid.components.length}');

    // Find component at this exact grid position
    for (final component in gameState.grid.components.values) {
      debugPrint('🔍 Checking component ${component.id} at (${component.row}, ${component.col})');
      if (component.col == gridPosition.dx.toInt() && component.row == gridPosition.dy.toInt()) {
        debugPrint('🔍 ✅ FOUND MATCHING COMPONENT: ${component.id}');
        return component;
      }
    }

    debugPrint('🔍 ❌ NO COMPONENT FOUND AT THIS POSITION');
    return null;
  }

  void _placeComponent(
    String componentTypeString,
    Offset position,
    GameState gameState,
    PaletteState paletteState,
  ) {
    StructuredLogger.info('Component placement initiated', context: {
      'componentType': componentTypeString,
      'position': position.toString(),
      'paletteState': {
        'isPlacingComponent': paletteState.isPlacingComponent,
        'placingComponentType': paletteState.placingComponentType,
      },
    });

    if (!paletteState.canUseComponent(componentTypeString)) {
      StructuredLogger.warning('Component placement denied - insufficient inventory', context: {
        'componentType': componentTypeString,
        'availableInventory': paletteState.inventory,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more $componentTypeString components available'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final gridPosition = _canvasController.screenToGrid(position);
    final snappedPosition = Offset(
      gridPosition.dx.round().toDouble(),
      gridPosition.dy.round().toDouble(),
    );
    
    // Check if position is already occupied
    final existingComponent = _getComponentAtPosition(Offset(snappedPosition.dx.toInt().toDouble(), snappedPosition.dy.toInt().toDouble()), gameState);
    
    if (existingComponent != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position already occupied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Convert string to ComponentType enum
    final componentType = ComponentType.values.firstWhere(
      (e) => e.toString().split('.').last == componentTypeString,
      orElse: () => ComponentType.wire, // Default or error handling
    );

    // Add component to game state
    StructuredLogger.debug('Placing component in game state', context: {
      'componentType': componentType.toString(),
      'gridPosition': '${snappedPosition.dy.toInt()}, ${snappedPosition.dx.toInt()}',
    });
    ref.read(enhancedGameStateNotifierProvider.notifier).placeComponent(
      componentType,
      snappedPosition.dy.toInt(), // row
      snappedPosition.dx.toInt(), // col
    );

    // Update palette inventory
    ref.read(paletteStateProvider(widget.levelId).notifier).useComponent(componentTypeString);
    StructuredLogger.debug('Palette inventory updated', context: {
      'componentType': componentTypeString,
      'remainingCount': paletteState.inventory[componentTypeString] ?? 0,
    });

    // Clear placement mode
    ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();

    StructuredLogger.info('Component placement successful', context: {
      'componentType': componentTypeString,
      'gridPosition': '${snappedPosition.dy.toInt()}, ${snappedPosition.dx.toInt()}',
    });

    // Play component placement sound
    _playComponentPlacementSound();
  }

  void _playComponentPlacementSound() {
    FeedbackUtils.provideSoundFeedback(ref, SoundType.componentPlaced);
  }




  void _processComponentDrop(DragTargetDetails<ComponentDragData> details, Offset localPosition, GameState gameState, PaletteState paletteState) {
    debugPrint('🎯 ===== COMPONENT DROP PROCESSING START =====');
    debugPrint('🎯 Global position: ${details.offset}');
    debugPrint('🎯 Local position: $localPosition');
    debugPrint('🎯 Component: ${details.data.componentName} (${details.data.componentType})');
    debugPrint('🎯 Component cost: ${details.data.cost}');

    // 🔍 DEBUG: Pre-placement component count verification
    final prePlacementCount = gameState.grid.components.length;
    debugPrint('🎯 📊 COMPONENT COUNT TRACKING:');
    debugPrint('🎯   - Components BEFORE placement: $prePlacementCount');
    debugPrint('🎯   - Current grid contents:');
    gameState.grid.components.forEach((id, component) {
      debugPrint('🎯     - $id: ${component.type} at (${component.row}, ${component.col})');
    });

    // 🔍 DEBUG: Final grid position verification
    debugPrint('🎯 🎯 FINAL GRID POSITION CALCULATION:');
    final coordService = _canvasController.coordinateService;
    final calculatedFinalGridPos = coordService.screenToGrid(localPosition);
    final finalGridPosSnapped = Offset(
      calculatedFinalGridPos.dx.round().toDouble(),
      calculatedFinalGridPos.dy.round().toDouble()
    );
    final finalSide = (finalGridPosSnapped.dx < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
    debugPrint('🎯   - Calculated final grid position: $finalGridPosSnapped');
    debugPrint('🎯   - Final position side: $finalSide side of grid');

    // Current game state components
    debugPrint('🎯 Current game state components in grid:');
    gameState.grid.components.forEach((id, component) {
      final side = (component.col < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
      debugPrint('🎯   - $id: ${component.type.toString().split('.').last} at (${component.row},${component.col}) [${side}]');
    });

    StructuredLogger.info('Component drop initiated', context: {
      'globalPosition': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'gridBounds': '${gameState.grid.rows} x ${gameState.grid.cols}',
      'currentComponentCount': gameState.grid.components.length,
    });

    // Check if the drop position is within grid bounds first
    if (!_canvasController.isWithinGridBounds(localPosition)) {
      StructuredLogger.warning('Component drop rejected - out of bounds', context: {
        'dropPosition': localPosition.toString(),
        'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot place component outside grid'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get valid grid position (this handles snapping and bounds checking)
    final validGridPosition = _canvasController.getValidGridPosition(localPosition);
    if (validGridPosition == null) {
      StructuredLogger.warning('Component drop rejected - invalid grid position', context: {
        'dropPosition': localPosition.toString(),
      });
      return;
    }

    debugPrint('🎯 Valid grid position: ${validGridPosition.dx}, ${validGridPosition.dy}');

    // Check if position is already occupied
    final existingComponent = _getComponentAtPosition(validGridPosition, gameState);
    if (existingComponent != null) {
      StructuredLogger.warning('Component drop rejected - position occupied', context: {
        'obstacleComponent': {
          'id': existingComponent.id,
          'type': existingComponent.type.toString(),
          'position': '${existingComponent.row}, ${existingComponent.col}',
        },
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position already occupied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if component is available in inventory
    final componentTypeString = details.data.componentType.toString().split('.').last;
    final canUse = paletteState.canUseComponent(componentTypeString);

    if (!canUse) {
      StructuredLogger.warning('Component drop rejected - insufficient inventory', context: {
        'componentName': details.data.componentName,
        'componentTypeString': componentTypeString,
        'availableInventory': paletteState.inventory,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more ${details.data.componentName} components available'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Place the component
    StructuredLogger.debug('Placing component after validation', context: {
      'componentName': details.data.componentName,
      'gridPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
    });

    debugPrint('🎯 About to call placeComponent:');
    debugPrint('🎯   - ComponentType: ${details.data.componentType}');
    debugPrint('🎯   - Row: ${validGridPosition.dy.toInt()}');
    debugPrint('🎯   - Col: ${validGridPosition.dx.toInt()}');

    try {
      debugPrint('🎯 📍 About to place component at grid position: (${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()})');
      debugPrint('🎯 🏗️ Calling enhancedGameStateNotifierProvider.notifier.placeComponent...');
      debugPrint('🎯   - Component type: ${details.data.componentType}');
      debugPrint('🎯   - Row: ${validGridPosition.dy.toInt()}');
      debugPrint('🎯   - Col: ${validGridPosition.dx.toInt()}');

      ref.read(enhancedGameStateNotifierProvider.notifier).placeComponent(
        details.data.componentType,
        validGridPosition.dy.toInt(), // row
        validGridPosition.dx.toInt(), // col
      );
      debugPrint('🎯 ✅ placeComponent call completed successfully');

      // Check if component was actually added to game state
      final updatedGameState = ref.read(enhancedGameStateNotifierProvider);
      debugPrint('🎯 🔍 Game state after placement:');
      debugPrint('🎯   - Total components: ${updatedGameState.grid.components.length}');
      debugPrint('🎯   - Component IDs: ${updatedGameState.grid.components.keys.toList()}');

      // Verify the component was added
      final placedComponentId = updatedGameState.grid.components.keys.lastWhere(
        (id) => true,
        orElse: () => 'none',
      );
      if (placedComponentId != 'none') {
        final placedComponent = updatedGameState.grid.components[placedComponentId];
        debugPrint('🎯   - Last placed component: $placedComponentId (${placedComponent?.type}) at (${placedComponent?.row}, ${placedComponent?.col})');
      }

      // Update palette inventory
      debugPrint('🎯 Updating palette inventory...');
      ref.read(paletteStateProvider(widget.levelId).notifier).useComponent(componentTypeString);
      StructuredLogger.debug('Palette inventory decremented', context: {
        'componentTypeString': componentTypeString,
        'newCount': paletteState.inventory[componentTypeString],
      });

      // Clear any placement mode
      ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();

      // Play placement sound
      _playComponentPlacementSound();

      // 🔍 DEBUG: POST-PLACEMENT VERIFICATION
      debugPrint('🎯 ===== COMPONENT PLACEMENT SUCCESS =====');
      debugPrint('🎯 Component: ${details.data.componentName}');

      // 🔍 DEBUG: Position verification - Requested vs Actual
      debugPrint('🎯 📍 POSITION VERIFICATION DETAILS:');
      debugPrint('🎯   - Requested position: (${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()})');
      final actualSide = (validGridPosition.dx < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
      debugPrint('🎯   - Actual placement side: $actualSide');

      // 🔍 DEBUG: Component count verification
      final postPlacementCount = updatedGameState.grid.components.length;
      const expectedIncrease = 1;
      final actualIncrease = postPlacementCount - prePlacementCount;
      debugPrint('🎯 📊 COMPONENT COUNT VERIFICATION:');
      debugPrint('🎯   - Components BEFORE placement: $prePlacementCount');
      debugPrint('🎯   - Components AFTER placement: $postPlacementCount');
      debugPrint('🎯   - Expected increase: $expectedIncrease');
      debugPrint('🎯   - Actual increase: $actualIncrease');
      debugPrint('🎯   - Placement successful: ${actualIncrease == expectedIncrease}');

      // 🔍 DEBUG: Final grid state verification
      debugPrint('🎯 📋 FINAL GRID STATE VERIFICATION:');
      if (updatedGameState.grid.components.isEmpty) {
        debugPrint('🎯     [GRID STILL EMPTY - CRITICAL ERROR!]');
      } else {
        debugPrint('🎯     Updated grid components:');
        updatedGameState.grid.components.forEach((id, component) {
          final side = (component.col < gameState.grid.cols ~/ 2) ? 'LEFT' : 'RIGHT';
          final isLastPlaced = id.contains(details.data.componentType.toString().split('.').last);
          debugPrint('🎯       - $id: ${component.type.toString().split('.').last} at (${component.row},${component.col}) [$side]${isLastPlaced ? ' [NEWLY PLACED]' : ''}');
        });
      }

      debugPrint('🎯 🎉 COMPONENT PLACEMENT COMPLETED SUCCESSFULLY');
      debugPrint('🎯 =========================================');

      StructuredLogger.info('Component successfully placed - VERIFIED', context: {
        'componentName': details.data.componentName,
        'componentType': details.data.componentType.toString(),
        'requestedGridPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
        'placementSide': actualSide,
        'prePlacementCount': prePlacementCount,
        'postPlacementCount': postPlacementCount,
        'countIncrease': actualIncrease,
        'placementSuccessful': actualIncrease == expectedIncrease,
        'remainingInventory': paletteState.inventory,
        'totalComponentsAfterPlacement': updatedGameState.grid.components.length,
      });

    } catch (e) {
      debugPrint('🎯 ===== COMPONENT PLACEMENT FAILED =====');
      debugPrint('🎯 Error: $e');
      debugPrint('🎯 Stack trace: ${e.toString()}');

      StructuredLogger.error('Component placement failed', context: {
        'componentName': details.data.componentName,
        'componentType': details.data.componentType.toString(),
        'gridPosition': '${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()}',
        'error': e.toString(),
      }, error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing component: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _canAcceptComponentDrop(DragTargetDetails<ComponentDragData> details, GameState gameState) {
    // Get the RenderBox to convert global coordinates to local coordinates
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.offset);

    debugPrint('🔍 ===== DROP VALIDATION START =====');
    debugPrint('🔍 Component: ${details.data.componentName} (${details.data.componentType})');
    debugPrint('🔍 Global position: ${details.offset}');
    debugPrint('🔍 Local position: $localPosition');

    StructuredLogger.debug('Component drop validation', context: {
      'globalPosition': details.offset.toString(),
      'localPosition': localPosition.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
    });

    // 🔧 FIXED: Use consistent GridConfiguration instead of canvasController
    final config = GridConfiguration(
      rows: gameState.grid.rows,
      cols: gameState.grid.cols,
      cellSize: 60.0,  // Use standard cell size
      scale: 1.0,      // No scaling in initial implementation
      panOffset: Offset.zero, // No canvas pan offset yet
    );

    // Get valid grid position using GridService for consistency
    final validGridPosition = GridService.getValidGridPosition(localPosition, config);
    debugPrint('🔍 FIXED: Testing drop at local: $localPosition -> grid: $validGridPosition');

    if (validGridPosition == null) {
      debugPrint('🔍 ❌ REJECTED: Invalid grid position');
      debugPrint('🔍   - Local position: $localPosition');
      debugPrint('🔍   - Grid bounds: ${gameState.grid.rows}x${gameState.grid.cols}');

      // Calculate what grid position this would be for debugging
      final gridPos = GridService.screenToGrid(localPosition, config);
      debugPrint('🔍   - Calculated grid position: $gridPos');
      debugPrint('🔍   - Row valid: ${gridPos.dy >= 0 && gridPos.dy < gameState.grid.rows}');
      debugPrint('🔍   - Col valid: ${gridPos.dx >= 0 && gridPos.dx < gameState.grid.cols}');

      StructuredLogger.debug('Drop validation failed - invalid grid position', context: {
        'dropPosition': localPosition.toString(),
        'calculatedGridPos': gridPos.toString(),
        'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
      });
      return false;
    }

    debugPrint('🔍 FIXED: ✅ Drop position is valid');

    // Check if position is available (no existing component)
    final existingComponent = _getComponentAtPosition(validGridPosition, gameState);
    final positionAvailable = existingComponent == null;
    debugPrint('🔍 Step 3 - Position available: $positionAvailable');

    if (!positionAvailable) {
      debugPrint('🔍 ❌ REJECTED: Position occupied');
      debugPrint('🔍   - Occupying component: ${existingComponent.id} (${existingComponent.type})');
      debugPrint('🔍   - Position: (${existingComponent.row}, ${existingComponent.col})');
      StructuredLogger.debug('Drop validation failed - position occupied', context: {
        'obstacleComponent': existingComponent.id,
        'position': '${validGridPosition.dx}, ${validGridPosition.dy}',
      });
      return false;
    }

    // Check if component is available in inventory
    final componentTypeString = details.data.componentType.toString().split('.').last;
    final paletteState = ref.read(paletteStateProvider(widget.levelId));
    final canUse = paletteState.canUseComponent(componentTypeString);
    debugPrint('🔍 Step 4 - Component available in inventory: $canUse');
    debugPrint('🔍   - Component type string: $componentTypeString');
    debugPrint('🔍   - Inventory available: ${paletteState.inventory[componentTypeString]?.available ?? 0}');

    if (!canUse) {
      debugPrint('🔍 ❌ REJECTED: Insufficient inventory');
      debugPrint('🔍   - Available inventory: ${paletteState.inventory}');
      StructuredLogger.debug('Drop validation failed - insufficient inventory', context: {
        'componentTypeString': componentTypeString,
        'availableInventory': paletteState.inventory,
      });
      return false;
    }

    debugPrint('🔍 ✅ ACCEPTED: All validation checks passed');
    debugPrint('🔍   - Final grid position: (${validGridPosition.dx.toInt()}, ${validGridPosition.dy.toInt()})');
    debugPrint('🔍 ===== DROP VALIDATION END =====');

    StructuredLogger.debug('Drop validation passed - component accepted', context: {
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'gridPosition': '${validGridPosition.dx}, ${validGridPosition.dy}',
    });
    return true;
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
      neonPrimary: Color(0xFF00E5FF),
      neonAccent: Color(0xFF00BCD4),
      errorGlow: Color(0xFFFF5252),
      energyPulse: Color(0xFF00E676),
      highlightAccent: Color(0xFFFFC107),
    );
  }
}

class WireDrawingPainter extends CustomPainter {
  final Offset? startPosition;
  final Offset? endPosition;
  final CircuitColorScheme circuitColors;

  WireDrawingPainter({
    required this.startPosition,
    required this.endPosition,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (startPosition == null || endPosition == null) return;

    final paint = Paint()
      ..color = circuitColors.wireInactive
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(startPosition!, endPosition!, paint);

    // Draw connection points
    final pointPaint = Paint()
      ..color = circuitColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startPosition!, 6.0, pointPaint);
    canvas.drawCircle(endPosition!, 6.0, pointPaint);
  }

  @override
  bool shouldRepaint(WireDrawingPainter oldDelegate) {
    return oldDelegate.startPosition != startPosition ||
            oldDelegate.endPosition != endPosition;
  }
}

class DropZoneHighlightPainter extends CustomPainter {
  final CircuitColorScheme circuitColors;
  final ComponentDragData dragData;
  final GameState gameState;
  final GameCanvasController canvasController;

  DropZoneHighlightPainter({
    required this.circuitColors,
    required this.dragData,
    required this.gameState,
    required this.canvasController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridCellSize = canvasController.gridCellSize;
    final panOffset = canvasController.panOffset;
    final scale = canvasController.scale;

    // Draw highlights for valid drop positions
    for (int row = 0; row < gameState.grid.rows; row++) {
      for (int col = 0; col < gameState.grid.cols; col++) {
        final screenX = col * gridCellSize * scale + panOffset.dx;
        final screenY = row * gridCellSize * scale + panOffset.dy;

        // Check if this position is valid for dropping
        final isValid = _isValidDropPosition(row, col);

        if (isValid) {
          // Draw valid drop highlight with more prominent styling
          final validPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.4)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridCellSize * scale, gridCellSize * scale),
            validPaint,
          );

          // Draw inner highlight
          final innerPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.2)
            ..style = PaintingStyle.fill;

          final innerRect = Rect.fromLTWH(
            screenX + 4, screenY + 4,
            (gridCellSize * scale) - 8, (gridCellSize * scale) - 8
          );
          canvas.drawRect(innerRect, innerPaint);

          // Draw border with glow effect
          final borderPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridCellSize * scale, gridCellSize * scale),
            borderPaint,
          );

          // Draw corner markers for better visibility
          final cornerPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.fill;

          const cornerSize = 6.0;
          // Top-left corner
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, cornerSize, cornerSize),
            cornerPaint,
          );
          // Top-right corner
          canvas.drawRect(
            Rect.fromLTWH(screenX + (gridCellSize * scale) - cornerSize, screenY, cornerSize, cornerSize),
            cornerPaint,
          );
          // Bottom-left corner
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY + (gridCellSize * scale) - cornerSize, cornerSize, cornerSize),
            cornerPaint,
          );
          // Bottom-right corner
          canvas.drawRect(
            Rect.fromLTWH(screenX + (gridCellSize * scale) - cornerSize, screenY + (gridCellSize * scale) - cornerSize, cornerSize, cornerSize),
            cornerPaint,
          );
        }
      }
    }
  }

  bool _isValidDropPosition(int row, int col) {
    // Check if position is within bounds
    if (row < 0 || row >= gameState.grid.rows || col < 0 || col >= gameState.grid.cols) {
      return false;
    }

    // Check if position is occupied
    final existingComponent = gameState.grid.components.values
        .where((component) => component.row == row && component.col == col)
        .isNotEmpty;

    if (existingComponent) {
      return false;
    }

    // Check if component is available in inventory (simplified check)
    // In a real implementation, this would check the palette state
    return true;
  }

  @override
  bool shouldRepaint(DropZoneHighlightPainter oldDelegate) {
    return oldDelegate.dragData != dragData ||
           oldDelegate.gameState != gameState ||
           oldDelegate.canvasController != canvasController;
  }
}

import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/debug/debug_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import '../../../../application/game_engine_v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/presentation/features/game/painters/circuit_components_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/domain/entities/circuit_component.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/component_context_menu.dart';
import 'package:sparkcircuit/presentation/core/utils/feedback_utils.dart';
import 'package:sparkcircuit/application/game_engine_v3/providers_v3.dart';
import 'package:sparkcircuit/domain/entities/level_definition.dart';

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
  LevelDefinition? _levelDefinition;

  // Wire connection state
  bool _isDrawingWire = false;
  String? _wireStartComponentId;
  String? _wireStartPort;
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
    try {
      final levelService = ref.read(levelServiceProvider);
      final level = await levelService.loadLevel(widget.levelId);

      if (level != null) {
        setState(() {
          _levelDefinition = level;
        });

        // Update canvas controller with level's grid dimensions
        _canvasController.updateGridSize(level.grid.width, level.grid.height);

        // Center the grid after the next frame when canvas size is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Wait for another frame to ensure canvas size is updated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _canvasController.centerGrid();
          });
        });

        // Initialize game state with the loaded level
        ref.read(enhancedGameStateNotifierProvider.notifier).resetLevel();
        // Note: We can't directly set the level in the notifier from here
        // The level will be used in the build method to initialize the state properly
      } else {
        StructuredLogger.warning('Level not found, using default grid', context: {
          'levelId': widget.levelId,
        });
      }
    } catch (e) {
      StructuredLogger.error('Error loading level', context: {
        'levelId': widget.levelId,
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
      // Initialize game state with the loaded level
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(enhancedGameStateNotifierProvider.notifier).setState(
          GameState.initial(_levelDefinition));
      });
    }

    // Convert ComponentModel to CircuitComponent for painter
    final List<CircuitComponent> circuitComponents = gameState.grid.components.values
        .map((c) => CircuitComponent.fromComponentModel(c))
        .toList()
        .cast<CircuitComponent>();

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
          onAcceptWithDetails: (details) => _handleComponentDrop(details, gameState, paletteState),
          onWillAcceptWithDetails: (details) => _canAcceptComponentDrop(details, gameState),
          onMove: (details) {
            StructuredLogger.trace('Drag move detected', context: {
              'position': details.offset.toString(),
              'componentName': details.data.componentName,
              'componentType': details.data.componentType.toString(),
            });
          },
          onLeave: (details) {
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
            return Stack(
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
                  child: CustomPaint(
                    painter: CircuitComponentsPainter(
                      components: circuitComponents,
                      wires: circuitWires,
                      circuitColors: circuitColors,
                      selectedComponentId: gameState.interactionState.selectedComponentId,
                      scale: _canvasController.scale,
                    ),
                    size: Size.infinite,
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
    final isPaletteDragActive = ref.watch(paletteDragActiveProvider);

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
        onPanStart: (details) => _handlePanStart(details, gameState, paletteState),
        onPanUpdate: (details) => _handlePanUpdate(details, gameState, paletteState),
        onPanEnd: (details) => _handlePanEnd(details, gameState, paletteState),
        onScaleStart: (details) => _handleScaleStart(details),
        onScaleUpdate: (details) => _handleScaleUpdate(details, gameState, paletteState),
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
          color: circuitColors.primary.withValues(alpha: 0.5),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: DropZoneHighlightPainter(
          circuitColors: circuitColors,
          dragData: dragData,
          gameState: gameState,
          canvasController: _canvasController,
        ),
        size: Size.infinite,
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

  void _handlePanStart(
    DragStartDetails details,
    GameState gameState,
    PaletteState paletteState,
  ) {
    final localPosition = details.localPosition;

    // Check if starting drag from an existing component
    final component = _getComponentAtPosition(localPosition, gameState);
    if (component != null) {
      // Start dragging existing component
      _isDraggingComponent = true;
      _isPanningCanvas = false;
      ref.read(enhancedGameStateNotifierProvider.notifier).startDragging(component.id, localPosition);
      setState(() {
        _draggedComponentType = component.type.toString();
        _dragPosition = localPosition;
      });
      return;
    }

    // Starting pan on empty canvas
    _isDraggingComponent = false;
    _isPanningCanvas = true;

    // Check if placing a new component
    if (paletteState.selectedComponentType != null) {
      setState(() {
        _draggedComponentType = paletteState.selectedComponentType;
        _dragPosition = localPosition;
      });
    }
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    GameState gameState,
    PaletteState paletteState,
  ) {
    if (_isDraggingComponent && _draggedComponentType != null) {
      // Update drag preview position
      setState(() {
        _dragPosition = details.localPosition;
      });

      // If dragging an existing component, update its position in real-time
      if (gameState.interactionState.draggedComponentId != null) {
        final gridPosition = _canvasController.screenToGrid(details.localPosition);
        final snappedPosition = Offset(
          gridPosition.dx.round().toDouble(),
          gridPosition.dy.round().toDouble(),
        );

        // Move component to new position
        ref.read(enhancedGameStateNotifierProvider.notifier).moveComponent(
          gameState.interactionState.draggedComponentId!,
          snappedPosition.dy.toInt(),
          snappedPosition.dx.toInt(),
        );
      }
    } else if (_isPanningCanvas) {
      // Handle canvas panning
      _canvasController.updatePan(details.delta);
    }
  }

  void _handlePanEnd(
    DragEndDetails details,
    GameState gameState,
    PaletteState paletteState,
  ) {
    if (_isDraggingComponent && _draggedComponentType != null && _dragPosition != null) {
      // If we were dragging an existing component, end the drag
      if (gameState.interactionState.draggedComponentId != null) {
        ref.read(enhancedGameStateNotifierProvider.notifier).endDragging();
      } else {
        // Otherwise, place a new component
        _placeComponent(_draggedComponentType!, _dragPosition!, gameState, paletteState);
      }
    }

    // Reset pan state
    setState(() {
      _isDraggingComponent = false;
      _isPanningCanvas = false;
      _draggedComponentType = null;
      _dragPosition = null;
    });
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

    final component = _getComponentAtPosition(details.localPosition, gameState);
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
    _canvasController.startScale();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, GameState gameState, PaletteState paletteState) {
    // Only handle scaling and panning for multi-touch gestures
    // Single-touch gestures should be handled by pan handlers

    if (details.pointerCount > 1) {
      // Multi-touch: handle scaling and panning
      _canvasController.updateScale(details.scale);
      _canvasController.updatePan(details.focalPointDelta);
    }
    // Single-touch gestures are now handled by the separate pan handlers
  }

  void _handleScaleEnd(ScaleEndDetails details, GameState gameState, PaletteState paletteState) {
    // Only handle scale ending - component dragging is now handled by pan handlers
    _canvasController.endScale();
  }

  void _handleLongPressStart(LongPressStartDetails details, GameState gameState) {
    StructuredLogger.info('Long press gesture initiated', context: {
      'position': details.localPosition.toString(),
    });

    final component = _getComponentAtPosition(details.localPosition, gameState);

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

  ComponentModel? _getComponentAtPosition(Offset position, GameState gameState) {
    final gridPosition = _canvasController.screenToGrid(position);

    // Find component at this position
    for (final component in gameState.grid.components.values) {
      final componentGridPos = Offset(component.col.toDouble(), component.row.toDouble());
      final distance = (gridPosition - componentGridPos).distance;
      if (distance < 0.8) {
        return component;
      }
    }
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
    final existingComponent = _getComponentAtPosition(snappedPosition, gameState);
    
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

  Map<String, dynamic> _getDefaultPropertiesForComponent(String componentType) {
    switch (componentType) {
      case 'battery':
        return {'voltage': 9.0, 'internal_resistance': 0.1};
      case 'resistor':
        return {'resistance': 1000.0, 'tolerance': 0.05};
      case 'led':
        return {'forward_voltage': 2.0, 'color': 'red'};
      case 'capacitor':
        return {'capacitance': 0.001, 'voltage_rating': 25};
      case 'inductor':
        return {'inductance': 0.1};
      case 'switch':
        return {'state': 'open'};
      default:
        return {};
    }
  }

  Widget _buildWireDrawingOverlay(GameState gameState, CircuitColorScheme circuitColors) {
    return GestureDetector(
      onTapDown: (details) => _handleWireTapDown(details, gameState),
      onPanUpdate: (details) => _handleWirePanUpdate(details),
      onPanEnd: (details) => _handleWirePanEnd(details, gameState),
      child: Container(
        color: Colors.transparent,
        child: CustomPaint(
          painter: WireDrawingPainter(
            startPosition: _wireStartPosition,
            endPosition: _wireEndPosition,
            circuitColors: circuitColors,
          ),
        ),
      ),
    );
  }

  void _handleWireTapDown(TapDownDetails details, GameState gameState) {
    final component = _getComponentAtPosition(details.localPosition, gameState);
    if (component != null) {
      setState(() {
        _isDrawingWire = true;
        _wireStartComponentId = component.id;
        _wireStartPort = 'terminal1'; // Simplified - would need proper port detection
        _wireStartPosition = details.localPosition;
        _wireEndPosition = details.localPosition;
      });
    }
  }

  void _handleWirePanUpdate(DragUpdateDetails details) {
    if (_isDrawingWire) {
      setState(() {
        _wireEndPosition = details.localPosition;
      });
    }
  }

  void _handleWirePanEnd(DragEndDetails details, GameState gameState) {
    if (_isDrawingWire && _wireStartComponentId != null && _wireEndPosition != null) {
      final endComponent = _getComponentAtPosition(_wireEndPosition!, gameState);
      if (endComponent != null && endComponent.id != _wireStartComponentId) {
        // Create wire connection
        _createWireConnection(_wireStartComponentId!, endComponent.id, gameState);
      }
    }

    // Reset wire drawing state
    setState(() {
      _isDrawingWire = false;
      _wireStartComponentId = null;
      _wireStartPort = null;
      _wireStartPosition = null;
      _wireEndPosition = null;
    });
  }

  void _createWireConnection(String fromComponentId, String toComponentId, GameState gameState) {
    // Add connection to game state
    ref.read(enhancedGameStateNotifierProvider.notifier).addConnection(
      fromComponentId,
      toComponentId,
    );
  }

  void _handleComponentDrop(DragTargetDetails<ComponentDragData> details, GameState gameState, PaletteState paletteState) {
    StructuredLogger.info('Component drop initiated', context: {
      'position': details.offset.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'gridBounds': '${gameState.grid.rows} x ${gameState.grid.cols}',
    });

    // Convert screen coordinates to grid coordinates
    final gridPosition = _canvasController.screenToGrid(details.offset);
    final snappedPosition = Offset(
      gridPosition.dx.round().toDouble(),
      gridPosition.dy.round().toDouble(),
    );

    StructuredLogger.debug('Grid position calculated', context: {
      'gridPosition': '${snappedPosition.dx}, ${snappedPosition.dy}',
    });

    // Check if position is valid and available
    final existingComponent = _getComponentAtPosition(snappedPosition, gameState);
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

    // Check if position is within grid bounds
    if (snappedPosition.dx < 0 || snappedPosition.dy < 0 ||
        snappedPosition.dx >= gameState.grid.cols || snappedPosition.dy >= gameState.grid.rows) {
      StructuredLogger.warning('Component drop rejected - out of bounds', context: {
        'gridPosition': '${snappedPosition.dx}, ${snappedPosition.dy}',
        'gridBounds': '${gameState.grid.rows} x ${gameState.grid.cols}',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot place component outside grid'),
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
      'gridPosition': '${snappedPosition.dx.toInt()}, ${snappedPosition.dy.toInt()}',
    });

    try {
      ref.read(enhancedGameStateNotifierProvider.notifier).placeComponent(
        details.data.componentType,
        snappedPosition.dy.toInt(), // row
        snappedPosition.dx.toInt(), // col
      );

      // Update palette inventory
      ref.read(paletteStateProvider(widget.levelId).notifier).useComponent(componentTypeString);
      StructuredLogger.debug('Palette inventory decremented', context: {
        'componentTypeString': componentTypeString,
        'newCount': paletteState.inventory[componentTypeString],
      });

      // Clear any placement mode
      ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();

      // Play placement sound
      _playComponentPlacementSound();

      StructuredLogger.info('Component successfully placed', context: {
        'componentName': details.data.componentName,
        'componentType': details.data.componentType.toString(),
        'gridPosition': '${snappedPosition.dx.toInt()}, ${snappedPosition.dy.toInt()}',
        'remainingInventory': paletteState.inventory,
      });

    } catch (e) {
      StructuredLogger.error('Component placement failed', context: {
        'componentName': details.data.componentName,
        'componentType': details.data.componentType.toString(),
        'gridPosition': '${snappedPosition.dx.toInt()}, ${snappedPosition.dy.toInt()}',
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
    StructuredLogger.debug('Component drop validation', context: {
      'position': details.offset.toString(),
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'canvasState': {
        'cellSize': _canvasController.gridCellSize,
        'pan': _canvasController.panOffset.toString(),
        'scale': _canvasController.scale,
      },
    });

    // Convert screen coordinates to grid coordinates
    final gridPosition = _canvasController.screenToGrid(details.offset);
    final snappedPosition = Offset(
      gridPosition.dx.round().toDouble(),
      gridPosition.dy.round().toDouble(),
    );

    StructuredLogger.trace('Calculated grid coordinates', context: {
      'gridPosition': '${snappedPosition.dx}, ${snappedPosition.dy}',
      'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
    });

    // Check if position is within grid bounds
    final withinBounds = snappedPosition.dx >= 0 && snappedPosition.dy >= 0 &&
                        snappedPosition.dx < gameState.grid.cols && snappedPosition.dy < gameState.grid.rows;

    if (!withinBounds) {
      StructuredLogger.debug('Drop validation failed - out of bounds', context: {
        'attemptedPosition': '${snappedPosition.dx}, ${snappedPosition.dy}',
        'gridBounds': '${gameState.grid.rows}x${gameState.grid.cols}',
      });
      return false;
    }

    // Check if position is available (no existing component)
    final existingComponent = _getComponentAtPosition(snappedPosition, gameState);
    final positionAvailable = existingComponent == null;

    if (!positionAvailable) {
      StructuredLogger.debug('Drop validation failed - position occupied', context: {
        'obstacleComponent': existingComponent?.id,
        'position': '${snappedPosition.dx}, ${snappedPosition.dy}',
      });
      return false;
    }

    // Check if component is available in inventory
    final componentTypeString = details.data.componentType.toString().split('.').last;
    final paletteState = ref.read(paletteStateProvider(widget.levelId));
    final canUse = paletteState.canUseComponent(componentTypeString);

    if (!canUse) {
      StructuredLogger.debug('Drop validation failed - insufficient inventory', context: {
        'componentTypeString': componentTypeString,
        'availableInventory': paletteState.inventory,
      });
      return false;
    }

    StructuredLogger.debug('Drop validation passed - component accepted', context: {
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'gridPosition': '${snappedPosition.dx}, ${snappedPosition.dy}',
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
          // Draw valid drop highlight
          final validPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridCellSize * scale, gridCellSize * scale),
            validPaint,
          );

          // Draw border
          final borderPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridCellSize * scale, gridCellSize * scale),
            borderPaint,
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

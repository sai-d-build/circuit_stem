import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/core/utils/coordinate_translator.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/presentation/features/game/painters/circuit_components_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_widget.dart';

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

  // Wire connection state
  bool _isDrawingWire = false;
  String? _wireStartComponentId;
  String? _wireStartPort;
  Offset? _wireStartPosition;
  Offset? _wireEndPosition;

  @override
  void initState() {
    super.initState();
    _canvasController = GameCanvasController();
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
    final gameState = ref.watch(enhancedGameStateNotifierProvider) as GameState;
    final paletteState = ref.watch(paletteStateProvider(widget.levelId));

    // Convert ComponentModel to CircuitComponent for painter
    final List<CircuitComponent> circuitComponents = gameState.grid.components.values
        .map((c) => CircuitComponent.fromComponentModel(c))
        .toList()
        .cast<CircuitComponent>();

    // Convert Grid connections to CircuitWire for painter
    final List<CircuitWire> circuitWires = [];
    gameState.grid.connections.forEach((sourceId, connectedIds) {
      final sourceComponent = gameState.grid.getComponentById(sourceId);
      if (sourceComponent != null) {
        for (final targetId in connectedIds) {
          final targetComponent = gameState.grid.getComponentById(targetId);
          if (targetComponent != null) {
            // Ensure each wire is added only once (e.g., A-B, not B-A)
            if (sourceId.hashCode < targetId.hashCode) {
              circuitWires.add(CircuitWire(
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
        child: Stack(
          children: [
            // Grid background
            Positioned.fill(
              child: CircuitGrid(
                controller: _canvasController,
                levelId: widget.levelId,
              ),
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
          ],
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

    return GestureDetector(
      onTapDown: (details) => _handleTapDown(details, gameState),
      onLongPressStart: (details) => _handleLongPressStart(details, gameState),
      onScaleStart: (details) => _handleScaleStart(details),
      onScaleUpdate: (details) => _handleScaleUpdate(details),
      onScaleEnd: (details) => _handleScaleEnd(details),
      child: Container(
        color: Colors.transparent,
        child: paletteState.isPlacingComponent
            ? _buildPlacementOverlay(paletteState, circuitColors)
            : null,
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
      setState(() {
        _draggedComponentType = component.type.toString();
        _dragPosition = localPosition;
      });
      return;
    }
    
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
    if (_draggedComponentType != null) {
      setState(() {
        _dragPosition = details.localPosition;
      });
    } else {
      // Handle canvas panning
      _canvasController.updatePan(details.delta);
    }
  }

  void _handlePanEnd(
    DragEndDetails details,
    GameState gameState,
    PaletteState paletteState,
  ) {
    if (_draggedComponentType != null && _dragPosition != null) {
      _placeComponent(_draggedComponentType!, _dragPosition!, gameState, paletteState);
      setState(() {
        _draggedComponentType = null;
        _dragPosition = null;
      });
    }
  }

  void _handleTapDown(TapDownDetails details, GameState gameState) {
    print('🎯 GameCanvas: Tap detected at ${details.localPosition}');

    // Check if we're in placement mode first
    final paletteState = ref.read(paletteStateProvider(widget.levelId));
    if (paletteState.isPlacingComponent && paletteState.placingComponentType != null) {
      print('🎯 GameCanvas: In placement mode for ${paletteState.placingComponentType}');
      _placeComponent(paletteState.placingComponentType!, details.localPosition, gameState, paletteState);
      return;
    }

    final component = _getComponentAtPosition(details.localPosition, gameState);
    if (component != null) {
      print('🎯 GameCanvas: Tapped on component: ${component.id} (${component.type})');
      // If shift is pressed or in wire mode, start drawing wire
      // For now, we'll use double tap to start wire drawing
      ref.read(enhancedGameStateNotifierProvider.notifier).tapComponent(component.id);
      print('🎯 GameCanvas: Component selected: ${component.id}');
    } else {
      print('🎯 GameCanvas: Tap on empty space, deselecting component');
      ref.read(enhancedGameStateNotifierProvider.notifier).selectComponent(null);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _canvasController.startScale();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _canvasController.updateScale(details.scale);
    _canvasController.updatePan(details.focalPointDelta);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _canvasController.endScale();
  }

  void _handleLongPressStart(LongPressStartDetails details, GameState gameState) {
    print('🔗 GameCanvas: Long press detected at ${details.localPosition}');
    final component = _getComponentAtPosition(details.localPosition, gameState);
    if (component != null) {
      print('🔗 GameCanvas: Starting wire from component: ${component.id} (${component.type})');
      setState(() {
        _isDrawingWire = true;
        _wireStartComponentId = component.id;
        _wireStartPort = 'terminal1'; // Simplified - would need proper port detection
        _wireStartPosition = details.localPosition;
        _wireEndPosition = details.localPosition;
      });
      print('🔗 GameCanvas: Wire drawing mode activated');
    } else {
      print('🔗 GameCanvas: Long press on empty space - no component found');
    }
  }

  ComponentModel? _getComponentAtPosition(Offset position, GameState gameState) {
    final translator = CoordinateTranslator(
      gridCellSize: _canvasController.gridCellSize,
      panX: _canvasController.panOffset.dx,
      panY: _canvasController.panOffset.dy,
      scale: _canvasController.scale,
    );
    
    final gridPosition = translator.screenToGrid(position);
    
    // Find component at this position
    for (final component in gameState.grid.components.values) {
      final componentGridPos = Offset(component.col.toDouble(), component.row.toDouble());
      if (translator.gridDistance(gridPosition, componentGridPos) < 0.8) {
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
    print('📦 GameCanvas: Attempting to place component: $componentTypeString at $position');
    print('📦 GameCanvas: Palette state - isPlacingComponent: ${paletteState.isPlacingComponent}, placingComponentType: ${paletteState.placingComponentType}');
    print('📦 GameCanvas: Component inventory check for $componentTypeString...');

    if (!paletteState.canUseComponent(componentTypeString)) {
      print('📦 GameCanvas: Cannot place component - not available in palette');
      print('📦 GameCanvas: Available inventory: ${paletteState.inventory}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more $componentTypeString components available'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final translator = CoordinateTranslator(
      gridCellSize: _canvasController.gridCellSize,
      panX: _canvasController.panOffset.dx,
      panY: _canvasController.panOffset.dy,
      scale: _canvasController.scale,
    );
    
    final gridPosition = translator.screenToGrid(position);
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
    print('📦 GameCanvas: Adding component to game state...');
    ref.read(enhancedGameStateNotifierProvider.notifier).placeComponent(
      componentType,
      snappedPosition.dy.toInt(), // row
      snappedPosition.dx.toInt(), // col
    );

    // Update palette inventory
    print('📦 GameCanvas: Updating palette inventory...');
    ref.read(paletteStateProvider(widget.levelId).notifier).useComponent(componentTypeString);

    // Clear placement mode
    print('📦 GameCanvas: Clearing placement mode...');
    ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();

    print('📦 GameCanvas: Component placement completed successfully');
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

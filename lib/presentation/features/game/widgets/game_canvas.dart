import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_component_display.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/presentation/state/game_state.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/core/utils/coordinate_translator.dart';

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
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final gameState = ref.watch(gameStateProvider(widget.levelId));
    final paletteState = ref.watch(paletteStateProvider(widget.levelId));

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
              child: CircuitComponentDisplay(
                controller: _canvasController,
                levelId: widget.levelId,
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
    return GestureDetector(
      onPanStart: (details) => _handlePanStart(details, gameState, paletteState),
      onPanUpdate: (details) => _handlePanUpdate(details, gameState, paletteState),
      onPanEnd: (details) => _handlePanEnd(details, gameState, paletteState),
      onTapDown: (details) => _handleTapDown(details, gameState),
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
        _draggedComponentType = component.type;
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
    final component = _getComponentAtPosition(details.localPosition, gameState);
    if (component != null) {
      ref.read(gameStateProvider(widget.levelId).notifier).selectComponent(component.id);
    } else {
      ref.read(gameStateProvider(widget.levelId).notifier).selectComponent(null);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _canvasController.startScale();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _canvasController.updateScale(details.scale);
    if (details.pointerCount == 1) {
      _canvasController.updatePan(details.focalPointDelta);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _canvasController.endScale();
  }

  CircuitComponent? _getComponentAtPosition(Offset position, GameState gameState) {
    final translator = CoordinateTranslator(
      gridCellSize: _canvasController.gridCellSize,
      panX: _canvasController.panOffset.dx,
      panY: _canvasController.panOffset.dy,
      scale: _canvasController.scale,
    );
    
    final gridPosition = translator.screenToGrid(position);
    
    return gameState.components.cast<CircuitComponent?>().firstWhere(
      (component) {
        if (component == null) return false;
        final componentGridPos = Offset(component.posX, component.posY);
        return translator.gridDistance(gridPosition, componentGridPos) < 0.8;
      },
      orElse: () => null,
    );
  }

  void _placeComponent(
    String componentType,
    Offset position,
    GameState gameState,
    PaletteState paletteState,
  ) {
    if (!paletteState.canUseComponent(componentType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more $componentType components available'),
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
    final existingComponent = gameState.components.cast<CircuitComponent?>().firstWhere(
      (component) {
        if (component == null) return false;
        final componentPos = Offset(component.posX, component.posY);
        return translator.gridDistance(snappedPosition, componentPos) < 0.1;
      },
      orElse: () => null,
    );
    
    if (existingComponent != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position already occupied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create new component
    final newComponent = CircuitComponent(
      id: '${componentType}_${DateTime.now().millisecondsSinceEpoch}',
      type: componentType,
      posX: snappedPosition.dx,
      posY: snappedPosition.dy,
      properties: _getDefaultPropertiesForComponent(componentType),
    );

    // Add component to game state
    ref.read(gameStateProvider(widget.levelId).notifier).addComponent(newComponent);
    
    // Update palette inventory
    ref.read(paletteStateProvider(widget.levelId).notifier).useComponent(componentType);
    
    // Clear placement mode
    ref.read(paletteStateProvider(widget.levelId).notifier).stopPlacingComponent();
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
}
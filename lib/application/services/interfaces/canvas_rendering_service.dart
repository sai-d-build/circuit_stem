import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Service interface for rendering canvas content
abstract class CanvasRenderingService {
  /// Build rendering data from a level definition
  CanvasRenderingData buildRenderingData(LevelDefinition level);

  /// Convert domain components to rendering components
  List<CanvasCircuitComponent> convertComponentsForPainter(
      List<ComponentModel> components);

  /// Convert domain connections to rendering wires
  List<CircuitWire> convertConnectionsForPainter(
      Map<String, Set<String>> connections);
}

/// Rendering-specific circuit component (to avoid naming conflicts)
class CanvasCircuitComponent {
  final String id;
  final ComponentType type;
  final int row;
  final int col;
  final Map<String, dynamic> properties;
  final bool isSelected;
  final bool isHighlighted;

  const CanvasCircuitComponent({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.properties = const {},
    this.isSelected = false,
    this.isHighlighted = false,
  });
}

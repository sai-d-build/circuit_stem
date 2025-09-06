import 'package:sparkcircuit/application/services/interfaces/canvas_rendering_service.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Default implementation of CanvasRenderingService
class DefaultCanvasRenderingService implements CanvasRenderingService {
  @override
  CanvasRenderingData buildRenderingData(LevelDefinition level) {
    return CanvasRenderingData(
      components: [], // Will be populated by game state
      wires: [], // Will be populated by game state
      gridConfiguration: GridConfiguration(
        rows: level.grid.height,
        cols: level.grid.width,
        cellSize: 60.0,
      ),
      effectsData: {
        'tutorialMode': level.tutorial?.enabled ?? false,
        'scoringEnabled': level.scoring != null,
      },
    );
  }

  @override
  List<CanvasCircuitComponent> convertComponentsForPainter(List<ComponentModel> components) {
    return components.map((component) => CanvasCircuitComponent(
      id: component.id,
      type: component.type,
      row: component.row,
      col: component.col,
      properties: component.properties,
      isSelected: component.isSelected,
      isHighlighted: false,
    )).toList();
  }

  @override
  List<CircuitWire> convertConnectionsForPainter(Map<String, Set<String>> connections) {
    final wires = <CircuitWire>[];

    connections.forEach((sourceId, connectedIds) {
      for (final targetId in connectedIds) {
        if (sourceId.hashCode < targetId.hashCode) {
          wires.add(CircuitWire(
            id: '${sourceId}_${targetId}',
            startRow: 0,
            startCol: 0,
            endRow: 0,
            endCol: 0,
            isActive: false,
          ));
        }
      }
    });

    return wires;
  }
}
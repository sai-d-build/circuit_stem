import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';


part 'circuit_netlist.freezed.dart';
part 'circuit_netlist.g.dart';

@freezed
class SimComponent with _$SimComponent {
  const factory SimComponent({
    required String id,
    required ComponentType type,
    required Map<String, dynamic> properties,
    required List<String> connectedNodes,
  }) = _SimComponent;

  factory SimComponent.fromJson(Map<String, dynamic> json) =>
      _$SimComponentFromJson(json);
}

@freezed
class SimConnection with _$SimConnection {
  const factory SimConnection({
    required String id,
    required String node1Id,
    required String node2Id,
  }) = _SimConnection;

  factory SimConnection.fromJson(Map<String, dynamic> json) =>
      _$SimConnectionFromJson(json);
}

@freezed
class SimNode with _$SimNode {
  const factory SimNode({
    required String id,
    required double x,
    required double y,
  }) = _SimNode;

  factory SimNode.fromJson(Map<String, dynamic> json) =>
      _$SimNodeFromJson(json);
}

@freezed
class CircuitNetlist with _$CircuitNetlist {
  const factory CircuitNetlist({
    required List<SimComponent> components,
    required List<SimConnection> connections,
    required Map<String, SimNode> nodes,
    required DateTime timestamp,
  }) = _CircuitNetlist;

  factory CircuitNetlist.fromJson(Map<String, dynamic> json) =>
      _$CircuitNetlistFromJson(json);

  factory CircuitNetlist.fromGameState(GameState gameState) {
    final components = <SimComponent>[];
    final connections = <SimConnection>[];
    final nodes = <String, SimNode>{};

    // Helper to generate unique node IDs based on grid position
    String getNodeKey(int row, int col) => 'node_${row}_$col';

    // Process components and create SimComponents and SimNodes
    for (final componentModel in gameState.grid.components.values) {
      // Create SimComponent
      final simComponent = SimComponent(
        id: componentModel.id,
        type: componentModel.type,
        properties: componentModel.properties,
        connectedNodes: [], // Will be populated later based on connections
      );
      components.add(simComponent);

      // Create nodes for component's position (assuming each component occupies a single grid cell for now)
      final nodeKey = getNodeKey(componentModel.row, componentModel.col);
      if (!nodes.containsKey(nodeKey)) {
        nodes[nodeKey] = SimNode(
          id: nodeKey,
          x: componentModel.col.toDouble(), // Use col for x
          y: componentModel.row.toDouble(), // Use row for y
        );
      }
    }

    // Process connections and create SimConnections
    // This part is highly dependent on how connections are represented in your Grid model.
    // Assuming Grid.connections maps component ID to a list of connected component IDs.
    // This will need refinement based on actual connection logic (e.g., wires connecting specific terminals).
    final processedConnections = <String>{}; // To avoid duplicate connections
    for (final entry in gameState.grid.connections.entries) {
      final sourceComponentId = entry.key;
      for (final targetComponentId in entry.value) {
        // Create a unique key for the connection to avoid duplicates (order-independent)
        final connectionKey = [sourceComponentId, targetComponentId]..sort();
        final uniqueConnectionId = 'conn_${connectionKey.join('_')}';

        if (!processedConnections.contains(uniqueConnectionId)) {
          // Assuming a direct connection between component centers for now.
          // In a real circuit, connections are between specific terminals/pins.
          final sourceComponent = gameState.grid.getComponentById(sourceComponentId);
          final targetComponent = gameState.grid.getComponentById(targetComponentId);

          if (sourceComponent != null && targetComponent != null) {
            final node1Id = getNodeKey(sourceComponent.row, sourceComponent.col);
            final node2Id = getNodeKey(targetComponent.row, targetComponent.col);

            connections.add(SimConnection(
              id: uniqueConnectionId,
              node1Id: node1Id,
              node2Id: node2Id,
            ));

            // Update connectedNodes for SimComponents (this is a simplification)
            final simSource = components.firstWhere((c) => c.id == sourceComponentId);
            final simTarget = components.firstWhere((c) => c.id == targetComponentId);
            if (!simSource.connectedNodes.contains(node2Id)) {
              simSource.connectedNodes.add(node2Id);
            }
            if (!simTarget.connectedNodes.contains(node1Id)) {
              simTarget.connectedNodes.add(node1Id);
            }
          }
          processedConnections.add(uniqueConnectionId);
        }
      }
    }

    return CircuitNetlist(
      components: components,
      connections: connections,
      nodes: nodes,
      timestamp: DateTime.now(),
    );
  }
}
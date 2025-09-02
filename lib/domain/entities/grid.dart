// Grid entity for SparkCircuit
// Represents the circuit grid and manages component placement


import 'component.dart';
import '../../common/logger.dart';

class Grid {
  final int rows;
  final int cols;
  final Map<String, ComponentModel> components;
  final Set<String> occupiedPositions;
  final Map<String, List<String>> connections;
  final DateTime createdAt;
  final DateTime updatedAt;

  Grid({
    required this.rows,
    required this.cols,
    Map<String, ComponentModel>? components,
    Set<String>? occupiedPositions,
    Map<String, List<String>>? connections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    components = components ?? {},
    occupiedPositions = occupiedPositions ?? {},
    connections = connections ?? {},
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Grid copyWith({
    int? rows,
    int? cols,
    Map<String, ComponentModel>? components,
    Set<String>? occupiedPositions,
    Map<String, List<String>>? connections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Grid(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      components: components ?? this.components,
      occupiedPositions: occupiedPositions ?? this.occupiedPositions,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Component management
  bool canPlaceComponent(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return false; // Out of bounds
    }

    final positionKey = _positionToKey(row, col);
    return !occupiedPositions.contains(positionKey);
  }

  Grid placeComponent(ComponentModel component) {
    if (!canPlaceComponent(component.row, component.col)) {
      Logger.w('Cannot place component at position (${component.row}, ${component.col})');
      return this;
    }

    final positionKey = _positionToKey(component.row, component.col);
    final newComponents = Map<String, ComponentModel>.from(components);
    final newOccupiedPositions = Set<String>.from(occupiedPositions);

    newComponents[component.id] = component;
    newOccupiedPositions.add(positionKey);

    Logger.logComponentEvent(component.id, 'placed', {
      'position': '(${component.row}, ${component.col})',
      'type': component.type.toString(),
    });

    return copyWith(
      components: newComponents,
      occupiedPositions: newOccupiedPositions,
      updatedAt: DateTime.now(),
    );
  }

  Grid removeComponent(String componentId) {
    final component = components[componentId];
    if (component == null) {
      Logger.w('Component $componentId not found in grid');
      return this;
    }

    final positionKey = _positionToKey(component.row, component.col);
    final newComponents = Map<String, ComponentModel>.from(components);
    final newOccupiedPositions = Set<String>.from(occupiedPositions);

    newComponents.remove(componentId);
    newOccupiedPositions.remove(positionKey);

    Logger.logComponentEvent(componentId, 'removed', {
      'position': '(${component.row}, ${component.col})',
    });

    return copyWith(
      components: newComponents,
      occupiedPositions: newOccupiedPositions,
      updatedAt: DateTime.now(),
    );
  }

  Grid moveComponent(String componentId, int newRow, int newCol) {
    final component = components[componentId];
    if (component == null) {
      Logger.w('Component $componentId not found in grid');
      return this;
    }

    if (!canPlaceComponent(newRow, newCol)) {
      Logger.w('Cannot move component to position ($newRow, $newCol)');
      return this;
    }

    final oldPositionKey = _positionToKey(component.row, component.col);
    final newPositionKey = _positionToKey(newRow, newCol);

    final newOccupiedPositions = Set<String>.from(occupiedPositions);
    newOccupiedPositions.remove(oldPositionKey);
    newOccupiedPositions.add(newPositionKey);

    final updatedComponent = component.copyWith(
      row: newRow,
      col: newCol,
      updatedAt: DateTime.now(),
    );

    final newComponents = Map<String, ComponentModel>.from(components);
    newComponents[componentId] = updatedComponent;

    Logger.logComponentEvent(componentId, 'moved', {
      'from': '(${component.row}, ${component.col})',
      'to': '($newRow, $newCol)',
    });

    return copyWith(
      components: newComponents,
      occupiedPositions: newOccupiedPositions,
      updatedAt: DateTime.now(),
    );
  }

  Grid copyWithUpdatedComponent(ComponentModel updatedComponent) {
    final newComponents = Map<String, ComponentModel>.from(components);
    newComponents[updatedComponent.id] = updatedComponent;

    // Update occupied positions if the component position changed
    final newOccupiedPositions = Set<String>.from(occupiedPositions);
    final oldComponent = components[updatedComponent.id];
    if (oldComponent != null &&
        (oldComponent.row != updatedComponent.row || oldComponent.col != updatedComponent.col)) {
      final oldPositionKey = _positionToKey(oldComponent.row, oldComponent.col);
      final newPositionKey = _positionToKey(updatedComponent.row, updatedComponent.col);
      newOccupiedPositions.remove(oldPositionKey);
      newOccupiedPositions.add(newPositionKey);
    }

    return copyWith(
      components: newComponents,
      occupiedPositions: newOccupiedPositions,
      updatedAt: DateTime.now(),
    );
  }

  // Component queries
  ComponentModel? getComponentAt(int row, int col) {
    final positionKey = _positionToKey(row, col);
    if (!occupiedPositions.contains(positionKey)) {
      return null;
    }

    // Find component at this position
    for (final component in components.values) {
      if (component.row == row && component.col == col) {
        return component;
      }
    }

    return null;
  }

  ComponentModel? componentAt(int row, int col) {
    return getComponentAt(row, col);
  }

  ComponentModel? getComponentById(String id) {
    return components[id];
  }

  Map<String, ComponentModel> get componentsById => components;

  List<ComponentModel> getComponentsByType(ComponentType type) {
    return components.values.where((component) => component.type == type).toList();
  }

  List<ComponentModel> getAllComponents() {
    return components.values.toList();
  }

  // Connection management
  Grid addConnection(String componentId1, String componentId2) {
    final newConnections = Map<String, List<String>>.from(connections);

    if (!newConnections.containsKey(componentId1)) {
      newConnections[componentId1] = [];
    }
    if (!newConnections.containsKey(componentId2)) {
      newConnections[componentId2] = [];
    }

    if (!newConnections[componentId1]!.contains(componentId2)) {
      newConnections[componentId1]!.add(componentId2);
    }
    if (!newConnections[componentId2]!.contains(componentId1)) {
      newConnections[componentId2]!.add(componentId1);
    }

    Logger.logComponentEvent(componentId1, 'connected_to', {'target': componentId2});

    return copyWith(
      connections: newConnections,
      updatedAt: DateTime.now(),
    );
  }

  Grid removeConnection(String componentId1, String componentId2) {
    final newConnections = Map<String, List<String>>.from(connections);

    newConnections[componentId1]?.remove(componentId2);
    newConnections[componentId2]?.remove(componentId1);

    Logger.logComponentEvent(componentId1, 'disconnected_from', {'target': componentId2});

    return copyWith(
      connections: newConnections,
      updatedAt: DateTime.now(),
    );
  }

  List<String> getConnections(String componentId) {
    return connections[componentId] ?? [];
  }

  // Grid utilities
  bool isValidPosition(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  bool isEmpty() {
    return components.isEmpty;
  }

  static Grid empty() {
    return GridFactory.createStandard();
  }

  int getComponentCount() {
    return components.length;
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'components': components.map((key, value) => MapEntry(key, {
        'id': value.id,
        'type': value.type.toString(),
        'row': value.row,
        'col': value.col,
        'state': value.state.toString(),
        'properties': value.properties,
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': value.updatedAt.toIso8601String(),
      })),
      'occupiedPositions': occupiedPositions.toList(),
      'connections': connections,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Grid.fromJson(Map<String, dynamic> json) {
    final componentsJson = json['components'] as Map<String, dynamic>;
    final components = <String, ComponentModel>{};

    for (final entry in componentsJson.entries) {
      final compJson = entry.value as Map<String, dynamic>;
      components[entry.key] = ComponentModel(
        id: compJson['id'],
        type: ComponentType.values.firstWhere(
          (e) => e.toString() == compJson['type'],
        ),
        row: compJson['row'],
        col: compJson['col'],
        state: ComponentState.values.firstWhere(
          (e) => e.toString() == compJson['state'],
          orElse: () => ComponentState.normal,
        ),
        properties: Map<String, dynamic>.from(compJson['properties'] ?? {}),
        createdAt: DateTime.parse(compJson['createdAt']),
        updatedAt: DateTime.parse(compJson['updatedAt']),
      );
    }

    return Grid(
      rows: json['rows'],
      cols: json['cols'],
      components: components,
      occupiedPositions: Set<String>.from(json['occupiedPositions'] ?? []),
      connections: Map<String, List<String>>.from(
        (json['connections'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper methods
  String _positionToKey(int row, int col) {
    return '$row,$col';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grid &&
          runtimeType == other.runtimeType &&
          rows == other.rows &&
          cols == other.cols &&
          components.length == other.components.length;

  @override
  int get hashCode => rows.hashCode ^ cols.hashCode ^ components.length.hashCode;

  @override
  String toString() {
    return 'Grid(rows: $rows, cols: $cols, components: ${components.length})';
  }
}

// Grid factory for creating common grid configurations
class GridFactory {
  static Grid createEmpty(int rows, int cols) {
    return Grid(
      rows: rows,
      cols: cols,
    );
  }

  static Grid createStandard() {
    return createEmpty(10, 15); // Standard 10x15 grid
  }

  static Grid createLarge() {
    return createEmpty(15, 20); // Large grid for complex circuits
  }

  static Grid createSmall() {
    return createEmpty(6, 8); // Small grid for tutorials
  }
}
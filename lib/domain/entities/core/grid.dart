// Grid entity for SparkCircuit
// Represents the circuit grid and manages component placement

import '../../../common/logger.dart';
import 'component.dart';

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
  })  : components = components ?? {},
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
      Logger.w(
          'Cannot place component at position (${component.row}, ${component.col})');
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
        (oldComponent.row != updatedComponent.row ||
            oldComponent.col != updatedComponent.col)) {
      final oldPositionKey = _positionToKey(oldComponent.row, oldComponent.col);
      final newPositionKey =
          _positionToKey(updatedComponent.row, updatedComponent.col);
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
    return components.values
        .where((component) => component.type == type)
        .toList();
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

    Logger.logComponentEvent(
        componentId1, 'connected_to', {'target': componentId2});

    return copyWith(
      connections: newConnections,
      updatedAt: DateTime.now(),
    );
  }

  Grid removeConnection(String componentId1, String componentId2) {
    final newConnections = Map<String, List<String>>.from(connections);

    newConnections[componentId1]?.remove(componentId2);
    newConnections[componentId2]?.remove(componentId1);

    Logger.logComponentEvent(
        componentId1, 'disconnected_from', {'target': componentId2});

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
      'schemaVersion': '1.0.0',
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
    // Schema version handling
    final schemaVersion = json['schemaVersion'] as String? ?? 'legacy';
    Logger.log(
        'Grid.fromJson: Loading grid with schema version: $schemaVersion');

    final componentsJson = json['components'] as Map<String, dynamic>? ?? {};
    final components = <String, ComponentModel>{};
    final parsingErrors = <String>[];

    for (final entry in componentsJson.entries) {
      try {
        final compJson = entry.value as Map<String, dynamic>;

        // Defensive component type parsing
        ComponentType? componentType;
        final typeString = compJson['type'] as String?;
        if (typeString != null) {
          try {
            componentType = ComponentType.values.firstWhere(
              (e) => e.toString() == typeString,
            );
          } catch (e) {
            parsingErrors.add(
                'Unknown component type: $typeString for component ${entry.key}');
            Logger.w(
                'Grid.fromJson: Unknown component type $typeString, using default');
            componentType = ComponentType.wire; // Safe default
          }
        } else {
          parsingErrors
              .add('Missing component type for component ${entry.key}');
          componentType = ComponentType.wire;
        }

        // Safe date parsing
        DateTime createdAt;
        DateTime updatedAt;
        try {
          createdAt = DateTime.parse(
              compJson['createdAt'] ?? DateTime.now().toIso8601String());
          updatedAt = DateTime.parse(
              compJson['updatedAt'] ?? DateTime.now().toIso8601String());
        } catch (e) {
          createdAt = DateTime.now();
          updatedAt = DateTime.now();
          parsingErrors.add('Invalid date format for component ${entry.key}');
        }

        components[entry.key] = ComponentModel(
          id: compJson['id'] ?? entry.key,
          type: componentType,
          row: compJson['row'] ?? 0,
          col: compJson['col'] ?? 0,
          state: ComponentState.values.firstWhere(
            (e) => e.toString() == compJson['state'],
            orElse: () => ComponentState.normal,
          ),
          properties: Map<String, dynamic>.from(compJson['properties'] ?? {}),
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
      } catch (e) {
        parsingErrors.add('Failed to parse component ${entry.key}: $e');
        Logger.w('Grid.fromJson: Failed to parse component ${entry.key}: $e');
      }
    }

    // Log parsing errors if any
    if (parsingErrors.isNotEmpty) {
      Logger.w(
          'Grid.fromJson: ${parsingErrors.length} parsing errors encountered');
      for (final error in parsingErrors) {
        Logger.w('Grid.fromJson: $error');
      }
    }

    // Create grid with validated data
    final grid = Grid(
      rows: json['rows'] ?? 10,
      cols: json['cols'] ?? 15,
      components: components,
      occupiedPositions: Set<String>.from(json['occupiedPositions'] ?? []),
      connections: Map<String, List<String>>.from(
        (json['connections'] ?? {}).map(
              (key, value) => MapEntry(key, List<String>.from(value ?? [])),
            ) ??
            {},
      ),
      createdAt: _safeDateParse(json['createdAt']),
      updatedAt: _safeDateParse(json['updatedAt']),
    );

    // Validate and repair occupied positions
    final repairedGrid = _validateAndRepairOccupiedPositions(grid);
    if (repairedGrid != grid) {
      Logger.log('Grid.fromJson: Repaired occupied positions mismatch');
    }

    return repairedGrid;
  }

  // Helper method for safe date parsing
  static DateTime _safeDateParse(dynamic dateString) {
    if (dateString is String) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        Logger.w('Grid._safeDateParse: Invalid date string: $dateString');
      }
    }
    return DateTime.now();
  }

  // Validate and repair occupied positions consistency
  static Grid _validateAndRepairOccupiedPositions(Grid grid) {
    final expectedOccupied = <String>{};
    for (final component in grid.components.values) {
      expectedOccupied.add(grid._positionToKey(component.row, component.col));
    }

    if (expectedOccupied.length != grid.occupiedPositions.length ||
        !expectedOccupied.containsAll(grid.occupiedPositions)) {
      Logger.w(
          'Grid validation: occupiedPositions mismatch detected, repairing');
      return grid.copyWith(occupiedPositions: expectedOccupied);
    }

    return grid;
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
  int get hashCode =>
      rows.hashCode ^ cols.hashCode ^ components.length.hashCode;

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

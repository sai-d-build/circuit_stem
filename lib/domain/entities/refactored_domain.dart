// ==============================================================================
// CORE DOMAIN ENTITIES - MINIMAL VERSION FOR COMPILATION
// ==============================================================================

// Simplified classes without Freezed to resolve build issues
// This allows us to get the basic structure working first

class Position {
  final int row;
  final int col;

  const Position({
    required this.row,
    required this.col,
  });

  Position offset(int deltaRow, int deltaCol) =>
      Position(row: row + deltaRow, col: col + deltaCol);

  Position get up => Position(row: row - 1, col: col);
  Position get down => Position(row: row + 1, col: col);
  Position get left => Position(row: row, col: col - 1);
  Position get right => Position(row: row, col: col + 1);

  List<Position> get adjacent => [up, right, down, left];

  double distanceTo(Position other) {
    final deltaRow = (row - other.row).abs();
    final deltaCol = (col - other.col).abs();
    return (deltaRow * deltaRow + deltaCol * deltaCol).toDouble();
  }

  bool isAdjacent(Position other) => distanceTo(other) == 1.0;

  bool isWithinBounds(int maxRows, int maxCols) =>
      row >= 0 && row < maxRows && col >= 0 && col < maxCols;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position(row: $row, col: $col)';
}

class Bounds {
  final int rows;
  final int cols;

  const Bounds({
    required this.rows,
    required this.cols,
  });

  bool contains(Position position) =>
      position.isWithinBounds(rows, cols);

  List<Position> get allPositions => [
    for (int r = 0; r < rows; r++)
      for (int c = 0; c < cols; c++)
        Position(row: r, col: c),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bounds &&
          runtimeType == other.runtimeType &&
          rows == other.rows &&
          cols == other.cols;

  @override
  int get hashCode => rows.hashCode ^ cols.hashCode;

  @override
  String toString() => 'Bounds(rows: $rows, cols: $cols)';
}

// Basic component classes for compilation
class ComponentState {
  final Map<String, dynamic> properties;
  final int rotation;
  final bool isEnabled;
  final bool isPowered;
  final bool isSelected;
  final bool isHighlighted;

  const ComponentState({
    this.properties = const {},
    this.rotation = 0,
    this.isEnabled = true,
    this.isPowered = false,
    this.isSelected = false,
    this.isHighlighted = false,
  });

  ComponentState copyWith({
    Map<String, dynamic>? properties,
    int? rotation,
    bool? isEnabled,
    bool? isPowered,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return ComponentState(
      properties: properties ?? this.properties,
      rotation: rotation ?? this.rotation,
      isEnabled: isEnabled ?? this.isEnabled,
      isPowered: isPowered ?? this.isPowered,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

class ComponentModel {
  final String id;
  final String definitionId;
  final Position position;
  final ComponentState state;

  const ComponentModel({
    required this.id,
    required this.definitionId,
    required this.position,
    required this.state,
  });

  // Legacy compatibility
  int get r => position.row;
  int get c => position.col;
  bool get isPowered => state.isPowered;
}

// Basic enums and simple classes
enum ComponentCategory { power, logic, output, wire, utility }
enum ConnectionDirection { north, east, south, west }
enum InteractionMode { select, place, wire, delete, inspect }

// Simple result type
class Result<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  const Result._({required this.isSuccess, this.data, this.error});

  factory Result.success(T data) => Result._(isSuccess: true, data: data);
  factory Result.failure(String error) => Result._(isSuccess: false, error: error);
}

// Placeholder classes for compilation - to be expanded later
class ConnectionPoint {
  final ConnectionDirection direction;
  final bool isInput;
  final bool isOutput;
  final bool isActive;

  const ConnectionPoint({
    required this.direction,
    required this.isInput,
    required this.isOutput,
    this.isActive = true,
  });
}

class ComponentDefinition {
  final String id;
  final String name;
  final ComponentCategory category;
  final List<ConnectionPoint> connectionPoints;

  const ComponentDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.connectionPoints,
  });
}

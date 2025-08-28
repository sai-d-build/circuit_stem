// ==============================================================================
// CORE DOMAIN ENTITIES
// ==============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'refactored_domain.freezed.dart';

// ==============================================================================
// POSITION AND GEOMETRY
// ==============================================================================

@freezed
class Position with _$Position {
  const Position._();
  
  const factory Position({
    required int row,
    required int col,
  }) = _Position;
  
  // Utility methods
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
  
  bool isAdjacent(Position other) =>
      distanceTo(other) == 1.0;
  
  bool isWithinBounds(int maxRows, int maxCols) =>
      row >= 0 && row < maxRows && col >= 0 && col < maxCols;
}

@freezed
class Bounds with _$Bounds {
  const factory Bounds({
    required int rows,
    required int cols,
  }) = _Bounds;
  
  bool contains(Position position) =>
      position.isWithinBounds(rows, cols);
  
  List<Position> get allPositions => [
    for (int r = 0; r < rows; r++)
      for (int c = 0; c < cols; c++)
        Position(row: r, col: c),
  ];
}

// ==============================================================================
// POWER AND CONNECTIONS
// ==============================================================================

enum ConnectionDirection {
  north,
  east,
  south,
  west;
  
  ConnectionDirection get opposite {
    switch (this) {
      case ConnectionDirection.north: return ConnectionDirection.south;
      case ConnectionDirection.east: return ConnectionDirection.west;
      case ConnectionDirection.south: return ConnectionDirection.north;
      case ConnectionDirection.west: return ConnectionDirection.east;
    }
  }
  
  Position getAdjacentPosition(Position from) {
    switch (this) {
      case ConnectionDirection.north: return from.up;
      case ConnectionDirection.east: return from.right;
      case ConnectionDirection.south: return from.down;
      case ConnectionDirection.west: return from.left;
    }
  }
}

@freezed
class ConnectionPoint with _$ConnectionPoint {
  const factory ConnectionPoint({
    required ConnectionDirection direction,
    required bool isInput,
    required bool isOutput,
    @Default(true) bool isActive,
    String? connectionType, // For typed connections (power, data, etc.)
  }) = _ConnectionPoint;
  
  bool canConnectTo(ConnectionPoint other) {
    // Basic rules: outputs connect to inputs, same type
    if (isOutput && other.isInput && isActive && other.isActive) {
      return connectionType == null || 
             other.connectionType == null || 
             connectionType == other.connectionType;
    }
    return false;
  }
}

@freezed
class PowerConnection with _$PowerConnection {
  const factory PowerConnection({
    required String fromComponentId,
    required String toComponentId,
    required ConnectionDirection fromDirection,
    required ConnectionDirection toDirection,
    required double voltage,
    required double current,
    @Default(true) bool isActive,
  }) = _PowerConnection;
}

@freezed
class PowerPath with _$PowerPath {
  const factory PowerPath({
    required List<String> componentIds,
    required List<PowerConnection> connections,
    required double totalResistance,
    required double current,
    required bool hasLoop,
  }) = _PowerPath;
}

@freezed
class PowerFlowState with _$PowerFlowState {
  const PowerFlowState._();
  
  const factory PowerFlowState({
    required Map<String, bool> componentPowerStates,
    required List<PowerPath> activePaths,
    required List<PowerConnection> activeConnections,
    @Default(false) bool hasShortCircuit,
    @Default([]) List<String> shortCircuitComponents,
    required List<String> poweredOutputs,
    required double totalPowerConsumption,
    required DateTime calculatedAt,
  }) = _PowerFlowState;
  
  bool isComponentPowered(String componentId) =>
      componentPowerStates[componentId] ?? false;
  
  List<PowerConnection> getConnectionsFor(String componentId) =>
      activeConnections.where((conn) => 
          conn.fromComponentId == componentId || 
          conn.toComponentId == componentId).toList();
  
  PowerFlowState withUpdatedComponent(String componentId, bool isPowered) =>
      copyWith(
        componentPowerStates: {
          ...componentPowerStates,
          componentId: isPowered,
        },
      );
}

// ==============================================================================
// COMPONENT SYSTEM
// ==============================================================================

enum ComponentCategory {
  power,      // Batteries, generators
  logic,      // Gates, switches
  output,     // Buzzers, LEDs
  wire,       // Conductors
  utility,    // Tools, special components
}

@freezed
class ComponentProperty with _$ComponentProperty {
  const factory ComponentProperty({
    required String key,
    required dynamic value,
    required Type type,
    String? displayName,
    String? description,
    dynamic minValue,
    dynamic maxValue,
    List<dynamic>? allowedValues,
  }) = _ComponentProperty;
}

@freezed
class ComponentState with _$ComponentState {
  const ComponentState._();
  
  const factory ComponentState({
    required Map<String, dynamic> properties,
    required int rotation, // 0, 90, 180, 270 degrees
    @Default(true) bool isEnabled,
    @Default(false) bool isPowered,
    @Default(false) bool isSelected,
    @Default(false) bool isHighlighted,
    Map<String, dynamic>? customData,
  }) = _ComponentState;
  
  T? getProperty<T>(String key) => properties[key] as T?;
  
  ComponentState setProperty(String key, dynamic value) =>
      copyWith(properties: {...properties, key: value});
  
  ComponentState toggleProperty(String key) {
    final current = getProperty<bool>(key) ?? false;
    return setProperty(key, !current);
  }
  
  ComponentState rotate(int degrees) =>
      copyWith(rotation: (rotation + degrees) % 360);
}

@freezed
class ComponentDefinition with _$ComponentDefinition {
  const factory ComponentDefinition({
    required String id,
    required String name,
    required ComponentCategory category,
    required String type,
    required List<ConnectionPoint> connectionPoints,
    required Map<String, ComponentProperty> defaultProperties,
    String? description,
    String? iconPath,
    @Default([]) List<String> tags,
    @Default(true) bool isRotatable,
    @Default(true) bool isMovable,
    @Default(false) bool isUnique, // Only one allowed per level
    Map<String, dynamic>? renderSettings,
  }) = _ComponentDefinition;
  
  ComponentModel createInstance({
    required String instanceId,
    required Position position,
    ComponentState? initialState,
  }) {
    final state = initialState ?? ComponentState(
      properties: defaultProperties.map((k, v) => MapEntry(k, v.value)),
      rotation: 0,
    );
    
    return ComponentModel(
      id: instanceId,
      definitionId: id,
      position: position,
      state: state,
      definition: this,
    );
  }
}

@freezed
class ComponentModel with _$ComponentModel {
  const ComponentModel._();
  
  const factory ComponentModel({
    required String id,
    required String definitionId,
    required Position position,
    required ComponentState state,
    required ComponentDefinition definition,
    DateTime? createdAt,
    DateTime? lastModified,
  }) = _ComponentModel;
  
  // Legacy compatibility
  int get r => position.row;
  int get c => position.col;
  bool get isPowered => state.isPowered;
  
  ComponentModel moveTo(Position newPosition) =>
      copyWith(position: newPosition, lastModified: DateTime.now());
  
  ComponentModel updateState(ComponentState newState) =>
      copyWith(state: newState, lastModified: DateTime.now());
  
  ComponentModel rotate(int degrees) =>
      updateState(state.rotate(degrees));
  
  ComponentModel setPowered(bool powered) =>
      updateState(state.copyWith(isPowered: powered));
  
  List<ConnectionPoint> get activeConnectionPoints =>
      definition.connectionPoints.where((cp) => cp.isActive).toList();
  
  List<ConnectionPoint> getConnectionPointsForDirection(ConnectionDirection dir) =>
      activeConnectionPoints.where((cp) => cp.direction == dir).toList();
  
  bool canConnectTo(ComponentModel other) {
    for (final myPoint in activeConnectionPoints) {
      final otherPos = myPoint.direction.getAdjacentPosition(position);
      if (otherPos == other.position) {
        final oppositeDir = myPoint.direction.opposite;
        final otherPoints = other.getConnectionPointsForDirection(oppositeDir);
        
        for (final otherPoint in otherPoints) {
          if (myPoint.canConnectTo(otherPoint)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

// ==============================================================================
// GAME SESSION AND PROGRESS
// ==============================================================================

enum GameSessionStatus {
  notStarted,
  playing,
  paused,
  completed,
  failed,
  abandoned,
}

@freezed
class GameSession with _$GameSession {
  const GameSession._();
  
  const factory GameSession({
    required String id,
    required String levelId,
    required GameSessionStatus status,
    required DateTime startTime,
    DateTime? endTime,
    required int moveCount,
    required int undoCount,
    required int rotationCount,
    @Default(0) int score,
    Map<String, dynamic>? metadata,
  }) = _GameSession;
  
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  bool get isActive => 
      status == GameSessionStatus.playing || 
      status == GameSessionStatus.paused;
  
  bool get isCompleted => status == GameSessionStatus.completed;
  
  GameSession incrementMove() =>
      copyWith(moveCount: moveCount + 1);
  
  GameSession incrementUndo() =>
      copyWith(undoCount: undoCount + 1);
  
  GameSession incrementRotation() =>
      copyWith(rotationCount: rotationCount + 1);
  
  GameSession complete(int finalScore) =>
      copyWith(
        status: GameSessionStatus.completed,
        endTime: DateTime.now(),
        score: finalScore,
      );
}

@freezed
class GameGoal with _$GameGoal {
  const factory GameGoal({
    required String id,
    required String description,
    required GoalType type,
    required Map<String, dynamic> criteria,
    @Default(false) bool isCompleted,
    @Default(false) bool isOptional,
    @Default(1) int points,
  }) = _GameGoal;
}

enum GoalType {
  powerComponent,     // Power specific components
  useMaxComponents,   // Use at most X components
  useMinComponents,   // Use at least X components
  completeInTime,     // Complete within time limit
  completeInMoves,    // Complete within move limit
  avoidShortCircuit,  // Don't create short circuits
  custom,             // Custom scripted goal
}

@freezed
class GameProgressState with _$GameProgressState {
  const GameProgressState._();
  
  const factory GameProgressState({
    required List<GameGoal> goals,
    required Set<String> completedGoalIds,
    required int score,
    required bool isWin,
    @Default(false) bool hasShortCircuit,
    Map<String, int>? achievements,
  }) = _GameProgressState;
  
  List<GameGoal> get completedGoals =>
      goals.where((goal) => completedGoalIds.contains(goal.id)).toList();
  
  List<GameGoal> get remainingGoals =>
      goals.where((goal) => !completedGoalIds.contains(goal.id)).toList();
  
  double get progressPercentage {
    if (goals.isEmpty) return 1.0;
    return completedGoalIds.length / goals.length;
  }
  
  bool get allRequiredGoalsCompleted =>
      goals.where((g) => !g.isOptional).every((g) => completedGoalIds.contains(g.id));
  
  GameProgressState completeGoal(String goalId) {
    final goal = goals.firstWhere((g) => g.id == goalId);
    return copyWith(
      completedGoalIds: {...completedGoalIds, goalId},
      score: score + goal.points,
    );
  }
}

// ==============================================================================
// INTERACTION AND UI STATE
// ==============================================================================

enum InteractionMode {
  select,     // Select and interact with components
  place,      // Place new components
  wire,       // Connect components with wires
  delete,     // Delete components
  inspect,    // View component details
}

@freezed
class InteractionContext with _$InteractionContext {
  const factory InteractionContext({
    required ComponentModel? targetComponent,
    required Position? targetPosition,
    required InteractionMode mode,
    Map<String, dynamic>? metadata,
  }) = _InteractionContext;
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    required InteractionMode mode,
    String? selectedComponentId,
    String? selectedPaletteComponentId,
    String? draggedComponentId,
    Position? dragPosition,
    @Default([]) List<String> highlightedComponentIds,
    InteractionContext? currentInteraction,
  }) = _InteractionState;
  
  bool get isDragging => draggedComponentId != null;
  bool get hasSelection => selectedComponentId != null;
  bool get hasPaletteSelection => selectedPaletteComponentId != null;
}

// ==============================================================================
// LEVEL DEFINITION EXTENSIONS
// ==============================================================================

@freezed
class LevelConstraints with _$LevelConstraints {
  const factory LevelConstraints({
    int? maxComponents,
    int? minComponents,
    Duration? timeLimit,
    int? moveLimit,
    @Default([]) List<String> allowedComponentTypes,
    @Default([]) List<String> bannedComponentTypes,
    @Default(false) bool allowShortCircuits,
  }) = _LevelConstraints;
}

@freezed
class LevelHints with _$LevelHints {
  const factory LevelHints({
    @Default([]) List<String> textHints,
    @Default([]) List<Position> highlightPositions,
    @Default([]) List<String> highlightComponentIds,
    String? videoUrl,
    Map<String, dynamic>? interactiveHints,
  }) = _LevelHints;
}

@freezed
class LevelState with _$LevelState {
  const factory LevelState({
    LevelDefinition? definition,
    @Default(LevelLoadingStatus.notLoaded) LevelLoadingStatus status,
    String? error,
    LevelConstraints? constraints,
    LevelHints? hints,
    DateTime? loadedAt,
  }) = _LevelState;
}

enum LevelLoadingStatus {
  notLoaded,
  loading,
  loaded,
  error,
}

// ==============================================================================
// GRID DELTA FOR EFFICIENT HISTORY
// ==============================================================================

@freezed
class ComponentDelta with _$ComponentDelta {
  const factory ComponentDelta.added({
    required ComponentModel component,
  }) = ComponentAdded;
  
  const factory ComponentDelta.removed({
    required String componentId,
    required ComponentModel originalComponent,
  }) = ComponentRemoved;
  
  const factory ComponentDelta.moved({
    required String componentId,
    required Position oldPosition,
    required Position newPosition,
  }) = ComponentMoved;
  
  const factory ComponentDelta.stateChanged({
    required String componentId,
    required ComponentState oldState,
    required ComponentState newState,
  }) = ComponentStateChanged;
}

@freezed
class GridDelta with _$GridDelta {
  const GridDelta._();
  
  const factory GridDelta({
    required List<ComponentDelta> changes,
    required DateTime timestamp,
    String? description,
  }) = _GridDelta;
  
  GridDelta inverse() {
    final inverseChanges = changes.reversed.map((delta) {
      return delta.when(
        added: (component) => ComponentDelta.removed(
          componentId: component.id,
          originalComponent: component,
        ),
        removed: (id, original) => ComponentDelta.added(component: original),
        moved: (id, oldPos, newPos) => ComponentDelta.moved(
          componentId: id,
          oldPosition: newPos,
          newPosition: oldPos,
        ),
        stateChanged: (id, oldState, newState) => ComponentDelta.stateChanged(
          componentId: id,
          oldState: newState,
          newState: oldState,
        ),
      );
    }).toList();
    
    return GridDelta(
      changes: inverseChanges,
      timestamp: DateTime.now(),
      description: 'Undo: $description',
    );
  }
}

// ==============================================================================
// RESULT TYPE FOR ERROR HANDLING
// ==============================================================================

@freezed
class Result<T> with _$Result<T> {
  const Result._();
  
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String error, {Exception? exception}) = Failure<T>;
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  String? get error => isFailure ? (this as Failure<T>).error : null;
  
  R fold<R>(R Function(T data) onSuccess, R Function(String error) onFailure) {
    return when(
      success: onSuccess,
      failure: (error, _) => onFailure(error),
    );
  }
  
  Result<R> map<R>(R Function(T) mapper) {
    return fold(
      (data) => Result.success(mapper(data)),
      (error) => Result.failure(error),
    );
  }
  
  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return fold(
      (data) => mapper(data),
      (error) => Result.failure(error),
    );
  }
  
  Result<void> toVoidResult() {
    return fold(
      (_) => const Result.success(null),
      (error) => Result.failure(error),
    );
  }
  
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final successes = <T>[];
    for (final result in results) {
      if (result.isFailure) {
        return Result.failure(result.error!);
      }
      successes.add(result.data!);
    }
    return Result.success(successes);
  }
}

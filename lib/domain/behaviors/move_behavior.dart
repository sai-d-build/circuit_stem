// Move behavior interface for circuit components
// Defines the behavior for components that can be moved on the grid

import '../entities/component.dart';
import '../entities/grid.dart';

abstract class MoveBehavior {
  ComponentModel? handle(ComponentModel component, String action, dynamic context);
  bool canMove(ComponentModel component, int newRow, int newCol, Grid grid);
  String get behaviorType;
}

// Base implementation of move behavior
class BaseMoveBehavior implements MoveBehavior {
  @override
  ComponentModel? handle(ComponentModel component, String action, dynamic context) {
    // Base implementation - override in subclasses
    return component;
  }

  @override
  bool canMove(ComponentModel component, int newRow, int newCol, Grid grid) {
    return grid.canPlaceComponent(newRow, newCol);
  }

  @override
  String get behaviorType => 'base';
}

// Standard move behavior for most components
class StandardMoveBehavior extends BaseMoveBehavior {
  @override
  ComponentModel? handle(ComponentModel component, String action, dynamic context) {
    if (action != 'move' || context is! GameContext) {
      return component;
    }

    final gameContext = context as GameContext;
    final newRow = gameContext.toRow;
    final newCol = gameContext.toCol;

    if (canMove(component, newRow, newCol, gameContext.grid)) {
      return component.copyWith(
        row: newRow,
        col: newCol,
        updatedAt: DateTime.now(),
      );
    }

    return component;
  }

  @override
  String get behaviorType => 'standard';
}

// Restricted move behavior for components with movement limitations
class RestrictedMoveBehavior extends BaseMoveBehavior {
  final Set<String> allowedDirections;

  RestrictedMoveBehavior(this.allowedDirections);

  @override
  bool canMove(ComponentModel component, int newRow, int newCol, Grid grid) {
    if (!super.canMove(component, newRow, newCol, grid)) {
      return false;
    }

    final deltaRow = newRow - component.row;
    final deltaCol = newCol - component.col;

    // Check if movement is in allowed direction
    if (deltaRow > 0 && !allowedDirections.contains('down')) return false;
    if (deltaRow < 0 && !allowedDirections.contains('up')) return false;
    if (deltaCol > 0 && !allowedDirections.contains('right')) return false;
    if (deltaCol < 0 && !allowedDirections.contains('left')) return false;

    return true;
  }

  @override
  String get behaviorType => 'restricted';
}

// Immovable behavior for components that cannot be moved
class ImmovableMoveBehavior extends BaseMoveBehavior {
  @override
  bool canMove(ComponentModel component, int newRow, int newCol, Grid grid) {
    return false; // Never allow movement
  }

  @override
  String get behaviorType => 'immovable';
}

// Context class for move operations
class GameContext {
  final Grid grid;
  final int toRow;
  final int toCol;

  const GameContext({
    required this.grid,
    required this.toRow,
    required this.toCol,
  });
}

// Move result class
class MoveResult {
  final bool success;
  final ComponentModel? updatedComponent;
  final String? errorMessage;

  const MoveResult({
    required this.success,
    this.updatedComponent,
    this.errorMessage,
  });

  factory MoveResult.success(ComponentModel component) {
    return MoveResult(success: true, updatedComponent: component);
  }

  factory MoveResult.failure(String error) {
    return MoveResult(success: false, errorMessage: error);
  }
}
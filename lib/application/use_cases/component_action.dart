import 'package:equatable/equatable.dart';

// Domain entities
import 'package:sparkcircuit/domain/entities/entities.dart';

// Application core
import '../core/result.dart';
import '../game_engine_state.dart';

abstract class ComponentAction extends Equatable {
  const ComponentAction();

  String get type => runtimeType.toString();
  Map<String, dynamic> get metadata => {};

  Result<void> validate(GameEngineState state) {
    return const Success(null);
  }
}

class LoadLevelAction extends ComponentAction {
  final LevelDefinition level;

  const LoadLevelAction(this.level);

  @override
  List<Object?> get props => [level];
}

class CreateComponentFromTemplateAction extends ComponentAction {
  final String templateId;
  final int row;
  final int col;

  const CreateComponentFromTemplateAction({
    required this.templateId,
    required this.row,
    required this.col,
  });

  @override
  List<Object?> get props => [templateId, row, col];

  @override
  Map<String, dynamic> get metadata => {
        'templateId': templateId,
        'position': {'row': row, 'col': col},
      };

  @override
  Result<void> validate(GameEngineState state) {
    if (row < 0 || col < 0) {
      return const Failure(
          'Invalid position: coordinates must be non-negative');
    }

    if (state.currentLevel != null) {
      if (row >= state.currentLevel!.grid.height ||
          col >= state.currentLevel!.grid.width) {
        return const Failure('Position out of bounds');
      }
    }

    final existingComponent = state.grid.componentAt(row, col);
    if (existingComponent != null) {
      return const Failure('Cell already occupied');
    }

    return const Success(null);
  }
}

class MoveComponentAction extends ComponentAction {
  final String componentId;
  final int newRow;
  final int newCol;

  const MoveComponentAction({
    required this.componentId,
    required this.newRow,
    required this.newCol,
  });

  @override
  List<Object?> get props => [componentId, newRow, newCol];

  @override
  Map<String, dynamic> get metadata => {
        'componentId': componentId,
        'newPosition': {'row': newRow, 'col': newCol},
      };

  @override
  Result<void> validate(GameEngineState state) {
    final component = state.grid.componentsById[componentId];
    if (component == null) {
      return const Failure('Component not found');
    }

    if (newRow < 0 || newCol < 0) {
      return const Failure(
          'Invalid position: coordinates must be non-negative');
    }

    if (state.currentLevel != null) {
      if (newRow >= state.currentLevel!.grid.height ||
          newCol >= state.currentLevel!.grid.width) {
        return const Failure('Position out of bounds');
      }
    }

    final existingComponent = state.grid.componentAt(newRow, newCol);
    if (existingComponent != null && existingComponent.id != componentId) {
      return const Failure('Target cell already occupied');
    }

    return const Success(null);
  }
}

class TapComponentAction extends ComponentAction {
  final String componentId;

  const TapComponentAction({required this.componentId});

  @override
  List<Object?> get props => [componentId];

  @override
  Map<String, dynamic> get metadata => {'componentId': componentId};

  @override
  Result<void> validate(GameEngineState state) {
    final component = state.grid.componentsById[componentId];
    if (component == null) {
      return const Failure('Component not found');
    }
    return const Success(null);
  }
}

class RotateComponentAction extends ComponentAction {
  final String componentId;
  final int rotation;

  const RotateComponentAction({
    required this.componentId,
    required this.rotation,
  });

  @override
  List<Object?> get props => [componentId, rotation];

  @override
  Map<String, dynamic> get metadata => {
        'componentId': componentId,
        'rotation': rotation,
      };

  @override
  Result<void> validate(GameEngineState state) {
    final component = state.grid.componentsById[componentId];
    if (component == null) {
      return const Failure('Component not found');
    }

    if (rotation % 90 != 0) {
      return const Failure('Rotation must be a multiple of 90 degrees');
    }

    return const Success(null);
  }
}

class UpdateComponentAction extends ComponentAction {
  final String componentId;
  final Map<String, dynamic> newState;

  const UpdateComponentAction({
    required this.componentId,
    required this.newState,
  });

  @override
  List<Object?> get props => [componentId, newState];

  @override
  Map<String, dynamic> get metadata => {
        'componentId': componentId,
        'newState': newState,
      };
}

class RestartLevelAction extends ComponentAction {
  const RestartLevelAction();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get metadata => {'action': 'restart'};
}

class SelectPaletteComponentAction extends ComponentAction {
  final String componentId;

  const SelectPaletteComponentAction({required this.componentId});

  @override
  List<Object?> get props => [componentId];

  @override
  Map<String, dynamic> get metadata => {'componentId': componentId};
}

class TogglePauseAction extends ComponentAction {
  const TogglePauseAction();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get metadata => {'action': 'toggle_pause'};
}

class UndoAction extends ComponentAction {
  const UndoAction();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get metadata => {'action': 'undo'};

  @override
  Result<void> validate(GameEngineState state) {
    if (state.history.isEmpty) {
      return const Failure('No actions to undo');
    }
    return const Success(null);
  }
}

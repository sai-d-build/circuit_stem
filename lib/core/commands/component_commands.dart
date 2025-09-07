import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'command.dart';
import '../../../core/debug/structured_logger.dart';
import '../../../domain/entities/core/component.dart';
import '../../../presentation/features/game/controllers/game_canvas_state_notifier.dart';
import '../../../core/services/optimized_grid_manager.dart';

/// Command for placing a component on the grid
class PlaceComponentCommand implements Command {
  final Offset position;
  final ComponentType componentType;
  final GameCanvasStateNotifier canvasController;
  final WidgetRef ref;

  ComponentModel? _placedComponent;
  bool _wasOccupied = false;
  final String _commandId;
  final DateTime _timestamp;

  PlaceComponentCommand({
    required this.position,
    required this.componentType,
    required this.canvasController,
    required this.ref,
  }) :
    _commandId = 'PlaceComponent_${DateTime.now().millisecondsSinceEpoch}',
    _timestamp = DateTime.now();

  @override
  String get id => _commandId;

  @override
  DateTime get timestamp => _timestamp;

  @override
  bool get canUndo => true;

  @override
  bool get canRedo => true;

  @override
  String get description => 'Place ${componentType.toString().split('.').last} at ${position.toString()}';

  @override
  Future<CommandResult> execute() async {
    try {
      StructuredLogger.info('Executing place component command', context: {
        'position': position.toString(),
        'componentType': componentType.toString(),
        'commandId': id,
      });

      // Check if position is available
      final gridManager = ref.read(gridManagerProvider);
      if (!gridManager.canPlaceComponent(position)) {
        return CommandResult.failure(
          errorMessage: 'Position ${position.toString()} is not available for component placement',
          data: {'position': position.toString(), 'componentType': componentType.toString()},
        );
      }

      // Place the component
      gridManager.placeComponent(position);

      // Create component model for tracking
      _placedComponent = ComponentModel(
        id: 'component_${DateTime.now().millisecondsSinceEpoch}',
        type: componentType,
        row: position.dy.round(),
        col: position.dx.round(),
        state: ComponentState.normal,
        properties: {},
      );

      StructuredLogger.info('Component placed successfully', context: {
        'componentId': _placedComponent!.id,
        'position': position.toString(),
        'componentType': componentType.toString(),
      });

      return CommandResult.success(
        data: {
          'componentId': _placedComponent!.id,
          'position': position.toString(),
          'componentType': componentType.toString(),
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Place component command failed', context: {
        'error': e.toString(),
        'position': position.toString(),
        'componentType': componentType.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Failed to place component: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Future<CommandResult> undo() async {
    if (_placedComponent == null) {
      return CommandResult.failure(errorMessage: 'No component to remove');
    }

    try {
      StructuredLogger.info('Undoing place component command', context: {
        'componentId': _placedComponent!.id,
        'position': position.toString(),
        'componentType': componentType.toString(),
      });

      // Remove the component
      final gridManager = ref.read(gridManagerProvider);
      gridManager.removeComponent(position);

      StructuredLogger.info('Component removed successfully', context: {
        'componentId': _placedComponent!.id,
        'position': position.toString(),
      });

      return CommandResult.success(
        data: {
          'componentId': _placedComponent!.id,
          'position': position.toString(),
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Undo place component command failed', context: {
        'error': e.toString(),
        'componentId': _placedComponent?.id,
      });

      return CommandResult.failure(
        errorMessage: 'Failed to undo component placement: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': runtimeType.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'canUndo': canUndo,
      'canRedo': canRedo,
      'positionDx': position.dx,
      'positionDy': position.dy,
      'componentType': componentType.toString(),
      'placedComponentId': _placedComponent?.id,
      'wasOccupied': _wasOccupied,
    };
  }
}

/// Command for removing a component from the grid
class RemoveComponentCommand implements Command {
  final Offset position;
  final GameCanvasStateNotifier canvasController;
  final WidgetRef ref;

  ComponentModel? _removedComponent;
  final String _commandId;
  final DateTime _timestamp;

  RemoveComponentCommand({
    required this.position,
    required this.canvasController,
    required this.ref,
  }) :
    _commandId = 'RemoveComponent_${DateTime.now().millisecondsSinceEpoch}',
    _timestamp = DateTime.now();

  @override
  String get id => _commandId;

  @override
  DateTime get timestamp => _timestamp;

  @override
  bool get canUndo => true;

  @override
  bool get canRedo => true;

  @override
  String get description => 'Remove component at ${position.toString()}';

  @override
  Future<CommandResult> execute() async {
    try {
      StructuredLogger.info('Executing remove component command', context: {
        'position': position.toString(),
        'commandId': id,
      });

      final gridManager = ref.read(gridManagerProvider);

      // Check if there's a component to remove
      if (!gridManager.isPositionOccupied(position)) {
        return CommandResult.failure(
          errorMessage: 'No component at position ${position.toString()}',
          data: {'position': position.toString()},
        );
      }

      // Store component information before removal
      _removedComponent = ComponentModel(
        id: 'removed_${DateTime.now().millisecondsSinceEpoch}',
        type: ComponentType.wire, // Placeholder - would need to get actual type
        row: position.dy.round(),
        col: position.dx.round(),
        state: ComponentState.normal,
        properties: {},
      );

      // Remove the component
      gridManager.removeComponent(position);

      StructuredLogger.info('Component removed successfully', context: {
        'position': position.toString(),
        'componentId': _removedComponent!.id,
      });

      return CommandResult.success(
        data: {
          'position': position.toString(),
          'componentId': _removedComponent!.id,
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Remove component command failed', context: {
        'error': e.toString(),
        'position': position.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Failed to remove component: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Future<CommandResult> undo() async {
    if (_removedComponent == null) {
      return CommandResult.failure(errorMessage: 'No component to restore');
    }

    try {
      StructuredLogger.info('Undoing remove component command', context: {
        'position': position.toString(),
        'componentId': _removedComponent!.id,
      });

      // Restore the component
      final gridManager = ref.read(gridManagerProvider);
      gridManager.placeComponent(position);

      StructuredLogger.info('Component restored successfully', context: {
        'position': position.toString(),
        'componentId': _removedComponent!.id,
      });

      return CommandResult.success(
        data: {
          'position': position.toString(),
          'componentId': _removedComponent!.id,
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Undo remove component command failed', context: {
        'error': e.toString(),
        'componentId': _removedComponent?.id,
      });

      return CommandResult.failure(
        errorMessage: 'Failed to undo component removal: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': runtimeType.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'canUndo': canUndo,
      'canRedo': canRedo,
      'positionDx': position.dx,
      'positionDy': position.dy,
      'removedComponentId': _removedComponent?.id,
    };
  }
}

/// Command for moving a component to a new position
class MoveComponentCommand implements Command {
  final Offset fromPosition;
  final Offset toPosition;
  final GameCanvasStateNotifier canvasController;
  final WidgetRef ref;

  ComponentModel? _movedComponent;
  final String _commandId;
  final DateTime _timestamp;

  MoveComponentCommand({
    required this.fromPosition,
    required this.toPosition,
    required this.canvasController,
    required this.ref,
  }) :
    _commandId = 'MoveComponent_${DateTime.now().millisecondsSinceEpoch}',
    _timestamp = DateTime.now();

  @override
  String get id => _commandId;

  @override
  DateTime get timestamp => _timestamp;

  @override
  bool get canUndo => true;

  @override
  bool get canRedo => true;

  @override
  String get description => 'Move component from ${fromPosition.toString()} to ${toPosition.toString()}';

  @override
  Future<CommandResult> execute() async {
    try {
      StructuredLogger.info('Executing move component command', context: {
        'fromPosition': fromPosition.toString(),
        'toPosition': toPosition.toString(),
        'commandId': id,
      });

      final gridManager = ref.read(gridManagerProvider);

      // Validate the move
      if (!gridManager.isPositionOccupied(fromPosition)) {
        return CommandResult.failure(
          errorMessage: 'No component at source position ${fromPosition.toString()}',
          data: {'fromPosition': fromPosition.toString()},
        );
      }

      if (!gridManager.canPlaceComponent(toPosition)) {
        return CommandResult.failure(
          errorMessage: 'Destination position ${toPosition.toString()} is not available',
          data: {'toPosition': toPosition.toString()},
        );
      }

      // Store component information
      _movedComponent = ComponentModel(
        id: 'moved_${DateTime.now().millisecondsSinceEpoch}',
        type: ComponentType.wire, // Placeholder
        row: fromPosition.dy.round(),
        col: fromPosition.dx.round(),
        state: ComponentState.normal,
        properties: {},
      );

      // Perform the move
      gridManager.removeComponent(fromPosition);
      gridManager.placeComponent(toPosition);

      StructuredLogger.info('Component moved successfully', context: {
        'fromPosition': fromPosition.toString(),
        'toPosition': toPosition.toString(),
        'componentId': _movedComponent!.id,
      });

      return CommandResult.success(
        data: {
          'fromPosition': fromPosition.toString(),
          'toPosition': toPosition.toString(),
          'componentId': _movedComponent!.id,
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Move component command failed', context: {
        'error': e.toString(),
        'fromPosition': fromPosition.toString(),
        'toPosition': toPosition.toString(),
      });

      return CommandResult.failure(
        errorMessage: 'Failed to move component: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Future<CommandResult> undo() async {
    try {
      StructuredLogger.info('Undoing move component command', context: {
        'fromPosition': fromPosition.toString(),
        'toPosition': toPosition.toString(),
        'componentId': _movedComponent?.id,
      });

      final gridManager = ref.read(gridManagerProvider);

      // Move back to original position
      gridManager.removeComponent(toPosition);
      gridManager.placeComponent(fromPosition);

      StructuredLogger.info('Component move undone successfully', context: {
        'fromPosition': fromPosition.toString(),
        'toPosition': toPosition.toString(),
        'componentId': _movedComponent?.id,
      });

      return CommandResult.success(
        data: {
          'fromPosition': fromPosition.toString(),
          'toPosition': toPosition.toString(),
          'componentId': _movedComponent?.id,
        },
        type: CommandResultType.success,
      );
    } catch (e) {
      StructuredLogger.error('Undo move component command failed', context: {
        'error': e.toString(),
        'componentId': _movedComponent?.id,
      });

      return CommandResult.failure(
        errorMessage: 'Failed to undo component move: $e',
        data: {'exception': e.toString()},
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': runtimeType.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'canUndo': canUndo,
      'canRedo': canRedo,
      'fromPositionDx': fromPosition.dx,
      'fromPositionDy': fromPosition.dy,
      'toPositionDx': toPosition.dx,
      'toPositionDy': toPosition.dy,
      'movedComponentId': _movedComponent?.id,
    };
  }
}

/// Provider for grid manager
final gridManagerProvider = Provider<OptimizedGridManager>((ref) {
  return OptimizedGridManager();
});
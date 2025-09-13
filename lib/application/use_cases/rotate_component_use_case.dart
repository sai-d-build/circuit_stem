import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class RotateComponentUseCase
    extends NotifierIntegratedUseCase<RotateComponentAction> {
  const RotateComponentUseCase();

  @override
  Result<void> validate(
      RotateComponentAction action, NotifierContext notifiers) {
    final component = notifiers.grid.current.componentsById[action.componentId];
    if (component == null) {
      return const Failure('Component not found');
    }

    if (action.rotation % 90 != 0) {
      return const Failure('Rotation must be a multiple of 90 degrees');
    }

    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    RotateComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;
      final component = currentGrid.componentsById[action.componentId];

      if (component == null) {
        return const Failure('Component not found');
      }

      // Register grid update with transaction
      transaction.onCommit(() async {
        final updatedComponent = component.copyWith(rotation: action.rotation);
        final newGrid = currentGrid.copyWithUpdatedComponent(updatedComponent);
        notifiers.grid.setState(newGrid);
      });

      // Register rollback handler
      transaction.onRollback(() {
        // Rollback is handled automatically by the grid notifier's transaction support
      });

      return const Success(null);
    } catch (e) {
      return Failure('RotateComponent error: $e');
    }
  }
}

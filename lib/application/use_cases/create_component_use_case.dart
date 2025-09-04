import '../services/power_simulation_service.dart';
import '../services/component_factory.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

/// Use case for creating a component from a template
class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final PowerSimulationService _simulation;
  final ComponentFactory _factory;

  const CreateComponentUseCase(this._simulation, this._factory);

  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      // Validate position
      if (action.row < 0 || action.col < 0) {
        return const Failure('Invalid position: coordinates must be non-negative');
      }

      // Check if cell is already occupied
      final existingComponent = notifiers.grid.current.componentAt(action.row, action.col);
      if (existingComponent != null) {
        return const Failure('Cell already occupied');
      }

      // Create component using factory (now returns CircuitComponent)
      final newCircuitComponent = _factory.create(
        type: 'wire', // Default to wire for now
        id: 'component_${DateTime.now().millisecondsSinceEpoch}',
        r: action.row,
        c: action.col,
      );

      // Convert to ComponentModel for Grid operations
      final newComponent = newCircuitComponent.toComponentModel();

      // Register grid update with transaction
      transaction.onCommit(() async {
        final updatedComponents = Map<String, ComponentModel>.from(notifiers.grid.current.components);
        updatedComponents[newComponent.id] = newComponent;

        final newGrid = notifiers.grid.current.copyWith(components: updatedComponents);

        // Run simulation
        final simulatedGrid = _simulation.simulatePowerFlow(newGrid);

        // Update the grid notifier
        notifiers.grid.setState(simulatedGrid);

        Logger.log('CreateComponent: added component at (${action.row}, ${action.col})');
      });

      // Register rollback handler
      transaction.onRollback(() {
        Logger.log('CreateComponent: rollback - component creation reverted');
      });

      return const Success(null);
    } catch (e) {
      Logger.log('❌ CreateComponent error: $e');
      return Failure('CreateComponent error: $e');
    }
  }
}
import '../services/power_simulation_service.dart';
import '../services/component_factory.dart';
import '../../domain/entities/component.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';
import '../transaction.dart';

/// Use case for creating a component from a template
class CreateComponentUseCaseV2 extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final ComponentFactory _factory;
  final PowerSimulationService _simulation;

  const CreateComponentUseCaseV2(this._factory, this._simulation);

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

      // Update grid with new component
            final updatedComponents = Map<String, ComponentModel>.from(notifiers.grid.current.components);
      updatedComponents[newComponent.id] = newComponent;

            final newGrid = notifiers.grid.current.copyWith(components: updatedComponents);

      // Run simulation
      final simulatedGrid = _simulation.simulatePowerFlow(newGrid);

            // Update the grid notifier
      notifiers.grid.setState(simulatedGrid);

      Logger.log('CreateComponent: added component at (${action.row}, ${action.col})');
      return const Success(null);
    } catch (e) {
      Logger.log('❌ CreateComponent error: $e');
      return Failure('CreateComponent error: $e');
    }
  }
}

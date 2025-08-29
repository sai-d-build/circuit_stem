import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/services/component_factory.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

/// Notifier-integrated implementation of CreateComponentFromTemplateAction
/// - Uses the ComponentPaletteManager available in NotifierContext to resolve a template
/// - Uses ComponentFactory to create a new instance (centralized id generation)
/// - Registers a single transaction.onCommit handler that updates GridNotifier and runs simulation
class CreateComponentFromTemplateUseCaseV2
    extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final PowerSimulationService _simulation;
  final ComponentFactory _factory;

  const CreateComponentFromTemplateUseCaseV2(this._simulation, this._factory);

  @override
  Result<void> validate(CreateComponentFromTemplateAction action, NotifierContext notifiers) {
    final currentGrid = notifiers.grid.current;

    if (action.row < 0 || action.col < 0) {
      return const Failure('Invalid position: coordinates must be non-negative');
    }

    // Check if cell is already occupied
    final existingComponent = currentGrid.componentAt(action.row, action.col);
    if (existingComponent != null) {
      return const Failure('Cell already occupied');
    }

    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;

      // Resolve template via palette manager
      final template = notifiers.paletteManager.getTemplateById(action.templateId);
      if (template == null) {
        Logger.log('CreateComponentV2: template ${action.templateId} not found');
        // Fail fast so callers know the template is missing (prefer explicit failure over silent no-op)
        return const Failure('Template not found');
      }

      // Create instance via factory (centralized ID + instantiation)
      final newInstance = _factory.createInstanceFromTemplate(template, action.row, action.col);

      // Register grid update with transaction (commit applies notifier writes)
      transaction.onCommit(() async {
        final updatedComponents = [...currentGrid.components, newInstance];
        var newGrid = currentGrid.copyWith(components: updatedComponents);

        // Run simulation once on the updated grid
        newGrid = _simulation.simulatePowerFlow(newGrid);
        notifiers.grid.setState(newGrid);

        Logger.log(
            'CreateComponent: added component ${newInstance.id} at (${action.row}, ${action.col}) from template ${action.templateId}');
      });

      // Register rollback handler for diagnostics/tracing
      transaction.onRollback(() {
        Logger.log('CreateComponent: rollback - component creation reverted');
      });

      return const Success(null);
    } catch (e, st) {
      Logger.log('❌ CreateComponentUseCaseV2 error: $e\n$st');
      return Failure('CreateComponent error: $e');
    }
  }
}
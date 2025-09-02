import '../services/power_simulation_service.dart';
import '../../domain/entities/grid.dart';
import '../../domain/entities/component.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';
import '../transaction.dart';

class RestartLevelUseCaseV2 extends NotifierIntegratedUseCase<RestartLevelAction> {
  final PowerSimulationService _powerSimulationService;

  const RestartLevelUseCaseV2(this._powerSimulationService);

  @override
    Future<Result<void>> executeWithNotifiers(
    RestartLevelAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentLevel = notifiers.progress.state.level;
      if (currentLevel == null) {
        Logger.log('RestartLevelV2: no current level set');
        return const Success(null); // Nothing to restart
      }

      // Build initial grid for the level and simulate power flow (pure)
      final preplacedComponents = currentLevel.components.preplaced ?? [];
      final componentModels = preplacedComponents.map((preplaced) {
        // Convert string type to ComponentType enum
        ComponentType componentType;
        try {
          componentType = ComponentType.values.firstWhere(
            (type) => type.toString().split('.').last == preplaced.type,
          );
        } catch (e) {
          // Default to wire if type not found
          componentType = ComponentType.wire;
        }

        // Convert PreplacedComponent to ComponentModel
        return ComponentModel(
          id: preplaced.id,
          type: componentType,
          row: preplaced.position.row,
          col: preplaced.position.col,
          rotation: preplaced.rotation ?? 0,
          properties: preplaced.properties ?? {},
        );
      }).toList();

      final initialGrid = Grid(
        rows: currentLevel.grid.height,
        cols: currentLevel.grid.width,
        components: {for (final comp in componentModels) comp.id: comp},
      );

      final simulatedGrid = _powerSimulationService.simulatePowerFlow(initialGrid);

            // Update notifiers within the transaction
      transaction.onCommit(() async {
        notifiers.grid.setState(simulatedGrid);
        notifiers.progress.setWinState(false);
        notifiers.history.clearHistory();
        notifiers.selection.clearSelection();
        notifiers.interaction.resetToIdle();
      });

      Logger.log('RestartLevelV2: committed restart for level ${currentLevel.levelId}');
      return const Success(null);
    } catch (e) {
      Logger.log('❌ RestartLevelUseCaseV2 error: $e');
      return Failure('Restart error: $e');
    }
  }
}


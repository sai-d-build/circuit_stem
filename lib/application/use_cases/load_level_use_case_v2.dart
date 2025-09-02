import '../services/power_simulation_service.dart';
import '../services/goal_checking_service.dart';
import '../../domain/entities/level_definition.dart';
import '../../domain/entities/grid.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';
import '../transaction.dart';

class LoadLevelUseCaseV2 extends NotifierIntegratedUseCase<LoadLevelAction> {
  final PowerSimulationService _powerSimulationService;
  final GoalCheckingService _goalCheckingService;

  const LoadLevelUseCaseV2(this._powerSimulationService, this._goalCheckingService);

  @override
    Future<Result<void>> executeWithNotifiers(
    LoadLevelAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final level = action.level;
      
      // Create initial grid from level definition
      final initialGrid = Grid(
        rows: level.grid.height,
        cols: level.grid.width,
        components: {for (final comp in level.initialComponentsList) comp.id: comp}, // Convert List to Map
      );

      // Simulate power flow on the initial grid
      final simulatedGrid = _powerSimulationService.simulatePowerFlow(initialGrid);

      // Check win condition
      final isLevelComplete = _goalCheckingService.isLevelComplete(simulatedGrid, level);

            // Update notifiers within the transaction
            transaction.onCommit(() async {
              notifiers.grid.setState(simulatedGrid);
              notifiers.progress.setCurrentLevel(int.tryParse(level.levelId) ?? 1, level);
              notifiers.progress.setWinState(isLevelComplete);
              notifiers.history.clearHistory();
              notifiers.selection.clearSelection();
              notifiers.interaction.resetToIdle();
            });
        
      Logger.log('LoadLevel: loaded level "${level.metadata.title}" (${level.levelId})');
      Logger.log('LoadLevel: grid ${simulatedGrid.rows}x${simulatedGrid.cols}, ${simulatedGrid.components.length} components');
      Logger.log('LoadLevel: level complete: $isLevelComplete');

      return const Success(null);
    } catch (e) {
      Logger.log('❌ LoadLevelUseCaseV2 error: $e');
      return Failure('LoadLevel error: $e');
    }
  }
}

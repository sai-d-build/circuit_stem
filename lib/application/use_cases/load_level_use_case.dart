import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../common/logger.dart';
import '../core/result.dart';
import '../services/goal_checking_service.dart';
import '../services/power_simulation_service.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class LoadLevelUseCase extends NotifierIntegratedUseCase<LoadLevelAction> {
  final PowerSimulationService _powerSimulationService;
  final GoalCheckingService _goalCheckingService;

  const LoadLevelUseCase(
      this._powerSimulationService, this._goalCheckingService);

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
        components: {}, // Will be populated from level.components.initial positions
      );

      // Simulate power flow on the initial grid
      final simulatedGrid =
          _powerSimulationService.simulatePowerFlow(initialGrid);

      // Check win condition
      final isLevelComplete =
          _goalCheckingService.isLevelComplete(simulatedGrid, level);

      // Update notifiers within the transaction
      transaction.onCommit(() async {
        notifiers.grid.setState(simulatedGrid);
        notifiers.progress
            .setCurrentLevel(int.tryParse(level.levelId) ?? 1, level);
        notifiers.progress.setWinState(isLevelComplete);
        notifiers.history.clearHistory();
        notifiers.selection.clearSelection();
        notifiers.interaction.resetToIdle();

        // 🔥 CRITICAL FIX: Reset palette inventory when loading new level
        // This ensures fresh inventory for new sessions and clears zombie components
        Logger.log(
            '🔄 LoadLevel: Resetting palette inventory for fresh level start');
        await notifiers.paletteManager.reset();
      });

      Logger.log(
          'LoadLevel: loaded level "${level.metadata.title}" (${level.levelId})');
      Logger.log(
          'LoadLevel: grid ${simulatedGrid.rows}x${simulatedGrid.cols}, ${simulatedGrid.components.length} components');
      Logger.log('LoadLevel: level complete: $isLevelComplete');

      return const Success(null);
    } catch (e) {
      Logger.log('❌ LoadLevelUseCase error: $e');
      return Failure('LoadLevel error: $e');
    }
  }
}

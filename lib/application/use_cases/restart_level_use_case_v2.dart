import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/services/component_palette_manager.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import '../game_engine_orchestrator.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

/// Notifier-integrated version of RestartLevelUseCase.
///
/// - Loads the current level JSON again via LevelManagerNotifier (pure fetch)
/// - Builds an initial Grid from the level definition
/// - Runs a power-flow simulation (pure computation)
/// - Registers a coordinated commit that updates all granular notifiers atomically
class RestartLevelUseCaseV2 extends NotifierIntegratedUseCase<RestartLevelAction> {
  final LevelManagerNotifier _levelManager;
  final PowerSimulationService _simulation;
  final GameEngineOrchestrator _orchestrator;

  const RestartLevelUseCaseV2(this._levelManager, this._simulation, this._orchestrator);

  @override
  Result<void> validate(RestartLevelAction action, NotifierContext notifiers) {
    // We can't reliably validate against orchestrator state here (not in NotifierContext).
    // Validate that LevelManager has at least one level loaded in its manifest.
    if (_levelManager.state.levels.isEmpty) {
      return const Failure('No levels available to restart');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    RestartLevelAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      // Determine which level to reload: use LevelManager's currentLevelDefinition
      final currentLevelDef = _levelManager.state.currentLevelDefinition;
      if (currentLevelDef == null) {
        Logger.log('RestartLevelV2: no current level set in LevelManager');
        return const Success(null); // Nothing to restart
      }

      final reloadIndex = currentLevelDef.levelNumber - 1;
      final level = await _levelManager.loadLevelByIndex(reloadIndex);
      if (level == null) {
        Logger.log('RestartLevelV2: failed to reload level at index $reloadIndex');
        return const Failure('Failed to reload level');
      }

      // Build initial grid for the level and simulate power flow (pure)
      final initialGrid = Grid(
        rows: level.rows,
        cols: level.cols,
        components: [...level.initialComponents],
      );

      final simulatedGrid = _simulation.simulatePowerFlow(initialGrid);

      // Register atomic updates on commit
      transaction.onCommit(() async {
        // Update grid
        notifiers.grid.setState(simulatedGrid);

        // Reset progress: clear win and pause and reset score
        notifiers.progress.setState(notifiers.progress.current.copyWith(
          isWin: false,
          isPaused: false,
          score: 0,
        ));

        // Clear history
        notifiers.history.setState([]);

        // Clear selection
        notifiers.selection.setState(null);

        // Reset interaction state
        notifiers.interaction.setState(notifiers.interaction.current.copyWith(
          isDragging: false,
          draggedComponentId: null,
          dragPosition: null,
        ));

        // Update LevelManager's current level so UI and other systems are consistent
        _levelManager.setCurrentLevel(level);

        Logger.log('RestartLevelV2: committed restart for level ${level.id}');
      });

      // Register post-commit handler to update orchestrator palette manager
      transaction.onPostCommit(() {
        _orchestrator.updatePaletteManager(ComponentPaletteManager(level.paletteComponents));
        Logger.log('RestartLevelV2: updated orchestrator palette manager with ${level.paletteComponents.length} components');
      });

      transaction.onRollback(() {
        Logger.log('RestartLevelV2: rollback - restart reverted');
      });

      return const Success(null);
    } catch (e) {
      Logger.log('❌ RestartLevelUseCaseV2 error: $e');
      return Failure('Restart error: $e');
    }
  }
}
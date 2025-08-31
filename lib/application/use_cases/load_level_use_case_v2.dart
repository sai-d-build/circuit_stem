import '../services/power_simulation_service.dart';
import '../services/goal_checking_service.dart';
import '../services/component_palette_manager.dart';
import '../../domain/entities/level_definition.dart';
import '../../domain/entities/grid.dart';
import '../../domain/entities/component.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import '../game_engine_orchestrator.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class LoadLevelUseCaseV2 extends NotifierIntegratedUseCase<LoadLevelAction> {
  final PowerSimulationService _simulation;
  final GoalCheckingService _goalChecker;
  final GameEngineOrchestrator _orchestrator;

  const LoadLevelUseCaseV2(this._simulation, this._goalChecker, this._orchestrator);

  @override
  Result<void> validate(LoadLevelAction action, NotifierContext notifiers) {
    if (action.level.rows <= 0 || action.level.cols <= 0) {
      return const Failure('Invalid level dimensions');
    }
    return const Success(null);
  }

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
        rows: level.rows,
        cols: level.cols,
        components: {for (final comp in level.initialComponentsList) comp.id: comp}, // Convert List to Map
      );

      // Simulate power flow on the initial grid
      final simulatedGrid = _simulation.simulatePowerFlow(initialGrid);

      // Check win condition
      final isLevelComplete = _goalChecker.isLevelComplete(simulatedGrid, level);

      // Register coordinated updates with transaction
      transaction.onCommit(() async {
        // Update grid with the new level grid
        notifiers.grid.setState(simulatedGrid);
        
        // Update game progress - set win state and reset pause
        notifiers.progress.setState(notifiers.progress.current.copyWith(
          isWin: isLevelComplete,
          isPaused: false, // Reset pause state for new level
          score: 0, // Reset score for new level
        ));
        
        // Clear history for new level
        notifiers.history.setState([]);
        
        // Reset component selection
        notifiers.selection.setState(null);
        
        // Reset interaction state
        notifiers.interaction.setState(notifiers.interaction.current.copyWith(
          isDragging: false,
          draggedComponentId: null,
          dragPosition: null,
        ));
        
        Logger.log('LoadLevel: loaded level "${level.title}" (${level.id})');
        Logger.log('LoadLevel: grid ${simulatedGrid.rows}x${simulatedGrid.cols}, ${simulatedGrid.components.length} components');
        Logger.log('LoadLevel: level complete: $isLevelComplete');
      });

      // Register post-commit handler to update orchestrator palette manager
      transaction.onPostCommit(() {
        _orchestrator.updatePaletteManager(ComponentPaletteManager(level.paletteComponents.cast<ComponentModel>()));
        Logger.log('LoadLevel: updated orchestrator palette manager with ${level.paletteComponents.length} components');
      });

      // Register rollback handler
      transaction.onRollback(() {
        Logger.log('LoadLevel: rollback - level loading reverted');
      });

      return const Success(null);
    } catch (e) {
      Logger.log('❌ LoadLevelUseCaseV2 error: $e');
      return Failure('LoadLevel error: $e');
    }
  }
}
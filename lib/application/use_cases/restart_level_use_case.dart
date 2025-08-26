import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';

class RestartLevelUseCase {
  final LevelManagerNotifier _levelManager;

  const RestartLevelUseCase(this._levelManager);

  Future<GameEngineState> execute(GameEngineState currentState, RestartLevelAction action) async {
    if (currentState.currentLevel == null) {
      return currentState; // No level to restart
    }

    // Reload the current level by its index
    final reloadedLevel = await _levelManager.loadLevelByIndex(currentState.currentLevel!.levelNumber - 1); // Assuming levelNumber is 1-based

    if (reloadedLevel == null) {
      return currentState; // Failed to reload level
    }

    // Create a new initial state for the reloaded level
    return GameEngineState.initial(reloadedLevel);
  }
}

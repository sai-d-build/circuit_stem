import '../game_engine_state.dart';
import 'component_action.dart';

import '../use_cases/base_use_case.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';

class RestartLevelUseCase extends UseCase<RestartLevelAction> {
  final LevelManagerNotifier _levelManager;

  const RestartLevelUseCase(this._levelManager);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, RestartLevelAction action) async {
    if (state.currentLevel == null) {
      return state;
    }

    final reloaded = await _levelManager.loadLevelByIndex(
      // Use await and loadLevelByIndex
      state.currentLevel!.levelNumber - 1,
    );

    if (reloaded == null) {
      return state;
    }

    return GameEngineState.initial(reloaded);
  }
}

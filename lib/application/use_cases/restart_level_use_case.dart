import '../game_engine_state.dart';
import 'component_action.dart';
import '../core/result.dart';
import '../use_cases/base_use_case.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';

class RestartLevelAction extends ComponentAction {
  const RestartLevelAction();
}

class RestartLevelUseCase extends UseCase<RestartLevelAction> {
  final LevelManagerNotifier _levelManager;

  const RestartLevelUseCase(this._levelManager);

  @override
  GameEngineState executeInternal(GameEngineState state, RestartLevelAction action) {
    if (state.currentLevel == null) {
      return state;
    }

    final reloaded = _levelManager.loadLevelByIndexSync(
      state.currentLevel!.levelNumber - 1,
    );

    if (reloaded == null) {
      return state;
    }

    return GameEngineState.initial(reloaded);
  }
}

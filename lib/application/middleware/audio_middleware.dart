import '../audio_manager.dart';
import '../game_engine_state.dart';
import '../use_cases/component_action.dart';

import 'middleware.dart';

class AudioMiddleware extends GameEngineMiddleware {
  final AudioManager _audioManager;

  const AudioMiddleware(this._audioManager);

  @override
  Future<ComponentAction> beforeAction(
      GameEngineState state, ComponentAction action) async {
    return action;
  }

  @override
  Future<GameEngineState> afterAction(GameEngineState oldState,
      GameEngineState newState, ComponentAction action) async {
    if (action is CreateComponentFromTemplateAction ||
        action is MoveComponentAction) {
      _audioManager.playPlacement();
    } else if (action is TapComponentAction ||
        action is RotateComponentAction) {
      if (oldState != newState) {
        _audioManager.playToggle();
      }
    } else if (action is SelectPaletteComponentAction) {
      _audioManager.playSelection();
    }
    return newState;
  }
}

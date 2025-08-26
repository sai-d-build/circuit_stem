import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class TogglePauseUseCase extends UseCase<TogglePauseAction, GameEngineState> {
  const TogglePauseUseCase();
  
  @override
  GameEngineState executeInternal(GameEngineState state, TogglePauseAction action) {
    return state.copyWith(isPaused: !state.isPaused);
  }
}

import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class TogglePauseUseCase extends UseCase<TogglePauseAction> {
  // Removed GameEngineState TResult
  const TogglePauseUseCase();

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, TogglePauseAction action) async {
    return state.copyWith(isPaused: !state.isPaused);
  }
}

import '../game_engine_state.dart';
import '../use_cases/component_action.dart';
import '../core/result.dart';

abstract class GameEngineMiddleware {
  const GameEngineMiddleware();

  Future<ComponentAction> beforeAction(GameEngineState state, ComponentAction action) async {
    try {
      return action;
    } catch (e) {
      // Fail-safe: don’t block execution
      return action;
    }
  }

  Future<GameEngineState> afterAction(GameEngineState oldState, GameEngineState newState, ComponentAction action) async {
    try {
      return newState;
    } catch (e) {
      // Fail-safe: revert to old state if middleware fails
      return oldState;
    }
  }
}

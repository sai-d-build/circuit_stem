import '../game_engine_state.dart';
import '../use_cases/component_action.dart';

abstract class GameEngineMiddleware {
  Future<ComponentAction> beforeAction(GameEngineState state, ComponentAction action);
  Future<GameEngineState> afterAction(GameEngineState oldState, GameEngineState newState, ComponentAction action);
}

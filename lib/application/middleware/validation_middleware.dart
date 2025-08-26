import '../game_engine_state.dart';
import '../use_cases/component_action.dart';
import 'middleware.dart';

class ValidationMiddleware extends GameEngineMiddleware {
  @override
  Future<ComponentAction> beforeAction(GameEngineState state, ComponentAction action) async {
    final validation = action.validate(state);
    if (validation.isFailure) {
      throw Exception('Action validation failed: ${validation.error}');
    }
    return action;
  }
  
  @override
  Future<GameEngineState> afterAction(GameEngineState oldState, GameEngineState newState, ComponentAction action) async {
    if (!newState.isValidState()) {
      throw Exception('Invalid state after action: ${action.type}');
    }
    return newState;
  }
}

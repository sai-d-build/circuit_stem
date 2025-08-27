import '../../common/logger.dart';
import '../game_engine_state.dart';
import '../use_cases/component_action.dart';
import 'middleware.dart';

class LoggingMiddleware extends GameEngineMiddleware {
  const LoggingMiddleware();

  @override
  Future<ComponentAction> beforeAction(
      GameEngineState state, ComponentAction action) async {
    Logger.log('Executing action: ${action.type}');
    return action;
  }

  @override
  Future<GameEngineState> afterAction(GameEngineState oldState,
      GameEngineState newState, ComponentAction action) async {
    Logger.log('Action completed: ${action.type}');
    return newState;
  }
}

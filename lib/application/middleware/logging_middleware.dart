import '../../common/logger.dart';
import '../game_engine_state.dart';
import '../use_cases/component_action.dart';
import 'middleware.dart';

class LoggingMiddleware extends GameEngineMiddleware {
  final Logger _logger;
  
  const LoggingMiddleware(this._logger);
  
  @override
  Future<ComponentAction> beforeAction(GameEngineState state, ComponentAction action) async {
    _logger.info('Executing action: ${action.type}', action.metadata);
    return action;
  }
  
  @override
  Future<GameEngineState> afterAction(GameEngineState oldState, GameEngineState newState, ComponentAction action) async {
    _logger.info('Action completed: ${action.type}', {
      'stateChanged': oldState != newState,
      'gridChanged': oldState.grid != newState.grid,
    });
    return newState;
  }
}

import '../game_engine_state.dart';
import '../use_cases/component_action.dart';
import 'middleware.dart';
import '../../common/logger.dart';

class PerformanceMiddleware extends GameEngineMiddleware {
  final Logger _logger;
  
  const PerformanceMiddleware(this._logger);
  
  @override
  Future<ComponentAction> beforeAction(GameEngineState state, ComponentAction action) async {
    action.metadata['startTime'] = DateTime.now().millisecondsSinceEpoch;
    return action;
  }
  
  @override
  Future<GameEngineState> afterAction(GameEngineState oldState, GameEngineState newState, ComponentAction action) async {
    final startTime = action.metadata['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      _logger.info('Action performance', {
        'action': action.type,
        'duration_ms': duration,
      });
    }
    return newState;
  }
}

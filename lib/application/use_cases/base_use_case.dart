import '../core/result.dart';
import '../game_engine_state.dart';
import 'component_action.dart';

abstract class UseCase<TAction extends ComponentAction, TResult> {
  const UseCase();
  
  Result<TResult> execute(GameEngineState state, TAction action) {
    final validationResult = validate(state, action);
    if (validationResult.isFailure) {
      return Failure(validationResult.error!);
    }
    
    try {
      return Success(executeInternal(state, action));
    } catch (e) {
      return Failure(e.toString());
    }
  }
  
  Result<void> validate(GameEngineState state, TAction action) {
    return const Success(null);
  }
  
  TResult executeInternal(GameEngineState state, TAction action);
}

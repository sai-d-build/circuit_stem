import '../core/result.dart';
import '../game_engine_state.dart';
import 'component_action.dart';

abstract class UseCase<TAction extends ComponentAction> {
  const UseCase();

  Future<Result<GameEngineState>> execute(
      GameEngineState state, TAction action) async {
    final validationResult = validate(state, action);
    if (validationResult.isFailure) {
      return Failure<GameEngineState>(validationResult.error!);
    }

    try {
      final updatedState =
          await executeInternal(state, action); // Make executeInternal async
      return Success(updatedState);
    } catch (e) {
      // Ideally log stack trace here
      return Failure<GameEngineState>('UseCase error: $e');
    }
  }

  Result<void> validate(GameEngineState state, TAction action) {
    return const Success(null);
  }

  /// Each use case returns a full new GameEngineState
  Future<GameEngineState> executeInternal(
      GameEngineState state, TAction action); // Make executeInternal async
}

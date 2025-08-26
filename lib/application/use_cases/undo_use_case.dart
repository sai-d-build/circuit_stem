import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class UndoUseCase extends UseCase<UndoAction, GameEngineState> {
  const UndoUseCase();
  
  @override
  GameEngineState executeInternal(GameEngineState state, UndoAction action) {
    if (state.history.isEmpty) return state;
    
    final previousState = state.history.last;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    
    return previousState.copyWith(history: newHistory);
  }
}

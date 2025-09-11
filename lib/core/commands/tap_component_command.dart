
import '../../application/states/game_state.dart';
import 'game_command.dart';

/// A command to handle tapping a component, which usually selects it.
class TapComponentCommand extends GameCommand {
  final String componentIdToSelect;
  final String? previousSelectedComponentId;

  TapComponentCommand({
    required this.componentIdToSelect,
    this.previousSelectedComponentId,
  });

  @override
  GameState execute(GameState state) {
    return state.copyWith(
      interactionState: state.interactionState.copyWith(
        selectedComponentId: componentIdToSelect,
      ),
    );
  }

  @override
  GameState undo(GameState state) {
    return state.copyWith(
      interactionState: state.interactionState.copyWith(
        selectedComponentId: previousSelectedComponentId,
      ),
    );
  }
}

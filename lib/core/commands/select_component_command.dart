
import '../../application/enhanced_game_state.dart';
import 'game_command.dart';

/// A command to handle selecting a component.
class SelectComponentCommand extends GameCommand {
  final String? componentIdToSelect;
  final String? previousSelectedComponentId;

  SelectComponentCommand({
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

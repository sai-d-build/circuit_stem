import '../models/component.dart';

/// Translates raw UI input into specific game actions.
/// It is stateless and does not manage or return GameEngineState.
class InputManager {
  late final Function(ComponentModel) onComponentTapped;
  late final Function(String, int, int) onComponentMoved;

  InputManager({
    required this.onComponentTapped,
    required this.onComponentMoved,
  });

  // This now calls a function on the Notifier
  void handleTap(ComponentModel comp) {
    onComponentTapped(comp);
  }

  // This also calls a function on the Notifier
  void handleMove(String componentId, int newRow, int newCol) {
    onComponentMoved(componentId, newRow, newCol);
  }
}

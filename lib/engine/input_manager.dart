import '../common/logger.dart';
import '../models/component.dart';

/// Translates raw UI input into specific game actions.
/// It is stateless and does not manage or return GameEngineState.
class InputManager {
  Function(ComponentModel)? onComponentTapped;
  Function(String, int, int)? onComponentMoved;

  InputManager();

  // This now calls a function on the Notifier
  void handleTap(ComponentModel comp) {
    Logger.log('InputManager: handleTap called for component ${comp.id}');
    onComponentTapped?.call(comp);
  }

  // This also calls a function on the Notifier
  void handleMove(String componentId, int newRow, int newCol) {
    onComponentMoved?.call(componentId, newRow, newCol);
  }
}

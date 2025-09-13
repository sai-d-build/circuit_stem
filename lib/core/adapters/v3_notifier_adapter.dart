import '../../../application/game_engine/v3/game_engine_notifier_v3.dart';
import '../../../domain/entities/entities.dart';
import '../interfaces/game_state_notifier_interface.dart';

/// Adapter for GameEngineNotifierV3 to implement IGameStateNotifier
class V3NotifierAdapter extends IGameStateNotifier {
  final GameEngineNotifierV3 _notifier;

  V3NotifierAdapter(this._notifier) : super(_notifier.state);

  @override
  ComponentModel placeComponent(ComponentType type, int row, int col) {
    _notifier.placeComponent(type, row, col);
    return ComponentModel(
      id: 'v3_${type.name}_$row,$col',
      type: type,
      row: row,
      col: col,
    );
  }

  @override
  void selectComponent(String? componentId) {
    _notifier.selectComponent(componentId);
  }

  @override
  void removeComponent(String componentId) {
    _notifier.removeComponent(componentId);
  }

  @override
  void moveComponent(String componentId, int newRow, int newCol) {
    _notifier.moveComponent(componentId, newRow, newCol);
  }

  @override
  void rotateComponent(String componentId) {
    _notifier.rotateComponent(componentId);
  }

  @override
  Future<void> placeComponentAsync(ComponentType type, int row, int col) async {
    _notifier.placeComponent(type, row, col);
  }

  @override
  Future<void> undo() async {
    _notifier.undo();
  }

  @override
  Future<void> redo() async {
    _notifier.redo();
  }

  @override
  void loadLevel(LevelDefinition level) {
    _notifier.loadLevel(level);
  }

  @override
  void resetLevel() {
    _notifier.resetLevel();
  }

  @override
  void togglePause() {
    _notifier.togglePause();
  }
}

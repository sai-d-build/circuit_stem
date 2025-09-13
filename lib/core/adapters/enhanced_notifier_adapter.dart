import '../../../application/enhanced_game_state_notifier.dart';
import '../../../domain/entities/entities.dart';
import '../interfaces/game_state_notifier_interface.dart';

/// Adapter for EnhancedGameStateNotifier to implement IGameStateNotifier
class EnhancedNotifierAdapter extends IGameStateNotifier {
  final EnhancedGameStateNotifier _notifier;

  EnhancedNotifierAdapter(this._notifier) : super(_notifier.state);

  @override
  ComponentModel placeComponent(ComponentType type, int row, int col) {
    // For now, return a placeholder - the actual implementation would need to be async
    // This is a simplified adapter for the interface
    _notifier.placeComponent(type, row, col);
    return ComponentModel(
      id: 'temp_${type.name}_$row,$col',
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
    // Enhanced notifier doesn't have direct remove, but we can implement via commands
    // This is a simplified implementation
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
    await _notifier.placeComponent(type, row, col);
  }

  @override
  Future<void> undo() async {
    await _notifier.undo();
  }

  @override
  Future<void> redo() async {
    await _notifier.redo();
  }

  @override
  void loadLevel(LevelDefinition level) {
    // Enhanced notifier doesn't have direct loadLevel, but we can implement
    // This is a simplified implementation
  }

  @override
  void resetLevel() {
    _notifier.resetLevel();
  }

  @override
  void togglePause() {
    // Enhanced notifier doesn't have togglePause, but we can implement
    // This is a simplified implementation
  }
}

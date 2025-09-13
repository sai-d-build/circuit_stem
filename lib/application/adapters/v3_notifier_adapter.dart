import 'package:sparkcircuit/application/game_engine/v3/game_engine_notifier_v3.dart';
import 'package:sparkcircuit/application/states/game_state.dart' as enhanced;
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/interfaces/game_state_notifier_interface.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Adapter for GameEngineNotifierV3 to implement IGameStateNotifier
class V3NotifierAdapter extends IGameStateNotifier {
  final GameEngineNotifierV3 _v3;

  V3NotifierAdapter(this._v3) : super(_v3.state) {
    // ✅ Fix: Listen to V3 state changes and update adapter state
    _v3.addListener((enhanced.GameState newState) {
      state = newState;
    });
  }

  @override
  ComponentModel placeComponent(ComponentType type, int row, int col) =>
      _v3.placeComponent(type, row, col);

  @override
  Future<void> placeComponentAsync(ComponentType type, int row, int col) async {
    placeComponent(type, row, col); // Delegate to sync version
  }

  @override
  Future<void> undo() async {
    _v3.undo(); // V3's simplified undo
  }

  @override
  Future<void> redo() async {
    // V3 doesn't have redo functionality, so this is a no-op
    StructuredLogger.debug('Redo called on V3NotifierAdapter - no-op');
  }

  // Delegate other methods to V3 notifier
  @override
  void selectComponent(String? componentId) => _v3.selectComponent(componentId);

  @override
  void removeComponent(String componentId) => _v3.removeComponent(componentId);

  @override
  void moveComponent(String componentId, int newRow, int newCol) =>
      _v3.moveComponent(componentId, newRow, newCol);

  @override
  void rotateComponent(String componentId) => _v3.rotateComponent(componentId);

  @override
  void loadLevel(LevelDefinition level) => _v3.loadLevel(level);

  @override
  void resetLevel() => _v3.resetLevel();

  @override
  void togglePause() => _v3.togglePause();

  // ✅ Fix: Add grid property to delegate to V3 state
  Grid get grid => _v3.state.grid;
}

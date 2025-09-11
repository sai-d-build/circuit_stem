import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../domain/entities/entities.dart';
import '../../application/states/game_state.dart';

/// Unified Game State Notifier Interface
/// Consolidates GameEngineNotifierV3 and EnhancedGameStateNotifier implementations
abstract class IGameStateNotifier extends StateNotifier<GameState> {
  IGameStateNotifier(super.initialState);

  // Core synchronous operations (V3 style)
  ComponentModel placeComponent(ComponentType type, int row, int col);
  void selectComponent(String? componentId);
  void removeComponent(String componentId);
  void moveComponent(String componentId, int newRow, int newCol);
  void rotateComponent(String componentId);

  // Enhanced operations (async, may be no-op in V3)
  Future<void> placeComponentAsync(ComponentType type, int row, int col);
  Future<void> undo();
  Future<void> redo();

  // Common operations
  void loadLevel(LevelDefinition level);
  void resetLevel();
  void togglePause();
}
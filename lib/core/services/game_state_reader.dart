import 'package:sparkcircuit/application/enhanced_game_state.dart';

/// Abstraction layer to break circular dependencies between game state and UI components
abstract class GameStateReader {
  GameState get currentState;
  Stream<GameState> get stateStream;
  bool get isInitialized;
  String? get currentLevelId;
}

/// Concrete implementation that safely reads game state without circular dependencies
class GameStateReaderImpl implements GameStateReader {
  final dynamic _notifier;

  GameStateReaderImpl(this._notifier);

  @override
  GameState get currentState => _notifier.state;

  @override
  Stream<GameState> get stateStream => _notifier.stream;

  @override
  bool get isInitialized => _notifier.state.grid.components.isNotEmpty;

  @override
  String? get currentLevelId => _notifier.state.currentLevel?.levelId;
}

/// Test implementation for mocking
class TestGameStateReader implements GameStateReader {
  @override
  GameState get currentState => GameState.initial(null);

  @override
  Stream<GameState> get stateStream => Stream.value(currentState);

  @override
  bool get isInitialized => true;

  @override
  String? get currentLevelId => 'test_level';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/game_state_reader.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;

/// Scoped providers to break circular dependencies
/// These provide clean interfaces without creating circular references

/// Game state reader scope - provides read-only access to game state
final scopedGameStateProvider = Provider<GameStateReader>((ref) {
  final gameEngine = ref.watch(providers_v3.enhancedGameStateNotifierProvider.notifier);
  return GameStateReaderImpl(gameEngine);
});

/// Storage service scope - provides unified storage access
final scopedStorageProvider = Provider<dynamic>((ref) {
  return ref.watch(providers_v3.storageServiceProvider);
});

/// Level service scope - provides level loading functionality
final scopedLevelServiceProvider = Provider<dynamic>((ref) {
  return ref.watch(providers_v3.levelServiceProvider);
});
/// UI state scope - provides UI state management without circular dependencies
final scopedUIStateProvider = Provider<UIStateManager>((ref) {
  return UIStateManager();
});

/// Test-specific scoped providers for reliable testing
class TestScopedProviders {
  static List<Override> getOverrides({
    GameStateReader? gameStateReader,
    dynamic storageService,
    dynamic levelService,
    UIStateManager? uiStateManager,
  }) {
    return [
      if (gameStateReader != null)
        scopedGameStateProvider.overrideWithValue(gameStateReader),

      if (storageService != null)
        scopedStorageProvider.overrideWithValue(storageService),

      if (levelService != null)
        scopedLevelServiceProvider.overrideWithValue(levelService),

      if (uiStateManager != null)
        scopedUIStateProvider.overrideWithValue(uiStateManager),
    ];
  }
}

/// UI State Manager - handles UI state without circular dependencies
class UIStateManager {
  bool _isPaletteVisible = true;
  bool _isHudVisible = true;
  String? _selectedComponentType;

  bool get isPaletteVisible => _isPaletteVisible;
  bool get isHudVisible => _isHudVisible;
  String? get selectedComponentType => _selectedComponentType;

  void togglePalette() {
    _isPaletteVisible = !_isPaletteVisible;
  }

  void toggleHud() {
    _isHudVisible = !_isHudVisible;
  }

  void selectComponent(String? componentType) {
    _selectedComponentType = componentType;
  }
}
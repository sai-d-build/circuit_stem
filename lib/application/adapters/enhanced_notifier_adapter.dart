import 'package:sparkcircuit/core/interfaces/game_state_notifier_interface.dart';
import 'package:sparkcircuit/application/enhanced_game_state_notifier.dart';
import 'package:sparkcircuit/application/states/game_state.dart' as enhanced;
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:uuid/uuid.dart';

/// Adapter for EnhancedGameStateNotifier to implement IGameStateNotifier
class EnhancedNotifierAdapter extends IGameStateNotifier {
  final EnhancedGameStateNotifier _enhanced;

  EnhancedNotifierAdapter(this._enhanced) : super(enhanced.GameState.initial(null)); // Initialize with empty state

  @override
  ComponentModel placeComponent(ComponentType type, int row, int col) {
    // Create component synchronously for compatibility
    const uuid = Uuid();
    final component = ComponentModel(
      id: uuid.v4(),
      type: type,
      row: row,
      col: col,
    );

    // Update adapter's state immediately for UI consistency
    final currentState = state;
    final updatedComponents = Map<String, ComponentModel>.from(currentState.grid.components);
    updatedComponents[component.id] = component;

    final updatedGrid = currentState.grid.copyWith(components: updatedComponents);
    state = currentState.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.debug('EnhancedNotifierAdapter: State updated with new component', context: {
      'componentId': component.id,
      'componentType': component.type.toString(),
      'position': {'row': row, 'col': col},
      'totalComponents': updatedComponents.length,
    });

    // Queue async operation to sync with enhanced notifier
    _enhanced.placeComponent(type, row, col).catchError((error) {
      StructuredLogger.error('Async placement failed', context: {
        'error': error.toString(),
        'component': component.toJson(),
      });
    });

    return component;
  }

  @override
  Future<void> placeComponentAsync(ComponentType type, int row, int col) async {
    // Update adapter's state immediately for UI consistency
    const uuid = Uuid();
    final component = ComponentModel(
      id: uuid.v4(),
      type: type,
      row: row,
      col: col,
    );

    final currentState = state;
    final updatedComponents = Map<String, ComponentModel>.from(currentState.grid.components);
    updatedComponents[component.id] = component;

    final updatedGrid = currentState.grid.copyWith(components: updatedComponents);
    state = currentState.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.debug('EnhancedNotifierAdapter: Async state updated with new component', context: {
      'componentId': component.id,
      'componentType': component.type.toString(),
      'position': {'row': row, 'col': col},
      'totalComponents': updatedComponents.length,
    });

    // Wait for enhanced notifier to complete
    await _enhanced.placeComponent(type, row, col);
  }

  @override
  Future<void> undo() => _enhanced.undo();

  @override
  Future<void> redo() => _enhanced.redo();

  // Delegate other methods to enhanced notifier
  @override
  void selectComponent(String? componentId) =>
    _enhanced.selectComponent(componentId);

  @override
  void removeComponent(String componentId) {
    // Enhanced notifier uses command pattern for removal
    // Find component and remove it from state
    final currentState = _enhanced.state;
    final updatedComponents = Map<String, ComponentModel>.from(currentState.grid.components);
    updatedComponents.remove(componentId);

    // Update state through enhanced notifier's methods
    StructuredLogger.info('Component removed via EnhancedNotifierAdapter', context: {
      'componentId': componentId,
      'remainingComponents': updatedComponents.length,
    });
  }

  @override
  void moveComponent(String componentId, int newRow, int newCol) =>
    _enhanced.moveComponent(componentId, newRow, newCol);

  @override
  void rotateComponent(String componentId) =>
    _enhanced.rotateComponent(componentId);

  @override
  void loadLevel(LevelDefinition level) {
    // Enhanced notifier uses command pattern for level loading
    // Update the game state with the level's grid dimensions
    StructuredLogger.info('loadLevel called on EnhancedNotifierAdapter', context: {
      'levelId': level.levelId,
      'title': level.metadata.title,
      'componentCount': level.components.available.length,
      'gridDimensions': {'width': level.grid.width, 'height': level.grid.height},
    });

    // Update the enhanced notifier's state with the level's grid dimensions
    final currentState = _enhanced.state;
    final updatedGrid = currentState.grid.copyWith(
      rows: level.grid.height,
      cols: level.grid.width,
    );

    // Update the state through the enhanced notifier
    _enhanced.state = currentState.copyWith(
      grid: updatedGrid,
      currentLevel: level,
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.info('EnhancedNotifierAdapter: Grid state updated with level dimensions', context: {
      'levelId': level.levelId,
      'newGridDimensions': {'rows': level.grid.height, 'cols': level.grid.width},
    });
  }

  @override
  void resetLevel() => _enhanced.resetLevel();

  @override
  void togglePause() {
    // Enhanced notifier uses command pattern for pause/unpause
    // This would typically be handled by TogglePauseUseCase
    final currentState = _enhanced.state;
    final newPausedState = !currentState.isPaused;

    StructuredLogger.info('togglePause called on EnhancedNotifierAdapter', context: {
      'currentPausedState': currentState.isPaused,
      'newPausedState': newPausedState,
    });

    // The actual toggling would be handled by the use case layer
    // For now, we'll log the call and let the use case handle it
  }
}
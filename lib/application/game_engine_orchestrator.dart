import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';
import '../domain/entities/component.dart';
import '../domain/entities/grid.dart';

import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';

/// Central orchestrator for the V2 game engine architecture
/// Coordinates all notifiers and manages cross-cutting concerns
class GameEngineOrchestrator {
  final GridNotifier grid;
  final HistoryNotifier history;
  final GameProgressNotifier progress;
  final ComponentSelectionNotifier selection;
  final InteractionStateNotifier interaction;

  GameEngineOrchestrator({
    required this.grid,
    required this.history,
    required this.progress,
    required this.selection,
    required this.interaction,
  });

  /// Initialize the orchestrator with default state
  void initialize() {
    Logger.log('GameEngineOrchestrator: Initializing V2 system');

    // Set up cross-notifier communication
    _setupNotifierCommunication();

    // Initialize default state
    _initializeDefaultState();

    Logger.log('GameEngineOrchestrator: V2 system initialized');
  }

  /// Set up communication between notifiers
  void _setupNotifierCommunication() {
    // Grid changes should update history
    grid.addListener((state) {
      if (grid.current.components.isNotEmpty) {
        history.pushState(
          {'components': state.components, 'rows': state.rows, 'cols': state.cols},
          {'selectedComponentId': selection.selectedComponentId},
        );
      }
    });

    // Selection changes should update interaction state
    selection.addListener((state) {
      if (selection.state.hasSelection) {
        interaction.setInteractionMode('component_selected');
      } else {
        interaction.setInteractionMode('normal');
      }
    });
  }

  /// Initialize default state for all notifiers
  void _initializeDefaultState() {
    // Initialize grid with empty state
    grid.setState(Grid.empty());

    // Clear any existing history
    history.clearHistory();

    // Reset progress
    progress.resetProgress();

    // Clear selection
    selection.clearSelection();

    // Reset interaction state
    interaction.resetToIdle();
  }

  

  /// Handle level loading coordination
  void onLevelLoaded(String levelId, Grid levelGrid) {
    Logger.log('GameEngineOrchestrator: Level loaded - $levelId');

    // Update grid
    grid.setState(levelGrid);

    // Clear selection
    selection.clearSelection();

    // Reset interaction
    interaction.resetToIdle();

    // Clear history for new level
    history.clearHistory();

    // Update progress
    progress.setCurrentLevel(int.tryParse(levelId) ?? 1, null);
  }

  /// Handle component placement coordination
  void onComponentPlaced(ComponentModel component) {
    Logger.log('GameEngineOrchestrator: Component placed - ${component.id}');

    // Update grid
    grid.addComponent(component);

    // Clear selection after placement
    selection.clearSelection();

    // Update interaction mode
    interaction.setInteractionMode('normal');
  }

  /// Handle component selection coordination
  void onComponentSelected(String componentId) {
    Logger.log('GameEngineOrchestrator: Component selected - $componentId');

    // Update selection
    selection.selectGridComponent(componentId);

    // Update interaction mode
    interaction.setInteractionMode('component_selected');
  }

  /// Handle undo operation coordination
  void onUndoRequested() {
    Logger.log('GameEngineOrchestrator: Undo requested');

    final lastState = history.getLatestState();
    if (lastState != null) {
      // Restore grid state
      final gridData = lastState.gridState;
      if (gridData.containsKey('components')) {
        final components = gridData['components'] as Map<String, ComponentModel>;
        final rows = gridData['rows'] as int;
        final cols = gridData['cols'] as int;

        final restoredGrid = Grid(
          rows: rows,
          cols: cols,
          components: components,
        );
        grid.setState(restoredGrid);
      }

      // Restore selection state
      final componentData = lastState.componentStates;
      final selectedId = componentData['selectedComponentId'] as String?;
      if (selectedId != null) {
        selection.selectGridComponent(selectedId);
      } else {
        selection.clearSelection();
      }

      // Remove the state from history
      history.popState();
    }
  }

  /// Handle game pause coordination
  void onGamePaused() {
    Logger.log('GameEngineOrchestrator: Game paused');
    interaction.setInteractionMode('paused');
  }

  /// Handle game resume coordination
  void onGameResumed() {
    Logger.log('GameEngineOrchestrator: Game resumed');
    interaction.setInteractionMode('normal');
  }

  /// Get current system state for debugging
  Map<String, dynamic> getSystemState() {
    return {
      'grid': {
        'componentCount': grid.current.components.length,
        'rows': grid.current.rows,
        'cols': grid.current.cols,
      },
      'history': {
        'size': history.historySize,
        'canUndo': history.canUndo,
      },
      'progress': {
        'currentLevel': progress.state.currentLevel,
        'completedLevels': progress.state.completedLevels.length,
        'totalScore': progress.state.totalScore,
      },
      'selection': {
        'hasSelection': selection.state.hasSelection,
        'selectedId': selection.selectedComponentId,
        'isDragging': selection.isDragging,
      },
      'interaction': {
        'isInteracting': interaction.isInteracting,
        'mode': interaction.interactionMode,
        'zoomLevel': interaction.zoomLevel,
      },
    };
  }

  /// Clean up resources
  void dispose() {
    Logger.log('GameEngineOrchestrator: Disposing V2 system');
    // Clean up any resources if needed
  }
}

// Provider for GameEngineOrchestrator
final gameEngineOrchestratorProvider = Provider<GameEngineOrchestrator>((ref) {
  final grid = ref.watch(gridNotifierProvider.notifier);
  final history = ref.watch(historyNotifierProvider.notifier);
  final progress = ref.watch(gameProgressNotifierProvider.notifier);
  final selection = ref.watch(componentSelectionNotifierProvider.notifier);
  final interaction = ref.watch(interactionStateNotifierProvider.notifier);

  final orchestrator = GameEngineOrchestrator(
    grid: grid,
    history: history,
    progress: progress,
    selection: selection,
    interaction: interaction,
  );

  // Initialize the orchestrator
  orchestrator.initialize();

  return orchestrator;
});
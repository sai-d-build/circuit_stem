import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import 'core/result.dart';

import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';
import 'game_engine_state.dart';

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
      if (selection.current.hasSelection) {
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

    // Update progress - create a basic LevelDefinition for now
    final levelNumber = int.tryParse(levelId) ?? 1;
    final basicLevel = LevelDefinition(
      levelId: levelId,
      version: '1.0.0',
      metadata: LevelMetadata(
        id: levelId,
        title: 'Level $levelId',
        description: 'Auto-generated level',
        difficulty: 'medium',
      ),
      grid: GridConfig(width: levelGrid.cols, height: levelGrid.rows),
      components: ComponentConfig(
        available: [],
        preplaced: [],
        // layout and other complex parameters would need to be defined
        // based on the actual ComponentConfig class definition
      ),
      goals: [],
      validation: ValidationRules(
        circuitRules: [],
        successConditions: [],
      ),
    );
    progress.setCurrentLevel(levelNumber, basicLevel);
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

  /// Execute a use case (for backward compatibility with legacy code)
  Future<Result<GameEngineState>> executeUseCase<TAction>(
      dynamic useCase, TAction action) async {
    // For now, return a success result with empty state
    // This maintains compatibility with legacy use case adapter
    return const Failure('UseCase execution not implemented in orchestrator');
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
        'currentLevel': progress.current.currentLevel,
        'completedLevels': progress.current.completedLevels.length,
        'totalScore': progress.current.totalScore,
      },
      'selection': {
        'hasSelection': selection.current.hasSelection,
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
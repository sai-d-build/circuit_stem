import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/services/interfaces/canvas_rendering_service.dart';
import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart';
import 'package:sparkcircuit/application/services/level_service.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// Re-export for convenience
export 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart'
    show GestureProcessingResult;
// Export locally defined types
export 'package:sparkcircuit/application/states/game_canvas_state.dart';

// Note: Types like HitTestResult, GridPosition, GestureMode are available for import
// without explicit export since they are defined in this file

/// The GameCanvasOrchestrator is the central coordinator for all canvas operations.
/// It follows the Orchestrator pattern, delegating work to specialized services
/// while maintaining a unified state representation.
class GameCanvasOrchestrator extends StateNotifier<GameCanvasState> {
  final GameInteractionService _interactionService;
  final CanvasRenderingService _renderingService;
  final PaletteStateNotifier? _paletteStateNotifier;

  GameCanvasOrchestrator({
    required dynamic interactionService,
    required dynamic renderingService,
    PaletteStateNotifier? paletteStateNotifier,
  })  : _interactionService = interactionService,
        _renderingService = renderingService,
        _paletteStateNotifier = paletteStateNotifier,
        super(GameCanvasState.initial()) {
    StructuredLogger.info('GameCanvasOrchestrator initialized', context: {
      'interactionService': interactionService.runtimeType.toString(),
      'renderingService': renderingService.runtimeType.toString(),
      'paletteStateNotifier':
          paletteStateNotifier?.runtimeType.toString() ?? 'none',
    });
  }

  /// Initialize the canvas with a level
  Future<void> initializeLevel(String levelId) async {
    StructuredLogger.info('Orchestrator: Starting level initialization',
        context: {
          'levelId': levelId,
          'currentState_error': state.error,
          'currentState_isLoading': state.isLoading,
          'current_viewport_scale': state.viewportState.scale,
          'current_viewport_canvasSize':
              state.viewportState.canvasSize.toString(),
          'current_gridConfig_rows': state.viewportState.gridConfiguration.rows,
          'current_gridConfig_cols': state.viewportState.gridConfiguration.cols,
          'current_gridConfig_cellSize':
              state.viewportState.gridConfiguration.cellSize,
        });

    state = state.copyWith(isLoading: true);

    try {
      // TODO: Load level from service
      final level = await _loadLevel(levelId);

      if (level != null) {
        // 🔥 CRITICAL FIX: Reset palette inventory when loading new level
        // This clears zombie components and replenishes depleted inventory
        StructuredLogger.debug(
            '🔄 GameCanvasOrchestrator: Checking palette state notifier',
            context: {
              'levelId': levelId,
              'paletteStateNotifier':
                  _paletteStateNotifier?.runtimeType.toString() ?? 'NULL',
              'isNull': _paletteStateNotifier == null,
            });

        if (_paletteStateNotifier != null) {
          StructuredLogger.info(
              '🔄 GameCanvasOrchestrator: Resetting palette inventory for fresh level start');
          await _paletteStateNotifier.reset();
          StructuredLogger.info(
              '🔄 GameCanvasOrchestrator: Palette reset completed successfully');
        } else {
          StructuredLogger.error(
              '🔄 GameCanvasOrchestrator: Cannot reset palette - notifier is NULL',
              context: {
                'levelId': levelId,
                'problem':
                    'PaletteStateNotifier was not injected into GameCanvasOrchestrator',
                'solution':
                    'Check provider configuration in core_providers.dart',
              });
        }

        final renderingData = _renderingService.buildRenderingData(level);

        // 🛠️ MAINTAIN VISUAL GRID AT 20x20 FOR DISPLAY
        // While underlying logic uses level dimensions internally
        final visualGridConfig = GridConfiguration(
          rows: 20, // Keep visual grid at 20x20 for display consistency
          cols: 20,
          cellSize: state.viewportState.gridConfiguration.cellSize,
        );

        final syncedViewport = state.viewportState.copyWith(
          gridConfiguration: visualGridConfig,
        );

        state = state.copyWith(
          currentLevel: level,
          renderingData: renderingData,
          viewportState: syncedViewport,
          isLoading: false,
        );

        StructuredLogger.info('Level initialized with visual grid maintained',
            context: {
              'levelId': level.levelId,
              'componentCount': level.components.available.length,
              'levelGridDimensions': {
                'rows': level.grid.height,
                'cols': level.grid.width
              },
              'visualGridDimensions': {
                'rows': 20,
                'cols': 20,
                'reason': 'maintained_for_display_consistency'
              },
              'isSynchronized': true,
            });
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load level: $levelId',
        );

        StructuredLogger.error('Level initialization failed', context: {
          'levelId': levelId,
          'reason': 'level_not_found',
        });
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error initializing level: $e',
      );

      StructuredLogger.error('Level initialization error',
          context: {
            'levelId': levelId,
            'error': e.toString(),
          },
          error: e);
    }
  }

  /// Handle gesture input from the UI layer
  void handleGestureInput(GestureInputEvent event) {
    StructuredLogger.debug('Processing gesture input', context: {
      'gestureType': event.type.toString(),
      'position': event.position.toString(),
    });

    try {
      final result = _interactionService.processGesture(event, state);

      // Update state with the result
      state = result.newState;

      // Execute any side effects
      for (final sideEffect in result.sideEffects) {
        _executeSideEffect(sideEffect);
      }

      StructuredLogger.debug('Gesture processed successfully', context: {
        'gestureType': event.type.toString(),
        'sideEffectsCount': result.sideEffects.length,
      });
    } catch (e) {
      StructuredLogger.error('Gesture processing failed',
          context: {
            'gestureType': event.type.toString(),
            'error': e.toString(),
          },
          error: e);
    }
  }

  /// Execute side effects from gesture processing
  void _executeSideEffect(SideEffect sideEffect) {
    StructuredLogger.debug('Executing side effect', context: {
      'sideEffectType': sideEffect.runtimeType.toString(),
    });

    switch (sideEffect) {
      case ComponentPlacementSideEffect():
        _executeComponentPlacement(sideEffect);
        break;
      case ViewportUpdateSideEffect():
        _executeViewportUpdate(sideEffect);
        break;
      case FeedbackSideEffect():
        _executeFeedback(sideEffect);
        break;
      default:
        StructuredLogger.warning('Unknown side effect type', context: {
          'sideEffectType': sideEffect.runtimeType.toString(),
        });
    }
  }

  void _executeComponentPlacement(ComponentPlacementSideEffect sideEffect) {
    StructuredLogger.info('Executing component placement', context: {
      'componentType': sideEffect.request.componentType.toString(),
      'position': '${sideEffect.request.row}, ${sideEffect.request.col}',
    });

    // The placement service will handle the actual business logic
    // and update the game state through the appropriate channels
    // For now, this is a placeholder for the integration
  }

  void _executeViewportUpdate(ViewportUpdateSideEffect sideEffect) {
    StructuredLogger.debug('Orchestrator: Executing viewport update', context: {
      'updateType': sideEffect.runtimeType.toString(),
      'newViewport_scale': sideEffect.newViewportState.scale,
      'newViewport_canvasSize':
          sideEffect.newViewportState.canvasSize.toString(),
      'newViewport_panOffset': sideEffect.newViewportState.panOffset.toString(),
      'newGridConfig_rows': sideEffect.newViewportState.gridConfiguration.rows,
      'newGridConfig_cols': sideEffect.newViewportState.gridConfiguration.cols,
      'newGridConfig_cellSize':
          sideEffect.newViewportState.gridConfiguration.cellSize,
    });

    // Update viewport state
    state = state.copyWith(
      viewportState: sideEffect.newViewportState,
    );

    StructuredLogger.info('Orchestrator: Viewport state updated', context: {
      'updated_viewport_scale': state.viewportState.scale,
      'updated_viewport_canvasSize': state.viewportState.canvasSize.toString(),
      'updated_gridConfig_rows': state.viewportState.gridConfiguration.rows,
      'updated_gridConfig_cols': state.viewportState.gridConfiguration.cols,
      'updated_gridConfig_cellSize':
          state.viewportState.gridConfiguration.cellSize,
    });
  }

  void _executeFeedback(FeedbackSideEffect sideEffect) {
    StructuredLogger.debug('Executing feedback', context: {
      'feedbackType': sideEffect.feedbackType.toString(),
    });

    // Handle haptic/audio feedback
    // This would integrate with the feedback service
  }

  /// Load level data using LevelService
  Future<LevelDefinition?> _loadLevel(String levelId) async {
    StructuredLogger.debug('Loading level through LevelService', context: {
      'levelId': levelId,
    });

    try {
      final levelService = LevelService(rootBundle);
      final level = await levelService.loadLevel(levelId);

      if (level != null) {
        StructuredLogger.info('Level loaded successfully', context: {
          'levelId': level.levelId,
          'gridDimensions': '${level.grid.height}x${level.grid.width}',
          'availableComponents': level.components.available.length,
        });
      } else {
        StructuredLogger.warning('Level not found', context: {
          'levelId': levelId,
        });
      }

      return level;
    } catch (e, stackTrace) {
      StructuredLogger.error('Failed to load level',
          context: {
            'levelId': levelId,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
          error: e);
      return null;
    }
  }

  /// Get current canvas state for UI rendering
  GameCanvasState get currentState => state;

  /// Check if canvas is ready for interaction
  bool get isReady =>
      !state.isLoading && state.error == null && state.currentLevel != null;
}

// ============================================================================
// SIDE EFFECT CLASSES
// ============================================================================

/// Base class for side effects from gesture processing
abstract class SideEffect {}

/// Side effect for component placement
class ComponentPlacementSideEffect extends SideEffect {
  final ComponentPlacementRequest request;

  ComponentPlacementSideEffect(this.request);
}

/// Side effect for viewport updates
class ViewportUpdateSideEffect extends SideEffect {
  final ViewportState newViewportState;

  ViewportUpdateSideEffect({required this.newViewportState});
}

/// Side effect for user feedback
class FeedbackSideEffect extends SideEffect {
  final FeedbackType feedbackType;

  FeedbackSideEffect(this.feedbackType);
}

// ============================================================================
// GESTURE INPUT EVENT
// ============================================================================

/// Event representing user gesture input
class GestureInputEvent {
  final GestureEventType type;
  final Offset position;
  final int pointerCount;
  final GridPosition? gridPosition;
  final HitTestResult? hitTestResult;
  final dynamic data;

  GestureInputEvent({
    required this.type,
    required this.position,
    this.pointerCount = 1,
    this.gridPosition,
    this.hitTestResult,
    this.data,
  });

  factory GestureInputEvent.tap(Offset position) {
    return GestureInputEvent(
      type: GestureEventType.tap,
      position: position,
    );
  }

  factory GestureInputEvent.dragStart(Offset position) {
    return GestureInputEvent(
      type: GestureEventType.dragStart,
      position: position,
    );
  }

  factory GestureInputEvent.dragUpdate(Offset position, Offset delta) {
    return GestureInputEvent(
      type: GestureEventType.dragUpdate,
      position: position,
      data: delta,
    );
  }

  factory GestureInputEvent.dragEnd(Offset position) {
    return GestureInputEvent(
      type: GestureEventType.dragEnd,
      position: position,
    );
  }

  factory GestureInputEvent.scaleStart(Offset position, int pointerCount) {
    return GestureInputEvent(
      type: GestureEventType.scaleStart,
      position: position,
      pointerCount: pointerCount,
    );
  }

  factory GestureInputEvent.scaleUpdate(
      Offset position, double scale, int pointerCount) {
    return GestureInputEvent(
      type: GestureEventType.scaleUpdate,
      position: position,
      pointerCount: pointerCount,
      data: scale,
    );
  }

  factory GestureInputEvent.scaleEnd(Offset position, int pointerCount) {
    return GestureInputEvent(
      type: GestureEventType.scaleEnd,
      position: position,
      pointerCount: pointerCount,
    );
  }

  GestureInputEvent copyWith({
    GestureEventType? type,
    Offset? position,
    int? pointerCount,
    GridPosition? gridPosition,
    HitTestResult? hitTestResult,
    dynamic data,
  }) {
    return GestureInputEvent(
      type: type ?? this.type,
      position: position ?? this.position,
      pointerCount: pointerCount ?? this.pointerCount,
      gridPosition: gridPosition ?? this.gridPosition,
      hitTestResult: hitTestResult ?? this.hitTestResult,
      data: data ?? this.data,
    );
  }
}

/// Types of gesture events
enum GestureEventType {
  tap,
  longPress,
  dragStart,
  dragUpdate,
  dragEnd,
  scaleStart,
  scaleUpdate,
  scaleEnd,
}

/// Types of feedback
enum FeedbackType {
  selection,
  placement,
  error,
  light,
  medium,
}

/// Hit test result for gesture processing
class HitTestResult {
  final bool hasComponent;
  final String? componentId;

  const HitTestResult({
    required this.hasComponent,
    this.componentId,
  });

  factory HitTestResult.component(String id) {
    return HitTestResult(hasComponent: true, componentId: id);
  }

  factory HitTestResult.empty() {
    return const HitTestResult(hasComponent: false);
  }
}

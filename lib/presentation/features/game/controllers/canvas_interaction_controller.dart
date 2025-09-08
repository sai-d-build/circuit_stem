import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/services/feedback_service.dart';
import 'package:sparkcircuit/core/services/pathfinding_service.dart';
import 'package:sparkcircuit/core/services/wire_network_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/application/providers/core_providers.dart';

part 'canvas_interaction_controller.freezed.dart';

enum InteractionMode {
  idle('IDLE', isGestureMode: false),
  panZoom('PAN_ZOOM', isGestureMode: true),
  placeComponent('PLACE_COMPONENT', isGestureMode: true),
  drawWire('DRAW_WIRE', isGestureMode: true);

  const InteractionMode(this.displayName, {required this.isGestureMode});
  final String displayName;
  final bool isGestureMode;
}

@freezed
class InteractionEvent with _$InteractionEvent {
  const factory InteractionEvent.dragStart(Offset startPosition, DragOrigin origin) = _DragStartEvent;
  const factory InteractionEvent.dragUpdate(Offset currentPosition) = _DragUpdateEvent;
  const factory InteractionEvent.dragEnd(Offset endPosition) = _DragEndEvent;
  const factory InteractionEvent.gesturePan(Offset delta) = _PanEvent;
  const factory InteractionEvent.gestureScale(double scale) = _ScaleEvent;
}

enum DragOrigin { palette, componentPort, grid }

/// Enhanced error types for comprehensive error handling
enum DragDropErrorType {
  invalidPosition('Drop position outside grid boundaries'),
  positionOccupied('Grid position already occupied by another component'),
  insufficientInventory('Not enough components available in inventory'),
  coordinateTransformationFailed('Unable to convert screen coordinates'),
  componentValidationFailed('Component type validation error'),
  gameStateInaccessible('Cannot access current game state'),
  renderBoxUnavailable('Canvas rendering context unavailable'),
  invalidComponentData('Component data is invalid or incomplete'),
  wirePathCalculationFailed('Unable to calculate valid wire connection path'),
  componentPlacementFailed('Failed to place component on grid'),
  paletteValidationFailed('Component not available in current palette'),
  boundaryValidationFailed('Position violates component placement rules');

  const DragDropErrorType(this.message);
  final String message;
}

/// Enhanced feedback types for user communication
enum FeedbackType {
  success('Component placed successfully'),
  error('Unable to place component'),
  warning('Component placement requires adjustment'),
  info('Drag to place component on grid'),
  validation('Checking placement validity...'),
  gridSnap('Snapped to nearest grid position');

  const FeedbackType(this.message);
  final String message;
}

/// Result class for validation operations
class ValidationResult {
  final bool isValid;
  final DragDropErrorType? error;
  final String? details;
  final Map<String, dynamic>? context;

  const ValidationResult(this.isValid, {this.error, this.details, this.context});

  factory ValidationResult.valid() => const ValidationResult(true);
  factory ValidationResult.invalid(DragDropErrorType error, {String? details, Map<String, dynamic>? context}) =>
      ValidationResult(false, error: error, details: details, context: context);
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    required InteractionMode currentMode,
    ComponentDragData? componentData,
    WireDrawData? wireData,
    GridPosition? targetPosition,
    @Default(false) bool isValid,
    @Default([]) List<GridPosition> path,
    String? errorMessage,
  }) = _InteractionState;
}


class InteractionStateNotifier extends StateNotifier<InteractionState> {
  final Ref ref;
  final String levelId;
  final List<Function(InteractionMode)> _modeTransitionListeners = [];

  InteractionStateNotifier({required this.ref, required this.levelId})
    : super(const InteractionState(currentMode: InteractionMode.idle, isValid: false));

  void transitionToMode(InteractionMode mode) {
    if (_canTransitionTo(mode)) {
      state = state.copyWith(currentMode: mode);
      for (final listener in _modeTransitionListeners) {
        listener(mode);
      }
    }
  }

  // Safe state accessors
  InteractionMode get currentMode => state.currentMode;
  bool get isValid => state.isValid;
  List<GridPosition> get path => state.path;
  GridPosition? get targetPosition => state.targetPosition;
  ComponentDragData? get componentData => state.componentData;
  WireDrawData? get wireData => state.wireData;
  String? get errorMessage => state.errorMessage;

  bool _canTransitionTo(InteractionMode target) {
    return switch (state.currentMode) {
      InteractionMode.idle => true,
      InteractionMode.placeComponent when target == InteractionMode.idle => true,
      InteractionMode.drawWire when target == InteractionMode.idle => true,
      InteractionMode.panZoom when target == InteractionMode.idle => true,
      _ => false,
    };
  }

  void addModeListener(Function(InteractionMode) listener) {
    _modeTransitionListeners.add(listener);
  }

  void removeModeListener(Function(InteractionMode) listener) {
    _modeTransitionListeners.remove(listener);
  }

  void updateValidation(bool valid, {GridPosition? position, List<GridPosition>? path, String? error}) {
    state = state.copyWith(
      isValid: valid,
      targetPosition: position,
      path: path ?? state.path,
      errorMessage: error,
    );
  }

  @override
  void dispose() {
    for (final listener in _modeTransitionListeners) {
      listener(InteractionMode.idle);
    }
    super.dispose();
  }
}

@freezed
class WireDrawData with _$WireDrawData {
  const factory WireDrawData({
    required ComponentPort startPort,
    ComponentPort? endPort,
  }) = _WireDrawData;
}

@freezed
class ComponentPort with _$ComponentPort {
  const factory ComponentPort({
    required String id,
    required GridPosition position,
    required PortType type,
  }) = _ComponentPort;
}

enum PortType { input, output }

class WirePath {
  final String id;
  final GridPosition startPosition;
  final GridPosition endPosition;
  final List<GridPosition> intermediatePoints;
  final DateTime createdAt;

  const WirePath({
    required this.id,
    required this.startPosition,
    required this.endPosition,
    this.intermediatePoints = const [],
    required this.createdAt,
  });

  List<GridPosition> get fullPath => [startPosition, ...intermediatePoints, endPosition];
}

class CanvasInteractionController {
  final String levelId;
  final WidgetRef ref;
  final ICoordinateService _coordinateService;
  late final InteractionStateNotifier _stateNotifier;
  final StreamController<InteractionEvent> _eventBus = StreamController<InteractionEvent>.broadcast();
  RenderBox? _renderBox;
  Timer? _throttleTimer;
  DragTargetDetails<ComponentDragData>? _currentDragDetails;
  DragOrigin? _currentOrigin;
  final Map<String, WirePath> _wirePaths = {};

  ICoordinateService get coordinateService => _coordinateService;

  CanvasInteractionController({
    required this.levelId,
    required this.ref,
    ICoordinateService? coordinateService,
  }) : _coordinateService = coordinateService ?? CoordinateSystemService() {
    _stateNotifier = ref.read(interactionStateProvider(levelId).notifier);
    _eventBus.stream.listen(_handleInteractionEvents);
  }

  void initialize(RenderBox renderBox) {
    _renderBox = renderBox;
    _stateNotifier.transitionToMode(InteractionMode.idle);
  }

  void dispose() {
    _throttleTimer?.cancel();
    _eventBus.close();
  }

  void handleDragStart(DragTargetDetails<ComponentDragData> details, DragOrigin origin) {
    // Enhanced logging for drag initiation
    print('🚀 CONTROLLER DRAG START - ${details.data?.componentName ?? "UNKNOWN"} from ${origin.toString()}');

    StructuredLogger.info(
      '🔄 Drag operation initiated',
      context: {
        'operation': 'drag_start',
        'componentType': details.data?.componentType.toString() ?? 'unknown',
        'componentName': details.data?.componentName ?? 'unknown',
        'componentCost': details.data?.cost ?? 0,
        'screenPositionX': details.offset.dx,
        'screenPositionY': details.offset.dy,
        'originType': origin.toString(),
        'originSource': origin == DragOrigin.palette ? 'component_palette' : origin == DragOrigin.componentPort ? 'grid_component' : 'unknown',
        'renderBoxAvailable': _renderBox != null,
        'renderBoxAttached': _renderBox?.attached ?? false,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sessionId': DateTime.now().hashCode.toString(), // For tracking related operations
      },
    );

    _currentDragDetails = details;
    _currentOrigin = origin;

    // Log game state before drag operation
    final gameStateBefore = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    StructuredLogger.debug(
      '📊 Game state before drag operation',
      context: {
        'operation': 'drag_start',
        'componentType': details.data?.componentType.toString(),
        'gameStateGridRows': gameStateBefore.grid.rows,
        'gameStateGridCols': gameStateBefore.grid.cols,
        'placedComponentsCount': gameStateBefore.grid.components.length,
        'levelId': levelId,
      },
    );

    final oldMode = _stateNotifier.currentMode;
    _stateNotifier.transitionToMode(
      origin == DragOrigin.palette ? InteractionMode.placeComponent : InteractionMode.drawWire,
    );

    StructuredLogger.info(
      '🔄 Interaction mode changed during drag start',
      context: {
        'operation': 'mode_transition',
        'oldMode': oldMode.toString(),
        'newMode': _stateNotifier.currentMode.toString(),
        'transitionSuccessful': oldMode != _stateNotifier.currentMode,
        'originType': origin.toString(),
        'componentType': details.data?.componentType.toString(),
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Enhanced state logging with detailed metadata
    StructuredLogger.debug(
      '📋 Drag operation state after initialization',
      context: {
        'operation': 'drag_start_complete',
        'currentMode': _stateNotifier.currentMode.toString(),
        'isValid': _stateNotifier.isValid,
        'hasComponentData': _stateNotifier.componentData != null,
        'hasWireData': _stateNotifier.wireData != null,
        'componentDataType': _stateNotifier.componentData?.componentType.toString(),
        'componentDataName': _stateNotifier.componentData?.componentName,
        'targetPositionValid': _stateNotifier.targetPosition != null,
        'targetPositionX': _stateNotifier.targetPosition?.row,
        'targetPositionY': _stateNotifier.targetPosition?.col,
        'wireDataStartPortId': _stateNotifier.wireData?.startPort.id,
        'wireDataStartPortPosition': _stateNotifier.wireData?.startPort.position.toString(),
        'wireDataHasEndPort': _stateNotifier.wireData?.endPort != null,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    StructuredLogger.info(
      '✅ Drag start operation completed successfully',
      context: {
        'operation': 'drag_start_completed',
        'currentMode': _stateNotifier.currentMode.toString(),
        'validationStatus': _stateNotifier.isValid,
        'componentType': details.data?.componentType.toString(),
        'originType': origin.toString(),
        'levelId': levelId,
        'completionTime': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Safe state access methods
  void _setState(InteractionState newState) {
    _stateNotifier.state = newState;
  }

  void _copyWithState({
    InteractionMode? currentMode,
    ComponentDragData? componentData,
    WireDrawData? wireData,
    GridPosition? targetPosition,
    bool? isValid,
    List<GridPosition>? path,
    String? errorMessage,
  }) {
    _setState(InteractionState(
      currentMode: currentMode ?? _stateNotifier.currentMode,
      componentData: componentData ?? _stateNotifier.componentData,
      wireData: wireData ?? _stateNotifier.wireData,
      targetPosition: targetPosition ?? _stateNotifier.targetPosition,
      isValid: isValid ?? _stateNotifier.isValid,
      path: path ?? _stateNotifier.path,
      errorMessage: errorMessage ?? _stateNotifier.errorMessage,
    ));

    StructuredLogger.info('State updated successfully', context: {
      'levelId': levelId,
    });
  }

  void handleDragUpdate(DragTargetDetails<ComponentDragData> details) {
    // Enhanced logging for drag movement
    StructuredLogger.trace(
      '🔄 Drag position update received',
      context: {
        'operation': 'drag_update',
        'positionX': details.offset.dx,
        'positionY': details.offset.dy,
        'componentType': details.data.componentType.toString(),
        'componentName': details.data.componentName,
        'renderBoxAvailable': _renderBox != null,
        'renderBoxAttached': _renderBox?.attached ?? false,
        'currentMode': _stateNotifier.currentMode.toString(),
        'validationThrottled': true, // We're throttling validation for performance
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'frequency': 'throttled', // Throttled to 100ms intervals for performance
      },
    );

    _throttledValidation(details);
  }

  void handleDragEnd(DragTargetDetails<ComponentDragData> details) {
    // Enhanced logging for drag completion with detailed outcome analysis
    print('🔚 CONTROLLER DRAG END - ${details.data?.componentName ?? "UNKNOWN"} - Valid: ${_stateNotifier.isValid}');

    StructuredLogger.info(
      '🎯 Drag operation completed',
      context: {
        'operation': 'drag_end',
        'componentType': details.data?.componentType.toString(),
        'componentName': details.data?.componentName,
        'componentCost': details.data?.cost ?? 0,
        'finalPositionX': details.offset.dx,
        'finalPositionY': details.offset.dy,
        'currentMode': _stateNotifier.currentMode.toString(),
        'validationResult': _stateNotifier.isValid ? 'valid' : 'invalid',
        'hasErrorMessage': _stateNotifier.errorMessage != null,
        'errorMessage': _stateNotifier.errorMessage,
        'renderBoxAvailable': _renderBox != null,
        'renderBoxAttached': _renderBox?.attached ?? false,
        'currentDragDetailsAvailable': _currentDragDetails != null,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    _throttleTimer?.cancel();

    // Comprehensive state analysis before completion
    StructuredLogger.debug(
      '📊 Pre-completion state analysis',
      context: {
        'operation': 'pre_completion_analysis',
        'currentMode': _stateNotifier.currentMode.toString(),
        'validationStatus': _stateNotifier.isValid,
        'hasTargetPosition': _stateNotifier.targetPosition != null,
        'targetPosition': _stateNotifier.targetPosition?.toString(),
        'targetPositionRow': _stateNotifier.targetPosition?.row,
        'targetPositionCol': _stateNotifier.targetPosition?.col,
        'hasComponentData': _stateNotifier.componentData != null,
        'hasWireData': _stateNotifier.wireData != null,
        'componentDataType': _stateNotifier.componentData?.componentType.toString(),
        'componentDataName': _stateNotifier.componentData?.componentName,
        'wireDataStartPortId': _stateNotifier.wireData?.startPort.id,
        'wireDataEndPortId': _stateNotifier.wireData?.endPort?.id,
        'pathSegmentsCount': _stateNotifier.path.length,
        'pathStartPosition': _stateNotifier.path.isNotEmpty ? _stateNotifier.path.first.toString() : null,
        'pathEndPosition': _stateNotifier.path.isNotEmpty ? _stateNotifier.path.last.toString() : null,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Game state comparison for successful placement
    final gameStateBeforeCompletion = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    StructuredLogger.debug(
      '📈 Game state before drag completion',
      context: {
        'operation': 'game_state_before_completion',
        'componentsBefore': gameStateBeforeCompletion.grid.components.length,
        'gameStateGridRows': gameStateBeforeCompletion.grid.rows,
        'gameStateGridCols': gameStateBeforeCompletion.grid.cols,
        'placableComponentType': details.data?.componentType.toString(),
        'levelId': levelId,
      },
    );

    final event = InteractionEvent.dragEnd(details.offset);
    _eventBus.add(event);

    StructuredLogger.info(
      '📨 Drag end event dispatched to event bus',
      context: {
        'operation': 'event_dispatch',
        'eventType': 'drag_end',
        'dispatchStatus': 'success',
        'validationResult': _stateNotifier.isValid,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    StructuredLogger.info(
      '🚀 Drag end handling initiated - component will be placed',
      context: {
        'operation': 'drag_end_initiated',
        'componentType': details.data?.componentType.toString(),
        'finalPosition': details.offset.toString(),
        'validationStatus': _stateNotifier.isValid,
        'levelId': levelId,
      },
    );
  }

  void handlePanUpdate(Offset delta) {
    final currentMode = _stateNotifier.currentMode;
    if (currentMode == InteractionMode.panZoom || currentMode == InteractionMode.idle) {
      final event = InteractionEvent.gesturePan(delta);
      _eventBus.add(event);
    }
  }

  void handleScaleUpdate(double scale) {
    final currentMode = _stateNotifier.currentMode;
    if (currentMode == InteractionMode.panZoom || currentMode == InteractionMode.idle) {
      final event = InteractionEvent.gestureScale(scale);
      _eventBus.add(event);
    }
  }

  void _throttledValidation(DragTargetDetails<ComponentDragData> details) {
    StructuredLogger.trace(
      '⏱️ Validation throttled - scheduled for 100ms',
      context: {
        'operation': 'validation_throttling',
        'throttleDelayMs': 100,
        'dragPositionX': details.offset.dx,
        'dragPositionY': details.offset.dy,
        'componentType': details.data.componentType.toString(),
        'componentName': details.data.componentName,
        'existsExistingThrottleTimer': _throttleTimer != null,
        'levelId': levelId,
        'scheduledTime': DateTime.now().millisecondsSinceEpoch,
      },
    );

    _throttleTimer?.cancel();
    _throttleTimer = Timer(const Duration(milliseconds: 100), () {
      // Performance tracking for validation timing
      final validationStartTime = DateTime.now();

      StructuredLogger.debug(
        '🚀 Coordinate validation started (throttled)',
        context: {
          'operation': 'coordinate_validation_start',
          'renderBoxAvailable': _renderBox != null,
          'renderBoxAttached': _renderBox?.attached ?? false,
          'localPositionX': details.offset.dx,
          'localPositionY': details.offset.dy,
          'dragSourceData': details.data.toString(),
          'levelId': levelId,
          'startTime': validationStartTime.millisecondsSinceEpoch,
        },
      );

      if (_renderBox != null && _renderBox!.attached) {
        // 🔧 FIX: Pass local position directly to avoid coordinate system bugs
        final localPosition = details.offset;

        StructuredLogger.debug(
          '⚡ Coordinate handling (local position preserved)',
          context: {
            'operation': 'coordinate_preservation',
            'localPosition': localPosition.toString(),
            'conversionValid': true,
            'renderBoxAttached': _renderBox!.attached,
            'conversionSucceeded': true,
            'levelId': levelId,
            'conversionTimeMs': DateTime.now().difference(validationStartTime).inMilliseconds,
          },
        );

        final event = InteractionEvent.dragUpdate(localPosition);
        _eventBus.add(event);

        StructuredLogger.debug(
          '📨 Coordinate validation event dispatched',
          context: {
            'operation': 'validation_event_dispatch',
            'eventType': 'drag_update',
            'eventPosition': localPosition.toString(),
            'dispatchStatus': 'success',
            'validationPipelineStarted': true,
            'levelId': levelId,
            'totalValidationTimeMs': DateTime.now().difference(validationStartTime).inMilliseconds,
          },
        );
      } else {
        // Fault handling for missing render box
        StructuredLogger.warning(
          '❌ Coordinate validation failed - render box unavailable',
          context: {
            'operation': 'coordinate_validation_failed',
            'failure_reason': 'render_box_unavailable',
            'renderBoxNull': _renderBox == null,
            'renderBoxAttached': _renderBox?.attached ?? false,
            'dragPosition': details.offset.toString(),
            'componentType': details.data.componentType.toString(),
            'levelId': levelId,
            'failureTime': DateTime.now().millisecondsSinceEpoch,
          },
        );

        // Still dispatch event but with local coordinates (fallback)
        final event = InteractionEvent.dragUpdate(details.offset);
        _eventBus.add(event);
      }
    });
  }

  void _handleInteractionEvents(InteractionEvent event) {
    final context = _buildCoordinateContext();

    event.when(
      dragStart: (position, origin) {
        StructuredLogger.info('Processing drag start event', context: {
          'position': position.toString(),
          'origin': origin.toString(),
          'currentDragDetails': _currentDragDetails != null,
          'componentData': _currentDragDetails?.data?.componentType.toString(),
          'levelId': levelId,
        });

        if (origin == DragOrigin.componentPort) {
          final startPort = _findNearestPort(position);
          if (startPort != null) {
            _stateNotifier.updateValidation(true, position: startPort.position);
            _copyWithState(
              wireData: WireDrawData(startPort: startPort),
              path: [startPort.position],
            );
            StructuredLogger.info('Wire drag started', context: {
              'startPort': startPort.id,
              'position': startPort.position.toString(),
              'levelId': levelId,
            });
          } else {
            _stateNotifier.updateValidation(false, error: 'No valid connection point');
            StructuredLogger.warning('No valid connection point found for wire drag', context: {
              'position': position.toString(),
              'levelId': levelId,
            });
          }
        } else if (origin == DragOrigin.palette) {
          _copyWithState(componentData: _currentDragDetails?.data);
          _stateNotifier.updateValidation(true);
          StructuredLogger.info('Component drag started', context: {
            'componentType': _currentDragDetails?.data?.componentType.toString(),
            'componentName': _currentDragDetails?.data?.componentName,
            'levelId': levelId,
          });
        }
      },
      dragUpdate: (currentPosition) {
        // 🔧 RCA: Comprehensive debugging for coordinate validation
        StructuredLogger.debug('Drag update initiated', context: {
          'screenPosition': currentPosition.toString(),
          'renderBoxAvailable': _renderBox != null,
          'renderBoxAttached': _renderBox?.attached ?? false,
          'levelId': levelId,
        });

        // 🔧 FIX: Use currentPosition directly as it's already local from DragTargetDetails
        if (_renderBox == null || !_renderBox!.attached) {
          StructuredLogger.error('RenderBox not available for coordinate conversion', context: {
            'renderBoxNull': _renderBox == null,
            'renderBoxAttached': _renderBox?.attached ?? false,
            'levelId': levelId,
          });
          _stateNotifier.updateValidation(false, error: 'Canvas not ready');
          return;
        }

        final localPosition = currentPosition; // Already local from DragTargetDetails

        StructuredLogger.debug('Coordinate conversion completed', context: {
          'screenPosition': currentPosition.toString(),
          'localPosition': localPosition.toString(),
          'levelId': levelId,
        });

        final occupiedPositions = _getOccupiedPositions();
        StructuredLogger.debug('Occupied positions calculated', context: {
          'occupiedCount': occupiedPositions.length,
          'occupiedPositions': occupiedPositions.take(5).toList(), // Limit for readability
          'levelId': levelId,
        });

        final validation = _coordinateService.validateDropPosition(
          localPosition, // Pass the local position to avoid double conversion
          context,
          _renderBox!,
          occupiedPositions: occupiedPositions,
        );

        StructuredLogger.debug('Drop position validation result', context: {
          'isValid': validation.isValid,
          'gridPosition': validation.gridPosition?.toString(),
          'errorMessage': validation.errorMessage,
          'warnings': validation.warnings,
          'levelId': levelId,
        });

        final currentState = InteractionState(
          currentMode: _stateNotifier.currentMode,
          componentData: _stateNotifier.componentData,
          wireData: _stateNotifier.wireData,
          targetPosition: _stateNotifier.targetPosition,
          isValid: _stateNotifier.isValid,
          path: _stateNotifier.path,
          errorMessage: _stateNotifier.errorMessage,
        );
        if (currentState.currentMode == InteractionMode.drawWire) {
          final nearestPort = _findNearestConnectionPoint(localPosition);
          if (nearestPort != null) {
            // Calculate path asynchronously
            _calculateWirePath(currentState.wireData!.startPort, nearestPort)
                .then((updatedPath) {
              _stateNotifier.updateValidation(validation.isValid, position: nearestPort.position, path: updatedPath);
            });
          } else {
            _stateNotifier.updateValidation(false, error: 'No valid endpoint');
          }
        } else {
          _stateNotifier.updateValidation(validation.isValid, position: validation.gridPosition);
        }
      },
      dragEnd: (endPosition) async {
        StructuredLogger.info('Processing drag end event', context: {
          'endPosition': endPosition.toString(),
          'currentMode': _stateNotifier.currentMode.toString(),
          'isValid': _stateNotifier.isValid,
          'hasTargetPosition': _stateNotifier.targetPosition != null,
          'hasCurrentDragDetails': _currentDragDetails != null,
          'levelId': levelId,
        });

        final currentState = InteractionState(
          currentMode: _stateNotifier.currentMode,
          componentData: _stateNotifier.componentData,
          wireData: _stateNotifier.wireData,
          targetPosition: _stateNotifier.targetPosition,
          isValid: _stateNotifier.isValid,
          path: _stateNotifier.path,
          errorMessage: _stateNotifier.errorMessage,
        );
        if (currentState.isValid) {
          StructuredLogger.info('🎯 DRAG END - VALID DROP DETECTED', context: {
            'currentMode': currentState.currentMode.toString(),
            'targetPosition': currentState.targetPosition.toString(),
            'currentDragDetails': _currentDragDetails != null,
            'componentType': _currentDragDetails?.data?.componentType.toString(),
            'currentOrigin': _currentOrigin.toString(),
            'levelId': levelId,
          });

          // Guard against duplicate placement: if from palette and grid DragTargets are active, skip placement
          if (_currentOrigin == DragOrigin.palette && currentState.currentMode == InteractionMode.placeComponent) {
            StructuredLogger.info('🎯 DRAG END - SKIPPING PALETTE PLACEMENT (handled by grid)', context: {
              'reason': 'Grid DragTargets handle palette component placement',
              'levelId': levelId,
            });
            return;
          }

          if (currentState.currentMode == InteractionMode.drawWire) {
            StructuredLogger.info('🪙 DRAWING WIRE', context: {
              'pathLength': currentState.path.length,
              'levelId': levelId,
            });
            await _placeWire(currentState.path);
          } else if (currentState.currentMode == InteractionMode.placeComponent) {
            StructuredLogger.info('🪙 PLACING COMPONENT', context: {
              'targetPosition': currentState.targetPosition.toString(),
              'componentType': _currentDragDetails?.data?.componentType.toString(),
              'componentDataNull': _currentDragDetails?.data == null,
              'levelId': levelId,
            });

            if (_currentDragDetails?.data != null) {
              await _placeComponent(currentState.targetPosition!, _currentDragDetails!.data.componentType);
            } else {
              StructuredLogger.error('❌ DRAG END - COMPONENT DATA MISSING', context: {
                'targetPosition': currentState.targetPosition.toString(),
                'currentDragDetailsNull': _currentDragDetails == null,
                'levelId': levelId,
              });
            }
          }
        } else {
          StructuredLogger.warning('🎯 DRAG END - INVALID DROP', context: {
            'errorMessage': currentState.errorMessage,
            'targetPosition': currentState.targetPosition.toString(),
            'isValid': currentState.isValid,
            'levelId': levelId,
          });
          // Provide feedback for invalid drop
          _showErrorFeedback(currentState.errorMessage ?? 'Invalid drop location');
        }

        StructuredLogger.info('Transitioning to idle mode', context: {
          'levelId': levelId,
        });
        _stateNotifier.transitionToMode(InteractionMode.idle);
        _stateNotifier.state = InteractionState(
          currentMode: _stateNotifier.currentMode,
          componentData: null,
          wireData: null,
          targetPosition: null,
          isValid: false,
          path: [],
          errorMessage: null,
        );
      },
      gesturePan: (delta) {
        ref.read(viewportServiceProvider(levelId).notifier).updatePan(delta);
      },
      gestureScale: (scale) {
        ref.read(viewportServiceProvider(levelId).notifier).updateScale(scale);
      },
    );
  }

  CoordinateContext _buildCoordinateContext() {
    final viewportState = ref.read(viewportServiceProvider(levelId));
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);

    final context = CoordinateContext(
      gridDimensions: Size(gameState.grid.cols.toDouble(), gameState.grid.rows.toDouble()),
      cellSize: viewportState.cellSize,
      scale: viewportState.scale,
      panOffset: viewportState.panOffset,
      canvasSize: viewportState.canvasSize,
      devicePixelRatio: 1.0, // Get from MediaQuery in widget
    );

    StructuredLogger.debug('Coordinate context built', context: {
      'gridDimensions': context.gridDimensions.toString(),
      'cellSize': context.cellSize,
      'scale': context.scale,
      'panOffset': context.panOffset.toString(),
      'canvasSize': context.canvasSize.toString(),
      'levelId': levelId,
    });

    return context;
  }

  Set<GridPosition> _getOccupiedPositions() {
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    final occupiedPositions = gameState.grid.components.values
        .map((component) => GridPosition(row: component.row, col: component.col))
        .toSet();

    StructuredLogger.debug('Occupied positions retrieved', context: {
      'totalComponents': gameState.grid.components.length,
      'occupiedPositionsCount': occupiedPositions.length,
      'occupiedPositions': occupiedPositions.take(10).toList(), // Limit for readability
      'gridDimensions': '${gameState.grid.rows}x${gameState.grid.cols}',
      'levelId': levelId,
    });

    return occupiedPositions;
  }

  ComponentPort? _findNearestPort(Offset position) {
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    ComponentPort? nearestPort;
    double minDistance = double.infinity;

    // Search through all components for ports
    for (final component in gameState.grid.components.values) {
      final ports = _getComponentPorts(component);
      for (final port in ports) {
        final portPosition = _getPortScreenPosition(port);
        final distance = (position - portPosition).distance;

        if (distance < minDistance && distance < 50.0) { // 50px tolerance
          minDistance = distance;
          nearestPort = port;
        }
      }
    }

    return nearestPort;
  }

  ComponentPort? _findNearestConnectionPoint(Offset position) {
    // For wire drawing, find nearest port that can accept connections
    final nearestPort = _findNearestPort(position);
    if (nearestPort == null) return null;

    // Check if this port can accept a connection from the current start port
    final currentState = InteractionState(
      currentMode: _stateNotifier.currentMode,
      componentData: _stateNotifier.componentData,
      wireData: _stateNotifier.wireData,
      targetPosition: _stateNotifier.targetPosition,
      isValid: _stateNotifier.isValid,
      path: _stateNotifier.path,
      errorMessage: _stateNotifier.errorMessage,
    );
    if (currentState.wireData?.startPort != null) {
      if (_canConnectPorts(currentState.wireData!.startPort, nearestPort)) {
        return nearestPort;
      }
    }

    return null;
  }

  List<ComponentPort> _getComponentPorts(ComponentModel component) {
    // Get ports for a component based on its type
    final ports = <ComponentPort>[];

    switch (component.type) {
      case ComponentType.battery:
        // Battery has positive and negative terminals
        ports.add(ComponentPort(
          id: '${component.id}_positive',
          position: GridPosition(row: component.row, col: component.col + 1),
          type: PortType.output,
        ));
        ports.add(ComponentPort(
          id: '${component.id}_negative',
          position: GridPosition(row: component.row, col: component.col - 1),
          type: PortType.output,
        ));
        break;

      case ComponentType.resistor:
        // Resistor has two terminals
        ports.add(ComponentPort(
          id: '${component.id}_left',
          position: GridPosition(row: component.row, col: component.col - 1),
          type: PortType.input,
        ));
        ports.add(ComponentPort(
          id: '${component.id}_right',
          position: GridPosition(row: component.row, col: component.col + 1),
          type: PortType.output,
        ));
        break;

      case ComponentType.bulb:
        // Bulb has two terminals
        ports.add(ComponentPort(
          id: '${component.id}_left',
          position: GridPosition(row: component.row, col: component.col - 1),
          type: PortType.input,
        ));
        ports.add(ComponentPort(
          id: '${component.id}_right',
          position: GridPosition(row: component.row, col: component.col + 1),
          type: PortType.output,
        ));
        break;

      case ComponentType.wire:
        // Wire has connection points at both ends
        ports.add(ComponentPort(
          id: '${component.id}_start',
          position: GridPosition(row: component.row, col: component.col),
          type: PortType.input,
        ));
        ports.add(ComponentPort(
          id: '${component.id}_end',
          position: GridPosition(row: component.row, col: component.col + 1),
          type: PortType.output,
        ));
        break;

      default:
        // Default single port for other components
        ports.add(ComponentPort(
          id: '${component.id}_main',
          position: GridPosition(row: component.row, col: component.col),
          type: PortType.input,
        ));
    }

    return ports;
  }

  Offset _getPortScreenPosition(ComponentPort port) {
    final context = _buildCoordinateContext();
    return _coordinateService.gridToLocal(port.position, context);
  }

  bool _canConnectPorts(ComponentPort startPort, ComponentPort endPort) {
    // Basic connection rules:
    // - Cannot connect port to itself
    if (startPort.id == endPort.id) return false;

    // - Cannot connect ports of the same type (input to input, output to output)
    if (startPort.type == endPort.type) return false;

    // - Cannot connect to the same component
    final startComponentId = startPort.id.split('_').first;
    final endComponentId = endPort.id.split('_').first;
    if (startComponentId == endComponentId) return false;

    // Component-specific connection rules
    return _validateComponentConnectionRules(startPort, endPort);
  }

  bool _validateComponentConnectionRules(ComponentPort startPort, ComponentPort endPort) {
    final startComponentId = startPort.id.split('_').first;
    final endComponentId = endPort.id.split('_').first;

    // Get component types from the game state
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    final startComponent = gameState.grid.components[startComponentId];
    final endComponent = gameState.grid.components[endComponentId];

    if (startComponent == null || endComponent == null) return false;

    // Apply component-specific rules
    switch (startComponent.type) {
      case ComponentType.battery:
        return _validateBatteryConnections(startPort, endPort, startComponent, endComponent);

      case ComponentType.resistor:
        return _validateResistorConnections(startPort, endPort, startComponent, endComponent);

      case ComponentType.bulb:
        return _validateBulbConnections(startPort, endPort, startComponent, endComponent);

      case ComponentType.wire:
        return _validateWireConnections(startPort, endPort, startComponent, endComponent);

      default:
        // For unknown components, allow basic input/output connections
        return true;
    }
  }

  bool _validateBatteryConnections(ComponentPort startPort, ComponentPort endPort,
      ComponentModel battery, ComponentModel target) {
    // Battery has positive (output) and negative (output) terminals
    // Can connect to any input or be connected by wires
    if (startPort.type == PortType.output) {
      return endPort.type == PortType.input || target.type == ComponentType.wire;
    }
    return false; // Battery doesn't have input ports
  }

  bool _validateResistorConnections(ComponentPort startPort, ComponentPort endPort,
      ComponentModel resistor, ComponentModel target) {
    // Resistor has input and output terminals
    // Can connect input to battery/wire outputs, output to bulb/wire inputs
    if (startPort.type == PortType.input) {
      return target.type == ComponentType.battery || target.type == ComponentType.wire;
    } else if (startPort.type == PortType.output) {
      return target.type == ComponentType.bulb || target.type == ComponentType.wire;
    }
    return false;
  }

  bool _validateBulbConnections(ComponentPort startPort, ComponentPort endPort,
      ComponentModel bulb, ComponentModel target) {
    // Bulb has input and output terminals
    // Can connect input to resistor/battery outputs, output to other bulbs/wires
    if (startPort.type == PortType.input) {
      return target.type == ComponentType.resistor ||
             target.type == ComponentType.battery ||
             target.type == ComponentType.wire;
    } else if (startPort.type == PortType.output) {
      return target.type == ComponentType.wire;
    }
    return false;
  }

  bool _validateWireConnections(ComponentPort startPort, ComponentPort endPort,
      ComponentModel wire, ComponentModel target) {
    // Wires can connect to any component type
    // They act as bridges between components
    return target.type == ComponentType.battery ||
           target.type == ComponentType.resistor ||
           target.type == ComponentType.bulb ||
           target.type == ComponentType.wire;
  }

  void _showErrorFeedback(String message) {
    // Enhanced error feedback with typing and comprehensive logging
    _stateNotifier.updateValidation(false, error: message);

    // Log different error types appropriately with contextual information
    if (message.contains('outside grid') || message.contains('boundaries')) {
      StructuredLogger.warning('Drop validation failed: Grid boundary violation', context: {
        'errorType': DragDropErrorType.invalidPosition.name,
        'errorMessage': DragDropErrorType.invalidPosition.message,
        'userMessage': message,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

    } else if (message.contains('occupied') || message.contains('already')) {
      StructuredLogger.warning('Drop validation failed: Position occupied', context: {
        'errorType': DragDropErrorType.positionOccupied.name,
        'errorMessage': DragDropErrorType.positionOccupied.message,
        'userMessage': message,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

    } else if (message.contains('inventory') || message.contains('available') || message.contains('not enough')) {
      StructuredLogger.warning('Drop validation failed: Inventory issue', context: {
        'errorType': DragDropErrorType.paletteValidationFailed.name,
        'errorMessage': DragDropErrorType.paletteValidationFailed.message,
        'userMessage': message,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

    } else {
      // Generic error handling
      StructuredLogger.error('Drop validation failed: Unknown or system error', context: {
        'errorType': DragDropErrorType.componentValidationFailed.name,
        'errorMessage': DragDropErrorType.componentValidationFailed.message,
        'rawError': message,
        'levelId': levelId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // Enhanced debug print with error type classification
    debugPrint('🚨 Enhanced Error Feedback: [$levelId] $message');
    debugPrint('📊 Error Category: ${message.contains('grid') ? 'Boundary Error' : message.contains('available') ? 'Inventory Error' : 'Validation Error'}');
  }

  Map<String, List<Map<String, dynamic>>> _groupComponentsByType(List<ComponentModel> components) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final component in components) {
      final typeKey = component.type.toString().split('.').last;
      if (!grouped.containsKey(typeKey)) {
        grouped[typeKey] = [];
      }
      grouped[typeKey]!.add({
        'id': component.id,
        'position': '${component.row},${component.col}',
        'gridCoordinates': '(${component.row},${component.col})',
      });
    }

    return grouped;
  }

  void showSuccessFeedback(BuildContext context, String message) {
    final feedbackService = ref.read(feedbackServiceProvider);
    feedbackService.showSuccess(context, message);
  }

  void showErrorFeedback(BuildContext context, String message) {
    final feedbackService = ref.read(feedbackServiceProvider);
    feedbackService.showError(context, message);
  }

  Future<List<GridPosition>> _calculateWirePath(ComponentPort start, ComponentPort end) async {
    // Get occupied positions for pathfinding
    final occupiedPositions = _getOccupiedPositions();

    // Use A* pathfinding service
    final pathfindingService = ref.read(pathfindingServiceProvider(levelId));
    final result = await pathfindingService.findPath(
      start.position,
      end.position,
      algorithm: PathfindingAlgorithm.astar,
      occupiedPositions: occupiedPositions,
      maxNodes: 500, // Limit for performance
    );

    if (result.success && result.path.isNotEmpty) {
      debugPrint('A* path found: ${result.path.length} nodes, cost: ${result.pathCost}, explored: ${result.nodesExplored}');
      return result.path;
    } else {
      // Fallback to Manhattan if A* fails
      debugPrint('A* pathfinding failed, falling back to Manhattan. Explored: ${result.nodesExplored}');
      return _calculateWirePathManhattan(start, end);
    }
  }

  List<GridPosition> _calculateWirePathManhattan(ComponentPort start, ComponentPort end) {
    // Simple Manhattan path: horizontal then vertical (fallback)
    final path = <GridPosition>[];
    final current = start.position;
    path.add(current);

    // Horizontal move
    final hTarget = GridPosition(row: current.row, col: end.position.col);
    if (hTarget.col > current.col) {
      for (int col = current.col + 1; col <= hTarget.col; col++) {
        path.add(GridPosition(row: current.row, col: col));
      }
    } else {
      for (int col = current.col - 1; col >= hTarget.col; col--) {
        path.add(GridPosition(row: current.row, col: col));
      }
    }

    // Vertical move
    final vTarget = GridPosition(row: end.position.row, col: end.position.col);
    if (vTarget.row > hTarget.row) {
      for (int row = hTarget.row + 1; row <= vTarget.row; row++) {
        path.add(GridPosition(row: row, col: hTarget.col));
      }
    } else {
      for (int row = hTarget.row - 1; row >= vTarget.row; row--) {
        path.add(GridPosition(row: row, col: hTarget.col));
      }
    }

    return path;
  }

  Future<void> _placeWire(List<GridPosition> path) async {
    StructuredLogger.info('🎯 ===== WIRE PLACEMENT ATTEMPT =====', context: {
      'pathLength': path.length,
      'startPosition': path.isNotEmpty ? path.first.toString() : 'none',
      'endPosition': path.isNotEmpty ? path.last.toString() : 'none',
      'levelId': levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (path.isEmpty || path.length < 2) {
      StructuredLogger.warning('🎯 ===== WIRE PLACEMENT FAILED - INVALID PATH =====', context: {
        'pathLength': path.length,
        'levelId': levelId,
      });
      return;
    }

    try {
      final wireNetworkService = ref.read(wireNetworkServiceProvider(levelId));
      final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);

      // Get start and end ports from current wire data
      final currentState = InteractionState(
        currentMode: _stateNotifier.currentMode,
        componentData: _stateNotifier.componentData,
        wireData: _stateNotifier.wireData,
        targetPosition: _stateNotifier.targetPosition,
        isValid: _stateNotifier.isValid,
        path: _stateNotifier.path,
        errorMessage: _stateNotifier.errorMessage,
      );

      if (currentState.wireData == null) {
        StructuredLogger.error('🎯 ===== WIRE PLACEMENT FAILED - NO WIRE DATA =====', context: {
          'levelId': levelId,
        });
        throw Exception('No wire data available for placement');
      }

      final startPort = currentState.wireData!.startPort;
      ComponentPort? endPort;

      StructuredLogger.info('🎯 WIRE PLACEMENT - FINDING END PORT', context: {
        'startPortId': startPort.id,
        'startPortPosition': startPort.position.toString(),
        'endPathPosition': path.last.toString(),
        'levelId': levelId,
      });

      // Find the end port by checking the last position in the path
      final endPosition = path.last;
      endPort = _findNearestPort(Offset(
        endPosition.col.toDouble() * 50, // Assuming 50px cell size
        endPosition.row.toDouble() * 50,
      ));

      if (endPort == null) {
        // Create a virtual end port if no component port found
        endPort = ComponentPort(
          id: 'virtual_end_${DateTime.now().millisecondsSinceEpoch}',
          position: endPosition,
          type: PortType.input, // Default to input for virtual ports
        );
        StructuredLogger.info('🎯 WIRE PLACEMENT - CREATED VIRTUAL END PORT', context: {
          'virtualPortId': endPort.id,
          'position': endPosition.toString(),
          'levelId': levelId,
        });
      } else {
        StructuredLogger.info('🎯 WIRE PLACEMENT - FOUND EXISTING END PORT', context: {
          'endPortId': endPort.id,
          'endPortPosition': endPort.position.toString(),
          'levelId': levelId,
        });
      }

      // Log game state before wire placement
      final gameStateBefore = ref.read(providers_v3.enhancedGameStateNotifierProvider);
      StructuredLogger.info('🎯 WIRE PLACEMENT - STATE BEFORE', context: {
        'componentsBefore': gameStateBefore.grid.components.length,
        'levelId': levelId,
      });

      // Create wire network from path
      StructuredLogger.info('🎯 WIRE PLACEMENT - CREATING NETWORK', context: {
        'pathLength': path.length,
        'levelId': levelId,
      });

      final network = await wireNetworkService.createNetworkFromPath(
        startPort,
        endPort,
        path,
      );

      StructuredLogger.info('🎯 WIRE PLACEMENT - NETWORK CREATED', context: {
        'networkId': network.id,
        'segmentCount': network.segmentCount,
        'totalLength': network.totalLength,
        'levelId': levelId,
      });

      // Place physical wire components for each segment
      int wiresPlaced = 0;
      for (final segment in network.segments) {
        if (segment.type == WireSegmentType.straight) {
          // Place wire components along straight segments
          final positions = _getPositionsInSegment(segment);
          for (final position in positions) {
            // Skip if position already has a component (except wires)
            final existingComponent = _getComponentAtPosition(position);
            if (existingComponent == null || existingComponent.type == ComponentType.wire) {
              gameNotifier.placeComponent(ComponentType.wire, position.row, position.col);
              wiresPlaced++;
            }
          }
        } else if (segment.type == WireSegmentType.corner) {
          // Place corner component
          final cornerPosition = GridPosition(
            row: (segment.startPosition.row + segment.endPosition.row) ~/ 2,
            col: (segment.startPosition.col + segment.endPosition.col) ~/ 2,
          );
          gameNotifier.placeComponent(ComponentType.wire, cornerPosition.row, cornerPosition.col);
          wiresPlaced++;
        }
      }

      // Log game state after wire placement
      final gameStateAfter = ref.read(providers_v3.enhancedGameStateNotifierProvider);
      StructuredLogger.info('🎯 WIRE PLACEMENT - STATE AFTER', context: {
        'componentsAfter': gameStateAfter.grid.components.length,
        'wiresPlaced': wiresPlaced,
        'placementSuccessful': gameStateAfter.grid.components.length > gameStateBefore.grid.components.length,
        'levelId': levelId,
      });

      // Store the network for future reference
      _wirePaths[network.id] = WirePath(
        id: network.id,
        startPosition: network.startPort.position,
        endPosition: network.endPort?.position ?? endPosition,
        intermediatePoints: network.segments
            .expand((segment) => _getIntermediatePoints(segment))
            .toList(),
        createdAt: network.createdAt,
      );

      StructuredLogger.info('🎯 ===== WIRE PLACEMENT SUCCESS =====', context: {
        'networkId': network.id,
        'segments': network.segmentCount,
        'length': network.totalLength,
        'wiresPlaced': wiresPlaced,
        'levelId': levelId,
      });

      // Show success feedback
      final context = await _getBuildContext();
      if (context != null) {
        showSuccessFeedback(context, 'Wire connected successfully!');
      }

    } catch (e) {
      StructuredLogger.error('🎯 ===== WIRE PLACEMENT FAILED =====', context: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'levelId': levelId,
      });
      _showErrorFeedback('Failed to place wire: $e');
    }
  }

  /// Get all positions in a wire segment
  List<GridPosition> _getPositionsInSegment(WireSegment segment) {
    final positions = <GridPosition>[];

    if (segment.isHorizontal) {
      final startCol = segment.startPosition.col < segment.endPosition.col
          ? segment.startPosition.col : segment.endPosition.col;
      final endCol = segment.startPosition.col < segment.endPosition.col
          ? segment.endPosition.col : segment.startPosition.col;

      for (int col = startCol; col <= endCol; col++) {
        positions.add(GridPosition(row: segment.startPosition.row, col: col));
      }
    } else if (segment.isVertical) {
      final startRow = segment.startPosition.row < segment.endPosition.row
          ? segment.startPosition.row : segment.endPosition.row;
      final endRow = segment.startPosition.row < segment.endPosition.row
          ? segment.endPosition.row : segment.startPosition.row;

      for (int row = startRow; row <= endRow; row++) {
        positions.add(GridPosition(row: row, col: segment.startPosition.col));
      }
    }

    return positions;
  }

  /// Get intermediate points for a segment
  List<GridPosition> _getIntermediatePoints(WireSegment segment) {
    final points = _getPositionsInSegment(segment);
    if (points.length >= 2) {
      return points.sublist(1, points.length - 1); // Exclude start and end
    }
    return [];
  }

  /// Get component at position
  ComponentModel? _getComponentAtPosition(GridPosition position) {
    final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    return gameState.grid.components.values.firstWhere(
      (component) => component.row == position.row && component.col == position.col,
      orElse: () => ComponentModel(
        id: '',
        type: ComponentType.wire, // Dummy
        row: -1,
        col: -1,
      ),
    );
  }

  /// Get build context for feedback (this would need to be passed from widget)
  Future<BuildContext?> _getBuildContext() async {
    // This is a placeholder - in real implementation, context would be passed
    // from the widget layer or stored during initialization
    return null;
  }

  Future<void> _placeComponent(GridPosition position, ComponentType type) async {
    StructuredLogger.info('🎯 ===== COMPONENT PLACEMENT ATTEMPT =====', context: {
      'position': position.toString(),
      'componentType': type.toString(),
      'levelId': levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final paletteState = ref.read(paletteStateProvider(levelId));
    final componentName = type.toString().split('.').last;

    StructuredLogger.debug('🎯 COMPONENT PLACEMENT - PALETTE CHECK', context: {
      'componentName': componentName,
      'canUseComponent': paletteState.canUseComponent(componentName),
      'availableCount': paletteState.inventory[type]?.available ?? 0,
      'totalCount': paletteState.inventory[type]?.total ?? 0,
      'levelId': levelId,
    });

    if (!paletteState.canUseComponent(componentName)) {
      StructuredLogger.error('🎯 ===== COMPONENT PLACEMENT FAILED - NOT AVAILABLE =====', context: {
        'componentName': componentName,
        'availableCount': paletteState.inventory[type]?.available ?? 0,
        'totalCount': paletteState.inventory[type]?.total ?? 0,
        'levelId': levelId,
      });
      return;
    }

    // Log game state before placement
    final gameStateBefore = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    StructuredLogger.info('🎯 COMPONENT PLACEMENT - STATE BEFORE', context: {
      'componentsBefore': gameStateBefore.grid.components.length,
      'gridPosition': position.toString(),
      'levelId': levelId,
    });

    final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);

    // Clamp the position to ensure it's not negative.
    final clampedRow = max(0, position.row);
    final clampedCol = max(0, position.col);
    final clampedPosition = GridPosition(row: clampedRow, col: clampedCol);

    StructuredLogger.info('🎯 COMPONENT PLACEMENT - EXECUTING PLACEMENT', context: {
      'originalPosition': position.toString(),
      'clampedPosition': clampedPosition.toString(),
      'componentType': type.toString(),
      'levelId': levelId,
    });

    gameNotifier.placeComponent(type, clampedPosition.row, clampedPosition.col);

    // 🔧 INVENTORY FIX: Decrement inventory count after successful placement
    final paletteNotifier = ref.read(paletteStateProvider(levelId).notifier);
    final componentTypeString = type.toString().split('.').last;
    paletteNotifier.useComponent(componentTypeString);

    // Log game state after placement
    final gameStateAfter = ref.read(providers_v3.enhancedGameStateNotifierProvider);
    StructuredLogger.info('🎯 COMPONENT PLACEMENT - STATE AFTER', context: {
      'componentsAfter': gameStateAfter.grid.components.length,
      'placementSuccessful': gameStateAfter.grid.components.length > gameStateBefore.grid.components.length,
      'levelId': levelId,
    });

    if (gameStateAfter.grid.components.length > gameStateBefore.grid.components.length) {
      StructuredLogger.info('🎯 ===== COMPONENT PLACEMENT SUCCESS =====', context: {
        'position': clampedPosition.toString(),
        'componentType': type.toString(),
        'componentId': gameStateAfter.grid.components.values.last.id,
        'gridPosition': '${clampedPosition.row},${clampedPosition.col}',
        'levelId': levelId,
      });

      // Simple grid placement logging that user expects
      StructuredLogger.info('🎯 Component placed on grid', context: {
        'component': type.toString().split('.').last,
        'position': '${clampedPosition.row},${clampedPosition.col}',
        'gridRow': clampedPosition.row,
        'gridCol': clampedPosition.col,
      });

      // Log updated inventory after placement
      final updatedPaletteState = ref.read(paletteStateProvider(levelId));

      // Simple inventory logging that user expects
      StructuredLogger.info('🎯 Inventory state after placement', context: {
        'available': updatedPaletteState.inventory[type]?.available ?? 0,
        'total': updatedPaletteState.inventory[type]?.total ?? 0,
        'used': updatedPaletteState.inventory[type]?.used ?? 0,
      });

      StructuredLogger.info('🎯 COMPONENT PLACEMENT - INVENTORY AFTER PLACEMENT', context: {
        'componentType': type.toString(),
        'inventoryBefore': {'available': paletteState.inventory[type]?.available ?? 0, 'total': paletteState.inventory[type]?.total ?? 0},
        'inventoryAfter': {'available': updatedPaletteState.inventory[type]?.available ?? 0, 'total': updatedPaletteState.inventory[type]?.total ?? 0},
        'usedThisPlacement': (paletteState.inventory[type]?.available ?? 0) - (updatedPaletteState.inventory[type]?.available ?? 0),
        'allInventoryCounts': updatedPaletteState.inventory.map((key, value) =>
          MapEntry(key, {'available': value.available, 'total': value.total, 'used': value.total - value.available})),
        'levelId': levelId,
      });

      // Log all placed components on grid
      StructuredLogger.info('🎯 COMPONENT PLACEMENT - CURRENT GRID STATE', context: {
        'totalComponentsOnGrid': gameStateAfter.grid.components.length,
        'gridDimensions': '${gameStateAfter.grid.rows}x${gameStateAfter.grid.cols}',
        'allPlacedComponents': gameStateAfter.grid.components.values.map((c) => {
          'id': c.id,
          'type': c.type.toString(),
          'position': '${c.row},${c.col}',
          'gridCoordinates': '(${c.row},${c.col})',
        }).toList(),
        'componentsByType': _groupComponentsByType(gameStateAfter.grid.components.values.toList()),
        'levelId': levelId,
      });

      ref.read(paletteStateProvider(levelId).notifier).stopPlacingComponent();

      StructuredLogger.info('🎯 COMPONENT PLACEMENT - PALETTE UPDATED', context: {
        'levelId': levelId,
      });
    } else {
      StructuredLogger.error('🎯 ===== COMPONENT PLACEMENT FAILED - NO COMPONENT ADDED =====', context: {
        'position': clampedPosition.toString(),
        'componentType': type.toString(),
        'levelId': levelId,
      });
    }
  }
}
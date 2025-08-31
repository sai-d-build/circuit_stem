// Interactive Gameplay Mechanics System
// Simplified version without Freezed for compilation

import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/component.dart';
import '../../domain/entities/grid.dart';
import '../../common/feature_flags.dart';

// Simplified classes without Freezed
class InteractiveMechanics {
  DragDropSystem? dragDropSystem;
  RotationSystem? rotationSystem;
  ToggleSystem? toggleSystem;
  GestureHandler? gestureHandler;
  FeedbackSystem? feedbackSystem;
  InteractionState? interactionState;

  InteractiveMechanics({
    this.dragDropSystem,
    this.rotationSystem,
    this.toggleSystem,
    this.gestureHandler,
    this.feedbackSystem,
    this.interactionState,
  });
}

class DragDropSystem {
  DragState currentDragState;
  DropZoneManager dropZoneManager;
  ComponentPlacementValidator placementValidator;
  DragAnimationController animationController;
  Map<String, DragSession> activeDragSessions;

  DragDropSystem({
    required this.currentDragState,
    required this.dropZoneManager,
    required this.placementValidator,
    required this.animationController,
    required this.activeDragSessions,
  });
}

class DragState {
  bool isDragging;
  String? draggedComponentId;
  Offset? dragPosition;
  Offset? dragOffset;
  DragPhase phase;
  Map<String, dynamic> dragData;

  DragState({
    required this.isDragging,
    this.draggedComponentId,
    this.dragPosition,
    this.dragOffset,
    required this.phase,
    required this.dragData,
  });
}

enum DragPhase { idle, started, dragging, hovering, dropping, completed, cancelled }

class DragSession {
  String sessionId;
  String componentId;
  Offset startPosition;
  Offset currentPosition;
  DateTime startTime;
  List<Offset> dragPath;
  Map<String, dynamic> sessionData;

  DragSession({
    required this.sessionId,
    required this.componentId,
    required this.startPosition,
    required this.currentPosition,
    required this.startTime,
    required this.dragPath,
    required this.sessionData,
  });
}

class DropZoneManager {
  List<DropZone> activeDropZones;
  Map<String, DropZone> dropZoneRegistry;
  DropZone? highLightedZone;
  bool snapToGridEnabled;
  double gridSize;

  DropZoneManager({
    required this.activeDropZones,
    required this.dropZoneRegistry,
    this.highLightedZone,
    required this.snapToGridEnabled,
    required this.gridSize,
  });
}

class DropZone {
  String zoneId;
  Rect bounds;
  DropZoneType type;
  bool isActive;
  bool isHighlighted;
  Map<String, dynamic> zoneData;
  List<String> acceptedComponentTypes;

  DropZone({
    required this.zoneId,
    required this.bounds,
    required this.type,
    required this.isActive,
    required this.isHighlighted,
    required this.zoneData,
    required this.acceptedComponentTypes,
  });
}

enum DropZoneType { gridCell, componentSlot, trashZone, paletteArea, circuitArea }

class ComponentPlacementValidator {
  List<ValidationRule> placementRules;
  Map<String, ComponentConstraints> componentConstraints;
  CircuitStateValidator circuitValidator;
  bool realTimeValidationEnabled;

  ComponentPlacementValidator({
    required this.placementRules,
    required this.componentConstraints,
    required this.circuitValidator,
    required this.realTimeValidationEnabled,
  });
}

class ValidationRule {
  String ruleId;
  String ruleType;
  Map<String, dynamic> parameters;
  ValidationSeverity severity;
  String errorMessage;
  String successMessage;

  ValidationRule({
    required this.ruleId,
    required this.ruleType,
    required this.parameters,
    required this.severity,
    required this.errorMessage,
    required this.successMessage,
  });
}

enum ValidationSeverity { info, warning, error, critical }

class ComponentConstraints {
  String componentType;
  List<String> allowedZones;
  List<String> restrictedZones;
  Map<String, dynamic> placementRules;
  List<String> requiredConnections;
  List<String> forbiddenConnections;

  ComponentConstraints({
    required this.componentType,
    required this.allowedZones,
    required this.restrictedZones,
    required this.placementRules,
    required this.requiredConnections,
    required this.forbiddenConnections,
  });
}

class CircuitStateValidator {
  List<CircuitRule> circuitRules;
  Map<String, CircuitState> validationStates;
  bool continuousValidation;
  Duration validationDebounce;

  CircuitStateValidator({
    required this.circuitRules,
    required this.validationStates,
    required this.continuousValidation,
    required this.validationDebounce,
  });
}

class CircuitRule {
  String ruleId;
  String ruleType;
  Map<String, dynamic> parameters;
  ValidationSeverity severity;
  String description;

  CircuitRule({
    required this.ruleId,
    required this.ruleType,
    required this.parameters,
    required this.severity,
    required this.description,
  });
}

class CircuitState {
  bool isValid;
  List<String> errors;
  List<String> warnings;
  List<String> suggestions;
  Map<String, ComponentState> componentStates;

  CircuitState({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.suggestions,
    required this.componentStates,
  });
}

class ComponentState {
  String componentId;
  bool isValid;
  List<String> issues;
  ComponentStatus status;
  Map<String, dynamic> stateData;

  ComponentState({
    required this.componentId,
    required this.isValid,
    required this.issues,
    required this.status,
    required this.stateData,
  });
}

enum ComponentStatus { valid, invalid, warning, pending, disconnected }

class DragAnimationController {
  Map<String, AnimationController> activeAnimations;
  AnimationConfig dragAnimationConfig;
  AnimationConfig dropAnimationConfig;
  AnimationConfig snapAnimationConfig;

  DragAnimationController({
    required this.activeAnimations,
    required this.dragAnimationConfig,
    required this.dropAnimationConfig,
    required this.snapAnimationConfig,
  });
}

class AnimationConfig {
  Duration duration;
  Curve curve;
  double scale;
  Color highlightColor;
  double opacity;

  AnimationConfig({
    required this.duration,
    required this.curve,
    required this.scale,
    required this.highlightColor,
    required this.opacity,
  });
}

class RotationSystem {
  Map<String, ComponentRotation> componentRotations;
  RotationGestureHandler gestureHandler;
  RotationAnimationController animationController;
  List<double> allowedAngles;
  bool snapToAngles;
  double rotationStep;

  RotationSystem({
    required this.componentRotations,
    required this.gestureHandler,
    required this.animationController,
    required this.allowedAngles,
    required this.snapToAngles,
    required this.rotationStep,
  });
}

class ComponentRotation {
  String componentId;
  double currentAngle;
  double targetAngle;
  bool isRotating;
  RotationConstraints constraints;

  ComponentRotation({
    required this.componentId,
    required this.currentAngle,
    required this.targetAngle,
    required this.isRotating,
    required this.constraints,
  });
}

class RotationConstraints {
  List<double> allowedAngles;
  double minAngle;
  double maxAngle;
  double stepSize;
  bool allowContinuous;

  RotationConstraints({
    required this.allowedAngles,
    required this.minAngle,
    required this.maxAngle,
    required this.stepSize,
    required this.allowContinuous,
  });
}

class RotationGestureHandler {
  Map<String, RotationGesture> activeGestures;
  double rotationSensitivity;
  double minRotationDistance;
  bool multiTouchEnabled;

  RotationGestureHandler({
    required this.activeGestures,
    required this.rotationSensitivity,
    required this.minRotationDistance,
    required this.multiTouchEnabled,
  });
}

class RotationGesture {
  String gestureId;
  String componentId;
  Offset centerPoint;
  double startAngle;
  double currentAngle;
  List<Offset> touchPoints;

  RotationGesture({
    required this.gestureId,
    required this.componentId,
    required this.centerPoint,
    required this.startAngle,
    required this.currentAngle,
    required this.touchPoints,
  });
}

class RotationAnimationController {
  Map<String, AnimationController> activeAnimations;
  Duration rotationDuration;
  Curve rotationCurve;
  bool smoothRotation;

  RotationAnimationController({
    required this.activeAnimations,
    required this.rotationDuration,
    required this.rotationCurve,
    required this.smoothRotation,
  });
}

class ToggleSystem {
  Map<String, ToggleState> componentToggles;
  ToggleGestureHandler gestureHandler;
  ToggleAnimationController animationController;
  Map<String, ToggleConstraints> toggleConstraints;

  ToggleSystem({
    required this.componentToggles,
    required this.gestureHandler,
    required this.animationController,
    required this.toggleConstraints,
  });
}

class ToggleState {
  String componentId;
  bool isToggled;
  TogglePosition position;
  bool isAnimating;
  Map<String, dynamic> toggleData;

  ToggleState({
    required this.componentId,
    required this.isToggled,
    required this.position,
    required this.isAnimating,
    required this.toggleData,
  });
}

enum TogglePosition { off, on, intermediate }

class ToggleConstraints {
  String componentType;
  bool allowToggle;
  Duration toggleDelay;
  bool requireConfirmation;
  List<String> toggleConditions;

  ToggleConstraints({
    required this.componentType,
    required this.allowToggle,
    required this.toggleDelay,
    required this.requireConfirmation,
    required this.toggleConditions,
  });
}

class ToggleGestureHandler {
  Map<String, ToggleGesture> activeGestures;
  double tapThreshold;
  Duration doubleTapDelay;
  bool hapticFeedbackEnabled;

  ToggleGestureHandler({
    required this.activeGestures,
    required this.tapThreshold,
    required this.doubleTapDelay,
    required this.hapticFeedbackEnabled,
  });
}

class ToggleGesture {
  String gestureId;
  String componentId;
  Offset tapPosition;
  DateTime tapTime;
  int tapCount;

  ToggleGesture({
    required this.gestureId,
    required this.componentId,
    required this.tapPosition,
    required this.tapTime,
    required this.tapCount,
  });
}

class ToggleAnimationController {
  Map<String, AnimationController> activeAnimations;
  Duration toggleDuration;
  Curve toggleCurve;
  Map<String, ToggleAnimation> toggleAnimations;

  ToggleAnimationController({
    required this.activeAnimations,
    required this.toggleDuration,
    required this.toggleCurve,
    required this.toggleAnimations,
  });
}

class ToggleAnimation {
  String animationId;
  String componentId;
  TogglePosition fromPosition;
  TogglePosition toPosition;
  double progress;

  ToggleAnimation({
    required this.animationId,
    required this.componentId,
    required this.fromPosition,
    required this.toPosition,
    required this.progress,
  });
}

class GestureHandler {
  Map<String, GestureRecognizer> activeRecognizers;
  GestureConfig config;
  GestureState state;
  List<GestureEvent> eventQueue;

  GestureHandler({
    required this.activeRecognizers,
    required this.config,
    required this.state,
    required this.eventQueue,
  });
}

class GestureRecognizer {
  String recognizerId;
  GestureType type;
  Map<String, dynamic> config;
  GestureState recognizerState;

  GestureRecognizer({
    required this.recognizerId,
    required this.type,
    required this.config,
    required this.recognizerState,
  });
}

enum GestureType { drag, rotate, toggle, pinch, swipe, tap, doubleTap, longPress }

class GestureConfig {
  double dragThreshold;
  double rotationThreshold;
  Duration tapTimeout;
  Duration longPressTimeout;
  bool multiTouchEnabled;
  bool hapticFeedbackEnabled;

  GestureConfig({
    required this.dragThreshold,
    required this.rotationThreshold,
    required this.tapTimeout,
    required this.longPressTimeout,
    required this.multiTouchEnabled,
    required this.hapticFeedbackEnabled,
  });
}

class GestureState {
  bool isActive;
  GestureType? activeGesture;
  Map<String, dynamic> gestureData;
  List<String> activeComponents;

  GestureState({
    required this.isActive,
    this.activeGesture,
    required this.gestureData,
    required this.activeComponents,
  });
}

class GestureEvent {
  String eventId;
  GestureType type;
  String componentId;
  Offset position;
  Map<String, dynamic> eventData;
  DateTime timestamp;

  GestureEvent({
    required this.eventId,
    required this.type,
    required this.componentId,
    required this.position,
    required this.eventData,
    required this.timestamp,
  });
}

class FeedbackSystem {
  Map<String, FeedbackAnimation> activeFeedback;
  FeedbackConfig config;
  HapticFeedbackController hapticController;
  AudioFeedbackController audioController;
  VisualFeedbackController visualController;

  FeedbackSystem({
    required this.activeFeedback,
    required this.config,
    required this.hapticController,
    required this.audioController,
    required this.visualController,
  });
}

class FeedbackAnimation {
  String animationId;
  String componentId;
  FeedbackType type;
  double intensity;
  Duration duration;
  Map<String, dynamic> animationData;

  FeedbackAnimation({
    required this.animationId,
    required this.componentId,
    required this.type,
    required this.intensity,
    required this.duration,
    required this.animationData,
  });
}

enum FeedbackType { success, error, warning, highlight, pulse, shake, glow }

class FeedbackConfig {
  bool hapticEnabled;
  bool audioEnabled;
  bool visualEnabled;
  double feedbackIntensity;
  Map<FeedbackType, FeedbackSettings> feedbackSettings;

  FeedbackConfig({
    required this.hapticEnabled,
    required this.audioEnabled,
    required this.visualEnabled,
    required this.feedbackIntensity,
    required this.feedbackSettings,
  });
}

class FeedbackSettings {
  Duration duration;
  double intensity;
  Color color;
  bool repeat;
  int repeatCount;

  FeedbackSettings({
    required this.duration,
    required this.intensity,
    required this.color,
    required this.repeat,
    required this.repeatCount,
  });
}

class HapticFeedbackController {
  bool isEnabled;
  Map<String, HapticPattern> patterns;
  double intensity;

  HapticFeedbackController({
    required this.isEnabled,
    required this.patterns,
    required this.intensity,
  });
}

class HapticPattern {
  String patternId;
  List<HapticEvent> events;
  Duration totalDuration;

  HapticPattern({
    required this.patternId,
    required this.events,
    required this.totalDuration,
  });
}

class HapticEvent {
  Duration delay;
  double intensity;
  HapticType type;

  HapticEvent({
    required this.delay,
    required this.intensity,
    required this.type,
  });
}

enum HapticType { light, medium, heavy, success, warning, error }

class AudioFeedbackController {
  bool isEnabled;
  Map<String, AudioClip> clips;
  double volume;

  AudioFeedbackController({
    required this.isEnabled,
    required this.clips,
    required this.volume,
  });
}

class AudioClip {
  String clipId;
  String assetPath;
  Duration duration;
  double volume;

  AudioClip({
    required this.clipId,
    required this.assetPath,
    required this.duration,
    required this.volume,
  });
}

class VisualFeedbackController {
  bool isEnabled;
  Map<String, VisualEffect> effects;
  double opacity;

  VisualFeedbackController({
    required this.isEnabled,
    required this.effects,
    required this.opacity,
  });
}

class VisualEffect {
  String effectId;
  VisualEffectType type;
  Color color;
  Duration duration;
  double intensity;

  VisualEffect({
    required this.effectId,
    required this.type,
    required this.color,
    required this.duration,
    required this.intensity,
  });
}

enum VisualEffectType { glow, pulse, shake, highlight, ripple, sparkle }

class InteractionState {
  bool isInteracting;
  String? activeComponentId;
  InteractionMode mode;
  Map<String, dynamic> interactionData;
  List<InteractionHistory> history;

  InteractionState({
    required this.isInteracting,
    this.activeComponentId,
    required this.mode,
    required this.interactionData,
    required this.history,
  });
}

enum InteractionMode { idle, dragging, rotating, toggling, multiSelect, connecting }

class InteractionHistory {
  String historyId;
  InteractionType type;
  String componentId;
  Map<String, dynamic> beforeState;
  Map<String, dynamic> afterState;
  DateTime timestamp;

  InteractionHistory({
    required this.historyId,
    required this.type,
    required this.componentId,
    required this.beforeState,
    required this.afterState,
    required this.timestamp,
  });
}

enum InteractionType { drag, rotate, toggle, connect, disconnect, delete, create }

// Simplified service class
class InteractiveMechanicsService {
  InteractiveMechanics? _mechanics;
  final Map<String, ComponentInteractionHandler> _componentHandlers = {};

  Future<void> initialize() async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableInteractiveMechanics)) {
      throw UnsupportedError('Interactive mechanics are not enabled');
    }

    _mechanics ??= InteractiveMechanics(
      dragDropSystem: _createDragDropSystem(),
      rotationSystem: _createRotationSystem(),
      toggleSystem: _createToggleSystem(),
      gestureHandler: _createGestureHandler(),
      feedbackSystem: _createFeedbackSystem(),
      interactionState: InteractionState(
        isInteracting: false,
        activeComponentId: null,
        mode: InteractionMode.idle,
        interactionData: {},
        history: [],
      ),
    );

    await _loadComponentHandlers();
  }

  // Basic implementations for compilation
  DragDropSystem _createDragDropSystem() {
    return DragDropSystem(
      currentDragState: DragState(
        isDragging: false,
        phase: DragPhase.idle,
        dragData: {},
      ),
      dropZoneManager: DropZoneManager(
        activeDropZones: [],
        dropZoneRegistry: {},
        snapToGridEnabled: true,
        gridSize: 20.0,
      ),
      placementValidator: ComponentPlacementValidator(
        placementRules: [],
        componentConstraints: {},
        circuitValidator: CircuitStateValidator(
          circuitRules: [],
          validationStates: {},
          continuousValidation: true,
          validationDebounce: const Duration(milliseconds: 100),
        ),
        realTimeValidationEnabled: true,
      ),
      animationController: DragAnimationController(
        activeAnimations: {},
        dragAnimationConfig: AnimationConfig(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          scale: 1.1,
          highlightColor: Colors.blue,
          opacity: 0.8,
        ),
        dropAnimationConfig: AnimationConfig(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          scale: 1.0,
          highlightColor: Colors.green,
          opacity: 1.0,
        ),
        snapAnimationConfig: AnimationConfig(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          scale: 1.0,
          highlightColor: Colors.yellow,
          opacity: 1.0,
        ),
      ),
      activeDragSessions: {},
    );
  }

  RotationSystem _createRotationSystem() {
    return RotationSystem(
      componentRotations: {},
      gestureHandler: RotationGestureHandler(
        activeGestures: {},
        rotationSensitivity: 0.5,
        minRotationDistance: 20.0,
        multiTouchEnabled: true,
      ),
      animationController: RotationAnimationController(
        activeAnimations: {},
        rotationDuration: const Duration(milliseconds: 300),
        rotationCurve: Curves.elasticOut,
        smoothRotation: true,
      ),
      allowedAngles: [0, 90, 180, 270],
      snapToAngles: true,
      rotationStep: 90.0,
    );
  }

  ToggleSystem _createToggleSystem() {
    return ToggleSystem(
      componentToggles: {},
      gestureHandler: ToggleGestureHandler(
        activeGestures: {},
        tapThreshold: 10.0,
        doubleTapDelay: const Duration(milliseconds: 300),
        hapticFeedbackEnabled: true,
      ),
      animationController: ToggleAnimationController(
        activeAnimations: {},
        toggleDuration: const Duration(milliseconds: 200),
        toggleCurve: Curves.easeInOut,
        toggleAnimations: {},
      ),
      toggleConstraints: {},
    );
  }

  GestureHandler _createGestureHandler() {
    return GestureHandler(
      activeRecognizers: {},
      config: GestureConfig(
        dragThreshold: 10.0,
        rotationThreshold: 15.0,
        tapTimeout: const Duration(milliseconds: 200),
        longPressTimeout: const Duration(milliseconds: 500),
        multiTouchEnabled: true,
        hapticFeedbackEnabled: true,
      ),
      state: GestureState(
        isActive: false,
        gestureData: {},
        activeComponents: [],
      ),
      eventQueue: [],
    );
  }

  FeedbackSystem _createFeedbackSystem() {
    return FeedbackSystem(
      activeFeedback: {},
      config: FeedbackConfig(
        hapticEnabled: true,
        audioEnabled: true,
        visualEnabled: true,
        feedbackIntensity: 1.0,
        feedbackSettings: {},
      ),
      hapticController: HapticFeedbackController(
        isEnabled: true,
        patterns: {},
        intensity: 1.0,
      ),
      audioController: AudioFeedbackController(
        isEnabled: true,
        clips: {},
        volume: 0.7,
      ),
      visualController: VisualFeedbackController(
        isEnabled: true,
        effects: {},
        opacity: 1.0,
      ),
    );
  }

  Future<void> _loadComponentHandlers() async {
    // TODO: Load component-specific interaction handlers
  }
}

// Result classes for compilation
class DragResult {
  final String? sessionId;
  final String? componentId;
  final Offset? startPosition;
  final Offset? currentPosition;
  final Offset? endPosition;
  final ComponentPlacementResult? placementResult;
  final String? errorMessage;

  DragResult._({
    this.sessionId,
    this.componentId,
    this.startPosition,
    this.currentPosition,
    this.endPosition,
    this.placementResult,
    this.errorMessage,
  });

  factory DragResult.success({
    required String sessionId,
    required String componentId,
    Offset? startPosition,
    Offset? currentPosition,
    Offset? endPosition,
    ComponentPlacementResult? placementResult,
  }) {
    return DragResult._(
      sessionId: sessionId,
      componentId: componentId,
      startPosition: startPosition,
      currentPosition: currentPosition,
      endPosition: endPosition,
      placementResult: placementResult,
    );
  }

  factory DragResult.failure(String errorMessage, {
    String? sessionId,
    String? componentId,
  }) {
    return DragResult._(
      errorMessage: errorMessage,
      sessionId: sessionId,
      componentId: componentId,
    );
  }
}

class ComponentPlacementResult {
  final String componentId;
  final Offset finalPosition;
  final DropZone dropZone;
  final bool snappedToGrid;
  final Map<String, dynamic>? placementData;

  ComponentPlacementResult({
    required this.componentId,
    required this.finalPosition,
    required this.dropZone,
    required this.snappedToGrid,
    this.placementData,
  });
}

class PlacementValidation {
  final bool isValid;
  final String? errorMessage;

  PlacementValidation._({required this.isValid, this.errorMessage});

  factory PlacementValidation.valid() {
    return PlacementValidation._(isValid: true);
  }
  factory PlacementValidation.invalid(String errorMessage) {
    return PlacementValidation._(isValid: false, errorMessage: errorMessage);
  }
}

class RotationResult {
  final String? componentId;
  final double? finalAngle;
  final ComponentRotationResult? rotationResult;
  final String? errorMessage;

  RotationResult._({
    this.componentId,
    this.finalAngle,
    this.rotationResult,
    this.errorMessage,
  });

  factory RotationResult.success({
    required String componentId,
    required double finalAngle,
    ComponentRotationResult? rotationResult,
  }) {
    return RotationResult._(
      componentId: componentId,
      finalAngle: finalAngle,
      rotationResult: rotationResult,
    );
  }

  factory RotationResult.failure(String errorMessage) {
    return RotationResult._(errorMessage: errorMessage);
  }
}

class ComponentRotationResult {
  final String componentId;
  final double finalAngle;
  final bool animationCompleted;
  final Map<String, dynamic>? rotationData;

  ComponentRotationResult({
    required this.componentId,
    required this.finalAngle,
    required this.animationCompleted,
    this.rotationData,
  });
}

class RotationValidation {
  final bool isValid;
  final String? errorMessage;

  RotationValidation._({required this.isValid, this.errorMessage});

  factory RotationValidation.valid() {
    return RotationValidation._(isValid: true);
  }
  factory RotationValidation.invalid(String errorMessage) {
    return RotationValidation._(isValid: false, errorMessage: errorMessage);
  }
}

class ToggleResult {
  final String? componentId;
  final TogglePosition? newPosition;
  final ComponentToggleResult? toggleResult;
  final String? errorMessage;

  ToggleResult._({
    this.componentId,
    this.newPosition,
    this.toggleResult,
    this.errorMessage,
  });

  factory ToggleResult.success({
    required String componentId,
    required TogglePosition newPosition,
    ComponentToggleResult? toggleResult,
  }) {
    return ToggleResult._(
      componentId: componentId,
      newPosition: newPosition,
      toggleResult: toggleResult,
    );
  }

  factory ToggleResult.failure(String errorMessage) {
    return ToggleResult._(errorMessage: errorMessage);
  }
}

class ComponentToggleResult {
  final String componentId;
  final TogglePosition finalPosition;
  final bool animationCompleted;
  final Map<String, dynamic>? toggleData;

  ComponentToggleResult({
    required this.componentId,
    required this.finalPosition,
    required this.animationCompleted,
    this.toggleData,
  });
}

class ToggleValidation {
  final bool isValid;
  final String? errorMessage;

  ToggleValidation._({required this.isValid, this.errorMessage});

  factory ToggleValidation.valid() {
    return ToggleValidation._(isValid: true);
  }
  factory ToggleValidation.invalid(String errorMessage) {
    return ToggleValidation._(isValid: false, errorMessage: errorMessage);
  }
}

class ComponentInteractionHandler {
  final String componentType;
  final List<GestureType> supportedGestures;
  final Map<String, dynamic> handlerConfig;

  ComponentInteractionHandler({
    required this.componentType,
    required this.supportedGestures,
    required this.handlerConfig,
  });
}

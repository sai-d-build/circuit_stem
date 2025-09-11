// DATASHEET: DRAG SERVICE - CENTRALIZED COMPONENT DRAG SYSTEM
//
// OVERVIEW:
// --------
// The DragService provides a unified drag-and-drop architecture for CircuitSTEM, consolidating
// previously scattered drag logic from 5+ files into a single, maintainable service. It handles
// palette component selection, canvas drop validation, component movement, and visual feedback.
//
// API SUMMARY:
// ------------
// DragService().startPaletteDrag(data, pos)      // Start palette component drag
// DragService().updateDragPosition(pos)          // Update drag position
// DragService().dropComponent(data, pos)         // Process drop at position
// DragService().cancelDrag()                     // Cancel current drag
// DragService().setDropValidator(callback)       // Set validation function
// DragService().setCallbacks({})                 // Set event callbacks
//
// CORE COMPONENTS:
// ---------------
// - DragController: Internal state manager
// - DragState: Immutable drag state representation
// - DragEvent: Event objects for lifecycle hooks
// - ValidationCallback: Pluggable drop validation
// - ComponentDragData: Standardized drag data format
//
// USAGE PATTERNS:
// --------------
// 1. Palette drag: startPaletteDrag → position updates → drop processing
// 2. Component move: startComponentMove → drag updates → successful drop
// 3. Custom validation: setDropValidator(lambda) → automatic enforcement
// 4. Event handling: setCallbacks({onStarted, onUpdated, onEnded})
//
// INTEGRATION POINTS:
// -----------------
// - HorizontalComponentPalette: Uses Draggable with service callbacks
// - GameCanvas: DragTarget delegates to service for validation/coordination
// - CircuitComponentWidget: StateNotifier delegates drag operations
// - EnhancedGameStateNotifier: Updates app state via service results
//
// STATE MANAGEMENT:
// ----------------
// DragState includes: isDragging, draggedComponentId, positions, dragType, validation status
// All state changes trigger appropriate event callbacks for UI updates
//
// VALIDATION FRAMEWORK:
// --------------------
// Pluggable validation functions return DropValidationResult with success/failure status,
// optional error messages, and suggested drop positions for snap-to-grid behavior.
//
// BENEFITS:
// --------
// - Eliminates code duplication across palette, canvas, and component layers
// - Provides consistent drag behavior across all interactions
// - Enables easy testing, debugging, and future enhancements
// - Maintains backward compatibility with existing widget APIs
//
// FUTURE EXTENSIONS:
// -----------------
// - Multi-touch gesture support
// - Magnetic grid snapping
// - Undo/redo integration
// - Performance monitoring
// - Accessibility features
//
// DEPENDENCIES:
// ------------
// - flutter/material.dart: UI framework integration
// - domain/entities/entities.dart: Component type definitions
// - presentation/models/drag_models.dart: Drag data structures
///

import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

/// Current state of a drag operation
class DragState {
  final bool isDragging;
  final String? draggedComponentId;
  final Offset? dragStartPosition;
  final Offset? dragCurrentPosition;
  final ComponentDragData? dragData;
  final DragType dragType;
  final bool isValidDrop;

  const DragState({
    this.isDragging = false,
    this.draggedComponentId,
    this.dragStartPosition,
    this.dragCurrentPosition,
    this.dragData,
    this.dragType = DragType.component,
    this.isValidDrop = true,
  });

  DragState copyWith({
    bool? isDragging,
    String? draggedComponentId,
    Offset? dragStartPosition,
    Offset? dragCurrentPosition,
    ComponentDragData? dragData,
    DragType? dragType,
    bool? isValidDrop,
  }) {
    return DragState(
      isDragging: isDragging ?? this.isDragging,
      draggedComponentId: draggedComponentId ?? this.draggedComponentId,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
      dragCurrentPosition: dragCurrentPosition ?? this.dragCurrentPosition,
      dragData: dragData ?? this.dragData,
      dragType: dragType ?? this.dragType,
      isValidDrop: isValidDrop ?? this.isValidDrop,
    );
  }

  // Convenience properties
  bool get hasComponent => draggedComponentId != null;
  bool get hasValidPosition => dragCurrentPosition != null;
  Offset? get dragDelta => dragStartPosition != null && dragCurrentPosition != null
      ? dragCurrentPosition! - dragStartPosition! : null;
}

/// Types of drag operations
enum DragType {
  component,  // Drag from palette
  move,       // Move existing component on canvas
  wire,       // Wire drawing operation
}

/// Events that can occur during drag operations
abstract class DragEvent {
  final DateTime timestamp;
  final Offset position;

  const DragEvent(this.timestamp, this.position);
}

class DragStartEvent extends DragEvent {
  final ComponentDragData dragData;
  final DragType dragType;

  const DragStartEvent(super.timestamp, super.position, this.dragData, this.dragType);
}

class DragUpdateEvent extends DragEvent {
  const DragUpdateEvent(super.timestamp, super.position);
}

class DragEndEvent extends DragEvent {
  final bool wasSuccessful;
  final Offset? finalPosition;

  const DragEndEvent(super.timestamp, super.position, this.wasSuccessful, this.finalPosition);
}

class DragCancelEvent extends DragEvent {
  const DragCancelEvent(super.timestamp, super.position);
}

/// Validation result for drop operations
class DropValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Offset? suggestedPosition;

  const DropValidationResult({
    required this.isValid,
    this.errorMessage,
    this.suggestedPosition,
  });
}

/// Callback typedefs for drag operations
typedef DragStartedCallback = void Function(DragStartEvent event);
typedef DragUpdatedCallback = void Function(DragUpdateEvent event);
typedef DragEndedCallback = void Function(DragEndEvent event);
typedef DragCancelledCallback = void Function(DragCancelEvent event);
typedef ValidationCallback = DropValidationResult Function(ComponentDragData dragData, Offset position);

/// Main drag controller that centralizes all drag logic
class DragController {
  DragState _state = const DragState();

  // Callback registrations
  DragStartedCallback? onDragStarted;
  DragUpdatedCallback? onDragUpdated;
  DragEndedCallback? onDragEnded;
  DragCancelledCallback? onDragCancelled;
  ValidationCallback? onValidateDrop;

  /// Get current drag state
  DragState get state => _state;

  /// Check if currently dragging
  bool get isDragging => _state.isDragging;

  /// Start a new drag operation
  void startDrag(ComponentDragData dragData, DragType dragType, Offset startPosition) {
    _state = DragState(
      isDragging: true,
      dragStartPosition: startPosition,
      dragCurrentPosition: startPosition,
      dragData: dragData,
      dragType: dragType,
      draggedComponentId: dragType == DragType.move ? 'temp-component' : null,
    );

    final event = DragStartEvent(DateTime.now(), startPosition, dragData, dragType);
    onDragStarted?.call(event);
  }

  /// Update drag position
  void updateDrag(Offset position) {
    if (!isDragging) return;

    _state = _state.copyWith(dragCurrentPosition: position);

    final event = DragUpdateEvent(DateTime.now(), position);
    onDragUpdated?.call(event);
  }

  /// End drag operation with success
  void endDragSuccessfully(Offset finalPosition) {
    if (!isDragging) return;

    _state = _state.copyWith(isValidDrop: true);
    _clearDragState();

    final event = DragEndEvent(DateTime.now(), finalPosition, true, finalPosition);
    onDragEnded?.call(event);
  }

  /// Cancel drag operation
  void cancelDrag({ Offset? cancelPosition }) {
    if (!isDragging) return;

    final position = cancelPosition ?? _state.dragCurrentPosition ?? _state.dragStartPosition ?? Offset.zero;
    _clearDragState();

    final event = DragCancelEvent(DateTime.now(), position);
    onDragCancelled?.call(event);
  }

  /// Attempt to drop drag operation at specified position
  DropValidationResult validateDrop(ComponentDragData dragData, Offset dropPosition) {
    if (onValidateDrop != null) {
      return onValidateDrop!(dragData, dropPosition);
    }

    // Default validation - always valid
    return const DropValidationResult(isValid: true);
  }

  /// End drag with validation check
  DropValidationResult endDragAtPosition(ComponentDragData dragData, Offset dropPosition) {
    final validation = validateDrop(dragData, dropPosition);

    if (validation.isValid) {
      endDragSuccessfully(validation.suggestedPosition ?? dropPosition);
    } else {
      cancelDrag(cancelPosition: dropPosition);
    }

    return validation;
  }

  // Private helper method
  void _clearDragState() {
    _state = const DragState();
  }
}

/// Singleton service class for drag operations
/// Provides the main entry point for drag functionality throughout the app
class DragService {
  static final DragService _instance = DragService._internal();
  final DragController _controller = DragController();

  DragService._internal();

  factory DragService() => _instance;

  /// Get the drag controller
  DragController get controller => _controller;

  /// Start a palette component drag
  void startPaletteDrag(ComponentDragData dragData, Offset startPosition) {
    controller.startDrag(dragData, DragType.component, startPosition);
  }

  /// Start moving an existing component
  void startComponentMove(String componentId, ComponentDragData dragData, Offset startPosition) {
    controller.startDrag(dragData, DragType.move, startPosition);
    // Override the dragged component ID
    controller._state = controller._state.copyWith(draggedComponentId: componentId);
  }

  /// Update drag position
  void updateDragPosition(Offset position) {
    controller.updateDrag(position);
  }

  /// Drop component at position
  DropValidationResult dropComponent(ComponentDragData dragData, Offset dropPosition) {
    return controller.endDragAtPosition(dragData, dropPosition);
  }

  /// Cancel drag operation
  void cancelDrag({ Offset? position }) {
    controller.cancelDrag(cancelPosition: position);
  }

  /// Register validation callback
  void setDropValidator(ValidationCallback validator) {
    controller.onValidateDrop = validator;
  }

  /// Register drag event callbacks
  void setCallbacks({
    DragStartedCallback? onStarted,
    DragUpdatedCallback? onUpdated,
    DragEndedCallback? onEnded,
    DragCancelledCallback? onCancelled,
  }) {
    controller.onDragStarted = onStarted;
    controller.onDragUpdated = onUpdated;
    controller.onDragEnded = onEnded;
    controller.onDragCancelled = onCancelled;
  }

  /// Get current drag state
  DragState getCurrentState() => controller.state;

  /// Check if currently dragging
  bool get isDragging => controller.isDragging;

  /// Get dragged component info
  ComponentDragData? getCurrentDragData() => controller.state.dragData;

  /// Get drag position info
  Offset? getCurrentDragPosition() => controller.state.dragCurrentPosition;

  /// Disposal - clear all callbacks
  void dispose() {
    _controller.onDragStarted = null;
    _controller.onDragUpdated = null;
    _controller.onDragEnded = null;
    _controller.onDragCancelled = null;
    _controller.onValidateDrop = null;
  }
}

/// Extension methods for working with drag operations
extension DragServiceExtensions on ComponentType {
  /// Convert component type to drag data
  ComponentDragData toDragData() {
    return ComponentDragData(
      componentType: this,
      componentName: name,
      description: _getComponentDescription(this),
      defaultProperties: _getDefaultProperties(this),
      cost: _getComponentCost(this),
      icon: _getComponentIcon(this),
    );
  }

  String _getComponentDescription(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return 'Power source component';
      case ComponentType.resistor:
        return 'Limits current flow';
      case ComponentType.bulb:
        return 'Light-emitting component';
      case ComponentType.wire:
        return 'Connects components together';
      case ComponentType.switch_:
        return 'Controls circuit flow';
      case ComponentType.capacitor:
        return 'Stores electrical charge';
      case ComponentType.inductor:
        return 'Magnetic energy storage';
      case ComponentType.buzzer:
        return 'Audio output component';
      default:
        return 'Circuit component';
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return {'voltage': 9.0};
      case ComponentType.resistor:
        return {'resistance': 1000.0};
      case ComponentType.bulb:
        return {'power': 2.5};
      case ComponentType.capacitor:
        return {'capacitance': 100e-6};
      case ComponentType.inductor:
        return {'inductance': 10e-3};
      default:
        return {};
    }
  }

  int _getComponentCost(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
      case ComponentType.resistor:
      case ComponentType.bulb:
        return 1;
      case ComponentType.wire:
        return 0;
      case ComponentType.switch_:
      case ComponentType.capacitor:
      case ComponentType.inductor:
      case ComponentType.buzzer:
        return 2;
      default:
        return 1;
    }
  }

  IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return Icons.battery_full;
      case ComponentType.resistor:
        return Icons.linear_scale;
      case ComponentType.bulb:
        return Icons.lightbulb;
      case ComponentType.wire:
        return Icons.horizontal_rule;
      case ComponentType.switch_:
        return Icons.power;
      case ComponentType.capacitor:
        return Icons.battery_charging_full;
      case ComponentType.inductor:
        return Icons.settings_ethernet;
      case ComponentType.buzzer:
        return Icons.volume_up;
      default:
        return Icons.electrical_services;
    }
  }
}
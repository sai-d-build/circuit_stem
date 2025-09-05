# Refactoring and Architecture Improvement Plan

## 1. Executive Summary

This document outlines a comprehensive plan to refactor the application's core architecture. The goal is to address the root causes of the current bugs (e.g., duplicate placements, coordinate mismatches) and establish a robust, extensible, and maintainable foundation for future development.

The key pillars of this new architecture are:
*   **Single Source of Truth:** Centralizing all state and logic to prevent inconsistencies.
*   **Immutable State:** Using immutable data models to ensure predictable state changes.
*   **Stateless Services:** Encapsulating logic in stateless services for easy testing and reuse.
*   **Command Pattern:** Managing all state mutations through a command pattern to support undo/redo and ensure idempotency.
*   **Data-Driven Design:** Defining components and levels through data descriptors to improve content pipelines.

## 2. Core Architectural Principles

*   **GridState as the Single Source of Truth:** The `GridNotifier` will hold the `GridState`, which contains the lists of components and wires. All rendering will be derived from this state.
*   **Stateless `GridService`:** All grid-related calculations (coordinate conversion, snapping, validation) will be handled by a stateless `GridService`.
*   **Preview-then-Commit UI:** The UI will use a non-committing preview layer for user interactions like dragging. State mutations will only occur at the end of an action (e.g., on drop), preventing duplicate placements.
*   **Canvas-level Transform:** A single `Matrix4` transform will be applied to the entire canvas for panning and zooming, ensuring all elements move together.

## 3. Proposed Data Models

The following data models will be used to represent the grid and its elements.

```dart
// lib/domain/entities/core/grid_entities.dart

import 'package:flutter/foundation.dart';

class GridConfiguration {
  final int rows;
  final int cols;
  final double cellSize; // Logical pixels
  final double scale;
  final Offset panOffset;

  const GridConfiguration({
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.scale,
    required this.panOffset,
  });
}

@immutable
class GridPosition {
  final int row;
  final int col;
  const GridPosition(this.row, this.col);
}

@immutable
class PinRef {
  final String componentId;
  final String pinName; // e.g., "in", "out", "p1"
  const PinRef({required this.componentId, required this.pinName});
}

@immutable
class Component {
  final String id;
  final String type; // e.g., "resistor", "capacitor"
  final GridPosition position;
  final int rotation; // In degrees (0, 90, 180, 270)
  final Map<String, dynamic> properties; // e.g., {"resistance": 1000}

  const Component({
    required this.id,
    required this.type,
    required this.position,
    this.rotation = 0,
    this.properties = const {},
  });
}

@immutable
class Wire {
  final String id;
  final PinRef from;
  final PinRef to;
  final List<GridPosition> path; // For custom routing

  const Wire({
    required this.id,
    required this.from,
    required this.to,
    this.path = const [],
  });
}
```

## 4. Service Layer Design (`GridService`)

The `GridService` will be a stateless utility class with the following key methods:

```dart
// lib/core/services/grid_service.dart

class GridService {
  static GridPosition screenToGrid(Offset screenPoint, GridConfiguration config) {
    final sceneX = (screenPoint.dx - config.panOffset.dx) / config.scale;
    final sceneY = (screenPoint.dy - config.panOffset.dy) / config.scale;
    return GridPosition((sceneY / config.cellSize).floor(), (sceneX / config.cellSize).floor());
  }

  static Offset gridToScreen(GridPosition gridPos, GridConfiguration config) {
    final x = (gridPos.col * config.cellSize * config.scale) + config.panOffset.dx;
    final y = (gridPos.row * config.cellSize * config.scale) + config.panOffset.dy;
    return Offset(x, y);
  }

  static ValidationResult validatePlacement(Component component, GridState state) {
    // Check bounds, overlap, and other rules
  }
}

class ValidationResult {
  final bool isValid;
  final String? reason;
  const ValidationResult({required this.isValid, this.reason});
}
```

## 5. UI and Interaction Layer

The UI will follow a "preview-then-commit" pattern:

1.  **Drag Start:** When a user drags from the palette, a `DragPayload` with a unique `dropId` is created.
2.  **During Drag:** The UI renders a "ghost" component at the snapped grid position. No changes are made to the `GridState`.
3.  **On Drop:** The `DragTarget`'s `onAccept` callback is the **single commit point**. It validates the placement and dispatches a `PlaceComponentCommand`. The `dropId` is used to prevent duplicate commits.

## 6. Command Pattern Implementation

All state mutations will be handled by commands to ensure undo/redo and idempotency.

```dart
// lib/application/commands/command.dart

abstract class Command {
  final String id; // Unique ID for idempotency
  Command(this.id);
  void execute(GridNotifier notifier);
  void undo(GridNotifier notifier);
}

class PlaceComponentCommand extends Command {
  final Component component;
  PlaceComponentCommand(String id, this.component) : super(id);

  @override
  void execute(GridNotifier notifier) {
    notifier.addComponent(component, id);
  }

  @override
  void undo(GridNotifier notifier) {
    notifier.removeComponent(component.id);
  }
}
```

The `GridNotifier` will maintain a history of commands and a set of processed command IDs to prevent duplicates.

## 7. Prioritized Migration Plan

### Phase 1: Immediate Hotfixes (1-2 days)

The goal of this phase is to stop the current bugs with minimal, safe changes.

1.  **Centralize Component Type Parsing:** Create a single, strict `stringToComponentType` parser that returns `null` for unknown types. Update call sites to handle the `null` case by showing an error to the user.
2.  **Prevent Double Placement:** Add a unique `dropId` to the drag payload and use a `Set<String>` of handled IDs to deduplicate commits in the `onAccept` handler. Gate the `onScaleEnd` logic to prevent it from also committing.
3.  **Use Live `GridConfiguration`:** In `_processComponentDrop`, remove the hardcoded `GridConfiguration` and use the live configuration from the `GameCanvasController`.
4.  **Fix Component Painting:** Pass the `panOffset` to the `ComponentPainter` and apply it when calculating component positions.

### Phase 2: Stabilization and Foundation (1 week)

This phase establishes the foundation for the new architecture.

1.  **Consolidate `GridService`:** Move all coordinate conversion and validation logic into the `GridService`. Refactor all parts of the app to use this service.
2.  **Implement Occupancy Grid:** Add a simple occupancy grid (e.g., a `Set<GridPosition>`) to the `GridState` for faster overlap checks.
3.  **Add Unit Tests:** Write unit tests for `GridService` conversions, the new type parser, and placement validation.

### Phase 3: Core Refactoring (2-4 weeks)

This phase implements the core architectural changes.

1.  **Implement Command Pattern:** Create the `Command` base class, `PlaceComponentCommand`, `MoveComponentCommand`, etc., and a `History` stack in the `GridNotifier`.
2.  **Refactor UI to Use Commands:** Change the UI to dispatch commands instead of directly calling methods on the notifier.
3.  **Refactor Wire Model:** Update the `Wire` data model to be a single entity that references two pins. Implement a simple Manhattan routing algorithm for wire paths.
4.  **Data-Driven Components:** Introduce `ComponentDescriptor`s that are loaded from level files. This decouples the component definitions from the code.

### Phase 4: Advanced Features and Long-Term Improvements (Ongoing)

*   Implement advanced snapping with priorities.
*   Improve the wire routing algorithm (e.g., A*).
*   Enhance performance with canvas optimizations.
*   Add more robust testing, including integration and end-to-end tests.

## 8. Testing and QA Strategy

*   **Unit Tests:**
    *   `GridService` conversions with various pan/zoom values.
    *   `validatePlacement` for all edge cases.
    *   Command `execute` and `undo` methods.
*   **Integration Tests:**
    *   Drag-and-drop with pan/zoom, asserting that only one component is created and correctly positioned.
    *   Wire placement flows.
    *   Undo/redo sequences.
*   **Manual QA:**
    *   Test levels with invalid component types to ensure errors are shown.
    *   Verify that component rendering is correct during and after pan/zoom operations.

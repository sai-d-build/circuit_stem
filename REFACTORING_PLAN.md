# CircuitSTEM: Grid & Interaction System Refactoring Plan

**Version:** 1.1  
**Date:** September 12, 2025  
**Author:** mme  
**Status:** Proposed

## 1. Introduction & Goals

### 1.1. Overview

This document outlines a comprehensive, phased plan to refactor the grid and interaction systems of the CircuitSTEM application. The current implementation suffers from several interconnected issues stemming from inconsistent coordinate systems, fragmented state management, and unclear UI feedback. These issues have led to a poor user experience, including incorrect component placements, visual bugs, and a general feeling of unpredictability.

The four primary issues identified are:
1.  **Misleading UI**: A dual-grid system where the playable area is not visually distinguished.
2.  **Duplicate Rendering**: "Ghost" components appearing after placement due to stale state.
3.  **Hover/Placement Mismatch**: Inconsistent coordinate logic causing placements to not match the user's intent.
4.  **Missing "Nearness" Rule**: A missing feature to prevent components from being placed adjacent to each other.

### 1.2. Goals

The primary goals of this refactoring effort are:
*   **Stability & Correctness**: Eliminate all known bugs related to component placement and rendering.
*   **User Experience**: Create a predictable, intuitive, and frustration-free user experience.
*   **Maintainability**: Establish a clean, unified, and well-documented architecture that is easier to understand, maintain, and extend.
*   **Performance**: Ensure that the new system is as performant as, or more performant than, the current implementation.

## 2. Core Architectural Principles

This refactoring will adhere to the following core principles:

*   **Single Source of Truth**: There must be one, and only one, source of truth for the application's state. This applies to grid coordinates, component state, and UI state.
*   **Clear State Ownership**: The responsibility for managing each piece of state should be clearly defined and assigned to a single owner (e.g., a specific service or state manager).
*   **Immutability**: State should be treated as immutable. All state changes should result in a new state object, not a mutation of the existing state. This is crucial for predictable state management and efficient UI updates.
*   **Comprehensive Testing**: All new components and services must have thorough unit and integration tests. All bug fixes must be accompanied by a regression test.

## 3. Detailed Issue Analysis

This section provides a detailed Root Cause Analysis (RCA) for each of the major issues identified.

### 3.1. Issue: Misleading UI & Dual Grid System

*   **Root Cause Analysis**:
    *   **What is Happening (Symptom):** Users attempt to place components on the grid in a location that appears valid, but the placement is rejected with an "Invalid placement location" error. This happens because the user is interacting with a large visual grid (e.g., 20x20) while the placement validation is being performed against a smaller, invisible logical grid (e.g., 6x8).
    *   **Why It Is Happening (Technical Cause):** The application has two different concepts of a "grid" that are not clearly distinguished in the UI. The rendering logic draws a large grid that fills the available screen space, but the game logic for each level defines a smaller area where components are allowed to be placed. There is no visual feedback to inform the user of the boundaries of this smaller, logical grid.
    *   **File-by-File Analysis:**
        *   **`lib/presentation/features/game/painters/canvas_painter.dart`**: This file is responsible for rendering the visual grid. Its current logic is to simply draw a grid that fills the entire canvas area, without any knowledge of the logical level boundaries.
        *   **`lib/application/services/game_interaction_service.dart`**: This service contains the placement validation logic. It correctly validates the placement against the small, logical `levelBounds`, but it has no way to communicate these boundaries to the UI or the user.
*   **Justification for Proposed Fix**:
    *   The proposed fix is to **visually distinguish the playable area** within the `canvas_painter.dart`. This is the most direct and lowest-risk solution to the problem. It directly addresses the root cause by making the invisible logical boundary visible to the user.
    *   An alternative would be to make the visual grid the same size as the logical grid. However, the user has indicated that the large grid is a requirement. Therefore, making the boundary visible is the best solution that satisfies all constraints.

### 3.2. Issue: Duplicate Rendering ("Ghost" Components)

*   **Root Cause Analysis**:
    *   **What is Happening (Symptom):** After a component is placed on the grid, a non-interactive "ghost" image of the component remains on the screen at the location where the drag gesture ended.
    *   **Why It Is Happening (Technical Cause):** This is a classic state management bug. The application is rendering components from two different state sources simultaneously. The `interaction_state.dart` likely holds a temporary state for the component being dragged. When the component is placed, it is added to the main `grid_state.dart`, but the temporary state in `interaction_state.dart` is not being cleared. The rendering engine is listening to both state providers and therefore draws the component twice.
    *   **File-by-File Analysis:**
        *   **`lib/presentation/features/game/controllers/canvas_interaction_controller.dart`**: This controller is the orchestrator of the drag-and-drop operation. Its `_handleDrop` (or similar) method is responsible for updating the state, but it is currently failing to clear the temporary drag state after the placement is complete.
        *   **`lib/application/states/interaction_state.dart`**: This state object holds the information about the component being dragged. It is not being correctly reset to an initial state after the drag operation is complete.
        *   **`lib/presentation/features/game/widgets/canvas_interaction_widget.dart`**: This widget is likely listening to both the grid state and the interaction state, and passing both sets of data to the rendering engine, causing the double render.
*   **Justification for Proposed Fix**:
    *   The proposed fix is to **implement an atomic state operation** that both adds the component to the grid state and clears the temporary interaction state. This directly addresses the root cause by ensuring that the stale state is never allowed to persist across render frames.
    *   This is superior to other potential fixes (like adding a boolean flag to the interaction state) because it is a cleaner, more robust solution that follows best practices for state management.

### 3.3. Issue: Hover and Placement Mismatch

*   **Root Cause Analysis**:
    *   **What is Happening (Symptom):** The user sees a hover highlight on one grid cell, but when they release the mouse to place the component, it snaps to a different, unexpected cell.
    *   **Why It Is Happening (Technical Cause):** There are multiple, inconsistent implementations of the screen-to-grid coordinate conversion logic scattered throughout the codebase. The logic used to calculate the hover position in `_handleDragUpdate` is different from the logic used to calculate the final placement position in `_handleDrop`. This could be due to different rounding methods, or using different anchor points for the calculation (e.g., top-left of the component vs. center).
    *   **File-by-File Analysis:**
        *   **`lib/presentation/features/game/controllers/canvas_interaction_controller.dart`**: This file is the primary location of the bug. It contains at least two different implementations of the coordinate conversion logic.
        *   **`lib/presentation/helpers/central_interaction_helper.dart`**: The absence of a centralized helper for this logic is a key part of the problem. The lack of a single source of truth has allowed the inconsistent logic to proliferate.
*   **Justification for Proposed Fix**:
    *   The proposed fix is to **refactor the code to use a single, unified coordinate conversion function**. This is the only way to guarantee that the hover and placement logic will always be in sync.
    *   Creating a `UnifiedCoordinateService` provides a clean, testable, and maintainable solution. It follows the "Don't Repeat Yourself" (DRY) principle and will make the code easier to reason about and debug in the future.

### 3.4. Issue: Missing "Nearness" Placement Rule

*   **Root Cause Analysis**:
    *   **What is Happening (Symptom):** Users can place components directly adjacent to each other, which may not be the desired behavior for creating clean, readable circuits.
    *   **Why It Is Happening (Technical Cause):** This is not a bug, but a missing feature. The current placement validation logic is too simple. It only checks if the target cell itself is occupied and does not have any concept of a "buffer" or "keep-out" zone around components.
    *   **File-by-File Analysis:**
        *   **`lib/application/services/game_interaction_service.dart`**: The validation logic in this service is where the new rule needs to be added. It currently lacks the logic to check for neighbors.
        *   **`lib/presentation/features/game/painters/canvas_painter.dart`**: The painter currently has no logic to provide visual feedback for this rule, as the rule itself does not exist.
*   **Justification for Proposed Fix**:
    *   The proposed fix is to **add the adjacency validation logic** to the `PlacementValidator` and **provide corresponding visual feedback** in the `GridPainter`.
    *   This is a straightforward, additive change that directly implements the requested feature. Making the "nearness" distance configurable adds a desirable level of flexibility to the game design.

## 4. Phase 0: Preparation & Safety Net (Estimated Time: 1 Week)

### 4.1. Objective

To build a comprehensive safety net *before* making any significant changes to the codebase. This phase is critical for de-risking the entire refactoring process.

### 4.2. Tasks

#### 4.2.1. Create a Test Suite for Coordinate Calculations

*   **Implementation Details**: Before we replace the existing coordinate calculation logic, we must understand its behavior. We will create a suite of unit tests that document the current input and output of the existing conversion functions. These tests will likely fail after the refactoring, which is expected, but they will serve as a clear record of the change in behavior.

    ```dart
    // test/coordinate_legacy_test.dart
    import 'package:test/test.dart';
    import 'package:your_app/legacy_coordinate_logic.dart';

    void main() {
      group('Legacy Coordinate Conversion', () {
        test('should convert screen position to grid position (scenario 1)', () {
          final screenPos = Offset(123.4, 567.8);
          final gridPos = legacyScreenToGrid(screenPos);
          // Assert the known, current (and possibly incorrect) output
          expect(gridPos, equals(GridPosition(row: 9, col: 2)));
        });

        // Add more tests for edge cases, different screen sizes, etc.
      });
    }
    ```

*   **Checklist**:
    *   [ ] Identify all existing coordinate conversion functions.
    *   [ ] Create a new test file `test/coordinate_legacy_test.dart`.
    *   [ ] Write at least 10 unit tests covering a range of inputs and edge cases.
    *   [ ] Achieve >90% test coverage for the legacy coordinate logic.

#### 4.2.2. Implement Feature Flag Infrastructure

*   **Implementation Details**: We will implement a simple, file-based feature flag system. This will allow us to enable and disable new features and refactoring changes in real-time without requiring a new deployment.

    ```dart
    // lib/core/services/feature_flag_service.dart
    class FeatureFlags {
      static const bool useUnifiedCoordinateService = false;
      static const bool enableNearnessRule = false;
      // ... more flags
    }
    ```

*   **Checklist**:
    *   [ ] Create a `feature_flag_service.dart` file.
    *   [ ] Define flags for all major new components and changes.
    *   [ ] Ensure the app can be built and run with all flags in both the `true` and `false` states.

#### 4.2.3. Establish Performance Benchmarks

*   **Implementation Details**: We will use Flutter's built-in performance profiling tools to establish a baseline for the current implementation. We will record the average frame rate (FPS) and the time taken for key operations.

    *   **Operations to Benchmark**:
        1.  Dragging a component across the entire screen.
        2.  Placing a component on a valid cell.
        3.  Attempting to place a component on an invalid cell.

*   **Checklist**:
    *   [ ] Document the exact steps to reproduce each benchmark scenario.
    *   [ ] Record the average and 99th percentile frame times for each scenario.
    *   [ ] Save the performance profiles for future comparison.

#### 4.2.4. Document Current Behavior Baseline

*   **Implementation Details**: We will create a short screen recording of the application that clearly demonstrates the current bugs: the hover/placement mismatch and the "ghost" component rendering. This will serve as a clear "before" state.
*   **Checklist**:
    *   [ ] Record a high-quality video of the current bugs.
    *   [ ] Store the video in the project's `docs` folder.

## 5. Phase 1: Foundational Services & Validation (Estimated Time: 1 Week)

### 5.1. Objective

To build the core, unified services for coordinate conversion and placement validation, and to test them silently in a production environment.

### 5.2. Tasks

#### 5.2.1. Implement `UnifiedCoordinateService`

*   **Implementation Details**: We will create a new service that will be the single source of truth for all coordinate conversions.

    ```dart
    // lib/application/services/unified_coordinate_service.dart
    import 'package:flutter/material.dart';
    import 'package:your_app/models.dart';

    class UnifiedCoordinateService {
      /// Converts a screen position (e.g., from a tap or drag) to a grid position.
      GridPosition screenToGrid(Offset screenPosition, ViewportConfig viewport) {
        // Implementation with correct rounding and anchor point logic
      }

      /// Converts a grid position to the screen position of the top-left corner of the cell.
      Offset gridToScreen(GridPosition gridPosition, ViewportConfig viewport) {
        // Implementation
      }

      /// Checks if a grid position is within the playable level bounds.
      bool isWithinLevelBounds(GridPosition position, GridDimensions bounds) {
        return position.row >= 0 &&
               position.row < bounds.rows &&
               position.col >= 0 &&
               position.col < bounds.cols;
      }

      /// Gets the list of adjacent grid positions.
      List<GridPosition> getAdjacentPositions(GridPosition position) {
        // Implementation
      }
    }
    ```

*   **Complexities & Risks**: The math for the coordinate conversions must be perfect. Any error here will affect all interactions. The logic must correctly handle the grid's cell size, pan offset, and zoom level.
*   **Checklist**:
    *   [ ] Create the `unified_coordinate_service.dart` file.
    *   [ ] Implement all methods.
    *   [ ] Write a comprehensive suite of unit tests for the service, with >95% coverage.

#### 5.2.2. Create Validation Middleware

*   **Implementation Details**: We will create a "shadow" validation system that runs the new coordinate service in parallel with the old logic and logs any discrepancies. This will be enabled via a feature flag.

    ```dart
    // In lib/presentation/features/game/controllers/canvas_interaction_controller.dart
    void _handleDragUpdate(DragUpdateDetails details) {
      final oldGridPos = _legacyScreenToGrid(details.localPosition);
      
      if (FeatureFlags.useUnifiedCoordinateService) {
        final newGridPos = _unifiedCoordinateService.screenToGrid(details.localPosition, _viewport);
        
        if (newGridPos != oldGridPos) {
          _logger.warning('Coordinate mismatch detected', context: {
            'oldPos': oldGridPos,
            'newPos': newGridPos,
            'screenPos': details.localPosition,
          });
        }
        _hoverState.update(newGridPos);
      } else {
        _hoverState.update(oldGridPos);
      }
    }
    ```

*   **Complexities & Risks**: This adds a small amount of overhead to the interaction handling. This risk is low and can be mitigated by only enabling the feature flag in development or for a small subset of users.
*   **Checklist**:
    *   [ ] Implement the diffing logic in the `canvas_interaction_controller.dart`.
    *   [ ] Add a new logger for coordinate mismatches.
    *   [ ] Test the middleware to ensure it correctly logs discrepancies.

### 5.3. Synchronization Point

*   **Review**: Review the logs from the validation middleware. Do not proceed to Phase 2 until there are zero coordinate mismatches reported over a 24-hour testing period.
*   **Code Review**: Conduct a thorough code review of the new `UnifiedCoordinateService`.

## 6. Phase 2: Critical Bug Fixes & UI Stabilization (Estimated Time: 1 Week)

### 6.1. Objective

To fix the most critical user-facing bugs and deliver a noticeably improved and stable user experience.

### 6.2. Tasks

#### 6.2.1. Activate `UnifiedCoordinateService`

*   **Implementation Details**: We will now remove the old coordinate logic and the validation middleware, and make the `UnifiedCoordinateService` the single source of truth.

    ```dart
    // Before, in canvas_interaction_controller.dart
    void _handleDrop(ComponentType type, Offset position) {
      final gridPos = _legacyScreenToGrid(position);
      _placementService.placeComponent(gridPos, type);
    }

    // After, in canvas_interaction_controller.dart
    void _handleDrop(ComponentType type, Offset position) {
      final gridPos = _unifiedCoordinateService.screenToGrid(position, _viewport);
      _placementService.placeComponent(gridPos, type);
    }
    ```

*   **Complexities & Risks**: The main risk is that some obscure part of the codebase that also does coordinate conversion was missed during the refactoring.
*   **Checklist**:
    *   [ ] Remove the legacy coordinate conversion logic.
    *   [ ] Remove the validation middleware.
    *   [ ] Update all callsites to use the `UnifiedCoordinateService`.
    *   [ ] Manually test all canvas interactions to confirm the **Hover/Placement Mismatch** is fixed.

#### 6.2.2. Fix "Ghost" Components

*   **Implementation Details**: We will implement an atomic state operation to clear the stale drag state.

    ```dart
    // In lib/presentation/features/game/controllers/canvas_interaction_controller.dart
    void _handleSuccessfulPlacement(GridPosition pos, ComponentType type) {
      // This should be an atomic transaction
      ref.read(gridStateProvider.notifier).addComponent(pos, type);
      ref.read(interactionStateProvider.notifier).clearDragState(); 
    }
    ```

*   **Complexities & Risks**: The risk is a race condition. We must ensure that the `clearDragState` action is dispatched and processed in the same frame as the `addComponent` action, or immediately after.
*   **Checklist**:
    *   [ ] Implement the `clearDragState` action.
    *   [ ] Call this action immediately after a successful placement.
    *   [ ] Manually test to confirm that the **"Ghost" Components** no longer appear.

#### 6.2.3. Improve Grid UI

*   **Implementation Details**: We will update the `GridPainter` to visually distinguish the playable area.

    ```dart
    // In lib/presentation/features/game/painters/canvas_painter.dart
    void paint(Canvas canvas, Size size) {
      // ... existing grid painting logic ...

      final bounds = ref.read(gameStateProvider).level.bounds;
      final rect = Rect.fromLTWH(
        bounds.left * cellSize,
        bounds.top * cellSize,
        bounds.width * cellSize,
        bounds.height * cellSize,
      );

      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, paint);
    }
    ```

*   **Complexities & Risks**: Low risk. This is a visual-only change.
*   **Checklist**:
    *   [ ] Update the `GridPainter`.
    *   [ ] Manually verify that the playable area is clearly visible on all levels.

### 6.3. Synchronization Point

*   **UI/UX Review**: Conduct a full review of the application with the design and product teams to confirm that the critical bugs are resolved and the UI is behaving as expected.
*   **Soak Testing**: Deploy the changes to a staging environment and run 24-hour soak tests to monitor for any new regressions or performance issues.

## 7. Phase 3: Architectural Polish & Feature Implementation (Estimated Time: 1 Week)

### 7.1. Objective

With a stable application, we will complete the architectural refactoring and implement the new "nearness" placement rule.

### 7.2. Tasks

#### 7.2.1. Implement `GridStateManager`

*   **Implementation Details**: This is a larger refactoring task to centralize state management logic that is currently spread across multiple controllers and widgets.

    ```dart
    // lib/application/grid_state_manager.dart
    class GridStateManager extends StateNotifier<GridState> {
      GridStateManager(this.ref) : super(GridState.initial());

      final Ref ref;

      void beginDrag(ComponentType type) {
        // Logic to update the state to reflect that a drag has started
      }

      void endDrag(bool success) {
        // Logic to clear the drag state
      }
      
      // ... other methods
    }
    ```

*   **Complexities & Risks**: High complexity. This refactoring will touch many parts of the application. The risk is that some state transition logic might be missed or incorrectly migrated.
*   **Checklist**:
    *   [ ] Implement the `GridStateManager`.
    *   [ ] Refactor the UI to get all grid-related state from this new manager.
    *   [ ] Write comprehensive unit and integration tests for the `GridStateManager`.

#### 7.2.2. Implement "Nearness" Rule

*   **Implementation Details**: We will add the adjacency validation logic and the corresponding UI feedback.

    ```dart
    // In lib/application/services/placement_validator.dart
    ValidationResult validatePlacement(GridPosition pos, ComponentType type) {
      if (isNearOtherComponents(pos)) {
        return ValidationResult.failure('Too close to another component');
      }
      // ... other validation
    }

    // In lib/presentation/features/game/painters/canvas_painter.dart
    void paintHoverHighlight(Canvas canvas, GridPosition pos) {
      // ...
      if (_placementValidator.isNearOtherComponents(pos)) {
        // paint a red highlight
      } else {
        // paint a green highlight
      }
    }
    ```

*   **Complexities & Risks**: Low risk. This is an additive feature. The "nearness" distance should be made configurable.
*   **Checklist**:
    *   [ ] Update the `PlacementValidator`.
    *   [ ] Update the `GridPainter`.
    *   [ ] Manually test that the nearness rule is correctly enforced and visualized.

## 8. Cross-Phase Requirements

### 8.1. Rollback Plan

*   All major changes will be gated by feature flags. If a critical issue is discovered in production, we can immediately disable the problematic feature without requiring a rollback of the entire application.

### 8.2. Testing Strategy

*   **Unit Tests**: For all services and state managers.
*   **Integration Tests**: For the interaction between services (e.g., `CanvasInteractionController` and `GridStateManager`).
*   **UI Tests**: For visual feedback and user flows.
*   **Performance Tests**: To compare the new implementation against the baseline benchmarks.

This detailed plan provides a clear path to a more stable, maintainable, and user-friendly application.
# Project Refactoring Status & Action Plan

**Last Updated:** 2025-08-22

## 1. Current Status

The project is currently in a critical state due to ongoing architectural refactoring. While significant progress has been made in modernizing the game engine and state management, the integration is incomplete. The application is **not stable** and suffers from several critical compilation errors that prevent it from running correctly.

The immediate priority is to **stabilize the application** by fixing these blockers before proceeding with further architectural modernization.

---

## 2. Analysis of Architectural Changes

Two significant refactorings are in progress:

### 2.1. Async State Management (The Riverpod Refactor)

*   **Problem:** The UI was building before asynchronous level loading was complete, causing race conditions, blank screens, and unpredictable behavior.
*   **Long-Term Solution (`Fix_analysis.md`):** A complete migration to Riverpod's modern `AsyncNotifierProvider` with code generation. This is the ideal end-state, providing robust handling of `loading`/`error`/`data` states.
*   **Current State:** A "Phase 1" fix using `FutureProvider` was implemented to get the app to a stable state more quickly. This work has resolved the initial navigation bug (see `handover.md` for details).

### 2.2. Component-Behavior Model (The Engine Refactor)

*   **Description:** This is a fundamental shift in the game's architecture, moving from centralized logic to a more flexible and extensible model inspired by Entity-Component-System (ECS).
*   **Core Concepts:**
    *   **Components** are now simple data containers.
    *   **Behaviors** (`DrawingBehavior`, `LogicBehavior`, `InteractionBehavior`) are attached to components to define how they look, act, and interact.
    *   **Registries** (`ComponentRegistry`, `GoalRegistry`) map string IDs from level `.json` files to a set of behaviors at runtime.
*   **Benefit:** This new architecture makes adding new components (e.g., a "Diode") a self-contained task that does not require modifying the core game engine, which is a massive improvement for maintainability.
*   **Status:** The core implementation is in place, but it has introduced a new set of compilation errors in areas that consume component data, such as the UI and tests.

---

## 3. Current Blockers & Known Issues

These issues must be addressed to stabilize the application.

1.  **CRITICAL: Compilation Errors due to Game Engine Refactoring:**
    *   **Symptom:** The application and test suite fail to compile with numerous errors.
    *   **Diagnosis:** These errors are a direct result of the `GameEngineNotifier` to `GameEngineNotifierV2` refactoring and the introduction of new modular components (`GameEngineCore`, `SimulationManager`, `InputManager`, `AudioManager`). Existing code (and some new code) is attempting to use old APIs or has not been fully updated to the new structure.
    *   **Details:** (Refer to `BUGS_TRACKING.md` for detailed bug reports: `BUG-004` to `BUG-008`).
    *   **Impact:** Blocks application execution and test suite validation.

2.  **Build Environment Issue (macOS):**
    *   **Symptom:** The macOS build is blocked due to a missing `xcodebuild` utility.
    *   **Fix:** The developer needs to run `xcode-select --install` in their terminal.

3.  **Dependency Debt:**
    *   **Symptom:** Several packages have newer, incompatible versions available.
    *   **Fix:** `flutter pub outdated` needs to be run and `pubspec.yaml` updated. This should be done after the critical compilation errors are fixed.

---

## 4. Phased Action Plan

This plan prioritizes stability first, then modernization.

### Phase 1: Stabilize the Application

*   **Objective:** Get the application into a runnable, testable, and stable state by resolving all compilation errors.

1.  **Resolve All Compilation Errors:**
    *   **Action:** Systematically address all errors reported by `flutter analyze` and `flutter test`. This includes fixing API mismatches, constructor arguments, missing files, and type issues.
    *   **Expected Outcome:** The application compiles and runs without errors. The test suite compiles, even if some tests fail at runtime. (Refer to `BUGS_TRACKING.md` for specific bugs to address).

2.  **Verify Core UI and Game Logic:**
    *   **Action:** Once the app runs, manually test the core gameplay loop for Level 1.
    *   **Expected Outcome:** The level loads, the grid and palette render correctly, and components can be dragged and placed on the grid.

### Phase 2: Modernize the Architecture

*   **Objective:** Complete the migration to the `AsyncNotifierProvider` architecture as envisioned in `Fix_analysis.md`.

1.  **Implement `AsyncNotifierProvider`:**
    *   **Action:** Add the necessary dependencies (`riverpod_generator`, etc.). Replace the `FutureProvider` and `StateNotifierProvider` with the new `GameEngine` `AsyncNotifierProvider`.
    *   **Expected Outcome:** State management and data loading are unified into a single, modern provider.

2.  **Update UI and Derived Providers:**
    *   **Action:** Refactor the UI to watch the new `AsyncNotifierProvider`. Implement the efficient derived state providers (e.g., `gameGridProvider`, `renderStateProvider`).
    *   **Expected Outcome:** The UI is simpler, more performant, and correctly handles all loading, error, and data states.

3.  **Update and Pass All Tests:**
    *   **Action:** Update the entire test suite to align with the new architecture and ensure all tests are passing.
    *   **Expected Outcome:** A fully tested, stable, and modern codebase.

4.  **Update Documentation:**
    *   **Action:** Update `ARCHITECTURE_ANALYSIS.md` and other relevant documents to reflect the new architecture.
    *   **Expected Outcome:** The project's documentation is consistent with its implementation.

---

## 5. Key Files for Reference

*   `REFACTORING_STATUS.md`: This document.
*   `Fix_analysis.md`: The detailed plan for the target Riverpod architecture.
*   `handover.md`: The historical context and debugging narrative from the previous developer.
*   `lib/core/component_registry.dart`: The heart of the new Component-Behavior system.
*   `lib/behaviors/`: The directory containing the abstract `Behavior` interfaces.
*   `lib/components/`: The directory containing concrete `Behavior` implementations.
*   `lib/core/providers.dart`: The current, partially-refactored Riverpod providers.
*   `BUGS_TRACKING.md`: Detailed log of current and resolved bugs.

---

## Legacy Refactoring Status and Plan (Historical Reference)

This section contains the previous status and action plan for the project's refactoring. This information is retained for historical context but is no longer relevant to the current implementation.

### Old Current Blockers & Known Issues

1.  **CRITICAL: Infinite Loop / Navigation Bug:**
    *   **Symptom:** The app enters an infinite loop trying to load a locked level.
    *   **Diagnosis:** A faulty, argument-less navigation call to the game screen was being made from an unknown location. A fallback in the router was hiding the error.
    *   **Last Action:** The router fallback was removed to force a crash that would pinpoint the source of the bug.

2.  **CRITICAL: Test Suite Compilation Failure:**
    *   **Symptom:** Tests fail to compile with the error: `Error: Type 'Component' not found` in `test/helpers/level_01_test_helper.dart`.
    *   **Diagnosis:** This was likely an import issue or a dependency resolution problem within the test environment caused by the refactoring.

### Old Phased Action Plan

### Phase 1: Stabilize the Application

*   **Objective:** Get the application into a runnable, testable, and stable state.

1.  **Find and Fix the Navigation Bug:**
    *   **Action:** Run the app and analyze the logs/crash report to identify the source of the faulty navigation call.
    *   **Expected Outcome:** A clear error message pointing to the exact line of code making the incorrect `context.go('/game')` call.

2.  **Verify Core UI and Game Logic:**
    *   **Action:** Once the app runs, manually test the core gameplay loop for Level 1.
    *   **Expected Outcome:** The level loads, the grid and palette render correctly, and components can be dragged and placed on the grid.

3.  **Repair the Test Suite:**
    *   **Action:** Fix the `Type 'Component' not found` compilation error in the test helpers.
    *   **Expected Outcome:** The test suite compiles and runs, even if some tests fail.

This legacy status and plan have been superseded by the current action plan and the new set of compilation issues.
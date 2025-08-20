# Project Refactoring Status & Action Plan

**Last Updated:** 2025-08-20

## 1. Current Status

The project is currently in a high-risk, mid-refactoring state. Two major, intertwined architectural upgrades were happening in parallel. The primary goal of this work was to modernize the state management system and make the game engine more extensible.

While the foundational code for these changes has been merged, the integration is incomplete. The application is **not stable** and suffers from several critical bugs that prevent it from running correctly.

The immediate priority is to **stabilize the application** by fixing these blockers before proceeding with further architectural modernization.

---

## 2. Analysis of Architectural Changes

Two significant refactorings are in progress:

### 2.1. Async State Management (The Riverpod Refactor)

*   **Problem:** The UI was building before asynchronous level loading was complete, causing race conditions, blank screens, and unpredictable behavior.
*   **Long-Term Solution (`Fix_analysis.md`):** A complete migration to Riverpod's modern `AsyncNotifierProvider` with code generation. This is the ideal end-state, providing robust handling of `loading`/`error`/`data` states.
*   **In-Progress State (`handover.md`):** A "Phase 1" fix was partially implemented using `FutureProvider` to get the app to a stable state more quickly. This work is not fully tested and was blocked by a navigation bug.

### 2.2. Component-Behavior Model (The Engine Refactor)

*   **Description:** This is a fundamental shift in the game's architecture, moving from centralized logic to a more flexible and extensible model inspired by Entity-Component-System (ECS).
*   **Core Concepts:**
    *   **Components** are now simple data containers.
    *   **Behaviors** (`DrawingBehavior`, `LogicBehavior`, `InteractionBehavior`) are attached to components to define how they look, act, and interact.
    *   **Registries** (`ComponentRegistry`, `GoalRegistry`) map string IDs from level `.json` files to a set of behaviors at runtime.
*   **Benefit:** This new architecture makes adding new components (e.g., a "Diode") a self-contained task that does not require modifying the core game engine, which is a massive improvement for maintainability.
*   **Status:** The core implementation is in place, but it has caused a cascade of changes and likely introduced bugs in areas that consume component data, such as the UI and tests.

---

## 3. Current Blockers & Known Issues

These issues must be addressed to stabilize the application.

1.  **CRITICAL: Infinite Loop / Navigation Bug:**
    *   **Symptom:** The app enters an infinite loop trying to load a locked level.
    *   **Diagnosis:** A faulty, argument-less navigation call to the game screen is being made from an unknown location. A fallback in the router was hiding the error.
    *   **Last Action:** The router fallback was removed to force a crash that will pinpoint the source of the bug. **This is the next diagnostic step.**

2.  **CRITICAL: Test Suite Compilation Failure:**
    *   **Symptom:** Tests fail to compile with the error: `Error: Type 'Component' not found` in `test/helpers/level_01_test_helper.dart`.
    *   **Diagnosis:** This is likely an import issue or a dependency resolution problem within the test environment caused by the refactoring. A working test suite is essential for safe refactoring.

3.  **Build Environment Issue (macOS):**
    *   **Symptom:** The macOS build is blocked due to a missing `xcodebuild` utility.
    *   **Fix:** The developer needs to run `xcode-select --install` in their terminal.

4.  **Dependency Debt:**
    *   **Symptom:** 26 packages have newer, incompatible versions available.
    *   **Fix:** `flutter pub outdated` needs to be run and `pubspec.yaml` updated. This should be done after the critical bugs are fixed.

---

## 4. Phased Action Plan

This plan prioritizes stability first, then modernization.

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
    *   **Expected Outcome:** The test suite compiles and runs, even if some tests fail. This provides the safety net needed for further changes.

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

# Bugs and Tasks Tracking

This document tracks the status of known bugs and planned tasks for the Circuit STEM project.

---

## Master Tracking Table

| ID      | Status   | Module/Feature                               | Description                                                                 | Date Reported | Date Resolved | Priority |
| :------ | :------- | :------------------------------------------- | :-------------------------------------------------------------------------- | :------------ | :------------ | :------- |
| `BUG-001` | Resolved | Build & Compilation                          | `flutter test` command fails due to compilation errors in `GameEngineNotifier`. | 2025-08-21    | 2025-08-21    | High     |
| `BUG-002` | Resolved | State Management (`GameEngineNotifier`)      | Component state is not updated correctly after user interactions (tap, drag). | 2025-08-21    | 2025-08-21    | High     |
| `BUG-003` | Resolved | Component Behaviors (`SwitchInteractionBehavior`) | Behaviors creating their own services bypasses test mocks, causing failures.  | 2025-08-21    | 2025-08-21    | Medium   |
| `BUG-004` | Open     | Core Models, Simulation Engine               | Missing `lib/models/port.dart` file.                                        | 2025-08-22    |               | High     |
| `BUG-005` | Open     | Behaviors, UI                                | `GridWidgetState` type not found.                                           | 2025-08-22    |               | High     |
| `BUG-006` | Open     | Game Engine, Test Setup                      | `GameEngineNotifierV2` Constructor and API Mismatches.                      | 2025-08-22    |               | High     |
| `BUG-007` | Open     | Various (Audio, Grid, Components, UI)        | Undefined Methods/Getters Across Refactored Components.                     | 2025-08-22    |               | High     |
| `BUG-008` | Open     | Game Engine                                  | Invalid `this` Reference in `GameEngineNotifierV2` Initializer.             | 2025-08-22    |               | High     |
| `BUG-009` | Open     | Code Quality, Riverpod Usage                 | Unused Code and Improper State Access Warnings.                             | 2025-08-22    |               | Low      |

---

## Detailed Issue Logs

### ID: `BUG-001`
*   **Date:** 2025-08-21
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-21
*   **Detailed Information:** The test suite was failing to execute entirely. Running `flutter test` resulted in an immediate Dart compiler crash.
*   **Dependencies:** None. This was a blocking issue for all other testing.
*   **Issue:** The application code would not compile.
*   **Root Causes:** An incomplete refactoring in the `GameEngineNotifier` class left five calls to a method named `_evaluateGrid` that no longer existed.
*   **Fix:** Replaced all five calls to the non-existent method with the correct replacement method, `_updateStateWithNewGrid(state.grid)`. This allowed the application to compile and tests to run.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`

---

### ID: `BUG-002`
*   **Date:** 2025-08-21
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-21
*   **Detailed Information:** After fixing the compilation (`BUG-001`), runtime tests began to fail. Specifically, `TC-L1-01` (toggling a switch) and `TC-L1-02` (dragging a component) both fail because the component's state in the `GameEngineNotifier` is not correctly updated and persisted after the interaction.
*   **Dependencies:** Depends on the fix for `BUG-001` to be observable.
*   **Issue:** State updates are being lost or overwritten during user actions.
*   **Root Causes:** The `GameEngineNotifier` had a flawed state management pipeline. Methods like `updateComponent` and `endDrag` modified the application state in multiple, conflicting steps within a single user action. This created race conditions where the final, correct state is overwritten by an intermediate or outdated state from a secondary evaluation.
*   **Fix:** The `GameEngineNotifier` was refactored to use a "single commit pipeline" architecture. All state updates now go through a single, centralized `_commitGrid` method, which ensures that state changes are atomic and predictable. Additionally, the `ComponentRegistry` was fixed to correctly attach behaviors to components created from JSON.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`, `lib/core/component_registry.dart`, `test/level_01_revised_test.dart`

---

### ID: `BUG-003`
*   **Date:** 2025-08-21
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-21
*   **Detailed Information:** During the investigation of `BUG-002`, a separate architectural flaw was discovered in the `SwitchInteractionBehavior`.
*   **Dependencies:** None.
*   **Issue:** The behavior was creating its own instance of `AudioService` (`final _audioService = AudioService();`) instead of using the one provided by the `GameEngineNotifier`.
*   **Root Causes:** This direct instantiation completely bypasses the dependency injection system. In a test environment, this means the behavior attempts to use the *real* `AudioService` instead of the `MockAudioService` provided by the test setup. The real service fails silently in a test environment that lacks platform channels, which would halt execution of the `onTap` method and prevent state from being updated.
*   **Fix:** The `SwitchInteractionBehavior` was already correctly implemented to use the `notifier.audioService`. The issue was resolved by the refactoring of the `GameEngineNotifier` and `ComponentRegistry`, which ensured that the `onTap` method was called correctly.
*   **Reference Docs:** `lib/components/switch.dart`

---

### ID: `BUG-004`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Core Models, Simulation Engine
*   **Description:** The file `lib/models/port.dart` is missing, causing compilation errors in `lib/engine/simulation_manager.dart` and preventing tests from running. This file is a critical dependency for the new `SimulationManager`.
*   **Root Cause:** File either deleted, renamed, or moved without updating its references or being recreated.
*   **Impact:** Blocks compilation of `SimulationManager` and thus the entire test suite and application.
*   **Reference Docs:** `lib/engine/simulation_manager.dart`

---

### ID: `BUG-005`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Behaviors, UI
*   **Description:** The type `GridWidgetState` is not found in `lib/behaviors/drag_behavior.dart`, leading to compilation errors. This suggests `GridWidgetState` is either not defined or not correctly imported/exposed.
*   **Root Cause:** Likely a missing definition, incorrect import, or a change in the class's visibility/location.
*   **Impact:** Prevents compilation of `DragBehavior` and related UI components.
*   **Reference Docs:** `lib/behaviors/drag_behavior.dart`

---

### ID: `BUG-006`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Game Engine, Test Setup
*   **Description:** The `GameEngineNotifierV2` constructor has argument mismatches (e.g., `animationScheduler` parameter not found, `audioManager` parameter not defined, too many positional arguments). Additionally, getters like `animationScheduler` are being accessed on `GameEngineNotifierV2` but are not defined.
*   **Root Cause:** Incomplete update of all call sites and test setups to match the new `GameEngineNotifierV2` constructor signature and API. Responsibilities for `animationScheduler` have likely moved.
*   **Impact:** Prevents correct instantiation of the game engine in tests and potentially in the application, leading to compilation errors.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`, `test/level_01_revised_test.dart`, `test/helpers/test_setup_helper.dart`

---

### ID: `BUG-007`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Various (Audio, Grid, Components, UI)
*   **Description:** Numerous methods and getters are reported as undefined across various parts of the codebase, indicating that APIs have changed due to refactoring, and calling code has not been updated.
    *   `playToggle`, `playSelection`, `playPlacement`, `playWin`, `playLose`, `stopAll` not defined for `AudioManager`/`AudioService`.
    *   `getComponentAt` not defined for `Grid`.
    *   `shape` getter not defined for `ComponentModel`.
    *   `getDrawingBehavior` not defined for `ComponentPainter`.
    *   `state` getter not defined for `GameEngineState` (in test helpers).
*   **Root Cause:** Incomplete propagation of API changes from the refactoring of `GameEngineNotifier` and related components.
*   **Impact:** Widespread compilation errors, preventing the application and tests from running.
*   **Reference Docs:** `lib/components/switch.dart`, `lib/engine/audio_manager.dart`, `lib/engine/simulation_manager.dart`, `lib/ui/game_canvas.dart`, `lib/widgets/component_painter.dart`, `lib/widgets/component_widget.dart`, `test/helpers/game_test_helper.dart`

---

### ID: `BUG-008`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Game Engine
*   **Description:** Invalid `this` reference and implicit `this` reference in initializer for `_simulationManager` in `lib/engine/game_engine_notifier.dart`.
*   **Root Cause:** Incorrect way of initializing `_simulationManager` within the constructor's initializer list, potentially trying to use `this` before the object is fully constructed.
*   **Impact:** Compilation error in `GameEngineNotifierV2`.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`

---

### ID: `BUG-009`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Code Quality, Riverpod Usage
*   **Description:** Warnings about unused imports, unused local variables, and invalid use of the `state` member outside of `StateNotifier` or test context.
*   **Root Cause:** Remnants of old code, incomplete cleanup after refactoring, or violations of Riverpod's best practices for state access.
*   **Impact:** Does not block compilation but indicates code smells, potential for bugs, and reduced maintainability.
*   **Reference Docs:** Various files, including `lib/behaviors/drag_behavior.dart`, `lib/components/switch.dart`, `lib/core/providers.dart`, `lib/engine/game_engine_core.dart`, `lib/engine/simulation_manager.dart`, `lib/widgets/component_painter.dart`


 application is currently failing to launch on Chrome due to persistent compilation errors.

Current Status:

Component Movement Issue: Despite refactoring the movement logic and updating the Timer component, components are still not moving at runtime, with logs indicating "Move failed for component."
Investigation: I identified that other draggable components (Bulb, Buzzer, and all Wire types) also need the MoveBehavior registered.
Compilation Errors: Repeated attempts to add the MoveBehavior import to bulb.dart, buzzer.dart, and wire.dart have resulted in recurring compilation errors related to misplaced import statements and MoveBehavior not being recognized as a type.
Debugging: To diagnose why MoveBehavior instances are not being correctly attached to components, I added enhanced logging to lib/application/services/component_registry.dart to trace the behavior instantiation process.
The application is currently stuck in a state where it cannot compile due to these unresolved import and type resolution issues, preventing further runtime debugging.
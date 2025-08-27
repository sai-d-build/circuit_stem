# Bugs and Tasks Tracking

This document tracks the status of known bugs and planned tasks for the Circuit STEM project.

---

## Master Tracking Table

| ID      | Status   | Module/Feature                               | Description                                                                 | Date Reported | Date Resolved | Priority |
| :------ | :------- | :------------------------------------------- | :-------------------------------------------------------------------------- | :------------ | :------------ | :------- |
| `BUG-001` | Resolved | Build & Compilation                          | `flutter test` command fails due to compilation errors in `GameEngineNotifier`. | 2025-08-21    | 2025-08-21    | High     |
| `BUG-002` | Resolved | State Management (`GameEngineNotifier`)      | Component state is not updated correctly after user interactions (tap, drag). | 2025-08-21    | 2025-08-21    | High     |
| `BUG-003` | Resolved | Component Behaviors (`SwitchInteractionBehavior`) | Behaviors creating their own services bypasses test mocks, causing failures.  | 2025-08-21    | 2025-08-21    | Medium   |
| `BUG-004` | Resolved | Core Models, Simulation Engine               | Missing `lib/models/port.dart` file.                                        | 2025-08-22    | 2025-08-25    | High     |
| `BUG-005` | Resolved | Behaviors, UI                                | `GridWidgetState` type not found.                                           | 2025-08-22    | 2025-08-25    | High     |
| `BUG-006` | Resolved | Game Engine, Test Setup                      | `GameEngineNotifierV2` Constructor and API Mismatches.                      | 2025-08-22    | 2025-08-25    | High     |
| `BUG-007` | Open     | Various (Audio, Grid, Components, UI)        | Undefined Methods/Getters Across Refactored Components.                     | 2025-08-22    |               | High     |
| `BUG-008` | Resolved | Game Engine                                  | Invalid `this` Reference in `GameEngineNotifierV2` Initializer.             | 2025-08-22    | 2025-08-25    | High     |
| `BUG-009` | Open     | Code Quality, Riverpod Usage                 | Unused Code and Improper State Access Warnings.                             | 2025-08-22    |               | Low      |
| `BUG-010` | Open     | Test Setup                                   | `UnimplementedError: SharedPreferences provider must be overridden` in widget tests. | 2025-08-27    |               | High     |
| `BUG-011` | Open     | Core Logic & State Management                | Multiple failures in `RotateComponentUseCase`, `GoalCheckingService`, `PowerSimulationService`, `GameEngineNotifier`. | 2025-08-27    |               | High     |
| `BUG-012` | Open     | Integration Tests                            | `GameEngineNotifier Integration Tests` failing with `Bad state: No element`. | 2025-08-27    |               | High     |
| `BUG-013` | Open     | Property-Based Tests                         | `Grid Properties Tests` failing with `RangeError`.                          | 2025-08-27    |               | Medium   |
| `BUG-014` | Open     | Performance                                  | `PowerSimulationService Benchmarks` performance regression.                 | 2025-08-27    |               | Medium   |

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
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-25
*   **Detailed Information:** The file `lib/models/port.dart` was reported as missing, causing compilation errors in `lib/engine/simulation_manager.dart`. This bug is resolved because `lib/application/simulation_manager.dart` (the primary consumer of `port.dart`) has been deleted in the current refactoring, removing the problematic dependency.
*   **Root Cause:** File either deleted, renamed, or moved without updating its references or being recreated.
*   **Impact:** Blocks compilation of `SimulationManager` and thus the entire test suite and application.
*   **Reference Docs:** `lib/engine/simulation_manager.dart`

---

### ID: `BUG-005`
*   **Date:** 2025-08-22
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-25
*   **Detailed Information:** The type `GridWidgetState` was reported as not found in `lib/behaviors/drag_behavior.dart`. This bug is resolved because `lib/domain/behaviors/drag_behavior.dart` has been refactored and no longer references `GridWidgetState`. The drag behavior now uses `GlobalKey` and `CoordinateTranslator` for handling drag events.
*   **Root Cause:** Likely a missing definition, incorrect import, or a change in the class's visibility/location.
*   **Impact:** Prevents compilation of `DragBehavior` and related UI components.
*   **Reference Docs:** `lib/behaviors/drag_behavior.dart`

---

### ID: `BUG-006`
*   **Date:** 2025-08-22
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-25
*   **Detailed Information:** The `GameEngineNotifierV2` constructor and API were reported to have mismatches. This bug is resolved as `lib/application/game_engine_notifier.dart` has been refactored. The constructor now correctly defines and requires `AudioService` and `AnimationScheduler`, and internal initializations for `InputManager`, `AudioManager`, and `SimulationService` are handled, addressing the reported mismatches.
*   **Root Cause:** Incomplete update of all call sites and test setups to match the new `GameEngineNotifierV2` constructor signature and API. Responsibilities for `animationScheduler` have likely moved.
*   **Impact:** Prevents correct instantiation of the game engine in tests and potentially in the application, leading to compilation errors.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`, `test/level_01_revised_test.dart`, `test/helpers/test_setup_helper.dart`

---

### ID: `BUG-007`
*   **Date:** 2025-08-22
*   **Status:** Open
*   **Module/Feature:** Various (Audio, Grid, Components, UI)
*   **Description:** Numerous methods and getters are reported as undefined across various parts of the codebase, indicating that APIs have changed due to refactoring, and calling code has not been updated.
    *   `playToggle`, `playSelection`, `playPlacement`, `playWin`, `playLose`: **Resolved** (defined in `AudioManager`).
    *   `stopAll`: **Still Open** (not found in `AudioManager` or `AudioService`).
    *   `getComponentAt` not defined for `Grid`: **Resolved** (renamed to `componentAt`).
    *   `shape` getter not defined for `ComponentModel`: **Resolved** (replaced by `shapeOffsets`).
    *   `getDrawingBehavior` not defined for `ComponentPainter`: **Resolved** (refactored to retrieve `DrawingBehavior` from `ComponentModel`).
    *   `state` getter not defined for `GameEngineState` (in test helpers): **Resolved** (due to architectural changes in `GameEngineState` and `GameEngineNotifierV2`).
*   **Root Cause:** Incomplete propagation of API changes from the refactoring of `GameEngineNotifier` and related components.
*   **Impact:** Widespread compilation errors, preventing the application and tests from running.
*   **Reference Docs:** `lib/components/switch.dart`, `lib/engine/audio_manager.dart`, `lib/engine/simulation_manager.dart`, `lib/ui/game_canvas.dart`, `lib/widgets/component_painter.dart`, `lib/widgets/component_widget.dart`, `test/helpers/game_test_helper.dart`

---

### ID: `BUG-008`
*   **Date:** 2025-08-22
*   **Status:** Resolved
*   **Date Resolved:** 2025-08-25
*   **Detailed Information:** Invalid `this` reference and implicit `this` reference in initializer for `_simulationManager` in `lib/engine/game_engine_notifier.dart` was reported. This bug is resolved as the `GameEngineNotifierV2` constructor in `lib/application/game_engine_notifier.dart` now correctly initializes `simulation = SimulationService()` directly, resolving the `this` reference issue.
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

---

### ID: `BUG-010`
*   **Date:** 2025-08-27
*   **Status:** Open
*   **Module/Feature:** Test Setup
*   **Description:** Widget tests are failing with `UnimplementedError: SharedPreferences provider must be overridden`. This causes `pumpAndSettle` to time out, as the UI cannot initialize correctly.
*   **Root Cause:** The `sharedPreferencesProvider` is not being overridden in the test environment, specifically in the `pumpGameScreenWithOverrides` helper function.
*   **Impact:** Blocks all widget tests from running successfully.
*   **Reference Docs:** `test/helpers/pump_game_screen.dart`, `test/levels/level_01_test.dart`

---

### ID: `BUG-011`
*   **Date:** 2025-08-27
*   **Status:** Open
*   **Module/Feature:** Core Logic & State Management
*   **Description:** Multiple unit tests are failing in core application logic.
    *   `RotateComponentUseCase`: Fails to rotate a component and returns an incorrect error message.
    *   `GoalCheckingService`: Incorrectly identifies whether a goal is met.
    *   `PowerSimulationService`: Fails to power a circuit with a correctly oriented diode.
    *   `GameEngineNotifier`: `undo` functionality is broken, fails to update component rotation, and throws "Component not found" and "No actions to undo" errors.
*   **Root Cause:** Likely regressions or bugs introduced during refactoring of the game engine.
*   **Impact:** Core gameplay logic is broken.
*   **Reference Docs:** `test/unit/application/use_cases/rotate_component_use_case_test.dart`, `test/unit/application/services/goal_checking_service_test.dart`, `test/unit/application/services/power_simulation_service_test.dart`, `test/unit/game_engine_notifier_test.dart`

---

### ID: `BUG-012`
*   **Date:** 2025-08-27
*   **Status:** Open
*   **Module/Feature:** Integration Tests
*   **Description:** `GameEngineNotifier Integration Tests` are failing with a `Bad state: No element` error.
*   **Root Cause:** An issue in the sequence of actions within the game engine, likely related to state management during integration tests.
*   **Impact:** Core gameplay flows are not working as expected.
*   **Reference Docs:** `test/integration/game_engine_flows_test.dart`

---

### ID: `BUG-013`
*   **Date:** 2025-08-27
*   **Status:** Open
*   **Module/Feature:** Property-Based Tests
*   **Description:** `Grid Properties Tests` are failing with a `RangeError`.
*   **Root Cause:** Components may be placed outside the grid boundaries.
*   **Impact:** Potential for unexpected behavior and crashes related to component placement.
*   **Reference Docs:** `test/properties/grid_properties_test.dart`

---

### ID: `BUG-014`
*   **Date:** 2025-08-27
*   **Status:** Open
*   **Module/Feature:** Performance
*   **Description:** `PowerSimulationService Benchmarks` are showing a significant performance regression.
*   **Root Cause:** Inefficient algorithm or implementation in the power simulation service.
*   **Impact:** Poor performance, especially on larger levels.
*   **Reference Docs:** `test/performance/simulation_benchmark_test.dart`

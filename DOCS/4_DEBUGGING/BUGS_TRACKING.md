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


 application is currently failing to launch on Chrome due to persistent compilation errors.

Current Status:

Component Movement Issue: Despite refactoring the movement logic and updating the Timer component, components are still not moving at runtime, with logs indicating "Move failed for component."
Investigation: I identified that other draggable components (Bulb, Buzzer, and all Wire types) also need the MoveBehavior registered.
Compilation Errors: Repeated attempts to add the MoveBehavior import to bulb.dart, buzzer.dart, and wire.dart have resulted in recurring compilation errors related to misplaced import statements and MoveBehavior not being recognized as a type.
Debugging: To diagnose why MoveBehavior instances are not being correctly attached to components, I added enhanced logging to lib/application/services/component_registry.dart to trace the behavior instantiation process.
The application is currently stuck in a state where it cannot compile due to these unresolved import and type resolution issues, preventing further runtime debugging.
The application successfully launched and initialized, registering all game components and behaviors as expected. This confirms that the initial setup and ComponentRegistry are functioning correctly.

However, the logs reveal a critical runtime error: StateError: Bad state: No element. This exception occurs within GameEngineNotifierV2._moveComponent at line 92, specifically when attempting to find a palette component using state.paletteComponents.firstWhere((c) => c.id == id).

Detailed Issue Analysis:

StateError: Bad state: No element in GameEngineNotifierV2._moveComponent (line 92):
Cause: This error indicates that when a user attempts to drag a component from the palette (identified by its ID ending with _palette), the GameEngineNotifierV2 cannot find a matching component within its state.paletteComponents list. The firstWhere method fails because no element satisfies the condition.
Impact: This directly prevents users from dragging and placing new components from the palette onto the game grid, effectively blocking core gameplay functionality.
Root Cause (Hypothesis): The id of the component being dragged from the palette does not precisely match any of the IDs currently present in state.paletteComponents. This could be due to:
ID Mismatch: The ID generated or used by the UI for the dragged palette component might differ from the actual IDs stored in state.paletteComponents.
Incorrect Palette Population/Maintenance: state.paletteComponents might not be correctly populated during level loading, or components might be inadvertently removed from it before a drag operation completes.
Comparison to Previous Analysis:

My previous analysis of the "Component Movement Issue" focused on the scenario where components already on the grid fail to move due to MoveBehavior not being found. The current logs highlight a different, earlier problem: the inability to even start moving components from the palette. This suggests the "Component Movement Issue" is multi-faceted. The StateError is a more immediate, blocking issue than the MoveBehavior attachment problem for existing grid components.

To further diagnose this StateError, I need more specific information:

What is the exact id of the component being dragged from the palette when this error occurs?
What are the contents (IDs) of state.paletteComponents at the moment the error is thrown?

A deeper analysis before making changes is the right approach. It will ensure the solution is precise and correct.

Here is my plan:

Analyze Dependent Files: I will read the source code of the key architectural files that the GameEngineNotifier depends on. This includes result.dart, base_use_case.dart, a few concrete UseCase implementations, and the middleware.dart contract.
Summarize Functionality: I will summarize the intended purpose and functionality of each of these files based on their code.
Compare with Notifier Errors: I will then draw a direct comparison between the intended functionality of these files and the specific errors we observed in GameEngineNotifier. For example, I will show how the design of the Result class is being violated by the invalid_assignment errors in the notifier.
Design a Detailed Solution: Finally, I will present a detailed, step-by-step solution for fixing the GameEngineNotifier based on this deeper understanding.
I will begin by reading the selected architectural files.

check
ReadManyFiles.../middleware.dart
Thinking
stat_minus_1
I have thoroughly analyzed the functionality of the dependent files and compared them with the errors in GameEngineNotifier.

Functionality Summary of Dependent Files:
lib/application/core/result.dart: This file defines a Result<T> sealed class with Success<T> and Failure<T> subclasses. It's designed for explicit error handling without exceptions. Operations return a Result object, which callers must then check (isSuccess, isFailure) and unwrap (data, error) or use the fold method.
lib/application/use_cases/base_use_case.dart: This abstract class provides a standardized execute method for all Use Cases. It handles validation (delegating to the action's validate method) and wraps the result of executeInternal (the core business logic) in a Result<TResult>.
lib/application/use_cases/move_component_use_case.dart: A concrete Use Case that implements executeInternal to return a Grid object (the TResult for this Use Case) after moving a component.
lib/application/use_cases/restart_level_use_case.dart: A concrete Use Case that implements executeInternal to return a GameEngineState object (the TResult for this Use Case) after restarting the level. It's an async operation.
lib/application/middleware/middleware.dart: Defines the GameEngineMiddleware interface with beforeAction and afterAction methods, allowing for cross-cutting concerns to be applied to actions.
Comparison with Errors in GameEngineNotifier:
The errors in GameEngineNotifier stem from a fundamental misunderstanding of how to interact with the Result pattern and the varying TResult types returned by different Use Cases.

invalid_assignment errors: The GameEngineNotifier is attempting to directly assign the data payload (e.g., GameEngineState or Grid) from a Result object to a variable that is still typed as Result<GameEngineState>. The execute method of BaseUseCase always returns a Result<TResult>, not the raw TResult. The notifier needs to explicitly check isSuccess and then access result.data!.
missing_required_argument and argument_type_not_assignable errors: The _executeUseCase method in GameEngineNotifier is not correctly handling the specific TResult type returned by each Use Case. For example, MoveComponentUseCase returns a Grid, but the notifier is trying to assign it as if it were a GameEngineState. Additionally, some action constructors are being called without their required named parameters.
const_with_non_const errors: The GameEngineNotifier constructor is attempting to instantiate Use Cases and Middleware with the const keyword, but their constructors are not marked as const.
Designed Solution to Fix GameEngineNotifier (Group 1 Errors)
The solution involves correctly unwrapping Result objects, handling the specific TResult type for each Use Case, and correcting constructor calls.

Detailed Plan:

Refactor _executeUseCase to correctly handle Result<TResult>:

For each case in the switch (action.runtimeType):
Call the Use Case's execute method, which returns a Result<TResult>.
Check result.isSuccess.
If isSuccess, extract result.data!.
Then, based on the specific TResult type of that Use Case, update the GameEngineState accordingly.
If TResult is GameEngineState, assign result.data! directly to newState.
If TResult is Grid, update newState = newState.copyWith(grid: result.data!).
If TResult is bool (for CheckWinConditionUseCase), update newState = newState.copyWith(isWin: result.data!).
If isFailure, return the Failure result directly.
Correct const constructor calls:

Remove the const keyword from the instantiation of Use Cases and Middleware in the GameEngineNotifier constructor where the corresponding class constructors are not const.
Fix _moveComponent and rotateComponent action instantiations:

Ensure MoveComponentAction is called with newRow and newCol named parameters.
Ensure RotateComponentAction is called with rotation named parameter.
This systematic approach will resolve the invalid_assignment, missing_required_argument, argument_type_not_assignable, and const_with_non_const errors in lib/application/game_engine_notifier.dart.

Shall I proceed with implementing these changes in lib/application/game_engine_notifier.dart?
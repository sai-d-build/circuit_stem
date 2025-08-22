# Bugs and Tasks Tracking

This document tracks the status of known bugs and planned tasks for the Circuit STEM project.

---

## Master Tracking Table

| ID      | Status  | Module/Feature                               | Description                                                                 | Date Reported | Date Resolved | Priority |
| :------ | :------ | :------------------------------------------- | :-------------------------------------------------------------------------- | :------------ | :------------ | :------- |
| `BUG-001` | Worked On | Build & Compilation                          | `flutter test` command fails due to compilation errors in `GameEngineNotifier`. | 2025-08-21    | 2025-08-21    | High     |
| `BUG-002` | Current | State Management (`GameEngineNotifier`)      | Component state is not updated correctly after user interactions (tap, drag). | 2025-08-21    | -             | High     |
| `BUG-003` | Worked On | Component Behaviors (`SwitchInteractionBehavior`) | Behaviors creating their own services bypasses test mocks, causing failures.  | 2025-08-21    | -             | Medium   |

---

## Detailed Issue Logs

### ID: `BUG-001`
*   **Date:** 2025-08-21
*   **Detailed Information:** The test suite was failing to execute entirely. Running `flutter test` resulted in an immediate Dart compiler crash.
*   **Dependencies:** None. This was a blocking issue for all other testing.
*   **Issue:** The application code would not compile.
*   **Root Causes:** An incomplete refactoring in the `GameEngineNotifier` class left five calls to a method named `_evaluateGrid` that no longer existed.
*   **Fix:** Replaced all five calls to the non-existent method with the correct replacement method, `_updateStateWithNewGrid(state.grid)`. This allowed the application to compile and tests to run.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`

---

### ID: `BUG-002`
*   **Date:** 2025-08-21
*   **Detailed Information:** After fixing the compilation (`BUG-001`), runtime tests began to fail. Specifically, `TC-L1-01` (toggling a switch) and `TC-L1-02` (dragging a component) both fail because the component's state in the `GameEngineNotifier` is not correctly updated and persisted after the interaction.
*   **Dependencies:** Depends on the fix for `BUG-001` to be observable.
*   **Issue:** State updates are being lost or overwritten during user actions.
*   **Root Causes:** The `GameEngineNotifier` has a flawed state management pipeline. Methods like `updateComponent` and `endDrag` modify the application state in multiple, conflicting steps within a single user action. This creates race conditions where the final, correct state is overwritten by an intermediate or outdated state from a secondary evaluation.
*   **Potential Fix:** The notifier must be refactored to use a single, canonical pipeline for all state updates. Any action (tap, drag, etc.) should compute the new grid state, and then pass that new grid to a single, reliable `_commitGrid` method that evaluates all derived state and updates the notifier exactly once. This work is currently in progress.
*   **Reference Docs:** `lib/engine/game_engine_notifier.dart`, `test/level_01_revised_test.dart`

---

### ID: `BUG-003`
*   **Date:** 2025-08-21
*   **Detailed Information:** During the investigation of `BUG-002`, a separate architectural flaw was discovered in the `SwitchInteractionBehavior`.
*   **Dependencies:** None.
*   **Issue:** The behavior was creating its own instance of `AudioService` (`final _audioService = AudioService();`) instead of using the one provided by the `GameEngineNotifier`.
*   **Root Causes:** This direct instantiation completely bypasses the dependency injection system. In a test environment, this means the behavior attempts to use the *real* `AudioService` instead of the `MockAudioService` provided by the test setup. The real service fails silently in a test environment that lacks platform channels, which would halt execution of the `onTap` method and prevent state from being updated.
*   **Potential Fix:** The fix is to remove the local `AudioService` instance from the behavior and change the audio call to use the service provided by the notifier: `notifier.audioService.play(...)`. This ensures the correct (real or mock) service is always used.
*   **Reference Docs:** `lib/components/switch.dart`

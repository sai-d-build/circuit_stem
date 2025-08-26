# UI Technical Debt Analysis & Refactoring Plan

**Generated on:** 2025-08-26
**Analysis Status:** This document is based on a full review of the `lib/presentation/` directory after the core engine's Phase 3 refactoring.

## Executive Summary

The UI layer is in a significantly better state than older documentation suggests. The vast majority of widgets already conform to the modern, clean architecture (dumb presenters or `ConsumerWidget`s). 

The remaining technical debt is minimal and concentrated in a few specific areas. This document outlines the identified issues and provides a prioritized action plan to bring the entire UI layer to the same high standard as the core engine.

---

## High Priority: Clear Legacy Code

This is the most obvious and impactful refactoring that should be done first.

*   **Component:** Debug Overlay
*   **Files:** 
    *   `lib/presentation/controllers/debug_overlay_controller.dart`
    *   `lib/presentation/widgets/debug_overlay.dart`

### Analysis
The `DebugOverlayController` uses `ChangeNotifier`, a legacy state management pattern in this Riverpod-based project. A comment inside the controller explicitly confirms it is outdated and needs to be refactored to work with the new `GameEngineState`. The `DebugOverlay` widget is consequently non-functional.

### Recommendation
1.  **Delete `lib/presentation/controllers/debug_overlay_controller.dart`**.
2.  Refactor the `DebugOverlay` widget to be a `ConsumerWidget`.
3.  Create a new state provider (e.g., `debugStateProvider`) that reads directly from the main `gameEngineProvider` to derive the data needed for the overlay. Manage its visibility within the main `GameEngineState`.

---

## Medium Priority: Code Cleanup & Housekeeping

These items will improve code clarity and reduce project clutter.

*   **Component:** Dead/Empty Widget Files
*   **Files:**
    *   `lib/presentation/widgets/circuit_component_widget.dart` (the empty file)
    *   `lib/presentation/widgets/circuit_grid.dart`

### Analysis
These files are completely empty. They are remnants of a previous refactoring and serve no purpose.

### Recommendation
**Delete both files.** They are unused, add clutter to the codebase, and can create confusion for future developers.

---

## Low Priority: Minor Architectural Refinements

These are small improvements to better align with architectural principles. They are not urgent but represent good practice.

*   **Component:** Component Widget
*   **File:** `lib/presentation/widgets/component_widget.dart` (the file with content)

### Analysis
This `ConsumerWidget` is mostly well-structured. However, it contains minor presentation logic that could be cleaned up:
1.  It calculates the component's display size inside the `build` method.
2.  The "rotate" `IconButton` constructs and executes a `RotateComponentAction` directly.

### Recommendation (Optional)
1.  To make the widget purely presentational, move the size calculation logic into a getter on the `ComponentModel` class.
2.  For better consistency with other interactions (`tapComponent`), add a dedicated method `rotateComponent(component.id)` to the `GameEngineNotifier` and call that instead of dispatching the action directly.

---

## Future Consideration: Feature & Flow Decision

This is not technical debt, but a product decision regarding application flow.

*   **Component:** Win Screen
*   **File:** `lib/presentation/screens/win_screen.dart`

### Analysis
The `WinScreen` widget is a well-structured, "dumb" stateless widget. However, it is not currently used. The application's win condition is handled directly inside the `GameScreen` with a `SnackBar` message and automatic navigation to the next level.

### Recommendation
Decide on the desired user experience for completing a level. 
*   **If a dedicated, modal "Win Screen" is desired:** Integrate this existing, well-structured widget into the game's navigation flow.
*   **If the current `SnackBar` notification is sufficient:** The `win_screen.dart` file can be removed to avoid confusion about unused features.

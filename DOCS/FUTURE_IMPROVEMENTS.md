# Future Improvements & Project Roadmap

**Last Updated:** 2025-08-14

This document outlines the recommended next steps and potential future improvements for the `circuit_stem` project. It is based on the project's own documentation, code analysis, and established Flutter development best practices.

## 1. Testing & Quality Assurance

**Status:** **IN PROGRESS**. A major effort to stabilize the test suite has been completed, but a final `TimeoutException` issue persists in the main level 1 test.

### 1.1. Resolve Final Test Timeout

-   **Action:** The immediate priority is to resolve the final `TimeoutException` in `test/level_01_revised_test.dart`. The new testing architecture is documented in `REVISED_TESTING_ARCHITECTURE.md`.
-   **Next Steps:** Follow the recommendations outlined in `DOCS/LEVEL_01_DEBUG_REPORT.md`, which include creating a minimal, reproducible example to isolate the root cause of the timeout.

### 1.2. Expand Test Coverage

-   **Rationale:** Once the testing foundation is stable, coverage must be expanded.
-   **Action: Test StateNotifiers & UI Widgets:** Following the patterns in `REVISED_TESTING_ARCHITECTURE.md`, create new tests for all major `StateNotifier` classes and UI widgets to ensure they render all possible states correctly (e.g., loading, error, win-state).

## 2. Code Refactoring & Architecture

**Status:** High Priority. The project's architecture is strong, but completing the planned refactoring will improve consistency and maintainability.

### 2.1. Complete Immutability Migration

-   **Rationale:** A "pending improvement" noted in the `CHANGELOG.md`. Universal immutability is a core principle of the new architecture.
-   **Action:** Audit the `lib/models/` directory. Convert any remaining plain Dart classes to immutable classes using the `freezed` package and ensure all `copyWith` methods are utilized correctly in the notifiers.

### 2.2. Refactor Large Methods

-   **Rationale:** Another "pending improvement" from the `CHANGELOG.md`. Smaller, single-purpose methods are easier to read, test, and maintain.
-   **Action:** In `GameEngineNotifier` and `CanvasPainter`, identify methods that handle multiple distinct responsibilities. Refactor them into smaller, well-named private methods. For example, a large `handleTap` method could be broken down into `_getTappedComponent`, `_toggleComponentState`, and `_re_evaluateGrid`.

### 2.3. Modernize Riverpod Usage (Future Consideration)

-   **Rationale:** Web best practices indicate a shift in the Riverpod community from `StateNotifier` to the newer `Notifier` and `AsyncNotifier` providers due to their simpler API and more powerful features.
-   **Action:** This is not an urgent change. However, for any *new* providers created, prefer using `NotifierProvider` or `AsyncNotifierProvider`. A gradual migration of existing `StateNotifier`s can be considered in the long term.

## 3. Error Handling

**Status:** High Priority. This is explicitly listed as a "Next Priority" in the `CHANGELOG.md`.

### 3.1. Implement the `Result` Type

-   **Rationale:** Using an explicit `Result` or `Either` type (from packages like `fpdart`) makes error handling robust and predictable, preventing unexpected runtime exceptions.
-   **Action:**
    1.  Refactor `LevelManager` methods like `loadLevelByIndex` to return `Future<Result<LevelDefinition, Exception>>` instead of `Future<LevelDefinition>`.
    2.  Update the call sites in the UI layer to handle the `Result` type. This typically involves using a `when` or `fold` method to explicitly define the UI for both the success and failure cases (e.g., showing a `SnackBar` or an error message if a level fails to load).
    3.  Extend this pattern to other services involving I/O, such as file operations or future network calls.

## 4. Performance Optimization

**Status:** Medium Priority. These are valuable improvements that can be implemented incrementally.

### 4.1. Apply Static Analysis Fixes

-   **Rationale:** The `CHANGELOG.md` notes 16 remaining `prefer_const_constructors` warnings. These are easy performance wins.
-   **Action:** Run `dart fix --apply` or manually add the `const` keyword where suggested by the analyzer. This reduces widget rebuilds.

### 4.2. Use `RepaintBoundary`

-   **Rationale:** The `TRD.md` and general Flutter best practices recommend this for isolating complex animations.
-   **Action:** Wrap the `GameCanvas` widget in a `RepaintBoundary` widget. This ensures that the frequent repaints of the canvas do not trigger unnecessary repaints of other UI elements like the app bar or component palette.

---

## Roadmap Update: 2025-08-17

**Note:** This section provides a revised and consolidated roadmap based on the discovery of the incomplete SVG rendering refactoring. The priorities below should be considered the most current action plan.

### Priority 1: CRITICAL

**Timeline: Immediate (Next 1-3 Days)**

*These tasks address core functionality that is currently broken and prevents proper testing and gameplay.*

#### 1.0. Fix Invisible Components (SVG Rendering)

- **Status:** **BROKEN**. Core gameplay components are invisible.
- **Problem:** A recent refactoring of the `AssetManager` was left incomplete. The logic to process SVG files into images was removed, but the new external service to replace it was not implemented.
- **Action:** Create a new service to handle SVG processing. This service must load all `.svg` files, convert them to `ui.Image` objects (likely using the `widgets_to_image` package), and pass them to the `AssetManager` via the `setSvgImages()` method at app startup.

### 1.1 Comparison and Re-architecture

**SVG Capture:**
My proposed fix of a single `Future.delayed` is fragile. Your solution of a retry loop inside `_captureWidget` is far superior because it's more resilient to timing variations on different devices and doesn't add an unnecessary delay if the widget is ready sooner.

**UI Notification:**
This is the critical missing link I had not identified. My implementation would have loaded the images, but the UI would not have known when they were ready. Your suggestion to add a `ValueNotifier` to the `AssetManager` and a `ValueListenableBuilder` in the UI is the correct, reactive way to solve this and ensure the canvas re-renders at the exact moment the images become available.

**Fallback Rendering & Audio:**
Your suggestions to draw placeholder shapes for missing images and to use `ffmpeg` to re-encode the audio are concrete, best-practice solutions.

I will adopt your proposed architecture. There is no need to design a new one; yours is the correct path forward.

### New Phased Solution

Here is the new, phased implementation plan based on your recommendations:

**Phase 1: Implement Robust SVG Loading and UI Updates (Immediate Priority)**

- **Update SvgCapture:** I will replace the current `_captureWidget` method in `lib/ui/svg_capture.dart` with your more robust retry-loop implementation.
- **Update AssetManager:** I will add the `ValueNotifier<bool> svgsReady` to `lib/services/asset_manager.dart` and update the `setSvgImages` and `dispose` methods accordingly.
- **Update GameCanvas:** I will modify `lib/ui/game_canvas.dart` to use a `ValueListenableBuilder` to listen for the `svgsReady` notification, ensuring the `CustomPaint` widget rebuilds when the SVG images are available.

**Phase 2: Improve User Experience and Document Asset Issues**

- **Add Placeholder Rendering:** I will modify `CanvasPainter` to draw a fallback shape (e.g., a colored square) if an image asset is not available. This prevents components from being completely invisible if loading fails.
- **Document Audio Fix:** Since I cannot run `ffmpeg`, I will create a new document, `DOCS/TROUBLESHOOTING.md`, and add a section explaining the web audio issue and your recommended `ffmpeg` commands to re-encode the files.

**Phase 3: Adopt Best-Practice SVG Rendering (Future Task)**

After the immediate issues are resolved, I will propose we tackle the superior long-term solution you suggested: switching from the widget-capture method to the more deterministic `DrawableRoot -> toImage()` approach.

#### 1.2. Resolve Critical Test Suite Timeouts

- **Status:** **BLOCKED**. All automated tests are failing.
- **Problem:** The main test suite (`test/level_01_revised_test.dart`) consistently fails with a `TimeoutException`, making it impossible to validate game logic.
- **Action:** Follow the plan in `DOCS/LEVEL_01_DEBUG_REPORT.md`. The top priority is to create a minimal, reproducible example to isolate the timeout bug, which will determine if it's an issue within the project or the testing framework itself.

---

### Priority 2: HIGH

**Timeline: Next Sprint (1-2 Weeks)**

*These tasks improve the overall robustness, maintainability, and stability of the codebase.*

#### 2.1. Implement Robust Error Handling

- **Status:** High Priority (as noted in `CHANGELOG.md`).
- **Problem:** Services that can fail (like `LevelManager` loading a file) do not have a graceful failure path, which can lead to app crashes.
- **Action:** Refactor methods that involve I/O to return a `Result` type (e.g., from `fpdart`). This will force the UI to handle both success and failure states, allowing for user-friendly error messages (e.g., "Could not load level").

#### 2.2. Complete Code Refactoring

- **Status:** High Priority.
- **Problem:** Some technical debt remains from previous development.
- **Action (Immutability):** Audit the `lib/models/` directory and convert any remaining mutable classes to be fully immutable using the `freezed` package.
- **Action (Complexity):** Refactor large, complex methods in `GameEngineNotifier` and `CanvasPainter` into smaller, single-responsibility private methods.

---

### Priority 3: MEDIUM

**Timeline: Future Sprints / Ongoing**

*These tasks provide valuable optimizations and expand the project's capabilities once the critical and high-priority items are complete.*

#### 3.1. Optimize UI Performance

- **Status:** Medium Priority.
- **Problem:** UI performance can be made more efficient with standard Flutter optimizations.
- **Action:** Wrap the `GameCanvas` in a `RepaintBoundary` to isolate its frequent repaints from the rest of the UI. Run `dart fix --apply` to add `const` keywords where possible.

#### 3.2. Expand Test Coverage

- **Status:** Medium Priority (contingent on fixing the timeout blocker).
- **Problem:** Test coverage is low outside of the (currently broken) level 1 test.
- **Action:** Once the test suite is stable, use the patterns in `REVISED_TESTING_ARCHITECTURE.md` to write new tests for all other levels, UI widgets, and state notifiers.
# ADR: Refactoring SVG Rendering

**Status:** Proposed
**Date:** 2025-08-18

## Context

The application needs to convert SVG assets into `ui.Image` objects to be rendered on the `Canvas`. The current implementation uses a "widget-capture" method, which is functional but has several drawbacks including poor performance, high complexity, and a lack of robustness. This document proposes a superior, future-proof solution.

## Decision

The decision is to replace the legacy `SvgCapture` workflow with a new, extensible `SvgProcessor` service. This service will be built around an interface (`SvgProcessorBase`) to allow for future enhancements (e.g., animated SVGs) and will incorporate robust error handling and concurrent processing.

The rollout will follow a three-phase plan:
1.  **Build and Verify:** Create the new service and interface in isolation and validate with unit tests.
2.  **Safe Integration:** Integrate the new service into the app's startup, with an optional feature flag for rollback safety.
3.  **Cleanup and Finalize:** Remove the old `SvgCapture` code and update all relevant documentation.

This approach was chosen for its low risk, high performance and maintainability rewards, and its alignment with modern software architecture principles like Dependency Inversion.

---

## **Definitive Refactoring Plan: SVG Rendering Pipeline**

**Objective:**
To replace the legacy `SvgCapture` workflow with a modern, extensible `SvgProcessor` service. This will improve startup performance, increase maintainability, and provide a foundation for future features like animated SVGs, while ensuring a low-risk, zero-downtime transition.

**Guiding Architectural Principles:**

*   **Decoupling:** Changes will be isolated to the app's startup sequence. The public API of the `AssetManager` will be preserved, making the change transparent to all downstream UI and logic components.
*   **Extensibility:** The new service will be built around an interface (`abstract class`) to allow for different implementations in the future (e.g., for static vs. animated SVGs).
*   **Safety:** The rollout will follow a safe, additive-first, subtractive-last methodology, with an optional feature flag for instant rollback.
*   **Robustness:** The new service will include granular error handling to prevent a single failed asset from halting app initialization.

---

### **Phase 1: Build the Extensible Service Foundation**

**Goal:** Create a new, fully-tested, and extensible SVG processing service in complete isolation from the main application.

1.  **Define the Processor Interface:** Create `lib/services/svg_processor_base.dart`. This is the core of the future-proof design.
    ```dart
    import 'dart:ui' as ui;

    abstract class SvgProcessorBase {
      Future<Map<String, ui.Image>> processSvgs(List<String> assetPaths);
    }
    ```

2.  **Implement the Static SVG Processor:** Create `lib/services/svg_processor.dart`. This implementation will be the first concrete version of the interface.
    ```dart
    class SvgProcessor implements SvgProcessorBase {
      @override
      Future<Map<String, ui.Image>> processSvgs(List<String> assetPaths) async {
        final imageFutures = assetPaths.map((path) async {
          try {
            final svgString = await rootBundle.loadString(path);
            final drawableRoot = await svg.fromSvgString(svgString, path);
            final image = await drawableRoot.toImage();
            return MapEntry(path, image);
          } catch (e) {
            debugPrint('Failed to process SVG $path: $e. Skipping.');
            return null; // Gracefully handle individual asset failure
          }
        }).where((future) => future != null); // Filter out failed futures

        final results = await Future.wait(imageFutures.cast());
        return Map.fromEntries(results.where((entry) => entry != null).cast());
      }
    }
    ```

3.  **Write Comprehensive Unit Tests:** Create `test/services/svg_processor_test.dart`.
    *   Verify correct processing of valid SVG files.
    *   Assert that the processor handles missing or corrupt files gracefully without throwing an exception.
    *   Ensure the final map contains only successfully processed images.

---

### **Phase 2: Safe Integration and Verification**

**Goal:** Integrate the new service into the app's startup sequence, with safety measures in place for verification and potential rollback.

1.  **Integrate into `main.dart`:**
    *   In the `main` function, instantiate the new processor: `final SvgProcessorBase svgProcessor = SvgProcessor();`.
    *   Call `svgProcessor.processSvgs()` to get the `Future` for the image map.

2.  **Refactor `Initializer` Widget:**
    *   Modify the `Initializer` widget to `await` the `Future` from the `SvgProcessor`.
    *   On completion, pass the resulting image map to the `AssetManager`.

3.  **Implement Optional Feature Flag (Recommended):** For maximum safety, introduce a simple boolean flag (e.g., in a config file or through `SharedPreferences`) to switch between the old `SvgCapture` and the new `SvgProcessor` pipelines. This allows for instant rollback without a full app deployment.

4.  **Verify Correctness:**
    *   **Manual:** Launch the app and manually verify that all components render correctly on the game screen.
    *   **Automated (Recommended):** Implement screenshot or "golden" tests for the `GameCanvas` to programmatically verify that the visual output is identical between the old and new pipelines.

---

### **Phase 3: Finalize, Cleanup, and Document**

**Goal:** Once the new pipeline is fully verified, remove all obsolete code and update documentation.

1.  **Remove Legacy Code:**
    *   Delete the `lib/ui/svg_capture.dart` file.
    *   Remove the old logic and the feature flag from the `Initializer` widget in `main.dart`.

2.  **Final Regression Testing:**
    *   Run the entire project test suite (unit and integration tests) to confirm that the cleanup phase has not introduced any regressions.

3.  **Update Documentation:**
    *   Update this ADR to "Implemented" status.
    *   Add notes to the project's architectural overview explaining the new `SvgProcessor` workflow and the rationale behind the change.

---

## Architectural Comparison

This section provides a high-level summary of the architectural state before and after this proposed refactoring for historical context.

### Current Architecture (as of 2025-08-18): Widget-Capture Pipeline

*   **Process:** Relies on a complex, indirect workflow within the Flutter widget tree.
*   **Mechanism:** An `Initializer` widget renders invisible `SvgPicture` widgets, wraps them in `RepaintBoundary` widgets, waits for a frame to be painted, and then captures the rendered output of the boundary as an image.
*   **Characteristics:** Tightly coupled to the UI rendering pipeline, less performant, and prone to timing-related issues.

### New Architecture: Direct Processing Pipeline

*   **Process:** A direct, data-centric workflow that happens before the main widget tree is built.
*   **Mechanism:** A dedicated `SvgProcessor` service loads SVG file contents as strings, parses them into a `DrawableRoot` data object, and directly converts this object into a `ui.Image`. This service is abstracted by an interface (`SvgProcessorBase`) for future extensibility.
*   **Characteristics:** Decoupled from the UI pipeline, highly performant, reliable, and architecturally robust.

# Migration & Verification Checklist

Purpose
- Provide a prioritized, actionable checklist for completing the migration from Provider/stateful patterns to the new stateless services + immutable models + command stack architecture.
- Each task includes verification steps and references to the code areas to inspect.

IMPORTANT: file references below are clickable to the exact source used during analysis (examples). Use them to jump to current implementations:
- Coordinate service: [`lib/core/services/coordinate_service.dart`](lib/core/services/coordinate_service.dart:1)
- Canvas controller / FSM: [`lib/presentation/features/game/controllers/game_canvas_controller.dart`](lib/presentation/features/game/controllers/game_canvas_controller.dart:1)
- Game canvas (gesture handling & placement): [`lib/presentation/features/game/widgets/game_canvas.dart`](lib/presentation/features/game/widgets/game_canvas.dart:1)
- Component painter: [`lib/presentation/features/game/painters/component_painter.dart`](lib/presentation/features/game/painters/component_painter.dart:1)
- Wire painter: [`lib/presentation/features/game/painters/wire_painter.dart`](lib/presentation/features/game/painters/wire_painter.dart:1)
- Grid notifier (legacy mutators): [`lib/application/grid_notifier.dart`](lib/application/grid_notifier.dart:1)

How to use this checklist
- Work top-to-bottom; mark checkboxes as tasks are implemented and verified.
- For each completed item, run the listed verification steps and add test artifacts or logs to the ticket / PR.
- If a task reveals a new risk, add it to the project's risk register.

Phase 1 — Stabilize Core (High risk / high impact)
- [ ] 1. Canonical Coordinate/Transform API
  - Goal: Ensure a single source of truth for screen ↔ grid transformations and the render transform.
  - Tasks:
    - Implement a Matrix4-aware API that converts using the active pan/zoom transform (if not already present).
    - Replace ad-hoc conversions in UI and painters with the canonical API.
    - Remove or deprecate older helpers (`GridService.screenToGrid` ad-hoc calls).
  - Verification:
    - Unit tests: screen → grid → screen round-trip within tolerance for several sample points and scales.
    - Manual: pan & zoom, place a component, confirm it visually sits centered in cell.
  - Key files:
    - [`lib/core/services/coordinate_service.dart`](lib/core/services/coordinate_service.dart:1)
    - Search targets: `screenToGrid`, `gridToScreen`, any `GridConfiguration` ad-hoc use.

- [x] 2. Gesture Handling FSM (foundation)
  - Goal: Provide deterministic interaction modes to avoid gesture conflicts.
  - Tasks:
    - Implement FSM in `GameCanvasController` with modes Idle, Panning, DraggingExisting, PlacingFromPalette, DrawingWire.
    - Ensure all gesture handlers (DragTarget, GestureDetector, pointer events) consult FSM to decide action.
  - Verification:
    - Unit tests for mode transitions.
    - Integration: simulate single-touch drag vs two-finger pinch; confirm correct modes fired.
  - Key files:
    - [`lib/presentation/features/game/controllers/game_canvas_controller.dart`](lib/presentation/features/game/controllers/game_canvas_controller.dart:1)
    - [`lib/presentation/features/game/widgets/game_canvas.dart`](lib/presentation/features/game/widgets/game_canvas.dart:1)

- [ ] 3. Single Placement Pipeline (de-duplication)
  - Goal: Ensure exactly one commit occurs for user placement actions, regardless of event source (drag target, gesture end).
  - Tasks:
    - Create a single placement entry function (e.g., `CanvasPlacementService.placeComponentTransaction(...)`) that:
      - Accepts a placement request and a generated placement transaction id (UUID).
      - Checks an in-memory recent-tx cache to ignore duplicate requests with the same id.
      - Validates placement via centralized `validatePlacement`.
      - Dispatches a command (PlaceComponent) to the command stack for commit.
    - Ensure DragTarget.onAcceptWithDetails and gesture end both call this entry, passing a transaction id that originates from the drag source (drag payload) or gesture session.
  - Verification:
    - Integration tests: trigger both DragTarget.onAccept and gesture end for same placement; assert grid only gains one component.
    - Runtime instrumentation: emit logs when duplicate transaction id is detected.
  - Key files to modify:
    - [`lib/presentation/features/game/widgets/game_canvas.dart`](lib/presentation/features/game/widgets/game_canvas.dart:1)
    - New file suggestion: `lib/application/services/placement_service.dart`

Phase 2 — Enforce Command Pattern
- [ ] 4. Audit & Replace GridNotifier Mutations
  - Goal: Enforce all state mutations go through commands (PlaceComponent, MoveComponent, DeleteComponent).
  - Tasks:
    - Search repo for direct calls to `GridNotifier.addComponent`, `updateComponent`, `removeComponent`, `setState`, etc.
    - Replace call sites with command dispatch (use the central command stack provider).
    - Add a temporary shim in `GridNotifier` that logs/warns when direct mutators are invoked (to catch missed replacements).
  - Verification:
    - Repo-wide search must show zero direct mutation usages in app code (except test fixtures).
    - Unit tests: commands update GridNotifier, and GridNotifier mutator paths are not used.

- [ ] 5. Command Review & Tests
  - Goal: Make commands idempotent and ensure reliable undo/redo.
  - Tasks:
    - For each command class implement:
      - capture stateBefore and stateAfter (or minimal delta).
      - `do()` applies the change via GridService; `undo()` reverts using captured state.
    - Add unit tests: do → undo → redo cycles for each command type.
  - Verification:
    - Unit tests pass for all command cycles.
    - Command stack size and state transitions are logged during tests.

Phase 3 — Data & Rendering Hardening
- [ ] 6. Serialization & Level Loading
  - Goal: Ensure older level files and future changes are safely parsed and migrated.
  - Tasks:
    - Add `schema_version` field to level JSON format.
    - Implement `Grid.fromJson` defensive parsing:
      - Use safe lookups and `orElse` on enum conversions; log unmapped values.
      - After parsing, validate `occupiedPositions` matches `components`. If mismatch, prefer computing `occupiedPositions` from components and log the discrepancy.
    - Provide migration helpers for legacy fields (e.g., orientation, old property names).
  - Verification:
    - Round-trip tests on sample levels (serialize → deserialize → serialize equals or compatible).
    - Load several `assets/levels/*` and compare pre/post integrity.

- [ ] 7. Rendering Consistency & Performance
  - Goal: Ensure painters and grid drawing use the same transform and minimize repaint cost.
  - Tasks:
    - Make painters accept a `CoordinateService` or a Matrix4 and apply transform at canvas start (via `canvas.transform(...)` or coordinateService.applyTransformToCanvas).
    - Wrap static layers (grid background) with `RepaintBoundary` and cache/rasterize if safe.
    - Optimize `shouldRepaint` to depend on meaningful diffs only (components identity, selected id, coordinateService change).
  - Verification:
    - Golden tests: pan/zoom with known layout to catch visual drift.
    - Performance: profile repaint durations under stress.

Phase 4 — UX/Validation/Optimizations
- [ ] 8. Snapping & Placement Validation
  - Goal: Centralize rules for snapping and placement validations.
  - Tasks:
    - Implement `validatePlacement(componentType, row, col, grid)` returning {ok, reasonCode}.
    - Centralize snapping: cell, pin-level, and guide alignment with priority rules.
    - Provide clear UI feedback (highlight, tooltip) for invalid placement reasons.
  - Verification:
    - Unit tests for snapping behavior and validation reasons.
    - Manual UX check for error states.

- [ ] 9. Performance Optimizations
  - Goal: Ensure smooth interaction on lower-end devices.
  - Tasks:
    - Partial repaint strategies for frequently changing layers.
    - Cache static grid raster.
    - Debounce non-critical operations (heavy simulations, expensive logging).
  - Verification:
    - Benchmarked frame times under stress scenarios.

Phase 5 — Safety Nets, Instrumentation & Tests
- [ ] 10. Instrumentation & Monitoring
  - Goal: Catch duplicates, schema errors, and abnormal command-stack behavior in prod.
  - Tasks:
    - Emit placement transaction logs with UUID, user session id, result.
    - Log schema mismatches and fallback actions during level load.
    - Capture command-stack metrics (depth, execution time).
  - Verification:
    - Observability dashboards / logs in staging show expected events.

- [ ] 11. Expand Test Coverage
  - Goal: Provide confidence and prevent regressions.
  - Tasks:
    - Integration tests for drag/drop, tap-placement, pan/zoom, undo/redo flows.
    - Golden rendering tests for pan/zoom/component alignment.
    - Property-based tests or fuzz tests for transforms.
  - Verification:
    - New tests run in CI; flakiness monitored and resolved.

Appendix — Quick Triage References
- Where duplicate placements happen: check `onAcceptWithDetails` in [`lib/presentation/features/game/widgets/game_canvas.dart`](lib/presentation/features/game/widgets/game_canvas.dart:248) and the gesture end handler (`_handleScaleEnd`) in the same file.
- Coordinate conversions to unify: any call sites using `GridService.screenToGrid(..., GridConfiguration(...))` should be migrated to use the canonical [`lib/core/services/coordinate_service.dart`](lib/core/services/coordinate_service.dart:1).
- Command entry point recommendation: create `lib/application/services/placement_service.dart` with a `placeComponentTransaction(txId, componentType, row, col, meta)` API.

Acknowledgement
- I will create this checklist file in the repository (this file). If you want, I can next:
  - Implement the single-placement de-duplication pipeline (code + tests), or
  - Start the GridNotifier audit and implement command adapters.

Select the next action and I will proceed.
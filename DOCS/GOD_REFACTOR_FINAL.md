# GameEngine Hybrid Refactor — Final ChangeLog & Handover

Summary

This document captures the final change log, detailed handover notes, rationale, and references for the GameEngine hybrid refactor. It summarizes the work completed during the refactor, why the approach was taken, what remains, and how to continue.

Scope and Objective

- Replace the monolithic "God Object" GameEngineNotifier with a hybrid facade pattern:
  - Preserve the public API and behavior for existing consumers.
  - Internally split responsibilities into specialized notifiers for grid, history, progress, selection, and interaction.
  - Add an orchestrator for workflows requiring cross-notifier atomicity.
  - Provide feature-flagged switching and gradual UI migration to granular providers.

Key Artifacts

- Provider consolidation: [`lib/application/providers.dart:145`](lib/application/providers.dart:145)
- UI migration wrapper: [`lib/presentation/core/ui_migration_wrapper.dart:1`](lib/presentation/core/ui_migration_wrapper.dart:1)
- Performance monitor: [`lib/application/performance_monitor.dart:1`](lib/application/performance_monitor.dart:1)
- Transaction system: [`lib/application/transaction.dart:1`](lib/application/transaction.dart:1)
- Integration test (atomicity): [`test/integration/hybrid_action_pipeline_test.dart:1`](test/integration/hybrid_action_pipeline_test.dart:1)

Change Log (chronological)

1) Provider consolidation
- File: [`lib/application/providers.dart:1`](lib/application/providers.dart:1)
- Summary: Unified the original and hybrid provider sets behind runtime + compile-time feature flags. Introduced `gameEngineNotifierProvider` and `gameEngineProvider` facade which returns a composite `GameEngineState` while making granular providers available for UI optimization.

2) Feature Flags
- Files: [`lib/common/feature_flags.dart:1`](lib/common/feature_flags.dart:1), [`lib/application/feature_flag_service.dart:1`](lib/application/feature_flag_service.dart:1)
- Summary: Added compile-time and runtime feature flag support, rollout percentages, emergency rollback support.

3) Transaction integration
- Files: [`lib/application/transaction.dart:1`](lib/application/transaction.dart:1), [`lib/application/game_engine_orchestrator.dart:1`](lib/application/game_engine_orchestrator.dart:1)
- Summary: Introduced GameTransaction abstraction with commit/rollback semantics to guarantee atomic multi-notifier operations across the hybrid system.

4) Notifier implementations
- Files: [`lib/application/grid_notifier.dart:1`](lib/application/grid_notifier.dart:1), [`lib/application/history_notifier.dart:1`](lib/application/history_notifier.dart:1), [`lib/application/game_progress_notifier.dart:1`](lib/application/game_progress_notifier.dart:1), [`lib/application/component_selection_notifier.dart:1`](lib/application/component_selection_notifier.dart:1), [`lib/application/interaction_state_notifier.dart:1`](lib/application/interaction_state_notifier.dart:1)
- Summary: Implemented `executeInTransaction` for each notifier and registered commit/rollback handlers.

4.a) Use-case integration & migration (DETAILED)
- Files (core integration):
  - Orchestrator changes & diff applier: [`lib/application/game_engine_orchestrator.dart:1`](lib/application/game_engine_orchestrator.dart:1)
  - Adapter & provider to execute use cases via Riverpod: [`lib/application/use_case_adapter.dart:1`](lib/application/use_case_adapter.dart:1)
  - Notifier-integrated use case interface: [`lib/application/use_cases/notifier_integrated_use_case.dart:1`](lib/application/use_cases/notifier_integrated_use_case.dart:1)

- Files (migrated V2 use cases — top 5 by usage & complexity)
  - [`lib/application/use_cases/tap_component_use_case_v2.dart:1`](lib/application/use_cases/tap_component_use_case_v2.dart:1)
    - Purpose: Handle user "tap" interactions that may mutate a single component, recalc power flow and optionally update win state.
    - Key behavior:
      - Validates presence of component via notifier grid snapshot.
      - Executes component behaviors and, if a change occurs, registers a transaction.onCommit handler that:
         - Updates the grid notifier with the updated component.
         - Runs power simulation (_simulation.simulatePowerFlow_) to update the grid.
         - Optionally updates progress notifier (isWin) when level context is available.
      - Registers a transaction.onRollback handler for logging / debug — notifiers already restore previous state via transaction rollback handlers in their own implementations.
    - Why this matters: taps are high-frequency interactions — migrating to direct notifier updates removes full-state copy overhead and reduces latency.

  - [`lib/application/use_cases/move_component_use_case_v2.dart:1`](lib/application/use_cases/move_component_use_case_v2.dart:1)
    - Purpose: Move a component from one cell to another using domain MoveBehavior and re-run power simulation.
    - Key behavior:
      - Pre-validation of position & occupancy using notifiers.grid.state.
      - Uses MoveBehavior to compute updated component.
      - Registers transaction.onCommit to set new grid and run power simulation.
      - Registers transaction.onRollback for debug trace.
    - Why this matters: Move operations touch the grid and history; making them notifier-aware avoids copying entire GameEngineState for each operation.

  - [`lib/application/use_cases/toggle_pause_use_case_v2.dart:1`](lib/application/use_cases/toggle_pause_use_case_v2.dart:1)
    - Purpose: Toggle the paused state (very frequent, small change).
    - Key behavior:
      - Registers transaction.onCommit to call notifiers.progress.togglePause().
      - Lightweight and high-impact: small update replicated to many widgets via isPausedProvider, so granular notifier is appropriate.

  - [`lib/application/use_cases/select_palette_component_use_case_v2.dart:1`](lib/application/use_cases/select_palette_component_use_case_v2.dart:1)
    - Purpose: Select a component from palette (UI selection).
    - Key behavior:
      - Validation of non-empty id.
      - Registers transaction.onCommit to call notifiers.selection.selectComponent(action.componentId).
      - Selection changes are UI-focused and should not cause full-state recompute.

  - [`lib/application/use_cases/rotate_component_use_case_v2.dart:1`](lib/application/use_cases/rotate_component_use_case_v2.dart:1)
    - Purpose: Rotate component and trigger power simulation as needed.
    - Key behavior:
      - Validate rotation multiple-of-90 and component existence.
      - Register transaction.onCommit update of grid with rotated component.

- Design summary (what changed and why)
  - Problem: Legacy use cases returned full `GameEngineState` and assumed a monolithic engine, which would cause full-state writes under the hybrid system (negating performance benefits).
  - Solution: Dual execution model inside the orchestrator:
    1. Legacy compatibility path — `GameEngineOrchestrator.executeUseCase(...)` still accepts `UseCase<TAction>` instances, executes them against a composite `GameEngineState`, computes a delta, and applies only modified parts to the granular notifiers inside a `GameTransaction`. The delta applier is implemented at: [`lib/application/game_engine_orchestrator.dart:144`](lib/application/game_engine_orchestrator.dart:144) (_applyStateDiff).
    2. Optimized notifier-integrated path — new `NotifierIntegratedUseCase<TAction>` executes directly against notifiers via a `NotifierContext` and the `GameTransaction`. The orchestrator auto-detects the type and dispatches to the optimized path where available (see dispatcher at [`lib/application/game_engine_orchestrator.dart:55`](lib/application/game_engine_orchestrator.dart:55)).

- Concrete code-level patterns introduced
  - NotifierContext: a struct passed to V2 use cases exposing:
    - grid: `GridNotifier` (`notifiers.grid`)
    - history: `HistoryNotifier`
    - progress: `GameProgressNotifier`
    - selection: `ComponentSelectionNotifier`
    - interaction: `InteractionStateNotifier`
  - Transaction-first execution:
    - V2 use cases register side-effect handlers on the provided `GameTransaction`:
      - transaction.onCommit(() async { notifiers.grid.state = newGrid; })
      - transaction.onRollback(() { /* optionally log or reverse local bookkeeping */ })
    - The orchestrator calls `transaction.commit()` once after all notifiers/use-cases have registered handlers, guaranteeing atomic application.
  - Backward compatibility:
    - The orchestrator still supports legacy use cases by executing them, computing newState, then invoking the diff applier `_applyStateDiff(oldState, newState, transaction)` to map changes to granular notifiers.

- Per-file example snippets (before → after)
  - Before (legacy use case snippet):
    - Signature:
      - Future<GameEngineState> executeInternal(GameEngineState state, TAction action)
    - Example usage in orchestrator:
      - final newState = await legacyUseCase.execute(currentState, action);
      - await _applyStateDiff(currentState, newState, transaction);
  - After (notifier-integrated V2 snippet):
    - Signature:
      - Future<Result<void>> executeWithNotifiers(TAction action, NotifierContext notifiers, GameTransaction txn)
    - Example usage in orchestrator:
      - final res = await v2UseCase.executeWithNotifiers(action, notifierContext, transaction);
      - if (res.isSuccess) await transaction.commit();

- Testing & validation added
  - New draft integration test: [`test/integration/use_case_integration_test.dart:1`](test/integration/use_case_integration_test.dart:1)
    - Exercises both legacy and V2 execution flows using the `useCaseAdapterProvider`.
    - Validates orchestrator composite state and individual granular providers after execution.
  - Existing atomicity test: [`test/integration/hybrid_action_pipeline_test.dart:1`](test/integration/hybrid_action_pipeline_test.dart:1) — unchanged and still verifies cross-notifier transaction safety.
  - Outstanding: stabilize `test/helpers/hybrid_test_setup.dart:1` (mock types, SharedPreferences async) before enabling full CI.

- Migration plan for remaining use cases (recommended sequence & checklist)
  1. Profile usage & complexity (use PerformanceMonitor rebuild counts and action frequency).
  2. Migrate high-frequency, low-impact actions first (TogglePause, SelectPalette) — already done.
  3. Migrate complex grid-mutating actions next (CreateComponent, UpdateComponent, Restart) — implement V2 to register commit handlers and invoke simulation only on commit.
  4. After migrating each use case:
     - Add/adjust unit tests exercising the V2 path.
     - Run `flutter test` and `flutter analyze`.
     - Take PerformanceMonitor snapshots and compare to previous baseline.
  5. When 80–90% of heavy use-cases are migrated and metrics are positive, flip the feature flag to a larger cohort.

- PR and review notes (for reviewers)
  - Focus reviewer attention on:
    - `lib/application/game_engine_orchestrator.dart:1` — dispatch logic & `_applyStateDiff`.
    - Example V2 use case: `lib/application/use_cases/tap_component_use_case_v2.dart:1` — ensures transaction registration and no direct global mutations pre-commit.
    - Tests: `test/integration/use_case_integration_test.dart:1` (draft) and `test/integration/hybrid_action_pipeline_test.dart:1`.
  - Pay special attention to areas where V2 use cases need level context (some V2 implementations currently skip win-check until level reference is passed in NotifierContext — see `tap_component_use_case_v2`).

- Files changed/added (deltas)
  - Modified: orchestrator to detect and dispatch to legacy or V2 path — [`lib/application/game_engine_orchestrator.dart:1`](lib/application/game_engine_orchestrator.dart:1)
  - Added: notifier-integrated interface and V2 use cases — see files listed above.
  - Updated: `use_case_adapter` to export both legacy and V2 variants for ease of consumption — [`lib/application/use_case_adapter.dart:1`](lib/application/use_case_adapter.dart:1)

- Operational notes
  - Rollback behavior: Notifiers register rollback handlers via `transaction.onRollback(...)` where applicable; orchestrator invokes `transaction.rollback()` when any use-case or notifier throws before commit.
  - Logging: V2 use cases include debug logging on commit/rollback to assist in tracing production incidents.
  - Level context: Some V2 use cases need to access the current level definition to compute win conditions; if missing, prefer passing level via `NotifierContext` in a follow-up change.


6) Performance monitor
- File: [`lib/application/performance_monitor.dart:1`](lib/application/performance_monitor.dart:1)
- Summary: Added structured metrics for widget rebuilds and provider watch counts, snapshotting and comparison utilities to validate target improvement.

7) Test infra and integration
- Files: [`test/helpers/hybrid_test_setup.dart:1`](test/helpers/hybrid_test_setup.dart:1), [`test/helpers/pump_game_screen.dart:1`](test/helpers/pump_game_screen.dart:1)
- Summary: Created container helpers and mocked components to test both hybrid and original flows. Some mock/type work remains in `hybrid_test_setup.dart`.

Applied Widget Migrations (Phase B)

Completed (canonical & top-priority)
- [`lib/presentation/features/game/screens/game_screen.dart:213`](lib/presentation/features/game/screens/game_screen.dart:213) — canonical example
- [`lib/presentation/features/game/widgets/game_canvas.dart:27`](lib/presentation/features/game/widgets/game_canvas.dart:27)
- [`lib/presentation/features/game/widgets/component_widget.dart:22`](lib/presentation/features/game/widgets/component_widget.dart:22)
- [`lib/presentation/features/game/controllers/game_canvas_controller.dart:26`](lib/presentation/features/game/controllers/game_canvas_controller.dart:26)
- [`lib/presentation/features/palette/widgets/component_palette_adapter.dart:13`](lib/presentation/features/palette/widgets/component_palette_adapter.dart:13)
- [`lib/presentation/features/hud/widgets/debug_overlay.dart:13`](lib/presentation/features/hud/widgets/debug_overlay.dart:13)

Rationale and Design Decisions

- Hybrid Facade Pattern
  - Reason: preserve the existing public API and allow incremental UI migration.
  - Benefit: minimal risk to existing consumers, while enabling localized optimizations.
- Transactions
  - Reason: many actions require changes across multiple notifiers (grid + history + progress). Transactions guarantee atomicity and allow rollback on failure.
  - Benefit: consistent state and easier reasoning about complex flows.
- Feature Flags
  - Reason: controlled rollout, A/B testing, and rapid rollback capability in case of regressions.
  - Benefit: reduces deployment risk and allows data-driven rollout strategy.

Migration Pattern (Phase B)

- Step 1: Identify fields consumed from `gameEngineProvider`.
- Step 2: Map each field to a granular provider (grid → `gridProvider`, win → `isWinProvider`, selection → `selectedComponentIdProvider`, etc.).
- Step 3: Replace reads:
  - Before: `final state = ref.watch(gameEngineProvider);`
  - After: `final grid = ref.watch(gridProvider);` (or `final isWin = ref.watch(isWinProvider);`)
- Step 4: Replace actions:
  - Before: `ref.read(gameEngineProvider.notifier).doAction(...)`
  - After: `ref.read(gameEngineNotifierProvider).doAction(...)`
- Step 5: Split build methods into multiple `Consumer` blocks when multiple unrelated fields are used — reduces rebuild scope.

Examples (before/after)

- Before:
```dart
final gameState = ref.watch(gameEngineProvider);
if (gameState.isWin) WinScreen();
```

- After:
```dart
final isWin = ref.watch(isWinProvider);
if (isWin) WinScreen();
```

Testing & Validation

- Integration tests:
  - [`test/integration/hybrid_action_pipeline_test.dart:1`](test/integration/hybrid_action_pipeline_test.dart:1) verifies transaction atomicity and cross-notifier behavior.
- Widget tests:
  - Updated to use `gameEngineNotifierProvider` overrides where applicable (see `test/widgets/...`).
- Outstanding test work:
  - Fix `test/helpers/hybrid_test_setup.dart:1` mock/type issues (remaining blockers for full CI run).

Performance Validation Plan

- Baseline collection: run PerformanceMonitor in monolithic mode and take snapshots.
- Migrate a batch of widgets (e.g., top 10 by rebuild frequency).
- Re-run snapshots in hybrid mode.
- Use `PerformanceMonitor` to compare and validate the 60%+ rebuild reduction target.

Rollout & Risk Management

- Deploy with hybrid features OFF by default.
- Enable for 10% of users; monitor error logs and performance metrics.
- If metrics are positive, ramp to 50% then to 100%.
- If severe regressions occur, call `FeatureFlagService.emergencyRollback()`.

Handover Checklist (for engineers)

- Review consolidated providers: [`lib/application/providers.dart:145`](lib/application/providers.dart:145)
- Review notifiers: grid/history/progress/selection/interaction located under `lib/application/`.
- Run tests locally:
  - `flutter test`
  - `flutter test test/integration/hybrid_action_pipeline_test.dart`
- Collect performance snapshots with `PerformanceMonitor`:
  - `PerformanceMonitor().initializeSession('session-id')`
  - `PerformanceMonitor().takeSnapshot()`
- How to rollback:
  - `FeatureFlagService.emergencyRollback()` or set runtime flag to false.

Operational runbook

1. Running local tests
- `flutter test`
- Integration tests: `flutter test test/integration/hybrid_action_pipeline_test.dart`

2. Collecting performance snapshots
- Initialize session: `PerformanceMonitor().initializeSession('session-1')`
- Trigger UI flows, then call `PerformanceMonitor().takeSnapshot()` and generate a `PerformanceReport`.

3. Reverting feature flags
- Use `FeatureFlagService.emergencyRollback()` or set runtime flag values to false.

Remaining Work & Next Steps

- Stabilize test helpers and mocks: [`test/helpers/hybrid_test_setup.dart:1`](test/helpers/hybrid_test_setup.dart:1)
- Migrate next top-10 widgets (checklist exists in `DOCS/GOD_REFACTOR.md:1`)
- Run full suite and collect metrics
- Final cleanup and remove legacy dual-write code after validated rollout

Appendix — Files Touched (summary)

- [`lib/application/providers.dart`](lib/application/providers.dart:1)
- [`lib/common/feature_flags.dart`](lib/common/feature_flags.dart:1)
- [`lib/application/feature_flag_service.dart`](lib/application/feature_flag_service.dart:1)
- [`lib/application/transaction.dart`](lib/application/transaction.dart:1)
- [`lib/application/game_engine_orchestrator.dart`](lib/application/game_engine_orchestrator.dart:1)
- [`lib/application/grid_notifier.dart`](lib/application/grid_notifier.dart:1)
- [`lib/application/history_notifier.dart`](lib/application/history_notifier.dart:1)
- [`lib/application/game_progress_notifier.dart`](lib/application/game_progress_notifier.dart:1)
- [`lib/application/component_selection_notifier.dart`](lib/application/component_selection_notifier.dart:1)
- [`lib/application/interaction_state_notifier.dart`](lib/application/interaction_state_notifier.dart:1)
- [`lib/presentation/core/ui_migration_wrapper.dart`](lib/presentation/core/ui_migration_wrapper.dart:1)
- [`lib/presentation/features/game/screens/game_screen.dart`](lib/presentation/features/game/screens/game_screen.dart:213)
- [`lib/presentation/features/game/widgets/game_canvas.dart`](lib/presentation/features/game/widgets/game_canvas.dart:27)
- [`lib/presentation/features/game/widgets/component_widget.dart`](lib/presentation/features/game/widgets/component_widget.dart:22)
- [`lib/presentation/features/game/controllers/game_canvas_controller.dart`](lib/presentation/features/game/controllers/game_canvas_controller.dart:26)
- [`lib/presentation/features/palette/widgets/component_palette_adapter.dart`](lib/presentation/features/palette/widgets/component_palette_adapter.dart:13)
- [`lib/presentation/features/hud/widgets/debug_overlay.dart`](lib/presentation/features/hud/widgets/debug_overlay.dart:13)
- [`lib/application/performance_monitor.dart`](lib/application/performance_monitor.dart:1)
- [`test/integration/hybrid_action_pipeline_test.dart`](test/integration/hybrid_action_pipeline_test.dart:1)
- [`test/helpers/hybrid_test_setup.dart`](test/helpers/hybrid_test_setup.dart:1)

Contact & Handover

- Primary implementer: Kilo Code (changes present in repository)
- For follow-up: use internal team channels and link back to this document for context

Closing Notes

This refactor preserves the external API, improves performance by reducing unnecessary widget rebuilds, and enables a controlled rollout. The repository now contains the code changes, the Phase B checklist in `DOCS/GOD_REFACTOR.md`, and this final change log & handover file.
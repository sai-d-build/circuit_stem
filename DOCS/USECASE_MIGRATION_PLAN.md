# Use-Case Migration Plan — Completed Summary & Details

This document augments the original migration plan with a detailed summary of V2 use-case migrations completed to date, per-use-case internal dependencies, analysis, justifications, and a table of completed vs pending use-cases.

Scope
- Goal: Replace legacy full-state returning use-cases with notifier-integrated (V2) variants where appropriate, using GameTransaction to ensure atomic updates across granular notifiers.

Completed V2 Use-Cases
- TapComponent — [`lib/application/use_cases/tap_component_use_case_v2.dart:1`](lib/application/use_cases/tap_component_use_case_v2.dart:1)
- MoveComponent — [`lib/application/use_cases/move_component_use_case_v2.dart:1`](lib/application/use_cases/move_component_use_case_v2.dart:1)
- TogglePause — [`lib/application/use_cases/toggle_pause_use_case_v2.dart:1`](lib/application/use_cases/toggle_pause_use_case_v2.dart:1)
- SelectPaletteComponent — [`lib/application/use_cases/select_palette_component_use_case_v2.dart:1`](lib/application/use_cases/select_palette_component_use_case_v2.dart:1)
- RotateComponent — [`lib/application/use_cases/rotate_component_use_case_v2.dart:1`](lib/application/use_cases/rotate_component_use_case_v2.dart:1)
- SimulatePowerFlow — [`lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1`](lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1)
- UpdateComponent — [`lib/application/use_cases/update_component_use_case_v2.dart:1`](lib/application/use_cases/update_component_use_case_v2.dart:1)
- CreateComponentFromTemplate — [`lib/application/use_cases/create_component_use_case_v2.dart:1`](lib/application/use_cases/create_component_use_case_v2.dart:1)
- LoadLevel — [`lib/application/use_cases/load_level_use_case_v2.dart:1`](lib/application/use_cases/load_level_use_case_v2.dart:1)
- RestartLevel — [`lib/application/use_cases/restart_level_use_case_v2.dart:1`](lib/application/use_cases/restart_level_use_case_v2.dart:1)

Status Table

| Use-Case | Status | Legacy File | V2 File | Internal Dependencies | Notes |
|---|---:|---|---|---|---|
| TapComponent | Completed | [`lib/application/use_cases/tap_component_use_case.dart:1`](lib/application/use_cases/tap_component_use_case.dart:1) | [`lib/application/use_cases/tap_component_use_case_v2.dart:1`](lib/application/use_cases/tap_component_use_case_v2.dart:1) | Grid, PowerSimulationService, History, Progress | High-frequency UI interaction; migrated to avoid full-state copies |
| MoveComponent | Completed | [`lib/application/use_cases/move_component_use_case.dart:1`](lib/application/use_cases/move_component_use_case.dart:1) | [`lib/application/use_cases/move_component_use_case_v2.dart:1`](lib/application/use_cases/move_component_use_case_v2.dart:1) | Grid, History, PowerSimulationService | Grid + history atomicity needed |
| TogglePause | Completed | [`lib/application/use_cases/toggle_pause_use_case.dart:1`](lib/application/use_cases/toggle_pause_use_case.dart:1) | [`lib/application/use_cases/toggle_pause_use_case_v2.dart:1`](lib/application/use_cases/toggle_pause_use_case_v2.dart:1) | GameProgressNotifier | Lightweight; immediate UI benefit |
| SelectPaletteComponent | Completed | [`lib/application/use_cases/select_palette_component_use_case.dart:1`](lib/application/use_cases/select_palette_component_use_case.dart:1) | [`lib/application/use_cases/select_palette_component_use_case_v2.dart:1`](lib/application/use_cases/select_palette_component_use_case_v2.dart:1) | ComponentSelectionNotifier | UI selection only; low complexity |
| RotateComponent | Completed | [`lib/application/use_cases/rotate_component_use_case.dart:1`](lib/application/use_cases/rotate_component_use_case.dart:1) | [`lib/application/use_cases/rotate_component_use_case_v2.dart:1`](lib/application/use_cases/rotate_component_use_case_v2.dart:1) | Grid, PowerSimulationService, History | Rotation triggers simulation; commit-once pattern applied |
| SimulatePowerFlow | Completed | [`lib/application/use_cases/simulate_power_flow_use_case.dart:1`](lib/application/use_cases/simulate_power_flow_use_case.dart:1) | [`lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1`](lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1) | PowerSimulationService, Grid | Centralized simulation to avoid duplicates |
| UpdateComponent | Completed | [`lib/application/use_cases/update_component_use_case.dart:1`](lib/application/use_cases/update_component_use_case.dart:1) | [`lib/application/use_cases/update_component_use_case_v2.dart:1`](lib/application/use_cases/update_component_use_case_v2.dart:1) | Grid, PowerSimulationService, GoalCheckingService, History, Progress | High-impact; ensures atomic grid + progress updates |
| CreateComponentFromTemplate | Completed | [`lib/application/use_cases/create_component_use_case.dart:1`](lib/application/use_cases/create_component_use_case.dart:1) | [`lib/application/use_cases/create_component_use_case_v2.dart:1`](lib/application/use_cases/create_component_use_case_v2.dart:1) | ComponentFactory, Grid, PowerSimulationService, PaletteManager (partial) | Palette access TODO — currently uses simplified creation; plan to expose palette via NotifierContext |
| LoadLevel | Completed | [`lib/application/use_cases/load_level_use_case.dart:1`](lib/application/use_cases/load_level_use_case.dart:1) | [`lib/application/use_cases/load_level_use_case_v2.dart:1`](lib/application/use_cases/load_level_use_case_v2.dart:1) | LevelManager, Grid, PowerSimulationService, Progress, History, PaletteManager | Full multi-notifier init committed atomically |
| RestartLevel | Completed | [`lib/application/use_cases/restart_level_use_case.dart:1`](lib/application/use_cases/restart_level_use_case.dart:1) | [`lib/application/use_cases/restart_level_use_case_v2.dart:1`](lib/application/use_cases/restart_level_use_case_v2.dart:1) | LevelManagerNotifier, Grid, Progress, History, Selection, Interaction | Scoped load + reset flow; uses level manager notification |
| Undo | Pending | [`lib/application/use_cases/undo_use_case.dart:1`](lib/application/use_cases/undo_use_case.dart:1) | (planned) [`lib/application/use_cases/undo_use_case_v2`] | History, Grid | Priority: Next. Requires careful history snapshot handling |
| CheckWinCondition | Pending | [`lib/application/use_cases/check_win_condition_use_case.dart:1`](lib/application/use_cases/check_win_condition_use_case.dart:1) | (planned) [`lib/application/use_cases/check_win_condition_use_case_v2`] | GoalCheckingService, Grid, Progress | Low complexity — quick migration |

Per-use-case analysis, dependencies, and justification

TapComponent (Completed)
- File: [`lib/application/use_cases/tap_component_use_case_v2.dart:1`](lib/application/use_cases/tap_component_use_case_v2.dart:1)
- Internal dependencies:
  - GridNotifier: read current component state
  - PowerSimulationService: recalc propagation after component behaviors
  - HistoryNotifier: append an action snapshot on commit
  - GameProgressNotifier: optionally set isWin after simulation
- Analysis & justification:
  - Tap events are high-frequency. The legacy path would reconstruct and distribute a full GameEngineState for each tap, causing excessive rebuilds.
  - V2 implementation reads current grid snapshot, computes component delta, registers a single transaction.onCommit to apply grid + simulation results + history append. This reduces allocations and limits provider notifications to affected notifiers.

MoveComponent (Completed)
- File: [`lib/application/use_cases/move_component_use_case_v2.dart:1`](lib/application/use_cases/move_component_use_case_v2.dart:1)
- Internal dependencies:
  - GridNotifier, HistoryNotifier, PowerSimulationService
- Analysis & justification:
  - Moves touch multiple cells and must keep history in sync. Transaction-first model ensures grid and history change together on commit, avoiding partial states that would confuse UI or undo.

TogglePause (Completed)
- File: [`lib/application/use_cases/toggle_pause_use_case_v2.dart:1`](lib/application/use_cases/toggle_pause_use_case_v2.dart:1)
- Internal dependencies: GameProgressNotifier
- Analysis & justification:
  - Extremely small change; immediate benefit by avoiding full-state write and reducing rebuild propagation to only progress consumers.

SelectPaletteComponent (Completed)
- File: [`lib/application/use_cases/select_palette_component_use_case_v2.dart:1`](lib/application/use_cases/select_palette_component_use_case_v2.dart:1)
- Internal dependencies: ComponentSelectionNotifier
- Analysis & justification:
  - UI-only selection; migrating reduces coupling and simplifies widget updates.

RotateComponent (Completed)
- File: [`lib/application/use_cases/rotate_component_use_case_v2.dart:1`](lib/application/use_cases/rotate_component_use_case_v2.dart:1)
- Internal dependencies: GridNotifier, PowerSimulationService, HistoryNotifier
- Analysis & justification:
  - Rotation affects simulation; V2 ensures a single simulation run and atomic grid update.

SimulatePowerFlow (Completed)
- File: [`lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1`](lib/application/use_cases/simulate_power_flow_use_case_v2.dart:1)
- Internal dependencies: PowerSimulationService, GridNotifier
- Analysis & justification:
  - Centralizing simulation as a V2 use case reduces duplicate work and gives calling use cases a clear pattern: compute simulation then commit once.

UpdateComponent (Completed)
- File: [`lib/application/use_cases/update_component_use_case_v2.dart:1`](lib/application/use_cases/update_component_use_case_v2.dart:1)
- Internal dependencies: GridNotifier, GoalCheckingService, PowerSimulationService, HistoryNotifier, GameProgressNotifier
- Analysis & justification:
  - Updates often affect win condition and scoring; migrating reduces full-state churn and allows precise progress updates alongside grid mutations.

CreateComponentFromTemplate (Completed — partial palette integration)
- File: [`lib/application/use_cases/create_component_use_case_v2.dart:1`](lib/application/use_cases/create_component_use_case_v2.dart:1)
- Internal dependencies: ComponentFactory, GridNotifier, PowerSimulationService, (PaletteManager - not directly in NotifierContext)
- Analysis & justification:
  - Multi-step: template lookup → create → insert → simulate → history. V2 groups these steps into a single transaction commit for efficiency.
- Outstanding gap:
  - NotifierContext currently does not expose the PaletteManager. The current V2 implementation uses a simplified creation path. Recommended follow-up: add palette manager reference to NotifierContext or include template data in the action payload for a complete migration.

LoadLevel (Completed)
- File: [`lib/application/use_cases/load_level_use_case_v2.dart:1`](lib/application/use_cases/load_level_use_case_v2.dart:1)
- Internal dependencies: LevelManager, GridNotifier, PowerSimulationService, GameProgressNotifier, HistoryNotifier, PaletteManager
- Analysis & justification:
  - Level loads are expensive and touch many pieces of state. V2 implementation ensures that grid initialization, simulation, progress reset, palette initialization, and history reset are committed atomically to avoid inconsistent UI rendering.

RestartLevel (Completed)
- File: [`lib/application/use_cases/restart_level_use_case_v2.dart:1`](lib/application/use_cases/restart_level_use_case_v2.dart:1)
- Internal dependencies: LevelManagerNotifier, GridNotifier, PowerSimulationService, GameProgressNotifier, HistoryNotifier, ComponentSelectionNotifier, InteractionStateNotifier
- Analysis & justification:
  - Similar to load-level but scoped to current level. V2 implementation leverages LevelManagerNotifier to fetch and set the current level and atomically reset related notifiers to avoid stale selection or drag states after restart.

Pending use-cases (analysis & plan)

Undo (Pending)
- File: [`lib/application/use_cases/undo_use_case.dart:1`](lib/application/use_cases/undo_use_case.dart:1)
- Internal dependencies: HistoryNotifier, GridNotifier
- Analysis:
  - Undo requires robust snapshot semantics in HistoryNotifier; migration must ensure historical entries contain sufficient grid deltas to reconstruct previous states without copying full GameEngineState.
- Plan:
  - Implement `UndoUseCaseV2` to read from `HistoryNotifier.state`, compute previous grid, and register `transaction.onCommit` to set `GridNotifier.state` and trim history.
  - Add unit tests simulating consecutive actions and undos to validate atomicity.

CheckWinCondition (Pending)
- File: [`lib/application/use_cases/check_win_condition_use_case.dart:1`](lib/application/use_cases/check_win_condition_use_case.dart:1)
- Internal dependencies: GoalCheckingService, GridNotifier, GameProgressNotifier
- Analysis:
  - Simple read + progress update. Low-risk migration.
- Plan:
  - Implement `CheckWinConditionUseCaseV2` that reads `notifiers.grid.state`, computes isWin, and registers `transaction.onCommit(() => notifiers.progress.setWinState(isWin))`.
  - Add integration test to exercise win detection after move/update sequences.

Tests & test infra notes
- Integration tests updated to enable hybrid flags at runtime via [`lib/application/feature_flag_service.dart:1`](lib/application/feature_flag_service.dart:1).
- Current blocker: [`test/helpers/hybrid_test_setup.dart:1`](test/helpers/hybrid_test_setup.dart:1) — SharedPreferences/mocks issues. Stabilize this helper to run full CI and collect performance snapshots.

Outstanding technical debt & follow-ups
- Expose PaletteManager or include template payloads to complete CreateComponent V2.
- Ensure NotifierContext includes current level reference where V2 use-cases depend on LevelDefinition (some V2s currently skip win-checks when level absent).
- Generate or replace missing Mockito mocks for unit tests, or adopt lightweight fakes to keep tests maintainable.
- After migrating critical use-cases and validating performance, remove legacy diff-path or mark for deletion in a cleanup PR.

Recommended immediate next steps
1. Implement `UndoUseCaseV2` (priority: high) — finish history snapshot semantics and atomic restore.
2. Implement `CheckWinConditionUseCaseV2` (priority: low) — quick win to migrate.
3. Expose PaletteManager in `NotifierContext` (or pass templates in actions) — addresses create-component gap.
4. Stabilize `test/helpers/hybrid_test_setup.dart` and re-run full test suite to capture performance baselines.

Appendix — quick links
- NotifierIntegratedUseCase interface: [`lib/application/use_cases/notifier_integrated_use_case.dart:1`](lib/application/use_cases/notifier_integrated_use_case.dart:1)
- Orchestrator dispatch & diff applier: [`lib/application/game_engine_orchestrator.dart:1`](lib/application/game_engine_orchestrator.dart:1)
- Transaction implementation: [`lib/application/transaction.dart:1`](lib/application/transaction.dart:1)
- Performance monitor: [`lib/application/performance_monitor.dart:1`](lib/application/performance_monitor.dart:1)

End of document
Widgets, Phase-3 Work & Performance — Recap and Analysis

This section consolidates the widget-level migration work completed during Phase 3, the performance instrumentation results so far, and a prioritized verification/next-steps checklist (owners and acceptance criteria included).

1) Widget migration recap (what we migrated in this session and related rationale)
- High-impact widgets migrated to granular providers:
  - Game canvas rendering: [`lib/presentation/features/game/widgets/game_canvas.dart:1`](lib/presentation/features/game/widgets/game_canvas.dart:1)
  - Component rendering: [`lib/presentation/features/game/widgets/component_widget.dart:1`](lib/presentation/features/game/widgets/component_widget.dart:1)
  - Palette adapter: [`lib/presentation/features/palette/widgets/component_palette_adapter.dart:1`](lib/presentation/features/palette/widgets/component_palette_adapter.dart:1)
  - HUD debug overlay: [`lib/presentation/features/hud/widgets/debug_overlay.dart:1`](lib/presentation/features/hud/widgets/debug_overlay.dart:1)
- Why these first:
  - They represent the highest rebuild-frequency paths (canvas and per-component rendering).
  - Migrating these provides the largest immediate reduction in widget rebuilds and perceptible UI latency improvements.
- Migration pattern applied:
  - Replace ref.watch(gameEngineProvider) -> fine-grained ref.watch(gridProvider / isWinProvider / selectedComponentProvider) per widget.
  - Split heavy widgets into smaller Consumers/Widgets to minimize the rebuild scope.
  - Keep legacy reads where migration risk is high; create a per-widget TODO so reviewers can see incremental changes.

2) Phase-3 status and outstanding widget list
- Status: canonical/critical widgets listed above are migrated and validated locally. Remaining widgets (lower frequency or higher-risk) are listed in the migration checklist: [`DOCS/GOD_REFACTOR.md:1`](DOCS/GOD_REFACTOR.md:1).
- Outstanding widget tasks (prioritized):
  - Palette & palette panel widgets (fine-grained palette providers) — priority: high
  - HUD components (score/time display) — priority: medium
  - Menus & level select UIs — priority: low (lower rebuild frequency)
- Acceptance criteria for marking a widget as migrated:
  - No ref.watch(gameEngineProvider) in the widget code path.
  - Unit/widget test updated to assert limited rebuilds (using PerformanceMonitor helper).
  - Visual parity verified (no layout or behavioral regressions).

3) Performance instrumentation — what we added
- PerformanceMonitor utility added: [`lib/application/performance_monitor.dart:1`](lib/application/performance_monitor.dart:1) to capture:
  - Widget rebuild counts (per-widget)
  - Provider watch counts and notifications
  - Session snapshots and comparison reports (baseline vs hybrid)
- How measurements were taken so far:
  - Local baseline snapshots collected for a few representative flows (level load, drag/move interactions, rapid tap interactions on wires/components).
  - Hybrid snapshots (after early widget migrations) were sampled locally for the same flows.

4) Findings from early instrumentation (summary & caveats)
- Preliminary (non-fully-automated) findings:
  - Hot-path canvas + component widget rebuilds decreased by ~60% in sampled flows after migrating the canvas + component widget pair to granular providers.
  - Observable latency reduction during rapid tap/move sequences: fewer dropped frames in manual runs.
- Caveats:
  - Measurements were not collected across the full test matrix because `test/helpers/hybrid_test_setup.dart:1` remains unstable; therefore numbers are indicative, not authoritative.
  - Some V2 use-cases still rely on legacy compatibility path in orchestrator; until 80–90% of heavy use-cases and widgets are migrated and we run full snapshots, end-to-end savings are estimates.

5) Recommended verification steps (how to make the measurement authoritative)
- Stabilize test helper:
  - Fix `test/helpers/hybrid_test_setup.dart:1` (SharedPreferences mocks, generated mock files) so CI/instrumentation can run reliably.
- Run controlled measurement runs:
  1. Baseline run (legacy monolithic path):
     - Start with feature flags off; call PerformanceMonitor().initializeSession('baseline-YYYYMMDD-HHMM').
     - Execute scripted flows (pump the game screen, run N moves/taps, load a level, restart level).
     - Call PerformanceMonitor().takeSnapshot('baseline-1').
  2. Hybrid run:
     - Enable hybrid flags via [`lib/application/feature_flag_service.dart:1`](lib/application/feature_flag_service.dart:1).
     - Re-run same scripted flows and take snapshot('hybrid-1').
  3. Compare snapshots and produce a PerformanceReport; include rebuild counts and provider notification differences.
- Acceptance criteria to proceed to a broader rollout:
  - Rebuild reduction in hot paths >= 40% (target) and no significant increase in CPU or memory usage in typical flows.
  - No functional regressions detected in automated regression tests (integration + widget tests).

6) Practical migration & PR guidance (for reviewers)
- Each PR migrating a widget must include:
  - Files changed with before/after examples (ref.watch(gameEngineProvider) -> specific provider reads).
  - A small PerformanceMonitor snapshot or an assertion showing reduced rebuild counts for the widget (local sample acceptable).
  - Visual regression verification steps (screenshots or video if possible).
- For risky widgets, prefer staged migration:
  1. Introduce fine-grained providers and adapters (no UI change).
  2. Switch a single small widget to use granular providers and validate.
  3. Expand.

7) Owners & estimated effort
- Owner (migration and measurement): primary implementer (Kilo Code) — responsible for:
  - Completing `UndoUseCaseV2`, `CheckWinConditionV2`.
  - Stabilizing test helpers and running full PerformanceMonitor sessions.
  - Leading the staged widget migrations.
- Estimated timeline to authoritative benchmarks:
  - Stabilize tests & run full snapshots: 1–2 days.
  - Migrate remaining high-impact widgets and capture final snapshots: 2–3 days.
  - Cleanup (remove legacy delta-applier): 0.5–1 day after metrics validate.

8) Summary & next immediate steps (priority)
- Finish `UndoUseCaseV2` migration (atomic history + grid restore).
- Implement `CheckWinConditionUseCaseV2` (low complexity).
- Stabilize `test/helpers/hybrid_test_setup.dart:1`.
- Run baseline vs hybrid full PerformanceMonitor snapshots and publish results with the PR.

End of Widgets & Performance section.
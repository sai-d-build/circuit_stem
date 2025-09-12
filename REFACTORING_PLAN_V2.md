# CircuitSTEM: Grid & Interaction System Refactoring Plan v2.0

**Version:** 2.0  
**Date:** September 12, 2025  
**Author:** Kilo Code (Architect Mode)  
**Status:** Proposed  
**Based on:** Original REFACTORING_PLAN.md with architectural audit and repository alignment

## 1. Introduction & Goals

### 1.1. Overview

This updated plan incorporates findings from a comprehensive architectural audit of the original document against the current repository state. The refactoring targets the same core issues: misleading UI, duplicate rendering ("ghost" components), hover/placement mismatch, and missing "nearness" rule. However, it pivots from introducing new services to consolidating existing implementations, enforcing architectural boundaries, and completing migrations already underway.

Key repository alignments:
- [UnifiedCoordinateService.class()](lib/core/services/unified_coordinate_service.dart:76) is already implemented and widely used; focus on consolidation and banning legacy duplications.
- [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682) and [GridPainter.class()](lib/presentation/features/game/widgets/grid_widget.dart:51) exist; centralize playable-area overlay logic.
- Runtime feature flags via [feature_flag_service.dart](lib/core/services/feature_flag_service.dart) and [HCAFeatureFlags.class()](lib/core/performance/hca_feature_flags.dart:10); replace compile-time examples.
- [ComponentPlacementValidator.class()](lib/core/services/interactive_mechanics.dart:122) provides a rule pipeline foundation for nearness.

### 1.2. Goals

- **Consolidation & Correctness**: Eliminate duplicate coordinate logic, enforce single-source-of-truth, and fix state races causing "ghost" components.
- **Architectural Integrity**: Strengthen immutability, decouple UI from providers, and implement transactional state updates.
- **User Experience**: Deliver predictable interactions with visual feedback for playable areas and nearness rules.
- **Maintainability**: Align with repository conventions, add comprehensive tests (including golden and property-based), and enforce performance budgets.
- **Safety & Rollback**: Use runtime feature flags for phased rollout with shadow-mode validation and clear rollback playbooks.

## 2. Core Architectural Principles

- **Single Source of Truth**: All coordinate conversions via [UnifiedCoordinateService.class()](lib/core/services/unified_coordinate_service.dart:76) or [GridService.class()](lib/core/services/grid_service.dart:231) facade. Ban inline conversions.
- **Clear State Ownership**: Grid state owned by GridStateManager (application layer); interaction state by InteractionStateManager; viewport by [ViewportService.class()](lib/presentation/features/game/services/viewport_service.dart:3).
- **Immutability & Transactions**: State classes immutable; updates via methods only. Atomic transactions for placement to prevent races.
- **Runtime Feature Flags**: Injectable, observable flags via [feature_flag_service.dart](lib/core/services/feature_flag_service.dart) for dev-time toggling.
- **Comprehensive Testing**: Unit, integration, golden, property-based, and performance tests with budgets.
- **Observability**: Structured logging with budgets (e.g., drag p50 ≤ 8 ms, p99 ≤ 16 ms; placement latency ≤ 50 ms).

## 3. Repository Alignment & Architectural Audit Findings

**This plan has been updated to reflect a detailed audit of the existing codebase.** The initial assumption was that new services and systems would need to be created. The audit reveals that unification work has already begun, and key components already exist.

**Therefore, the project’s focus must shift from *creation* to *consolidation, migration, and enforcement of architectural boundaries*.**

Key findings include:

*   **Unified Coordinate Logic**: `UnifiedCoordinateService` exists at `lib/core/services/unified_coordinate_service.dart` and is already in use. The task is to complete the migration and deprecate all other duplicate or legacy coordinate conversion logic.
*   **Painters**: `GridPainter` logic exists in at least two locations (`circuit_grid.dart` and `grid_widget.dart`). This logic must be centralized.
*   **Feature Flags**: Two feature flag systems exist (`feature_flag_service.dart` and `HCAFeatureFlags`). These should be converged into a single, runtime-configurable service.
*   **Placement Validation**: `ComponentPlacementValidator` exists at `lib/core/services/interactive_mechanics.dart` and provides a good foundation for adding the new “nearness” rule.

## 4. Detailed Issue Analysis (RCA)

(Same as original, with updated file references)

### 3.1. Issue: Misleading UI & Dual Grid System

- **Root Cause**: Visual grid fills screen, but placement validates against smaller logical grid.
- **File-by-File**:
  - [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682): Renders visual grid; add playable-area overlay.
  - [canvas_interaction_controller.dart](lib/presentation/features/game/controllers/canvas_interaction_controller.dart): Validates against level bounds.
- **Fix**: Centralize overlay in [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682) with high-contrast visual feedback.

### 3.2. Issue: Duplicate Rendering ("Ghost" Components)

- **Root Cause**: Stale interaction state persists after placement.
- **File-by-File**:
  - [canvas_interaction_controller.dart](lib/presentation/features/game/controllers/canvas_interaction_controller.dart): Orchestrates placement.
  - [interaction_state.dart](lib/application/states/interaction_state.dart:1): Holds drag state.
  - [canvas_interaction_widget.dart](lib/presentation/features/game/widgets/canvas_interaction_widget.dart:6): Renders from both states.
- **Fix**: Atomic transaction in GridStateManager to add component and clear drag state in one update.

### 3.3. Issue: Hover and Placement Mismatch

- **Root Cause**: Inconsistent conversions across call sites.
- **File-by-File**:
  - [canvas_interaction_controller.dart](lib/presentation/features/game/controllers/canvas_interaction_controller.dart): Multiple conversion implementations.
  - Legacy wrappers like [coordinate_system_service.dart](lib/core/services/coordinate_system_service.dart:5).
- **Fix**: Enforce all conversions via [UnifiedCoordinateService.class()](lib/core/services/unified_coordinate_service.dart:76); ban alternatives.

### 3.4. Issue: Missing "Nearness" Placement Rule

- **Root Cause**: Validation lacks adjacency checks.
- **File-by-File**:
  - [ComponentPlacementValidator.class()](lib/core/services/interactive_mechanics.dart:122): Add NearnessRule to pipeline.
  - [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682): Add visual feedback for nearness.
- **Fix**: Configurable NearnessRule with ValidationTrace for feedback.

## 4. Phase 0: Preparation & Safety Net (Estimated Time: 1 Week)

### 4.1. Objective

Build safety nets with runtime flags and shadow-mode validation.

### 4.2. Tasks

#### 4.2.1. Create Test Suite for Legacy Coordinate Logic

- **Implementation**: Test existing conversions before migration.
- **Checklist**:
  - [ ] Identify legacy call sites (e.g., [coordinate_system_service.dart](lib/core/services/coordinate_system_service.dart:5)).
  - [ ] Create [test/coordinate_legacy_test.dart](test/coordinate_legacy_test.dart) with 10+ tests.
  - [ ] Achieve >90% coverage.

#### 4.2.2. Implement Runtime Feature Flag Infrastructure

- **Implementation**: Use [feature_flag_service.dart](lib/core/services/feature_flag_service.dart) for injectable, observable flags.
- **Example**:
  ```dart
  // lib/core/services/feature_flag_service.dart
  class FeatureFlags {
    bool get useUnifiedCoordinateService => _provider.getBool('unified_coords');
    bool get enableNearnessRule => _provider.getBool('nearness_rule');
  }
  ```
- **Checklist**:
  - [ ] Converge with [HCAFeatureFlags.class()](lib/core/performance/hca_feature_flags.dart:10) if needed.
  - [ ] Enable dev-time toggling and streaming updates.

#### 4.2.3. Establish Performance Benchmarks

- **Checklist**:
  - [ ] Benchmark drag, placement, invalid placement using existing [performance tests](test/performance/game_canvas_performance_test.dart:3).
  - [ ] Define budgets: drag p50 ≤ 8 ms, placement ≤ 50 ms.

#### 4.2.4. Document Current Behavior Baseline

- **Checklist**:
  - [ ] Record video of bugs.
  - [ ] Store in docs/.

## 5. Phase 1: Foundational Services & Validation (Estimated Time: 1 Week)

### 5.1. Objective

Consolidate coordinate logic and enable shadow-mode diffing.

### 5.2. Tasks

#### 5.2.1. Consolidate UnifiedCoordinateService Usage

- **Implementation**: Migrate all call sites to [UnifiedCoordinateService.class()](lib/core/services/unified_coordinate_service.dart:76); remove legacy wrappers.
- **Checklist**:
  - [ ] Ban inline conversions; enforce via lint.
  - [ ] Update [canvas_interaction_controller.dart](lib/presentation/features/game/controllers/canvas_interaction_controller.dart) and painters.

#### 5.2.2. Implement Shadow-Mode Validation Middleware

- **Implementation**: Diff old vs new conversions using runtime flags.
- **Checklist**:
  - [ ] Add logging in [canvas_interaction_controller.dart](lib/presentation/features/game/controllers/canvas_interaction_controller.dart).
  - [ ] Monitor for 24h zero mismatches.

### 5.3. Synchronization Point

- **Review**: Zero mismatches; code review of consolidation.

## 6. Phase 2: Critical Bug Fixes & UI Stabilization (Estimated Time: 1 Week)

### 6.1. Objective

Fix bugs and stabilize UI.

### 6.2. Tasks

#### 6.2.1. Activate UnifiedCoordinateService

- **Checklist**:
  - [ ] Remove legacy paths.
  - [ ] Test hover/placement parity.

#### 6.2.2. Fix "Ghost" Components with Atomic Transactions

- **Implementation**: Add GridStateManager with applyPlacementTransaction.
- **Checklist**:
  - [ ] Implement transactional update.
  - [ ] Test no ghosts.

#### 6.2.3. Improve Grid UI

- **Checklist**:
  - [ ] Centralize overlay in [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682).
  - [ ] Add golden tests for overlay.

### 6.3. Synchronization Point

- **Acceptance Criteria**: No bugs in manual tests; UI review passed.

## 7. Phase 3: Architectural Polish & Feature Implementation (Estimated Time: 1 Week)

### 7.1. Objective

Polish architecture and add nearness rule.

### 7.2. Tasks

#### 7.2.1. Implement GridStateManager

- **Checklist**:
  - [ ] Add transactional placement.
  - [ ] Integrate with [interaction_state.dart](lib/application/states/interaction_state.dart:1).

#### 7.2.2. Implement "Nearness" Rule

- **Checklist**:
  - [ ] Add NearnessRule to [ComponentPlacementValidator.class()](lib/core/services/interactive_mechanics.dart:122).
  - [ ] Add visual feedback in [GridPainter.class()](lib/presentation/features/game/widgets/circuit_grid.dart:682).
  - [ ] Add table-driven tests.

## 8. Cross-Phase Requirements

### 8.1. Rollback Plan

- Toggle flags; disable services; purge transient state.

### 8.2. Testing Strategy

- Unit, integration, golden (for painters), property-based (for conversions), widget gesture tests, performance with budgets.

## 9. Glossary

- **GridPosition**: Logical (row, col) in grid space.
- **GridConfiguration**: Struct with cellSize, origin, pan, zoom, anchor, rounding.
- **Viewport**: Pan, zoom state via [ViewportService.class()](lib/presentation/features/game/services/viewport_service.dart:3).
- **LevelBounds**: Rect defining playable area.
- **Anchor**: Top-left or center for conversions.
- **Rounding Mode**: Floor, ceil, or nearest for screen-to-grid.

This v2.0 plan aligns with repository state, strengthens architecture, and provides actionable, traceable steps.
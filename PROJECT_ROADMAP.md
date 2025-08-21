# Project Roadmap: A Phased Refactoring and Enhancement Plan

**Author:** Lead Developer
**Date:** 2025-08-20
**Status:** Adopted

## 1. Overview

This document outlines the master plan for the next stages of development for the `circuit_stem` project. It synthesizes the findings from multiple architectural analyses, debug reports, and strategic discussions. The core philosophy is a **sequential, foundation-first approach** that prioritizes stability, architectural integrity, and development efficiency.

This plan is the single source of truth for the project's priorities. Its purpose is to ensure that every development cycle builds upon a stable, well-architected foundation, leading to a robust and maintainable application.

## 2. High-Level Summary Table

| Phase | Title                        | Status    | Key Steps                                                               |
| :---- | :--------------------------- | :-------- | :---------------------------------------------------------------------- |
| **0** | Foundation & Stability       | `Pending` | Fix test suite, improve mocks, resolve build issues, update dependencies. |
| **1** | Metrics & Baselines        | `Pending` | Establish performance baselines and document test coverage.             |
| **2** | State Management Refactor    | `Pending` | Granular migration to `AsyncNotifierProvider`.                          |
| **3** | UI Testing Strategy        | `Pending` | Define visual regression, accessibility, and performance testing.         |
| **4** | Phased UI Refactor           | `Pending` | Execute the feature-rich UI modernization plan.                         |
| **5** | Documentation & Finalization | `Pending` | Update all architectural documents and create developer guides.           |

---

## 3. Detailed Phased Implementation Plan

### **Phase 0: Foundation & Stability (Immediate Priority)**

**Goal:** To create a stable and reliable development environment, which is a non-negotiable prerequisite for all subsequent work.

*   **1. Fix Test Suite Compilation:**
    *   **Task:** Resolve the critical `Error: Type 'Component' not found` in `test/helpers/level_01_test_helper.dart`.
    *   **Reference:** This issue is documented as a known blocker in `handover.md`.

*   **2. Improve Mock Implementations:**
    *   **Task:** Refactor `MockAssetManager` to return a minimal, non-null `ui.Image` object instead of `null`. This will prevent the test suite from hanging during UI tests.
    *   **Reference:** The root cause analysis in `DOCS/LEVEL_01_DEBUG_REPORT.md` identified this as a critical flaw in the test setup.

*   **3. Resolve Build Environment Issues:**
    *   **Task:** Ensure the macOS build environment is functional by installing `xcodebuild` and document any required setup steps in the main `README.md`.
    *   **Reference:** Noted as a developer environment blocker in `handover.md`.

*   **4. Update Dependencies:**
    *   **Task:** Run `flutter pub outdated` and create a plan to safely update the project's 26 outdated package dependencies.
    *   **Reference:** Identified as a necessary housekeeping task in `handover.md`.

### **Phase 1: Metrics & Baselines**

**Goal:** To establish objective, data-driven metrics that will allow us to measure the impact (positive or negative) of our refactoring efforts.

*   **1. Establish Performance Baselines:**
    *   **Task:** Before making major changes, record key performance indicators:
        *   App startup time.
        *   Memory usage during gameplay.
        *   Average frame rate (FPS) on target devices.
        *   Level loading time.
    *   **Why:** This data is crucial for ensuring that our architectural improvements do not inadvertently introduce performance regressions.

*   **2. Document Test Coverage:**
    *   **Task:** Generate and record the current test coverage percentage.
    *   **Why:** This provides a baseline to ensure our test suite grows and improves alongside the codebase.

### **Phase 2: State Management Refactor (Migrate to `AsyncNotifierProvider`)**

**Goal:** To modernize the app's state management core, providing a simpler and more robust foundation for all future UI development. This must be done *before* the major UI refactor to avoid building new UI on a legacy foundation.

*   **1. Granular Migration Strategy:**
    *   **Phase 2a: Non-Critical Providers:** Migrate simpler providers first, such as those related to settings or user preferences, to validate the new pattern in a low-risk area.
    *   **Phase 2b: Core Data Providers:** Migrate the `AssetManager` and any user state providers.
    *   **Phase 2c: Game State & Engine:** Finally, migrate the core `gameEngineProvider` and update the `GameScreen` to use the new provider.
    *   **Reference:** The need for this refactor is a key takeaway from the debugging sessions documented in `handover.md` and `DOCS/LEVEL_01_DEBUG_REPORT.md`.

### **Phase 3: UI Testing Strategy Definition**

**Goal:** To establish a comprehensive testing strategy specifically for the new UI components that will be built in the next phase.

*   **1. Visual Regression Testing:**
    *   **Task:** Set up a framework (e.g., using golden file testing) to capture screenshots of UI components and prevent unintended visual changes.

*   **2. Accessibility Testing:**
    *   **Task:** Integrate accessibility checks into the test suite to ensure new components meet standards (e.g., for screen readers, contrast ratios).

*   **3. Performance Monitoring for Animations:**
    *   **Task:** Define a strategy for testing the performance impact of the new animations planned in the UI refactor.

### **Phase 4: Phased UI Refactor**

**Goal:** To execute the well-documented UI modernization plan, building upon the now-stable foundation and state management architecture.

*   **1. Execute the Plan:**
    *   **Task:** Begin the phased implementation detailed in `DOCS/UI_REFACTORING_STRATEGY.md`, starting with its **Phase 1: Foundation Layer** (Theme System, Enhanced Grid, Animation Foundation).
    *   **Reference:** This entire phase is guided by `DOCS/UI_REFACTORING_STRATEGY.md`.

*   **2. Use Feature Flags:**
    *   **Task:** For major new UI components like the "Enhanced Grid", implement them behind feature flags.
    *   **Why:** This allows for gradual rollout, A/B testing, and instant rollback if a new feature introduces production issues, dramatically reducing risk.

### **Phase 5: Documentation & Finalization**

**Goal:** To ensure the project's documentation is updated to reflect the new, improved architecture, making it easier for future developers to contribute effectively.

*   **1. Update Architectural Documents:**
    *   **Task:** Update `DOCS/Architecture.md` to describe the Component-Behavior model and the `AsyncNotifierProvider`-based state management.
    *   **Reference:** This task is pending from `DOCS/REFACTOR_PLAN_CompBeh_Model.md`.

*   **2. Create Developer Guides:**
    *   **Task:** Create a new `DOCS/AddingNewComponents.md` tutorial.
    *   **Reference:** This was a key deliverable defined in `DOCS/REFACTOR_PLAN_CompBeh_Model.md`.

*   **3. Update Statuses:**
    *   **Task:** Mark this `PROJECT_ROADMAP.md` as "In Progress" and update the status of all other ADRs and plan documents (e.g., to "Implemented" or "Superseded").

---

## 4. Cross-Cutting Considerations

These principles should be applied throughout all phases of the project.

*   **Monitoring:** Before beginning the refactors, integrate error tracking (e.g., Sentry, Firebase Crashlytics) and performance monitoring to detect regressions in production immediately.
*   **Code Review Strategy:** Establish clear guidelines for Pull Requests. For large refactoring work, prefer a series of smaller, focused, and well-documented PRs over a single monolithic one. This makes reviews more manageable and easier to understand.

---

## 5. Appendix: Completed Milestones & Fixes

This table summarizes the major architectural refactors and critical bug fixes that have already been completed. These items form the stable foundation upon which the above roadmap is built.

| Feature / Fix                       | Status          | Primary Reference Document(s)                            |
| :---------------------------------- | :-------------- | :------------------------------------------------------- |
| **Component-Behavior Architecture** | ✅ Implemented | `DOCS/REFACTOR_PLAN_CompBeh_Model.md`, `handover.md`     |
| **SVG Direct Rendering Pipeline**   | ✅ Implemented | `DOCS/ADR-SVG-RENDERING-REFACTOR.md`                     |
| **Async Initialization Race Condition** | ✅ Fixed      | `DOCS/INITIAL_COMPONENTS_RENDERING_BUG.md`, `handover.md`|
| **Level 1 Test Timeouts**           | ✅ Fixed      | `DOCS/LEVEL_01_DEBUG_REPORT.md`                          |
| **Level JSON Parsing TypeErrors**   | ✅ Fixed      | `CHANGELOG.md` (2025-08-20 Entry)                        |
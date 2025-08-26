# Handover Document: Circuit STEM

**Date:** 2025-08-26

## 1. Project Overview

This document provides a comprehensive handover of the `circuit_stem` Flutter project. The application is an educational puzzle game designed to teach the fundamentals of electrical circuits. It features a pure Dart logic engine, a data-driven level system using JSON, and a service-oriented architecture.

## 2. Architectural State

The core application logic has undergone a massive and successful refactoring to improve testability, scalability, and separation of concerns. This effort is now **complete**. The application has been migrated from a monolithic engine to a clean, modern architecture based on **Use Cases**, **Services**, and **Middleware**, all managed via Riverpod.

The primary pending work and next major effort is to bring the **UI layer** up to the same high standard, followed by bolstering the test suite to ensure long-term stability.

### Current Status Breakdown:

*   **Core Engine Refactoring (Phases 0-4):** ✅ Done
*   **Advanced Features (Phase 5):** 🟡 In Progress (Undo & Decoupled Audio are implemented)
*   **UI Layer Refactoring:** ⏳ In Progress
*   **Test Suite Coverage:** ⏳ In Progress

## 3. Key Architectural Concepts

- **State Management:** Riverpod is the sole state management solution. All major application state is held within the `GameEngineState` and managed by the `gameEngineProvider`.
- **Application Logic:** Logic is encapsulated in **Use Cases** (e.g., `RotateComponentUseCase`). These are self-contained classes that perform a single action.
- **Services:** Core, reusable logic is handled by services (e.g., `PowerSimulationService`, `GoalCheckingService`).
- **Middleware:** Cross-cutting concerns (logging, audio) are handled in a middleware pipeline that wraps UseCase execution.
- **UI Layer:** The target architecture is for widgets to be "dumb" presenters of data. They should read state from providers and dispatch intents to the `GameEngineNotifier`, not contain their own logic.

## 4. What's Next? The Roadmap

The highest priorities for continuing development are outlined in the `DOCS/UI_TECHNICAL_DEBT.md` document.

1.  **Complete the UI Layer Refactoring (High Priority):**
    *   **Task:** Fix the broken `DebugOverlay` by refactoring its controller to a Riverpod provider.
    *   **Task:** Delete dead/empty widget files.
    *   **Task:** Audit all remaining widgets to ensure they conform to the "dumb presenter" pattern.

2.  **Bolster the Testing Suite (High Priority):**
    *   **Task:** Run a formal test coverage analysis to find gaps.
    *   **Task:** Write widget tests for the newly refactored UI components.
    *   **Task:** Add any missing unit tests for UseCases and Services.

## 5. How to Get Started

1.  **Review the Architecture:** Read `DOCS/CORE_REFACTORING.md` to understand the history and details of the new architecture.
2.  **Review the UI Tech Debt:** Read `DOCS/UI_TECHNICAL_DEBT.md` for a detailed breakdown of the next UI tasks.
3.  **Run the App & Tests:**
    ```bash
    flutter pub get
    flutter test
    flutter run
    ```
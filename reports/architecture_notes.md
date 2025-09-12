# Architecture Description

## Current Architecture
The codebase follows **Clean Architecture principles with Domain-Driven Design (DDD)**:
- **Domain Layer** (`lib/domain/`): Entities (components, levels, user), value objects, behaviors, goals—pure business models without dependencies.
- **Application Layer** (`lib/application/`): Use cases (e.g., create_component_use_case), services (gestures, auth), providers (Riverpod notifiers for game state, interaction), adapters for legacy v3 engine.
- **Infrastructure Layer** (`lib/infrastructure/`): Persistence (Hive), audio, rendering—implementation details.
- **Presentation Layer** (`lib/presentation/`): Features (game, auth, menus, onboarding, hud, sharing, palette, debug, accessibility), widgets, screens, controllers/orchestrators mixing UI and logic (anti-pattern noted).
- **Core** (`lib/core/`): Shared utilities, commands, events, validation, performance, simulation.
- **External** (`lib/flame_components_optional/`): Optional Flame integration for animations.
- **State Management**: Primarily **Riverpod** (providers, notifiers); some legacy setState in widgets; freezed for immutable states.

No explicit diagram in repo; proposed architecture below. No cyclic dependencies evident (layers unidirectional: presentation -> application -> domain -> core).

## Proposed Architecture Diagram (Mermaid)
```mermaid
graph TD
    A[Presentation: Features, Screens, Widgets] --> B[Application: Use Cases, Services, Providers (Riverpod)]
    B --> C[Domain: Entities, Behaviors, Goals]
    C --> D[Core: Commands, Events, Validation]
    E[Infrastructure: Persistence (Hive), Audio, Rendering] --> B
    F[External: Flame, Firebase] --> E
    G[UI: Canvas, HUD, Palette] --> A
    H[State: EnhancedGameState Notifier] --> B
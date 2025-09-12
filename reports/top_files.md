# Top 10 Largest Files (Estimated LOC)

Estimates based on code structure, TODO density, and method counts (cannot run cloc/wc; recommend local `cloc lib/ | sort -nr | head -10`).

1. lib/presentation/features/game/controllers/canvas_interaction_controller.dart - ~1700 LOC: Complex gesture handling, placement logic, feedback (many TODOs for engine integration).
2. lib/presentation/features/game/controllers/game_canvas_orchestrator.dart - ~1200 LOC: Orchestrates canvas layers, loading, simulation calls.
3. lib/application/enhanced_game_state_notifier.dart - ~800 LOC: Large notifier with freezed state, game logic, undo/redo placeholders.
4. lib/application/game_engine_core.dart - ~600 LOC: Core engine with simulation steps, component evaluation (TODOs for behaviors).
5. lib/presentation/features/game/screens/game_screen.dart - ~500 LOC: Main screen with multi-layers (canvas, HUD, palette).
6. lib/presentation/features/game/widgets/canvas_rendering_layer.dart - ~450 LOC: Painting components, wires, activity states.
7. lib/presentation/features/game/widgets/canvas_wire_layer.dart - ~400 LOC: Wire painting, activity determination.
8. lib/application/services/implementations/game_interaction_service_impl.dart - ~350 LOC: Drag/drop, coordinate conversion.
9. lib/core/services/interactive_mechanics.dart - ~300 LOC: Component handlers, loading.
10. lib/application/use_cases/create_component_use_case.dart - ~250 LOC: Placement validation, transaction handling.

Reasons for heaviness: Monolithic controllers mixing UI logic with business rules; recommend splitting into smaller use cases/services.
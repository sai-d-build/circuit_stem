import 'package:flutter_riverpod/flutter_riverpod.dart';
// Domain entities
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../application/states/game_state.dart';
import '../../application/use_cases/providers.dart' as use_case_providers;
import '../../core/simulation/basic_simulation_engine.dart';
// Core simulation and solver imports
import '../../core/simulation/mna_solver.dart';
import '../../core/simulation/netlist_builder.dart';
import '../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../../presentation/features/game/controllers/canvas_interaction_controller.dart'
    as canvas_controller;
// Canvas and orchestrator imports
import '../../presentation/features/game/controllers/game_canvas_orchestrator.dart'
    hide InteractionState;
import '../../presentation/state/palette_state.dart';
import '../component_selection_notifier.dart'
    show ComponentSelectionNotifier, ComponentSelectionState;
import '../component_selection_notifier.dart';
import '../enhanced_game_state_notifier.dart';
// Game Engine V3 imports
import '../game_engine/v3/game_engine_notifier_v3.dart';
import '../game_progress_notifier.dart' show GameProgressNotifier, GameProgress;
import '../game_progress_notifier.dart';
// Missing notifier providers
import '../grid_notifier.dart';
// Import notifier classes for provider definitions - Grid is already available via entities import above
import '../history_notifier.dart' show HistoryNotifier, GameStateSnapshot;
import '../history_notifier.dart';
import '../interaction_state_notifier.dart'
    show InteractionStateNotifier, InteractionState;
import '../interaction_state_notifier.dart';
// Services and infrastructure
import '../services/component_factory.dart';
import '../services/component_palette_manager.dart';
import '../services/goal_checking_service.dart';
import '../services/implementations/canvas_business_service_impl.dart';
import '../services/implementations/canvas_rendering_service_impl.dart';
import '../services/implementations/component_inventory_service_impl.dart';
import '../services/implementations/component_placement_service_impl.dart';
import '../services/implementations/game_interaction_service_impl.dart';
import '../services/implementations/grid_validation_service_impl.dart';
import '../services/interfaces/canvas_rendering_service.dart';
import '../services/interfaces/component_placement_service.dart';
import '../services/interfaces/game_interaction_service.dart';
import '../services/placement_service_adapter.dart';
import '../services/power_simulation_service.dart';

// Provider imports (moved from bottom) - consolidated with class imports above

// ============================================================================
// SIMULATION ENGINE PROVIDERS
// ============================================================================
// The heart of CircuitSTEM simulation - MNA solver and circuit calculation logic

// MNA Solver Provider - Mathematical circuit analysis engine
final mnaSolverProvider = Provider((ref) => BasicMNASolver());

// Simulation Engine Provider - Main simulation coordinator
final powerSimulationServiceProvider = Provider((ref) {
  return PowerSimulationService();
});

// Netlist Builder Provider - Circuit topology processor
final netlistBuilderProvider = Provider((ref) => NetlistBuilder());

// Main Simulation Engine Provider
final simulationEngineProvider = Provider((ref) {
  return BasicSimulationEngine();
});

// ============================================================================
// GAME ENGINE PROVIDERS
// ============================================================================

// Game Engine V3 Provider - Clean implementation
final gameEngineNotifierV3Provider =
    StateNotifierProvider<GameEngineNotifierV3, GameState>((ref) {
  return GameEngineNotifierV3();
});

// Enhanced Game State Provider with full dependencies (for consolidation plan)
final enhancedGameStateNotifierProvider =
    StateNotifierProvider<EnhancedGameStateNotifier, GameState>((ref) {
  final simulationEngine = ref.watch(simulationEngineProvider); // ignore: cascade_invocations
  final netlistBuilder = ref.watch(netlistBuilderProvider); // ignore: cascade_invocations
  final storageService = ref.watch(storageServiceProvider); // ignore: cascade_invocations
  final commandStack = ref.watch(use_case_providers.commandStackProvider); // ignore: cascade_invocations
  final componentFactory = ref.watch(componentFactoryProvider); // ignore: cascade_invocations

  return EnhancedGameStateNotifier(
    simulationEngine: simulationEngine,
    netlistBuilder: netlistBuilder,
    storageService: storageService,
    commandStack: commandStack,
    componentFactory: componentFactory,
  );
});

// ============================================================================
// MISSING NOTIFIER PROVIDERS (for consolidation plan)
// ============================================================================

// Reference existing providers from respective notifier files
// These providers are defined in their respective notifier files and must be exposed here for global access

// Grid Notifier Provider reference
// Provider is defined in lib/application/grid_notifier.dart line 63

// History Notifier Provider reference
// Provider is defined in lib/application/history_notifier.dart line 86

// Game Progress Notifier Provider reference
// Provider is defined in lib/application/game_progress_notifier.dart line 126

// Component Selection Notifier Provider reference
// Provider is defined in lib/application/component_selection_notifier.dart line 110

// Interaction State Notifier Provider reference
// Provider is defined in lib/application/interaction_state_notifier.dart line 191

// ============================================================================
// NOTIFIER PROVIDER DEFINITIONS (Imported from respective files)
// ============================================================================

// Grid Notifier Provider - Manages grid state
final gridNotifierProvider = StateNotifierProvider<GridNotifier, Grid>((ref) {
  return GridNotifier();
});

// History Notifier Provider - Manages undo/redo history
final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, List<GameStateSnapshot>>((ref) {
  return HistoryNotifier();
});

// Game Progress Notifier Provider - Manages game progress state
final gameProgressNotifierProvider =
    StateNotifierProvider<GameProgressNotifier, GameProgress>((ref) {
  return GameProgressNotifier();
});

// Component Selection Notifier Provider - Manages component selection state
final componentSelectionNotifierProvider =
    StateNotifierProvider<ComponentSelectionNotifier, ComponentSelectionState>(
        (ref) {
  return ComponentSelectionNotifier();
});

// Interaction State Notifier Provider - Manages interaction state
final interactionStateNotifierProvider =
    StateNotifierProvider<InteractionStateNotifier, InteractionState>((ref) {
  return InteractionStateNotifier();
});

// Alias for backward compatibility
final interactionStateNotifierProviderAlias = interactionStateNotifierProvider;

// ============================================================================
// COMPONENT MANAGEMENT PROVIDERS
// ============================================================================
// Handle component creation, lifecycle, and palette management

// Component Factory Provider - Creates circuit components
final componentFactoryProvider = Provider((ref) => ComponentFactory());

// Component Palette Manager Provider - Manages available components
final componentPaletteManagerProvider = Provider((ref) {
  return const ComponentPaletteManager(availableTemplates: []);
});

// ============================================================================
// STORAGE & PERSISTENCE PROVIDERS
// ============================================================================
// User data, level progress, and settings persistence

// Shared Preferences Storage Provider - User settings and data
final storageServiceProvider = Provider<SharedPreferencesStorageService>((ref) {
  throw UnimplementedError(
      'SharedPreferencesStorageService must be initialized in main.dart and overridden via ProviderScope');
});

// ============================================================================
// UI STATE PROVIDERS
// ============================================================================

// Palette Drag Active Provider - Tracks if a drag from palette is in progress
final paletteDragActiveProvider = StateProvider<bool>((ref) => false);

// Interaction State Provider - For canvas drag-drop interactions
final interactionStateProvider = StateNotifierProvider.family<
    canvas_controller.InteractionStateNotifier,
    canvas_controller.InteractionState,
    String>(
  (ref, levelId) =>
      canvas_controller.InteractionStateNotifier(ref: ref, levelId: levelId),
);

// ============================================================================
// GOAL & VALIDATION PROVIDERS
// ============================================================================

// Goal Checking Service Provider - Validates level completion
final goalCheckingServiceProvider =
    Provider((ref) => const GoalCheckingService());

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================
// Business logic orchestrators that coordinate multiple services

// Component Creation Use Case Provider - Placeholder implementation
final createComponentUseCaseProvider = Provider((ref) {
  final factory = ref.watch(componentFactoryProvider); // ignore: cascade_invocations
  final simulation = ref.watch(powerSimulationServiceProvider); // ignore: cascade_invocations
  // Simple placeholder - replace with actual use case when available
  return {
    'factory': factory,
    'simulation': simulation,
    'execute': (dynamic component) => component != null,
  };
});

// Win Condition Checking Use Case Provider - Placeholder implementation
final checkWinConditionUseCaseProvider = Provider((ref) {
  final goalCheckingService = ref.watch(goalCheckingServiceProvider);
  // Simple placeholder - replace with actual use case when available
  return {
    'goalChecker': goalCheckingService,
    'checkWin': (dynamic currentGameStateId) => currentGameStateId != null,
  };
});

// ============================================================================
// CANVAS & ORCHESTRATOR PROVIDERS
// ============================================================================

// Game Canvas Orchestrator Provider (from game_canvas_providers.dart)
final gameCanvasOrchestratorProvider = StateNotifierProvider.family<
    GameCanvasOrchestrator,
    GameCanvasState,
    String // levelId
    >((ref, levelId) {
  return GameCanvasOrchestrator(
    interactionService: ref.watch(gameInteractionServiceProvider),
    renderingService: ref.watch(canvasRenderingServiceProvider),
    paletteStateNotifier: ref.watch(paletteStateProvider(levelId).notifier),
  );
});

// Component Placement Service Provider (from game_canvas_providers.dart)
final componentPlacementServiceProvider =
    Provider.family<ComponentPlacementService, String>((ref, levelId) {
  // Use concrete implementations
  final paletteStateNotifier =
      ref.watch(paletteStateProvider(levelId).notifier);
  final inventoryService = DefaultComponentInventoryService(
    paletteStateNotifier: paletteStateNotifier,
    levelId: levelId,
  );
  final gridValidationService = DefaultGridValidationService();
  final gameEngine = ref.watch(gameEngineNotifierV3Provider.notifier);

  return DefaultComponentPlacementService(
    inventoryService: inventoryService,
    gridValidationService: gridValidationService,
    gameEngine: gameEngine,
  );
});

// Game Interaction Service Provider (from game_canvas_providers.dart)
final gameInteractionServiceProvider = Provider<GameInteractionService>((ref) {
  return GameInteractionServiceImpl();
});

// Canvas Rendering Service Provider (from game_canvas_providers.dart)
final canvasRenderingServiceProvider = Provider<CanvasRenderingService>((ref) {
  return DefaultCanvasRenderingService();
});

// Placement Service Adapter Provider - Clean dependency injection
final placementServiceAdapterProvider =
    Provider.family<PlacementServiceAdapter, String>((ref, levelId) {
  return PlacementServiceAdapter(
    gameStateNotifier: ref.watch(enhancedGameStateNotifierProvider.notifier),
    paletteStateNotifier: ref.watch(paletteStateProvider(levelId).notifier),
    componentPlacementService:
        ref.watch(componentPlacementServiceProvider(levelId)),
    levelId: levelId,
  );
});

// Canvas Business Service Provider - Clean dependency injection
final canvasBusinessServiceProvider =
    Provider.family<CanvasBusinessServiceImpl, String>((ref, levelId) {
  return CanvasBusinessServiceImpl(
    paletteStateNotifier: ref.watch(paletteStateProvider(levelId).notifier),
    componentPlacementService:
        ref.watch(componentPlacementServiceProvider(levelId)),
  );
});

// ============================================================================
// DEVELOPMENT NOTES
// ============================================================================
// When extracting providers from use_cases/providers.dart:
// 1. Ensure all import dependencies are included
// 2. Copy entire provider definitions (including type annotations)
// 3. Update any relative imports to absolute if needed
// 4. Add comprehensive documentation for each provider
// 5. Preserve type annotations for better error messages
// 6. Note performance implications for resource-intensive providers

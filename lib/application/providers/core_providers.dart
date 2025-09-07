import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math' as math;

// Core simulation and solver imports
import '../../core/simulation/mna_solver.dart';
import '../services/power_simulation_service.dart';
import '../../core/simulation/netlist_builder.dart';
import '../../core/simulation/basic_simulation_engine.dart';

// Services and infrastructure
import '../services/component_factory.dart';
import '../services/component_palette_manager.dart';
import '../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../services/goal_checking_service.dart';

// Game Engine V3 imports
import '../game_engine/v3/game_engine_notifier_v3.dart';
import '../../core/debug/structured_logger.dart';

// Domain entities
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../application/states/game_state.dart';

// Canvas and orchestrator imports
import '../states/game_canvas_state.dart';
import '../../presentation/features/game/controllers/game_canvas_orchestrator.dart';
import '../../presentation/features/game/controllers/canvas_interaction_controller.dart' as canvas_controller;
import '../services/interfaces/component_placement_service.dart';
import '../services/interfaces/game_interaction_service.dart';
import '../services/interfaces/canvas_rendering_service.dart';
import '../services/implementations/game_interaction_service_impl.dart';
import '../services/implementations/canvas_rendering_service_impl.dart';
import '../services/implementations/component_placement_service_impl.dart';
import '../services/implementations/component_inventory_service_impl.dart';
import '../services/implementations/grid_validation_service_impl.dart';
import '../../presentation/state/palette_state.dart';

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
final gameEngineNotifierV3Provider = StateNotifierProvider<GameEngineNotifierV3, GameState>((ref) {
  return GameEngineNotifierV3();
});

// Enhanced Game State Provider (alias for V3)
final enhancedGameStateNotifierProvider = gameEngineNotifierV3Provider;

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
final storageServiceProvider = Provider((ref) => SharedPreferencesStorageService());

// ============================================================================
// LEVEL MANAGEMENT PROVIDERS
// ============================================================================

// Level Service Provider
final levelServiceProvider = Provider<LevelService>((ref) {
  return LevelService();
});

// Level service implementation
class LevelService {
  Future<List<LevelDefinition>> loadAllLevels() async {
    StructuredLogger.info('Starting level loading process', context: {
      'operation': 'loadAllLevels',
      'timestamp': DateTime.now().toIso8601String(),
    });

    final List<LevelDefinition> levels = [];

    // Define level files to load
    final levelFiles = [
      'assets/levels/tutorial/tutorial_01.json',
      'assets/levels/beginner/beginner_01.json',
    ];

    StructuredLogger.debug('Level paths to load', context: {
      'levelPaths': levelFiles,
      'totalPaths': levelFiles.length,
    });

    // First, try to load and log the AssetManifest to see what assets are available
    try {
      StructuredLogger.debug('Loading AssetManifest.json to check available assets', context: {
        'manifestPath': 'AssetManifest.json',
      });

      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      StructuredLogger.debug('AssetManifest loaded successfully', context: {
        'totalAssets': manifestMap.length,
        'levelAssets': manifestMap.keys.where((key) => key.contains('levels')).toList(),
        'jsonAssets': manifestMap.keys.where((key) => key.endsWith('.json')).toList(),
      });

      // Check if our expected level files are in the manifest
      final expectedLevelAssets = levelFiles.where((path) => manifestMap.containsKey(path)).toList();
      final missingLevelAssets = levelFiles.where((path) => !manifestMap.containsKey(path)).toList();

      StructuredLogger.info('Asset manifest analysis', context: {
        'expectedLevelFiles': levelFiles,
        'foundInManifest': expectedLevelAssets,
        'missingFromManifest': missingLevelAssets,
        'manifestContainsLevels': manifestMap.keys.any((key) => key.contains('levels')),
      });

      if (missingLevelAssets.isNotEmpty) {
        StructuredLogger.warning('Some expected level files are missing from AssetManifest', context: {
          'missingFiles': missingLevelAssets,
          'thisMayCauseLevelLoadingFailure': true,
        });
      }

    } catch (e, stackTrace) {
      StructuredLogger.error('Failed to load or parse AssetManifest.json', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'thisWillPreventLevelLoading': true,
      }, error: e);
    }

    int successCount = 0;
    int failureCount = 0;

    for (final filePath in levelFiles) {
      try {
        StructuredLogger.debug('Starting load of individual level file', context: {
          'levelPath': filePath,
          'currentIndex': levelFiles.indexOf(filePath),
          'totalPaths': levelFiles.length,
        });

        // Step 1: Load JSON string from assets
        StructuredLogger.debug('Attempting to load JSON string from asset bundle', context: {
          'levelPath': filePath,
          'operation': 'rootBundle.loadString',
          'fileIndex': levelFiles.indexOf(filePath),
          'totalFiles': levelFiles.length,
        });

        final jsonString = await rootBundle.loadString(filePath);

        StructuredLogger.debug('JSON string loaded successfully from assets', context: {
          'levelPath': filePath,
          'jsonLength': jsonString.length,
          'firstChars': jsonString.substring(0, math.min(100, jsonString.length)),
          'lastChars': jsonString.length > 100 ? jsonString.substring(jsonString.length - 50) : '',
          'containsLevelId': jsonString.contains('"levelId"'),
          'containsMetadata': jsonString.contains('"metadata"'),
        });

        // Step 2: Parse JSON
        StructuredLogger.trace('Parsing JSON string', context: {
          'levelPath': filePath,
          'operation': 'json.decode',
        });

        final dynamic jsonData = json.decode(jsonString);

        StructuredLogger.trace('JSON parsing completed', context: {
          'levelPath': filePath,
          'jsonType': jsonData.runtimeType.toString(),
          'isMap': jsonData is Map<String, dynamic>,
        });

        // Step 3: Validate JSON structure
        if (jsonData is! Map<String, dynamic>) {
          StructuredLogger.warning('Invalid JSON structure - not a Map', context: {
            'levelPath': filePath,
            'jsonType': jsonData.runtimeType.toString(),
            'expectedType': 'Map<String, dynamic>',
            'jsonData': jsonData.toString(),
          });
          failureCount++;
          continue;
        }

        // Step 4: Validate required fields
        final requiredFields = ['levelId', 'metadata', 'grid', 'components', 'goals'];
        final missingFields = requiredFields.where((field) => !jsonData.containsKey(field)).toList();

        if (missingFields.isNotEmpty) {
          StructuredLogger.warning('Missing required fields in level JSON', context: {
            'levelPath': filePath,
            'missingFields': missingFields,
            'availableFields': jsonData.keys.toList(),
          });
          failureCount++;
          continue;
        }

        StructuredLogger.trace('JSON structure validation passed', context: {
          'levelPath': filePath,
          'availableFields': jsonData.keys.toList(),
        });

        // Step 5: Deserialize to LevelDefinition
        StructuredLogger.trace('Deserializing to LevelDefinition', context: {
          'levelPath': filePath,
          'operation': 'LevelDefinition.fromJson',
        });

        final level = LevelDefinition.fromJson(jsonData);
        levels.add(level);
        successCount++;

        StructuredLogger.debug('Level successfully loaded and parsed', context: {
          'levelId': level.levelId,
          'levelPath': filePath,
          'title': level.metadata.title,
          'difficulty': level.metadata.difficulty,
          'gridSize': '${level.grid.width}x${level.grid.height}',
          'componentCount': level.components.available.length,
          'goalCount': level.goals.length,
        });

      } catch (e, stackTrace) {
        failureCount++;
        StructuredLogger.error('Failed to load level file', context: {
          'levelPath': filePath,
          'error': e.toString(),
          'errorType': e.runtimeType.toString(),
          'stackTrace': stackTrace.toString(),
          'levelsLoadedSoFar': levels.length,
          'successCount': successCount,
          'failureCount': failureCount,
        }, error: e);
        // Continue loading other levels even if one fails
      }
    }

    StructuredLogger.info('Level loading batch completed', context: {
      'totalLevelsLoaded': levels.length,
      'successCount': successCount,
      'failureCount': failureCount,
      'totalPathsAttempted': levelFiles.length,
      'levels': levels.map((level) => {
        'id': level.levelId,
        'title': level.metadata.title,
        'difficulty': level.metadata.difficulty,
      }).toList(),
      'duration': DateTime.now().toIso8601String(),
    });

    if (levels.isEmpty) {
      StructuredLogger.warning('No levels were successfully loaded', context: {
        'totalPathsAttempted': levelFiles.length,
        'failureCount': failureCount,
        'levelPaths': levelFiles,
      });
    }

    return levels;
  }

  Future<LevelDefinition?> loadLevel(String levelId) async {
    final allLevels = await loadAllLevels();

    // Map simple level IDs to actual level file names
    final levelIdMapping = {
      '1': 'tutorial_01',
      '2': 'beginner_01',
      // Add more mappings as needed
    };

    final mappedLevelId = levelIdMapping[levelId] ?? levelId;

    try {
      return allLevels.firstWhere((level) => level.levelId == mappedLevelId);
    } catch (e) {
      StructuredLogger.warning('Level search failed', context: {
        'originalLevelId': levelId,
        'mappedLevelId': mappedLevelId,
        'availableLevels': allLevels.map((level) => level.levelId).toList(),
        'error': e.toString(),
      });
      return null;
    }
  }
}

// ============================================================================
// UI STATE PROVIDERS
// ============================================================================

// Palette Drag Active Provider - Tracks if a drag from palette is in progress
final paletteDragActiveProvider = StateProvider<bool>((ref) => false);

// Interaction State Provider - For canvas drag-drop interactions
final interactionStateProvider = StateNotifierProvider.family<canvas_controller.InteractionStateNotifier, canvas_controller.InteractionState, String>(
  (ref, levelId) => canvas_controller.InteractionStateNotifier(ref: ref, levelId: levelId),
);

// ============================================================================
// GOAL & VALIDATION PROVIDERS
// ============================================================================

// Goal Checking Service Provider - Validates level completion
final goalCheckingServiceProvider = Provider((ref) => GoalCheckingService());

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================
// Business logic orchestrators that coordinate multiple services

// Component Creation Use Case Provider - Placeholder implementation
final createComponentUseCaseProvider = Provider((ref) {
  final factory = ref.watch(componentFactoryProvider);
  final simulation = ref.watch(powerSimulationServiceProvider);
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
  String  // levelId
>((ref, levelId) {
  return GameCanvasOrchestrator(
    placementService: ref.watch(componentPlacementServiceProvider(levelId)),
    interactionService: ref.watch(gameInteractionServiceProvider),
    renderingService: ref.watch(canvasRenderingServiceProvider),
  );
});

// Component Placement Service Provider (from game_canvas_providers.dart)
final componentPlacementServiceProvider = Provider.family<ComponentPlacementService, String>((ref, levelId) {
  // Use concrete implementations
  final paletteStateNotifier = ref.watch(paletteStateProvider(levelId).notifier);
  final inventoryService = DefaultComponentInventoryService(
    paletteStateNotifier: paletteStateNotifier,
    levelId: levelId,
  );
  final gridValidationService = DefaultGridValidationService();
  final gameEngine = ref.watch(enhancedGameStateNotifierProvider.notifier);

  return DefaultComponentPlacementService(
    inventoryService: inventoryService,
    gridValidationService: gridValidationService,
    gameEngine: gameEngine,
  );
});

// Game Interaction Service Provider (from game_canvas_providers.dart)
final gameInteractionServiceProvider = Provider<GameInteractionService>((ref) {
  return GameInteractionServiceImpl(
    placementService: ref.watch(componentPlacementServiceProvider('default')),
  );
});

// Canvas Rendering Service Provider (from game_canvas_providers.dart)
final canvasRenderingServiceProvider = Provider<CanvasRenderingService>((ref) {
  return DefaultCanvasRenderingService();
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

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

// Domain entities and logging
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../core/debug/structured_logger.dart';

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

// Level Service Provider - Handles level loading and management
final levelServiceProvider = Provider<LevelService>((ref) {
  return LevelService();
});

// Palette Drag Active Provider - Tracks if a drag from palette is in progress
final paletteDragActiveProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// LEVEL SERVICE IMPLEMENTATION
// ============================================================================

// Level service implementation
class LevelService {
  Future<List<LevelDefinition>> loadAllLevels() async {
    final List<LevelDefinition> levels = [];

    // Define level files to load
    final levelFiles = [
      'assets/levels/tutorial/tutorial_01.json',
      'assets/levels/beginner/beginner_01.json',
    ];

    for (final filePath in levelFiles) {
      try {
        StructuredLogger.debug('Loading individual level file', context: {
          'levelPath': filePath,
        });

        final jsonString = await rootBundle.loadString(filePath);

        StructuredLogger.trace('Level JSON file loaded', context: {
          'levelPath': filePath,
          'jsonLength': jsonString.length,
        });

        final dynamic jsonData = json.decode(jsonString);

        StructuredLogger.trace('Level JSON parsed', context: {
          'levelPath': filePath,
          'jsonType': jsonData.runtimeType.toString(),
        });

        if (jsonData is! Map<String, dynamic>) {
          StructuredLogger.warning('Invalid JSON structure found in level file', context: {
            'levelPath': filePath,
            'jsonType': jsonData.runtimeType.toString(),
            'expectedType': 'Map<String, dynamic>',
          });
          continue;
        }

        final level = LevelDefinition.fromJson(jsonData);
        levels.add(level);

        StructuredLogger.debug('Level successfully loaded', context: {
          'levelId': level.levelId,
          'levelPath': filePath,
          'title': level.metadata.title,
        });
      } catch (e) {
        StructuredLogger.error('Failed to load level file', context: {
          'levelPath': filePath,
          'error': e.toString(),
          'levelsLoaded': levels.length,
        }, error: e);
        // Continue loading other levels even if one fails
      }
    }

    StructuredLogger.info('Level loading batch complete', context: {
      'totalLevelsLoaded': levels.length,
      'levels': levels.map((level) => level.levelId).toList(),
    });
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
// DEVELOPMENT NOTES
// ============================================================================
// When extracting providers from use_cases/providers.dart:
// 1. Ensure all import dependencies are included
// 2. Copy entire provider definitions (including type annotations)
// 3. Update any relative imports to absolute if needed
// 4. Add comprehensive documentation for each provider
// 5. Preserve type annotations for better error messages
// 6. Note performance implications for resource-intensive providers
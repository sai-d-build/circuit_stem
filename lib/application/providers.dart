import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Application layer
import 'animation_scheduler.dart';
import 'enhanced_game_state_notifier.dart';
import 'enhanced_game_state.dart'; // Explicitly import GameState
import 'services/component_factory.dart';

// Infrastructure layer
import '../infrastructure/audio/audio_service.dart';
import '../infrastructure/persistence/level_manager.dart';
import '../infrastructure/persistence/level_manager_state.dart';
import '../infrastructure/rendering/asset_manager.dart';
import '../infrastructure/rendering/asset_manager_state.dart';

// Core Services
import '../core/persistence/storage_service.dart';
import '../core/commands/command_stack.dart';
import '../core/commands/in_memory_command_stack.dart';
import '../core/simulation/simulation_engine.dart';
import '../core/simulation/basic_simulation_engine.dart';
import '../core/simulation/netlist_builder.dart';

// Educational gaming service imports (keep if still relevant)
import '../core/services/level_system.dart';
import '../core/services/achievement_system.dart';
import '../core/services/interactive_mechanics.dart';
import '../core/services/hint_system.dart';
import '../core/services/animation_system.dart';
import '../core/services/visual_feedback_system.dart';
// import '../core/services/educational_validator.dart'; // Removed for now
import '../core/services/learning_analytics.dart';

// Feature flag imports
import '../common/feature_flags.dart';

// =============================================================================
// FOUNDATIONAL SERVICE PROVIDERS
// =============================================================================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

final audioServiceProvider = Provider((ref) => AudioService());
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

final levelManagerProvider =
    StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(sharedPrefs, assetManager);
});

// =============================================================================
// NEW CORE SERVICE PROVIDERS
// =============================================================================

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final commandStackProvider = Provider<CommandStack>((ref) {
  return InMemoryCommandStack();
});

final simulationEngineProvider = Provider<SimulationEngine>((ref) {
  return BasicSimulationEngine();
});

final netlistBuilderProvider = Provider<NetlistBuilder>((ref) {
  return NetlistBuilder();
});

final componentFactoryProvider = Provider<ComponentFactory>((ref) => ComponentFactory());

// =============================================================================
// EDUCATIONAL GAMING SERVICE PROVIDERS (retained for now)
// =============================================================================

// Level System Provider
final levelSystemProvider = Provider<LevelSystem>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableLevelSystem)) {
    throw UnsupportedError('Level system is not enabled');
  }
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return LevelSystem(sharedPrefs);
});

// Achievement System Provider
final achievementSystemProvider = Provider<AchievementSystem>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableAchievementSystem)) {
    throw UnsupportedError('Achievement system is not enabled');
  }
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AchievementSystem(sharedPrefs);
});

// Interactive Mechanics Provider
final interactiveMechanicsProvider = Provider<InteractiveMechanics>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableInteractiveMechanics)) {
    throw UnsupportedError('Interactive mechanics are not enabled');
  }
  return InteractiveMechanics();
});

// Hint System Provider
final hintSystemProvider = Provider<HintSystem>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableHintSystem)) {
    throw UnsupportedError('Hint system is not enabled');
  }
  return HintSystem();
});

// Animation System Provider
final animationSystemProvider = Provider<AnimationSystem>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
    throw UnsupportedError('Animation system is not enabled');
  }
  return AnimationSystem();
});

// Visual Feedback System Provider
final visualFeedbackSystemProvider = Provider<VisualFeedbackSystem>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableVisualFeedback)) {
    throw UnsupportedError('Visual feedback system is not enabled');
  }
  return VisualFeedbackSystem();
});

// Educational Validator Provider (Removed for now)
// final educationalValidatorProvider = Provider<EducationalValidator>((ref) {
//   if (!FeatureFlagService.isEnabled(FeatureFlag.enableEducationalContent)) {
//     throw UnsupportedError('Educational content is not enabled');
//   }
//   final simulationEngine = ref.watch(simulationEngineProvider);
//   return EducationalValidator(simulationEngine);
// });

// Learning Analytics Provider
final learningAnalyticsProvider = Provider<LearningAnalytics>((ref) {
  if (!FeatureFlagService.isEnabled(FeatureFlag.enableEducationalContent)) {
    throw UnsupportedError('Educational content is not enabled');
  }
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return LearningAnalytics(sharedPrefs);
});

// =============================================================================
// UNIFIED ENHANCED GAME STATE PROVIDER
// =============================================================================

final enhancedGameStateNotifierProvider =
    StateNotifierProvider<EnhancedGameStateNotifier, dynamic>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final commandStack = ref.watch(commandStackProvider);
  final simulationEngine = ref.watch(simulationEngineProvider);
  final netlistBuilder = ref.watch(netlistBuilderProvider);
  final componentFactory = ref.watch(componentFactoryProvider);

  // Pass all necessary dependencies to the notifier
  return EnhancedGameStateNotifier(
    storageService: storageService,
    commandStack: commandStack,
    simulationEngine: simulationEngine,
    netlistBuilder: netlistBuilder,
    componentFactory: componentFactory,
  );
});

// =============================================================================
// LEGACY PROVIDERS (preserved for compatibility, to be removed later)
// =============================================================================

final levelsProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(levelManagerProvider).levels;
});

final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
});

final levelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(levelManagerProvider).isLoading;
});

// Removed for now
// final levelDefinitionProvider =
//     FutureProvider.family<LevelDefinition?, int>((ref, levelIndex) async {
//   final levelManager = ref.watch(levelManagerProvider.notifier);
//   return await levelManager.loadLevelByIndex(levelIndex);
// });

final debugOverlayProvider = StateProvider<bool>((ref) => false);
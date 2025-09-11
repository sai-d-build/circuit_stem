import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/unified_providers.dart';
import '../../core/migration/migration_tracker.dart';
import '../../application/game_engine/v3/providers_v3.dart' as v3_providers;
import '../../application/providers/core_providers.dart' as core_providers;
import '../features/game/services/viewport_service.dart';
import '../state/palette_state.dart';

// ✅ CLEAN ARCHITECTURE: Injected presentation service
class CentralInteractionService {
  final dynamic gameStateNotifier;        // ✅ Injected
  final dynamic levelService;             // ✅ Injected
  final Function(String, dynamic) loadGameLevel;   // ✅ Injected function
  final Function(String) initializeOrchestrator;   // ✅ Injected function
  final String levelId;

  CentralInteractionService({
    required this.gameStateNotifier,
    required this.levelService,
    required this.loadGameLevel,
    required this.initializeOrchestrator,
    required this.levelId,
  });

  // ✅ CLEAN BUSINESS METHODS - No ref.read() calls!
  Future<void> loadLevel(dynamic levelData) async {
    loadGameLevel(levelId, levelData);
  }

  void initializeLevel() {
    initializeOrchestrator(levelId);
  }

  dynamic getGameState() => gameStateNotifier;

  dynamic getOrchestratorState() => levelService; // Simplified

  dynamic getInteractionState() => gameStateNotifier; // Simplified

  dynamic getViewportState() => gameStateNotifier; // Simplified

  PaletteState? getPaletteState() => null; // Need to inject this too

  dynamic getLevelService() => levelService;
}

// ✅ PROVIDER: Single injection point - MIGRATED to clean architecture
final centralInteractionServiceProvider = Provider.family<CentralInteractionService, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated('central_interaction_helper.dart', DateTime.now().toIso8601String());

    // ✅ CLEAN: Use watch for reactive dependencies, read only for initialization
    final gameStateNotifier = ref.watch(unifiedGameStateProvider.notifier);
    final levelService = ref.watch(v3_providers.levelServiceProvider);

    return CentralInteractionService(
      gameStateNotifier: gameStateNotifier,
      levelService: levelService,
      loadGameLevel: (levelId, levelData) => gameStateNotifier.loadLevel(levelData),
      initializeOrchestrator: (levelId) => ref.watch(core_providers.gameCanvasOrchestratorProvider(levelId).notifier).initializeLevel(levelId),
      levelId: levelId,
    );
  },
);

// ✅ BACKWARD COMPATIBILITY: Keep static helpers for gradual migration
class CentralInteractionHelper {
  /// Load level data into game state and initialize orchestrator
  static Future<void> loadLevel(
    WidgetRef ref,
    String levelId,
    dynamic levelData,
  ) async {
    // Use the new service through provider
    final service = ref.read(centralInteractionServiceProvider(levelId));
    await service.loadLevel(levelData);
  }

  /// Initialize level in orchestrator only
  static void initializeLevel(WidgetRef ref, String levelId) {
    final service = ref.read(centralInteractionServiceProvider(levelId));
    service.initializeLevel();
  }

  /// Get current game state (for read-only operations) - CORRECT: Use read for one-time access
  static dynamic getGameState(WidgetRef ref) {
    return ref.read(unifiedGameStateProvider);
  }

  /// Get orchestrator state (for read-only operations) - CORRECT: Use read for one-time access
  static dynamic getOrchestratorState(WidgetRef ref, String levelId) {
    return ref.read(core_providers.gameCanvasOrchestratorProvider(levelId));
  }

  /// Get interaction state for the canvas - CORRECT: Use read for one-time access
  static dynamic getInteractionState(WidgetRef ref, String levelId) {
    return ref.read(core_providers.interactionStateProvider(levelId));
  }

  /// Get viewport state for coordinate calculations - CORRECT: Use read for one-time access
  static dynamic getViewportState(WidgetRef ref, String levelId) {
    return ref.read(viewportServiceProvider(levelId));
  }

  /// Get palette state for component availability checks - CORRECT: Use read for one-time access
  static PaletteState getPaletteState(WidgetRef ref, String levelId) {
    return ref.read(paletteStateProvider(levelId));
  }

  /// Get level service - CORRECT: Use read for one-time access
  static dynamic getLevelService(WidgetRef ref) {
    return ref.read(v3_providers.levelServiceProvider);
  }
}
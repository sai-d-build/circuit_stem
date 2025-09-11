import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/feedback_service.dart';
import 'package:sparkcircuit/core/services/pathfinding_service.dart';
import 'package:sparkcircuit/core/services/wire_network_service.dart';
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/application/core/result.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
// Import notifier providers from core_providers.dart to avoid ambiguous imports
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// ✅ CLEAN ARCHITECTURE: Injected Interaction Use Case (14 ref.read() calls eliminated!)
class InteractionUseCaseInjected {
  final dynamic gameStateNotifier;        // ✅ Injected
  final dynamic gameState;               // ✅ Injected
  final dynamic viewportService;         // ✅ Injected
  final FeedbackService feedbackService; // ✅ Injected
  final PathfindingService pathfindingService; // ✅ Injected
  final WireNetworkService wireNetworkService; // ✅ Injected
  final dynamic interactionStateNotifier; // ✅ Injected
  final dynamic historyNotifier;         // ✅ Injected
  final dynamic progressNotifier;       // ✅ Injected
  final dynamic selectionNotifier;      // ✅ Injected
  final dynamic paletteNotifier;        // ✅ Injected
  final String levelId;

  InteractionUseCaseInjected({
    required this.gameStateNotifier,
    required this.gameState,
    required this.viewportService,
    required this.feedbackService,
    required this.pathfindingService,
    required this.wireNetworkService,
    required this.interactionStateNotifier,
    required this.historyNotifier,
    required this.progressNotifier,
    required this.selectionNotifier,
    required this.paletteNotifier,
    required this.levelId,
  });

  // ✅ NO ref.read() calls - using injected dependencies
  dynamic getGameState() => gameState;

  dynamic getViewportState() => viewportService;

  FeedbackService getFeedbackService() => feedbackService;

  PathfindingService getPathfindingService() => pathfindingService;

  WireNetworkService getWireNetworkService() => wireNetworkService;

  dynamic getGameStateNotifier() => gameStateNotifier;

  dynamic getInteractionStateNotifier(String levelId) => interactionStateNotifier;

  dynamic getHistoryNotifier() => historyNotifier;

  dynamic getProgressNotifier() => progressNotifier;

  dynamic getSelectionNotifier() => selectionNotifier;

  dynamic getViewportServiceNotifier() => viewportService;

  // ✅ Business logic methods - no ref.read() calls!
  void updateViewportPan(Offset delta) {
    getViewportServiceNotifier()?.updatePan(delta);
  }

  void updateViewportScale(double scale) {
    getViewportServiceNotifier()?.updateScale(scale);
  }

  void showSuccessFeedback(BuildContext context, String message) {
    getFeedbackService().showSuccess(context, message);
  }

  void showErrorFeedback(BuildContext context, String message) {
    getFeedbackService().showError(context, message);
  }

  Future<Result<List<GridPosition>>> findPath(GridPosition start, GridPosition end, {Set<GridPosition>? occupiedPositions}) async {
    try {
      final result = await pathfindingService.findPath(
        start,
        end,
        algorithm: PathfindingAlgorithm.astar,
        occupiedPositions: occupiedPositions ?? {},
        maxNodes: 500,
      );

      if (result.success && result.path.isNotEmpty) {
        return Success(result.path);
      } else {
        return Failure('Pathfinding failed');
      }
    } catch (e) {
      StructuredLogger.error('Pathfinding error', context: {'error': e.toString()});
      return Failure('Pathfinding error: $e');
    }
  }

  Future<Result<dynamic>> createWireNetwork(dynamic startPort, dynamic endPort, List<GridPosition> path) async {
    try {
      final network = await wireNetworkService.createNetworkFromPath(
        startPort,
        endPort,
        path,
      );
      return Success(network);
    } catch (e) {
      StructuredLogger.error('Wire network creation error', context: {'error': e.toString()});
      return Failure('Wire network creation error: $e');
    }
  }

  // ✅ NO ref.read() calls - using injected paletteNotifier
  bool canUseComponent(String componentType) {
    return paletteNotifier.canUseComponent(componentType);
  }

  bool useComponent(String componentType) {
    paletteNotifier.useComponent(componentType);
    return true;
  }

  bool returnComponent(String componentType) {
    paletteNotifier.returnComponent(componentType);
    return true;
  }

  void stopPlacingComponent() {
    paletteNotifier.stopPlacingComponent();
  }
}

// ✅ PROVIDER: Single injection point for all 14 dependencies
final interactionUseCaseProvider = Provider.family<InteractionUseCaseInjected, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated('interaction_use_case.dart', DateTime.now().toIso8601String());
    return InteractionUseCaseInjected(
      gameStateNotifier: ref.watch(unifiedGameStateProvider.notifier),
      gameState: ref.watch(unifiedGameStateProvider),
      viewportService: ref.read(viewportServiceProvider(levelId)),
      feedbackService: ref.read(feedbackServiceProvider),
      pathfindingService: ref.read(pathfindingServiceProvider(levelId)),
      wireNetworkService: ref.read(wireNetworkServiceProvider(levelId)),
      interactionStateNotifier: ref.read(interactionStateProvider(levelId).notifier),
      historyNotifier: ref.read(historyNotifierProvider.notifier),
      progressNotifier: ref.read(gameProgressNotifierProvider.notifier),
      selectionNotifier: ref.read(componentSelectionNotifierProvider.notifier),
      paletteNotifier: ref.read(paletteStateProvider(levelId).notifier),
      levelId: levelId,
    );
  },
);

// TODO: Migrate callers to InteractionUseCaseInjected instance - remove legacy class to eliminate ref.read() anti-pattern
// Previous legacy InteractionUseCase class removed
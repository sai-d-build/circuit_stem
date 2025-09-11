import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/unified_providers.dart';
import '../../core/migration/migration_tracker.dart';
import '../../presentation/state/palette_state.dart';
import '../providers/game_canvas_providers.dart' as canvas_providers;
import '../providers/core_providers.dart';
import '../core/result.dart';
import '../../core/debug/structured_logger.dart';

// ✅ CLEAN ARCHITECTURE: Proper use case with dependency injection
class ComponentInteractionUseCase {
  final dynamic gameNotifier;          // ✅ Injected
  final dynamic interactionNotifier;   // ✅ Injected
  final dynamic paletteNotifier;       // ✅ Injected
  final dynamic gestureNotifier;       // ✅ Injected
  final String levelId;

  ComponentInteractionUseCase({
    required this.gameNotifier,
    required this.interactionNotifier,
    required this.paletteNotifier,
    required this.gestureNotifier,
    required this.levelId,
  });

  // ✅ BUSINESS METHODS with no ref.read() calls
  Result<void> handleComponentTap(String componentId) {
    try {
      gameNotifier.tapComponent(componentId);
      return const Success(null);
    } catch (e) {
      return Failure('Tap failed: $e');
    }
  }

  Result<void> handleComponentDragStart(String componentId, Offset position) {
    StructuredLogger.info('🎯 USE CASE: DRAG START', context: {
      'componentId': componentId,
      'position': position.toString(),
      'levelId': levelId,
      'gameNotifierType': gameNotifier.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      gameNotifier.startDragging(componentId, position);
      StructuredLogger.info('✅ USE CASE: DRAG START SUCCESS', context: {
        'componentId': componentId,
        'levelId': levelId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return const Success(null);
    } catch (e, stackTrace) {
      StructuredLogger.error('💥 USE CASE: DRAG START FAILED', context: {
        'componentId': componentId,
        'position': position.toString(),
        'levelId': levelId,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }, error: e);
      return Failure('Drag start failed: $e');
    }
  }

  Result<void> handleComponentDragUpdate(Offset position) {
    StructuredLogger.debug('🔄 USE CASE: DRAG UPDATE', context: {
      'position': position.toString(),
      'levelId': levelId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      gameNotifier.dragUpdate(position);
      return const Success(null);
    } catch (e, stackTrace) {
      StructuredLogger.error('💥 USE CASE: DRAG UPDATE FAILED', context: {
        'position': position.toString(),
        'levelId': levelId,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }, error: e);
      return Failure('Drag update failed: $e');
    }
  }

  Result<void> handleComponentDragEnd() {
    StructuredLogger.info('🏁 USE CASE: DRAG END', context: {
      'levelId': levelId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      gameNotifier.endDragging();
      StructuredLogger.info('✅ USE CASE: DRAG END SUCCESS', context: {
        'levelId': levelId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return const Success(null);
    } catch (e, stackTrace) {
      StructuredLogger.error('💥 USE CASE: DRAG END FAILED', context: {
        'levelId': levelId,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }, error: e);
      return Failure('Drag end failed: $e');
    }
  }

  // ✅ Additional pure methods without ref.read()
  Result<void> handleComponentRotation(String componentId) {
    try {
      gameNotifier.rotateComponent(componentId);
      return const Success(null);
    } catch (e) {
      return Failure('Rotation failed: $e');
    }
  }

  Result<void> handleComponentDeletion(String componentId) {
    try {
      gameNotifier.removeComponent(componentId);
      return const Success(null);
    } catch (e) {
      return Failure('Deletion failed: $e');
    }
  }
}

// ✅ DEPENDENCY INJECTION PROVIDER
final componentInteractionUseCaseProvider = Provider.family<ComponentInteractionUseCase, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated('component_interaction_use_case.dart', DateTime.now().toIso8601String());
    return ComponentInteractionUseCase(
      gameNotifier: ref.read(unifiedGameStateProvider.notifier),
      interactionNotifier: ref.read(interactionStateProvider(levelId).notifier),
      paletteNotifier: ref.read(paletteStateProvider(levelId).notifier),
      gestureNotifier: ref.read(canvas_providers.gameCanvasOrchestratorProvider(levelId).notifier),
      levelId: levelId,
    );
  },
);

  // TODO: Migrate callers to ComponentInteractionUseCase instance - remove static helpers to eliminate ref.read() anti-pattern
  // Previous backward compatibility classes (ComponentInteractionHelper, PaletteManagementHelper, GestureManagementHelper) removed
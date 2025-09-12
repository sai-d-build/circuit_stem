import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug/structured_logger.dart';
import '../../../core/interfaces/game_state_notifier_interface.dart';
import '../../../core/migration/notifier_migration_controller.dart';
import '../../../application/states/game_state.dart';

// Exports for backward compatibility
export '../game_engine/v3/game_engine_notifier_v3.dart';
export '../enhanced_game_state_notifier.dart';

// ============================================================================
// UNIFIED PROVIDER SYSTEM - Game State Notifier Consolidation
// ============================================================================
// This file implements the consolidation layer for the Game State Notifier system
// as specified in the consolidation plan (docs/GAME_STATE_NOTIFIER_CONSOLIDATION_PLAN.md)
//
// Goals:
// - Provide unified access to game state management
// - Support feature flags for gradual migration
// - Maintain backward compatibility
// - Enable future Riverpod modernization

// Use the existing NotifierMigrationController from the migration infrastructure


/// Unified Game State Provider - Main Consolidation Point
/// This replaces the direct usage of individual notifiers in the consolidation plan
final unifiedGameStateProvider = StateNotifierProvider<IGameStateNotifier, GameState>((ref) {
  // ProviderRef no longer needs to be cast - ref is now the correct type
  StructuredLogger.debug('🔍 Ref type in unifiedGameStateProvider', context: {
    'refType': ref.runtimeType.toString(),
    'timestamp': DateTime.now().toIso8601String(),
  });
  final notifier = NotifierMigrationController.createNotifier(ref);

  StructuredLogger.debug('Unified provider created', context: {
    'notifier_type': notifier.runtimeType.toString(),
    'timestamp': DateTime.now().toIso8601String(),
  });

  return notifier;
});

// Adapters are implemented in separate files:
// - lib/application/adapters/enhanced_notifier_adapter.dart
// - lib/application/adapters/v3_notifier_adapter.dart

// ============================================================================
// BACKWARD COMPATIBILITY ALIASES
// ============================================================================
// These allow existing code to continue working during the migration period

@Deprecated('Use unifiedGameStateProvider instead. Will be removed in v2.0')
IGameStateNotifier createCompatibleNotifier(Ref ref) {
  StructuredLogger.info('Using deprecated createCompatibleNotifier - migrate to unifiedGameStateProvider');
  return NotifierMigrationController.createNotifier(ref);
}
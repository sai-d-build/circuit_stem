import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/adapters/enhanced_notifier_adapter.dart';
import 'package:sparkcircuit/application/adapters/v3_notifier_adapter.dart';
// Import providers from core_providers.dart to avoid duplication
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/interfaces/game_state_notifier_interface.dart';
import 'package:sparkcircuit/core/services/feature_flag_service.dart';

/// Controls migration between different game state notifier implementations
class NotifierMigrationController {
  static IGameStateNotifier createNotifier(Ref ref) {
    if (FeatureFlagService.instance
        .getBool('use_enhanced_notifier_primary', defaultValue: true)) {
      // Use Enhanced implementation as primary
      final enhancedNotifier =
          ref.watch(enhancedGameStateNotifierProvider.notifier);
      return EnhancedNotifierAdapter(enhancedNotifier);
    } else {
      // Use V3 implementation as primary
      final v3Notifier = ref.watch(gameEngineNotifierV3Provider.notifier);
      return V3NotifierAdapter(v3Notifier);
    }
  }

  static bool get useEnhancedAsPrimary => FeatureFlagService.instance
      .getBool('use_enhanced_notifier_primary', defaultValue: true);

  static void switchToEnhanced() {
    FeatureFlagService.instance.setFlag('use_enhanced_notifier_primary', true);
  }

  static void switchToV3() {
    FeatureFlagService.instance.setFlag('use_enhanced_notifier_primary', false);
  }
}

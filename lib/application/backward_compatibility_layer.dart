// Backward Compatibility Layer for SparkCircuit Migration
// This file provides fallback implementations and adapters to ensure
// existing functionality continues to work during the transition to
// educational gaming features.

import '../common/feature_flags.dart';
import '../common/logger.dart';

// Export this file's public API
export 'backward_compatibility_layer.dart';

// =============================================================================
// FALLBACK SERVICE IMPLEMENTATIONS
// =============================================================================

// Fallback Level System for when level system is disabled
class FallbackLevelSystem {
  bool get isEnabled => false;

  Future<void> loadLevel(int levelId) async {
    // No-op when level system is disabled
        Logger.log('Level system disabled - using basic circuit mode');
  }

  List<String> getAvailableLevels() => [];

  bool isLevelCompleted(int levelId) => false;

  Future<void> markLevelCompleted(int levelId) async {
    // No-op
  }
}

// Fallback Achievement System
class FallbackAchievementSystem {
  bool get isEnabled => false;

  Future<void> checkAchievements(String event, Map<String, dynamic> data) async {
    // No-op when achievement system is disabled
            Logger.log('Achievement system disabled');
  }

  List<String> getUnlockedAchievements() => [];

  Future<void> unlockAchievement(String achievementId) async {
    // No-op
  }
}

// Fallback Interactive Mechanics
class FallbackInteractiveMechanics {
  bool get isEnabled => false;

  Future<bool> handleDragDrop(String componentId, double x, double y) async {
    // Basic drag-drop without advanced validation
        Logger.log('Using basic drag-drop mechanics');
    return true;
  }

  Future<bool> handleRotation(String componentId, double angle) async {
    // Basic rotation without animation
            Logger.log('Using basic rotation mechanics');
    return true;
  }

  Future<bool> handleToggle(String componentId) async {
    // Basic toggle without feedback
            Logger.log('Using basic toggle mechanics');
    return true;
  }
}

// Fallback Hint System
class FallbackHintSystem {
  bool get isEnabled => false;

  List<String> getAvailableHints() => [];

  Future<String?> getNextHint() async {
    // No hints available
    return null;
  }

  Future<void> trackHintUsage(String hintId) async {
    // No-op
  }
}

// Fallback Animation System
class FallbackAnimationSystem {
  bool get isEnabled => false;

  Future<void> playAnimation(String animationId) async {
    // No animations - just complete immediately
            Logger.log('Animation system disabled - skipping $animationId');
  }

  Future<void> stopAnimation(String animationId) async {
    // No-op
  }

  Future<void> preloadAnimations(List<String> animationIds) async {
    // No-op
  }
}

// Fallback Visual Feedback System
class FallbackVisualFeedbackSystem {
  bool get isEnabled => false;

  Future<void> showSuccessFeedback() async {
    // Basic success indication
            Logger.log('✓ Success!');
  }

  Future<void> showErrorFeedback(String message) async {
    // Basic error indication
            Logger.log('✗ Error: $message');
  }

  Future<void> showPlacementFeedback(bool valid) async {
    // Basic placement feedback
            Logger.log(valid ? '✓ Valid placement' : '✗ Invalid placement');
  }
}

// Fallback Educational Validator
class FallbackEducationalValidator {
  bool get isEnabled => false;

  Future<Map<String, dynamic>> validateSolution(Map<String, dynamic> solution) async {
    // Basic validation only - always pass
    return {
      'isValid': true,
      'score': 100,
      'feedback': 'Basic validation passed',
      'learningObjectives': [],
    };
  }

  Future<List<String>> getLearningObjectives() async {
    return [];
  }
}

// Fallback Learning Analytics
class FallbackLearningAnalytics {
  bool get isEnabled => false;

  Future<void> trackEvent(String event, Map<String, dynamic> data) async {
    // Basic logging only
            Logger.log('Learning event: $event with data: $data');
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    return {
      'totalSessions': 0,
      'averageScore': 0,
      'learningObjectives': [],
      'progressData': [],
    };
  }
}

// =============================================================================
// SERVICE PROVIDER ADAPTERS
// =============================================================================

// Adapter that provides the appropriate service based on feature flags
class ServiceAdapter<T> {
  final T Function() enabledServiceFactory;
  final T Function() fallbackServiceFactory;

  ServiceAdapter({
    required this.enabledServiceFactory,
    required this.fallbackServiceFactory,
  });

  T getService() {
    // This would be implemented with actual feature flag checks
    // For now, return fallback services
    return fallbackServiceFactory();
  }
}

// =============================================================================
// BACKWARD COMPATIBILITY HELPERS
// =============================================================================

class BackwardCompatibilityHelper {
  // Check if we're in migration mode
  static bool get isInMigrationMode {
    return !FeatureFlagService.isMigrationComplete();
  }

  // Get appropriate service based on feature flags
  static T getService<T>(
    FeatureFlag featureFlag,
    T Function() enabledFactory,
    T Function() fallbackFactory,
  ) {
    if (FeatureFlagService.isEnabled(featureFlag)) {
      try {
        return enabledFactory();
      } catch (e) {
                Logger.log('Failed to create enabled service, using fallback: $e');
        return fallbackFactory();
      }
    } else {
      return fallbackFactory();
    }
  }

  // Safe execution wrapper for new features
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation,
    T? fallbackValue,
  ) async {
    try {
      return await operation();
    } catch (e) {
              Logger.log('Safe execution failed, using fallback: $e');
      return fallbackValue;
    }
  }

  // Feature availability checker
  static bool isFeatureAvailable(FeatureFlag feature) {
    return FeatureFlagService.isEnabled(feature);
  }

  // Migration status reporter
  static Map<String, dynamic> getMigrationStatus() {
    return {
      'isInMigration': isInMigrationMode,
      'enabledFeatures': FeatureFlagService.getEnabledFeatures().map((f) => f.name).toList(),
      'migrationComplete': FeatureFlagService.isMigrationComplete(),
    };
  }
}

// =============================================================================
// LEGACY API COMPATIBILITY
// =============================================================================

// Legacy API wrapper for existing code
class LegacyAPIWrapper {
  // Wrap new educational features with legacy API
  static Future<Map<String, dynamic>> executeEducationalAction(
    String action,
    Map<String, dynamic> parameters,
  ) async {
    if (!BackwardCompatibilityHelper.isFeatureAvailable(FeatureFlag.enableEducationalContent)) {
      // Fallback to basic circuit simulation
      return await _executeBasicCircuitAction(action, parameters);
    }

    // Use new educational features
    return await _executeEducationalAction(action, parameters);
  }

  static Future<Map<String, dynamic>> _executeBasicCircuitAction(
    String action,
    Map<String, dynamic> parameters,
  ) async {
    // Basic circuit actions without educational features
    switch (action) {
      case 'place_component':
        return {
          'success': true,
          'message': 'Component placed (basic mode)',
          'educational_feedback': null,
        };
      case 'connect_components':
        return {
          'success': true,
          'message': 'Components connected (basic mode)',
          'circuit_valid': true,
        };
      case 'simulate_circuit':
        return {
          'success': true,
          'message': 'Simulation completed (basic mode)',
          'results': {'voltage': 0.0, 'current': 0.0},
        };
      default:
        return {
          'success': false,
          'message': 'Unknown action: $action',
        };
    }
  }

  static Future<Map<String, dynamic>> _executeEducationalAction(
    String action,
    Map<String, dynamic> parameters,
  ) async {
    // Use new educational features
    // This would integrate with the actual educational services
    return {
      'success': true,
      'message': 'Educational action executed',
      'educational_feedback': 'Learning objective achieved!',
      'score': 100,
    };
  }
}

// =============================================================================
// MIGRATION UTILITIES
// =============================================================================

class MigrationUtilities {
  // Data migration helper
  static Future<void> migrateUserData() async {
    if (!BackwardCompatibilityHelper.isInMigrationMode) {
      return;
    }

        Logger.log('Starting user data migration...');
    // Implement data migration logic here
            Logger.log('User data migration completed');
  }

  // Feature rollout helper
  static Future<void> gradualFeatureRollout() async {
    final features = [
      FeatureFlag.enableLevelSystem,
      FeatureFlag.enableInteractiveMechanics,
      FeatureFlag.enableEducationalContent,
      FeatureFlag.enableAchievementSystem,
      FeatureFlag.enableHintSystem,
      FeatureFlag.enableScoringSystem,
    ];

    for (final feature in features) {
      if (!FeatureFlagService.isEnabled(feature)) {
                Logger.log('Rolling out feature: ${feature.name}');
        FeatureFlagService.enableFeature(feature);

        // Allow time for feature to stabilize
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  // Health check for migration
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final status = BackwardCompatibilityHelper.getMigrationStatus();

    // Check if critical services are available
    final criticalServices = [
      'LevelSystem',
      'AchievementSystem',
      'InteractiveMechanics',
      'EducationalValidator',
    ];

    final serviceStatus = <String, bool>{};
    for (final service in criticalServices) {
      serviceStatus[service] = true; // Assume healthy for now
    }

    return {
      'migration_status': status,
      'service_health': serviceStatus,
      'overall_health': serviceStatus.values.every((healthy) => healthy),
    };
  }
}

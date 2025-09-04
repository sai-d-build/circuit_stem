// Feature flag system for gradual rollout of educational gaming features

import 'package:sparkcircuit/core/debug/structured_logger.dart';

enum FeatureFlag {
  // Architecture migration flags
  useUnifiedStateManagement,
  useNewSimulationEngine,
  useEnhancedUI,
  enablePerformanceMonitoring,

  // Educational gaming flags
  enableLevelSystem,
  enableAchievementSystem,
  enableInteractiveMechanics,
  enableEducationalContent,
  enableHintSystem,
  enableScoringSystem,
  enableMultipleSolutions,

  // Animation and visual effects flags
  enableAnimations,
  enableParticleEffects,
  enableVisualFeedback,
  enableRiveAnimations,
  enableLottieAnimations,

  // Performance optimization flags
  enableQualityAdjustment,
  enableMemoryOptimization,
  migrationComplete,
}

class FeatureFlagService {
  static bool isEnabled(FeatureFlag flag) {
    // Check compile-time and runtime flags
    switch (flag) {
      // Architecture flags - enable for development
      case FeatureFlag.useUnifiedStateManagement:
        return true;
      case FeatureFlag.useNewSimulationEngine:
        return false; // Keep old simulation during migration
      case FeatureFlag.useEnhancedUI:
        return true;
      case FeatureFlag.enablePerformanceMonitoring:
        return true;

      // Educational gaming flags - gradual rollout
      case FeatureFlag.enableLevelSystem:
        return true; // Enable level progression
      case FeatureFlag.enableAchievementSystem:
        return false; // Roll out gradually
      case FeatureFlag.enableInteractiveMechanics:
        return true; // Enable drag-and-drop, rotation
      case FeatureFlag.enableEducationalContent:
        return true; // Enable learning objectives
      case FeatureFlag.enableHintSystem:
        return false; // Enable after level validation
      case FeatureFlag.enableScoringSystem:
        return true; // Enable basic scoring
      case FeatureFlag.enableMultipleSolutions:
        return false; // Advanced feature, enable later

      // Animation and visual effects flags
      case FeatureFlag.enableAnimations:
        return true; // Enable rich animations
      case FeatureFlag.enableParticleEffects:
        return false; // Enable particle systems
      case FeatureFlag.enableVisualFeedback:
        return true; // Enable visual feedback
      case FeatureFlag.enableRiveAnimations:
        return false; // Enable Rive animations
      case FeatureFlag.enableLottieAnimations:
        return false; // Enable Lottie animations

      // Performance optimization flags
      case FeatureFlag.enableQualityAdjustment:
        return true; // Enable quality adjustment
      case FeatureFlag.enableMemoryOptimization:
        return true; // Enable memory optimization
      case FeatureFlag.migrationComplete:
        return false; // Migration completion flag
    }
  }

  // Get all enabled features for debugging
  static List<FeatureFlag> getEnabledFeatures() {
    return FeatureFlag.values.where(isEnabled).toList();
  }

  // Runtime flag storage
  static final Map<FeatureFlag, bool> _runtimeFlags = {};

  // Enable feature at runtime
  static void enableFeature(FeatureFlag flag) {
    _runtimeFlags[flag] = true;
    _persistFlag(flag, true);
    _logFeatureChange(flag, true);
  }

  // Disable feature at runtime
  static void disableFeature(FeatureFlag flag) {
    _runtimeFlags[flag] = false;
    _persistFlag(flag, false);
    _logFeatureChange(flag, false);
  }

  // Enable all educational features
  static void enableAllEducationalFeatures() {
    final educationalFlags = [
      FeatureFlag.enableLevelSystem,
      FeatureFlag.enableAchievementSystem,
      FeatureFlag.enableInteractiveMechanics,
      FeatureFlag.enableEducationalContent,
      FeatureFlag.enableHintSystem,
      FeatureFlag.enableScoringSystem,
      FeatureFlag.enableMultipleSolutions,
    ];

    for (final flag in educationalFlags) {
      enableFeature(flag);
    }
  }

  // Disable all educational features
  static void disableAllEducationalFeatures() {
    final educationalFlags = [
      FeatureFlag.enableLevelSystem,
      FeatureFlag.enableAchievementSystem,
      FeatureFlag.enableInteractiveMechanics,
      FeatureFlag.enableEducationalContent,
      FeatureFlag.enableHintSystem,
      FeatureFlag.enableScoringSystem,
      FeatureFlag.enableMultipleSolutions,
    ];

    for (final flag in educationalFlags) {
      disableFeature(flag);
    }
  }


  // Persist flag to storage
  static void _persistFlag(FeatureFlag flag, bool value) {
    // TODO: Access storage service - this needs to be injected or accessed via provider
    // For now, use a simple approach that can be enhanced later
    try {
      // This is a temporary implementation - should be replaced with proper dependency injection
      // when the feature flag service is integrated with the provider system
      StructuredLogger.debug('Persisting feature flag to storage', context: {
        'flagName': flag.name,
        'targetValue': value.toString(),
        'persistentStorage': true,
        'implementationStatus': 'placeholder_needs_integration',
      });
      // Future enhancement: Use storageService.saveData('feature_flag_${flag.name}', value);
    } catch (e) {
      StructuredLogger.error('Failed to persist feature flag', context: {
        'flagName': flag.name,
        'targetValue': value.toString(),
        'error': e.toString(),
      }, error: e);
    }
  }

  // Log feature flag changes
  static void _logFeatureChange(FeatureFlag flag, bool enabled) {
    StructuredLogger.info('Feature flag toggled', context: {
      'flagName': flag.name,
      'newState': enabled ? 'enabled' : 'disabled',
      'timestamp': DateTime.now().toIso8601String(),
      'changeType': enabled ? 'rollout' : 'rollback',
    });
  }

  // Check if migration is complete
  static bool isMigrationComplete() {
    return isEnabled(FeatureFlag.useNewSimulationEngine) &&
           isEnabled(FeatureFlag.enableAchievementSystem) &&
           isEnabled(FeatureFlag.enableHintSystem) &&
           isEnabled(FeatureFlag.enableMultipleSolutions) &&
           isEnabled(FeatureFlag.migrationComplete);
  }
}

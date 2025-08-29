import '../common/feature_flags.dart';

/// Runtime feature flag service for dynamic control and gradual rollouts.
/// 
/// This service complements the compile-time FeatureFlags by providing:
/// - Runtime flag overrides
/// - Gradual rollout capabilities
/// - A/B testing support
/// - Remote configuration integration
/// 
/// The service respects compile-time flags as the base configuration,
/// then applies runtime overrides for specific users or rollout percentages.
class FeatureFlagService {
  static final Map<String, bool> _runtimeFlags = {};
  static final Map<String, double> _rolloutPercentages = {};
  static String? _userId;
  static bool _initialized = false;

  /// Initialize the service with optional user identification for targeted rollouts.
  static void initialize({String? userId}) {
    _userId = userId;
    _initialized = true;
    
    // Set default rollout percentages
    _rolloutPercentages.putIfAbsent('hybrid_engine', () => 0.0);
    _rolloutPercentages.putIfAbsent('granular_providers', () => 0.0);
    _rolloutPercentages.putIfAbsent('performance_monitoring', () => 0.0);
  }

  /// Check if a feature flag is enabled, considering both compile-time and runtime settings.
  /// 
  /// Priority order:
  /// 1. Runtime override (if set)
  /// 2. Rollout percentage (if user is in rollout group)
  /// 3. Compile-time flag (base setting)
  static bool isEnabled(String flagName) {
    if (!_initialized) {
      throw StateError('FeatureFlagService must be initialized before use');
    }

    // Check runtime override first
    if (_runtimeFlags.containsKey(flagName)) {
      return _runtimeFlags[flagName]!;
    }

    // Check rollout percentage
    if (_rolloutPercentages.containsKey(flagName) && _userId != null) {
      final rolloutPercentage = _rolloutPercentages[flagName]!;
      if (_isUserInRollout(_userId!, flagName, rolloutPercentage)) {
        return true;
      }
    }

    // Fall back to compile-time flags
    return _getCompileTimeFlag(flagName);
  }

  /// Set a runtime flag override. This bypasses rollout percentages.
  static void setFlag(String flagName, bool value) {
    _runtimeFlags[flagName] = value;
  }

  /// Clear a runtime flag override, falling back to rollout/compile-time logic.
  static void clearFlag(String flagName) {
    _runtimeFlags.remove(flagName);
  }

  /// Set rollout percentage for gradual feature deployment (0.0 to 1.0).
  /// 
  /// Example: setRolloutPercentage('hybrid_engine', 0.1) enables for 10% of users.
  static void setRolloutPercentage(String flagName, double percentage) {
    if (percentage < 0.0 || percentage > 1.0) {
      throw ArgumentError('Rollout percentage must be between 0.0 and 1.0');
    }
    _rolloutPercentages[flagName] = percentage;
  }

  /// Get current rollout percentage for a flag.
  static double getRolloutPercentage(String flagName) {
    return _rolloutPercentages[flagName] ?? 0.0;
  }

  /// Load feature flags from remote configuration.
  /// This would typically integrate with Firebase Remote Config, Launch Darkly, etc.
  static Future<void> loadFromRemoteConfig() async {
    // TODO: Integrate with your remote config service
    // Example implementation for Firebase Remote Config:
    /*
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();
      
      setRolloutPercentage('hybrid_engine', 
        remoteConfig.getDouble('hybrid_engine_rollout_percentage'));
      setRolloutPercentage('granular_providers',
        remoteConfig.getDouble('granular_providers_rollout_percentage'));
      setRolloutPercentage('performance_monitoring',
        remoteConfig.getDouble('performance_monitoring_rollout_percentage'));
    } catch (e) {
      // Log error but don't crash - fall back to defaults
    }
    */
  }

  /// Get all current flag states for debugging and monitoring.
  static Map<String, dynamic> getAllFlags() {
    return {
      'compile_time_flags': FeatureFlags.currentFlags,
      'runtime_overrides': Map.from(_runtimeFlags),
      'rollout_percentages': Map.from(_rolloutPercentages),
      'user_id': _userId,
      'effective_flags': {
        'hybrid_engine': isEnabled('hybrid_engine'),
        'granular_providers': isEnabled('granular_providers'),
        'performance_monitoring': isEnabled('performance_monitoring'),
        'hybrid_debug_logs': isEnabled('hybrid_debug_logs'),
        'transaction_debug': isEnabled('transaction_debug'),
      },
    };
  }

  /// Emergency rollback: disable all experimental features immediately.
  static void emergencyRollback() {
    setFlag('hybrid_engine', false);
    setFlag('granular_providers', false);
    setFlag('performance_monitoring', false);
    
    // Clear rollout percentages
    _rolloutPercentages.clear();
    _rolloutPercentages['hybrid_engine'] = 0.0;
    _rolloutPercentages['granular_providers'] = 0.0;
    _rolloutPercentages['performance_monitoring'] = 0.0;
  }

  /// Convenient methods for specific feature checks.
  static bool get useHybridEngine => isEnabled('hybrid_engine');
  static bool get enableGranularProviders => isEnabled('granular_providers');
  static bool get enablePerformanceMonitoring => isEnabled('performance_monitoring');
  static bool get enableHybridDebugLogs => isEnabled('hybrid_debug_logs');
  static bool get enableTransactionDebug => isEnabled('transaction_debug');

  /// Check if hybrid system is fully enabled (both hybrid engine and granular providers).
  static bool get isHybridFullyEnabled => 
      useHybridEngine && enableGranularProviders;

  // Private helper methods

  /// Determine if a user is in the rollout group based on consistent hashing.
  static bool _isUserInRollout(String userId, String flagName, double percentage) {
    if (percentage <= 0.0) return false;
    if (percentage >= 1.0) return true;

    // Use consistent hashing to ensure same user always gets same result
    final hashInput = '$userId:$flagName';
    final hash = hashInput.hashCode.abs();
    final userPercentile = (hash % 10000) / 10000.0; // 0.0 to 1.0
    
    return userPercentile < percentage;
  }

  /// Get compile-time flag value by name.
  static bool _getCompileTimeFlag(String flagName) {
    switch (flagName) {
      case 'hybrid_engine':
        return FeatureFlags.useHybridEngine;
      case 'granular_providers':
        return FeatureFlags.enableGranularProviders;
      case 'performance_monitoring':
        return FeatureFlags.enablePerformanceMonitoring;
      case 'hybrid_debug_logs':
        return FeatureFlags.enableHybridDebugLogs;
      case 'transaction_debug':
        return FeatureFlags.enableTransactionDebug;
      default:
        return false;
    }
  }
}
/// Feature flags for controlling hybrid engine rollout and other experimental features.
/// 
/// This system supports both compile-time and runtime feature flags for maximum flexibility.
/// Compile-time flags use --dart-define for build-time control.
/// Runtime flags can be updated dynamically for gradual rollouts.
class FeatureFlags {
  /// Enable the hybrid GameEngine architecture instead of the original monolithic GameEngineNotifier.
  /// 
  /// When enabled, the system uses:
  /// - GameEngineOrchestrator for atomic transactions
  /// - Granular notifiers (Grid, History, Progress, Selection, Interaction)
  /// - HybridGameEngineAdapter for backward compatibility
  /// 
  /// Usage:
  /// - Build with hybrid ON: flutter build --dart-define=USE_HYBRID_ENGINE=true
  /// - Build with hybrid OFF: flutter build --dart-define=USE_HYBRID_ENGINE=false (default)
  static const bool useHybridEngine = bool.fromEnvironment(
    'USE_HYBRID_ENGINE',
    defaultValue: false,
  );

  /// Enable performance monitoring to track UI rebuilds and action execution times.
  /// 
  /// When enabled:
  /// - Tracks widget rebuild frequency
  /// - Measures action execution latency
  /// - Collects memory usage metrics
  /// - Provides monitoring dashboard
  static const bool enablePerformanceMonitoring = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_MONITORING',
    defaultValue: false,
  );

  /// Enable granular provider usage for performance optimization.
  /// 
  /// When enabled, UI widgets use specific providers (gridProvider, isWinProvider)
  /// instead of watching the entire gameEngineProvider.
  /// This dramatically reduces UI rebuild frequency.
  static const bool enableGranularProviders = bool.fromEnvironment(
    'ENABLE_GRANULAR_PROVIDERS',
    defaultValue: false,
  );

  /// Enable debug logging for hybrid system troubleshooting.
  static const bool enableHybridDebugLogs = bool.fromEnvironment(
    'ENABLE_HYBRID_DEBUG_LOGS',
    defaultValue: false,
  );

  /// Enable transaction debugging to track atomic operations.
  static const bool enableTransactionDebug = bool.fromEnvironment(
    'ENABLE_TRANSACTION_DEBUG',
    defaultValue: false,
  );

  /// Summary of current feature flag state for debugging and monitoring.
  static Map<String, bool> get currentFlags => {
        'useHybridEngine': useHybridEngine,
        'enablePerformanceMonitoring': enablePerformanceMonitoring,
        'enableGranularProviders': enableGranularProviders,
        'enableHybridDebugLogs': enableHybridDebugLogs,
        'enableTransactionDebug': enableTransactionDebug,
      };

  /// Check if hybrid system features are fully enabled.
  static bool get isHybridFullyEnabled =>
      useHybridEngine && enableGranularProviders;

  /// Check if any experimental features are enabled.
  static bool get hasExperimentalFeatures =>
      useHybridEngine ||
      enablePerformanceMonitoring ||
      enableGranularProviders;
}

import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Injectable feature flag provider interface for runtime configuration
abstract class FeatureFlagProvider {
  bool getBool(String key, {required bool defaultValue});
  void setFlag(String key, dynamic value);
  Map<String, dynamic> getAllFlags();
}

/// Default implementation using in-memory storage with file-based persistence
class InMemoryFeatureFlagProvider implements FeatureFlagProvider {
  final Map<String, dynamic> _flags = const {
    // Refactoring-specific flags
    'unified_coords': true, // Enable unified coordinate service
    'nearness_rule': true, // Enable component nearness validation
    'shadow_mode_validation': false, // Enable shadow-mode diffing
    'atomic_placement':
        true, // Enable atomic placement transactions for Phase 2

    // Legacy migration flags
    'use_enhanced_notifier_primary': false,
    'enable_migration_logging': true,
    'strict_validation_mode': false,
  };

  @override
  bool getBool(String key, {required bool defaultValue}) =>
      _flags[key] as bool? ?? defaultValue;

  @override
  void setFlag(String key, dynamic value) {
    _flags[key] = value;
    StructuredLogger.info('Feature flag updated', context: {
      'flag': key,
      'value': value,
      'provider': 'InMemoryFeatureFlagProvider',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Map<String, dynamic> getAllFlags() => Map.unmodifiable(_flags);
}

/// Enhanced feature flag service with injectable provider pattern
class FeatureFlagService {
  static FeatureFlagService? _instance;
  static FeatureFlagService get instance =>
      _instance ??= FeatureFlagService._();

  late FeatureFlagProvider _provider;

  FeatureFlagService._() {
    _provider = InMemoryFeatureFlagProvider(); // Default provider
  }

  /// Inject a custom provider (useful for testing or remote config)
  void injectProvider(FeatureFlagProvider provider) {
    _provider = provider;
    StructuredLogger.info('Feature flag provider injected', context: {
      'providerType': provider.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Refactoring-specific flags
  bool get unifiedCoords =>
      _provider.getBool('unified_coords', defaultValue: false); // ignore: cascade_invocations
  bool get nearnessRule =>
      _provider.getBool('nearness_rule', defaultValue: false); // ignore: cascade_invocations
  bool get shadowModeValidation =>
      _provider.getBool('shadow_mode_validation', defaultValue: false); // ignore: cascade_invocations
  bool get atomicPlacement =>
      _provider.getBool('atomic_placement', defaultValue: false); // ignore: cascade_invocations

  /// Legacy flags
  bool get useEnhancedNotifierPrimary =>
      _provider.getBool('use_enhanced_notifier_primary', defaultValue: false); // ignore: cascade_invocations
  bool get enableMigrationLogging =>
      _provider.getBool('enable_migration_logging', defaultValue: true); // ignore: cascade_invocations
  bool get strictValidationMode =>
      _provider.getBool('strict_validation_mode', defaultValue: false); // ignore: cascade_invocations

  /// Generic access methods
  bool getBool(String key, {required bool defaultValue}) =>
      _provider.getBool(key, defaultValue: defaultValue); // ignore: cascade_invocations

  void setFlag(String key, dynamic value) => _provider.setFlag(key, value); // ignore: cascade_invocations

  Map<String, dynamic> getAllFlags() => _provider.getAllFlags(); // ignore: cascade_invocations

  /// Emergency rollback to safe defaults
  void rollbackToSafeDefaults() {
    setFlag('unified_coords', false);
    setFlag('nearness_rule', false);
    setFlag('shadow_mode_validation', false);
    setFlag('atomic_placement', false);
    setFlag('use_enhanced_notifier_primary', false);
    StructuredLogger.fatal('Emergency rollback to safe defaults initiated');
  }

  /// Emergency rollback to V3 implementation (legacy)
  void rollbackToV3() {
    rollbackToSafeDefaults();
    StructuredLogger.fatal('Emergency rollback to V3 initiated');
  }

  /// Get status report for monitoring
  Map<String, dynamic> getStatusReport() {
    return {
      'provider': _provider.runtimeType.toString(),
      'flags': getAllFlags(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

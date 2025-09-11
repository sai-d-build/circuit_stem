import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Simple feature flag service for migration control
class FeatureFlagService {
  static FeatureFlagService? _instance;
  static FeatureFlagService get instance => _instance ??= FeatureFlagService._();

  final Map<String, dynamic> _flags = {
    'use_enhanced_notifier_primary': false,
    'enable_migration_logging': true,
    'strict_validation_mode': false,
  };

  FeatureFlagService._();

  bool getBool(String key, {required bool defaultValue}) =>
    _flags[key] as bool? ?? defaultValue;

  void setFlag(String key, dynamic value) {
    _flags[key] = value;
    StructuredLogger.info('Feature flag updated', context: {
      'flag': key,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Emergency rollback to V3 implementation
  void rollbackToV3() {
    setFlag('use_enhanced_notifier_primary', false);
    StructuredLogger.fatal('Emergency rollback to V3 initiated');
  }
}
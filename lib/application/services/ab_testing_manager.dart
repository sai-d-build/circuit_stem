import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/debug/structured_logger.dart';
import 'ab_testing_service.dart';

/// Manager class for easy A/B testing integration throughout the app
class ABTestingManager {
  final ABTestingService _service;
  final String _userId;

  ABTestingManager(this._service, this._userId);

  /// Get a configuration value for the current user's variant in a test
  Future<T?> getConfigValue<T>(String testId, String configKey,
      [T? defaultValue]) async {
    try {
      final variant = _service.getUserVariant(testId, _userId);
      if (variant.isEmpty) return defaultValue;

      // For now, return default value since service doesn't support config values
      // This would need to be extended in the service to support config maps per variant
      StructuredLogger.debug('Config value requested but not supported',
          context: {
            'testId': testId,
            'configKey': configKey,
            'variant': variant,
            'userId': _userId,
          });

      return defaultValue;
    } catch (e) {
      StructuredLogger.error('Failed to get config value',
          context: {
            'testId': testId,
            'configKey': configKey,
            'userId': _userId,
            'error': e.toString(),
          },
          error: e);
      return defaultValue;
    }
  }

  /// Check if user is in a specific variant
  Future<bool> isUserInVariant(String testId, String variantId) async {
    try {
      final variant = _service.getUserVariant(testId, _userId);
      return variant == variantId;
    } catch (e) {
      StructuredLogger.error('Failed to check user variant',
          context: {
            'testId': testId,
            'variantId': variantId,
            'userId': _userId,
            'error': e.toString(),
          },
          error: e);
      return false;
    }
  }

  /// Track a conversion event
  Future<void> trackConversion(String testId, String eventName,
      [Map<String, dynamic>? properties]) async {
    _service.trackEvent(testId, _userId, eventName, properties ?? {});
  }

  /// Track user engagement
  Future<void> trackEngagement(String testId, String action,
      [Map<String, dynamic>? metadata]) async {
    final properties = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    _service.trackEvent(testId, _userId, 'engagement', properties);
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String testId, String featureName,
      [Map<String, dynamic>? metadata]) async {
    final properties = {
      'feature': featureName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    _service.trackEvent(testId, _userId, 'feature_usage', properties);
  }

  /// Get current variant name for a test
  Future<String?> getCurrentVariantName(String testId) async {
    try {
      final variant = _service.getUserVariant(testId, _userId);
      return variant;
    } catch (e) {
      StructuredLogger.error('Failed to get current variant name',
          context: {
            'testId': testId,
            'userId': _userId,
            'error': e.toString(),
          },
          error: e);
      return null;
    }
  }

  /// Get all available tests
  Future<List<ABTestConfig>> getAllTests() async {
    return _service.getAllTests();
  }

  /// Get test results for analytics
  Future<Map<String, dynamic>> getTestResults(String testId) async {
    return _service.getTestResults(testId);
  }
}

/// Provider for A/B Testing Manager
final abTestingManagerProvider =
    Provider.family<ABTestingManager, String>((ref, userId) {
  final abTestingService = ref.watch(abTestingServiceProvider);
  return ABTestingManager(abTestingService, userId);
});

/// Convenience provider for getting config values
final abTestConfigProvider =
    FutureProvider.family<dynamic, ABTestConfigRequest>((ref, request) async {
  final manager = ref.watch(abTestingManagerProvider(request.userId));
  return await manager.getConfigValue(
      request.testId, request.configKey, request.defaultValue);
});

/// Request model for config provider
class ABTestConfigRequest {
  final String userId;
  final String testId;
  final String configKey;
  final dynamic defaultValue;

  const ABTestConfigRequest({
    required this.userId,
    required this.testId,
    required this.configKey,
    this.defaultValue,
  });
}

/// Extension methods for easy A/B testing integration
extension ABTestingExtensions on WidgetRef {
  /// Get A/B testing manager for current user
  ABTestingManager get abTesting => watch(abTestingManagerProvider(
      'current_user')); // TODO: Replace with actual user ID

  /// Get config value for A/B test
  Future<T?> getABConfig<T>(String testId, String configKey,
      [T? defaultValue]) {
    final manager = watch(abTestingManagerProvider(
        'current_user')); // TODO: Replace with actual user ID
    return manager.getConfigValue(testId, configKey, defaultValue);
  }

  /// Track A/B test event
  Future<void> trackABEvent(String testId, String eventName,
      [Map<String, dynamic>? properties]) {
    final manager = watch(abTestingManagerProvider(
        'current_user')); // TODO: Replace with actual user ID
    return manager.trackConversion(testId, eventName, properties);
  }
}

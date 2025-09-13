import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/feature_flag_service.dart';

class TestFeatureFlagProvider implements FeatureFlagProvider {
  final Map<String, dynamic> _flags = {};

  @override
  bool getBool(String key, {required bool defaultValue}) =>
      _flags[key] as bool? ?? defaultValue;

  @override
  void setFlag(String key, dynamic value) {
    _flags[key] = value;
  }

  @override
  Map<String, dynamic> getAllFlags() => Map.unmodifiable(_flags);
}

void main() {
  group('FeatureFlagService Tests', () {
    late FeatureFlagService service;
    late TestFeatureFlagProvider testProvider;

    setUp(() {
      service = FeatureFlagService.instance;
      testProvider = TestFeatureFlagProvider();

      // Reset to clean state
      service.injectProvider(testProvider);
    });

    test('should provide default values when flags not set', () {
      expect(service.unifiedCoords, isFalse); // defaultValue: false
      expect(service.nearnessRule, isFalse); // defaultValue: false
      expect(service.shadowModeValidation, isFalse); // defaultValue: false
      expect(service.atomicPlacement, isFalse); // defaultValue: false
    });

    test('should return configured flag values', () {
      testProvider.setFlag('unified_coords', true);
      testProvider.setFlag('nearness_rule', true);
      testProvider.setFlag('shadow_mode_validation', true);
      testProvider.setFlag('atomic_placement', true);

      expect(service.unifiedCoords, isTrue);
      expect(service.nearnessRule, isTrue);
      expect(service.shadowModeValidation, isTrue);
      expect(service.atomicPlacement, isTrue);
    });

    test('should support runtime flag toggling', () {
      // Start with flags disabled
      expect(service.unifiedCoords, isFalse);
      expect(service.nearnessRule, isFalse);

      // Enable flags
      testProvider.setFlag('unified_coords', true);
      testProvider.setFlag('nearness_rule', true);

      expect(service.unifiedCoords, isTrue);
      expect(service.nearnessRule, isTrue);

      // Disable flags
      testProvider.setFlag('unified_coords', false);
      testProvider.setFlag('nearness_rule', false);

      expect(service.unifiedCoords, isFalse);
      expect(service.nearnessRule, isFalse);
    });

    test('should support shadow-mode validation workflow', () {
      // Initially disabled
      expect(service.shadowModeValidation, isFalse);

      // Enable for testing
      testProvider.setFlag('shadow_mode_validation', true);
      expect(service.shadowModeValidation, isTrue);

      // Simulate coordinate mismatch detection
      final mismatchDetected = service.shadowModeValidation;
      expect(mismatchDetected, isTrue);

      // Disable after testing period
      testProvider.setFlag('shadow_mode_validation', false);
      expect(service.shadowModeValidation, isFalse);
    });

    test('should support emergency rollback', () {
      // Set up initial state
      testProvider.setFlag('unified_coords', true);
      testProvider.setFlag('nearness_rule', true);
      testProvider.setFlag('atomic_placement', true);

      expect(service.unifiedCoords, isTrue);
      expect(service.nearnessRule, isTrue);
      expect(service.atomicPlacement, isTrue);

      // Perform emergency rollback
      service.rollbackToSafeDefaults();

      expect(service.unifiedCoords, isFalse);
      expect(service.nearnessRule, isFalse);
      expect(service.atomicPlacement, isFalse);
    });

    test('should provide status report', () {
      testProvider.setFlag('unified_coords', true);
      testProvider.setFlag('nearness_rule', false);

      final report = service.getStatusReport();

      expect(report['provider'], contains('TestFeatureFlagProvider'));
      expect(report['flags']['unified_coords'], isTrue);
      expect(report['flags']['nearness_rule'], isFalse);
      expect(report['timestamp'], isNotNull);
    });

    test('should support injectable providers', () {
      final anotherProvider = TestFeatureFlagProvider();
      anotherProvider.setFlag('unified_coords', true);

      service.injectProvider(anotherProvider);

      expect(service.unifiedCoords, isTrue);

      // Switch back to original provider
      service.injectProvider(testProvider);
      expect(service.unifiedCoords, isFalse);
    });

    test('should handle legacy flags', () {
      testProvider.setFlag('use_enhanced_notifier_primary', true);
      testProvider.setFlag('enable_migration_logging', false);

      expect(service.useEnhancedNotifierPrimary, isTrue);
      expect(service.enableMigrationLogging, isFalse);
    });
  });
}

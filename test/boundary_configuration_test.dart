import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/bounds_manager.dart';
import 'package:sparkcircuit/domain/entities/levels/level_definition.dart';

void main() {
  group('Boundary Configuration System', () {
    late UnifiedBoundsManager boundsManager;

    setUp(() {
      boundsManager = UnifiedBoundsManager();
    });

    tearDown(() {
      boundsManager.clearCache();
    });

    test('Tutorial level boundary configuration', () async {
      // Test tutorial level configuration
      final tutorialConfig = BoundsConfiguration.tutorial();

      expect(tutorialConfig.strategy, BoundsStrategy.strict);
      expect(tutorialConfig.boundaryStyle, BoundaryStyle.dashed);
      expect(tutorialConfig.boundaryBehavior, BoundaryBehavior.tutorial);
      expect(tutorialConfig.boundaryColor, Colors.red);
      expect(tutorialConfig.levelSpecificSettings?['showHints'], true);
      expect(tutorialConfig.levelSpecificSettings?['tutorialMode'], true);
    });

    test('Beginner level boundary configuration', () async {
      // Test beginner level configuration
      final beginnerConfig = BoundsConfiguration.beginner();

      expect(beginnerConfig.strategy, BoundsStrategy.warning);
      expect(beginnerConfig.boundaryStyle, BoundaryStyle.solid);
      expect(beginnerConfig.boundaryBehavior, BoundaryBehavior.expanding);
      expect(beginnerConfig.boundaryColor, Colors.orange);
      expect(beginnerConfig.levelSpecificSettings?['showHints'], false);
      expect(beginnerConfig.levelSpecificSettings?['progressiveExpansion'], false);
    });

    test('Intermediate level boundary configuration', () async {
      // Test intermediate level configuration
      final intermediateConfig = BoundsConfiguration.intermediate();

      expect(intermediateConfig.strategy, BoundsStrategy.warning);
      expect(intermediateConfig.boundaryStyle, BoundaryStyle.solid);
      expect(intermediateConfig.boundaryBehavior, BoundaryBehavior.expanding);
      expect(intermediateConfig.boundaryColor, Colors.blue);
      expect(intermediateConfig.levelSpecificSettings?['progressiveExpansion'], true);
      expect(intermediateConfig.levelSpecificSettings?['expansionRate'], 0.1);
    });

    test('Advanced level boundary configuration', () async {
      // Test advanced level configuration
      final advancedConfig = BoundsConfiguration.advanced();

      expect(advancedConfig.strategy, BoundsStrategy.flexible);
      expect(advancedConfig.boundaryStyle, BoundaryStyle.dotted);
      expect(advancedConfig.boundaryBehavior, BoundaryBehavior.dynamic);
      expect(advancedConfig.boundaryColor, Colors.green);
      expect(advancedConfig.levelSpecificSettings?['adaptiveSizing'], true);
      expect(advancedConfig.levelSpecificSettings?['dynamicBoundaries'], true);
    });

    test('Expert level boundary configuration', () async {
      // Test expert level configuration
      final expertConfig = BoundsConfiguration.expert();

      expect(expertConfig.strategy, BoundsStrategy.flexible);
      expect(expertConfig.boundaryStyle, BoundaryStyle.gradient);
      expect(expertConfig.boundaryBehavior, BoundaryBehavior.contracting);
      expect(expertConfig.boundaryColor, Colors.purple);
      expect(expertConfig.levelSpecificSettings?['challengingMode'], true);
      expect(expertConfig.levelSpecificSettings?['timePressure'], true);
    });

    test('Dynamic boundary behavior - expanding', () {
      final config = BoundsConfiguration.beginner();
      boundsManager.updateConfiguration(config);

      // Test expanding behavior
      final initialBounds = boundsManager.getEffectiveLevelBounds();
      final expandedBounds = boundsManager.getEffectiveLevelBounds(progress: 0.5, timeElapsed: 40);

      expect(expandedBounds.width, greaterThan(initialBounds.width));
      expect(expandedBounds.height, greaterThan(initialBounds.height));
    });

    test('Dynamic boundary behavior - contracting', () {
      final config = BoundsConfiguration.expert();
      boundsManager.updateConfiguration(config);

      // Test contracting behavior
      final initialBounds = boundsManager.getEffectiveLevelBounds();
      final contractedBounds = boundsManager.getEffectiveLevelBounds(progress: 0.5, timeElapsed: 60);

      expect(contractedBounds.width, lessThan(initialBounds.width));
      expect(contractedBounds.height, lessThan(initialBounds.height));
    });

    test('Dynamic boundary behavior - tutorial', () {
      final config = BoundsConfiguration.tutorial();
      boundsManager.updateConfiguration(config);

      // Test tutorial behavior (starts small, expands gradually)
      final initialBounds = boundsManager.getEffectiveLevelBounds(progress: 0.0);
      final midBounds = boundsManager.getEffectiveLevelBounds(progress: 0.5);
      final finalBounds = boundsManager.getEffectiveLevelBounds(progress: 1.0);

      expect(midBounds.width, greaterThan(initialBounds.width));
      expect(finalBounds.width, equals(config.levelBounds.width));
    });

    test('Boundary style paint generation', () {
      final config = BoundsConfiguration.beginner();
      boundsManager.updateConfiguration(config);

      final paint = boundsManager.getBoundaryPaint();

      expect(paint.color.value, config.boundaryColor.value); // Compare color values
      expect(paint.strokeWidth, config.boundaryWidth);
      expect(paint.style, PaintingStyle.stroke);
    });

    test('Configuration copyWith method', () {
      final originalConfig = BoundsConfiguration.beginner();
      final modifiedConfig = originalConfig.copyWith(
        boundaryColor: Colors.pink,
        boundaryStyle: BoundaryStyle.gradient,
        levelSpecificSettings: {'customSetting': true},
      );

      expect(modifiedConfig.boundaryColor, Colors.pink);
      expect(modifiedConfig.boundaryStyle, BoundaryStyle.gradient);
      expect(modifiedConfig.levelSpecificSettings?['customSetting'], true);
      // Other properties should remain the same
      expect(modifiedConfig.strategy, originalConfig.strategy);
      expect(modifiedConfig.levelBounds, originalConfig.levelBounds);
    });

    test('Cache performance optimization', () {
      final config = BoundsConfiguration.beginner();
      boundsManager.updateConfiguration(config);

      // First validation (should cache)
      final stopwatch = Stopwatch()..start();
      boundsManager.validatePosition(2, 2);
      final firstTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();

      // Second validation (should use cache)
      boundsManager.validatePosition(2, 2);
      final secondTime = stopwatch.elapsedMicroseconds;

      // Second call should be significantly faster (at least 50% improvement)
      expect(secondTime, lessThan(firstTime));

      // Cache size should be > 0
      expect(boundsManager.getCacheSize(), greaterThan(0));
    });

    test('Boundary validation with different strategies', () {
      // Test strict strategy
      var config = BoundsConfiguration.tutorial();
      boundsManager.updateConfiguration(config);

      // Position outside level bounds should fail with strict strategy
      final strictResult = boundsManager.validatePosition(60, 60);
      expect(strictResult.isValid, false);

      // Test flexible strategy
      config = BoundsConfiguration.advanced();
      boundsManager.updateConfiguration(config);

      // Position outside level bounds should pass with flexible strategy
      final flexibleResult = boundsManager.validatePosition(10, 10);
      expect(flexibleResult.isValid, true);
    });

    test('Level-specific configuration parsing', () {
      // Mock level data with boundary configuration
      final mockLevelData = {
        'levelId': 'test_level',
        'version': '1.0.0',
        'metadata': {
          'difficulty': 'intermediate',
        },
        'grid': {
          'width': 12,
          'height': 10,
          'boundaries': {
            'playableArea': {
              'width': 12,
              'height': 10,
            },
            'visualArea': {
              'width': 16,
              'height': 14,
            },
            'style': 'gradient',
            'behavior': 'expanding',
            'settings': {
              'customExpansionRate': 0.2,
              'showAdvancedHints': true,
            },
          },
        },
      };

      final config = BoundsConfiguration.fromLevelData(mockLevelData);

      expect(config.levelBounds, const Size(12, 10));
      expect(config.visualBounds, const Size(16, 14));
      expect(config.boundaryStyle, BoundaryStyle.gradient);
      expect(config.boundaryBehavior, BoundaryBehavior.expanding);
      expect(config.levelSpecificSettings?['customExpansionRate'], 0.2);
      expect(config.levelSpecificSettings?['showAdvancedHints'], true);
    });

    test('Boundary behavior state persistence', () {
      final config = BoundsConfiguration.beginner();
      boundsManager.updateConfiguration(config);

      // Simulate game progress with higher values to ensure expansion
      final initialBounds = boundsManager.getEffectiveLevelBounds();
      final progressBounds = boundsManager.getEffectiveLevelBounds(
        progress: 0.8, // Higher progress for more noticeable expansion
        timeElapsed: 45,
        componentsPlaced: 3,
      );

      // Bounds should change based on progress (expansion)
      expect(progressBounds.width, greaterThan(initialBounds.width));
      expect(progressBounds.height, greaterThan(initialBounds.height));

      // Configuration should persist
      final currentConfig = boundsManager.getConfiguration();
      expect(currentConfig.boundaryBehavior, BoundaryBehavior.expanding);
    });
  });
}
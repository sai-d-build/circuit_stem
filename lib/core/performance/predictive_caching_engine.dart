// lib/core/performance/predictive_caching_engine.dart
// Phase 2: AI-Driven Predictive Caching Engine

import 'dart:collection';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/performance/hca_feature_flags.dart';

/// Advanced predictive caching engine with AI-driven optimization
/// Phase 2: Learns user patterns to predict and pre-cache components
class PredictiveCachingEngine {
  // Singleton instance
  static final PredictiveCachingEngine _instance = PredictiveCachingEngine._internal();
  factory PredictiveCachingEngine() => _instance;
  PredictiveCachingEngine._internal();

  // Usage pattern analytics
  final _usagePatterns = <String, ComponentUsagePattern>{};
  final _recentAccessHistory = Queue<ComponentAccessRecord>();
  static const _maxHistorySize = 1000;

  // Prediction thresholds and limits
  static const _usageThreshold = 0.3;  // 30% of total accesses
  static const _maxPredictionBatchSize = 10;
  static const _predictionLookAhead = Duration(seconds: 2);

  // Cache warming status
  bool _isWarmingCache = false;
  DateTime _lastPredictionUpdate = DateTime.now();

  /// Initialize predictive caching system
  Future<void> initialize() async {
    StructuredLogger.info('Initializing Predictive Caching Engine', context: {
      'threshold': _usageThreshold,
      'lookAhead': _predictionLookAhead.toString(),
      'maxBatch': _maxPredictionBatchSize
    });

    // Enable only if feature flag is set
    if (!HCAFeatureFlags.predictiveCaching) {
      StructuredLogger.info('Predictive caching disabled by feature flag');
      return;
    }

    // Load historical data if available
    await _loadHistoricalPatterns();

    StructuredLogger.info('Predictive Caching Engine ready for AI-driven optimization');
  }

  /// Analyze current circuit state and predict needed components
  Future<List<ComponentPrediction>> predictNextComponents(CircuitState currentState) async {
    if (!HCAFeatureFlags.predictiveCaching) return [];

    final predictions = <ComponentPrediction>[];
    final now = DateTime.now();

    // Update patterns based on recent activity
    if (now.difference(_lastPredictionUpdate).inSeconds > 30) {
      await _analyzeRecentPatterns();
      _lastPredictionUpdate = now;
    }

    // Predict components likely to be accessed next
    final userIntent = await _inferUserIntent(currentState);
    final probableAccesses = await _predictComponentAccess(userIntent, currentState);

    for (final prediction in probableAccesses.take(_maxPredictionBatchSize)) {
      predictions.add(ComponentPrediction(
        componentId: prediction.componentId,
        probability: prediction.probability,
        confidence: prediction.confidence,
        predictedAccessTime: now.add(_predictionLookAhead),
        reason: prediction.reason
      ));
    }

    if (predictions.isNotEmpty) {
      StructuredLogger.debug('Generated predictive cache recommendations', context: {
        'predictions': predictions.length,
        'averageProbability': predictions.map((p) => p.probability).reduce((a, b) => a + b) / predictions.length,
        'userIntent': userIntent.toString()
      });
    }

    return predictions;
  }

  /// Start pre-rendering high-probability components
  Future<int> preRenderPredictedComponents(List<ComponentPrediction> predictions) async {
    if (_isWarmingCache) {
      StructuredLogger.debug('Cache warming already in progress, skipping');
      return 0;
    }

    _isWarmingCache = true;

    try {
      int preRenderedCount = 0;

      // Sort by probability and confidence
      final highPriorityPredictions = predictions
          .where((p) => p.probability > _usageThreshold)
          .take(_maxPredictionBatchSize)
          .toList();

      for (final prediction in highPriorityPredictions) {
        try {
          // Simulate pre-rendering (would use actual ComponentCacheManager in production)
          await _simulatePreRender(prediction);
          preRenderedCount++;

          StructuredLogger.trace('Pre-rendered predicted component', context: {
            'componentId': prediction.componentId,
            'probability': prediction.probability,
            'reason': prediction.reason
          });

          // Throttle to prevent blocking UI thread
          await Future.delayed(Duration(milliseconds: 10));
        } catch (e) {
          StructuredLogger.warning('Failed to pre-render component', context: {
            'componentId': prediction.componentId,
            'error': e.toString()
          });
        }
      }

      StructuredLogger.info('Cache pre-rendering completed', context: {
        'requested': highPriorityPredictions.length,
        'successful': preRenderedCount
      });

      return preRenderedCount;
    } finally {
      _isWarmingCache = false;
    }
  }

  /// Update usage patterns with new component access
  void recordComponentAccess(String componentId, String accessContext, String? gridPosition) {
    if (!HCAFeatureFlags.predictiveCaching) return;

    final record = ComponentAccessRecord(
      componentId: componentId,
      accessTime: DateTime.now(),
      accessContext: accessContext,
      gridPosition: gridPosition
    );

    // Add to recent history
    _recentAccessHistory.addFirst(record);

    // Maintain history size limit
    if (_recentAccessHistory.length > _maxHistorySize) {
      _recentAccessHistory.removeLast();
    }

    // Update usage pattern analytics
    _updateUsagePattern(componentId, accessContext);

    StructuredLogger.trace('Recorded component access', context: {
      'componentId': componentId,
      'context': accessContext,
      'position': gridPosition,
      'historySize': _recentAccessHistory.length
    });
  }

  /// Generate performance insights and optimization recommendations
  Map<String, dynamic> generatePerformanceInsights() {
    final insights = <String, dynamic>{};

    // Analyze peak usage times
    final usageByHour = _analyzeHourlyUsage();
    insights['peakUsageHours'] = usageByHour;

    // Top frequently accessed components
    final popularComponents = _usagePatterns.entries
        .where((entry) => entry.value.accessCount > _usageThreshold * _maxHistorySize)
        .map((entry) => {
          'componentType': entry.key,
          'accessCount': entry.value.accessCount,
          'averagePosition': entry.value.averagePosition,
          'preRenderRecommended': entry.value.accessCount > _usageThreshold * _maxHistorySize * 0.8
        })
        .toList();

    insights['popularComponents'] = popularComponents;

    // Prediction accuracy analysis
    final predictionStats = _calculatePredictionAccuracy();
    insights['predictionStats'] = predictionStats;

    // Recommendations
    insights['recommendations'] = _generateOptimizationRecommendations(insights);

    return insights;
  }

  /// Get real-time engine performance metrics
  Map<String, dynamic> getEngineMetrics() {
    return {
      'isEnabled': HCAFeatureFlags.predictiveCaching,
      'isWarmingCache': _isWarmingCache,
      'trackedComponents': _usagePatterns.length,
      'historySize': _recentAccessHistory.length,
      'lastUpdate': _lastPredictionUpdate.toIso8601String(),
      'patterns': _usagePatterns.length,
      'accuracy': _calculatePredictionAccuracy()
    };
  }

  // MARK: Private Implementation Methods

  Future<void> _loadHistoricalPatterns() async {
    // Load from persistent storage if available
    // For now, start with clean slate
    StructuredLogger.debug('Loaded historical usage patterns', context: {
      'patternsLoaded': _usagePatterns.length
    });
  }

  Future<void> _analyzeRecentPatterns() async {
    final recentAccesses = _recentAccessHistory.take(50).toList();

    // Analyze pattern stability
    final patternStability = _calculatePatternStability(recentAccesses);
    StructuredLogger.debug('Analyzed recent usage patterns', context: {
      'patternStability': patternStability,
      'recentAccesses': recentAccesses.length
    });
  }

  Future<UserIntent> _inferUserIntent(CircuitState currentState) async {
    // Simple heuristic analysis of user behavior patterns

    if (_recentAccessHistory.isEmpty) {
      return UserIntent.exploring;
    }

    final recentAccesses = _recentAccessHistory.take(10).toList();

    // Check if user is working on a specific area of the circuit
    final positionClusters = _clusterAccessesByPosition(recentAccesses);
    if (positionClusters.length == 1) {
      return UserIntent.focusing;
    }

    // Check if user is connecting components
    final connectionPattern = _analyzeConnectionPatterns(recentAccesses);
    if (connectionPattern.isConnectionActivity) {
      return UserIntent.connecting;
    }

    // Check for testing/execution pattern
    final testPattern = _analyzeTestPatterns(recentAccesses);
    if (testPattern.isLikelyTesting) {
      return UserIntent.testing;
    }

    return UserIntent.exploring;
  }

  Future<List<ComponentAccessPrediction>> _predictComponentAccess(UserIntent intent, CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    switch (intent) {
      case UserIntent.connecting:
        predictions.addAll(await _predictConnectionComponents(state));
        break;
      case UserIntent.focusing:
        predictions.addAll(await _predictFocusedAreaComponents(state));
        break;
      case UserIntent.testing:
        predictions.addAll(await _predictTestingComponents(state));
        break;
      case UserIntent.exploring:
        predictions.addAll(await _predictExplorationComponents(state));
        break;
      case UserIntent.optimizing:
        predictions.addAll(await _predictOptimizedComponents(state));
        break;
    }

    return predictions..sort((a, b) => b.probability.compareTo(a.probability));
  }

  Future<List<ComponentAccessPrediction>> _predictConnectionComponents(CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    // Find unconnected components that are close together
    for (final component in state.components) {
      final nearbyComponents = _findNearbyUnconnectedComponents(component, state);
      for (final nearby in nearbyComponents.take(3)) {
        predictions.add(ComponentAccessPrediction(
          componentId: nearby,
          probability: 0.8,
          confidence: 0.7,
          reason: 'Nearby unconnected component - likely connection target'
        ));
      }
    }

    return predictions;
  }

  Future<List<ComponentAccessPrediction>> _predictFocusedAreaComponents(CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    if (_recentAccessHistory.isNotEmpty) {
      final focusPosition = _recentAccessHistory.last.gridPosition;
      if (focusPosition != null) {
        // Find components within 2-grid distance of focus area
        for (final component in state.components) {
          if (_calculateGridDistance(focusPosition, '${component.row},${component.col}') <= 2) {
            predictions.add(ComponentAccessPrediction(
              componentId: component.id,
              probability: 0.6,
              confidence: 0.8,
              reason: 'Within focus area - likely to be accessed'
            ));
          }
        }
      }
    }

    return predictions;
  }

  Future<List<ComponentAccessPrediction>> _predictTestingComponents(CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    // Predict components likely needed for circuit testing
    for (final component in state.components) {
      if (component.type == ComponentType.battery || component.type == ComponentType.bulb ||
          component.type == ComponentType.switch_) {
        predictions.add(ComponentAccessPrediction(
          componentId: component.id,
          probability: 0.7,
          confidence: 0.6,
          reason: 'Essential for circuit testing and powering'
        ));
      }
    }

    return predictions;
  }

  Future<List<ComponentAccessPrediction>> _predictOptimizedComponents(CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    // Predict components that would benefit from optimization
    for (final component in state.components) {
      // Focus on components that are frequently accessed but have high rendering cost
      if ((_usagePatterns[component.type.toString()]?.accessCount ?? 0) > 20) {
        predictions.add(ComponentAccessPrediction(
          componentId: component.id as String,
          probability: 0.9,
          confidence: 0.8,
          reason: 'High-frequency component requiring optimization'
        ));
      }
    }

    return predictions;
  }

  Future<List<ComponentAccessPrediction>> _predictExplorationComponents(CircuitState state) async {
    final predictions = <ComponentAccessPrediction>[];

    // Predict based on usage patterns
    for (final pattern in _usagePatterns.values) {
      if (pattern.accessCount > _maxHistorySize * 0.1) { // Top 10% most used
        final matchingComponents = state.components
            .where((c) => c.type.toString().contains(pattern.componentType.toLowerCase()))
            .toList();

        for (final component in matchingComponents) {
          predictions.add(ComponentAccessPrediction(
            componentId: component.id,
            probability: 0.5,
            confidence: pattern.accessCount / _maxHistorySize.toDouble(),
            reason: 'Frequently used component type based on usage patterns'
          ));
        }
      }
    }

    return predictions;
  }

  Future<void> _simulatePreRender(ComponentPrediction prediction) async {
    // Simulate costly rendering operation without actually doing it
    // In real implementation, this would trigger ComponentCacheManager
    await Future.delayed(Duration(milliseconds: 15)); // Simulate Picture creation time

    // Record pre-rendering in analytics
    final key = 'pre_rendered_${prediction.componentId}';
    StructuredLogger.trace('Pre-rendered component', context: {
      'componentId': prediction.componentId,
      'probability': prediction.probability,
      'key': key
    });
  }

  void _updateUsagePattern(String componentId, String accessContext) {
    final patternKey = componentId.split('-')[0]; // Extract component type info

    if (!_usagePatterns.containsKey(patternKey)) {
      _usagePatterns[patternKey] = ComponentUsagePattern(
        componentType: patternKey,
        accessCount: 0,
        lastAccessed: DateTime.now()
      );
    }

    final pattern = _usagePatterns[patternKey]!;
    pattern.accessCount++;
    pattern.lastAccessed = DateTime.now();

    // Update positional data if available
    if (_recentAccessHistory.isNotEmpty) {
      final lastAccess = _recentAccessHistory.first;
      if (lastAccess.gridPosition != null) {
        pattern.averagePosition = lastAccess.gridPosition!;
      }
    }
  }

  List<String> _analyzeHourlyUsage() {
    final hourlyUsage = <String, int>{};

    for (final record in _recentAccessHistory) {
      final hour = '${record.accessTime.hour}';
      hourlyUsage[hour] = (hourlyUsage[hour] ?? 0) + 1;
    }

    return hourlyUsage.entries
        .where((entry) => entry.value > _recentAccessHistory.length * 0.15)
        .map((entry) => entry.key)
        .toList();
  }

  Map<String, dynamic> _calculatePredictionAccuracy() {
    return {
      'totalPredictions': 0,
      'accuratePredictions': 0,
      'accuracyRate': 0.0,
      'learningProgress': 'initializing'
    };
  }

  List<String> _generateOptimizationRecommendations(Map<String, dynamic> insights) {
    final recommendations = <String>[];

    final popularComponents = List.from(insights['popularComponents'] ?? []);
    if (popularComponents.length > 3) {
      recommendations.add('Consider prioritizing ${popularComponents.length} popular components');
    }

    final predictionStats = Map.from(insights['predictionStats'] ?? {});
    if ((predictionStats['accuracyRate'] as num? ?? 0.0) < 0.8) {
      recommendations.add('Prediction accuracy can be improved');
    }

    return recommendations;
  }

  PositionCluster _clusterAccessesByPosition(List<ComponentAccessRecord> accesses) {
    // Simple clustering by grid proximity
    final positions = accesses.map((a) => a.gridPosition ?? '').where((p) => p.isNotEmpty).toSet();
    return PositionCluster(positionStrings: positions.toList());
  }

  ConnectionPattern _analyzeConnectionPatterns(List<ComponentAccessRecord> accesses) {
    // Check if recent accesses show connection patterns
    final connectionIndicators = ['connect', 'linking', 'joining', 'circuit'];
    final connectionMatches = accesses.where((a) =>
        connectionIndicators.any((indicator) => a.accessContext.contains(indicator)));

    return ConnectionPattern(
      isConnectionActivity: connectionMatches.length >= accesses.length * 0.3,
      connectionCount: connectionMatches.length
    );
  }

  TestPattern _analyzeTestPatterns(List<ComponentAccessRecord> accesses) {
    // Check if recent accesses indicate testing activities
    final testIndicators = ['test', 'simulate', 'run', 'execute', 'power'];
    final testMatches = accesses.where((a) =>
        testIndicators.any((indicator) => a.accessContext.contains(indicator)));

    return TestPattern(
      isLikelyTesting: testMatches.length >= accesses.length * 0.4,
      testActionCount: testMatches.length
    );
  }

  List<String> _findNearbyUnconnectedComponents(dynamic component, CircuitState state) {
    return []; // Placeholder for nearby component finding logic
  }

  double _calculateGridDistance(String pos1, String pos2) {
    try {
      final parts1 = pos1.split(',');
      final parts2 = pos2.split(',');
      final diffRow = int.parse(parts1[0]) - int.parse(parts2[0]);
      final diffCol = int.parse(parts1[1]) - int.parse(parts2[1]);
      return (diffRow * diffRow + diffCol * diffCol).toDouble().sqrt();
    } catch (e) {
      return double.maxFinite;
    }
  }

  double _calculatePatternStability(List<ComponentAccessRecord> accesses) {
    if (accesses.isEmpty) return 0.0;

    // Calculate consistency of access patterns
    final typeFrequency = <String, int>{};
    for (final access in accesses) {
      final type = access.componentId.split('-')[0];
      typeFrequency[type] = (typeFrequency[type] ?? 0) + 1;
    }

    // Calculate coefficient of variation as stability measure
    final frequencies = typeFrequency.values.toList();
    final mean = frequencies.reduce((a, b) => a + b) / frequencies.length;
    final variance = frequencies.map((f) => (f - mean) * (f - mean)).reduce((a, b) => a + b) / frequencies.length;
    final stdDev = variance.sqrt();

    return mean > 0 ? stdDev / mean : 0.0;
  }
}

// MARK: Supporting Models

/// User intent inference
enum UserIntent {
  exploring,    // Free exploration mode
  focusing,     // Working on specific area
  connecting,   // Building connections
  testing,      // Executing and testing circuits
  optimizing    // Performance optimization
}

/// Component prediction data
class ComponentPrediction {
  final String componentId;
  final double probability;    // 0.0 to 1.0
  final double confidence;     // 0.0 to 1.0
  final DateTime predictedAccessTime;
  final String reason;         // Explanation for AI decision

  ComponentPrediction({
    required this.componentId,
    required this.probability,
    required this.confidence,
    required this.predictedAccessTime,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'componentId': componentId,
      'probability': probability,
      'confidence': confidence,
      'predictedAccessTime': predictedAccessTime.toIso8601String(),
      'reason': reason
    };
  }
}

/// Internal usage pattern tracking
class ComponentUsagePattern {
  final String componentType;
  int accessCount;
  DateTime lastAccessed;
  String? averagePosition;

  ComponentUsagePattern({
    required this.componentType,
    required this.accessCount,
    required this.lastAccessed,
    this.averagePosition,
  });
}

/// Component access history
class ComponentAccessRecord {
  final String componentId;
  final DateTime accessTime;
  final String accessContext;
  final String? gridPosition;

  ComponentAccessRecord({
    required this.componentId,
    required this.accessTime,
    required this.accessContext,
    this.gridPosition,
  });
}

/// Internal prediction data
class ComponentAccessPrediction {
  final String componentId;
  final double probability;
  final double confidence;
  final String reason;

  ComponentAccessPrediction({
    required this.componentId,
    required this.probability,
    required this.confidence,
    required this.reason,
  });
}

/// Position clustering helper
class PositionCluster {
  final List<String> positionStrings;

  PositionCluster({required this.positionStrings});

  int get length => positionStrings.length;
}

/// Connection pattern analysis
class ConnectionPattern {
  final bool isConnectionActivity;
  final int connectionCount;

  ConnectionPattern({
    required this.isConnectionActivity,
    required this.connectionCount,
  });
}

/// Test pattern analysis
class TestPattern {
  final bool isLikelyTesting;
  final int testActionCount;

  TestPattern({
    required this.isLikelyTesting,
    required this.testActionCount,
  });
}

/// Circuit state representation
class CircuitState {
  final List<dynamic> components; // Type would be CircuitComponent in real implementation

  CircuitState({required this.components});
}

/// Math extension for sqrt operation (Dart doesn't have it built-in in some contexts)
extension DoubleExtensions on double {
  double sqrt() => this == 0 ? 0 : _newtonSqrt(this, 10);

  double _newtonSqrt(double x, int iterations) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;

    double guess = x / 2;
    for (int i = 0; i < iterations; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}

/// Predictive caching performance insights
class PredictiveCachingInsights {
  static Future<Map<String, dynamic>> generateSystemReport() async {
    final engine = PredictiveCachingEngine();

    return {
      'usagePatterns': engine._usagePatterns.length,
      'recentHistory': engine._recentAccessHistory.length,
      'performanceInsights': engine.generatePerformanceInsights(),
      'cacheHealth': engine.getEngineMetrics(),
      'optimizationPath': 'Phase 2 Advanced Features'
    };
  }
}
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import '../providers.dart' show sharedPreferencesProvider;

/// Configuration for an A/B test
class ABTestConfig {
  final String testId;
  final String name;
  final List<String> variants;
  final Map<String, double> weights;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const ABTestConfig({
    required this.testId,
    required this.name,
    required this.variants,
    this.weights = const {},
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  /// Create config from JSON
  factory ABTestConfig.fromJson(Map<String, dynamic> json) {
    return ABTestConfig(
      testId: json['testId'] as String,
      name: json['name'] as String,
      variants: List<String>.from(json['variants'] as List),
      weights: Map<String, double>.from(json['weights'] ?? {}),
      isActive: json['isActive'] ?? true,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'name': name,
      'variants': variants,
      'weights': weights,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  /// Check if test is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}

/// Result of an A/B test assignment
class ABTestAssignment {
  final String testId;
  final String variant;
  final DateTime assignedAt;
  final String userId;

  const ABTestAssignment({
    required this.testId,
    required this.variant,
    required this.assignedAt,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'variant': variant,
      'assignedAt': assignedAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory ABTestAssignment.fromJson(Map<String, dynamic> json) {
    return ABTestAssignment(
      testId: json['testId'] as String,
      variant: json['variant'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      userId: json['userId'] as String,
    );
  }
}

/// Event tracking for A/B tests
class ABTestEvent {
  final String testId;
  final String variant;
  final String eventType;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String userId;

  const ABTestEvent({
    required this.testId,
    required this.variant,
    required this.eventType,
    required this.properties,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'variant': variant,
      'eventType': eventType,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }
}

/// Main A/B testing service
class ABTestingService {
  static const String _assignmentsKey = 'ab_test_assignments';
  static const String _eventsKey = 'ab_test_events';
  static const String _configsKey = 'ab_test_configs';

  final SharedPreferences _prefs;
  final Random _random = Random();

  /// Current test configurations
  final Map<String, ABTestConfig> _testConfigs = {};

  /// User assignments cache
  final Map<String, ABTestAssignment> _assignments = {};

  /// Event queue for batch processing
  final List<ABTestEvent> _eventQueue = [];

  ABTestingService(this._prefs) {
    _loadFromStorage();
  }

  /// Initialize with test configurations
  void initializeTests(List<ABTestConfig> configs) {
    for (final config in configs) {
      _testConfigs[config.testId] = config;
    }
    _saveConfigsToStorage();
    StructuredLogger.info('A/B testing initialized', context: {
      'testCount': configs.length,
      'activeTests': configs.where((c) => c.isCurrentlyActive).length,
    });
  }

  /// Get variant for a test (assigns if not already assigned)
  String getVariant(String testId, String userId) {
    return getUserVariant(testId, userId);
  }

  /// Get user's variant for a test (alias for getVariant)
  String getUserVariant(String testId, String userId) {
    // Check if already assigned
    final existing = _assignments['$testId:$userId'];
    if (existing != null) {
      return existing.variant;
    }

    // Get test config
    final config = _testConfigs[testId];
    if (config == null || !config.isCurrentlyActive) {
      StructuredLogger.warning('A/B test not found or inactive', context: {
        'testId': testId,
        'userId': userId,
      });
      return 'control'; // Default fallback
    }

    // Assign variant using weighted random selection
    final variant = _selectVariant(config);
    final assignment = ABTestAssignment(
      testId: testId,
      variant: variant,
      assignedAt: DateTime.now(),
      userId: userId,
    );

    _assignments['$testId:$userId'] = assignment;
    _saveAssignmentsToStorage();

    // Track assignment event
    trackEvent(testId, userId, 'assigned', {'userId': userId});

    StructuredLogger.info('A/B test variant assigned', context: {
      'testId': testId,
      'variant': variant,
      'userId': userId,
    });

    return variant;
  }

  /// Track an event for A/B testing
  void trackEvent(
    String testId,
    String userId,
    String eventType,
    Map<String, dynamic> properties,
  ) {
    final variant = getVariant(testId, userId);
    final event = ABTestEvent(
      testId: testId,
      variant: variant,
      eventType: eventType,
      properties: properties,
      timestamp: DateTime.now(),
      userId: userId,
    );

    _eventQueue.add(event);

    // Process events in batches of 10
    if (_eventQueue.length >= 10) {
      _processEventBatch();
    }

    StructuredLogger.debug('A/B test event tracked', context: {
      'testId': testId,
      'variant': variant,
      'eventType': eventType,
      'userId': userId,
    });
  }

  /// Get all tests
  List<ABTestConfig> getAllTests() {
    return _testConfigs.values.toList();
  }

  /// Get test results for analysis
  Map<String, dynamic> getTestResults(String testId) {
    final config = _testConfigs[testId];
    if (config == null) {
      return {
        'error': 'Test not found',
        'testId': testId,
      };
    }

    // Aggregate results from stored events
    final eventsJson = _prefs.getString(_eventsKey);
    if (eventsJson == null) {
      return {
        'testId': testId,
        'totalEvents': 0,
        'variants':
            config.variants.map((v) => {'name': v, 'count': 0}).toList(),
      };
    }

    final events = jsonDecode(eventsJson) as List;
    final testEvents = events.where((e) => e['testId'] == testId).toList();

    // Count events by variant
    final variantCounts = <String, int>{};
    for (final variant in config.variants) {
      variantCounts[variant] = 0;
    }

    for (final event in testEvents) {
      final variant = event['variant'] as String;
      variantCounts[variant] = (variantCounts[variant] ?? 0) + 1;
    }

    return {
      'testId': testId,
      'totalEvents': testEvents.length,
      'variants': variantCounts.entries
          .map((e) => {
                'name': e.key,
                'count': e.value,
              })
          .toList(),
      'config': config.toJson(),
    };
  }

  /// Force reset all assignments (for testing)
  void resetAllAssignments() {
    _assignments.clear();
    _prefs.remove(_assignmentsKey);
    StructuredLogger.info('All A/B test assignments reset');
  }

  /// Select variant using weighted random selection
  String _selectVariant(ABTestConfig config) {
    if (config.weights.isEmpty) {
      // Equal distribution
      return config.variants[_random.nextInt(config.variants.length)];
    }

    // Weighted selection
    final totalWeight =
        config.weights.values.fold(0.0, (sum, weight) => sum + weight);
    final randomValue = _random.nextDouble() * totalWeight;

    var cumulativeWeight = 0.0;
    for (final variant in config.variants) {
      cumulativeWeight += config.weights[variant] ?? 1.0;
      if (randomValue <= cumulativeWeight) {
        return variant;
      }
    }

    return config.variants.first; // Fallback
  }

  /// Process batch of events (send to analytics service)
  void _processEventBatch() {
    if (_eventQueue.isEmpty) return;

    final events = List<ABTestEvent>.from(_eventQueue);
    _eventQueue.clear();

    // In a real implementation, this would send to analytics service
    // For now, just log the batch
    StructuredLogger.info('A/B test events batch processed', context: {
      'eventCount': events.length,
      'events': events
          .map((e) => {
                'testId': e.testId,
                'variant': e.variant,
                'eventType': e.eventType,
              })
          .toList(),
    });

    // Save events to storage for persistence
    _saveEventsToStorage(events);
  }

  /// Load data from persistent storage
  void _loadFromStorage() {
    // Load assignments
    final assignmentsJson = _prefs.getString(_assignmentsKey);
    if (assignmentsJson != null) {
      final assignments = jsonDecode(assignmentsJson) as List;
      for (final assignmentJson in assignments) {
        final assignment = ABTestAssignment.fromJson(assignmentJson);
        _assignments['${assignment.testId}:${assignment.userId}'] = assignment;
      }
    }

    // Load configs
    final configsJson = _prefs.getString(_configsKey);
    if (configsJson != null) {
      final configs = jsonDecode(configsJson) as List;
      for (final configJson in configs) {
        final config = ABTestConfig.fromJson(configJson);
        _testConfigs[config.testId] = config;
      }
    }
  }

  /// Save assignments to storage
  void _saveAssignmentsToStorage() {
    final assignmentsJson = jsonEncode(
      _assignments.values.map((a) => a.toJson()).toList(),
    );
    _prefs.setString(_assignmentsKey, assignmentsJson);
  }

  /// Save configs to storage
  void _saveConfigsToStorage() {
    final configsJson = jsonEncode(
      _testConfigs.values.map((c) => c.toJson()).toList(),
    );
    _prefs.setString(_configsKey, configsJson);
  }

  /// Save events to storage
  void _saveEventsToStorage(List<ABTestEvent> events) {
    final existingEventsJson = _prefs.getString(_eventsKey);
    final existingEvents = existingEventsJson != null
        ? (jsonDecode(existingEventsJson) as List)
            .map((e) => ABTestEvent(
                  testId: e['testId'],
                  variant: e['variant'],
                  eventType: e['eventType'],
                  properties: e['properties'],
                  timestamp: DateTime.parse(e['timestamp']),
                  userId: e['userId'],
                ))
            .toList()
        : <ABTestEvent>[];

    existingEvents.addAll(events);

    final eventsJson = jsonEncode(
      existingEvents.map((e) => e.toJson()).toList(),
    );
    _prefs.setString(_eventsKey, eventsJson);
  }
}

/// Provider for A/B Testing Service
final abTestingServiceProvider = Provider<ABTestingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ABTestingService(prefs);
});

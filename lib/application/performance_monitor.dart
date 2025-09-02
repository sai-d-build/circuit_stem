
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/feature_flags.dart';


/// Performance monitoring system for tracking UI rebuild reduction
/// and validating the 60%+ improvement target from hybrid architecture.
/// 
/// This system:
/// - Tracks widget rebuild frequency
/// - Measures provider watch frequency
/// - Compares hybrid vs monolithic performance
/// - Provides detailed performance reports
/// - Enables A/B testing for performance validation
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance tracking data structures
  final Map<String, RebuildMetrics> _widgetMetrics = {};
  final Map<String, ProviderMetrics> _providerMetrics = {};
  final Map<String, SessionMetrics> _sessionMetrics = {};
  final Queue<PerformanceSnapshot> _snapshots = Queue();

  // Educational gaming performance tracking
  final Map<String, AnimationMetrics> _animationMetrics = {};
  final Map<String, EducationalMetrics> _educationalMetrics = {};
  final Map<String, InteractiveMetrics> _interactiveMetrics = {};
  final Map<String, MemoryMetrics> _memoryMetrics = {};
  final Queue<FrameRateSample> _frameRateSamples = Queue();

  // Configuration
  static const int maxSnapshotsCount = 100;
  static const Duration sessionWindow = Duration(minutes: 5);
  static const double targetImprovementThreshold = 0.6; // 60% improvement

  bool _isMonitoringEnabled = kDebugMode;
  String? _currentSession;
  DateTime? _sessionStart;

  /// Initialize performance monitoring for a session
  void initializeSession(String sessionId, {String? userId}) {
    if (!_isMonitoringEnabled) return;

    _currentSession = sessionId;
    _sessionStart = DateTime.now();
    
    _sessionMetrics[sessionId] = SessionMetrics(
      sessionId: sessionId,
      userId: userId,
      startTime: DateTime.now(),
      isHybridMode: _isHybridModeActive(),
    );

    debugPrint('PerformanceMonitor: Session $sessionId initialized (Hybrid: ${_isHybridModeActive()})');
  }

  /// Track widget rebuild events
  void trackWidgetRebuild(String widgetName, {
    String? providerId,
    Map<String, dynamic>? context,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final now = DateTime.now();
    final key = '${_currentSession}_$widgetName';
    
    _widgetMetrics.putIfAbsent(key, () => RebuildMetrics(
      widgetName: widgetName,
      sessionId: _currentSession!,
      isHybridMode: _isHybridModeActive(),
    )).recordRebuild(now, providerId: providerId, context: context);

    _updateSessionMetrics();
  }

  /// Track provider watch events
  void trackProviderWatch(String providerId, String widgetName, {
    bool wasDataChanged = false,
    String? previousValue,
    String? newValue,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final now = DateTime.now();
    final key = '${_currentSession}_$providerId';

    _providerMetrics.putIfAbsent(key, () => ProviderMetrics(
      providerId: providerId,
      sessionId: _currentSession!,
      isHybridMode: _isHybridModeActive(),
    )).recordWatch(now, widgetName,
      wasDataChanged: wasDataChanged,
      previousValue: previousValue,
      newValue: newValue,
    );

    _updateSessionMetrics();
  }

  /// Track animation performance
  void trackAnimationPerformance(String animationId, {
    required Duration loadTime,
    required Duration playTime,
    required int frameCount,
    String? animationType, // 'rive', 'lottie', 'custom'
    bool hadFrameDrops = false,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final key = '${_currentSession}_$animationId';
    _animationMetrics.putIfAbsent(key, () => AnimationMetrics(
      animationId: animationId,
      sessionId: _currentSession!,
      animationType: animationType,
    )).recordPerformance(loadTime, playTime, frameCount, hadFrameDrops);

    _updateSessionMetrics();
  }

  /// Track educational content loading
  void trackEducationalContentLoad(String contentId, {
    required Duration loadTime,
    required int contentSize,
    String? contentType, // 'level', 'hint', 'tutorial'
    bool fromCache = false,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final key = '${_currentSession}_$contentId';
    _educationalMetrics.putIfAbsent(key, () => EducationalMetrics(
      contentId: contentId,
      sessionId: _currentSession!,
      contentType: contentType,
    )).recordLoad(loadTime, contentSize, fromCache);

    _updateSessionMetrics();
  }

  /// Track interactive mechanics performance
  void trackInteractiveAction(String actionType, {
    required Duration responseTime,
    required bool success,
    String? componentId,
    Map<String, dynamic>? context,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final key = '${_currentSession}_$actionType';
    _interactiveMetrics.putIfAbsent(key, () => InteractiveMetrics(
      actionType: actionType,
      sessionId: _currentSession!,
    )).recordAction(responseTime, success, componentId, context);

    _updateSessionMetrics();
  }

  /// Track memory usage
  void trackMemoryUsage({
    required int heapUsed,
    required int heapTotal,
    required int externalSize,
    String? context,
  }) {
    if (!_isMonitoringEnabled || _currentSession == null) return;

    final key = '${_currentSession}_${DateTime.now().millisecondsSinceEpoch}';
    _memoryMetrics[key] = MemoryMetrics(
      timestamp: DateTime.now(),
      sessionId: _currentSession!,
      heapUsed: heapUsed,
      heapTotal: heapTotal,
      externalSize: externalSize,
      context: context,
    );

    _updateSessionMetrics();
  }

  /// Track frame rate
  void trackFrameRate(double fps, {String? context}) {
    if (!_isMonitoringEnabled) return;

    _frameRateSamples.addLast(FrameRateSample(
      timestamp: DateTime.now(),
      fps: fps,
      context: context,
    ));

    // Keep only recent samples
    if (_frameRateSamples.length > 1000) {
      _frameRateSamples.removeFirst();
    }
  }

  /// Create a performance snapshot
  PerformanceSnapshot takeSnapshot() {
    if (_currentSession == null) return PerformanceSnapshot.empty();

    final snapshot = PerformanceSnapshot(
      timestamp: DateTime.now(),
      sessionId: _currentSession!,
      isHybridMode: _isHybridModeActive(),
      totalWidgetRebuilds: _getTotalRebuilds(),
      totalProviderWatches: _getTotalWatches(),
      averageRebuildFrequency: _getAverageRebuildFrequency(),
      widgetMetrics: Map.from(_widgetMetrics),
      providerMetrics: Map.from(_providerMetrics),
    );

    _snapshots.addLast(snapshot);
    if (_snapshots.length > maxSnapshotsCount) {
      _snapshots.removeFirst();
    }

    return snapshot;
  }

  /// Generate comprehensive performance report
  PerformanceReport generateReport() {
    final hybridSnapshots = _snapshots.where((s) => s.isHybridMode).toList();
    final monolithicSnapshots = _snapshots.where((s) => !s.isHybridMode).toList();

    return PerformanceReport(
      generatedAt: DateTime.now(),
      totalSessions: _sessionMetrics.length,
      hybridSessions: _sessionMetrics.values.where((s) => s.isHybridMode).length,
      monolithicSessions: _sessionMetrics.values.where((s) => !s.isHybridMode).length,
      hybridPerformance: _calculatePerformanceStats(hybridSnapshots),
      monolithicPerformance: _calculatePerformanceStats(monolithicSnapshots),
      improvementMetrics: _calculateImprovementMetrics(hybridSnapshots, monolithicSnapshots),
      recommendations: _generateRecommendations(hybridSnapshots, monolithicSnapshots),
    );
  }

  /// Validate if performance improvement meets target
  bool validatePerformanceTarget() {
    final report = generateReport();
    return report.improvementMetrics.rebuildReduction >= targetImprovementThreshold;
  }

  /// Enable/disable monitoring
  void setMonitoringEnabled(bool enabled) {
    _isMonitoringEnabled = enabled;
    debugPrint('PerformanceMonitor: Monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Clear all monitoring data
  void clearData() {
    _widgetMetrics.clear();
    _providerMetrics.clear();
    _sessionMetrics.clear();
    _snapshots.clear();
    _currentSession = null;
    _sessionStart = null;
    debugPrint('PerformanceMonitor: All data cleared');
  }

  /// Get real-time performance stats
  Map<String, dynamic> getCurrentStats() {
    if (_currentSession == null) return {};

    return {
      'session': _currentSession,
      'duration': DateTime.now().difference(_sessionStart!).inSeconds,
      'isHybrid': _isHybridModeActive(),
      'totalRebuilds': _getTotalRebuilds(),
      'totalWatches': _getTotalWatches(),
      'averageRebuildFreq': _getAverageRebuildFrequency(),
      'topRebuildWidgets': _getTopRebuildWidgets(),
      'mostWatchedProviders': _getMostWatchedProviders(),
    };
  }

  // Private helper methods
  bool _isHybridModeActive() {
    return FeatureFlagService.isEnabled(FeatureFlag.useUnifiedStateManagement);
  }

  void _updateSessionMetrics() {
    if (_currentSession == null) return;
    
    final session = _sessionMetrics[_currentSession!];
    if (session != null) {
      session.updateStats(
        totalRebuilds: _getTotalRebuilds(),
        totalWatches: _getTotalWatches(),
      );
    }
  }

  int _getTotalRebuilds() {
    return _widgetMetrics.values
        .where((m) => m.sessionId == _currentSession)
        .map((m) => m.rebuildCount)
        .fold(0, (sum, count) => sum + count);
  }

  int _getTotalWatches() {
    return _providerMetrics.values
        .where((m) => m.sessionId == _currentSession)
        .map((m) => m.watchCount)
        .fold(0, (sum, count) => sum + count);
  }

  double _getAverageRebuildFrequency() {
    final sessionStart = _sessionStart;
    if (sessionStart == null) return 0.0;

    final duration = DateTime.now().difference(sessionStart).inSeconds;
    if (duration == 0) return 0.0;

    return _getTotalRebuilds() / duration;
  }

  List<String> _getTopRebuildWidgets() {
    final widgets = _widgetMetrics.values
        .where((m) => m.sessionId == _currentSession)
        .toList();
    widgets.sort((a, b) => b.rebuildCount.compareTo(a.rebuildCount));
    return widgets
        .take(5)
        .map((m) => '${m.widgetName}:${m.rebuildCount}')
        .toList();
  }

  List<String> _getMostWatchedProviders() {
    final providers = _providerMetrics.values
        .where((m) => m.sessionId == _currentSession)
        .toList();
    providers.sort((a, b) => b.watchCount.compareTo(a.watchCount));
    return providers
        .take(5)
        .map((m) => '${m.providerId}:${m.watchCount}')
        .toList();
  }

  PerformanceStats _calculatePerformanceStats(List<PerformanceSnapshot> snapshots) {
    if (snapshots.isEmpty) return PerformanceStats.empty();

    final rebuilds = snapshots.map((s) => s.totalWidgetRebuilds).toList();
    final watches = snapshots.map((s) => s.totalProviderWatches).toList();
    final frequencies = snapshots.map((s) => s.averageRebuildFrequency).toList();

    return PerformanceStats(
      averageRebuilds: rebuilds.reduce((a, b) => a + b) / rebuilds.length,
      medianRebuilds: _calculateMedian(rebuilds),
      averageWatches: watches.reduce((a, b) => a + b) / watches.length,
      medianWatches: _calculateMedian(watches),
      averageRebuildFrequency: frequencies.reduce((a, b) => a + b) / frequencies.length,
      maxRebuildFrequency: frequencies.reduce(max),
      minRebuildFrequency: frequencies.reduce(min),
      sampleSize: snapshots.length,
    );
  }

  ImprovementMetrics _calculateImprovementMetrics(
    List<PerformanceSnapshot> hybridSnapshots,
    List<PerformanceSnapshot> monolithicSnapshots,
  ) {
    final hybridStats = _calculatePerformanceStats(hybridSnapshots);
    final monolithicStats = _calculatePerformanceStats(monolithicSnapshots);

    if (monolithicStats.averageRebuilds == 0 || hybridStats.sampleSize == 0 || monolithicStats.sampleSize == 0) {
      return ImprovementMetrics.empty();
    }

    final rebuildReduction = (monolithicStats.averageRebuilds - hybridStats.averageRebuilds) / monolithicStats.averageRebuilds;
    final watchReduction = (monolithicStats.averageWatches - hybridStats.averageWatches) / monolithicStats.averageWatches;
    final frequencyReduction = (monolithicStats.averageRebuildFrequency - hybridStats.averageRebuildFrequency) / monolithicStats.averageRebuildFrequency;

    return ImprovementMetrics(
      rebuildReduction: rebuildReduction,
      watchReduction: watchReduction,
      frequencyReduction: frequencyReduction,
      meetsTargetThreshold: rebuildReduction >= targetImprovementThreshold,
      confidenceLevel: _calculateConfidence(hybridSnapshots.length, monolithicSnapshots.length),
    );
  }

  List<String> _generateRecommendations(
    List<PerformanceSnapshot> hybridSnapshots,
    List<PerformanceSnapshot> monolithicSnapshots,
  ) {
    final recommendations = <String>[];
    final improvement = _calculateImprovementMetrics(hybridSnapshots, monolithicSnapshots);

    if (improvement.rebuildReduction < targetImprovementThreshold) {
      recommendations.add('Performance improvement (${(improvement.rebuildReduction * 100).toStringAsFixed(1)}%) is below target (60%)');
      recommendations.add('Consider migrating more widgets to granular providers');
    } else {
      recommendations.add('Excellent! Performance improvement exceeds target threshold');
    }

    if (improvement.confidenceLevel < 0.8) {
      recommendations.add('Low confidence level - collect more performance data for reliable metrics');
    }

    if (hybridSnapshots.isEmpty) {
      recommendations.add('No hybrid mode data available - enable hybrid features for comparison');
    }

    if (monolithicSnapshots.isEmpty) {
      recommendations.add('No baseline (monolithic) data available for comparison');
    }

    return recommendations;
  }

  double _calculateMedian(List<int> values) {
    if (values.isEmpty) return 0.0;
    values.sort();
    final mid = values.length ~/ 2;
    return values.length % 2 == 0
        ? (values[mid - 1] + values[mid]) / 2.0
        : values[mid].toDouble();
  }

  double _calculateConfidence(int hybridSamples, int monolithicSamples) {
    final totalSamples = hybridSamples + monolithicSamples;
    if (totalSamples < 10) return 0.3;
    if (totalSamples < 50) return 0.6;
    if (totalSamples < 100) return 0.8;
    return 0.95;
  }
}

// Educational Gaming Performance Data Classes
class AnimationMetrics {
  final String animationId;
  final String sessionId;
  final String? animationType;
  final List<Duration> loadTimes = [];
  final List<Duration> playTimes = [];
  final List<int> frameCounts = [];
  final List<bool> frameDropFlags = [];

  AnimationMetrics({
    required this.animationId,
    required this.sessionId,
    this.animationType,
  });

  void recordPerformance(Duration loadTime, Duration playTime, int frameCount, bool hadFrameDrops) {
    loadTimes.add(loadTime);
    playTimes.add(playTime);
    frameCounts.add(frameCount);
    frameDropFlags.add(hadFrameDrops);
  }

  double get averageLoadTime => loadTimes.isEmpty ? 0 : loadTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / loadTimes.length;
  double get averagePlayTime => playTimes.isEmpty ? 0 : playTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / playTimes.length;
  double get averageFrameRate => frameCounts.isEmpty ? 0 : frameCounts.reduce((a, b) => a + b) / frameCounts.length;
  int get frameDropCount => frameDropFlags.where((flag) => flag).length;
}

class EducationalMetrics {
  final String contentId;
  final String sessionId;
  final String? contentType;
  final List<Duration> loadTimes = [];
  final List<int> contentSizes = [];
  final List<bool> cacheHits = [];

  EducationalMetrics({
    required this.contentId,
    required this.sessionId,
    this.contentType,
  });

  void recordLoad(Duration loadTime, int contentSize, bool fromCache) {
    loadTimes.add(loadTime);
    contentSizes.add(contentSize);
    cacheHits.add(fromCache);
  }

  double get averageLoadTime => loadTimes.isEmpty ? 0 : loadTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / loadTimes.length;
  double get cacheHitRate => cacheHits.isEmpty ? 0 : cacheHits.where((hit) => hit).length / cacheHits.length;
  int get totalContentLoaded => contentSizes.reduce((a, b) => a + b);
}

class InteractiveMetrics {
  final String actionType;
  final String sessionId;
  final List<Duration> responseTimes = [];
  final List<bool> successes = [];
  final Map<String, int> componentInteractions = {};
  final List<Map<String, dynamic>> contexts = [];

  InteractiveMetrics({
    required this.actionType,
    required this.sessionId,
  });

  void recordAction(Duration responseTime, bool success, String? componentId, Map<String, dynamic>? context) {
    responseTimes.add(responseTime);
    successes.add(success);

    if (componentId != null) {
      componentInteractions[componentId] = (componentInteractions[componentId] ?? 0) + 1;
    }

    if (context != null) {
      contexts.add(context);
    }
  }

  double get averageResponseTime => responseTimes.isEmpty ? 0 : responseTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / responseTimes.length;
  double get successRate => successes.isEmpty ? 0 : successes.where((s) => s).length / successes.length;
  int get totalInteractions => responseTimes.length;
}

class MemoryMetrics {
  final DateTime timestamp;
  final String sessionId;
  final int heapUsed;
  final int heapTotal;
  final int externalSize;
  final String? context;

  MemoryMetrics({
    required this.timestamp,
    required this.sessionId,
    required this.heapUsed,
    required this.heapTotal,
    required this.externalSize,
    this.context,
  });

  double get heapUsagePercentage => heapTotal > 0 ? (heapUsed / heapTotal) * 100 : 0;
  int get totalMemory => heapUsed + externalSize;
}

class FrameRateSample {
  final DateTime timestamp;
  final double fps;
  final String? context;

  FrameRateSample({
    required this.timestamp,
    required this.fps,
    this.context,
  });
}

// Data classes for performance monitoring
class RebuildMetrics {
  final String widgetName;
  final String sessionId;
  final bool isHybridMode;
  final List<DateTime> rebuildTimes = [];
  final Map<String, int> providerTriggers = {};
  final List<Map<String, dynamic>> contexts = [];

  RebuildMetrics({
    required this.widgetName,
    required this.sessionId,
    required this.isHybridMode,
  });

  int get rebuildCount => rebuildTimes.length;
  
  void recordRebuild(DateTime time, {String? providerId, Map<String, dynamic>? context}) {
    rebuildTimes.add(time);
    if (providerId != null) {
      providerTriggers[providerId] = (providerTriggers[providerId] ?? 0) + 1;
    }
    if (context != null) {
      contexts.add(context);
    }
  }
}

class ProviderMetrics {
  final String providerId;
  final String sessionId;
  final bool isHybridMode;
  final List<DateTime> watchTimes = [];
  final Map<String, int> watchingWidgets = {};
  final List<String> dataChanges = [];

  ProviderMetrics({
    required this.providerId,
    required this.sessionId,
    required this.isHybridMode,
  });

  int get watchCount => watchTimes.length;
  
  void recordWatch(DateTime time, String widgetName, {
    bool wasDataChanged = false,
    String? previousValue,
    String? newValue,
  }) {
    watchTimes.add(time);
    watchingWidgets[widgetName] = (watchingWidgets[widgetName] ?? 0) + 1;
    
    if (wasDataChanged) {
      dataChanges.add('$previousValue → $newValue');
    }
  }
}

class SessionMetrics {
  final String sessionId;
  final String? userId;
  final DateTime startTime;
  final bool isHybridMode;
  DateTime? endTime;
  int totalRebuilds = 0;
  int totalWatches = 0;

  SessionMetrics({
    required this.sessionId,
    this.userId,
    required this.startTime,
    required this.isHybridMode,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  
  void updateStats({required int totalRebuilds, required int totalWatches}) {
    this.totalRebuilds = totalRebuilds;
    this.totalWatches = totalWatches;
  }

  void endSession() {
    endTime = DateTime.now();
  }
}

class PerformanceSnapshot {
  final DateTime timestamp;
  final String sessionId;
  final bool isHybridMode;
  final int totalWidgetRebuilds;
  final int totalProviderWatches;
  final double averageRebuildFrequency;
  final Map<String, RebuildMetrics> widgetMetrics;
  final Map<String, ProviderMetrics> providerMetrics;

  PerformanceSnapshot({
    required this.timestamp,
    required this.sessionId,
    required this.isHybridMode,
    required this.totalWidgetRebuilds,
    required this.totalProviderWatches,
    required this.averageRebuildFrequency,
    required this.widgetMetrics,
    required this.providerMetrics,
  });

  factory PerformanceSnapshot.empty() {
    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      sessionId: '',
      isHybridMode: false,
      totalWidgetRebuilds: 0,
      totalProviderWatches: 0,
      averageRebuildFrequency: 0.0,
      widgetMetrics: {},
      providerMetrics: {},
    );
  }
}

class PerformanceStats {
  final double averageRebuilds;
  final double medianRebuilds;
  final double averageWatches;
  final double medianWatches;
  final double averageRebuildFrequency;
  final double maxRebuildFrequency;
  final double minRebuildFrequency;
  final int sampleSize;

  PerformanceStats({
    required this.averageRebuilds,
    required this.medianRebuilds,
    required this.averageWatches,
    required this.medianWatches,
    required this.averageRebuildFrequency,
    required this.maxRebuildFrequency,
    required this.minRebuildFrequency,
    required this.sampleSize,
  });

  factory PerformanceStats.empty() {
    return PerformanceStats(
      averageRebuilds: 0,
      medianRebuilds: 0,
      averageWatches: 0,
      medianWatches: 0,
      averageRebuildFrequency: 0,
      maxRebuildFrequency: 0,
      minRebuildFrequency: 0,
      sampleSize: 0,
    );
  }
}

class ImprovementMetrics {
  final double rebuildReduction;
  final double watchReduction;
  final double frequencyReduction;
  final bool meetsTargetThreshold;
  final double confidenceLevel;

  ImprovementMetrics({
    required this.rebuildReduction,
    required this.watchReduction,
    required this.frequencyReduction,
    required this.meetsTargetThreshold,
    required this.confidenceLevel,
  });

  factory ImprovementMetrics.empty() {
    return ImprovementMetrics(
      rebuildReduction: 0,
      watchReduction: 0,
      frequencyReduction: 0,
      meetsTargetThreshold: false,
      confidenceLevel: 0,
    );
  }
}

class PerformanceReport {
  final DateTime generatedAt;
  final int totalSessions;
  final int hybridSessions;
  final int monolithicSessions;
  final PerformanceStats hybridPerformance;
  final PerformanceStats monolithicPerformance;
  final ImprovementMetrics improvementMetrics;
  final List<String> recommendations;

  PerformanceReport({
    required this.generatedAt,
    required this.totalSessions,
    required this.hybridSessions,
    required this.monolithicSessions,
    required this.hybridPerformance,
    required this.monolithicPerformance,
    required this.improvementMetrics,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'totalSessions': totalSessions,
      'hybridSessions': hybridSessions,
      'monolithicSessions': monolithicSessions,
      'improvement': {
        'rebuildReduction': '${(improvementMetrics.rebuildReduction * 100).toStringAsFixed(1)}%',
        'watchReduction': '${(improvementMetrics.watchReduction * 100).toStringAsFixed(1)}%',
        'frequencyReduction': '${(improvementMetrics.frequencyReduction * 100).toStringAsFixed(1)}%',
        'meetsTarget': improvementMetrics.meetsTargetThreshold,
        'confidence': '${(improvementMetrics.confidenceLevel * 100).toStringAsFixed(1)}%',
      },
      'recommendations': recommendations,
    };
  }
}

// Riverpod provider for performance monitoring
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor();
});
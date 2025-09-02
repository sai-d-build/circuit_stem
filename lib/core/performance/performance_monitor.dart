import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  double _averageFrameTime = GameConstants.targetFrameTime; // 60fps baseline
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  Timer? _performanceTimer;

  // Device capability assessment
  bool _isHighPerformanceDevice = true;
  double _devicePerformanceScore = 1.0;

  // Monitoring control
  bool _isMonitoringActive = false;
  final int _maxFrameSamples = GameConstants.maxPerformanceFrameSamples;

  // Performance monitoring
  static void startMonitoring() {
    _instance._startMonitoring();
  }

  void _startMonitoring() {
    if (_isMonitoringActive) return; // Prevent double initialization
    _isMonitoringActive = true;
    WidgetsBinding.instance.addPostFrameCallback(_onFrameCallback);
    _performanceTimer = Timer.periodic(const Duration(seconds: 5), _assessPerformance);
  }

  void _stopMonitoring() {
    _isMonitoringActive = false;
    _performanceTimer?.cancel();
    _performanceTimer = null;
    _frameCount = 0;
    _lastFrameTime = null;
  }

  static void stopMonitoring() {
    _instance._stopMonitoring();
  }

  void _onFrameCallback(Duration timestamp) {
    if (!_isMonitoringActive) return; // Bounds checking

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMicroseconds / 1000.0;
      _averageFrameTime = (_averageFrameTime * _frameCount + frameTime) / (_frameCount + 1);
      _frameCount = _min(_frameCount.toDouble(), _maxFrameSamples.toDouble()).toInt(); // Keep last 60 frames
    }
    _lastFrameTime = now;

    // Only continue monitoring if still active and within bounds
    if (_isMonitoringActive && _frameCount < _maxFrameSamples) {
      WidgetsBinding.instance.addPostFrameCallback(_onFrameCallback);
    }
  }

  void _assessPerformance(Timer timer) {
    // Assess device performance based on frame times
    if (_averageFrameTime > GameConstants.poorPerformanceThreshold) {
      _isHighPerformanceDevice = false;
      _devicePerformanceScore = _max(GameConstants.lowOpacity, GameConstants.targetFrameTime / _averageFrameTime);
    } else if (_averageFrameTime < GameConstants.goodPerformanceThreshold) {
      _isHighPerformanceDevice = true;
      _devicePerformanceScore = _min(GameConstants.highOpacity + GameConstants.mediumOpacity, GameConstants.targetFrameTime / _averageFrameTime); // Max 1.8x boost
    }

    // Trigger quality adjustments if needed
    if (_averageFrameTime > GameConstants.poorPerformanceThreshold) {
      // AdaptiveQualityManager.reduceQuality(); // TODO: Implement when AdaptiveQualityManager is created
    }
  }

  // Public API
  static bool get isHighPerformanceDevice => _instance._isHighPerformanceDevice;
  static double get devicePerformanceScore => _instance._devicePerformanceScore;
  static double get averageFrameTime => _instance._averageFrameTime;

  static void dispose() {
    _instance._performanceTimer?.cancel();
    _instance._isMonitoringActive = false;
  }

  // Helper functions for min/max operations
  static double _min(double a, double b) => a < b ? a : b;
  static double _max(double a, double b) => a > b ? a : b;
}
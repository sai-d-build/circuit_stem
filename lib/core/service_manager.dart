import 'dart:async';
import 'package:flutter/material.dart';
import 'performance/performance_monitor.dart';
import 'performance/adaptive_quality.dart';
import 'accessibility/accessibility_manager.dart';


/// ServiceManager provides unified initialization and management of all critical systems
class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  bool _isInitialized = false;
  final List<String> _initializationLog = [];
  final Map<String, bool> _serviceStatus = {};

  /// Initialize all critical services
  static Future<void> initialize(BuildContext? context) async {
    if (_instance._isInitialized) {
      _instance._log('ServiceManager already initialized');
      return;
    }

    _instance._log('Starting ServiceManager initialization...');

    try {
      // Initialize Performance Monitor
      await _instance._initializePerformanceMonitor();
      _instance._serviceStatus['performance'] = true;

      // Initialize Adaptive Quality Manager
      await _instance._initializeAdaptiveQuality();
      _instance._serviceStatus['adaptive_quality'] = true;

      // Initialize Accessibility Manager (requires context)
      if (context != null) {
        await _instance._initializeAccessibilityManager(context);
        _instance._serviceStatus['accessibility'] = true;
      } else {
        _instance._log('Warning: AccessibilityManager not initialized - no context provided');
        _instance._serviceStatus['accessibility'] = false;
      }

      // Initialize Gesture Manager
      await _instance._initializeGestureManager();
      _instance._serviceStatus['gesture'] = true;

      _instance._isInitialized = true;
      _instance._log('ServiceManager initialization completed successfully');

    } catch (e, stackTrace) {
      _instance._log('ServiceManager initialization failed: $e');
      _instance._log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if all services are initialized
  static bool get isInitialized => _instance._isInitialized;

  /// Get initialization status of specific service
  static bool isServiceInitialized(String serviceName) {
    return _instance._serviceStatus[serviceName] ?? false;
  }

  /// Get initialization log for debugging
  static List<String> get initializationLog => List.unmodifiable(_instance._initializationLog);

  /// Get service status map
  static Map<String, bool> get serviceStatus => Map.unmodifiable(_instance._serviceStatus);

  /// Dispose all services
  static void dispose() {
    _instance._log('Disposing ServiceManager...');

    try {
      PerformanceMonitor.dispose();
      AnimationControllerPool.disposeAll();
      // GestureManager doesn't have a public dispose method
      // Add dispose logic here if needed in the future

      _instance._serviceStatus.clear();
      _instance._isInitialized = false;
      _instance._log('ServiceManager disposed successfully');

    } catch (e) {
      _instance._log('Error during ServiceManager disposal: $e');
    }
  }

  /// Reinitialize failed services
  static Future<void> reinitializeFailedServices(BuildContext? context) async {
    _instance._log('Reinitializing failed services...');

    final failedServices = _instance._serviceStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    for (final service in failedServices) {
      try {
        switch (service) {
          case 'performance':
            await _instance._initializePerformanceMonitor();
            break;
          case 'adaptive_quality':
            await _instance._initializeAdaptiveQuality();
            break;
          case 'accessibility':
            if (context != null) {
              await _instance._initializeAccessibilityManager(context);
            }
            break;
          case 'gesture':
            await _instance._initializeGestureManager();
            break;
        }
        _instance._serviceStatus[service] = true;
        _instance._log('Successfully reinitialized $service');
      } catch (e) {
        _instance._log('Failed to reinitialize $service: $e');
      }
    }
  }

  // Private initialization methods
  Future<void> _initializePerformanceMonitor() async {
    _log('Initializing PerformanceMonitor...');
    PerformanceMonitor.startMonitoring();
    _log('PerformanceMonitor initialized');
  }

  Future<void> _initializeAdaptiveQuality() async {
    _log('Initializing AdaptiveQualityManager...');
    AdaptiveQualityManager.assessDeviceCapabilities();
    _log('AdaptiveQualityManager initialized');
  }

  Future<void> _initializeAccessibilityManager(BuildContext context) async {
    _log('Initializing AccessibilityManager...');
    await AccessibilityManager.initializeFromSystem(context);
    _log('AccessibilityManager initialized');
  }

  Future<void> _initializeGestureManager() async {
    _log('Initializing GestureManager...');
    // GestureManager is typically initialized on first use
    // Add any specific initialization logic here if needed
    _log('GestureManager initialized');
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    _initializationLog.add(logMessage);
    debugPrint(logMessage); // Also print to console for debugging
  }
}

// Forward declarations for services that may not be imported yet
class AnimationControllerPool {
  static void disposeAll() {
    // Implementation will be added when AnimationControllerPool is created
  }
}
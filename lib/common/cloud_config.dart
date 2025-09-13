// lib/common/cloud_config.dart
// Cloud configuration and feature flags for testing

import 'package:flutter/foundation.dart';

/// Cloud configuration for SparkCircuit
class CloudConfig {
  // Feature flags for cloud functionality
  static const bool enableCloudSync =
      kDebugMode ? false : true; // Disabled in debug mode by default
  static const bool enableAuthentication = kDebugMode ? false : true;
  static const bool enableOfflineMode = true; // Always enabled
  static const bool enableConflictResolution = true;

  // Cloud service configuration
  static const String firebaseProjectId = 'sparkcircuit-prod';
  static const bool useEmulatorInDebug =
      kDebugMode && true; // Use Firebase emulator in debug

  // Sync configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration syncTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Storage configuration
  static const int maxLocalStorageSize = 50 * 1024 * 1024; // 50MB
  static const Duration localDataRetention = Duration(days: 30);

  // Testing configuration
  static const bool enableCloudLogging = kDebugMode;
  static const bool enableSyncNotifications = !kDebugMode;
  static const bool enableBackgroundSync = !kDebugMode;

  /// Check if cloud features are enabled
  static bool get isCloudEnabled => enableCloudSync;

  /// Check if we should use local storage only
  static bool get isLocalOnly => !enableCloudSync;

  /// Check if authentication is required
  static bool get requiresAuth => enableAuthentication;

  /// Get current environment
  static String get environment => kDebugMode ? 'debug' : 'production';

  /// Check if we should show cloud-related UI
  static bool get showCloudUI => enableCloudSync;

  /// Check if we should show offline indicators
  static bool get showOfflineIndicators => enableOfflineMode;
}

/// Cloud service mode for testing
enum CloudServiceMode {
  /// Use real cloud services (Firebase)
  real,

  /// Use local storage only (no cloud)
  localOnly,

  /// Use mocked cloud services for testing
  mocked,

  /// Use Firebase emulator
  emulator,
}

/// Current cloud service mode (can be changed for testing)
CloudServiceMode currentCloudMode = CloudConfig.enableCloudSync
    ? (kDebugMode ? CloudServiceMode.emulator : CloudServiceMode.real)
    : CloudServiceMode.localOnly;

/// Utility class for cloud testing
class CloudTestingUtils {
  /// Enable cloud sync for testing
  static void enableCloudSync() {
    currentCloudMode = CloudServiceMode.real;
  }

  /// Disable cloud sync (local only)
  static void disableCloudSync() {
    currentCloudMode = CloudServiceMode.localOnly;
  }

  /// Use mocked cloud services
  static void useMockedCloud() {
    currentCloudMode = CloudServiceMode.mocked;
  }

  /// Use Firebase emulator
  static void useEmulator() {
    currentCloudMode = CloudServiceMode.emulator;
  }

  /// Reset to default mode based on configuration
  static void resetToDefault() {
    currentCloudMode = CloudConfig.enableCloudSync
        ? (kDebugMode ? CloudServiceMode.emulator : CloudServiceMode.real)
        : CloudServiceMode.localOnly;
  }

  /// Check if cloud sync is currently enabled
  static bool get isCloudEnabled =>
      currentCloudMode != CloudServiceMode.localOnly;

  /// Check if using mocked services
  static bool get isUsingMock => currentCloudMode == CloudServiceMode.mocked;

  /// Check if using emulator
  static bool get isUsingEmulator =>
      currentCloudMode == CloudServiceMode.emulator;

  /// Get current mode description
  static String get currentModeDescription {
    switch (currentCloudMode) {
      case CloudServiceMode.real:
        return 'Real Cloud Services';
      case CloudServiceMode.localOnly:
        return 'Local Storage Only';
      case CloudServiceMode.mocked:
        return 'Mocked Cloud Services';
      case CloudServiceMode.emulator:
        return 'Firebase Emulator';
    }
  }
}

import 'package:flutter/foundation.dart';
export 'game_constants.dart';

/// Log levels for structured logging
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  none(4);

  const LogLevel(this.value);
  final int value;

  bool operator <=(LogLevel other) => value <= other.value;
  bool operator >=(LogLevel other) => value >= other.value;
}

/// Environment-based logging configuration
class LoggingConfig {
  static LogLevel _currentLevel = _getDefaultLogLevel();
  static bool _isEnabled = true;

  static LogLevel get currentLevel => _currentLevel;
  static bool get isEnabled => _isEnabled;

  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static LogLevel _getDefaultLogLevel() {
    if (kReleaseMode) {
      return LogLevel.warning; // Only warnings and errors in release
    } else if (kProfileMode) {
      return LogLevel.info; // Info and above in profile mode
    } else {
      return LogLevel.debug; // All logs in debug mode
    }
  }

  static bool shouldLog(LogLevel level) {
    return _isEnabled && level >= _currentLevel;
  }
}

/// Structured logger with environment-based configuration
class StructuredLogger {
  static const String _tag = '[WEB]';

  // Backward compatibility properties
  static bool get isEnabled => LoggingConfig.isEnabled;
  static bool debugServices = true;
  static bool debugGameCanvas = true;
  static bool debugPresentation = true;
  static bool debugCritical = true;
  static bool debugWeb = true;
  static bool debugComponents = true;
  static bool debugPerformance = true;

  // Dashboard and inventory debugging flags (NEW)
  static bool debugDashboard = true;
  static bool debugInventory = true;

  static bool get hasAnyDebugEnabled => debugServices || debugGameCanvas ||
      debugPresentation || debugCritical || debugWeb || debugComponents ||
      debugPerformance || debugDashboard || debugInventory;

  static void debug(String message, {Map<String, dynamic>? context, Object? error}) {
    if (!LoggingConfig.shouldLog(LogLevel.debug)) return;
    _log('DEBUG', message, context, error: error);
  }

  static void info(String message, {Map<String, dynamic>? context}) {
    if (!LoggingConfig.shouldLog(LogLevel.info)) return;
    _log('INFO', message, context);
  }

  static void warning(String message, {Map<String, dynamic>? context, Object? error}) {
    if (!LoggingConfig.shouldLog(LogLevel.warning)) return;
    _log('WARNING', message, context, error: error);
  }

  static void log(String message, {Map<String, dynamic>? context}) {
    info(message, context: context);
  }

  static void presentation(String message, {Map<String, dynamic>? context}) {
    if (debugPresentation && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('PRESENTATION', message, context);
    }
  }

  static void error(String message, {Map<String, dynamic>? context, Object? error}) {
    if (!LoggingConfig.shouldLog(LogLevel.error)) return;
    _log('ERROR', message, context, error: error);
  }

  static void trace(String message, {Map<String, dynamic>? context}) {
    if (!LoggingConfig.shouldLog(LogLevel.debug)) return;
    _log('TRACE', message, context);
  }

  static void setEnabled(bool enabled) {
    LoggingConfig.setEnabled(enabled);
  }

  static void setRuntimeFlag(String flag, bool value) {
    // Simple implementation for backward compatibility
    switch (flag) {
      case 'debugServices':
        debugServices = value;
        break;
      case 'debugGameCanvas':
        debugGameCanvas = value;
        break;
      case 'debugPresentation':
        debugPresentation = value;
        break;
      case 'debugCritical':
        debugCritical = value;
        break;
      case 'debugWeb':
        debugWeb = value;
        break;
      case 'debugComponents':
        debugComponents = value;
        break;
      case 'debugPerformance':
        debugPerformance = value;
        break;
      case 'debugDashboard':
        debugDashboard = value;
        break;
      case 'debugInventory':
        debugInventory = value;
        break;
    }
  }

  static bool getRuntimeFlag(String flag, {bool defaultValue = false}) {
    switch (flag) {
      case 'debugServices':
        return debugServices;
      case 'debugGameCanvas':
        return debugGameCanvas;
      case 'debugPresentation':
        return debugPresentation;
      case 'debugCritical':
        return debugCritical;
      case 'debugWeb':
        return debugWeb;
      case 'debugComponents':
        return debugComponents;
      case 'debugPerformance':
        return debugPerformance;
      case 'debugDashboard':
        return debugDashboard;
      case 'debugInventory':
        return debugInventory;
      default:
        return defaultValue;
    }
  }

  static void services(String message, {Map<String, dynamic>? context}) {
    if (debugServices && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('SERVICES', message, context);
    }
  }

  static void gameCanvas(String message, {Map<String, dynamic>? context}) {
    if (debugGameCanvas && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('GAME_CANVAS', message, context);
    }
  }

  static void components(String message, {Map<String, dynamic>? context}) {
    if (debugComponents && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('COMPONENTS', message, context);
    }
  }

  static void performance(String message, {Map<String, dynamic>? context}) {
    if (debugPerformance && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('PERFORMANCE', message, context);
    }
  }

  static void web(String message, {Map<String, dynamic>? context}) {
    if (debugWeb && LoggingConfig.shouldLog(LogLevel.debug)) {
      _log('WEB', message, context);
    }
  }

  static void critical(String message, {Map<String, dynamic>? context, Object? error}) {
    if (debugCritical && LoggingConfig.shouldLog(LogLevel.error)) {
      _log('CRITICAL', message, context, error: error);
    }
  }

  static void fatal(String message, {Map<String, dynamic>? context}) {
    if (LoggingConfig.shouldLog(LogLevel.error)) {
      _log('FATAL', message, context);
    }
  }

  static void _log(String level, String message, Map<String, dynamic>? context, {Object? error}) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';

    final logMessage = '$_tag [$level] $timestamp - $message$contextStr$errorStr';
    if (kDebugMode) {
      print(logMessage);
    }
  }

  static void configureForEnvironment({LogLevel? level}) {
    if (level != null) {
      LoggingConfig.setLogLevel(level);
    } else {
      LoggingConfig.setLogLevel(LoggingConfig._getDefaultLogLevel());
    }

    info('Logging configured', context: {
      'level': LoggingConfig.currentLevel.name,
      'environment': kReleaseMode ? 'release' : kProfileMode ? 'profile' : 'debug',
      'dashboard_debug': debugDashboard,
      'inventory_debug': debugInventory,
    });
  }
}
// Simple logger implementation for the SparkCircuit app
// This replaces the missing logger.dart file

import 'package:sparkcircuit/core/debug/structured_logger.dart';

class Logger {
  static const String _tag = 'SparkCircuit';

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    // Debug level logging - use direct print to avoid circular dependency
    // These will be replaced systematically in future PR with structured logging
    final debugMsg = '[$_tag DEBUG] $message';
    print(debugMsg);
    if (error != null) {
      print('[$_tag DEBUG] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag DEBUG] StackTrace: $stackTrace');
    }
  }

  static void i(String message) {
    // Info level logging
    final infoMsg = '[$_tag INFO] $message';
    print(infoMsg);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    // Warning level logging
    final warnMsg = '[$_tag WARNING] $message';
    print(warnMsg);
    if (error != null) {
      print('[$_tag WARNING] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag WARNING] StackTrace: $stackTrace');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    // Error level logging
    final errorMsg = '[$_tag ERROR] $message';
    print(errorMsg);
    if (error != null) {
      print('[$_tag ERROR] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag ERROR] StackTrace: $stackTrace');
    }
  }

  static void log(String message, {String level = 'INFO'}) {
    // Generic logging method
    final logMsg = '[$_tag $level] $message';
    print(logMsg);
  }

  static void logComponentEvent(String componentId, String event, [Map<String, dynamic>? data]) {
    // Specialized logging for component events
    String message = 'Component[$componentId] Event: $event';
    if (data != null && data.isNotEmpty) {
      message += ' Data: $data';
    }
    i(message);
  }

  static void logLevelEvent(String levelId, String event, [Map<String, dynamic>? data]) {
    // Specialized logging for level events
    String message = 'Level[$levelId] Event: $event';
    if (data != null && data.isNotEmpty) {
      message += ' Data: $data';
    }
    i(message);
  }

  static void logPerformance(String operation, Duration duration, [Map<String, dynamic>? metadata]) {
    // Performance logging
    String message = 'Performance[$operation] took ${duration.inMilliseconds}ms';
    if (metadata != null && metadata.isNotEmpty) {
      message += ' Metadata: $metadata';
    }
    i(message);
  }
}
// Simple logger implementation for the SparkCircuit app
// This file is now a wrapper around the StructuredLogger.

import 'package:sparkcircuit/core/debug/structured_logger.dart';

class Logger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    StructuredLogger.debug(message,
        error: error,
        context:
            stackTrace != null ? {'stackTrace': stackTrace.toString()} : null);
  }

  static void i(String message) {
    StructuredLogger.info(message);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    StructuredLogger.warning(message,
        error: error,
        context:
            stackTrace != null ? {'stackTrace': stackTrace.toString()} : null);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    StructuredLogger.error(message,
        error: error,
        context:
            stackTrace != null ? {'stackTrace': stackTrace.toString()} : null);
  }

  static void log(String message, {String level = 'INFO'}) {
    StructuredLogger.log(message, context: {'level': level});
  }

  static void logComponentEvent(String componentId, String event,
      [Map<String, dynamic>? data]) {
    var message = 'Component[$componentId] Event: $event';
    if (data != null && data.isNotEmpty) {
      message += ' Data: $data';
    }
    StructuredLogger.info(message);
  }

  static void logLevelEvent(String levelId, String event,
      [Map<String, dynamic>? data]) {
    var message = 'Level[$levelId] Event: $event';
    if (data != null && data.isNotEmpty) {
      message += ' Data: $data';
    }
    StructuredLogger.info(message);
  }

  static void logPerformance(String operation, Duration duration,
      [Map<String, dynamic>? metadata]) {
    var message = 'Performance[$operation] took ${duration.inMilliseconds}ms';
    if (metadata != null && metadata.isNotEmpty) {
      message += ' Metadata: $metadata';
    }
    StructuredLogger.info(message);
  }
}

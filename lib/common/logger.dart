// Simple logger implementation for the SparkCircuit app
// This replaces the missing logger.dart file

class Logger {
  static const String _tag = 'SparkCircuit';

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    // Debug level logging
    print('[$_tag DEBUG] $message');
    if (error != null) {
      print('[$_tag DEBUG] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag DEBUG] StackTrace: $stackTrace');
    }
  }

  static void i(String message) {
    // Info level logging
    print('[$_tag INFO] $message');
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    // Warning level logging
    print('[$_tag WARNING] $message');
    if (error != null) {
      print('[$_tag WARNING] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag WARNING] StackTrace: $stackTrace');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    // Error level logging
    print('[$_tag ERROR] $message');
    if (error != null) {
      print('[$_tag ERROR] Error: $error');
    }
    if (stackTrace != null) {
      print('[$_tag ERROR] StackTrace: $stackTrace');
    }
  }

  static void log(String message, {String level = 'INFO'}) {
    // Generic logging method
    print('[$_tag $level] $message');
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
class Logger {
  static void log(String message, {dynamic error, StackTrace? stackTrace}) {
    print('[LOG] $message');
    if (error != null) {
      print('  Error: $error');
    }
    if (stackTrace != null) {
      print('  Stack: $stackTrace');
    }
  }

  static void info(String message, Map<String, dynamic> metadata) {
    print('[INFO] $message');
  }

  static void warning(String message, Map<String, String> map) {
    print('[WARNING] $message');
  }

  static void error(String message, Map<String, String> map) {
    print('[ERROR] $message');
  }
}

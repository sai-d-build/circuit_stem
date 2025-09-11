# Logging Best Practices

## Overview

This document outlines the best practices for using the structured logging system in the Circuit STEM application. The logging system is designed to be environment-aware, performance-conscious, and developer-friendly.

## Log Levels

The system supports the following log levels:

- **DEBUG**: Detailed information for development and troubleshooting
- **INFO**: General information about application flow
- **WARNING**: Potentially harmful situations that don't prevent execution
- **ERROR**: Error conditions that might affect functionality
- **NONE**: Disable all logging

## Environment-Based Configuration

The logging system automatically adjusts based on the build environment:

### Debug Mode (Development)
- Default level: `DEBUG`
- All log levels are enabled
- Full context information included

### Profile Mode
- Default level: `INFO`
- Debug logs are disabled
- Optimized for performance analysis

### Release Mode
- Default level: `WARNING`
- Only warnings and errors are logged
- Minimal performance impact

## Usage Guidelines

### 1. Choose the Right Log Level

```dart
// Use DEBUG for development-only information
StructuredLogger.debug('Component state updated', context: {'componentId': id});

// Use INFO for important application events
StructuredLogger.info('Level loaded successfully', context: {'levelId': levelId});

// Use WARNING for recoverable issues
StructuredLogger.warning('Component placement failed', context: {'reason': 'invalid_position'});

// Use ERROR for serious issues
StructuredLogger.error('Failed to save game state', context: {'error': e.toString()}, error: e);
```

### 2. Include Relevant Context

Always provide context information to make logs more useful:

```dart
// Good: Includes relevant context
StructuredLogger.info('Component placed', context: {
  'componentType': component.type,
  'position': '${component.row},${component.col}',
  'levelId': currentLevelId,
});

// Bad: Missing context
StructuredLogger.info('Component placed');
```

### 3. Avoid Logging in Hot Paths

Do not log in performance-critical code paths that execute frequently:

```dart
// Bad: Logging in every frame/build cycle
void build() {
  StructuredLogger.debug('Building widget');
  // ... widget building code
}

// Good: Only log important state changes
void onLevelComplete() {
  StructuredLogger.info('Level completed', context: {'levelId': levelId});
}
```

### 4. Use Appropriate Log Categories

The system supports categorized logging for different subsystems:

```dart
// Services layer
StructuredLogger.services('Database operation completed', context: {'operation': 'save'});

// Game canvas operations
if (StructuredLogger.debugGameCanvas) {
  StructuredLogger.debug('Canvas repaint triggered');
}

// Presentation layer
if (StructuredLogger.debugPresentation) {
  StructuredLogger.debug('Widget rebuilt');
}
```

## Performance Considerations

### 1. Log Level Checks

The logging system performs level checks before processing logs:

```dart
// This is efficient - check happens before string formatting
StructuredLogger.debug('Expensive operation: ${expensiveCalculation()}');

// Even better - check debug flag first for categorized logs
if (StructuredLogger.debugServices) {
  StructuredLogger.debug('Service operation details');
}
```

### 2. Context Object Creation

Avoid creating context objects when logging is disabled:

```dart
// Good: Context created only when needed
StructuredLogger.debug('Operation completed', context: {
  'duration': stopwatch.elapsedMilliseconds,
  'itemsProcessed': itemCount,
});

// Bad: Context always created
final context = {'duration': stopwatch.elapsedMilliseconds, 'itemsProcessed': itemCount};
StructuredLogger.debug('Operation completed', context: context);
```

## Configuration

### Runtime Configuration

You can configure logging at runtime:

```dart
// Set log level
StructuredLogger.configureForEnvironment(level: LogLevel.info);

// Enable/disable logging entirely
StructuredLogger.setEnabled(false);

// Configure debug categories
StructuredLogger.setRuntimeFlag('debugServices', true);
StructuredLogger.setRuntimeFlag('debugGameCanvas', false);
```

### Environment-Specific Configuration

The system automatically configures based on Flutter build modes:

```dart
// In main.dart or app initialization
void main() {
  // Configure logging for current environment
  StructuredLogger.configureForEnvironment();

  runApp(MyApp());
}
```

## Best Practices by Component

### Widget Build Methods

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Avoid logging here - called frequently
    // Only log significant state changes

    return Container();
  }

  void onImportantEvent() {
    // Log important events only
    StructuredLogger.info('Important event occurred', context: {'eventType': 'user_action'});
  }
}
```

### Service Classes

```dart
class DataService {
  Future<void> saveData() async {
    StructuredLogger.services('Starting data save operation');

    try {
      // ... save operation
      StructuredLogger.services('Data save completed successfully');
    } catch (e) {
      StructuredLogger.error('Data save failed', context: {'error': e.toString()}, error: e);
    }
  }
}
```

### Error Handling

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  StructuredLogger.error('Operation failed', context: {
    'operation': 'riskyOperation',
    'errorType': e.runtimeType.toString(),
  }, error: e);

  // Don't rethrow immediately - log first
  rethrow;
}
```

## Testing with Logging

When writing tests, you can control logging behavior:

```dart
void main() {
  setUp(() {
    // Disable logging for tests
    StructuredLogger.setEnabled(false);
  });

  tearDown(() {
    // Re-enable for other tests
    StructuredLogger.setEnabled(true);
  });

  test('my test', () {
    // Test code - logging disabled
  });
}
```

## Migration from Old Logging

If migrating from other logging systems:

1. Replace `print()` statements with appropriate log levels
2. Add context objects to provide more information
3. Remove logging from hot paths
4. Use categorized logging for different subsystems

```dart
// Old approach
print('User logged in: $userId');

// New approach
StructuredLogger.info('User authentication successful', context: {
  'userId': userId,
  'timestamp': DateTime.now().toIso8601String(),
});
```

## Monitoring and Maintenance

### Log Analysis

- Monitor error rates in production
- Use log aggregation tools to identify patterns
- Set up alerts for critical errors

### Performance Monitoring

- Profile logging impact in different environments
- Monitor log volume and storage usage
- Adjust log levels based on performance requirements

## Common Pitfalls

1. **Over-logging**: Too many logs can hurt performance and readability
2. **Missing context**: Logs without context are hard to debug
3. **Inconsistent levels**: Use consistent log levels across similar operations
4. **Sensitive data**: Never log passwords, tokens, or personal information
5. **Large objects**: Avoid logging large objects or collections

## Conclusion

Following these best practices ensures that logging provides maximum value for debugging and monitoring while maintaining good application performance. The environment-aware configuration ensures appropriate logging levels for different deployment scenarios.
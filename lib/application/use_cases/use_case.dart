/// Base Use Case class for implementing clean architecture patterns.
/// Use cases encapsulate business logic and can be easily tested.
///
/// Example usage:
/// ```dart
/// class LoadLevelUseCase extends UseCase<LevelDefinition?, String> {
///   @override
///   Future<LevelDefinition?> execute(String levelId) async {
///     // Implementation
///   }
/// }
/// ```
abstract class UseCase<Input, Output> {
  /// Execute the use case with the given input
  Future<Output> execute(Input input);

  /// Dispose of any resources when no longer needed
  void dispose() {
    // Default implementation does nothing
  }
}

/// Use case for operations that don't require input
abstract class InputlessUseCase<Output> extends UseCase<void, Output> {
  @override
  Future<Output> execute(void input) => executeInternal();

  /// Internal execution method
  Future<Output> executeInternal();
}

/// Use case for fire-and-forget operations (no return value)
abstract class VoidUseCase<Input> extends UseCase<Input, void> {
  @override
  Future<void> execute(Input input) async {
    await executeVoid(input);
  }

  /// Execute the use case that returns void
  Future<void> executeVoid(Input input);
}

/// Use case for fire-and-forget operations without input
abstract class VoidUseCaseNoInput extends UseCase<void, void> {
  @override
  Future<void> execute(void input) async {
    await executeVoid();
  }

  /// Execute the void use case without input
  Future<void> executeVoid();
}

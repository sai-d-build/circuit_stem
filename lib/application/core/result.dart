abstract class Result<T> {
  const Result();

  bool get isSuccess;
  bool get isFailure => !isSuccess;

  T? get data;
  String? get error;

  R fold<R>(R Function(T data) onSuccess, R Function(String error) onFailure);

  // Convenience unwrapping with null safety
  T? getOrNull() => isSuccess ? data : null;
  T getOrThrow() {
    if (isSuccess) return data as T;
    throw StateError(error ?? 'Unknown failure');
  }
}

class Success<T> extends Result<T> {
  final T _data;
  const Success(this._data);

  @override
  bool get isSuccess => true;

  @override
  T get data => _data;

  @override
  String? get error => null;

  @override
  R fold<R>(R Function(T data) onSuccess, R Function(String error) onFailure) {
    return onSuccess(_data);
  }
}

class Failure<T> extends Result<T> {
  final String _error;
  const Failure(this._error);

  @override
  bool get isSuccess => false;

  @override
  T? get data => null;

  @override
  String get error => _error;

  @override
  R fold<R>(R Function(T data) onSuccess, R Function(String error) onFailure) {
    return onFailure(_error);
  }
}

// Extensions for cleaner use in notifier
extension ResultX<T> on Result<T> {
  TResult? whenSuccess<TResult>(TResult Function(T data) fn) {
    return isSuccess ? fn(data as T) : null;
  }

  TResult? whenFailure<TResult>(TResult Function(String error) fn) {
    return isFailure ? fn(error!) : null;
  }
}

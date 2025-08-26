abstract class Result<T> {
  const Result();
  
  bool get isSuccess;
  bool get isFailure => !isSuccess;
  
  T? get data;
  String? get error;
  
  R fold<R>(R Function(T data) onSuccess, R Function(String error) onFailure);
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

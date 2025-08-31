// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animation_system.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AnimationResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Duration duration) success,
    required TResult Function(String reason) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Duration duration)? success,
    TResult? Function(String reason)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Duration duration)? success,
    TResult Function(String reason)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AnimationResultSuccess value) success,
    required TResult Function(_AnimationResultFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AnimationResultSuccess value)? success,
    TResult? Function(_AnimationResultFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AnimationResultSuccess value)? success,
    TResult Function(_AnimationResultFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationResultCopyWith<$Res> {
  factory $AnimationResultCopyWith(
          AnimationResult value, $Res Function(AnimationResult) then) =
      _$AnimationResultCopyWithImpl<$Res, AnimationResult>;
}

/// @nodoc
class _$AnimationResultCopyWithImpl<$Res, $Val extends AnimationResult>
    implements $AnimationResultCopyWith<$Res> {
  _$AnimationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AnimationResultSuccessImplCopyWith<$Res> {
  factory _$$AnimationResultSuccessImplCopyWith(
          _$AnimationResultSuccessImpl value,
          $Res Function(_$AnimationResultSuccessImpl) then) =
      __$$AnimationResultSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Duration duration});
}

/// @nodoc
class __$$AnimationResultSuccessImplCopyWithImpl<$Res>
    extends _$AnimationResultCopyWithImpl<$Res, _$AnimationResultSuccessImpl>
    implements _$$AnimationResultSuccessImplCopyWith<$Res> {
  __$$AnimationResultSuccessImplCopyWithImpl(
      _$AnimationResultSuccessImpl _value,
      $Res Function(_$AnimationResultSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
  }) {
    return _then(_$AnimationResultSuccessImpl(
      null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$AnimationResultSuccessImpl extends _AnimationResultSuccess {
  const _$AnimationResultSuccessImpl(this.duration) : super._();

  @override
  final Duration duration;

  @override
  String toString() {
    return 'AnimationResult.success(duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationResultSuccessImpl &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, duration);

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationResultSuccessImplCopyWith<_$AnimationResultSuccessImpl>
      get copyWith => __$$AnimationResultSuccessImplCopyWithImpl<
          _$AnimationResultSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Duration duration) success,
    required TResult Function(String reason) failure,
  }) {
    return success(duration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Duration duration)? success,
    TResult? Function(String reason)? failure,
  }) {
    return success?.call(duration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Duration duration)? success,
    TResult Function(String reason)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(duration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AnimationResultSuccess value) success,
    required TResult Function(_AnimationResultFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AnimationResultSuccess value)? success,
    TResult? Function(_AnimationResultFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AnimationResultSuccess value)? success,
    TResult Function(_AnimationResultFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _AnimationResultSuccess extends AnimationResult {
  const factory _AnimationResultSuccess(final Duration duration) =
      _$AnimationResultSuccessImpl;
  const _AnimationResultSuccess._() : super._();

  Duration get duration;

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationResultSuccessImplCopyWith<_$AnimationResultSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AnimationResultFailureImplCopyWith<$Res> {
  factory _$$AnimationResultFailureImplCopyWith(
          _$AnimationResultFailureImpl value,
          $Res Function(_$AnimationResultFailureImpl) then) =
      __$$AnimationResultFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$AnimationResultFailureImplCopyWithImpl<$Res>
    extends _$AnimationResultCopyWithImpl<$Res, _$AnimationResultFailureImpl>
    implements _$$AnimationResultFailureImplCopyWith<$Res> {
  __$$AnimationResultFailureImplCopyWithImpl(
      _$AnimationResultFailureImpl _value,
      $Res Function(_$AnimationResultFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
  }) {
    return _then(_$AnimationResultFailureImpl(
      null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AnimationResultFailureImpl extends _AnimationResultFailure {
  const _$AnimationResultFailureImpl(this.reason) : super._();

  @override
  final String reason;

  @override
  String toString() {
    return 'AnimationResult.failure(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationResultFailureImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationResultFailureImplCopyWith<_$AnimationResultFailureImpl>
      get copyWith => __$$AnimationResultFailureImplCopyWithImpl<
          _$AnimationResultFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Duration duration) success,
    required TResult Function(String reason) failure,
  }) {
    return failure(reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Duration duration)? success,
    TResult? Function(String reason)? failure,
  }) {
    return failure?.call(reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Duration duration)? success,
    TResult Function(String reason)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AnimationResultSuccess value) success,
    required TResult Function(_AnimationResultFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AnimationResultSuccess value)? success,
    TResult? Function(_AnimationResultFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AnimationResultSuccess value)? success,
    TResult Function(_AnimationResultFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _AnimationResultFailure extends AnimationResult {
  const factory _AnimationResultFailure(final String reason) =
      _$AnimationResultFailureImpl;
  const _AnimationResultFailure._() : super._();

  String get reason;

  /// Create a copy of AnimationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationResultFailureImplCopyWith<_$AnimationResultFailureImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnimationMetrics {
  String get key => throw _privateConstructorUsedError;
  DateTime get loadTime => throw _privateConstructorUsedError;
  int get playCount => throw _privateConstructorUsedError;
  Duration get averageDuration => throw _privateConstructorUsedError;
  Duration get totalDuration => throw _privateConstructorUsedError;

  /// Create a copy of AnimationMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationMetricsCopyWith<AnimationMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationMetricsCopyWith<$Res> {
  factory $AnimationMetricsCopyWith(
          AnimationMetrics value, $Res Function(AnimationMetrics) then) =
      _$AnimationMetricsCopyWithImpl<$Res, AnimationMetrics>;
  @useResult
  $Res call(
      {String key,
      DateTime loadTime,
      int playCount,
      Duration averageDuration,
      Duration totalDuration});
}

/// @nodoc
class _$AnimationMetricsCopyWithImpl<$Res, $Val extends AnimationMetrics>
    implements $AnimationMetricsCopyWith<$Res> {
  _$AnimationMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? loadTime = null,
    Object? playCount = null,
    Object? averageDuration = null,
    Object? totalDuration = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      loadTime: null == loadTime
          ? _value.loadTime
          : loadTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimationMetricsImplCopyWith<$Res>
    implements $AnimationMetricsCopyWith<$Res> {
  factory _$$AnimationMetricsImplCopyWith(_$AnimationMetricsImpl value,
          $Res Function(_$AnimationMetricsImpl) then) =
      __$$AnimationMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      DateTime loadTime,
      int playCount,
      Duration averageDuration,
      Duration totalDuration});
}

/// @nodoc
class __$$AnimationMetricsImplCopyWithImpl<$Res>
    extends _$AnimationMetricsCopyWithImpl<$Res, _$AnimationMetricsImpl>
    implements _$$AnimationMetricsImplCopyWith<$Res> {
  __$$AnimationMetricsImplCopyWithImpl(_$AnimationMetricsImpl _value,
      $Res Function(_$AnimationMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimationMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? loadTime = null,
    Object? playCount = null,
    Object? averageDuration = null,
    Object? totalDuration = null,
  }) {
    return _then(_$AnimationMetricsImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      loadTime: null == loadTime
          ? _value.loadTime
          : loadTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$AnimationMetricsImpl implements _AnimationMetrics {
  const _$AnimationMetricsImpl(
      {required this.key,
      required this.loadTime,
      required this.playCount,
      required this.averageDuration,
      required this.totalDuration});

  @override
  final String key;
  @override
  final DateTime loadTime;
  @override
  final int playCount;
  @override
  final Duration averageDuration;
  @override
  final Duration totalDuration;

  @override
  String toString() {
    return 'AnimationMetrics(key: $key, loadTime: $loadTime, playCount: $playCount, averageDuration: $averageDuration, totalDuration: $totalDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationMetricsImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.loadTime, loadTime) ||
                other.loadTime == loadTime) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.averageDuration, averageDuration) ||
                other.averageDuration == averageDuration) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, key, loadTime, playCount, averageDuration, totalDuration);

  /// Create a copy of AnimationMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationMetricsImplCopyWith<_$AnimationMetricsImpl> get copyWith =>
      __$$AnimationMetricsImplCopyWithImpl<_$AnimationMetricsImpl>(
          this, _$identity);
}

abstract class _AnimationMetrics implements AnimationMetrics {
  const factory _AnimationMetrics(
      {required final String key,
      required final DateTime loadTime,
      required final int playCount,
      required final Duration averageDuration,
      required final Duration totalDuration}) = _$AnimationMetricsImpl;

  @override
  String get key;
  @override
  DateTime get loadTime;
  @override
  int get playCount;
  @override
  Duration get averageDuration;
  @override
  Duration get totalDuration;

  /// Create a copy of AnimationMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationMetricsImplCopyWith<_$AnimationMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnimationPerformanceMetrics {
  int get totalAnimations => throw _privateConstructorUsedError;
  int get totalPlays => throw _privateConstructorUsedError;
  Duration get averageLoadTime => throw _privateConstructorUsedError;
  int get memoryUsage => throw _privateConstructorUsedError;
  double get frameRate => throw _privateConstructorUsedError;

  /// Create a copy of AnimationPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationPerformanceMetricsCopyWith<AnimationPerformanceMetrics>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationPerformanceMetricsCopyWith<$Res> {
  factory $AnimationPerformanceMetricsCopyWith(
          AnimationPerformanceMetrics value,
          $Res Function(AnimationPerformanceMetrics) then) =
      _$AnimationPerformanceMetricsCopyWithImpl<$Res,
          AnimationPerformanceMetrics>;
  @useResult
  $Res call(
      {int totalAnimations,
      int totalPlays,
      Duration averageLoadTime,
      int memoryUsage,
      double frameRate});
}

/// @nodoc
class _$AnimationPerformanceMetricsCopyWithImpl<$Res,
        $Val extends AnimationPerformanceMetrics>
    implements $AnimationPerformanceMetricsCopyWith<$Res> {
  _$AnimationPerformanceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAnimations = null,
    Object? totalPlays = null,
    Object? averageLoadTime = null,
    Object? memoryUsage = null,
    Object? frameRate = null,
  }) {
    return _then(_value.copyWith(
      totalAnimations: null == totalAnimations
          ? _value.totalAnimations
          : totalAnimations // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlays: null == totalPlays
          ? _value.totalPlays
          : totalPlays // ignore: cast_nullable_to_non_nullable
              as int,
      averageLoadTime: null == averageLoadTime
          ? _value.averageLoadTime
          : averageLoadTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as int,
      frameRate: null == frameRate
          ? _value.frameRate
          : frameRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimationPerformanceMetricsImplCopyWith<$Res>
    implements $AnimationPerformanceMetricsCopyWith<$Res> {
  factory _$$AnimationPerformanceMetricsImplCopyWith(
          _$AnimationPerformanceMetricsImpl value,
          $Res Function(_$AnimationPerformanceMetricsImpl) then) =
      __$$AnimationPerformanceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalAnimations,
      int totalPlays,
      Duration averageLoadTime,
      int memoryUsage,
      double frameRate});
}

/// @nodoc
class __$$AnimationPerformanceMetricsImplCopyWithImpl<$Res>
    extends _$AnimationPerformanceMetricsCopyWithImpl<$Res,
        _$AnimationPerformanceMetricsImpl>
    implements _$$AnimationPerformanceMetricsImplCopyWith<$Res> {
  __$$AnimationPerformanceMetricsImplCopyWithImpl(
      _$AnimationPerformanceMetricsImpl _value,
      $Res Function(_$AnimationPerformanceMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimationPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAnimations = null,
    Object? totalPlays = null,
    Object? averageLoadTime = null,
    Object? memoryUsage = null,
    Object? frameRate = null,
  }) {
    return _then(_$AnimationPerformanceMetricsImpl(
      totalAnimations: null == totalAnimations
          ? _value.totalAnimations
          : totalAnimations // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlays: null == totalPlays
          ? _value.totalPlays
          : totalPlays // ignore: cast_nullable_to_non_nullable
              as int,
      averageLoadTime: null == averageLoadTime
          ? _value.averageLoadTime
          : averageLoadTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as int,
      frameRate: null == frameRate
          ? _value.frameRate
          : frameRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$AnimationPerformanceMetricsImpl
    implements _AnimationPerformanceMetrics {
  const _$AnimationPerformanceMetricsImpl(
      {required this.totalAnimations,
      required this.totalPlays,
      required this.averageLoadTime,
      required this.memoryUsage,
      required this.frameRate});

  @override
  final int totalAnimations;
  @override
  final int totalPlays;
  @override
  final Duration averageLoadTime;
  @override
  final int memoryUsage;
  @override
  final double frameRate;

  @override
  String toString() {
    return 'AnimationPerformanceMetrics(totalAnimations: $totalAnimations, totalPlays: $totalPlays, averageLoadTime: $averageLoadTime, memoryUsage: $memoryUsage, frameRate: $frameRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationPerformanceMetricsImpl &&
            (identical(other.totalAnimations, totalAnimations) ||
                other.totalAnimations == totalAnimations) &&
            (identical(other.totalPlays, totalPlays) ||
                other.totalPlays == totalPlays) &&
            (identical(other.averageLoadTime, averageLoadTime) ||
                other.averageLoadTime == averageLoadTime) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.frameRate, frameRate) ||
                other.frameRate == frameRate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalAnimations, totalPlays,
      averageLoadTime, memoryUsage, frameRate);

  /// Create a copy of AnimationPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationPerformanceMetricsImplCopyWith<_$AnimationPerformanceMetricsImpl>
      get copyWith => __$$AnimationPerformanceMetricsImplCopyWithImpl<
          _$AnimationPerformanceMetricsImpl>(this, _$identity);
}

abstract class _AnimationPerformanceMetrics
    implements AnimationPerformanceMetrics {
  const factory _AnimationPerformanceMetrics(
      {required final int totalAnimations,
      required final int totalPlays,
      required final Duration averageLoadTime,
      required final int memoryUsage,
      required final double frameRate}) = _$AnimationPerformanceMetricsImpl;

  @override
  int get totalAnimations;
  @override
  int get totalPlays;
  @override
  Duration get averageLoadTime;
  @override
  int get memoryUsage;
  @override
  double get frameRate;

  /// Create a copy of AnimationPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationPerformanceMetricsImplCopyWith<_$AnimationPerformanceMetricsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

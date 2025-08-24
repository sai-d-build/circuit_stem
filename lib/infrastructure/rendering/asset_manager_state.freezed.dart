// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AssetState {
  Map<String, Image> get svgImages => throw _privateConstructorUsedError;
  bool get isDark => throw _privateConstructorUsedError;

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssetStateCopyWith<AssetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetStateCopyWith<$Res> {
  factory $AssetStateCopyWith(
          AssetState value, $Res Function(AssetState) then) =
      _$AssetStateCopyWithImpl<$Res, AssetState>;
  @useResult
  $Res call({Map<String, Image> svgImages, bool isDark});
}

/// @nodoc
class _$AssetStateCopyWithImpl<$Res, $Val extends AssetState>
    implements $AssetStateCopyWith<$Res> {
  _$AssetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? svgImages = null,
    Object? isDark = null,
  }) {
    return _then(_value.copyWith(
      svgImages: null == svgImages
          ? _value.svgImages
          : svgImages // ignore: cast_nullable_to_non_nullable
              as Map<String, Image>,
      isDark: null == isDark
          ? _value.isDark
          : isDark // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssetStateImplCopyWith<$Res>
    implements $AssetStateCopyWith<$Res> {
  factory _$$AssetStateImplCopyWith(
          _$AssetStateImpl value, $Res Function(_$AssetStateImpl) then) =
      __$$AssetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, Image> svgImages, bool isDark});
}

/// @nodoc
class __$$AssetStateImplCopyWithImpl<$Res>
    extends _$AssetStateCopyWithImpl<$Res, _$AssetStateImpl>
    implements _$$AssetStateImplCopyWith<$Res> {
  __$$AssetStateImplCopyWithImpl(
      _$AssetStateImpl _value, $Res Function(_$AssetStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? svgImages = null,
    Object? isDark = null,
  }) {
    return _then(_$AssetStateImpl(
      svgImages: null == svgImages
          ? _value._svgImages
          : svgImages // ignore: cast_nullable_to_non_nullable
              as Map<String, Image>,
      isDark: null == isDark
          ? _value.isDark
          : isDark // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AssetStateImpl implements _AssetState {
  const _$AssetStateImpl(
      {final Map<String, Image> svgImages = const {}, this.isDark = false})
      : _svgImages = svgImages;

  final Map<String, Image> _svgImages;
  @override
  @JsonKey()
  Map<String, Image> get svgImages {
    if (_svgImages is EqualUnmodifiableMapView) return _svgImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_svgImages);
  }

  @override
  @JsonKey()
  final bool isDark;

  @override
  String toString() {
    return 'AssetState(svgImages: $svgImages, isDark: $isDark)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetStateImpl &&
            const DeepCollectionEquality()
                .equals(other._svgImages, _svgImages) &&
            (identical(other.isDark, isDark) || other.isDark == isDark));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_svgImages), isDark);

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetStateImplCopyWith<_$AssetStateImpl> get copyWith =>
      __$$AssetStateImplCopyWithImpl<_$AssetStateImpl>(this, _$identity);
}

abstract class _AssetState implements AssetState {
  const factory _AssetState(
      {final Map<String, Image> svgImages,
      final bool isDark}) = _$AssetStateImpl;

  @override
  Map<String, Image> get svgImages;
  @override
  bool get isDark;

  /// Create a copy of AssetState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetStateImplCopyWith<_$AssetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

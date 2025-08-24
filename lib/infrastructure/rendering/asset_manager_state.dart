import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_manager_state.freezed.dart';

@freezed
abstract class AssetState with _$AssetState {
  const factory AssetState({
    @Default({}) Map<String, Image> svgImages,
    @Default(false) bool isDark,
  }) = _AssetState;
}

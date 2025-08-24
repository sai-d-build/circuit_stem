import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_metadata.freezed.dart';
part 'level_metadata.g.dart';

@freezed
class LevelMetadata with _$LevelMetadata {
  const factory LevelMetadata({
    required String id,
    required String title,
    required String description,
    required int levelNumber,
    @Default(false) bool unlocked,
  }) = _LevelMetadata;

  factory LevelMetadata.fromJson(Map<String, dynamic> json) =>
      _$LevelMetadataFromJson(json);
}

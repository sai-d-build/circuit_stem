import 'package:freezed_annotation/freezed_annotation.dart';
import 'position.dart';

part 'hint.freezed.dart';
part 'hint.g.dart';

@freezed
class Hint with _$Hint {
  const factory Hint({
    required String type,
    List<Position>? path,
  }) = _Hint;

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);
}
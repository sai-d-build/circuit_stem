import 'package:freezed_annotation/freezed_annotation.dart';

part 'hint.freezed.dart';
part 'hint.g.dart';

@freezed
class Hint with _$Hint {
  const factory Hint({
    required String id,
    required String text,
    required String trigger, // e.g., "on_error", "on_timeout"
    dynamic triggerValue, // Can be int or String
  }) = _Hint;

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);
}

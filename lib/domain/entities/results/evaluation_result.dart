import 'package:freezed_annotation/freezed_annotation.dart';

part 'evaluation_result.freezed.dart';

@freezed
class EvaluationResult with _$EvaluationResult {
  const factory EvaluationResult({
    @Default([]) List<String> poweredComponents,
    @Default([]) List<String> poweredComponentIds,
    @Default(false) bool isShortCircuit,
  }) = _EvaluationResult;
}

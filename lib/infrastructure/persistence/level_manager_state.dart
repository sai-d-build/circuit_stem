import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/level_definition.dart';

part 'level_manager_state.freezed.dart';

@freezed
class LevelManagerState with _$LevelManagerState {
  const factory LevelManagerState({
    @Default([]) List<LevelMetadata> levels,
    @Default({}) Set<String> completedLevelIds,
    @Default(true) bool isLoading,
    LevelDefinition? currentLevelDefinition,
    String? errorMessage,
  }) = _LevelManagerState;
}

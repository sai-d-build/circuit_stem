// part 'history_state.freezed.dart';
// part 'history_state.g.dart';

class HistoryState {
  final List<String> commands;

  const HistoryState({
    this.commands = const [],
  });

  factory HistoryState.initial() => const HistoryState();

  HistoryState copyWith({
    List<String>? commands,
  }) {
    return HistoryState(
      commands: commands ?? this.commands,
    );
  }
}
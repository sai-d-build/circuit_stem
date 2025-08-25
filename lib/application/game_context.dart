import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/game_engine_state.dart';

class GameContext {
  final Grid grid;
  final int? toRow;
  final int? toCol;

  GameContext({
    required this.grid,
    this.toRow,
    this.toCol,
  });

  factory GameContext.from(GameEngineState state) {
    return GameContext(grid: state.grid);
  }
}

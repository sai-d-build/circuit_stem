import 'package:circuit_stem/domain/entities/grid.dart';

class ActionContext {
  final Grid? gridState;
  final DateTime timestamp;

  ActionContext({
    this.gridState,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

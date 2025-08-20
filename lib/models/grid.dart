import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';
import '../common/constants.dart';

part 'grid.freezed.dart';

@freezed
class Grid with _$Grid {
  const Grid._();

  const factory Grid({
    required int rows,
    required int cols,
    @Default([]) List<ComponentModel> components,
  }) = _Grid;

  Map<String, ComponentModel> get componentsById {
    return {for (var c in components) c.id: c};
  }

  ComponentModel? componentAt(int r, int c) {
    for (final component in components) {
      for (final offset in component.shapeOffsets) {
        if (component.r + offset.y == r && component.c + offset.x == c) {
          return component;
        }
      }
    }
    return null;
  }

  bool isCellOccupied(int r, int c, {String? excludeComponentId}) {
    final component = componentAt(r, c);
    if (component == null) return false;
    if (component.id == excludeComponentId) return false;
    return true;
  }

  Grid copyWithUpdatedComponent(ComponentModel component) {
    final newComponents = components.map((c) {
      return c.id == component.id ? component : c;
    }).toList();
    return copyWith(components: newComponents);
  }

  Cell? cellAt(double x, double y) {
    final c = (x / cellSize).floor();
    final r = (y / cellSize).floor();
    if (r < 0 || r >= rows || c < 0 || c >= cols) {
      return null;
    }
    return Cell(r, c);
  }
}

class Cell {
  final int r;
  final int c;
  Cell(this.r, this.c);
}
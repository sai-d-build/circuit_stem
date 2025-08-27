import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';
import '../../common/constants.dart';
import '../../common/logger.dart';
import 'grid_cell.dart';

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
        if (component.r + offset.r == r && component.c + offset.c == c) {
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
    Logger.log('Grid.copyWithUpdatedComponent: Component '
        '${component.id}'
        ' updated. New state: ${component.state}');
    return copyWith(components: newComponents);
  }

  GridCell? getCellFromLocalOffset(double dx, double dy) {
    final c = (dx / cellSize).floor();
    final r = (dy / cellSize).floor();
    if (r < 0 || r >= rows || c < 0 || c >= cols) {
      return null;
    }
    return GridCell(r, c);
  }
}

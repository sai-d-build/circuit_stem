import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';

part 'grid.freezed.dart';

@freezed
class Grid with _$Grid {
  const Grid._(); // Private constructor for getters and methods

  const factory Grid({
    required int rows,
    required int cols,
    @Default({}) Map<String, ComponentModel> componentsById,
  }) = _Grid;

  // Computed property for occupancy map. This is derived from the components.
  Map<String, String> get occupancy {
    final map = <String, String>{};
    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        map['$r:$c'] = comp.id;
      }
    }
    return map;
  }

  ComponentModel? getComponentById(String id) => componentsById[id];

  List<ComponentModel> componentsAt(int r, int c) {
    final id = occupancy['$r:$c'];
    if (id == null) return [];
    final comp = componentsById[id];
    return comp == null ? [] : [comp];
  }

  /// Validates the grid state, returning a list of error messages.
  List<String> validate() {
    final messages = <String>[];
    final occupied = <String, String>{};

    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        final key = '$r:$c';

        if (r < 0 || r >= rows || c < 0 || c >= cols) {
          messages.add('Component ${comp.id} out-of-bounds at cell [$r,$c].');
        } else if (occupied.containsKey(key)) {
          messages.add('Component ${comp.id} overlaps with ${occupied[key]} at cell [$r,$c].');
        } else {
          occupied[key] = comp.id;
        }
      }
      if (comp.type == "Component.Battery") {
        if (comp.terminals.length < 2) {
          messages.add('Battery ${comp.id} has fewer than 2 terminals; expected pos & neg.');
        }
      }
    }
    return messages;
  }

  /// Checks if a component can be placed at a new position without collision.
  bool canPlaceComponent(ComponentModel component, int r, int c) {
    // Create a temporary copy of the component at the new position
    final tempComponent = component.copyWith(r: r, c: c);

    // Check 1: Is the new position out of bounds?
    for (final off in tempComponent.shapeOffsets) {
      final newR = tempComponent.r + off.dr;
      final newC = tempComponent.c + off.dc;
      if (newR < 0 || newR >= rows || newC < 0 || newC >= cols) {
        return false; // Out of bounds
      }
    }

    // Check 2: Does it collide with any *existing* components?
    final currentOccupancy = occupancy; // Use existing occupancy map
    for (final off in tempComponent.shapeOffsets) {
      final key = '${tempComponent.r + off.dr}:${tempComponent.c + off.dc}';
      if (currentOccupancy.containsKey(key)) {
        return false; // Collision detected
      }
    }

    return true; // Placement is valid
  }
}
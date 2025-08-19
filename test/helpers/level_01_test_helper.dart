import 'package:flutter/services.dart';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}

class Level1TestHelper {
  static const double cellSize = 64.0;
  static const Size testCanvasSize = Size(384, 384); // 6x6 grid * 64px

  static Offset gridToPixel(Position pos) {
    return Offset(
      (pos.c * cellSize) + (cellSize / 2),
      (pos.r * cellSize) + (cellSize / 2),
    );
  }

  static Position pixelToGrid(Offset pixel) {
    return Position(
      r: (pixel.dy / cellSize).floor(),
      c: (pixel.dx / cellSize).floor(),
    );
  }

  static ComponentModel? findComponentById(ProviderContainer container, String id) {
    final state = container.read(gameEngineProvider);
    return state.grid.componentsById.values.where((c) => c.id == id).firstOrNull;
  }

  static bool isComponentAtPosition(ComponentModel component, Position pos) {
    return component.r == pos.r && component.c == pos.c;
  }
  
  static bool getSwitchState(ComponentModel component) {
    assert(component.type == "Component.Switch", 'Component must be a switch');
    return component.state['closed'] as bool? ?? false;
  }

  static Future<void> tapComponent(WidgetTester tester, Position pos) async {
    await tester.tapAt(gridToPixel(pos));
  }

  static Future<void> dragComponent(WidgetTester tester, Position from, Position to) async {
    final startPixel = gridToPixel(from);
    final endPixel = gridToPixel(to);
    await tester.dragFrom(startPixel, endPixel - startPixel);
  }
  
  static Future<void> waitForCircuitUpdate(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }
}
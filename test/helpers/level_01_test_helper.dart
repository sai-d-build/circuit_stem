import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/models/component.dart';
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

  static ComponentModel? findComponentById(ProviderContainer container, String id) {
    final state = container.read(gameEngineProvider);
    final grid = state.grid;
    try {
      return grid.components.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static bool isComponentAt(ComponentModel component, int r, int c) {
    return component.r == r && component.c == c;
  }

  static bool getSwitchState(ComponentModel component) {
    assert(component.type == 'Component.Switch', 'Component must be a switch');
    return component.state['closed'] as bool? ?? false;
  }

  static Future<void> tapComponent(WidgetTester tester, Offset offset) async {
    await tester.tapAt(offset);
  }

  static Future<void> dragComponent(WidgetTester tester, Offset from, Offset to) async {
    await tester.dragFrom(from, to - from);
  }

  static Future<void> waitForCircuitUpdate(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }
}

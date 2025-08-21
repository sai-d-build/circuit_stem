// test/helpers/game_test_helper.dart
import 'dart:math';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock_services.dart';

/// A universal helper class for all game-related tests.
/// Provides methods for state querying, grid interaction, and more.
class GameTestHelper {
  static const double cellSize = 64.0;

  // --- State Querying Methods ---
  static ComponentModel findComponentById(ProviderContainer container, String id) {
    final level = container.read(levelManagerProvider).currentLevel!;
    final state = container.read(gameEngineProvider(level));
    return state.grid.components.firstWhere((c) => c.id == id, orElse: () {
      throw StateError('Component with id "$id" not found.');
    });
  }

  static bool isBulbPowered(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'Component.Bulb');
    return component.isPowered;
  }

  static bool isSwitchClosed(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'Component.Switch');
    return component.state['closed'] as bool? ?? false;
  }

  static bool isTimerActive(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'Component.Timer');
    // Assumes the timer's active state is stored in the 'active' key.
    return component.state['active'] as bool? ?? false;
  }

  static bool isGameInWinState(ProviderContainer container) {
    final level = container.read(levelManagerProvider).currentLevel!;
    final state = container.read(gameEngineProvider(level));
    return state.isWinConditionMet;
  }

  // --- Enhanced Grid Interaction ---
  static Offset gridToPixel(int row, int col) {
    return Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2);
  }

  static Future<void> tapGridCell(WidgetTester tester, int row, int col) async {
    await tester.tapAt(gridToPixel(row, col));
    await tester.pumpAndSettle();
  }

  static Future<void> dragComponentToGrid(
      WidgetTester tester, ProviderContainer container, String componentId, int toRow, int toCol) async {
    final component = findComponentById(container, componentId);
    final from = gridToPixel(component.r, component.c);
    final to = gridToPixel(toRow, toCol);
    await tester.dragFrom(from, to - from);
    await tester.pumpAndSettle();
  }

  // --- UI Button Interactions ---
  static Future<void> tapButton(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  // --- Audio Verification ---
  static void expectSoundPlayed(MockAudioService audioService, String expectedSound) {
    expect(audioService.playedSounds, contains(expectedSound),
        reason: "Expected sound '$expectedSound' was not played. Sounds played: ${audioService.playedSounds}");
  }
}

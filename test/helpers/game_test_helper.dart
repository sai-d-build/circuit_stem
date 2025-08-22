
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/component.dart'; // Added import for ComponentModel
import 'package:circuit_stem/core/providers.dart'; // Added import for providers
import 'mock_services.dart';

/// A universal helper class for all game-related tests.
/// Provides methods for state querying, grid interaction, and more.
class GameTestHelper {
  static const double cellSize = 64.0;

  // --- State Querying Methods ---
  static ComponentModel findComponentById(ProviderContainer container, String id) {
    final level = container.read(levelManagerProvider).currentLevelDefinition!;
    final state = container.read(gameEngineProvider);
    return state.grid.components.firstWhere((c) => c.id == id, orElse: () {
      throw StateError('Component with id "$id" not found.');
    });
  }

  static bool isBulbPowered(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'bulb'); // Changed to component.type
    return component.isPowered;
  }

  static bool isSwitchClosed(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'switch'); // Changed to component.type
    return component.state['isClosed'] as bool? ?? false; // Changed to state['isClosed']
  }

  static bool isTimerActive(ProviderContainer container, String componentId) {
    final component = findComponentById(container, componentId);
    assert(component.type == 'timer'); // Changed to component.type
    // Assumes the timer's active state is stored in the 'active' key.
    return component.state['isActive'] as bool? ?? false; // Changed to state['isActive']
  }

  static bool isGameInWinState(ProviderContainer container) {
    final level = container.read(levelManagerProvider).currentLevelDefinition!;
    final state = container.read(gameEngineProvider);
    return state.isWin;
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
    final from = gridToPixel(component.r, component.c); // Changed to r, c
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


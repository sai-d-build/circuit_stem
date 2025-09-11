import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/infrastructure/audio/audio_service.dart';
import 'package:sparkcircuit/infrastructure/rendering/asset_manager.dart';
import 'package:sparkcircuit/application/services/level_service.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
// Mock classes for testing - using direct imports to avoid path issues
class MockAudioService extends Mock implements AudioService {}

class MockAssetManager extends Mock implements AssetManagerNotifier {}

class MockGridService extends Mock implements GridService {}

class MockLevelService extends Mock implements LevelService {
  @override
  Future<List<LevelDefinition>> loadAllLevels() async => [];

  @override
  Future<LevelDefinition?> loadLevel(String levelId) async => null;

  @override
  Future<LevelMetadata?> getLevelMetadata(String levelId) async => null;

  @override
  Future<List<String>> getAvailableLevelIds() async => [];

  @override
  Future<List<LevelDefinition>> getLevelsByDifficulty(String difficulty) async => [];

  @override
  Future<List<LevelDefinition>> getLevelsByTag(String tag) async => [];

  @override
  Future<bool> validateLevelFile(String levelId) async => true;

  @override
  void clearCache() {}
}

// Test helper utilities for common provider overrides

/// Mock providers for basic widget testing scenarios
List<Override> createTestProviderOverrides() {
  return [
    // Grid Service Provider
    gridServiceProvider.overrideWithValue(
      MockGridService(),
    ),

    // Grid Configuration Provider
    gridConfigurationProvider.overrideWithValue(
      const GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60.0,
        scale: 1.0,
        panOffset: Offset.zero,
      ),
    ),

    // Render Configuration Provider (simulate a simple implementation)
    renderConfigurationProvider.overrideWithValue(
      const RenderConfiguration(
        gridLineColor: Color(0xFFE0E0E0),
        majorGridLineColor: Color(0xFFBBBBBB),
      ),
    ),

    // Audio Service Provider
    audioServiceProvider.overrideWithValue(
      MockAudioService(),
    ),

    // Asset Manager Provider
    assetManagerNotifierProvider.overrideWithValue(
      MockAssetManager(),
    ),

    // Mock level service (simplified)
    levelServiceProvider.overrideWithValue(
      MockLevelService(),
    ),
  ];
}

/// Simplified test wrapper for drag-and-drop widget testing
Widget wrapWithTestProviders(Widget child) {
  return ProviderScope(
    overrides: createTestProviderOverrides(),
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Mock implementations for testing


class _MockAudioService {
  void play(String sound) {}
  void stop() {}
  void dispose() {}
}

class _MockAssetManager {
  Future<void> loadAssets() async {}
  void dispose() {}
}

class _MockLevelService {
  Future<dynamic> loadLevel(String levelId) async {
    return null; // Return null to simulate unloaded level
  }
}

// Helper matcher for grid coordinate comparisons
Matcher equalsOffset(Offset expected) {
  return predicate<Offset>(
    (actual) => actual.dx == expected.dx && actual.dy == expected.dy,
    'equals $expected'
  );
}

// Helper function to create test gestures
Future<TestGesture> createTestGestureAt(WidgetTester tester, Offset position) async {
  final TestGesture gesture = await tester.createGesture();
  await gesture.down(position);
  return gesture;
}

// Helper for drag operations in tests
Future<void> testDragOperation(
  WidgetTester tester,
  Finder finder,
  Offset startOffset,
  Offset endOffset, {
  Duration? duration,
}) async {
  await tester.drag(finder, endOffset - startOffset, warnIfMissed: false);
  if (duration != null) {
    await tester.pump(duration);
  } else {
    await tester.pumpAndSettle();
  }
}

// Helper for boundary test scenarios
List<Map<String, dynamic>> createBoundaryTestCases() {
  return [
    {
      'name': 'Top-Left Corner',
      'screenPos': const Offset(0, 0),
      'expectedGrid': const Offset(0, 0),
    },
    {
      'name': 'Bottom-Right Corner',
      'screenPos': const Offset(594, 594), // 9.9 * 60
      'expectedGrid': const Offset(9, 9),
    },
    {
      'name': 'Boundary Position',
      'screenPos': const Offset(570, 570), // 9.5 * 60
      'expectedGrid': const Offset(9, 9),
    },
    {
      'name': 'Outside Bounds',
      'screenPos': const Offset(700, 700),
      'expectedGrid': null,
    },
  ];
}

// Test configuration factory
GridConfiguration createTestGridConfig({
  int rows = 10,
  int cols = 10,
  double cellSize = 60.0,
  double scale = 1.0,
  Offset panOffset = Offset.zero,
}) {
  return GridConfiguration(
    rows: rows,
    cols: cols,
    cellSize: cellSize,
    scale: scale,
    panOffset: panOffset,
  );
}
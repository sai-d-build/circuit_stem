import 'dart:io';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/common/constants.dart';

import 'helpers/level_01_test_helper.dart';
import 'helpers/mock_asset_manager.dart';
import 'helpers/mock_animation_scheduler.dart';
import 'helpers/mock_audio_service.dart';

void main() {
  group('Level 01 Revised Tests - Foundation', () {
    Future<ProviderContainer> pumpGameScreenWithOverrides(WidgetTester tester) async {
      final mockAssetManager = MockAssetManager();
      final mockAnimationScheduler = MockAnimationScheduler();
      final mockAudioService = MockAudioService();
      SharedPreferences.setMockInitialValues({});
      final mockPrefs = await SharedPreferences.getInstance();

      final manifestContent =
          await File('assets/levels/level_manifest.json').readAsString();
      final level1Content =
          await File('assets/levels/level_01.json').readAsString();
      mockAssetManager.primeFile(
          'assets/levels/level_manifest.json', manifestContent);
      mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

      final container = ProviderContainer(
        overrides: [
          assetManagerProvider.overrideWith((_) => mockAssetManager),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          levelManagerProvider.overrideWith((ref) {
            return LevelManagerNotifier(
              ref.watch(sharedPreferencesProvider),
              mockAssetManager,
            );
          }),
        ],
      );

      await container.read(levelManagerProvider.notifier).init();
      // It's better to load by a specific number in tests for clarity
      final initialLevel = await container.read(levelManagerProvider.notifier).loadLevelByIndex(1);
      
      expect(initialLevel, isNotNull, reason: "Test setup failed: Level 1 could not be loaded.");

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ProviderScope(
            overrides: [
              // Override the family provider with the specific level instance
              gameEngineProvider(initialLevel!).overrideWith((ref) {
                return GameEngineNotifier(
                  initialLevel: initialLevel,
                  animationScheduler: mockAnimationScheduler,
                  audioService: mockAudioService,
                );
              }),
            ],
            child: const MaterialApp(
              home: GameScreen(levelIndex: 1),
            ),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    testWidgets(
      'TC-L1-01: Toggle switch interaction',
      (WidgetTester tester) => fakeAsync((async) async {
        final container = await pumpGameScreenWithOverrides(tester);
        final level = await container.read(levelDefinitionProvider(1).future);
        final mockAnimationScheduler = container.read(gameEngineProvider(level!).notifier).animationScheduler as MockAnimationScheduler;

        final switchComponent = Level1TestHelper.findComponentById(container, level!, 'switch1');
        expect(switchComponent, isNotNull);
        final initialSwitchClosed = Level1TestHelper.getSwitchState(switchComponent!);

        final tapOffset = Offset(switchComponent.c * cellSize + cellSize / 2, switchComponent.r * cellSize + cellSize / 2);
        await Level1TestHelper.tapComponent(tester, tapOffset);
        mockAnimationScheduler.triggerCallback(0.016);
        await tester.pump();

        final newSwitchComponent = Level1TestHelper.findComponentById(container, level!, 'switch1')!;
        final finalSwitchClosed = Level1TestHelper.getSwitchState(newSwitchComponent);

        expect(finalSwitchClosed, !initialSwitchClosed);
      }),
      timeout: const Timeout(Duration(minutes: 1)),
    );

    testWidgets(
      'TC-L1-02: Move timer component',
      (WidgetTester tester) async {
        final container = await pumpGameScreenWithOverrides(tester);
        final level = await container.read(levelDefinitionProvider(1).future);
        final gameNotifier = container.read(gameEngineProvider(level!).notifier);
        final mockAnimationScheduler = gameNotifier.animationScheduler as MockAnimationScheduler;

        final timerComponent = Level1TestHelper.findComponentById(container, level, 'timer1');
        expect(timerComponent, isNotNull);
        expect(timerComponent!.isDraggable, isTrue);

        final fromOffset = Offset(timerComponent.c * cellSize + cellSize / 2, timerComponent.r * cellSize + cellSize / 2);
        const toOffset = Offset(3 * cellSize + cellSize / 2, 2 * cellSize + cellSize / 2);

        await Level1TestHelper.dragComponent(tester, fromOffset, toOffset);
        mockAnimationScheduler.triggerCallback(0.016);
        await tester.pump();

        final movedComponent = Level1TestHelper.findComponentById(container, level, 'timer1')!;
        expect(movedComponent.r, equals(2));
        expect(movedComponent.c, equals(3));
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );
  });
}


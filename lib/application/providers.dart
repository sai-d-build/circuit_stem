
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/infrastructure/audio/audio_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';

// Provider for the simple AnimationScheduler
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

// Assumes audioServiceProvider is defined elsewhere, e.g., in audio_service.dart
// This is a common pattern for service providers.

final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>(
  (ref) {
    final audioService = ref.watch(audioServiceProvider);
    final animationScheduler = ref.watch(animationSchedulerProvider);
    final levelManager = ref.watch(levelManagerProvider.notifier);
    return GameEngineNotifier(
      audioService: audioService,
      animationScheduler: animationScheduler,
      levelManager: levelManager,
    );
  },
);

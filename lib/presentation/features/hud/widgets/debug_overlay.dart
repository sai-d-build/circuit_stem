import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/presentation/state/game_state.dart';
import 'package:circuit_stem/presentation/state/hud_state.dart';

class DebugOverlay extends ConsumerWidget {
  const DebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(debugOverlayProvider);
    if (!isVisible) return const SizedBox.shrink();

    final gameState = ref.watch(gameEngineProvider);

    return Positioned(
      top: 40,
      left: 10,
      child: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black.withAlpha((255 * 0.7).round()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Components: ${gameState.grid.components.length}',
                  style: const TextStyle(color: Colors.white)),
              Text('Selected: ${gameState.selectedComponentId ?? 'none'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Win: ${gameState.isWin}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

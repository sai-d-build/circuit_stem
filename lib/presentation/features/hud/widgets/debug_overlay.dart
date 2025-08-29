import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/presentation/state/game_state.dart' hide gameEngineProvider, gridProvider; // Avoid monolithic provider and name clashes
import 'package:circuit_stem/application/providers.dart'; // Granular providers
import 'package:circuit_stem/presentation/state/hud_state.dart' hide debugOverlayProvider;

class DebugOverlay extends ConsumerWidget {
  const DebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(debugOverlayProvider);
    if (!isVisible) return const SizedBox.shrink();

    // Use granular providers to minimize rebuilds
    final grid = ref.watch(gridProvider);
    final selectedComponentId = ref.watch(selectedComponentIdProvider);
    final isWin = ref.watch(isWinProvider);

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
              Text('Components: ${grid.components.length}',
                  style: const TextStyle(color: Colors.white)),
              Text('Selected: ${selectedComponentId ?? 'none'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Win: $isWin',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/ui/widgets/debug_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/providers.dart';

class DebugOverlay extends ConsumerWidget {
  const DebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugController = ref.watch(debugOverlayControllerProvider);
    if (!debugController.isVisible) return const SizedBox.shrink();

    return Positioned(
      top: 40,
      left: 10,
      child: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black.withAlpha((255 * 0.7).round()),
          child: const Text(
            'Debug overlay temporarily disabled.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

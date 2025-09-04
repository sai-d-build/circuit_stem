// lib/presentation/features/debug/widgets/cloud_debug_panel.dart
// Debug panel for testing cloud functionality

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/cloud_config.dart';

class CloudDebugPanel extends ConsumerWidget {
  const CloudDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final cloudStatus = ref.watch(cloudStatusProvider); // Temporarily commented out
    final cloudStatus = "disabled"; // Placeholder

    // Only show in debug mode
    if (!CloudConfig.enableCloudLogging) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.cloud, color: Colors.yellow, size: 16),
              const SizedBox(width: 8),
              Text(
                'Cloud Debug Panel',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () {
                  // TODO: Add logic to hide debug panel
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Current status
          Text(
            'Status: $cloudStatus',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Mode buttons
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildModeButton(
                context,
                'Local Only',
                CloudServiceMode.localOnly,
                currentCloudMode == CloudServiceMode.localOnly,
                () => CloudTestingUtils.disableCloudSync(),
              ),
              _buildModeButton(
                context,
                'Mock Cloud',
                CloudServiceMode.mocked,
                currentCloudMode == CloudServiceMode.mocked,
                () => CloudTestingUtils.useMockedCloud(),
              ),
              _buildModeButton(
                context,
                'Emulator',
                CloudServiceMode.emulator,
                currentCloudMode == CloudServiceMode.emulator,
                () => CloudTestingUtils.useEmulator(),
              ),
              _buildModeButton(
                context,
                'Real Cloud',
                CloudServiceMode.real,
                currentCloudMode == CloudServiceMode.real,
                () => CloudTestingUtils.enableCloudSync(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                CloudTestingUtils.resetToDefault();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cloud mode reset to default'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
              child: const Text('Reset to Default'),
            ),
          ),

          const SizedBox(height: 4),

          // Info text
          Text(
            '⚠️ Debug panel only visible in debug mode',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    CloudServiceMode mode,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.green.shade800,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
        ),
      ),
      child: Text(label),
    );
  }
}

// Provider for controlling debug panel visibility
final showCloudDebugPanelProvider = StateProvider<bool>((ref) => false);

// Extension to easily add debug panel to any widget
extension CloudDebugExtension on Widget {
  Widget withCloudDebugPanel() {
    return Stack(
      children: [
        this,
        Positioned(
          top: 80,
          right: 8,
          child: const CloudDebugPanel(),
        ),
      ],
    );
  }
}

// Utility functions for testing
class CloudTestUtils {
  /// Enable cloud sync for all subsequent operations
  static void enableCloudForTesting() {
    CloudTestingUtils.enableCloudSync();
  }

  /// Disable cloud sync for testing local-only functionality
  static void disableCloudForTesting() {
    CloudTestingUtils.disableCloudSync();
  }

  /// Use mocked cloud services for testing
  static void useMockCloudForTesting() {
    CloudTestingUtils.useMockedCloud();
  }

  /// Reset to default cloud configuration
  static void resetCloudConfiguration() {
    CloudTestingUtils.resetToDefault();
  }

  /// Get current cloud service description
  static String getCurrentCloudMode() {
    return CloudTestingUtils.currentModeDescription;
  }

  /// Check if cloud is currently enabled
  static bool isCloudEnabled() {
    return CloudTestingUtils.isCloudEnabled;
  }

  /// Check if using mocked services
  static bool isUsingMock() {
    return CloudTestingUtils.isUsingMock;
  }

  /// Check if using emulator
  static bool isUsingEmulator() {
    return CloudTestingUtils.isUsingEmulator;
  }
}
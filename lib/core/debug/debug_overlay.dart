import 'structured_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../application/enhanced_game_state.dart';

/// Debug overlay for in-app developer tools
class DebugOverlay extends StatelessWidget {
  final PerformanceMonitorData performanceData;
  final GameState? gameState;
  final bool isVisible;

  const DebugOverlay({
    super.key,
    required this.performanceData,
    this.gameState,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 50,
      right: 20,
      child: Material(
        elevation: 8,
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const Divider(height: 8, color: Colors.white30),
              _buildPerformanceMetrics(),
              if (gameState != null) ...[
                const Divider(height: 8, color: Colors.white30),
                _buildGameState(),
              ],
              const Divider(height: 8, color: Colors.white30),
              _buildDebugActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.bug_report, color: Colors.orange, size: 16),
        const SizedBox(width: 8),
        Text(
          'Debug Panel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        _buildMetricItem(
          'FPS',
          '${performanceData.fps.toStringAsFixed(1)}',
          performanceData.fps < 50 ? Colors.red : Colors.green,
        ),
        _buildMetricItem(
          'Memory',
          '${(performanceData.memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB',
          performanceData.memoryUsage > 100 * 1024 * 1024 ? Colors.red : Colors.green,
        ),
        _buildMetricItem(
          'CPU',
          '${performanceData.cpuUsage.toStringAsFixed(1)}%',
          performanceData.cpuUsage > 80 ? Colors.red : Colors.yellow,
        ),
      ],
    );
  }

  Widget _buildGameState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game State',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        _buildMetricItem(
          'Components',
          '${gameState!.grid.components.length}',
          Colors.white,
        ),
        _buildMetricItem(
          'Connections',
          '${gameState!.grid.connections.length}',
          Colors.white,
        ),
        _buildMetricItem(
          'Win State',
          gameState!.isWin ? 'Won' : 'Playing',
          gameState!.isWin ? Colors.green : Colors.white,
        ),
        if (gameState!.interactionState.selectedComponentId != null)
          _buildMetricItem(
            'Selected',
            gameState!.interactionState.selectedComponentId!,
            Colors.blue,
          ),
      ],
    );
  }

  Widget _buildDebugActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildActionButton('Clear Logs'),
            _buildActionButton('Export Data'),
            _buildActionButton('Toggle Wire'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label) {
    return GestureDetector(
      onTap: () => _onActionPressed(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  void _onActionPressed(String action) {
    // TODO: Implement debug actions
    StructuredLogger.debug('Debug action pressed', context: {'action': action});
  }
}

/// Performance monitoring data
class PerformanceMonitorData {
  final double fps;
  final int memoryUsage;
  final double cpuUsage;

  const PerformanceMonitorData({
    required this.fps,
    required this.memoryUsage,
    required this.cpuUsage,
  });

  PerformanceMonitorData.empty()
      : fps = 0.0,
        memoryUsage = 0,
        cpuUsage = 0.0;
}

/// Performance monitor with timing capabilities
class PerformanceMonitor {
  static final _watcher = Stopwatch();
  final Map<String, Duration> _operationDurations = {};

  /// Time an operation and automatically log if slow
  T timeOperation<T>(String operationName, T Function() operation) {
    _watcher.reset();
    _watcher.start();

    final result = operation();

    _watcher.stop();
    _operationDurations[operationName] = _watcher.elapsed;

    // Auto-warn for slow operations
    if (_watcher.elapsed > const Duration(milliseconds: 16)) { // Below 60 FPS
      StructuredLogger.warning('Slow operation detected', context: {
        'operation': operationName,
        'durationMs': _watcher.elapsed.inMilliseconds,
        'thresholdMs': 16,
      });
    }

    return result;
  }

  /// Get performance statistics
  PerformanceMonitorData getStats() {
    return PerformanceMonitorData(
      fps: _calculateAverageFPS(),
      memoryUsage: _getMemoryUsage(),
      cpuUsage: _calculateCPUUsage(),
    );
  }

  double _calculateAverageFPS() {
    // TODO: Implement FPS calculation using frame callbacks
    return 60.0; // Placeholder
  }

  int _getMemoryUsage() {
    // TODO: Implement memory usage tracking
    // Use Dart's Observatory or platform channels for iOS/Android
    return 0; // Placeholder
  }

  double _calculateCPUUsage() {
    // TODO: Implement CPU usage tracking
    return 0.0; // Placeholder
  }
}

/// Debug command console for advanced debugging
class DebugConsole extends InheritedWidget {
  final List<String> _commandHistory = [];
  final Map<String, void Function(List<String>)> _commands = {};

  DebugConsole({super.key, required super.child}) {
    _registerCommands();
  }

  static DebugConsole? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DebugConsole>();
  }

  void _registerCommands() {
    _commands['help'] = _cmdHelp;
    _commands['clear'] = _cmdClear;
    _commands['log'] = _cmdLog;
    _commands['performance'] = _cmdPerformance;
  }

  void executeCommand(String command) {
    final parts = command.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return;

    final cmd = parts[0];
    final args = parts.sublist(1);

    final handler = _commands[cmd];
    if (handler != null) {
      handler(args);
    } else {
      StructuredLogger.info('Unknown command: $cmd', context: {'input': command});
    }

    _commandHistory.add(command);
  }

  void _cmdHelp(List<String> args) {
    StructuredLogger.info('Available commands:', context: _commands.keys.toList());
  }

  void _cmdClear(List<String> args) {
    _commandHistory.clear();
    StructuredLogger.info('Command history cleared');
  }

  void _cmdLog(List<String> args) {
    if (args.isEmpty) {
      StructuredLogger.warning('Usage: log <level> <message>');
      return;
    }
    final level = args[0].toUpperCase();
    final message = args.sublist(1).join(' ');
    // Log at specified level
    StructuredLogger.info('User command log: $message', context: {'userLevel': level});
  }

  void _cmdPerformance(List<String> args) {
    // TODO: Show performance stats via overlay
    StructuredLogger.info('Performance command executed', context: args);
  }

  @override
  bool updateShouldNotify(DebugConsole oldWidget) => false;
}
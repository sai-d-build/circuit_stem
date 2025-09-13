import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/performance/performance_monitor.dart';

/// Performance dashboard widget for monitoring app performance
class PerformanceDashboard extends ConsumerStatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  ConsumerState<PerformanceDashboard> createState() =>
      _PerformanceDashboardState();
}

class _PerformanceDashboardState extends ConsumerState<PerformanceDashboard> {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    // Check if monitoring is active by checking static flag
    _isMonitoring = PerformanceMonitor.isMonitoringStatic;
  }

  void _toggleMonitoring() {
    setState(() {
      if (_isMonitoring) {
        _monitor.stopMonitoring();
      } else {
        _monitor.startMonitoring();
      }
      _isMonitoring = !_isMonitoring;
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _monitor.getAllMetrics();
    final frameStats = _monitor.getMetricStats('frame_callback');
    final memoryStats = _monitor.getMetricStats('memory_usage_mb');
    final buildStats = _monitor.getMetricStats('build_time');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleMonitoring,
            tooltip: _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildMetricCard(
                'Frame Performance', frameStats, 'ms', Icons.speed),
            const SizedBox(height: 16),
            _buildMetricCard('Memory Usage', memoryStats, 'MB', Icons.memory),
            const SizedBox(height: 16),
            _buildMetricCard('Build Time', buildStats, 'ms', Icons.build),
            const SizedBox(height: 16),
            _buildRecentMetrics(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isMonitoring ? Icons.monitor : Icons.visibility_off,
              color: _isMonitoring ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _isMonitoring ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: _isMonitoring ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, Map<String, dynamic> stats, String unit, IconData icon) {
    final count = stats['count'] as int? ?? 0;
    final average = stats['average'] as double? ?? 0.0;
    final min = stats['min'] as double? ?? 0.0;
    final max = stats['max'] as double? ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (count == 0)
              const Text('No data available')
            else ...[
              _buildMetricRow('Samples', count.toString()),
              _buildMetricRow('Average', '${average.toStringAsFixed(2)} $unit'),
              _buildMetricRow('Min', '${min.toStringAsFixed(2)} $unit'),
              _buildMetricRow('Max', '${max.toStringAsFixed(2)} $unit'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRecentMetrics(List<PerformanceMeasurement> metrics) {
    final recentMetrics = metrics.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (recentMetrics.isEmpty)
              const Text('No recent metrics')
            else
              ...recentMetrics.map(_buildMetricItem),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(PerformanceMeasurement data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.metric.displayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${data.value.toStringAsFixed(2)} ${data.metric.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            data.timestamp.toLocal().toString().substring(11, 19), // HH:MM:SS
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Performance overlay widget that can be added to any screen
class PerformanceOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const PerformanceOverlay({super.key, required this.child});

  @override
  ConsumerState<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends ConsumerState<PerformanceOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 10,
          child: _buildPerformanceIndicator(),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator() {
    final monitor = PerformanceMonitor();
    final frameStats = monitor.getMetricStats('frame_callback');
    final averageFrameTime = frameStats['average'] as double? ?? 16.67;

    final fps = (1000 / averageFrameTime).round();
    final color = fps >= 60
        ? Colors.green
        : fps >= 30
            ? Colors.yellow
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$fps FPS',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

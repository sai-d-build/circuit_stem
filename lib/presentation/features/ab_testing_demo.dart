import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/ab_testing_manager.dart';

// ✅ CLEAN ARCHITECTURE: A/B Testing service for demo
class ABTestingDemoService {
  final ABTestingManager _manager;

  ABTestingDemoService(this._manager);

  Future<Map<String, String>> loadTestConfigurations() async {
    final theme = await _manager.getConfigValue<String>(
        'ui_theme_test', 'theme', 'classic');
    final tutorialMode = await _manager.getConfigValue<String>(
        'tutorial_flow_test', 'tutorialMode', 'step_by_step');
    final difficultyMode = await _manager.getConfigValue<String>(
        'difficulty_progression_test', 'progression', 'gradual');

    return {
      'theme': theme ?? 'classic',
      'tutorialMode': tutorialMode ?? 'step_by_step',
      'difficultyMode': difficultyMode ?? 'gradual',
    };
  }

  Future<void> trackEngagement(
      String testId, String eventType, Map<String, dynamic> properties) async {
    await _manager.trackEngagement(testId, eventType, properties);
  }

  Future<void> trackConversion(
      String testId, String eventType, Map<String, dynamic> properties) async {
    await _manager.trackConversion(testId, eventType, properties);
  }
}

final abTestingDemoServiceProvider = Provider<ABTestingDemoService>((ref) {
  final manager = ref.watch(abTestingManagerProvider('demo_user'));
  return ABTestingDemoService(manager);
});

/// Demo widget showing A/B testing integration
class ABTestingDemo extends ConsumerStatefulWidget {
  const ABTestingDemo({super.key});

  @override
  ConsumerState<ABTestingDemo> createState() => _ABTestingDemoState();
}

class _ABTestingDemoState extends ConsumerState<ABTestingDemo> {
  String _currentTheme = 'Loading...';
  String _tutorialMode = 'Loading...';
  String _difficultyMode = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadTestConfigurations();
  }

  Future<void> _loadTestConfigurations() async {
    final service = ref.read(abTestingDemoServiceProvider);

    final configs = await service.loadTestConfigurations();

    setState(() {
      _currentTheme = configs['theme']!;
      _tutorialMode = configs['tutorialMode']!;
      _difficultyMode = configs['difficultyMode']!;
    });

    // Track that user viewed the demo
    await service.trackEngagement(
        'ui_theme_test', 'demo_viewed', {'theme': _currentTheme});
  }

  Future<void> _trackButtonClick() async {
    final service = ref.read(abTestingDemoServiceProvider);
    await service.trackConversion('ui_theme_test', 'demo_button_clicked', {
      'theme': _currentTheme,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event tracked for theme: $_currentTheme')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A/B Testing Demo'),
        backgroundColor: _getThemeColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your A/B Test Assignments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTestResult('UI Theme Test', _currentTheme),
            _buildTestResult('Tutorial Flow Test', _tutorialMode),
            _buildTestResult('Difficulty Test', _difficultyMode),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _trackButtonClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getThemeColor(),
                foregroundColor: Colors.white,
              ),
              child: const Text('Track Demo Event'),
            ),
            const SizedBox(height: 16),
            const Text(
              'This button click will be tracked for A/B testing analytics.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String testName, String variant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(testName, style: const TextStyle(fontWeight: FontWeight.w500)),
            Chip(
              label: Text(variant),
              backgroundColor: _getThemeColor().withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (_currentTheme) {
      case 'modern':
        return const Color(0xFFFF6B6B);
      case 'classic':
      default:
        return const Color(0xFF007BFF);
    }
  }
}

/// Provider for demo user ID (in real app, this would come from auth)
final demoUserIdProvider = Provider<String>((ref) => 'demo_user_123');

/// Example of how to use A/B testing in a real widget
class ThemeAwareButton extends ConsumerWidget {
  final String text;
  final VoidCallback onPressed;

  const ThemeAwareButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user's theme variant
    final themeAsync = ref.watch(abTestConfigProvider(
      ABTestConfigRequest(
        userId: ref.watch(demoUserIdProvider),
        testId: 'ui_theme_test',
        configKey: 'primaryColor',
        defaultValue: '#007bff',
      ),
    ));

    return themeAsync.when(
      data: (colorHex) {
        final color = _hexToColor(colorHex as String);
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: Text(text),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

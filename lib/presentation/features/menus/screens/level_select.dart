// Level select screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../../../application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_level_card.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  List<LevelDefinition>? _levels;
  bool _isLoading = true;
  String? _error;
  Set<String> _completedLevels = {};

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    StructuredLogger.info('LevelSelectScreen: Starting level loading', context: {
      'operation': '_loadLevels',
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      setState(() => _isLoading = true);

      StructuredLogger.debug('LevelSelectScreen: Getting level service from Riverpod', context: {
        'provider': 'levelServiceProvider',
      });

      // Get level service from Riverpod
      final levelService = ref.read(levelServiceProvider);

      StructuredLogger.debug('LevelSelectScreen: Calling levelService.loadAllLevels()', context: {
        'serviceType': levelService.runtimeType.toString(),
      });

      final levels = await levelService.loadAllLevels();

      StructuredLogger.info('LevelSelectScreen: Levels loaded successfully', context: {
        'levelsCount': levels.length,
        'levelIds': levels.map((level) => level.levelId).toList(),
        'levelTitles': levels.map((level) => level.metadata.title).toList(),
      });

      // Load completed levels from storage
      await _loadCompletedLevels();

      StructuredLogger.debug('LevelSelectScreen: Setting state with loaded levels', context: {
        'levelsCount': levels.length,
        'isLoading': false,
        'hasError': false,
      });

      setState(() {
        _levels = levels;
        _isLoading = false;
        _error = null;
      });

      StructuredLogger.info('LevelSelectScreen: Level loading completed successfully', context: {
        'finalLevelsCount': levels.length,
        'screenState': 'ready',
      });

    } catch (e, stackTrace) {
      StructuredLogger.error('LevelSelectScreen: Failed to load levels', context: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'stackTrace': stackTrace.toString(),
        'isLoading': false,
        'hasError': true,
      }, error: e);

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompletedLevels() async {
    final storageService = ref.read(storageServiceProvider);
    final completedLevels = storageService.readData<List<String>>('completed_levels') ?? [];
    setState(() {
      _completedLevels = Set.from(completedLevels);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>() ?? const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00FFFF),
      neonAccent: Color(0xFFFF00FF),
      errorGlow: Color(0xFFFF0040),
      energyPulse: Color(0xFF39FF14),
      highlightAccent: Color(0xFFFFFF00),
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Select Level',
          style: textTheme.headlineMedium?.copyWith(
            color: colors.onSurface,
            shadows: [
              BoxShadow(
                color: colors.neonPrimary.withValues(alpha: 0.5),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: _buildBody(colors, textTheme),
    );
  }

  Widget _buildBody(CircuitColorScheme colors, TextTheme textTheme) {
    StructuredLogger.debug('LevelSelectScreen: Building body', context: {
      'isLoading': _isLoading,
      'hasError': _error != null,
      'errorMessage': _error,
      'levelsCount': _levels?.length ?? 0,
      'levelsNull': _levels == null,
      'levelsEmpty': _levels?.isEmpty ?? false,
    });

    if (_isLoading) {
      StructuredLogger.debug('LevelSelectScreen: Showing loading indicator');
      return Center(child: CircularProgressIndicator(color: colors.neonPrimary));
    }

    if (_error != null) {
      StructuredLogger.warning('LevelSelectScreen: Showing error view', context: {
        'error': _error,
        'errorLength': _error!.length,
      });
      return _buildErrorView(colors, textTheme);
    }

    if (_levels == null || _levels!.isEmpty) {
      StructuredLogger.warning('LevelSelectScreen: Showing empty view', context: {
        'levelsIsNull': _levels == null,
        'levelsLength': _levels?.length ?? 0,
        'reason': _levels == null ? 'levels_not_loaded' : 'no_levels_available',
      });
      return _buildEmptyView(colors, textTheme);
    }

    StructuredLogger.info('LevelSelectScreen: Showing level grid', context: {
      'levelsCount': _levels!.length,
      'levelIds': _levels!.map((level) => level.levelId).toList(),
      'levelTitles': _levels!.map((level) => level.metadata.title).toList(),
    });

    return _buildLevelGrid(colors, textTheme);
  }

  Widget _buildErrorView(CircuitColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: colors.errorGlow),
          const SizedBox(height: 16),
          Text(
            'Failed to load levels',
            style: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLevels,
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            child: Text('Retry', style: TextStyle(color: colors.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(CircuitColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: colors.outline),
          const SizedBox(height: 16),
          Text(
            'No levels available',
            style: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new challenges!',
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(CircuitColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Challenge',
            style: textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              shadows: [
                BoxShadow(
                  color: colors.neonPrimary.withValues(alpha: 0.3),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start with basic circuits and work your way up to advanced challenges!',
            style: textTheme.bodyLarge?.copyWith(color: colors.onSurface.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Adjusted for better card size
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Adjusted for better card aspect ratio
              ),
              itemCount: _levels!.length,
              itemBuilder: (context, index) {
                final level = _levels![index];
                final isCompleted = _completedLevels.contains(level.levelId);
                final isUnlocked = !_isLevelLocked(level);
                return NeonLevelCard(
                  levelName: level.metadata.title,
                  isUnlocked: isUnlocked,
                  isCompleted: isCompleted,
                  onPressed: isUnlocked ? () {
                    StructuredLogger.info('LevelSelect: Level selected for navigation', context: {
                      'levelId': level.levelId,
                      'levelTitle': level.metadata.title,
                      'destination': '/game/${level.levelId}',
                      'isCompleted': isCompleted,
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                    context.push('/game/${level.levelId}');
                  } : () {
                    StructuredLogger.debug('LevelSelect: Attempted to select locked level', context: {
                      'levelId': level.levelId,
                      'levelTitle': level.metadata.title,
                      'isLocked': true,
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                  }, // Empty callback for locked levels
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isLevelLocked(LevelDefinition level) {
    // Tutorial levels are always unlocked
    if (level.metadata.difficulty == 'tutorial') {
      return false;
    }

    // Check prerequisites - all must be completed
    final prerequisites = level.metadata.prerequisites ?? [];
    if (prerequisites.isEmpty) {
      return false; // No prerequisites means unlocked
    }

    // Check if all prerequisites are completed
    return !prerequisites.every((prereqId) => _completedLevels.contains(prereqId));
  }
}
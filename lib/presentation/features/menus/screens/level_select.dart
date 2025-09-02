// Level select screen for SparkCircuit educational gaming platform

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../../domain/entities/level_definition.dart';
import '../../../../application/game_engine_v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/ui_components/neon_level_card.dart';
import '../../../../routes.dart';

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
    try {
      setState(() => _isLoading = true);

      // Get level service from Riverpod
      final levelService = ref.read(levelServiceProvider);
      final levels = await levelService.loadAllLevels();

      // Load completed levels from storage
      await _loadCompletedLevels();

      setState(() {
        _levels = levels;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
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
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
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
                color: colors.neonPrimary.withOpacity(0.5),
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.neonPrimary));
    }

    if (_error != null) {
      return _buildErrorView(colors, textTheme);
    }

    if (_levels == null || _levels!.isEmpty) {
      return _buildEmptyView(colors, textTheme);
    }

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
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLevels,
            child: Text('Retry', style: TextStyle(color: colors.onPrimary)),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
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
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.7)),
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
                  color: colors.neonPrimary.withOpacity(0.3),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start with basic circuits and work your way up to advanced challenges!',
            style: textTheme.bodyLarge?.copyWith(color: colors.onSurface.withOpacity(0.8)),
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
                    Navigator.of(context).pushNamed(AppRoutes.gameScreen, arguments: level.levelId);
                  } : () {}, // Empty callback for locked levels
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
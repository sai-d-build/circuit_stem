import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/level_metadata.dart';

class LevelGrid extends ConsumerWidget {
  final Function(int) onLevelSelected;

  const LevelGrid({required this.onLevelSelected, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = ref.watch(levelsProvider);
    final completedLevelIds = ref.watch(completedLevelIdsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Level',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              final isCompleted = completedLevelIds.contains(level.id);
              return _LevelCard(
                level: level,
                isCompleted: isCompleted,
                onTap: level.unlocked ? () => onLevelSelected(index) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelMetadata level;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !level.unlocked;
    final color = isLocked
        ? Colors.grey
        : isCompleted
            ? Colors.green
            : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked
                    ? Icons.lock
                    : (isCompleted ? Icons.check_circle : Icons.lightbulb_outline),
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${level.levelNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isLocked ? Colors.grey : null,
                    ),
              ),
              if (!isLocked) ...[
                const SizedBox(height: 4),
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

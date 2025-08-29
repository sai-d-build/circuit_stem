import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/features/hud/widgets/level_card.dart';

class LevelGrid extends StatelessWidget {
  final List<LevelData> levels;
  final Function(String) onLevelTap;

  const LevelGrid({
    super.key,
    required this.levels,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return LevelCard(
          levelId: level.id,
          title: level.title,
          description: level.description,
          difficulty: level.difficulty,
          isCompleted: level.isCompleted,
          stars: level.stars,
          isLocked: level.isLocked,
          onTap: level.isLocked ? null : () => onLevelTap(level.id),
        );
      },
    );
  }
}

class LevelData {
  final String id;
  final String title;
  final String description;
  final int difficulty;
  final bool isCompleted;
  final int stars;
  final bool isLocked;

  const LevelData({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.isCompleted = false,
    this.stars = 0,
    this.isLocked = false,
  });
}
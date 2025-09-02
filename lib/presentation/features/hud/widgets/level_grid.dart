import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/features/hud/widgets/level_card.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

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
      padding: UIConstants.standardInsets,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: UIConstants.levelGridCrossAxisCount,
        childAspectRatio: UIConstants.levelGridAspectRatio,
        crossAxisSpacing: UIConstants.standardSpacing,
        mainAxisSpacing: UIConstants.standardSpacing,
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
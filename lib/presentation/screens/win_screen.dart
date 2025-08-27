import 'package:flutter/material.dart';

class WinScreen extends StatelessWidget {
  final String levelId;
  final VoidCallback onNextLevel;
  final VoidCallback onLevelSelect;

  const WinScreen(
      {super.key,
      required this.levelId,
      required this.onNextLevel,
      required this.onLevelSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Level Complete!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Level: $levelId'),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: onLevelSelect,
                      child: const Text('Level Select'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onNextLevel,
                      child: const Text('Next Level'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

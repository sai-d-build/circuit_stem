import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;

  const PauseMenu({super.key, required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paused',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onResume,
                child: const Text('Resume'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Go back to previous screen (e.g., main menu)
                },
                child: const Text('Quit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

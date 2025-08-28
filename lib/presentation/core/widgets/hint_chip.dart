import 'package:flutter/material.dart';

class HintChip extends StatelessWidget {
  final String hintText;
  final Color? color;

  const HintChip({super.key, required this.hintText, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color ?? Colors.amber,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        hintText,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

const double cellSize = 64.0;
const int defaultRows = 6;
const int defaultCols = 6;

// Define a custom MaterialColor for better theming
const MaterialColor primaryMaterialColor = MaterialColor(
  _primaryColorValue,
  <int, Color>{
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(_primaryColorValue),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  },
);
const int _primaryColorValue = 0xFF2196F3; // Corresponds to Colors.blue[500]

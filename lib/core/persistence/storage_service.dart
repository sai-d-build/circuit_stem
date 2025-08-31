
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/domain/entities/level_definition.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'package:sparkcircuit/domain/entities/grid.dart';
import 'package:sparkcircuit/domain/entities/component.dart';


class StorageService {
  static const String _gameStateKey = 'gameState';

  Future<void> saveState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_gameStateKey, jsonString);
  }

  Future<GameState?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gameStateKey);
    if (jsonString == null) {
      return null;
    }
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return GameState.fromJson(jsonMap);
    } catch (e) {
      print('Error loading game state: \$e');
      return null;
    }
  }
}

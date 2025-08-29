import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models for game state
class CircuitComponent {
  final String id;
  final String type; // resistor, battery, wire, switch, etc.
  final double posX;
  final double posY;
  final Map<String, dynamic> properties;
  final bool isConnected;
  final bool isActive;

  const CircuitComponent({
    required this.id,
    required this.type,
    required this.posX,
    required this.posY,
    this.properties = const {},
    this.isConnected = false,
    this.isActive = false,
  });

  CircuitComponent copyWith({
    String? id,
    String? type,
    double? posX,
    double? posY,
    Map<String, dynamic>? properties,
    bool? isConnected,
    bool? isActive,
  }) {
    return CircuitComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      properties: properties ?? this.properties,
      isConnected: isConnected ?? this.isConnected,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CircuitConnection {
  final String id;
  final String fromComponentId;
  final String toComponentId;
  final String fromPort;
  final String toPort;
  final double current;
  final bool isActive;

  const CircuitConnection({
    required this.id,
    required this.fromComponentId,
    required this.toComponentId,
    required this.fromPort,
    required this.toPort,
    this.current = 0.0,
    this.isActive = false,
  });

  CircuitConnection copyWith({
    String? id,
    String? fromComponentId,
    String? toComponentId,
    String? fromPort,
    String? toPort,
    double? current,
    bool? isActive,
  }) {
    return CircuitConnection(
      id: id ?? this.id,
      fromComponentId: fromComponentId ?? this.fromComponentId,
      toComponentId: toComponentId ?? this.toComponentId,
      fromPort: fromPort ?? this.fromPort,
      toPort: toPort ?? this.toPort,
      current: current ?? this.current,
      isActive: isActive ?? this.isActive,
    );
  }
}

class GameLevel {
  final String id;
  final String name;
  final String description;
  final String objective;
  final Map<String, int> availableComponents;
  final List<CircuitComponent> initialComponents;
  final bool isCompleted;
  final int stars;
  final int bestScore;

  const GameLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.objective,
    this.availableComponents = const {},
    this.initialComponents = const [],
    this.isCompleted = false,
    this.stars = 0,
    this.bestScore = 0,
  });

  GameLevel copyWith({
    String? id,
    String? name,
    String? description,
    String? objective,
    Map<String, int>? availableComponents,
    List<CircuitComponent>? initialComponents,
    bool? isCompleted,
    int? stars,
    int? bestScore,
  }) {
    return GameLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      availableComponents: availableComponents ?? this.availableComponents,
      initialComponents: initialComponents ?? this.initialComponents,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
    );
  }
}

class GameState {
  final String levelId;
  final List<CircuitComponent> components;
  final List<CircuitConnection> connections;
  final bool isSimulating;
  final bool isComplete;
  final int score;
  final int hintsUsed;
  final DateTime startTime;
  final GameLevel? currentLevel;
  final String? selectedComponentId;
  final bool isPlacingComponent;
  final String? placingComponentType;

  const GameState({
    required this.levelId,
    this.components = const [],
    this.connections = const [],
    this.isSimulating = false,
    this.isComplete = false,
    this.score = 0,
    this.hintsUsed = 0,
    required this.startTime,
    this.currentLevel,
    this.selectedComponentId,
    this.isPlacingComponent = false,
    this.placingComponentType,
  });

  GameState copyWith({
    String? levelId,
    List<CircuitComponent>? components,
    List<CircuitConnection>? connections,
    bool? isSimulating,
    bool? isComplete,
    int? score,
    int? hintsUsed,
    DateTime? startTime,
    GameLevel? currentLevel,
    String? selectedComponentId,
    bool? isPlacingComponent,
    String? placingComponentType,
  }) {
    return GameState(
      levelId: levelId ?? this.levelId,
      components: components ?? this.components,
      connections: connections ?? this.connections,
      isSimulating: isSimulating ?? this.isSimulating,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      startTime: startTime ?? this.startTime,
      currentLevel: currentLevel ?? this.currentLevel,
      selectedComponentId: selectedComponentId ?? this.selectedComponentId,
      isPlacingComponent: isPlacingComponent ?? this.isPlacingComponent,
      placingComponentType: placingComponentType ?? this.placingComponentType,
    );
  }

  Duration get elapsedTime => DateTime.now().difference(startTime);
  
  int get starsEarned {
    if (!isComplete) return 0;
    
    // Star calculation logic based on score, time, and hints used
    final baseStars = 1;
    final timeBonus = elapsedTime.inMinutes < 5 ? 1 : 0;
    final hintsBonus = hintsUsed == 0 ? 1 : 0;
    
    return baseStars + timeBonus + hintsBonus;
  }
}

// Providers
final gameStateProvider = StateNotifierProvider.family<GameStateNotifier, GameState, String>((ref, levelId) {
  return GameStateNotifier(levelId);
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(String levelId) : super(GameState(
    levelId: levelId,
    startTime: DateTime.now(),
    currentLevel: _getSampleLevel(levelId),
  ));

  void addComponent(CircuitComponent component) {
    state = state.copyWith(
      components: [...state.components, component],
    );
    _checkLevelComplete();
  }

  void removeComponent(String componentId) {
    state = state.copyWith(
      components: state.components.where((c) => c.id != componentId).toList(),
      connections: state.connections.where((conn) => 
        conn.fromComponentId != componentId && conn.toComponentId != componentId
      ).toList(),
    );
  }

  void updateComponent(String componentId, CircuitComponent updatedComponent) {
    final components = state.components.map((c) => 
      c.id == componentId ? updatedComponent : c
    ).toList();
    
    state = state.copyWith(components: components);
    _checkLevelComplete();
  }

  void addConnection(CircuitConnection connection) {
    state = state.copyWith(
      connections: [...state.connections, connection],
    );
    _updateSimulation();
  }

  void removeConnection(String connectionId) {
    state = state.copyWith(
      connections: state.connections.where((c) => c.id != connectionId).toList(),
    );
    _updateSimulation();
  }

  void selectComponent(String? componentId) {
    state = state.copyWith(selectedComponentId: componentId);
  }

  void startPlacingComponent(String componentType) {
    state = state.copyWith(
      isPlacingComponent: true,
      placingComponentType: componentType,
    );
  }

  void stopPlacingComponent() {
    state = state.copyWith(
      isPlacingComponent: false,
      placingComponentType: null,
    );
  }

  void toggleSimulation() {
    state = state.copyWith(isSimulating: !state.isSimulating);
    if (state.isSimulating) {
      _updateSimulation();
    }
  }

  void useHint() {
    state = state.copyWith(hintsUsed: state.hintsUsed + 1);
  }

  void resetLevel() {
    state = GameState(
      levelId: state.levelId,
      startTime: DateTime.now(),
      currentLevel: state.currentLevel,
    );
  }

  void _updateSimulation() {
    // Simulate circuit behavior - this would connect to the backend game engine
    final updatedConnections = state.connections.map((conn) {
      // Basic simulation logic - in real app this would be more complex
      final isActive = state.isSimulating && _isCircuitComplete();
      return conn.copyWith(
        isActive: isActive,
        current: isActive ? 1.0 : 0.0, // Simplified current calculation
      );
    }).toList();

    final updatedComponents = state.components.map((comp) {
      final hasActiveCurrent = updatedConnections.any((conn) => 
        (conn.fromComponentId == comp.id || conn.toComponentId == comp.id) && 
        conn.isActive && conn.current > 0
      );
      return comp.copyWith(isActive: hasActiveCurrent);
    }).toList();

    state = state.copyWith(
      components: updatedComponents,
      connections: updatedConnections,
    );
  }

  bool _isCircuitComplete() {
    // Basic circuit completion check - would be more sophisticated in real app
    return state.components.length >= 3 && state.connections.length >= 2;
  }

  void _checkLevelComplete() {
    if (!state.isComplete && _isLevelObjectiveMet()) {
      final finalScore = _calculateScore();
      state = state.copyWith(
        isComplete: true,
        score: finalScore,
      );
    }
  }

  bool _isLevelObjectiveMet() {
    // Check if the level objective is met - placeholder logic
    return _isCircuitComplete();
  }

  int _calculateScore() {
    const baseScore = 1000;
    final timeBonus = (300 - state.elapsedTime.inSeconds).clamp(0, 300);
    final hintPenalty = state.hintsUsed * 50;
    return baseScore + timeBonus - hintPenalty;
  }
}

// Sample level data - in a real app this would come from the backend
GameLevel _getSampleLevel(String levelId) {
  final sampleLevels = {
    '1': const GameLevel(
      id: '1',
      name: 'Basic Circuit',
      description: 'Create a simple circuit to light up an LED',
      objective: 'Connect a battery to an LED using a resistor',
      availableComponents: {
        'battery': 1,
        'resistor': 2,
        'led': 1,
        'wire': 5,
      },
    ),
    '2': const GameLevel(
      id: '2',
      name: 'Series Circuit',
      description: 'Build a series circuit with multiple components',
      objective: 'Connect components in series to create a working circuit',
      availableComponents: {
        'battery': 1,
        'resistor': 3,
        'led': 2,
        'wire': 8,
      },
    ),
    '3': const GameLevel(
      id: '3',
      name: 'Parallel Circuit',
      description: 'Learn about parallel circuits and current division',
      objective: 'Create a parallel circuit with two branches',
      availableComponents: {
        'battery': 1,
        'resistor': 2,
        'led': 2,
        'wire': 10,
        'switch': 1,
      },
    ),
  };

  return sampleLevels[levelId] ?? sampleLevels['1']!;
}
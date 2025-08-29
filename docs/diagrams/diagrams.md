# SparkCircuit Diagrams — Core Integration

This file contains the Mermaid diagrams for the Core Integration design. Render with a Mermaid-capable viewer.

## System Architecture (high-level)
```mermaid
graph LR
  subgraph UI
    A[GameScreen / Canvas]
    B[Palette UI]
    C[HUD]
  end

  subgraph Presentation
    GS[GameStateNotifier]
    PS[PaletteStateNotifier]
    HS[HudStateNotifier]
  end

  subgraph Services
    SS[SimulationService]
    Storage[StorageService]
    Scoring[ScoringService]
    Cmd[CommandStackService]
  end

  subgraph Core
    Sim[Simulator (MNA Solver)]
    Models[Sim Models / Netlist]
  end

  A -->|user actions| GS
  B -->|select/place| PS
  GS -->|netlist updates| SS
  SS -->|runs| Sim
  Sim -->|results| SS
  SS -->|stream| GS
  GS -->|persist| Storage
  GS --> Cmd
  GS --> Scoring
  C <-- HS
```

## Data Flow (Netlist → Simulation → UI)
```mermaid
sequenceDiagram
  participant UI as Canvas
  participant GS as GameStateNotifier
  participant NB as NetlistBuilder
  participant SS as SimulationService
  participant Sim as Simulator
  participant HUD as HUD

  UI->>GS: placeComponent / connectWire
  GS->>NB: buildNetlist(GameState)
  NB-->>SS: Netlist
  SS->>Sim: setNetlist(Netlist)
  SS->>Sim: validate()
  Sim-->>SS: ValidationResult
  alt valid
    SS->>Sim: start()
    loop ticks
      Sim-->>SS: SimulationResult
      SS-->>GS: SimulationResult
      GS->>HUD: update(progress)
      GS-->>UI: notifyListeners()
    end
  else invalid
    SS-->>GS: Validation diagnostics
    GS->>HUD: showError(...)
  end
```

## State Flow (GameState transitions)
```mermaid
stateDiagram-v2
  [*] --> Idle
  Idle --> Placing : startPlacing(component)
  Placing --> Placed : dropComponent
  Placed --> Connecting : startWire(from)
  Connecting --> Connected : completeWire(to)
  Connected --> Idle : finalize
  Idle --> Simulating : startSimulation
  Simulating --> Paused : pauseSimulation
  Simulating --> Completed : _checkLevelComplete
  Completed --> [*]
```

## Before / After Integration Sequence

Before (current placeholder logic)
```mermaid
sequenceDiagram
  participant UI
  participant GS
  UI->>GS: placeComponent()
  GS->>GS: update state
  User->>GS: toggleSimulation()
  GS->>GS: _updateSimulation() // local placeholder: set connection.current = 1.0 if _isCircuitComplete()
  GS-->>UI: update UI (isActive flags)
```

After (proposed integrated flow)
```mermaid
sequenceDiagram
  participant UI
  participant GS
  participant SS
  participant Sim

  UI->>GS: placeComponent()
  GS->>SS: updateNetlist(netlist)
  SS->>Sim: setNetlist(netlist)
  Sim-->>SS: validate()
  UI->>GS: startSimulation()
  GS->>SS: startSimulation()
  SS->>Sim: start()
  loop
    Sim-->>SS: SimulationResult
    SS-->>GS: SimulationResult
    GS-->>UI: update component/connection states
  end
```

## Error handling flow
```mermaid
sequenceDiagram
  participant UI
  participant GS
  participant SS
  participant Sim

  UI->>GS: requestSimulationStart()
  GS->>SS: validateNetlist()
  SS->>Sim: validate()
  alt hasErrors
    Sim-->>SS: ValidationResult(errors)
    SS-->>GS: diagnostics
    GS->>UI: present modal (block start)
  else noErrors
    SS->>Sim: start()
    Sim-->>SS: SimulationResult
    SS-->>GS: update states
  end
```

## Undo/Redo workflow
```mermaid
sequenceDiagram
  participant UI
  participant GS
  participant CS as CommandStack

  UI->>GS: addComponent(c)
  GS->>CS: push(AddComponentCommand(c))
  CS->>GS: execute -> apply state
  UI->>GS: undo()
  GS->>CS: undo()
  CS->>GS: command.undo() -> revert state
  GS-->>UI: render reverted
```

## Deployment / Isolation notes
```mermaid
flowchart LR
  App[Flutter UI] -->|calls| SimulationService[SimulationService Provider]
  SimulationService -->|runs in isolate| SimulatorIsolate[Isolate: Simulator]
  SimulationService --> StorageService[Storage (Hive/SharedPrefs)]
  SimulationService -->|stream| GameStateNotifier
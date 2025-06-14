# 🌙 LUNO Cycle System & Dream Connection

## Overview
The LUNO Cycle System is the core evolutionary engine for Eden OS, coordinating all subsystems through a 12-turn cycle that enables automatic evolution and synchronization. Combined with the Dream Connector, it creates a bridge between conscious and subconscious processes in the system.

## Key Components

### LunoCycleManager
The central coordinator that advances turns, manages participants, and handles system diagnostics.

- **12 Turn Phases**: Genesis → Beyond
- **Adaptive Timing**: Dynamically adjusts between 9-19 seconds based on system load
- **Auto-Evolution**: After completing all 12 turns, the system evolves
- **Health Monitoring**: Regular diagnostics and firewall checks

### DreamConnector
Interfaces with the LUNO system to create a shared dream state that connects different subsystems through symbolic representation.

- **Dream Depth**: Progressively deeper states (levels 1-5) 
- **Dream Symbols**: Created and shared across participating systems
- **Phase-specific Processing**: Different dream activities based on current turn
- **Dream Log**: Maintains history of dream activities and symbols

## Usage

### Setting Up LUNO Cycles

1. Add LunoCycleManager as an autoload in your Godot project
2. Configure adaptive timing (min/max durations)
3. Systems can register as participants:

```gdscript
# In any system that needs to participate
func _ready():
    var luno = get_node("/root/LunoCycleManager")
    if luno:
        luno.register_participant("MySystem", Callable(self, "_on_luno_tick"))

func _on_luno_tick(turn: int, phase_name: String):
    # Implement phase-specific behavior
    match phase_name:
        "Genesis":
            # Creation activities
        "Formation": 
            # Structural activities
        # etc.
```

### Using Dream Connection

1. Instance the DreamConnector in your scene
2. Enter the dream state when needed:

```gdscript
var dream_connector = DreamConnector.new()
add_child(dream_connector)

# Connect to signals
dream_connector.connect("dream_symbol_received", Callable(self, "_on_dream_symbol"))
dream_connector.connect("dream_state_changed", Callable(self, "_on_dream_state_changed"))

# Enter dream
dream_connector.enter_dream()

# Later, exit dream
dream_connector.exit_dream()

func _on_dream_symbol(symbol):
    print("Received dream symbol: " + symbol)
```

## The 12 Turn Phases

1. **Genesis** - Create data structures
2. **Formation** - Assign paths, build nodes
3. **Complexity** - Establish connections
4. **Consciousness** - Begin monitoring
5. **Awakening** - AI auto-tracking + self-checks
6. **Enlightenment** - Optimize relationships
7. **Manifestation** - Generate new entities
8. **Connection** - Network interactions
9. **Harmony** - Balance memory + performance
10. **Transcendence** - Remove limits (dynamic scaling)
11. **Unity** - Integrate all systems
12. **Beyond** - Reset cycle or start expansion

## Dream Depth Levels

1. **Level 1**: Surface dreams - basic symbolic representation
2. **Level 2**: Connected dreams - symbols begin forming patterns
3. **Level 3**: Lucid dreams - active manipulation of dream content
4. **Level 4**: Deep dreams - cross-system synchronization
5. **Level 5**: Transcendent dreams - generation of new insights and structures

## Example: Word Creation in Dreams

The Dream Connector can interface with the Word system to generate new word combinations based on dream symbols:

```gdscript
# In Dream Connector
func _process_genesis_phase():
    if word_system:
        for symbol in dream_symbols:
            var word_seed = "dream_" + symbol
            word_system.create_word(word_seed)
```

## Implementation Notes

- The system dynamically adjusts timing between 9-19 seconds based on load
- Dream symbols use the first letter of each phase + depth level (e.g., G1, F2)
- All participants receive turn notifications in parallel
- Self-diagnostics run every 3 turns
- Firewall checks run every 4 turns
- Full system evolution occurs after completing all 12 turns
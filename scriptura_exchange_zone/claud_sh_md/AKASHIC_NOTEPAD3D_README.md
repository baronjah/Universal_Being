# Akashic Notepad3D Game

This project integrates multiple systems into a cohesive game experience that allows for the creation, evolution, and visualization of entities across 12 dimensions.

## Core Systems

### Eden Pitopia Integration

The `eden_pitopia_integration.gd` script serves as the central nervous system of the application, connecting:

- The Akashic Records system
- Eden Harmony system 
- Pitopia system
- Word Manifestation system
- Notepad3D visualization

This integration provides:
- Cross-system entity creation and mapping
- Synchronized dimension transitions
- Word manifestation across all systems
- Unified Akashic record keeping

### Integrated Game System

The `integrated_game_system.gd` script provides the main controller for the unified game experience:
- Entity management with evolutionary stages
- Command processing
- Folder/project connections
- Dimension management
- UI integration

### Turn Controller

The `turn_controller.gd` script manages the 12-dimension turn cycle:
- Each dimension has unique properties affecting gameplay
- Automatic turn advancement
- Greek symbols (α to μ) representing different dimensions
- Dimension-specific visualization effects

### Word Manifestation System

The word manifestation system allows words to become entities with:
- Physical properties in 3D space
- Evolution through 5 stages (seed → sprout → sapling → tree → transcendent)
- Connections between related words
- Dimension-specific behaviors

### Notepad3D Visualization

The visual component provides:
- 3D display of manifested words and entities
- Dimension transition effects
- Multiple perception modes (normal, dual, quantum, divine)
- Camera controls and screenshot capabilities

## Game Concepts

### Dimensions (1D-12D)

1. **1D (α)**: Linear dimension - entities exist in sequence
2. **2D (β)**: Planar dimension - entities exist on a flat surface
3. **3D (γ)**: Spatial dimension - entities exist in physical 3D space
4. **4D (δ)**: Temporal dimension - entities exist across time
5. **5D (ε)**: Probability dimension - entities exist in multiple possible states
6. **6D (ζ)**: Conceptual dimension - entities exist as pure concepts
7. **7D (η)**: Consciousness dimension - entities are aware across dimensions
8. **8D (θ)**: Harmony dimension - entities resonate with all other entities
9. **9D (ι)**: Possibility dimension - all possible futures/pasts exist
10. **11D (κ)**: Intention dimension - reality shaped by thought
11. **12D (λ)**: Manifestation dimension - thoughts instantly become form
12. **12D (μ)**: Integration dimension - all dimensions merge

### Evolution Stages

1. **Seed**: Initial manifestation, minimal influence
2. **Sprout**: Beginning growth, starting to affect reality
3. **Sapling**: Established presence, moderate influence
4. **Tree**: Powerful entity, significant influence
5. **Transcendent**: Eternal entity, maximum influence

### Entity Types

- **Words**: Text manifested into the multiverse with physical properties
- **Connections**: Relationships between entities
- **Akashic Records**: Universal data records spanning dimensions
- **Notepad Cells**: 3D visualization of notes in dimensional space
- **Gates**: Connections between different dimensions

## Usage Instructions

### Running the Game

1. Use the launch script:
   ```
   ./launch_akashic_notepad_game.sh
   ```

2. Or open the scene directly in Godot:
   ```
   godot --path /path/to/project /path/to/akashic_notepad_game.tscn
   ```

### Commands

The game accepts these commands in the command line:

- `help` - Show command help
- `create <type> <name>` - Create a new entity
- `evolve <entity_id> [stage]` - Evolve an entity
- `list [dimension|type]` - List entities
- `dimension <index>` - Change dimension (0-11)
- `next` - Advance to next dimension

Any text entered that doesn't match a command will be manifested as a word entity.

### Keyboard/Mouse Controls

- **WASD/Arrow Keys**: Move camera
- **QE/PgUp/PgDn**: Raise/lower camera
- **Space**: Cycle perception modes
- **Tab**: Rotate camera
- **Shift+Tab**: Rotate camera opposite direction

## Integration with External Systems

This system is designed to connect with:

1. **Eden Harmony**: For entity creation and evolution
2. **Pitopia**: For node-based integration
3. **Akashic Records**: For universal data storage
4. **Godot Projects**: For visualization and interaction

You can connect external folders or projects using:
```
integrated_game_system.connect_folder(folder_path, connection_type)
```

Connection types:
- `data`: Load entity data from files
- `project`: Connect to another Godot project
- `scripts`: Load scripts from folder

## Development Notes

### Entity Mapping System

Entities are mapped across systems using a unique ID system. For example, when a word is manifested:

1. It's created in the Word Manifestation System with ID `word_123`
2. It's created in Eden Harmony with ID `eden_456`
3. It's created in Pitopia with ID `node_789`
4. The integration system maps these IDs together: `{word_id: word_123, eden_id: eden_456, pitopia_id: node_789}`

This allows operations on one system to propagate to all connected systems.

### Dimension Synchronization

When a dimension change occurs:
1. The Turn Controller signals the dimension change
2. The Integration system receives this signal
3. All connected systems are updated to the new dimension
4. Visual effects are applied to represent the dimension

### Custom Extensions

To extend the system with new functionality:
1. Create a new script that inherits from one of the core systems
2. Override the relevant methods
3. Connect your system to the integration using the appropriate signals

For example, to add a new entity type:
```gdscript
# my_entity_extension.gd
extends "res://integrated_game_system.gd"

func _ready():
    # Register new entity type
    register_entity_type("my_entity_type", {
        "properties": ["prop1", "prop2"],
        "evolution_stages": ["stage1", "stage2", "stage3"],
        "dimension_effects": true
    })
```
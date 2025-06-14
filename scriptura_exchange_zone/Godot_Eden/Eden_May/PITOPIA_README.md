# Pitopia

Pitopia is a node-based reusable integration of the Eden project systems, providing an easy way to create a word manifestation game across multiple dimensions.

## Quick Start

1. **Add to Scene**: Add the `pitopia_scene.tscn` to your project
2. **Run**: Press play to start Pitopia with default settings
3. **Use Console**: Press TAB to toggle the console
4. **Manifest Words**: Type words into the console to manifest them as entities
5. **Change Dimensions**: Use number keys 1-9 (and 0, -, =) to switch between dimensions 1-12

## Core Features

- **Word Manifestation**: Words transform into interactive entities with unique properties
- **Dimensional System**: 12 dimensions with increasingly complex visual and behavioral effects
- **Turn-Based Progression**: Automatic or manual advancement through turns
- **Entity Connections**: Create relationships between manifested words
- **Reusable Integration**: Easy to add to any Godot project

## PitopiaMain Node

The `PitopiaMain` script is designed to be easily reused and extended through the Inspector panel:

### Node Paths

Connect existing components through node paths:

- `word_manifestor_path`: Path to CoreWordManifestor node
- `turn_system_path`: Path to TurnSystem node
- `ethereal_engine_path`: Path to JshEtherealIntegration node
- `color_system_path`: Path to DimensionalColorSystem node
- `console_path`: Path to console UI
- `player_camera_path`: Path to camera
- `entity_container_path`: Path to entity container node

### Configuration Options

Customize behavior through these properties:

- `auto_initialize`: Automatically initialize on _ready
- `auto_connect_signals`: Automatically connect signals between components
- `default_dimension`: Starting dimension (1-12)
- `default_turn_duration`: Duration of each turn in seconds
- `enable_creation_on_words`: Allow direct word creation from console
- `enable_automatic_dimension_effects`: Enable automatic dimension effects
- `enable_debug_messages`: Show debug messages in console

### Preloaded Resources

Customize visuals by changing these resources:

- `default_entity_scene`: Default entity scene for word manifestation
- `word_display_effect_scene`: Effect when displaying words
- `dimension_particle_effect_scene`: Effect when changing dimensions
- `pitopia_environment`: Environment resource for scene rendering

## Console Commands

The console supports these commands:

- `create [word]`: Create an entity from a word
- `combine [word1] [word2] ...`: Combine multiple words
- `transform [word] to [form]`: Transform an entity
- `connect [word1] to [word2]`: Connect two entities
- `dimension [1-12]`: Change to specified dimension
- `turn`: Advance to next turn
- `help`: Display available commands

## Dimensions

Each dimension has unique characteristics:

1. **Linear Expression**: Simple 1D entities
2. **Planar Reflection**: Flat 2D entities
3. **Spatial Manifestation**: Standard 3D entities
4. **Temporal Flow**: Entities affected by time, with subtle movement
5. **Probability Waves**: Entities existing in multiple possible states
6. **Phase Resonance**: Entities that resonate with each other
7. **Dream Weaving**: Entities with glowing effects and color shifts
8. **Interconnection**: Entities that automatically connect with others
9. **Divine Judgment**: Entities with moral/ethical properties
10. **Harmonic Convergence**: Entities that orbit and harmonize
11. **Conscious Reflection**: Self-aware entities with complex behavior
12. **Divine Manifestation**: Transcendent entities with reality-bending effects

## Extending Pitopia

### Adding New Components

You can easily extend Pitopia by:

1. Creating scenes that inherit from `PitopiaMain`
2. Adding custom entity types
3. Implementing new dimension effects
4. Creating specialized word manifestation logic

### Custom Entities

To add custom entity types:

1. Create a scene that inherits from the default entity
2. Customize its appearance and behavior
3. Set it as the `default_entity_scene` in PitopiaMain

### API Usage

You can use these methods in your code:

```gdscript
# Manifest a word into an entity
var entity = pitopia.manifest_word("crystal")

# Combine multiple words
var combined = pitopia.combine_words(["fire", "water"])

# Change dimension
pitopia.set_dimension(4)

# Advance turn
pitopia.advance_turn()

# Process a command
pitopia.process_command("transform crystal to diamond")
```

## Integration with Existing Systems

Pitopia automatically integrates with:

- **Turn System**: From the 12_turns_system
- **Word Manifestor**: CoreWordManifestor or JSHWordManifestor
- **Ethereal Engine**: JshEtherealIntegration
- **Color System**: DimensionalColorSystem or ExtendedColorThemeSystem

## Signals

Connect to these signals for custom behavior:

- `initialization_completed`: When all systems are initialized
- `word_manifested(word, entity)`: When a word is manifested
- `dimension_changed(new_dimension, old_dimension)`: When dimension changes
- `turn_advanced(turn_number)`: When turn advances
- `pitopia_state_changed(state_name, value)`: When a state value changes
- `entity_connected(source_entity, target_entity, connection_type)`: When entities are connected

## Troubleshooting

- **Component not found**: Check node paths in the Inspector
- **Word manifestation not working**: Ensure CoreWordManifestor is available
- **Visual effects missing**: Check if dimension_particle_effect_scene is set
- **Console not appearing**: Ensure TAB key is not being captured elsewhere

## Credits

Pitopia integrates systems from:

- Eden OS
- JSH Ethereal Engine
- 12 Turns System
- Word Manifestation System
- Dimensional Color System
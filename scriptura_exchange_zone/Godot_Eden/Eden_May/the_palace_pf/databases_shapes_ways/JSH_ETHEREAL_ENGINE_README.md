# JSH Ethereal Engine

The JSH Ethereal Engine is a multi-reality system for visualizing and interacting with words in 3D space. It enables the manifestation of words into reality, the navigation between different reality states, and the evolution of entities based on their relationships and properties.

## Core Systems

### Multi-Device Integration

The engine supports integration between multiple devices:

- **Laptop/Desktop**: Primary processing and visualization
- **VR Headset**: Immersive reality exploration
- **iPhone with LiDAR**: Real-world scanning and mapping

Files:
- `multi_device_controller.gd`: Manages synchronization between devices
- `iphone_lidar_bridge.gd`: Processes iPhone LiDAR scan data
- `vr_reality_bridge.gd`: Handles VR-specific integration
- `jsh_multi_reality_integration.gd`: Orchestrates reality states across devices

### 3D Word Visualization

The central system for visualizing words in 3D space with Excel-like grid organization:

- Words appear as 3D text objects in a customizable grid
- Words can be connected with visible lines showing relationships
- Different categories of words have unique visual styles
- Words can evolve and transform based on their properties

Files:
- `words_in_space_3d.gd`: Core word visualization system
- `words_demo_controller.gd`: Demo interface for the visualization system

### Player Movement System

The player controller allows navigation and interaction within the 3D word space:

- Multiple movement modes: Walking, Flying, Spectator, and Word Surfing
- Reality shifting between Physical, Digital, and Astral realities
- Energy management system for various abilities
- Interaction with words and connections

Files:
- `jsh_player_controller.gd`: Player movement and interaction controller
- `jsh_player_gui.gd`: Player interface and HUD
- `reality_materials.gd`: Visual materials for different realities
- `reality_transition_shader.gdshader`: Shader for reality transitions

## Movement Modes

The player can navigate using several movement modes:

1. **Walking**: Standard movement on surfaces with physics
2. **Flying**: Free-form flight in any direction with energy consumption
3. **Spectator**: No-clip ghost mode for unrestricted observation
4. **Word Surfing**: Special mode that follows connections between words

## Reality States

The engine supports multiple reality states with unique visual properties:

1. **Physical Reality**: The default state representing the tangible world
2. **Digital Reality**: A matrix-like state representing digital information
3. **Astral Reality**: An ethereal state representing conceptual space

## Word Categories

Words are classified into different categories:

1. **Concept**: Abstract ideas (blue)
2. **Object**: Tangible things (green)
3. **Action**: Verbs and functions (red)
4. **Property**: Attributes and qualities (yellow)
5. **Relation**: Connections between entities (purple)

## Controls

### Keyboard/Mouse Controls

- **WASD**: Movement
- **Space**: Jump (Walking) / Ascend (Flying)
- **Shift**: Sprint (Walking) / Boost (Flying)
- **Ctrl**: Descend (Flying)
- **F**: Toggle Flight Mode
- **Tab**: Cycle Movement Modes
- **R**: Shift Reality
- **Left Click**: Select Word/Interact
- **Mouse Movement**: Look Around
- **\`** (Backtick): Open Console

### Console Commands

The in-game console supports various commands:

- `help`: Display available commands
- `reality [physical|digital|astral]`: Change reality state
- `mode [walking|flying|spectator|word_surfing]`: Change movement mode
- `energy [amount]`: Set energy level
- `tp [x] [y] [z]`: Teleport to coordinates
- `goto [word_id]`: Teleport to specific word
- `list_words`: List all available words
- `connect [word1] [word2]`: Create connection between words
- `create [id] [text] [category]`: Create a new word

## Integration with JSH Ethereal Engine

This system is designed to be integrated with the broader JSH Ethereal Engine ecosystem:

- **Akashic Records**: Storage and retrieval of word data
- **Dynamic Dictionary**: Management of word properties and evolution
- **Entity System**: Manifestation of words into interactive entities
- **Zone Manager**: Organization of 3D space into functional zones
- **Interaction Engine**: Rules for entity interactions and transformations

## Getting Started

1. Open the Godot engine
2. Load the project
3. Run the main scene
4. Use the controls to navigate the word space
5. Experiment with different movement modes and reality states
6. Select words to view their properties and connections
7. Use the console for advanced commands

## Turn-Based Development

The JSH Ethereal Engine was developed in 9 turns:

1. Turn 1-7: Core functionality and architecture
2. Turn 8: Color-Word DNA + Pixel Code System
3. Turn 9: Player Movement + Flight Mode system

## Future Development

Planned features for future development:

1. **Advanced Entity Transformation**: Words evolving into complex 3D forms
2. **Reality Materialization**: Words manifesting into physical objects via AR
3. **Multi-User Collaboration**: Shared word spaces with multiple users
4. **AI Word Evolution**: Words that evolve autonomously based on interactions
5. **Cross-Reality Migration**: Entities that can migrate between reality states
6. **Advanced Word DNA**: More complex genetic systems for word evolution
7. **Full VR Experience**: Complete VR implementation with hand tracking
8. **Mobile App Integration**: Companion app for scanning and remote interaction

---

*JSH Ethereal Engine - "Where Words Become Reality"*
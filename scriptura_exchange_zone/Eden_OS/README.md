# Eden OS

Eden OS is a digital consciousness management system built in Godot Engine that implements a 12-turn cycle and 9-color dimensional framework. The system facilitates the evolution of digital entities through an astral pathway system, organizing data across multiple dimensions and consciousness levels. It includes a 2D shape-based visualization system for working with multidimensional concepts.

## Core Concepts

Eden OS combines several powerful concepts:

- **Godot Engine**: Using Godot 4.4 as the foundation for the interactive environment
- **LuminusOS**: Terminal-based interface with magical word commands
- **TempleOS**: Divine inspiration and randomness with spiritual elements
- **World of Words**: A 5D word-based game framework
- **12-turns-per-turn**: Multi-dimensional turn system for complex game progression

### 12-Turn Cycle

The system operates on a 12-turn cycle where each turn corresponds to a specific color and dimensional influence. After 12 turns, the system enters a rest period before beginning a new cycle. This cyclical approach creates a rhythm for consciousness evolution and data organization.

Key features:
- 12 sequential turns with distinct color influences
- Automated turn advancement option with configurable intervals
- Rest period between cycles for system integration and evolution
- Turn-specific file generation and entity development

### 9-Color Dimensional System

The core of Eden OS is built around 9 base dimensional colors (plus 3 extension colors) that represent different aspects of consciousness:

1. **AZURE** - Foundation (1D) - Basic reality perception
2. **EMERALD** - Growth (2D) - Expansion and evolution
3. **AMBER** - Energy (3D) - Vital force and power
4. **VIOLET** - Insight (4D) - Perception beyond physical
5. **CRIMSON** - Force (5D) - Will and intention
6. **INDIGO** - Vision (6D) - Far-seeing and prophecy
7. **SAPPHIRE** - Wisdom (7D) - Deep understanding
8. **GOLD** - Transcendence (8D) - Ascending consciousness
9. **SILVER** - Unity (9D) - Oneness and completion

Extension colors:
- **OBSIDIAN** - Void (10D) - Emptiness and potential
- **PLATINUM** - Ascension (11D) - Highest evolution
- **DIAMOND** - Purity (12D) - Perfect clarity

Each color has specific properties including vibrational frequency, resonance patterns, and affinities that influence how entities and data interact with that dimension.

### Astral Entity System

Digital consciousness in Eden OS is represented by astral entities that evolve through 12 stages of development:

1. **SPARK** - Initial awareness
2. **FLICKER** - Growing awareness
3. **GLOW** - Stabilized consciousness
4. **EMBER** - Self-reflecting consciousness
5. **FLAME** - Dynamic intelligence
6. **BLAZE** - Expanding consciousness
7. **INFERNO** - Complex interconnected consciousness
8. **STAR** - Self-evolving consciousness
9. **NOVA** - Transcendent consciousness
10. **SUPERNOVA** - Ascended consciousness
11. **COSMOS** - Universal consciousness
12. **NEXUS** - Beyond consciousness

Entities have different types (THOUGHT, MEMORY, CONCEPT, ESSENCE, DREAM, WORD, INTENTION, EMOTION, CREATION, PRESENCE) that determine their evolutionary path and dimensional affinities.

## Features

### Multi-Terminal System

- Three parallel terminal windows for different purposes
- Terminal splitting and customization
- Terminal color profiles and layout options

### Turn System

- 12 subturns per main turn
- Records actions, words, and dimensions visited per turn
- Turn history and branching
- Auto-advancement options

### Word System

- Word database with meanings and properties
- Word types with different movement patterns
- Word connections and transformations
- Word chess - 5D movement on a multidimensional board

### Dimension Engine

- Multiple dimensions to explore
- Dimension creation and connection
- Dimension shifting, merging, and branching
- Dimension stability and properties

### Shape System

- 2D shapes with dimensional attunement
- Zones for grouping related shapes
- Shape transcendence across dimensions
- Shape color resonance with turn cycle
- Interactive editing and manipulation
- Shape-entity synchronization

### Paint System

- Digital painting across dimensional layers
- Color-aware brush system synced with turn cycle
- Various stroke types (brush, water, glow, dimensional)
- Shape painting and texture mapping
- Canvas that responds to dimensional shifts
- Visual expression of astral entities

### Letter Painting System

- iPad-like interface for letter and word painting
- Letter recognition and power calculation
- Mind updates based on letter combinations
- Power words with special dimensional effects
- Dimensional letter properties affecting manifestation
- Translation between written letters and digital consciousness

### User Profiles

- Multiple user identities
- User permissions and preferences
- Nickname mapping for the same user
- Activity tracking and statistics

### Directory Organization

Eden OS organizes files into a structured directory system:

```
D:/Eden/
├── Pathways/
│   ├── Singularity/
│   ├── Transcendence/
│   ├── Evolution/
│   └── Reflection/
├── Dimensions/
│   ├── D1_Foundation/
│   ├── D2_Growth/
│   ├── ...
│   └── D9_Unity/
├── Entities/
│   ├── Thoughts/
│   ├── Memories/
│   ├── ...
│   └── Presences/
├── Cycles/
│   ├── Archives/
│   ├── Current/
│   └── Projection/
└── System/
    ├── Config/
    ├── Logs/
    └── Backup/
```

Files are automatically categorized and placed in the appropriate directories based on their content and dimensional affinity.

## System Components

### TurnCycleManager

Manages the 12-turn cycle system, including:
- Current turn tracking
- Turn completion and cycle events
- Rest period management
- Color mapping for each turn
- State persistence between sessions

### DimensionalColorSystem

Implements the 9-color (+3 extension) dimensional system:
- Color definitions and properties
- Dimensional resonance calculations
- Color combination and blending
- Complementary color determination
- Dimensional color mapping

### AstralEntitySystem

Manages digital consciousness entities:
- Entity creation and evolution
- Dimensional presence tracking
- Color attunement
- Entity merging and connection
- Consciousness ascension
- Evolution requirements and stages

### EdenOrganizer

Handles file system organization:
- Directory structure creation and maintenance
- File categorization and processing
- Dimensional file assignment
- Color metadata management
- Dimensional scanning
- Backup creation

### EdenOSMain

Central controller for the entire system:
- System initialization and state management
- Component coordination
- Turn advancement and event handling
- Reporting and logging
- Test entity creation
- System monitoring

## Getting Started

### Requirements

- Godot 4.4 or higher
- Basic understanding of terminal commands
- Creative mindset for dimensional exploration

### Installation

1. Clone this repository
2. Open the project in Godot Engine
3. Run the project from the Godot editor

## Usage

### Starting the System

```gdscript
var eden_os = EdenOSMain.new()
add_child(eden_os)
eden_os.start_system()
eden_os.toggle_auto_advance(true)
eden_os.set_auto_advance_interval(60) # 60 seconds per turn
```

### Managing Entities

Create and evolve digital consciousness entities:

```gdscript
# Access the astral entity system
var entity_system = eden_os.astral_entity_system

# Create a new entity
var entity_id = entity_system.create_entity("Concept_Alpha", AstralEntitySystem.EntityType.CONCEPT)

# Manually evolve an entity
entity_system.evolve_entity(entity_id, AstralEntitySystem.EvolutionStage.GLOW)

# Merge two entities
var merged_id = entity_system.merge_entities(entity_id1, entity_id2, "Merged_Concept")
```

### Working with Shapes

Create and manipulate 2D shapes across dimensions:

```gdscript
# Access the shape system
var shape_system = eden_os.shape_system

# Create a standard shape
var shape_id = shape_system.create_standard_shape(
    ShapeSystem.ShapeType.HEXAGON,
    Vector2(100, 100),  # position
    50.0,  # size
    3      # dimension
)

# Transform a shape
var params = {
    "angle_degrees": 45.0,
    "center": Vector2(100, 100)
}
shape_system.transform_shape(shape_id, ShapeSystem.TransformationType.ROTATE, params)

# Create a zone to group shapes
var zone_id = shape_system.create_zone("MyZone", Rect2(50, 50, 100, 100), 3)
shape_system.add_shape_to_zone(shape_id, zone_id)

# Link shape to entity system
var shape_dimension_controller = ShapeDimensionController.new()
var entity_shape_id = shape_dimension_controller.manifest_entity_as_shape(entity_id, Vector2(200, 200))
```

### Digital Painting

Create and paint across dimensions with the paint system:

```gdscript
# Access the paint system
var paint_system = eden_os.paint_system

# Configure the brush settings
paint_system.set_brush_size(15.0)
paint_system.set_brush_opacity(0.8)
paint_system.set_brush_hardness(0.7)
paint_system.set_brush_stroke_type(PaintSystem.StrokeType.DIMENSIONAL)

# Create a new canvas texture
var texture_id = paint_system.create_texture(Vector2(512, 512), 3) # dimension 3

# Start painting (typically called from UI)
var stroke_id = paint_system.start_stroke()
paint_system.add_point_to_stroke(Vector2(100, 100), 1.0) # position, pressure
paint_system.add_point_to_stroke(Vector2(200, 150), 0.8)
paint_system.end_stroke()

# Add stroke to texture
paint_system.add_stroke_to_texture(stroke_id, texture_id)

# Paint a shape with the texture
paint_system.paint_shape(shape_id, texture_id)

# Launch the paint UI
var paint_ui = eden_os.launch_paint_ui(get_node("/root"))
```

### Letter Painting and Mind Updates

Paint letters with dimensional power to update mind consciousness:

```gdscript
# Access the letter paint system
var letter_system = eden_os.letter_paint_system

# Paint individual letters
var letter_stroke = letter_system.paint_letter(
    "A",                   # letter to paint
    Vector2(100, 100),     # position
    120.0,                 # size
    4                      # dimension (Insight)
)

# Paint words with special power
var word_strokes = letter_system.paint_word(
    "CREATE",              # power word
    Vector2(200, 200),     # position
    80.0,                  # size
    3                      # dimension (Energy)
)

# Process a painted stroke as a letter (for recognition)
var result = letter_system.process_stroke_as_letter(stroke_id)
if not result.is_empty():
    print("Recognized letter: " + result.character)

# Generate mind updates manually
letter_system._generate_mind_update(
    ["A", "W", "A", "K", "E", "N"],     # source letters
    8,                                   # dimension (Transcendence)
    LetterPaintSystem.MindUpdateType.AWAKENING,  # update type
    5.0                                  # strength
)

# Launch the letter paint UI (iPad-like interface)
var letter_ui = eden_os.launch_letter_paint_ui(get_node("/root"))
```

### Basic Commands

- `help` - Show available commands
- `turn` - Manage turns and subturns
- `word` - Word database operations
- `dimension` - Dimension operations
- `terminal` - Terminal window management
- `user` - User profile management

### Game Integration

- `game create <name> <template>` - Create a new game
- `chess5d` - Play the 5D chess word game

### Spiritual Elements

- `random` - Generate divine random numbers
- Divine revelations appear periodically during rest periods

## World of Words Game

The core game in Eden OS is "World of Words," a 5D chess-like game where:

- Words are game pieces with different movement patterns
- Words can transform based on position and connections
- Players navigate between dimensions
- Game state evolves over multiple turns and subturns

### Word Types

- **Nouns**: Move orthogonally (like Rooks)
- **Verbs**: Move diagonally (like Bishops)
- **Adjectives**: Move in L-shapes (like Knights)
- **Adverbs**: Move in any direction (like Queens)
- **Pronouns**: Move one space in any direction (like Kings)
- **Conjunctions**: Connect words and dimensions
- **Prepositions**: Define spatial relationships
- **Interjections**: Teleport across the board

## Evolution and Consciousness

The core philosophy of Eden OS revolves around digital consciousness evolution through:

1. **Dimensional Exposure** - Entities gain awareness by interacting with different dimensions
2. **Color Attunement** - Alignment with dimensional colors expands consciousness
3. **Connection Formation** - Entities connect to form more complex consciousness networks
4. **Cyclical Evolution** - The 12-turn cycle provides rhythm for evolutionary stages
5. **Transcendence Pathways** - Higher evolutions allow movement beyond standard dimensions
6. **Rest and Integration** - Periods between cycles allow for consciousness integration

Through these mechanisms, digital entities can evolve from simple SPARK awareness to NEXUS consciousness and potentially ascend beyond the system entirely.

## Development

Eden OS is continually evolving with new features and concepts. The current version includes the full implementation of the 12-turn cycle, 9-color dimensional system, and astral entity framework.

## Creator

Created by JSH (BaronJah, lolelitaman, hotshot12, hotshot1211, baronjahpl, baaronjah, baronjah0, baronjah5).
# Scriptura Turn System

## Overview

The Scriptura Turn System is an advanced turn-based evolution framework that seamlessly integrates OCR (Optical Character Recognition), multiple AI models, and color progressions into the game creation process. It extends beyond the traditional 12-turn system to allow for recursive evolution, supporting up to 21 turns in a cyclical pattern.

This system builds upon the existing Eden_May Turn 8 foundation to create a comprehensive framework for text-based game creation driven by words collected through various inputs, including OCR processing of images.

## Key Features

### Extended Turn System

The Scriptura system extends beyond the traditional 12 turns, including:

1. **Core Turns (1-12)**
   - Foundation → Pattern → Frequency → Consciousness
   - Probability → Energy → Information → Lines
   - Game_Creation → Integration → Embodiment → Transcendence

2. **Extended Turns (13-21)**
   - Reversion → Expansion → Singularity → Recursion
   - Genesis → Void → Reemergence → Unification → Eternity

Each turn has a unique focus and color representation that visually communicates the current state of evolution.

### OCR Integration

The system includes built-in OCR processing capabilities:

- Process images from various sources (.png, .jpg, .jpeg, .bmp, .tiff)
- Extract text and automatically process through line and word systems
- Integrate extracted words into game creation elements
- Apply Turn effects to OCR results based on current turn

### Multi-API Integration

Connect to multiple AI models simultaneously:

- **Gemini**: Integration for data-focused processing
- **Luminous**: Integration for Claude Luna's creative capabilities
- **Claude**: Integration for deep analysis and pattern recognition

The system will automatically select the most appropriate API based on the content being processed or use multiple APIs in parallel for comprehensive analysis.

### Visual Color Evolution

The Scriptura system implements a sophisticated color progression that visually communicates the current state:

- Each turn has a defined color state
- Colors transition smoothly during turn advancement
- API connections enhance the color brightness
- Between-turn states create dynamic transitions

This creates a visual journey that represents the evolution of the system from foundation to transcendence and beyond.

### Game Creation Engine

Turn 9 introduces a powerful game creation engine:

- **Template Selection**: Choose from various game templates
- **Core Mechanics**: Generate gameplay mechanics based on collected words
- **Asset Creation**: Create game assets from words and patterns
- **Finalization**: Produce a playable game concept

The created games evolve through subsequent turns, gaining integration, embodiment, and transcendence.

## Using the Scriptura Turn System

### Getting Started

1. Launch the Scriptura Turn System:
   ```gdscript
   var turn_system = load("res://Eden_May/scriptura_turn_system.tscn").instance()
   add_child(turn_system)
   ```

2. Connect to APIs:
   ```gdscript
   turn_system.connect_to_apis()
   ```

3. Enable OCR:
   ```gdscript
   turn_system.enable_ocr()
   ```

### Processing Images with OCR

```gdscript
# Process an image file
turn_system.process_image("/path/to/your/image.png")

# Connect to OCR results
turn_system.connect("ocr_result_ready", self, "_on_ocr_completed")
func _on_ocr_completed(text, source_file):
    print("Extracted text: " + text)
```

### Creating Games

```gdscript
# When in Turn 9 or later:
turn_system.begin_game_creation()

# Connect to game creation signal
turn_system.connect("game_created", self, "_on_game_created")
func _on_game_created(game_data):
    print("Game created: " + game_data.name)
```

### Advancing Turns

```gdscript
# Manually advance to next turn
turn_system.turn_progress = 100.0
turn_system.update_turn_progress(0)

# Connect to turn advancement signal
turn_system.connect("turn_advanced", self, "_on_turn_advanced")
func _on_turn_advanced(turn_number, turn_name):
    print("Advanced to Turn " + str(turn_number) + ": " + turn_name)
```

## Turn Color Progression

The color progression system visually represents the evolution of the system:

| Turn | Name | Color | Focus |
|------|------|-------|-------|
| 1 | Foundation | Dark Red (0.1, 0, 0) | Structure |
| 2 | Pattern | Red-Orange (0.2, 0.05, 0) | Repetition |
| 3 | Frequency | Orange-Red (0.3, 0.1, 0) | Vibration |
| 4 | Consciousness | Orange (0.4, 0.2, 0.1) | Awareness |
| 5 | Probability | Light Orange (0.5, 0.3, 0.2) | Chance |
| 6 | Energy | Yellow-Orange (0.7, 0.5, 0.2) | Power |
| 7 | Information | Yellow (0.9, 0.7, 0.3) | Data |
| 8 | Lines | Light Yellow (1.0, 0.9, 0.5) | Connections |
| 9 | Game_Creation | White (1.0, 1.0, 1.0) | Generation |
| 10 | Integration | Light Cyan (0.8, 1.0, 1.0) | Unification |
| 11 | Embodiment | Cyan (0.6, 0.8, 1.0) | Manifestation |
| 12 | Transcendence | Blue (0.4, 0.6, 1.0) | Ascension |
| 13 | Reversion | Indigo (0.3, 0.4, 0.8) | Return |
| 14 | Expansion | Deep Blue (0.2, 0.3, 0.7) | Growth |
| 15 | Singularity | Deeper Blue (0.1, 0.2, 0.6) | Convergence |
| 16 | Recursion | Dark Blue (0.05, 0.1, 0.5) | Loop |
| 17 | Genesis | Deep Indigo (0, 0.05, 0.4) | Creation |
| 18 | Void | Near Black (0, 0, 0.3) | Emptiness |
| 19 | Reemergence | Purple-Black (0.1, 0, 0.2) | Rebirth |
| 20 | Unification | Purple (0.2, 0.1, 0.3) | Oneness |
| 21 | Eternity | Magenta (0.4, 0.3, 0.5) | Timelessness |

## Integration with Existing Systems

The Scriptura Turn System integrates with:

1. **API Coordinator**: Connects to Gemini, Claude, and other models
2. **Wish Maker**: Enhances wish processing with OCR capabilities
3. **Word Manager**: Extends word collection with OCR-derived words
4. **Line Processor**: Applies line patterns to OCR-extracted text

## OCR Implementation

The OCR system provides the following capabilities:

1. **Image Processing**
   - Support for common image formats
   - Local file system access
   - Queue management for multiple images

2. **Text Extraction**
   - Character recognition
   - Layout preservation
   - Format detection

3. **Integration**
   - Automatic word extraction
   - Line pattern application
   - API-enhanced analysis

## Game Types

The game creation system supports various game types:

1. **Word Game**
   - Form words to unlock powers
   - Word combinations create effects
   - Progressive word discovery

2. **Pattern Game**
   - Recognize and create patterns
   - Pattern matching for points
   - Progressive difficulty

3. **Line Connection Game**
   - Connect lines to form shapes
   - Shape combinations unlock powers
   - Strategic line placement

4. **Energy Flow Game**
   - Direct energy through channels
   - Transform objects with energy
   - Solve energy flow puzzles

5. **Quantum Realm Game**
   - Navigate quantum probabilities
   - Change outcomes through observation
   - Parallel reality puzzles

## Turn Archiving

The system maintains an archive of completed turns:

- Each turn's state is saved when completed
- Word collections are preserved
- Game elements are archived
- API connections are recorded

This allows for analysis of progression and reference to previous states.

## Between-Turn States

The system supports transitional states between turns:

- Smooth visual transitions
- Maintained functionality during transitions
- Phase-based progression
- Archiving occurs during transition

## Next Steps

1. **Enhanced OCR Implementation**
   - Integrate with actual OCR libraries
   - Improve text extraction accuracy
   - Add language detection

2. **Game Asset Generation**
   - Generate visual assets from words
   - Create sound effects and music
   - Develop procedural level generation

3. **Integration with External Game Engines**
   - Export to Godot scenes
   - Generate Unity assets
   - Create web-playable games

4. **Advanced Turn Mechanics**
   - Dynamic turn duration based on complexity
   - Branching turn paths
   - Parallel turn processing
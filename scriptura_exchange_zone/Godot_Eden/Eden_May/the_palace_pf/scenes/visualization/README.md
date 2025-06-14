# 3D Words in Space Visualization

This component allows you to visualize words in 3D space with Excel-like grid functionality, creating a visual representation of the JSH Ethereal Engine's word manifestation system.

## Overview

The Words in Space visualization places words in a 3D grid, connecting related concepts and showing relationships between different words. It provides:

- Interactive 3D visualization of words
- Excel-like grid system for organization
- Connection visualization between related words
- Visual effects like pulsing, rotation, and glow
- Category-based coloring of words
- Integration with the JSH Ethereal Engine word system

## Getting Started

1. Open the demo scene: `scenes/visualization/words_in_space_demo.tscn`
2. Press Play to run the demo
3. Use the UI panel to add words and create connections
4. Right-click and drag to rotate the camera around the words

## Features

### Word Visualization

Words are displayed as 3D text in space, with:
- Category-based coloring (concepts, objects, actions, properties, relations)
- Visual effects like pulsing and rotation
- Highlighting on hover and selection
- Connections between related words

### Excel-like Grid

The 3D space is organized in an Excel-like grid system:
- Columns (A, B, C...)
- Rows (1, 2, 3...)
- Layers (Front, Mid, Back...)
- Cell-based formulas and word placement

### Integration with JSH Ethereal Engine

The visualization can:
- Display words from the Word Manifestor system
- Visualize entities from the Entity Manager
- Show connections based on the Akashic Records system
- Update in real-time as new words are manifested

## Controls

- **Right Mouse Button + Drag**: Rotate camera
- **Click on Word**: Select word and see details
- **UI Panel**:
  - Add new words to the space
  - Control visual effects
  - Connect words
  - Export visualization

## Usage Examples

### Basic Visualization

```gdscript
# Create visualization node
var words_viz = WordsInSpace3D.new()
add_child(words_viz)

# Add some words
words_viz.add_word("reality", Vector3(1, 5, 1), "concept")
words_viz.add_word("creation", Vector3(3, 5, 2), "concept")
words_viz.add_word("fire", Vector3(5, 3, 1), "object")
words_viz.add_word("water", Vector3(5, 3, 3), "object")

# Connect related words
words_viz.connect_words("reality", "creation")
words_viz.connect_words("fire", "water")
```

### Word Positioning in Grid

```gdscript
# Place words in specific grid cells
words_viz.set_cell_word("A1", "Front", "reality")
words_viz.set_cell_word("C2", "Mid", "creation")
words_viz.set_cell_word("E3", "Front", "fire")
words_viz.set_cell_word("E3", "Back", "water")

# Add a formula to connect words
words_viz.set_cell_formula("D4", "Mid", "=CONNECT(A1,C2)")
```

### Entity Visualization

```gdscript
# Visualize all entities from Entity Manager
words_viz.visualize_entities()

# Export visualization to a file
words_viz.export_visualization("user://my_words_visualization.tscn")
```

## Integration with Word System

The visualization integrates with the JSH Ethereal Engine's word system:

1. **Word Manifestor**: Uses word analysis to determine properties
2. **Entity Manager**: Visualizes entities in 3D space
3. **Akashic Records**: Shows connections based on relationships

## Sending to Luminus

To share this visualization with Luminus:

1. Run the demo scene and add your desired words
2. Click "Export Visualization" to save the current state
3. The file will be saved to the user directory
4. Share this file with Luminus, who can import it into their own JSH Ethereal Engine

## Technical Notes

- The visualization uses Godot's 3D text rendering capabilities
- Words are represented as 3D meshes with materials
- Connections are drawn using immediate geometry
- The system is designed to handle hundreds of words in 3D space
- Performance optimizations include distance-based level of detail

Enjoy exploring your world of words in 3D space!
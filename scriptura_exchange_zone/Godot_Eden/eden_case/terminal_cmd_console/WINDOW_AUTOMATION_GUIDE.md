# Window & Keyboard Automation Guide

This guide summarizes the automation tools available in the system for controlling windows, keyboard, and mouse interactions in your game and terminal environment.

## Core Automation Components

### 1. KeyboardShapeManager
A sophisticated keyboard tracking system that detects key patterns and generates visual shapes.

**Key Features:**
- Tracks keyboard input and key combinations
- Generates shapes based on key patterns (WASD → cube, HJKL → sphere, etc.)
- Supports color progression and special effect combinations
- Includes eye tracking integration for enhanced visualization
- Saves and loads shapes to a persistent library

**Usage Example:**
```gdscript
var keyboard_manager = KeyboardShapeManager.new()
add_child(keyboard_manager)
keyboard_manager.connect("shape_changed", self, "_on_shape_changed")
```

### 2. TerminalGridCreator
Creates and manages ASCII-based grid elements for game visualization.

**Key Features:**
- Generates ASCII representation of rooms, corridors, and entities
- Creates special elements like miracle portals and dimension gates
- Supports pattern recognition for special effects
- Handles multi-dimensional elements (1D to 12D)
- Implements time effects (past/present/future/timeless)

**Usage Example:**
```gdscript
var grid_creator = TerminalGridCreator.new()
grid_creator.create_grid(80, 24)
grid_creator.generate_dungeon(5)
```

### 3. MouseAutomation
Advanced cursor control system with awareness capabilities (Turn 5: Awakening).

**Key Features:**
- Provides smooth cursor movement with path generation
- Includes OCR for recognizing screen elements
- Supports clicking, dragging, and typing automation
- Implements pattern recognition for UI elements
- Features self-healing and self-awareness capabilities

**Usage Example:**
```gdscript
var mouse_automation = MouseAutomation.new()
add_child(mouse_automation)
mouse_automation.recognize_target("Login button")
mouse_automation.click()
```

## Window Automation Techniques

### Horizontal Window Management
For creating side-by-side window layouts:

1. **Grid-Based Positioning**:
   Use TerminalGridCreator to design layouts with adjacent ASCII elements.

2. **Mouse Automation for Window Manipulation**:
   ```gdscript
   mouse_automation.recognize_target("window title")
   mouse_automation.drag(start_position, end_position)
   ```

3. **Keyboard Shortcuts Integration**:
   ```gdscript
   keyboard_manager.key_combinations = ["CTRL+ALT+LEFT", "CTRL+ALT+RIGHT"]
   ```

### Creating Keyboard-Like Screen Elements

Implement interactive keyboard visualizations:

1. Use TerminalGridCreator to design keyboard layouts:
   ```gdscript
   var keyboard_layout = "+---+ +---+ +---+\n| Q | | W | | E |\n+---+ +---+ +---+"
   grid_creator.place_pattern(10, 10, keyboard_layout, ShapeCategory.SPECIAL)
   ```

2. Connect MouseAutomation for interaction:
   ```gdscript
   mouse_automation.connect_to_bridge(terminal_bridge)
   ```

3. Use KeyboardShapeManager to track and visualize keyboard state

## Integration Points

### Terminal-to-Game Bridge
```gdscript
# Connect mouse automation to terminal bridge
mouse_automation.connect_to_bridge(get_node("/root/TerminalToGodotBridge"))
```

### Multiple Window Coordination
For split-screen terminal layouts:
```gdscript
# Create two grid displays side by side
var grid1 = grid_creator.create_grid(40, 24)
var grid2 = grid_creator.create_grid(40, 24)
grid_creator.save_grid("left_window")
grid_creator.save_grid("right_window")
```

### 12-Turn System Integration
```gdscript
# Connect to turn system for dimension management
turn_system.connect("dimension_changed", grid_creator, "_on_dimension_changed")
```

## Advanced Applications

1. **Split Terminal Layouts**:
   Divide the screen into zones for different functions using TerminalGridCreator

2. **Keyboard-Driven Shape Visualization**:
   Use KeyboardShapeManager for real-time visual feedback from keyboard input

3. **Automated Testing**:
   Leverage MouseAutomation's target recognition and clicking capabilities

4. **Self-Aware Cursor**:
   Implement cursor behaviors that respond to context using MouseAutomation's self-awareness

5. **Multi-Dimensional Interfaces**:
   Build interfaces that span different conceptual dimensions using TerminalGridCreator

## Next Steps

1. Create a unified controller script that coordinates all three systems
2. Implement save/load functionality for window layouts
3. Add visualization for keyboard shapes in terminal space
4. Connect automation to word manifestation system
5. Develop multi-window preset configurations
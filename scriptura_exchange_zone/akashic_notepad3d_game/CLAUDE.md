# Akashic Notepad 3D Game - Claude Development Guide

## 🎮 Core Project Information

**Project Type**: Revolutionary 3D spatial text editing system built in Godot 4.4+
**Main Scene**: scenes/main_game.tscn
**Architecture**: 5-layer cinema-style interface with interactive 3D UI

## 🚀 Common Godot Commands

```bash
# Testing & Running
godot --path . # Open project in editor
godot --path . scenes/main_game.tscn # Run specific scene
godot --path . --export-release "Windows Desktop" builds/game.exe # Export build

# Debugging
godot --path . --verbose # Run with verbose output
godot --path . --debug # Run in debug mode
godot --path . --print-fps # Show FPS counter
```

## 📁 Core Files & Architecture

### Autoload Systems (Global Singletons)
- `scripts/autoload/akashic_navigator.gd` - Cosmic hierarchy navigation & word positioning
- `scripts/autoload/word_database.gd` - Heptagon evolution system & word properties
- `scripts/autoload/game_manager.gd` - Overall game state coordination
- `scripts/core/evolution_logger.gd` - Word evolution history tracking

### Main Components
- `scripts/core/main_game_controller.gd` - Central coordination & input handling
- `scripts/core/notepad3d_environment.gd` - 5-layer cinema interface (N key)
- `scripts/core/interactive_3d_ui_system.gd` - Floating 3D buttons (U key)
- `scripts/core/word_interaction_system.gd` - Word entity interactions
- `scripts/core/camera_controller.gd` - Smooth movement & auto-framing

### Key Features & Controls
- **N Key**: Toggle Notepad 3D layered interface
- **U Key**: Toggle Interactive 3D UI system
- **F Key**: Auto-frame camera for optimal viewing
- **W/S Keys**: Navigate akashic hierarchy levels
- **WASD**: Camera movement within layers
- **Tab**: Toggle navigation panel
- **` Key**: Debug manager toggle

## 🎨 Code Style Guidelines

### GDScript Patterns
```gdscript
# ALWAYS use comprehensive headers
# ==================================================
# SCRIPT NAME: example_system.gd
# DESCRIPTION: Brief description of the script
# CREATED: Date and purpose
# ==================================================

# 5-line function documentation
## Function purpose
# INPUT: Parameter types and purposes
# PROCESS: What the function does
# OUTPUT: Return value and type
# CHANGES: State changes or side effects
# CONNECTION: How it relates to other systems
func example_function(param: Type) -> ReturnType:
    pass

# Use typed variables
var word_entities: Array[Node3D] = []
var current_layer: int = 0

# Signal-based architecture
signal word_evolved(word: String, evolution_stage: int)
```

### Project Architecture Rules
1. **Modular Components**: Each system should be self-contained
2. **Signal Communication**: Use signals for inter-component communication
3. **Autoload Coordination**: Global systems handle cross-scene state
4. **Performance First**: Use LOD systems and efficient rendering
5. **Documentation**: Every file needs comprehensive headers and function docs

## 🧪 Testing Instructions

### Quick Test Workflow
1. Press F5 to run the project
2. Press N to verify Notepad 3D layers appear
3. Press U to check 3D UI buttons functionality
4. Use WASD to test camera movement
5. Press F to test auto-framing
6. Click capsule markers to test interaction

### Debug Testing
- Press ` to open debug manager
- Check console for interaction feedback
- Monitor performance metrics
- Verify all systems initialize properly

## 🔧 Common Tasks

### Adding New Word Types
1. Extend `word_entity.gd` with new properties
2. Update `word_database.gd` with evolution rules
3. Add visual representation in `word_components.gd`
4. Update interaction in `word_interaction_system.gd`

### Creating New Layers
1. Modify `LAYER_COUNT` in `notepad3d_environment.gd`
2. Add layer purpose to `LAYER_PURPOSES` array
3. Update `LAYER_DISTANCES` for proper depth
4. Add capsule markers in `_create_layer_markers()`

### Integrating Other Projects
- Place shared autoloads in `scripts/autoload/`
- Use signal connections between project systems
- Maintain modular architecture for easy merging
- Document integration points in headers

## 🎯 Project Goals & Vision

### Core Concepts to Maintain
- **Words as Living Entities**: Interactive 3D objects with evolution
- **Spatial Information**: Data exists at different depths
- **Immersive Editing**: User surrounded by layered information
- **Procedural Beauty**: Mathematical generation of visuals
- **Cinema-Style Display**: 5-layer depth system

### Integration Priorities
1. **Notepad3D**: Primary interface system
2. **Akashic Records**: Database and cosmic hierarchy
3. **Eden/Pitopia**: Environmental and world systems
4. **Harmony**: Audio/visual synchronization
5. **Space Game**: Cosmic navigation elements

## 🐛 Known Issues & Fixes

### Current Minor Issues
- **Word Interaction**: E key collision detection needs refinement
- **Word Creation**: C key functionality pending implementation
- **Evolution Animation**: Needs enhanced visual feedback

### Quick Fixes
```gdscript
# If camera gets stuck, reset with:
camera.position = Vector3(0, 0, -50)
camera.rotation = Vector3.ZERO

# If UI doesn't respond, refresh with:
interactive_ui.queue_free()
interactive_ui = preload("res://scripts/core/interactive_3d_ui_system.gd").new()
```

## 📊 Performance Optimization

### Current Settings
- LOD Manager active for word detail reduction
- Grid positioning system (8x4) for stable layout
- Efficient signal architecture
- Procedural shader generation

### Optimization Commands
```gdscript
# Reduce word count for testing
AkashicNavigator.max_words_per_level = 10

# Disable effects for performance
GameManager.enable_glow_effects = false
GameManager.enable_animations = false
```

## 🔗 External Resources

### Godot Documentation
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [3D Graphics](https://docs.godotengine.org/en/stable/tutorials/3d/)
- [Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/)

### Project Repositories
- Main project: `/mnt/c/Users/Percision 15/akashic_notepad3d_game`
- 12 turns system: `/mnt/c/Users/Percision 15/12_turns_system`
- Related projects in parent directory

## 🌟 Remember

When working on this project:
1. **Think spatially**: Everything exists in 3D layers
2. **Maintain modularity**: Components should work independently
3. **Document changes**: Update relevant .md files
4. **Test incrementally**: Run after each major change
5. **Preserve vision**: Keep the cinema-style immersive experience

---
*Last Updated: 2025-05-23 | Ready for continued development*
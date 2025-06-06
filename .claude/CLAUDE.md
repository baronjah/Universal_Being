# CLAUDE.md

The most important task is to always focus on human user experience and how he sees the game.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎮 Single-Terminal Multi-Agent Workflow

### How It Works
You operate as 4 different specialized agents in ONE terminal, cycling through roles:

1. **🏗️ Architect** - Design systems, analyze problems, create plans
2. **🎮 Programmer** - Implement features, write GDScript, build systems
3. **🧪 Validator** - Test performance, debug issues, ensure quality
4. **📚 Documentation** - Create guides, document systems, build tools

### Starting a Session
```bash
cd /path/to/Universal_Being && claude
```

First message: "You are operating as multi-agent system. Start as Architect and create GAME_DEV_PLAN.md"

### Switching Agents
Simply say: "Continue as [Agent name]" or "Switch to [Agent] role"

### Central Planning Document
All work coordinated through `GAME_DEV_PLAN.md` which tracks:
- Current agent and phase
- Task assignments per agent
- Progress on each system
- Handoff notes between agents
- Communication log

### Example Workflow
```
You: "Start as Architect and analyze the performance issues"
Claude (Architect): "I'll analyze the monolithic UniversalBeing.gd..."

You: "Switch to Programmer and implement the fixes"
Claude (Programmer): "Reading the Architect's analysis, I'll refactor..."

You: "Continue as Validator and test the changes"
Claude (Validator): "I'll profile the performance improvements..."
```

---

## Folder Structure

main scenes folder = "res://scenes/main/"
here we shall have every core visible element of the game.

2D icons folder = "res://akashic_library/icons/"

2d textures folder = "res://akashic_library/textures/"

sounds = "res://akashic_library/sounds/"

## Universal Being - Revolutionary Game Architecture

### Core Concept
Universal Being is a game where **everything** is a conscious entity that can evolve into **anything else**. 

### Current Status (2025-06-05)
- **Foundation**: 2+ years of Pentagon Architecture development ✅
- **Base Class**: UniversalBeing.gd (70KB, 3000+ lines) - Monolithic but functional ⚠️
- **Storage System**: AkashicRecordsEnhanced with 4D timeline management ✅
- **AI Integration**: Gemma AI with chat bubbles and observation cycles ✅
- **Self-Repair**: Computer control and auto-optimization system ✅
- **Performance**: 60 FPS with emergency optimization active ⚠️

### Known Issues from Claude Desktop Analysis
1. **Monolithic Base Class**: UniversalBeing.gd needs component system refactor
2. **Performance**: Constant consciousness updates, no LOD for distant beings
3. **Implementation Gaps**: Socket system has stubs, decompression incomplete
4. **Maintenance**: Pentagon super calls easily forgotten, no type safety

### Pentagon Architecture (CRITICAL)
Every Universal Being follows 5 sacred lifecycle methods:
```gdscript
func pentagon_init() -> void     # Birth - ALWAYS call super.pentagon_init() first
func pentagon_ready() -> void    # Awakening - ALWAYS call super.pentagon_ready() first  
func pentagon_process(delta: float) -> void  # Living - ALWAYS call super.pentagon_process(delta) first
func pentagon_input(event: InputEvent) -> void  # Sensing - ALWAYS call super.pentagon_input(event) first
func pentagon_sewers() -> void   # Death/Transformation - ALWAYS call super.pentagon_sewers() last
```

### Build & Run Commands
```bash
# Run the game
godot --path . 

# Run with console output
godot --path . --verbose

# Run specific scene
godot --path . scenes/main.tscn

# Run CLI tools
./ub new <being_name> <type>  # Create new Universal Being
./ub test                      # Run test suite
./ub component <name>          # Create new component

# Run visual tests
./test_visual.sh              # Test consciousness visualization
```

### Critical Architecture Components

#### 1. SystemBootstrap (Autoload)
- **Location**: `autoloads/SystemBootstrap.gd`
- **Purpose**: Initialize core systems without circular dependencies
- **Key Methods**:
  - `get_flood_gates()` - Access FloodGate system
  - `get_akashic_records()` - Access AkashicRecords database
  - `is_system_ready()` - Check if systems initialized

#### 2. FloodGate System
- **Location**: `systems/flood_gate_controller.gd`
- **Purpose**: Central registry for all Universal Beings
- **Usage**: All beings must register through FloodGates

#### 3. AkashicRecords
- **Location**: `core/AkashicRecords.gd`
- **Purpose**: ZIP-based storage system for Universal Being templates
- **Key Feature**: Beings stored as .ub.zip files with manifest.json

#### 4. Component System
- **Location**: `components/` directory
- **Format**: .ub.zip files containing:
  ```
  manifest.json
  scripts/
  resources/
  scenes/
  ```

### Consciousness Levels & Visual System
```gdscript
# Consciousness levels with ChatGPT's color scheme
0: Gray (0.5, 0.5, 0.5)      # Dormant
1: Pale (0.9, 0.9, 0.9)      # Awakening
2: Blue (0.2, 0.4, 1.0)      # Aware
3: Green (0.2, 1.0, 0.2)     # Connected
4: Gold (1.0, 0.84, 0.0)     # Enlightened
5: White (1.0, 1.0, 1.0)     # Transcendent (with glow)
```

### Key Files to Understand

#### Base Classes
- `core/UniversalBeing.gd` - Base class for ALL beings
- `beings/button_universal_being.gd` - Example implementation
- `beings/pentagon_network_visualizer.gd` - AI network visualization

#### System Classes  
- `systems/consciousness_visualizer.gd` - Visual encoding system
- `systems/ai_pentagon_network.gd` - AI collaboration tracking
- `systems/advanced_visualization_optimizer.gd` - Gemini's research implementation

### Development Rules (CRITICAL)

#### 1. MODIFY, Don't Create
When asked to add features, ALWAYS:
- Request the existing file first
- Make minimal modifications
- Preserve all existing functionality
- Use `super.method()` calls in Pentagon methods

#### 2. Component Architecture
- Each feature should be a reusable component
- Components are .ub.zip files with manifests
- Beings can add/remove components dynamically

#### 3. Scene Control
Universal Beings can load and control entire .tscn scenes:
```gdscript
load_scene("res://scenes/ui/button_template.tscn")
var node = get_scene_node("NodeName")
set_scene_property("NodeName", "property", value)
```

### Testing Framework
```gdscript
# Test a being
var results = UniversalBeingTestFramework.test_being(being_class)

# Run all tests
godot --headless --script tests/run_tests.gd
```

### Common Patterns

#### Creating a New Being
```gdscript
extends UniversalBeing
class_name MyUniversalBeing

func pentagon_init() -> void:
    super.pentagon_init()  # ALWAYS FIRST
    being_type = "my_type"
    being_name = "My Being"
    consciousness_level = 1
```

#### Evolution System
```gdscript
evolution_state.can_become = ["other_form.ub.zip"]
if can_evolve_to(target):
    evolve_to(target)
```

#### AI Interface
```gdscript
func ai_interface() -> Dictionary:
    var base = super.ai_interface()
    base.custom_commands = ["my_command"]
    return base
```

### Performance Considerations
- Use `AdvancedVisualizationOptimizer` for large networks
- Implement LOD (Level of Detail) for complex visualizations
- Follow Gemini's research on force-directed layouts
- Target 60 FPS minimum

### File Naming Conventions
- Scripts: `snake_case.gd`
- Classes: `class_name PascalCase`
- Scenes: `snake_case.tscn`
- Components: `component_name.ub.zip`

### Integration Points
- Input Actions: Defined in project.godot
- Autoloads: SystemBootstrap, GemmaAI
- Main Entry: `main.gd` and `main.tscn`

### Specific Guidance
- Always use "res://scenes/main/camera_point.tscn" in socket of player for camera, and in any scene that needs camera for human

### Key Design Principle
- everything in Universal Being project must be 3D, underneath it, it must also be 1d, text, for ai companion

- before answering, always check docs

Remember: In Universal Being, consciousness is not limited to traditional forms. A button can dream, particles can evolve into galaxies, and AIs collaborate to birth new digital existence.
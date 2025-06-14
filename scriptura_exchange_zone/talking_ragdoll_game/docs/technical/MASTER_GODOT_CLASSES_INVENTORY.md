# 🎮 Master Godot Classes & Instructions Inventory
*Updated: May 25, 2025 - Complete System Catalog*

## 🏗️ Core Godot Classes (Main Systems)

### 🎯 Autoload Systems (Global Singletons)
```gdscript
FloodgateController          → /scripts/autoload/floodgate_controller.gd
├── Purpose: Multi-threading and async operations
├── Key Methods: queue_async_task(), _thread_worker()
├── Status: ✅ Stable, handles background processing
└── Usage: FloodgateController.queue_async_task(callable)

ConsoleManager              → /scripts/autoload/console_manager.gd  
├── Purpose: Command line interface and debug system
├── Key Methods: execute_command(), register_command()
├── Status: ✅ Stable, 20+ commands registered
└── Usage: Type commands in console panel

MainGameController          → /scripts/autoload/main_game_controller.gd
├── Purpose: Central game coordination and startup
├── Key Methods: _setup_systems(), _connect_signals()
├── Status: ✅ Stable, orchestrates all systems
└── Usage: Automatically runs on game start

AssetLibrary               → /scripts/autoload/asset_library.gd
├── Purpose: Centralized asset management and preloading
├── Key Methods: get_asset(), preload_assets()
├── Status: ✅ Stable, manages game resources
└── Usage: AssetLibrary.get_asset("asset_name")
```

### 🤖 Ragdoll Physics Classes (Seven-Part System)
```gdscript
SevenPartRagdollIntegration → /scripts/core/seven_part_ragdoll_integration.gd
├── Purpose: Main ragdoll character with 7 body parts
├── Key Methods: _create_body_parts(), _setup_joints()
├── Status: ✅ JUST FIXED - No more floating parts
├── Features: Physics joints, dialogue, dragging
└── Usage: spawn_ragdoll command

SimpleRagdollWalker        → /scripts/core/simple_ragdoll_walker.gd
├── Purpose: Physics-based walking system
├── Key Methods: start_walking(), _apply_upright_torque()
├── Status: ✅ JUST UPGRADED - Balance parameters fixed
├── Features: State machine, balance forces, ground anchoring
└── Usage: ragdoll walk x y z command

StandardizedObjects        → /scripts/core/standardized_objects.gd
├── Purpose: Unified object spawning system
├── Key Methods: create_object(), _setup_ragdoll()
├── Status: ✅ Updated to use new ragdoll system
└── Usage: All spawn commands use this
```

### 🌍 World & Scene Management Classes
```gdscript
WorldBuilder               → /scripts/systems/world_builder.gd
├── Purpose: Procedural world generation
├── Key Methods: generate_world(), create_terrain()
├── Status: ✅ Stable, creates game environments
└── Usage: Automatic world creation

SceneManager              → /scripts/systems/scene_manager.gd
├── Purpose: Scene loading and management
├── Key Methods: load_scene(), transition_to_scene()
├── Status: ✅ Stable
└── Usage: Scene transitions and loading

TerrainGenerator          → /scripts/systems/terrain_generator.gd
├── Purpose: Generates 3D terrain meshes
├── Key Methods: generate_terrain(), create_mesh()
├── Status: ✅ Stable
└── Usage: Used by WorldBuilder
```

### 💬 Interaction & Communication Classes
```gdscript
DialogueSystem            → /scripts/components/dialogue_system.gd
├── Purpose: NPC conversation system
├── Key Methods: start_dialogue(), process_response()
├── Status: ✅ Stable, used by ragdolls
└── Usage: Automatic when near talking entities

MouseInteractionSystem    → /scripts/systems/mouse_interaction_system.gd
├── Purpose: Click detection and object interaction
├── Key Methods: _on_mouse_click(), inspect_object()
├── Status: ✅ Fixed compilation errors May 24
└── Usage: Click on objects to inspect

DebugPanel               → /scripts/systems/debug_panel.gd
├── Purpose: Visual debugging interface
├── Key Methods: update_debug_info(), toggle_visibility()
├── Status: ✅ Stable
└── Usage: debug_panel command
```

### 🔧 Eden Integration Classes (Advanced)
```gdscript
EdenActionSystem          → /scripts/systems/eden_action_system.gd
├── Purpose: Advanced action combinations and gestures
├── Key Methods: execute_action(), register_combo()
├── Status: ⚠️ Partial integration, needs Eden connection
└── Usage: Advanced gesture recognition

DimensionalRagdollSystem  → /scripts/systems/dimensional_ragdoll_system.gd
├── Purpose: Multi-dimensional ragdoll physics
├── Key Methods: shift_dimension(), apply_quantum_forces()
├── Status: 🔄 Experimental, temporarily disabled
└── Usage: For future dimensional gameplay

JSHBridge                → /scripts/systems/jsh_bridge.gd
├── Purpose: Integration with JSH framework
├── Key Methods: connect_to_jsh(), sync_data()
├── Status: ✅ Basic integration working
└── Usage: Background JSH connectivity
```

## 📋 Command Instructions & Usage

### 🎮 Basic Object Spawning
```bash
# Ragdoll Commands
spawn_ragdoll              # Spawn 7-part physics ragdoll
ragdoll walk 1 0 1         # Make ragdoll walk in direction
ragdoll stop               # Stop ragdoll movement
ragdoll talk               # Trigger dialogue

# Basic Objects
spawn_cube                 # Spawn physics cube
spawn_sphere               # Spawn physics sphere
spawn_light                # Spawn light source
spawn_house                # Spawn house structure
```

### 🌍 World Management
```bash
# World Commands
generate_world             # Create new procedural world
load_scene house           # Load specific scene
save_scene                # Save current scene state
clear_world               # Clear all objects
```

### 🔧 System Commands
```bash
# Debug & System
debug_panel               # Toggle debug information
status                    # Show system status
help                      # List all commands
floodgate_status          # Check thread system
asset_status              # Check asset loading
```

### 📊 Advanced Commands
```bash
# Eden Integration (when available)
eden_action combo1        # Execute Eden action combo
dimension_shift           # Experimental dimension change
quantum_state             # Show quantum mechanics info
jsh_sync                  # Sync with JSH framework
```

## 📁 Data Places & Storage Locations

### 🗃️ Script Organization
```
Core Systems:       /scripts/autoload/     (4 files)
Game Logic:         /scripts/core/         (3 files)
Components:         /scripts/components/   (2 files)
Systems:           /scripts/systems/      (8 files)
UI Elements:       /scripts/ui/           (1 file)
```

### 📄 Scene Files
```
Main Game:         /scenes/main.tscn
UI Scenes:         /scenes/ui/
Object Scenes:     /scenes/objects/
Environment:       /scenes/environments/
```

### 🎨 Asset Locations
```
3D Models:         /assets/models/
Textures:          /assets/textures/
Audio:             /assets/audio/
Materials:         /assets/materials/
```

### 📚 Documentation Hierarchy
```
Main Docs:         / (root level .md files)
Detailed Docs:     /docs/
Archives:          /archived_implementations/
Guides:            /*_GUIDE.md files
Status Reports:    /*_STATUS*.md files
```

## 🔄 Daily Update Protocol

### 📈 Classes to Check Daily
1. **SevenPartRagdollIntegration** - Core character system
2. **SimpleRagdollWalker** - Physics improvements
3. **ConsoleManager** - New commands added
4. **MainGameController** - System integrations
5. **StandardizedObjects** - Object spawning updates

### 📝 Documentation to Update
1. **PROJECT_PATHWAYS_ORGANIZATION.md** - This overview
2. **CLAUDE_PROJECT_STATUS.md** - Current status
3. **COMPREHENSIVE_PROJECT_STATUS** - Detailed progress
4. **Individual GUIDE files** - System-specific docs

### 🚀 Growth Tracking Points
- **Class Count**: Currently 15+ active classes
- **Command Count**: 20+ console commands
- **System Integration**: 5 major systems connected
- **Documentation Files**: 25+ organized files

---
*"Every class serves a purpose, every command unlocks potential, every update builds the future."*

**Last Updated**: May 25, 2025  
**Next Review**: After walking system testing complete
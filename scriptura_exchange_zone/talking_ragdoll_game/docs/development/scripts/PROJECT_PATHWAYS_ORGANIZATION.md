# 🗺️ Project Pathways & Organization Map
*Updated: May 25, 2025 - The Living Directory*

## 📍 Core Documentation Strongholds

### 🏰 Main Documentation Hubs (The Three Places)
1. **CLAUDE_PROJECT_STATUS.md** - Current state & recent changes
2. **docs/COMPREHENSIVE_PROJECT_STATUS_2025_05_24.md** - Detailed technical progress
3. **PROJECT_SUMMARY.md** - High-level overview & design goals

### 🗂️ Pathway Documentation Files
```
NAVIGATION_SYSTEM_INTEGRATION.md     - Navigation pathfinding plans
SYSTEM_CONNECTION_SCHEME.md          - System architecture map
MEMORY_AND_CONNECTIONS.md            - Memory integration pathways
PROJECT_PATHWAYS_ORGANIZATION.md     - This file (meta-organization)
```

## 🏗️ Project Structure Datapoints

### 📁 Core System Folders
```
/scripts/
├── autoload/           - Global systems (FloodgateController, ConsoleManager)
├── core/              - Main game logic (seven_part_ragdoll_integration.gd)
├── components/        - Reusable components (DialogueSystem, etc.)
├── systems/           - Specialized systems (WorldBuilder, JSH Bridge)
└── ui/               - User interface components

/scenes/              - Godot scene files
/assets/              - Game assets (meshes, textures, audio)
/docs/                - Documentation archive
/archived_implementations/ - Old/backup code
```

### 🎯 Key Script Datapoints
```
CORE RAGDOLL SYSTEM:
├── seven_part_ragdoll_integration.gd  - Main ragdoll implementation
├── simple_ragdoll_walker.gd          - Walking physics system
└── standardized_objects.gd           - Object spawning system

GAME FOUNDATION:
├── main_game_controller.gd           - Central game coordinator
├── floodgate_controller.gd          - Thread management
├── console_manager.gd               - Command system
└── world_builder.gd                 - World generation
```

## 🌊 Data Flow Pathways

### 💻 Console Command Flow
```
User Input → Console Manager → Command Parser → Object Spawner
                    ↓
            Command Registry → Standardized Objects → Ragdoll System
                    ↓
            Scene Tree Update → Physics Update → Visual Update
```

### 🤖 Ragdoll Physics Flow
```
Spawn Command → seven_part_ragdoll_integration.gd → Create Body Parts
                            ↓
                Create Joints → Add to Scene → Apply Physics
                            ↓
                Walking System → Balance Forces → State Machine
```

## 🔗 System Strongholds (Major Integration Points)

### 🎮 Game Core Stronghold
- **Location**: `/scripts/autoload/main_game_controller.gd`
- **Purpose**: Central coordination hub
- **Connections**: All major systems
- **Status**: ✅ Stable

### 🧵 Thread Management Stronghold  
- **Location**: `/scripts/autoload/floodgate_controller.gd`
- **Purpose**: Multi-threading coordination
- **Connections**: Asset loading, processing
- **Status**: ✅ Stable

### 🎪 Ragdoll Physics Stronghold
- **Location**: `/scripts/core/seven_part_ragdoll_integration.gd`
- **Purpose**: Advanced physics character
- **Connections**: Walking system, dialogue, spawning
- **Status**: ✅ Major upgrade complete (May 25)

### 💬 Console Interface Stronghold
- **Location**: `/scripts/autoload/console_manager.gd`
- **Purpose**: User command interface
- **Connections**: All spawnable objects, debug systems
- **Status**: ✅ Stable with 20+ commands

## 📊 Current Project Stats & Locations

### 🎯 Active Features (Where They Live)
```
Console Commands (20+)     → /scripts/autoload/console_manager.gd
Object Spawning           → /scripts/core/standardized_objects.gd
7-Part Ragdoll            → /scripts/core/seven_part_ragdoll_integration.gd
Physics Walking           → /scripts/core/simple_ragdoll_walker.gd
Dialogue System           → /scripts/components/dialogue_system.gd
World Building            → /scripts/systems/world_builder.gd
Scene Management          → /scripts/systems/scene_manager.gd
```

### 🔧 Development Tools Locations
```
Asset Library            → /scripts/autoload/asset_library.gd
Debug Systems            → /scripts/systems/debug_panel.gd
Mouse Interaction        → /scripts/systems/mouse_interaction_system.gd
Eden Integration         → /scripts/systems/eden_action_system.gd
JSH Framework            → /scripts/systems/jsh_bridge.gd
```

## 🚀 Growth Tracking (Daily Updates)

### 📈 Recent Additions (May 25, 2025)
- ✅ Fixed ragdoll tilted hovering
- ✅ Improved balance parameters
- ✅ Added ground anchoring system
- ✅ Created strict upright detection
- ✅ Enhanced documentation organization

### 📋 Next Expansion Points
- 🔄 Walking system testing
- 🔄 Navigation pathfinding integration
- 🔄 Enhanced dialogue interactions
- 🔄 Multi-ragdoll coordination
- 🔄 Eden system full integration

## 🗃️ Documentation Archive Locations

### 📚 Guide Collections
```
RAGDOLL_SYSTEM_GUIDE.md          - Complete ragdoll documentation
SCENE_MANAGEMENT_GUIDE.md        - Scene system overview
WORLD_GENERATION_GUIDE.md        - World building procedures
ASTRAL_BEINGS_QUICK_GUIDE.md     - Special entity management
docs/EDEN_MAGIC_TESTING_GUIDE.md - Advanced system testing
```

### 📊 Status Reports
```
TODAYS_ACHIEVEMENTS_2025_05_25.md - Daily achievement tracking
docs/README_MASTER.md             - Master overview document
docs/TALKING_ASTRAL_BEINGS_GUIDE.md - Entity interaction guide
```

---
*"Every pathway leads to discovery, every stronghold guards knowledge, every datapoint tells our story."*

**Last Updated**: May 25, 2025  
**Next Update**: Add walking test results and navigation improvements
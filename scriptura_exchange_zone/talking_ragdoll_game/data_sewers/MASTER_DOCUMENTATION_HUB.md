# TALKING RAGDOLL GAME - MASTER DOCUMENTATION HUB

## 🎯 Quick Start Documentation

- [**QUICK REFERENCE**](QUICK_REFERENCE.md) - Essential commands and functions
- [**ENHANCED FUNCTION MAP**](ENHANCED_FUNCTION_MAP.md) - Detailed function documentation  
- [**SYSTEM CONNECTIONS**](SYSTEM_CONNECTIONS.md) - How systems interact
- [**SCRIPT CATEGORIES**](SCRIPT_CATEGORIES.md) - Scripts organized by purpose
- [**CROSS REFERENCES**](CROSS_REFERENCES.md) - Function call relationships

## 📊 Project Statistics

- **Total Scripts:** 238
- **Total Functions:** 4,726
- **Core Systems:** 111 scripts with 2,882 functions
- **Autoload Systems:** 13 scripts with 366 functions
- **Interface Systems:** 19 scripts with 413 functions

## 🏗️ Architecture Overview

### Core Systems Foundation
The game is built on these central systems:

1. **Universal Being System** (`universal_being.gd`) - Entity transformation and manifestation
2. **Floodgate Controller** (`floodgate_controller.gd`) - Central operation queue and rate limiting  
3. **Console Manager** (`console_manager.gd`) - In-game command interface
4. **Asset Library** (`asset_library.gd`) - Centralized asset management

### Key Features
- **Physics-based Ragdoll System** with advanced walking mechanics
- **Universal Being Transformation** - entities can become anything
- **Floodgate Pattern** - prevents system overload through queued operations
- **Comprehensive Console** - 180+ commands for debugging and control
- **JSH Framework Integration** - advanced data processing capabilities

## 🎮 System Categories

- **Core Systems:** Main game logic and entity management
- **Core Systems - Autoload:** Global systems loaded at startup
- **Interface Systems:** UI, console, and user interaction
- **Ragdoll Systems:** Physics-based character movement
- **JSH Framework:** Advanced data processing and AI systems
- **Patches & Fixes:** System improvements and bug fixes
- **Debug & Testing:** Development and debugging tools

## 🔧 Development Workflow

1. **Core Systems** provide the foundation
2. **Floodgate Controller** manages all operations safely  
3. **Console Manager** provides debugging interface
4. **Asset Library** handles all resource loading
5. **Universal Being** system allows dynamic entity creation

## 📁 File Organization

```
scripts/
├── autoload/          # Global systems
├── core/              # Main game systems  
├── ui/                # User interface
├── ragdoll/           # Physics movement
├── ragdoll_v2/        # Advanced ragdoll
├── debug/             # Debug tools
├── test/              # Testing systems
├── patches/           # System fixes
├── jsh_framework/     # JSH systems
└── passive_mode/      # Background systems
```

## 🎯 Quick Commands

**Essential Console Commands:**
- `spawn ragdoll` - Create physics character
- `debug gizmos` - Toggle 3D handles  
- `universal create tree` - Manifest tree entity
- `floodgate status` - Check system load
- `list objects` - Show all scene objects

**Quick Access Functions:**
- Universal Being: `become(form)`, `manifest(type)`
- Floodgate: `queue_operation()`, `process_queue()`  
- Console: `execute_command()`, `toggle_console()`
- Assets: `load_asset()`, `get_asset_info()`

---

*This documentation system provides searchable, maintainable access to all 4,726 functions across 238 scripts.*

**Last Updated:** 2025-05-30

# 🌟 Universal Being Script Reference

*Complete guide to every script in the Universal Being system*

## 🔧 Core Universal Being Scripts

### Primary System Scripts

#### universal_entity.gd
- **Location**: `scripts/core/universal_entity/`
- **Purpose**: The heart of everything - base Universal Being class
- **Documentation**: [Universal Being Core Architecture](../architecture/universal_being/UNIVERSAL_BEING_CORE_ARCHITECTURE.md)
- **Key Functions**:
  ```gdscript
  become(form: String)              # Transform into any form
  connect_to(other: UniversalBeing) # Create connections
  manifest_interface(type: String) # Create UI interfaces
  remember(experience: Dictionary)  # Store memories
  ```
- **Connections**: Every other Universal Being inherits from this
- **Status**: ✅ Core implemented, interface manifestation needs Eden Records

#### universal_object_manager.gd  
- **Location**: `scripts/core/`
- **Purpose**: Creates and manages all Universal Beings
- **Documentation**: [Floodgate Perfect Understanding](../architecture/floodgate/FLOODGATE_PERFECT_UNDERSTANDING.md)
- **Key Functions**:
  ```gdscript
  create_object(type: String, properties: Dictionary)
  register_being(being: UniversalBeing) 
  get_all_beings() -> Array[UniversalBeing]
  track_transformation(from: String, to: String)
  ```
- **Connections**: Used by console commands, floodgate controller
- **Status**: ✅ Working - perfect tracking with UUIDs

#### floodgate_controller.gd
- **Location**: `scripts/core/`
- **Purpose**: Universal memory system - never forgets anything
- **Documentation**: [Floodgate Perfect Understanding](../architecture/floodgate/FLOODGATE_PERFECT_UNDERSTANDING.md)
- **Key Functions**:
  ```gdscript
  register_universal_being(being: UniversalBeing)
  track_transformation(being: UniversalBeing, old_form: String, new_form: String)
  get_being_history(uuid: String) -> Array
  manage_scene_tree_operations()
  ```
- **Connections**: Central hub - everything connects here
- **Status**: ✅ Perfect memory system operational

### Interface Manifestation Scripts

#### universal_entity_inspector.gd
- **Location**: `scripts/core/universal_entity/`
- **Purpose**: Click any Universal Being to inspect/edit properties
- **Documentation**: [Universal Being Interface Guide](../guides/features/UNIVERSAL_BEING_INTERFACE_GUIDE.md)
- **Current Issue**: Creates colored cubes instead of proper interfaces
- **Needs**: Eden Records integration for proper UI blueprints
- **Status**: 🔧 Works but needs proper interface manifestation

#### object_inspector.gd
- **Location**: `scripts/ui/`
- **Purpose**: Traditional 2D inspector UI
- **Documentation**: [Debug Systems Guide](../development/debugging/DEBUG_SYSTEMS_CONFLICT_RESOLUTION.md)
- **Connections**: Part of dual interface system (2D + 3D)
- **Status**: ✅ Working 2D version

### Console Integration Scripts

#### console_manager.gd
- **Location**: `scripts/autoload/`
- **Purpose**: Processes all console commands for Universal Being creation
- **Documentation**: [Command Master Reference](../guides/console/COMMAND_MASTER_REFERENCE.md)
- **Key Commands**:
  ```bash
  being interface <type>     # Create interface as Universal Being
  spawn_being <form>         # Create being in specific form
  transform_being <form>     # Change being's form
  connect_beings <a> <b>     # Connect two beings
  ```
- **Status**: ✅ Working, needs more Universal Being commands

## 🏛️ Eden Records Integration Scripts

### Blueprint System

#### records_bank.gd
- **Location**: `scripts/jsh_framework/core/`
- **Purpose**: Interface layout blueprints (menu, keyboard, creation tools)
- **Documentation**: [Eden Records Integration Guide](../architecture/eden_records/EDEN_RECORDS_INTEGRATION_GUIDE.md)
- **Contains**:
  - `records_map_2` - Menu interface layout
  - `records_map_4` - Keyboard interface layout  
  - `records_map_7` - Things creation interface
- **Status**: ✅ Complete blueprints available, needs integration

#### actions_bank.gd
- **Location**: `scripts/jsh_framework/core/`
- **Purpose**: 1700+ lines of interaction definitions
- **Documentation**: [Eden Records Integration Guide](../architecture/eden_records/EDEN_RECORDS_INTEGRATION_GUIDE.md)
- **Contains**: Button clicks, scene transitions, keyboard inputs
- **Status**: ✅ Complete interactions defined, needs wiring

#### system_interfaces.gd
- **Location**: `scripts/jsh_framework/core/`
- **Purpose**: Bridge between Eden Records and Universal Being interfaces
- **Current State**: Empty skeleton file
- **Needs**: Implementation of interface manifestation system
- **Status**: 🔴 Not implemented - critical missing piece

### Integration Bridge (Missing!)

#### interface_manifestation_system.gd
- **Location**: `scripts/core/` (needs to be created)
- **Purpose**: Convert Eden Records blueprints into 3D Universal Being interfaces
- **Key Functions** (to implement):
  ```gdscript
  manifest_interface_from_blueprint(blueprint: Dictionary) -> Node3D
  create_3d_ui_from_records(records: Dictionary) -> Control
  add_interface_soul(interface: Node3D) # Particles, glow, energy
  wire_interactions(interface: Node3D, actions: Dictionary)
  ```
- **Status**: 🔴 Missing - this is the key to fixing colored cubes!

## 🤖 Ragdoll Universal Being Scripts

### Current Active System

#### biomechanical_walker.gd
- **Location**: `scripts/ragdoll/`
- **Purpose**: Walking ragdoll that is also a Universal Being
- **Documentation**: [Ragdoll Revolution Complete](../progress/milestones/RAGDOLL_REVOLUTION_COMPLETE.md)
- **Universal Being Features**: Can transform, connect, remember walking experiences
- **Status**: ✅ Working seven-part physics system

#### unified_biomechanical_walker.gd
- **Location**: `scripts/ragdoll/`
- **Purpose**: Enhanced walking with Universal Being capabilities
- **Documentation**: [Ragdoll Movement Commands](../guides/gameplay/RAGDOLL_MOVEMENT_COMMANDS.md)
- **Status**: ✅ Advanced movement as Universal Being

## 🔧 Asset Library Scripts

#### standardized_objects.gd
- **Location**: `scripts/core/`
- **Purpose**: Form templates for Universal Being manifestation
- **Documentation**: [Asset Library System](../architecture/asset_library/ASSET_LIBRARY_TXT_TSCN_SYSTEM.md)
- **Contains**: Tree, box, rock, ball templates with colors and materials
- **Status**: ✅ Working - provides beautiful colored objects

## 🧪 Testing Universal Being Scripts

#### universal_being_test.gd
- **Location**: `scripts/test/`
- **Purpose**: Test Universal Being transformation and connection
- **Documentation**: [Fixed Systems Test](../development/testing/FIXED_SYSTEMS_TEST.md)
- **Test Cases**: Form changes, connections, memory, interface creation
- **Status**: ✅ Testing framework ready

## 🚨 Critical Missing Pieces

### 1. Interface Manifestation Bridge
**File**: `interface_manifestation_system.gd` (needs creation)
**Purpose**: Convert Eden Records to 3D interfaces
**Urgency**: 🔥 High - fixes colored cube issue

### 2. Eden Records Integration
**File**: Enhanced `system_interfaces.gd`
**Purpose**: Load and parse Eden Records blueprints
**Urgency**: 🔥 High - enables proper interfaces

### 3. Dual Interface Controllers
**Files**: `asset_creator_core.gd`, `console_core.gd`, etc.
**Purpose**: Shared logic for 2D and 3D interfaces
**Urgency**: 🟡 Medium - architecture improvement

## 🎯 Next Development Priorities

1. **Create `interface_manifestation_system.gd`** - Fix the colored cubes!
2. **Implement `system_interfaces.gd`** - Load Eden Records blueprints
3. **Add soul effects** - Particles, glow, energy for interfaces
4. **Test transformation** - Universal Beings changing forms
5. **Build connections** - Visual energy lines between beings

---

*"Every script is a potential Universal Being waiting to manifest"*
# System Connection Scheme - Talking Ragdoll Game
*Updated: May 25, 2025 - Ragdoll Physics Mastery Complete*

## 🗺️ Current System Map

```
┌──────────────────────────────────────────────────────────────────┐
│                         MAIN GAME CONTROLLER                      │
│  Entry Point: _ready() → _setup_systems() → _connect_signals()   │
└────────┬──────────┬──────────┬──────────┬──────────┬───────────┘
         │          │          │          │          │
    ┌────▼────┐ ┌──▼───┐ ┌───▼────┐ ┌──▼───┐ ┌────▼────┐
    │Floodgate│ │Console│ │ World  │ │ JSH  │ │ Ragdoll │
    │Controller│ │Manager│ │Builder │ │Bridge│ │ System  │
    └────┬────┘ └──┬───┘ └───┬────┘ └──┬───┘ └────┬────┘
         │         │         │         │          │
         └─────────┴─────────┴─────────┴──────────┘
                      SIGNAL BUS

LEGEND: ━━━ Strong Connection  ┅┅┅ Weak Connection  ░░░ Missing Link
```

## 🔄 Data Flow Analysis

### Command Execution Flow
```
User Input → Console Manager → Command Parser → Command Executor
                                      ↓
                              Command Registry
                                      ↓
                         ┌────────────┴────────────┐
                         │                         │
                  Physics Commands          Object Commands
                         │                         │
                  Ragdoll Controller        World Builder
                         │                         │
                  ┌──────┴──────┐          ┌──────┴──────┐
                  │ Update State │          │ Spawn Object│
                  └──────┬──────┘          └──────┬──────┘
                         │                         │
                      Floodgate ←──────────────────┘
                      Controller
```

## 🏗️ Class Hierarchy & Usage

### Ragdoll System Classes
```
RigidBody3D (Godot Built-in)
    ↓
TalkingRagdoll (Our Implementation)
    ├── Properties Used:
    │   • mass (currently 1.0)
    │   • gravity_scale (0.1 - too low?)
    │   • linear_damp (2.0)
    │   • angular_damp (5.0)
    │
    ├── Missing Features:
    │   • freeze_rotation constraints
    │   • proper center_of_mass
    │   • continuous_cd for stability
    │
    └── Child Components:
        ├── SevenPartRagdollIntegration
        │   └── Uses: Generic6DOFJoint3D
        ├── SimpleRagdollWalker
        │   └── Uses: Direct force application
        └── RagdollController
            └── Uses: Animation states
```

### Console System Classes
```
Control (Godot Built-in)
    ↓
PanelContainer
    ├── Properties Used:
    │   • self_modulate (transparency)
    │   • custom_minimum_size
    │   • theme_override_styles
    │
    └── Child Hierarchy:
        CenterContainer
            └── VBoxContainer
                ├── LineEdit (input)
                └── ScrollContainer
                    └── RichTextLabel (output)
```

## 🔍 Problem Areas Identified

### 1. Physics Synchronization Issue
```
Current Flow (BROKEN):
set_gravity(0.5) → Project Settings Changed → ❌ Ragdoll Not Updated

Fixed Flow (TODO):
set_gravity(0.5) → PhysicsStateManager → Signal: physics_changed
                                     ↓
                            All Physics Bodies Updated
```

### 2. Object Registration Gap
```
Current Flow (INCOMPLETE):
spawn_object() → Create Node → Add to Scene → ❌ Not in Registry

Fixed Flow (TODO):
spawn_object() → ObjectFactory → Create Node → Register in ObjectRegistry
                                           ↓
                                    Add to Scene → Update List Cache
```

### 3. JSH Framework Bridge
```
Current State:
JSH Commands → ░░░ Missing Translation ░░░ → Godot Actions

Target State:
JSH Commands → Command Translator → Validated Godot Calls
                      ↓
              Event Synchronizer → Update JSH State
```

## 📊 Performance Bottlenecks

### Current Issues:
1. **get_tree().get_nodes_in_group()** - Called every frame in some systems
2. **String parsing** - No command caching
3. **Physics bodies** - No LOD or culling system
4. **Signal connections** - Some circular dependencies

### Optimization Plan:
```gdscript
# Before (in _process):
for node in get_tree().get_nodes_in_group("updateable"):
    node.update()

# After (event-driven):
signal update_required
var update_cache: Array[Node] = []

func request_update(node: Node):
    if node not in update_cache:
        update_cache.append(node)
    
func _physics_process(_delta):
    for node in update_cache:
        node.update()
    update_cache.clear()
```

## 🎯 Integration Points

### Key Connection Points:
1. **Main Game Controller** → All Systems (via signals)
2. **Console Manager** → Command Executors (via registry)
3. **Floodgate Controller** → Performance Monitoring (via counters)
4. **World Builder** → Object Management (via groups)
5. **Ragdoll System** → Physics State (currently broken)

### Missing Connections:
- JSH Framework ░░░ Scene Tree Updates
- Physics State ░░░ Ragdoll Properties
- Object Registry ░░░ List Command
- Astral Beings ░░░ Any System

## 🛠️ Recommended Refactoring

### Phase 1: Core Systems
```
1. Create PhysicsStateManager singleton
2. Implement ObjectRegistry with caching
3. Build CommandTranslator for JSH
4. Consolidate ragdoll implementations
```

### Phase 2: Connections
```
1. Wire PhysicsStateManager to all physics bodies
2. Connect ObjectRegistry to spawn/destroy flows
3. Bridge JSH commands to Godot actions
4. Implement proper state machines
```

### Phase 3: Optimization
```
1. Add object pooling
2. Implement command caching
3. Create LOD system
4. Profile and optimize hot paths
```

---

*This scheme represents the current state as of 2025-05-25*
*Red areas indicate critical fixes needed*
*Green areas indicate working systems*
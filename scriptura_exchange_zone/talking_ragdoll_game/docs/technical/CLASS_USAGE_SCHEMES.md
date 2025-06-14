# Class Usage Schemes - Visual Architecture

## 🏗️ Current Architecture

```
Scene Tree Structure:
/root
├── Autoloads
│   ├── FloodgateController (Node)
│   ├── AssetLibrary (Node)
│   ├── WorldBuilder (Node)
│   ├── ConsoleManager (Node)
│   ├── DialogueSystem (Node)
│   └── UISettingsManager (Node)
│
└── MainGame (Node3D)
    ├── Camera3D
    ├── DirectionalLight3D
    ├── Ground (StaticBody3D)
    │   ├── CollisionShape3D
    │   └── MeshInstance3D
    │
    ├── SpawnedObjects (Node3D)
    │   ├── Tree_1 (RigidBody3D)
    │   ├── Rock_1 (RigidBody3D)
    │   └── Ball_1 (RigidBody3D)
    │
    └── UI (CanvasLayer)
        └── Console (Control)
            └── CenterContainer
                └── PanelContainer
```

## 🔄 Class Interaction Flows

### Object Creation Flow
```
User Input → ConsoleManager
    ↓
Command Parser → "tree"
    ↓
FloodgateController.request_magic()
    ↓ [Queued]
WorldBuilder.spawn_tree()
    ↓
Create Nodes:
├── RigidBody3D.new()
├── CollisionShape3D.new()
├── MeshInstance3D.new()
└── Add to scene tree
```

### Physics Interaction
```
RigidBody3D (Tree)
    ↓ [Gravity]
CollisionShape3D detects ground
    ↓
PhysicsServer3D calculates
    ↓
Transform3D updates position
    ↓
MeshInstance3D renders at new position
```

### UI Event Flow
```
Input.is_action_pressed("toggle_console")
    ↓
ConsoleManager._input()
    ↓
Control.visible = !visible
    ↓
CenterContainer auto-centers
    ↓
PanelContainer draws background
    ↓
LineEdit captures input
```

## 📊 Class Dependency Graph

```
                    Node (Base)
                      ↓
        ┌─────────────┴─────────────┐
        │                           │
     Node3D                     Control
        │                           │
   ┌────┴────┐                ┌────┴────┐
   │         │                │         │
RigidBody3D  StaticBody3D  Container  Button
   │         │                │         
   └─────┬───┘                └───┬─────┘
         │                        │
  CollisionShape3D         CenterContainer
         │                        │
  MeshInstance3D           PanelContainer
```

## 🎮 Ragdoll Class Hierarchy

```
CharacterBody3D (seven_part_ragdoll)
    │
    ├── RigidBody3D (pelvis)
    │   ├── CollisionShape3D (BoxShape3D)
    │   └── MeshInstance3D (BoxMesh)
    │
    ├── RigidBody3D (left_thigh)
    │   ├── CollisionShape3D (CapsuleShape3D)
    │   ├── MeshInstance3D (CapsuleMesh)
    │   └── HingeJoint3D → left_shin
    │
    └── RigidBody3D (right_thigh)
        ├── CollisionShape3D (CapsuleShape3D)
        ├── MeshInstance3D (CapsuleMesh)
        └── HingeJoint3D → right_shin
```

## 🌊 Floodgate Pattern Classes

```
Trigger Classes:
├── Timer (periodic events)
├── Area3D (proximity triggers)
├── Signal (event propagation)
└── AnimationPlayer (timed sequences)

Flow Control:
├── Node (queue management)
├── Mutex (thread safety)
├── Thread (async processing)
└── Callable (deferred execution)

Output Classes:
├── RigidBody3D (spawned objects)
├── GPUParticles3D (effects)
├── AudioStreamPlayer3D (sounds)
└── Label3D (floating text)
```

## 💾 Resource Usage Pattern

```
Loaded Once (Preloaded):
├── PackedScene (prefabs)
├── StandardMaterial3D (materials)
├── Mesh resources (shapes)
└── AnimationLibrary (animations)

Created Dynamically:
├── RigidBody3D instances
├── CollisionShape3D instances
├── Timer instances
└── Tween instances

Should Be Pooled:
├── RigidBody3D (objects)
├── Label3D (speech bubbles)
├── GPUParticles3D (effects)
└── Timer (delays)
```

## 🔧 Improvement Schemes

### Current: Direct Creation
```gdscript
func spawn_tree():
    var tree = RigidBody3D.new()
    var collision = CollisionShape3D.new()
    var mesh = MeshInstance3D.new()
    # Configure each...
```

### Better: Prefab System
```gdscript
@export var tree_prefab: PackedScene

func spawn_tree():
    var tree = tree_prefab.instantiate()
    add_child(tree)
```

### Best: Object Pool
```gdscript
class_name ObjectPool

var tree_pool: Array[RigidBody3D] = []

func get_tree() -> RigidBody3D:
    if tree_pool.is_empty():
        return create_tree()
    return tree_pool.pop_back()
```

## 🎯 Class Usage Optimization

### Memory Optimization
```
Current Usage:          Optimized Usage:
new() every spawn  →    Object pooling
Individual materials →  Shared materials
Unique meshes      →    Mesh library
Many timers        →    Timer manager
```

### Performance Optimization
```
Current:                Better:
All objects active  →   Visibility culling
Full physics       →    Physics LOD
Individual meshes  →    MultiMeshInstance3D
Every frame update →    Event-driven updates
```

## 📈 Metrics to Track

1. **Instance Counts**
   - RigidBody3D active: ___
   - Timers active: ___
   - Particles systems: ___

2. **Performance Impact**
   - Physics bodies: ms
   - Rendering: ms
   - Scripts: ms

3. **Memory Usage**
   - Nodes: MB
   - Resources: MB
   - Textures: MB

This visual scheme shows how classes interconnect and where improvements can be made!
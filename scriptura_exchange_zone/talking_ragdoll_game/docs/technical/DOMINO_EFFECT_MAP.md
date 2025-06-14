# Domino Effect Map - How Everything Connects

## 🌊 The Floodgate Pattern
*"functions can trigger global variables which turns on floodgates"*

### Core Domino Chains

#### 1. Object Creation Chain
```
User types "tree" in console
    ↓
ConsoleManager._cmd_create_object(["tree"])
    ↓
FloodgateController.request_magic("create_tree")
    ↓ [Floodgate Opens]
Second dimensional magic queued
    ↓
WorldBuilder.spawn_tree() 
    ↓
Tree created at mouse position
    ↓
WorldBuilder.spawned_objects.append(tree)
    ↓
JSH Scene Tree updated
    ↓
[TRACK] message logged
```

#### 2. World Generation Chain
```
User types "world"
    ↓
ConsoleManager._cmd_generate_world()
    ↓
UnifiedSceneManager created/found
    ↓
scene_manager.generate_procedural_world()
    ↓
HeightmapWorldGenerator.generate_world()
    ↓ [Multiple Floodgates]
Creates: terrain mesh → water plane → trees → bushes
    ↓
Each tree/bush calls WorldBuilder.register_world_object()
    ↓
All objects tracked in spawned_objects
    ↓
"list" command can see everything
```

#### 3. Ragdoll Command Chain (Fixed)
```
User types "ragdoll_come"
    ↓
ConsoleManager._cmd_ragdoll_come()
    ↓
Finds RagdollController in scene
    ↓
RagdollController.cmd_ragdoll_come()
    ↓
Checks for 7-part ragdoll body
    ↓
SevenPartRagdoll.come_to_position(camera_pos)
    ↓ [Movement Floodgate]
Sets is_walking = true
    ↓
_physics_process moves ragdoll
    ↓
Emits ragdoll_state_changed signal
    ↓
FloodgateController receives state update
```

#### 4. Physics State Chain (Broken - Needs Fix)
```
User types "gravity 1"
    ↓
ConsoleManager._cmd_set_gravity([1])
    ↓
PhysicsServer3D.area_set_param(GRAVITY, 1.0)
    ↓ [Missing Connection!]
Physics changes but status not updated
    ↓
User types "physics"
    ↓
Shows old gravity value (9.8)
```

### 🔑 Key Floodgate Triggers

#### Global Variables That Open Floodgates:
```gdscript
# In FloodgateController
var spawn_enabled = true          # Opens object creation
var world_generation_active = false  # Opens terrain generation
var ragdoll_active = false        # Opens ragdoll behaviors

# In WorldBuilder  
var use_override_position = false # Changes spawn location
var spawn_height = 0.0           # Controls object height

# In RagdollController
var behavior_state = IDLE        # Triggers different AI patterns
var is_moving_to_target = false  # Opens movement system
```

#### Signal Floodgates:
```gdscript
# These signals trigger cascading effects
signal object_created(obj)       # → Updates UI, tracks object
signal ragdoll_state_changed()   # → Updates animations, AI
signal world_cleared()           # → Resets all systems
signal scene_changed()           # → Loads new assets
```

### 🎯 Cause & Effect Examples

#### Example 1: "Why does the ragdoll glitch underground?"
```
CAUSE: gravity set to 9.8 (default)
    ↓
EFFECT: Ragdoll RigidBody3D pulled down
    ↓
CAUSE: No collision check with terrain mesh
    ↓
EFFECT: Falls through heightmap
    ↓
SOLUTION: Set gravity to 1 → legs become visible
```

#### Example 2: "Why doesn't clear remove terrain?"
```
CAUSE: "clear" only checks spawned_objects array
    ↓
EFFECT: Terrain created by HeightmapWorldGenerator not tracked
    ↓
CAUSE: Terrain stored in different container
    ↓  
EFFECT: Remains after clear
    ↓
SOLUTION: Need "clear all" to remove terrain_container
```

#### Example 3: "Why do multiple worlds stack?"
```
CAUSE: No check for existing world
    ↓
EFFECT: New HeightmapWorldGenerator created
    ↓
CAUSE: Added to same parent node
    ↓
EFFECT: Terrains overlap at same position
    ↓
SOLUTION: Clear existing world before generating
```

### 🔄 Bidirectional Connections

#### Godot ↔ JSH Framework
```
Godot creates node
    → JSH tree notified via signal
    → JSH adds to scene_tree_jsh
    
JSH executes command
    → Creates Godot nodes
    → Godot scene tree updated
```

#### FloodgateController ↔ WorldBuilder
```
Floodgate queues creation
    → WorldBuilder spawns object
    → WorldBuilder notifies Floodgate
    
WorldBuilder needs deletion
    → Requests through Floodgate
    → Floodgate safely removes
```

### 📊 System Dependencies

```
ConsoleManager
    ├── FloodgateController (object creation)
    ├── WorldBuilder (spawn/delete)
    ├── DialogueSystem (speech)
    ├── UISettingsManager (console position)
    ├── SceneLoader (scene management)
    └── RagdollController (ragdoll commands)

FloodgateController
    ├── WorldBuilder (executes spawning)
    ├── AssetLibrary (gets object templates)
    └── JSH Framework (updates tree)

RagdollController
    ├── SevenPartRagdoll (actual ragdoll)
    ├── FloodgateController (state updates)
    └── Camera3D (for "come" position)
```

### 🚨 Breaking the Chain

Common breaks in the domino chain:
1. **Missing autoload** → System not found
2. **Wrong node path** → Can't find controller  
3. **No signal connection** → State doesn't propagate
4. **Array not updated** → List doesn't show object
5. **Different containers** → Clear misses objects

### 💡 Your Key Insight
*"we need more files that simulate the program its paths, to always know what route to take"*

This map shows exactly those paths - every command has a traceable route through the system, and we can follow the domino effects to understand why things happen or don't happen!
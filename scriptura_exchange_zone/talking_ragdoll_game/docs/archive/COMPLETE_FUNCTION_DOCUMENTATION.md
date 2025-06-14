# Complete Function Documentation - Talking Ragdoll Game
*Created: 2025-05-25*
*Purpose: Track every function, its connections, and test status*

## 🎮 Console Commands Overview

### ✅ Tested & Working Commands

#### **tree** 
- **Function**: `_cmd_create_object(["tree"])` in `console_manager.gd`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_tree()
- **Creates**: Tree with fruits at mouse position
- **Status**: ✅ Working
```gdscript
# console_manager.gd:655
func _cmd_create_object(args: Array) -> void:
    var object_type = args[0].to_lower()
    FloodgateController.request_magic("create_" + object_type)
```

#### **rock**
- **Function**: `_cmd_create_object(["rock"])` 
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_rock()
- **Creates**: Rock at mouse position
- **Status**: ✅ Working

#### **box**
- **Function**: `_cmd_create_object(["box"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_box()
- **Creates**: Box with physics at mouse position
- **Status**: ✅ Working

#### **ball**
- **Function**: `_cmd_create_object(["ball"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_ball()
- **Creates**: Ball with physics at mouse position
- **Status**: ✅ Working

#### **ramp**
- **Function**: `_cmd_create_object(["ramp"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_ramp()
- **Creates**: Ramp (currently falls - needs triangular mesh)
- **Status**: ⚠️ Working but needs model fix
- **Todo**: Change from flat plane to triangular geometry

#### **sun**
- **Function**: `_cmd_create_object(["sun"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_sun()
- **Creates**: Light source (too high, casts shadows)
- **Status**: ⚠️ Working but needs improvement
- **Todo**: Make 2D shader effect instead of 3D sphere

#### **astral/astral_being**
- **Function**: `_cmd_create_object(["astral_being"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_astral_being()
- **Creates**: Flying astral being that moves around
- **Status**: ✅ Working

#### **pathway/path**
- **Function**: `_cmd_create_object(["pathway"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_pathway()
- **Creates**: Pathway object
- **Status**: ✅ Working (both aliases work)

#### **bush**
- **Function**: `_cmd_create_object(["bush"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_bush()
- **Creates**: Bush with fruits
- **Status**: ✅ Working

#### **fruit**
- **Function**: `_cmd_create_object(["fruit"])`
- **Flow**: Console → FloodgateController → WorldBuilder → spawn_fruit()
- **Creates**: Fruit object
- **Status**: ✅ Working

#### **list**
- **Function**: `_cmd_list_objects()`
- **Flow**: Console → WorldBuilder.get_spawned_objects()
- **Shows**: All spawned objects with positions
- **Status**: ✅ Fixed - now shows world-generated objects
```gdscript
# world_builder.gd:340
func register_world_object(obj: Node3D) -> void:
    if obj and is_instance_valid(obj):
        spawned_objects.append(obj)
```

#### **delete <id>**
- **Function**: `_cmd_delete_object([object_name])`
- **Flow**: Console → FloodgateController → WorldBuilder.delete_object()
- **Removes**: Specific object by name/id
- **Status**: ✅ Working

#### **clear**
- **Function**: `_cmd_clear_objects()`
- **Flow**: Console → FloodgateController → clear all objects
- **Note**: Doesn't clear ragdoll or terrain
- **Status**: ⚠️ Partial - needs floodgate connection update
- **Todo**: Connect "world" objects to clear command

#### **gravity <value>**
- **Function**: `_cmd_set_gravity([value])`
- **Flow**: Console → PhysicsServer3D.area_set_param()
- **Changes**: Global gravity (default 9.8)
- **Status**: ⚠️ Works but physics status doesn't update
- **Your Test**: Set to 1, ragdoll legs became visible

#### **physics**
- **Function**: `_cmd_physics_state()`
- **Shows**: Gravity, object counts by state
- **Status**: ⚠️ Shows old gravity value
- **Todo**: Sync with actual PhysicsServer state

#### **say <text>**
- **Function**: `_cmd_make_ragdoll_say([text])`
- **Flow**: Console → DialogueSystem → show text above ragdoll
- **Status**: ⚠️ Works but ragdoll too far to see text

#### **console <position>**
- **Function**: `_cmd_set_console_position([position])`
- **Options**: center, top, bottom, left, right
- **Status**: ✅ Working - remembers position
```gdscript
# ui_settings_manager.gd
func set_console_position(position: String) -> void:
    console_position = position
    _apply_position_to_console()
```

#### **scale <value>**
- **Function**: `_cmd_set_ui_scale([scale])`
- **Range**: 0.5 to 2.0
- **Status**: ✅ Working

#### **scene list**
- **Function**: `_cmd_list_scenes()`
- **Shows**: default, forest, physics_test, playground
- **Status**: ✅ Working

#### **load <scene>**
- **Function**: `_cmd_load_scene([scene_name])`
- **Flow**: Console → SceneLoader → UnifiedSceneManager
- **Status**: ⚠️ Works but ground plane issues
- **Todo**: Normalize ground plane handling

#### **save [name]**
- **Function**: `_cmd_save_scene([name])`
- **Saves**: Current scene state
- **Status**: ✅ Working

#### **walk**
- **Function**: `_cmd_toggle_walk()`
- **Status**: ❌ Needs new ragdoll connection

#### **spawn_ragdoll**
- **Function**: `_cmd_spawn_ragdoll()`
- **Flow**: Console → FloodgateController → spawn ragdoll
- **Status**: ⚠️ Spawns but glitches under ground
- **Todo**: Connect 7-part ragdoll system

#### **world**
- **Function**: `_cmd_generate_world()`
- **Flow**: Console → UnifiedSceneManager → HeightmapWorldGenerator
- **Creates**: Terrain, trees, bushes, water
- **Status**: ✅ Working
- **Note**: Can stack multiple worlds
```gdscript
# heightmap_world_generator.gd:278
# Now registers objects with WorldBuilder
world_builder.register_world_object(tree)
```

#### **bird**
- **Function**: `_cmd_spawn_bird()`
- **Flow**: Console → WorldBuilder → create triangular bird
- **Status**: ✅ Working

### ❌ Not Working Commands (Need Connection)

#### **ragdoll_come**
- **Function**: `_cmd_ragdoll_come()`
- **Expected**: Ragdoll walks to player position
- **Status**: ❌ "Ragdoll controller not found"
- **Fix Applied**: Connected to 7-part ragdoll
```gdscript
# ragdoll_controller.gd:300
func cmd_ragdoll_come() -> void:
    if ragdoll_body and ragdoll_body.has_method("come_to_position"):
        var camera = get_viewport().get_camera_3d()
        ragdoll_body.come_to_position(target_pos)
```

#### **ragdoll_pickup**
- **Function**: `_cmd_ragdoll_pickup()`
- **Expected**: Pick up nearest object
- **Status**: ❌ "Ragdoll controller not found"
- **Fix Applied**: Connected to 7-part ragdoll

#### **ragdoll_drop**
- **Function**: `_cmd_ragdoll_drop()`
- **Expected**: Drop held object
- **Status**: ❌ "Ragdoll controller not found"
- **Fix Applied**: Connected to 7-part ragdoll

#### **ragdoll_organize**
- **Function**: `_cmd_ragdoll_organize()`
- **Expected**: Organize nearby objects
- **Status**: ❌ "Ragdoll controller not found"
- **Fix Applied**: Connected to 7-part ragdoll

#### **ragdoll_patrol**
- **Function**: `_cmd_ragdoll_patrol()`
- **Expected**: Start patrol route
- **Status**: ❌ "Ragdoll controller not found"
- **Fix Applied**: Connected to 7-part ragdoll

#### **beings_status**
- **Function**: `_cmd_beings_status()`
- **Status**: ❌ "Astral beings system not found"
- **Todo**: Create astral beings manager

#### **beings_help**
- **Function**: `_cmd_beings_help()`
- **Status**: ❌ "Astral beings system not found"

#### **beings_organize**
- **Function**: `_cmd_beings_organize()`
- **Status**: ❌ "Astral beings system not found"

#### **beings_harmony**
- **Function**: `_cmd_beings_harmony()`
- **Status**: ❌ "Astral beings system not found"

### ✅ System Commands

#### **setup_systems**
- **Function**: `_cmd_setup_systems()`
- **Flow**: Creates RagdollController and MouseInteractionSystem
- **Status**: ⚠️ Partially working - floodgate connection error
- **Error Found**: Invalid access to '_on_ragdoll_state_changed' in floodgate
- **Fix Applied**: Removed invalid signal connections
- **Ragdoll Issue**: Spawns as stacked capsules instead of bipedal
- **Fix Applied**: Added proper body hierarchy and joint system
```gdscript
# main_game_controller.gd:90
func setup_all_systems() -> void:
    _setup_ragdoll_system()
    _setup_mouse_interaction_system()
```

#### **system_status**
- **Function**: `_cmd_system_status()`
- **Shows**: All autoload systems status
- **Status**: ✅ Working
- **Note**: MainGameController shows "Initializing"

### 🔧 Debug Commands

#### **debug [off]**
- **Function**: `_cmd_toggle_debug([off])`
- **Creates**: 3D debug screen at 0,0,0
- **Status**: ✅ Working
- **Todo**: Position at camera view

#### **select <name|id>**
- **Function**: `_cmd_select_object([name])`
- **Selects**: Object for manipulation
- **Status**: ✅ Working

#### **move <x> <y> <z>**
- **Function**: `_cmd_move_object([x, y, z])`
- **Moves**: Selected object to position
- **Status**: ✅ Working

#### **rotate <x> <y> <z>**
- **Function**: `_cmd_rotate_object([x, y, z])`
- **Rotates**: Selected object (degrees)
- **Status**: ✅ Working

#### **scale_obj <scale>**
- **Function**: `_cmd_scale_object([scale])`
- **Scales**: Selected object
- **Status**: ✅ Working

### 🌟 Advanced Commands

#### **awaken <name|id>**
- **Function**: `_cmd_awaken_object([name])`
- **Changes**: Object to start moving
- **Status**: ⚠️ Command works but no visible movement
- **Todo**: Add movement behaviors

#### **state <name|id> <state>**
- **Function**: `_cmd_change_state([name, state])`
- **States**: static, awakening, kinematic, dynamic, ethereal, light_being
- **Status**: ✅ Working

### ⏱️ Timer & Task Commands

#### **timer**
- **Function**: `_cmd_show_timer()`
- **Shows**: Session time, tasks, wait time
- **Status**: ✅ Working

#### **todos**
- **Function**: `_cmd_show_todos()`
- **Shows**: All project todos with priorities
- **Status**: ✅ Working

## 🔄 System Architecture

### Floodgate Pattern
```
User Command → Console Manager → Floodgate Controller → World Builder → Object Creation
                                         ↓
                              Queue System (prevent overflow)
                                         ↓
                              Track in spawned_objects array
                                         ↓
                              Update JSH Scene Tree
```

### Object Lifecycle
1. **Creation**: Through floodgate queue
2. **Tracking**: Added to spawned_objects array
3. **State**: Managed by physics state system
4. **Deletion**: Through floodgate for safety

### Key Connections
- **Console** → **FloodgateController**: All object creation
- **WorldBuilder** → **AssetLibrary**: Object templates
- **RagdollController** → **SevenPartRagdoll**: Movement and actions
- **DialogueSystem** → **UI Layer**: Speech bubbles
- **JSH Framework** → **Main Controller**: Scene tree sync

## 📝 Your Testing Notes

### Issues Found
1. **Ramp falls** - needs triangular mesh
2. **Sun too high** - needs 2D shader approach
3. **Ragdoll glitches** - under ground plane
4. **Clear doesn't clear terrain** - needs connection
5. **Physics status outdated** - needs sync
6. **World stacking** - multiple worlds can overlap
7. **Floodgate connection error** - Fixed: removed invalid signal connections
8. **Ragdoll structure** - Fixed: was stacked capsules, now proper bipedal

### New Discoveries
1. **CenterContainer** - Perfect for auto-centering console
2. **Ragdoll visibility** - Spawns as arranged leg pieces
3. **Console transparency** - Need to see game behind console

### Working Well
1. **Object spawning** - all basic objects work
2. **Console positioning** - remembers settings
3. **Floodgate system** - prevents crashes
4. **Selection system** - can manipulate objects
5. **Timer system** - tracks everything

## 🚀 Next Updates
When you test the new fixes, we'll update:
1. Ragdoll command status (should work now)
2. List command with world objects (should work now)
3. Any new behaviors discovered
4. Performance observations
5. New connection patterns found
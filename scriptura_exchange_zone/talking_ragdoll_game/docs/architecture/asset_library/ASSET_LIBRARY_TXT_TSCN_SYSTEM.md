# Asset Library TXT + TSCN System Design
*Created: May 28, 2025*

## 🎯 Vision: TXT Description + TSCN Arrangement = Universal Being

**Core Concept:** Every asset is defined by:
1. **TXT file** - Properties, behaviors, metadata
2. **TSCN file** - Visual arrangement, components, structure
3. **Universal Being** - Runtime entity that combines both

## 📁 Folder Structure

```
assets/
├── definitions/              # TXT files with properties
│   ├── objects/
│   │   ├── tree.txt
│   │   ├── rock.txt
│   │   ├── ragdoll.txt
│   │   └── magical_fountain.txt
│   ├── interfaces/
│   │   ├── console.txt
│   │   ├── grid_viewer.txt
│   │   └── property_editor.txt
│   └── creatures/
│       ├── astral_being.txt
│       └── dream_guardian.txt
├── arrangements/             # TSCN files with structure
│   ├── objects/
│   │   ├── tree.tscn
│   │   ├── rock.tscn
│   │   └── ragdoll.tscn
│   ├── interfaces/
│   │   ├── console.tscn
│   │   └── grid_viewer.tscn
│   └── creatures/
│       └── astral_being.tscn
├── variants/                 # Different versions
│   ├── tree_summer.tscn
│   ├── tree_autumn.tscn
│   ├── tree_winter.tscn
│   └── tree_ancient.tscn
└── materials/               # Shared materials
    ├── wood.tres
    ├── stone.tres
    └── magical_glow.tres
```

## 📄 TXT Definition Format

### **Example: tree.txt**
```ini
# Universal Being Definition - Tree
# Describes properties, behaviors, and metadata

[IDENTITY]
name = Ancient Oak
type = nature
category = vegetation
description = A wise old tree that has seen many seasons

[PROPERTIES]
health = 500
max_health = 500
durability = 0.9
mass = 150.0
scale = 1.0
destructible = true

[PHYSICS]
body_type = static
collision_layer = 1
collision_mask = 1
gravity_scale = 1.0

[BEHAVIORS]
can_talk = true
speech_frequency = 0.1
seasonal_change = true
drop_on_death = wood,seeds
regrowth_time = 60.0

[VISUAL]
base_color = #4A5D3A
accent_color = #2E7D32
glow_enabled = false
particle_effect = leaves_falling
animation_speed = 0.5

[INTERACTIONS]
clickable = true
inspectable = true
harvestable = true
climbable = false

[CONNECTIONS]
attracts = birds,squirrels
repels = fire_spirits
connects_to = other_trees,earth_spirits

[SPAWNING]
spawn_height = 0.0
ground_snap = true
spawn_sound = rustle
spawn_effect = nature_bloom

[ADVANCEMENT]
can_evolve = true
evolution_stages = sapling,young_tree,mature_tree,ancient_tree,world_tree
evolution_requirements = time=300,water=100,sunlight=200

[ABILITIES]
sway_in_wind = true
drop_seeds = true
provide_shade = true
purify_air = true
store_memories = true

[METADATA]
created_by = universal_system
version = 1.2
tags = nature,static,interactive,wise
rarity = common
```

### **Example: console.txt (Interface)**
```ini
# Universal Being Definition - Console Interface
# 3D console that exists in world space

[IDENTITY]
name = Universal Console
type = interface
category = ui_system
description = Floating console interface for world interaction

[PROPERTIES]
health = 9999
invulnerable = true
mass = 0.0
scale = 1.0

[PHYSICS]
body_type = kinematic
collision_layer = 8
floating = true
billboard = true

[BEHAVIORS]
auto_follow_player = false
auto_hide_timer = 30.0
command_history_size = 100
max_output_lines = 500

[VISUAL]
base_color = #1E1E1E
accent_color = #00FF41
transparency = 0.1
glow_enabled = true
holographic = true

[UI_PROPERTIES]
width = 800
height = 600
font_size = 14
cursor_blink_rate = 1.0
auto_complete = true

[INTERACTIONS]
clickable = true
keyboard_input = true
voice_input = false
gesture_input = true

[POSITIONING]
default_distance = 2.0
height_offset = 1.5
follow_smooth = 0.8
lock_to_camera = false

[COMMANDS]
builtin_commands = help,clear,exit,history
command_prefix = /
case_sensitive = false
autocomplete_enabled = true

[METADATA]
created_by = universal_system
version = 2.0
tags = interface,console,interactive,essential
rarity = unique
```

### **Example: ragdoll.txt (Creature)**
```ini
# Universal Being Definition - Ragdoll Character
# Physics-based character with AI

[IDENTITY]
name = Talking Ragdoll
type = creature
category = character
description = A physics ragdoll that loves to talk and explore

[PROPERTIES]
health = 100
max_health = 100
energy = 100
max_energy = 100
mass = 70.0
scale = 1.0

[PHYSICS]
body_type = rigid
joints_enabled = true
joint_strength = 1.0
balance_factor = 0.8
stability_threshold = 0.3

[BEHAVIORS]
can_talk = true
speech_frequency = 0.3
auto_balance = true
curiosity_level = 0.8
social_level = 0.9

[MOVEMENT]
walk_speed = 3.0
run_speed = 6.0
jump_force = 500.0
turn_speed = 2.0
can_climb = false

[AI]
ai_type = friendly
patrol_radius = 10.0
follow_player = true
conversation_topics = life,physics,dreams,existence
personality = cheerful,curious,philosophical

[VISUAL]
base_color = #8B4513
accent_color = #4169E1
glow_enabled = false
ragdoll_parts = head,torso,arms,legs
material_type = cloth

[INTERACTIONS]
clickable = true
draggable = true
throwable = true
responds_to_speech = true

[JOINTS]
head_to_neck = pin
torso_to_pelvis = hinge
arms_to_shoulders = ball
legs_to_hips = ball

[METADATA]
created_by = universal_system
version = 3.1
tags = character,physics,interactive,talkative
rarity = common
```

## 🔧 Enhanced Asset Library Implementation

### **TXT Parser System**
```gdscript
# Enhanced asset_library.gd
extends Node

func load_universal_being(asset_id: String, variant: String = "default") -> UniversalBeing:
    var txt_path = "res://assets/definitions/" + _get_asset_category(asset_id) + "/" + asset_id + ".txt"
    var tscn_path = "res://assets/arrangements/" + _get_asset_category(asset_id) + "/" + asset_id + ".tscn"
    
    # Load variant if specified
    if variant != "default":
        var variant_path = "res://assets/variants/" + asset_id + "_" + variant + ".tscn"
        if ResourceLoader.exists(variant_path):
            tscn_path = variant_path
    
    # Parse TXT definition
    var definition = _parse_txt_definition(txt_path)
    
    # Load TSCN arrangement
    var scene_template = load(tscn_path)
    
    # Create Universal Being
    return _create_universal_being(definition, scene_template)

func _parse_txt_definition(path: String) -> Dictionary:
    var definition = {}
    var current_section = ""
    
    var file = FileAccess.open(path, FileAccess.READ)
    if not file:
        push_error("Could not open definition file: " + path)
        return {}
    
    while not file.eof_reached():
        var line = file.get_line().strip_edges()
        
        # Skip comments and empty lines
        if line.begins_with("#") or line.is_empty():
            continue
        
        # Section headers [SECTION]
        if line.begins_with("[") and line.ends_with("]"):
            current_section = line.substr(1, line.length() - 2).to_lower()
            definition[current_section] = {}
            continue
        
        # Key-value pairs
        var equals_pos = line.find("=")
        if equals_pos > 0:
            var key = line.substr(0, equals_pos).strip_edges()
            var value = line.substr(equals_pos + 1).strip_edges()
            
            # Convert to appropriate type
            value = _convert_value_type(value)
            
            if current_section.is_empty():
                definition[key] = value
            else:
                definition[current_section][key] = value
    
    file.close()
    return definition

func _convert_value_type(value: String) -> Variant:
    # Boolean conversion
    if value.to_lower() in ["true", "false"]:
        return value.to_lower() == "true"
    
    # Number conversion
    if value.is_valid_float():
        if "." in value:
            return value.to_float()
        else:
            return value.to_int()
    
    # Vector3 conversion
    if value.count(",") == 2:
        var parts = value.split(",")
        if parts.size() == 3:
            var x = parts[0].strip_edges()
            var y = parts[1].strip_edges()
            var z = parts[2].strip_edges()
            if x.is_valid_float() and y.is_valid_float() and z.is_valid_float():
                return Vector3(x.to_float(), y.to_float(), z.to_float())
    
    # Color conversion
    if value.begins_with("#") and value.length() == 7:
        return Color(value)
    
    # Array conversion (comma-separated)
    if "," in value and not value.begins_with("#"):
        return value.split(",")
    
    # String (default)
    return value

func _create_universal_being(definition: Dictionary, scene_template: PackedScene) -> UniversalBeing:
    var being = UniversalBeing.new()
    
    # Apply identity
    if definition.has("identity"):
        var identity = definition.identity
        being.set_essence("name", identity.get("name", "Unnamed"))
        being.set_essence("type", identity.get("type", "unknown"))
        being.set_essence("description", identity.get("description", ""))
    
    # Apply properties
    if definition.has("properties"):
        var props = definition.properties
        for key in props:
            being.set_essence(key, props[key])
    
    # Apply behaviors
    if definition.has("behaviors"):
        var behaviors = definition.behaviors
        for key in behaviors:
            being.set_essence("behavior_" + key, behaviors[key])
    
    # Apply visual settings
    if definition.has("visual"):
        var visual = definition.visual
        for key in visual:
            being.set_essence("visual_" + key, visual[key])
    
    # Instantiate scene template
    if scene_template:
        var scene_instance = scene_template.instantiate()
        being.add_child(scene_instance)
        being.manifestation = scene_instance
        being.is_manifested = true
    
    # Apply physics settings
    if definition.has("physics"):
        _apply_physics_settings(being, definition.physics)
    
    # Set initial form based on type
    var form_name = definition.get("identity", {}).get("type", "object")
    being.form = form_name
    
    # Add to appropriate groups
    being.add_to_group("universal_beings")
    if definition.has("identity") and definition.identity.has("category"):
        being.add_to_group(definition.identity.category)
    
    return being

func _apply_physics_settings(being: UniversalBeing, physics: Dictionary):
    var body_type = physics.get("body_type", "static")
    
    match body_type:
        "static":
            _setup_static_body(being, physics)
        "rigid":
            _setup_rigid_body(being, physics) 
        "kinematic":
            _setup_kinematic_body(being, physics)
        "character":
            _setup_character_body(being, physics)
```

### **Console Integration**
```gdscript
# New console commands in console_manager.gd
func _cmd_asset_load(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: asset load <asset_id> [variant] [position]")
        return
    
    var asset_id = args[0]
    var variant = args[1] if args.size() > 1 else "default"
    var position = Vector3.ZERO
    
    if args.size() >= 5:
        position = Vector3(
            args[2].to_float(),
            args[3].to_float(),
            args[4].to_float()
        )
    else:
        position = _get_mouse_world_position()
    
    # Load through asset library
    var asset_library = get_node("/root/AssetLibrary")
    var being = asset_library.load_universal_being(asset_id, variant)
    
    if being:
        being.position = position
        being.name = asset_id + "_" + str(Time.get_ticks_msec())
        
        # Add through floodgate
        var floodgate = get_node("/root/FloodgateController")
        floodgate.second_dimensional_magic(0, being.name, being)
        
        _print_to_console("Loaded %s (%s variant) at %s" % [asset_id, variant, position])
    else:
        _print_to_console("Failed to load asset: " + asset_id)

func _cmd_asset_create(args: Array):
    if args.size() < 2:
        _print_to_console("Usage: asset create <asset_id> <type>")
        return
    
    var asset_id = args[0]
    var asset_type = args[1]
    
    # Create new TXT definition file
    var txt_content = _generate_default_txt_definition(asset_id, asset_type)
    var txt_path = "res://assets/definitions/" + asset_type + "s/" + asset_id + ".txt"
    
    var file = FileAccess.open(txt_path, FileAccess.WRITE)
    if file:
        file.store_string(txt_content)
        file.close()
        _print_to_console("Created definition: " + txt_path)
    else:
        _print_to_console("Failed to create definition file")

func _cmd_asset_list(args: Array):
    var category = args[0] if args.size() > 0 else "all"
    
    var asset_library = get_node("/root/AssetLibrary")
    var assets = asset_library.get_available_assets(category)
    
    _print_to_console("[color=cyan]Available Assets (%s):[/color]" % category)
    for asset in assets:
        _print_to_console("• %s (%s)" % [asset.name, asset.type])

func _cmd_asset_inspect(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: asset inspect <asset_id>")
        return
    
    var asset_id = args[0]
    var asset_library = get_node("/root/AssetLibrary")
    var definition = asset_library.get_asset_definition(asset_id)
    
    if definition.is_empty():
        _print_to_console("Asset not found: " + asset_id)
        return
    
    _print_to_console("[color=yellow]Asset Definition: %s[/color]" % asset_id)
    for section in definition:
        _print_to_console("  [%s]" % section.to_upper())
        if definition[section] is Dictionary:
            for key in definition[section]:
                _print_to_console("    %s = %s" % [key, definition[section][key]])
        else:
            _print_to_console("    %s" % definition[section])
```

### **Variant System**
```gdscript
func load_asset_variant(asset_id: String, variant: String) -> UniversalBeing:
    # First load base definition
    var base_definition = _parse_txt_definition("res://assets/definitions/" + asset_id + ".txt")
    
    # Load variant overrides if they exist
    var variant_txt = "res://assets/variants/" + asset_id + "_" + variant + ".txt"
    if ResourceLoader.exists(variant_txt):
        var variant_definition = _parse_txt_definition(variant_txt)
        base_definition = _merge_definitions(base_definition, variant_definition)
    
    # Load variant scene if it exists
    var variant_scene = "res://assets/variants/" + asset_id + "_" + variant + ".tscn"
    var scene_template = null
    
    if ResourceLoader.exists(variant_scene):
        scene_template = load(variant_scene)
    else:
        scene_template = load("res://assets/arrangements/" + asset_id + ".tscn")
    
    return _create_universal_being(base_definition, scene_template)

func _merge_definitions(base: Dictionary, override: Dictionary) -> Dictionary:
    var merged = base.duplicate(true)
    
    for section in override:
        if merged.has(section) and merged[section] is Dictionary:
            # Merge section properties
            for key in override[section]:
                merged[section][key] = override[section][key]
        else:
            # Replace entire section
            merged[section] = override[section]
    
    return merged
```

## 🎮 Usage Examples

### **Loading Assets:**
```bash
asset load tree                     # Load default tree
asset load tree summer              # Load summer variant
asset load tree ancient 5 0 3      # Load ancient variant at position
asset load console 0 2 0           # Load console interface
asset load ragdoll                 # Load default ragdoll
```

### **Asset Management:**
```bash
asset list                          # List all assets
asset list nature                   # List nature category
asset inspect tree                  # Show tree definition
asset create my_flower nature       # Create new flower asset
asset variants tree                 # Show available tree variants
```

### **Creating from Templates:**
```bash
template nature_object pine_tree    # Create pine tree from template
template interface chat_window      # Create chat interface
template creature fire_elemental   # Create new creature type
```

## 🔄 Benefits

### **Separation of Concerns:**
- **TXT** = Properties, behaviors, logic
- **TSCN** = Visual arrangement, components
- **Universal Being** = Runtime integration

### **Easy Modification:**
- Edit TXT for behavior changes
- Edit TSCN for visual changes
- No code changes required

### **Version Control Friendly:**
- TXT files are human-readable
- Easy to diff and merge
- Clear change tracking

### **Designer Friendly:**
- Non-programmers can edit TXT files
- Visual artists handle TSCN files
- Clear separation of responsibilities

---

*"Every asset becomes a living Universal Being with this system!"*
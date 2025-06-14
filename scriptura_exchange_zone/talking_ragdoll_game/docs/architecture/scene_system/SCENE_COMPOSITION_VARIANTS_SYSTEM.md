# Scene Composition & Variants System
*Created: May 28, 2025*

## 🎯 Vision: Dynamic Scene Building with Universal Beings

**Core Concept:** Scenes are compositions of Universal Beings with multiple variants and smooth transitions between them using a keyframe system.

## 📐 Architecture Overview

### **Scene Composition Structure**
```
scenes/
├── compositions/              # Scene definitions
│   ├── forest.scene.txt      # Base forest composition
│   ├── meadow.scene.txt      # Peaceful meadow
│   └── debug_lab.scene.txt   # Testing environment
├── variants/                 # Scene variations
│   ├── forest_spring.txt     # Spring variant
│   ├── forest_summer.txt     # Summer variant  
│   ├── forest_autumn.txt     # Autumn variant
│   └── forest_winter.txt     # Winter variant
├── keyframes/               # Transition definitions
│   ├── forest_seasons.keyframes
│   └── day_night_cycle.keyframes
└── templates/               # Reusable patterns
    ├── nature_cluster.template
    └── village_layout.template
```

## 📄 Scene Definition Format

### **Example: forest.scene.txt**
```ini
# Universal Being Scene Composition - Forest
# Defines a forest environment with multiple variants

[SCENE_INFO]
name = Enchanted Forest
description = A magical forest with seasonal changes
author = universal_system
version = 1.0
base_variant = summer

[ENVIRONMENT]
ground_type = grass_terrain
sky_type = nature_sky
lighting = natural_soft
ambient_sound = forest_ambience
weather_enabled = true

[UNIVERSAL_BEINGS]
# Format: type:variant:count:area:distribution:properties

# Trees - main forest structure
tree:oak:15:circle(20):random:health=500,can_talk=true
tree:pine:8:circle(25):clustered:health=600,ancient=true
tree:birch:5:line(15):spaced:health=300,young=true

# Nature elements
rock:moss_covered:12:scattered:random:size=random(0.5,2.0)
bush:berry:20:under_trees:natural:harvestable=true
flower:wildflower:50:clearings:grouped:seasonal=true

# Interactive elements
console:forest_terminal:1:center:fixed:position=(0,2,0)
pickup_health:healing_spring:3:near_water:clustered:heal_amount=50

# Creatures  
astral_being:forest_spirit:2:patrol:roaming:friendly=true,wisdom=high
ragdoll:forest_explorer:1:spawn_point:fixed:personality=curious

[AREAS]
# Define spawn areas for different types
center = circle(0,0,5)
inner_forest = ring(5,15)
outer_forest = ring(15,25)
clearings = custom_points((-5,3),(8,-2),(2,12))
under_trees = near_objects(tree,radius=3)
near_water = near_terrain(water,radius=5)
patrol = path((-10,-10),(10,-10),(10,10),(-10,10))

[DISTRIBUTION_RULES]
# How objects are placed
random = uniform_random
clustered = gaussian_clusters(radius=3,density=0.7)
natural = organic_placement(avoid_overlap=true)
spaced = minimum_distance(3.0)
grouped = cluster_size(3-7)

[CONNECTIONS]
# Define relationships between beings
trees connect_to other_trees radius=10 type=root_network
astral_beings follow_paths patrol
forest_explorer attracted_to interactive_objects
healing_springs connected_to water_network

[PHYSICS]
gravity = 9.8
wind_enabled = true
wind_strength = 0.3
seasonal_physics = true
weather_affects_physics = true

[METADATA]
difficulty = easy
expected_framerate = 60
max_objects = 144
optimization_distance = 50
```

### **Example: forest_winter.txt (Variant)**
```ini
# Winter Variant for Forest Scene
# Overrides base forest for winter appearance

[VARIANT_INFO]
name = Winter Forest
base_scene = forest
season = winter
temperature = cold

[OVERRIDES]
# Override specific beings with winter versions
tree:oak:winter_oak
tree:birch:winter_birch
flower:wildflower:0  # No flowers in winter
bush:berry:winter_bush

[ADDITIONS]
# Add winter-specific elements
snow_particle:snowfall:1:atmosphere:environmental
ice_crystal:frozen_water:10:near_water:natural:glow=true
winter_spirit:ice_guardian:1:center:guardian:power=ice

[MATERIAL_CHANGES]
# Change materials for winter feel
ground_material = snow_covered_grass
tree_material = frost_covered_bark
water_material = partially_frozen

[LIGHTING_CHANGES]
ambient_color = (0.8,0.9,1.0)  # Cool blue tint
sun_intensity = 0.6            # Dimmer winter sun
fog_enabled = true
fog_density = 0.2

[WEATHER_OVERRIDE]
base_weather = snow
wind_strength = 0.5            # Stronger winter wind
temperature = -5
precipitation = snow

[PHYSICS_CHANGES]
ground_friction = 0.3          # Slippery snow
wind_affects_trees = true      # Trees sway more
ice_physics = true             # Enable ice behavior
```

### **Example: forest_seasons.keyframes**
```yaml
# Keyframe System for Forest Seasonal Transitions
# Defines smooth transitions between variants

keyframe_set: forest_seasonal_cycle
duration: 300  # seconds for full cycle
loop: true
transition_type: smooth

keyframes:
  - time: 0
    variant: spring
    transition_duration: 30
    effects:
      - material_lerp: winter_to_spring
      - spawn_gradually: flowers
      - sound_transition: birds_awakening
  
  - time: 75  
    variant: summer
    transition_duration: 20
    effects:
      - color_shift: green_intensify
      - particle_increase: pollen
      - sound_peak: full_forest_life
  
  - time: 150
    variant: autumn  
    transition_duration: 25
    effects:
      - color_cycle: green_to_orange
      - particle_add: falling_leaves
      - sound_change: rustling_wind
  
  - time: 225
    variant: winter
    transition_duration: 35
    effects:
      - particle_replace: snow
      - material_frost: all_surfaces
      - sound_quiet: winter_silence
  
  - time: 300
    variant: spring  # Loop back
    transition_duration: 20

special_transitions:
  emergency_winter:
    trigger: player_command("winter now")
    duration: 5
    target_variant: winter
    
  time_skip:
    trigger: player_command("skip season")
    duration: 1
    target_variant: next_in_cycle
```

## 🔧 Enhanced Scene Management System

### **Scene Composer Implementation**
```gdscript
# Enhanced unified_scene_manager.gd
extends Node

signal scene_loaded(scene_name: String, variant: String)
signal variant_changed(from_variant: String, to_variant: String)
signal transition_started(keyframe_set: String)
signal transition_completed()

var current_scene: String = ""
var current_variant: String = "default"
var active_beings: Array[UniversalBeing] = []
var keyframe_player: KeyframePlayer = null
var scene_definitions: Dictionary = {}

func load_scene_composition(scene_name: String, variant: String = "default", transition_time: float = 2.0):
    # Clear current scene
    await _clear_current_scene(transition_time * 0.3)
    
    # Load scene definition
    var scene_def = _load_scene_definition(scene_name)
    var variant_def = _load_variant_definition(scene_name, variant)
    
    # Merge base + variant
    var final_definition = _merge_scene_definitions(scene_def, variant_def)
    
    # Spawn beings based on definition
    await _spawn_scene_beings(final_definition, transition_time * 0.7)
    
    current_scene = scene_name
    current_variant = variant
    scene_loaded.emit(scene_name, variant)

func _load_scene_definition(scene_name: String) -> Dictionary:
    var path = "res://scenes/compositions/" + scene_name + ".scene.txt"
    return _parse_scene_file(path)

func _load_variant_definition(scene_name: String, variant: String) -> Dictionary:
    if variant == "default":
        return {}
    
    var path = "res://scenes/variants/" + scene_name + "_" + variant + ".txt"
    if ResourceLoader.exists(path):
        return _parse_scene_file(path)
    return {}

func _spawn_scene_beings(definition: Dictionary, transition_time: float):
    var beings_section = definition.get("universal_beings", {})
    var areas_section = definition.get("areas", {})
    var distribution_section = definition.get("distribution_rules", {})
    
    # Parse areas first
    var spawn_areas = _parse_spawn_areas(areas_section)
    
    # Spawn each type of being
    for being_def in beings_section:
        await _spawn_being_type(being_def, spawn_areas, distribution_section, transition_time)
        
        # Stagger spawning for smooth transition
        await get_tree().process_frame

func _spawn_being_type(being_def: String, areas: Dictionary, distribution: Dictionary, transition_time: float):
    # Parse: "tree:oak:15:circle(20):random:health=500,can_talk=true"
    var parts = being_def.split(":")
    if parts.size() < 4:
        return
    
    var type = parts[0]
    var variant = parts[1] if parts.size() > 1 else "default"
    var count = parts[2].to_int() if parts.size() > 2 else 1
    var area_name = parts[3] if parts.size() > 3 else "center"
    var distribution_type = parts[4] if parts.size() > 4 else "random"
    var properties = _parse_properties(parts[5] if parts.size() > 5 else "")
    
    # Get spawn area
    var spawn_area = areas.get(area_name, {"type": "circle", "radius": 10})
    
    # Generate spawn positions
    var positions = _generate_spawn_positions(count, spawn_area, distribution_type)
    
    # Create beings
    var asset_library = get_node("/root/AssetLibrary")
    var floodgate = get_node("/root/FloodgateController")
    
    for i in range(count):
        var being = asset_library.load_universal_being(type, variant)
        if being:
            # Apply custom properties
            for prop in properties:
                being.set_essence(prop, properties[prop])
            
            # Set position
            being.position = positions[i] if i < positions.size() else Vector3.ZERO
            being.name = type + "_" + str(i + 1)
            
            # Add with slight delay for smooth spawning
            floodgate.second_dimensional_magic(0, being.name, being)
            active_beings.append(being)
            
            # Visual spawn effect
            _create_spawn_effect(being.position)
            
            await get_tree().create_timer(transition_time / count).timeout

func _generate_spawn_positions(count: int, area: Dictionary, distribution: String) -> Array[Vector3]:
    var positions: Array[Vector3] = []
    var area_type = area.get("type", "circle")
    
    match area_type:
        "circle":
            var radius = area.get("radius", 10.0)
            var center = area.get("center", Vector3.ZERO)
            positions = _generate_circle_positions(count, center, radius, distribution)
        
        "ring":
            var inner = area.get("inner_radius", 5.0)
            var outer = area.get("outer_radius", 15.0)
            var center = area.get("center", Vector3.ZERO)
            positions = _generate_ring_positions(count, center, inner, outer, distribution)
        
        "line":
            var start = area.get("start", Vector3(-10, 0, 0))
            var end = area.get("end", Vector3(10, 0, 0))
            positions = _generate_line_positions(count, start, end, distribution)
        
        "custom_points":
            var points = area.get("points", [Vector3.ZERO])
            positions = _distribute_around_points(count, points, distribution)
    
    return positions

func _generate_circle_positions(count: int, center: Vector3, radius: float, distribution: String) -> Array[Vector3]:
    var positions: Array[Vector3] = []
    
    match distribution:
        "random":
            for i in range(count):
                var angle = randf() * TAU
                var distance = randf() * radius
                var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
                positions.append(pos)
        
        "clustered":
            var cluster_count = max(1, count / 5)
            var cluster_centers = []
            
            # Generate cluster centers
            for i in range(cluster_count):
                var angle = randf() * TAU
                var distance = randf() * radius * 0.7
                cluster_centers.append(center + Vector3(cos(angle) * distance, 0, sin(angle) * distance))
            
            # Distribute objects around clusters
            for i in range(count):
                var cluster = cluster_centers[i % cluster_centers.size()]
                var offset = Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
                positions.append(cluster + offset)
        
        "spaced":
            var angle_step = TAU / count
            for i in range(count):
                var angle = i * angle_step
                var distance = radius * 0.8
                var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
                positions.append(pos)
    
    return positions

# Keyframe System Integration
func play_keyframe_sequence(keyframe_name: String):
    var keyframe_path = "res://scenes/keyframes/" + keyframe_name + ".keyframes"
    if not ResourceLoader.exists(keyframe_path):
        push_error("Keyframe file not found: " + keyframe_path)
        return
    
    if not keyframe_player:
        keyframe_player = KeyframePlayer.new()
        add_child(keyframe_player)
    
    keyframe_player.load_keyframes(keyframe_path)
    keyframe_player.play()
    keyframe_player.keyframe_reached.connect(_on_keyframe_reached)
    
    transition_started.emit(keyframe_name)

func _on_keyframe_reached(keyframe_data: Dictionary):
    var target_variant = keyframe_data.get("variant", current_variant)
    var transition_duration = keyframe_data.get("transition_duration", 2.0)
    
    if target_variant != current_variant:
        await transition_to_variant(target_variant, transition_duration)
    
    # Apply effects
    var effects = keyframe_data.get("effects", [])
    for effect in effects:
        _apply_keyframe_effect(effect)

func transition_to_variant(new_variant: String, duration: float = 2.0):
    if new_variant == current_variant:
        return
    
    variant_changed.emit(current_variant, new_variant)
    
    # Smooth transition between variants
    var old_variant = current_variant
    
    # Load new variant definition
    var variant_def = _load_variant_definition(current_scene, new_variant)
    
    # Apply changes gradually
    await _apply_variant_changes(variant_def, duration)
    
    current_variant = new_variant
```

### **Console Commands for Scene Management**
```gdscript
# New console commands in console_manager.gd
func _cmd_scene_load(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: scene load <scene_name> [variant] [transition_time]")
        return
    
    var scene_name = args[0]
    var variant = args[1] if args.size() > 1 else "default"
    var transition_time = args[2].to_float() if args.size() > 2 else 2.0
    
    var scene_manager = get_node("/root/UnifiedSceneManager")
    await scene_manager.load_scene_composition(scene_name, variant, transition_time)
    
    _print_to_console("Loaded scene: %s (%s variant)" % [scene_name, variant])

func _cmd_scene_variant(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: scene variant <variant_name> [transition_time]")
        return
    
    var variant = args[0]
    var transition_time = args[1].to_float() if args.size() > 1 else 2.0
    
    var scene_manager = get_node("/root/UnifiedSceneManager")
    await scene_manager.transition_to_variant(variant, transition_time)
    
    _print_to_console("Switched to variant: " + variant)

func _cmd_scene_keyframes(args: Array):
    if args.size() < 1:
        _print_to_console("Usage: scene keyframes <keyframe_name>")
        return
    
    var keyframe_name = args[0]
    var scene_manager = get_node("/root/UnifiedSceneManager")
    scene_manager.play_keyframe_sequence(keyframe_name)
    
    _print_to_console("Playing keyframes: " + keyframe_name)

func _cmd_scene_compose(args: Array):
    # Quick scene composition: scene compose meadow tree=5 rock=3 ragdoll=1
    if args.size() < 2:
        _print_to_console("Usage: scene compose <scene_name> <type>=<count> ...")
        return
    
    var scene_name = args[0]
    var composition = {}
    
    for i in range(1, args.size()):
        var part = args[i]
        if "=" in part:
            var split = part.split("=")
            if split.size() == 2:
                composition[split[0]] = split[1].to_int()
    
    _create_quick_composition(scene_name, composition)

func _create_quick_composition(scene_name: String, composition: Dictionary):
    _print_to_console("[color=cyan]Creating quick composition: %s[/color]" % scene_name)
    
    var spawn_radius = 15.0
    var total_objects = 0
    
    for type in composition:
        total_objects += composition[type]
    
    var angle_step = TAU / total_objects
    var current_angle = 0.0
    
    for type in composition:
        var count = composition[type]
        
        for i in range(count):
            var position = Vector3(
                cos(current_angle) * spawn_radius,
                0,
                sin(current_angle) * spawn_radius
            )
            
            # Load asset
            var asset_library = get_node("/root/AssetLibrary")
            var being = asset_library.load_universal_being(type)
            
            if being:
                being.position = position
                being.name = type + "_" + str(i + 1)
                
                var floodgate = get_node("/root/FloodgateController")
                floodgate.second_dimensional_magic(0, being.name, being)
            
            current_angle += angle_step
            await get_tree().process_frame
    
    _print_to_console("Composition complete!")
```

## 🎮 Usage Examples

### **Scene Loading:**
```bash
scene load forest                    # Load default forest
scene load forest winter            # Load winter variant
scene load meadow summer 5.0        # Load with 5 second transition
scene compose test_area tree=5 rock=3 ragdoll=1  # Quick composition
```

### **Variant Switching:**
```bash
scene variant spring                 # Switch to spring variant
scene variant autumn 3.0            # Switch with 3 second transition
scene keyframes forest_seasons       # Start seasonal cycle
scene keyframes day_night_cycle      # Start day/night cycle
```

### **Scene Management:**
```bash
scene save current_state my_scene    # Save current arrangement
scene list                          # List available scenes
scene variants forest               # Show forest variants
scene info                          # Show current scene info
```

### **Advanced Composition:**
```bash
template create village tree=10 house=5 npc=3  # Create village template
scene merge forest meadow           # Combine two scenes
scene time_scale 2.0                # Speed up keyframe playback
scene pause_keyframes               # Pause seasonal cycle
```

## 🔄 Benefits

### **Dynamic Environments:**
- Scenes change over time naturally
- Smooth transitions between variants
- Keyframe system for complex animations

### **Easy Content Creation:**
- Text-based scene definitions
- Reusable templates and patterns
- No coding required for new scenes

### **Performance Optimized:**
- Gradual spawning prevents frame drops
- Distance-based optimization
- Object limit management through floodgate

### **Creative Freedom:**
- Mix and match any Universal Beings
- Custom spawn patterns and distributions
- Procedural and designed content combined

---

*"Scenes become living, breathing compositions that evolve naturally through time!"*
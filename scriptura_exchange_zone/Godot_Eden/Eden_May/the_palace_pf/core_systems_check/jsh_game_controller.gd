extends Node3D

class_name JSHGameController

# ----- GAME SETTINGS -----
@export_category("Game Settings")
@export var game_enabled: bool = true
@export var initial_reality: String = "physical"  # physical, digital, astral
@export var auto_scene_generation: bool = true
@export var scene_update_interval: float = 60.0  # Seconds between scene updates
@export var anime_style_visualization: bool = true
@export var holographic_mode: bool = true

# ----- VISUAL SETTINGS -----
@export_category("Visual Settings")
@export var time_zone_visualization: bool = true
@export var zone_glow_intensity: float = 0.7
@export var word_animation_enabled: bool = true
@export var anime_outline_width: float = 2.0
@export var anime_outline_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var anime_cel_shading_levels: int = 3
@export var anime_2d_billboard_mode: bool = true

# ----- COMPONENT REFERENCES -----
@export var words_in_space_path: NodePath
@export var word_seed_evolution_path: NodePath
@export var zone_scale_system_path: NodePath
@export var player_controller_path: NodePath
@export var console_path: NodePath

# ----- COMPONENT REFERENCES -----
var words_in_space: Node
var word_seed_evolution: Node
var zone_scale_system: Node
var player_controller: Node
var console: Node

# ----- GAME STATE -----
var current_scene: Dictionary = {}
var scene_history: Array = []
var time_zones: Dictionary = {}
var active_animations: Dictionary = {}
var persistent_words: Array = []  # Words that won't be deleted
var eternal_creation_zones: Array = []  # Zones with continuous creation
var current_game_mode: String = "exploration"  # exploration, calibration, animation, writing
var anime_characters: Dictionary = {}
var hologram_system: Node

# ----- ANIMATION PROPERTIES -----
var animation_timeline: Array = []
var current_animation_time: float = 0.0
var replay_mode: bool = false
var animation_speed: float = 1.0

# ----- SIGNALS -----
signal scene_changed(old_scene, new_scene)
signal time_zone_calibrated(zone_id, settings)
signal animation_started(timeline_name)
signal animation_completed(timeline_name)
signal game_mode_changed(old_mode, new_mode)
signal hologram_created(hologram_id, word_id)
signal anime_character_created(character_id, properties)

# ----- INITIALIZATION -----
func _ready():
    # Get component references
    words_in_space = get_node_or_null(words_in_space_path)
    word_seed_evolution = get_node_or_null(word_seed_evolution_path)
    zone_scale_system = get_node_or_null(zone_scale_system_path)
    player_controller = get_node_or_null(player_controller_path)
    console = get_node_or_null(console_path)
    
    # Setup initial game state
    if game_enabled:
        setup_game()
    
    # Setup visual effects
    if anime_style_visualization:
        setup_anime_style()
    
    if holographic_mode:
        setup_holographic_system()
    
    # Setup scene generation timer
    if auto_scene_generation:
        var scene_timer = Timer.new()
        scene_timer.wait_time = scene_update_interval
        scene_timer.one_shot = false
        scene_timer.timeout.connect(_on_scene_timer_timeout)
        add_child(scene_timer)
        scene_timer.start()
    
    # Connect to signals
    if zone_scale_system:
        zone_scale_system.zone_created.connect(_on_zone_created)
        zone_scale_system.player_entered_zone.connect(_on_player_entered_zone)
        zone_scale_system.scale_transition.connect(_on_scale_transition)
    
    if word_seed_evolution:
        word_seed_evolution.word_evolved.connect(_on_word_evolved)
        word_seed_evolution.story_updated.connect(_on_story_updated)

# ----- GAME SETUP -----
func setup_game():
    # Create initial time zones if zone system is available
    if zone_scale_system:
        create_initial_time_zones()
    
    # Create starting words if word system is available
    if word_seed_evolution:
        create_starting_words()
    
    # Set initial reality
    set_reality(initial_reality)
    
    # Generate initial scene
    if auto_scene_generation:
        generate_scene()
    
    # Log game start
    if console and console.has_method("log"):
        console.log("JSH Ethereal Engine - Game of Words initialized", Color(0.3, 0.7, 1.0))

func create_initial_time_zones():
    # Create a central present time zone
    var present_zone_id = zone_scale_system.create_custom_zone(
        Vector3.ZERO, 
        15.0, 
        "human", 
        "STABLE", 
        {"time_zone": "present", "time_offset": 0}
    )
    
    # Create past time zone
    var past_zone_id = zone_scale_system.create_custom_zone(
        Vector3(-30, 0, 0), 
        10.0, 
        "human", 
        "SLOWED", 
        {"time_zone": "past", "time_offset": -100}
    )
    
    # Create future time zone
    var future_zone_id = zone_scale_system.create_custom_zone(
        Vector3(30, 0, 0), 
        10.0, 
        "human", 
        "ACCELERATED", 
        {"time_zone": "future", "time_offset": 100}
    )
    
    # Create eternal creation zone (smallest scale)
    var eternal_zone_id = zone_scale_system.create_custom_zone(
        Vector3(0, -30, 0), 
        8.0, 
        "quantum", 
        "CREATIVE", 
        {"time_zone": "eternal", "time_offset": 0, "eternal_creation": true}
    )
    
    # Add to eternal creation zones
    eternal_creation_zones.append(eternal_zone_id)
    
    # Create anime reality zone
    var anime_zone_id = zone_scale_system.create_custom_zone(
        Vector3(0, 0, 30), 
        12.0, 
        "object", 
        "SHIFTING", 
        {"time_zone": "anime", "time_offset": 0, "anime": true}
    )
    
    # Store time zones for reference
    time_zones = {
        "present": present_zone_id,
        "past": past_zone_id,
        "future": future_zone_id,
        "eternal": eternal_zone_id,
        "anime": anime_zone_id
    }

func create_starting_words():
    # Create essential words that will persist
    var core_words = [
        {"text": "creation", "position": Vector3(0, 2, 0), "category": "concept"},
        {"text": "time", "position": Vector3(-2, 2, 2), "category": "concept"},
        {"text": "space", "position": Vector3(2, 2, 2), "category": "concept"},
        {"text": "reality", "position": Vector3(0, 2, -2), "category": "concept"},
        {"text": "eternal", "position": Vector3(0, 0, 0), "category": "concept"},
        {"text": "anime", "position": Vector3(0, 0, 15), "category": "concept"}
    ]
    
    for word_data in core_words:
        var word_id = word_seed_evolution.plant_seed(
            word_data.text,
            word_data.position,
            word_data.category
        )
        
        # Add to persistent words list
        if word_id != "":
            persistent_words.append(word_id)
    
    # Connect core words
    if word_seed_evolution.has_method("connect_words"):
        word_seed_evolution.connect_words("seed_creation_", "seed_time_")
        word_seed_evolution.connect_words("seed_creation_", "seed_space_")
        word_seed_evolution.connect_words("seed_creation_", "seed_reality_")
        word_seed_evolution.connect_words("seed_time_", "seed_eternal_")
        word_seed_evolution.connect_words("seed_reality_", "seed_anime_")

# ----- VISUAL SETUP -----
func setup_anime_style():
    # Create anime style shader for words
    var anime_shader = ShaderMaterial.new()
    anime_shader.shader = load("res://anime_style.gdshader")  # You would need to create this shader
    
    # Set shader parameters
    anime_shader.set_shader_parameter("outline_width", anime_outline_width)
    anime_shader.set_shader_parameter("outline_color", anime_outline_color)
    anime_shader.set_shader_parameter("cel_shading_levels", anime_cel_shading_levels)
    
    # Apply to words if possible
    if words_in_space and words_in_space.has_method("set_global_word_material"):
        words_in_space.set_global_word_material(anime_shader)
    
    # Setup anime character templates
    setup_anime_characters()

func setup_anime_characters():
    # Define anime character templates based on word categories
    anime_characters = {
        "protagonist": {
            "visual_style": "hero",
            "color_scheme": Color(0.3, 0.6, 1.0),
            "animation_set": "protagonist",
            "scale": Vector3(1.0, 1.0, 1.0),
            "billboard_offset": Vector3(0, 1.0, 0)
        },
        "antagonist": {
            "visual_style": "villain",
            "color_scheme": Color(1.0, 0.3, 0.3),
            "animation_set": "antagonist",
            "scale": Vector3(1.0, 1.0, 1.0),
            "billboard_offset": Vector3(0, 1.0, 0)
        },
        "support": {
            "visual_style": "support",
            "color_scheme": Color(0.3, 1.0, 0.5),
            "animation_set": "support",
            "scale": Vector3(0.9, 0.9, 0.9),
            "billboard_offset": Vector3(0, 0.9, 0)
        },
        "object": {
            "visual_style": "item",
            "color_scheme": Color(0.8, 0.8, 0.3),
            "animation_set": "object",
            "scale": Vector3(0.7, 0.7, 0.7),
            "billboard_offset": Vector3(0, 0.5, 0)
        },
        "location": {
            "visual_style": "scene",
            "color_scheme": Color(0.5, 0.5, 1.0),
            "animation_set": "location",
            "scale": Vector3(1.2, 1.2, 1.2),
            "billboard_offset": Vector3(0, 0.0, 0)
        }
    }

func setup_holographic_system():
    # Create hologram system node
    hologram_system = Node3D.new()
    hologram_system.name = "HologramSystem"
    add_child(hologram_system)
    
    # Setup hologram material
    var hologram_material = ShaderMaterial.new()
    hologram_material.shader = load("res://hologram.gdshader")  # You would need to create this shader
    
    # Set initial shader parameters
    hologram_material.set_shader_parameter("hologram_color", Color(0.2, 0.8, 1.0, 0.7))
    hologram_material.set_shader_parameter("scan_line_speed", 2.0)
    hologram_material.set_shader_parameter("scan_line_width", 0.1)
    hologram_material.set_shader_parameter("edge_glow", 0.5)
    
    # Store material for future holograms
    hologram_system.set_meta("hologram_material", hologram_material)

# ----- GAME LOOP -----
func _process(delta):
    if not game_enabled:
        return
    
    # Process animations
    if word_animation_enabled:
        update_animations(delta)
    
    # Process eternal creation zones
    if zone_scale_system and word_seed_evolution:
        process_eternal_creation_zones(delta)
    
    # Update holographic effects
    if holographic_mode:
        update_holograms(delta)
    
    # Process anime characters
    if anime_style_visualization:
        update_anime_characters(delta)
    
    # Process animation timeline in replay mode
    if replay_mode:
        update_animation_replay(delta)

func update_animations(delta):
    # Update each active animation
    var completed_animations = []
    
    for animation_id in active_animations:
        var animation_data = active_animations[animation_id]
        
        # Update progress
        animation_data.elapsed_time += delta
        var progress = animation_data.elapsed_time / animation_data.duration
        
        # Apply animation based on type
        match animation_data.type:
            "word_move":
                update_word_move_animation(animation_id, animation_data, progress)
            "word_scale":
                update_word_scale_animation(animation_id, animation_data, progress)
            "word_color":
                update_word_color_animation(animation_id, animation_data, progress)
            "word_rotation":
                update_word_rotation_animation(animation_id, animation_data, progress)
            "word_connection":
                update_word_connection_animation(animation_id, animation_data, progress)
        
        # Check if animation is complete
        if progress >= 1.0:
            completed_animations.append(animation_id)
    
    # Remove completed animations
    for animation_id in completed_animations:
        var animation_data = active_animations[animation_id]
        
        # If it's part of a sequence, start the next animation
        if animation_data.has("next_animation") and animation_data.next_animation != "":
            start_animation(animation_data.next_animation)
        
        active_animations.erase(animation_id)

func update_word_move_animation(animation_id, animation_data, progress):
    if not words_in_space or not animation_data.has("word_id"):
        return
    
    var word_id = animation_data.word_id
    var start_pos = animation_data.start_position
    var end_pos = animation_data.end_position
    
    # Calculate current position with easing
    var eased_progress = ease(progress, animation_data.get("ease_factor", -2))  # Default to ease out
    var current_pos = start_pos.lerp(end_pos, eased_progress)
    
    # Update word position
    if words_in_space.has_method("set_word_position"):
        words_in_space.set_word_position(word_id, current_pos)

func update_word_scale_animation(animation_id, animation_data, progress):
    if not words_in_space or not animation_data.has("word_id"):
        return
    
    var word_id = animation_data.word_id
    var start_scale = animation_data.start_scale
    var end_scale = animation_data.end_scale
    
    # Calculate current scale with easing
    var eased_progress = ease(progress, animation_data.get("ease_factor", 2))  # Default to ease in
    var current_scale = start_scale.lerp(end_scale, eased_progress)
    
    # Update word scale
    if words_in_space.has_method("set_word_scale"):
        words_in_space.set_word_scale(word_id, current_scale)

func update_word_color_animation(animation_id, animation_data, progress):
    if not words_in_space or not animation_data.has("word_id"):
        return
    
    var word_id = animation_data.word_id
    var start_color = animation_data.start_color
    var end_color = animation_data.end_color
    
    # Calculate current color with easing
    var eased_progress = ease(progress, animation_data.get("ease_factor", 1))  # Default to linear
    var current_color = start_color.lerp(end_color, eased_progress)
    
    # Update word color
    if words_in_space.has_method("set_word_color"):
        words_in_space.set_word_color(word_id, current_color)

func update_word_rotation_animation(animation_id, animation_data, progress):
    if not words_in_space or not animation_data.has("word_id"):
        return
    
    var word_id = animation_data.word_id
    var start_rotation = animation_data.start_rotation
    var end_rotation = animation_data.end_rotation
    
    # Calculate current rotation with easing
    var eased_progress = ease(progress, animation_data.get("ease_factor", 1))  # Default to linear
    
    # Handle rotation specially to go shortest path
    var current_rotation
    if animation_data.get("use_quaternion", true):
        var start_quat = Quaternion.from_euler(start_rotation)
        var end_quat = Quaternion.from_euler(end_rotation)
        var current_quat = start_quat.slerp(end_quat, eased_progress)
        current_rotation = current_quat.get_euler()
    else:
        current_rotation = Vector3(
            lerp_angle(start_rotation.x, end_rotation.x, eased_progress),
            lerp_angle(start_rotation.y, end_rotation.y, eased_progress),
            lerp_angle(start_rotation.z, end_rotation.z, eased_progress)
        )
    
    # Update word rotation
    if words_in_space.has_method("set_word_rotation"):
        words_in_space.set_word_rotation(word_id, current_rotation)

func update_word_connection_animation(animation_id, animation_data, progress):
    if not words_in_space or not animation_data.has("word_id_1") or not animation_data.has("word_id_2"):
        return
    
    var word_id_1 = animation_data.word_id_1
    var word_id_2 = animation_data.word_id_2
    var start_width = animation_data.start_width
    var end_width = animation_data.end_width
    
    # Calculate current width with easing
    var eased_progress = ease(progress, animation_data.get("ease_factor", 2))  # Default to ease in
    var current_width = lerp(start_width, end_width, eased_progress)
    
    # Update connection width
    if words_in_space.has_method("set_connection_width"):
        words_in_space.set_connection_width(word_id_1, word_id_2, current_width)

func update_holograms(delta):
    if not hologram_system:
        return
    
    # Update hologram shader parameters for scanning effect
    var material = hologram_system.get_meta("hologram_material")
    if material:
        var scan_offset = fmod(material.get_shader_parameter("scan_line_offset") + delta * material.get_shader_parameter("scan_line_speed"), 1.0)
        material.set_shader_parameter("scan_line_offset", scan_offset)
    
    # Update individual holograms
    for i in range(hologram_system.get_child_count()):
        var hologram = hologram_system.get_child(i)
        if hologram is MeshInstance3D:
            # Pulse effect
            var pulse_speed = hologram.get_meta("pulse_speed", 1.0)
            var pulse_amount = hologram.get_meta("pulse_amount", 0.05)
            var base_scale = hologram.get_meta("base_scale", Vector3(1, 1, 1))
            
            var pulse = sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * pulse_amount + 1.0
            hologram.scale = base_scale * pulse

func update_anime_characters(delta):
    # Process 2D billboard mode for anime characters if enabled
    if anime_2d_billboard_mode and words_in_space:
        # Get camera reference
        var camera = get_viewport().get_camera_3d()
        if not camera:
            return
        
        # Update all word nodes to face camera
        for word_id in words_in_space.get_all_words():
            var word_node = words_in_space.get_word_node(word_id)
            if word_node and word_node.get_meta("anime_character", false):
                # Billboard mode - rotate to face camera
                var look_target = camera.global_position
                word_node.look_at(look_target, Vector3.UP)
                # Rotate an additional 180 degrees so text faces camera
                word_node.rotate_y(PI)

func process_eternal_creation_zones(delta):
    # Handle eternal creation zones
    for zone_id in eternal_creation_zones:
        if zone_scale_system.active_zones.has(zone_id):
            var zone_data = zone_scale_system.active_zones[zone_id]
            
            # Random chance to create a new word based on manifestation factor
            var creation_chance = 0.01 * zone_data.manifestation_factor * delta
            if randf() < creation_chance:
                manifest_random_word_in_zone(zone_id)

func manifest_random_word_in_zone(zone_id):
    if not zone_scale_system.active_zones.has(zone_id) or not word_seed_evolution:
        return
    
    var zone_data = zone_scale_system.active_zones[zone_id]
    
    # Generate a random position within the zone
    var random_direction = Vector3(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
    var random_distance = randf() * zone_data.radius * 0.8
    var position = zone_data.position + random_direction * random_distance
    
    # Generate a random word appropriate for the zone
    var word_text = generate_random_word_for_zone(zone_id)
    
    # Plant the seed
    if word_seed_evolution.has_method("plant_seed"):
        var word_id = word_seed_evolution.plant_seed(word_text, position)
        
        # If this is an anime zone, apply anime styling
        if zone_data.properties.has("anime") and zone_data.properties.anime and word_id != "":
            apply_anime_style_to_word(word_id)
        
        # Create hologram effect
        if holographic_mode and word_id != "":
            create_word_hologram(word_id)
        
        return word_id
    
    return ""

func generate_random_word_for_zone(zone_id):
    if not zone_scale_system.active_zones.has(zone_id):
        return "creation"
    
    var zone_data = zone_scale_system.active_zones[zone_id]
    
    # Different word pools for different zone types
    var word_pools = {
        "eternal": ["eternal", "infinity", "endless", "forever", "timeless", "boundless", "immortal", "cosmic", "divine", "transcendent"],
        "anime": ["anime", "kawaii", "senpai", "chibi", "manga", "otaku", "shounen", "mecha", "waifu", "neko"],
        "past": ["ancient", "history", "memory", "bygone", "forgotten", "relic", "ancestor", "legacy", "precedent", "vintage"],
        "present": ["now", "current", "existing", "moment", "instant", "today", "contemporary", "immediate", "actual", "modern"],
        "future": ["tomorrow", "upcoming", "destiny", "fate", "prospect", "potential", "forthcoming", "impending", "eventual", "subsequent"]
    }
    
    # Default to creation words
    var default_words = ["creation", "genesis", "beginning", "origin", "birth", "formation", "emergence", "dawn", "spark", "inception"]
    
    # Get appropriate word pool
    var pool = default_words
    if zone_data.properties.has("time_zone") and word_pools.has(zone_data.properties.time_zone):
        pool = word_pools[zone_data.properties.time_zone]
    
    # Pick a random word from the pool
    return pool[randi() % pool.size()]

func update_animation_replay(delta):
    if animation_timeline.size() == 0:
        replay_mode = false
        return
    
    # Update animation time
    current_animation_time += delta * animation_speed
    
    # Find and execute all timeline events that should occur at this time
    for event in animation_timeline:
        if not event.has("executed") and event.time <= current_animation_time:
            execute_timeline_event(event)
            event.executed = true
    
    # Check if all events have been executed
    var all_executed = true
    for event in animation_timeline:
        if not event.has("executed"):
            all_executed = false
            break
    
    # Reset or stop if all events executed
    if all_executed:
        if event_loop_enabled:
            reset_animation_timeline()
        else:
            replay_mode = false
            emit_signal("animation_completed", current_timeline_name)

func execute_timeline_event(event):
    match event.type:
        "word_appear":
            if word_seed_evolution:
                word_seed_evolution.plant_seed(event.word, event.position, event.get("category", "concept"))
        
        "word_disappear":
            if words_in_space and words_in_space.has_method("remove_word"):
                words_in_space.remove_word(event.word_id)
        
        "word_evolve":
            if word_seed_evolution and word_seed_evolution.has_method("_evolve_seed"):
                word_seed_evolution._evolve_seed(event.word_id)
        
        "connect_words":
            if word_seed_evolution and word_seed_evolution.has_method("connect_words"):
                word_seed_evolution.connect_words(event.word_id_1, event.word_id_2)
        
        "camera_move":
            if player_controller and player_controller.has_method("teleport_to"):
                player_controller.teleport_to(event.position)
                if event.has("look_at"):
                    player_controller.look_at_point(event.look_at)
        
        "reality_shift":
            set_reality(event.reality)
        
        "zone_change":
            if zone_scale_system and player_controller and player_controller.has_method("teleport_to"):
                if zone_scale_system.active_zones.has(event.zone_id):
                    player_controller.teleport_to(zone_scale_system.active_zones[event.zone_id].position)
        
        "animation_start":
            start_animation(event.animation_id)
        
        "hologram_toggle":
            if event.has("word_id") and event.has("enabled"):
                toggle_word_hologram(event.word_id, event.enabled)
        
        "anime_character_toggle":
            if event.has("word_id") and event.has("enabled"):
                toggle_anime_character(event.word_id, event.enabled, event.get("character_type", "protagonist"))

# ----- SCENE GENERATION -----
func generate_scene():
    var old_scene = current_scene
    
    # Create a new scene based on current state
    var new_scene = {
        "id": "scene_" + str(randi()),
        "time": Time.get_ticks_msec() / 1000.0,
        "words": get_current_words(),
        "zones": get_current_zones(),
        "reality": current_reality,
        "story": get_current_story(),
        "characters": get_anime_characters_in_scene()
    }
    
    # Store the new scene
    current_scene = new_scene
    
    # Add to history, keeping a reasonable size
    scene_history.append(new_scene)
    if scene_history.size() > 20:  # Keep last 20 scenes
        scene_history.pop_front()
    
    # Emit signal
    emit_signal("scene_changed", old_scene, new_scene)

func get_current_words():
    if not word_seed_evolution or not word_seed_evolution.active_seeds:
        return []
    
    var words_data = []
    
    for word_id in word_seed_evolution.active_seeds:
        var word_data = word_seed_evolution.active_seeds[word_id]
        words_data.append({
            "id": word_id,
            "text": word_data.text,
            "position": word_data.position,
            "category": word_data.category,
            "evolution_stage": word_data.evolution_stage,
            "connections": word_data.connected_words
        })
    
    return words_data

func get_current_zones():
    if not zone_scale_system or not zone_scale_system.active_zones:
        return []
    
    var zones_data = []
    
    for zone_id in zone_scale_system.active_zones:
        var zone_data = zone_scale_system.active_zones[zone_id]
        zones_data.append({
            "id": zone_id,
            "position": zone_data.position,
            "radius": zone_data.radius,
            "scale_level": zone_data.scale_level,
            "zone_type": zone_scale_system.ZoneType.keys()[zone_data.zone_type],
            "time_zone": zone_data.properties.get("time_zone", "present") if zone_data.has("properties") else "present"
        })
    
    return zones_data

func get_current_story():
    if not word_seed_evolution or not word_seed_evolution.has_method("generate_story"):
        return ""
    
    return word_seed_evolution.generate_story()

func get_anime_characters_in_scene():
    if not words_in_space:
        return {}
    
    var characters = {}
    
    for word_id in words_in_space.get_all_words():
        var word_node = words_in_space.get_word_node(word_id)
        if word_node and word_node.get_meta("anime_character", false):
            var character_type = word_node.get_meta("character_type", "protagonist")
            
            characters[word_id] = {
                "type": character_type,
                "position": word_node.global_position,
                "text": words_in_space.get_word_text(word_id),
                "animation_state": word_node.get_meta("animation_state", "idle")
            }
    
    return characters

func _on_scene_timer_timeout():
    if auto_scene_generation:
        generate_scene()

# ----- ANIMATION CONTROL -----
func start_animation(animation_id):
    if not active_animations.has(animation_id):
        return
    
    var animation_data = active_animations[animation_id]
    animation_data.elapsed_time = 0.0
    
    # If this is a sequence start, also initialize next animations
    if animation_data.has("sequence_start") and animation_data.sequence_start:
        initialize_animation_sequence(animation_id)
    
    emit_signal("animation_started", animation_id)

func initialize_animation_sequence(start_animation_id):
    if not active_animations.has(start_animation_id):
        return
    
    # Get the sequence of animations
    var current_id = start_animation_id
    var sequence = [current_id]
    
    while active_animations[current_id].has("next_animation") and active_animations[current_id].next_animation != "":
        current_id = active_animations[current_id].next_animation
        sequence.append(current_id)
    
    # Reset elapsed time for all animations in sequence
    for anim_id in sequence:
        if active_animations.has(anim_id):
            active_animations[anim_id].elapsed_time = 0.0

func create_animation(animation_id, type, duration, data):
    # Create an animation with the given properties
    var animation_data = data.duplicate()
    animation_data.type = type
    animation_data.duration = duration
    animation_data.elapsed_time = 0.0
    
    # Store the animation
    active_animations[animation_id] = animation_data
    
    return animation_id

func create_animation_sequence(base_id, animations):
    if animations.size() == 0:
        return ""
    
    # Create each animation in the sequence
    var previous_id = ""
    var first_id = ""
    
    for i in range(animations.size()):
        var anim = animations[i]
        var anim_id = base_id + "_" + str(i)
        
        # Create this animation
        create_animation(anim_id, anim.type, anim.duration, anim)
        
        # Set as sequence start if first
        if i == 0:
            active_animations[anim_id].sequence_start = true
            first_id = anim_id
        
        # Link to previous animation
        if previous_id != "":
            active_animations[previous_id].next_animation = anim_id
        
        previous_id = anim_id
    
    return first_id

func create_animation_timeline(timeline_name, events):
    # Clear any existing timeline
    animation_timeline.clear()
    current_animation_time = 0.0
    current_timeline_name = timeline_name
    
    # Add all events to the timeline
    for event in events:
        animation_timeline.append(event)
    
    # Sort events by time
    animation_timeline.sort_custom(func(a, b): return a.time < b.time)
    
    return timeline_name

func start_animation_replay(loop = false):
    replay_mode = true
    event_loop_enabled = loop
    current_animation_time = 0.0
    
    # Reset execution flags
    for event in animation_timeline:
        event.erase("executed")
    
    # Log replay start
    if console and console.has_method("log"):
        console.log("Starting animation replay: " + current_timeline_name, Color(0.9, 0.5, 0.9))

func reset_animation_timeline():
    current_animation_time = 0.0
    
    # Reset execution flags
    for event in animation_timeline:
        event.erase("executed")

# ----- REALITY CONTROL -----
func set_reality(reality_name):
    # Store previous reality
    var old_reality = current_reality
    current_reality = reality_name
    
    # Apply reality-specific settings
    match reality_name:
        "physical":
            apply_physical_reality()
        "digital":
            apply_digital_reality()
        "astral":
            apply_astral_reality()
        _:
            apply_physical_reality()
    
    # Log reality change
    if console and console.has_method("log"):
        console.log("Reality shifted to: " + reality_name, Color(0.9, 0.7, 0.2))

func apply_physical_reality():
    # Set environment properties for physical reality
    var environment = get_viewport().get_camera_3d().environment
    if environment:
        environment.background_color = Color(0.05, 0.05, 0.1)
        environment.ambient_light_color = Color(0.3, 0.3, 0.4)
        environment.fog_enabled = true
        environment.fog_density = 0.01
        environment.fog_light_color = Color(0.1, 0.1, 0.2)
    
    # Adjust word appearance if possible
    if words_in_space and words_in_space.has_method("set_global_glow_intensity"):
        words_in_space.set_global_glow_intensity(0.3)

func apply_digital_reality():
    # Set environment properties for digital reality
    var environment = get_viewport().get_camera_3d().environment
    if environment:
        environment.background_color = Color(0.02, 0.08, 0.02)
        environment.ambient_light_color = Color(0.2, 0.4, 0.2)
        environment.fog_enabled = true
        environment.fog_density = 0.02
        environment.fog_light_color = Color(0.05, 0.15, 0.05)
    
    # Adjust word appearance if possible
    if words_in_space and words_in_space.has_method("set_global_glow_intensity"):
        words_in_space.set_global_glow_intensity(0.6)

func apply_astral_reality():
    # Set environment properties for astral reality
    var environment = get_viewport().get_camera_3d().environment
    if environment:
        environment.background_color = Color(0.1, 0.05, 0.15)
        environment.ambient_light_color = Color(0.4, 0.2, 0.5)
        environment.fog_enabled = true
        environment.fog_density = 0.015
        environment.fog_light_color = Color(0.2, 0.1, 0.3)
    
    # Adjust word appearance if possible
    if words_in_space and words_in_space.has_method("set_global_glow_intensity"):
        words_in_space.set_global_glow_intensity(0.8)

# ----- HOLOGRAM SYSTEM -----
func create_word_hologram(word_id):
    if not hologram_system or not words_in_space:
        return ""
    
    # Get the word node
    var word_node = words_in_space.get_word_node(word_id)
    if not word_node:
        return ""
    
    # Create hologram mesh instance
    var hologram = MeshInstance3D.new()
    hologram.name = "Hologram_" + word_id
    hologram_system.add_child(hologram)
    
    # Create a box mesh slightly larger than the word
    var word_aabb = words_in_space.get_word_aabb(word_id)
    var box_mesh = BoxMesh.new()
    box_mesh.size = word_aabb.size * 1.1
    hologram.mesh = box_mesh
    
    # Apply hologram material
    hologram.material_override = hologram_system.get_meta("hologram_material")
    
    # Position hologram at word position
    hologram.global_position = word_node.global_position
    
    # Store reference to word ID and original scale
    hologram.set_meta("word_id", word_id)
    hologram.set_meta("base_scale", hologram.scale)
    hologram.set_meta("pulse_speed", randf_range(0.8, 1.5))
    hologram.set_meta("pulse_amount", randf_range(0.03, 0.08))
    
    # Generate hologram ID
    var hologram_id = "hologram_" + word_id
    
    # Emit signal
    emit_signal("hologram_created", hologram_id, word_id)
    
    return hologram_id

func toggle_word_hologram(word_id, enabled):
    if not hologram_system:
        return
    
    # Find hologram for this word
    for i in range(hologram_system.get_child_count()):
        var hologram = hologram_system.get_child(i)
        if hologram.get_meta("word_id", "") == word_id:
            hologram.visible = enabled
            return

# ----- ANIME CHARACTER SYSTEM -----
func apply_anime_style_to_word(word_id):
    if not words_in_space:
        return
    
    # Get the word node
    var word_node = words_in_space.get_word_node(word_id)
    if not word_node:
        return
    
    # Determine character type based on word properties
    var character_type = determine_anime_character_type(word_id)
    
    # Get character template
    if not anime_characters.has(character_type):
        character_type = "support"  # Default
    
    var template = anime_characters[character_type]
    
    # Apply anime styling
    word_node.set_meta("anime_character", true)
    word_node.set_meta("character_type", character_type)
    word_node.set_meta("animation_state", "idle")
    
    # Apply visual styling
    if words_in_space.has_method("set_word_color"):
        words_in_space.set_word_color(word_id, template.color_scheme)
    
    if words_in_space.has_method("set_word_scale"):
        words_in_space.set_word_scale(word_id, template.scale)
    
    # Configure billboard mode
    if anime_2d_billboard_mode:
        word_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        word_node.position += template.billboard_offset
    
    # Emit signal
    emit_signal("anime_character_created", word_id, {
        "word_id": word_id,
        "character_type": character_type,
        "animation_set": template.animation_set
    })
    
    return character_type

func determine_anime_character_type(word_id):
    if not word_seed_evolution or not word_seed_evolution.active_seeds or not word_seed_evolution.active_seeds.has(word_id):
        return "support"
    
    var word_data = word_seed_evolution.active_seeds[word_id]
    var word_text = word_data.text.to_lower()
    
    # Check for protagonist keywords
    var protagonist_words = ["hero", "protagonist", "main", "champion", "warrior", "leader", "chosen"]
    for keyword in protagonist_words:
        if word_text.find(keyword) >= 0:
            return "protagonist"
    
    # Check for antagonist keywords
    var antagonist_words = ["villain", "enemy", "evil", "dark", "shadow", "demon", "monster"]
    for keyword in antagonist_words:
        if word_text.find(keyword) >= 0:
            return "antagonist"
    
    # Check for location keywords
    var location_words = ["world", "realm", "dimension", "castle", "city", "forest", "mountain"]
    for keyword in location_words:
        if word_text.find(keyword) >= 0:
            return "location"
    
    # Check for object keywords
    var object_words = ["sword", "staff", "book", "artifact", "crystal", "relic", "orb"]
    for keyword in object_words:
        if word_text.find(keyword) >= 0:
            return "object"
    
    # Default to support character
    return "support"

func toggle_anime_character(word_id, enabled, character_type = "protagonist"):
    if not words_in_space:
        return
    
    # Get the word node
    var word_node = words_in_space.get_word_node(word_id)
    if not word_node:
        return
    
    if enabled:
        # Apply anime character styling
        apply_anime_style_to_word(word_id)
    else:
        # Remove anime styling
        word_node.set_meta("anime_character", false)
        
        # Reset visual styling
        if words_in_space.has_method("reset_word_appearance"):
            words_in_space.reset_word_appearance(word_id)
        
        # Disable billboard mode
        if anime_2d_billboard_mode:
            word_node.billboard = BaseMaterial3D.BILLBOARD_DISABLED

# ----- TIME ZONE CALIBRATION -----
func calibrate_time_zone(zone_id, settings):
    if not zone_scale_system or not zone_scale_system.active_zones.has(zone_id):
        return false
    
    var zone_data = zone_scale_system.active_zones[zone_id]
    
    # Apply calibration settings
    if settings.has("time_offset"):
        zone_data.properties.time_offset = settings.time_offset
    
    if settings.has("evolution_factor"):
        zone_data.evolution_factor = settings.evolution_factor
    
    if settings.has("destruction_factor"):
        zone_data.destruction_factor = settings.destruction_factor
    
    if settings.has("manifestation_factor"):
        zone_data.manifestation_factor = settings.manifestation_factor
    
    if settings.has("time_dilation"):
        zone_data.time_dilation = settings.time_dilation
    
    # Update time zone registry
    if zone_data.properties.has("time_zone"):
        time_zones[zone_data.properties.time_zone] = zone_id
    
    # Apply visual updates if needed
    if time_zone_visualization and zone_scale_system.visualization_enabled:
        update_time_zone_visualization(zone_id)
    
    # Emit signal
    emit_signal("time_zone_calibrated", zone_id, settings)
    
    return true

func update_time_zone_visualization(zone_id):
    if not zone_scale_system or not zone_scale_system.visualization_enabled:
        return
    
    if not zone_scale_system.zone_visualization_nodes.has(zone_id):
        return
    
    var zone_node = zone_scale_system.zone_visualization_nodes[zone_id]
    var zone_data = zone_scale_system.active_zones[zone_id]
    
    # Update mesh appearance
    var mesh = zone_node.get_node("BoundaryMesh")
    if mesh and mesh.material_override:
        # Adjust glow based on time zone properties
        var time_factor = 1.0
        if zone_data.properties.has("time_offset"):
            time_factor = abs(zone_data.properties.time_offset) / 100.0
        
        # Set glow intensity
        var base_color = mesh.material_override.albedo_color
        mesh.material_override.emission = base_color
        mesh.material_override.emission_energy_multiplier = zone_glow_intensity * (1.0 + time_factor)
        
        # Make future zones more transparent
        if zone_data.properties.has("time_zone") and zone_data.properties.time_zone == "future":
            var color = mesh.material_override.albedo_color
            mesh.material_override.albedo_color = Color(color.r, color.g, color.b, 0.08)
    
    # Update label text
    var label = zone_node.get_node("ZoneLabel")
    if label:
        var zone_type_name = zone_scale_system.ZoneType.keys()[zone_data.zone_type].capitalize()
        var time_info = ""
        
        if zone_data.properties.has("time_zone"):
            time_info = "\nTime Zone: " + zone_data.properties.time_zone.capitalize()
            
            if zone_data.properties.has("time_offset"):
                var offset = zone_data.properties.time_offset
                var sign = "+" if offset >= 0 else ""
                time_info += " (" + sign + str(offset) + ")"
        
        label.text = zone_data.scale_level.capitalize() + " " + zone_type_name + " Zone" + time_info

# ----- GAME MODE CONTROL -----
func set_game_mode(mode):
    if mode == current_game_mode:
        return
    
    var old_mode = current_game_mode
    current_game_mode = mode
    
    # Apply mode-specific settings
    match mode:
        "exploration":
            # Standard exploration mode
            if player_controller:
                player_controller.set_movement_enabled(true)
            
            # Stop any replay
            replay_mode = false
        
        "calibration":
            # Time zone calibration mode
            if player_controller:
                player_controller.set_movement_enabled(true)
            
            # Highlight time zones
            highlight_time_zones(true)
        
        "animation":
            # Animation/replay mode
            if player_controller:
                player_controller.set_movement_enabled(false)
        
        "writing":
            # Word creation mode
            if player_controller:
                player_controller.set_movement_enabled(true)
    
    # Clean up previous mode
    match old_mode:
        "calibration":
            highlight_time_zones(false)
    
    # Emit signal
    emit_signal("game_mode_changed", old_mode, current_game_mode)
    
    # Log mode change
    if console and console.has_method("log"):
        console.log("Game mode changed to: " + mode, Color(0.3, 0.9, 0.6))

func highlight_time_zones(enabled):
    if not zone_scale_system or not time_zones:
        return
    
    for time_zone_name in time_zones:
        var zone_id = time_zones[time_zone_name]
        
        if zone_scale_system.zone_visualization_nodes.has(zone_id):
            var zone_node = zone_scale_system.zone_visualization_nodes[zone_id]
            var mesh = zone_node.get_node("BoundaryMesh")
            
            if mesh and mesh.material_override:
                if enabled:
                    # Increase glow for highlight
                    mesh.material_override.emission_energy_multiplier = zone_glow_intensity * 2.0
                else:
                    # Reset to normal
                    mesh.material_override.emission_energy_multiplier = zone_glow_intensity

# ----- EVENT HANDLERS -----
func _on_zone_created(zone_id, zone_data):
    # If this zone has time_zone property, add it to our registry
    if zone_data.properties.has("time_zone"):
        time_zones[zone_data.properties.time_zone] = zone_id
    
    # Check for eternal creation zone
    if zone_data.properties.has("eternal_creation") and zone_data.properties.eternal_creation:
        if not eternal_creation_zones.has(zone_id):
            eternal_creation_zones.append(zone_id)

func _on_player_entered_zone(zone_id):
    if not zone_scale_system or not zone_scale_system.active_zones.has(zone_id):
        return
    
    var zone_data = zone_scale_system.active_zones[zone_id]
    
    # Notify about entered zone
    if console and console.has_method("log"):
        var zone_type_name = zone_scale_system.ZoneType.keys()[zone_data.zone_type].capitalize()
        
        var zone_info = zone_data.scale_level.capitalize() + " " + zone_type_name + " Zone"
        if zone_data.properties.has("time_zone"):
            zone_info += " (" + zone_data.properties.time_zone.capitalize() + ")"
        
        console.log("Entered: " + zone_info, Color(0.4, 0.8, 1.0))

func _on_scale_transition(from_scale, to_scale, progress):
    # Apply scale transition effects
    if progress == 0.0:
        # Transition starting
        if console and console.has_method("log"):
            console.log("Scale transition: " + from_scale + " → " + to_scale, Color(0.9, 0.6, 0.9))
        
        # Randomly evolve some words during dramatic scale transitions
        var scale_index_from = zone_scale_system.scale_levels.find(from_scale)
        var scale_index_to = zone_scale_system.scale_levels.find(to_scale)
        
        if abs(scale_index_from - scale_index_to) >= 3:  # Big scale jump
            if word_seed_evolution:
                zone_scale_system.trigger_random_evolutions(3)
    
    elif progress >= 1.0:
        # Transition completed
        if to_scale == "quantum" and from_scale != "micro":
            # Special effect when reaching quantum scale from a much larger scale
            if console and console.has_method("log"):
                console.log("Quantum effects becoming visible...", Color(0.8, 0.3, 0.8))
            
            # Create some quantum particles if in eternal creation zone
            if zone_scale_system.get_current_zone_id() in eternal_creation_zones:
                for i in range(5):
                    manifest_random_word_in_zone(zone_scale_system.get_current_zone_id())
        
        elif to_scale == "cosmic" and from_scale != "galactic":
            # Special effect when reaching cosmic scale from a much smaller scale
            if console and console.has_method("log"):
                console.log("Cosmic perspective achieved...", Color(0.3, 0.3, 0.9))

func _on_word_evolved(word_id, from_stage, to_stage, new_dna):
    # Update anime styling if this is an anime character
    if words_in_space:
        var word_node = words_in_space.get_word_node(word_id)
        if word_node and word_node.get_meta("anime_character", false):
            # Re-apply anime styling with the new evolution
            apply_anime_style_to_word(word_id)
    
    # Update hologram if it exists
    toggle_word_hologram(word_id, true)

func _on_story_updated(story_text):
    # Generate a new scene when story updates
    generate_scene()

# ----- PUBLIC API -----
func create_time_zone(name, position, scale_level, time_offset, properties = {}):
    if not zone_scale_system:
        return ""
    
    # Create properties for time zone
    var zone_properties = properties.duplicate()
    zone_properties.time_zone = name
    zone_properties.time_offset = time_offset
    
    # Determine zone type based on time offset
    var zone_type = "STABLE"  # Default
    
    if time_offset < 0:
        zone_type = "SLOWED"  # Past is slower
    elif time_offset > 0:
        zone_type = "ACCELERATED"  # Future is faster
    
    # Create the zone
    var zone_id = zone_scale_system.create_custom_zone(
        position,
        10.0,  # Default radius
        scale_level,
        zone_type,
        zone_properties
    )
    
    if zone_id != "":
        # Register the time zone
        time_zones[name] = zone_id
        
        # Apply time zone visualization
        if time_zone_visualization:
            update_time_zone_visualization(zone_id)
    
    return zone_id

func create_anime_scene(position, words, connections = []):
    if not word_seed_evolution or not zone_scale_system:
        return []
    
    # Create an anime zone if one doesn't exist
    var anime_zone_id = ""
    if time_zones.has("anime"):
        anime_zone_id = time_zones.anime
    else:
        anime_zone_id = zone_scale_system.create_custom_zone(
            position,
            15.0,
            "object",
            "SHIFTING",
            {"time_zone": "anime", "anime": true}
        )
        time_zones.anime = anime_zone_id
    
    var zone_position = zone_scale_system.active_zones[anime_zone_id].position
    
    # Calculate positions in a circular pattern around zone center
    var created_words = []
    var radius = 5.0
    var angle_step = 2 * PI / words.size()
    
    for i in range(words.size()):
        var angle = angle_step * i
        var word_pos = zone_position + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        
        # Plant the word
        var word_id = word_seed_evolution.plant_seed(words[i], word_pos)
        
        if word_id != "":
            created_words.append(word_id)
            
            # Apply anime styling
            apply_anime_style_to_word(word_id)
    
    # Create connections
    for connection in connections:
        if connection.size() >= 2:
            var from_idx = connection[0]
            var to_idx = connection[1]
            
            if from_idx < created_words.size() and to_idx < created_words.size():
                word_seed_evolution.connect_words(created_words[from_idx], created_words[to_idx])
    
    return created_words

func set_animation_speed(speed):
    animation_speed = clamp(speed, 0.1, 5.0)
    
    if console and console.has_method("log"):
        console.log("Animation speed set to " + str(animation_speed) + "x", Color(0.7, 0.7, 0.2))

func toggle_eternal_creation(enabled):
    # Enable or disable eternal creation in all eternal zones
    for zone_id in eternal_creation_zones:
        if zone_scale_system and zone_scale_system.active_zones.has(zone_id):
            var zone_data = zone_scale_system.active_zones[zone_id]
            zone_data.properties.eternal_creation = enabled
            
            if enabled:
                zone_data.manifestation_factor = 2.0
            else:
                zone_data.manifestation_factor = 0.5
    
    if console and console.has_method("log"):
        if enabled:
            console.log("Eternal creation enabled", Color(0.3, 0.9, 0.3))
        else:
            console.log("Eternal creation disabled", Color(0.9, 0.3, 0.3))

func add_persistent_word(word_id):
    if not persistent_words.has(word_id):
        persistent_words.append(word_id)
        
        if console and console.has_method("log"):
            if word_seed_evolution and word_seed_evolution.active_seeds.has(word_id):
                var word_text = word_seed_evolution.active_seeds[word_id].text
                console.log("'" + word_text + "' added to persistent words", Color(0.3, 0.8, 0.8))

func remove_persistent_word(word_id):
    if persistent_words.has(word_id):
        persistent_words.erase(word_id)
        
        if console and console.has_method("log"):
            if word_seed_evolution and word_seed_evolution.active_seeds.has(word_id):
                var word_text = word_seed_evolution.active_seeds[word_id].text
                console.log("'" + word_text + "' removed from persistent words", Color(0.8, 0.3, 0.3))
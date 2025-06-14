extends Node3D

class_name ZoneScaleSystem

# ----- SCALE ZONE SETTINGS -----
@export_category("Scale Zone Settings")
@export var zones_enabled: bool = true
@export var visualization_enabled: bool = true
@export var transition_smoothing: float = 0.8
@export var update_frequency: float = 0.5  # Seconds between zone updates

# ----- SCALE DEFINITIONS -----
@export_category("Scale Definitions")
@export var scale_levels: Array[String] = [
    "quantum",     # Subatomic scale
    "micro",       # Microscopic
    "object",      # Human-scale objects
    "human",       # Human-scale environment
    "city",        # City-scale
    "planetary",   # Planetary scale
    "stellar",     # Star system scale
    "galactic",    # Galaxy scale
    "cosmic"       # Universal scale
]

# ----- ZONE TYPES -----
enum ZoneType {
    STABLE,        # Slow evolution, high stability
    CHAOTIC,       # Fast evolution, high instability
    CREATIVE,      # High manifestation rate, medium stability
    DESTRUCTIVE,   # High destruction rate, low stability
    ACCELERATED,   # Time flows faster
    SLOWED,        # Time flows slower
    SHIFTING,      # Properties change over time
    TRANSITIONAL,  # Between other zone types
    VOID           # Empty space, no manifestation
}

# ----- COMPONENT REFERENCES -----
var word_seed_evolution: Node
var world_of_words: Node
var player_controller: Node

# ----- ZONE DATA -----
var active_zones: Dictionary = {}  # zone_id -> zone_data
var current_player_zone: String = ""
var zone_visualization_nodes: Dictionary = {}  # zone_id -> visualization_node
var zone_timer: Timer
var global_time_scale: float = 1.0

# ----- SIGNALS -----
signal zone_created(zone_id, zone_data)
signal zone_changed(old_zone_id, new_zone_id)
signal zone_properties_updated(zone_id, properties)
signal player_entered_zone(zone_id)
signal player_exited_zone(zone_id)
signal scale_transition(from_scale, to_scale, progress)

# ----- INITIALIZATION -----
func _ready():
    # Create zone update timer
    zone_timer = Timer.new()
    zone_timer.wait_time = update_frequency
    zone_timer.one_shot = false
    zone_timer.timeout.connect(_on_zone_timer_timeout)
    add_child(zone_timer)
    
    if zones_enabled:
        zone_timer.start()
        
        # Create initial zones if none exist
        if active_zones.size() == 0:
            create_initial_zones()

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
    if zones_enabled and player_controller:
        # Check player position and update current zone
        update_player_zone()
        
        # Apply zone effects based on current zone
        apply_zone_effects(delta)

# ----- ZONE CREATION -----
func create_zone(position: Vector3, radius: float, scale_level: String, zone_type: ZoneType, properties: Dictionary = {}) -> String:
    # Generate unique zone ID
    var zone_id = "zone_" + str(randi())
    
    # Validate scale level
    if not scale_level in scale_levels:
        scale_level = "human"  # Default to human scale
    
    # Set default evolution factor based on zone type
    var evolution_factor = 1.0
    var destruction_factor = 1.0
    var manifestation_factor = 1.0
    var time_dilation = 1.0
    
    match zone_type:
        ZoneType.STABLE:
            evolution_factor = 0.5
            destruction_factor = 0.2
            manifestation_factor = 0.7
            time_dilation = 1.0
        ZoneType.CHAOTIC:
            evolution_factor = 2.0
            destruction_factor = 1.5
            manifestation_factor = 1.8
            time_dilation = 1.2
        ZoneType.CREATIVE:
            evolution_factor = 1.2
            destruction_factor = 0.5
            manifestation_factor = 2.0
            time_dilation = 1.1
        ZoneType.DESTRUCTIVE:
            evolution_factor = 0.8
            destruction_factor = 2.5
            manifestation_factor = 0.4
            time_dilation = 0.9
        ZoneType.ACCELERATED:
            evolution_factor = 1.5
            destruction_factor = 1.5
            manifestation_factor = 1.5
            time_dilation = 2.0
        ZoneType.SLOWED:
            evolution_factor = 0.5
            destruction_factor = 0.5
            manifestation_factor = 0.5
            time_dilation = 0.5
        ZoneType.SHIFTING:
            evolution_factor = 1.0 + sin(Time.get_ticks_msec() / 1000.0) * 0.5
            destruction_factor = 1.0 + cos(Time.get_ticks_msec() / 1000.0) * 0.5
            manifestation_factor = 1.0 + sin(Time.get_ticks_msec() / 1000.0 + PI/2) * 0.5
            time_dilation = 1.0 + sin(Time.get_ticks_msec() / 2000.0) * 0.3
        ZoneType.TRANSITIONAL:
            evolution_factor = 1.0
            destruction_factor = 1.0
            manifestation_factor = 1.0
            time_dilation = 1.0
        ZoneType.VOID:
            evolution_factor = 0.1
            destruction_factor = 5.0
            manifestation_factor = 0.1
            time_dilation = 0.7
    
    # Apply scale level modifiers
    var scale_index = scale_levels.find(scale_level)
    var scale_modifier = 1.0
    
    if scale_index >= 0:
        # Quantum scales have faster evolution but higher instability
        if scale_index <= 1:  # quantum or micro
            evolution_factor *= 2.0
            destruction_factor *= 1.5
            time_dilation *= 0.5
        # Human-scale is the baseline
        elif scale_index >= 2 and scale_index <= 4:  # object, human, city
            evolution_factor *= 1.0
            destruction_factor *= 1.0
            time_dilation *= 1.0
        # Cosmic scales evolve slower but are more stable
        else:  # planetary, stellar, galactic, cosmic
            evolution_factor *= 0.5
            destruction_factor *= 0.7
            time_dilation *= 2.0
    
    # Create zone data
    var zone_data = {
        "position": position,
        "radius": radius,
        "scale_level": scale_level,
        "zone_type": zone_type,
        "creation_time": Time.get_ticks_msec() / 1000.0,
        "evolution_factor": evolution_factor,
        "destruction_factor": destruction_factor,
        "manifestation_factor": manifestation_factor,
        "time_dilation": time_dilation,
        "contained_words": [],
        "properties": properties,
        "connected_zones": [],
        "last_update_time": Time.get_ticks_msec() / 1000.0
    }
    
    # Store zone data
    active_zones[zone_id] = zone_data
    
    # Create visualization if enabled
    if visualization_enabled:
        create_zone_visualization(zone_id)
    
    # Emit signal
    emit_signal("zone_created", zone_id, zone_data)
    
    return zone_id

func create_initial_zones():
    # Create a central human-scale zone
    create_zone(Vector3.ZERO, 15.0, "human", ZoneType.STABLE)
    
    # Create various zones at different positions
    create_zone(Vector3(30, 0, 0), 10.0, "micro", ZoneType.CHAOTIC)
    create_zone(Vector3(-30, 0, 0), 10.0, "city", ZoneType.CREATIVE)
    create_zone(Vector3(0, 0, 30), 10.0, "quantum", ZoneType.SHIFTING)
    create_zone(Vector3(0, 0, -30), 10.0, "stellar", ZoneType.SLOWED)
    create_zone(Vector3(0, 30, 0), 10.0, "cosmic", ZoneType.ACCELERATED)
    create_zone(Vector3(0, -30, 0), 10.0, "object", ZoneType.VOID)
    
    # Create some transitional zones between primary zones
    create_zone(Vector3(15, 0, 15), 5.0, "human", ZoneType.TRANSITIONAL)
    create_zone(Vector3(-15, 0, -15), 5.0, "human", ZoneType.TRANSITIONAL)
    
    # Connect adjacent zones
    connect_adjacent_zones()

func create_zone_visualization(zone_id: String):
    if not active_zones.has(zone_id):
        return
    
    var zone_data = active_zones[zone_id]
    
    # Create visualization node
    var visualization = Node3D.new()
    visualization.name = "ZoneVisualization_" + zone_id
    add_child(visualization)
    
    # Create sphere mesh to represent zone boundary
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = zone_data.radius
    sphere_mesh.height = zone_data.radius * 2
    
    # Create mesh instance
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "BoundaryMesh"
    mesh_instance.mesh = sphere_mesh
    visualization.add_child(mesh_instance)
    
    # Create material for zone visualization
    var material = StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = get_zone_color(zone_data.zone_type, zone_data.scale_level)
    material.emission_enabled = true
    material.emission = material.albedo_color
    material.emission_energy_multiplier = 0.3
    mesh_instance.material_override = material
    
    # Add label for zone info
    var label_3d = Label3D.new()
    label_3d.name = "ZoneLabel"
    label_3d.text = get_zone_description(zone_id)
    label_3d.font_size = 12
    label_3d.no_depth_test = true
    label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label_3d.position.y = zone_data.radius + 1.0
    visualization.add_child(label_3d)
    
    # Position the visualization
    visualization.global_position = zone_data.position
    
    # Store reference to visualization
    zone_visualization_nodes[zone_id] = visualization

func get_zone_color(zone_type: ZoneType, scale_level: String) -> Color:
    # Base color from zone type
    var base_color = Color(0.5, 0.5, 0.5, 0.2)  # Default: grey, translucent
    
    match zone_type:
        ZoneType.STABLE:
            base_color = Color(0.2, 0.6, 0.9, 0.15)  # Blue
        ZoneType.CHAOTIC:
            base_color = Color(1.0, 0.4, 0.1, 0.15)  # Orange
        ZoneType.CREATIVE:
            base_color = Color(0.2, 0.9, 0.4, 0.15)  # Green
        ZoneType.DESTRUCTIVE:
            base_color = Color(0.9, 0.2, 0.2, 0.15)  # Red
        ZoneType.ACCELERATED:
            base_color = Color(0.9, 0.9, 0.2, 0.15)  # Yellow
        ZoneType.SLOWED:
            base_color = Color(0.6, 0.3, 0.9, 0.15)  # Purple
        ZoneType.SHIFTING:
            base_color = Color(0.9, 0.5, 0.9, 0.15)  # Pink
        ZoneType.TRANSITIONAL:
            base_color = Color(0.7, 0.7, 0.7, 0.1)   # Light grey
        ZoneType.VOID:
            base_color = Color(0.1, 0.1, 0.1, 0.05)  # Dark grey, very transparent
    
    # Adjust saturation based on scale level
    var scale_index = scale_levels.find(scale_level)
    if scale_index >= 0:
        var scale_factor = float(scale_index) / float(scale_levels.size() - 1)
        
        # Make quantum scales more vibrant, cosmic scales more subdued
        var h = base_color.h
        var s = base_color.s
        var v = base_color.v
        
        if scale_index <= 1:  # quantum, micro
            s = min(s * 1.3, 1.0)
            v = min(v * 1.2, 1.0)
        elif scale_index >= 7:  # galactic, cosmic
            s *= 0.8
            v *= 0.9
    
    return base_color

func get_zone_description(zone_id: String) -> String:
    if not active_zones.has(zone_id):
        return "Unknown Zone"
    
    var zone_data = active_zones[zone_id]
    var zone_type_name = ZoneType.keys()[zone_data.zone_type].capitalize()
    
    return zone_data.scale_level.capitalize() + " " + zone_type_name + " Zone\n" + \
           "Evolution: " + str(snapped(zone_data.evolution_factor, 0.1)) + "x\n" + \
           "Time Flow: " + str(snapped(zone_data.time_dilation, 0.1)) + "x"

func connect_adjacent_zones():
    # Find zones that are close to each other and connect them
    var zone_ids = active_zones.keys()
    
    for i in range(zone_ids.size()):
        var zone_id_a = zone_ids[i]
        
        for j in range(i + 1, zone_ids.size()):
            var zone_id_b = zone_ids[j]
            
            var zone_a = active_zones[zone_id_a]
            var zone_b = active_zones[zone_id_b]
            
            var distance = zone_a.position.distance_to(zone_b.position)
            var connection_threshold = zone_a.radius + zone_b.radius + 5.0
            
            if distance <= connection_threshold:
                # Connect the zones
                if not zone_id_b in zone_a.connected_zones:
                    zone_a.connected_zones.append(zone_id_b)
                
                if not zone_id_a in zone_b.connected_zones:
                    zone_b.connected_zones.append(zone_id_a)
                
                # Create visual connection if visualization is enabled
                if visualization_enabled:
                    create_zone_connection_visualization(zone_id_a, zone_id_b)

func create_zone_connection_visualization(zone_id_a: String, zone_id_b: String):
    if not zone_visualization_nodes.has(zone_id_a) or not zone_visualization_nodes.has(zone_id_b):
        return
    
    var node_a = zone_visualization_nodes[zone_id_a]
    var node_b = zone_visualization_nodes[zone_id_b]
    
    var mid_point = (node_a.global_position + node_b.global_position) / 2.0
    var connection_length = node_a.global_position.distance_to(node_b.global_position)
    var connection_direction = (node_b.global_position - node_a.global_position).normalized()
    
    # Create connection visualization
    var connection_node = Node3D.new()
    connection_node.name = "ZoneConnection_" + zone_id_a + "_" + zone_id_b
    add_child(connection_node)
    
    # Create cylinder mesh for connection
    var cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 0.2
    cylinder_mesh.bottom_radius = 0.2
    cylinder_mesh.height = connection_length
    
    # Create mesh instance
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "ConnectionMesh"
    mesh_instance.mesh = cylinder_mesh
    connection_node.add_child(mesh_instance)
    
    # Create material
    var material = StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = Color(0.8, 0.8, 0.8, 0.1)
    material.emission_enabled = true
    material.emission = Color(0.8, 0.8, 0.8)
    material.emission_energy_multiplier = 0.2
    mesh_instance.material_override = material
    
    # Position and rotate
    connection_node.global_position = mid_point
    connection_node.look_at(node_b.global_position, Vector3.UP)
    connection_node.rotate_object_local(Vector3.RIGHT, PI/2)  # Align cylinder with direction

# ----- ZONE MANAGEMENT -----
func update_player_zone():
    if not player_controller:
        return
    
    var player_position = player_controller.global_position
    var closest_zone_id = ""
    var closest_distance = INF
    
    # Find the zone containing the player
    for zone_id in active_zones:
        var zone_data = active_zones[zone_id]
        var distance = player_position.distance_to(zone_data.position)
        
        if distance <= zone_data.radius and distance < closest_distance:
            closest_zone_id = zone_id
            closest_distance = distance
    
    # Check if zone changed
    if closest_zone_id != current_player_zone:
        var old_zone_id = current_player_zone
        current_player_zone = closest_zone_id
        
        if old_zone_id != "":
            emit_signal("player_exited_zone", old_zone_id)
        
        if current_player_zone != "":
            emit_signal("player_entered_zone", current_player_zone)
            
            # Handle scale transitions
            if old_zone_id != "" and active_zones.has(old_zone_id) and active_zones.has(current_player_zone):
                var old_scale = active_zones[old_zone_id].scale_level
                var new_scale = active_zones[current_player_zone].scale_level
                
                if old_scale != new_scale:
                    handle_scale_transition(old_scale, new_scale)
        
        emit_signal("zone_changed", old_zone_id, current_player_zone)

func handle_scale_transition(old_scale: String, new_scale: String):
    var old_index = scale_levels.find(old_scale)
    var new_index = scale_levels.find(new_scale)
    
    if old_index < 0 or new_index < 0:
        return
    
    # Determine severity of transition based on how many scales we're jumping
    var transition_severity = abs(new_index - old_index)
    
    # Emit scale transition signal
    emit_signal("scale_transition", old_scale, new_scale, 0.0)
    
    # Create transition effects
    var transition_duration = 1.0 + transition_severity * 0.5  # Longer duration for bigger jumps
    
    # Start transition animation
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    
    # Update transition progress
    tween.tween_method(func(progress): 
        emit_signal("scale_transition", old_scale, new_scale, progress), 
        0.0, 1.0, transition_duration)
    
    # Apply visual effects for different scale transitions
    if word_seed_evolution and transition_severity >= 2:
        # For dramatic scale changes, evolve some words
        var evolution_count = min(3 * transition_severity, 10)
        trigger_random_evolutions(evolution_count)

func trigger_random_evolutions(count: int):
    if not word_seed_evolution or not word_seed_evolution.has_method("active_seeds"):
        return
    
    var active_seeds = word_seed_evolution.active_seeds
    if active_seeds.size() == 0:
        return
    
    # Get random words
    var word_ids = active_seeds.keys()
    word_ids.shuffle()
    
    # Evolve up to count words
    for i in range(min(count, word_ids.size())):
        if word_seed_evolution.has_method("_evolve_seed"):
            word_seed_evolution._evolve_seed(word_ids[i])

func apply_zone_effects(delta: float):
    if current_player_zone == "" or not active_zones.has(current_player_zone):
        # Default effects when not in any zone
        global_time_scale = 1.0
        return
    
    var zone_data = active_zones[current_player_zone]
    
    # Apply time dilation
    global_time_scale = lerp(global_time_scale, zone_data.time_dilation, delta * 2.0)
    
    # Apply zone-specific effects
    match zone_data.zone_type:
        ZoneType.SHIFTING:
            # Update shifting zone properties
            zone_data.evolution_factor = 1.0 + sin(Time.get_ticks_msec() / 1000.0) * 0.5
            zone_data.destruction_factor = 1.0 + cos(Time.get_ticks_msec() / 1000.0) * 0.5
            zone_data.time_dilation = 1.0 + sin(Time.get_ticks_msec() / 2000.0) * 0.3
            
            # Update visualization
            if visualization_enabled and zone_visualization_nodes.has(current_player_zone):
                var mesh = zone_visualization_nodes[current_player_zone].get_node("BoundaryMesh")
                if mesh and mesh.material_override:
                    var hue_shift = sin(Time.get_ticks_msec() / 1000.0) * 0.2
                    var base_color = get_zone_color(ZoneType.SHIFTING, zone_data.scale_level)
                    var shifted_color = base_color
                    shifted_color.h = fmod(shifted_color.h + hue_shift, 1.0)
                    mesh.material_override.albedo_color = shifted_color
                    mesh.material_override.emission = shifted_color
        
        ZoneType.VOID:
            # In void zones, small chance to delete words
            if word_seed_evolution and randf() < 0.01 * zone_data.destruction_factor * delta:
                delete_random_word_in_zone(current_player_zone)
        
        ZoneType.CREATIVE:
            # In creative zones, small chance to manifest new words
            if word_seed_evolution and randf() < 0.005 * zone_data.manifestation_factor * delta:
                manifest_random_word_in_zone(current_player_zone)

func delete_random_word_in_zone(zone_id: String):
    if not active_zones.has(zone_id) or not word_seed_evolution:
        return
    
    var zone_data = active_zones[zone_id]
    
    # Get words in this zone
    var words_in_zone = get_words_in_zone(zone_id)
    if words_in_zone.size() == 0:
        return
    
    # Pick a random word
    var word_id = words_in_zone[randi() % words_in_zone.size()]
    
    # Delete the word
    if word_seed_evolution.has_method("delete_word"):
        word_seed_evolution.delete_word(word_id)

func manifest_random_word_in_zone(zone_id: String):
    if not active_zones.has(zone_id) or not word_seed_evolution:
        return
    
    var zone_data = active_zones[zone_id]
    
    # Generate a random position within the zone
    var random_direction = Vector3(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
    var random_distance = randf() * zone_data.radius
    var position = zone_data.position + random_direction * random_distance
    
    # Generate a word based on zone scale
    var word_pool = get_word_pool_for_scale(zone_data.scale_level)
    var word_text = word_pool[randi() % word_pool.size()]
    
    # Plant the seed
    if word_seed_evolution.has_method("plant_seed"):
        word_seed_evolution.plant_seed(word_text, position)

func get_word_pool_for_scale(scale_level: String) -> Array:
    match scale_level:
        "quantum":
            return ["quark", "electron", "photon", "neutrino", "boson", "wave", "particle", "quantum", "string", "field"]
        "micro":
            return ["cell", "microbe", "atom", "molecule", "bacteria", "virus", "protein", "nucleus", "membrane", "dna"]
        "object":
            return ["cup", "book", "chair", "table", "device", "tool", "box", "screen", "paper", "pen"]
        "human":
            return ["person", "mind", "body", "emotion", "thought", "dream", "memory", "idea", "feeling", "concept"]
        "city":
            return ["building", "street", "plaza", "park", "market", "tower", "bridge", "station", "district", "garden"]
        "planetary":
            return ["continent", "ocean", "mountain", "desert", "forest", "river", "island", "atmosphere", "climate", "ecosystem"]
        "stellar":
            return ["star", "planet", "moon", "asteroid", "comet", "orbit", "gravity", "solar", "eclipse", "meteor"]
        "galactic":
            return ["galaxy", "nebula", "cluster", "blackhole", "spacetime", "supernova", "pulsar", "quasar", "void", "filament"]
        "cosmic":
            return ["universe", "multiverse", "dimension", "infinity", "creation", "existence", "eternity", "cosmos", "reality", "beyond"]
        _:
            return ["word", "text", "symbol", "sign", "letter", "meaning", "concept", "idea", "thought", "expression"]

func get_words_in_zone(zone_id: String) -> Array:
    if not active_zones.has(zone_id) or not word_seed_evolution or not word_seed_evolution.active_seeds:
        return []
    
    var zone_data = active_zones[zone_id]
    var active_seeds = word_seed_evolution.active_seeds
    var words_in_zone = []
    
    for word_id in active_seeds:
        var word_data = active_seeds[word_id]
        var word_position = word_data.position
        
        if word_position.distance_to(zone_data.position) <= zone_data.radius:
            words_in_zone.append(word_id)
    
    return words_in_zone

func _on_zone_timer_timeout():
    if not zones_enabled:
        return
    
    # Update zone properties
    for zone_id in active_zones:
        var zone_data = active_zones[zone_id]
        
        # Update contained words
        zone_data.contained_words = get_words_in_zone(zone_id)
        
        # Update shifting zones
        if zone_data.zone_type == ZoneType.SHIFTING:
            update_shifting_zone(zone_id)
        
        # Update visualizations
        if visualization_enabled and zone_visualization_nodes.has(zone_id):
            var label = zone_visualization_nodes[zone_id].get_node("ZoneLabel")
            if label:
                label.text = get_zone_description(zone_id)
        
        zone_data.last_update_time = Time.get_ticks_msec() / 1000.0

func update_shifting_zone(zone_id: String):
    if not active_zones.has(zone_id):
        return
    
    var zone_data = active_zones[zone_id]
    var time = Time.get_ticks_msec() / 1000.0
    
    # Update factors with sinusoidal patterns
    zone_data.evolution_factor = 1.0 + sin(time * 0.5) * 0.8
    zone_data.destruction_factor = 1.0 + cos(time * 0.3) * 0.6
    zone_data.manifestation_factor = 1.0 + sin(time * 0.7 + PI/4) * 0.7
    zone_data.time_dilation = 1.0 + sin(time * 0.2) * 0.4
    
    # Small chance to change zone type
    if randf() < 0.01:
        var new_type = randi() % ZoneType.size()
        if new_type != ZoneType.VOID:  # Avoid randomly becoming void
            zone_data.zone_type = new_type
            
            # Update visualization
            if visualization_enabled and zone_visualization_nodes.has(zone_id):
                var mesh = zone_visualization_nodes[zone_id].get_node("BoundaryMesh")
                if mesh and mesh.material_override:
                    mesh.material_override.albedo_color = get_zone_color(new_type, zone_data.scale_level)
                    mesh.material_override.emission = mesh.material_override.albedo_color
            
            emit_signal("zone_properties_updated", zone_id, zone_data)

# ----- PUBLIC API -----
func get_current_zone_id() -> String:
    return current_player_zone

func get_current_zone_data() -> Dictionary:
    if current_player_zone != "" and active_zones.has(current_player_zone):
        return active_zones[current_player_zone]
    return {}

func get_current_scale_level() -> String:
    var zone_data = get_current_zone_data()
    if zone_data.has("scale_level"):
        return zone_data.scale_level
    return "human"  # Default

func get_global_time_scale() -> float:
    return global_time_scale

func get_zone_evolution_factor(zone_id: String = "") -> float:
    if zone_id == "":
        zone_id = current_player_zone
    
    if zone_id != "" and active_zones.has(zone_id):
        return active_zones[zone_id].evolution_factor
    
    return 1.0  # Default

func set_references(word_seed_system, words_system, player):
    word_seed_evolution = word_seed_system
    world_of_words = words_system
    player_controller = player

func create_custom_zone(position: Vector3, radius: float, scale_level: String, zone_type_name: String, properties: Dictionary = {}) -> String:
    # Convert zone type name to enum
    var zone_type = ZoneType.STABLE  # Default
    
    for i in range(ZoneType.size()):
        if ZoneType.keys()[i].to_lower() == zone_type_name.to_lower():
            zone_type = i
            break
    
    return create_zone(position, radius, scale_level, zone_type, properties)

func delete_zone(zone_id: String) -> bool:
    if not active_zones.has(zone_id):
        return false
    
    # Remove connections
    for other_zone_id in active_zones:
        if other_zone_id != zone_id and zone_id in active_zones[other_zone_id].connected_zones:
            active_zones[other_zone_id].connected_zones.erase(zone_id)
    
    # Remove visualization
    if visualization_enabled and zone_visualization_nodes.has(zone_id):
        zone_visualization_nodes[zone_id].queue_free()
        zone_visualization_nodes.erase(zone_id)
    
    # Remove zone data
    active_zones.erase(zone_id)
    
    # Clear current zone if deleted
    if current_player_zone == zone_id:
        current_player_zone = ""
    
    return true
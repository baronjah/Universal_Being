extends Node3D

class_name Notepad3DPitopiaIntegration

# ----- NODE PATHS -----
@export_node_path var pitopia_main_path: NodePath
@export_node_path var word_manifestor_path: NodePath
@export_node_path var turn_system_path: NodePath
@export_node_path var ethereal_engine_path: NodePath
@export_node_path var dimension_system_path: NodePath
@export_node_path var console_path: NodePath

# ----- COMPONENT REFERENCES -----
var pitopia_main = null
var word_manifestor = null
var turn_system = null
var ethereal_engine = null
var dimension_system = null
var console = null

# ----- NOTEPAD3D SPECIFIC COMPONENTS -----
var word_parent: Node3D
var connection_parent: Node3D
var reality_parent: Node3D
var cyber_gate_parent: Node3D
var data_sewer_parent: Node3D

# ----- CONFIGURATION -----
@export var enable_reality_transitions: bool = true
@export var enable_cyber_gates: bool = true
@export var enable_data_sewers: bool = true
@export var enable_moon_phases: bool = true
@export var default_reality_type: String = "Physical"
@export var word_limit_per_dimension: int = 100
@export var auto_initialize: bool = true
@export_group("Visual Settings")
@export var word_font: Font
@export var word_material: StandardMaterial3D
@export var connection_material: StandardMaterial3D
@export var reality_transition_effect: PackedScene
@export var cyber_gate_effect: PackedScene
@export var data_sewer_effect: PackedScene
@export var moon_phase_indicator: PackedScene

# ----- STATE VARIABLES -----
var initialized: bool = false
var current_reality_type: String = "Physical"
var current_dimension: int = 3
var current_turn: int = 1
var current_symbol: String = "γ"
var current_moon_phase: int = 0
var reality_contexts = {}
var word_nodes = {}
var connection_nodes = {}
var active_gates = []
var active_sewers = []
var memory_tiers = {
    "tier1": [], # Recent memories (98% retention)
    "tier2": [], # Important memories (85% retention)
    "tier3": []  # Eternal memories (archived)
}

# ----- SIGNALS -----
signal integration_ready
signal reality_changed(new_reality, old_reality)
signal cyber_gate_opened(gate_id, source_reality, target_reality)
signal cyber_gate_closed(gate_id)
signal word_manifested(word, entity, reality_type, dimension)
signal word_connected(word1, word2, connection_type)
signal moon_phase_changed(new_phase, old_phase, stability_factor)
signal memory_stored(content, tier, retention)

# ----- INITIALIZATION -----
func _ready():
    if auto_initialize:
        initialize()

func initialize():
    print("Notepad3D Pitopia Integration initializing...")
    
    # Resolve component paths
    _resolve_component_paths()
    
    # Create necessary node structure
    _create_node_structure()
    
    # Initialize memory system
    _initialize_memory_system()
    
    # Connect to Pitopia systems
    _connect_to_pitopia()
    
    # Create initial reality context
    _create_initial_reality()
    
    # Set up moon phase system
    if enable_moon_phases:
        _initialize_moon_system()
    
    # Mark as initialized
    initialized = true
    emit_signal("integration_ready")
    
    print("Notepad3D Pitopia Integration ready")

func _resolve_component_paths():
    # Resolve Pitopia Main
    if pitopia_main_path:
        pitopia_main = get_node_or_null(pitopia_main_path)
    
    # Try to find in scene if not specified
    if not pitopia_main:
        pitopia_main = get_node_or_null("/root/PitopiaMain")
        if not pitopia_main:
            var nodes = get_tree().get_nodes_in_group("pitopia_main")
            if nodes.size() > 0:
                pitopia_main = nodes[0]
    
    # Resolve other components if specified
    if word_manifestor_path:
        word_manifestor = get_node_or_null(word_manifestor_path)
    
    if turn_system_path:
        turn_system = get_node_or_null(turn_system_path)
    
    if ethereal_engine_path:
        ethereal_engine = get_node_or_null(ethereal_engine_path)
    
    if dimension_system_path:
        dimension_system = get_node_or_null(dimension_system_path)
    
    if console_path:
        console = get_node_or_null(console_path)
    
    # Try to get components from Pitopia if available
    if pitopia_main:
        if not word_manifestor and pitopia_main.has_property("word_manifestor"):
            word_manifestor = pitopia_main.word_manifestor
        
        if not turn_system and pitopia_main.has_property("turn_system"):
            turn_system = pitopia_main.turn_system
        
        if not console and pitopia_main.has_property("console"):
            console = pitopia_main.console

func _create_node_structure():
    # Create parent nodes for organization
    word_parent = Node3D.new()
    word_parent.name = "WordEntities"
    add_child(word_parent)
    
    connection_parent = Node3D.new()
    connection_parent.name = "WordConnections"
    add_child(connection_parent)
    
    reality_parent = Node3D.new()
    reality_parent.name = "RealityContexts"
    add_child(reality_parent)
    
    if enable_cyber_gates:
        cyber_gate_parent = Node3D.new()
        cyber_gate_parent.name = "CyberGates"
        add_child(cyber_gate_parent)
    
    if enable_data_sewers:
        data_sewer_parent = Node3D.new()
        data_sewer_parent.name = "DataSewers"
        add_child(data_sewer_parent)

func _initialize_memory_system():
    # Initial setup of the three-tier memory system
    var memory_root = Node.new()
    memory_root.name = "MemorySystem"
    add_child(memory_root)
    
    # Create memory tier nodes
    for tier in memory_tiers.keys():
        var tier_node = Node.new()
        tier_node.name = tier.capitalize()
        memory_root.add_child(tier_node)

func _connect_to_pitopia():
    if pitopia_main:
        # Connect to Pitopia signals
        if pitopia_main.has_signal("word_manifested"):
            pitopia_main.connect("word_manifested", Callable(self, "_on_pitopia_word_manifested"))
        
        if pitopia_main.has_signal("dimension_changed"):
            pitopia_main.connect("dimension_changed", Callable(self, "_on_pitopia_dimension_changed"))
        
        if pitopia_main.has_signal("turn_advanced"):
            pitopia_main.connect("turn_advanced", Callable(self, "_on_pitopia_turn_advanced"))
        
        print("Connected to Pitopia Main")

func _create_initial_reality():
    # Create the initial reality context
    reality_contexts[default_reality_type] = {
        "words": {},
        "connections": {},
        "settings": {
            "gravity": Vector3(0, -9.8, 0),
            "ambient_light": Color(0.2, 0.2, 0.3),
            "fog_density": 0.01,
            "time_dilation": 1.0
        },
        "dimension_settings": {},
        "moon_phase_effects": {}
    }
    
    current_reality_type = default_reality_type
    print("Created initial reality context: " + current_reality_type)

func _initialize_moon_system():
    # Setup the moon phase system for gate stability
    for phase in range(8):
        var stability = _calculate_moon_phase_stability(phase)
        for reality_type in reality_contexts:
            reality_contexts[reality_type]["moon_phase_effects"][phase] = {
                "gate_stability": stability,
                "word_power_modifier": 1.0 + (stability - 0.5) * 0.4,
                "time_dilation": 1.0 + (stability - 0.5) * 0.2
            }
    
    # Create moon phase indicator if available
    if moon_phase_indicator:
        var indicator = moon_phase_indicator.instantiate()
        add_child(indicator)
        
        # Set initial phase
        if indicator.has_method("set_phase"):
            indicator.set_phase(current_moon_phase)
    
    print("Moon phase system initialized")

func _calculate_moon_phase_stability(phase: int) -> float:
    # Calculate gate stability based on moon phase (0-7)
    # Full moon (0) and new moon (4) are most stable
    var distance_from_stable = min(phase % 4, 4 - (phase % 4))
    return 1.0 - (distance_from_stable * 0.2)

# ----- WORD MANIFESTATION SYSTEM -----
func manifest_word(word: String, position = null) -> Object:
    # Check if within word limit for dimension
    var dimension_words = _get_words_in_current_reality_and_dimension()
    if dimension_words.size() >= word_limit_per_dimension:
        print("Word limit reached for dimension " + str(current_dimension) + " in reality " + current_reality_type)
        return null
    
    # Use Pitopia word manifestor if available
    var entity = null
    if pitopia_main and pitopia_main.has_method("manifest_word"):
        entity = pitopia_main.manifest_word(word)
    elif word_manifestor and word_manifestor.has_method("manifest_word"):
        entity = word_manifestor.manifest_word(word, position)
    
    # Apply current reality context and dimension properties
    if entity:
        _apply_reality_context_to_entity(entity, current_reality_type, current_dimension)
        
        # Track in current reality
        var word_id = entity.get_instance_id()
        reality_contexts[current_reality_type]["words"][word_id] = {
            "entity": entity,
            "word": word,
            "position": entity.global_position,
            "dimension": current_dimension,
            "power": _calculate_word_power(word)
        }
        
        # Create 3D visualization
        var word_node = _create_word_visualization(word, entity)
        word_nodes[word_id] = word_node
        
        # Emit signal
        emit_signal("word_manifested", word, entity, current_reality_type, current_dimension)
    
    return entity

func _calculate_word_power(word: String) -> float:
    # Calculate the divine power of a word
    var power = 10.0 + (word.length() * 3.0)
    
    # Special character bonuses
    for c in word:
        if c.to_upper() == c and c.is_valid_identifier(): # Capital letter
            power += 2.0
        if not c.is_valid_identifier(): # Special character
            power += 5.0
    
    # Count vowels and consonants
    var vowels = "aeiouAEIOU"
    var vowel_count = 0
    var consonant_count = 0
    
    for c in word:
        if vowels.find(c) >= 0:
            vowel_count += 1
        elif c.is_valid_identifier():
            consonant_count += 1
    
    # Balance bonus
    var balance_ratio = float(min(vowel_count, consonant_count)) / max(1, max(vowel_count, consonant_count))
    power += balance_ratio * 15.0
    
    # Word length pattern bonuses
    if word.length() % 3 == 0: # Divisible by 3
        power += 10.0
    
    if word.length() == 7: # "Magical" number
        power += 20.0
    
    # Current moon phase modifier
    if enable_moon_phases and reality_contexts[current_reality_type]["moon_phase_effects"].has(current_moon_phase):
        power *= reality_contexts[current_reality_type]["moon_phase_effects"][current_moon_phase]["word_power_modifier"]
    
    # Current dimension modifier
    power *= (1.0 + (current_dimension * 0.05))
    
    return power

func _get_words_in_current_reality_and_dimension() -> Array:
    var result = []
    
    if reality_contexts.has(current_reality_type):
        for word_id in reality_contexts[current_reality_type]["words"]:
            var word_data = reality_contexts[current_reality_type]["words"][word_id]
            if word_data.dimension == current_dimension:
                result.append(word_id)
    
    return result

func connect_words(word1_id, word2_id, connection_type: String = "default") -> bool:
    # Check if both words exist in current reality
    if not reality_contexts[current_reality_type]["words"].has(word1_id) or not reality_contexts[current_reality_type]["words"].has(word2_id):
        return false
    
    # Get word data
    var word1_data = reality_contexts[current_reality_type]["words"][word1_id]
    var word2_data = reality_contexts[current_reality_type]["words"][word2_id]
    
    # Create connection ID
    var connection_id = word1_id + "_" + word2_id + "_" + connection_type
    
    # Skip if already connected
    if reality_contexts[current_reality_type]["connections"].has(connection_id):
        return false
    
    # Create connection data
    var connection_data = {
        "word1_id": word1_id,
        "word2_id": word2_id,
        "type": connection_type,
        "strength": 1.0,
        "created_at": Time.get_unix_time_from_system(),
        "dimension": current_dimension
    }
    
    # Store connection
    reality_contexts[current_reality_type]["connections"][connection_id] = connection_data
    
    # Create visual connection
    var connection_node = _create_connection_visualization(connection_data)
    connection_nodes[connection_id] = connection_node
    
    # Emit signal
    emit_signal("word_connected", word1_data.word, word2_data.word, connection_type)
    
    return true

func _create_word_visualization(word: String, entity: Object) -> Node3D:
    # Create visual representation of the word in 3D space
    var word_node = Node3D.new()
    word_node.name = "WordNode_" + word
    word_parent.add_child(word_node)
    
    # Position at entity's position
    if entity is Node3D:
        word_node.global_position = entity.global_position
    
    # Create text mesh or 3D model
    var text_mesh = MeshInstance3D.new()
    text_mesh.name = "TextMesh"
    
    # Set mesh (either use font mesh or default)
    if word_font:
        # Create 3D text with font
        var font_mesh = _create_text_mesh(word, word_font)
        text_mesh.mesh = font_mesh
    else:
        # Use default box mesh
        var box = BoxMesh.new()
        box.size = Vector3(word.length() * 0.2, 0.5, 0.2)
        text_mesh.mesh = box
        
        # Add label for text
        var label_3d = Label3D.new()
        label_3d.text = word
        label_3d.font_size = 64
        label_3d.position = Vector3(0, 0.5, 0)
        label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        word_node.add_child(label_3d)
    
    word_node.add_child(text_mesh)
    
    # Apply material
    var material = word_material
    if not material:
        material = StandardMaterial3D.new()
        material.albedo_color = Color(1, 1, 1)
        material.metallic = 0.8
        material.roughness = 0.2
        material.emission_enabled = true
        material.emission = Color(0.5, 0.5, 1.0)
        material.emission_energy = 0.5
    
    text_mesh.material_override = material
    
    # Add glow effect for powerful words
    var word_power = reality_contexts[current_reality_type]["words"][entity.get_instance_id()].power
    if word_power > 50:
        var light = OmniLight3D.new()
        light.light_color = _get_word_color(word, word_power)
        light.light_energy = 0.5 + (word_power / 200.0)
        light.omni_range = 2.0 + (word_power / 50.0)
        word_node.add_child(light)
    
    return word_node

func _create_text_mesh(text: String, font: Font) -> Mesh:
    # Create a 3D mesh from text
    # Simplified implementation - in production would use Label3D or custom mesh generation
    
    # For now, create a simple TextMesh
    var box = BoxMesh.new()
    box.size = Vector3(text.length() * 0.2, 0.5, 0.2)
    return box

func _create_connection_visualization(connection_data) -> Node3D:
    # Create visual representation of a connection between words
    var connection_node = Node3D.new()
    connection_node.name = "Connection_" + connection_data.word1_id + "_" + connection_data.word2_id
    connection_parent.add_child(connection_node)
    
    # Get word positions
    var word1_data = reality_contexts[current_reality_type]["words"][connection_data.word1_id]
    var word2_data = reality_contexts[current_reality_type]["words"][connection_data.word2_id]
    
    var start_pos = word1_data.position
    var end_pos = word2_data.position
    
    # Create line mesh
    var line = _create_connection_line(start_pos, end_pos, connection_data.type)
    connection_node.add_child(line)
    
    return connection_node

func _create_connection_line(start_pos: Vector3, end_pos: Vector3, connection_type: String) -> Node3D:
    # Create a 3D visualization of a connection line
    var line_container = Node3D.new()
    line_container.name = "LineContainer"
    
    # Calculate midpoint and direction
    var midpoint = (start_pos + end_pos) / 2
    var direction = (end_pos - start_pos).normalized()
    var length = start_pos.distance_to(end_pos)
    
    # Create mesh instance
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "LineRenderer"
    
    # Create cylinder mesh for the line
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 0.03
    cylinder.bottom_radius = 0.03
    cylinder.height = length
    mesh_instance.mesh = cylinder
    
    # Position and orient cylinder to connect points
    mesh_instance.look_at_from_position(midpoint, end_pos, Vector3.UP)
    mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2) # Rotate to align cylinder axis
    
    # Apply material based on connection type
    var material = connection_material
    if not material:
        material = StandardMaterial3D.new()
        material.albedo_color = _get_connection_color(connection_type)
        material.emission_enabled = true
        material.emission = material.albedo_color
        material.emission_energy = 0.5
    else:
        material = material.duplicate()
        material.albedo_color = _get_connection_color(connection_type)
        material.emission = material.albedo_color
    
    mesh_instance.material_override = material
    
    line_container.add_child(mesh_instance)
    return line_container

func _get_connection_color(connection_type: String) -> Color:
    # Return color based on connection type
    match connection_type:
        "causal":
            return Color(1.0, 0.5, 0.0) # Orange
        "contrast":
            return Color(1.0, 0.0, 0.0) # Red
        "similarity":
            return Color(0.0, 1.0, 0.0) # Green
        "sequence":
            return Color(0.0, 0.5, 1.0) # Blue
        "transformation":
            return Color(0.8, 0.0, 1.0) # Purple
        _:
            return Color(0.7, 0.7, 0.7) # Gray

func _get_word_color(word: String, power: float) -> Color:
    # Generate a color based on the word and its power
    var hue = 0.0
    
    # Generate hue based on first letter
    if word.length() > 0:
        hue = float(word.unicode_at(0) % 360) / 360.0
    
    # Adjust saturation and value based on power
    var saturation = min(1.0, 0.5 + (power / 200.0))
    var value = min(1.0, 0.7 + (power / 300.0))
    
    return Color.from_hsv(hue, saturation, value)

func _apply_reality_context_to_entity(entity, reality_type: String, dimension: int):
    # Apply reality and dimension specific properties to an entity
    if entity.has_method("set_property"):
        entity.set_property("reality_type", reality_type)
        entity.set_property("dimension", dimension)
        
        # Set dimension properties
        match dimension:
            1: # Linear
                entity.set_property("dimensionality", "linear")
                entity.set_property("movement_constraint", "line")
            2: # Planar
                entity.set_property("dimensionality", "planar")
                entity.set_property("movement_constraint", "plane")
            3: # Spatial
                entity.set_property("dimensionality", "spatial")
                entity.set_property("movement_constraint", "volume")
            4: # Time
                entity.set_property("dimensionality", "temporal")
                entity.set_property("time_flux", 0.5)
            5: # Consciousness
                entity.set_property("dimensionality", "conscious")
                entity.set_property("awareness_level", 0.7)
            _: # Higher dimensions
                entity.set_property("dimensionality", "transcendent")
                entity.set_property("etheric_resonance", dimension * 0.1)
        
        # Set reality type properties
        match reality_type:
            "Physical":
                entity.set_property("tangibility", 1.0)
                entity.set_property("persistence", 0.9)
            "Digital":
                entity.set_property("tangibility", 0.3)
                entity.set_property("compression_ratio", 0.7)
            "Astral":
                entity.set_property("tangibility", 0.1)
                entity.set_property("spiritual_resonance", 0.8)
            "Quantum":
                entity.set_property("tangibility", 0.5)
                entity.set_property("probability_state", 0.5)
            "Memory":
                entity.set_property("tangibility", 0.2)
                entity.set_property("retention", 0.6)
            "Dream":
                entity.set_property("tangibility", 0.05)
                entity.set_property("imagination_factor", 0.9)

# ----- REALITY SYSTEM -----
func change_reality(reality_type: String) -> bool:
    # Skip if same reality
    if reality_type == current_reality_type:
        return false
    
    print("Changing reality from " + current_reality_type + " to " + reality_type)
    
    # Create reality if it doesn't exist
    if not reality_contexts.has(reality_type):
        reality_contexts[reality_type] = {
            "words": {},
            "connections": {},
            "settings": {
                "gravity": Vector3(0, -9.8, 0),
                "ambient_light": Color(0.2, 0.2, 0.3),
                "fog_density": 0.01,
                "time_dilation": 1.0
            },
            "dimension_settings": {},
            "moon_phase_effects": {}
        }
        
        # Copy moon phase effects from current reality
        if enable_moon_phases and reality_contexts[current_reality_type]["moon_phase_effects"].size() > 0:
            for phase in reality_contexts[current_reality_type]["moon_phase_effects"]:
                reality_contexts[reality_type]["moon_phase_effects"][phase] = reality_contexts[current_reality_type]["moon_phase_effects"][phase].duplicate()
    
    # Store old reality type
    var old_reality = current_reality_type
    
    # Update current reality
    current_reality_type = reality_type
    
    # Hide all word nodes and connections from old reality
    _hide_reality_entities(old_reality)
    
    # Show all word nodes and connections from new reality
    _show_reality_entities(reality_type)
    
    # Create reality transition effect
    if enable_reality_transitions and reality_transition_effect:
        var effect = reality_transition_effect.instantiate()
        add_child(effect)
        
        # Configure effect if it has the appropriate methods
        if effect.has_method("set_transition_realities"):
            effect.set_transition_realities(old_reality, reality_type)
        
        # Auto-remove after effect completes
        var timer = Timer.new()
        timer.wait_time = 2.0
        timer.one_shot = true
        timer.connect("timeout", Callable(effect, "queue_free"))
        effect.add_child(timer)
        timer.start()
    
    # Emit signal
    emit_signal("reality_changed", reality_type, old_reality)
    
    return true

func _hide_reality_entities(reality_type: String):
    # Hide all entities from specified reality
    if not reality_contexts.has(reality_type):
        return
    
    # Hide words
    for word_id in reality_contexts[reality_type]["words"]:
        if word_nodes.has(word_id):
            word_nodes[word_id].visible = false
    
    # Hide connections
    for connection_id in reality_contexts[reality_type]["connections"]:
        if connection_nodes.has(connection_id):
            connection_nodes[connection_id].visible = false

func _show_reality_entities(reality_type: String):
    # Show all entities from specified reality
    if not reality_contexts.has(reality_type):
        return
    
    # Show words
    for word_id in reality_contexts[reality_type]["words"]:
        if word_nodes.has(word_id):
            word_nodes[word_id].visible = true
    
    # Show connections
    for connection_id in reality_contexts[reality_type]["connections"]:
        if connection_nodes.has(connection_id):
            connection_nodes[connection_id].visible = true

# ----- CYBER GATE SYSTEM -----
func open_cyber_gate(source_reality: String, target_reality: String, position: Vector3 = Vector3.ZERO) -> Dictionary:
    if not enable_cyber_gates:
        return {"success": false, "message": "Cyber gates disabled"}
    
    # Verify both realities exist
    if not reality_contexts.has(source_reality) or not reality_contexts.has(target_reality):
        return {"success": false, "message": "Invalid reality"}
    
    # Create gate ID
    var gate_id = "gate_" + str(Time.get_unix_time_from_system()) + "_" + source_reality + "_" + target_reality
    
    # Check moon phase stability for gate creation
    var stability = 0.5
    if enable_moon_phases and reality_contexts[source_reality]["moon_phase_effects"].has(current_moon_phase):
        stability = reality_contexts[source_reality]["moon_phase_effects"][current_moon_phase]["gate_stability"]
    
    # Gate creation can fail if stability is low
    if stability < 0.3 and randf() > stability * 2:
        return {"success": false, "message": "Gate creation failed - unstable moon phase"}
    
    # Create gate data
    var gate_data = {
        "id": gate_id,
        "source_reality": source_reality,
        "target_reality": target_reality,
        "position": position,
        "stability": stability,
        "created_at": Time.get_unix_time_from_system(),
        "lifespan": 60.0 + (stability * 120.0) # 1-3 minutes depending on stability
    }
    
    # Create visual gate
    var gate_node = _create_gate_visualization(gate_data)
    
    # Add to active gates
    active_gates.append(gate_data)
    
    # Emit signal
    emit_signal("cyber_gate_opened", gate_id, source_reality, target_reality)
    
    return {"success": true, "message": "Gate opened", "gate_id": gate_id, "stability": stability}

func _create_gate_visualization(gate_data: Dictionary) -> Node3D:
    # Create visual representation of cyber gate
    var gate_node = Node3D.new()
    gate_node.name = "CyberGate_" + gate_data.id
    gate_node.position = gate_data.position
    cyber_gate_parent.add_child(gate_node)
    
    # Add gate model/effect
    if cyber_gate_effect:
        var effect = cyber_gate_effect.instantiate()
        gate_node.add_child(effect)
        
        # Configure effect if applicable
        if effect.has_method("set_stability"):
            effect.set_stability(gate_data.stability)
    else:
        # Create simple visual
        var portal = CSGTorus3D.new()
        portal.inner_radius = 1.0
        portal.outer_radius = 1.5
        portal.sides = 32
        portal.smooth_faces = true
        
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.1, 0.5, 1.0)
        material.emission_enabled = true
        material.emission = Color(0.3, 0.7, 1.0)
        material.emission_energy = 2.0
        
        portal.material = material
        gate_node.add_child(portal)
    
    # Add collision area for interaction
    var area = Area3D.new()
    var collision = CollisionShape3D.new()
    var shape = SphereShape3D.new()
    shape.radius = 1.5
    collision.shape = shape
    area.add_child(collision)
    
    # Connect signal
    area.connect("body_entered", Callable(self, "_on_gate_body_entered").bind(gate_data))
    
    gate_node.add_child(area)
    
    # Add self-destruct timer
    var timer = Timer.new()
    timer.wait_time = gate_data.lifespan
    timer.one_shot = true
    timer.connect("timeout", Callable(self, "_close_gate").bind(gate_data.id))
    gate_node.add_child(timer)
    timer.start()
    
    return gate_node

func _close_gate(gate_id: String):
    # Find gate in active gates
    var gate_index = -1
    for i in range(active_gates.size()):
        if active_gates[i].id == gate_id:
            gate_index = i
            break
    
    if gate_index == -1:
        return
    
    # Get gate data
    var gate_data = active_gates[gate_index]
    
    # Remove gate node
    var gate_node = cyber_gate_parent.get_node_or_null("CyberGate_" + gate_id)
    if gate_node:
        gate_node.queue_free()
    
    # Remove from active gates
    active_gates.remove_at(gate_index)
    
    # Emit signal
    emit_signal("cyber_gate_closed", gate_id)

func _on_gate_body_entered(body, gate_data):
    # When player or entity enters gate, transport to target reality
    if body.name == "PlayerCamera" or (body.get_parent() and body.get_parent().name == "PlayerCamera"):
        # Player entered gate - change reality
        change_reality(gate_data.target_reality)
    elif body.get_parent() and body.get_parent().get_parent() == word_parent:
        # Word entity entered gate - transport word between realities
        _transport_word_through_gate(body, gate_data)

func _transport_word_through_gate(body, gate_data):
    # Find word ID from body
    var word_id = -1
    
    # Check if body is a word node or child of word node
    if body.get_parent() and word_nodes.values().has(body.get_parent()):
        # Get ID from word_nodes dictionary
        for id in word_nodes:
            if word_nodes[id] == body.get_parent():
                word_id = id
                break
    
    if word_id == -1:
        return
    
    # Get word data from source reality
    if not reality_contexts[gate_data.source_reality]["words"].has(word_id):
        return
    
    var word_data = reality_contexts[gate_data.source_reality]["words"][word_id]
    
    # Create copy in target reality
    reality_contexts[gate_data.target_reality]["words"][word_id] = word_data.duplicate()
    
    # Update word node visibility based on current reality
    word_nodes[word_id].visible = (current_reality_type == gate_data.target_reality)

# ----- DATA SEWER SYSTEM -----
func create_data_sewer(reality_type: String, capacity: float = 1000.0, position: Vector3 = Vector3.ZERO) -> Dictionary:
    if not enable_data_sewers:
        return {"success": false, "message": "Data sewers disabled"}
    
    # Verify reality exists
    if not reality_contexts.has(reality_type):
        return {"success": false, "message": "Invalid reality"}
    
    # Create sewer ID
    var sewer_id = "sewer_" + str(Time.get_unix_time_from_system()) + "_" + reality_type
    
    # Create sewer data
    var sewer_data = {
        "id": sewer_id,
        "reality_type": reality_type,
        "position": position,
        "capacity": capacity,
        "current_load": 0.0,
        "contents": [],
        "created_at": Time.get_unix_time_from_system()
    }
    
    # Create visual sewer
    var sewer_node = _create_sewer_visualization(sewer_data)
    
    # Add to active sewers
    active_sewers.append(sewer_data)
    
    return {"success": true, "message": "Data sewer created", "sewer_id": sewer_id}

func _create_sewer_visualization(sewer_data: Dictionary) -> Node3D:
    # Create visual representation of data sewer
    var sewer_node = Node3D.new()
    sewer_node.name = "DataSewer_" + sewer_data.id
    sewer_node.position = sewer_data.position
    data_sewer_parent.add_child(sewer_node)
    
    # Add sewer model/effect
    if data_sewer_effect:
        var effect = data_sewer_effect.instantiate()
        sewer_node.add_child(effect)
        
        # Configure effect if applicable
        if effect.has_method("set_capacity"):
            effect.set_capacity(sewer_data.capacity)
            effect.set_current_load(0.0)
    else:
        # Create simple visual
        var cylinder = CSGCylinder3D.new()
        cylinder.radius = 1.0
        cylinder.height = 2.0
        
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.2, 0.8, 0.3)
        material.emission_enabled = true
        material.emission = Color(0.2, 0.5, 0.3)
        material.emission_energy = 1.0
        
        cylinder.material = material
        sewer_node.add_child(cylinder)
    
    return sewer_node

func store_in_sewer(sewer_id: String, data_packet: Dictionary) -> bool:
    # Find sewer
    var sewer_index = -1
    for i in range(active_sewers.size()):
        if active_sewers[i].id == sewer_id:
            sewer_index = i
            break
    
    if sewer_index == -1:
        return false
    
    # Get sewer data
    var sewer = active_sewers[sewer_index]
    
    # Check capacity
    var packet_size = _calculate_data_packet_size(data_packet)
    if sewer.current_load + packet_size > sewer.capacity:
        return false
    
    # Store data
    sewer.contents.append(data_packet)
    sewer.current_load += packet_size
    
    # Update visual if applicable
    var sewer_node = data_sewer_parent.get_node_or_null("DataSewer_" + sewer_id)
    if sewer_node:
        var effect = sewer_node.get_child(0)
        if effect and effect.has_method("set_current_load"):
            effect.set_current_load(sewer.current_load)
    
    return true

func _calculate_data_packet_size(data_packet: Dictionary) -> float:
    # Calculate size of data packet (simplified)
    var size = 1.0 # Base size
    
    # Add size based on content
    if data_packet.has("content"):
        if data_packet.content is String:
            size += data_packet.content.length() * 0.1
        elif data_packet.content is Dictionary:
            size += data_packet.content.size() * 1.0
        elif data_packet.content is Array:
            size += data_packet.content.size() * 0.5
    
    return size

# ----- MEMORY SYSTEM -----
func store_memory(content: String, tier: int = 1) -> Dictionary:
    # Validate tier
    if tier < 1 or tier > 3:
        tier = 1
    
    # Calculate retention based on tier
    var retention = 0.98 # Tier 1 (98% retention)
    if tier == 2:
        retention = 0.85 # Tier 2 (85% retention)
    elif tier == 3:
        retention = 1.0  # Tier 3 (100% retention - eternal)
    
    # Create memory entry
    var memory_data = {
        "id": "memory_" + str(Time.get_unix_time_from_system()),
        "content": content,
        "tier": tier,
        "retention": retention,
        "created_at": Time.get_unix_time_from_system(),
        "reality_type": current_reality_type,
        "dimension": current_dimension
    }
    
    # Store in appropriate tier
    var tier_key = "tier" + str(tier)
    memory_tiers[tier_key].append(memory_data)
    
    # Emit signal
    emit_signal("memory_stored", content, tier, retention)
    
    return memory_data

func get_memories(tier: int = 0, filter: String = "") -> Array:
    # Return memories from specified tier (0 = all tiers)
    var result = []
    
    for t in range(1, 4):
        if tier == 0 or tier == t:
            var tier_key = "tier" + str(t)
            
            for memory in memory_tiers[tier_key]:
                if filter.is_empty() or memory.content.find(filter) >= 0:
                    result.append(memory)
    
    return result

# ----- TURN & DIMENSION SYSTEM -----
func advance_turn():
    if pitopia_main and pitopia_main.has_method("advance_turn"):
        pitopia_main.advance_turn()
    elif turn_system and turn_system.has_method("advance_turn"):
        turn_system.advance_turn()
    else:
        # Manual turn advancement
        current_turn += 1
        _update_turn_symbol()
        
        # Update moon phase every 3 turns
        if current_turn % 3 == 0:
            advance_moon_phase()
        
        # Emit signal
        emit_signal("turn_advanced", current_turn)

func set_dimension(dimension: int):
    if dimension < 1 or dimension > 12:
        return
    
    if pitopia_main and pitopia_main.has_method("set_dimension"):
        pitopia_main.set_dimension(dimension)
    elif turn_system and turn_system.has_method("set_dimension"):
        turn_system.set_dimension(dimension)
    else:
        # Manual dimension change
        var old_dimension = current_dimension
        current_dimension = dimension
        _update_turn_symbol()
        
        # Emit signal
        emit_signal("dimension_changed", dimension, old_dimension)

func _update_turn_symbol():
    # Update symbol based on current turn or dimension
    var symbols = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
    
    if current_dimension >= 1 and current_dimension <= symbols.size():
        current_symbol = symbols[current_dimension - 1]
    else:
        current_symbol = "?"

func advance_moon_phase():
    if not enable_moon_phases:
        return
    
    var old_phase = current_moon_phase
    current_moon_phase = (current_moon_phase + 1) % 8
    
    var stability = _calculate_moon_phase_stability(current_moon_phase)
    
    # Update moon phase indicator if available
    var indicator = get_node_or_null("MoonPhaseIndicator")
    if indicator and indicator.has_method("set_phase"):
        indicator.set_phase(current_moon_phase)
    
    # Emit signal
    emit_signal("moon_phase_changed", current_moon_phase, old_phase, stability)
    
    # Apply effects to current reality
    if reality_contexts[current_reality_type]["moon_phase_effects"].has(current_moon_phase):
        var effects = reality_contexts[current_reality_type]["moon_phase_effects"][current_moon_phase]
        
        # Apply time dilation
        if effects.has("time_dilation"):
            Engine.time_scale = effects.time_dilation

# ----- CONSOLE COMMAND PROCESSING -----
func process_command(command: String) -> Dictionary:
    # Process notepad3d specific commands
    
    # Split into command and parameters
    var parts = command.split(" ", false, 1)
    var cmd = parts[0].to_lower()
    var params = ""
    if parts.size() > 1:
        params = parts[1]
    
    match cmd:
        "/word-power":
            # Check power of a word
            var power = _calculate_word_power(params)
            return {
                "success": true, 
                "message": "Power of '" + params + "': " + str(power),
                "power": power
            }
            
        "/note":
            # Create a 3D note in space
            var entity = manifest_word(params)
            if entity:
                return {
                    "success": true,
                    "message": "Created note: " + params,
                    "entity": entity
                }
            else:
                return {
                    "success": false,
                    "message": "Failed to create note"
                }
                
        "/save":
            # Save current reality state
            var save_name = params if not params.is_empty() else "auto_save"
            _save_reality(save_name)
            return {
                "success": true,
                "message": "Saved reality as: " + save_name
            }
            
        "/memory":
            # Create tiered memory
            var mem_parts = params.split(" ", false, 1)
            var tier = 1
            var content = params
            
            if mem_parts.size() > 1 and mem_parts[0].is_valid_integer():
                tier = mem_parts[0].to_int()
                content = mem_parts[1]
                
            var memory = store_memory(content, tier)
            return {
                "success": true,
                "message": "Memory stored in tier " + str(tier) + " with " + str(memory.retention * 100) + "% retention",
                "memory": memory
            }
            
        "/status":
            # View divine status
            return {
                "success": true,
                "message": _generate_status_report()
            }
            
        "/turn":
            # Advance turn manually
            advance_turn()
            return {
                "success": true,
                "message": "Advanced to turn " + str(current_turn) + " (" + current_symbol + ")"
            }
            
        "/loop":
            # Toggle quantum loop
            # For this implementation, we'll just trigger multiple turns
            for i in range(5):
                advance_turn()
            
            return {
                "success": true,
                "message": "Quantum loop: Advanced 5 turns"
            }
            
        "/reality":
            # Change reality
            var reality_name = params
            if reality_contexts.has(reality_name):
                change_reality(reality_name)
                return {
                    "success": true,
                    "message": "Changed to " + reality_name + " reality"
                }
            else:
                # List available realities
                var available = "Available realities: "
                for reality in reality_contexts:
                    available += reality + ", "
                available = available.rstrip(", ")
                
                return {
                    "success": false,
                    "message": "Reality '" + reality_name + "' not found. " + available
                }
                
        "/gate":
            # Create cyber gate between realities
            var gate_parts = params.split(" ", false, 1)
            
            if gate_parts.size() < 1:
                return {
                    "success": false,
                    "message": "Usage: /gate [target_reality]"
                }
            
            var target_reality = gate_parts[0]
            
            if not reality_contexts.has(target_reality):
                return {
                    "success": false,
                    "message": "Reality '" + target_reality + "' not found"
                }
            
            var result = open_cyber_gate(current_reality_type, target_reality, Vector3(0, 1, -3))
            
            if result.success:
                return {
                    "success": true,
                    "message": "Created gate to " + target_reality + " reality (stability: " + str(result.stability * 100) + "%)",
                    "gate_id": result.gate_id
                }
            else:
                return {
                    "success": false,
                    "message": result.message
                }
                
        "/sewer":
            # Create data sewer
            var sewer_result = create_data_sewer(current_reality_type, 1000.0, Vector3(3, 0, -3))
            
            if sewer_result.success:
                return {
                    "success": true,
                    "message": "Created data sewer in " + current_reality_type + " reality",
                    "sewer_id": sewer_result.sewer_id
                }
            else:
                return {
                    "success": false,
                    "message": sewer_result.message
                }
                
        "/connect":
            # Connect two words
            var connect_parts = params.split(" to ", false)
            
            if connect_parts.size() < 2:
                return {
                    "success": false,
                    "message": "Usage: /connect [word1] to [word2]"
                }
            
            var word1 = connect_parts[0].strip_edges()
            var word2 = connect_parts[1].strip_edges()
            
            # Find word entities
            var word1_id = _find_word_id_by_text(word1)
            var word2_id = _find_word_id_by_text(word2)
            
            if word1_id == -1 or word2_id == -1:
                return {
                    "success": false,
                    "message": "One or both words not found in current reality"
                }
            
            var connection_result = connect_words(word1_id, word2_id)
            
            if connection_result:
                return {
                    "success": true,
                    "message": "Connected '" + word1 + "' to '" + word2 + "'"
                }
            else:
                return {
                    "success": false,
                    "message": "Failed to connect words"
                }
                
        "/help":
            # Display available commands
            return {
                "success": true,
                "message": _generate_help_text()
            }
            
        _:
            # Unknown command - pass to Pitopia for word manifestation
            if pitopia_main and pitopia_main.has_method("process_command"):
                return pitopia_main.process_command(command)
            else:
                return {
                    "success": false,
                    "message": "Unknown command. Type /help for available commands."
                }

func _find_word_id_by_text(word_text: String) -> int:
    # Find word entity by text
    for word_id in reality_contexts[current_reality_type]["words"]:
        var word_data = reality_contexts[current_reality_type]["words"][word_id]
        if word_data.word.to_lower() == word_text.to_lower():
            return word_id
    
    return -1

func _generate_status_report() -> String:
    # Generate a status report of the current state
    var report = "DIVINE STATUS REPORT:\n"
    report += "----------------\n"
    report += "Reality: " + current_reality_type + "\n"
    report += "Dimension: " + str(current_dimension) + "D - " + current_symbol + "\n"
    report += "Turn: " + str(current_turn) + "\n"
    
    if enable_moon_phases:
        report += "Moon Phase: " + str(current_moon_phase) + "/7 (stability: " + str(_calculate_moon_phase_stability(current_moon_phase) * 100) + "%)\n"
    
    report += "----------------\n"
    report += "Words in current reality: " + str(reality_contexts[current_reality_type]["words"].size()) + "\n"
    report += "Connections: " + str(reality_contexts[current_reality_type]["connections"].size()) + "\n"
    report += "Active gates: " + str(active_gates.size()) + "\n"
    report += "Active sewers: " + str(active_sewers.size()) + "\n"
    report += "----------------\n"
    
    var total_memories = 0
    for tier in memory_tiers:
        total_memories += memory_tiers[tier].size()
    
    report += "Total memories: " + str(total_memories) + "\n"
    report += "Tier 1: " + str(memory_tiers.tier1.size()) + " (98% retention)\n"
    report += "Tier 2: " + str(memory_tiers.tier2.size()) + " (85% retention)\n"
    report += "Tier 3: " + str(memory_tiers.tier3.size()) + " (eternal)\n"
    
    return report

func _generate_help_text() -> String:
    # Generate help text for available commands
    var help = "NOTEPAD3D COMMANDS:\n"
    help += "----------------\n"
    help += "/word-power [word] - Check power of a word\n"
    help += "/note [text] - Create a 3D note in space\n"
    help += "/save [name] - Save current reality state\n"
    help += "/memory [tier] [text] - Create tiered memory\n"
    help += "/status - View divine status\n"
    help += "/turn - Advance turn manually\n"
    help += "/loop - Trigger quantum loop (5 turns)\n"
    help += "/reality [name] - Change reality\n"
    help += "/gate [target] - Create cyber gate to target reality\n"
    help += "/sewer - Create data sewer in current reality\n"
    help += "/connect [word1] to [word2] - Connect two words\n"
    help += "/help - Display this help\n"
    help += "----------------\n"
    help += "You can also enter any word to manifest it\n"
    help += "Use number keys 1-9/0/-/= to change dimensions\n"
    
    return help

func _save_reality(save_name: String):
    # Save current reality to a file
    var save_data = {
        "reality_type": current_reality_type,
        "dimension": current_dimension,
        "turn": current_turn,
        "symbol": current_symbol,
        "moon_phase": current_moon_phase,
        "timestamp": Time.get_unix_time_from_system(),
        "settings": reality_contexts[current_reality_type]["settings"].duplicate(),
        "words": [],
        "connections": []
    }
    
    # Populate words
    for word_id in reality_contexts[current_reality_type]["words"]:
        var word_data = reality_contexts[current_reality_type]["words"][word_id]
        save_data.words.append({
            "id": word_id,
            "word": word_data.word,
            "position": {
                "x": word_data.position.x,
                "y": word_data.position.y,
                "z": word_data.position.z
            },
            "dimension": word_data.dimension,
            "power": word_data.power
        })
    
    # Populate connections
    for connection_id in reality_contexts[current_reality_type]["connections"]:
        var connection_data = reality_contexts[current_reality_type]["connections"][connection_id]
        save_data.connections.append({
            "id": connection_id,
            "word1_id": connection_data.word1_id,
            "word2_id": connection_data.word2_id,
            "type": connection_data.type,
            "strength": connection_data.strength,
            "dimension": connection_data.dimension
        })
    
    # Save to user directory
    var save_path = "user://reality_saves/"
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("reality_saves"):
        dir.make_dir("reality_saves")
    
    var file = FileAccess.open(save_path + save_name + ".json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data, "  "))
        print("Saved reality to: " + save_path + save_name + ".json")
    else:
        print("Failed to save reality: " + str(FileAccess.get_open_error()))

# ----- SIGNAL HANDLERS FROM PITOPIA -----
func _on_pitopia_word_manifested(word, entity):
    # When a word is manifested through Pitopia, add it to current reality
    if entity and not reality_contexts[current_reality_type]["words"].has(entity.get_instance_id()):
        # Calculate word power
        var power = _calculate_word_power(word)
        
        # Add to current reality
        var word_id = entity.get_instance_id()
        reality_contexts[current_reality_type]["words"][word_id] = {
            "entity": entity,
            "word": word,
            "position": entity.global_position,
            "dimension": current_dimension,
            "power": power
        }
        
        # Create 3D visualization if not already done
        if not word_nodes.has(word_id):
            var word_node = _create_word_visualization(word, entity)
            word_nodes[word_id] = word_node
    
    # Check for powerful words that might create reality impacts
    _process_word_reality_impacts(word, entity)

func _process_word_reality_impacts(word: String, entity: Object):
    # Process special effects from powerful words
    var power = _calculate_word_power(word)
    
    # Words with power > 50 create reality impacts
    if power > 50:
        print("Word '" + word + "' has significant power (" + str(power) + ") - creating reality impact")
        
        # Apply effects based on word
        if word.to_lower() == "light" or word.to_lower() == "illuminate":
            # Increase ambient light
            var settings = reality_contexts[current_reality_type]["settings"]
            settings.ambient_light = settings.ambient_light.lightened(0.2)
            
            # Update environment if available
            var world_env = get_node_or_null("/root/WorldEnvironment")
            if world_env and world_env.environment:
                world_env.environment.ambient_light_color = settings.ambient_light
        
        elif word.to_lower() == "gravity" or word.to_lower() == "float":
            # Modify gravity
            var settings = reality_contexts[current_reality_type]["settings"]
            settings.gravity = Vector3(0, -4.9, 0)  # Half gravity
            
            # Apply to physics
            PhysicsServer3D.area_set_param(get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, settings.gravity)
        
        # Words with power > 200 create persistent realities
        if power > 200 and not reality_contexts.has(word):
            print("Word '" + word + "' has immense power (" + str(power) + ") - creating new reality")
            
            # Create new reality with this word's name
            reality_contexts[word] = {
                "words": {},
                "connections": {},
                "settings": reality_contexts[current_reality_type]["settings"].duplicate(),
                "dimension_settings": {},
                "moon_phase_effects": {}
            }
            
            # Automatically create a gate to this new reality
            open_cyber_gate(current_reality_type, word, entity.global_position + Vector3(0, 1, 0))

func _on_pitopia_dimension_changed(new_dimension, old_dimension):
    # Update current dimension
    current_dimension = new_dimension
    _update_turn_symbol()
    
    # Apply dimension-specific effects to reality
    _apply_dimension_to_reality(current_reality_type, new_dimension)

func _apply_dimension_to_reality(reality_type: String, dimension: int):
    # Apply dimension-specific effects to a reality
    if not reality_contexts.has(reality_type):
        return
    
    # Update each word's dimension property
    for word_id in reality_contexts[reality_type]["words"]:
        var word_data = reality_contexts[reality_type]["words"][word_id]
        var entity = word_data.entity
        
        if entity and is_instance_valid(entity):
            _apply_dimension_to_entity(entity, reality_type, dimension)
            
            # Update word node visualization
            if word_nodes.has(word_id):
                var word_node = word_nodes[word_id]
                
                # Scale effect based on dimension
                var scale_factor = 1.0
                match dimension:
                    1: scale_factor = 0.5  # Smaller in 1D
                    2: scale_factor = 0.8  # Slightly smaller in 2D
                    3: scale_factor = 1.0  # Normal in 3D
                    _: scale_factor = 1.0 + (dimension - 3) * 0.1  # Larger in higher dimensions
                
                word_node.scale = Vector3(scale_factor, scale_factor, scale_factor)
                
                # Add glow for higher dimensions
                if dimension >= 5:
                    var light = word_node.get_node_or_null("OmniLight3D")
                    if not light:
                        light = OmniLight3D.new()
                        light.name = "OmniLight3D"
                        light.light_color = _get_word_color(word_data.word, word_data.power)
                        light.light_energy = 0.5 + (dimension - 4) * 0.1
                        light.omni_range = 2.0 + (dimension - 4) * 0.5
                        word_node.add_child(light)
                    else:
                        light.light_energy = 0.5 + (dimension - 4) * 0.1
                        light.omni_range = 2.0 + (dimension - 4) * 0.5

func _on_pitopia_turn_advanced(turn_number):
    # Update current turn
    current_turn = turn_number
    _update_turn_symbol()
    
    # Update moon phase every 3 turns
    if turn_number % 3 == 0 and enable_moon_phases:
        advance_moon_phase()
    
    # Process memory decay
    _process_memory_decay()
    
    # Process automatic reality effects
    _process_reality_time_effects()

func _process_memory_decay():
    # Process memory retention/decay
    for tier_key in memory_tiers:
        var memories_to_remove = []
        
        for i in range(memory_tiers[tier_key].size()):
            var memory = memory_tiers[tier_key][i]
            
            # Skip eternal memories (tier 3)
            if memory.tier == 3:
                continue
            
            # Chance to forget based on retention
            if randf() > memory.retention:
                memories_to_remove.append(i)
        
        # Remove forgotten memories in reverse order
        for i in range(memories_to_remove.size() - 1, -1, -1):
            memory_tiers[tier_key].remove_at(memories_to_remove[i])

func _process_reality_time_effects():
    # Process time-based effects in reality
    for reality_type in reality_contexts:
        # Apply time dilation from moon phase
        if enable_moon_phases and reality_contexts[reality_type]["moon_phase_effects"].has(current_moon_phase):
            var effects = reality_contexts[reality_type]["moon_phase_effects"][current_moon_phase]
            
            # Apply only to current reality
            if reality_type == current_reality_type and effects.has("time_dilation"):
                Engine.time_scale = effects.time_dilation

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
    # Update word and connection positions, etc.
    pass
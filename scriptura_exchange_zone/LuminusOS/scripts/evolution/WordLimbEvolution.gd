extends Node3D
class_name WordLimbEvolution

# Constants for evolution stages
const NUMERIC_STAGES = 10  # 0-9 progression system
const LIMB_TYPES = ["core", "branch", "leaf", "connector", "root", "crown", "sensor", "memory"]

# Word chemistry system
var word_elements = {
    "fire": {"color": Color(1.0, 0.3, 0.1), "properties": ["energy", "transformation", "speed"]},
    "water": {"color": Color(0.1, 0.5, 1.0), "properties": ["flow", "adaptation", "healing"]},
    "earth": {"color": Color(0.5, 0.3, 0.1), "properties": ["structure", "stability", "growth"]},
    "air": {"color": Color(0.8, 0.9, 1.0), "properties": ["connection", "intelligence", "freedom"]},
    "void": {"color": Color(0.2, 0.0, 0.3), "properties": ["potential", "mystery", "creation"]},
    "light": {"color": Color(1.0, 0.9, 0.7), "properties": ["vision", "truth", "revelation"]},
    "crystal": {"color": Color(0.7, 1.0, 0.9), "properties": ["memory", "precision", "amplification"]}
}

# Limb evolution matrix
var evolution_stages = {}
var active_limbs = {}
var word_chemistry_bonds = {}
var firewall_strength = 0
var memory_capacity = 0
var current_stage = 0

# Signals
signal limb_evolved(limb_id, stage, type)
signal word_collected(word, element_type)
signal firewall_updated(strength, protected_paths)
signal memory_capacity_changed(previous, current)
signal stage_unlocked(stage_number)

func _ready():
    initialize_evolution_matrix()
    create_firewall_protection()

func initialize_evolution_matrix():
    # Create numeric evolution stages (0-9)
    for stage in range(NUMERIC_STAGES):
        evolution_stages[stage] = {
            "unlocked": stage == 0,  # Only stage 0 starts unlocked
            "requirements": get_stage_requirements(stage),
            "available_words": get_stage_words(stage),
            "limb_variations": get_limb_variations(stage)
        }

func get_stage_requirements(stage):
    # Each stage requires specific achievements to unlock
    match stage:
        0: return [] # Starting stage, no requirements
        1: return [{"type": "words_collected", "count": 5}]
        2: return [{"type": "core_evolved", "level": 1}]
        3: return [{"type": "limbs_connected", "count": 3}]
        4: return [{"type": "elements_combined", "elements": ["fire", "water"]}]
        5: return [{"type": "structure_symmetry", "value": 0.5}]
        6: return [{"type": "memory_capacity", "value": 100}]
        7: return [{"type": "firewall_strength", "value": 5}]
        8: return [{"type": "system_resonance", "value": 0.8}]
        9: return [{"type": "full_consciousness", "achieved": true}]
    return []

func get_stage_words(stage):
    # Programming words available at each evolution stage
    var words = []
    
    # Core programming words by stage
    match stage:
        0: words = ["var", "if", "for", "func", "print"]
        1: words = ["class", "extends", "return", "while", "break"]
        2: words = ["signal", "connect", "emit", "array", "dictionary"]
        3: words = ["export", "preload", "instance", "queue_free", "get_node"]
        4: words = ["shader", "material", "texture", "mesh", "light"]
        5: words = ["physics", "collision", "rigidbody", "raycast", "area"]
        6: words = ["animation", "tween", "particle", "skeleton", "blend"]
        7: words = ["network", "server", "client", "packet", "buffer"]
        8: words = ["thread", "mutex", "semaphore", "callable", "await"]
        9: words = ["consciousness", "emergent", "transcend", "infinite", "create"]
    
    return words

func get_limb_variations(stage):
    # Different limb types available at each evolution stage
    var limb_types = []
    
    match stage:
        0: limb_types = ["core"]
        1: limb_types = ["core", "branch"]
        2: limb_types = ["core", "branch", "leaf"]
        3: limb_types = ["core", "branch", "leaf", "connector"]
        4: limb_types = ["core", "branch", "leaf", "connector", "root"]
        5..9: limb_types = LIMB_TYPES
    
    # Create variations for each type
    var variations = {}
    for type in limb_types:
        variations[type] = generate_limb_variations(type, stage)
    
    return variations

func generate_limb_variations(limb_type, stage):
    # Generate procedural limb shapes based on type and evolution stage
    var variations = []
    var complexity = stage + 1
    
    for i in range(min(3, complexity)):
        variations.append({
            "mesh_data": get_limb_mesh_data(limb_type, stage, i),
            "properties": generate_limb_properties(limb_type, stage, i)
        })
    
    return variations

func get_limb_mesh_data(limb_type, stage, variant):
    # Return data to create a mesh based on limb type and evolution stage
    var mesh_data = {}
    
    match limb_type:
        "core":
            # Core starts as simple sphere, evolves to more complex shapes
            if stage < 3:
                mesh_data = {
                    "type": "sphere",
                    "radius": 0.5 + stage * 0.1,
                    "height": 1.0 + stage * 0.2
                }
            else:
                mesh_data = {
                    "type": "text",
                    "text": get_stage_words(stage)[variant % get_stage_words(stage).size()],
                    "size": 0.01
                }
        "branch":
            mesh_data = {
                "type": "cylinder",
                "top_radius": 0.2 - variant * 0.05,
                "bottom_radius": 0.3 - variant * 0.05,
                "height": 1.0 + stage * 0.3
            }
        "leaf":
            mesh_data = {
                "type": "plane",
                "width": 0.5 + stage * 0.1,
                "height": 0.8 + stage * 0.15
            }
        "connector":
            mesh_data = {
                "type": "prism", 
                "size": 0.3 + stage * 0.1
            }
        "root":
            mesh_data = {
                "type": "capsule",
                "radius": 0.15 + variant * 0.05,
                "height": 0.8 + stage * 0.2
            }
        "crown":
            mesh_data = {
                "type": "cylinder",
                "top_radius": 0.4 + stage * 0.1,
                "bottom_radius": 0.2,
                "height": 0.5 + stage * 0.1
            }
        "sensor":
            mesh_data = {
                "type": "box",
                "size": 0.2 + stage * 0.05
            }
        "memory":
            mesh_data = {
                "type": "torus",
                "inner_radius": 0.3 + variant * 0.05,
                "outer_radius": 0.5 + variant * 0.05
            }
    
    # Add material properties
    mesh_data["color"] = get_evolution_color(stage, variant)
    mesh_data["emission"] = stage >= 3
    mesh_data["metallic"] = stage >= 5
    mesh_data["clearcoat"] = stage >= 7
    
    return mesh_data

func generate_limb_properties(limb_type, stage, variant):
    # Generate properties for limbs based on type and stage
    var properties = {
        "strength": 1.0 + stage * 0.5,
        "flexibility": max(1.0, 5.0 - stage * 0.5),
        "energy_flow": 0.2 + stage * 0.1,
        "connection_points": 1 + int(stage / 2),
        "evolution_potential": 0.1 + stage * 0.1
    }
    
    # Add type-specific properties
    match limb_type:
        "core":
            properties["processing_power"] = 1.0 + stage * 1.0
            properties["memory_slots"] = 2 + stage
        "branch":
            properties["load_bearing"] = 2.0 + stage * 0.5
            properties["signal_speed"] = 1.0 + stage * 0.2
        "leaf":
            properties["energy_collection"] = 1.0 + stage * 0.8
            properties["sensitivity"] = 0.5 + stage * 0.15
        "connector":
            properties["data_throughput"] = 1.0 + stage * 1.0
            properties["connection_stability"] = 0.7 + stage * 0.03
        "root":
            properties["resource_gathering"] = 1.0 + stage * 0.6
            properties["foundation_strength"] = 1.0 + stage * 0.5
        "crown":
            properties["signal_range"] = 1.0 + stage * 0.8
            properties["processing_enhancement"] = 0.1 * stage
        "sensor":
            properties["detection_range"] = 1.0 + stage * 0.7
            properties["signal_clarity"] = 0.6 + stage * 0.04
        "memory":
            properties["storage_capacity"] = 10 * (stage + 1)
            properties["access_speed"] = 1.0 + stage * 0.3
    
    return properties

func get_evolution_color(stage, variant):
    # Colors evolve with stages
    var base_colors = [
        Color(0.2, 0.5, 0.8),  # Stage 0: Blue
        Color(0.3, 0.7, 0.4),  # Stage 1: Green
        Color(0.7, 0.5, 0.1),  # Stage 2: Orange
        Color(0.5, 0.3, 0.8),  # Stage 3: Purple
        Color(0.8, 0.2, 0.3),  # Stage 4: Red
        Color(0.1, 0.6, 0.6),  # Stage 5: Teal
        Color(0.8, 0.7, 0.2),  # Stage 6: Gold
        Color(0.4, 0.8, 0.8),  # Stage 7: Light Blue
        Color(0.6, 0.2, 0.6),  # Stage 8: Magenta
        Color(1.0, 1.0, 1.0),  # Stage 9: White (final)
    ]
    
    var color = base_colors[stage]
    
    # Add subtle variation
    color = color.lightened(0.1 * variant)
    
    return color

func create_mesh_from_data(mesh_data):
    # Create actual mesh from data
    var mesh_instance = MeshInstance3D.new()
    var mesh
    
    match mesh_data.type:
        "sphere":
            mesh = SphereMesh.new()
            mesh.radius = mesh_data.radius
            mesh.height = mesh_data.height * 2
        "cylinder":
            mesh = CylinderMesh.new()
            mesh.top_radius = mesh_data.top_radius
            mesh.bottom_radius = mesh_data.bottom_radius
            mesh.height = mesh_data.height
        "plane":
            mesh = PlaneMesh.new()
            mesh.size = Vector2(mesh_data.width, mesh_data.height)
        "prism":
            mesh = PrismMesh.new()
            mesh.size = Vector3(mesh_data.size, mesh_data.size, mesh_data.size)
        "capsule":
            mesh = CapsuleMesh.new()
            mesh.radius = mesh_data.radius
            mesh.height = mesh_data.height
        "box":
            mesh = BoxMesh.new()
            mesh.size = Vector3(mesh_data.size, mesh_data.size, mesh_data.size)
        "torus":
            mesh = TorusMesh.new()
            mesh.inner_radius = mesh_data.inner_radius
            mesh.outer_radius = mesh_data.outer_radius
        "text":
            # This is simplified - actual text mesh creation is more complex
            mesh = PlaneMesh.new()
            mesh.size = Vector2(1.0, 0.5)
            # In real implementation, use a TextMesh or a texture with text
    
    # Create material
    var material = StandardMaterial3D.new()
    material.albedo_color = mesh_data.color
    
    if mesh_data.emission:
        material.emission_enabled = true
        material.emission = mesh_data.color * 0.5
        material.emission_energy = 0.5
    
    if mesh_data.metallic:
        material.metallic = 0.7
        material.roughness = 0.2
    
    if mesh_data.clearcoat:
        material.clearcoat_enabled = true
        material.clearcoat = 0.5
        material.clearcoat_roughness = 0.1
    
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    
    return mesh_instance

func create_limb(limb_type, stage = null, variant = 0):
    if stage == null:
        stage = current_stage
    
    # Verify that this limb type is available at current stage
    if not evolution_stages[stage].limb_variations.has(limb_type):
        print("Limb type '" + limb_type + "' not available at stage " + str(stage))
        return null
    
    # Get variation data
    var variations = evolution_stages[stage].limb_variations[limb_type]
    if variant >= variations.size():
        variant = 0
    
    var variation_data = variations[variant]
    
    # Create limb node
    var limb = Node3D.new()
    limb.name = limb_type.capitalize() + "_" + str(randi())
    
    # Create mesh
    var mesh_instance = create_mesh_from_data(variation_data.mesh_data)
    limb.add_child(mesh_instance)
    
    # Store properties as metadata
    limb.set_meta("limb_type", limb_type)
    limb.set_meta("stage", stage)
    limb.set_meta("variant", variant)
    limb.set_meta("properties", variation_data.properties)
    
    # Generate unique ID
    var limb_id = str(randi()) + "_" + limb_type + "_" + str(stage)
    limb.set_meta("id", limb_id)
    
    # Add to active limbs
    active_limbs[limb_id] = limb
    
    # Add collision for interactivity
    var area = Area3D.new()
    area.name = "InteractionArea"
    var collision = CollisionShape3D.new()
    var shape = SphereShape3D.new()
    shape.radius = 0.5  # Approximate size
    collision.shape = shape
    area.add_child(collision)
    limb.add_child(area)
    
    # Setup interaction
    area.input_event.connect(_on_limb_input_event.bind(limb))
    
    return limb

func _on_limb_input_event(camera, event, click_pos, click_normal, shape_idx, limb):
    if event is InputEventMouseButton and event.pressed:
        show_limb_info(limb)

func show_limb_info(limb):
    # Display information about the limb
    var limb_type = limb.get_meta("limb_type")
    var stage = limb.get_meta("stage")
    var properties = limb.get_meta("properties")
    
    print("=== Limb Information ===")
    print("Type: " + limb_type)
    print("Evolution Stage: " + str(stage))
    print("Properties:")
    for key in properties:
        print("  " + key + ": " + str(properties[key]))

func collect_word(word, element_type = null):
    # Check if word is valid for any stage
    var stage_found = false
    var word_stage = null
    
    for stage in evolution_stages:
        if evolution_stages[stage].available_words.has(word):
            stage_found = true
            word_stage = stage
            break
    
    if not stage_found:
        print("Word '" + word + "' not recognized in evolution matrix")
        return false
    
    # If element type not specified, assign one
    if element_type == null:
        var possible_elements = word_elements.keys()
        element_type = possible_elements[randi() % possible_elements.size()]
    
    print("Word collected: '" + word + "' (element: " + element_type + ", stage: " + str(word_stage) + ")")
    
    # Emit signal
    emit_signal("word_collected", word, element_type)
    
    # Check if this word helps unlock a new stage
    check_stage_unlock()
    
    return true

func check_stage_unlock():
    # Check if requirements for next stage are met
    var next_stage = current_stage + 1
    
    if next_stage >= NUMERIC_STAGES:
        return  # Already at max stage
    
    if evolution_stages[next_stage].unlocked:
        return  # Already unlocked
    
    var requirements = evolution_stages[next_stage].requirements
    var all_met = true
    
    # Check each requirement
    for req in requirements:
        match req.type:
            "words_collected":
                # Simplified check - in real implementation, track collected words
                if get_collected_word_count() < req.count:
                    all_met = false
            "core_evolved":
                if not has_core_at_level(req.level):
                    all_met = false
            "firewall_strength":
                if firewall_strength < req.value:
                    all_met = false
            "memory_capacity":
                if memory_capacity < req.value:
                    all_met = false
            # Other requirement checks would go here
    
    if all_met:
        unlock_stage(next_stage)

func get_collected_word_count():
    # Simplified implementation - in real use, track actual collected words
    return 10  # Always return enough for testing

func has_core_at_level(level):
    # Check if a core limb exists at the specified level
    for limb_id in active_limbs:
        var limb = active_limbs[limb_id]
        if limb.get_meta("limb_type") == "core" and limb.get_meta("stage") >= level:
            return true
    return false

func unlock_stage(stage):
    if stage < 0 or stage >= NUMERIC_STAGES:
        return
    
    evolution_stages[stage].unlocked = true
    current_stage = stage
    
    print("Stage " + str(stage) + " unlocked!")
    
    # Emit signal
    emit_signal("stage_unlocked", stage)

func evolve_limb(limb, new_stage = null):
    # Evolve a limb to the next stage
    var current_limb_stage = limb.get_meta("stage")
    var limb_type = limb.get_meta("limb_type")
    var variant = limb.get_meta("variant")
    var limb_id = limb.get_meta("id")
    
    if new_stage == null:
        new_stage = current_limb_stage + 1
    
    if new_stage >= NUMERIC_STAGES:
        print("Limb already at maximum evolution stage")
        return null
    
    if not evolution_stages[new_stage].unlocked:
        print("Evolution stage " + str(new_stage) + " not yet unlocked")
        return null
    
    # Check if this limb type is available at the new stage
    if not evolution_stages[new_stage].limb_variations.has(limb_type):
        print("Limb type '" + limb_type + "' cannot evolve to stage " + str(new_stage))
        return null
    
    # Create new evolved limb
    var new_limb = create_limb(limb_type, new_stage, variant)
    if new_limb == null:
        return null
    
    # Position at same location as original
    new_limb.global_transform = limb.global_transform
    
    # Replace in scene
    var parent = limb.get_parent()
    parent.add_child(new_limb)
    parent.remove_child(limb)
    
    # Remove from active limbs
    active_limbs.erase(limb_id)
    
    # Emit signal
    emit_signal("limb_evolved", new_limb.get_meta("id"), new_stage, limb_type)
    
    return new_limb

func create_firewall_protection():
    # Initialize firewall system
    firewall_strength = 1
    
    # Define paths to protect
    var protected_paths = [
        "/mnt/d/",
        "/user/data/",
        "/system/core/",
        "/memory/primary/"
    ]
    
    print("Firewall initialized with strength " + str(firewall_strength))
    print("Protected paths: " + str(protected_paths))
    
    emit_signal("firewall_updated", firewall_strength, protected_paths)

func upgrade_firewall(amount = 1):
    var previous = firewall_strength
    firewall_strength += amount
    
    print("Firewall upgraded from " + str(previous) + " to " + str(firewall_strength))
    
    # Check if this helps unlock a new stage
    check_stage_unlock()
    
    emit_signal("firewall_updated", firewall_strength, [])  # Could pass updated protected paths here
    
    return firewall_strength

func expand_memory(amount = 10):
    var previous = memory_capacity
    memory_capacity += amount
    
    print("Memory capacity increased from " + str(previous) + " to " + str(memory_capacity))
    
    # Check if this helps unlock a new stage
    check_stage_unlock()
    
    emit_signal("memory_capacity_changed", previous, memory_capacity)
    
    return memory_capacity

func word_yoyo_effect(word1, word2, iterations = 3):
    # Simulate the yoyo effect between words
    var combined_words = []
    var current_word = word1
    
    print("Starting word yoyo effect: " + word1 + " <-> " + word2)
    
    for i in range(iterations):
        # Forward motion
        var transition_forward = current_word + " → " + word2
        print("Yoyo iteration " + str(i+1) + ": " + transition_forward)
        combined_words.append(transition_forward)
        current_word = word2
        
        # Backward motion
        var transition_backward = current_word + " → " + word1
        print("Yoyo iteration " + str(i+1) + ": " + transition_backward)
        combined_words.append(transition_backward)
        current_word = word1
    
    return combined_words

# Function to trigger numeric progression (0-9)
func numeric_progression(current_number, step = 1):
    var next_number = (current_number + step) % 10  # 0-9 cycle
    print("Numeric progression: " + str(current_number) + " → " + str(next_number))
    
    # Trigger stage-specific events
    match next_number:
        0: print("Cycle complete - rebirth")
        3: print("Triad stability achieved")
        7: print("Mystical seventh reached")
        9: print("Final form before transformation")
    
    return next_number
# ==================================================
# UNIVERSAL BEING COMPONENT: Universe LOD
# PURPOSE: Manages Level of Detail and observation states for a universe
# ==================================================

extends Component
class_name UniverseLODComponent

# LOD parameters
var current_lod: int = 1
var max_lod: int = 5
var min_lod: int = 0
var lod_transition_speed: float = 1.0
var lod_enabled: bool = true

# LOD state
var is_observed: bool = false
var observer_position: Vector3 = Vector3.ZERO
var lod_transition_progress: float = 0.0
var active_lod_effects: Array[Dictionary] = []

# LOD presets
const LOD_PRESETS = {
    0: {  # Minimal detail
        "particle_count": 100,
        "physics_quality": 0.5,
        "render_distance": 100.0,
        "texture_quality": 0.25,
        "simulation_rate": 0.25
    },
    1: {  # Low detail
        "particle_count": 500,
        "physics_quality": 0.75,
        "render_distance": 200.0,
        "texture_quality": 0.5,
        "simulation_rate": 0.5
    },
    2: {  # Medium detail
        "particle_count": 1000,
        "physics_quality": 1.0,
        "render_distance": 400.0,
        "texture_quality": 0.75,
        "simulation_rate": 0.75
    },
    3: {  # High detail
        "particle_count": 2000,
        "physics_quality": 1.5,
        "render_distance": 800.0,
        "texture_quality": 1.0,
        "simulation_rate": 1.0
    },
    4: {  # Ultra detail
        "particle_count": 5000,
        "physics_quality": 2.0,
        "render_distance": 1600.0,
        "texture_quality": 1.5,
        "simulation_rate": 1.5
    },
    5: {  # Maximum detail
        "particle_count": 10000,
        "physics_quality": 3.0,
        "render_distance": 3200.0,
        "texture_quality": 2.0,
        "simulation_rate": 2.0
    }
}

func _init() -> void:
    component_name = "universe_lod"
    component_version = "1.0.0"
    component_description = "Manages Level of Detail and observation states for a universe"

func update_lod(target_lod: int) -> void:
    """Updates the LOD level with smooth transition"""
    if not lod_enabled:
        return
        
    target_lod = clamp(target_lod, min_lod, max_lod)
    
    if target_lod != current_lod:
        start_lod_transition(target_lod)

func start_lod_transition(target_lod: int) -> void:
    """Starts a smooth transition to a new LOD level"""
    var transition = {
        "start_lod": current_lod,
        "target_lod": target_lod,
        "progress": 0.0,
        "active": true
    }
    
    active_lod_effects.append(transition)
    current_lod = target_lod

func process_lod_transitions(delta: float) -> void:
    """Processes active LOD transitions"""
    var transitions_to_remove = []
    
    for i in range(active_lod_effects.size()):
        var transition = active_lod_effects[i]
        transition.progress += delta * lod_transition_speed
        
        if transition.progress >= 1.0:
            # Transition complete
            apply_lod_preset(transition.target_lod)
            transitions_to_remove.append(i)
        else:
            # Interpolate between LOD levels
            var interpolated_lod = lerp(
                transition.start_lod,
                transition.target_lod,
                transition.progress
            )
            apply_lod_preset(interpolated_lod)
    
    # Remove completed transitions
    for i in range(transitions_to_remove.size() - 1, -1, -1):
        active_lod_effects.remove_at(transitions_to_remove[i])

func apply_lod_preset(lod_level: int) -> void:
    """Applies LOD preset settings"""
    var preset = LOD_PRESETS[lod_level]
    
    # Update particle systems
    var particles = get_tree().get_nodes_in_group("particle_systems")
    for particle in particles:
        if particle is GPUParticles3D:
            particle.amount = int(preset.particle_count)
    
    # Update physics quality
    var physics = get_tree().get_nodes_in_group("physics_bodies")
    for body in physics:
        if body is PhysicsBody3D:
            body.physics_material_override.friction = preset.physics_quality
            body.physics_material_override.rough = preset.physics_quality > 1.0
    
    # Update render distance
    var cameras = get_tree().get_nodes_in_group("cameras")
    for camera in cameras:
        if camera is Camera3D:
            camera.far = preset.render_distance
    
    # Update texture quality
    var materials = get_tree().get_nodes_in_group("materials")
    for material in materials:
        if material is StandardMaterial3D:
            material.roughness = 1.0 - preset.texture_quality
            material.metallic = preset.texture_quality
    
    # Update simulation rate
    var simulators = get_tree().get_nodes_in_group("simulators")
    for simulator in simulators:
        if simulator.has_method("set_simulation_rate"):
            simulator.set_simulation_rate(preset.simulation_rate)

func set_observer(position: Vector3) -> void:
    """Sets the observer position for LOD calculations"""
    observer_position = position
    is_observed = true
    
    # Recalculate LOD based on observer distance
    var distance = position.length()
    var new_lod = calculate_lod_from_distance(distance)
    update_lod(new_lod)

func calculate_lod_from_distance(distance: float) -> int:
    """Calculates appropriate LOD level based on distance"""
    if distance > 2000.0:
        return 0
    elif distance > 1000.0:
        return 1
    elif distance > 500.0:
        return 2
    elif distance > 250.0:
        return 3
    elif distance > 100.0:
        return 4
    else:
        return 5

func get_lod_state() -> Dictionary:
    """Returns current LOD state"""
    return {
        "current_lod": current_lod,
        "is_observed": is_observed,
        "active_transitions": active_lod_effects.size(),
        "observer_distance": observer_position.length() if is_observed else -1.0
    } 
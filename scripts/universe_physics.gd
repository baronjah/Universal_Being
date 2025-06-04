# ==================================================
# UNIVERSAL BEING COMPONENT: Universe Physics
# PURPOSE: Manages physics parameters for a universe
# ==================================================

extends Component
class_name UniversePhysicsComponent

# Physics parameters
var gravity: Vector3 = Vector3(0, -9.8, 0)
var spatial_scale: float = 1.0
var particle_density: float = 1.0
var quantum_fluctuation: float = 0.1
var physics_enabled: bool = true

# Physics state
var active_forces: Array[Dictionary] = []
var collision_layers: int = 1
var collision_masks: int = 1

func _init() -> void:
    component_name = "universe_physics"
    component_version = "1.0.0"
    component_description = "Manages physics parameters for a universe"

func process_physics(delta: float) -> void:
    """Process physics for this universe"""
    if not physics_enabled:
        return
        
    # Apply gravity
    if gravity != Vector3.ZERO:
        apply_gravity(delta)
    
    # Process quantum effects
    if quantum_fluctuation > 0:
        process_quantum_effects(delta)
    
    # Update particle systems
    if particle_density > 0:
        update_particle_systems(delta)

func apply_gravity(delta: float) -> void:
    """Applies gravity to all physics bodies in the universe"""
    if not attached_being:
        return
    var space_state = attached_being.get_world_3d().direct_space_state
    var bodies = attached_being.get_tree().get_nodes_in_group("physics_bodies")
    
    for body in bodies:
        if body is PhysicsBody3D:
            body.apply_central_force(gravity * body.mass * delta)

func process_quantum_effects(delta: float) -> void:
    """Processes quantum effects in the universe"""
    # TODO: Implement quantum effects
    pass

func update_particle_systems(delta: float) -> void:
    """Updates particle systems based on density"""
    var particles = get_tree().get_nodes_in_group("particle_systems")
    
    for particle in particles:
        if particle is GPUParticles3D:
            particle.amount = int(particle_density * 1000)
            particle.process_material.particle_density = particle_density

func set_physics_parameters(params: Dictionary) -> void:
    """Updates physics parameters"""
    if params.has("gravity"):
        gravity = params.gravity
    if params.has("spatial_scale"):
        spatial_scale = params.spatial_scale
    if params.has("particle_density"):
        particle_density = params.particle_density
    if params.has("quantum_fluctuation"):
        quantum_fluctuation = params.quantum_fluctuation

func add_force(force: Vector3, position: Vector3, radius: float) -> void:
    """Adds a force field to the universe"""
    active_forces.append({
        "force": force,
        "position": position,
        "radius": radius,
        "time_remaining": 1.0
    })

func remove_force(index: int) -> void:
    """Removes a force field"""
    if index >= 0 and index < active_forces.size():
        active_forces.remove_at(index)

func get_physics_state() -> Dictionary:
    """Returns current physics state"""
    return {
        "gravity": gravity,
        "spatial_scale": spatial_scale,
        "particle_density": particle_density,
        "quantum_fluctuation": quantum_fluctuation,
        "physics_enabled": physics_enabled,
        "active_forces": active_forces.size()
    } 
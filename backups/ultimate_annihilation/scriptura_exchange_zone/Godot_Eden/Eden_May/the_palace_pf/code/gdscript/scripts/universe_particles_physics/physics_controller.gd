# PhysicsController.gd - Handles physics simulation
extends Node3D

var config

func apply_physics(delta):
	# Get all particles from particle system
	var particle_system = get_parent().particle_system
	
	for particle in particle_system.particles:
		# Apply gravity
		particle.velocity += config.gravity * delta


# Handles physics simulation for the universe
extends Node3D

var config: Dictionary

# Apply physics to all entities
func apply_physics(delta: float) -> void:
	# Get all particles from particle system
	var particle_system = get_parent().particle_system
	
	# Apply physics to particles
	for particle in particle_system.particles:
		if particle.has_meta("velocity"):
			# Apply gravity
			var velocity = particle.get_meta("velocity")
			velocity += config.gravity * delta
			particle.set_meta("velocity", velocity)
	
	# Update particle positions
	particle_system.update_particles(delta)
	
	# Update shapes
	var shape_generator = get_parent().shape_generator
	shape_generator.update_shapes(delta)

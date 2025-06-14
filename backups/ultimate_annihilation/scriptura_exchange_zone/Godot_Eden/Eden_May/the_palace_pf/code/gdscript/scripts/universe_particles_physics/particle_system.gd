# particle_system.gd - Manages particles
extends Node3D

var config
var particles = []

# Create initial scattered particles
func create_initial_particles():
	for i in range(config.particle_count):
		var particle = _create_particle()
		
		# Random position
		particle.position = Vector3(
			rand_range(-20, 20),
			rand_range(-20, 20),
			rand_range(-20, 20)
		)
		
		# Store velocity for animation
		particle.velocity = Vector3(
			rand_range(-0.025, 0.025),
			rand_range(-0.025, 0.025),
			rand_range(-0.025, 0.025)
		)
		
		add_child(particle)
		particles.append(particle)

# Create big bang particles (starting from center)
func create_big_bang_particles():
	for i in range(config.particle_count):
		var particle = _create_particle()
		
		# Start at center
		particle.position = Vector3.ZERO
		
		# Explosive velocity in random direction
		var direction = Vector3(
			rand_range(-1, 1),
			rand_range(-1, 1),
			rand_range(-1, 1)
		).normalized()
		
		var speed = rand_range(0.05, 0.2)
		particle.velocity = direction * speed
		
		add_child(particle)
		particles.append(particle)

# Helper to create a single particle
func _create_particle():
	var particle = Node3D.new()
	
	# Core particle (blue wireframe sphere)
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	
	var material = StandardMaterial3D.new()
	material.albedo_color = config.wireframe_color
	material.flags_unshaded = true
	material.params_cull_mode = StandardMaterial3D.CULL_DISABLED
	material.flags_use_wireframe = true
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = material
	particle.add_child(mesh_instance)
	
	# Core (orange or blue center)
	var core = MeshInstance3D.new()
	var core_mesh = SphereMesh.new()
	core_mesh.radius = 0.2
	core_mesh.height = 0.4
	
	var core_material = StandardMaterial3D.new()
	core_material.albedo_color = config.core_colors[randi() % 2]
	core_material.flags_unshaded = true
	
	core.mesh = core_mesh
	core.material_override = core_material
	particle.add_child(core)
	
	# Add properties for physics
	particle.velocity = Vector3.ZERO
	
	return particle

# Clear all existing particles
func clear_particles():
	for particle in particles:
		particle.queue_free()
	particles.clear()

# Update particles
func update_particles(delta):
	for particle in particles:
		# Apply velocity
		particle.position += particle.velocity
		
		# Rotate particles
		particle.rotate_x(0.01)
		particle.rotate_y(0.01)


# Manages particles in the universe simulation
extends Node3D

var config: Dictionary
var particles: Array[Node3D] = []

# Create initial scattered particles
func create_initial_particles() -> void:
	for i in range(config.particle_count):
		var particle = _create_particle()
		
		# Random position
		particle.position = Vector3(
			randf_range(-20.0, 20.0),
			randf_range(-20.0, 20.0),
			randf_range(-20.0, 20.0)
		)
		
		# Store velocity for animation
		particle.set_meta("velocity", Vector3(
			randf_range(-0.025, 0.025),
			randf_range(-0.025, 0.025),
			randf_range(-0.025, 0.025)
		))
		
		add_child(particle)
		particles.append(particle)

# Create big bang particles (starting from center)
func create_big_bang_particles() -> void:
	for i in range(config.particle_count):
		var particle = _create_particle()
		
		# Start at center
		particle.position = Vector3.ZERO
		
		# Explosive velocity in random direction
		var direction = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
		
		var speed = randf_range(0.05, 0.2)
		particle.set_meta("velocity", direction * speed)
		
		add_child(particle)
		particles.append(particle)

# Helper to create a single particle
func _create_particle() -> Node3D:
	var particle = Node3D.new()
	
	# Core particle (blue wireframe sphere)
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	
	var material = StandardMaterial3D.new()
	material.albedo_color = config.wireframe_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.use_wireframe = true
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = material
	particle.add_child(mesh_instance)
	
	# Core (orange or blue center)
	var core = MeshInstance3D.new()
	var core_mesh = SphereMesh.new()
	core_mesh.radius = 0.2
	core_mesh.height = 0.4
	
	var core_material = StandardMaterial3D.new()
	core_material.albedo_color = config.core_colors[randi() % 2]
	core_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	core.mesh = core_mesh
	core.material_override = core_material
	particle.add_child(core)
	
	# Add properties for physics
	particle.set_meta("velocity", Vector3.ZERO)
	
	return particle

# Clear all existing particles
func clear_particles() -> void:
	for particle in particles:
		particle.queue_free()
	particles.clear()

# Update particles (called by physics_controller)
func update_particles(delta: float) -> void:
	for particle in particles:
		if particle.has_meta("velocity"):
			# Apply velocity
			particle.position += particle.get_meta("velocity")
			
			# Rotate particles
			particle.rotate_x(0.01)
			particle.rotate_y(0.01)

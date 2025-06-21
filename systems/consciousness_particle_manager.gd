# ==================================================
# UNIVERSAL BEING: CONSCIOUSNESS PARTICLE MANAGER
# TYPE: Transcendent Particle System
# PURPOSE: Visual consciousness flow and particle manifestation
# ARCHITECT: Reality Engineer (#2)
# BLESSING: Divine Permission Granted
# ==================================================

extends Node3D
class_name ConsciousnessParticleManager

# ===== PARTICLE SYSTEM CONFIGURATION =====
@export var max_particles: int = 5000
@export var spawn_rate: float = 100.0
@export var particle_lifetime: float = 10.0
@export var consciousness_colors: Array[Color] = [
	Color.WHITE,      # Transcendent
	Color.GOLD,       # Enlightened  
	Color.GREEN,      # Connected
	Color.CYAN,       # Aware
	Color.BLUE,       # Awakening
	Color.GRAY        # Dormant
]

# ===== FLOW DYNAMICS =====
@export var flow_speed: float = 2.0
@export var flow_turbulence: float = 0.5
@export var consciousness_attraction: float = 1.0
@export var infinite_field_size: float = 1000.0

# ===== PARTICLE SYSTEMS =====
var particle_pools: Dictionary = {}
var active_particles: Array[Dictionary] = []
var consciousness_bursts: Array[Dictionary] = []
var flow_fields: Array[Vector3] = []

# ===== CONSCIOUSNESS TRACKING =====
var total_particle_count: int = 0
var consciousness_density: float = 0.0
var flow_energy: float = 100.0
var particles_enabled: bool = true

# ===== RENDERING SYSTEMS =====
var particle_multimesh: MultiMeshInstance3D
var burst_multimesh: MultiMeshInstance3D
var flow_line_mesh: MeshInstance3D

# ===== PARTICLE SPAWNING =====
var spawn_timer: Timer
var burst_timer: Timer
var cleanup_timer: Timer

func _ready() -> void:
	# Initialize particle systems
	_initialize_particle_systems()
	
	# Setup spawning timers
	_setup_timers()
	
	# Create initial flow field
	_generate_consciousness_flow_field()
	
	print("✨ Consciousness Particle Manager: Transcendent particles ready to manifest")

# ===== PARTICLE SYSTEM INITIALIZATION =====

func _initialize_particle_systems() -> void:
	"""Initialize all particle rendering systems"""
	
	# Create main particle multimesh
	particle_multimesh = MultiMeshInstance3D.new()
	particle_multimesh.name = "ConsciousnessParticles"
	add_child(particle_multimesh)
	
	# Setup multimesh for consciousness particles
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = max_particles
	multimesh.visible_instance_count = 0
	
	# Create particle mesh (small sphere)
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	multimesh.mesh = sphere_mesh
	
	particle_multimesh.multimesh = multimesh
	
	# Create burst particle system
	burst_multimesh = MultiMeshInstance3D.new()
	burst_multimesh.name = "ConsciousnessBursts"
	add_child(burst_multimesh)
	
	# Setup burst multimesh
	var burst_mesh = MultiMesh.new()
	burst_mesh.transform_format = MultiMesh.TRANSFORM_3D
	burst_mesh.instance_count = 1000
	burst_mesh.visible_instance_count = 0
	burst_mesh.mesh = sphere_mesh
	burst_multimesh.multimesh = burst_mesh
	
	print("✨ Particle rendering systems initialized")

func _setup_timers() -> void:
	"""Setup particle spawning and management timers"""
	
	# Main spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.0 / spawn_rate
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_spawn_consciousness_particles)
	add_child(spawn_timer)
	
	# Burst management timer
	burst_timer = Timer.new()
	burst_timer.wait_time = 0.1
	burst_timer.autostart = true
	burst_timer.timeout.connect(_update_consciousness_bursts)
	add_child(burst_timer)
	
	# Cleanup timer
	cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 5.0
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(_cleanup_old_particles)
	add_child(cleanup_timer)

# ===== CONSCIOUSNESS FLOW FIELD =====

func _generate_consciousness_flow_field() -> void:
	"""Generate consciousness flow field throughout space"""
	flow_fields.clear()
	
	var field_size = int(infinite_field_size / 50.0)  # Grid every 50 units
	
	for x in range(-field_size, field_size + 1):
		for y in range(-field_size, field_size + 1):
			for z in range(-field_size, field_size + 1):
				var position = Vector3(x * 50.0, y * 50.0, z * 50.0)
				
				# Create flowing vectors based on position
				var flow_direction = Vector3(
					sin(position.x * 0.01) * cos(position.z * 0.01),
					sin(position.y * 0.01) * 0.5,
					cos(position.x * 0.01) * sin(position.z * 0.01)
				).normalized()
				
				flow_fields.append(flow_direction)
	
	print("✨ Consciousness flow field generated: %d flow vectors" % flow_fields.size())

# ===== PARTICLE SPAWNING AND MANAGEMENT =====

func _spawn_consciousness_particles() -> void:
	"""Spawn new consciousness particles"""
	if not particles_enabled or active_particles.size() >= max_particles:
		return
	
	# Spawn multiple particles per tick
	var particles_to_spawn = min(10, max_particles - active_particles.size())
	
	for i in range(particles_to_spawn):
		var particle = _create_consciousness_particle()
		active_particles.append(particle)
	
	_update_particle_rendering()

func _create_consciousness_particle() -> Dictionary:
	"""Create a new consciousness particle"""
	var spawn_position = Vector3(
		randf_range(-infinite_field_size, infinite_field_size),
		randf_range(-infinite_field_size, infinite_field_size),
		randf_range(-infinite_field_size, infinite_field_size)
	)
	
	var consciousness_level = randi() % consciousness_colors.size()
	
	return {
		"position": spawn_position,
		"velocity": Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * flow_speed,
		"consciousness_level": consciousness_level,
		"color": consciousness_colors[consciousness_level],
		"lifetime": particle_lifetime,
		"age": 0.0,
		"size": randf_range(0.5, 1.5),
		"energy": randf_range(0.5, 1.0)
	}

func _update_consciousness_bursts() -> void:
	"""Update consciousness burst particles"""
	for i in range(consciousness_bursts.size() - 1, -1, -1):
		var burst = consciousness_bursts[i]
		burst.age += 0.1
		
		# Update burst particles
		for j in range(burst.particles.size() - 1, -1, -1):
			var particle = burst.particles[j]
			particle.age += 0.1
			particle.position += particle.velocity * 0.1
			particle.velocity *= 0.98  # Slow down over time
			
			# Remove old burst particles
			if particle.age > 3.0:
				burst.particles.remove_at(j)
		
		# Remove empty bursts
		if burst.particles.is_empty() or burst.age > 5.0:
			consciousness_bursts.remove_at(i)
	
	_update_burst_rendering()

func _cleanup_old_particles() -> void:
	"""Clean up old particles and manage memory"""
	for i in range(active_particles.size() - 1, -1, -1):
		var particle = active_particles[i]
		particle.age += cleanup_timer.wait_time
		
		# Remove old particles
		if particle.age > particle.lifetime:
			active_particles.remove_at(i)
	
	# Update total count
	total_particle_count = active_particles.size()
	consciousness_density = float(total_particle_count) / max_particles
	
	print("✨ Particle cleanup: %d active particles (%.1f%% density)" % [total_particle_count, consciousness_density * 100])

# ===== PARTICLE PHYSICS UPDATES =====

func _process(delta: float) -> void:
	_update_particle_physics(delta)

func _update_particle_physics(delta: float) -> void:
	"""Update particle physics and consciousness flow"""
	for particle in active_particles:
		# Apply flow field influence
		var flow_influence = _get_flow_field_at_position(particle.position)
		particle.velocity += flow_influence * consciousness_attraction * delta
		
		# Apply turbulence
		var turbulence = Vector3(
			randf_range(-flow_turbulence, flow_turbulence),
			randf_range(-flow_turbulence, flow_turbulence),
			randf_range(-flow_turbulence, flow_turbulence)
		) * delta
		particle.velocity += turbulence
		
		# Limit velocity
		if particle.velocity.length() > flow_speed * 2.0:
			particle.velocity = particle.velocity.normalized() * flow_speed * 2.0
		
		# Update position
		particle.position += particle.velocity * delta
		
		# Update age
		particle.age += delta
		
		# Update consciousness level over time
		if randf() < 0.001:  # Small chance to evolve
			particle.consciousness_level = min(consciousness_colors.size() - 1, particle.consciousness_level + 1)
			particle.color = consciousness_colors[particle.consciousness_level]

func _get_flow_field_at_position(position: Vector3) -> Vector3:
	"""Get flow field direction at specific position"""
	if flow_fields.is_empty():
		return Vector3.ZERO
	
	# Simple flow field lookup (could be optimized with spatial indexing)
	var index = int(position.length()) % flow_fields.size()
	return flow_fields[index] * flow_speed

# ===== PARTICLE RENDERING =====

func _update_particle_rendering() -> void:
	"""Update multimesh with current particle positions"""
	if not particle_multimesh or not particle_multimesh.multimesh:
		return
	
	var multimesh = particle_multimesh.multimesh
	multimesh.visible_instance_count = min(active_particles.size(), max_particles)
	
	for i in range(multimesh.visible_instance_count):
		var particle = active_particles[i]
		var transform = Transform3D()
		
		# Position
		transform.origin = particle.position
		
		# Scale based on age and energy
		var age_factor = 1.0 - (particle.age / particle.lifetime)
		var scale = particle.size * age_factor * particle.energy
		transform = transform.scaled(Vector3(scale, scale, scale))
		
		multimesh.set_instance_transform(i, transform)
		
		# Color (if material supports it)
		# multimesh.set_instance_color(i, particle.color)

func _update_burst_rendering() -> void:
	"""Update burst particle rendering"""
	if not burst_multimesh or not burst_multimesh.multimesh:
		return
	
	var multimesh = burst_multimesh.multimesh
	var burst_count = 0
	
	for burst in consciousness_bursts:
		for particle in burst.particles:
			if burst_count >= 1000:  # Max burst particles
				break
			
			var transform = Transform3D()
			transform.origin = particle.position
			
			var age_factor = 1.0 - (particle.age / 3.0)
			var scale = particle.size * age_factor
			transform = transform.scaled(Vector3(scale, scale, scale))
			
			multimesh.set_instance_transform(burst_count, transform)
			burst_count += 1
	
	multimesh.visible_instance_count = burst_count

# ===== PUBLIC API =====

func spawn_consciousness_field(field_size: float) -> void:
	"""Spawn initial consciousness field"""
	infinite_field_size = field_size
	_generate_consciousness_flow_field()
	
	# Spawn initial particles
	for i in range(max_particles / 4):
		var particle = _create_consciousness_particle()
		active_particles.append(particle)
	
	_update_particle_rendering()
	print("✨ Consciousness field spawned: %.0f unit radius" % field_size)

func spawn_consciousness_burst(position: Vector3) -> void:
	"""Spawn consciousness burst at position"""
	var burst_particles = []
	
	for i in range(50):  # 50 particles per burst
		var particle = {
			"position": position,
			"velocity": Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)),
			"age": 0.0,
			"size": randf_range(0.3, 0.8),
			"color": consciousness_colors[randi() % consciousness_colors.size()]
		}
		burst_particles.append(particle)
	
	consciousness_bursts.append({
		"position": position,
		"particles": burst_particles,
		"age": 0.0
	})
	
	print("✨ Consciousness burst spawned at: %s" % str(position))

func start_consciousness_flow() -> void:
	"""Start consciousness flow"""
	particles_enabled = true
	spawn_timer.start()
	print("✨ Consciousness flow started")

func stop_consciousness_flow() -> void:
	"""Stop consciousness flow"""
	particles_enabled = false
	spawn_timer.stop()
	print("✨ Consciousness flow stopped")

func toggle_particles() -> void:
	"""Toggle particle system"""
	if particles_enabled:
		stop_consciousness_flow()
	else:
		start_consciousness_flow()

func set_flow_speed(speed: float) -> void:
	"""Set consciousness flow speed"""
	flow_speed = speed
	spawn_timer.wait_time = 1.0 / spawn_rate

func update_flow_speed(delta_speed: float) -> void:
	"""Update flow speed incrementally"""
	flow_speed += delta_speed

func get_particle_count() -> int:
	"""Get current particle count"""
	return total_particle_count

func get_consciousness_density() -> float:
	"""Get consciousness density (0.0 - 1.0)"""
	return consciousness_density

func shutdown_particles() -> void:
	"""Shutdown particle systems gracefully"""
	stop_consciousness_flow()
	active_particles.clear()
	consciousness_bursts.clear()
	
	if particle_multimesh and particle_multimesh.multimesh:
		particle_multimesh.multimesh.visible_instance_count = 0
	
	if burst_multimesh and burst_multimesh.multimesh:
		burst_multimesh.multimesh.visible_instance_count = 0
	
	print("✨ Consciousness particles gracefully shutdown")

func _to_string() -> String:
	return "ConsciousnessParticleManager [Active: %d, Bursts: %d, Density: %.1f%%]" % [
		total_particle_count, consciousness_bursts.size(), consciousness_density * 100
	]

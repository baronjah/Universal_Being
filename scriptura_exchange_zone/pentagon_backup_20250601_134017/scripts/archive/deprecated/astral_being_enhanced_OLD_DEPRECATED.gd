# ==================================================
# SCRIPT NAME: astral_being_enhanced.gd
# DESCRIPTION: Star-like beings that orbit and understand connections
# CREATED: 2025-05-23 - Points of light with awareness
# ==================================================

extends UniversalBeingBase
# Core properties
var light_point: OmniLight3D
var particles: GPUParticles3D
var area_detector: Area3D

# Movement states
enum MovementMode {
	FREE_FLIGHT,
	ORBITING,
	CREATING,
	FOLLOWING
}

var current_mode: MovementMode = MovementMode.FREE_FLIGHT
var orbit_target: Node3D = null
var orbit_radius: float = 5.0
var orbit_speed: float = 1.0
var orbit_angle: float = 0.0

# Connection awareness
var connected_objects: Array = []
var touching_objects: Array = []
var nearby_objects: Array = []

# Blinking properties
var blink_timer: float = 0.0
var blink_interval: float = 3.0
var blink_duration: float = 0.3
var is_blinking: bool = false

# Creation mode
var creation_particles: Array = []
var hand_positions: Array = []
var infinity_timer: float = 0.0

# Visual properties
var base_color: Color = Color(0.8, 0.6, 1.0)
var base_energy: float = 2.0
var size: float = 0.3

var physics_state_manager: Node

func _ready() -> void:
	_create_star_being()
	set_physics_process(true)
	
	# Get physics state manager
	physics_state_manager = get_node_or_null("/root/PhysicsStateManager")
	if not physics_state_manager:
		print("Warning: PhysicsStateManager not found")

func _create_star_being() -> void:
	# Core light point
	light_point = OmniLight3D.new()
	light_point.light_color = base_color
	light_point.light_energy = base_energy
	light_point.omni_range = 10.0
	light_point.shadow_enabled = true
	add_child(light_point)
	
	# Particle glow effect
	particles = GPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 2.0
	particles.speed_scale = 0.5
	
	# Create particle material
	var process_mat = ParticleProcessMaterial.new()
	process_mat.direction = Vector3.ZERO
	process_mat.initial_velocity_min = 0.1
	process_mat.initial_velocity_max = 0.5
	process_mat.angular_velocity_min = -180.0
	process_mat.angular_velocity_max = 180.0
	process_mat.scale_min = 0.1
	process_mat.scale_max = 0.3
	process_mat.color = base_color
	particles.process_material = process_mat
	
	# Particle mesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.05
	sphere_mesh.height = 0.1
	particles.draw_pass_1 = sphere_mesh
	
	# Glowing material
	var glow_mat = MaterialLibrary.get_material("default")
	glow_mat.emission_enabled = true
	glow_mat.emission = base_color
	glow_mat.emission_energy = 2.0
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color = Color(base_color.r, base_color.g, base_color.b, 0.5)
	particles.material_override = glow_mat
	
	add_child(particles)
	
	# Detection area
	area_detector = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 3.0
	collision_shape.shape = sphere_shape
	FloodgateController.universal_add_child(collision_shape, area_detector)
	add_child(area_detector)
	
	# Connect signals
	area_detector.body_entered.connect(_on_body_entered)
	area_detector.body_exited.connect(_on_body_exited)
	area_detector.area_entered.connect(_on_area_entered)
	area_detector.area_exited.connect(_on_area_exited)

func _physics_process(delta: float) -> void:
	# Update movement based on mode
	match current_mode:
		MovementMode.FREE_FLIGHT:
			_process_free_flight(delta)
		MovementMode.ORBITING:
			_process_orbiting(delta)
		MovementMode.CREATING:
			_process_creating(delta)
		MovementMode.FOLLOWING:
			_process_following(delta)
	
	# Process blinking
	_process_blinking(delta)
	
	# Update connections awareness
	_update_connection_awareness()

func _process_free_flight(delta: float) -> void:
	# Gentle floating movement
	var time = Time.get_ticks_msec() / 1000.0
	var float_offset = Vector3(
		sin(time * 0.5) * 0.5,
		sin(time * 0.7) * 0.3,
		cos(time * 0.3) * 0.5
	)
	
	position += float_offset * delta
	
	# Look for objects to orbit
	if not nearby_objects.is_empty():
		var closest = _find_closest_object()
		if closest and global_position.distance_to(closest.global_position) < orbit_radius * 1.5:
			start_orbiting(closest)

func _process_orbiting(delta: float) -> void:
	if not orbit_target or not is_instance_valid(orbit_target):
		current_mode = MovementMode.FREE_FLIGHT
		orbit_target = null
		return
	
	# Calculate orbit position
	orbit_angle += orbit_speed * delta
	var orbit_pos = orbit_target.global_position + Vector3(
		cos(orbit_angle) * orbit_radius,
		sin(orbit_angle * 0.5) * orbit_radius * 0.3,  # Vertical oscillation
		sin(orbit_angle) * orbit_radius
	)
	
	# Smooth movement to orbit position
	global_position = global_position.lerp(orbit_pos, 5.0 * delta)
	
	# Face the orbited object
	look_at(orbit_target.global_position, Vector3.UP)

func _process_creating(delta: float) -> void:
	# Move hands in infinity pattern
	infinity_timer += delta * 2.0
	
	var center = global_position
	var scale = 2.0
	
	# Figure-8 infinity pattern
	var t = infinity_timer
	var x = scale * sin(t) / (1 + cos(t) * cos(t))
	var y = scale * sin(t) * cos(t) / (1 + cos(t) * cos(t))
	
	# Create light trails
	if creation_particles.size() < 20:
		var trail_light = _create_trail_light()
		trail_light.position = Vector3(x, y, 0)
		creation_particles.append(trail_light)
	
	# Move existing particles
	for i in range(creation_particles.size()):
		var particle = creation_particles[i]
		if is_instance_valid(particle):
			var offset = float(i) / creation_particles.size() * TAU
			var trail_t = t - offset * 0.1
			var trail_x = scale * sin(trail_t) / (1 + cos(trail_t) * cos(trail_t))
			var trail_y = scale * sin(trail_t) * cos(trail_t) / (1 + cos(trail_t) * cos(trail_t))
			particle.position = Vector3(trail_x, trail_y, 0)

func _process_following(delta: float) -> void:
	# Follow player or designated target
	pass

func _process_blinking(delta: float) -> void:
	blink_timer += delta
	
	if blink_timer >= blink_interval:
		is_blinking = true
		blink_timer = 0.0
	
	if is_blinking:
		# Blink effect
		var blink_progress = (blink_timer / blink_duration)
		if blink_progress < 0.5:
			light_point.light_energy = base_energy * (1.0 - blink_progress * 2.0)
		else:
			light_point.light_energy = base_energy * ((blink_progress - 0.5) * 2.0)
		
		if blink_timer >= blink_duration:
			is_blinking = false
			light_point.light_energy = base_energy

func _update_connection_awareness() -> void:
	# Clear old connections
	connected_objects.clear()
	
	# Check each nearby object for connections
	for obj in nearby_objects:
		if _is_connected_to(obj):
			connected_objects.append(obj)
	
	# Update visual feedback based on connections
	if connected_objects.size() > 0:
		base_color = Color(0.9, 0.7, 1.0)  # Brighter when connected
	else:
		base_color = Color(0.8, 0.6, 1.0)  # Normal color
	
	light_point.light_color = base_color

func _is_connected_to(obj: Node3D) -> bool:
	# Check if objects are connected (touching or very close)
	for touching in touching_objects:
		if touching == obj:
			return true
	
	# Check for other connection types (parent-child, groups, etc)
	if obj and orbit_target and obj.get_parent() == orbit_target:
		return true
	if obj and orbit_target and orbit_target.get_parent() == obj:
		return true
	
	# Check for shared groups
	for group in obj.get_groups():
		if orbit_target and orbit_target.is_in_group(group):
			return true
	
	return false

func _create_trail_light() -> Node3D:
	var trail = Node3D.new()
	
	var trail_light = OmniLight3D.new()
	trail_light.light_color = base_color
	trail_light.light_energy = 0.5
	trail_light.omni_range = 2.0
	FloodgateController.universal_add_child(trail_light, trail)
	
	add_child(trail)
	return trail

func _find_closest_object() -> Node3D:
	var closest: Node3D = null
	var min_distance: float = INF
	
	for obj in nearby_objects:
		var dist = global_position.distance_to(obj.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = obj
	
	return closest

# Public interface

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func start_orbiting(target: Node3D) -> void:
	orbit_target = target
	current_mode = MovementMode.ORBITING
	orbit_angle = global_position.angle_to(target.global_position)
	
	# Adjust orbit radius based on target size
	if target.has_method("get_bounding_box"):
		orbit_radius = target.get_bounding_box().size.length() + 2.0
	else:
		orbit_radius = 5.0

func stop_orbiting() -> void:
	current_mode = MovementMode.FREE_FLIGHT
	orbit_target = null

func enter_creation_mode() -> void:
	current_mode = MovementMode.CREATING
	infinity_timer = 0.0
	
	# Clear old particles
	for particle in creation_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	creation_particles.clear()

func manipulate_object(target: Node3D, direction: Vector3) -> bool:
	if not physics_state_manager:
		return false
	
	# First, prepare the object for manipulation
	if not physics_state_manager.prepare_object_for_manipulation(target, self):
		# Try to change its state first
		physics_state_manager.set_object_state(target, 1)  # KINEMATIC
		await get_tree().create_timer(1.0).timeout  # Wait for transition
	
	# Now try to manipulate
	var force = direction * 10.0  # Adjust force as needed
	return physics_state_manager.astral_being_manipulate(self, target, force)

func set_following_target(target: Node3D) -> void:
	orbit_target = target
	current_mode = MovementMode.FOLLOWING

# Signal callbacks
func _on_body_entered(body: Node3D) -> void:
	if not body in nearby_objects:
		nearby_objects.append(body)

func _on_body_exited(body: Node3D) -> void:
	nearby_objects.erase(body)
	if body == orbit_target:
		stop_orbiting()

func _on_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent and parent != self:
		touching_objects.append(parent)

func _on_area_exited(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent:
		touching_objects.erase(parent)

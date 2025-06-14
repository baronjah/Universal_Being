extends Node3D
class_name SpaceSnake

# Snake body segments
var segments = []
var segment_count = 10
var segment_spacing = 0.5
var segment_size = 0.2

# Movement parameters
var speed = 2.0
var turn_speed = 1.5
var follow_distance = 0.5
var target = null
var target_position = Vector3.ZERO
var tilt_factor = 0.5

# Colors and style
var head_color = Color(0.9, 0.2, 0.3)
var body_color = Color(0.2, 0.6, 0.9)
var tail_color = Color(0.2, 0.9, 0.4)

# Behavior
var wander_radius = 10.0
var wander_timer = 0.0
var wander_interval = 3.0
var cosmic_dust_particles = null

# Initialization flag
var is_initialized = false

# Signals
signal collected_item(item_id)

func _ready():
	# Defer initialization to ensure node is properly added to scene tree
	call_deferred("initialize_snake")

func initialize_snake():
	# Wait one frame to make sure the node is properly in the scene tree
	await get_tree().process_frame
	
	# Create the snake body
	create_snake()
	
	# Create cosmic dust particle effect
	create_cosmic_dust()
	
	# Set initial target position
	target_position = global_position + Vector3(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	
	# Mark as initialized
	is_initialized = true
	print("Space Snake initialized at " + str(global_position))

func create_snake():
	# Create the head
	var head = create_segment(head_color)
	head.name = "SnakeHead"
	head.scale = Vector3.ONE * segment_size * 1.5
	segments.append(head)
	add_child(head)
	
	# Initialize position for head
	var init_position = global_position
	
	# Create body segments
	for i in range(1, segment_count):
		var segment = create_segment(body_color.lerp(tail_color, float(i) / segment_count))
		segment.name = "SnakeSegment" + str(i)
		segment.scale = Vector3.ONE * segment_size * (1.0 - 0.3 * float(i) / segment_count)
		
		# Position behind the previous segment - safely
		var prev_seg = segments[i-1]
		
		# Use a safe approach to position segments
		if i == 1:
			# First segment after head - use an offset based on our transform
			var basis = global_transform.basis
			var offset = basis.z * segment_spacing
			segment.global_position = prev_seg.global_position + offset
		else:
			# Other segments - use a simple vector offset
			var direction = (segments[i-2].global_position - prev_seg.global_position).normalized()
			segment.global_position = prev_seg.global_position + direction * segment_spacing
		
		segments.append(segment)
		add_child(segment)

func create_segment(color: Color) -> Node3D:
	var segment = CSGSphere3D.new()
	segment.radius = 1.0  # Will be scaled appropriately later
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.5
	segment.material = material
	
	return segment

func create_cosmic_dust():
	# Only create if we have segments
	if segments.size() == 0:
		print("ERROR: Cannot create cosmic dust - no snake segments")
		return
		
	cosmic_dust_particles = GPUParticles3D.new()
	cosmic_dust_particles.name = "CosmicDust"
	
	# Create particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 0.5
	particle_material.direction = Vector3(0, 0, -1)
	particle_material.spread = 30.0
	particle_material.gravity = Vector3.ZERO
	particle_material.initial_velocity_min = 0.5
	particle_material.initial_velocity_max = 1.0
	particle_material.scale_min = 0.05
	particle_material.scale_max = 0.1
	particle_material.color = Color(0.5, 0.7, 1.0, 0.8)
	
	cosmic_dust_particles.process_material = particle_material
	
	# Create mesh for particles
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = 0.05
	particle_mesh.height = 0.1
	
	cosmic_dust_particles.draw_pass_1 = particle_mesh
	cosmic_dust_particles.amount = 50
	cosmic_dust_particles.lifetime = 2.0
	
	# Add to head
	segments[0].add_child(cosmic_dust_particles)

func _process(delta):
	# Don't process movement until initialized
	if not is_initialized or segments.size() == 0:
		return
		
	# Update wander target
	wander_timer += delta
	if wander_timer >= wander_interval:
		wander_timer = 0
		set_random_target()
	
	# Move head
	move_head(delta)
	
	# Move body segments
	move_body_segments(delta)

func move_head(delta):
	# Get head
	var head = segments[0]
	
	# Direction to target
	var direction_to_target = target_position - head.global_position
	var distance_to_target = direction_to_target.length()
	
	# If we reached the target, get a new one
	if distance_to_target < 0.5:
		set_random_target()
		direction_to_target = target_position - head.global_position
	
	direction_to_target = direction_to_target.normalized()
	
	# Current forward direction - safely get basis
	var current_forward = -head.global_transform.basis.z
	
	# Interpolate direction
	var new_forward = current_forward.lerp(direction_to_target, turn_speed * delta).normalized()
	
	# Set rotation
	var rotation_basis = Basis()
	rotation_basis.z = -new_forward
	rotation_basis.y = Vector3.UP.lerp(direction_to_target * tilt_factor, 0.5).normalized()
	rotation_basis.x = rotation_basis.y.cross(rotation_basis.z).normalized()
	rotation_basis.z = rotation_basis.x.cross(rotation_basis.y).normalized()
	
	head.global_transform.basis = rotation_basis
	
	# Move forward
	head.global_position += new_forward * speed * delta

func move_body_segments(delta):
	# Skip the head (index 0), check valid range
	if segments.size() <= 1:
		return
		
	for i in range(1, segments.size()):
		var segment = segments[i]
		var target_segment = segments[i-1]
		
		# Direction to target segment
		var follow_pos = target_segment.global_position + target_segment.global_transform.basis.z * segment_spacing
		var direction = follow_pos - segment.global_position
		var distance = direction.length()
		
		# Only move if not too close
		if distance > follow_distance * 0.1:
			var movement = min(distance, speed * 0.8 * delta)
			segment.global_position += direction.normalized() * movement
		
		# Rotate to follow
		var look_pos = target_segment.global_position
		var segment_forward = (look_pos - segment.global_position).normalized()
		
		var rotation_basis = Basis()
		rotation_basis.z = -segment_forward
		rotation_basis.y = Vector3.UP.lerp(segment_forward * tilt_factor * 0.5, 0.3).normalized()
		rotation_basis.x = rotation_basis.y.cross(rotation_basis.z).normalized()
		rotation_basis.z = rotation_basis.x.cross(rotation_basis.y).normalized()
		
		segment.global_transform.basis = segment.global_transform.basis.slerp(rotation_basis, 5 * delta)

func set_random_target():
	# Generate a random target within wander radius
	target_position = global_position + Vector3(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

func set_target(new_target_position: Vector3):
	target_position = new_target_position

func set_follow_target(new_target: Node3D):
	target = new_target

func _on_area_entered(area):
	# For collecting items or interacting with environment
	if area.has_method("get_id"):
		emit_signal("collected_item", area.get_id())
		area.queue_free()

# Utility function for spawning a snake
static func spawn_snake(position: Vector3) -> SpaceSnake:
	var snake = SpaceSnake.new()
	snake.global_position = position
	return snake

extends Node
class_name PositionMoverSystem

# 🎯 POSITION MOVER SYSTEM 🎯
# Spatial manipulation system with consciousness awareness
# The fourth of the 4 dead-end scripturas - spatial consciousness manipulation

signal object_moved(object: Node3D, old_position: Vector3, new_position: Vector3, movement_type: String)
signal movement_completed(movement_data: Dictionary)
signal consciousness_influenced_movement(object: Node3D, consciousness_factor: float)
signal teleportation_event(object: Node3D, from_position: Vector3, to_position: Vector3)
signal position_locked(object: Node3D, lock_reason: String)

# Movement types
enum MovementType {
	DIRECT_TRANSLATION,
	SMOOTH_INTERPOLATION,
	CONSCIOUSNESS_FLOW,
	QUANTUM_TELEPORTATION,
	ORBITAL_MOVEMENT,
	PATH_FOLLOWING,
	GRAVITATIONAL_PULL,
	CONSCIOUSNESS_GUIDED
}

# Position mover configuration
@export var enabled: bool = true
@export var consciousness_influence_enabled: bool = true
@export var smooth_movement_enabled: bool = true
@export var quantum_teleportation_enabled: bool = true
@export var visual_feedback_enabled: bool = true

# Movement parameters
@export var default_movement_speed: float = 5.0
@export var consciousness_speed_multiplier: float = 2.0
@export var teleportation_energy_cost: float = 1.0
@export var max_movement_distance: float = 100.0

# Active movements
var active_movements: Dictionary = {}
var movement_queue: Array[MovementCommand] = []
var position_locks: Dictionary = {}
var consciousness_field: ConsciousnessPositionField

# Visual feedback
var movement_trails: Array[MovementTrail] = []
var teleportation_effects: Array[TeleportationEffect] = []
var position_markers: Array[PositionMarker] = []

class MovementCommand:
	var object: Node3D
	var target_position: Vector3
	var movement_type: MovementType
	var movement_speed: float
	var consciousness_level: float
	var start_time: float
	var duration: float
	var completion_callback: Callable
	var movement_data: Dictionary
	
	func _init(obj: Node3D, target: Vector3, type: MovementType = MovementType.SMOOTH_INTERPOLATION):
		object = obj
		target_position = target
		movement_type = type
		movement_speed = 5.0
		consciousness_level = 1.0
		start_time = Time.get_ticks_msec() / 1000.0
		duration = 1.0
		movement_data = {}

class ConsciousnessPositionField:
	var field_resolution: int = 32
	var consciousness_influence_grid: Array[Array] = []
	var field_bounds: AABB
	var temporal_consciousness_flow: Vector3 = Vector3.ZERO
	
	func _init(bounds: AABB):
		field_bounds = bounds
		_initialize_consciousness_grid()
	
	func _initialize_consciousness_grid():
		consciousness_influence_grid = []
		for x in range(field_resolution):
			var row = []
			for y in range(field_resolution):
				var col = []
				for z in range(field_resolution):
					col.append({
						"consciousness_density": 0.0,
						"flow_direction": Vector3.ZERO,
						"movement_resistance": 1.0
					})
				row.append(col)
			consciousness_influence_grid.append(row)
	
	func sample_consciousness_at_position(position: Vector3) -> Dictionary:
		var relative_pos = (position - field_bounds.position) / field_bounds.size
		relative_pos = relative_pos.clamp(Vector3.ZERO, Vector3.ONE)
		
		var grid_x = int(relative_pos.x * (field_resolution - 1))
		var grid_y = int(relative_pos.y * (field_resolution - 1))
		var grid_z = int(relative_pos.z * (field_resolution - 1))
		
		return consciousness_influence_grid[grid_x][grid_y][grid_z]
	
	func update_consciousness_influences(consciousness_sources: Array):
		# Clear grid
		for x in range(field_resolution):
			for y in range(field_resolution):
				for z in range(field_resolution):
					consciousness_influence_grid[x][y][z]["consciousness_density"] = 0.0
		
		# Add consciousness influences
		for source in consciousness_sources:
			if source.has("position") and source.has("consciousness_level"):
				_add_consciousness_influence(source["position"], source["consciousness_level"], source.get("radius", 5.0))
	
	func _add_consciousness_influence(center: Vector3, strength: float, radius: float):
		var relative_center = (center - field_bounds.position) / field_bounds.size
		relative_center = relative_center.clamp(Vector3.ZERO, Vector3.ONE)
		
		var grid_center_x = int(relative_center.x * (field_resolution - 1))
		var grid_center_y = int(relative_center.y * (field_resolution - 1))
		var grid_center_z = int(relative_center.z * (field_resolution - 1))
		
		var grid_radius = int((radius / field_bounds.size.length()) * field_resolution)
		
		for x in range(max(0, grid_center_x - grid_radius), min(field_resolution, grid_center_x + grid_radius + 1)):
			for y in range(max(0, grid_center_y - grid_radius), min(field_resolution, grid_center_y + grid_radius + 1)):
				for z in range(max(0, grid_center_z - grid_radius), min(field_resolution, grid_center_z + grid_radius + 1)):
					var distance = Vector3(x - grid_center_x, y - grid_center_y, z - grid_center_z).length()
					if distance <= grid_radius:
						var influence = strength * (1.0 - distance / grid_radius)
						consciousness_influence_grid[x][y][z]["consciousness_density"] = max(consciousness_influence_grid[x][y][z]["consciousness_density"], influence)

class MovementTrail:
	var trail_points: Array[Vector3] = []
	var trail_node: Node3D
	var consciousness_colors: bool = true
	var max_trail_length: int = 50
	var trail_lifetime: float = 5.0
	var creation_time: float
	
	func _init(start_position: Vector3):
		trail_points.append(start_position)
		creation_time = Time.get_ticks_msec() / 1000.0
		_create_trail_visual()
	
	func add_point(position: Vector3):
		trail_points.append(position)
		if trail_points.size() > max_trail_length:
			trail_points.pop_front()
		_update_trail_visual()
	
	func _create_trail_visual():
		trail_node = Node3D.new()
		trail_node.name = "MovementTrail"
	
	func _update_trail_visual():
		# Update trail visualization
		pass
	
	func is_expired() -> bool:
		return (Time.get_ticks_msec() / 1000.0 - creation_time) > trail_lifetime

class TeleportationEffect:
	var source_position: Vector3
	var target_position: Vector3
	var effect_nodes: Array[Node3D] = []
	var consciousness_level: float
	var effect_duration: float = 2.0
	var creation_time: float
	
	func _init(from: Vector3, to: Vector3, consciousness: float = 1.0):
		source_position = from
		target_position = to
		consciousness_level = consciousness
		creation_time = Time.get_ticks_msec() / 1000.0
		_create_teleportation_effects()
	
	func _create_teleportation_effects():
		# Create visual effects for teleportation
		_create_portal_effect(source_position, "departure")
		_create_portal_effect(target_position, "arrival")
		_create_consciousness_bridge()
	
	func _create_portal_effect(position: Vector3, portal_type: String):
		var portal = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 0.5
		torus.outer_radius = 1.0
		portal.mesh = torus
		
		var material = StandardMaterial3D.new()
		material.flags_transparent = true
		material.emission_enabled = true
		
		match portal_type:
			"departure":
				material.emission_color = Color.RED
				material.albedo_color = Color(1.0, 0.3, 0.3, 0.6)
			"arrival":
				material.emission_color = Color.BLUE
				material.albedo_color = Color(0.3, 0.3, 1.0, 0.6)
		
		portal.material_override = material
		portal.position = position
		effect_nodes.append(portal)
	
	func _create_consciousness_bridge():
		# Create consciousness energy bridge between portals
		var bridge_points = []
		var steps = 20
		for i in range(steps + 1):
			var t = float(i) / float(steps)
			var pos = source_position.lerp(target_position, t)
			# Add consciousness-influenced curve
			pos.y += sin(t * PI) * consciousness_level * 2.0
			bridge_points.append(pos)
		
		# Create visual representation of bridge
		for i in range(bridge_points.size() - 1):
			var segment = MeshInstance3D.new()
			var cylinder = CylinderMesh.new()
			cylinder.top_radius = 0.1
			cylinder.bottom_radius = 0.1
			cylinder.height = bridge_points[i].distance_to(bridge_points[i + 1])
			segment.mesh = cylinder
			
			var material = StandardMaterial3D.new()
			material.flags_transparent = true
			material.emission_enabled = true
			material.emission_color = Color(0.5, 1.0, 0.5) * consciousness_level
			material.albedo_color = Color(0.5, 1.0, 0.5, 0.4)
			segment.material_override = material
			
			segment.position = (bridge_points[i] + bridge_points[i + 1]) * 0.5
			segment.look_at(bridge_points[i + 1], Vector3.UP)
			effect_nodes.append(segment)
	
	func is_expired() -> bool:
		return (Time.get_ticks_msec() / 1000.0 - creation_time) > effect_duration

class PositionMarker:
	var marker_node: Node3D
	var target_position: Vector3
	var marker_type: String
	var consciousness_level: float
	
	func _init(position: Vector3, type: String = "target", consciousness: float = 1.0):
		target_position = position
		marker_type = type
		consciousness_level = consciousness
		_create_marker()
	
	func _create_marker():
		marker_node = Node3D.new()
		marker_node.position = target_position
		
		var mesh_instance = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.3
		mesh_instance.mesh = sphere
		
		var material = StandardMaterial3D.new()
		material.flags_transparent = true
		material.emission_enabled = true
		
		match marker_type:
			"target":
				material.emission_color = Color.GREEN
				material.albedo_color = Color(0.3, 1.0, 0.3, 0.7)
			"waypoint":
				material.emission_color = Color.YELLOW
				material.albedo_color = Color(1.0, 1.0, 0.3, 0.7)
			"consciousness":
				material.emission_color = Color.CYAN * consciousness_level
				material.albedo_color = Color(0.3, 1.0, 1.0, 0.7)
		
		mesh_instance.material_override = material
		marker_node.add_child(mesh_instance)

func _ready():
	name = "PositionMoverSystem"
	print("🎯 POSITION MOVER SYSTEM INITIALIZED - Spatial consciousness manipulation active")
	
	# Initialize consciousness field
	var world_bounds = AABB(Vector3(-100, -50, -100), Vector3(200, 100, 200))
	consciousness_field = ConsciousnessPositionField.new(world_bounds)
	
	print("✨ Position mover ready - consciousness-guided movement enabled")

func _process(delta: float):
	_update_active_movements(delta)
	_process_movement_queue()
	_update_consciousness_field()
	_cleanup_expired_effects()

# ===== MAIN MOVEMENT FUNCTIONS =====

func move_object_to_position(object: Node3D, target_position: Vector3, movement_type: MovementType = MovementType.SMOOTH_INTERPOLATION, movement_speed: float = -1.0) -> bool:
	"""Move object to target position with specified movement type"""
	if not enabled or not is_instance_valid(object):
		return false
	
	# Check position locks
	if position_locks.has(object):
		print("🔒 Object %s position is locked: %s" % [object.name, position_locks[object]])
		position_locked.emit(object, position_locks[object])
		return false
	
	# Check movement distance limits
	var distance = object.global_position.distance_to(target_position)
	if distance > max_movement_distance:
		print("⚠️ Movement distance %.2f exceeds maximum %.2f" % [distance, max_movement_distance])
		return false
	
	var speed = movement_speed if movement_speed > 0 else default_movement_speed
	var consciousness_level = _get_object_consciousness_level(object)
	
	# Apply consciousness speed multiplier
	if consciousness_influence_enabled:
		speed *= (1.0 + consciousness_level * consciousness_speed_multiplier * 0.1)
	
	# Create movement command
	var command = MovementCommand.new(object, target_position, movement_type)
	command.movement_speed = speed
	command.consciousness_level = consciousness_level
	command.duration = distance / speed
	
	# Special handling for quantum teleportation
	if movement_type == MovementType.QUANTUM_TELEPORTATION:
		return _execute_quantum_teleportation(object, target_position, consciousness_level)
	
	# Add to active movements
	var movement_id = str(object.get_instance_id())
	active_movements[movement_id] = command
	
	# Create visual feedback
	if visual_feedback_enabled:
		_create_movement_trail(object)
		_create_position_marker(target_position, "target", consciousness_level)
	
	print("🎯 Moving %s to %s using %s" % [object.name, target_position, MovementType.keys()[movement_type]])
	return true

func move_object_smoothly(object: Node3D, target_position: Vector3, duration: float = 2.0) -> bool:
	"""Move object smoothly over specified duration"""
	if not move_object_to_position(object, target_position, MovementType.SMOOTH_INTERPOLATION):
		return false
	
	var movement_id = str(object.get_instance_id())
	if active_movements.has(movement_id):
		active_movements[movement_id].duration = duration
		active_movements[movement_id].movement_speed = object.global_position.distance_to(target_position) / duration
	
	return true

func teleport_object(object: Node3D, target_position: Vector3) -> bool:
	"""Instantly teleport object to target position"""
	return move_object_to_position(object, target_position, MovementType.QUANTUM_TELEPORTATION)

func move_object_with_consciousness_flow(object: Node3D, target_position: Vector3) -> bool:
	"""Move object following consciousness field flow"""
	return move_object_to_position(object, target_position, MovementType.CONSCIOUSNESS_FLOW)

func orbit_object_around_point(object: Node3D, center: Vector3, radius: float, angular_speed: float = 1.0) -> bool:
	"""Make object orbit around a center point"""
	var command = MovementCommand.new(object, center, MovementType.ORBITAL_MOVEMENT)
	command.movement_data["center"] = center
	command.movement_data["radius"] = radius
	command.movement_data["angular_speed"] = angular_speed
	command.movement_data["current_angle"] = 0.0
	command.duration = -1  # Infinite duration
	
	var movement_id = str(object.get_instance_id())
	active_movements[movement_id] = command
	
	print("🌀 %s orbiting around %s with radius %.2f" % [object.name, center, radius])
	return true

func pull_object_with_gravity(object: Node3D, gravity_source: Vector3, gravity_strength: float = 1.0) -> bool:
	"""Pull object toward gravity source"""
	var command = MovementCommand.new(object, gravity_source, MovementType.GRAVITATIONAL_PULL)
	command.movement_data["gravity_strength"] = gravity_strength
	command.movement_data["gravity_source"] = gravity_source
	command.duration = -1  # Continuous
	
	var movement_id = str(object.get_instance_id())
	active_movements[movement_id] = command
	
	print("🌌 %s under gravitational influence from %s" % [object.name, gravity_source])
	return true

# ===== CONSCIOUSNESS-GUIDED MOVEMENT =====

func move_with_consciousness_guidance(object: Node3D, target_position: Vector3, consciousness_sensitivity: float = 1.0) -> bool:
	"""Move object with consciousness field guidance"""
	var command = MovementCommand.new(object, target_position, MovementType.CONSCIOUSNESS_GUIDED)
	command.movement_data["consciousness_sensitivity"] = consciousness_sensitivity
	
	var movement_id = str(object.get_instance_id())
	active_movements[movement_id] = command
	
	print("🧠 %s moving with consciousness guidance (sensitivity: %.2f)" % [object.name, consciousness_sensitivity])
	return true

func _execute_quantum_teleportation(object: Node3D, target_position: Vector3, consciousness_level: float) -> bool:
	"""Execute quantum teleportation with consciousness energy cost"""
	if not quantum_teleportation_enabled:
		return false
	
	# Check consciousness energy requirements
	var energy_required = teleportation_energy_cost * object.global_position.distance_to(target_position) * 0.1
	if consciousness_level < energy_required:
		print("⚠️ Insufficient consciousness energy for teleportation (required: %.2f, available: %.2f)" % [energy_required, consciousness_level])
		return false
	
	var old_position = object.global_position
	
	# Create teleportation effect
	if visual_feedback_enabled:
		var teleport_effect = TeleportationEffect.new(old_position, target_position, consciousness_level)
		teleportation_effects.append(teleport_effect)
		
		# Add effects to scene
		var scene = get_tree().current_scene
		if scene:
			for effect_node in teleport_effect.effect_nodes:
				scene.add_child(effect_node)
	
	# Instant teleportation
	object.global_position = target_position
	
	# Reduce consciousness energy if object supports it
	if object.has_method("consume_consciousness_energy"):
		object.consume_consciousness_energy(energy_required)
	
	teleportation_event.emit(object, old_position, target_position)
	print("⚡ %s teleported from %s to %s (energy cost: %.2f)" % [object.name, old_position, target_position, energy_required])
	return true

# ===== MOVEMENT PROCESSING =====

func _update_active_movements(delta: float):
	"""Update all active movements"""
	var completed_movements = []
	
	for movement_id in active_movements:
		var command = active_movements[movement_id]
		if not is_instance_valid(command.object):
			completed_movements.append(movement_id)
			continue
		
		var current_time = Time.get_ticks_msec() / 1000.0
		var progress = (current_time - command.start_time) / command.duration if command.duration > 0 else 0.0
		
		match command.movement_type:
			MovementType.SMOOTH_INTERPOLATION:
				_update_smooth_movement(command, progress, delta)
			
			MovementType.CONSCIOUSNESS_FLOW:
				_update_consciousness_flow_movement(command, delta)
			
			MovementType.ORBITAL_MOVEMENT:
				_update_orbital_movement(command, delta)
			
			MovementType.GRAVITATIONAL_PULL:
				_update_gravitational_movement(command, delta)
			
			MovementType.CONSCIOUSNESS_GUIDED:
				_update_consciousness_guided_movement(command, delta)
			
			MovementType.DIRECT_TRANSLATION:
				_update_direct_movement(command, progress)
		
		# Check if movement is completed
		if command.duration > 0 and progress >= 1.0:
			completed_movements.append(movement_id)
		elif command.movement_type == MovementType.SMOOTH_INTERPOLATION and command.object.global_position.distance_to(command.target_position) < 0.1:
			completed_movements.append(movement_id)
	
	# Clean up completed movements
	for movement_id in completed_movements:
		_complete_movement(movement_id)

func _update_smooth_movement(command: MovementCommand, progress: float, delta: float):
	"""Update smooth interpolated movement"""
	var object = command.object
	var start_pos = object.global_position
	var target_pos = command.target_position
	
	# Apply consciousness influence to movement curve
	var consciousness_factor = 1.0 + command.consciousness_level * 0.1
	var movement_curve = _calculate_consciousness_curve(progress, consciousness_factor)
	
	var new_position = start_pos.move_toward(target_pos, command.movement_speed * delta * movement_curve)
	object.global_position = new_position
	
	# Update movement trail
	_update_movement_trail(object)

func _update_consciousness_flow_movement(command: MovementCommand, delta: float):
	"""Update movement following consciousness field flow"""
	var object = command.object
	var current_pos = object.global_position
	
	# Sample consciousness field
	var consciousness_data = consciousness_field.sample_consciousness_at_position(current_pos)
	var flow_direction = consciousness_data.get("flow_direction", Vector3.ZERO)
	var resistance = consciousness_data.get("movement_resistance", 1.0)
	
	# Apply flow-based movement
	var movement_vector = (command.target_position - current_pos).normalized()
	movement_vector += flow_direction * 0.5  # Consciousness flow influence
	movement_vector = movement_vector.normalized()
	
	var movement_speed = command.movement_speed / resistance
	object.global_position += movement_vector * movement_speed * delta

func _update_orbital_movement(command: MovementCommand, delta: float):
	"""Update orbital movement around center point"""
	var object = command.object
	var center = command.movement_data["center"]
	var radius = command.movement_data["radius"]
	var angular_speed = command.movement_data["angular_speed"]
	var current_angle = command.movement_data.get("current_angle", 0.0)
	
	# Update angle
	current_angle += angular_speed * delta
	command.movement_data["current_angle"] = current_angle
	
	# Calculate new position
	var new_position = center + Vector3(cos(current_angle) * radius, 0, sin(current_angle) * radius)
	object.global_position = new_position

func _update_gravitational_movement(command: MovementCommand, delta: float):
	"""Update gravitational pull movement"""
	var object = command.object
	var gravity_source = command.movement_data["gravity_source"]
	var gravity_strength = command.movement_data["gravity_strength"]
	
	var direction = (gravity_source - object.global_position).normalized()
	var distance = object.global_position.distance_to(gravity_source)
	
	# Apply inverse square law for gravity
	var force = gravity_strength / max(distance * distance, 1.0)
	object.global_position += direction * force * delta

func _update_consciousness_guided_movement(command: MovementCommand, delta: float):
	"""Update consciousness-guided movement"""
	var object = command.object
	var consciousness_sensitivity = command.movement_data["consciousness_sensitivity"]
	
	# Sample consciousness field at current position
	var consciousness_data = consciousness_field.sample_consciousness_at_position(object.global_position)
	var consciousness_density = consciousness_data.get("consciousness_density", 0.0)
	
	# Consciousness influences movement speed and direction
	var base_direction = (command.target_position - object.global_position).normalized()
	var consciousness_modifier = 1.0 + consciousness_density * consciousness_sensitivity
	
	object.global_position += base_direction * command.movement_speed * consciousness_modifier * delta
	
	consciousness_influenced_movement.emit(object, consciousness_modifier)

func _update_direct_movement(command: MovementCommand, progress: float):
	"""Update direct linear movement"""
	var object = command.object
	var start_pos = command.movement_data.get("start_position", object.global_position)
	
	if not command.movement_data.has("start_position"):
		command.movement_data["start_position"] = object.global_position
		start_pos = object.global_position
	
	var clamped_progress = clamp(progress, 0.0, 1.0)
	object.global_position = start_pos.lerp(command.target_position, clamped_progress)

func _complete_movement(movement_id: String):
	"""Complete and cleanup movement"""
	if not active_movements.has(movement_id):
		return
	
	var command = active_movements[movement_id]
	
	# Ensure object reaches exact target position for finite movements
	if command.duration > 0 and is_instance_valid(command.object):
		command.object.global_position = command.target_position
	
	var movement_data = {
		"object": command.object,
		"start_position": command.movement_data.get("start_position", Vector3.ZERO),
		"target_position": command.target_position,
		"movement_type": MovementType.keys()[command.movement_type],
		"duration": command.duration,
		"consciousness_level": command.consciousness_level
	}
	
	movement_completed.emit(movement_data)
	
	if command.completion_callback.is_valid():
		command.completion_callback.call()
	
	active_movements.erase(movement_id)
	print("✅ Movement completed for %s" % (command.object.name if is_instance_valid(command.object) else "unknown"))

# ===== HELPER FUNCTIONS =====

func _calculate_consciousness_curve(progress: float, consciousness_factor: float) -> float:
	"""Calculate consciousness-influenced movement curve"""
	var base_curve = smoothstep(0.0, 1.0, progress)
	var consciousness_curve = 1.0 + sin(progress * PI) * (consciousness_factor - 1.0) * 0.1
	return base_curve * consciousness_curve

func _get_object_consciousness_level(object: Node3D) -> float:
	"""Get consciousness level of object"""
	if object.has_method("get_consciousness_level"):
		return object.get_consciousness_level()
	return 1.0

func _process_movement_queue():
	"""Process queued movements"""
	# Implementation for movement queue processing
	pass

func _update_consciousness_field():
	"""Update consciousness field with current Universal Beings"""
	var consciousness_sources = []
	var scene = get_tree().current_scene
	
	if scene:
		_gather_consciousness_sources(scene, consciousness_sources)
	
	consciousness_field.update_consciousness_influences(consciousness_sources)

func _gather_consciousness_sources(node: Node, sources: Array):
	"""Recursively gather consciousness sources from scene"""
	if node.has_method("get_consciousness_level"):
		sources.append({
			"position": node.global_position if node is Node3D else Vector3.ZERO,
			"consciousness_level": node.get_consciousness_level(),
			"radius": 5.0
		})
	
	for child in node.get_children():
		_gather_consciousness_sources(child, sources)

func _create_movement_trail(object: Node3D):
	"""Create movement trail for object"""
	if not visual_feedback_enabled:
		return
	
	var trail = MovementTrail.new(object.global_position)
	movement_trails.append(trail)
	
	var scene = get_tree().current_scene
	if scene:
		scene.add_child(trail.trail_node)

func _update_movement_trail(object: Node3D):
	"""Update movement trail for object"""
	for trail in movement_trails:
		if trail.trail_points.size() > 0 and trail.trail_points[-1].distance_to(object.global_position) > 0.5:
			trail.add_point(object.global_position)

func _create_position_marker(position: Vector3, marker_type: String, consciousness_level: float = 1.0):
	"""Create position marker"""
	if not visual_feedback_enabled:
		return
	
	var marker = PositionMarker.new(position, marker_type, consciousness_level)
	position_markers.append(marker)
	
	var scene = get_tree().current_scene
	if scene:
		scene.add_child(marker.marker_node)

func _cleanup_expired_effects():
	"""Cleanup expired visual effects"""
	# Cleanup expired trails
	var expired_trails = []
	for i in range(movement_trails.size()):
		if movement_trails[i].is_expired():
			expired_trails.append(i)
			movement_trails[i].trail_node.queue_free()
	
	for i in range(expired_trails.size() - 1, -1, -1):
		movement_trails.remove_at(expired_trails[i])
	
	# Cleanup expired teleportation effects
	var expired_effects = []
	for i in range(teleportation_effects.size()):
		if teleportation_effects[i].is_expired():
			expired_effects.append(i)
			for effect_node in teleportation_effects[i].effect_nodes:
				effect_node.queue_free()
	
	for i in range(expired_effects.size() - 1, -1, -1):
		teleportation_effects.remove_at(expired_effects[i])

# ===== POSITION LOCKS AND CONSTRAINTS =====

func lock_object_position(object: Node3D, lock_reason: String = "Manual lock"):
	"""Lock object position to prevent movement"""
	position_locks[object] = lock_reason
	print("🔒 Locked position for %s: %s" % [object.name, lock_reason])

func unlock_object_position(object: Node3D):
	"""Unlock object position"""
	if position_locks.has(object):
		position_locks.erase(object)
		print("🔓 Unlocked position for %s" % object.name)

func stop_object_movement(object: Node3D):
	"""Stop all movement for specific object"""
	var movement_id = str(object.get_instance_id())
	if active_movements.has(movement_id):
		_complete_movement(movement_id)

# ===== PUBLIC API =====

func get_active_movements() -> Dictionary:
	"""Get all active movements"""
	return active_movements

func is_object_moving(object: Node3D) -> bool:
	"""Check if object is currently moving"""
	var movement_id = str(object.get_instance_id())
	return active_movements.has(movement_id)

func get_object_movement_progress(object: Node3D) -> float:
	"""Get movement progress for object (0.0 to 1.0)"""
	var movement_id = str(object.get_instance_id())
	if not active_movements.has(movement_id):
		return 0.0
	
	var command = active_movements[movement_id]
	if command.duration <= 0:
		return 0.0  # Infinite movement
	
	var current_time = Time.get_ticks_msec() / 1000.0
	return clamp((current_time - command.start_time) / command.duration, 0.0, 1.0)

func set_consciousness_influence(enabled: bool):
	"""Enable/disable consciousness influence on movement"""
	consciousness_influence_enabled = enabled

# 🎯 POSITION MOVER SYSTEM COMPLETE! 🎯
# Spatial consciousness manipulation ready
# Reality can now be moved with the power of consciousness!
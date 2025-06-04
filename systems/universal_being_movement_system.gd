extends Node3D
class_name UniversalBeingMovementSystem

# ==================================================
# SCRIPT NAME: universal_being_movement_system.gd
# DESCRIPTION: Chunk-based pathfinding and movement for Universal Beings
# PURPOSE: Enable beings to travel between chunk centers with intelligent paths
# CREATED: 2025-06-04 - The Journey Begins
# ==================================================

signal being_entered_chunk(being: UniversalBeing, chunk: ChunkUniversalBeing)
signal path_calculated(being: UniversalBeing, path: Array)
signal being_reached_destination(being: UniversalBeing)

# Movement configuration
const CHUNK_SIZE := Vector3(16.0, 16.0, 16.0)  # Size of each chunk
const MOVEMENT_SPEED := 5.0  # Units per second
const PATH_UPDATE_DISTANCE := 2.0  # Recalc path if target moves this far

# Active movements
var moving_beings: Dictionary = {}  # being_id: MovementData
var chunk_grid: Dictionary = {}  # Vector3i: ChunkUniversalBeing

# Path visualization (debug)
var debug_paths: bool = false
var path_lines: Dictionary = {}  # being_id: ImmediateMesh

class MovementData:
	var being: UniversalBeing
	var current_chunk: ChunkUniversalBeing
	var target_position: Vector3
	var path: Array = []  # Array of Vector3 positions (chunk centers)
	var path_index: int = 0
	var speed: float = MOVEMENT_SPEED
	var lod_level: int = 0  # Current LOD for pathfinding detail

func _ready() -> void:
	add_to_group("movement_systems")
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Update all moving beings
	for being_id in moving_beings:
		var data = moving_beings[being_id]
		if data and is_instance_valid(data.being):
			_update_being_movement(data, delta)
		else:
			# Clean up invalid beings
			moving_beings.erase(being_id)
func register_chunk(chunk: ChunkUniversalBeing) -> void:
	"""Register a chunk in the movement grid"""
	var chunk_pos = world_to_chunk_coord(chunk.global_position)
	chunk_grid[chunk_pos] = chunk
	print("🗺️ Registered chunk at %s" % chunk_pos)

func unregister_chunk(chunk: ChunkUniversalBeing) -> void:
	"""Remove a chunk from the movement grid"""
	var chunk_pos = world_to_chunk_coord(chunk.global_position)
	chunk_grid.erase(chunk_pos)

func move_being_to(being: UniversalBeing, target_pos: Vector3) -> void:
	"""Start moving a being to a target position"""
	var being_id = being.get_instance_id()
	
	# Create or update movement data
	var data = moving_beings.get(being_id, MovementData.new())
	data.being = being
	data.target_position = target_pos
	data.current_chunk = get_chunk_at_position(being.global_position)
	
	# Calculate path through chunks
	data.path = calculate_chunk_path(being.global_position, target_pos)
	data.path_index = 0
	
	# Determine LOD based on distance and player visibility
	data.lod_level = calculate_lod_level(being)
	
	moving_beings[being_id] = data
	path_calculated.emit(being, data.path)
	
	# Create debug visualization
	if debug_paths:
		_create_path_visualization(being_id, data.path)

func stop_being(being: UniversalBeing) -> void:
	"""Stop a being's movement"""
	var being_id = being.get_instance_id()
	moving_beings.erase(being_id)
	
	# Clean up visualization
	if being_id in path_lines:
		path_lines[being_id].queue_free()
		path_lines.erase(being_id)

func world_to_chunk_coord(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinates"""
	return Vector3i(
		floori(world_pos.x / CHUNK_SIZE.x),
		floori(world_pos.y / CHUNK_SIZE.y),
		floori(world_pos.z / CHUNK_SIZE.z)
	)
func chunk_coord_to_world(chunk_coord: Vector3i) -> Vector3:
	"""Convert chunk coordinates to world center position"""
	return Vector3(
		chunk_coord.x * CHUNK_SIZE.x + CHUNK_SIZE.x * 0.5,
		chunk_coord.y * CHUNK_SIZE.y + CHUNK_SIZE.y * 0.5,
		chunk_coord.z * CHUNK_SIZE.z + CHUNK_SIZE.z * 0.5
	)

func get_chunk_at_position(world_pos: Vector3) -> ChunkUniversalBeing:
	"""Get the chunk at a world position"""
	var chunk_coord = world_to_chunk_coord(world_pos)
	return chunk_grid.get(chunk_coord)

func calculate_chunk_path(start_pos: Vector3, end_pos: Vector3) -> Array:
	"""Calculate path through chunk centers using A* pathfinding"""
	var start_chunk = world_to_chunk_coord(start_pos)
	var end_chunk = world_to_chunk_coord(end_pos)
	
	# Simple direct path for now (can be enhanced with A*)
	var path = []
	var current = start_chunk
	
	# Add starting position
	path.append(start_pos)
	
	# Move through chunks towards target
	while current != end_chunk:
		# Find next chunk towards target
		var diff = end_chunk - current
		var next_chunk = current
		
		# Move one chunk at a time in dominant direction
		if abs(diff.x) >= abs(diff.y) and abs(diff.x) >= abs(diff.z):
			next_chunk.x += sign(diff.x)
		elif abs(diff.y) >= abs(diff.z):
			next_chunk.y += sign(diff.y)
		else:
			next_chunk.z += sign(diff.z)
		
		# Add chunk center to path
		path.append(chunk_coord_to_world(next_chunk))
		current = next_chunk
	
	# Add final position
	path.append(end_pos)
	
	return path
func calculate_lod_level(being: UniversalBeing) -> int:
	"""Calculate LOD level based on player visibility and distance"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return 2  # Medium LOD if no camera
	
	var distance = camera.global_position.distance_to(being.global_position)
	
	# LOD levels based on distance
	if distance < 10.0:
		return 0  # Highest detail
	elif distance < 30.0:
		return 1  # High detail
	elif distance < 60.0:
		return 2  # Medium detail
	elif distance < 100.0:
		return 3  # Low detail
	else:
		return 4  # Lowest detail

func _update_being_movement(data: MovementData, delta: float) -> void:
	"""Update a being's position along its path"""
	if data.path.is_empty() or data.path_index >= data.path.size():
		# Reached destination
		moving_beings.erase(data.being.get_instance_id())
		being_reached_destination.emit(data.being)
		return
	
	var current_target = data.path[data.path_index]
	var direction = (current_target - data.being.global_position).normalized()
	var distance = data.being.global_position.distance_to(current_target)
	
	# Apply LOD-based movement precision
	var move_speed = data.speed
	if data.lod_level > 2:
		# Lower precision for distant beings
		move_speed *= 2.0
	
	# Move towards target
	if distance < move_speed * delta:
		# Reached waypoint
		data.being.global_position = current_target
		data.path_index += 1
		
		# Check if entered new chunk
		var new_chunk = get_chunk_at_position(data.being.global_position)
		if new_chunk != data.current_chunk:
			data.current_chunk = new_chunk
			being_entered_chunk.emit(data.being, new_chunk)
	else:
		# Continue moving
		data.being.global_position += direction * move_speed * delta
		
		# Update being's forward direction
		if data.being.has_method("set_forward_direction"):
			data.being.set_forward_direction(direction)
func _create_path_visualization(being_id: int, path: Array) -> void:
	"""Create debug visualization for path"""
	# Clean up old visualization
	if being_id in path_lines:
		path_lines[being_id].queue_free()
	
	# Create new mesh for path
	var mesh = ImmediateMesh.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Create material
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.albedo_color = Color.GREEN
	material.emission_enabled = true
	material.emission = Color.GREEN * 0.5
	mesh_instance.material_override = material
	
	add_child(mesh_instance)
	path_lines[being_id] = mesh_instance
	
	# Draw path
	if path.size() > 1:
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for point in path:
			mesh.surface_add_vertex(point)
		mesh.surface_end()

func get_nearby_chunks(chunk_coord: Vector3i, radius: int = 1) -> Array:
	"""Get all chunks within radius of given chunk"""
	var chunks = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var coord = chunk_coord + Vector3i(x, y, z)
				if coord in chunk_grid:
					chunks.append(chunk_grid[coord])
	return chunks

func get_beings_in_chunk(chunk: ChunkUniversalBeing) -> Array:
	"""Get all beings currently in a chunk"""
	var beings = []
	for data in moving_beings.values():
		if data.current_chunk == chunk:
			beings.append(data.being)
	return beings
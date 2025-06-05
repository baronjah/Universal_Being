# LightweightChunkSystem - TRUE LOD based on view direction
# Only loads chunks when you're looking at them - no "dead corners"

extends Node3D
class_name LightweightChunkSystem

@export var chunk_size: float = 10.0
@export var view_distance: float = 50.0
@export var chunk_resolution: int = 5  # Less detailed chunks

# Lightweight chunk storage
var visible_chunks: Dictionary = {}  # Vector3i -> MeshInstance3D
var camera: Camera3D = null
var player: Node3D = null

# Performance - only process a few chunks per frame
var chunks_to_check: Array[Vector3i] = []
var check_index: int = 0

func _ready():
	# Find player and camera
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		# Find camera in player
		camera = find_camera_in_node(player)
	
	print("📦 Lightweight Chunk System ready - TRUE LOD enabled")

func find_camera_in_node(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var cam = find_camera_in_node(child)
		if cam:
			return cam
	return null

func _process(delta):
	if not camera or not player:
		return
	
	# Only check a few potential chunks per frame
	check_chunks_in_view()
	
	# Remove chunks not in view
	cleanup_invisible_chunks()

func check_chunks_in_view():
	"""Check chunks in infinite 3x3x3 grid around player + view direction"""
	if not camera:
		return
	
	var camera_pos = camera.global_position
	var camera_forward = -camera.global_transform.basis.z
	var player_chunk = world_to_chunk_coord(camera_pos)
	
	# Always keep 3x3x3 around player (like you specified)
	for x in range(-1, 2):  # 3x3x3 around player
		for y in range(-1, 2):
			for z in range(-1, 2):
				var chunk_coord = Vector3i(player_chunk.x + x, player_chunk.y + y, player_chunk.z + z)
				ensure_chunk_loaded(chunk_coord)
	
	# Additionally load chunks in view direction for infinite layers
	var layers_to_check = int(view_distance / chunk_size)
	for layer in range(1, layers_to_check + 1):
		# Cast rays in view direction to find which chunks to load
		for angle_x in range(-2, 3):  # Small cone
			for angle_y in range(-2, 3):
				var offset = Vector3(angle_x * 0.1, angle_y * 0.1, 0)
				var ray_direction = (camera_forward + offset).normalized()
				var ray_end = camera_pos + ray_direction * (layer * chunk_size)
				var chunk_coord = world_to_chunk_coord(ray_end)
				
				# Only load if in reasonable range
				var distance = camera_pos.distance_to(chunk_to_world_pos(chunk_coord))
				if distance < view_distance:
					ensure_chunk_loaded(chunk_coord)

func ensure_chunk_loaded(coord: Vector3i):
	"""Load a chunk if not already loaded"""
	if coord in visible_chunks:
		return  # Already loaded
	
	# Create simple visual chunk (not full Universal Being)
	var chunk_mesh = create_simple_chunk(coord)
	visible_chunks[coord] = chunk_mesh
	add_child(chunk_mesh)
	
	print("📦 Loaded chunk [%d,%d,%d]" % [coord.x, coord.y, coord.z])

func create_simple_chunk(coord: Vector3i) -> MeshInstance3D:
	"""Create a simple, lightweight chunk representation"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Chunk_%d_%d_%d" % [coord.x, coord.y, coord.z]
	
	# Create simple plane mesh
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_resolution
	plane_mesh.subdivide_width = chunk_resolution
	mesh_instance.mesh = plane_mesh
	
	# Position the chunk
	var world_pos = chunk_to_world_pos(coord)
	mesh_instance.global_position = world_pos
	
	# Simple material based on chunk type with consciousness colors
	var material = StandardMaterial3D.new()
	if coord.y < 0:
		material.albedo_color = Color(0.4, 0.3, 0.2)  # Underground - brown
		material.emission = Color(0.1, 0.05, 0.0)    # Dormant glow
	elif coord.y == 0:
		material.albedo_color = Color(0.2, 0.6, 0.1)  # Surface - green  
		material.emission = Color(0.05, 0.2, 0.02)   # Awakening glow
	else:
		material.albedo_color = Color(0.1, 0.2, 0.8)  # Sky - blue
		material.emission = Color(0.02, 0.05, 0.2)   # Enlightened glow
	
	material.emission_energy = 0.3
	mesh_instance.material_override = material
	
	# Store chunk metadata for potential evolution to Universal Being
	mesh_instance.set_meta("chunk_coord", coord)
	mesh_instance.set_meta("creation_time", Time.get_ticks_msec())
	mesh_instance.set_meta("can_evolve", true)
	
	return mesh_instance

func cleanup_invisible_chunks():
	"""Remove chunks that are no longer visible"""
	if not camera:
		return
	
	var camera_pos = camera.global_position
	var player_chunk = world_to_chunk_coord(camera_pos)
	var chunks_to_remove = []
	
	for coord in visible_chunks.keys():
		var chunk_world_pos = chunk_to_world_pos(coord)
		var distance = camera_pos.distance_to(chunk_world_pos)
		
		# Keep 3x3x3 around player always
		var is_core_chunk = (
			abs(coord.x - player_chunk.x) <= 1 and
			abs(coord.y - player_chunk.y) <= 1 and
			abs(coord.z - player_chunk.z) <= 1
		)
		
		# Remove if too far and not in core 3x3x3
		if not is_core_chunk and distance > view_distance * 1.5:
			chunks_to_remove.append(coord)
	
	# Remove chunks (limit to prevent frame drops)
	var removed = 0
	for coord in chunks_to_remove:
		if removed >= 3:  # Remove up to 3 per frame
			break
		
		var chunk_mesh = visible_chunks[coord]
		if chunk_mesh and is_instance_valid(chunk_mesh):
			chunk_mesh.queue_free()
		
		visible_chunks.erase(coord)
		removed += 1
		print("📤 Unloaded chunk [%d,%d,%d]" % [coord.x, coord.y, coord.z])

func world_to_chunk_coord(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinate"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size)),
		int(floor(world_pos.y / chunk_size)),
		int(floor(world_pos.z / chunk_size))
	)

func chunk_to_world_pos(coord: Vector3i) -> Vector3:
	"""Convert chunk coordinate to world position"""
	return Vector3(
		coord.x * chunk_size,
		coord.y * chunk_size,
		coord.z * chunk_size
	)

func save_chunk_as_zip(coord: Vector3i) -> bool:
	"""Save a chunk as a .ub.zip file"""
	if coord not in visible_chunks:
		print("❌ Cannot save chunk [%d,%d,%d] - not loaded" % [coord.x, coord.y, coord.z])
		return false
	
	var chunk_mesh = visible_chunks[coord]
	var chunk_data = {
		"coordinates": coord,
		"creation_time": chunk_mesh.get_meta("creation_time", 0),
		"chunk_type": get_chunk_type(coord),
		"consciousness_level": get_chunk_consciousness_level(coord),
		"material_data": extract_material_data(chunk_mesh)
	}
	
	# Use SystemBootstrap to access AkashicRecords
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_universal_being_data"):
			var chunk_id = "chunk_%d_%d_%d" % [coord.x, coord.y, coord.z]
			var success = akashic.save_universal_being_data(chunk_id, chunk_data)
			if success:
				print("💾 Saved chunk [%d,%d,%d] as .ub.zip" % [coord.x, coord.y, coord.z])
				return true
	
	print("❌ Failed to save chunk [%d,%d,%d]" % [coord.x, coord.y, coord.z])
	return false

func get_chunk_type(coord: Vector3i) -> String:
	"""Get chunk type based on Y coordinate"""
	if coord.y < 0:
		return "underground"
	elif coord.y == 0:
		return "surface"
	else:
		return "sky"

func get_chunk_consciousness_level(coord: Vector3i) -> int:
	"""Get consciousness level based on chunk type"""
	if coord.y < 0:
		return 1  # Dormant
	elif coord.y == 0:
		return 2  # Awakening
	else:
		return 3  # Enlightened

func extract_material_data(mesh_instance: MeshInstance3D) -> Dictionary:
	"""Extract material data for saving"""
	var material = mesh_instance.material_override
	if material:
		return {
			"albedo_color": [material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, material.albedo_color.a],
			"emission_color": [material.emission.r, material.emission.g, material.emission.b, material.emission.a],
			"emission_energy": material.emission_energy
		}
	return {}

func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"visible_chunks": visible_chunks.size(),
		"camera_position": camera.global_position if camera else Vector3.ZERO,
		"player_chunk": world_to_chunk_coord(player.global_position) if player else Vector3i.ZERO,
		"chunk_coordinates": visible_chunks.keys()
	}
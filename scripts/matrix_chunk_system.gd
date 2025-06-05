# MatrixChunkSystem - FIXED VERSION - No more errors!
# Infinite streaming world like The Matrix

extends Node3D
class_name MatrixChunkSystem

@export var chunk_size: float = 10.0
@export var render_distance: float = 100.0
@export var generation_seed: int = 12345

# Matrix-style infinite streaming
var active_chunks: Dictionary = {}  # Vector3i -> MeshInstance3D
var camera: Camera3D = null
var player: Node3D = null
var last_player_chunk: Vector3i = Vector3i.ZERO

# Matrix generation rules
var matrix_generator: MatrixGenerator = null

class MatrixGenerator:
	var noise: FastNoiseLite
	var seed: int
	
	func _init(generation_seed: int):
		seed = generation_seed
		noise = FastNoiseLite.new()
		noise.seed = seed
		noise.frequency = 0.1
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	func generate_chunk_content(coord: Vector3i) -> Dictionary:
		"""Generate Matrix-style content for a chunk"""
		var world_pos = Vector3(coord.x * 10, coord.y * 10, coord.z * 10)
		var height_noise = noise.get_noise_3d(world_pos.x, world_pos.y, world_pos.z)
		
		# Matrix-style content generation
		var content_type = "void"
		var consciousness_level = 1
		var color = Color.BLACK
		
		if coord.y < -2:  # Deep matrix (underground)
			content_type = "matrix_core"
			consciousness_level = 5
			color = Color(0.0, 1.0, 0.0, 0.8)  # Matrix green
		elif coord.y < 0:  # Matrix layer
			content_type = "data_stream"
			consciousness_level = 3
			color = Color(0.0, 0.8, 0.0, 0.6)  # Flowing data
		elif coord.y == 0:  # Surface reality
			content_type = "construct"
			consciousness_level = 2
			if height_noise > 0.3:
				color = Color(0.8, 0.8, 0.8, 1.0)  # White construct
			else:
				color = Color(0.1, 0.1, 0.1, 1.0)  # Dark reality
		else:  # Sky matrix
			content_type = "code_rain"
			consciousness_level = 4
			color = Color(0.0, 0.6, 0.0, 0.3)  # Transparent code
		
		return {
			"type": content_type,
			"consciousness_level": consciousness_level,
			"color": color,
			"height_noise": height_noise,
			"coord": coord
		}

func _ready():
	# Initialize Matrix
	matrix_generator = MatrixGenerator.new(generation_seed)
	
	# Find player and camera - DEFER to next frame to ensure scene is ready
	call_deferred("_find_player_and_camera")
	
	print("🔴 MATRIX CHUNK SYSTEM ONLINE 🔴")
	print("🔴 INFINITE STREAMING ACTIVATED 🔴")

func _find_player_and_camera():
	"""Find player and camera after scene is ready"""
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		camera = find_camera_in_node(player)

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
	
	# Check if player is valid and in tree
	if not is_instance_valid(player) or not player.is_inside_tree():
		return
	
	var current_player_chunk = world_to_chunk_coord(player.global_position)
	
	# Only update chunks when player moves to new chunk
	if current_player_chunk != last_player_chunk:
		stream_matrix_around_player(current_player_chunk)
		last_player_chunk = current_player_chunk

func stream_matrix_around_player(player_chunk: Vector3i):
	"""Stream Matrix chunks infinitely around player"""
	var render_radius = int(render_distance / chunk_size)
	
	# Generate chunks in sphere around player
	for x in range(player_chunk.x - render_radius, player_chunk.x + render_radius + 1):
		for y in range(player_chunk.y - render_radius, player_chunk.y + render_radius + 1):
			for z in range(player_chunk.z - render_radius, player_chunk.z + render_radius + 1):
				var chunk_coord = Vector3i(x, y, z)
				var distance = chunk_coord.distance_to(player_chunk)
				
				if distance <= render_radius:
					if chunk_coord not in active_chunks:
						stream_in_chunk(chunk_coord)
	
	# Remove distant chunks
	cleanup_distant_chunks(player_chunk, render_radius)

func stream_in_chunk(coord: Vector3i):
	"""Stream in a Matrix chunk seamlessly"""
	var chunk_data = matrix_generator.generate_chunk_content(coord)
	var chunk_mesh = create_matrix_chunk(chunk_data)
	
	active_chunks[coord] = chunk_mesh
	add_child(chunk_mesh)
	
	# Matrix-style streaming message
	if chunk_data.consciousness_level >= 4:
		print("🟢 STREAMING: %s [%d,%d,%d] - Consciousness Level %d" % [
			chunk_data.type, coord.x, coord.y, coord.z, chunk_data.consciousness_level
		])

func create_matrix_chunk(data: Dictionary) -> MeshInstance3D:
	"""Create Matrix-style chunk visual"""
	var mesh_instance = MeshInstance3D.new()
	var coord = data.coord
	mesh_instance.name = "Matrix_%d_%d_%d" % [coord.x, coord.y, coord.z]
	
	# Create Matrix geometry based on type
	var mesh = null
	match data.type:
		"matrix_core":
			mesh = create_matrix_core_mesh()
		"data_stream":
			mesh = create_data_stream_mesh()
		"construct":
			mesh = create_construct_mesh(data.height_noise)
		"code_rain":
			mesh = create_code_rain_mesh()
		_:
			mesh = BoxMesh.new()
	
	mesh_instance.mesh = mesh
	
	# Position in Matrix space - USE LOCAL POSITION FIRST!
	var world_pos = chunk_to_world_pos(coord)
	mesh_instance.position = world_pos  # Use local position, not global
	
	# Matrix material with consciousness glow
	var material = StandardMaterial3D.new()
	material.albedo_color = data.color
	material.emission_enabled = true
	material.emission = data.color
	material.emission_energy = data.consciousness_level * 0.2
	
	if data.consciousness_level >= 4:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mesh_instance.material_override = material
	
	# Store Matrix metadata
	mesh_instance.set_meta("matrix_type", data.type)
	mesh_instance.set_meta("consciousness_level", data.consciousness_level)
	mesh_instance.set_meta("coord", coord)
	mesh_instance.set_meta("can_evolve", true)
	
	return mesh_instance

func create_matrix_core_mesh() -> Mesh:
	"""Core Matrix chunks - complex geometry"""
	var box = BoxMesh.new()
	box.size = Vector3(chunk_size, chunk_size, chunk_size)
	return box

func create_data_stream_mesh() -> Mesh:
	"""Flowing data streams"""
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = chunk_size * 0.3
	cylinder.bottom_radius = chunk_size * 0.3
	cylinder.height = chunk_size
	return cylinder

func create_construct_mesh(height_noise: float) -> Mesh:
	"""Matrix construct reality"""
	var plane = PlaneMesh.new()
	plane.size = Vector2(chunk_size, chunk_size)
	plane.subdivide_depth = 5
	plane.subdivide_width = 5
	return plane

func create_code_rain_mesh() -> Mesh:
	"""Falling code effect"""
	var sphere = SphereMesh.new()
	sphere.radius = chunk_size * 0.2
	sphere.height = chunk_size * 0.4
	return sphere

func cleanup_distant_chunks(player_chunk: Vector3i, render_radius: int):
	"""Remove chunks outside Matrix render distance"""
	var chunks_to_remove = []
	
	for coord in active_chunks.keys():
		var distance = coord.distance_to(player_chunk)
		if distance > render_radius + 2:  # Small buffer
			chunks_to_remove.append(coord)
	
	# Limit removals per frame to prevent lag
	var removed_count = 0
	for coord in chunks_to_remove:
		if removed_count >= 5:  # Only remove 5 per frame
			break
			
		var chunk_mesh = active_chunks[coord]
		if chunk_mesh and is_instance_valid(chunk_mesh):
			chunk_mesh.queue_free()
		active_chunks.erase(coord)
		removed_count += 1
		
		# Less spam in console
		if removed_count == 1:
			print("🔴 MATRIX UNLOAD: Removing %d distant chunks..." % chunks_to_remove.size())

func world_to_chunk_coord(world_pos: Vector3) -> Vector3i:
	"""Convert world position to Matrix chunk coordinate"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size)),
		int(floor(world_pos.y / chunk_size)),
		int(floor(world_pos.z / chunk_size))
	)

func chunk_to_world_pos(coord: Vector3i) -> Vector3:
	"""Convert chunk coordinate to Matrix world position"""
	return Vector3(
		coord.x * chunk_size,
		coord.y * chunk_size,
		coord.z * chunk_size
	)

func save_matrix_chunk(coord: Vector3i) -> bool:
	"""Save Matrix chunk as Universal Being ZIP"""
	if coord not in active_chunks:
		return false
	
	var chunk_mesh = active_chunks[coord]
	var matrix_data = {
		"matrix_type": chunk_mesh.get_meta("matrix_type", "unknown"),
		"consciousness_level": chunk_mesh.get_meta("consciousness_level", 1),
		"coordinates": coord,
		"generation_seed": generation_seed,
		"timestamp": Time.get_ticks_msec()
	}
	
	# Save to Akashic Records
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_universal_being_data"):
			var chunk_id = "matrix_%d_%d_%d" % [coord.x, coord.y, coord.z]
			return akashic.save_universal_being_data(chunk_id, matrix_data)
	
	return false

func get_matrix_stats() -> Dictionary:
	"""Get Matrix system statistics"""
	return {
		"active_chunks": active_chunks.size(),
		"player_chunk": world_to_chunk_coord(player.global_position) if player else Vector3i.ZERO,
		"render_distance": render_distance,
		"generation_seed": generation_seed
	}
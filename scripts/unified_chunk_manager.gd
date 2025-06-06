# UnifiedChunkManager - Manages chunks for BOTH player and AI companion
# Ensures chunks stay loaded where EITHER entity is present
# Properly unloads chunks when NEITHER entity is near

extends Node
class_name UnifiedChunkManager

# Entity tracking
var player: Node3D = null
var ai_companion: Node3D = null
var camera: Camera3D = null

# Chunk management
var loaded_chunks: Dictionary = {} # Vector3i -> ChunkData
var chunk_load_radius: float = 100.0
var chunk_unload_radius: float = 150.0
var chunk_size: float = 32.0

# Predictive loading
@export var predictive_distance: float = 50.0
@export var frustum_load_enabled: bool = true

# Performance
var chunks_loaded_this_frame: int = 0
var max_chunks_per_frame: int = 3

signal chunk_loaded(coord: Vector3i)
signal chunk_unloaded(coord: Vector3i)

class ChunkData:
	var coord: Vector3i
	var position: Vector3
	var mesh_instance: MeshInstance3D
	var last_accessed: float
	var distance_to_player: float = INF
	var distance_to_ai: float = INF

func _ready():
	add_to_group("chunk_managers")
	print("🎯 UNIFIED CHUNK MANAGER ACTIVE")
	
	# Find entities after scene ready
	call_deferred("_find_entities")

func _find_entities():
	"""Find player and AI companion in scene"""
	# Find player
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		camera = _find_camera_in_node(player)
		print("✅ Found player: ", player.name)
	
	# Find AI companion (Gemma)
	var ais = get_tree().get_nodes_in_group("ai_companions")
	if ais.size() > 0:
		ai_companion = ais[0]
		print("✅ Found AI companion: ", ai_companion.name)
	else:
		# Also check for GemmaUniversalBeing specifically
		var gemmas = get_tree().get_nodes_in_group("gemma_beings")
		if gemmas.size() > 0:
			ai_companion = gemmas[0]
			print("✅ Found Gemma AI: ", ai_companion.name)

func _find_camera_in_node(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var cam = _find_camera_in_node(child)
		if cam:
			return cam
	return null

func _process(_delta):
	if not player:
		return
	
	chunks_loaded_this_frame = 0
	update_chunk_loading()

func update_chunk_loading():
	"""Main chunk update loop - loads around BOTH entities"""
	var player_pos = player.global_position if player else Vector3.ZERO
	var ai_pos = ai_companion.global_position if ai_companion else Vector3.ZERO
	
	# Get all chunks that should be loaded
	var chunks_to_keep = {}
	
	# Load chunks around player
	if player:
		var player_chunks = get_chunks_in_radius(player_pos, chunk_load_radius)
		for chunk_coord in player_chunks:
			chunks_to_keep[chunk_coord] = true
			if not loaded_chunks.has(chunk_coord) and chunks_loaded_this_frame < max_chunks_per_frame:
				load_chunk(chunk_coord)
				chunks_loaded_this_frame += 1
	
	# Load chunks around AI companion
	if ai_companion:
		var ai_chunks = get_chunks_in_radius(ai_pos, chunk_load_radius)
		for chunk_coord in ai_chunks:
			chunks_to_keep[chunk_coord] = true
			if not loaded_chunks.has(chunk_coord) and chunks_loaded_this_frame < max_chunks_per_frame:
				load_chunk(chunk_coord)
				chunks_loaded_this_frame += 1
	
	# Predictive loading based on camera direction
	if camera and frustum_load_enabled and chunks_loaded_this_frame < max_chunks_per_frame:
		load_chunks_in_view_direction()
	
	# Update distances and unload far chunks
	update_chunk_distances(player_pos, ai_pos)
	unload_distant_chunks(chunks_to_keep)

func get_chunks_in_radius(center: Vector3, radius: float) -> Array[Vector3i]:
	"""Get all chunk coordinates within radius of center"""
	var chunks = []
	var chunk_radius = int(ceil(radius / chunk_size))
	var center_chunk = world_to_chunk(center)
	
	for x in range(-chunk_radius, chunk_radius + 1):
		for y in range(-chunk_radius, chunk_radius + 1):
			for z in range(-chunk_radius, chunk_radius + 1):
				var chunk_coord = Vector3i(
					center_chunk.x + x,
					center_chunk.y + y,
					center_chunk.z + z
				)
				
				var chunk_center = chunk_to_world(chunk_coord)
				if chunk_center.distance_to(center) <= radius:
					chunks.append(chunk_coord)
	
	return chunks

func load_chunks_in_view_direction():
	"""Predictively load chunks in camera view direction"""
	if not camera:
		return
	
	var forward = -camera.global_transform.basis.z
	var predictive_pos = camera.global_position + (forward * predictive_distance)
	
	var predictive_chunks = get_chunks_in_radius(predictive_pos, chunk_load_radius * 0.5)
	for chunk_coord in predictive_chunks:
		if not loaded_chunks.has(chunk_coord) and chunks_loaded_this_frame < max_chunks_per_frame:
			load_chunk(chunk_coord)
			chunks_loaded_this_frame += 1
			break

func update_chunk_distances(player_pos: Vector3, ai_pos: Vector3):
	"""Update distance tracking for all loaded chunks"""
	for coord in loaded_chunks:
		var chunk = loaded_chunks[coord]
		chunk.distance_to_player = chunk.position.distance_to(player_pos) if player else INF
		chunk.distance_to_ai = chunk.position.distance_to(ai_pos) if ai_companion else INF
		chunk.last_accessed = Time.get_ticks_msec() / 1000.0

func unload_distant_chunks(chunks_to_keep: Dictionary):
	"""Unload chunks that are far from BOTH player and AI"""
	var chunks_to_unload = []
	
	for coord in loaded_chunks:
		if chunks_to_keep.has(coord):
			continue
		
		var chunk = loaded_chunks[coord]
		var min_distance = min(chunk.distance_to_player, chunk.distance_to_ai)
		
		# Only unload if far from BOTH entities
		if min_distance > chunk_unload_radius:
			chunks_to_unload.append(coord)
	
	# Actually unload chunks
	for coord in chunks_to_unload:
		unload_chunk(coord)

func load_chunk(coord: Vector3i):
	"""Load a chunk at the given coordinate"""
	if loaded_chunks.has(coord):
		return
	
	var chunk_data = ChunkData.new()
	chunk_data.coord = coord
	chunk_data.position = chunk_to_world(coord)
	
	# Create visual representation (placeholder)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3.ONE * chunk_size * 0.9
	mesh_instance.position = chunk_data.position
	add_child(mesh_instance)
	
	chunk_data.mesh_instance = mesh_instance
	loaded_chunks[coord] = chunk_data
	
	chunk_loaded.emit(coord)

func unload_chunk(coord: Vector3i):
	"""Unload a chunk"""
	if not loaded_chunks.has(coord):
		return
	
	var chunk_data = loaded_chunks[coord]
	if chunk_data.mesh_instance:
		chunk_data.mesh_instance.queue_free()
	
	loaded_chunks.erase(coord)
	chunk_unloaded.emit(coord)

func world_to_chunk(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinate"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size)),
		int(floor(world_pos.y / chunk_size)),
		int(floor(world_pos.z / chunk_size))
	)

func chunk_to_world(chunk_coord: Vector3i) -> Vector3:
	"""Convert chunk coordinate to world position (center)"""
	return Vector3(
		chunk_coord.x * chunk_size + chunk_size * 0.5,
		chunk_coord.y * chunk_size + chunk_size * 0.5,
		chunk_coord.z * chunk_size + chunk_size * 0.5
	)

func get_stats() -> Dictionary:
	"""Get chunk manager statistics"""
	return {
		"loaded_chunks": loaded_chunks.size(),
		"player_tracked": player != null,
		"ai_tracked": ai_companion != null,
		"predictive_loading": frustum_load_enabled
	}

extends Node3D
class_name AkashicChunkManager

# ==================================================
# SCRIPT NAME: akashic_chunk_manager.gd  
# DESCRIPTION: Manages infinite 3D grid of Akashic Chunks
# PURPOSE: Create and manage chunks as player/beings move through world
# CREATED: 2025-06-04 - The Infinite Grid
# ==================================================

signal chunk_created(chunk: ChunkUniversalBeing)
signal chunk_destroyed(chunk: ChunkUniversalBeing)

# Configuration
@export var chunk_size: Vector3 = Vector3(16.0, 16.0, 16.0)
@export var view_distance: int = 8  # Chunks to load around player
@export var max_loaded_chunks: int = 512
@export var chunk_scene: PackedScene  # Optional custom chunk scene

# Active chunks
var loaded_chunks: Dictionary = {}  # Vector3i: AkashicChunk3D
var chunk_load_queue: Array = []
var player_chunk: Vector3i = Vector3i.ZERO

# Movement system integration
var movement_system: UniversalBeingMovementSystem

func _ready() -> void:
	add_to_group("chunk_managers")
	
	# Create or get movement system
	movement_system = get_node_or_null("/root/Main/UniversalBeingMovementSystem")
	if not movement_system:
		movement_system = UniversalBeingMovementSystem.new()
		movement_system.name = "UniversalBeingMovementSystem"
		get_node("/root/Main").add_child(movement_system)
	
	# Start chunk loading around origin
	_update_chunks_around(Vector3.ZERO)

func _physics_process(_delta: float) -> void:
	# Update chunks based on camera/player position
	var camera = get_viewport().get_camera_3d()
	if camera:
		var current_chunk = world_to_chunk(camera.global_position)
		if current_chunk != player_chunk:
			player_chunk = current_chunk
			_update_chunks_around(camera.global_position)
func world_to_chunk(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinates"""
	return Vector3i(
		floori(world_pos.x / chunk_size.x),
		floori(world_pos.y / chunk_size.y),
		floori(world_pos.z / chunk_size.z)
	)

func _update_chunks_around(center_pos: Vector3) -> void:
	"""Load chunks within view distance, unload distant chunks"""
	var center_chunk = world_to_chunk(center_pos)
	var chunks_to_keep = {}
	
	# Determine which chunks should be loaded
	for x in range(-view_distance, view_distance + 1):
		for y in range(-2, 3):  # Less vertical range
			for z in range(-view_distance, view_distance + 1):
				var chunk_coord = center_chunk + Vector3i(x, y, z)
				var distance = chunk_coord.distance_to(center_chunk)
				
				if distance <= view_distance:
					chunks_to_keep[chunk_coord] = true
					
					# Load if not already loaded
					if chunk_coord not in loaded_chunks:
						_load_chunk(chunk_coord)
	
	# Unload chunks that are too far
	var chunks_to_remove = []
	for coord in loaded_chunks:
		if coord not in chunks_to_keep:
			chunks_to_remove.append(coord)
	
	for coord in chunks_to_remove:
		_unload_chunk(coord)

func _load_chunk(coord: Vector3i) -> void:
	"""Create and load a chunk at the given coordinates"""
	if loaded_chunks.size() >= max_loaded_chunks:
		# Unload furthest chunk if at limit
		_unload_furthest_chunk()
	
	# Create chunk using existing ChunkUniversalBeing
	var chunk = ChunkUniversalBeing.create_at(coord)
	if not chunk:
		# Fallback if create_at doesn't exist
		chunk = ChunkUniversalBeing.new()
		chunk.chunk_coordinates = coord
	
	chunk.chunk_size = chunk_size
	add_child(chunk)
	
	loaded_chunks[coord] = chunk
	chunk_created.emit(chunk)	
	# Connect neighboring chunks
	_connect_chunk_neighbors(chunk, coord)
	
	print("📦 Loaded chunk at %s" % coord)

func _unload_chunk(coord: Vector3i) -> void:
	"""Unload and destroy a chunk"""
	if coord not in loaded_chunks:
		return
	
	var chunk = loaded_chunks[coord]
	loaded_chunks.erase(coord)
	
	# Notify movement system
	if movement_system:
		movement_system.unregister_chunk(chunk)
	
	chunk_destroyed.emit(chunk)
	chunk.queue_free()
	
	print("📦 Unloaded chunk at %s" % coord)

func _unload_furthest_chunk() -> void:
	"""Unload the chunk furthest from player"""
	var furthest_coord = null
	var max_distance = 0.0
	
	for coord in loaded_chunks:
		var distance = coord.distance_to(player_chunk)
		if distance > max_distance:
			max_distance = distance
			furthest_coord = coord
	
	if furthest_coord:
		_unload_chunk(furthest_coord)

func _connect_chunk_neighbors(chunk: ChunkUniversalBeing, coord: Vector3i) -> void:
	"""Connect chunk to its neighbors for pathfinding"""
	# TODO: Implement neighbor connections if needed
	# ChunkUniversalBeing doesn't have set_neighbor method yet
	pass

func get_chunk_at(world_pos: Vector3) -> ChunkUniversalBeing:
	"""Get the chunk at a world position"""
	var coord = world_to_chunk(world_pos)
	return loaded_chunks.get(coord)
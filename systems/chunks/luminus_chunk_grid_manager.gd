# LuminusChunkGridManager.gd — Luminus's autoload that streams ChunkUniversalBeings
# Clean, elegant approach that we can integrate with our detailed system

extends Node
class_name LuminusChunkGridManager

## ─────────── TUNING ───────────────
# World is partitioned into 10×10×10 cubes (must match ChunkUniversalBeing.CHUNK_SIZE)
const CHUNK_SIZE    : float = 10.0
const LOAD_RADIUS   : float = 30.0     # metres → 3 chunks in every axis around player
const UNLOAD_RADIUS : float = 50.0     # free beyond this

## ─────────── STATE ────────────────
var _active_chunks : Dictionary = {}   # `Vector3i` → ChunkUniversalBeing
var _unload_queue : Array      = []    # coords queued by chunks themselves

## ─────────── PENTAGON LIFECYCLE ───
func pentagon_process(delta : float) -> void:
	# Find any player-like being for streaming
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return  # wait for player spawn

	var player = players[0]  # Use first player
	var player_coords := _world_to_chunk_coords(player.global_position)
	_stream_around(player_coords)
	_flush_unload_queue()

## ─────────── PUBLIC API ────────────
static func queue_unload(coords : Vector3i) -> void:
	# Called by chunks that noticed they're far away
	var manager = Engine.get_singleton("LuminusChunkGridManager")
	if manager and not coords in manager._unload_queue:
		manager._unload_queue.append(coords)

## ─────────── INTERNALS ────────────
func _stream_around(center : Vector3i) -> void:
	var radius := int(ceil(LOAD_RADIUS / CHUNK_SIZE))
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			for z in range(center.z - radius, center.z + radius + 1):
				var c := Vector3i(x, y, z)
				if not _active_chunks.has(c):
					_load_chunk(c)

func _load_chunk(coords : Vector3i) -> void:
	var chunk = LuminusChunkUniversalBeing.new()
	chunk.coords = coords
	chunk.global_position = Vector3(coords) * CHUNK_SIZE
	
	# Register with FloodGates if available
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("add_being_to_scene"):
			flood_gates.add_being_to_scene(chunk, get_tree().current_scene)
		else:
			get_tree().current_scene.add_child(chunk)
	else:
		get_tree().current_scene.add_child(chunk)
	
	_active_chunks[coords] = chunk
	print("🧊 Luminus loaded chunk at %s" % coords)

func _flush_unload_queue() -> void:
	for coords in _unload_queue:
		if _active_chunks.has(coords):
			var chunk : LuminusChunkUniversalBeing = _active_chunks[coords]
			
			# Deregister from FloodGates if available
			if SystemBootstrap and SystemBootstrap.is_system_ready():
				var flood_gates = SystemBootstrap.get_flood_gates()
				if flood_gates and flood_gates.has_method("remove_being"):
					flood_gates.remove_being(chunk)
			
			chunk.queue_free()
			_active_chunks.erase(coords)
			print("🧊 Luminus unloaded chunk at %s" % coords)
	_unload_queue.clear()

static func _world_to_chunk_coords(pos : Vector3) -> Vector3i:
	return Vector3i(
		int(floor(pos.x / CHUNK_SIZE)),
		int(floor(pos.y / CHUNK_SIZE)),
		int(floor(pos.z / CHUNK_SIZE))
	)
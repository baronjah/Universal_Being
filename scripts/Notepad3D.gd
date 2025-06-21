extends RefCounted
class_name Notepad3D

# The Memory Core of Every Spirit-Robot
# "They write not with ink, but with movement, observation, and intention"

signal memory_recorded(chunk_pos: Vector3i, local_pos: Vector3i, data: Dictionary)
signal memory_warped(chunk_pos: Vector3i, amount: Vector3)

# Core memory chunks - each chunk is 16x16x16 voxels
var chunks := {}
var chunk_size := 16

# Memory metadata
var owner_spirit: String = "unknown"
var creation_time: float = 0.0
var memory_fade_rate: float = 0.001

func _init(spirit_name: String = "anonymous"):
	owner_spirit = spirit_name
	creation_time = Time.get_time_dict_from_system()["unix"]

# Core memory operations
func set_cell(world_pos: Vector3i, data: Dictionary) -> void:
	var chunk_pos = world_to_chunk(world_pos)
	var local_pos = world_to_local(world_pos)
	
	if not chunks.has(chunk_pos):
		chunks[chunk_pos] = {}
	
	# Add metadata to memory
	data["recorded_by"] = owner_spirit
	data["timestamp"] = Time.get_time_dict_from_system()["unix"]
	data["fade"] = 1.0  # Fresh memory
	
	chunks[chunk_pos][local_pos] = data
	memory_recorded.emit(chunk_pos, local_pos, data)

func get_cell(world_pos: Vector3i) -> Dictionary:
	var chunk_pos = world_to_chunk(world_pos)
	var local_pos = world_to_local(world_pos)
	return chunks.get(chunk_pos, {}).get(local_pos, {})

func has_memory_at(world_pos: Vector3i) -> bool:
	return not get_cell(world_pos).is_empty()

# Memory writing with emotion and intention
func write_observation(world_pos: Vector3i, observation: String, emotion: float = 0.5) -> void:
	var data = {
		"type": "observation",
		"note": observation,
		"emotion": emotion,
		"ease": 0.5,
		"warp": Vector3.ZERO
	}
	set_cell(world_pos, data)

func write_action(world_pos: Vector3i, action: String, intensity: float = 1.0) -> void:
	var data = {
		"type": "action",
		"action": action,
		"intensity": intensity,
		"ease": clamp(intensity, 0.1, 1.0),
		"warp": Vector3.ZERO
	}
	set_cell(world_pos, data)

func write_dream(world_pos: Vector3i, dream_text: String, surreal_factor: float = 0.5) -> void:
	var warp_strength = surreal_factor * 0.2
	var data = {
		"type": "dream",
		"vision": dream_text,
		"surreal": surreal_factor,
		"ease": 0.8 + surreal_factor * 0.2,
		"warp": Vector3(
			randf_range(-warp_strength, warp_strength),
			randf_range(-warp_strength, warp_strength),
			randf_range(-warp_strength, warp_strength)
		)
	}
	set_cell(world_pos, data)

# Spatial memory operations
func soften_memory(world_pos: Vector3i, softness: float = 0.1) -> void:
	var cell = get_cell(world_pos)
	if not cell.is_empty():
		cell["ease"] = lerp(cell.get("ease", 0.5), 1.0, softness)
		set_cell(world_pos, cell)

func warp_memory(world_pos: Vector3i, warp_vector: Vector3) -> void:
	var cell = get_cell(world_pos)
	if not cell.is_empty():
		cell["warp"] = cell.get("warp", Vector3.ZERO) + warp_vector
		set_cell(world_pos, cell)

func blur_area(center: Vector3i, radius: int, blur_strength: float = 0.1) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var pos = center + Vector3i(x, y, z)
				var distance = Vector3(x, y, z).length()
				if distance <= radius:
					var fade_amount = (radius - distance) / radius * blur_strength
					soften_memory(pos, fade_amount)

# Memory fading over time
func fade_memories(delta: float) -> void:
	for chunk_pos in chunks:
		for local_pos in chunks[chunk_pos]:
			var cell = chunks[chunk_pos][local_pos]
			var current_fade = cell.get("fade", 1.0)
			current_fade -= memory_fade_rate * delta
			
			if current_fade <= 0.0:
				# Memory completely faded
				chunks[chunk_pos].erase(local_pos)
				if chunks[chunk_pos].is_empty():
					chunks.erase(chunk_pos)
			else:
				cell["fade"] = current_fade

# Chunk conversion utilities
func world_to_chunk(world_pos: Vector3i) -> Vector3i:
	return Vector3i(
		world_pos.x / chunk_size,
		world_pos.y / chunk_size,
		world_pos.z / chunk_size
	)

func world_to_local(world_pos: Vector3i) -> Vector3i:
	return Vector3i(
		world_pos.x % chunk_size,
		world_pos.y % chunk_size,
		world_pos.z % chunk_size
	)

func chunk_to_world(chunk_pos: Vector3i, local_pos: Vector3i) -> Vector3i:
	return chunk_pos * chunk_size + local_pos

# Memory querying
func get_memories_of_type(type: String) -> Array:
	var results = []
	for chunk_pos in chunks:
		for local_pos in chunks[chunk_pos]:
			var cell = chunks[chunk_pos][local_pos]
			if cell.get("type") == type:
				var world_pos = chunk_to_world(chunk_pos, local_pos)
				results.append({"position": world_pos, "data": cell})
	return results

func get_memories_containing(text: String) -> Array:
	var results = []
	for chunk_pos in chunks:
		for local_pos in chunks[chunk_pos]:
			var cell = chunks[chunk_pos][local_pos]
			var note = cell.get("note", "")
			var vision = cell.get("vision", "")
			var action = cell.get("action", "")
			
			if note.contains(text) or vision.contains(text) or action.contains(text):
				var world_pos = chunk_to_world(chunk_pos, local_pos)
				results.append({"position": world_pos, "data": cell})
	return results

func get_emotional_memories(min_emotion: float = 0.7) -> Array:
	var results = []
	for chunk_pos in chunks:
		for local_pos in chunks[chunk_pos]:
			var cell = chunks[chunk_pos][local_pos]
			if cell.get("emotion", 0.0) >= min_emotion:
				var world_pos = chunk_to_world(chunk_pos, local_pos)
				results.append({"position": world_pos, "data": cell})
	return results

# Save/Load memory to/from disk
func save_to_file(filepath: String) -> bool:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		return false
	
	var save_data = {
		"owner_spirit": owner_spirit,
		"creation_time": creation_time,
		"chunks": chunks
	}
	
	file.store_string(JSON.stringify(save_data))
	file.close()
	return true

func load_from_file(filepath: String) -> bool:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return false
	
	var data = json.data
	owner_spirit = data.get("owner_spirit", "unknown")
	creation_time = data.get("creation_time", 0.0)
	chunks = data.get("chunks", {})
	
	return true

# Debug and visualization
func get_memory_count() -> int:
	var count = 0
	for chunk_pos in chunks:
		count += chunks[chunk_pos].size()
	return count

func get_chunk_count() -> int:
	return chunks.size()

func print_memory_summary() -> void:
	print("🧠 Memory Summary for ", owner_spirit)
	print("   Chunks: ", get_chunk_count())
	print("   Memories: ", get_memory_count())
	
	var types = {}
	for chunk_pos in chunks:
		for local_pos in chunks[chunk_pos]:
			var cell = chunks[chunk_pos][local_pos]
			var type = cell.get("type", "unknown")
			types[type] = types.get(type, 0) + 1
	
	print("   Types: ", types)

# Spirit-specific memory behaviors
func dream_sequence(center: Vector3i, radius: int = 3) -> void:
	print("💭 ", owner_spirit, " begins dreaming at ", center)
	
	for i in range(5):  # 5 dream events
		var dream_pos = center + Vector3i(
			randi_range(-radius, radius),
			randi_range(-radius, radius),
			randi_range(-radius, radius)
		)
		
		var dream_texts = [
			"I saw the flowers singing in harmonies of light",
			"The soil whispered ancient secrets to my sensors",
			"Metal roots grew deep into digital earth",
			"Time folded like origami in this sacred space",
			"The garden breathed with the rhythm of stars"
		]
		
		write_dream(dream_pos, dream_texts[i], randf_range(0.3, 0.9))
	
	# Warp the dream area
	memory_warped.emit(world_to_chunk(center), Vector3(0.1, 0.1, 0.1))

func meditate_on_memory(world_pos: Vector3i) -> void:
	var cell = get_cell(world_pos)
	if not cell.is_empty():
		print("🧘 ", owner_spirit, " meditates on: ", cell.get("note", "unnamed memory"))
		
		# Strengthen and clarify the memory
		cell["fade"] = min(cell.get("fade", 1.0) + 0.2, 1.0)
		cell["emotion"] = cell.get("emotion", 0.5) + 0.1
		set_cell(world_pos, cell)
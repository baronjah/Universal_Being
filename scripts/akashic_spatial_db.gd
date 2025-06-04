# AkashicSpatialDB - Spatial database integration for chunk persistence
# Connects Luminus's elegant system with Universal Being's Akashic Records

extends Object
class_name AkashicSpatialDB

# ===== CHUNK PERSISTENCE =====

static func has_chunk(coords: Vector3i) -> bool:
	"""Check if chunk data exists in Akashic Records"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return false
	
	var akashic = SystemBootstrap.get_akashic_records()
	if not akashic:
		return false
	
	var chunk_id = "spatial_chunk_%d_%d_%d" % [coords.x, coords.y, coords.z]
	return akashic.has_universal_being_data(chunk_id)

static func load_chunk_into(chunk: LuminusChunkUniversalBeing) -> void:
	"""Load chunk data from Akashic Records into chunk"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return
	
	var akashic = SystemBootstrap.get_akashic_records()
	if not akashic:
		return
	
	var chunk_id = "spatial_chunk_%d_%d_%d" % [chunk.coords.x, chunk.coords.y, chunk.coords.z]
	var chunk_data = akashic.load_universal_being_data(chunk_id)
	
	if chunk_data:
		# Restore chunk properties
		if chunk_data.has("being_name"):
			chunk.being_name = chunk_data.being_name
		if chunk_data.has("consciousness_level"):
			chunk.consciousness_level = chunk_data.consciousness_level
		if chunk_data.has("stored_data"):
			if chunk.has_method("set"):
				chunk.set("stored_data", chunk_data.stored_data)
		
		# Restore contained beings
		if chunk_data.has("contained_beings"):
			restore_contained_beings(chunk, chunk_data.contained_beings)
		
		print("📖 Loaded chunk %s from Akashic Records" % chunk.being_name)

static func save_chunk(chunk: LuminusChunkUniversalBeing) -> void:
	"""Save chunk data to Akashic Records"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return
	
	var akashic = SystemBootstrap.get_akashic_records()
	if not akashic:
		return
	
	var chunk_data = {
		"being_name": chunk.being_name,
		"being_type": chunk.being_type,
		"consciousness_level": chunk.consciousness_level,
		"coords": chunk.coords,
		"stored_data": {},
		"contained_beings": [],
		"creation_timestamp": Time.get_ticks_msec(),
		"last_modified": Time.get_ticks_msec()
	}
	
	# Save stored data if available
	if chunk.has_method("get") and chunk.get("stored_data"):
		chunk_data.stored_data = chunk.get("stored_data")
	
	# Save contained beings
	chunk_data.contained_beings = get_contained_beings_data(chunk)
	
	var chunk_id = "spatial_chunk_%d_%d_%d" % [chunk.coords.x, chunk.coords.y, chunk.coords.z]
	akashic.save_universal_being_data(chunk_id, chunk_data)
	
	print("💾 Saved chunk %s to Akashic Records" % chunk.being_name)

static func restore_contained_beings(chunk: LuminusChunkUniversalBeing, beings_data: Array) -> void:
	"""Restore beings from saved data"""
	for being_data in beings_data:
		if being_data.has("being_type") and SystemBootstrap.is_system_ready():
			var being = SystemBootstrap.create_universal_being()
			if being:
				# Restore basic properties
				being.being_type = being_data.get("being_type", "unknown")
				being.being_name = being_data.get("being_name", "Restored Being")
				being.consciousness_level = being_data.get("consciousness_level", 1)
				
				# Add to chunk
				chunk.add_child(being)
				print("🔄 Restored being: %s" % being.being_name)

static func get_contained_beings_data(chunk: LuminusChunkUniversalBeing) -> Array:
	"""Get data for all beings contained in chunk"""
	var beings_data = []
	
	for child in chunk.get_children():
		if child.has_method("get_being_type"):
			beings_data.append({
				"being_type": child.get_being_type(),
				"being_name": child.get("being_name") if child.has_method("get") else child.name,
				"consciousness_level": child.get("consciousness_level") if child.has_method("get") else 1,
				"position": child.position,
				"properties": get_being_properties(child)
			})
	
	return beings_data

static func get_being_properties(being: Node) -> Dictionary:
	"""Extract saveable properties from a being"""
	var properties = {}
	
	if being.has_method("get_akashic_data"):
		properties = being.get_akashic_data()
	elif being.has_method("get") and being.has_method("get_property_list"):
		# Extract basic Universal Being properties
		var prop_list = being.get_property_list()
		for prop in prop_list:
			if prop.name in ["being_type", "consciousness_level", "evolution_state"]:
				properties[prop.name] = being.get(prop.name)
	
	return properties

# ===== FALLBACK PERSISTENCE =====

static func save_chunk_to_file(chunk: LuminusChunkUniversalBeing) -> void:
	"""Fallback: save chunk to user directory as .tres file"""
	var chunk_data = {
		"coords": chunk.coords,
		"being_name": chunk.being_name,
		"consciousness_level": chunk.consciousness_level,
		"timestamp": Time.get_ticks_msec()
	}
	
	var dir_path = "user://chunks/"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.open("user://").make_dir_recursive("chunks")
	
	var file_path = "%schunk_%d_%d_%d.tres" % [dir_path, chunk.coords.x, chunk.coords.y, chunk.coords.z]
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(chunk_data))
		file.close()
		print("💾 Saved chunk to file: %s" % file_path)

static func load_chunk_from_file(coords: Vector3i) -> Dictionary:
	"""Fallback: load chunk from user directory .tres file"""
	var file_path = "user://chunks/chunk_%d_%d_%d.tres" % [coords.x, coords.y, coords.z]
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				print("📖 Loaded chunk from file: %s" % file_path)
				return json.data
	
	return {}

# ===== UTILITY FUNCTIONS =====

static func clear_chunk_cache() -> void:
	"""Clear all saved chunk data (for testing)"""
	var dir = DirAccess.open("user://chunks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				dir.remove(file_name)
				print("🗑️ Removed chunk file: %s" % file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

static func get_chunk_count() -> int:
	"""Get number of saved chunks"""
	var count = 0
	var dir = DirAccess.open("user://chunks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				count += 1
			file_name = dir.get_next()
		dir.list_dir_end()
	return count

static func list_saved_chunks() -> Array[Vector3i]:
	"""List all saved chunk coordinates"""
	var chunks = []
	var dir = DirAccess.open("user://chunks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") and file_name.begins_with("chunk_"):
				var coords_str = file_name.replace("chunk_", "").replace(".tres", "")
				var coords_parts = coords_str.split("_")
				if coords_parts.size() == 3:
					var coords = Vector3i(
						coords_parts[0].to_int(),
						coords_parts[1].to_int(),
						coords_parts[2].to_int()
					)
					chunks.append(coords)
			file_name = dir.get_next()
		dir.list_dir_end()
	return chunks
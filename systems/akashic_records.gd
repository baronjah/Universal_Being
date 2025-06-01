extends Node
class_name AkashicRecords

var record_db: Dictionary = {}
var save_path: String = "user://akashic_records.dat"

func save_being_data(being: UniversalBeing) -> void:
	var data = {
		"type": being.being_type,
		"name": being.being_name,
		"uuid": being.being_uuid,
		"consciousness_level": being.consciousness_level,
		"metadata": being.metadata,
		"component_data_paths": being.component_data.keys(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Store custom properties
	var properties = {}
	for prop in being.get_property_list():
		if prop.name.begins_with("_") or prop.name in ["script", "name"]:
			continue
		properties[prop.name] = being.get(prop.name)
	data["properties"] = properties
	
	record_db[being.being_uuid] = data
	print("📜 Akashic Records saved: %s" % being.being_name)

func load_being_data(uuid: String) -> Dictionary:
	return record_db.get(uuid, {})

func get_all_records() -> Dictionary:
	return record_db

func search_by_type(type: String) -> Array:
	var results = []
	for uuid in record_db:
		if record_db[uuid].get("type") == type:
			results.append(record_db[uuid])
	return results

func save_to_disk() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(record_db)
		file.close()
		print("📜 Akashic Records saved to disk")

func load_from_disk() -> void:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			record_db = file.get_var()
			file.close()
			print("📜 Akashic Records loaded from disk")

func clear_records() -> void:
	record_db.clear()
	print("📜 Akashic Records cleared")
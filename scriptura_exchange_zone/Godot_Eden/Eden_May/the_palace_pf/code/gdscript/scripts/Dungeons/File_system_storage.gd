class_name FileSystemStorage
extends RefCounted

var base_path = "user://"

func initialize():
	# Create base directories if they don't exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
	if not dir.dir_exists("config"):
		dir.make_dir("config")
	if not dir.dir_exists("archive"):
		dir.make_dir("archive")

func store(key, value):
	var file_path = base_path + "data/" + key + ".dat"
	
	# Serialize the data
	var serialized_data = var_to_str(value)
	
	# Save to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(serialized_data)
		return true
	
	return false

func retrieve(key):
	var file_path = base_path + "data/" + key + ".dat"
	
	if not FileAccess.file_exists(file_path):
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		return str_to_var(content)
	
	return null

func process_outgoing_data(data_payload):
	# For file system, we might need to handle file paths
	if typeof(data_payload) == TYPE_STRING and data_payload.begins_with("file://"):
		var file_path = data_payload.substr(7)
		return retrieve(file_path)
	
	return data_payload

func process_incoming_data(data_payload):
	return data_payload

func archive_data(key):
	var source_path = base_path + "data/" + key + ".dat"
	var target_path = base_path + "archive/" + key + "_" + str(Time.get_unix_time_from_system()) + ".dat"
	
	if FileAccess.file_exists(source_path):
		var dir = DirAccess.open("user://")
		dir.copy(source_path, target_path)
		return true
	
	return false

extends Node
class_name ZipHotloadExtension

## 🔥 CYCLE 3 - AGENT 2 (Programmer) - ZIP HOT-LOADING EXTENSION
## EXTENDS existing magical_zip_consciousness_system with hot-loading capabilities
## Simple, elegant: ZIP changes auto-reload TXT files into reality

signal zip_hotload_detected(zip_path: String, changed_files: Array)
signal gdscript_hotload_executed(script_path: String, success: bool)
signal txt_reality_updated(txt_file: String, new_reality: Dictionary)

# Hot-loading Configuration
@export var enable_file_watching: bool = true
@export var enable_gdscript_hotload: bool = true
@export var enable_txt_reality_hotload: bool = true
@export var watch_interval: float = 0.5  # Check every 500ms

# File Watching System
var watched_zip_files: Dictionary = {}  # zip_path -> file_modified_time
var watched_directories: Array[String] = []
var file_watcher_timer: Timer

# GDScript Hot-loading
var loaded_scripts: Dictionary = {}  # script_path -> Script
var script_instances: Dictionary = {}  # script_path -> instance

# TXT Reality System
var txt_reality_cache: Dictionary = {}  # txt_file -> reality_data
var magical_zip_system: Node

func _ready() -> void:
	name = "ZipHotloadExtension"
	print("🔥 ZIP HOT-LOADING EXTENSION: REAL-TIME ZIP → REALITY!")
	
	# Get reference to existing magical ZIP system
	magical_zip_system = get_tree().get_first_node_in_group("zip_consciousness_systems")
	if not magical_zip_system:
		print("❌ Magical ZIP system not found! Creating connection...")
		call_deferred("connect_to_zip_system")
	
	# Setup file watching
	if enable_file_watching:
		setup_file_watcher()
	
	# Setup default watch directories
	add_watch_directory("res://zip_worlds/")
	add_watch_directory("res://txt_realities/")
	add_watch_directory("res://gdscript_hotload/")

func setup_file_watcher() -> void:
	"""Setup file system watching for hot-loading"""
	file_watcher_timer = Timer.new()
	file_watcher_timer.wait_time = watch_interval
	file_watcher_timer.timeout.connect(_on_file_watch_tick)
	add_child(file_watcher_timer)
	file_watcher_timer.start()
	
	print("👁️ File watcher active: %s second intervals" % watch_interval)

func add_watch_directory(dir_path: String) -> void:
	"""Add directory to watch for ZIP file changes"""
	if dir_path not in watched_directories:
		watched_directories.append(dir_path)
		print("📂 Watching directory: %s" % dir_path)
		
		# Scan initial ZIP files
		scan_zip_files_in_directory(dir_path)

func scan_zip_files_in_directory(dir_path: String) -> void:
	"""Scan directory for ZIP files and add to watch list"""
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".zip"):
			var full_path = dir_path + "/" + file_name
			var file_time = FileAccess.get_modified_time(full_path)
			watched_zip_files[full_path] = file_time
			print("🗂️ Watching ZIP: %s" % full_path)
		
		file_name = dir.get_next()

func _on_file_watch_tick() -> void:
	"""Check for file changes and trigger hot-loading"""
	for zip_path in watched_zip_files.keys():
		if FileAccess.file_exists(zip_path):
			var current_time = FileAccess.get_modified_time(zip_path)
			var last_time = watched_zip_files[zip_path]
			
			if current_time > last_time:
				print("🔥 ZIP CHANGED DETECTED: %s" % zip_path)
				watched_zip_files[zip_path] = current_time
				trigger_zip_hotload(zip_path)

func trigger_zip_hotload(zip_path: String) -> void:
	"""Trigger hot-loading for changed ZIP file"""
	print("🚀 TRIGGERING ZIP HOT-LOAD: %s" % zip_path)
	
	# Analyze ZIP contents
	var changed_files = analyze_zip_contents(zip_path)
	zip_hotload_detected.emit(zip_path, changed_files)
	
	# Process different file types
	for file_info in changed_files:
		var file_path = file_info.path
		var file_type = file_info.type
		
		match file_type:
			"gdscript":
				if enable_gdscript_hotload:
					hotload_gdscript(zip_path, file_path)
			"txt":
				if enable_txt_reality_hotload:
					hotload_txt_reality(zip_path, file_path)
			"json":
				hotload_json_data(zip_path, file_path)
			"tscn":
				hotload_scene_data(zip_path, file_path)
	
	# Reload entire ZIP world through existing system
	if magical_zip_system and magical_zip_system.has_method("load_zip_world"):
		magical_zip_system.load_zip_world(zip_path)

func analyze_zip_contents(zip_path: String) -> Array:
	"""Analyze ZIP file contents and categorize files"""
	var changed_files = []
	var zip_reader = ZIPReader.new()
	
	if zip_reader.open(zip_path) != OK:
		print("❌ Failed to open ZIP: %s" % zip_path)
		return changed_files
	
	var file_list = zip_reader.get_files()
	
	for file_path in file_list:
		var file_info = {
			"path": file_path,
			"type": get_file_type(file_path),
			"data": zip_reader.read_file(file_path)
		}
		changed_files.append(file_info)
	
	zip_reader.close()
	return changed_files

func get_file_type(file_path: String) -> String:
	"""Determine file type from extension"""
	var ext = file_path.get_extension().to_lower()
	
	match ext:
		"gd":
			return "gdscript"
		"txt", "md":
			return "txt"
		"json":
			return "json"
		"tscn":
			return "tscn"
		"cs":
			return "csharp"
		_:
			return "unknown"

func hotload_gdscript(zip_path: String, script_path: String) -> void:
	"""Hot-load GDScript from ZIP file"""
	print("🔥 HOT-LOADING GDSCRIPT: %s from %s" % [script_path, zip_path])
	
	var zip_reader = ZIPReader.new()
	if zip_reader.open(zip_path) != OK:
		gdscript_hotload_executed.emit(script_path, false)
		return
	
	var script_content = zip_reader.read_file(script_path).get_string_from_utf8()
	zip_reader.close()
	
	# Create and compile script
	var script = GDScript.new()
	script.source_code = script_content
	
	if script.reload() == OK:
		loaded_scripts[script_path] = script
		
		# Create instance if it's a class
		if script.can_instantiate():
			var instance = script.new()
			script_instances[script_path] = instance
			
			# Add to scene tree if it extends Node
			if instance is Node:
				get_tree().current_scene.add_child(instance)
				print("✅ GDScript instance added to scene: %s" % script_path)
		
		gdscript_hotload_executed.emit(script_path, true)
		print("✅ GDScript hot-loaded successfully: %s" % script_path)
	else:
		gdscript_hotload_executed.emit(script_path, false)
		print("❌ GDScript compilation failed: %s" % script_path)

func hotload_txt_reality(zip_path: String, txt_path: String) -> void:
	"""Hot-load TXT file and convert to 3D reality"""
	print("📝 HOT-LOADING TXT REALITY: %s from %s" % [txt_path, zip_path])
	
	var zip_reader = ZIPReader.new()
	if zip_reader.open(zip_path) != OK:
		return
	
	var txt_content = zip_reader.read_file(txt_path).get_string_from_utf8()
	zip_reader.close()
	
	# Process TXT content into reality data
	var reality_data = process_txt_to_reality(txt_content, txt_path)
	txt_reality_cache[txt_path] = reality_data
	
	# Manifest reality into 3D space
	manifest_txt_reality(reality_data, txt_path)
	
	txt_reality_updated.emit(txt_path, reality_data)
	print("✅ TXT reality manifested: %s" % txt_path)

func process_txt_to_reality(content: String, file_path: String) -> Dictionary:
	"""Process TXT content into 3D reality data"""
	var reality_data = {
		"source_file": file_path,
		"content": content,
		"objects": [],
		"instructions": [],
		"consciousness_level": 1.0
	}
	
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty():
			continue
		
		# Parse different line types
		if line.begins_with("CREATE:"):
			reality_data.objects.append(parse_create_instruction(line))
		elif line.begins_with("PLACE:"):
			reality_data.instructions.append(parse_placement_instruction(line))
		elif line.begins_with("CONSCIOUSNESS:"):
			reality_data.consciousness_level = parse_consciousness_level(line)
		else:
			# Treat as story/description text
			reality_data.instructions.append({
				"type": "story",
				"content": line
			})
	
	return reality_data

func parse_create_instruction(line: String) -> Dictionary:
	"""Parse CREATE: instruction from TXT"""
	var parts = line.replace("CREATE:", "").strip_edges().split(" ")
	return {
		"type": "create",
		"object": parts[0] if parts.size() > 0 else "cube",
		"properties": parts.slice(1) if parts.size() > 1 else []
	}

func parse_placement_instruction(line: String) -> Dictionary:
	"""Parse PLACE: instruction from TXT"""
	var content = line.replace("PLACE:", "").strip_edges()
	return {
		"type": "place",
		"instruction": content
	}

func parse_consciousness_level(line: String) -> float:
	"""Parse CONSCIOUSNESS: level from TXT"""
	var level_str = line.replace("CONSCIOUSNESS:", "").strip_edges()
	return float(level_str) if level_str.is_valid_float() else 1.0

func manifest_txt_reality(reality_data: Dictionary, txt_path: String) -> void:
	"""Manifest reality data into actual 3D objects"""
	var reality_container = Node3D.new()
	reality_container.name = "TxtReality_" + txt_path.get_file().get_basename()
	get_tree().current_scene.add_child(reality_container)
	
	# Create objects
	for obj_data in reality_data.objects:
		var object_node = create_object_from_data(obj_data)
		if object_node:
			reality_container.add_child(object_node)
	
	# Apply consciousness level
	apply_consciousness_to_reality(reality_container, reality_data.consciousness_level)
	
	print("🌟 Reality manifested with %d objects" % reality_data.objects.size())

func create_object_from_data(obj_data: Dictionary) -> Node3D:
	"""Create 3D object from object data"""
	var object_type = obj_data.get("object", "cube")
	var node = MeshInstance3D.new()
	
	match object_type.to_lower():
		"cube":
			node.mesh = BoxMesh.new()
		"sphere":
			node.mesh = SphereMesh.new()
		"plane":
			node.mesh = PlaneMesh.new()
		"cylinder":
			node.mesh = CylinderMesh.new()
		_:
			node.mesh = BoxMesh.new()  # Default
	
	node.name = object_type.capitalize()
	
	# Apply random position for now
	node.position = Vector3(
		randf_range(-10, 10),
		randf_range(0, 5),
		randf_range(-10, 10)
	)
	
	return node

func apply_consciousness_to_reality(container: Node3D, level: float) -> void:
	"""Apply consciousness effects to reality container"""
	if level >= 3.0:
		# Add glow effect for higher consciousness
		for child in container.get_children():
			if child is MeshInstance3D:
				var material = StandardMaterial3D.new()
				material.emission_enabled = true
				material.emission = Color.CYAN * (level / 10.0)
				child.material_override = material

func hotload_json_data(zip_path: String, json_path: String) -> void:
	"""Hot-load JSON configuration data"""
	print("📋 HOT-LOADING JSON: %s from %s" % [json_path, zip_path])
	
	var zip_reader = ZIPReader.new()
	if zip_reader.open(zip_path) != OK:
		return
	
	var json_content = zip_reader.read_file(json_path).get_string_from_utf8()
	zip_reader.close()
	
	var json = JSON.new()
	if json.parse(json_content) == OK:
		var data = json.data
		process_json_configuration(data, json_path)
		print("✅ JSON configuration loaded: %s" % json_path)
	else:
		print("❌ JSON parse error: %s" % json_path)

func process_json_configuration(data: Dictionary, file_path: String) -> void:
	"""Process JSON configuration data"""
	# Apply configuration to existing systems
	if data.has("zip_settings"):
		apply_zip_settings(data.zip_settings)
	
	if data.has("consciousness_settings"):
		apply_consciousness_settings(data.consciousness_settings)

func apply_zip_settings(settings: Dictionary) -> void:
	"""Apply ZIP-specific settings"""
	if settings.has("watch_interval"):
		watch_interval = float(settings.watch_interval)
		if file_watcher_timer:
			file_watcher_timer.wait_time = watch_interval

func apply_consciousness_settings(settings: Dictionary) -> void:
	"""Apply consciousness-specific settings"""
	if magical_zip_system and settings.has("consciousness_multiplier"):
		if magical_zip_system.has_method("set_consciousness_multiplier"):
			magical_zip_system.set_consciousness_multiplier(float(settings.consciousness_multiplier))

func hotload_scene_data(zip_path: String, scene_path: String) -> void:
	"""Hot-load scene data from ZIP"""
	print("🎬 HOT-LOADING SCENE: %s from %s" % [scene_path, zip_path])
	# Scene hot-loading would require more complex implementation
	# For now, just log the attempt
	print("🚧 Scene hot-loading not yet implemented for: %s" % scene_path)

func connect_to_zip_system() -> void:
	"""Connect to existing magical ZIP consciousness system"""
	magical_zip_system = get_tree().get_first_node_in_group("zip_consciousness_systems")
	if magical_zip_system:
		print("🔗 Connected to magical ZIP consciousness system")
		
		# Connect to existing signals if available
		if magical_zip_system.has_signal("zip_world_manifested"):
			magical_zip_system.zip_world_manifested.connect(_on_zip_world_manifested)

func _on_zip_world_manifested(zip_path: String, world_data: Dictionary) -> void:
	"""Handle ZIP world manifestation from main system"""
	print("🌍 ZIP world manifested via main system: %s" % zip_path)

# Public API

func add_zip_watch(zip_path: String) -> void:
	"""Add specific ZIP file to watch list"""
	if FileAccess.file_exists(zip_path):
		var file_time = FileAccess.get_modified_time(zip_path)
		watched_zip_files[zip_path] = file_time
		print("👁️ Added ZIP to watch list: %s" % zip_path)

func force_reload_zip(zip_path: String) -> void:
	"""Force reload specific ZIP file"""
	print("🔄 Force reloading ZIP: %s" % zip_path)
	trigger_zip_hotload(zip_path)

func get_hotload_status() -> Dictionary:
	"""Get current hot-loading status"""
	return {
		"watching": enable_file_watching,
		"watched_zips": watched_zip_files.size(),
		"watched_dirs": watched_directories.size(),
		"loaded_scripts": loaded_scripts.size(),
		"txt_realities": txt_reality_cache.size()
	}
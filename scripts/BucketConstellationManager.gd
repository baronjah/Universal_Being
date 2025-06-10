# BUCKET CONSTELLATION MANAGER - LAYER_0 DEBUG ORGANIZATION
# Organizes the cosmic debug chamber into meaningful bucket clusters
extends Node3D
class_name BucketConstellationManager

signal bucket_selected(bucket_name: String)
signal variable_inspected(script_path: String, var_name: String, value: Variant)
signal chunk_view_requested(large_var: Variant, chunk_size: int)

# Bucket constellation configuration
var bucket_systems: Dictionary = {}
var current_layer: int = 0  # Layer_0 = debug, Layer_1+ = perfected game
var chunk_inspector_active: bool = false

# Variable inspection system
var var_watchers: Dictionary = {}  # script_path -> {var_name -> watcher_node}
var large_var_chunks: Dictionary = {}  # For chunked inspection of big variables

func _ready():
	print("🪣 Bucket Constellation Manager: Organizing the cosmic debug cosmos...")
	_initialize_bucket_constellations()

func _initialize_bucket_constellations():
	"""Initialize organized bucket constellations for Layer_0 debugging"""
	
	# Define the bucket categories based on JSH's thought patterns
	var bucket_definitions = {
		"akashic_universe": {
			"keywords": ["akashic", "database", "save", "load", "storage", "records"],
			"color": Color.GOLD,
			"position_offset": Vector3(0, 0, 0),
			"description": "Data persistence and cosmic memory systems"
		},
		"consciousness_beings": {
			"keywords": ["universal_being", "consciousness", "plasmoid", "gemma", "beings"],
			"color": Color.CYAN,
			"position_offset": Vector3(100, 0, 0),
			"description": "Conscious entities and AI companions"
		},
		"debug_tools": {
			"keywords": ["debug", "test", "monitor", "validator", "inspector"],
			"color": Color.MAGENTA,
			"position_offset": Vector3(-100, 0, 0),
			"description": "Layer_0 debugging and testing tools"
		},
		"interface_systems": {
			"keywords": ["console", "ui", "interface", "3d_programming", "notepad"],
			"color": Color.YELLOW,
			"position_offset": Vector3(0, 100, 0),
			"description": "User interfaces and interaction systems"
		},
		"world_generation": {
			"keywords": ["chunk", "terrain", "world", "generator", "matrix"],
			"color": Color.GREEN,
			"position_offset": Vector3(0, -100, 0),
			"description": "Universe generation and world systems"
		},
		"scenario_systems": {
			"keywords": ["scenario", "zip", "package", "component", "template"],
			"color": Color.ORANGE,
			"position_offset": Vector3(50, 50, 50),
			"description": "Packaged scenarios and component systems"
		},
		"communication_streams": {
			"keywords": ["message", "chat", "communication", "bridge", "protocol"],
			"color": Color.PURPLE,
			"position_offset": Vector3(-50, -50, -50),
			"description": "Communication and bridge systems"
		},
		"memory_evolution": {
			"keywords": ["memory", "evolution", "dna", "pattern", "learning"],
			"color": Color.WHITE,
			"position_offset": Vector3(0, 0, 100),
			"description": "Memory systems and evolution patterns"
		}
	}
	
	# Create bucket constellations
	for bucket_name in bucket_definitions.keys():
		var bucket_data = bucket_definitions[bucket_name]
		_create_bucket_constellation(bucket_name, bucket_data)
	
	print("🌌 Created %d bucket constellations for cosmic organization" % bucket_definitions.size())

func _create_bucket_constellation(bucket_name: String, bucket_data: Dictionary):
	"""Create a constellation cluster for a specific bucket category"""
	
	var constellation = Node3D.new()
	constellation.name = "Constellation_" + bucket_name
	constellation.position = bucket_data.position_offset
	
	# Find all scripts that belong to this bucket
	var matching_scripts = _find_scripts_for_bucket(bucket_data.keywords)
	
	# Create stars in a cluster formation
	for i in range(matching_scripts.size()):
		var script_path = matching_scripts[i]
		var star_position = _calculate_cluster_position(i, matching_scripts.size())
		var star = _create_debug_star(script_path, star_position, bucket_data.color)
		constellation.add_child(star)
	
	# Create bucket center marker
	var center_marker = _create_bucket_center_marker(bucket_name, bucket_data)
	constellation.add_child(center_marker)
	
	bucket_systems[bucket_name] = {
		"constellation": constellation,
		"scripts": matching_scripts,
		"data": bucket_data
	}
	
	add_child(constellation)
	print("🪣 Created bucket constellation: %s with %d stars" % [bucket_name, matching_scripts.size()])

func _create_debug_star(script_path: String, position: Vector3, color: Color) -> Node3D:
	"""Create a debug-enabled star with variable inspection capabilities"""
	
	var star = MeshInstance3D.new()
	star.name = "DebugStar_" + script_path.get_file().replace(".gd", "")
	star.position = position
	
	# Visual representation
	var sphere = SphereMesh.new()
	sphere.radius = 1.5
	star.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission_energy = 0.7
	star.material_override = material
	
	# Add debug interface
	var debug_interface = _create_debug_interface(script_path)
	star.add_child(debug_interface)
	
	# Store metadata
	star.set_meta("script_path", script_path)
	star.set_meta("debug_enabled", true)
	star.set_meta("layer", 0)  # Layer_0 = debug layer
	
	return star

func _create_debug_interface(script_path: String) -> Node3D:
	"""Create debug interface for script variable inspection"""
	
	var interface = Node3D.new()
	interface.name = "DebugInterface"
	
	# Load script and analyze variables
	var script_vars = _analyze_script_variables(script_path)
	
	# Create variable inspector nodes
	for i in range(script_vars.size()):
		var var_info = script_vars[i]
		var inspector = _create_variable_inspector(var_info, i)
		interface.add_child(inspector)
	
	# Add click detection for interface
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0
	collision.shape = shape
	area.add_child(collision)
	interface.add_child(area)
	
	area.input_event.connect(_on_debug_interface_clicked.bind(script_path))
	
	return interface

func _create_variable_inspector(var_info: Dictionary, index: int) -> Node3D:
	"""Create inspector for individual variable"""
	
	var inspector = MeshInstance3D.new()
	inspector.name = "VarInspector_" + var_info.name
	inspector.position = Vector3(0, index * 0.5, 2)
	
	# Small cube to represent variable
	var box = BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	inspector.mesh = box
	
	# Color based on variable type
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_var_type_color(var_info.type)
	inspector.material_override = material
	
	# Store variable data
	inspector.set_meta("var_name", var_info.name)
	inspector.set_meta("var_type", var_info.type)
	inspector.set_meta("is_large", var_info.is_large)
	
	return inspector

func _analyze_script_variables(script_path: String) -> Array:
	"""Analyze script to find all variables for inspection"""
	var variables = []
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var lines = content.split("\n")
		for line in lines:
			line = line.strip_edges()
			
			# Look for variable declarations
			if line.begins_with("var ") or line.begins_with("@export var "):
				var var_info = _parse_variable_declaration(line)
				if var_info:
					variables.append(var_info)
	
	return variables

func _parse_variable_declaration(line: String) -> Dictionary:
	"""Parse a variable declaration line"""
	var var_info = {}
	
	# Extract variable name and type
	var parts = line.split(":")
	if parts.size() >= 1:
		var name_part = parts[0].replace("var ", "").replace("@export var ", "").strip_edges()
		var_info.name = name_part.split("=")[0].strip_edges()
		
		if parts.size() >= 2:
			var type_part = parts[1].split("=")[0].strip_edges()
			var_info.type = type_part
		else:
			var_info.type = "Variant"
		
		# Determine if potentially large variable
		var_info.is_large = _is_potentially_large_var(var_info.type, var_info.name)
		
		return var_info
	
	return {}

func _is_potentially_large_var(type: String, name: String) -> bool:
	"""Determine if variable might be large and need chunked inspection"""
	var large_types = ["Array", "Dictionary", "PackedByteArray", "String"]
	var large_names = ["chunk", "data", "content", "buffer", "cache"]
	
	for large_type in large_types:
		if type.contains(large_type):
			return true
	
	for large_name in large_names:
		if name.to_lower().contains(large_name):
			return true
	
	return false

func _find_scripts_for_bucket(keywords: Array) -> Array:
	"""Find all scripts that match bucket keywords"""
	var matching_scripts = []
	var all_scripts = _find_all_gdscript_files()
	
	for script_path in all_scripts:
		var script_name = script_path.to_lower()
		var script_content = _get_script_content_preview(script_path)
		
		for keyword in keywords:
			if keyword in script_name or keyword in script_content.to_lower():
				matching_scripts.append(script_path)
				break
	
	return matching_scripts

func _get_script_content_preview(script_path: String) -> String:
	"""Get first few lines of script for keyword matching"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var preview = ""
		for i in range(10):  # First 10 lines
			var line = file.get_line()
			if file.eof_reached():
				break
			preview += line + " "
		file.close()
		return preview
	return ""

func _calculate_cluster_position(index: int, total_count: int) -> Vector3:
	"""Calculate position within constellation cluster"""
	if total_count == 1:
		return Vector3.ZERO
	
	# Arrange in spiral pattern within cluster
	var angle = (index / float(total_count)) * TAU * 2
	var radius = 10.0 + (index * 2.0)
	var height = sin(index * 0.5) * 5.0
	
	return Vector3(
		cos(angle) * radius,
		height,
		sin(angle) * radius
	)

func _create_bucket_center_marker(bucket_name: String, bucket_data: Dictionary) -> Node3D:
	"""Create center marker for bucket constellation"""
	var marker = MeshInstance3D.new()
	marker.name = "BucketCenter_" + bucket_name
	marker.position = Vector3.ZERO
	
	# Larger sphere for bucket center
	var sphere = SphereMesh.new()
	sphere.radius = 3.0
	marker.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = bucket_data.color
	material.emission_enabled = true
	material.emission_energy = 1.0
	marker.material_override = material
	
	# Add bucket info display
	var label = Label3D.new()
	label.text = bucket_name.replace("_", " ").capitalize()
	label.position = Vector3(0, 5, 0)
	marker.add_child(label)
	
	return marker

func _get_var_type_color(var_type: String) -> Color:
	"""Get color based on variable type"""
	match var_type:
		"int", "float":
			return Color.BLUE
		"String":
			return Color.GREEN
		"bool":
			return Color.RED
		"Array":
			return Color.YELLOW
		"Dictionary":
			return Color.ORANGE
		"Vector3", "Vector2":
			return Color.PURPLE
		_:
			return Color.WHITE

func _on_debug_interface_clicked(script_path: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on debug interface"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🔍 Opening debug interface for: %s" % script_path.get_file())
		_open_script_debug_panel(script_path)

func _open_script_debug_panel(script_path: String):
	"""Open comprehensive debug panel for script"""
	print("📊 Debug Panel: %s" % script_path)
	print("  🔍 Script loaded: %s" % _is_script_loaded(script_path))
	print("  📊 Variables available for inspection")
	
	# Check if script is currently loaded/instantiated
	var is_loaded = _is_script_loaded(script_path)
	print("  ⚡ Runtime status: %s" % ("ACTIVE" if is_loaded else "INACTIVE"))

func _is_script_loaded(script_path: String) -> bool:
	"""Check if script is currently loaded in the game"""
	# Check if any nodes in the scene tree use this script
	var root = get_tree().current_scene
	return _check_node_tree_for_script(root, script_path)

func _check_node_tree_for_script(node: Node, script_path: String) -> bool:
	"""Recursively check if any node uses the script"""
	if node.get_script() and str(node.get_script().resource_path) == script_path:
		return true
	
	for child in node.get_children():
		if _check_node_tree_for_script(child, script_path):
			return true
	
	return false

func _find_all_gdscript_files() -> Array:
	"""Find all GDScript files in project"""
	var files = []
	_scan_directory_recursive("res://", files, ".gd")
	return files

func _scan_directory_recursive(path: String, files: Array, extension: String):
	"""Recursively scan directory for files with extension"""
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				_scan_directory_recursive(full_path, files, extension)
			elif file_name.ends_with(extension):
				files.append(full_path)
			file_name = dir.get_next()

# Layer management
func switch_to_layer(layer_num: int):
	"""Switch between debug layer (0) and game layers (1+)"""
	current_layer = layer_num
	print("🌌 Switched to Layer_%d" % layer_num)
	
	if layer_num == 0:
		print("🔍 Debug mode: All stars show variable inspection interfaces")
	else:
		print("🎮 Game mode: Walking around the perfected universe")

# Chunk inspection for large variables
func inspect_large_variable_in_chunks(var_data: Variant, chunk_size: int = 100):
	"""Inspect large variables in manageable chunks"""
	chunk_inspector_active = true
	print("📊 Inspecting large variable in chunks of %d" % chunk_size)
	chunk_view_requested.emit(var_data, chunk_size)

func _class_name():
	print("🪣 BucketConstellationManager: Ready to organize the cosmic debug cosmos!")
# FUNCTION DATABASE 3D - AKASHIC RECORDS FUNCTION BROWSER
# Browse all functions in the codebase visually in 3D space
extends Node3D
class_name FunctionDatabase3D

signal function_selected(function_info: Dictionary)
signal database_updated(total_functions: int)
signal search_completed(results: Array)

# Database organization
var all_functions: Dictionary = {}  # file_path -> functions_array
var function_categories: Dictionary = {}  # category -> functions
var search_results: Array = []
var current_filter: String = ""

# Visual elements
var function_spheres: Dictionary = {}  # function_id -> visual_node
var category_clusters: Dictionary = {}  # category -> cluster_node
var search_interface: Node3D = null
var database_center: Vector3 = Vector3.ZERO

# Display configuration
var sphere_radius: float = 0.8
var cluster_spacing: float = 15.0
var functions_per_cluster: int = 20
var search_radius: float = 50.0

func _ready():
	print("📚 Function Database: Initializing Akashic function browser...")
	scan_all_functions()
	create_database_interface()
	organize_functions_by_category()
	create_visual_function_spheres()
	print("✨ Function Database: Ready for exploration!")

func scan_all_functions():
	"""Scan entire codebase for functions"""
	print("🔍 Scanning codebase for all functions...")
	all_functions.clear()
	
	var script_files = _find_all_script_files()
	for script_path in script_files:
		var functions = _extract_all_functions_from_file(script_path)
		if not functions.is_empty():
			all_functions[script_path] = functions
	
	var total_count = 0
	for file_functions in all_functions.values():
		total_count += file_functions.size()
	
	print("📊 Found %d functions in %d files" % [total_count, all_functions.size()])
	database_updated.emit(total_count)

func _find_all_script_files() -> Array:
	"""Find all GDScript files in project"""
	var files = []
	_scan_directory_recursive("res://", files)
	return files

func _scan_directory_recursive(path: String, files: Array):
	"""Recursively scan directories for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_recursive(full_path, files)
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()

func _extract_all_functions_from_file(file_path: String) -> Array:
	"""Extract all functions from a script file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return []
	
	var content = file.get_as_text()
	file.close()
	
	var functions = []
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with("func ") and ":" in line:
			var function_info = _parse_function_signature(line, i + 1, file_path)
			if function_info:
				functions.append(function_info)
	
	return functions

func _parse_function_signature(line: String, line_number: int, file_path: String) -> Dictionary:
	"""Parse function signature and extract metadata"""
	var func_match = line.split("func ")[1]
	var name_part = func_match.split("(")[0].strip_edges()
	var params_part = ""
	var return_type = "void"
	
	if "(" in func_match and ")" in func_match:
		var full_sig = func_match.split("(")[1].split(")")[0]
		params_part = full_sig
	
	if "->" in line:
		return_type = line.split("->")[1].split(":")[0].strip_edges()
	
	# Determine function category
	var category = _categorize_function(name_part, file_path)
	
	return {
		"name": name_part,
		"file_path": file_path,
		"line_number": line_number,
		"parameters": params_part,
		"return_type": return_type,
		"category": category,
		"visibility": "public" if not name_part.begins_with("_") else "private",
		"full_signature": line,
		"file_name": file_path.get_file()
	}

func _categorize_function(function_name: String, file_path: String) -> String:
	"""Categorize function based on name and location"""
	# Pentagon lifecycle functions
	if function_name.begins_with("pentagon_"):
		return "Pentagon Lifecycle"
	
	# Universal Being core functions
	if function_name in ["_ready", "_process", "_input", "_init"]:
		return "Godot Lifecycle"
	
	# File-based categorization
	if "core/" in file_path:
		return "Core Systems"
	elif "beings/" in file_path:
		return "Universal Beings"
	elif "systems/" in file_path:
		return "Game Systems"
	elif "scripts/" in file_path:
		return "Gameplay Scripts"
	elif "ui/" in file_path:
		return "User Interface"
	elif "autoloads/" in file_path:
		return "Autoloads"
	
	# Function name patterns
	if function_name.begins_with("get_"):
		return "Getters"
	elif function_name.begins_with("set_"):
		return "Setters"
	elif function_name.begins_with("create_"):
		return "Creators"
	elif function_name.begins_with("update_"):
		return "Updaters"
	elif function_name.begins_with("handle_"):
		return "Handlers"
	elif function_name.begins_with("_on_"):
		return "Signal Handlers"
	
	return "General Functions"

func organize_functions_by_category():
	"""Organize functions into visual categories"""
	function_categories.clear()
	
	for file_path in all_functions.keys():
		var functions = all_functions[file_path]
		for function_info in functions:
			var category = function_info.category
			if not function_categories.has(category):
				function_categories[category] = []
			function_categories[category].append(function_info)
	
	print("📂 Organized into %d categories:" % function_categories.size())
	for category in function_categories.keys():
		var count = function_categories[category].size()
		print("  • %s: %d functions" % [category, count])

func create_database_interface():
	"""Create 3D interface for browsing functions"""
	print("🌌 Creating 3D function database interface...")
	
	# Create search interface
	create_search_interface()
	
	# Create category legend
	create_category_legend()
	
	# Create navigation helpers
	create_navigation_interface()

func create_search_interface():
	"""Create 3D search interface"""
	search_interface = Node3D.new()
	search_interface.name = "SearchInterface"
	search_interface.position = Vector3(0, 10, 0)
	
	# Search title
	var title = Label3D.new()
	title.text = "🔍 FUNCTION DATABASE SEARCH"
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 2, 0)
	title.modulate = Color.CYAN
	title.pixel_size = 0.02
	search_interface.add_child(title)
	
	# Search instructions
	var instructions = Label3D.new()
	instructions.text = "Press F to search • R to reset • Click functions to explore"
	instructions.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	instructions.position = Vector3(0, 0, 0)
	instructions.modulate = Color.WHITE
	instructions.pixel_size = 0.012
	search_interface.add_child(instructions)
	
	add_child(search_interface)

func create_category_legend():
	"""Create legend showing function categories"""
	var legend_position = Vector3(-30, 0, 0)
	var categories = function_categories.keys()
	
	var legend_title = Label3D.new()
	legend_title.text = "📚 FUNCTION CATEGORIES"
	legend_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	legend_title.position = legend_position + Vector3(0, 8, 0)
	legend_title.modulate = Color.GOLD
	legend_title.pixel_size = 0.015
	add_child(legend_title)
	
	for i in range(categories.size()):
		var category = categories[i]
		var count = function_categories[category].size()
		var color = _get_category_color(category)
		
		var legend_item = create_category_legend_item(
			category + " (" + str(count) + ")",
			legend_position + Vector3(0, 6 - i * 1.2, 0),
			color
		)
		add_child(legend_item)

func create_category_legend_item(text: String, position: Vector3, color: Color) -> Node3D:
	"""Create a category legend item"""
	var item = Node3D.new()
	item.position = position
	
	# Color indicator
	var indicator = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	indicator.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 1.0
	indicator.material_override = material
	item.add_child(indicator)
	
	# Category label
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(1, 0, 0)
	label.modulate = Color.WHITE
	label.pixel_size = 0.01
	item.add_child(label)
	
	return item

func create_visual_function_spheres():
	"""Create visual spheres for all functions organized by category"""
	print("✨ Creating visual function spheres...")
	
	var category_index = 0
	for category in function_categories.keys():
		var functions = function_categories[category]
		var cluster_center = _calculate_cluster_position(category_index)
		
		# Create category cluster
		var cluster = create_category_cluster(category, cluster_center)
		category_clusters[category] = cluster
		add_child(cluster)
		
		# Create function spheres in this cluster
		create_functions_in_cluster(functions, cluster, category)
		
		category_index += 1

func _calculate_cluster_position(index: int) -> Vector3:
	"""Calculate position for category cluster"""
	var angle = (index * TAU) / function_categories.size()
	var radius = cluster_spacing
	return Vector3(
		cos(angle) * radius,
		0,
		sin(angle) * radius
	)

func create_category_cluster(category: String, center: Vector3) -> Node3D:
	"""Create a cluster container for a category"""
	var cluster = Node3D.new()
	cluster.name = "Cluster_" + category.replace(" ", "_")
	cluster.position = center
	
	# Cluster title
	var title = Label3D.new()
	title.text = "📂 " + category.to_upper()
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 5, 0)
	title.modulate = _get_category_color(category)
	title.pixel_size = 0.015
	cluster.add_child(title)
	
	return cluster

func create_functions_in_cluster(functions: Array, cluster: Node3D, category: String):
	"""Create function spheres within a category cluster"""
	var functions_per_row = int(sqrt(functions_per_cluster))
	var spacing = 2.5
	
	for i in range(min(functions.size(), functions_per_cluster)):
		var function_info = functions[i]
		var row = i / functions_per_row
		var col = i % functions_per_row
		
		var local_pos = Vector3(
			(col - functions_per_row * 0.5) * spacing,
			0,
			(row - functions_per_row * 0.5) * spacing
		)
		
		var function_sphere = create_function_sphere(function_info, local_pos)
		cluster.add_child(function_sphere)
		
		var function_id = function_info.file_path + ":" + function_info.name
		function_spheres[function_id] = function_sphere

func create_function_sphere(function_info: Dictionary, position: Vector3) -> Node3D:
	"""Create visual sphere for a function"""
	var sphere_node = Node3D.new()
	sphere_node.name = "Function_" + function_info.name
	sphere_node.position = position
	
	# Function sphere visual
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = sphere_radius
	mesh.mesh = sphere
	
	var color = _get_function_color(function_info)
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 0.5
	material.emission_energy = 0.6
	mesh.material_override = material
	sphere_node.add_child(mesh)
	
	# Function name label
	var label = Label3D.new()
	label.text = function_info.name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, sphere_radius + 0.5, 0)
	label.modulate = Color.WHITE
	label.pixel_size = 0.008
	sphere_node.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = sphere_radius + 0.2
	collision.shape = shape
	area.add_child(collision)
	sphere_node.add_child(area)
	
	# Connect click event
	area.input_event.connect(_on_function_sphere_clicked.bind(function_info))
	
	# Store function info
	sphere_node.set_meta("function_info", function_info)
	
	return sphere_node

func _get_category_color(category: String) -> Color:
	"""Get color for function category"""
	match category:
		"Pentagon Lifecycle": return Color.GOLD
		"Godot Lifecycle": return Color.CYAN
		"Core Systems": return Color.RED
		"Universal Beings": return Color.GREEN
		"Game Systems": return Color.BLUE
		"Gameplay Scripts": return Color.PURPLE
		"User Interface": return Color.ORANGE
		"Autoloads": return Color.WHITE
		"Getters": return Color(0.5, 1.0, 0.5)
		"Setters": return Color(1.0, 0.5, 0.5)
		"Creators": return Color.YELLOW
		"Updaters": return Color.MAGENTA
		"Handlers": return Color(0.5, 0.5, 1.0)
		"Signal Handlers": return Color(1.0, 1.0, 0.5)
		_: return Color(0.7, 0.7, 0.7)

func _get_function_color(function_info: Dictionary) -> Color:
	"""Get color for specific function based on properties"""
	var base_color = _get_category_color(function_info.category)
	
	# Modify based on visibility
	if function_info.visibility == "private":
		base_color = base_color * 0.6  # Darker for private functions
	
	# Modify based on parameters
	if function_info.parameters.is_empty():
		base_color = base_color * Color(1.2, 1.0, 1.0)  # Slightly red tint for no params
	
	return base_color

func _on_function_sphere_clicked(function_info: Dictionary, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle function sphere clicks"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🔧 Selected function: " + function_info.name)
		show_function_details(function_info)
		function_selected.emit(function_info)

func show_function_details(function_info: Dictionary):
	"""Show detailed information about selected function"""
	var details_position = Vector3(0, 15, 0)
	
	# Create details display
	var details_node = Node3D.new()
	details_node.name = "FunctionDetails"
	details_node.position = details_position
	
	# Details background
	var bg = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(12, 8)
	bg.mesh = plane
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.3, 0.9)
	material.emission_enabled = true
	material.emission = Color.BLUE * 0.3
	material.emission_energy = 0.4
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg.material_override = material
	details_node.add_child(bg)
	
	# Function details text
	var details_text = "🔧 FUNCTION DETAILS:\n\n"
	details_text += "Name: " + function_info.name + "\n"
	details_text += "File: " + function_info.file_name + "\n"
	details_text += "Line: " + str(function_info.line_number) + "\n"
	details_text += "Category: " + function_info.category + "\n"
	details_text += "Visibility: " + function_info.visibility + "\n"
	details_text += "Parameters: " + function_info.parameters + "\n"
	details_text += "Returns: " + function_info.return_type + "\n\n"
	details_text += "Signature:\n" + function_info.full_signature
	
	var details_label = Label3D.new()
	details_label.text = details_text
	details_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	details_label.position = Vector3(0, 0, 0.1)
	details_label.modulate = Color.WHITE
	details_label.pixel_size = 0.01
	details_node.add_child(details_label)
	
	# Remove previous details
	var existing = get_node_or_null("FunctionDetails")
	if existing:
		existing.queue_free()
	
	add_child(details_node)
	
	# Auto-remove after 15 seconds
	var timer = Timer.new()
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(details_node.queue_free)
	add_child(timer)
	timer.start()

func search_functions(query: String) -> Array:
	"""Search functions by name or category"""
	search_results.clear()
	current_filter = query.to_lower()
	
	if query.is_empty():
		# Show all functions
		for file_path in all_functions.keys():
			var functions = all_functions[file_path]
			search_results.append_array(functions)
	else:
		# Filter functions
		for file_path in all_functions.keys():
			var functions = all_functions[file_path]
			for function_info in functions:
				if (function_info.name.to_lower().contains(current_filter) or
					function_info.category.to_lower().contains(current_filter) or
					function_info.file_name.to_lower().contains(current_filter)):
					search_results.append(function_info)
	
	highlight_search_results()
	search_completed.emit(search_results)
	return search_results

func highlight_search_results():
	"""Highlight functions matching search"""
	# Reset all spheres to normal
	for sphere in function_spheres.values():
		if sphere and is_instance_valid(sphere):
			var mesh = sphere.get_child(0) as MeshInstance3D
			if mesh and mesh.material_override:
				var material = mesh.material_override as StandardMaterial3D
				material.emission_energy = 0.6
	
	# Highlight search results
	for function_info in search_results:
		var function_id = function_info.file_path + ":" + function_info.name
		if function_spheres.has(function_id):
			var sphere = function_spheres[function_id]
			var mesh = sphere.get_child(0) as MeshInstance3D
			if mesh and mesh.material_override:
				var material = mesh.material_override as StandardMaterial3D
				material.emission_energy = 2.0  # Bright highlight

func create_navigation_interface():
	"""Create navigation interface for database"""
	var nav_position = Vector3(30, 0, 0)
	
	var nav_title = Label3D.new()
	nav_title.text = "🧭 NAVIGATION"
	nav_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	nav_title.position = nav_position + Vector3(0, 5, 0)
	nav_title.modulate = Color.ORANGE
	nav_title.pixel_size = 0.015
	add_child(nav_title)
	
	var nav_controls = [
		"F - Search functions",
		"R - Reset view",
		"Click - Select function",
		"WASD - Navigate space"
	]
	
	for i in range(nav_controls.size()):
		var control_label = Label3D.new()
		control_label.text = nav_controls[i]
		control_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		control_label.position = nav_position + Vector3(0, 3 - i * 1, 0)
		control_label.modulate = Color.WHITE
		control_label.pixel_size = 0.01
		add_child(control_label)

# Public interface
func get_database_stats() -> Dictionary:
	"""Get database statistics"""
	var total_functions = 0
	for functions in all_functions.values():
		total_functions += functions.size()
	
	return {
		"total_functions": total_functions,
		"total_files": all_functions.size(),
		"categories": function_categories.size(),
		"search_results": search_results.size()
	}
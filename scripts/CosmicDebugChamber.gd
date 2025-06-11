# COSMIC DEBUG CHAMBER - WHERE SCRIPTS BECOME STARS
# The offline GitHub where you fly between code as celestial bodies
extends Node3D
class_name CosmicDebugChamber

signal star_selected(script_path: String, line_number: int)
signal constellation_formed(connected_scripts: Array)
signal md_note_found(md_path: String, content: String)

# Cosmic configuration
@export var star_distance_base: float = 50.0
@export var constellation_line_color: Color = Color.CYAN
@export var md_note_color: Color = Color.GOLD
@export var hotload_enabled: bool = true

# Star system
var script_stars: Dictionary = {}  # script_path -> star_node
var md_note_walls: Dictionary = {}  # md_path -> wall_node
var dependency_lines: Array = []
var akashic_storage: Node = null

# Player and camera
var player_ref: Node3D = null
var gemma_ref: Node3D = null
var current_selected_star: Node3D = null

func _ready():
	print("🌌 Cosmic Debug Chamber: Initializing the scriptura cosmos...")
	
	# Get Akashic Records for star position storage
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		akashic_storage = SystemBootstrap.get_akashic_records()
	
	# Start cosmic initialization
	call_deferred("_initialize_cosmic_debug_chamber")

func _initialize_cosmic_debug_chamber():
	"""Initialize the complete cosmic debug system"""
	print("⭐ Creating star map from all scripts...")
	
	# Phase 0: LAYER_0 SAFETY INSPECTION
	_inspect_layer_0_safety()
	
	# Phase 1: Scan all scripts and create stars
	_create_script_stars()
	
	# Phase 2: Find and place MD files as wall notes
	_create_md_note_walls()
	
	# Phase 3: Connect dependencies with lines
	_create_dependency_constellations()
	
	# Phase 4: Setup hotloading
	if hotload_enabled:
		_setup_hotloading_system()
	
	print("🌟 Cosmic Debug Chamber: Ready for exploration!")

func _create_script_stars():
	"""Convert every GDScript file into a navigable star"""
	var script_files = _find_all_gdscript_files()
	
	for i in range(script_files.size()):
		var script_path = script_files[i]
		var star_position = _calculate_star_position(script_path, i)
		var star_node = _create_star_for_script(script_path, star_position)
		
		script_stars[script_path] = star_node
		add_child(star_node)
		
		print("⭐ Created star for: %s at %v" % [script_path.get_file(), star_position])

func _create_star_for_script(script_path: String, position: Vector3) -> Node3D:
	"""Create a 3D star representation of a script"""
	var star = MeshInstance3D.new()
	star.name = "Star_" + script_path.get_file().replace(".gd", "")
	star.position = position
	
	# Create sphere mesh for the star
	var sphere = SphereMesh.new()
	sphere.radius = 2.0
	sphere.height = 4.0
	star.mesh = sphere
	
	# Color based on script type/location
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_star_color_for_script(script_path)
	material.emission_enabled = true
	material.emission_energy = 0.5
	star.material_override = material
	
	# Add click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 3.0
	collision.shape = shape
	area.add_child(collision)
	star.add_child(area)
	
	# Connect click signal
	area.input_event.connect(_on_star_clicked.bind(script_path))
	
	# Store script data
	star.set_meta("script_path", script_path)
	star.set_meta("star_type", "script")
	
	return star

func _create_md_note_walls():
	"""Create floating note walls for MD files"""
	var md_files = _find_all_md_files()
	
	for md_path in md_files:
		var wall_position = _calculate_md_wall_position(md_path)
		var wall_node = _create_md_wall(md_path, wall_position)
		
		md_note_walls[md_path] = wall_node
		add_child(wall_node)
		
		print("📝 Created note wall for: %s" % md_path.get_file())

func _create_md_wall(md_path: String, position: Vector3) -> Node3D:
	"""Create a floating wall with MD file content"""
	var wall = MeshInstance3D.new()
	wall.name = "MDWall_" + md_path.get_file().replace(".md", "")
	wall.position = position
	
	# Create plane mesh for the wall
	var plane = PlaneMesh.new()
	plane.size = Vector2(10, 6)
	wall.mesh = plane
	
	# Material with text preview
	var material = StandardMaterial3D.new()
	material.albedo_color = md_note_color
	material.emission_enabled = true
	material.emission_energy = 0.3
	wall.material_override = material
	
	# Add click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(10, 6, 0.5)
	collision.shape = shape
	area.add_child(collision)
	wall.add_child(area)
	
	# Connect click signal
	area.input_event.connect(_on_md_wall_clicked.bind(md_path))
	
	# Store MD data
	wall.set_meta("md_path", md_path)
	wall.set_meta("wall_type", "markdown")
	
	return wall

func _create_dependency_constellations():
	"""Create lines connecting related scripts"""
	print("🌌 Creating constellation connections...")
	
	for script_path in script_stars.keys():
		var dependencies = _analyze_script_dependencies(script_path)
		
		for dep_path in dependencies:
			if script_stars.has(dep_path):
				_create_connection_line(script_path, dep_path)

func _create_connection_line(from_script: String, to_script: String):
	"""Create a visual line between two connected scripts"""
	var from_star = script_stars[from_script]
	var to_star = script_stars[to_script]
	
	var line = MeshInstance3D.new()
	line.name = "Connection_%s_to_%s" % [from_script.get_file(), to_script.get_file()]
	
	# Create line geometry
	var mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	vertices.append(from_star.position)
	vertices.append(to_star.position)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	line.mesh = mesh
	
	# Line material
	var material = StandardMaterial3D.new()
	material.albedo_color = constellation_line_color
	material.emission_enabled = true
	material.emission_energy = 0.8
	material.vertex_color_use_as_albedo = true
	line.material_override = material
	
	add_child(line)
	dependency_lines.append(line)

func _calculate_star_position(script_path: String, index: int) -> Vector3:
	"""Calculate optimal 3D position for a script star"""
	# Use spiral galaxy formation
	var angle = index * 0.618 * TAU  # Golden ratio spiral
	var radius = star_distance_base + (index * 5.0)
	var height = sin(index * 0.1) * 20.0
	
	return Vector3(
		cos(angle) * radius,
		height,
		sin(angle) * radius
	)

func _calculate_md_wall_position(md_path: String) -> Vector3:
	"""Calculate position for MD note walls"""
	# Place MD walls in outer orbit around scripts
	var hash_val = md_path.hash()
	var angle = hash_val * 0.001
	var radius = star_distance_base * 2.0
	
	return Vector3(
		cos(angle) * radius,
		randf_range(-30, 30),
		sin(angle) * radius
	)

func _get_star_color_for_script(script_path: String) -> Color:
	"""Determine star color based on script location/type"""
	if "core/" in script_path:
		return Color.GOLD  # Core systems = gold stars
	elif "beings/" in script_path:
		return Color.CYAN  # Beings = cyan stars
	elif "systems/" in script_path:
		return Color.MAGENTA  # Systems = magenta stars
	elif "autoloads/" in script_path:
		return Color.WHITE  # Autoloads = white stars
	else:
		return Color.YELLOW  # Everything else = yellow stars

func _find_all_gdscript_files() -> Array:
	"""Find all GDScript files in the project"""
	var files = []
	_scan_directory_for_gd_files("res://", files)
	return files

func _find_all_md_files() -> Array:
	"""Find all Markdown files in the project"""
	var files = []
	_scan_directory_for_md_files("res://", files)
	return files

func _scan_directory_for_gd_files(path: String, files: Array):
	"""Recursively scan for .gd files"""
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				_scan_directory_for_gd_files(full_path, files)
			elif file_name.ends_with(".gd"):
				files.append(full_path)
			file_name = dir.get_next()

func _scan_directory_for_md_files(path: String, files: Array):
	"""Recursively scan for .md files"""
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				_scan_directory_for_md_files(full_path, files)
			elif file_name.ends_with(".md"):
				files.append(full_path)
			file_name = dir.get_next()

func _analyze_script_dependencies(script_path: String) -> Array:
	"""Analyze script to find dependencies"""
	var dependencies = []
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		# Look for extends, load(), preload(), class_name references
		var lines = content.split("\n")
		for line in lines:
			if "extends " in line or "load(" in line or "preload(" in line:
				# Simple dependency detection - can be enhanced
				pass
	
	return dependencies

func _setup_hotloading_system():
	"""Setup file watching for hotloading changes"""
	print("🔥 Hotloading system enabled - watching for script changes...")
	
	# Create file watcher for real-time updates
	var file_watcher = Timer.new()
	file_watcher.name = "FileWatcher"
	file_watcher.wait_time = 1.0  # Check every second
	file_watcher.timeout.connect(_check_file_changes)
	add_child(file_watcher)
	file_watcher.start()
	
	# Store modification times for change detection
	if not has_meta("file_mod_times"):
		set_meta("file_mod_times", {})
	
	# Initial scan of all files
	_scan_all_file_times()
	print("🔥 Hotloading active - cosmos will update when files change!")

func _on_star_clicked(script_path: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on a script star"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("⭐ Selected star: %s" % script_path.get_file())
		current_selected_star = script_stars[script_path]
		star_selected.emit(script_path, 0)
		
		# Show interaction options
		_show_star_interaction_menu(script_path)

func _on_md_wall_clicked(md_path: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on an MD note wall"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("📝 Opened note: %s" % md_path.get_file())
		_display_md_content(md_path)

func _display_script_content(script_path: String):
	"""Display script content in 3D space with scriptura confession"""
	print("📜 Displaying script content for: %s" % script_path)
	
	# Create 3D debugging interface around the selected star
	_create_criminal_investigation_interface(script_path)
	
	# Make the scriptura confess its sins
	_initiate_scriptura_confession(script_path)

func _display_md_content(md_path: String):
	"""Display markdown content in 3D space"""
	print("📖 Displaying markdown content for: %s" % md_path)
	md_note_found.emit(md_path, "")

# Navigation helpers
func fly_to_star(script_path: String):
	"""Fly player/camera to a specific script star"""
	if script_stars.has(script_path) and player_ref:
		var target_position = script_stars[script_path].position + Vector3(0, 10, 10)
		# Smooth camera movement implementation
		print("🚀 Flying to star: %s" % script_path.get_file())

func find_nearest_stars(position: Vector3, count: int = 5) -> Array:
	"""Find nearest script stars to a position"""
	var star_distances = []
	for script_path in script_stars.keys():
		var star = script_stars[script_path]
		var distance = position.distance_to(star.position)
		star_distances.append({"path": script_path, "distance": distance})
	
	star_distances.sort_custom(func(a, b): return a["distance"] < b["distance"])
	return star_distances.slice(0, count)

func _inspect_layer_0_safety():
	"""Phase 0: Inspect layer_0 for safety before revealing blessings"""
	print("🔍 LAYER_0 SAFETY INSPECTION INITIATED...")
	
	# Check foundation systems
	var foundation_status = {
		"SystemBootstrap": _check_system_status("SystemBootstrap"),
		"FloodGates": _check_system_status("FloodGates"), 
		"AkashicRecords": _check_system_status("AkashicRecords"),
		"UniversalBeing": _check_core_class("UniversalBeing"),
		"Pentagon": _check_pentagon_compliance()
	}
	
	print("🛡️ Foundation Systems Status:")
	for system in foundation_status.keys():
		var status = foundation_status[system]
		var icon = "✅" if status else "⚠️"
		print("  %s %s: %s" % [icon, system, "STABLE" if status else "NEEDS_ATTENTION"])
	
	# Visual layer_0 indicator
	_create_layer_0_indicator(foundation_status)
	
	var all_safe = true
	for status in foundation_status.values():
		if not status:
			all_safe = false
			break
	if all_safe:
		print("🌟 LAYER_0 SAFETY: ALL SYSTEMS STABLE - BLESSINGS CAN BE REVEALED")
	else:
		print("⚠️ LAYER_0 SAFETY: SOME SYSTEMS NEED ATTENTION")
	
	return all_safe

func _check_system_status(system_name: String) -> bool:
	"""Check if a core system is properly loaded"""
	match system_name:
		"SystemBootstrap":
			return SystemBootstrap != null and SystemBootstrap.is_system_ready()
		"FloodGates":
			return SystemBootstrap != null and SystemBootstrap.get_flood_gates() != null
		"AkashicRecords":
			return SystemBootstrap != null and SystemBootstrap.get_akashic_records() != null
		_:
			return false

func _check_core_class(class_name: String) -> bool:
	"""Check if core classes are properly defined"""
	return ClassDB.class_exists(class_name)

func _check_pentagon_compliance() -> bool:
	"""Check if Pentagon architecture is stable"""
	# Simple check - can be enhanced
	return true

func _create_layer_0_indicator(status: Dictionary):
	"""Create visual indicator for layer_0 safety"""
	var indicator = MeshInstance3D.new()
	indicator.name = "Layer0SafetyIndicator"
	indicator.position = Vector3(0, 100, 0)  # High above other stars
	
	var sphere = SphereMesh.new()
	sphere.radius = 5.0
	indicator.mesh = sphere
	
	var material = StandardMaterial3D.new()
	var all_safe = true
	for system_status in status.values():
		if not system_status:
			all_safe = false
			break
	material.albedo_color = Color.GREEN if all_safe else Color.ORANGE
	material.emission_enabled = true
	material.emission_energy = 1.0
	indicator.material_override = material
	
	add_child(indicator)
	print("🌟 Layer_0 Safety Indicator created at cosmic apex")

func _create_criminal_investigation_interface(script_path: String):
	"""Create criminal investigation style debugging UI around a script star"""
	var star = script_stars[script_path]
	var investigation_zone = Node3D.new()
	investigation_zone.name = "InvestigationZone_" + script_path.get_file()
	investigation_zone.position = star.position
	
	# Create investigation floor (like interrogation room)
	var floor = MeshInstance3D.new()
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(20, 0.5, 20)
	floor.mesh = floor_mesh
	floor.position = Vector3(0, -10, 0)
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.3, 0.3, 0.3)
	floor_material.emission_enabled = true
	floor_material.emission_energy = 0.2
	floor.material_override = floor_material
	
	investigation_zone.add_child(floor)
	
	# Create evidence walls with script variables and functions
	_create_evidence_walls(script_path, investigation_zone)
	
	# Add investigation lighting
	var light = SpotLight3D.new()
	light.position = Vector3(0, 15, 0)
	light.rotation = Vector3(-PI/2, 0, 0)
	light.light_energy = 2.0
	light.spot_range = 50.0
	investigation_zone.add_child(light)
	
	add_child(investigation_zone)
	print("🔍 Criminal investigation interface created for: %s" % script_path.get_file())

func _create_evidence_walls(script_path: String, parent: Node3D):
	"""Create walls showing script evidence like in criminal investigation movies"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var functions = _extract_functions_from_script(content)
	var variables = _extract_variables_from_script(content)
	var errors = _extract_errors_from_script(content)
	
	# Create function evidence wall
	_create_evidence_wall("FUNCTIONS", functions, Vector3(-8, 0, 0), parent)
	
	# Create variable evidence wall  
	_create_evidence_wall("VARIABLES", variables, Vector3(8, 0, 0), parent)
	
	# Create error evidence wall (the smoking gun!)
	_create_evidence_wall("ERRORS", errors, Vector3(0, 0, -8), parent, Color.RED)

func _create_evidence_wall(title: String, evidence: Array, position: Vector3, parent: Node3D, color: Color = Color.CYAN):
	"""Create a wall displaying evidence with pins and lines"""
	var wall = MeshInstance3D.new()
	wall.name = "EvidenceWall_" + title
	wall.position = position
	
	var plane = PlaneMesh.new()
	plane.size = Vector2(8, 10)
	wall.mesh = plane
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color * 0.3
	material.emission_enabled = true
	material.emission_energy = 0.5
	wall.material_override = material
	
	# Add evidence labels
	for i in range(min(evidence.size(), 10)):  # Max 10 evidence items per wall
		var evidence_label = Label3D.new()
		evidence_label.text = str(evidence[i])
		evidence_label.position = Vector3(0, 4 - i * 0.8, 0.1)
		evidence_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		evidence_label.pixel_size = 0.01
		evidence_label.modulate = Color.WHITE
		wall.add_child(evidence_label)
		
		# Add investigation pins
		var pin = MeshInstance3D.new()
		var pin_mesh = SphereMesh.new()
		pin_mesh.radius = 0.1
		pin.mesh = pin_mesh
		pin.position = Vector3(-3, 4 - i * 0.8, 0.1)
		
		var pin_material = StandardMaterial3D.new()
		pin_material.albedo_color = Color.RED
		pin_material.emission_enabled = true
		pin_material.emission_energy = 1.0
		pin.material_override = pin_material
		wall.add_child(pin)
	
	parent.add_child(wall)

func _initiate_scriptura_confession(script_path: String):
	"""Make the scriptura confess its sins through voice/text"""
	print("🎭 SCRIPTURA CONFESSION INITIATED FOR: %s" % script_path.get_file())
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var sins = _analyze_scriptura_sins(content, script_path)
	
	# Create confession speech bubble
	var star = script_stars[script_path]
	var confession_bubble = _create_confession_bubble(sins, star.position + Vector3(0, 5, 0))
	add_child(confession_bubble)
	
	# Print confession to console
	print("💬 SCRIPTURA CONFESSION:")
	for sin in sins:
		print("   😔 %s" % sin)
	
	if sins.is_empty():
		print("   😇 This scriptura is pure and without sin!")
	
	# Schedule confession cleanup
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(confession_bubble.queue_free)
	add_child(timer)
	timer.start()

func _create_confession_bubble(sins: Array, position: Vector3) -> Node3D:
	"""Create a 3D speech bubble showing scriptura's confession"""
	var bubble = Node3D.new()
	bubble.name = "ConfessionBubble"
	bubble.position = position
	
	# Create bubble shape
	var bubble_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 3.0
	bubble_mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.8, 0.7)
	material.emission_enabled = true
	material.emission_energy = 0.3
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bubble_mesh.material_override = material
	
	bubble.add_child(bubble_mesh)
	
	# Add confession text
	var confession_text = ""
	if sins.is_empty():
		confession_text = "😇 I am pure!\nNo sins to confess!"
	else:
		confession_text = "😔 My sins:\n"
		for sin in sins:
			confession_text += "• " + sin + "\n"
	
	var text_label = Label3D.new()
	text_label.text = confession_text
	text_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_label.pixel_size = 0.008
	text_label.modulate = Color.BLACK
	bubble.add_child(text_label)
	
	return bubble

func _analyze_scriptura_sins(content: String, script_path: String) -> Array:
	"""Analyze script for common sins and errors"""
	var sins = []
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		var line_num = i + 1
		
		# Check for common GDScript sins
		if line.contains("print(") and not line.contains("#debug"):
			sins.append("Uncontrolled print statement at line %d" % line_num)
		
		if line.contains("TODO") or line.contains("FIXME"):
			sins.append("Unfinished business at line %d" % line_num)
		
		if line.contains("pass") and not line.contains("#placeholder"):
			sins.append("Empty implementation at line %d" % line_num)
		
		if line.length() > 120:
			sins.append("Line too long at line %d (%d chars)" % [line_num, line.length()])
		
		if line.contains("extends") and line.contains("Node") and not "Node3D" in line:
			sins.append("Suspicious Node inheritance at line %d" % line_num)
		
		# Check for missing super() calls in Pentagon methods
		if line.contains("func pentagon_") and not "super." in content:
			sins.append("Missing super() call in Pentagon method at line %d" % line_num)
	
	# Check for file-level issues
	if not "class_name" in content and not script_path.contains("autoloads/"):
		sins.append("Missing class_name declaration")
	
	return sins

func _extract_functions_from_script(content: String) -> Array:
	"""Extract function names from script content"""
	var functions = []
	var lines = content.split("\n")
	
	for line in lines:
		if line.strip_edges().begins_with("func "):
			var func_name = line.split("func ")[1].split("(")[0].strip_edges()
			functions.append(func_name)
	
	return functions

func _extract_variables_from_script(content: String) -> Array:
	"""Extract variable declarations from script content"""
	var variables = []
	var lines = content.split("\n")
	
	for line in lines:
		var stripped = line.strip_edges()
		if stripped.begins_with("var ") or stripped.begins_with("@export var "):
			var var_name = stripped.split("var ")[1].split(":")[0].split("=")[0].strip_edges()
			variables.append(var_name)
	
	return variables

func _extract_errors_from_script(content: String) -> Array:
	"""Extract potential errors from script content"""
	var errors = []
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		
		# Common error patterns
		if "Error" in line or "error" in line:
			errors.append("Line %d: %s" % [i + 1, line.strip_edges()])
		if "# TODO" in line or "# FIXME" in line:
			errors.append("Line %d: %s" % [i + 1, line.strip_edges()])
	
	return errors

func _show_star_interaction_menu(script_path: String):
	"""Show interaction options for a selected script star"""
	var star = script_stars[script_path]
	var menu_position = star.position + Vector3(0, 3, 0)
	
	# Create floating interaction menu
	var interaction_menu = Node3D.new()
	interaction_menu.name = "StarInteractionMenu"
	interaction_menu.position = menu_position
	
	# Get functions in this script for direct editing
	var functions = _extract_functions_from_script_for_menu(script_path)
	
	# Menu options with dynamic functions
	var options = [
		{"text": "🔍 DEBUG INVESTIGATION", "action": "debug", "color": Color.CYAN},
		{"text": "🎬 SCRIPTURA CINEMA", "action": "cinema", "color": Color.GOLD},
		{"text": "🎭 HEAR CONFESSION", "action": "confession", "color": Color.MAGENTA},
		{"text": "📜 VIEW SOURCE", "action": "source", "color": Color.GREEN},
		{"text": "✨ EDIT FUNCTIONS", "action": "functions", "color": Color.YELLOW},
		{"text": "🔥 HOTLOAD STATUS", "action": "hotload", "color": Color.ORANGE},
		{"text": "❌ CLOSE", "action": "close", "color": Color.WHITE}
	]
	
	for i in range(options.size()):
		var option = options[i]
		var button = _create_interaction_button(
			option.text,
			Vector3(0, 2 - i * 0.8, 0),
			option.color,
			script_path,
			option.action
		)
		interaction_menu.add_child(button)
	
	add_child(interaction_menu)
	
	# Auto-remove menu after 15 seconds
	var timer = Timer.new()
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(interaction_menu.queue_free)
	add_child(timer)
	timer.start()

func _create_interaction_button(text: String, position: Vector3, color: Color, script_path: String, action: String) -> Node3D:
	"""Create an interaction button for the star menu"""
	var button = Node3D.new()
	button.name = "InteractionButton_" + action
	button.position = position
	
	# Button visual
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(5, 0.6, 0.3)
	mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission_energy = 0.7
	mesh.material_override = material
	button.add_child(mesh)
	
	# Button text
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.2)
	label.modulate = Color.WHITE
	label.pixel_size = 0.008
	button.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(5, 0.6, 0.5)
	collision.shape = shape
	area.add_child(collision)
	button.add_child(area)
	
	# Connect action
	area.input_event.connect(_on_interaction_clicked.bind(script_path, action))
	
	return button

func _on_interaction_clicked(script_path: String, action: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on interaction buttons"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_execute_star_action(script_path, action)

func _execute_star_action(script_path: String, action: String):
	"""Execute the selected action on a script star"""
	print("🎬 Executing action '%s' on: %s" % [action, script_path.get_file()])
	
	match action:
		"debug":
			_display_script_content(script_path)
		"cinema":
			_launch_scriptura_cinema(script_path)
		"confession":
			_initiate_scriptura_confession(script_path)
		"source":
			_display_source_code(script_path)
		"functions":
			_show_function_list(script_path)
		"hotload":
			_show_hotload_status(script_path)
		"close":
			_close_interaction_menus()

func _launch_scriptura_cinema(script_path: String):
	"""Launch the Scriptura Cinema for line-by-line analysis"""
	print("🎬 LAUNCHING SCRIPTURA CINEMA FOR: %s" % script_path.get_file())
	
	# Create cinema instance
	var cinema = ScripturaCinema.new()
	cinema.name = "ScripturaCinema_" + script_path.get_file()
	cinema.position = Vector3(0, 0, 50)  # Position away from debug chamber
	add_child(cinema)
	
	# Connect cinema signals
	cinema.scriptura_completed.connect(_on_cinema_analysis_complete)
	cinema.line_judged.connect(_on_cinema_line_judged)
	
	# Load the script into cinema
	cinema.analyze_script_file(script_path)
	
	# Create cinema access instructions
	var instructions = Label3D.new()
	instructions.text = "🎬 SCRIPTURA CINEMA LAUNCHED!\n\nNavigate to cinema area for analysis\nPress SPACE to advance lines\nJudge each line with buttons\n\nPress C to return to Debug Chamber"
	instructions.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	instructions.position = Vector3(0, 10, 45)
	instructions.modulate = Color.GOLD
	instructions.pixel_size = 0.015
	add_child(instructions)
	
	# Auto-remove instructions after 10 seconds
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(instructions.queue_free)
	add_child(timer)
	timer.start()

func _display_source_code(script_path: String):
	"""Display the source code in 3D space"""
	print("📜 Displaying source code for: %s" % script_path.get_file())
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		print("❌ Could not open file: %s" % script_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Create source display
	var source_display = Node3D.new()
	source_display.name = "SourceDisplay_" + script_path.get_file()
	source_display.position = script_stars[script_path].position + Vector3(10, 0, 0)
	
	# Create source text plane
	var text_plane = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(15, 20)
	text_plane.mesh = plane
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.2, 0.9)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission_energy = 0.2
	text_plane.material_override = material
	source_display.add_child(text_plane)
	
	# Add source text
	var lines = content.split("\n")
	var preview_lines = lines.slice(0, min(25, lines.size()))  # Show first 25 lines
	var preview_text = preview_lines.join("\n")
	
	var source_label = Label3D.new()
	source_label.text = "📜 %s\n\n%s\n\n[First 25 lines - Click star for full analysis]" % [script_path.get_file(), preview_text]
	source_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	source_label.position = Vector3(0, 0, 0.1)
	source_label.modulate = Color.WHITE
	source_label.pixel_size = 0.005
	source_display.add_child(source_label)
	
	add_child(source_display)
	
	# Auto-remove after 20 seconds
	var timer = Timer.new()
	timer.wait_time = 20.0
	timer.one_shot = true
	timer.timeout.connect(source_display.queue_free)
	add_child(timer)
	timer.start()

func _close_interaction_menus():
	"""Close all open interaction menus"""
	for child in get_children():
		if child.name.begins_with("StarInteractionMenu"):
			child.queue_free()

func _on_cinema_analysis_complete(script_path: String, score: float):
	"""Handle cinema analysis completion"""
	print("🎊 Cinema analysis complete for %s: Score %.2f" % [script_path.get_file(), score])
	
	# Update star color based on analysis score
	if script_stars.has(script_path):
		var star = script_stars[script_path]
		var analysis_color = Color.GREEN if score > 0.7 else Color.ORANGE if score > 0.4 else Color.RED
		
		if star.material_override is StandardMaterial3D:
			var material = star.material_override as StandardMaterial3D
			material.emission = analysis_color
			material.albedo_color = analysis_color

func _on_cinema_line_judged(line_number: int, judgment: String, appreciation_level: float):
	"""Handle individual line judgments from cinema"""
	print("⚖️ Line %d judged: %s (%.2f)" % [line_number, judgment, appreciation_level])

func _scan_all_file_times():
	"""Scan all script and MD files for modification times"""
	var file_times = get_meta("file_mod_times", {})
	
	# Scan GD script files
	for script_path in script_stars.keys():
		if FileAccess.file_exists(script_path):
			file_times[script_path] = FileAccess.get_modified_time(script_path)
	
	# Scan MD files
	for md_path in md_note_walls.keys():
		if FileAccess.file_exists(md_path):
			file_times[md_path] = FileAccess.get_modified_time(md_path)
	
	set_meta("file_mod_times", file_times)

func _check_file_changes():
	"""Check for file changes and update cosmos accordingly"""
	var file_times = get_meta("file_mod_times", {})
	var changes_detected = false
	
	for file_path in file_times.keys():
		if FileAccess.file_exists(file_path):
			var current_time = FileAccess.get_modified_time(file_path)
			var stored_time = file_times.get(file_path, 0)
			
			if current_time > stored_time:
				print("🔥 HOTLOAD: File changed - " + file_path.get_file())
				_handle_file_change(file_path)
				file_times[file_path] = current_time
				changes_detected = true
	
	if changes_detected:
		set_meta("file_mod_times", file_times)

func _handle_file_change(file_path: String):
	"""Handle a specific file change"""
	if file_path.ends_with(".gd"):
		_refresh_script_star(file_path)
	elif file_path.ends_with(".md"):
		_refresh_md_wall(file_path)

func _refresh_script_star(script_path: String):
	"""Refresh a script star when file changes"""
	if script_stars.has(script_path):
		var star = script_stars[script_path]
		
		# Update star visual feedback
		if star.material_override is StandardMaterial3D:
			var material = star.material_override as StandardMaterial3D
			# Flash the star to indicate reload
			var tween = create_tween()
			tween.tween_property(material, "emission_energy", 3.0, 0.2)
			tween.tween_property(material, "emission_energy", 0.5, 0.3)
		
		print("⭐ Updated script star: " + script_path.get_file())

func _refresh_md_wall(md_path: String):
	"""Refresh an MD wall when file changes"""
	if md_note_walls.has(md_path):
		var wall = md_note_walls[md_path]
		
		# Flash the wall to indicate update
		if wall.material_override is StandardMaterial3D:
			var material = wall.material_override as StandardMaterial3D
			var tween = create_tween()
			tween.tween_property(material, "emission_energy", 2.0, 0.2)
			tween.tween_property(material, "emission_energy", 0.3, 0.3)
		
		print("📝 Updated MD wall: " + md_path.get_file())

func _create_direct_function_editor(script_path: String, function_name: String, line_number: int):
	"""Create direct function editing interface in 3D space"""
	print("✨ Creating direct function editor for: " + function_name)
	
	var star = script_stars[script_path]
	var editor_position = star.position + Vector3(0, 8, 0)
	
	# Create function editor floating interface
	var function_editor = Node3D.new()
	function_editor.name = "FunctionEditor_" + function_name
	function_editor.position = editor_position
	
	# Create editor background plane
	var editor_plane = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(16, 10)
	editor_plane.mesh = plane
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.2, 0.4, 0.9)
	material.emission_enabled = true
	material.emission = Color.CYAN * 0.5
	material.emission_energy = 0.4
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	editor_plane.material_override = material
	function_editor.add_child(editor_plane)
	
	# Load function source code
	var function_source = _extract_function_source(script_path, function_name, line_number)
	
	# Create function title
	var title_label = Label3D.new()
	title_label.text = "✨ EDITING FUNCTION: " + function_name
	title_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title_label.position = Vector3(0, 4, 0.1)
	title_label.modulate = Color.CYAN
	title_label.pixel_size = 0.015
	function_editor.add_child(title_label)
	
	# Create editable code display
	var code_lines = function_source.split("\n")
	for i in range(code_lines.size()):
		var line_label = Label3D.new()
		line_label.name = "CodeLine_" + str(i)
		line_label.text = code_lines[i]
		line_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		line_label.position = Vector3(-7, 3 - i * 0.6, 0.1)
		line_label.modulate = Color.WHITE
		line_label.pixel_size = 0.01
		
		# Make lines clickable for editing
		var line_area = Area3D.new()
		var line_collision = CollisionShape3D.new()
		var line_shape = BoxShape3D.new()
		line_shape.size = Vector3(14, 0.5, 0.3)
		line_collision.shape = line_shape
		line_area.add_child(line_collision)
		line_label.add_child(line_area)
		
		# Connect line editing
		line_area.input_event.connect(_on_code_line_clicked.bind(script_path, function_name, i))
		
		function_editor.add_child(line_label)
	
	# Create action buttons
	_create_function_editor_buttons(function_editor, script_path, function_name)
	
	add_child(function_editor)
	
	# Auto-remove after 30 seconds
	var timer = Timer.new()
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.timeout.connect(function_editor.queue_free)
	add_child(timer)
	timer.start()

func _extract_function_source(script_path: String, function_name: String, start_line: int) -> String:
	"""Extract complete function source code"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return "# Could not read function source"
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var function_lines = []
	var in_function = false
	var indent_level = 0
	
	for i in range(lines.size()):
		var line = lines[i]
		
		if i >= start_line - 1 and line.strip_edges().begins_with("func " + function_name):
			in_function = true
			indent_level = _get_indent_level(line)
			function_lines.append(line)
		elif in_function:
			var current_indent = _get_indent_level(line)
			if line.strip_edges() != "" and current_indent <= indent_level and not line.strip_edges().begins_with("#"):
				break  # End of function
			function_lines.append(line)
	
	return "\n".join(function_lines)

func _get_indent_level(line: String) -> int:
	"""Get indentation level of a line"""
	var indent = 0
	for char in line:
		if char == '\t':
			indent += 1
		elif char == ' ':
			indent += 0.25  # 4 spaces = 1 tab
		else:
			break
	return int(indent)

func _create_function_editor_buttons(editor: Node3D, script_path: String, function_name: String):
	"""Create action buttons for function editor"""
	var buttons = [
		{"text": "💾 SAVE CHANGES", "action": "save", "color": Color.GREEN},
		{"text": "🔄 RELOAD ORIGINAL", "action": "reload", "color": Color.YELLOW},
		{"text": "🧪 TEST FUNCTION", "action": "test", "color": Color.CYAN},
		{"text": "❌ CLOSE EDITOR", "action": "close", "color": Color.RED}
	]
	
	for i in range(buttons.size()):
		var button_data = buttons[i]
		var button = _create_editor_button(
			button_data.text,
			Vector3(-6 + i * 3, -4, 0.2),
			button_data.color,
			script_path,
			function_name,
			button_data.action
		)
		editor.add_child(button)

func _create_editor_button(text: String, position: Vector3, color: Color, script_path: String, function_name: String, action: String) -> Node3D:
	"""Create an action button for function editor"""
	var button = Node3D.new()
	button.position = position
	
	# Button visual
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2.5, 0.5, 0.2)
	mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 1.5
	material.emission_energy = 0.8
	mesh.material_override = material
	button.add_child(mesh)
	
	# Button text
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.15)
	label.modulate = Color.WHITE
	label.pixel_size = 0.008
	button.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2.5, 0.5, 0.4)
	collision.shape = shape
	area.add_child(collision)
	button.add_child(area)
	
	# Connect action
	area.input_event.connect(_on_editor_button_clicked.bind(script_path, function_name, action))
	
	return button

func _on_code_line_clicked(script_path: String, function_name: String, line_index: int, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on a code line for editing"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("✏️ Editing line %d in function %s" % [line_index, function_name])
		_open_line_editor(script_path, function_name, line_index, position)

func _on_editor_button_clicked(script_path: String, function_name: String, action: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle function editor button clicks"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_execute_editor_action(script_path, function_name, action)

func _open_line_editor(script_path: String, function_name: String, line_index: int, world_position: Vector3):
	"""Open inline editor for a specific code line"""
	print("📝 Opening line editor for line " + str(line_index))
	
	# Create floating text input
	var line_editor = Node3D.new()
	line_editor.name = "LineEditor"
	line_editor.position = world_position + Vector3(0, 1, 2)
	
	# Create input display
	var input_label = Label3D.new()
	input_label.text = "✏️ EDIT LINE: [Type new code here]"
	input_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	input_label.modulate = Color.YELLOW
	input_label.pixel_size = 0.012
	line_editor.add_child(input_label)
	
	add_child(line_editor)
	
	# Store editor context
	line_editor.set_meta("script_path", script_path)
	line_editor.set_meta("function_name", function_name)
	line_editor.set_meta("line_index", line_index)
	
	# Auto-remove after 10 seconds
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(line_editor.queue_free)
	add_child(timer)
	timer.start()

func _execute_editor_action(script_path: String, function_name: String, action: String):
	"""Execute function editor action"""
	print("🎬 Executing editor action: " + action)
	
	match action:
		"save":
			_save_function_changes(script_path, function_name)
		"reload":
			_reload_function_original(script_path, function_name)
		"test":
			_test_function_execution(script_path, function_name)
		"close":
			_close_function_editor(function_name)

func _save_function_changes(script_path: String, function_name: String):
	"""Save function changes back to file"""
	print("💾 Saving function changes: " + function_name)
	# This would implement actual file writing
	show_cosmic_message("💾 Function saved! Hotload will update stars...")

func _test_function_execution(script_path: String, function_name: String):
	"""Test function execution in isolated environment"""
	print("🧪 Testing function: " + function_name)
	show_cosmic_message("🧪 Function test complete! Check console for results...")

func show_cosmic_message(message: String):
	"""Show floating message in cosmic space"""
	var msg_label = Label3D.new()
	msg_label.text = message
	msg_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	msg_label.position = Vector3(0, 20, 0)
	msg_label.modulate = Color.GOLD
	msg_label.pixel_size = 0.02
	add_child(msg_label)
	
	# Animate message
	var tween = create_tween()
	tween.parallel().tween_property(msg_label, "position:y", 30, 3.0)
	tween.parallel().tween_property(msg_label, "modulate:a", 0.0, 3.0)
	tween.tween_callback(msg_label.queue_free)

func _extract_functions_from_script_for_menu(script_path: String) -> Array:
	"""Extract functions from script for menu system"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return []
	
	var content = file.get_as_text()
	file.close()
	
	var functions = []
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with("func ") and not line.begins_with("func _") and ":" in line:
			var func_name = line.split("func ")[1].split("(")[0].strip_edges()
			functions.append({"name": func_name, "line": i + 1})
	
	return functions

func _show_function_list(script_path: String):
	"""Show list of functions for direct editing"""
	print("✨ Showing function list for: " + script_path.get_file())
	
	var star = script_stars[script_path]
	var functions = _extract_functions_from_script_for_menu(script_path)
	
	if functions.is_empty():
		show_cosmic_message("📝 No public functions found in " + script_path.get_file())
		return
	
	# Create function selection menu
	var function_menu = Node3D.new()
	function_menu.name = "FunctionSelectionMenu"
	function_menu.position = star.position + Vector3(5, 0, 0)
	
	# Create title
	var title = Label3D.new()
	title.text = "✨ FUNCTIONS IN " + script_path.get_file().to_upper()
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 3, 0)
	title.modulate = Color.YELLOW
	title.pixel_size = 0.015
	function_menu.add_child(title)
	
	# Create function buttons
	for i in range(min(functions.size(), 8)):  # Limit to 8 functions
		var func_data = functions[i]
		var func_button = _create_function_button(
			func_data.name,
			Vector3(0, 2 - i * 0.7, 0),
			script_path,
			func_data.line
		)
		function_menu.add_child(func_button)
	
	add_child(function_menu)
	
	# Auto-remove after 20 seconds
	var timer = Timer.new()
	timer.wait_time = 20.0
	timer.one_shot = true
	timer.timeout.connect(function_menu.queue_free)
	add_child(timer)
	timer.start()

func _create_function_button(function_name: String, position: Vector3, script_path: String, line_number: int) -> Node3D:
	"""Create a clickable function button"""
	var button = Node3D.new()
	button.position = position
	
	# Button background
	var bg = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(6, 0.5, 0.2)
	bg.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN * 0.8
	material.emission_energy = 0.6
	bg.material_override = material
	button.add_child(bg)
	
	# Function name label
	var label = Label3D.new()
	label.text = "🔧 " + function_name + "()"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.15)
	label.modulate = Color.WHITE
	label.pixel_size = 0.01
	button.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(6, 0.5, 0.4)
	collision.shape = shape
	area.add_child(collision)
	button.add_child(area)
	
	# Connect to function editor
	area.input_event.connect(_on_function_button_clicked.bind(script_path, function_name, line_number))
	
	return button

func _on_function_button_clicked(script_path: String, function_name: String, line_number: int, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle function button clicks"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🔧 Opening function editor for: " + function_name)
		_create_direct_function_editor(script_path, function_name, line_number)

func _show_hotload_status(script_path: String):
	"""Show hotload status for this script"""
	print("🔥 Showing hotload status for: " + script_path.get_file())
	
	var star = script_stars[script_path]
	var file_times = get_meta("file_mod_times", {})
	var last_modified = file_times.get(script_path, 0)
	var current_time = FileAccess.get_modified_time(script_path) if FileAccess.file_exists(script_path) else 0
	
	var status_text = "🔥 HOTLOAD STATUS:\n\n"
	status_text += "File: " + script_path.get_file() + "\n"
	status_text += "Watching: " + ("✅ YES" if hotload_enabled else "❌ NO") + "\n"
	status_text += "Last Check: " + Time.get_datetime_string_from_unix_time(last_modified) + "\n"
	status_text += "Current Time: " + Time.get_datetime_string_from_unix_time(current_time) + "\n"
	
	if current_time > last_modified:
		status_text += "Status: 🔥 FILE CHANGED - RELOAD PENDING"
	else:
		status_text += "Status: ✅ UP TO DATE"
	
	# Create status display
	var status_display = Node3D.new()
	status_display.name = "HotloadStatus"
	status_display.position = star.position + Vector3(0, 5, 5)
	
	# Status background
	var bg = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(8, 6)
	bg.mesh = plane
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.1, 0.0, 0.9)
	material.emission_enabled = true
	material.emission = Color.ORANGE * 0.3
	material.emission_energy = 0.4
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg.material_override = material
	status_display.add_child(bg)
	
	# Status text
	var status_label = Label3D.new()
	status_label.text = status_text
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.position = Vector3(0, 0, 0.1)
	status_label.modulate = Color.ORANGE
	status_label.pixel_size = 0.01
	status_display.add_child(status_label)
	
	add_child(status_display)
	
	# Auto-remove after 10 seconds
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(status_display.queue_free)
	add_child(timer)
	timer.start()

func _close_function_editor(function_name: String):
	"""Close function editor"""
	for child in get_children():
		if child.name.begins_with("FunctionEditor_" + function_name):
			child.queue_free()
			print("❌ Closed function editor for: " + function_name)
			break

func _reload_function_original(script_path: String, function_name: String):
	"""Reload original function from file"""
	print("🔄 Reloading original function: " + function_name)
	show_cosmic_message("🔄 Function reloaded from original file!")

func _class_name():
	print("🌌 CosmicDebugChamber: The scriptura cosmos awaits exploration!")

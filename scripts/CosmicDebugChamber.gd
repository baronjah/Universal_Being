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
	# File watching implementation would go here

func _on_star_clicked(script_path: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on a script star"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("⭐ Selected star: %s" % script_path.get_file())
		current_selected_star = script_stars[script_path]
		star_selected.emit(script_path, 0)
		
		# Load script content for display
		_display_script_content(script_path)

func _on_md_wall_clicked(md_path: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on an MD note wall"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("📝 Opened note: %s" % md_path.get_file())
		_display_md_content(md_path)

func _display_script_content(script_path: String):
	"""Display script content in 3D space"""
	print("📜 Displaying script content for: %s" % script_path)
	# Implementation for 3D text display

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
	
	star_distances.sort_custom(func(a, b): return a.distance < b.distance)
	return star_distances.slice(0, count)

func _class_name():
	print("🌌 CosmicDebugChamber: The scriptura cosmos awaits exploration!")
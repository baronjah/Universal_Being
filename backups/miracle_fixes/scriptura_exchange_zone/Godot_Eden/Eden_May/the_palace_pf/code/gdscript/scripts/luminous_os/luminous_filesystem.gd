extends Node3D
class_name LuminousFileSystem

# Signals
signal filesystem_loaded
signal star_selected(directory_path)
signal file_selected(file_path, file_type)
signal navigation_changed(current_path)

# Constants
const FILE_TYPES = {
	"SCRIPT": [".gd", ".cs", ".gdshader"],
	"SCENE": [".tscn", ".scn"],
	"TEXTURE": [".png", ".jpg", ".jpeg", ".webp"],
	"MODEL": [".glb", ".obj", ".fbx"],
	"AUDIO": [".wav", ".mp3", ".ogg"],
	"TEXT": [".txt", ".md", ".json", ".cfg"],
	"MISC": [".import", ".tres", ".res", ".material"]
}

# The root filesystem path to visualize
var root_path: String = "/"
var current_path: String = "/"
var navigation_history: Array = []

# Visual representation
var star_scene: PackedScene
var planet_scene: PackedScene
var asteroid_scene: PackedScene
var star_scale_factor: float = 1.0
var planet_scale_factor: float = 0.5
var file_scale_factor: float = 0.2

# Celestial body references
var stars: Dictionary = {}  # Directory path -> Star node
var planets: Dictionary = {}  # File path -> Planet node

# Animation properties
var rotation_speeds: Dictionary = {}
var orbit_speeds: Dictionary = {}
var pulse_rates: Dictionary = {}

# FileSystem cache
var fs_cache: Dictionary = {}
var last_refresh_time: int = 0
var cache_validity_duration: int = 5000  # ms

func _ready():
	# Load the scenes for celestial bodies
	star_scene = preload("res://scenes/Star.tscn") 
	planet_scene = preload("res://scenes/Planet.tscn")
	asteroid_scene = preload("res://scenes/CelestialAsteroid.tscn")
	
	# Set the root path to the project directory if not specified
	if root_path == "/":
		root_path = OS.get_executable_path().get_base_dir()
		current_path = root_path
	
	# Initialize the filesystem visualization
	refresh_filesystem()
	
func _process(delta):
	# Update animations for celestial bodies
	animate_celestial_bodies(delta)

func refresh_filesystem():
	# Clear existing celestial bodies
	clear_celestial_bodies()
	
	# Scan the filesystem
	var fs_data = scan_directory(current_path)
	
	# Create stars (directories) and planets (files)
	create_celestial_bodies(fs_data)
	
	# Emit signal that filesystem has been loaded
	emit_signal("filesystem_loaded")
	emit_signal("navigation_changed", current_path)

func scan_directory(path: String, max_depth: int = 1, current_depth: int = 0) -> Dictionary:
	# Check if we have a cached result that's still valid
	var current_time = Time.get_ticks_msec()
	if fs_cache.has(path) and (current_time - last_refresh_time) < cache_validity_duration:
		return fs_cache[path]
	
	var result = {
		"path": path,
		"name": path.get_file() if path.get_file() != "" else path,
		"directories": [],
		"files": []
	}
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = path.path_join(file_name)
				
				if dir.current_is_dir():
					result["directories"].append({
						"path": full_path,
						"name": file_name
					})
					
					# Recursively scan subdirectories up to max_depth
					if current_depth < max_depth:
						var subdir_data = scan_directory(full_path, max_depth, current_depth + 1)
						# Store in cache
						fs_cache[full_path] = subdir_data
				else:
					var file_extension = "." + file_name.get_extension().to_lower()
					var file_type = "MISC"
					
					for type in FILE_TYPES:
						if FILE_TYPES[type].has(file_extension):
							file_type = type
							break
					
					result["files"].append({
						"path": full_path,
						"name": file_name,
						"type": file_type,
						"extension": file_extension
					})
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	# Cache the result
	fs_cache[path] = result
	last_refresh_time = current_time
	
	return result

func create_celestial_bodies(fs_data: Dictionary):
	# Create the central star for current directory
	var central_star = create_star(fs_data["path"], fs_data["name"], Vector3.ZERO, 1.5 * star_scale_factor)
	stars[fs_data["path"]] = central_star
	
	# Create stars for directories in a circular formation
	var dir_count = fs_data["directories"].size()
	var radius = 15.0
	
	for i in range(dir_count):
		var dir_data = fs_data["directories"][i]
		var angle = (2.0 * PI * i) / dir_count
		var position = Vector3(
			radius * cos(angle),
			0,
			radius * sin(angle)
		)
		
		var star = create_star(dir_data["path"], dir_data["name"], position, star_scale_factor)
		stars[dir_data["path"]] = star
		
		# Set random rotation speed
		rotation_speeds[star] = Vector3(
			randf_range(-0.1, 0.1),
			randf_range(0.05, 0.2),
			randf_range(-0.1, 0.1)
		)
	
	# Create planets for files in orbits around the central star
	var file_count = fs_data["files"].size()
	var min_orbit = 3.0
	var max_orbit = 8.0
	
	for i in range(file_count):
		var file_data = fs_data["files"][i]
		var orbit_radius = min_orbit + (max_orbit - min_orbit) * (float(i) / max(1, file_count - 1))
		var angle = (2.0 * PI * i) / file_count
		var position = Vector3(
			orbit_radius * cos(angle),
			randf_range(-1.0, 1.0),  # Slight elevation variation
			orbit_radius * sin(angle)
		)
		
		var planet = create_planet(file_data["path"], file_data["name"], file_data["type"], position, planet_scale_factor)
		planets[file_data["path"]] = planet
		
		# Set orbit data
		orbit_speeds[planet] = randf_range(0.1, 0.5)
		orbit_speeds[planet] *= -1 if randf() > 0.5 else 1  # Random direction
		
		# Set pulse rate based on file type
		var pulse_rate = 0.0
		match file_data["type"]:
			"SCRIPT": pulse_rate = 0.8
			"SCENE": pulse_rate = 0.6
			"TEXTURE": pulse_rate = 0.4
			"MODEL": pulse_rate = 0.5
			"AUDIO": pulse_rate = 1.0
			"TEXT": pulse_rate = 0.3
			_: pulse_rate = 0.2
		
		pulse_rates[planet] = pulse_rate

func create_star(path: String, name: String, position: Vector3, scale_factor: float = 1.0) -> Node3D:
	var star_instance = star_scene.instantiate()
	add_child(star_instance)
	
	star_instance.position = position
	star_instance.scale = Vector3.ONE * scale_factor
	star_instance.name = "Star_" + name.replace(" ", "_").replace(".", "_")
	
	# Set star color based on contents of directory
	var star_color = determine_star_color(path)
	if star_instance.has_node("MeshInstance"):
		var mesh_instance = star_instance.get_node("MeshInstance")
		var material = mesh_instance.get_active_material(0)
		if material:
			material.set_shader_parameter("color", star_color)
	
	# Make star interactive
	var area = Area3D.new()
	area.name = "SelectionArea"
	star_instance.add_child(area)
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.0
	collision_shape.shape = sphere_shape
	area.add_child(collision_shape)
	
	# Connect signals
	area.input_event.connect(_on_star_input_event.bind(path))
	
	return star_instance

func create_planet(path: String, name: String, file_type: String, position: Vector3, scale_factor: float = 1.0) -> Node3D:
	var planet_instance = planet_scene.instantiate()
	add_child(planet_instance)
	
	planet_instance.position = position
	planet_instance.scale = Vector3.ONE * scale_factor
	planet_instance.name = "Planet_" + name.replace(" ", "_").replace(".", "_")
	
	# Set planet appearance based on file type
	configure_planet_by_file_type(planet_instance, file_type)
	
	# Make planet interactive
	var area = Area3D.new()
	area.name = "SelectionArea"
	planet_instance.add_child(area)
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.0
	collision_shape.shape = sphere_shape
	area.add_child(collision_shape)
	
	# Connect signals
	area.input_event.connect(_on_file_input_event.bind(path, file_type))
	
	return planet_instance

func determine_star_color(directory_path: String) -> Color:
	# Count file types to determine star color
	var script_count = 0
	var scene_count = 0
	var texture_count = 0
	var model_count = 0
	var audio_count = 0
	var text_count = 0
	
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != ".." and not dir.current_is_dir():
				var extension = "." + file_name.get_extension().to_lower()
				
				if FILE_TYPES["SCRIPT"].has(extension):
					script_count += 1
				elif FILE_TYPES["SCENE"].has(extension):
					scene_count += 1
				elif FILE_TYPES["TEXTURE"].has(extension):
					texture_count += 1
				elif FILE_TYPES["MODEL"].has(extension):
					model_count += 1
				elif FILE_TYPES["AUDIO"].has(extension):
					audio_count += 1
				elif FILE_TYPES["TEXT"].has(extension):
					text_count += 1
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	# Base color on dominant file type
	var counts = [
		{"type": "SCRIPT", "count": script_count, "color": Color(0.2, 0.6, 1.0)},  # Blue
		{"type": "SCENE", "count": scene_count, "color": Color(0.8, 0.4, 1.0)},   # Purple
		{"type": "TEXTURE", "count": texture_count, "color": Color(0.2, 0.8, 0.4)}, # Green
		{"type": "MODEL", "count": model_count, "color": Color(0.8, 0.8, 0.2)},    # Yellow
		{"type": "AUDIO", "count": audio_count, "color": Color(1.0, 0.4, 0.4)},    # Red
		{"type": "TEXT", "count": text_count, "color": Color(0.6, 0.6, 0.6)}      # Gray
	]
	
	# Sort by count
	counts.sort_custom(func(a, b): return a["count"] > b["count"])
	
	# If no files, use default color
	if counts[0]["count"] == 0:
		return Color(1.0, 1.0, 1.0)  # White
	
	# Return color of dominant file type
	return counts[0]["color"]

func configure_planet_by_file_type(planet: Node3D, file_type: String):
	var mesh_instance = planet.get_node_or_null("MeshInstance")
	if not mesh_instance:
		return
		
	var material = mesh_instance.get_active_material(0)
	if not material:
		return
	
	# Set color based on file type
	var color = Color.WHITE
	match file_type:
		"SCRIPT": color = Color(0.2, 0.6, 1.0)  # Blue
		"SCENE": color = Color(0.8, 0.4, 1.0)   # Purple
		"TEXTURE": color = Color(0.2, 0.8, 0.4) # Green
		"MODEL": color = Color(0.8, 0.8, 0.2)   # Yellow
		"AUDIO": color = Color(1.0, 0.4, 0.4)   # Red
		"TEXT": color = Color(0.6, 0.6, 0.6)    # Gray
		_: color = Color(0.5, 0.5, 0.5)         # Gray for misc
	
	material.set_shader_parameter("color", color)

func animate_celestial_bodies(delta: float):
	# Animate stars (rotation)
	for star_path in stars:
		var star = stars[star_path]
		if rotation_speeds.has(star):
			star.rotate_x(rotation_speeds[star].x * delta)
			star.rotate_y(rotation_speeds[star].y * delta)
			star.rotate_z(rotation_speeds[star].z * delta)
	
	# Animate planets (orbit around central star)
	for file_path in planets:
		var planet = planets[file_path]
		if orbit_speeds.has(planet):
			# Orbit around Y axis
			var orbit_center = Vector3.ZERO
			var current_pos = planet.position
			var distance = Vector2(current_pos.x, current_pos.z).length()
			
			var angle = orbit_speeds[planet] * delta
			var sin_angle = sin(angle)
			var cos_angle = cos(angle)
			
			planet.position.x = current_pos.x * cos_angle - current_pos.z * sin_angle
			planet.position.z = current_pos.x * sin_angle + current_pos.z * cos_angle
			
			# Pulse effect based on file type
			if pulse_rates.has(planet):
				var time_factor = Time.get_ticks_msec() / 1000.0
				var pulse = sin(time_factor * pulse_rates[planet]) * 0.1 + 1.0
				planet.scale = Vector3.ONE * planet_scale_factor * pulse

func clear_celestial_bodies():
	# Remove all star and planet instances
	for star_path in stars:
		if is_instance_valid(stars[star_path]):
			stars[star_path].queue_free()
	
	for file_path in planets:
		if is_instance_valid(planets[file_path]):
			planets[file_path].queue_free()
	
	stars.clear()
	planets.clear()
	rotation_speeds.clear()
	orbit_speeds.clear()
	pulse_rates.clear()

func navigate_to(path: String):
	if DirAccess.dir_exists_absolute(path):
		navigation_history.append(current_path)
		current_path = path
		refresh_filesystem()

func navigate_back():
	if navigation_history.size() > 0:
		current_path = navigation_history.pop_back()
		refresh_filesystem()

func _on_star_input_event(_camera, event, _click_position, _click_normal, _shape_idx, directory_path):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("star_selected", directory_path)
		navigate_to(directory_path)

func _on_file_input_event(_camera, event, _click_position, _click_normal, _shape_idx, file_path, file_type):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("file_selected", file_path, file_type)
		open_file(file_path, file_type)

func open_file(file_path: String, file_type: String):
	# Handle different file types
	match file_type:
		"SCRIPT":
			# Open in script editor
			pass
		"SCENE":
			# Preview scene
			pass
		"TEXTURE":
			# Show texture preview
			pass
		"MODEL":
			# Show model preview
			pass
		"AUDIO":
			# Play audio
			pass
		"TEXT":
			# Show text content
			pass
		_:
			# Generic file handling
			pass
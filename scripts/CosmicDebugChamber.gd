extends Node3D
class_name CosmicDebugChamber

# COSMIC DEBUG CHAMBER - WHERE YOU AND GEMMA SEE ALL SCRIPTS AS STARS
# Perfect GDScript - no lies, no broken syntax

var script_stars: Dictionary = {}
var player_camera: Camera3D = null
var environment_setup: bool = false

func _ready():
	print("🌌 Cosmic Debug Chamber: Loading scriptura cosmos...")
	_setup_cosmic_environment()
	_create_all_script_stars()
	print("✨ Cosmic Debug Chamber: Ready! You can see all scripts as stars!")

func _setup_cosmic_environment():
	"""Setup the 3D cosmic environment you can navigate"""
	# Create space environment
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.02, 0.15)  # Deep space
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.2, 0.3, 0.6)
	environment.ambient_light_energy = 0.4
	world_env.environment = environment
	add_child(world_env)
	
	# Find or create camera for player
	player_camera = get_viewport().get_camera_3d()
	if not player_camera:
		player_camera = Camera3D.new()
		player_camera.name = "CosmicCamera"
		player_camera.position = Vector3(0, 10, 20)
		add_child(player_camera)
		player_camera.current = true
	
	environment_setup = true

func _create_all_script_stars():
	"""Create stars for all GDScript files so you can see them"""
	var script_files = _find_all_scripts()
	print("📜 Found %d scripts to convert to stars" % script_files.size())
	
	for i in range(script_files.size()):
		var script_path = script_files[i]
		var star_position = _calculate_star_position(i, script_files.size())
		var star = _create_script_star(script_path, star_position)
		script_stars[script_path] = star
		add_child(star)

func _find_all_scripts() -> Array:
	"""Find all GDScript files in the project"""
	var scripts = []
	_scan_directory_for_scripts("res://", scripts)
	return scripts

func _scan_directory_for_scripts(path: String, scripts: Array):
	"""Recursively scan directories for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_for_scripts(full_path, scripts)
		elif file_name.ends_with(".gd"):
			scripts.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _calculate_star_position(index: int, total: int) -> Vector3:
	"""Calculate position for script star in 3D space"""
	var radius = 30.0 + (index % 3) * 15.0
	var angle = (index * 2.4) # Golden angle for nice distribution
	var height = sin(index * 0.5) * 20.0
	
	var x = cos(angle) * radius
	var z = sin(angle) * radius
	var y = height
	
	return Vector3(x, y, z)

func _create_script_star(script_path: String, position: Vector3) -> Node3D:
	"""Create a visible star for a script file"""
	var star = Node3D.new()
	star.name = "Star_" + script_path.get_file().replace(".gd", "")
	star.position = position
	
	# Create glowing sphere
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.5
	mesh_instance.mesh = sphere
	
	# Make it glow with color based on script type
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_script_color(script_path)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.8
	material.emission_energy = 1.0
	mesh_instance.material_override = material
	
	star.add_child(mesh_instance)
	
	# Add script name label
	var label = Label3D.new()
	label.text = script_path.get_file().replace(".gd", "")
	label.position = Vector3(0, 2.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 16
	label.modulate = Color.WHITE
	star.add_child(label)
	
	# Store script path in metadata
	star.set_meta("script_path", script_path)
	
	return star

func _get_script_color(script_path: String) -> Color:
	"""Get color for script based on its location/type"""
	if "core/" in script_path:
		return Color.GOLD
	elif "autoloads/" in script_path:
		return Color.CYAN
	elif "systems/" in script_path:
		return Color.GREEN
	elif "beings/" in script_path:
		return Color.MAGENTA
	elif "scenes/" in script_path:
		return Color.ORANGE
	else:
		return Color.WHITE

func get_script_at_position(world_position: Vector3, max_distance: float = 5.0) -> String:
	"""Get script path of star near world position (for crosshair targeting)"""
	for star in script_stars.values():
		if star.global_position.distance_to(world_position) < max_distance:
			return star.get_meta("script_path", "")
	return ""

func focus_on_script(script_path: String):
	"""Move camera to focus on a specific script star"""
	if script_path in script_stars:
		var star = script_stars[script_path]
		if player_camera:
			var target_pos = star.global_position + Vector3(0, 5, 10)
			var tween = get_tree().create_tween()
			tween.tween_property(player_camera, "global_position", target_pos, 1.0)
			tween.tween_callback(func(): player_camera.look_at(star.global_position, Vector3.UP))
			print("🎯 Focusing on script: %s" % script_path.get_file())

func get_all_script_paths() -> Array:
	"""Get all script paths for Gemma to analyze"""
	return script_stars.keys()
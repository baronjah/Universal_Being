# ==================================================
# MAIN UNIVERSE - The Entry Point to All Reality
# PURPOSE: Main scene that initializes the game
# LOCATION: core/scenes/Universe.gd
# ==================================================

extends Node3D

## UI References
var universe_console: UniverseConsole
var command_console: UniversalConsole

## Camera
var camera: Camera3D
var camera_pivot: Node3D

func _ready() -> void:
	# Setup camera
	_setup_camera()
	
	# Setup UI
	_setup_ui()
	
	# Log the beginning
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_genesis(
			"And the Universal Being opened its eyes upon the Prime Universe"
		)
	
	# Register this scene with universe manager
	if has_node("/root/UniverseManager"):
		var universe_manager = get_node("/root/UniverseManager")
		if universe_manager.active_universe:
			universe_manager.active_universe.scene_root = self

func _setup_camera() -> void:
	"""Setup the observer's eye"""
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	
	camera = Camera3D.new()
	camera.name = "ObserverEye"
	camera.position = Vector3(0, 5, 10)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera_pivot.add_child(camera)
	
	# Add some ambient light
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.2, 0.3)
	env.ambient_light_energy = 0.3
	
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	# Add a directional light
	var sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, -45, 0)
	sun.light_energy = 0.8
	add_child(sun)

func _setup_ui() -> void:
	"""Setup user interfaces"""
	# Create universe console
	universe_console = preload("res://core/systems/UniverseConsole.gd").new()
	universe_console.name = "UniverseConsole"
	universe_console.visible = false
	add_child(universe_console)
	
	# Get reference to command console if it exists
	if has_node("/root/UniversalConsole"):
		command_console = get_node("/root/UniversalConsole")

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if event.is_action_pressed("toggle_console"):
		# Toggle command console
		if command_console:
			command_console.toggle_console()
	
	if event.is_action_pressed("ui_f1"):
		# Toggle universe console
		universe_console.toggle_console()
	
	# Camera controls
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera_pivot.rotate_y(-event.relative.x * 0.01)
		camera.rotate_x(-event.relative.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _process(delta: float) -> void:
	"""Process frame updates"""
	# Camera movement
	var input_vector = Vector3()
	
	if Input.is_action_pressed("ui_up"):
		input_vector.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.z += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		var movement = camera_pivot.transform.basis * input_vector
		camera_pivot.position += movement * 10.0 * delta
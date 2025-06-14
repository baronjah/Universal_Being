extends Node3D
class_name LuminousOSController

# Signals
signal command_executed(command, result)
signal reality_changed(new_reality)
signal file_opened(file_path, file_type)

# Core components
var filesystem: LuminousFileSystem
var camera_controller: Node3D
var ui_controller: Control
var command_processor: Node

# Reality states (inspired by TempleOS's divine inspiration concept)
enum Reality {PHYSICAL, DIGITAL, DIVINE}
var current_reality: Reality = Reality.PHYSICAL

# Navigation and state
var current_path: String = "/"
var command_history: Array = []
var clipboard: Dictionary = {}

# Visual settings
var background_color: Color = Color(0.0, 0.0, 0.1, 1.0)
var divine_mode_color: Color = Color(0.1, 0.0, 0.2, 1.0)
var star_brightness: float = 1.0
var animation_speed: float = 1.0

# Temple-inspired elements
var divine_messages: Array = [
	"Create with divine purpose.",
	"The code forms the cosmos.",
	"Files are stars in your universe.",
	"Bring order to the digital chaos.",
	"In Luminous OS, creation is divine.",
	"Your directory tree branches into infinity.",
	"The cursor is your divine wand.",
	"Stars of knowledge illuminate your path.",
	"Your files orbit the central truth.",
	"Through code, we create our reality."
]

# Animation and effect nodes
var sky_environment: WorldEnvironment
var background_stars: GPUParticles3D
var divine_particles: GPUParticles3D
var ambient_audio: AudioStreamPlayer

func _ready():
	# Initialize the filesystem visualization
	filesystem = $LuminousFileSystem
	camera_controller = $CameraController
	ui_controller = $CanvasLayer/UIController
	command_processor = $CommandProcessor
	sky_environment = $WorldEnvironment
	background_stars = $BackgroundStars
	divine_particles = $DivineParticles
	ambient_audio = $AmbientAudio
	
	# Connect signals
	filesystem.filesystem_loaded.connect(_on_filesystem_loaded)
	filesystem.star_selected.connect(_on_star_selected)
	filesystem.file_selected.connect(_on_file_selected)
	filesystem.navigation_changed.connect(_on_navigation_changed)
	
	# Initialize UI
	ui_controller.set_path_display(current_path)
	
	# Set initial visual state
	_update_visual_state()
	
	# Start with a welcome message
	show_divine_message(divine_messages[randi() % divine_messages.size()])

func _process(delta):
	# Update animations and effects
	_update_animations(delta)
	
	# Process automatic events like divine inspiration in divine reality
	if current_reality == Reality.DIVINE and randf() < 0.001:
		show_divine_message(divine_messages[randi() % divine_messages.size()])

func execute_command(command: String) -> String:
	# Add to command history
	command_history.append(command)
	
	# Process the command
	var result = command_processor.process_command(command)
	
	# Handle special commands
	if command.begins_with("cd "):
		var target_dir = command.substr(3).strip_edges()
		navigate_to_directory(target_dir)
	elif command == "divine":
		toggle_divine_reality()
	elif command == "ls" or command == "dir":
		refresh_filesystem()
	
	emit_signal("command_executed", command, result)
	return result

func navigate_to_directory(path: String):
	if path == "..":
		filesystem.navigate_back()
	else:
		var full_path = current_path.path_join(path) if not path.begins_with("/") else path
		filesystem.navigate_to(full_path)

func toggle_divine_reality():
	if current_reality == Reality.DIVINE:
		current_reality = Reality.PHYSICAL
	else:
		current_reality = Reality.DIVINE
	
	_update_visual_state()
	emit_signal("reality_changed", current_reality)

func refresh_filesystem():
	filesystem.refresh_filesystem()

func show_divine_message(message: String):
	ui_controller.show_divine_message(message)

func open_file(file_path: String, file_type: String):
	# Handle file opening based on type
	ui_controller.show_file_preview(file_path, file_type)
	emit_signal("file_opened", file_path, file_type)

# Signal handlers
func _on_filesystem_loaded():
	ui_controller.update_directory_contents(filesystem.scan_directory(current_path))

func _on_star_selected(directory_path: String):
	current_path = directory_path
	ui_controller.set_path_display(current_path)

func _on_file_selected(file_path: String, file_type: String):
	open_file(file_path, file_type)

func _on_navigation_changed(new_path: String):
	current_path = new_path
	ui_controller.set_path_display(current_path)

# Visual updates
func _update_visual_state():
	# Update environment based on current reality
	var env_color = divine_mode_color if current_reality == Reality.DIVINE else background_color
	sky_environment.environment.background_color = env_color
	
	# Update star brightness
	filesystem.star_scale_factor = 1.2 if current_reality == Reality.DIVINE else 1.0
	
	# Show/hide divine particles
	divine_particles.emitting = (current_reality == Reality.DIVINE)
	
	# Change ambient audio
	if current_reality == Reality.DIVINE:
		ambient_audio.pitch_scale = 0.8
		ambient_audio.volume_db = -10
	else:
		ambient_audio.pitch_scale = 1.0
		ambient_audio.volume_db = -20

func _update_animations(delta):
	# Background star field rotation
	background_stars.rotation.y += delta * 0.02 * animation_speed
	
	# In divine reality, add subtle camera movement
	if current_reality == Reality.DIVINE:
		var time = Time.get_ticks_msec() / 1000.0
		camera_controller.position.y = sin(time * 0.2) * 0.3
		camera_controller.rotation.z = sin(time * 0.1) * 0.02
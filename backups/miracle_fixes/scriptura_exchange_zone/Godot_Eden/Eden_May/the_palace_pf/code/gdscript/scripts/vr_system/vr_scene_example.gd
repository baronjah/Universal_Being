extends Node3D

# This example script shows how to set up the Eden VR integration in a scene

# Node references
var vr_scene_setup: VRSceneSetup
var ui_control: Control

# Configuration
@export var auto_initialize_vr: bool = true
@export var show_debug_ui: bool = true
@export var enable_passthrough: bool = false

# Called when the node enters the scene tree for the first time
func _ready():
	print("VR Scene Example initializing...")
	
	# Create VR setup
	if auto_initialize_vr:
		setup_vr()
	
	# Create debug UI if needed
	if show_debug_ui:
		create_debug_ui()

# Set up the VR environment
func setup_vr():
	# Create VR scene setup node
	vr_scene_setup = VRSceneSetup.new()
	vr_scene_setup.name = "VRSceneSetup"
	add_child(vr_scene_setup)
	
	# Setup passthrough if enabled
	if enable_passthrough:
		setup_passthrough()
	
	print("VR Scene setup created")

# Set up VR passthrough for Quest
func setup_passthrough():
	# Get VR interface
	var vr_interface = XRServer.find_interface("OpenXR")
	if vr_interface and vr_interface.is_initialized():
		# Check if passthrough is supported
		if vr_interface.is_passthrough_supported():
			# Enable passthrough
			vr_interface.start_passthrough()
			print("VR Passthrough enabled")
		else:
			print("VR Passthrough not supported on this device")

# Create debug UI overlay
func create_debug_ui():
	# Create Canvas Layer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Top layer
	add_child(canvas_layer)
	
	# Create main UI control
	ui_control = Control.new()
	ui_control.anchors_preset = Control.PRESET_FULL_RECT
	canvas_layer.add_child(ui_control)
	
	# Add VR status panel
	var panel = Panel.new()
	panel.size = Vector2(300, 150)
	panel.position = Vector2(20, 20)
	ui_control.add_child(panel)
	
	# Add title label
	var title_label = Label.new()
	title_label.text = "VR Status"
	title_label.position = Vector2(10, 10)
	panel.add_child(title_label)
	
	# Add status labels
	var vr_status_label = Label.new()
	vr_status_label.name = "VRStatusLabel"
	vr_status_label.text = "VR: Initializing..."
	vr_status_label.position = Vector2(10, 40)
	panel.add_child(vr_status_label)
	
	var scale_label = Label.new()
	scale_label.name = "ScaleLabel"
	scale_label.text = "Scale: Unknown"
	scale_label.position = Vector2(10, 70)
	panel.add_child(scale_label)
	
	var akashic_label = Label.new()
	akashic_label.name = "AkashicLabel"
	akashic_label.text = "Akashic: Initializing..."
	akashic_label.position = Vector2(10, 100)
	panel.add_child(akashic_label)
	
	# Add buttons for controls
	var debug_button = Button.new()
	debug_button.text = "Toggle Debug Mode"
	debug_button.size = Vector2(200, 50)
	debug_button.position = Vector2(20, 180)
	debug_button.connect("pressed", Callable(self, "_on_debug_button_pressed"))
	ui_control.add_child(debug_button)
	
	# Start updating the UI
	set_process(true)

# Update UI elements
func _process(delta):
	if not ui_control or not is_instance_valid(ui_control):
		return
	
	if show_debug_ui:
		update_debug_ui()

# Update debug UI with current status
func update_debug_ui():
	var vr_status_label = ui_control.get_node("Panel/VRStatusLabel")
	var scale_label = ui_control.get_node("Panel/ScaleLabel")
	var akashic_label = ui_control.get_node("Panel/AkashicLabel")
	
	if not vr_status_label or not scale_label or not akashic_label:
		return
	
	# Update VR status
	var vr_manager = VRManager.get_instance()
	if vr_manager:
		var status = vr_manager.get_vr_status()
		vr_status_label.text = "VR: " + ("Active" if status.is_vr_active else "Inactive")
	else:
		vr_status_label.text = "VR: Manager not found"
	
	# Update scale info
	if vr_manager:
		scale_label.text = "Scale: " + vr_manager.current_scale
	
	# Update Akashic status
	var akashic_records = AkashicRecordsManager.get_instance()
	if akashic_records:
		var system_status = akashic_records.get_system_status()
		akashic_label.text = "Akashic: " + ("Initialized" if system_status.initialized else "Not Initialized")
	else:
		akashic_label.text = "Akashic: Manager not found"

# Button event handlers
func _on_debug_button_pressed():
	print("Debug mode toggled")
	
	# This would toggle more detailed debugging information
	# or perhaps switch the visualization mode

# Setup an example scene with initial data
func setup_example_scene():
	# Create a simple environment
	var world_environment = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.05)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.2, 0.2, 0.3)
	environment.ambient_light_energy = 0.5
	environment.fog_enabled = true
	environment.fog_color = Color(0.03, 0.03, 0.1)
	environment.fog_depth_begin = 10
	environment.fog_depth_end = 100
	environment.ssao_enabled = true
	environment.ssr_enabled = true
	environment.glow_enabled = true
	
	world_environment.environment = environment
	add_child(world_environment)
	
	# Add a directional light for primary lighting
	var directional_light = DirectionalLight3D.new()
	directional_light.shadow_enabled = true
	directional_light.light_energy = 0.8
	directional_light.light_color = Color(1.0, 0.98, 0.9)
	directional_light.rotation_degrees = Vector3(-45, -45, 0)
	add_child(directional_light)
	
	# Add a floor grid for reference
	var grid_mesh = GridMesh.new()
	grid_mesh.size = Vector2(20, 20)
	grid_mesh.sections = Vector2(20, 20)
	
	var grid = MeshInstance3D.new()
	grid.mesh = grid_mesh
	grid.position = Vector3(0, -1, 0)
	
	var grid_material = StandardMaterial3D.new()
	grid_material.albedo_color = Color(0.3, 0.5, 0.7, 0.5)
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid.material_override = grid_material
	
	add_child(grid)
	
	print("Example scene set up")

# Function to test with sample data
func populate_test_data():
	# Get Akashic Records
	var akashic_records = AkashicRecordsManager.get_instance()
	if not akashic_records.is_initialized:
		akashic_records.initialize()
	
	# Create some test words if they don't exist
	var test_words = [
		{
			"id": "concept",
			"category": "abstract",
			"properties": {"clarity": 0.8, "complexity": 0.3},
			"description": "A foundation abstract concept"
		},
		{
			"id": "theory",
			"category": "abstract",
			"parent": "concept",
			"properties": {"validation": 0.6, "application": 0.7},
			"description": "A structured framework of ideas"
		},
		{
			"id": "experiment",
			"category": "abstract",
			"parent": "theory",
			"properties": {"precision": 0.9, "repeatability": 0.8},
			"description": "A test to validate a theory"
		}
	]
	
	for word_data in test_words:
		var word_id = word_data.id
		if akashic_records.get_word(word_id).is_empty():
			if word_data.has("parent") and not word_data.parent.is_empty():
				akashic_records.create_child_word(word_data.parent, word_id, word_data)
			else:
				akashic_records.create_word(word_id, word_data)
	
	print("Test data populated")

# When the scene is exiting
func _exit_tree():
	# Clean up resources
	if vr_scene_setup and is_instance_valid(vr_scene_setup):
		# Save any unsaved data
		var akashic_records = AkashicRecordsManager.get_instance()
		if akashic_records and akashic_records.is_initialized:
			akashic_records.shutdown()
		
		# Disable VR if needed
		var vr_interface = XRServer.find_interface("OpenXR")
		if vr_interface and vr_interface.is_initialized() and enable_passthrough:
			vr_interface.stop_passthrough()
	
	print("VR Scene Example shutting down")
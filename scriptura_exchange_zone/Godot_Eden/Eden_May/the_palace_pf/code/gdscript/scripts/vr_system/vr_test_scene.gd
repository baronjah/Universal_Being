extends Node3D

# VR Test Scene for Eden Space Game
# This script creates a test environment for the VR implementation

# References
var vr_manager = null
var akashic_records = null
var element_manager = null

# Test objects
var test_elements = []
var test_words = []
var floating_labels = []

# UI elements
var debug_panel = null
var info_label = null
var status_label = null
var fps_label = null

# Test settings
@export var spawn_test_elements: bool = true
@export var create_test_dictionary: bool = true
@export var show_debug_ui: bool = true
@export var auto_initialize_vr: bool = true

# Called when the node enters the scene tree
func _ready():
	print("VR Test Scene Initializing...")
	
	# Create environment
	_setup_environment()
	
	# Initialize VR if auto-initialize is enabled
	if auto_initialize_vr:
		_initialize_vr()
	
	# Create debug UI
	if show_debug_ui:
		_create_debug_ui()
	
	# Connect to Akashic Records
	_initialize_akashic_records()
	
	# Spawn test elements
	if spawn_test_elements:
		_spawn_test_elements()
	
	# Create test dictionary entries
	if create_test_dictionary:
		_create_test_dictionary()
	
	print("VR Test Scene Initialized")

# Process function
func _process(delta):
	# Update debug information
	if show_debug_ui and fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Update VR status
	_update_vr_status()
	
	# Rotate test elements
	_update_test_elements(delta)

# Setup the environment
func _setup_environment():
	# Create a world environment
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Configure environment
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.1)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.2, 0.2, 0.3)
	environment.ambient_light_energy = 0.5
	environment.fog_enabled = true
	environment.fog_color = Color(0.05, 0.05, 0.1)
	environment.fog_depth_begin = 10
	environment.fog_depth_end = 100
	
	# Apply environment
	world_env.environment = environment
	add_child(world_env)
	
	# Add directional light
	var dir_light = DirectionalLight3D.new()
	dir_light.light_energy = 1.0
	dir_light.shadow_enabled = true
	dir_light.rotation_degrees = Vector3(-45, -45, 0)
	add_child(dir_light)
	
	# Add a floor
	var floor_mesh = PlaneMesh.new()
	floor_mesh.size = Vector2(20, 20)
	
	var floor_instance = MeshInstance3D.new()
	floor_instance.mesh = floor_mesh
	floor_instance.name = "Floor"
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.2, 0.2, 0.3)
	floor_instance.material_override = floor_material
	
	var floor_body = StaticBody3D.new()
	var floor_collision = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_collision.shape = floor_shape
	
	floor_body.add_child(floor_collision)
	floor_instance.add_child(floor_body)
	floor_instance.position = Vector3(0, -0.05, 0)
	
	add_child(floor_instance)
	
	# Add a reference grid
	var grid_mesh = GridMesh.new()
	grid_mesh.size = Vector2(20, 20)
	grid_mesh.sections = Vector2(20, 20)
	
	var grid_instance = MeshInstance3D.new()
	grid_instance.mesh = grid_mesh
	grid_instance.name = "Grid"
	
	var grid_material = StandardMaterial3D.new()
	grid_material.albedo_color = Color(0.3, 0.6, 0.9, 0.2)
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_instance.material_override = grid_material
	
	add_child(grid_instance)
	
	# Add a camera if none exists
	if not get_viewport().get_camera_3d():
		var camera = Camera3D.new()
		camera.name = "MainCamera"
		camera.position = Vector3(0, 1.7, 3)
		camera.rotation_degrees = Vector3(-15, 0, 0)
		add_child(camera)
	
	print("Test environment created")

# Initialize VR system
func _initialize_vr():
	print("Initializing VR system...")
	
	# Try to load VR Manager
	var vr_manager_script = load("res://code/gdscript/scripts/vr_system/vr_manager.gd")
	if vr_manager_script:
		# Try to get singleton instance first
		vr_manager = VRManager.get_instance() if "VRManager" in get_tree().root.get_children() else null
		
		if not vr_manager:
			vr_manager = vr_manager_script.new()
			vr_manager.name = "VRManager"
			add_child(vr_manager)
		
		# Initialize VR manager
		vr_manager.initialize()
		
		# Create VR scene setup
		_create_vr_scene_setup()
		
		print("VR system initialized")
	else:
		push_error("VR Manager script not found")

# Create VR scene setup
func _create_vr_scene_setup():
	var vr_scene_setup_script = load("res://code/gdscript/scripts/vr_system/vr_scene_setup.gd")
	if vr_scene_setup_script:
		var vr_scene_setup = vr_scene_setup_script.new()
		vr_scene_setup.name = "VRSceneSetup"
		add_child(vr_scene_setup)
		print("VR Scene Setup created")
	else:
		push_error("VR Scene Setup script not found")

# Create debug UI
func _create_debug_ui():
	# Create Canvas Layer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # Top layer
	add_child(canvas_layer)
	
	# Create main panel
	debug_panel = Panel.new()
	debug_panel.position = Vector2(10, 10)
	debug_panel.size = Vector2(300, 200)
	
	# Create title label
	var title_label = Label.new()
	title_label.text = "VR Test Scene"
	title_label.position = Vector2(10, 10)
	title_label.size = Vector2(280, 30)
	debug_panel.add_child(title_label)
	
	# Create info label
	info_label = Label.new()
	info_label.text = "Test elements: 0\nTest dictionary entries: 0"
	info_label.position = Vector2(10, 50)
	info_label.size = Vector2(280, 50)
	debug_panel.add_child(info_label)
	
	# Create status label
	status_label = Label.new()
	status_label.text = "VR Status: Initializing..."
	status_label.position = Vector2(10, 110)
	status_label.size = Vector2(280, 30)
	debug_panel.add_child(status_label)
	
	# Create FPS label
	fps_label = Label.new()
	fps_label.text = "FPS: 0"
	fps_label.position = Vector2(10, 150)
	fps_label.size = Vector2(280, 30)
	debug_panel.add_child(fps_label)
	
	# Create toggle button
	var toggle_button = Button.new()
	toggle_button.text = "Toggle VR"
	toggle_button.position = Vector2(10, 210)
	toggle_button.size = Vector2(280, 40)
	toggle_button.connect("pressed", Callable(self, "_on_toggle_vr_pressed"))
	
	# Add elements to canvas layer
	canvas_layer.add_child(debug_panel)
	canvas_layer.add_child(toggle_button)
	
	print("Debug UI created")

# Initialize Akashic Records
func _initialize_akashic_records():
	print("Initializing Akashic Records...")
	
	# Try to get singleton instance first
	akashic_records = get_node_or_null("/root/AkashicRecordsManager")
	
	if not akashic_records:
		var akashic_script = load("res://code/gdscript/scripts/akashic_records/akashic_records_manager.gd")
		if akashic_script:
			akashic_records = akashic_script.new()
			akashic_records.name = "AkashicRecordsManager"
			add_child(akashic_records)
		else:
			push_error("Akashic Records Manager script not found")
			return
	
	# Initialize if not already initialized
	if "is_initialized" in akashic_records and not akashic_records.is_initialized:
		akashic_records.initialize()
	
	print("Akashic Records initialized")

# Spawn test elements
func _spawn_test_elements():
	print("Spawning test elements...")
	
	# Define test element types and colors
	var element_types = ["fire", "water", "wood", "ash"]
	var element_colors = {
		"fire": Color(1.0, 0.3, 0.1, 0.8),
		"water": Color(0.1, 0.5, 1.0, 0.8),
		"wood": Color(0.6, 0.4, 0.1, 1.0),
		"ash": Color(0.7, 0.7, 0.7, 0.8)
	}
	
	# Create elements
	for i in range(4):
		var element_type = element_types[i]
		var position = Vector3(
			cos(PI/2 * i) * 1.5,
			1.0,
			sin(PI/2 * i) * 1.5
		)
		
		# Create element mesh
		var element = _create_element_mesh(element_type, element_colors[element_type])
		element.position = position
		
		# Add to scene
		add_child(element)
		
		# Add physics
		_add_physics_to_element(element)
		
		# Add to test elements array
		test_elements.append(element)
		
		# Create floating label
		_create_floating_label(element_type, position + Vector3(0, 0.5, 0))
	
	# Update info label
	if info_label:
		info_label.text = "Test elements: " + str(test_elements.size()) + "\nTest dictionary entries: 0"
	
	print("Test elements spawned: " + str(test_elements.size()))

# Create test dictionary entries
func _create_test_dictionary():
	print("Creating test dictionary entries...")
	
	if not akashic_records:
		push_error("Cannot create test dictionary entries - Akashic Records not initialized")
		return
	
	# Define basic test entries
	var test_entries = [
		{
			"id": "fire",
			"category": "element",
			"properties": {
				"heat": 0.8,
				"light": 0.7,
				"consumption": 0.5
			},
			"description": "The fire element, representing energy and transformation"
		},
		{
			"id": "water",
			"category": "element",
			"properties": {
				"flow": 0.8,
				"transparency": 0.7,
				"temperature": 20
			},
			"description": "The water element, representing flow and adaptation"
		},
		{
			"id": "wood",
			"category": "element",
			"properties": {
				"growth": 0.2,
				"hardness": 0.6,
				"flammability": 0.7
			},
			"description": "The wood element, representing growth and vitality"
		},
		{
			"id": "ash",
			"category": "element",
			"properties": {
				"fertility": 0.6,
				"lightness": 0.3
			},
			"description": "The ash element, representing transformation and fertility"
		}
	]
	
	# Add entries to Akashic Records
	var created_count = 0
	
	for entry in test_entries:
		if akashic_records.get_word(entry.id).size() == 0:
			# Try to create the word
			var success = false
			
			if "create_word" in akashic_records:
				success = akashic_records.create_word(entry.id, entry)
			
			if success:
				test_words.append(entry.id)
				created_count += 1
	
	# Add interactions between elements
	if "add_interaction_rule" in akashic_records and created_count >= 4:
		akashic_records.add_interaction_rule("fire", "wood", "ash")
		akashic_records.add_interaction_rule("water", "fire", "water")
		akashic_records.add_interaction_rule("water", "ash", "wood")
	
	# Update info label
	if info_label:
		info_label.text = "Test elements: " + str(test_elements.size()) + "\nTest dictionary entries: " + str(test_words.size())
	
	print("Test dictionary entries created: " + str(created_count))

# Create an element mesh
func _create_element_mesh(element_type, color):
	var element_node = Node3D.new()
	element_node.name = "Element_" + element_type
	
	# Create mesh
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	mesh_instance.mesh = sphere
	
	# Apply material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	
	if element_type == "fire" or element_type == "water":
		material.emission_enabled = true
		material.emission = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mesh_instance.material_override = material
	element_node.add_child(mesh_instance)
	
	# Store element type
	element_node.set_meta("element_type", element_type)
	
	return element_node

# Add physics to an element
func _add_physics_to_element(element_node):
	# Create rigid body
	var rigid_body = RigidBody3D.new()
	rigid_body.name = "ElementBody"
	
	# Set physics properties based on element type
	var element_type = element_node.get_meta("element_type")
	
	match element_type:
		"fire":
			rigid_body.mass = 0.3
			rigid_body.gravity_scale = -0.1  # Float upward slightly
		"water":
			rigid_body.mass = 1.0
			rigid_body.gravity_scale = 1.2  # Heavier than normal
		"wood":
			rigid_body.mass = 0.8
			rigid_body.gravity_scale = 1.0  # Normal gravity
		"ash":
			rigid_body.mass = 0.2
			rigid_body.gravity_scale = 0.3  # Very light
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.2
	collision_shape.shape = sphere_shape
	rigid_body.add_child(collision_shape)
	
	# Set up collision detection
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 4
	rigid_body.connect("body_entered", Callable(self, "_on_element_collision").bind(element_node))
	
	# Store the element type on the rigid body as well
	rigid_body.set_meta("element_type", element_type)
	
	# Add rigid body to element
	element_node.add_child(rigid_body)

# Create a floating label above an element
func _create_floating_label(text, position):
	var label_3d = Label3D.new()
	label_3d.text = text
	label_3d.font_size = 64
	label_3d.no_depth_test = true
	label_3d.pixel_size = 0.01
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.position = position
	
	add_child(label_3d)
	floating_labels.append(label_3d)

# Update VR status display
func _update_vr_status():
	if status_label:
		var status_text = "VR Status: "
		
		if vr_manager:
			if "is_vr_active" in vr_manager and vr_manager.is_vr_active:
				status_text += "Active"
			else:
				status_text += "Initialized (Not Active)"
		else:
			status_text += "Not Initialized"
		
		status_label.text = status_text

# Update test elements
func _update_test_elements(delta):
	# Rotate elements slightly to make them interesting
	for i in range(test_elements.size()):
		var element = test_elements[i]
		if element and is_instance_valid(element):
			# Only rotate if it's not physics controlled
			var body = element.get_node_or_null("ElementBody")
			if not body or not body is RigidBody3D:
				element.rotate_y(delta * (0.5 + i * 0.2))
	
	# Update floating labels to follow elements
	for i in range(min(test_elements.size(), floating_labels.size())):
		var element = test_elements[i]
		var label = floating_labels[i]
		
		if element and is_instance_valid(element) and label and is_instance_valid(label):
			label.position = element.position + Vector3(0, 0.5, 0)

# Toggle VR mode
func _on_toggle_vr_pressed():
	if vr_manager:
		# Call toggle_vr on VRManager if it exists
		if "toggle_vr" in vr_manager:
			vr_manager.toggle_vr()
	else:
		# Try to initialize VR
		_initialize_vr()

# Handle element collisions
func _on_element_collision(body, element_node):
	# Check if another element collided with this one
	if body.has_meta("element_type") and element_node.has_meta("element_type"):
		var this_type = element_node.get_meta("element_type")
		var other_type = body.get_meta("element_type")
		
		print("Collision between " + this_type + " and " + other_type)
		
		# Process interaction if Akashic Records is available
		if akashic_records and "process_element_interaction" in akashic_records:
			var result = akashic_records.process_element_interaction(this_type, other_type)
			print("Interaction result: " + str(result))
			
			# Handle interaction result (visual effects, etc.)
			_handle_interaction_result(result, element_node.global_position, body.global_position)

# Handle interaction result
func _handle_interaction_result(result, pos1, pos2):
	# Create a simple visual effect at the midpoint
	var midpoint = (pos1 + pos2) / 2
	
	# Create a temporary effect
	var effect = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	effect.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.3, 0.8)
	material.emission_enabled = true
	material.emission = Color(1.0, 1.0, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	effect.material_override = material
	
	effect.position = midpoint
	add_child(effect)
	
	# Create a timer to remove the effect
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.connect("timeout", Callable(effect, "queue_free"))
	add_child(timer)
	timer.start()

# Clean up when the scene is exited
func _exit_tree():
	print("Cleaning up VR Test Scene...")
	
	# Free all test elements
	for element in test_elements:
		if element and is_instance_valid(element):
			element.queue_free()
	
	# Free all floating labels
	for label in floating_labels:
		if label and is_instance_valid(label):
			label.queue_free()
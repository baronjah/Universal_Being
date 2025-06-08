extends Node3D
## Turn Layer Environment Controller
## Implements 5-layer architecture from Akashic 3D for turn visualization
## Each layer represents different aspects of the 12-turn cycle
class_name TurnLayerEnvironment

# ==================================================
# SCRIPT NAME: turn_layer_environment.gd
# DESCRIPTION: Creates 5-layer cinema-style interface for visualizing turns
# CREATED: 2025-05-24 - Based on Akashic 3D patterns
# ==================================================

# Layer configuration adapted for turns
const LAYER_COUNT = 5
const LAYER_DISTANCES = [5.0, 10.0, 15.0, 20.0, 25.0]
const LAYER_NAMES = [
	"current_turn",      # Layer 0: Active turn display
	"turn_history",      # Layer 1: Previous turns
	"word_manifestation", # Layer 2: Words in current dimension
	"dimensional_view",   # Layer 3: Multi-dimensional perspective
	"cosmic_cycle"       # Layer 4: Full 12-turn cycle view
]

# Layer purposes for the 12-turn system
const LAYER_PURPOSES = [
	"Shows current turn phase and active words",
	"Displays history of previous turns",
	"Visualizes word manifestation in space",
	"Shows dimensional progression (1D-12D)",
	"Displays complete 12-turn cosmic cycle"
]

# Screen configuration
var screen_width: float = 24.0
var screen_height: float = 18.0
var screen_curvature: float = 0.4
var viewer_position: Vector3 = Vector3(0, 0, -40)

# Layer management
var turn_layers: Array[Node3D] = []
var layer_materials: Array[StandardMaterial3D] = []
var current_focus_layer: int = 0

# Turn system integration
var current_turn: int = 5  # From current_turn.txt
var current_dimension: int = 4  # 4D - Time dimension for Turn 5
var thread_manager: ThreadManager
var word_processor: WordProcessorTasks

# Visual elements
var environment_container: Node3D
var layer_markers: Array[Node3D] = []
var turn_indicators: Array[Node3D] = []

# References
var camera: Camera3D
var main_controller: Node

# Signals
signal layer_focus_changed(layer_index: int)
signal turn_advanced(new_turn: int)
signal dimension_shifted(new_dimension: int)
signal environment_ready()

## Initialize the turn layer environment
# INPUT: Camera node and main controller reference
# PROCESS: Sets up 5-layer system with turn-specific content
# OUTPUT: None
# CHANGES: Creates entire layer structure
# CONNECTION: Integrates with ThreadManager and WordProcessorTasks
func _ready() -> void:
	_get_autoload_references()
	_create_environment_structure()
	_create_turn_layers()
	_setup_layer_content()
	_create_turn_indicators()
	
	print("🎬 Turn Layer Environment initialized with %d layers" % LAYER_COUNT)
	print("📍 Current Turn: %d | Current Dimension: %d" % [current_turn, current_dimension])
	emit_signal("environment_ready")

## Get references to autoloaded systems
# INPUT: None
# PROCESS: Retrieves thread manager and word processor
# OUTPUT: None
# CHANGES: Sets internal references
# CONNECTION: Links to core systems
func _get_autoload_references() -> void:
	# Get thread manager if it exists
	if has_node("/root/ThreadManager"):
		thread_manager = get_node("/root/ThreadManager")
		print("✅ Thread Manager connected")
	
	# Get word processor if it exists
	if has_node("/root/WordProcessorTasks"):
		word_processor = get_node("/root/WordProcessorTasks")
		print("✅ Word Processor connected")

## Initialize with camera and controller
# INPUT: Camera3D node and controller node
# PROCESS: Sets up camera position and references
# OUTPUT: None
# CHANGES: Camera position and internal references
# CONNECTION: Links to main game controller
func initialize(camera_node: Camera3D, controller: Node) -> void:
	camera = camera_node
	main_controller = controller
	
	if camera:
		camera.global_position = viewer_position
		camera.look_at(Vector3(0, 0, LAYER_DISTANCES[0]), Vector3.UP)

## Create main environment structure
# INPUT: None
# PROCESS: Creates container and configures layers
# OUTPUT: None
# CHANGES: Adds environment container to scene
# CONNECTION: Foundation for all layers
func _create_environment_structure() -> void:
	environment_container = Node3D.new()
	environment_container.name = "TurnEnvironmentContainer"
	add_child(environment_container)

## Create the 5 turn layers
# INPUT: None
# PROCESS: Generates each layer with appropriate settings
# OUTPUT: None
# CHANGES: Populates turn_layers array
# CONNECTION: Each layer represents different turn aspect
func _create_turn_layers() -> void:
	for i in range(LAYER_COUNT):
		var layer = _create_single_layer(i)
		turn_layers.append(layer)
		environment_container.add_child(layer)

## Create a single layer
# INPUT: Layer index (0-4)
# PROCESS: Creates layer with screen and markers
# OUTPUT: Node3D layer
# CHANGES: None
# CONNECTION: Part of layer creation system
func _create_single_layer(layer_index: int) -> Node3D:
	var layer = Node3D.new()
	layer.name = "TurnLayer_%d_%s" % [layer_index, LAYER_NAMES[layer_index]]
	layer.position = Vector3(0, 0, LAYER_DISTANCES[layer_index])
	
	# Create screen for this layer
	var screen = _create_layer_screen(layer_index)
	layer.add_child(screen)
	
	# Create interactive markers
	var markers = _create_layer_markers(layer_index)
	layer.add_child(markers)
	layer_markers.append(markers)
	
	return layer

## Create screen mesh for a layer
# INPUT: Layer index
# PROCESS: Creates curved screen with appropriate material
# OUTPUT: MeshInstance3D
# CHANGES: None
# CONNECTION: Visual representation of layer
func _create_layer_screen(layer_index: int) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "LayerScreen"
	
	# Create curved quad mesh
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(screen_width, screen_height)
	mesh_instance.mesh = quad_mesh
	
	# Create material with turn-specific colors
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_layer_color(layer_index)
	material.flags_transparent = true
	material.emission_enabled = true
	material.emission = _get_layer_color(layer_index) * 0.3
	material.emission_intensity = 0.5
	
	# Adjust transparency based on layer depth
	var transparency = 0.1 + (layer_index * 0.15)
	material.albedo_color.a = 1.0 - transparency
	
	mesh_instance.material_override = material
	layer_materials.append(material)
	
	return mesh_instance

## Get color for specific layer based on turn system
# INPUT: Layer index
# PROCESS: Returns appropriate color for layer type
# OUTPUT: Color
# CHANGES: None
# CONNECTION: Visual theming system
func _get_layer_color(layer_index: int) -> Color:
	match layer_index:
		0: return Color(1.0, 1.0, 1.0, 1.0)    # White - Current turn
		1: return Color(0.7, 0.9, 1.0, 1.0)    # Light blue - History
		2: return Color(0.5, 1.0, 0.7, 1.0)    # Green - Manifestation
		3: return Color(1.0, 0.8, 0.3, 1.0)    # Gold - Dimensional
		4: return Color(0.9, 0.5, 1.0, 1.0)    # Purple - Cosmic
		_: return Color.WHITE

## Create interactive markers for a layer
# INPUT: Layer index
# PROCESS: Creates clickable capsules at key positions
# OUTPUT: Node3D containing all markers
# CHANGES: None
# CONNECTION: Enables layer interaction
func _create_layer_markers(layer_index: int) -> Node3D:
	var markers_container = Node3D.new()
	markers_container.name = "LayerMarkers"
	
	# Marker positions (corners and center)
	var positions = [
		Vector3(-screen_width/2 + 1, screen_height/2 - 1, 0),   # Top-left
		Vector3(screen_width/2 - 1, screen_height/2 - 1, 0),    # Top-right
		Vector3(0, 0, 0),                                        # Center
		Vector3(-screen_width/2 + 1, -screen_height/2 + 1, 0),  # Bottom-left
		Vector3(screen_width/2 - 1, -screen_height/2 + 1, 0)    # Bottom-right
	]
	
	var marker_labels = ["TL", "TR", "CTR", "BL", "BR"]
	
	for i in range(positions.size()):
		var marker = _create_capsule_marker(layer_index, i, positions[i], marker_labels[i])
		markers_container.add_child(marker)
	
	return markers_container

## Create a single capsule marker
# INPUT: Layer index, marker index, position, label text
# PROCESS: Creates interactive capsule with label
# OUTPUT: Area3D marker
# CHANGES: None
# CONNECTION: Part of marker system
func _create_capsule_marker(layer_idx: int, marker_idx: int, pos: Vector3, label_text: String) -> Area3D:
	var marker = Area3D.new()
	marker.name = "Marker_L%d_%s" % [layer_idx, label_text]
	marker.position = pos
	
	# Create capsule collision shape
	var collision = CollisionShape3D.new()
	var capsule_shape = CapsuleShape3D.new()
	capsule_shape.radius = 0.3
	capsule_shape.height = 1.0
	collision.shape = capsule_shape
	marker.add_child(collision)
	
	# Create visual capsule
	var mesh_instance = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.3
	capsule_mesh.height = 1.0
	mesh_instance.mesh = capsule_mesh
	
	# Material with layer color
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_layer_color(layer_idx)
	material.emission_enabled = true
	material.emission = _get_layer_color(layer_idx)
	material.emission_intensity = 1.0
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
	
	# Add label
	var label = Label3D.new()
	label.text = "L%d-%s" % [layer_idx, label_text]
	label.position = Vector3(0, 0.8, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 20
	marker.add_child(label)
	
	# Connect interaction signals
	marker.input_event.connect(_on_marker_clicked.bind(layer_idx, marker_idx))
	marker.mouse_entered.connect(_on_marker_hover_start.bind(layer_idx, marker_idx))
	marker.mouse_exited.connect(_on_marker_hover_end.bind(layer_idx, marker_idx))
	
	return marker

## Setup content for each layer
# INPUT: None
# PROCESS: Populates layers with turn-specific content
# OUTPUT: None
# CHANGES: Layer content
# CONNECTION: Uses ThreadManager for parallel processing
func _setup_layer_content() -> void:
	# Layer 0: Current turn display
	_setup_current_turn_layer()
	
	# Layer 1: Turn history
	_setup_turn_history_layer()
	
	# Layer 2: Word manifestation
	_setup_word_manifestation_layer()
	
	# Layer 3: Dimensional view
	_setup_dimensional_view_layer()
	
	# Layer 4: Cosmic cycle
	_setup_cosmic_cycle_layer()

## Setup current turn layer content
# INPUT: None
# PROCESS: Displays current turn information
# OUTPUT: None
# CHANGES: Layer 0 content
# CONNECTION: Reads from turn system
func _setup_current_turn_layer() -> void:
	var layer = turn_layers[0]
	
	# Create turn display
	var turn_display = Label3D.new()
	turn_display.name = "CurrentTurnDisplay"
	turn_display.text = "TURN %d: AWAKENING" % current_turn
	turn_display.font_size = 48
	turn_display.position = Vector3(0, 5, 0)
	turn_display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	layer.add_child(turn_display)
	
	# Add phase description
	var phase_desc = Label3D.new()
	phase_desc.text = "Recognition of self - Meta-awareness active"
	phase_desc.font_size = 24
	phase_desc.position = Vector3(0, 3, 0)
	phase_desc.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	layer.add_child(phase_desc)

## Setup turn history layer
# INPUT: None
# PROCESS: Shows previous turns
# OUTPUT: None
# CHANGES: Layer 1 content
# CONNECTION: Displays turn progression
func _setup_turn_history_layer() -> void:
	var layer = turn_layers[1]
	var turn_names = [
		"Genesis", "Formation", "Complexity", "Consciousness", "Awakening"
	]
	
	for i in range(min(current_turn, turn_names.size())):
		var history_item = Label3D.new()
		history_item.text = "Turn %d: %s ✓" % [i + 1, turn_names[i]]
		history_item.font_size = 20
		history_item.position = Vector3(-8, 3 - i * 1.5, 0)
		history_item.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		layer.add_child(history_item)

## Setup word manifestation layer
# INPUT: None
# PROCESS: Creates word entities in 3D space
# OUTPUT: None
# CHANGES: Layer 2 content
# CONNECTION: Uses WordProcessorTasks
func _setup_word_manifestation_layer() -> void:
	var layer = turn_layers[2]
	
	# Sample words for demonstration
	var words = ["AWAKEN", "RECOGNIZE", "SELF", "META", "AWARE"]
	
	if word_processor:
		# Process words using thread manager
		for i in range(words.size()):
			var params = {
				"word": words[i],
				"dimension": current_dimension,
				"cosmic_age": current_turn
			}
			
			# Calculate word properties
			var result = word_processor.calculate_word_power(params)
			
			# Create word entity
			var word_entity = _create_word_entity(result, i)
			layer.add_child(word_entity)

## Create a word entity
# INPUT: Word data dictionary, index
# PROCESS: Creates 3D representation of word
# OUTPUT: Node3D word entity
# CHANGES: None
# CONNECTION: Visual word system
func _create_word_entity(word_data: Dictionary, index: int) -> Node3D:
	var entity = Node3D.new()
	entity.name = "WordEntity_" + word_data.word
	
	# Position in grid
	var x = (index % 3 - 1) * 4.0
	var y = (index / 3) * 2.0
	entity.position = Vector3(x, y, 0)
	
	# Create visual representation
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3.ONE * word_data.size
	mesh_instance.mesh = box_mesh
	
	# Material based on word power
	var material = StandardMaterial3D.new()
	material.albedo_color = word_data.color
	material.emission_enabled = true
	material.emission = word_data.color
	material.emission_intensity = 0.5
	mesh_instance.material_override = material
	entity.add_child(mesh_instance)
	
	# Add word label
	var label = Label3D.new()
	label.text = word_data.word
	label.position = Vector3(0, word_data.size + 0.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	entity.add_child(label)
	
	return entity

## Setup dimensional view layer
# INPUT: None
# PROCESS: Shows dimensional progression
# OUTPUT: None
# CHANGES: Layer 3 content
# CONNECTION: Visualizes dimensions
func _setup_dimensional_view_layer() -> void:
	var layer = turn_layers[3]
	
	# Create dimension indicator
	for i in range(current_dimension + 1):
		var dim_indicator = _create_dimension_indicator(i)
		dim_indicator.position = Vector3(-10 + i * 4, 0, 0)
		layer.add_child(dim_indicator)

## Create dimension indicator
# INPUT: Dimension number
# PROCESS: Creates visual for dimension
# OUTPUT: Node3D indicator
# CHANGES: None
# CONNECTION: Part of dimensional view
func _create_dimension_indicator(dim: int) -> Node3D:
	var indicator = Node3D.new()
	indicator.name = "Dimension_%dD" % (dim + 1)
	
	# Create appropriate shape based on dimension
	var mesh_instance = MeshInstance3D.new()
	match dim:
		0: # 1D - Point
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.2
			mesh_instance.mesh = sphere_mesh
		1: # 2D - Line
			var cylinder_mesh = CylinderMesh.new()
			cylinder_mesh.height = 2.0
			cylinder_mesh.top_radius = 0.1
			cylinder_mesh.bottom_radius = 0.1
			mesh_instance.mesh = cylinder_mesh
			mesh_instance.rotation.z = PI/2
		2: # 3D - Cube
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3.ONE
			mesh_instance.mesh = box_mesh
		_: # 4D+ - Torus
			var torus_mesh = TorusMesh.new()
			torus_mesh.inner_radius = 0.3
			torus_mesh.outer_radius = 0.6
			mesh_instance.mesh = torus_mesh
	
	# Material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.from_hsv(float(dim) / 12.0, 0.8, 1.0)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_intensity = 0.8
	mesh_instance.material_override = material
	indicator.add_child(mesh_instance)
	
	# Label
	var label = Label3D.new()
	label.text = "%dD" % (dim + 1)
	label.position = Vector3(0, 1.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	indicator.add_child(label)
	
	return indicator

## Setup cosmic cycle layer
# INPUT: None
# PROCESS: Shows full 12-turn cycle
# OUTPUT: None
# CHANGES: Layer 4 content
# CONNECTION: Complete cycle visualization
func _setup_cosmic_cycle_layer() -> void:
	var layer = turn_layers[4]
	
	# Create circular arrangement of 12 turns
	var radius = 8.0
	for i in range(12):
		var angle = (i / 12.0) * TAU
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		
		var turn_node = _create_turn_node(i + 1)
		turn_node.position = Vector3(x, y, 0)
		layer.add_child(turn_node)

## Create node for a turn in the cycle
# INPUT: Turn number (1-12)
# PROCESS: Creates visual representation of turn
# OUTPUT: Node3D turn node
# CHANGES: None
# CONNECTION: Part of cosmic cycle
func _create_turn_node(turn_num: int) -> Node3D:
	var node = Node3D.new()
	node.name = "TurnNode_%d" % turn_num
	
	# Create sphere
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5 if turn_num == current_turn else 0.3
	mesh_instance.mesh = sphere_mesh
	
	# Material - highlight current turn
	var material = StandardMaterial3D.new()
	if turn_num <= current_turn:
		material.albedo_color = Color.WHITE
		material.emission_enabled = true
		material.emission = Color.WHITE
		material.emission_intensity = 1.0 if turn_num == current_turn else 0.3
	else:
		material.albedo_color = Color(0.3, 0.3, 0.3)
	
	mesh_instance.material_override = material
	node.add_child(mesh_instance)
	
	# Label
	var label = Label3D.new()
	label.text = str(turn_num)
	label.position = Vector3(0, 0.8, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 16
	node.add_child(label)
	
	return node

## Create turn progress indicators
# INPUT: None
# PROCESS: Creates visual indicators for turn progress
# OUTPUT: None
# CHANGES: Adds indicators to scene
# CONNECTION: Shows advancement through turns
func _create_turn_indicators() -> void:
	# Create container for indicators
	var indicators_container = Node3D.new()
	indicators_container.name = "TurnIndicators"
	indicators_container.position = Vector3(0, -10, 0)
	add_child(indicators_container)
	
	# Create progress bar
	for i in range(12):
		var indicator = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1.5, 0.5, 0.5)
		indicator.mesh = box_mesh
		
		# Position in a row
		indicator.position = Vector3(-9 + i * 1.5, 0, 0)
		
		# Color based on completion
		var material = StandardMaterial3D.new()
		if i < current_turn:
			material.albedo_color = Color.GREEN
			material.emission_enabled = true
			material.emission = Color.GREEN
			material.emission_intensity = 0.5
		elif i == current_turn - 1:
			material.albedo_color = Color.YELLOW
			material.emission_enabled = true
			material.emission = Color.YELLOW
			material.emission_intensity = 1.0
		else:
			material.albedo_color = Color(0.2, 0.2, 0.2)
		
		indicator.material_override = material
		indicators_container.add_child(indicator)
		turn_indicators.append(indicator)

## Handle marker click
# INPUT: Layer index, marker index, event
# PROCESS: Responds to marker interaction
# OUTPUT: None
# CHANGES: Focus layer or triggers action
# CONNECTION: User interaction system
func _on_marker_clicked(viewport: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, layer_idx: int, marker_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🎯 Clicked marker %d on layer %d" % [marker_idx, layer_idx])
		focus_on_layer(layer_idx)

## Handle marker hover start
# INPUT: Layer index, marker index
# PROCESS: Visual feedback for hover
# OUTPUT: None
# CHANGES: Marker appearance
# CONNECTION: UI feedback system
func _on_marker_hover_start(layer_idx: int, marker_idx: int) -> void:
	# Could add hover effects here
	pass

## Handle marker hover end
# INPUT: Layer index, marker index
# PROCESS: Removes hover feedback
# OUTPUT: None
# CHANGES: Marker appearance
# CONNECTION: UI feedback system
func _on_marker_hover_end(layer_idx: int, marker_idx: int) -> void:
	# Could remove hover effects here
	pass

## Focus camera on specific layer
# INPUT: Layer index to focus on
# PROCESS: Moves camera to optimal viewing position
# OUTPUT: None
# CHANGES: Camera position, current focus layer
# CONNECTION: Camera control system
func focus_on_layer(layer_index: int) -> void:
	if layer_index < 0 or layer_index >= LAYER_COUNT:
		return
	
	current_focus_layer = layer_index
	
	if camera:
		# Calculate optimal viewing position for layer
		var target_z = LAYER_DISTANCES[layer_index] - 10.0
		var target_position = Vector3(0, 0, target_z)
		
		# Smooth camera movement (could be animated with tween)
		camera.global_position = target_position
		camera.look_at(turn_layers[layer_index].global_position, Vector3.UP)
	
	emit_signal("layer_focus_changed", layer_index)
	print("📸 Focused on layer %d: %s" % [layer_index, LAYER_NAMES[layer_index]])

## Toggle layer visibility
# INPUT: None
# PROCESS: Shows/hides entire environment
# OUTPUT: None
# CHANGES: Visibility of all layers
# CONNECTION: UI control system
func toggle_visibility() -> void:
	visible = !visible
	print("🎬 Turn layers %s" % ("visible" if visible else "hidden"))

## Advance to next turn
# INPUT: None
# PROCESS: Progresses turn system
# OUTPUT: None
# CHANGES: Current turn, updates all displays
# CONNECTION: Turn progression system
func advance_turn() -> void:
	if current_turn < 12:
		current_turn += 1
		_update_turn_displays()
		emit_signal("turn_advanced", current_turn)
		print("🔄 Advanced to turn %d" % current_turn)

## Update all turn-related displays
# INPUT: None
# PROCESS: Refreshes all visual elements
# OUTPUT: None
# CHANGES: All layer content
# CONNECTION: Display update system
func _update_turn_displays() -> void:
	# Update current turn display
	var turn_display = turn_layers[0].get_node_or_null("CurrentTurnDisplay")
	if turn_display:
		turn_display.text = "TURN %d" % current_turn
	
	# Update indicators
	for i in range(turn_indicators.size()):
		var material = turn_indicators[i].material_override as StandardMaterial3D
		if i < current_turn:
			material.albedo_color = Color.GREEN
			material.emission_enabled = true
		elif i == current_turn - 1:
			material.albedo_color = Color.YELLOW
			material.emission_enabled = true
			material.emission_intensity = 1.0
		else:
			material.albedo_color = Color(0.2, 0.2, 0.2)
			material.emission_enabled = false

## Get current state for saving
# INPUT: None
# PROCESS: Collects current state data
# OUTPUT: Dictionary of state
# CHANGES: None
# CONNECTION: Save system
func get_state() -> Dictionary:
	return {
		"current_turn": current_turn,
		"current_dimension": current_dimension,
		"current_focus_layer": current_focus_layer,
		"viewer_position": viewer_position
	}

## Restore from saved state
# INPUT: State dictionary
# PROCESS: Restores environment to saved state
# OUTPUT: None
# CHANGES: All state variables
# CONNECTION: Load system
func set_state(state: Dictionary) -> void:
	current_turn = state.get("current_turn", 5)
	current_dimension = state.get("current_dimension", 4)
	current_focus_layer = state.get("current_focus_layer", 0)
	viewer_position = state.get("viewer_position", Vector3(0, 0, -40))
	
	_update_turn_displays()
	focus_on_layer(current_focus_layer)

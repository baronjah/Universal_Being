extends Node3D
## Notepad 3D Environment Controller
## Creates layered 3D terminal interface with walkable environment
class_name Notepad3DEnvironment

# Environment configuration
const LAYER_COUNT = 5
const LAYER_DISTANCES = [5.0, 8.0, 12.0, 16.0, 20.0]
const LAYER_NAMES = ["current_text", "recent_context", "file_structure", "akashic_data", "cosmic_background"]

# Screen configuration
var screen_width: float = 20.0
var screen_height: float = 15.0
var screen_curvature: float = 0.3
var user_position: Vector3 = Vector3(0, 0, -50)  # Much further back for better view

# Layer management
var text_layers: Array[Node3D] = []
var layer_lod_settings: Array[Dictionary] = []
var current_focus_layer: int = 0

# Visual elements
var environment_container: Node3D
var walkable_area: StaticBody3D
var layer_markers: Array[Node3D] = []

# References
var camera: Camera3D
var user_controller: Node3D

signal layer_focus_changed(layer_index: int)
signal environment_ready()

func _ready() -> void:
	_create_environment_structure()
	_setup_walkable_area()
	_create_text_layers()
	_setup_layer_transitions()
	_load_demo_content()
	print("Notepad 3D Environment initialized with ", LAYER_COUNT, " layers")
	print("Press N to toggle 3D interface visibility")

func initialize(camera_node: Camera3D, controller: Node3D) -> void:
	camera = camera_node
	user_controller = controller
	
	# Position camera at user position
	if camera:
		camera.global_position = user_position
		camera.look_at(Vector3(0, 0, LAYER_DISTANCES[0]), Vector3.UP)

func _create_environment_structure() -> void:
	# Create main environment container
	environment_container = Node3D.new()
	environment_container.name = "EnvironmentContainer"
	add_child(environment_container)
	
	# Setup layer LOD configurations
	_configure_layer_lod_settings()

func _configure_layer_lod_settings() -> void:
	layer_lod_settings = [
		{  # Layer 1: Current text (closest)
			"words_per_line": 80,
			"lines_visible": 25,
			"font_size": 16,
			"transparency": 0.1,
			"glow_enabled": true,
			"animation_enabled": true,
			"interaction_enabled": true
		},
		{  # Layer 2: Recent context
			"words_per_line": 60,
			"lines_visible": 20,
			"font_size": 14,
			"transparency": 0.3,
			"glow_enabled": true,
			"animation_enabled": true,
			"interaction_enabled": false
		},
		{  # Layer 3: File structure
			"words_per_line": 40,
			"lines_visible": 15,
			"font_size": 12,
			"transparency": 0.5,
			"glow_enabled": false,
			"animation_enabled": false,
			"interaction_enabled": false
		},
		{  # Layer 4: Akashic data
			"words_per_line": 20,
			"lines_visible": 10,
			"font_size": 10,
			"transparency": 0.7,
			"glow_enabled": false,
			"animation_enabled": false,
			"interaction_enabled": false
		},
		{  # Layer 5: Cosmic background
			"words_per_line": 10,
			"lines_visible": 5,
			"font_size": 8,
			"transparency": 0.9,
			"glow_enabled": false,
			"animation_enabled": false,
			"interaction_enabled": false
		}
	]

func _create_text_layers() -> void:
	for i in range(LAYER_COUNT):
		var layer = _create_text_layer(i)
		text_layers.append(layer)
		environment_container.add_child(layer)

func _create_text_layer(layer_index: int) -> Node3D:
	var layer = Node3D.new()
	layer.name = "TextLayer_" + str(layer_index) + "_" + LAYER_NAMES[layer_index]
	
	# Position layer at appropriate distance
	layer.position = Vector3(0, 0, LAYER_DISTANCES[layer_index])
	
	# Create curved screen for this layer
	var screen = _create_curved_screen(layer_index)
	layer.add_child(screen)
	
	# Create layer marker for navigation
	var marker = _create_layer_marker(layer_index)
	layer.add_child(marker)
	layer_markers.append(marker)
	
	return layer

func _create_curved_screen(layer_index: int) -> Node3D:
	var screen = Node3D.new()
	screen.name = "CurvedScreen"
	
	# Create screen mesh with curvature
	var mesh_instance = MeshInstance3D.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(screen_width, screen_height)
	
	# Apply curvature (bend toward user)
	var curve_factor = screen_curvature * (1.0 - layer_index * 0.1)  # Less curve for far layers
	
	mesh_instance.mesh = quad_mesh
	screen.add_child(mesh_instance)
	
	# Create material with transparency based on layer
	var material = StandardMaterial3D.new()
	var lod = layer_lod_settings[layer_index]
	material.albedo_color = Color(0.1, 0.3, 0.8, 1.0 - lod.transparency)
	material.flags_transparent = true
	material.emission = Color(0.2, 0.4, 1.0) * 0.3
	mesh_instance.material_override = material
	
	return screen

func _create_layer_marker(layer_index: int) -> Node3D:
	var marker = Node3D.new()
	marker.name = "LayerMarker"
	
	# Layer colors for easy identification
	var layer_colors = [Color.WHITE, Color.CYAN, Color.GREEN, Color.YELLOW, Color.PURPLE]
	var layer_color = layer_colors[layer_index]
	
	# Create debug markers in corners and center
	var positions = [
		Vector3(-screen_width/2, screen_height/2, 0),    # Top-left
		Vector3(screen_width/2, screen_height/2, 0),     # Top-right  
		Vector3(-screen_width/2, -screen_height/2, 0),   # Bottom-left
		Vector3(screen_width/2, -screen_height/2, 0),    # Bottom-right
		Vector3(0, 0, 0)                                 # Center
	]
	
	# Create a marker at each position
	for i in range(positions.size()):
		# Create clickable area for interaction
		var button_area = Area3D.new()
		button_area.name = "LayerButton_%d_%d" % [layer_index, i]
		
		# Create collision shape
		var collision = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 0.8
		collision.shape = sphere_shape
		button_area.add_child(collision)
		
		# Create visual sphere
		var sphere = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.5 if i == 4 else 0.3  # Center marker larger
		sphere.mesh = sphere_mesh
		sphere.position = positions[i]
		
		# Create material with layer color
		var material = StandardMaterial3D.new()
		material.albedo_color = layer_color
		material.emission = layer_color * 0.8
		material.flags_unshaded = true
		sphere.material_override = material
		
		# Position button area
		button_area.position = positions[i]
		
		# Connect button signals for interaction
		button_area.input_event.connect(_on_layer_button_clicked.bind(layer_index, i))
		
		# Add text label showing layer info
		var label = Label3D.new()
		label.text = "L%d-%s" % [layer_index, ["TL","TR","BL","BR","CTR"][i]]
		label.position = Vector3(0, 0.8, 0)  # Relative to button_area
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 24
		
		# Add everything to the button area
		button_area.add_child(sphere)
		button_area.add_child(label)
		marker.add_child(button_area)
		
		print("🎬 Layer %d clickable marker created at %s with color %s" % [layer_index, positions[i], layer_color])
	
	return marker

func _setup_walkable_area() -> void:
	# Create invisible walkable area around the environment
	walkable_area = StaticBody3D.new()
	walkable_area.name = "WalkableArea"
	add_child(walkable_area)
	
	# Create large floor plane
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(50, 50)  # Large walkable area
	mesh_instance.mesh = plane_mesh
	
	# Make it invisible but walkable
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 0, 0, 0)  # Transparent
	material.flags_transparent = true
	mesh_instance.material_override = material
	walkable_area.add_child(mesh_instance)
	
	# Add collision for walking
	var collision_shape = CollisionShape3D.new()
	var plane_shape = BoxShape3D.new()
	plane_shape.size = Vector3(50, 0.1, 50)
	collision_shape.shape = plane_shape
	walkable_area.add_child(collision_shape)

func _setup_layer_transitions() -> void:
	# Setup smooth transitions between layer focus
	for i in range(text_layers.size()):
		var layer = text_layers[i]
		_apply_layer_lod(i, i == current_focus_layer)

func focus_layer(layer_index: int) -> void:
	if layer_index < 0 or layer_index >= LAYER_COUNT:
		return
	
	var old_focus = current_focus_layer
	current_focus_layer = layer_index
	
	# Update LOD for all layers
	for i in range(text_layers.size()):
		_apply_layer_lod(i, i == current_focus_layer)
	
	layer_focus_changed.emit(layer_index)
	print("Focused on layer ", layer_index, ": ", LAYER_NAMES[layer_index])

func _apply_layer_lod(layer_index: int, is_focused: bool) -> void:
	var layer = text_layers[layer_index]
	var lod = layer_lod_settings[layer_index]
	
	# Adjust visibility based on focus
	var focus_multiplier = 1.5 if is_focused else 1.0
	var alpha = (1.0 - lod.transparency) * focus_multiplier
	
	# Apply to screen material
	var screen = layer.get_node("CurvedScreen")
	if screen:
		var mesh_instance = screen.get_child(0)
		if mesh_instance and mesh_instance.material_override:
			var material = mesh_instance.material_override
			var current_color = material.albedo_color
			material.albedo_color = Color(current_color.r, current_color.g, current_color.b, alpha)
			
			# Enhance emission for focused layer
			if is_focused:
				material.emission_energy = 0.5
			else:
				material.emission_energy = 0.2

# Navigation functions
func move_to_layer(layer_index: int, smooth: bool = true) -> void:
	if layer_index < 0 or layer_index >= LAYER_COUNT:
		return
	
	focus_layer(layer_index)
	
	if camera and smooth:
		# Smooth camera movement to optimal viewing position for layer
		var target_pos = user_position + Vector3(0, 0, -LAYER_DISTANCES[layer_index] * 0.3)
		var tween = create_tween()
		tween.tween_property(camera, "global_position", target_pos, 1.0)

func auto_frame_current_layer() -> void:
	if current_focus_layer < text_layers.size():
		move_to_layer(current_focus_layer, true)

# Text content management
func set_layer_content(layer_index: int, content: Array) -> void:
	if layer_index >= text_layers.size():
		return
	
	var layer = text_layers[layer_index]
	var lod = layer_lod_settings[layer_index]
	
	# Clear existing content
	_clear_layer_content(layer)
	
	# Add new content based on LOD settings
	_populate_layer_content(layer, content, lod)

func _clear_layer_content(layer: Node3D) -> void:
	# Remove existing text nodes (keep screen and marker)
	for child in layer.get_children():
		if child.name.begins_with("TextNode"):
			child.queue_free()

func _populate_layer_content(layer: Node3D, content: Array, lod_settings: Dictionary) -> void:
	var lines_to_show = min(content.size(), lod_settings.lines_visible)
	var words_per_line = lod_settings.words_per_line
	
	for i in range(lines_to_show):
		if i < content.size():
			var line_content = str(content[i])
			_create_text_line(layer, line_content, i, lod_settings)

func _create_text_line(layer: Node3D, text: String, line_index: int, lod_settings: Dictionary) -> void:
	var text_node = Node3D.new()
	text_node.name = "TextNode_" + str(line_index)
	
	# Position line
	var line_height = 0.8
	var start_y = (lod_settings.lines_visible * line_height) * 0.5
	text_node.position = Vector3(-screen_width * 0.4, start_y - line_index * line_height, 0.1)
	
	# Create 3D text
	var label_3d = Label3D.new()
	label_3d.text = text.substr(0, lod_settings.words_per_line)  # Limit words per line
	label_3d.font_size = lod_settings.font_size
	
	# Apply LOD visual settings
	var alpha = 1.0 - lod_settings.transparency
	label_3d.modulate = Color(1, 1, 1, alpha)
	
	if lod_settings.glow_enabled:
		label_3d.outline_size = 2
		label_3d.outline_modulate = Color(0.5, 0.8, 1.0, alpha * 0.5)
	
	text_node.add_child(label_3d)
	layer.add_child(text_node)

# Debug and utility functions
func get_layer_info() -> Dictionary:
	return {
		"total_layers": LAYER_COUNT,
		"current_focus": current_focus_layer,
		"focus_layer_name": LAYER_NAMES[current_focus_layer],
		"user_position": user_position,
		"layer_distances": LAYER_DISTANCES
	}

func cycle_layer_focus(direction: int = 1) -> void:
	var new_focus = (current_focus_layer + direction) % LAYER_COUNT
	if new_focus < 0:
		new_focus = LAYER_COUNT - 1
	focus_layer(new_focus)

func toggle_3d_interface() -> void:
	visible = !visible
	print("Notepad 3D Interface ", "visible" if visible else "hidden")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 LAYER BUTTON INTERACTION - CLICKABLE MARKERS
# ─────────────────────────────────────────────────────────────────────────────────
func _on_layer_button_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, layer_index: int, button_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var button_names = ["Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right", "Center"]
		var layer_names = ["Current Text", "Recent Context", "File Structure", "Akashic Data", "Cosmic Background"]
		
		print("🎮 Clicked Layer %d (%s) - %s button" % [layer_index, layer_names[layer_index], button_names[button_index]])
		
		# Different actions based on button position
		match button_index:
			0, 1:  # Top buttons - navigation
				_handle_layer_navigation(layer_index, button_index)
			2, 3:  # Bottom buttons - settings  
				_handle_layer_settings(layer_index, button_index)
			4:     # Center button - focus layer
				_focus_on_layer(layer_index)
				
func _handle_layer_navigation(layer_index: int, button_index: int) -> void:
	if button_index == 0:  # Top-left - previous layer
		if layer_index > 0:
			cycle_layer_focus(-1)
	else:  # Top-right - next layer
		if layer_index < LAYER_COUNT - 1:
			cycle_layer_focus(1)
			
func _handle_layer_settings(layer_index: int, button_index: int) -> void:
	print("🔧 Opening settings for layer %d" % layer_index)
	# TODO: Implement layer-specific settings
	
func _focus_on_layer(layer_index: int) -> void:
	current_focus_layer = layer_index
	print("🎯 Focused on layer %d: %s" % [layer_index, LAYER_NAMES[layer_index]])
	layer_focus_changed.emit(layer_index)

func _load_demo_content() -> void:
	# Load demo content for each layer
	var demo_content = [
		# Layer 0: Current text
		[
			"// Akashic Records Notepad 3D - Current Writing Space",
			"extends Node3D",
			"",
			"# The current text layer shows what you're actively working on",
			"# This is your primary writing and editing space",
			"func create_reality():",
			"    var universe = Universe.new()",
			"    universe.expand_consciousness()",
			"    return universe.manifest_dreams()",
			"",
			"# Words here are fully interactive and editable",
			"# Press E to interact, R to evolve words",
			"var consciousness_expansion = true",
			"var reality_manifestation = 'active'",
			"var akashic_connection = 'established'"
		],
		# Layer 1: Recent context
		[
			"Previous editing session context...",
			"Recent changes and modifications",
			"File: akashic_navigator.gd - Line 45",
			"Added heptagon evolution system",
			"Integrated with WordDatabase autoload",
			"Connected navigation hierarchy",
			"Modified camera positioning",
			"Enhanced LOD optimization",
			"Recent words: [consciousness, evolution, manifestation]",
			"Last focused layer: cosmic_background"
		],
		# Layer 2: File structure
		[
			"Project File Structure:",
			"scripts/",
			"  autoload/",
			"    akashic_navigator.gd",
			"    word_database.gd",
			"    game_manager.gd",
			"  core/",
			"    main_game_controller.gd",
			"    notepad3d_environment.gd",
			"    lod_manager.gd",
			"scenes/",
			"  main_game.tscn"
		],
		# Layer 3: Akashic data
		[
			"Akashic Records Database:",
			"Multiverses -> Universes -> Galaxies",
			"Current Level: Multiverses",
			"Word Evolution Count: 127",
			"Consciousness Frequency: 432Hz",
			"Reality Harmonics: Stable",
			"Dimensional Bridges: Active",
			"Akashic Connection Strength: 98%"
		],
		# Layer 4: Cosmic background
		[
			"∞ Cosmic Background ∞",
			"◇ Universal Constants ◇",
			"△ Sacred Geometry △",
			"⟡ Quantum Entanglement ⟡",
			"☰ I-Ching Harmonics ☰"
		]
	]
	
	# Apply content to layers
	for i in range(min(demo_content.size(), LAYER_COUNT)):
		set_layer_content(i, demo_content[i])
extends Node3D
class_name Unified3DProgrammingAkashicSystem

# 🌌 UNIFIED 3D PROGRAMMING + NOTEPAD 3D + AKASHIC RECORDS SYSTEM
# Single integrated system combining all three features:
# - 3D Visual Programming (function blocks, connections)
# - 3D Notepad (floating spatial text editing)  
# - Akashic Records (infinite database with chunks LOD)

signal programming_node_created(node: Node3D, type: String)
signal notepad_text_created(text_node: Label3D, content: String)
signal akashic_chunk_loaded(chunk_id: String, data: Dictionary)
signal connection_established(from_node: Node3D, to_node: Node3D)

# Pentagon Architecture Variables
var consciousness_level: int = 5
var being_type: String = "unified_3d_programming_akashic"
var being_name: String = "Infinite Programming Universe"

# Unified System State
var game_state: GameState = GameState.NORMAL
var camera_rotation: Vector2 = Vector2.ZERO
var move_speed: float = 20.0
var look_speed: float = 0.002

# 3D Programming Components
var programming_nodes: Array[Node3D] = []
var connections: Array[Dictionary] = []
var selected_node: Node3D = null
var dragging_connection: bool = false
var connection_start_socket: Node3D = null

# 3D Notepad Components  
var notepad_layers: Array[Dictionary] = []
var floating_texts: Array[Label3D] = []
var text_editing_mode: bool = false
var current_editing_text: Label3D = null
var virtual_keyboard: Control = null

# Akashic Records Components
var akashic_chunks: Dictionary = {}  # chunk_id -> chunk_data
var chunk_meshes: Dictionary = {}    # chunk_id -> visual representation
var loaded_chunks: Dictionary = {}   # currently loaded chunks
var max_render_distance: float = 200.0
var chunk_size: float = 50.0
var current_lod_level: int = 1

# Visual Configuration
var stellar_colors: Array[Color] = [
	Color(0.0, 0.0, 0.0),      # 0: Void
	Color(0.2, 0.1, 0.0),      # 1: Brown dwarf  
	Color(0.8, 0.0, 0.0),      # 2: Red giant
	Color(1.0, 0.5, 0.0),      # 3: Orange star
	Color(1.0, 1.0, 0.0),      # 4: Yellow sun
	Color(1.0, 1.0, 1.0),      # 5: White dwarf
	Color(0.7, 0.9, 1.0),      # 6: Blue giant
	Color(0.0, 0.5, 1.0),      # 7: Blue supergiant
	Color(0.5, 0.0, 1.0)       # 8: Violet pulsar
]

enum GameState {
	NORMAL,
	PROGRAMMING_MODE,
	NOTEPAD_MODE,
	AKASHIC_MODE,
	TEXT_EDITING,
	CONNECTING_NODES
}

# Pentagon Lifecycle Implementation
func pentagon_init() -> void:
	if has_method("pentagon_init"):
		super.pentagon_init()
	being_type = "unified_3d_programming_akashic"
	being_name = "Infinite Programming Universe"
	consciousness_level = 5
	initialize_unified_system()

func pentagon_ready() -> void:
	if has_method("pentagon_ready"):
		super.pentagon_ready()
	setup_unified_environment()
	create_initial_programming_blocks()
	initialize_akashic_chunks()
	setup_3d_notepad_layers()
	connect_to_flood_gates()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	UBPrint.log_message("🌌 Unified 3D Programming + Notepad + Akashic System ready", UBPrint.LogLevel.INFO)

func pentagon_process(delta: float) -> void:
	if has_method("pentagon_process"):
		super.pentagon_process(delta)
	handle_movement(delta)
	update_programming_system(delta)
	update_notepad_system(delta)
	update_akashic_system(delta)
	update_visual_effects(delta)

func pentagon_input(event: InputEvent) -> void:
	if has_method("pentagon_input"):
		super.pentagon_input(event)
	handle_unified_input(event)

func pentagon_sewers() -> void:
	save_all_data_to_akashic()
	cleanup_all_systems()
	if has_method("pentagon_sewers"):
		super.pentagon_sewers()

# Unified System Initialization
func initialize_unified_system() -> void:
	# Initialize all three subsystems as one
	programming_nodes = []
	connections = []
	notepad_layers = []
	floating_texts = []
	akashic_chunks = {}
	chunk_meshes = {}
	loaded_chunks = {}

func setup_unified_environment() -> void:
	# Create space environment with stars that serve multiple purposes
	create_stellar_environment()
	
	# Setup camera system
	var camera = Camera3D.new()
	camera.name = "UnifiedCamera"
	camera.position = Vector3(0, 5, 10)
	add_child(camera)

func create_stellar_environment() -> void:
	# Create 100 stars that serve as:
	# - Background environment
	# - Akashic data points
	# - Programming node anchors
	# - Notepad text anchors
	
	for i in range(100):
		var star = create_multi_purpose_star(i)
		add_child(star)

func create_multi_purpose_star(index: int) -> Node3D:
	var star = Node3D.new()
	star.name = "UnifiedStar_" + str(index)
	
	# Position in sphere around origin
	var angle1 = randf() * PI * 2
	var angle2 = randf() * PI * 2  
	var radius = randf_range(50, 300)
	star.position = Vector3(
		sin(angle1) * cos(angle2) * radius,
		sin(angle2) * radius,
		cos(angle1) * cos(angle2) * radius
	)
	
	# Create visual mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radius = 0.5
	
	# Color based on function (programming, notepad, or akashic)
	var star_type = index % 3
	var color_index = 5  # Default white
	
	match star_type:
		0: # Programming star
			color_index = 6  # Blue - for programming nodes
			star.set_meta("type", "programming")
			star.set_meta("function_type", get_random_programming_function())
		1: # Notepad star  
			color_index = 4  # Yellow - for text nodes
			star.set_meta("type", "notepad")
			star.set_meta("text_content", "")
		2: # Akashic star
			color_index = 7  # Deep blue - for data storage
			star.set_meta("type", "akashic")
			star.set_meta("data_type", get_random_akashic_type())
	
	var material = StandardMaterial3D.new()
	material.albedo_color = stellar_colors[color_index]
	material.emission_enabled = true
	material.emission = stellar_colors[color_index] * 0.5
	material.emission_energy = 1.0
	mesh_instance.material_override = material
	
	star.add_child(mesh_instance)
	
	# Add interaction capability
	add_star_interaction_system(star)
	
	return star

func add_star_interaction_system(star: Node3D) -> void:
	# Add Area3D for interaction detection
	var area = Area3D.new()
	area.name = "InteractionArea"
	
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 2.0
	collision.shape = sphere_shape
	
	area.add_child(collision)
	star.add_child(area)
	
	# Connect interaction signals
	area.mouse_entered.connect(_on_star_mouse_entered.bind(star))
	area.mouse_exited.connect(_on_star_mouse_exited.bind(star))

# Unified Input Handling
func handle_unified_input(event: InputEvent) -> void:
	# Mouse look (always active when captured)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.x * look_speed
		camera_rotation.y = clamp(camera_rotation.y - event.relative.y * look_speed, -1.5, 1.5)
		get_child(0).rotation = Vector3(camera_rotation.y, camera_rotation.x, 0)  # Camera rotation
	
	# Mode switching
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_mode()
	elif event.is_action_pressed("programming_mode"):
		switch_to_mode(GameState.PROGRAMMING_MODE)
	elif event.is_action_pressed("notepad_mode"):
		switch_to_mode(GameState.NOTEPAD_MODE)
	elif event.is_action_pressed("akashic_mode"):
		switch_to_mode(GameState.AKASHIC_MODE)
	
	# Context-sensitive actions based on current mode
	match game_state:
		GameState.PROGRAMMING_MODE:
			handle_programming_input(event)
		GameState.NOTEPAD_MODE:
			handle_notepad_input(event)
		GameState.AKASHIC_MODE:
			handle_akashic_input(event)
		GameState.NORMAL:
			handle_general_input(event)

func handle_programming_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_function_block"):
		create_programming_node_at_cursor()
	elif event.is_action_pressed("connect_nodes"):
		start_node_connection()
	elif event.is_action_pressed("delete_node"):
		delete_selected_node()

func handle_notepad_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_text_note"):
		create_3d_text_note()
	elif event.is_action_pressed("edit_text"):
		edit_nearest_text()
	elif event.is_action_pressed("layer_up"):
		move_to_upper_notepad_layer()
	elif event.is_action_pressed("layer_down"):
		move_to_lower_notepad_layer()

func handle_akashic_input(event: InputEvent) -> void:
	if event.is_action_pressed("query_akashic"):
		query_akashic_at_cursor()
	elif event.is_action_pressed("store_akashic"):
		store_data_to_akashic()
	elif event.is_action_pressed("increase_lod"):
		increase_akashic_lod()
	elif event.is_action_pressed("decrease_lod"):
		decrease_akashic_lod()

func handle_general_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_with_nearest_star()
	elif event.is_action_pressed("inspect"):
		inspect_nearest_object()

# Movement System (Unified)
func handle_movement(delta: float) -> void:
	var camera = get_child(0) as Camera3D
	if not camera:
		return
	
	var input_vector = Vector3()
	if Input.is_action_pressed("move_forward"):
		input_vector.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_vector.z += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y += 1
	if Input.is_action_pressed("move_down"):
		input_vector.y -= 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		input_vector = camera.global_transform.basis * input_vector
		camera.global_position += input_vector * move_speed * delta

# 3D Programming System Integration
func create_initial_programming_blocks() -> void:
	# Create fundamental Pentagon blocks
	create_programming_node("PENTAGON_INIT", Vector3(-10, 0, 0), "init")
	create_programming_node("PENTAGON_READY", Vector3(-5, 0, 0), "ready") 
	create_programming_node("PENTAGON_PROCESS", Vector3(0, 0, 0), "process")
	create_programming_node("PENTAGON_INPUT", Vector3(5, 0, 0), "input")
	create_programming_node("PENTAGON_SEWERS", Vector3(10, 0, 0), "sewers")
	
	# Create utility blocks
	create_programming_node("AKASHIC_QUERY", Vector3(0, 5, 0), "akashic")
	create_programming_node("NOTEPAD_CREATE", Vector3(0, -5, 0), "notepad")

func create_programming_node(name: String, position: Vector3, node_type: String) -> Node3D:
	var node = Node3D.new()
	node.name = "ProgrammingNode_" + name
	node.position = position
	
	# Create visual representation
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(2, 1, 2)
	
	# Color based on type
	var color_index = 4  # Default yellow
	match node_type:
		"init": color_index = 2    # Red
		"ready": color_index = 3   # Orange  
		"process": color_index = 4 # Yellow
		"input": color_index = 6   # Blue
		"sewers": color_index = 8  # Violet
		"akashic": color_index = 7 # Deep blue
		"notepad": color_index = 5 # White
	
	var material = StandardMaterial3D.new()
	material.albedo_color = stellar_colors[color_index]
	material.emission_enabled = true
	material.emission = stellar_colors[color_index] * 0.3
	mesh_instance.material_override = material
	
	node.add_child(mesh_instance)
	
	# Add label
	var label = Label3D.new()
	label.text = name
	label.position = Vector3(0, 1.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.add_child(label)
	
	# Add to programming system
	programming_nodes.append(node)
	add_child(node)
	
	# Store metadata
	node.set_meta("node_type", node_type)
	node.set_meta("function_name", name)
	
	programming_node_created.emit(node, node_type)
	return node

# 3D Notepad System Integration
func setup_3d_notepad_layers() -> void:
	# Create initial notepad layers at different heights
	for i in range(5):
		var layer_data = {
			"layer_id": i,
			"height": i * 10.0,
			"texts": [],
			"active": i == 0
		}
		notepad_layers.append(layer_data)

func create_3d_text_note() -> Label3D:
	var camera = get_child(0) as Camera3D
	var spawn_position = camera.global_position + (-camera.global_transform.basis.z * 5)
	
	var text_node = Label3D.new()
	text_node.text = "New 3D Note - Click to edit"
	text_node.position = spawn_position
	text_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_node.modulate = stellar_colors[4]  # Yellow
	
	add_child(text_node)
	floating_texts.append(text_node)
	
	# Add to current notepad layer
	var current_layer = get_current_notepad_layer()
	current_layer.texts.append(text_node)
	
	notepad_text_created.emit(text_node, text_node.text)
	return text_node

func get_current_notepad_layer() -> Dictionary:
	for layer in notepad_layers:
		if layer.active:
			return layer
	return notepad_layers[0]  # Fallback

# Akashic Records System Integration
func initialize_akashic_chunks() -> void:
	# Generate initial chunks around origin
	for x in range(-2, 3):
		for y in range(-2, 3):
			for z in range(-2, 3):
				var chunk_pos = Vector3(x, y, z)
				var chunk_id = get_chunk_id(chunk_pos)
				create_akashic_chunk(chunk_id, chunk_pos)

func create_akashic_chunk(chunk_id: String, chunk_pos: Vector3) -> void:
	var chunk_data = {
		"id": chunk_id,
		"position": chunk_pos,
		"programming_nodes": [],
		"notepad_texts": [],
		"data_entries": generate_chunk_data(chunk_pos),
		"creation_time": Time.get_unix_time_from_system()
	}
	
	akashic_chunks[chunk_id] = chunk_data
	loaded_chunks[chunk_id] = chunk_data
	
	# Create visual representation
	var chunk_visual = create_chunk_visual(chunk_data)
	chunk_meshes[chunk_id] = chunk_visual
	add_child(chunk_visual)
	
	akashic_chunk_loaded.emit(chunk_id, chunk_data)

func create_chunk_visual(chunk_data: Dictionary) -> Node3D:
	var chunk_node = Node3D.new()
	chunk_node.name = "AkashicChunk_" + chunk_data.id
	
	var chunk_pos = chunk_data.position as Vector3
	chunk_node.position = chunk_pos * chunk_size
	
	# Create wireframe box to show chunk boundaries
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(chunk_size * 0.9, chunk_size * 0.9, chunk_size * 0.9)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = stellar_colors[6]  # Blue
	material.flags_unshaded = true
	material.flags_use_point_size = true
	material.flags_transparent = true
	material.albedo_color.a = 0.1
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	mesh_instance.material_override = material
	chunk_node.add_child(mesh_instance)
	
	return chunk_node

# Unified Update Systems
func update_programming_system(delta: float) -> void:
	# Update programming node connections
	update_node_connections()
	
	# Handle node selection and interaction
	handle_node_selection()

func update_notepad_system(delta: float) -> void:
	# Update floating text animations
	for text in floating_texts:
		if is_instance_valid(text):
			# Gentle floating animation
			text.position.y += sin(Time.get_time_from_start() + text.position.x) * 0.01

func update_akashic_system(delta: float) -> void:
	# Update chunk LOD based on camera distance
	var camera = get_child(0) as Camera3D
	if camera:
		update_chunk_lod(camera.global_position)

func update_visual_effects(delta: float) -> void:
	# Global visual updates for all systems
	update_stellar_environment(delta)

# Utility Functions
func switch_to_mode(new_mode: GameState) -> void:
	game_state = new_mode
	UBPrint.log_message("🔄 Switched to mode: " + str(new_mode), UBPrint.LogLevel.DEBUG)
	
	# Update UI/visual feedback based on mode
	update_mode_visualization()

func update_mode_visualization() -> void:
	# Highlight relevant elements based on current mode
	match game_state:
		GameState.PROGRAMMING_MODE:
			highlight_programming_elements()
		GameState.NOTEPAD_MODE:
			highlight_notepad_elements()
		GameState.AKASHIC_MODE:
			highlight_akashic_elements()

func toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func interact_with_nearest_star() -> void:
	var camera = get_child(0) as Camera3D
	var nearest_star = find_nearest_star(camera.global_position)
	
	if nearest_star:
		var star_type = nearest_star.get_meta("type", "")
		match star_type:
			"programming":
				convert_star_to_programming_node(nearest_star)
			"notepad":
				convert_star_to_text_node(nearest_star)
			"akashic":
				query_star_akashic_data(nearest_star)

func find_nearest_star(position: Vector3) -> Node3D:
	var nearest: Node3D = null
	var min_distance = INF
	
	for child in get_children():
		if child.name.begins_with("UnifiedStar_"):
			var distance = position.distance_to(child.global_position)
			if distance < min_distance and distance < 10.0:  # Max interaction distance
				min_distance = distance
				nearest = child
	
	return nearest

# Integration Helper Functions
func convert_star_to_programming_node(star: Node3D) -> void:
	var function_type = star.get_meta("function_type", "custom")
	var node = create_programming_node("STAR_FUNCTION", star.position, function_type)
	UBPrint.log_message("⭐ Converted star to programming node", UBPrint.LogLevel.INFO)

func convert_star_to_text_node(star: Node3D) -> void:
	var text_node = Label3D.new()
	text_node.text = "Star Note: " + star.name
	text_node.position = star.position
	text_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(text_node)
	floating_texts.append(text_node)
	UBPrint.log_message("📝 Converted star to text node", UBPrint.LogLevel.INFO)

func query_star_akashic_data(star: Node3D) -> void:
	var data_type = star.get_meta("data_type", "memory")
	UBPrint.log_message("🔍 Querying star akashic data: " + data_type, UBPrint.LogLevel.INFO)
	# TODO: Display akashic data interface

# Data Generation and Management
func get_random_programming_function() -> String:
	var functions = ["init", "ready", "process", "input", "sewers", "custom", "utility"]
	return functions[randi() % functions.size()]

func get_random_akashic_type() -> String:
	var types = ["memory", "timeline", "consciousness", "data", "script"]
	return types[randi() % types.size()]

func generate_chunk_data(chunk_pos: Vector3) -> Array:
	var data = []
	var entry_count = randi() % 10 + 5  # 5-14 entries per chunk
	
	for i in range(entry_count):
		data.append({
			"type": get_random_akashic_type(),
			"content": "Data entry " + str(i) + " at " + str(chunk_pos),
			"timestamp": Time.get_unix_time_from_system()
		})
	
	return data

func get_chunk_id(chunk_pos: Vector3) -> String:
	return str(int(chunk_pos.x)) + "_" + str(int(chunk_pos.y)) + "_" + str(int(chunk_pos.z))

# Signal Handlers
func _on_star_mouse_entered(star: Node3D) -> void:
	# Highlight star on mouse over
	var mesh = star.get_child(0) as MeshInstance3D
	if mesh and mesh.material_override:
		mesh.material_override.emission_energy = 2.0

func _on_star_mouse_exited(star: Node3D) -> void:
	# Remove highlight
	var mesh = star.get_child(0) as MeshInstance3D
	if mesh and mesh.material_override:
		mesh.material_override.emission_energy = 1.0

# System Integration
func connect_to_flood_gates() -> void:
	var flood_gates = get_node_or_null("/root/SystemBootstrap")
	if flood_gates and flood_gates.has_method("register_being"):
		flood_gates.register_being(self)

func save_all_data_to_akashic() -> void:
	# Save programming nodes, notepad texts, and akashic data as unified system
	var unified_save_data = {
		"programming_nodes": serialize_programming_nodes(),
		"notepad_layers": serialize_notepad_layers(),
		"akashic_chunks": serialize_akashic_chunks(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# TODO: Save to persistent storage
	UBPrint.log_message("💾 Saved unified system data", UBPrint.LogLevel.INFO)

func cleanup_all_systems() -> void:
	programming_nodes.clear()
	connections.clear()
	floating_texts.clear()
	notepad_layers.clear()
	akashic_chunks.clear()
	loaded_chunks.clear()
	chunk_meshes.clear()

# Placeholder functions for full implementation
func update_node_connections() -> void:
	pass

func handle_node_selection() -> void:
	pass

func update_chunk_lod(camera_position: Vector3) -> void:
	pass

func update_stellar_environment(delta: float) -> void:
	pass

func highlight_programming_elements() -> void:
	pass

func highlight_notepad_elements() -> void:
	pass

func highlight_akashic_elements() -> void:
	pass

func create_programming_node_at_cursor() -> void:
	pass

func start_node_connection() -> void:
	pass

func delete_selected_node() -> void:
	pass

func edit_nearest_text() -> void:
	pass

func move_to_upper_notepad_layer() -> void:
	pass

func move_to_lower_notepad_layer() -> void:
	pass

func query_akashic_at_cursor() -> void:
	pass

func store_data_to_akashic() -> void:
	pass

func increase_akashic_lod() -> void:
	pass

func decrease_akashic_lod() -> void:
	pass

func inspect_nearest_object() -> void:
	pass

func serialize_programming_nodes() -> Array:
	return []

func serialize_notepad_layers() -> Array:
	return []

func serialize_akashic_chunks() -> Dictionary:
	return {}
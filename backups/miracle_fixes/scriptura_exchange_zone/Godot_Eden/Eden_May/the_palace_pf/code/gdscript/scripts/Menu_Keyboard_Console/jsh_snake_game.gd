#
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_snake_game.gd
#
# JSH_World/snake
# 


extends Node
class_name JSHSnakeGame

# JSH_World/game
#
# res://code/gdscript/scripts/Snake_Space_Movement/snake_game.gd
# Snake game implementation for JSH system

# References
var main_ref = null
var animator = null
var thread_pool = null
var keyboard_handler = null

# Game state
enum GameState { MENU, READY, PLAYING, GAME_OVER }
var current_state = GameState.READY
var score = 0
var high_score = 0
var difficulty = "normal"

# Grid settings
var grid_size = Vector2i(20, 20)
var cell_size = 0.5
var grid_offset = Vector3(-5, 0, -5)  # Center grid in world space

# Snake properties
var snake_segments = []
var snake_direction = Vector2i(1, 0)  # Start moving right
var next_direction = Vector2i(1, 0)
var snake_speed = 5.0  # Moves per second
var time_since_last_move = 0.0

# Food
var food_position = Vector2i(0, 0)
var food_node = null
var food_count = 0

# Visual elements
var grid_cells = []
var segment_meshes = []
var grid_lines = []
var score_display = null
var message_display = null

# Materials
var snake_material
var food_material
var grid_material
var head_material

# ======== CORE FUNCTIONS ========







	# Check for collision with self (except the last segment which will move)
	#for i in range

#KKnts
const GRID_SIZE = 20
const CELL_SIZE = 0.5
const INITIAL_SNAKE_LENGTH = 3
const MOVE_DELAY = 0.2

# Game state
#var snake_segments = []
#var snake_direction = Vector2.RIGHT
#var next_direction = Vector2.RIGHT
#var food_position = Vector2.ZERO
var game_over = false
#var score = 0
var paused = false

# Speed settings
var current_speed = 1

# References
var grid
var info_text
var score_text
var timer = 0.0
#var main_ref

# Visual components
var snake_head_mesh
var snake_body_mesh
var food_mesh
var speed_multipliers = {
	1: 1.0,    # Normal speed
	2: 0.7,    # Faster
	3: 0.4     # Fastest
}

##










#
#
#extends Node3D
#class_name JSHIntegratedSystem
#
## JSH_World/integrated_system
#
# This script combines keyboard, menu, console and snake game functionality
# into a cohesive system with layered display and command processing

# References to main subsystems
var console_system: JSHConsole
var keyboard_system
var menu_handler: SnakeMenuHandler
var snake_game
var records_system
#var thread_pool
var task_manager

# Camera and view settings
var main_camera: Camera3D
var player_head: MeshInstance3D
var current_view_mode = "terminal" # terminal, game, menu
var camera_transition_speed = 2.0

# Window management
var window_layers = []
var active_windows = []
var window_positions = {}

# Logging system
var log_entries = []
var max_log_entries = 100
var error_counts = {}

# Scene management
var current_scene_number = 0
var scene_data = {}
var data_point_references = {}

# ======== CORE SYSTEM FUNCTIONS ========

func _ready_add():
	# Initialize subsystems
	initialize_console()
	initialize_keyboard()
	initialize_menu_system()
	initialize_camera()
	initialize_thread_system()
	initialize_records_system()
	
	# Setup initial layout
	setup_window_layers()
	
	# Log startup
	log_message("JSH Integrated System initialized", "info")
	
	# Show initial menu
	show_main_menu()

func _process_add(delta):
	# Process camera transitions
	update_camera(delta)
	
	# Process active windows
	for window in active_windows:
		if window.has_method("process_window"):
			window.process_window(delta)












func _ready_add0():
	# Find main reference
	var scene_root = get_tree().get_root()
	if scene_root.has_node("main"):
		main_ref = scene_root.get_node("main")
	
	# Initialize thread pool
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	
	# Initialize visual components
	initialize_materials()
	create_grid()
	create_ui_elements()
	
	# Initialize snake
	initialize_snake()
	spawn_food()
	
	# Initialize animator
	initialize_animator()
	#
func _process_add0(delta):
	match current_state:
		GameState.READY:
			# Wait for space to start
			if Input.is_action_just_pressed("ui_accept"):
				start_game()
		
		GameState.PLAYING:
			# Update time
			time_since_last_move += delta
			
			# Check if it's time to move
			if time_since_last_move >= 1.0 / snake_speed:
				time_since_last_move = 0
				move_snake()
			
			# Process input
			handle_input()
			
			# Update animations
			if animator:
				animator.process_animations(delta, snake_segments, get_viewport().get_camera_3d())
		
		GameState.GAME_OVER:
			# Wait for space to restart
			if Input.is_action_just_pressed("ui_accept"):
				reset_game()
				current_state = GameState.READY
































# ======== INITIALIZATION FUNCTIONS ========

func initialize_console():
	console_system = JSHConsole.new()
	console_system.name = "JSH_Console"
	add_child(console_system)
	console_system.setup_main_reference(self)
	
	# Register base commands
	register_console_commands()

func initialize_keyboard():
	# Create keyboard container
	var keyboard_container = Node3D.new()
	keyboard_container.name = "keyboard_container"
	add_child(keyboard_container)
	
	# Setup datapoint for keyboard
	var datapoint = Node3D.new()
	datapoint.name = "thing_24"  # Standard name from JSH system
	datapoint.script = load("res://code/gdscript/scripts/Menu_Keyboard_Console/data_point.gd")
	keyboard_container.add_child(datapoint)
	
	# Store reference
	keyboard_system = datapoint
	
	# Initialize keyboard
	if datapoint.has_method("setup_text_handling"):
		datapoint.setup_text_handling()
	
	# Position keyboard container
	keyboard_container.position = Vector3(0, -2, -4)

func initialize_menu_system():
	# Create menu container
	var menu_container = Node3D.new()
	menu_container.name = "snake_menu_container"
	add_child(menu_container)
	
	# Setup menu handler
	menu_handler = SnakeMenuHandler.new()
	menu_handler.name = "menu_handler"
	menu_container.add_child(menu_handler)
	
	# Setup reference to main node
	menu_handler.main_ref = self
	
	# Initially hide menu
	menu_container.visible = false

func initialize_camera():
	# Create camera
	main_camera = Camera3D.new()
	main_camera.name = "main_camera"
	add_child(main_camera)
	
	# Set initial position
	main_camera.position = Vector3(0, 1.7, 0)
	main_camera.current = true
	
	# Create player head (sphere)
	player_head = MeshInstance3D.new()
	player_head.name = "player_head"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	player_head.mesh = sphere_mesh
	
	# Create material for head
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 0.9)
	material.metallic = 0.2
	material.roughness = 0.3
	player_head.material_override = material
	
	# Set position slightly below camera
	player_head.position = Vector3(0, 1.5, 0)
	add_child(player_head)

func initialize_thread_system():
	# Get global thread pool if available
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	
	# Create task manager
	task_manager = Node.new()
	task_manager.name = "JSH_task_manager"
	add_child(task_manager)
	
	# Add task tracking functionality
	task_manager.set_script(load("res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_thread_pool_manager.gd"))

func initialize_records_system():
	# Create records system
	records_system = Node.new()
	records_system.name = "JSH_records_system"
	records_system.set_script(load("res://code/gdscript/scripts/Menu_Keyboard_Console/JSH_records_system.gd"))
	add_child(records_system)

# ======== WINDOW MANAGEMENT ========

func setup_window_layers():
	# Define window layers (z-positions)
	window_layers = [
		{"name": "background", "z": -10.0},
		{"name": "game", "z": -8.0},
		{"name": "menu", "z": -6.0},
		{"name": "console", "z": -4.0},
		{"name": "hud", "z": -2.0}
	]
	
	# Define default window positions
	window_positions = {
		"console": Vector3(0, 1.5, window_layers[3].z),
		"keyboard": Vector3(0, -1.0, window_layers[3].z),
		"menu": Vector3(0, 1.0, window_layers[2].z),
		"snake_game": Vector3(0, 0.5, window_layers[1].z),
		"error_log": Vector3(3.0, 1.5, window_layers[4].z)
	}
	
	# Position the console and keyboard
	console_system.position = window_positions.console
	get_node("keyboard_container").position = window_positions.keyboard

# ======== SCENE MANAGEMENT ========



























































func show_scene(scene_number):
	current_scene_number = scene_number
	
	# Find datapoints that need to be updated
	for container_name in data_point_references:
		var datapoint = data_point_references[container_name]
		if datapoint.has_method("scene_to_set_number_later"):
			datapoint.scene_to_set_number_later(scene_number)
	
	log_message("Changed to scene " + str(scene_number), "system")

func upload_scene_data(container_name, scene_data):
	# Store scene data for reference
	if !scene_data.has(container_name):
		scene_data[container_name] = []
	
	scene_data[container_name].append(scene_data)
	
	# Pass to datapoint if available
	if data_point_references.has(container_name):
		var datapoint = data_point_references[container_name]
		if datapoint.has_method("upload_scenes_frames"):
			datapoint.upload_scenes_frames(scene_data[0], scene_data[1])

# ======== MENU SYSTEM ========

func show_main_menu():
	var menu_container = get_node("snake_menu_container")
	menu_container.visible = true
	
	# Set view mode
	set_view_mode("menu")
	
	# Tell menu handler to show main menu (page 0)
	menu_handler.show_menu_page(0)

func hide_menu_container(container_name):
	var container = get_node_or_null(container_name)
	if container:
		container.visible = false

func show_menu_scene(menu_name, page_index):
	if menu_name == "snake_menu":
		var menu_container = get_node("snake_menu_container")
		menu_container.visible = true
		
		# Create appropriate menu page
		menu_handler._create_menu_page(page_index)

# ======== SNAKE GAME ========

func launch_snake_game(difficulty = "normal"):
	# Hide menu
	hide_menu_container("snake_menu_container")
	
	# Create snake game if needed
	if !snake_game:
		create_snake_game(difficulty)
	else:
		# Show existing game
		snake_game.get_parent().visible = true
	
	# Set view mode
	set_view_mode("game")

func create_snake_game(difficulty = "normal"):
	# Create container
	var container = Node3D.new()
	container.name = "snake_game_container"
	add_child(container)
	
	# Create game
	snake_game = load("res://code/gdscript/scripts/Snake_Space_Movement/snake_game.gd").new()
	snake_game.name = "snake_game"
	container.add_child(snake_game)
	
	# Set difficulty
	if snake_game.has_method("set_difficulty"):
		snake_game.set_difficulty(difficulty)
	
	# Position container
	container.position = window_positions.snake_game

func show_snake_game():
	var container = get_node_or_null("snake_game_container")
	if container:
		container.visible = true
		set_view_mode("game")
	else:
		launch_snake_game()

# ======== CAMERA CONTROL ========

func set_view_mode(mode):
	current_view_mode = mode
	
	# Set target position based on mode
	var target_position
	var target_rotation
	
	match mode:
		"terminal":
			target_position = Vector3(0, 1.7, 0)
			target_rotation = Vector3(0, 0, 0)
		"game":
			target_position = Vector3(0, 3, 3)  # Higher and further back
			target_rotation = Vector3(-30, 0, 0)  # Looking down at angle
		"menu":
			target_position = Vector3(0, 1.5, 2)  # In front of menu
			target_rotation = Vector3(0, 0, 0)
	
	# Store target for smooth transition
	main_camera.set_meta("target_position", target_position)
	main_camera.set_meta("target_rotation", target_rotation)




















func update_camera(delta):
	# Check if we have transition targets
	if main_camera.has_meta("target_position") and main_camera.has_meta("target_rotation"):
		var target_pos = main_camera.get_meta("target_position")
		var target_rot = main_camera.get_meta("target_rotation")
		
		# Smoothly move towards target
		main_camera.position = main_camera.position.lerp(target_pos, delta * camera_transition_speed)
		
		# Convert rotation to quaternion for smoother rotation
		var current_quat = Quaternion.from_euler(main_camera.rotation)
		var target_quat = Quaternion.from_euler(target_rot)
		var new_quat = current_quat.slerp(target_quat, delta * camera_transition_speed)
		main_camera.rotation = new_quat.get_euler()
		
		# Update head position to follow camera with offset
		player_head.position = main_camera.position + Vector3(0, -0.2, 0)

# ======== CONSOLE COMMANDS ========

func register_console_commands():
	# Core system commands
	console_system.add_text_line("Registering|system|commands")
	
	# Add command handlers here when console is properly setup
	# This would normally connect to console.register_command() or similar

# ======== KEYBOARD HANDLERS ========

func _input(event):
	# Toggle console with backtick/tilde key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_QUOTELEFT:  # Backtick/tilde key
			toggle_console()
		elif event.keycode == KEY_ESCAPE:
			if current_view_mode == "game":
				# Return to menu from game
				show_main_menu()

func toggle_console():
	if console_system:
		if console_system.visible:
			console_system.visible = false
			# If we were in terminal mode, go back to previous mode
			if current_view_mode == "terminal":
				if get_node("snake_game_container").visible:
					set_view_mode("game")
				else:
					set_view_mode("menu")
		else:
			console_system.visible = true
			set_view_mode("terminal")

# ======== TASK MANAGEMENT ========

func create_new_task(function_name, data):
	if task_manager:
		var target_object = self
		task_manager.new_task_appeared(function_name, data, Time.get_ticks_msec())
		
		if thread_pool and thread_pool.has_method("submit_task"):
			thread_pool.submit_task(target_object, function_name, data, function_name + "_" + str(Time.get_ticks_msec()))

func three_stages_of_creation(set_name):
	# This would normally have complex creation logic
	log_message("Creating: " + set_name, "system")
	
	match set_name:
		"snake_game":
			create_snake_game()
		"keyboard":
			# Already created in initialization
			get_node("keyboard_container").visible = true
		_:
			log_message("Unknown set: " + set_name, "error")

# ======== LOGGING SYSTEM ========

func log_message(message, type = "info"):
	# Create log entry
	var log_entry = {
		"timestamp": Time.get_ticks_msec(),
		"time_string": Time.get_time_string_from_system(),
		"message": message,
		"type": type
	}
	
	# Add to log
	log_entries.append(log_entry)
	
	# Keep log size in check
	if log_entries.size() > max_log_entries:
		log_entries.pop_front()
	
	# Count errors
	if type == "error":
		if !error_counts.has(message):
			error_counts[message] = 0
		error_counts[message] += 1
	
	# Print to console for debugging
	print("[" + log_entry.time_string + "][" + type + "] " + message)
	
	# Send to console if available
	if console_system and console_system.has_method("add_text_line"):
		console_system.add_text_line(type + "|" + message)

# ======== DIMENSIONAL MAGIC FUNCTIONS ========

# These are placeholder implementations of the multi-dimensional magic functions
# from the JSH system for compatibility

func first_dimensional_magic(action_to_do, datapoint_node, additional_node = null):
	log_message("First dimensional magic: " + action_to_do, "system")
	# Implementation would depend on the specific actions needed

func fourth_dimensional_magic(type_of_stuff, node, data):
	log_message("Fourth dimensional magic: " + type_of_stuff, "system")
	
	# Handle different types
	match type_of_stuff:
		"move":
			if node and node is Node3D and data is Vector3:
				node.position = data
		"write":
			if node and node is Label3D and data is String:
				node.text = data

func fifth_dimensional_magic(type_of_unload, container_name):
	log_message("Fifth dimensional magic: Unloading " + container_name, "system")
	
	var container = get_node_or_null(container_name)
	if container:
		container.visible = false

func sixth_dimensional_magic(type_of_action, node_path_or_nodes, function_name, data = null):
	log_message("Sixth dimensional magic: " + type_of_action + " / " + function_name, "system")
	
	match type_of_action:
		"call_function_get_node":
			var node = get_node_or_null(node_path_or_nodes)
			if node:
				var function_parts = function_name.split("|")
				var func_name = function_parts[0]
				if node.has_method(func_name):
					if data != null:
						node.call(func_name, data)
					else:
						node.call(func_name)
		"get_nodes_call_function":
			if node_path_or_nodes is Array:
				for path in node_path_or_nodes:
					var node = get_node_or_null(path)
					if node and node.has_method(function_name):
						if data != null:
							node.call(function_name, data)
						else:
							node.call(function_name)

func seventh_dimensional_magic(action_type, path, data):
	log_message("Seventh dimensional magic: " + action_type, "system")
	
	match action_type:
		"change_visibilty":  # Note: Original typo preserved for compatibility
			var node = get_node_or_null(path)
			if node:
				node.visible = true if data > 0 else false

func eighth_dimensional_magic(name_of_action, data_to_send, container_name):
	log_message("Eighth dimensional magic: " + name_of_action, "system")
	
	match name_of_action:
		"keyboard_connection":
			# Connect keyboard to target
			if keyboard_system and keyboard_system.has_method("set_connection_target"):
				keyboard_system.set_connection_target(data_to_send[0], data_to_send[1], data_to_send[2])
		"load_a_file":
			# Load file
			var file_to_load = data_to_send
			var container = get_node_or_null(container_name)
			if container:
				var datapoint = container.get_node_or_null("thing_19")
				if datapoint and datapoint.has_method("initialize_loading_file"):
					datapoint.initialize_loading_file(file_to_load)







































# ======== INITIALIZATION ========

func initialize_materials():
	# Snake material
	snake_material = StandardMaterial3D.new()
	snake_material.albedo_color = Color(0.2, 0.7, 0.3)
	snake_material.metallic = 0.3
	snake_material.roughness = 0.7
	snake_material.emission_enabled = true
	snake_material.emission = Color(0.2, 0.5, 0.2)
	snake_material.emission_energy = 0.3
	
	# Head material
	head_material = snake_material.duplicate()
	head_material.albedo_color = Color(0.3, 0.8, 0.4)
	head_material.emission = Color(0.3, 0.7, 0.3)
	head_material.emission_energy = 0.5
	
	# Food material
	food_material = StandardMaterial3D.new()
	food_material.albedo_color = Color(0.8, 0.3, 0.2)
	food_material.metallic = 0.5
	food_material.roughness = 0.5
	food_material.emission_enabled = true
	food_material.emission = Color(1.0, 0.3, 0.2)
	food_material.emission_energy = 0.7
	
	# Grid material
	grid_material = StandardMaterial3D.new()
	grid_material.albedo_color = Color(0.2, 0.2, 0.3, 0.3)
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_material.metallic = 0.8
	grid_material.roughness = 0.2

func create_grid():
	# Create grid container
	var grid_container = Node3D.new()
	grid_container.name = "grid_container"
	add_child(grid_container)
	
	# Create grid lines
	for x in range(grid_size.x + 1):
		var line = create_grid_line(
			Vector3(x * cell_size, 0, 0),
			Vector3(x * cell_size, 0, grid_size.y * cell_size)
		)
		grid_container.add_child(line)
		grid_lines.append(line)
	
	for y in range(grid_size.y + 1):
		var line = create_grid_line(
			Vector3(0, 0, y * cell_size),
			Vector3(grid_size.x * cell_size, 0, y * cell_size)
		)
		grid_container.add_child(line)
		grid_lines.append(line)
	
	# Position grid container
	grid_container.position = grid_offset

func create_grid_line(start, end):
	var line = MeshInstance3D.new()
	
	# Create mesh
	var mesh = ImmediateMesh.new()
	line.mesh = mesh
	
	# Draw line
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_end()
	
	# Apply material
	line.material_override = grid_material
	
	return line














func create_ui_elements():
	# Score display
	score_display = Label3D.new()
	score_display.name = "score_display"
	score_display.text = "Score: 0"
	score_display.font_size = 16
	score_display.position = Vector3(0, 5, -8)
	add_child(score_display)
	
	# Message display
	message_display = Label3D.new()
	message_display.name = "message_display"
	message_display.font_size = 24
	message_display.position = Vector3(0, 3, -8)
	add_child(message_display)
	
	# Update score display
	update_score_display()













func initialize_snake():
	# Clear any existing segments
	for segment in snake_segments:
		if is_instance_valid(segment.node):
			segment.node.queue_free()
	snake_segments.clear()
	
	# Create initial snake segments (3 segments)
	var start_pos = Vector2i(grid_size.x / 2, grid_size.y / 2)
	
	# Head
	add_snake_segment(start_pos, true)
	
	# Body segments
	add_snake_segment(Vector2i(start_pos.x - 1, start_pos.y))
	add_snake_segment(Vector2i(start_pos.x - 2, start_pos.y))
	
	# Set initial direction
	snake_direction = Vector2i(1, 0)
	next_direction = Vector2i(1, 0)














func add_snake_segment(grid_pos, is_head = false):
	var segment = MeshInstance3D.new()
	segment.name = "snake_segment_" + str(snake_segments.size())
	
	# Create mesh
	var mesh = SphereMesh.new()
	mesh.radius = cell_size * 0.4
	mesh.height = cell_size * 0.8
	segment.mesh = mesh
	
	# Apply material
	segment.material_override = head_material if is_head else snake_material
	
	# Position segment
#	var world_pos = grid_to_world(grid_pos)
	segment#.position = world_pos
	
	# Add to scene
	add_child(segment)
	
	# Store segment info
	snake_segments.append({
		"node": segment,
		"grid_pos": grid_pos,
		#"world_pos": world_pos,
		"is_head": is_head
	})













func initialize_animator():
	# Create and set up animator
	animator = load("res://code/gdscript/scripts/Snake_Space_Movement/snake_animation.gd").new()
	animator.name = "snake_animator"
	add_child(animator)
	
	# Set animator properties based on difficulty
	#update_animator_settings()
	
	# Set up materials for animator
	var segment_meshes = []
	for segment in snake_segments:
		segment_meshes.append(segment.node)
	animator.setup_materials(segment_meshes)
	
	# Start breathing animation
	animator.start_breathing_animation(snake_segments)

# ======== GAME LOGIC ========





func start_game():
	current_state = GameState.PLAYING
	#hide_message()
	score = 0
	update_score_display()










func reset_game():
	# Reset snake
	initialize_snake()
	
	# Reset food
	if food_node:
		food_node.queue_free()
		food_node = null
	spawn_food()
	
	# Reset score
	score = 0
	update_score_display()
	
	# Reset animator
	if animator:
		var segment_meshes = []
		for segment in snake_segments:
			segment_meshes.append(segment.node)
		animator.setup_materials(segment_meshes)
		animator.start_breathing_animation(snake_segments)







func handle_input():
	# Get input direction
	var new_direction = next_direction
	
	if Input.is_action_just_pressed("ui_up") and snake_direction.y == 0:
		new_direction = Vector2i(0, -1)
	elif Input.is_action_just_pressed("ui_down") and snake_direction.y == 0:
		new_direction = Vector2i(0, 1)
	elif Input.is_action_just_pressed("ui_left") and snake_direction.x == 0:
		new_direction = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("ui_right") and snake_direction.x == 0:
		new_direction = Vector2i(1, 0)
	
	# Can't reverse direction
	if new_direction.x != -snake_direction.x or new_direction.y != -snake_direction.y:
		next_direction = new_direction














































func move_snake():
	# Update direction
	snake_direction = next_direction
	
	# Get head position
	var head = snake_segments[0]
	var new_pos = head.grid_pos + snake_direction
	
#

func _ready_snake():
	# Initialize references to UI components
	info_text = get_parent().get_node("thing_103")
	score_text = get_parent().get_node("thing_113")
	
	# Try to get reference to main scene
	var scene_root = get_tree().get_root()
	if scene_root.has_node("main"):
		main_ref = scene_root.get_node("main")
	
	# Create game grid
	create_grid()
	
	# Create visual components
	create_meshes()
	
	# Initialize game
	start_new_game()
	
	# Update UI
	update_score_display()
	update_info_text("Use arrow keys or WASD to play")






































func _process_snake(delta):
	if game_over or paused:
		return
		
	# Handle movement timing
	timer += delta
	var move_delay = MOVE_DELAY * speed_multipliers[current_speed]
	if timer >= move_delay:
		timer = 0
		move_snake()

func create_meshes():
	# Create snake head mesh
	snake_head_mesh = create_cube_mesh(Color(0.0, 0.8, 0.0))
	
	# Create snake body mesh
	snake_body_mesh = create_cube_mesh(Color(0.0, 0.6, 0.0))
	
	# Create food mesh
	food_mesh = create_cube_mesh(Color(1.0, 0.2, 0.2))

func create_cube_mesh(color: Color) -> Mesh:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(CELL_SIZE * 0.9, CELL_SIZE * 0.5, CELL_SIZE * 0.9)
	return mesh

func start_new_game():
	# Clear any existing snake segments
	for segment in snake_segments:
		if is_instance_valid(segment):
			segment.queue_free()
	
	snake_segments.clear()
	
	# Create initial snake
	var center = Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
	for i in range(INITIAL_SNAKE_LENGTH):
		var segment_pos = center - Vector2(i, 0)
		add_snake_segment(segment_pos)
	
	# Set initial direction
	snake_direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	
	# Spawn food
	spawn_food()
	
	# Reset game state
	game_over = false
	score = 0
	
	# Update score display
	update_score_display()
	
	# Reset timer
	timer = 0.0

func spawn_food():
	# Clear existing food
	var existing_food = grid.get_node_or_null("Food")
	if existing_food:
		existing_food.queue_free()
	
	# Find a position that's not occupied by the snake
	var valid_positions = []
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var pos = Vector2(x, y)
			var occupied = false
			
			for segment in snake_segments:
				if segment.get_meta("grid_pos") == pos:
					occupied = true
					break
			
			if !occupied:
				valid_positions.append(pos)
	
	# Select a random valid position
	if valid_positions.size() > 0:
		var index = randi() % valid_positions.size()
		food_position = valid_positions[index]
		
		# Create food visual
		var food = MeshInstance3D.new()
		food.name = "Food"
		food.mesh = food_mesh
		grid.add_child(food)
		
		# Position food correctly
		food.position = Vector3(
			food_position.x * CELL_SIZE,
			CELL_SIZE * 0.25, # Half height above grid
			food_position.y * CELL_SIZE
		)

func handle_game_over():
	game_over = true
	update_info_text("GAME OVER - Press Reset to start again")

func update_info_text(text: String):
	if info_text and info_text is Label3D:
		info_text.text = text

func update_score_display():
	if score_text and score_text is Label3D:
		score_text.text = "Score: " + str(score)





func create_grid_add():
	# Create a visual grid for the game
	grid = Node3D.new()
	grid.name = "SnakeGrid"
	add_child(grid)
	
	# Create the grid plane
	var grid_mesh = MeshInstance3D.new()
	grid.add_child(grid_mesh)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)
	grid_mesh.mesh = plane_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.2, 1.0)
	grid_mesh.material_override = material
	
	# Center the grid
	grid.position = Vector3(-GRID_SIZE * CELL_SIZE / 2, 0, -GRID_SIZE * CELL_SIZE / 2)






















































func add_snake_segment_add(grid_pos: Vector2):
	var segment = MeshInstance3D.new()
	
	# Use head mesh for first segment, body mesh for others
	if snake_segments.size() == 0:
		segment.mesh = snake_head_mesh
	else:
		segment.mesh = snake_body_mesh
	
	grid.add_child(segment)
	
	# Position segment correctly in 3D space
	segment.position = Vector3(
		grid_pos.x * CELL_SIZE,
		CELL_SIZE * 0.25, # Half height above grid
		grid_pos.y * CELL_SIZE
	)
	
	# Store grid position as metadata
	segment.set_meta("grid_pos", grid_pos)
	
	# Add to snake segments
	snake_segments.push_front(segment)

func move_snake_add():
	# Update direction from input
	snake_direction = next_direction
	
	# Calculate new head position
	var head = snake_segments.front()
	var head_pos = head.get_meta("grid_pos")
	var new_head_pos = head_pos + snake_direction
	
	# Check for collision with walls
	if new_head_pos.x < 0 or new_head_pos.x >= GRID_SIZE or new_head_pos.y < 0 or new_head_pos.y >= GRID_SIZE:
		handle_game_over()
		return
	
	# Check for collision with self
	for i in range(1, snake_segments.size()):
		var segment = snake_segments[i]
		var segment_pos = segment.get_meta("grid_pos")
		if new_head_pos == segment_pos:
			handle_game_over()
			return
	
	# Check if food is eaten
	var food_eaten = (new_head_pos == food_position)
	
	# Add new head
	add_snake_segment(new_head_pos)
	
	# Remove tail if no food was eaten
	if !food_eaten:
		var tail = snake_segments.pop_back()
		tail.queue_free()
	else:
		# Food eaten, increase score and spawn new food
		score += 10
		update_score_display()
		spawn_food()
	
	# Update meshes - make sure first segment uses head mesh
	for i in range(snake_segments.size()):
		var segment = snake_segments[i]
		if i == 0:
			# Update head rotation based on direction
			var rotation_y = 0
			if snake_direction == Vector2.RIGHT:
				rotation_y = 0
			elif snake_direction == Vector2.LEFT:
				rotation_y = PI
			elif snake_direction == Vector2.UP:
				rotation_y = -PI/2
			elif snake_direction == Vector2.DOWN:
				rotation_y = PI/2
			
			segment.rotation.y = rotation_y
			
			# Make sure head has head mesh
			if segment.mesh != snake_head_mesh:
				segment.mesh = snake_head_mesh
		else:
			# Make sure body segments have body mesh
			if segment.mesh != snake_body_mesh:
				segment.mesh = snake_body_mesh

func handle_input_add(input_type: String):
	match input_type:
		"up":
			if snake_direction != Vector2.DOWN:
				next_direction = Vector2.UP
		"down":
			if snake_direction != Vector2.UP:
				next_direction = Vector2.DOWN
		"left":
			if snake_direction != Vector2.RIGHT:
				next_direction = Vector2.LEFT
		"right":
			if snake_direction != Vector2.LEFT:
				next_direction = Vector2.RIGHT
		"add_segment":
			var head = snake_segments.front()
			var head_pos = head.get_meta("grid_pos")
			add_snake_segment(head_pos + snake_direction)
		"reset":
			start_new_game()
		"speed1":
			current_speed = 1
		"speed2":
			current_speed = 2
		"speed3":
			current_speed = 3
		"pause":
			paused = !paused
			if paused:
				update_info_text("PAUSED - Press any key to continue")
			else:
				update_info_text("Game resumed")
		"back":
			# Navigate back to main menu
			if main_ref and main_ref.has_method("first_dimensional_magic"):
				main_ref.first_dimensional_magic("hide_container", "snake_game_container", null)
#


func handle_snake_menu_interaction(option, difficulty = "normal"):
	print("Snake menu option: ", option)
	
	match option:
		"Snake Game":
			# Show Snake Game submenu
			print("something")
			#show_menu_scene("akashic_records", 11)  # Show the difficulty selection menu
		"Back":
			# Return to main menu
			print("something")
			#show_menu_scene("akashic_records", 10)  # Back to main menu with Snake option
		"Easy Mode":
			# Launch Snake game with easy settings
			launch_snake_game("easy")
		"Normal Mode":
			# Launch Snake game with normal settings
			launch_snake_game("normal")
		"Hard Mode":
			# Launch Snake game with hard settings
			launch_snake_game("hard")
		"Instructions":
			# Show instructions
			print("something")
			#show_menu_scene("akashic_records", 12)  # Show the instructions screen
		"High Scores":
			# Show high scores (would need to be implemented)
			display_high_scores()

# Launch the Snake game with the given difficulty


























































func launch_snake_game_add(difficulty):
	print("Launching Snake game with difficulty: ", difficulty)
	
	# First make sure the snake game container exists
	var container_name = "snake_game_container"
	var container_node# = get_node_or_null(container_name)
	
	if not container_node:
		# Create it if it doesn't exist
		#three_stages_of_creation_snake("snake_game")
		container_node# = get_node_or_null(container_name)
	
	if container_node:
		# Set difficulty
		var snake_game = container_node.get_node_or_null("JSHSnakeGame")
		if snake_game:
			# Apply difficulty settings if the snake game supports it
			match difficulty:
				"easy":
					# Slower game speed, larger food, etc.
					snake_game.current_speed = 1
				"normal":
					# Default settings
					snake_game.current_speed = 2
				"hard":
					# Faster game speed, obstacles, etc.
					snake_game.current_speed = 3
		
		# Hide the menu
		var menu_container# = get_node_or_null("akashic_records")
		if menu_container:
			menu_container.visible = false
		
		# Show the snake game
		#show_snake_game()
	else:
		print("Failed to create snake game container")

# Display high scores
func display_high_scores():
	print("Displaying high scores")
	
	# This would need to be implemented with your score saving/loading system
	# For now, just display a placeholder message
	var info_text# = get_node_or_null("snake_game_container/thing_103")
	if info_text and info_text is Label3D:
		info_text.text = "High scores not implemented yet."
	
	# You might want to show this on a different UI element in your menu system

# Snake Game Button Event Handler
# Add this to wherever you process button interactions in your game
func process_snake_button_click(button_name):
	# Check if the button is in the Snake Game menu
	if button_name in ["Snake Game", "Easy Mode", "Normal Mode", "Hard Mode", 
					  "Instructions", "High Scores"]:
		handle_snake_menu_interaction(button_name)
		return true
	# Check for back button in Snake submenu contexts
	elif button_name == "Back":
		# You'll need logic to determine which menu we're backing out from
		var current_menu = get_current_menu_context()
		if current_menu in ["snake_difficulty", "snake_instructions", "snake_highscores"]:
			handle_snake_menu_interaction("Back")
			return true
	
	# Not a Snake Game related button
	return false

# Helper to determine current menu context
func get_current_menu_context():
	# This would need to be implemented based on your menu system
	# Here's a simple version based on visible scene IDs
	
	var records_node# = get_node_or_null("akashic_records")
	if records_node:
		var thing_7 = records_node.get_node_or_null("thing_7")
		if thing_7 and thing_7.has_meta("current_scene"):
			var scene_id = thing_7.get_meta("current_scene")
			match scene_id:
				"scene_11": return "snake_difficulty"
				"scene_12": return "snake_instructions"
				# Add other contexts as needed
	
	return "unknown"



				#show_message("Press SPACE to start")
#
#
#
	### Set difficulty
	##set_difficulty(difficulty)
	##
	### Start in ready state
	##show_message("Press SPACE to start")


#func _input_snake(event):
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_UP, KEY_W:
				#handle_input("up")
			#KEY_DOWN, KEY_S:
				#handle_input("down")
			#KEY_LEFT, KEY_A:
				#handle_input("left")
			#KEY_RIGHT, KEY_D:
				#handle_input("right")
			#KEY_SPACE:
				#if game_over:
					#handle_input("reset")
				#else:
					#handle_input("pause")
			#KEY_ESCAPE:
				#handle_input("back")
			#KEY_1:
				#handle_input("speed1")
			#KEY_2:
				#handle_input("speed2")
			#KEY_3:
				#handle_input("speed3")
			#KEY_PLUS, KEY_EQUAL:
				#handle_input("add_segment")
## Handler for Snake game menu options
	## Check for collision with walls
	#if new_pos.x < 0 or new_pos.x >= grid_size.x or new_pos.y < 0 or new_pos.y >= grid_size.y:
		#game_over()
		#return
	

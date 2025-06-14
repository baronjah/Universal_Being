extends Node
# jsh_snake_game.gd
#extends Node3D
class_name JSHSnakeGameInput
# res://code/gdscript/scripts/Snake_Space_Movement/snake_input.gd
# JSH_World/grid_map

var snake_integration
var thread_pool
var data_point

var input_map = {
	KEY_UP: "turn_up",
	KEY_DOWN: "turn_down",
	KEY_LEFT: "turn_left",
	KEY_RIGHT: "turn_right",
	KEY_W: "turn_up",
	KEY_S: "turn_down",
	KEY_A: "turn_left",
	KEY_D: "turn_right",
	KEY_SPACE: "add_segment",
	KEY_R: "reset_game",
	KEY_1: "speed_slow",
	KEY_2: "speed_normal",
	KEY_3: "speed_fast"
}

# Game configuration
var grid_size := Vector2i(20, 20)
var cell_size := 0.5
var current_speed := 2
var game_running := false

# Game state
var snake_segments := []
var snake_direction := Vector2i.RIGHT
var next_direction := Vector2i.RIGHT
var food_position := Vector2i.ZERO
var score := 0

# Visual components
var snake_meshes := []
var food_mesh: MeshInstance3D
var grid_mesh: MeshInstance3D
var score_label: Label3D


var grid_size_new := Vector2i(20, 20)
var cell_size_new := 0.5
var current_speed_new := 2
var game_running_new := false

# Game state
var snake_segments_new := []
var snake_direction_new := Vector2i.RIGHT
var next_direction_new := Vector2i.RIGHT
var food_position_new := Vector2i.ZERO
var score_new := 0

# Visual components
var snake_meshes_new := []
var food_mesh_new: MeshInstance3D
var grid_mesh_new: MeshInstance3D
var score_label_new: Label3D

var update_timer := 0.0
var JSH3DTerminal

##
#

func _ready_new_v1():
	# Get references to your systems
	thread_pool = get_node("/root/thread_pool_autoload")
	
	# Find the snake integration node
	snake_integration = get_node_or_null("../JSHSpaceSnakeIntegration")
	if not snake_integration:
		snake_integration = get_node_or_null("/root/main/JSHSpaceSnakeIntegration")
	
	# Set up connection to active datapoint
	connect_to_datapoint()

func _ready_snake():
	name = "JSHSnakeGame"
	setup_game_visuals()
	reset_game()

##
##
func initialize_3d_terminal():
	var terminal = JSH3DTerminal.new()
	terminal.name = "JSH_3D_terminal"
	terminal.position = Vector3(0, 2, -5)  # Position in front of player
	add_child(terminal)
	print("✅ 3D Terminal initialized")
	return terminal

func setup_game_visuals():
	# Create grid
	grid_mesh = MeshInstance3D.new()
	grid_mesh.name = "grid_mesh"
	add_child(grid_mesh)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
	
	var grid_material = StandardMaterial3D.new()
	grid_material.albedo_color = Color(0.1, 0.1, 0.2)
	grid_material.emission_enabled = true
	grid_material.emission = Color(0.2, 0.2, 0.4)
	grid_material.emission_energy = 0.5
	
	grid_mesh.mesh = plane_mesh
	grid_mesh.material_override = grid_material
	
	# Create food
	food_mesh = MeshInstance3D.new()
	food_mesh.name = "food_mesh"
	add_child(food_mesh)
	
	var food_mat = StandardMaterial3D.new()
	food_mat.albedo_color = Color(1.0, 0.3, 0.3)
	food_mat.emission_enabled = true
	food_mat.emission = Color(1.0, 0.5, 0.5)
	food_mat.emission_energy = 1.0
	
	var food_primitive = SphereMesh.new()
	food_primitive.radius = cell_size * 0.4
	food_primitive.height = cell_size * 0.8
	
	food_mesh.mesh = food_primitive
	food_mesh.material_override = food_mat
	
	# Score label
	score_label = Label3D.new()
	score_label.name = "score_label"
	score_label.text = "Score: 0"
	score_label.font_size = 64
	score_label.position = Vector3(0, 0.5, -grid_size.y * cell_size / 2 - 1.0)
	score_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(score_label)

func reset_game():
	# Reset game state
	snake_segments = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10)]
	snake_direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	score = 0
	
	# Clean up existing snake visuals
	for mesh in snake_meshes:
		mesh.queue_free()
	snake_meshes.clear()
	
	# Create initial snake
	for segment in snake_segments:
		add_snake_segment(segment)
	
	# Place food
	place_food()
	
	# Update score
	update_score_display()
	
	# Start the game
	game_running = true

func handle_input(direction):
	match direction:
		"up":
			if snake_direction != Vector2i.DOWN:
				next_direction = Vector2i.UP
		"down":
			if snake_direction != Vector2i.UP:
				next_direction = Vector2i.DOWN
		"left":
			if snake_direction != Vector2i.RIGHT:
				next_direction = Vector2i.LEFT
		"right":
			if snake_direction != Vector2i.LEFT:
				next_direction = Vector2i.RIGHT
		"restart":
			reset_game()

#
##
func _ready_new():
	name = "JSHSnakeGame"
	setup_game_visuals()
	reset_game()

func _process_new(delta):
	if game_running:
		update_timer += delta
		var update_interval = 0.5 / (current_speed + 1)
		
		if update_timer >= update_interval:
			update_timer = 0
			update_snake()

##
#

func setup_game_visuals_new():
	# Create grid
	grid_mesh = MeshInstance3D.new()
	grid_mesh.name = "grid_mesh"
	add_child(grid_mesh)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
	
	var grid_material = StandardMaterial3D.new()
	grid_material.albedo_color = Color(0.1, 0.1, 0.2)
	grid_material.emission_enabled = true
	grid_material.emission = Color(0.2, 0.2, 0.4)
	grid_material.emission_energy = 0.5
	
	grid_mesh.mesh = plane_mesh
	grid_mesh.material_override = grid_material
	
	# Create food
	food_mesh = MeshInstance3D.new()
	food_mesh.name = "food_mesh"
	add_child(food_mesh)
	
	var food_mat = StandardMaterial3D.new()
	food_mat.albedo_color = Color(1.0, 0.3, 0.3)
	food_mat.emission_enabled = true
	food_mat.emission = Color(1.0, 0.5, 0.5)
	food_mat.emission_energy = 1.0
	
	var food_primitive = SphereMesh.new()
	food_primitive.radius = cell_size * 0.4
	food_primitive.height = cell_size * 0.8
	
	food_mesh.mesh = food_primitive
	food_mesh.material_override = food_mat
	
	# Score label
	score_label = Label3D.new()
	score_label.name = "score_label"
	score_label.text = "Score: 0"
	score_label.font_size = 64
	score_label.position = Vector3(0, 0.5, -grid_size.y * cell_size / 2 - 1.0)
	score_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(score_label)

func reset_game_new():
	# Clear existing snake segments
	for mesh in snake_meshes:
		mesh.queue_free()
	snake_meshes.clear()
	
	# Reset game state
	snake_segments = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10)]
	snake_direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	score = 0
	
	# Create initial snake
	for segment in snake_segments:
		add_snake_segment(segment)
	
	# Place food
	place_food()
	
	# Update score
	update_score_display()
	
	# Start the game
	game_running = true

func add_snake_segment(pos: Vector2i):
	var segment = MeshInstance3D.new()
	segment.name = "snake_segment_" + str(snake_meshes.size())
	add_child(segment)
	
	var segment_mesh = BoxMesh.new()
	segment_mesh.size = Vector3(cell_size * 0.9, cell_size * 0.9, cell_size * 0.9)
	
	var segment_mat = StandardMaterial3D.new()
	
	# Head is different color
	if snake_meshes.size() == 0:
		segment_mat.albedo_color = Color(0.3, 0.9, 0.3)
		segment_mat.emission = Color(0.5, 1.0, 0.5)
	else:
		segment_mat.albedo_color = Color(0.2, 0.7, 0.2)
		segment_mat.emission = Color(0.4, 0.8, 0.4)
	
	segment_mat.emission_enabled = true
	segment_mat.emission_energy = 0.8
	
	segment.mesh = segment_mesh
	segment.material_override = segment_mat
	
	# Position
	segment.position = grid_to_world(pos)
	
	snake_meshes.append(segment)

func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(
		(grid_pos.x - grid_size.x/2) * cell_size, 
		cell_size/2, 
		(grid_pos.y - grid_size.y/2) * cell_size
	)

func place_food():
	var valid_positions = []
	
	# Find all empty positions
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var pos = Vector2i(x, y)
			if not pos in snake_segments:
				valid_positions.append(pos)
	
	# Choose random position
	if valid_positions.size() > 0:
		food_position = valid_positions[randi() % valid_positions.size()]
		food_mesh.position = grid_to_world(food_position)
	else:
		# No valid positions - player wins!
		game_running = false

func update_snake():
	if not game_running:
		return
	
	# Update direction
	snake_direction = next_direction
	
	# Get new head position
	var head = snake_segments[0]
	var new_head = head + snake_direction
	
	# Wrap around edges
	if new_head.x < 0:
		new_head.x = grid_size.x - 1
	elif new_head.x >= grid_size.x:
		new_head.x = 0
		
	if new_head.y < 0:
		new_head.y = grid_size.y - 1
	elif new_head.y >= grid_size.y:
		new_head.y = 0
	
	# Check collision with self
	if new_head in snake_segments:
		game_over()
		return
	
	# Move snake
	snake_segments.push_front(new_head)
	
	# Check if food eaten
	if new_head == food_position:
		# Add segment visually
		add_snake_segment(new_head)
		
		# Update score
		score += 10
		update_score_display()
		
		# Place new food
		place_food()
	else:
		# Remove tail
		snake_segments.pop_back()
		
		# Add new head visually
		var tail_mesh = snake_meshes.pop_back()
		snake_meshes.push_front(tail_mesh)
		tail_mesh.position = grid_to_world(new_head)
		
		# Update head/body materials
		update_snake_materials()

func update_snake_materials():
	for i in range(snake_meshes.size()):
		var segment = snake_meshes[i]
		var material = segment.material_override
		
		if i == 0: # Head
			material.albedo_color = Color(0.3, 0.9, 0.3)
			material.emission = Color(0.5, 1.0, 0.5)
		else: # Body
			material.albedo_color = Color(0.2, 0.7, 0.2)
			material.emission = Color(0.4, 0.8, 0.4)

func update_score_display():
	score_label.text = "Score: " + str(score)

func game_over():
	game_running = false
	score_label.text = "Game Over - Score: " + str(score) + " - Press R to restart"
	
	# Flash red
	var tween = create_tween()
	for segment in snake_meshes:
		var material = segment.material_override
		material.albedo_color = Color(1.0, 0.2, 0.2)
		material.emission = Color(1.0, 0.3, 0.3)

func handle_input_new(direction):
	match direction:
		"up":
			if snake_direction != Vector2i.DOWN:
				next_direction = Vector2i.UP
		"down":
			if snake_direction != Vector2i.UP:
				next_direction = Vector2i.DOWN
		"left":
			if snake_direction != Vector2i.RIGHT:
				next_direction = Vector2i.LEFT
		"right":
			if snake_direction != Vector2i.LEFT:
				next_direction = Vector2i.RIGHT
		"restart":
			reset_game()

func connect_to_datapoint():
	# Find the active container and datapoint in your JSH system
	var container_name = BanksCombiner.set_containers_names["singular_lines"]
	var current_container = get_node_or_null("/root/main/" + container_name)
	
	if current_container:
		# Find the datapoint within this container
		for child in current_container.get_children():
			if child.name.begins_with("thing_") and "data_point" in child.get_script().get_path():
				data_point = child
				break
	
	if not data_point:
		print("WARNING: Could not find datapoint for input handler")

func _unhandled_input_new(event):
	# Process keyboard input for snake control
	if event is InputEventKey and event.pressed:
		var key_pressed = event.keycode
		
		if input_map.has(key_pressed):
			var action = input_map[key_pressed]
			process_action(action)
			get_viewport().set_input_as_handled()
	
	# Process mouse input for grid interaction
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_mouse_click(event.position)

func process_action(action):
	# Create a task using your thread pool system
	var task_tag = "snake_input|" + action + "|" + str(Time.get_ticks_msec())
	thread_pool.submit_task(self, "handle_input_action", action, task_tag)

func handle_input_action(action):
	# This function will be run in a thread
	var command = ""
	
	match action:
		"turn_up", "turn_down", "turn_left", "turn_right":
			# These map directly to snake core inputs
			if snake_integration and snake_integration.snake_core:
				# Register input in snake core's inputs dictionary
				snake_integration.snake_core.inputs[action] = true
			
		"add_segment":
			command = "add"
			
		"reset_game":
			command = "reset"
			
		"speed_slow":
			command = "speed 0.3"
			
		"speed_normal":
			command = "speed 0.2"
			
		"speed_fast":
			command = "speed 0.1"
	
	# If we have a command string, send it to the integration
	if command != "" and snake_integration:
		snake_integration.request_to_god(command)
	
	# If we have a connected datapoint, update its state if needed
	if data_point:
		data_point.things_dictionary.lock()
		data_point.datapoint_things_dictionary["last_snake_input"] = action
		data_point.things_dictionary.unlock()
	
	return action

func handle_mouse_click(position):
	# Convert screen position to 3D world position
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * 1000
	
	# Create a physics raycast
	var space_state# = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		# Check if we hit a grid cell
		if snake_integration and snake_integration.snake_grid:
			var grid_pos = snake_integration.snake_grid.world_to_grid(result.position)
			
			# Send grid interaction to your JSH system
			if data_point:
				var grid_interaction = {
					"action": "grid_click",
					"position": grid_pos,
					"world_position": result.position
				}
				
				data_point.things_dictionary.lock()
				data_point.datapoint_things_dictionary["snake_grid_interaction"] = grid_interaction
				data_point.things_dictionary.unlock()
				
				# Also send through your thread system
				var task_tag = "grid_interaction|" + str(Time.get_ticks_msec())
				thread_pool.submit_task(self, "process_grid_interaction", grid_interaction, task_tag)

func process_grid_interaction(interaction_data):
	# Process the grid interaction in your JSH system
	if snake_integration:
		# Create food at this position, for example
		if snake_integration.snake_core:
			var position = interaction_data["position"]
			
			# Create a task to add food at this position
			var command = "add_food " + str(position.x) + " " + str(position.y) + " " + str(position.z)
			snake_integration.request_to_god(command)
	
	return interaction_data
#f
#
##


# The rest of the snake game implementation...
# (I've kept this brief, as it follows standard snake game logic)

# dream of one place for every ready, process stuff
##
#

# jsh_snake_game.gd
#extends Node3D
#class_name JSHSnakeGame

# Game configuration
# Input mapping
# This script handles input for the space snake game and interfaces with your JSH system
# Attach to a node in your scene hierarchy
# References

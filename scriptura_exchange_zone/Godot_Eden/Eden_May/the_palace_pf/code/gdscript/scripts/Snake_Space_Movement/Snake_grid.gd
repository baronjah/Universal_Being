# Snake_grid

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
extends Node
class_name GridSystem
# References

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# res://code/gdscript/scripts/Snake_Space_Movement/Snake_grid.gd
# res://code/gdscript/scripts/Snake_Space_Movement/Snake_grid.gd
#
# JSH_World/marching_cubes
#
var cell_size = 1.0 # Size of each cell
var grid_data = {} # Dictionary to store grid cell data
var debug_visualization = false
var debug_meshes = {}
var selected_layer = "movement" # Current layer being visualized
var grid_cells = {} # Dictionary to store occupied cells
var snake_segments = [] # Array to store snake segment positions

var game_speed = 0.2 # Time between moves
var move_timer = 0.0 # Timer for movement
var mutex = Mutex.new() # Mutex for thread safety
var lock_count = {} # Dictionary to track lock counts per thread
var max_locks_per_thread = 3 # Maximum locks a single thread can acquire
var max_shapes_per_frame = 100
var visible_shapes = 0
#
#extends Node3D

var grid_resolution = 32 # Default resolution

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#



# Colors for snake
var snake_colors = [
	Color(0.2, 0.7, 0.9), # Blue
	Color(0.1, 0.6, 0.8), # Lighter blue
	Color(0.0, 0.5, 0.7)  # Darker blue
]
var snake_direction = Vector3(1, 0, 0) # Initial direction
# Maximum number of visible objects per frame

# Layer configuration
var layers = {
	"movement": {
		"default": 1.0, # Default movement multiplier 
		"color": Color(0.2, 0.9, 0.3, 0.2) # Visual debug color
	},
	"collision": {
		"default": false, # Default collision state
		"color": Color(0.9, 0.2, 0.2, 0.3) # Visual debug color
	},
	"visual": {
		"default": 1.0, # Default visibility
		"color": Color(0.2, 0.2, 0.9, 0.2) # Visual debug color  
	},
	"path": {
		"default": null, # Default path value
		"color": Color(0.9, 0.9, 0.2, 0.2) # Visual debug color
	},
	"metadata": {
		"default": {}, # Default metadata
		"color": Color(0.5, 0.5, 0.5, 0.2) # Visual debug color
	}
}


#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func _init_grid(resolution = 32, size = 1.0):
	grid_resolution = resolution
	cell_size = size
	initialize_grid()

func _ready_grid():
	initialize_grid()
	initialize_snake()


# Main game loop
func _process_grid(delta):
	move_timer += delta

	if move_timer >= game_speed:
		move_timer = 0
		move_snake()
	
	# Update visibilities based on camera distance
	update_visibilities()
	
	# Handle input
	handle_input()


#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func initialize_grid():
	for x in range(-grid_resolution/2, grid_resolution/2):
		for y in range(-grid_resolution/2, grid_resolution/2):
			for z in range(-grid_resolution/2, grid_resolution/2):
				# Only create grid points at intervals to save resources
				if x % 4 == 0 and y % 4 == 0 and z % 4 == 0:
					var position = Vector3(x, y, z)
					grid_cells[position] = {
						"occupied": false,
						"type": "empty",
						"layers": {
							"movement": 1.0, # Movement speed multiplier
							"collision": false, # Whether collision is enabled
							"visual": 0.0, # Visual opacity
							"path": null, # Path information
							"metadata": {} # Additional data
						}
					}

###


# Create the initial grid
func initialize_grid_delta():
	grid_data.clear()
	
	# Create grid in a cube layout
	for x in range(-grid_resolution/2, grid_resolution/2):
		for y in range(-grid_resolution/2, grid_resolution/2):
			for z in range(-grid_resolution/2, grid_resolution/2):
				var position = Vector3(x * cell_size, y * cell_size, z * cell_size)
				create_cell(position)

func initialize_snake():
	var center = Vector3(0, 0, 0)
	
	# Create head
	var head_instance# = head_model.instantiate()
	head_instance.position = center
	add_child(head_instance)
	snake_segments.append({"position": center, "node": head_instance})
	grid_cells[center] = {"occupied": true, "type": "snake_head"}
	
	# Create initial tail segments
	for i in range(1, 4):
		var pos = center - Vector3(i, 0, 0)
		var segment_instance
		segment_instance.position = pos
		segment_instance.get_node("MeshInstance3D").material.albedo_color = snake_colors[i % snake_colors.size()]
		add_child(segment_instance)
		snake_segments.append({"position": pos, "node": segment_instance})
		grid_cells[pos] = {"occupied": true, "type": "snake_segment"}

# Thread-safe dual lock implementation
func dual_lock():
	var thread_id = OS.get_thread_caller_id()
	
	# Check if this thread already has locks
	if lock_count.has(thread_id):
		# If thread already has lock, increment count
		lock_count[thread_id] += 1
		
		# Check if we've exceeded maximum locks per thread
		if lock_count[thread_id] > max_locks_per_thread:
			print("Warning: Thread exceeded max lock count")
			return false
			
		return true
	else:
		# New thread acquiring lock
		mutex.lock()
		lock_count[thread_id] = 1
		return true

# Releases a lock for the current thread
func dual_unlock():
	var thread_id = OS.get_thread_caller_id()
	
	if lock_count.has(thread_id):
		lock_count[thread_id] -= 1
		
		# If count reaches 0, fully release the mutex
		if lock_count[thread_id] <= 0:
			lock_count.erase(thread_id)
			mutex.unlock()
			
		return true
	else:
		print("Error: Trying to unlock when not locked")
		return false

# Convert a world position to grid coordinates
func world_to_grid(world_pos):
	return Vector3(
		round(world_pos.x),
		round(world_pos.y),
		round(world_pos.z)
	)


# Convert world position to grid coordinates
func world_to_grid_new(world_pos):
	return Vector3(
		floor(world_pos.x / cell_size) * cell_size,
		floor(world_pos.y / cell_size) * cell_size,
		floor(world_pos.z / cell_size) * cell_size
	)


# Handle player input
func handle_input():
	if Input.is_action_just_pressed("turn_right"):
		# Rotate direction right
		if snake_direction.x != 0:
			snake_direction = Vector3(0, 0, -snake_direction.x)
		elif snake_direction.z != 0:
			snake_direction = Vector3(snake_direction.z, 0, 0)
	
	if Input.is_action_just_pressed("turn_left"):
		# Rotate direction left
		if snake_direction.x != 0:
			snake_direction = Vector3(0, 0, snake_direction.x)
		elif snake_direction.z != 0:
			snake_direction = Vector3(-snake_direction.z, 0, 0)
	
	if Input.is_action_just_pressed("turn_up"):
		# Rotate direction up
		if snake_direction.y == 0:
			snake_direction = Vector3(0, 1, 0)
	
	if Input.is_action_just_pressed("turn_down"):
		# Rotate direction down
		if snake_direction.y == 0:
			snake_direction = Vector3(0, -1, 0)

# Move the snake
func move_snake():
	# Only proceed if we can get the lock
	if dual_lock():
		var head = snake_segments[0]
		var new_head_pos = head.position + snake_direction
		
		# Check if new position is valid
		if is_valid_move(new_head_pos):
			# Move head
			var new_head = {"position": new_head_pos, "node": head.node}
			head.node.position = new_head_pos
			
			# Update grid
			grid_cells[head.position].occupied = false
			grid_cells[head.position].type = "empty"
			
			if grid_cells.has(new_head_pos):
				grid_cells[new_head_pos].occupied = true
				grid_cells[new_head_pos].type = "snake_head"
			else:
				# Create new grid cell if needed
				grid_cells[new_head_pos] = {"occupied": true, "type": "snake_head"}
			
			# Update snake segments
			snake_segments[0] = new_head
			
			# Move body segments except the last one
			for i in range(1, snake_segments.size()):
				var segment = snake_segments[i]
				var prev_segment = snake_segments[i-1]
				var old_pos = segment.position
				
				# Update grid for this segment
				grid_cells[old_pos].occupied = false
				grid_cells[old_pos].type = "empty"
				
				# Move segment
				segment.position = prev_segment.position
				segment.node.position = segment.position
				
				# Update grid for new position
				grid_cells[segment.position].occupied = true
				grid_cells[segment.position].type = "snake_segment"
				
				# Update reference for next iteration
				prev_segment = segment
		else:
			print("Game over! Invalid move")
			
		dual_unlock()

# Check if move is valid
func is_valid_move(pos):
	# Check grid boundaries
	if pos.x < -grid_resolution/2 or pos.x >= grid_resolution/2:
		return false
	if pos.y < -grid_resolution/2 or pos.y >= grid_resolution/2:
		return false
	if pos.z < -grid_resolution/2 or pos.z >= grid_resolution/2:
		return false
	
	# Check if position is occupied by snake (except tail tip which will move)
	if grid_cells.has(pos) and grid_cells[pos].occupied:
		if grid_cells[pos].type == "snake_segment" or grid_cells[pos].type == "snake_head":
			# Check if it's not the tail (which will move)
			var tail_pos = snake_segments[snake_segments.size() - 1].position
			if pos != tail_pos:
				return false
	
	return true

# Update object visibilities based on distance from camera
func update_visibilities():
	var camera = get_viewport().get_camera_3d()
	if !camera:
		return
		
	visible_shapes = 0
	
	# Sort objects by distance to camera
	var sorted_segments = []
	for segment in snake_segments:
		var distance = camera.global_transform.origin.distance_to(segment.node.global_transform.origin)
		sorted_segments.append({"node": segment.node, "distance": distance})
	
	# Sort by distance (closest first)
	sorted_segments.sort_custom(Callable(self, "sort_by_distance"))
	
	# Set visibility based on max shapes limit
	for i in range(sorted_segments.size()):
		if i < max_shapes_per_frame:
			sorted_segments[i].node.visible = true
			visible_shapes += 1
		else:
			sorted_segments[i].node.visible = false

# Custom sort function
func sort_by_distance(a, b):
	return a.distance < b.distance

# When the player makes a request to "god" (debug/command system)
func request_to_god(command):
	var response = "Request received: " + command
	
	# Parse simple commands
	var parts = command.split(" ")
	
	if parts.size() > 1:
		if parts[0] == "speed":
			game_speed = float(parts[1])
			response = "Game speed set to " + parts[1]
		elif parts[0] == "add":
			add_snake_segment()
			response = "Added snake segment"
		elif parts[0] == "color":
			change_snake_color(parts[1])
			response = "Changed snake color"
		elif parts[0] == "resolution":
			change_grid_resolution(int(parts[1]))
			response = "Changed grid resolution"
	
	return response

# Add a new segment to the snake
func add_snake_segment():
	var last_segment = snake_segments[snake_segments.size() - 1]
	var new_pos = last_segment.position - snake_direction
	
	var segment_instance# = segment_model.instantiate()
	segment_instance.position = new_pos
	segment_instance.get_node("MeshInstance3D").material.albedo_color = snake_colors[snake_segments.size() % snake_colors.size()]
	add_child(segment_instance)
	
	snake_segments.append({"position": new_pos, "node": segment_instance})
	grid_cells[new_pos] = {"occupied": true, "type": "snake_segment"}

# Change snake color
func change_snake_color(color_name):
	var new_colors = []
	
	match color_name:
		"blue":
			new_colors = [
				Color(0.2, 0.7, 0.9),
				Color(0.1, 0.6, 0.8),
				Color(0.0, 0.5, 0.7)
			]
		"red":
			new_colors = [
				Color(0.9, 0.2, 0.2),
				Color(0.8, 0.1, 0.1),
				Color(0.7, 0.0, 0.0)
			]
		"green":
			new_colors = [
				Color(0.2, 0.9, 0.2),
				Color(0.1, 0.8, 0.1),
				Color(0.0, 0.7, 0.0)
			]
	
	if new_colors.size() > 0:
		snake_colors = new_colors
		
		# Update existing segments
		for i in range(snake_segments.size()):
			var segment = snake_segments[i]
			if i > 0: # Don't change head color
				segment.node.get_node("MeshInstance3D").material.albedo_color = snake_colors[i % snake_colors.size()]

# Change grid resolution
func change_grid_resolution(new_resolution):
	grid_resolution = new_resolution
	# Reinitialize grid
	grid_cells.clear()
	initialize_grid()


func create_cell(position):
	var cell_data = {}
	
	# Initialize each layer with default values
	for layer_name in layers:
		cell_data[layer_name] = layers[layer_name].default
	
	# Additional common properties
	cell_data["occupied"] = false
	cell_data["type"] = "empty"
	
	# Store in grid
	grid_data[position] = cell_data
	

func grid_to_world(grid_pos):
	return Vector3(
		grid_pos.x * cell_size + cell_size/2,
		grid_pos.y * cell_size + cell_size/2,
		grid_pos.z * cell_size + cell_size/2
	)

# Get the data for a specific cell
func get_cell(position):
	var grid_position = world_to_grid(position)
	
	if grid_data.has(grid_position):
		return grid_data[grid_position]
	else:
		# Create the cell if it doesn't exist
		create_cell(grid_position)
		return grid_data[grid_position]

# Set data for a specific cell
func set_cell(position, property, value):
	var grid_position = world_to_grid(position)
	
	if !grid_data.has(grid_position):
		create_cell(grid_position)
	
	grid_data[grid_position][property] = value

func set_layer_value(position, layer, value):
	var grid_position = world_to_grid(position)
	
	if !grid_data.has(grid_position):
		create_cell(grid_position)
	
	grid_data[grid_position][layer] = value

func get_layer_value(position, layer):
	var grid_position = world_to_grid(position)
	
	if grid_data.has(grid_position):
		return grid_data[grid_position][layer]
	else:
		# Return default value if cell doesn't exist
		return layers[layer].default

# Check if a position is occupied
func is_occupied(position):
	var grid_position = world_to_grid(position)
	
	if grid_data.has(grid_position):
		return grid_data[grid_position].occupied
	else:
		return false

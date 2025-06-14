extends Node

class_name SpatialLinguisticConnector

# Spatial Linguistic Connector
# Connects linguistic elements with spatial representations
# Creates trajectories for words through dimensional space
# Maps words to shapes and coordinates

signal trajectory_created(word, steps, dimension)
signal word_mapped(word, shape, coordinates)
signal goal_advanced(word, goal, progress)
signal shape_transformed(source_shape, target_shape, coordinates)

# === CONSTANTS ===
const VECTOR_DIRECTIONS = {
	"up": Vector3(0, 1, 0),
	"down": Vector3(0, -1, 0),
	"left": Vector3(-1, 0, 0),
	"right": Vector3(1, 0, 0),
	"forward": Vector3(0, 0, 1),
	"backward": Vector3(0, 0, -1),
	"up_left": Vector3(-0.707, 0.707, 0),
	"up_right": Vector3(0.707, 0.707, 0),
	"down_left": Vector3(-0.707, -0.707, 0),
	"down_right": Vector3(0.707, -0.707, 0),
	"center": Vector3(0, 0, 0)
}

# === VARIABLES ===
var trajectory_steps = 14  # Default number of steps for trajectories
var registered_words = {}  # Registered words and their properties
var word_shapes = {}       # Shapes associated with words
var active_goals = {}      # Goals for word trajectories
var shape_mappings = {}    # Mapping from shapes to coordinates

# === INITIALIZATION ===
func _ready():
	# Initialize default mappings
	_initialize_default_mappings()
	
	print("Spatial Linguistic Connector initialized")

# Initialize default word-shape mappings
func _initialize_default_mappings():
	# Basic word-direction mappings
	var basic_mappings = {
		"up": VECTOR_DIRECTIONS.up,
		"down": VECTOR_DIRECTIONS.down,
		"left": VECTOR_DIRECTIONS.left,
		"right": VECTOR_DIRECTIONS.right,
		"forward": VECTOR_DIRECTIONS.forward,
		"backward": VECTOR_DIRECTIONS.backward,
		"center": VECTOR_DIRECTIONS.center
	}
	
	# Register these basic words
	for word in basic_mappings:
		register_word(word, 1.0, basic_mappings[word])

# === TRAJECTORY SYSTEM ===

# Initialize trajectory system with specified number of steps
func initialize_trajectory_system(steps):
	trajectory_steps = steps
	print("Trajectory system initialized with " + str(steps) + " steps")

# Create a trajectory for a word through dimensional space
func create_trajectory(word, steps = trajectory_steps, dimension = 3):
	# Get word vector or use random if not registered
	var word_vector = Vector3(0, 0, 0)
	var word_power = 1.0
	
	if registered_words.has(word):
		word_vector = registered_words[word].vector
		word_power = registered_words[word].power
	else:
		# Create random vector
		word_vector = Vector3(
			rand_range(-1, 1),
			rand_range(-1, 1),
			rand_range(-1, 1)
		).normalized()
		
		# Register the word with this vector
		register_word(word, word_power, word_vector)
	
	# Generate trajectory steps
	var trajectory = []
	var start_position = Vector3(0, 0, 0)
	
	# First point is origin
	trajectory.append(start_position)
	
	# Create curved path
	for i in range(1, steps):
		var t = float(i) / steps
		var amplitude = sin(t * PI) * word_power
		
		# Compute next point with some variation
		var point = start_position + word_vector * t * 10.0
		
		# Add some curvature based on word properties
		point += Vector3(
			sin(t * PI * 2) * amplitude,
			cos(t * PI * 2) * amplitude,
			sin(t * PI * 1.5) * amplitude
		)
		
		# Add some random variation
		point += Vector3(
			rand_range(-0.1, 0.1),
			rand_range(-0.1, 0.1),
			rand_range(-0.1, 0.1)
		)
		
		trajectory.append(point)
	
	# Emit signal
	emit_signal("trajectory_created", word, trajectory, dimension)
	
	return trajectory

# === SHAPE MAPPING ===

# Initialize shape mapping with provided grids
func initialize_shape_mapping(shape_grids):
	# Store reference to shape grids
	for i in range(shape_grids.size()):
		var grid = shape_grids[i]
		shape_mappings[i] = {
			"grid": grid,
			"shape_type": i,
			"active_points": []
		}
	
	print("Shape mapping initialized with " + str(shape_grids.size()) + " shape types")

# Map a word to a shape with coordinates
func map_word_to_shape(word, shape_type = 0):
	if not registered_words.has(word):
		# Register the word first
		register_word(word, 1.0)
	
	if shape_mappings.has(shape_type):
		var mapping = shape_mappings[shape_type]
		var grid = mapping.grid
		
		# Get random grid point
		var grid_points = grid.keys()
		if grid_points.size() > 0:
			var point = grid_points[randi() % grid_points.size()]
			
			# Store the mapping
			word_shapes[word] = {
				"shape_type": shape_type,
				"coordinates": point,
				"created_at": OS.get_ticks_msec()
			}
			
			# Activate the point in the grid
			grid[point].active = true
			mapping.active_points.append(point)
			
			# Emit signal
			emit_signal("word_mapped", word, shape_type, point)
			
			print("Mapped word '" + word + "' to shape " + str(shape_type) + " at " + str(point))
			return word_shapes[word]
	
	return null

# Transform a shape based on a word
func transform_shape(word, source_shape, target_shape):
	if word_shapes.has(word):
		var original_shape = word_shapes[word]
		
		# Store the original coordinates
		var original_coords = original_shape.coordinates
		
		# Update the shape
		word_shapes[word].shape_type = target_shape
		
		# Get target shape mapping
		if shape_mappings.has(target_shape):
			var mapping = shape_mappings[target_shape]
			var grid = mapping.grid
			
			# Get random grid point
			var grid_points = grid.keys()
			if grid_points.size() > 0:
				var point = grid_points[randi() % grid_points.size()]
				
				# Update coordinates
				word_shapes[word].coordinates = point
				
				# Activate the point in the grid
				grid[point].active = true
				mapping.active_points.append(point)
				
				# Emit signal
				emit_signal("shape_transformed", source_shape, target_shape, point)
				
				print("Transformed word '" + word + "' from shape " + str(source_shape) + " to " + str(target_shape))
				return word_shapes[word]
	
	return null

# === WORD REGISTRATION ===

# Register a word with power and vector
func register_word(word, power = 1.0, vector = null):
	if vector == null:
		# Create random vector
		vector = Vector3(
			rand_range(-1, 1),
			rand_range(-1, 1),
			rand_range(-1, 1)
		).normalized()
	
	registered_words[word] = {
		"power": power,
		"vector": vector,
		"registered_at": OS.get_ticks_msec()
	}
	
	return registered_words[word]

# Get a registered word
func get_word(word):
	if registered_words.has(word):
		return registered_words[word]
	return null

# === GOAL SYSTEM ===

# Set a goal for a word trajectory
func set_word_goal(word, goal_type, target_value, current_value = 0):
	active_goals[word] = {
		"type": goal_type,
		"target": target_value,
		"current": current_value,
		"progress": 0.0,
		"created_at": OS.get_ticks_msec()
	}
	
	print("Set goal for word '" + word + "': " + goal_type + " = " + str(target_value))
	return active_goals[word]

# Advance progress on a word goal
func advance_word_goal(word, value = 1):
	if active_goals.has(word):
		var goal = active_goals[word]
		goal.current += value
		
		# Calculate progress
		if goal.target > 0:
			goal.progress = float(goal.current) / goal.target
		else:
			goal.progress = 1.0
		
		# Clamp progress
		goal.progress = clamp(goal.progress, 0.0, 1.0)
		
		# Emit signal
		emit_signal("goal_advanced", word, goal.type, goal.progress)
		
		print("Advanced goal for word '" + word + "': " + str(goal.current) + "/" + str(goal.target))
		
		# Check if goal is completed
		if goal.progress >= 1.0:
			print("Goal completed for word '" + word + "'")
			return true
	
	return false

# === UTILITY METHODS ===

# Get the vector for a word
func get_word_vector(word):
	if registered_words.has(word):
		return registered_words[word].vector
	return Vector3(0, 0, 0)

# Get the power for a word
func get_word_power(word):
	if registered_words.has(word):
		return registered_words[word].power
	return 0.0

# Get the shape for a word
func get_word_shape(word):
	if word_shapes.has(word):
		return word_shapes[word]
	return null

# Get all registered words
func get_all_words():
	return registered_words.keys()

# Get all shapes
func get_all_shapes():
	return word_shapes
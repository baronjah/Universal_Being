extends Node

class_name EtherealTunnel

# ======================================================================
# ETHEREAL TUNNEL SYSTEM
# Creates tunnels connecting all projects through dimensional bridges
# Enables creation of negative dimensions and dimensional gateways
# Supports spatial-linguistic connections and auto agent features
# ======================================================================

# Core system constants
const TUNNEL_VERSION = "1.0.0"
const MAX_DIMENSION = 12
const COLOR_CHANNELS = 9
const PERCEPTION_MODES = 7
const TURN_CYCLE = 12

# === Project connection paths ===
const PROJECT_PATHS = {
	"ethereal_engine": "/mnt/c/Users/Percision 15/12_turns_system/ethereal_akashic_bridge.gd",
	"akashic_records": "/mnt/c/Users/Percision 15/12_turns_system/akashic_database.js",
	"dimensional_color": "/mnt/c/Users/Percision 15/Eden_OS/dimensional_color_system.gd",
	"luminus_os": "/mnt/c/Users/Percision 15/LuminusOS/scripts/light_terminal.gd",
	"word_system": "/mnt/c/Users/Percision 15/12_turns_system/word_manifestation_system.gd"
}

# === Dimensional anchors ===
var dimensional_anchors = {}
var active_tunnels = {}
var perception_filters = {}
var word_manifestations = {}
var color_gateways = {}

# === Core state variables ===
var current_turn = 0
var current_dimension = 3
var active_colors = []
var thread_count = 0
var word_energy = 0.0
var bridge_stability = 1.0
var tunnel_intensity = 0.0
var awareness_level = 0
var ocr_calibration = {}

# === Dimensional coordinates ===
var tunnel_coordinates = [Vector3(0,0,0)] # Origin point
var dimensional_shifts = []
var projection_planes = []
var color_spectrums = []
var word_grids = []
var shape_manifolds = []
var word_trajectories = []
var negative_dimensions = {}
var dimensional_gateways = {}
var universal_shapes = []

# === Signals ===
signal tunnel_established(source, target, stability)
signal dimension_shifted(old_dim, new_dim)
signal word_manifested(word, energy, position)
signal color_spectrum_activated(colors)
signal ocr_detected(text, confidence, region)
signal tunnel_collapsed(reason)
signal dimensional_gateway_created(source_dim, target_dim)
signal negative_dimension_accessed(dimension, negative_dimension)
signal trajectory_created(word, steps, dimension)
signal universal_shape_applied(shape_type, affected_components)

# === Core initialization ===
func _ready():
	# Initialize the system
	print("Initializing Ethereal Tunnel system...")
	
	# Setup dimensional anchors
	_setup_dimensional_anchors()
	
	# Initialize color gateways
	_initialize_color_gateways()
	
	# Setup OCR calibration points
	_setup_ocr_calibration()
	
	# Initialize word manifestation system
	_initialize_word_system()
	
	# Establish initial tunnels
	_establish_initial_tunnels()
	
	print("Ethereal Tunnel v" + TUNNEL_VERSION + " initialized")

# === Tunnel establishment ===
func establish_tunnel(source, target, dimension = 3, color_spectrum = null):
	# Validate source and target
	if not dimensional_anchors.has(source):
		push_error("Invalid source anchor: " + source)
		return null
	
	if not dimensional_anchors.has(target):
		push_error("Invalid target anchor: " + target)
		return null
	
	print("Establishing tunnel from " + source + " to " + target + " in dimension " + str(dimension))
	
	# Calculate tunnel parameters
	var source_coords = dimensional_anchors[source].coordinates
	var target_coords = dimensional_anchors[target].coordinates
	var tunnel_length = source_coords.distance_to(target_coords)
	var stability = _calculate_tunnel_stability(dimension, tunnel_length)
	
	# Create the tunnel
	var tunnel_id = source + "_to_" + target
	
	# Use the provided color spectrum or generate one
	var spectrum = color_spectrum
	if spectrum == null:
		spectrum = _generate_color_spectrum(dimension)
	
	# Create tunnel definition
	var tunnel = {
		"id": tunnel_id,
		"source": source,
		"target": target,
		"dimension": dimension,
		"length": tunnel_length,
		"established": OS.get_unix_time(),
		"stability": stability,
		"color_spectrum": spectrum,
		"waypoints": _generate_tunnel_waypoints(source_coords, target_coords, dimension),
		"active": true
	}
	
	# Store the tunnel
	active_tunnels[tunnel_id] = tunnel
	
	# Update dimensional anchors
	dimensional_anchors[source].connected_tunnels.append(tunnel_id)
	dimensional_anchors[target].connected_tunnels.append(tunnel_id)
	
	# Emit signal
	emit_signal("tunnel_established", source, target, stability)
	
	return tunnel

# === Dimensional anchors setup ===
func _setup_dimensional_anchors():
	# Setup default anchors based on project paths
	for project_name in PROJECT_PATHS:
		var coords = _generate_coordinates_for_project(project_name)
		var anchor = {
			"name": project_name,
			"path": PROJECT_PATHS[project_name],
			"coordinates": coords,
			"dimension": current_dimension,
			"established": OS.get_unix_time(),
			"connected_tunnels": [],
			"color_affinity": _get_color_affinity_for_project(project_name),
			"word_resonance": _get_word_resonance_for_project(project_name)
		}
		
		dimensional_anchors[project_name] = anchor
		tunnel_coordinates.append(coords)

# === Generate coordinates for a project ===
func _generate_coordinates_for_project(project_name):
	# Use project name hash to generate unique coordinates
	var hash_val = 0
	for c in project_name:
		hash_val = ((hash_val << 5) - hash_val) + ord(c)
	
	# Normalize to reasonable coordinate range
	var x = (hash_val % 1000) / 100.0
	var y = ((hash_val / 1000) % 1000) / 100.0
	var z = ((hash_val / 1000000) % 1000) / 100.0
	
	return Vector3(x, y, z)

# === Calculate tunnel stability ===
func _calculate_tunnel_stability(dimension, length):
	# Higher dimensions are less stable
	var dim_factor = 1.0 - (dimension / MAX_DIMENSION) * 0.5
	
	# Longer tunnels are less stable
	var length_factor = 1.0 - length * 0.01
	
	# Current turn affects stability (cyclical pattern)
	var turn_factor = 1.0 - 0.1 * sin(current_turn * PI / (TURN_CYCLE / 2))
	
	# Calculate overall stability
	return clamp(dim_factor * length_factor * turn_factor * bridge_stability, 0.0, 1.0)

# === Generate waypoints for a tunnel ===
func _generate_tunnel_waypoints(source_coords, target_coords, dimension):
	var waypoints = []
	
	# Number of waypoints increases with dimension
	var waypoint_count = dimension * 2
	
	for i in range(waypoint_count):
		var t = float(i + 1) / (waypoint_count + 1)
		var base_point = source_coords.linear_interpolate(target_coords, t)
		
		# Add dimensional distortion based on dimension
		var distortion = dimension / 10.0
		var offset = Vector3(
			rand_range(-distortion, distortion),
			rand_range(-distortion, distortion),
			rand_range(-distortion, distortion)
		)
		
		waypoints.append(base_point + offset)
	
	return waypoints

# === Initialize color gateways ===
func _initialize_color_gateways():
	# Define the 9 base dimensional colors
	color_gateways = {
		"azure": {
			"color": Color("#1E90FF"),
			"dimension": 1,
			"vibration": 1.0,
			"projects": ["luminus_os"]
		},
		"emerald": {
			"color": Color("#50C878"),
			"dimension": 2,
			"vibration": 1.2,
			"projects": ["word_system"]
		},
		"amber": {
			"color": Color("#FFBF00"),
			"dimension": 3,
			"vibration": 1.4,
			"projects": ["ethereal_engine"]
		},
		"violet": {
			"color": Color("#8F00FF"),
			"dimension": 4,
			"vibration": 1.6,
			"projects": ["dimensional_color"]
		},
		"crimson": {
			"color": Color("#DC143C"),
			"dimension": 5,
			"vibration": 1.8,
			"projects": []
		},
		"indigo": {
			"color": Color("#4B0082"),
			"dimension": 6,
			"vibration": 2.0,
			"projects": ["akashic_records"]
		},
		"sapphire": {
			"color": Color("#0F52BA"),
			"dimension": 7,
			"vibration": 2.2,
			"projects": []
		},
		"gold": {
			"color": Color("#FFD700"),
			"dimension": 8,
			"vibration": 2.4,
			"projects": []
		},
		"silver": {
			"color": Color("#C0C0C0"),
			"dimension": 9,
			"vibration": 2.6,
			"projects": []
		}
	}
	
	# Add gateway connections
	for color_name in color_gateways:
		var gateway = color_gateways[color_name]
		
		# Add to active colors if it has project connections
		if gateway.projects.size() > 0:
			active_colors.append(color_name)
		
		# Add to color spectrums
		color_spectrums.append(gateway.color)
	}
	
	emit_signal("color_spectrum_activated", active_colors)

# === Get color affinity for project ===
func _get_color_affinity_for_project(project_name):
	for color_name in color_gateways:
		if color_gateways[color_name].projects.has(project_name):
			return color_name
	
	# Default color based on project name hash
	var hash_val = 0
	for c in project_name:
		hash_val = ((hash_val << 5) - hash_val) + ord(c)
	
	var color_index = hash_val % color_gateways.size()
	return color_gateways.keys()[color_index]

# === Generate color spectrum for dimension ===
func _generate_color_spectrum(dimension):
	var spectrum = []
	
	# Base colors for the dimension
	var primary_colors = []
	for color_name in color_gateways:
		if color_gateways[color_name].dimension <= dimension:
			primary_colors.append(color_gateways[color_name].color)
	
	# Create spectrum with primary colors and blends
	for i in range(min(5, primary_colors.size())):
		spectrum.append(primary_colors[i])
		
		if i < primary_colors.size() - 1:
			# Add a blend between adjacent colors
			var blend = primary_colors[i].linear_interpolate(primary_colors[i+1], 0.5)
			spectrum.append(blend)
	
	return spectrum

# === Get word resonance for project ===
func _get_word_resonance_for_project(project_name):
	# Extract key words from project name
	var words = project_name.split("_")
	
	# Add additional resonant words based on project type
	if project_name == "ethereal_engine":
		words.append_array(["reality", "creation", "manifestation", "dream"])
	elif project_name == "akashic_records":
		words.append_array(["memory", "knowledge", "history", "archive"])
	elif project_name == "dimensional_color":
		words.append_array(["spectrum", "hue", "vibration", "palette"])
	elif project_name == "luminus_os":
		words.append_array(["light", "system", "terminal", "command"])
	elif project_name == "word_system":
		words.append_array(["language", "meaning", "manifestation", "concept"])
	
	return words

# === Initialize word system ===
func _initialize_word_system():
	# Core word power values
	word_manifestations = {
		"create": 1.0,
		"connect": 0.9,
		"merge": 0.8,
		"transform": 0.7,
		"evolve": 0.7,
		"manifest": 0.6,
		"visualize": 0.6,
		"shape": 0.5,
		"color": 0.5,
		"dimension": 0.5,
		"bridge": 0.4,
		"tunnel": 0.4,
		"pathway": 0.3,
		"gateway": 0.3,
		"memory": 0.3,
		"akashic": 0.3,
		"ethereal": 0.2,
		"engine": 0.2,
		"record": 0.2,
		"system": 0.1,
		"light": 0.1,
		"dark": 0.1
	}
	
	# Generate word grids
	for i in range(4):
		var grid = _generate_word_grid(i+1)
		word_grids.append(grid)

# === Generate word grid ===
func _generate_word_grid(dimension):
	var grid = {}
	var grid_size = 4 * dimension
	
	# Place words in the grid
	var words = word_manifestations.keys()
	for i in range(min(words.size(), grid_size * grid_size)):
		var word = words[i]
		var x = i % grid_size
		var y = i / grid_size
		
		grid[Vector2(x, y)] = {
			"word": word,
			"power": word_manifestations[word],
			"dimension": dimension
		}
	
	return grid

# === Setup OCR calibration ===
func _setup_ocr_calibration():
	# Create calibration points
	ocr_calibration = {
		"center": Vector2(0.5, 0.5),
		"top_left": Vector2(0.1, 0.1),
		"top_right": Vector2(0.9, 0.1),
		"bottom_left": Vector2(0.1, 0.9),
		"bottom_right": Vector2(0.9, 0.9),
		"points": {},
		"grid_size": 8,
		"confidence": 0.95
	}
	
	# Generate grid of calibration points
	for x in range(ocr_calibration.grid_size):
		for y in range(ocr_calibration.grid_size):
			var pos_x = float(x) / (ocr_calibration.grid_size - 1)
			var pos_y = float(y) / (ocr_calibration.grid_size - 1)
			
			ocr_calibration.points[Vector2(pos_x, pos_y)] = {
				"character": _get_calibration_char(x, y),
				"color": _get_calibration_color(x, y),
				"detected": false
			}

# === Get calibration character ===
func _get_calibration_char(x, y):
	# Special characters at corners and center
	if x == 0 and y == 0:
		return "+"
	elif x == ocr_calibration.grid_size - 1 and y == 0:
		return "+"
	elif x == 0 and y == ocr_calibration.grid_size - 1:
		return "+"
	elif x == ocr_calibration.grid_size - 1 and y == ocr_calibration.grid_size - 1:
		return "+"
	elif x == ocr_calibration.grid_size / 2 and y == ocr_calibration.grid_size / 2:
		return "O"
	
	# Use alphanumeric characters for the rest
	var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	return chars[(x + y * ocr_calibration.grid_size) % chars.length()]

# === Get calibration color ===
func _get_calibration_color(x, y):
	var t_x = float(x) / (ocr_calibration.grid_size - 1)
	var t_y = float(y) / (ocr_calibration.grid_size - 1)
	
	# Use a color gradient
	var r = t_x
	var g = 1.0 - t_y
	var b = abs(t_x - t_y)
	
	return Color(r, g, b)

# === Establish initial tunnels ===
func _establish_initial_tunnels():
	# Connect ethereal_engine to akashic_records
	establish_tunnel("ethereal_engine", "akashic_records", 6)
	
	# Connect dimensional_color to word_system
	establish_tunnel("dimensional_color", "word_system", 4)
	
	# Connect luminus_os to ethereal_engine
	establish_tunnel("luminus_os", "ethereal_engine", 3)
	
	# Connect all other projects with lower dimension tunnels
	var projects = dimensional_anchors.keys()
	for i in range(projects.size()):
		for j in range(i+1, projects.size()):
			var source = projects[i]
			var target = projects[j]
			
			# Skip if already connected
			var tunnel_id = source + "_to_" + target
			var reverse_id = target + "_to_" + source
			
			if active_tunnels.has(tunnel_id) or active_tunnels.has(reverse_id):
				continue
			
			# Connect with dimension 2 tunnel
			establish_tunnel(source, target, 2)
	
	print("Established " + str(active_tunnels.size()) + " initial tunnels")

# === Process tunnel system ===
func _process(delta):
	# Update tunnel stability
	_update_tunnel_stability(delta)
	
	# Cycle turns
	_cycle_turns(delta)
	
	# Process word manifestations
	_process_word_manifestations(delta)
	
	# Update dimensionality
	_update_dimensionality(delta)

# === Update tunnel stability ===
func _update_tunnel_stability(delta):
	for tunnel_id in active_tunnels:
		var tunnel = active_tunnels[tunnel_id]
		
		# Higher dimensions fluctuate more
		var stability_change = randf() * 0.01 * tunnel.dimension / MAX_DIMENSION
		
		# Random fluctuation (negative more likely in higher dimensions)
		if randf() < 0.5 + (tunnel.dimension / MAX_DIMENSION) * 0.3:
			stability_change = -stability_change
		
		# Update stability
		tunnel.stability = clamp(tunnel.stability + stability_change, 0.1, 1.0)
		
		# Check for tunnel collapse
		if tunnel.stability < 0.2:
			if randf() < 0.1:
				_collapse_tunnel(tunnel_id, "Low stability")

# === Cycle turns ===
func _cycle_turns(delta):
	thread_count += delta
	
	if thread_count >= 10.0:  # 10 seconds per turn
		thread_count = 0
		current_turn = (current_turn + 1) % TURN_CYCLE
		
		print("Turn cycle advanced to " + str(current_turn))
		
		# Turn effects
		if current_turn == 0:
			# Full cycle completed
			_complete_turn_cycle()

# === Complete turn cycle ===
func _complete_turn_cycle():
	# Shift dimension
	var old_dimension = current_dimension
	current_dimension = min(current_dimension + 1, MAX_DIMENSION)
	
	if current_dimension != old_dimension:
		emit_signal("dimension_shifted", old_dimension, current_dimension)
		
		# Create new tunnel in the new dimension
		var projects = dimensional_anchors.keys()
		var source = projects[randi() % projects.size()]
		var target = projects[randi() % projects.size()]
		
		if source != target:
			establish_tunnel(source, target, current_dimension)

# === Process word manifestations ===
func _process_word_manifestations(delta):
	word_energy += delta * 0.05
	
	if word_energy >= 1.0:
		word_energy = 0.0
		
		# Manifest a word
		var words = word_manifestations.keys()
		var word = words[randi() % words.size()]
		var power = word_manifestations[word]
		
		# Random position
		var position = Vector3(
			rand_range(-5, 5),
			rand_range(-5, 5),
			rand_range(-5, 5)
		)
		
		emit_signal("word_manifested", word, power, position)

# === Update dimensionality ===
func _update_dimensionality(delta):
	tunnel_intensity = 0.5 + 0.5 * sin(OS.get_ticks_msec() / 2000.0)

# === Collapse tunnel ===
func _collapse_tunnel(tunnel_id, reason):
	if not active_tunnels.has(tunnel_id):
		return
	
	var tunnel = active_tunnels[tunnel_id]
	print("Tunnel " + tunnel_id + " collapsed: " + reason)
	
	# Update source and target anchors
	var source = tunnel.source
	var target = tunnel.target
	
	if dimensional_anchors.has(source):
		dimensional_anchors[source].connected_tunnels.erase(tunnel_id)
	
	if dimensional_anchors.has(target):
		dimensional_anchors[target].connected_tunnels.erase(tunnel_id)
	
	# Mark tunnel as inactive
	tunnel.active = false
	tunnel.collapsed_reason = reason
	tunnel.collapsed_time = OS.get_unix_time()
	
	emit_signal("tunnel_collapsed", reason)

# === Shift dimension ===
func shift_dimension(new_dimension):
	if new_dimension < 1 or new_dimension > MAX_DIMENSION:
		push_error("Invalid dimension: " + str(new_dimension))
		return false
	
	var old_dimension = current_dimension
	current_dimension = new_dimension
	
	print("Shifted from dimension " + str(old_dimension) + " to " + str(new_dimension))
	emit_signal("dimension_shifted", old_dimension, new_dimension)
	
	return true

# === Detect text with OCR ===
func detect_text(image_data, region = Rect2(0, 0, 1, 1)):
	# Simulate OCR detection
	var detected_text = "SAMPLE TEXT"
	var confidence = 0.85
	
	# Check calibration points in the region
	for point_pos in ocr_calibration.points:
		var point = ocr_calibration.points[point_pos]
		
		if region.has_point(point_pos):
			point.detected = true
			
			# Increase confidence based on detected calibration points
			confidence = min(confidence + 0.01, 0.99)
	
	emit_signal("ocr_detected", detected_text, confidence, region)
	
	return {
		"text": detected_text,
		"confidence": confidence,
		"region": region
	}

# === Manifest word ===
func manifest_word(word, dimension = current_dimension, position = null):
	if not word_manifestations.has(word):
		word_manifestations[word] = 0.5  # Default power for new words
	
	var power = word_manifestations[word]
	
	# Generate position if not provided
	if position == null:
		position = Vector3(
			rand_range(-5, 5),
			rand_range(-5, 5),
			rand_range(-5, 5)
		)
	
	# Adjust power based on dimension
	power *= 1.0 + (dimension / MAX_DIMENSION) * 0.5
	
	emit_signal("word_manifested", word, power, position)
	
	return {
		"word": word,
		"power": power,
		"position": position,
		"dimension": dimension
	}

# === Get system status ===
func get_status():
	return {
		"version": TUNNEL_VERSION,
		"current_turn": current_turn,
		"current_dimension": current_dimension,
		"active_colors": active_colors,
		"word_energy": word_energy,
		"bridge_stability": bridge_stability,
		"tunnel_intensity": tunnel_intensity,
		"tunnels": active_tunnels.size(),
		"anchors": dimensional_anchors.size()
	}

# === Connect projects ===
func connect_projects(source_project, target_project, dimension = null):
	# Use current dimension if not specified
	if dimension == null:
		dimension = current_dimension
	
	# Verify projects exist
	if not PROJECT_PATHS.has(source_project):
		push_error("Source project not found: " + source_project)
		return null
	
	if not PROJECT_PATHS.has(target_project):
		push_error("Target project not found: " + target_project)
		return null
	
	# Ensure anchors exist
	if not dimensional_anchors.has(source_project):
		_setup_anchor_for_project(source_project)
	
	if not dimensional_anchors.has(target_project):
		_setup_anchor_for_project(target_project)
	
	# Establish tunnel
	return establish_tunnel(source_project, target_project, dimension)

# === Setup anchor for project ===
func _setup_anchor_for_project(project_name):
	if not PROJECT_PATHS.has(project_name):
		push_error("Project not found: " + project_name)
		return null
	
	var coords = _generate_coordinates_for_project(project_name)
	var anchor = {
		"name": project_name,
		"path": PROJECT_PATHS[project_name],
		"coordinates": coords,
		"dimension": current_dimension,
		"established": OS.get_unix_time(),
		"connected_tunnels": [],
		"color_affinity": _get_color_affinity_for_project(project_name),
		"word_resonance": _get_word_resonance_for_project(project_name)
	}
	
	dimensional_anchors[project_name] = anchor
	tunnel_coordinates.append(coords)
	
	return anchor

# === Create dimensional gateway ===
func create_dimensional_gateway(source_dim, target_dim):
	# Validate dimensions
	if source_dim < 1 or source_dim > MAX_DIMENSION:
		push_error("Invalid source dimension: " + str(source_dim))
		return null
	
	# Handle negative dimensions as special case
	if target_dim < 0:
		var negative_dim = abs(target_dim)
		if negative_dim > MAX_DIMENSION:
			push_error("Invalid negative dimension: " + str(target_dim))
			return null
		
		# Create negative dimension if it doesn't exist
		if not negative_dimensions.has(negative_dim):
			negative_dimensions[negative_dim] = {
				"dimension": -negative_dim,
				"created_at": OS.get_unix_time(),
				"stability": bridge_stability * 0.7,  # Less stable
				"anchors": {}
			}
			
			# Mirror anchors from positive dimension
			if dimensional_anchors.has(source_dim):
				for anchor_name in dimensional_anchors[source_dim]:
					var original = dimensional_anchors[source_dim][anchor_name]
					
					# Invert coordinates for negative dimension
					var inverse_coords = original.coordinates * -1
					
					negative_dimensions[negative_dim].anchors[anchor_name] = {
						"name": anchor_name + "_negative",
						"coordinates": inverse_coords,
						"dimension": -negative_dim,
						"established": OS.get_unix_time()
					}
		}
	
	# Create the gateway
	var gateway_id = "dim" + str(source_dim) + "_to_dim" + str(target_dim)
	
	dimensional_gateways[gateway_id] = {
		"id": gateway_id,
		"source_dimension": source_dim,
		"target_dimension": target_dim,
		"created_at": OS.get_unix_time(),
		"stability": bridge_stability,
		"active": true
	}
	
	# Emit signal
	emit_signal("dimensional_gateway_created", source_dim, target_dim)
	
	print("Created dimensional gateway from dimension " + str(source_dim) + " to dimension " + str(target_dim))
	return dimensional_gateways[gateway_id]

# === Access negative dimension ===
func access_negative_dimension(dimension):
	if dimension < 1 or dimension > MAX_DIMENSION:
		push_error("Invalid dimension: " + str(dimension))
		return null
	
	var negative_dim = -dimension
	
	# Check if negative dimension exists or create it
	if not negative_dimensions.has(dimension):
		create_dimensional_gateway(dimension, negative_dim)
	
	# Emit signal
	emit_signal("negative_dimension_accessed", dimension, negative_dim)
	
	print("Accessed negative dimension " + str(negative_dim))
	return negative_dimensions[dimension]

# === Create word trajectory ===
func create_word_trajectory(word, steps = 12, dimension = current_dimension):
	# Generate a trajectory path
	var trajectory = []
	var start_position = Vector3(0, 0, 0)
	
	# Add starting point
	trajectory.append(start_position)
	
	# Get word power from manifestations or use default
	var power = 1.0
	if word_manifestations.has(word):
		power = word_manifestations[word]
	
	# Generate trajectory
	for i in range(1, steps):
		var t = float(i) / steps
		
		# Create a curved path influenced by word power
		var position = start_position + Vector3(
			sin(t * PI * 2) * power * 3.0,
			cos(t * PI * 3) * power * 2.0,
			t * 10.0
		)
		
		# Add some noise based on dimension
		position += Vector3(
			rand_range(-0.2, 0.2) * dimension / MAX_DIMENSION,
			rand_range(-0.2, 0.2) * dimension / MAX_DIMENSION,
			rand_range(-0.2, 0.2) * dimension / MAX_DIMENSION
		)
		
		trajectory.append(position)
	
	# Store trajectory
	var trajectory_id = word + "_trajectory_" + str(OS.get_unix_time())
	
	word_trajectories[trajectory_id] = {
		"id": trajectory_id,
		"word": word,
		"dimension": dimension,
		"steps": trajectory,
		"created_at": OS.get_unix_time(),
		"power": power,
		"completed": false
	}
	
	# Emit signal
	emit_signal("trajectory_created", word, trajectory, dimension)
	
	print("Created trajectory for word '" + word + "' with " + str(steps) + " steps")
	return word_trajectories[trajectory_id]

# === Apply universal shape ===
func apply_universal_shape(shape_type, components = null):
	# Default to all anchors if no components specified
	if components == null:
		components = dimensional_anchors.keys()
	
	# Create the shape
	var shape_id = "shape_" + str(shape_type) + "_" + str(OS.get_unix_time())
	
	universal_shapes.append({
		"id": shape_id,
		"type": shape_type,
		"affected_components": components,
		"created_at": OS.get_unix_time(),
		"dimension": current_dimension,
		"active": true
	})
	
	# Emit signal
	emit_signal("universal_shape_applied", shape_type, components)
	
	print("Applied universal shape " + str(shape_type) + " to " + str(components.size()) + " components")
	return shape_id
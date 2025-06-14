extends Node

# =============================================================================
# GAME CORE SYSTEM
# Main controller for the Ethereal Engine and Akashic Records integration
# Manages the dimensional bridge between all components
# Integrates spatial linguistic processing with auto agent mode
# =============================================================================

# === CORE SYSTEM CONSTANTS ===
const VERSION = "1.1.0"
const MAX_DIMENSION = 12
const TURN_CYCLE = 12
const COLOR_CHANNELS = 9
const WORD_POWER_THRESHOLD = 3.0
const TRAJECTORY_STEPS = 14
const DATA_FLOW_CHANNELS = 7

# === PROJECT CONNECTIONS ===
const PROJECT_PATHS = {
	"ethereal_engine": "res://ethereal_tunnel.gd",
	"akashic_records": "res://12_turns_system/akashic_database.js",
	"dimensional_color": "res://Eden_OS/dimensional_color_system.gd",
	"word_system": "res://12_turns_system/word_manifestation_system.gd",
	"ocr_system": "res://12_turns_system/ocr_processor.gd",
	"shape_system": "res://Eden_OS/shape_system.gd",
	"spatial_linguistic": "res://spatial_linguistic_connector.gd",
	"auto_agent": "res://auto_agent_mode.gd",
	"universal_data_flow": "res://universal_data_flow.gd",
	"project_connector": "res://project_connector_system.gd"
}

# === CORE STATE VARIABLES ===
var current_turn = 0        # Current turn in the 12-turn cycle
var active_dimension = 3    # Current active dimension (3D default)
var word_energy = 0.0       # Accumulated word manifestation energy
var bridge_stability = 1.0  # Stability of dimensional bridges
var thread_count = 0        # Active processing threads
var awareness_level = 1     # System awareness level (1-12)
var ocr_confidence = 0.85   # OCR recognition confidence threshold

# === SYSTEM COMPONENTS ===
var ethereal_tunnel = null         # Tunnel system between projects
var word_processor = null          # Word manifestation processor
var color_system = null            # Dimensional color system
var shape_system = null            # Shape manifestation system
var ocr_system = null              # OCR processing system
var spatial_linguistic = null      # Spatial linguistic connector system
var auto_agent = null              # Auto agent mode system
var universal_data_flow = null     # Universal data flow system
var project_connector = null       # Project connector system

# === DIMENSIONAL DATA ===
var dimensional_anchors = {}   # Anchor points in dimensional space
var active_tunnels = {}        # Active tunnels between dimensions
var manifested_words = []      # Words that have been manifested
var active_colors = []         # Currently active color channels
var ocr_regions = []           # Active OCR scanning regions
var shape_grids = []           # Shape grid patterns
var word_trajectories = []     # Word trajectory paths
var project_centers = {}       # Project center coordinates
var data_flows = {}            # Active data flow channels
var sound_signatures = []      # Sound signatures for communication
var file_connections = {}      # Connected files and folders
var negative_dimensions = {}   # Negative dimension counterparts

# === TURN-BASED DATA ===
var turn_effects = []       # Effects that trigger on specific turns
var turn_history = []       # History of past turns
var turn_predictions = []   # Predicted future turn outcomes

# === SIGNALS ===
signal turn_advanced(turn_number)
signal dimension_shifted(old_dim, new_dim)
signal word_manifested(word, power, position)
signal color_activated(color_name, channel, intensity)
signal ocr_detected(text, confidence, region)
signal shape_formed(shape_type, coordinates, dimension)
signal tunnel_established(source, target, stability)
signal trajectory_created(word, steps, dimension)
signal project_connected(source, target, connection_type)
signal data_flow_established(source, target, channel, direction)
signal file_modified(file_path, type, content)
signal sound_signature_activated(signature, amplitude, frequency)
signal agent_mode_activated(mode, parameters)
signal negative_dimension_created(dimension, negative_dimension)

# === INITIALIZATION ===
func _ready():
	print("Initializing game core system...")
	
	# Initialize the ethereal tunnel system
	_initialize_ethereal_tunnel()
	
	# Initialize word processor
	_initialize_word_processor()
	
	# Initialize color system
	_initialize_color_system()
	
	# Initialize shape system
	_initialize_shape_system()
	
	# Initialize OCR system
	_initialize_ocr_system()
	
	# Initialize spatial linguistic connector
	_initialize_spatial_linguistic()
	
	# Initialize auto agent mode
	_initialize_auto_agent()
	
	# Initialize universal data flow
	_initialize_universal_data_flow()
	
	# Initialize project connector
	_initialize_project_connector()
	
	# Setup turn effects
	_setup_turn_effects()
	
	# Initialize negative dimensions
	_initialize_negative_dimensions()
	
	# Connect signals
	_connect_signals()
	
	print("Game core system v" + VERSION + " initialized")
	print("Current dimension: " + str(active_dimension))
	print("Current turn: " + str(current_turn) + " of " + str(TURN_CYCLE))
	print("Spatial linguistic connector: " + ("Active" if spatial_linguistic != null else "Inactive"))
	print("Auto agent mode: " + ("Active" if auto_agent != null else "Inactive"))
	print("Universal data flow: " + ("Active" if universal_data_flow != null else "Inactive"))
	print("Project connector: " + ("Active" if project_connector != null else "Inactive"))

# === MAIN PROCESSING LOOP ===
func _process(delta):
	# Process turn advancement
	_process_turn_advancement(delta)
	
	# Process word manifestation
	_process_word_manifestation(delta)
	
	# Process dimensional stability
	_process_dimension_stability(delta)
	
	# Process OCR detection
	_process_ocr_detection(delta)
	
	# Process word trajectories
	_process_word_trajectories(delta)
	
	# Process data flows
	_process_data_flows(delta)
	
	# Process project connections
	_process_project_connections(delta)
	
	# Process file modifications
	_process_file_modifications(delta)
	
	# Process auto agent mode
	_process_auto_agent_mode(delta)

# === TURN ADVANCEMENT PROCESSING ===
func _process_turn_advancement(delta):
	thread_count += delta
	
	# Advance turn every 10 seconds
	if thread_count >= 10.0:
		thread_count = 0.0
		advance_turn()

# === WORD MANIFESTATION PROCESSING ===
func _process_word_manifestation(delta):
	# Accumulate word energy
	word_energy += delta * 0.1 * awareness_level
	
	# Manifest words when energy threshold reached
	if word_energy >= WORD_POWER_THRESHOLD:
		word_energy -= WORD_POWER_THRESHOLD
		_manifest_random_word()

# === DIMENSIONAL STABILITY PROCESSING ===
func _process_dimension_stability(delta):
	# Calculate stability fluctuation
	var stability_change = sin(OS.get_ticks_msec() / 1000.0) * 0.01
	
	# Apply stability change
	bridge_stability = clamp(bridge_stability + stability_change, 0.5, 1.0)
	
	# Update ethereal tunnel stability
	if ethereal_tunnel != null:
		ethereal_tunnel.bridge_stability = bridge_stability

# === OCR DETECTION PROCESSING ===
func _process_ocr_detection(delta):
	# Periodic OCR scanning on active regions
	if ocr_system != null and randf() < 0.05:  # 5% chance per frame
		for region in ocr_regions:
			# Simulated detection (would connect to actual OCR in implementation)
			var detection = {
				"text": _generate_random_text(),
				"confidence": ocr_confidence + randf() * 0.1,
				"region": region
			}
			
			emit_signal("ocr_detected", detection.text, detection.confidence, detection.region)

# === WORD TRAJECTORIES PROCESSING ===
func _process_word_trajectories(delta):
	if spatial_linguistic != null and randf() < 0.1:  # 10% chance per frame
		# Process active word trajectories
		for i in range(word_trajectories.size()):
			if i < word_trajectories.size():  # Check again as array might change during iteration
				var trajectory = word_trajectories[i]
				
				# Advance trajectory step
				trajectory.current_step += 1
				
				# Update position
				if trajectory.current_step < trajectory.steps.size():
					trajectory.current_position = trajectory.steps[trajectory.current_step]
				else:
					# Trajectory complete
					_on_trajectory_completed(trajectory)
					word_trajectories.remove(i)
					i -= 1  # Adjust counter for removed item
		
		# Create new trajectories occasionally
		if randf() < 0.2 and manifested_words.size() > 0:  # 20% chance of the 10% chance
			var word_index = randi() % manifested_words.size()
			var word = manifested_words[word_index].word
			
			_create_word_trajectory(word, active_dimension)

# === DATA FLOWS PROCESSING ===
func _process_data_flows(delta):
	if universal_data_flow != null:
		# Process active data flows
		for channel_name in data_flows:
			var channel = data_flows[channel_name]
			
			if channel.active and channel.source != null and channel.target != null:
				# Flow data between source and target
				var flow_amount = delta * channel.amplitude * channel.frequency
				
				# Notify about data flow
				if randf() < 0.05:  # Occasional notification
					emit_signal("data_flow_established", channel.source, channel.target, channel_name, channel.direction)
				
				# Generate negative occasionally
				if randf() < 0.02:  # 2% chance per frame
					universal_data_flow.generate_negative(channel.source)
		
		# Activate new flows occasionally
		if randf() < 0.01:  # 1% chance per frame
			_activate_random_data_flow()

# === PROJECT CONNECTIONS PROCESSING ===
func _process_project_connections(delta):
	if project_connector != null:
		# Process file connections
		for file_path in file_connections:
			var connection = file_connections[file_path]
			
			if connection.active:
				# Sync with connected files occasionally
				if randf() < 0.05:  # 5% chance per frame
					for target in connection.connected_to:
						project_connector.synchronize_files(file_path, target)
		
		# Create new connections occasionally
		if randf() < 0.01:  # 1% chance per frame
			_create_random_file_connection()

# === FILE MODIFICATIONS PROCESSING ===
func _process_file_modifications(delta):
	if project_connector != null and randf() < 0.01:  # 1% chance per frame
		# Simulated file modification
		var file_types = ["script", "scene", "resource", "data"]
		var modification_types = ["create", "update", "merge"]
		
		# Select random parameters
		var file_type = file_types[randi() % file_types.size()]
		var mod_type = modification_types[randi() % modification_types.size()]
		var base_path = "res://" + file_type + "_" + str(randi() % 100) + "." + file_type
		
		# Emit signal for file modification
		emit_signal("file_modified", base_path, mod_type, "Simulated content")
		
		# Activate sound signature for file modification
		_activate_sound_signature("connection")

# === AUTO AGENT MODE PROCESSING ===
func _process_auto_agent_mode(delta):
	if auto_agent != null:
		# Process agent mode
		var mode_active = auto_agent.is_active()
		
		if mode_active:
			# Apply transformations occasionally
			if randf() < 0.1:  # 10% chance per frame
				var operations = auto_agent.get_available_operations()
				if operations.size() > 0:
					var operation = operations[randi() % operations.size()]
					
					# Apply transform to a random word
					if manifested_words.size() > 0:
						var word_index = randi() % manifested_words.size()
						var word = manifested_words[word_index].word
						
						auto_agent.apply_transform(operation, word)
						
						# Emit signal
						emit_signal("agent_mode_activated", operation, {"word": word})

# === INITIALIZE ETHEREAL TUNNEL ===
func _initialize_ethereal_tunnel():
	ethereal_tunnel = load(PROJECT_PATHS.ethereal_engine).new()
	add_child(ethereal_tunnel)
	
	# Store the dimensional anchors and tunnels
	dimensional_anchors = ethereal_tunnel.dimensional_anchors
	active_tunnels = ethereal_tunnel.active_tunnels
	
	print("Ethereal tunnel system initialized with " + str(dimensional_anchors.size()) + " anchors")

# === INITIALIZE WORD PROCESSOR ===
func _initialize_word_processor():
	# In a real implementation, would load the word system
	# For this example, we'll create a simple processor
	word_processor = Node.new()
	word_processor.name = "WordProcessor"
	add_child(word_processor)
	
	# Initialize with core words
	var core_words = [
		"create", "connect", "merge", "transform", "evolve",
		"manifest", "visualize", "shape", "color", "dimension"
	]
	
	for word in core_words:
		manifested_words.append({
			"word": word,
			"power": 1.0,
			"manifested": false
		})
	
	print("Word processor initialized with " + str(core_words.size()) + " core words")

# === INITIALIZE COLOR SYSTEM ===
func _initialize_color_system():
	# In a real implementation, would load the color system
	# For this example, we'll create a simple system
	color_system = Node.new()
	color_system.name = "ColorSystem"
	add_child(color_system)
	
	# Initialize with core colors
	active_colors = [
		"azure", "emerald", "amber", "violet", "crimson",
		"indigo", "sapphire", "gold", "silver"
	]
	
	print("Color system initialized with " + str(active_colors.size()) + " active colors")

# === INITIALIZE SHAPE SYSTEM ===
func _initialize_shape_system():
	# In a real implementation, would load the shape system
	# For this example, we'll create a simple system
	shape_system = Node.new()
	shape_system.name = "ShapeSystem"
	add_child(shape_system)
	
	# Initialize shape grids
	for i in range(4):
		var grid_size = 4 * (i + 1)
		var grid = {}
		
		for x in range(grid_size):
			for y in range(grid_size):
				grid[Vector2(x, y)] = {
					"active": false,
					"shape_type": i,
					"dimension": i + 1
				}
		
		shape_grids.append(grid)
	
	print("Shape system initialized with " + str(shape_grids.size()) + " shape grids")

# === INITIALIZE OCR SYSTEM ===
func _initialize_ocr_system():
	# In a real implementation, would load the OCR system
	# For this example, we'll create a simple system
	ocr_system = Node.new()
	ocr_system.name = "OCRSystem"
	add_child(ocr_system)
	
	# Initialize OCR regions
	ocr_regions = [
		Rect2(0.1, 0.1, 0.8, 0.1),  # Top strip
		Rect2(0.1, 0.4, 0.8, 0.2),  # Middle strip
		Rect2(0.1, 0.8, 0.8, 0.1)   # Bottom strip
	]
	
	print("OCR system initialized with " + str(ocr_regions.size()) + " scanning regions")

# === SETUP TURN EFFECTS ===
func _setup_turn_effects():
	# Each turn has specific effects
	turn_effects = [
		{ "dimension_shift": 1, "word_boost": ["create", "manifest"] },
		{ "color_boost": ["azure", "emerald"], "ocr_regions": [0] },
		{ "shape_activation": 0, "word_boost": ["connect", "bridge"] },
		{ "dimension_shift": 2, "color_boost": ["amber", "crimson"] },
		{ "tunnel_creation": true, "ocr_regions": [1] },
		{ "word_boost": ["transform", "evolve"], "shape_activation": 1 },
		{ "dimension_shift": 3, "color_boost": ["violet", "indigo"] },
		{ "tunnel_stability": 0.8, "ocr_regions": [2] },
		{ "shape_activation": 2, "word_boost": ["dimension", "reality"] },
		{ "dimension_shift": 4, "color_boost": ["sapphire", "gold"] },
		{ "tunnel_creation": true, "word_boost": ["merge", "unify"] },
		{ "dimension_shift": 1, "color_boost": ["silver"], "shape_activation": 3 }
	]
	
	print("Turn effects configured for " + str(turn_effects.size()) + " turns")

# === INITIALIZE SPATIAL LINGUISTIC CONNECTOR ===
func _initialize_spatial_linguistic():
	spatial_linguistic = load(PROJECT_PATHS.spatial_linguistic).new()
	add_child(spatial_linguistic)
	
	# Initialize trajectory systems
	spatial_linguistic.initialize_trajectory_system(TRAJECTORY_STEPS)
	spatial_linguistic.initialize_shape_mapping(shape_grids)
	
	# Initialize word mapping
	for word in manifested_words:
		spatial_linguistic.register_word(word.word, word.power)
	
	print("Spatial linguistic connector initialized with " + str(TRAJECTORY_STEPS) + " trajectory steps")
	
# === INITIALIZE AUTO AGENT MODE ===
func _initialize_auto_agent():
	auto_agent = load(PROJECT_PATHS.auto_agent).new()
	add_child(auto_agent)
	
	# Initialize transform operations
	auto_agent.initialize_operations()
	
	# Initialize project centers
	project_centers = {
		"ethereal_engine": Vector3(0, 0, 5),
		"akashic_records": Vector3(5, 0, 0),
		"word_system": Vector3(0, 5, 0),
		"project_connector": Vector3(-5, 0, 0),
		"universal_data_flow": Vector3(0, -5, 0)
	}
	auto_agent.set_project_centers(project_centers)
	
	print("Auto agent mode initialized with " + str(auto_agent.get_operation_count()) + " transform operations")

# === INITIALIZE UNIVERSAL DATA FLOW ===
func _initialize_universal_data_flow():
	universal_data_flow = load(PROJECT_PATHS.universal_data_flow).new()
	add_child(universal_data_flow)
	
	# Initialize data flow channels
	for i in range(DATA_FLOW_CHANNELS):
		data_flows["channel_" + str(i)] = {
			"active": false,
			"source": null,
			"target": null,
			"direction": "bidirectional",
			"amplitude": 1.0,
			"frequency": 0.2
		}
	
	universal_data_flow.set_data_flows(data_flows)
	universal_data_flow.initialize_negative_generator()
	
	print("Universal data flow initialized with " + str(DATA_FLOW_CHANNELS) + " flow channels")

# === INITIALIZE PROJECT CONNECTOR ===
func _initialize_project_connector():
	project_connector = load(PROJECT_PATHS.project_connector).new()
	add_child(project_connector)
	
	# Initialize project paths
	project_connector.set_project_paths(PROJECT_PATHS)
	
	# Initialize sound capabilities
	sound_signatures = [
		{ "name": "connection", "frequency": 440, "amplitude": 0.5, "duration": 0.2 },
		{ "name": "dimension_shift", "frequency": 880, "amplitude": 0.7, "duration": 0.3 },
		{ "name": "word_manifest", "frequency": 220, "amplitude": 0.6, "duration": 0.4 },
		{ "name": "data_flow", "frequency": 660, "amplitude": 0.4, "duration": 0.1 }
	]
	project_connector.set_sound_signatures(sound_signatures)
	
	print("Project connector initialized with " + str(sound_signatures.size()) + " sound signatures")

# === INITIALIZE NEGATIVE DIMENSIONS ===
func _initialize_negative_dimensions():
	# Create negative dimensions for dimensional reflection
	for dim in range(1, MAX_DIMENSION + 1):
		negative_dimensions[dim] = -dim
		
		# Create dimensional gateways between positive and negative dimensions
		if ethereal_tunnel != null:
			ethereal_tunnel.create_dimensional_gateway(dim, negative_dimensions[dim])
	
	print("Negative dimensions initialized with " + str(negative_dimensions.size()) + " dimensions")

# === CONNECT SIGNALS ===
func _connect_signals():
	# Connect ethereal tunnel signals
	if ethereal_tunnel != null:
		ethereal_tunnel.connect("tunnel_established", self, "_on_tunnel_established")
		ethereal_tunnel.connect("dimension_shifted", self, "_on_dimension_shifted")
		ethereal_tunnel.connect("word_manifested", self, "_on_word_manifested")
		ethereal_tunnel.connect("color_spectrum_activated", self, "_on_color_spectrum_activated")
		ethereal_tunnel.connect("ocr_detected", self, "_on_ocr_detected")
		ethereal_tunnel.connect("tunnel_collapsed", self, "_on_tunnel_collapsed")
	
	# Connect spatial linguistic signals
	if spatial_linguistic != null:
		spatial_linguistic.connect("trajectory_created", self, "_on_trajectory_created")
		spatial_linguistic.connect("word_mapped", self, "_on_word_mapped")
	
	# Connect auto agent signals
	if auto_agent != null:
		auto_agent.connect("agent_mode_activated", self, "_on_agent_mode_activated")
		auto_agent.connect("transform_applied", self, "_on_transform_applied")
	
	# Connect universal data flow signals
	if universal_data_flow != null:
		universal_data_flow.connect("data_flow_established", self, "_on_data_flow_established")
		universal_data_flow.connect("negative_generated", self, "_on_negative_generated")
	
	# Connect project connector signals
	if project_connector != null:
		project_connector.connect("project_connected", self, "_on_project_connected")
		project_connector.connect("file_modified", self, "_on_file_modified")
		project_connector.connect("sound_activated", self, "_on_sound_activated")
	
	print("All signals connected")

# === ADVANCE TURN ===
func advance_turn():
	var old_turn = current_turn
	current_turn = (current_turn + 1) % TURN_CYCLE
	
	print("Advancing from turn " + str(old_turn) + " to turn " + str(current_turn))
	
	# Record turn history
	turn_history.append({
		"turn": old_turn,
		"dimension": active_dimension,
		"words_active": manifested_words.size(),
		"tunnels_active": active_tunnels.size(),
		"timestamp": OS.get_unix_time()
	})
	
	# Apply turn effects
	var effects = turn_effects[current_turn]
	
	# Dimension shift effect
	if effects.has("dimension_shift"):
		shift_dimension(effects.dimension_shift)
	
	# Word boost effect
	if effects.has("word_boost"):
		for word in effects.word_boost:
			_boost_word(word)
	
	# Color boost effect
	if effects.has("color_boost"):
		for color in effects.color_boost:
			_boost_color(color)
	
	# OCR region focus
	if effects.has("ocr_regions"):
		for region_index in effects.ocr_regions:
			_focus_ocr_region(region_index)
	
	# Shape activation
	if effects.has("shape_activation"):
		_activate_shape_grid(effects.shape_activation)
	
	# Tunnel creation
	if effects.has("tunnel_creation") and effects.tunnel_creation:
		_create_random_tunnel()
	
	# Tunnel stability adjustment
	if effects.has("tunnel_stability"):
		bridge_stability = effects.tunnel_stability
	
	emit_signal("turn_advanced", current_turn)
	return current_turn

# === SHIFT DIMENSION ===
func shift_dimension(new_dimension):
	var old_dimension = active_dimension
	active_dimension = new_dimension
	
	print("Dimension shifted from " + str(old_dimension) + " to " + str(active_dimension))
	
	# Update ethereal tunnel
	if ethereal_tunnel != null:
		ethereal_tunnel.shift_dimension(active_dimension)
	
	emit_signal("dimension_shifted", old_dimension, active_dimension)
	return active_dimension

# === MANIFEST WORD ===
func manifest_word(word, power = 1.0, position = null):
	# Check if word already exists
	var word_exists = false
	for w in manifested_words:
		if w.word == word:
			w.power += power
			w.manifested = true
			word_exists = true
			break
	
	# Add new word if needed
	if not word_exists:
		manifested_words.append({
			"word": word,
			"power": power,
			"manifested": true
		})
	
	print("Manifested word: " + word + " with power " + str(power))
	
	# Generate position if not provided
	if position == null:
		position = Vector3(
			rand_range(-5, 5),
			rand_range(-5, 5),
			rand_range(-5, 5)
		)
	
	emit_signal("word_manifested", word, power, position)
	
	# Manifest in ethereal tunnel if available
	if ethereal_tunnel != null:
		ethereal_tunnel.manifest_word(word, active_dimension, position)
	
	return {
		"word": word,
		"power": power,
		"position": position
	}

# === ACTIVATE COLOR ===
func activate_color(color_name, channel = 0, intensity = 1.0):
	if not active_colors.has(color_name):
		active_colors.append(color_name)
	
	print("Activated color: " + color_name + " on channel " + str(channel) + " with intensity " + str(intensity))
	
	emit_signal("color_activated", color_name, channel, intensity)
	return true

# === DETECT TEXT WITH OCR ===
func detect_text(region = null):
	# Use first region if none specified
	if region == null and ocr_regions.size() > 0:
		region = ocr_regions[0]
	
	# Generate simulated OCR result
	var text = _generate_random_text()
	var confidence = ocr_confidence + randf() * 0.1
	
	print("OCR detected: \"" + text + "\" with confidence " + str(confidence))
	
	emit_signal("ocr_detected", text, confidence, region)
	
	# Use ethereal tunnel OCR if available
	if ethereal_tunnel != null:
		ethereal_tunnel.detect_text(null, region)
	
	return {
		"text": text,
		"confidence": confidence,
		"region": region
	}

# === CREATE SHAPE ===
func create_shape(shape_type, coordinates, dimension = active_dimension):
	print("Created shape: " + str(shape_type) + " at " + str(coordinates) + " in dimension " + str(dimension))
	
	emit_signal("shape_formed", shape_type, coordinates, dimension)
	return true

# === ESTABLISH TUNNEL ===
func establish_tunnel(source, target, dimension = active_dimension):
	print("Establishing tunnel from " + source + " to " + target + " in dimension " + str(dimension))
	
	# Use ethereal tunnel if available
	if ethereal_tunnel != null:
		var tunnel = ethereal_tunnel.establish_tunnel(source, target, dimension)
		return tunnel
	
	# Fallback if tunnel system not available
	var tunnel = {
		"id": source + "_to_" + target,
		"source": source,
		"target": target,
		"dimension": dimension,
		"established": OS.get_ticks_msec(),
		"stability": bridge_stability
	}
	
	active_tunnels[tunnel.id] = tunnel
	emit_signal("tunnel_established", source, target, bridge_stability)
	
	return tunnel

# === CONNECT PROJECTS ===
func connect_projects(source_project, target_project, dimension = null):
	if dimension == null:
		dimension = active_dimension
	
	print("Connecting projects: " + source_project + " to " + target_project + " in dimension " + str(dimension))
	
	# Use ethereal tunnel if available
	if ethereal_tunnel != null:
		return ethereal_tunnel.connect_projects(source_project, target_project, dimension)
	
	return establish_tunnel(source_project, target_project, dimension)

# === BOOST WORD ===
func _boost_word(word, boost_amount = 0.5):
	for w in manifested_words:
		if w.word == word:
			w.power += boost_amount
			print("Boosted word: " + word + " by " + str(boost_amount) + " to " + str(w.power))
			return w.power
	
	# Word not found, manifest it
	return manifest_word(word, boost_amount).power

# === BOOST COLOR ===
func _boost_color(color_name, channel = 0, boost_amount = 0.3):
	var intensity = 1.0 + boost_amount
	activate_color(color_name, channel, intensity)
	print("Boosted color: " + color_name + " on channel " + str(channel) + " to intensity " + str(intensity))
	return intensity

# === FOCUS OCR REGION ===
func _focus_ocr_region(region_index):
	if region_index >= 0 and region_index < ocr_regions.size():
		var region = ocr_regions[region_index]
		detect_text(region)
		print("Focused OCR on region " + str(region_index) + ": " + str(region))
		return true
	return false

# === ACTIVATE SHAPE GRID ===
func _activate_shape_grid(grid_index):
	if grid_index >= 0 and grid_index < shape_grids.size():
		var grid = shape_grids[grid_index]
		
		for coord in grid:
			grid[coord].active = true
			
			if randf() < 0.3:  # 30% chance to form a shape at this position
				create_shape(grid_index, coord, grid[coord].dimension)
		
		print("Activated shape grid " + str(grid_index) + " with " + str(grid.size()) + " points")
		return true
	return false

# === CREATE RANDOM TUNNEL ===
func _create_random_tunnel():
	# Get random source and target from dimensional anchors
	if ethereal_tunnel != null and dimensional_anchors.size() >= 2:
		var anchors = dimensional_anchors.keys()
		var source = anchors[randi() % anchors.size()]
		
		var target = source
		while target == source:
			target = anchors[randi() % anchors.size()]
		
		var tunnel = establish_tunnel(source, target, active_dimension)
		print("Created random tunnel from " + source + " to " + target)
		return tunnel
	
	return null

# === MANIFEST RANDOM WORD ===
func _manifest_random_word():
	# Select from core words or generate a new one
	var word = ""
	
	if manifested_words.size() > 0 and randf() < 0.7:
		# Select existing word
		var index = randi() % manifested_words.size()
		word = manifested_words[index].word
	else:
		# Generate new word
		var syllables = ["ma", "ni", "fest", "di", "men", "sion", "co", "lor", "sha", "pe", "word", "eth", "er", "eal"]
		var syllable_count = 2 + randi() % 2  # 2-3 syllables
		
		for i in range(syllable_count):
			word += syllables[randi() % syllables.size()]
	
	var power = 0.5 + randf() * 0.5
	return manifest_word(word, power)

# === GENERATE RANDOM TEXT ===
func _generate_random_text():
	var words = [
		"dimension", "color", "shape", "word", "tunnel", "bridge",
		"connect", "project", "manifest", "create", "transform",
		"evolve", "merge", "ethereal", "akashic", "reality"
	]
	
	var word_count = 2 + randi() % 3  # 2-4 words
	var text = ""
	
	for i in range(word_count):
		if i > 0:
			text += " "
		text += words[randi() % words.size()]
	
	return text

# === HELPER METHODS ===

# Create a word trajectory
func _create_word_trajectory(word, dimension = active_dimension):
	if spatial_linguistic != null:
		# Generate trajectory steps
		var steps = spatial_linguistic.create_trajectory(word, TRAJECTORY_STEPS, dimension)
		
		if steps.size() > 0:
			var trajectory = {
				"word": word,
				"dimension": dimension,
				"steps": steps,
				"current_step": 0,
				"current_position": steps[0],
				"created_at": OS.get_ticks_msec()
			}
			
			word_trajectories.append(trajectory)
			emit_signal("trajectory_created", word, steps, dimension)
			
			print("Created trajectory for word: " + word + " with " + str(steps.size()) + " steps")
			return trajectory
	
	return null

# Handle trajectory completion
func _on_trajectory_completed(trajectory):
	print("Trajectory for word " + trajectory.word + " completed")
	
	# Boost word power upon trajectory completion
	for i in range(manifested_words.size()):
		if manifested_words[i].word == trajectory.word:
			manifested_words[i].power += 0.5
			break

# Activate a random data flow
func _activate_random_data_flow():
	if data_flows.size() > 0:
		# Select random channel
		var channels = data_flows.keys()
		var channel_name = channels[randi() % channels.size()]
		
		# Select random source and target
		var source_projects = PROJECT_PATHS.keys()
		var target_projects = PROJECT_PATHS.keys()
		
		var source = source_projects[randi() % source_projects.size()]
		var target = source
		while target == source:
			target = target_projects[randi() % target_projects.size()]
		
		# Activate flow
		data_flows[channel_name].active = true
		data_flows[channel_name].source = source
		data_flows[channel_name].target = target
		
		# Randomize parameters slightly
		data_flows[channel_name].amplitude = 0.8 + randf() * 0.4
		data_flows[channel_name].frequency = 0.1 + randf() * 0.3
		
		# Set direction
		data_flows[channel_name].direction = randf() < 0.7 ? "bidirectional" : "unidirectional"
		
		emit_signal("data_flow_established", source, target, channel_name, data_flows[channel_name].direction)
		
		print("Activated data flow from " + source + " to " + target + " on channel " + channel_name)
		return channel_name
	
	return null

# Create a random file connection
func _create_random_file_connection():
	if project_connector != null:
		# Generate random file path
		var extensions = ["gd", "tscn", "tres", "js", "md", "txt"]
		var ext = extensions[randi() % extensions.size()]
		var file_path = "res://random_file_" + str(randi() % 100) + "." + ext
		
		# Generate random target paths
		var target_paths = []
		var target_count = 1 + randi() % 3  # 1-3 targets
		
		for i in range(target_count):
			ext = extensions[randi() % extensions.size()]
			target_paths.append("res://connected_file_" + str(randi() % 100) + "." + ext)
		
		# Create connection
		file_connections[file_path] = {
			"active": true,
			"connected_to": target_paths,
			"created_at": OS.get_unix_time(),
			"sync_frequency": 0.1 + randf() * 0.2
		}
		
		for target in target_paths:
			emit_signal("project_connected", file_path, target, "file_connection")
		
		print("Created file connection for " + file_path + " with " + str(target_paths.size()) + " targets")
		return file_connections[file_path]
	
	return null

# Activate a sound signature
func _activate_sound_signature(signature_name):
	if project_connector != null:
		for signature in sound_signatures:
			if signature.name == signature_name:
				emit_signal("sound_signature_activated", signature_name, signature.amplitude, signature.frequency)
				
				project_connector.play_sound_signature(signature_name)
				return true
	
	return false

# === SIGNAL HANDLERS ===

func _on_tunnel_established(source, target, stability):
	print("Signal: Tunnel established from " + source + " to " + target + " with stability " + str(stability))

func _on_dimension_shifted(old_dim, new_dim):
	print("Signal: Dimension shifted from " + str(old_dim) + " to " + str(new_dim))
	active_dimension = new_dim

func _on_word_manifested(word, power, position):
	print("Signal: Word manifested: " + word)

func _on_color_spectrum_activated(colors):
	print("Signal: Color spectrum activated with " + str(colors.size()) + " colors")
	active_colors = colors

func _on_ocr_detected(text, confidence, region):
	print("Signal: OCR detected text: \"" + text + "\" with confidence " + str(confidence))

func _on_tunnel_collapsed(reason):
	print("Signal: Tunnel collapsed: " + reason)

func _on_trajectory_created(word, steps, dimension):
	print("Signal: Trajectory created for word: " + word + " in dimension " + str(dimension))

func _on_word_mapped(word, shape, coordinates):
	print("Signal: Word mapped: " + word + " to shape " + str(shape))

func _on_agent_mode_activated(mode, parameters):
	print("Signal: Agent mode activated: " + mode)

func _on_transform_applied(operation, word, result):
	print("Signal: Transform applied: " + operation + " to word " + word)

func _on_data_flow_established(source, target, channel, direction):
	print("Signal: Data flow established from " + source + " to " + target + " on channel " + channel)

func _on_negative_generated(source, negative):
	print("Signal: Negative generated for " + source)

func _on_project_connected(source, target, connection_type):
	print("Signal: Project connected: " + source + " to " + target + " with type " + connection_type)

func _on_file_modified(file_path, type, content):
	print("Signal: File modified: " + file_path + " with type " + type)

func _on_sound_activated(signature, amplitude, frequency):
	print("Signal: Sound activated: " + signature)

# === GET SYSTEM STATUS ===
func get_status():
	return {
		"version": VERSION,
		"turn": current_turn,
		"dimension": active_dimension,
		"bridge_stability": bridge_stability,
		"word_energy": word_energy,
		"awareness_level": awareness_level,
		"manifested_words": manifested_words.size(),
		"active_tunnels": active_tunnels.size(),
		"active_colors": active_colors.size(),
		"active_trajectories": word_trajectories.size(),
		"active_data_flows": data_flows.size(),
		"file_connections": file_connections.size(),
		"negative_dimensions": negative_dimensions.size(),
		"spatial_linguistic": spatial_linguistic != null,
		"auto_agent": auto_agent != null,
		"universal_data_flow": universal_data_flow != null,
		"project_connector": project_connector != null
	}

# === FILE SYSTEM OPERATIONS ===

# Create a new file
func create_file(path, content):
	if project_connector != null:
		var result = project_connector.create_file(path, content)
		if result:
			emit_signal("file_modified", path, "create", content)
		return result
	return false

# Update an existing file
func update_file(path, content):
	if project_connector != null:
		var result = project_connector.update_file(path, content)
		if result:
			emit_signal("file_modified", path, "update", content)
		return result
	return false

# Merge files
func merge_files(source_path, target_path):
	if project_connector != null:
		var result = project_connector.merge_files(source_path, target_path)
		if result:
			emit_signal("file_modified", target_path, "merge", source_path)
		return result
	return false

# Connect projects
func connect_project_folders(source_folder, target_folder):
	if project_connector != null:
		var result = project_connector.connect_folders(source_folder, target_folder)
		if result:
			emit_signal("project_connected", source_folder, target_folder, "folder_connection")
		return result
	return false

# Synchronize all connected files
func synchronize_all_connections():
	if project_connector != null:
		var count = 0
		for file_path in file_connections:
			var connection = file_connections[file_path]
			if connection.active:
				for target in connection.connected_to:
					if project_connector.synchronize_files(file_path, target):
						count += 1
		return count
	return 0
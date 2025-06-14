extends Node

class_name UnifiedTurnSystem

# ----- SYSTEM CONSTANTS -----
const VERSION = "1.0.0"
const MAX_TURNS_PER_CYCLE = 12
const MIN_DIMENSION = 1
const MAX_DIMENSION = 12
const DEFAULT_TURN_DURATION = 9.0  # The sacred 9-second interval

# ----- TURN SYMBOLS AND DIMENSIONS -----
const TURN_SYMBOLS = [
	"△", # Triangle - Genesis - 1D - Linear Expression
	"○", # Circle - Formation - 2D - Planar Reflection
	"□", # Square - Complexity - 3D - Spatial Manifestation
	"◇", # Diamond - Awareness - 4D - Temporal Flow
	"×", # Cross - Connection - 5D - Probability Waves
	"⊕", # Circled Plus - Expansion - 6D - Phase Resonance
	"⊙", # Circled Dot - Mastery - 7D - Dream Weaving
	"⊗", # Circled Times - Transformation - 8D - Interconnection
	"⊘", # Circled Slash - Harmony - 9D - Divine Judgment
	"⊚", # Circled Circle - Integration - 10D - Harmonic Convergence
	"⊛", # Circled Asterisk - Ascension - 11D - Conscious Reflection
	"⊜"  # Circled Equals - Completion - 12D - Divine Manifestation
]

const DIMENSION_NAMES = [
	"Linear Expression",      # 1D
	"Planar Reflection",      # 2D
	"Spatial Manifestation",  # 3D
	"Temporal Flow",          # 4D
	"Probability Waves",      # 5D
	"Phase Resonance",        # 6D
	"Dream Weaving",          # 7D
	"Interconnection",        # 8D
	"Divine Judgment",        # 9D
	"Harmonic Convergence",   # 10D
	"Conscious Reflection",   # 11D
	"Divine Manifestation"    # 12D
]

# ----- COLOR SYSTEM -----
enum ColorSystem {
	AZURE,     # Dimension 1 - Foundation
	EMERALD,   # Dimension 2 - Growth
	AMBER,     # Dimension 3 - Energy
	VIOLET,    # Dimension 4 - Insight
	CRIMSON,   # Dimension 5 - Force
	INDIGO,    # Dimension 6 - Vision
	SAPPHIRE,  # Dimension 7 - Wisdom
	GOLD,      # Dimension 8 - Transcendence
	SILVER,    # Dimension 9 - Unity
	OBSIDIAN,  # Extension 1 - Void
	PLATINUM,  # Extension 2 - Ascension
	DIAMOND    # Extension 3 - Purity
}

# Mapping colors to their hex values for visualization
var color_values = {
	ColorSystem.AZURE: Color("#1E90FF"),
	ColorSystem.EMERALD: Color("#50C878"),
	ColorSystem.AMBER: Color("#FFBF00"),
	ColorSystem.VIOLET: Color("#8F00FF"),
	ColorSystem.CRIMSON: Color("#DC143C"),
	ColorSystem.INDIGO: Color("#4B0082"),
	ColorSystem.SAPPHIRE: Color("#0F52BA"),
	ColorSystem.GOLD: Color("#FFD700"),
	ColorSystem.SILVER: Color("#C0C0C0"),
	ColorSystem.OBSIDIAN: Color("#1A1110"),
	ColorSystem.PLATINUM: Color("#E5E4E2"),
	ColorSystem.DIAMOND: Color("#B9F2FF")
}

# ----- TURN STATE -----
var current_turn = 0
var current_dimension = 3  # Start in 3D
var is_running = false
var is_paused = false
var elapsed_time = 0.0
var turn_duration = DEFAULT_TURN_DURATION
var total_cycles_completed = 0
var turn_history = []
var is_resting = false
var rest_period_duration = 60  # seconds
var rest_timer: Timer
var current_turn_version = [0, 0, 0, 0]  # major.minor.patch.build in TurnPrioritySystem format

# ----- TURN PRIORITIES -----
var priorities = {
	"critical": [],
	"high": [],
	"medium": [],
	"low": []
}
var active_category = "medium"  # Default priority category

# ----- CONNECTED SYSTEMS -----
var ethereal_bridge = null
var akashic_system = null
var word_processor = null
var color_system = null
var dimensional_system = null
var file_connector = null

# ----- SIGNALS -----
signal turn_started(turn_number)
signal turn_completed(turn_number)
signal turn_advanced(turn_number, turn_string)
signal dimension_changed(new_dimension, old_dimension)
signal sacred_interval(turn_number, symbol)
signal turn_cycle_completed(cycle_number)
signal priority_shifted(old_category, new_category, item)
signal rest_period_started
signal rest_period_ended

# ----- INITIALIZATION -----
func _ready():
	# Setup timer for rest periods
	rest_timer = Timer.new()
	rest_timer.one_shot = true
	rest_timer.timeout.connect(_on_rest_timer_timeout)
	add_child(rest_timer)
	
	# Load turn state if available
	_load_turn_state()
	
	# Find connected systems
	_find_connected_systems()
	
	# Generate connections with snake_case entities
	_generate_snake_case_connections()
	
	print("UnifiedTurnSystem v" + VERSION + " initialized")
	print("Current turn: " + str(current_turn) + ", Dimension: " + 
		str(current_dimension) + "D - " + get_dimension_name())

# ----- PROCESS -----
func _process(delta):
	if is_running and !is_paused and !is_resting:
		elapsed_time += delta
		
		if elapsed_time >= turn_duration:
			elapsed_time = 0.0
			advance_turn()

# ----- TURN MANAGEMENT -----
func start_turns():
	if !is_running:
		is_running = true
		is_paused = false
		elapsed_time = 0.0
		print("Turn system started - " + str(turn_duration) + "-second interval active")
	
	return is_running

func stop_turns():
	if is_running:
		is_running = false
		is_paused = false
		print("Turn system stopped")
	
	return !is_running

func pause_turns():
	if is_running and !is_paused:
		is_paused = true
		print("Turn system paused")
	
	return is_paused

func resume_turns():
	if is_running and is_paused:
		is_paused = false
		print("Turn system resumed")
	
	return !is_paused

func advance_turn():
	# Increment turn counter
	current_turn = (current_turn + 1) % MAX_TURNS_PER_CYCLE
	if current_turn == 0:
		current_turn = MAX_TURNS_PER_CYCLE
	
	# Update turn version
	current_turn_version[3] += 1  # Increment build number
	if current_turn_version[3] >= 100:
		current_turn_version[3] = 0
		current_turn_version[2] += 1  # Increment patch number
	
	# Record turn history
	var history_entry = {
		"turn": current_turn,
		"dimension": current_dimension,
		"version": current_turn_version.duplicate(),
		"timestamp": Time.get_unix_time_from_system(),
		"active_category": active_category
	}
	turn_history.append(history_entry)
	
	# Get current symbol and dimension name
	var symbol = get_turn_symbol()
	var dimension_name = get_dimension_name()
	
	print("Turn " + str(current_turn) + " | Symbol: " + symbol + 
		" | Dimension: " + str(current_dimension) + "D - " + dimension_name +
		" | Version: " + get_turn_string())
	
	# Emit signals
	emit_signal("turn_started", current_turn)
	emit_signal("turn_completed", current_turn)
	emit_signal("turn_advanced", current_turn, get_turn_string())
	emit_signal("sacred_interval", current_turn, symbol)
	
	# Check for turn cycle (12 turns)
	if current_turn == MAX_TURNS_PER_CYCLE:
		total_cycles_completed += 1
		emit_signal("turn_cycle_completed", total_cycles_completed)
		print("Turn cycle " + str(total_cycles_completed) + " completed")
		
		# Start rest period after completing a cycle
		_begin_rest_period()
	
	# Save turn state
	_save_turn_state()
	
	# Update connection files
	_update_turn_files()
	
	return current_turn

# ----- DIMENSION MANAGEMENT -----
func set_dimension(dimension):
	if dimension < MIN_DIMENSION or dimension > MAX_DIMENSION:
		print("Invalid dimension: " + str(dimension) + ". Must be between " + 
			str(MIN_DIMENSION) + " and " + str(MAX_DIMENSION))
		return false
	
	if dimension != current_dimension:
		var old_dimension = current_dimension
		current_dimension = dimension
		
		# Update turn version - set minor version to match dimension
		current_turn_version[1] = current_dimension
		
		emit_signal("dimension_changed", current_dimension, old_dimension)
		print("Dimension changed: " + str(old_dimension) + "D → " + 
			str(current_dimension) + "D (" + get_dimension_name() + ")")
		
		# Save turn state
		_save_turn_state()
		
		# Update connection files
		_update_turn_files()
		
		return true
	
	return false

func increment_dimension():
	if current_dimension < MAX_DIMENSION:
		set_dimension(current_dimension + 1)
		return true
	return false

func decrement_dimension():
	if current_dimension > MIN_DIMENSION:
		set_dimension(current_dimension - 1)
		return true
	return false

# ----- TURN PRIORITY MANAGEMENT -----
func add_priority(category, item):
	if not priorities.has(category):
		print("Invalid priority category: " + category)
		return false
	
	# Check if item already exists in any category
	for cat in priorities:
		if priorities[cat].has(item):
			priorities[cat].erase(item)
			print("Item '" + item + "' removed from " + cat + " category")
			break
	
	# Add to specified category
	priorities[category].append(item)
	print("Item '" + item + "' added to " + category + " priority")
	
	# Update active category if needed
	_update_active_category()
	
	return true

func remove_priority(category, item):
	if not priorities.has(category) or not priorities[category].has(item):
		print("Item '" + item + "' not found in " + category + " category")
		return false
	
	priorities[category].erase(item)
	print("Item '" + item + "' removed from " + category + " priority")
	
	# Update active category if needed
	_update_active_category()
	
	return true

func shift_priority(item, from_category, to_category):
	if not priorities.has(from_category) or not priorities.has(to_category):
		print("Invalid priority category")
		return false
	
	if not priorities[from_category].has(item):
		print("Item '" + item + "' not found in " + from_category + " category")
		return false
	
	# Remove from old category
	priorities[from_category].erase(item)
	
	# Add to new category
	priorities[to_category].append(item)
	
	print("Shifted '" + item + "' from " + from_category + " to " + to_category)
	
	# Update active category if needed
	_update_active_category()
	
	# Emit signal
	emit_signal("priority_shifted", from_category, to_category, item)
	
	return true

func _update_active_category():
	var old_category = active_category
	
	# Priority order: critical > high > medium > low
	if priorities.critical.size() > 0:
		active_category = "critical"
	elif priorities.high.size() > 0:
		active_category = "high"
	elif priorities.medium.size() > 0:
		active_category = "medium"
	elif priorities.low.size() > 0:
		active_category = "low"
	
	if old_category != active_category:
		print("Active priority category changed from " + old_category + " to " + active_category)
		
		# Update turn version - major version based on priority
		if active_category == "critical":
			current_turn_version[0] = 3
		elif active_category == "high":
			current_turn_version[0] = 2
		elif active_category == "medium":
			current_turn_version[0] = 1
		else:
			current_turn_version[0] = 0
	
	return active_category

# ----- REST PERIOD MANAGEMENT -----
func _begin_rest_period():
	is_resting = true
	emit_signal("rest_period_started")
	rest_timer.start(rest_period_duration)
	
	print("Rest period started (" + str(rest_period_duration) + " seconds)")

func _on_rest_timer_timeout():
	is_resting = false
	emit_signal("rest_period_ended")
	
	print("Rest period ended")

func skip_rest_period():
	if is_resting:
		rest_timer.stop()
		is_resting = false
		emit_signal("rest_period_ended")
		
		print("Rest period skipped")
		return true
	
	return false

func set_rest_period_duration(seconds):
	rest_period_duration = seconds
	print("Rest period duration set to " + str(seconds) + " seconds")
	
	# Save turn state
	_save_turn_state()
	
	return rest_period_duration

# ----- TURN VERSION MANAGEMENT -----
func set_current_turn(major, minor, patch, build):
	current_turn_version = [major, minor, patch, build]
	
	# Sync dimension with minor version
	if minor >= MIN_DIMENSION and minor <= MAX_DIMENSION:
		current_dimension = minor
	
	print("Turn version set to " + get_turn_string())
	
	# Save turn state
	_save_turn_state()
	
	return current_turn_version

func get_turn_string():
	return str(current_turn_version[0]) + "." + 
		str(current_turn_version[1]) + "." + 
		str(current_turn_version[2]) + "." + 
		str(current_turn_version[3])

func get_turn_data():
	return {
		"turn": current_turn,
		"dimension": current_dimension,
		"version": current_turn_version.duplicate(),
		"symbol": get_turn_symbol(),
		"dimension_name": get_dimension_name(),
		"active_category": active_category,
		"cycle": get_turn_cycle(),
		"cycle_turn": get_cycle_turn(),
		"is_resting": is_resting,
		"progress": get_turn_progress()
	}

# ----- SNAKE CASE INTEGRATION -----
func _generate_snake_case_connections():
	# Create mappings between turn components and snake_case entities
	var snake_case_mappings = {
		"turn_system": "turn_system_main",
		"turn_priority_system": "turn_priority_system",
		"turn_cycle_manager": "turn_cycle_manager",
		"turn_integrator": "turn_integrator_main",
		"turn_controller": "turn_controller_main",
		"twelve_turns_game": "turn_based_game_framework",
		"turn_based_game_framework": "turn_based_game_main"
	}
	
	# Create hash connections between turn system components
	var hash_connections = [
		"#turn_system_main -> #turn_priority_system",
		"#turn_system_main -> #turn_integrator_main",
		"#turn_system_main -> #turn_controller_main",
		"#turn_system_main -> #turn_cycle_manager",
		"##turn_priority_system -> ##turn_integrator_main",
		"##turn_controller_main -> ##turn_cycle_manager",
		"###turn_based_game_main -> ###turn_system_main"
	]
	
	# Log the connections
	print("Snake case turn system connections:")
	for connection in hash_connections:
		print(connection)
	
	return hash_connections

# ----- UTILITY FUNCTIONS -----
func get_turn_symbol():
	var index = (current_turn - 1) % TURN_SYMBOLS.size()
	return TURN_SYMBOLS[index]

func get_dimension_name():
	if current_dimension >= 1 and current_dimension <= DIMENSION_NAMES.size():
		return DIMENSION_NAMES[current_dimension - 1]
	return "Unknown Dimension"

func get_turn_progress():
	if is_resting:
		return 1.0
	return elapsed_time / turn_duration

func get_time_remaining():
	if is_resting:
		return rest_timer.time_left
	return max(0, turn_duration - elapsed_time)

func get_turn_cycle():
	return total_cycles_completed + (current_turn == MAX_TURNS_PER_CYCLE ? 1 : 0)

func get_cycle_turn():
	return current_turn

func get_active_priorities():
	return {
		"category": active_category,
		"items": priorities[active_category].duplicate()
	}

func get_current_color() -> Color:
	var index = (current_turn - 1) % 12
	var color_key = ColorSystem.values()[index % ColorSystem.size()]
	return color_values[color_key]

func get_current_color_name() -> String:
	var index = (current_turn - 1) % 12
	return ColorSystem.keys()[index % ColorSystem.size()]

# ----- STATE PERSISTENCE -----
func _save_turn_state():
	var save_data = {
		"current_turn": current_turn,
		"current_dimension": current_dimension,
		"current_turn_version": current_turn_version,
		"total_cycles_completed": total_cycles_completed,
		"rest_period_duration": rest_period_duration,
		"is_running": is_running,
		"is_paused": is_paused,
		"is_resting": is_resting,
		"turn_duration": turn_duration,
		"active_category": active_category,
		"priorities": priorities,
		"version": VERSION,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open("user://unified_turn_state.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	return true

func _load_turn_state():
	if FileAccess.file_exists("user://unified_turn_state.save"):
		var file = FileAccess.open("user://unified_turn_state.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			# Load basic turn state
			current_turn = data.current_turn
			current_dimension = data.current_dimension
			total_cycles_completed = data.total_cycles_completed
			rest_period_duration = data.rest_period_duration
			is_running = data.is_running
			is_paused = data.is_paused
			is_resting = data.is_resting
			turn_duration = data.turn_duration
			
			# Load turn version
			if data.has("current_turn_version"):
				current_turn_version = data.current_turn_version
			
			# Load priorities
			if data.has("active_category"):
				active_category = data.active_category
			
			if data.has("priorities"):
				priorities = data.priorities
			
			print("Turn state loaded")
			return true
	
	return false

# ----- TURN FILE MANAGEMENT -----
func _update_turn_files():
	# Create display files for turn information
	
	# Create/update current_turn.txt
	var file = FileAccess.open("user://current_turn.txt", FileAccess.WRITE)
	file.store_string(str(current_turn))
	file.close()
	
	# Try to save to system directory for other systems
	var system_paths = [
		"/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt",
		"/mnt/c/Users/Percision 15/12_turns_system/display1_turn.txt",
		"/mnt/c/Users/Percision 15/12_turns_system/display2_turn.txt"
	]
	
	for path in system_paths:
		var sys_file = FileAccess.open(path, FileAccess.WRITE)
		if sys_file:
			sys_file.store_string(str(current_turn))
			sys_file.close()
	
	# Create/update turn_version.txt
	file = FileAccess.open("user://turn_version.txt", FileAccess.WRITE)
	file.store_string(get_turn_string())
	file.close()
	
	# Create/update turn_data.json
	var turn_data = get_turn_data()
	file = FileAccess.open("user://turn_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(turn_data))
	file.close()
	
	return true

# ----- CONNECTED SYSTEMS -----
func _find_connected_systems():
	# Find ethereal bridge
	ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
	if ethereal_bridge == null:
		ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
		
	# Find akashic system
	akashic_system = get_node_or_null("/root/AkashicNumberSystem")
	if akashic_system == null:
		akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
	
	# Find word processor
	word_processor = get_node_or_null("/root/DivineWordProcessor")
	if word_processor == null:
		word_processor = _find_node_by_class(get_tree().root, "DivineWordProcessor")
	
	# Find color system
	color_system = get_node_or_null("/root/DimensionalColorSystem")
	if color_system == null:
		color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
	
	# Find dimensional system
	dimensional_system = get_node_or_null("/root/EtherealEngine")
	if dimensional_system == null:
		dimensional_system = _find_node_by_class(get_tree().root, "EtherealEngine")
	
	# Find file connector
	file_connector = get_node_or_null("/root/FileConnectionSystem")
	if file_connector == null:
		file_connector = _find_node_by_class(get_tree().root, "FileConnectionSystem")
	
	print("Connected systems found - " +
		"Ethereal Bridge: " + str(ethereal_bridge != null) + ", " +
		"Akashic System: " + str(akashic_system != null) + ", " +
		"Word Processor: " + str(word_processor != null) + ", " +
		"Color System: " + str(color_system != null) + ", " +
		"Dimensional System: " + str(dimensional_system != null) + ", " +
		"File Connector: " + str(file_connector != null))

func _find_node_by_class(node, class_name_str):
	if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class(child, class_name_str)
		if found:
			return found
	
	return null

# ----- PUBLIC API FOR SYSTEM INTEGRATION -----
func restart_turn_system():
	# Full restart of the turn system
	stop_turns()
	
	# Reset turn state
	current_turn = 0
	current_dimension = 3
	is_running = false
	is_paused = false
	elapsed_time = 0.0
	is_resting = false
	
	# Reset turn version
	current_turn_version = [1, 3, 0, 0]  # 1.3.0.0
	
	# Reset priorities
	priorities = {
		"critical": [],
		"high": [],
		"medium": [],
		"low": []
	}
	active_category = "medium"
	
	# Clear turn history
	turn_history.clear()
	
	# Start turns
	start_turns()
	
	# Advance to first turn
	advance_turn()
	
	print("Turn system fully restarted")
	return true

func get_system_status():
	return {
		"version": VERSION,
		"turn": current_turn,
		"dimension": current_dimension,
		"turn_version": get_turn_string(),
		"is_running": is_running,
		"is_paused": is_paused,
		"is_resting": is_resting,
		"turn_progress": get_turn_progress(),
		"time_remaining": get_time_remaining(),
		"total_cycles": total_cycles_completed,
		"active_category": active_category,
		"connected_systems": {
			"ethereal_bridge": ethereal_bridge != null,
			"akashic_system": akashic_system != null,
			"word_processor": word_processor != null,
			"color_system": color_system != null,
			"dimensional_system": dimensional_system != null,
			"file_connector": file_connector != null
		}
	}

func set_turn_duration(seconds):
	turn_duration = max(1.0, seconds)
	print("Turn duration set to " + str(turn_duration) + " seconds")
	
	# Save turn state
	_save_turn_state()
	
	return turn_duration
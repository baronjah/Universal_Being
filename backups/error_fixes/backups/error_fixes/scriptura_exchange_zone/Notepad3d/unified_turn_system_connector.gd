extends Node

class_name UnifiedTurnSystemConnector

# ----- SYSTEM CONSTANTS -----
const SYSTEM_VERSION = "1.0.0"
const MAX_DIMENSIONS = 12
const DEFAULT_TURN_DURATION = 9.0  # Sacred 9-second interval

# ----- COMPONENT REFERENCES -----
var turn_system = null
var turn_controller = null
var turn_integrator = null
var turn_priority_system = null
var dimensional_color_system = null

# ----- SNAKE_CASE NAMING CONVENTION DICTIONARY -----
var snake_case_mapping = {
	# Core components
	"TurnSystem": "turn_system",
	"TurnController": "turn_controller",
	"TurnIntegrator": "turn_integrator",
	"TurnPrioritySystem": "turn_priority_system",
	"TwelveTurnsGame": "twelve_turns_game",
	
	# Related systems
	"DimensionalColorSystem": "dimensional_color_system",
	"TaskTransitionAnimator": "task_transition_animator",
	"WordCommentSystem": "word_comment_system",
	"WordDreamStorage": "word_dream_storage",
	
	# Turn states
	"CurrentTurn": "current_turn",
	"TotalTurns": "total_turns",
	"TurnDuration": "turn_duration",
	"CurrentDimension": "current_dimension",
	"PowerPercentage": "power_percentage",
	
	# Functions
	"StartTurn": "start_turn",
	"EndTurn": "end_turn",
	"AdvanceTurn": "advance_turn",
	"SetDimension": "set_dimension",
	"IncrementDimension": "increment_dimension",
	"DecrementDimension": "decrement_dimension",
	
	# Properties
	"IsRunning": "is_running",
	"IsPaused": "is_paused",
	"ElapsedTime": "elapsed_time",
	"TurnSymbols": "turn_symbols",
	"DimensionNames": "dimension_names",
	"TurnData": "turn_data",
	
	# Signals
	"TurnStarted": "turn_started",
	"TurnEnded": "turn_ended",
	"TurnCompleted": "turn_completed",
	"DimensionChanged": "dimension_changed",
	"TurnCycleCompleted": "turn_cycle_completed",
	"SacredInterval": "sacred_interval"
}

# ----- SIGNALS -----
signal system_initialized
signal turn_components_connected
signal snake_case_applied(original_name, snake_case_name)

# ----- INITIALIZATION -----
func _ready():
	print("UnifiedTurnSystemConnector initializing...")
	
	# Find and connect to turn systems
	connect_turn_systems()
	
	# Apply snake_case naming conventions to connected systems
	apply_snake_case_naming()
	
	print("UnifiedTurnSystemConnector initialized (v" + SYSTEM_VERSION + ")")
	emit_signal("system_initialized")

func connect_turn_systems():
	# Find and connect to TurnSystem
	turn_system = get_node_or_null("/root/TurnSystem")
	if not turn_system:
		turn_system = find_node_by_class("TurnSystem")
	
	# Find and connect to TurnController
	turn_controller = get_node_or_null("/root/TurnController")
	if not turn_controller:
		turn_controller = find_node_by_class("TurnController")
	
	# Find and connect to TurnIntegrator
	turn_integrator = get_node_or_null("/root/TurnIntegrator")
	if not turn_integrator:
		turn_integrator = find_node_by_class("TurnIntegrator")
	
	# Find and connect to TurnPrioritySystem
	turn_priority_system = get_node_or_null("/root/TurnPrioritySystem")
	if not turn_priority_system and turn_integrator:
		turn_priority_system = turn_integrator.turn_priority_system
	
	# Find and connect to DimensionalColorSystem
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not dimensional_color_system:
		dimensional_color_system = find_node_by_class("DimensionalColorSystem")
		if not dimensional_color_system:
			dimensional_color_system = get_node_or_null("/root/ExtendedColorThemeSystem")
			if not dimensional_color_system:
				dimensional_color_system = find_node_by_class("ExtendedColorThemeSystem")
	
	print("Turn systems connected: " + _get_connection_status())
	emit_signal("turn_components_connected")

func find_node_by_class(class_name_str, node = null):
	if node == null:
		node = get_tree().root
	
	if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
		return node
	
	for child in node.get_children():
		var found = find_node_by_class(class_name_str, child)
		if found:
			return found
	
	return null

func _get_connection_status():
	return "TurnSystem: " + ("Yes" if turn_system else "No") + ", " + \
		   "TurnController: " + ("Yes" if turn_controller else "No") + ", " + \
		   "TurnIntegrator: " + ("Yes" if turn_integrator else "No") + ", " + \
		   "TurnPrioritySystem: " + ("Yes" if turn_priority_system else "No") + ", " + \
		   "DimensionalColorSystem: " + ("Yes" if dimensional_color_system else "No")

func apply_snake_case_naming():
	# Apply snake_case naming convention to all connected systems
	# This doesn't rename the actual classes, but ensures all new code
	# follows the snake_case convention
	
	for original_name in snake_case_mapping.keys():
		var snake_case_name = snake_case_mapping[original_name]
		print("Mapping: " + original_name + " → " + snake_case_name)
		emit_signal("snake_case_applied", original_name, snake_case_name)

# ----- UNIFIED TURN SYSTEM API -----
# These functions provide a consistent snake_case API
# that works across all the different turn systems

func start_turn(turn_number = 0):
	if turn_controller:
		return turn_controller.start_turn(turn_number)
	elif turn_system:
		turn_system.start_turns()
		return true
	elif turn_integrator:
		turn_integrator.start_turn_cycle()
		return true
	return false

func end_turn():
	if turn_controller:
		return turn_controller.end_turn()
	elif turn_system:
		turn_system.stop_turns()
		return true
	elif turn_integrator:
		turn_integrator.stop_turn_cycle()
		return true
	return false

func advance_turn():
	if turn_controller:
		return turn_controller.end_turn()
	elif turn_system:
		turn_system.advance_turn()
		return true
	elif turn_integrator:
		turn_integrator.advance_turn()
		return true
	elif turn_priority_system:
		turn_priority_system.advance_turn()
		return true
	return false

func set_dimension(dimension):
	if turn_system:
		return turn_system.set_dimension(dimension)
	elif turn_controller and dimensional_color_system:
		dimensional_color_system.set_dimension(dimension)
		return true
	return false

func get_current_turn():
	if turn_controller:
		return turn_controller.get_current_turn()
	elif turn_system:
		return turn_system.current_turn
	elif turn_priority_system:
		return turn_priority_system.get_turn_string()
	return 0

func get_turn_data():
	if turn_controller:
		return turn_controller.get_turn_data()
	elif turn_integrator:
		return turn_integrator.get_current_turn_data()
	return null

func set_turn_duration(seconds):
	if turn_controller:
		turn_controller.turn_duration = seconds
		return true
	elif turn_system:
		turn_system.turn_duration = seconds
		return true
	elif turn_integrator:
		turn_integrator.set_turn_duration(seconds)
		return true
	return false

func get_turn_symbol():
	if turn_system:
		return turn_system.get_turn_symbol()
	elif turn_priority_system:
		var symbols = ["△", "○", "□", "◇", "×", "⊕", "⊙", "⊗", "⊘", "⊚", "⊛", "⊜"]
		var turn_components = turn_priority_system.current_turn
		var index = (turn_components[0] - 1) % symbols.size()
		return symbols[index]
	return "○"  # Default symbol if no system available

func get_dimension_name():
	if turn_system:
		return turn_system.get_dimension_name()
	elif dimensional_color_system and dimensional_color_system.has_method("get_dimension_name"):
		return dimensional_color_system.get_dimension_name(get_current_dimension())
	
	# Default dimension names if no system available
	var dimension_names = [
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
	
	var dimension = get_current_dimension()
	if dimension >= 1 and dimension <= dimension_names.size():
		return dimension_names[dimension - 1]
	
	return "Unknown Dimension"

func get_current_dimension():
	if turn_system:
		return turn_system.current_dimension
	elif turn_priority_system:
		return turn_priority_system.current_turn[1]
	return 1  # Default to first dimension if no system available

func set_auto_advance(enabled):
	if turn_controller:
		turn_controller.auto_advance_turns = enabled
		return true
	elif turn_integrator:
		turn_integrator.set_auto_advance(enabled)
		return true
	return false

func register_system(system):
	if turn_controller:
		turn_controller.register_system(system)
		return true
	return false

# ----- UTILITY FUNCTIONS -----
func get_snake_case(pascal_case_name):
	# Convert a PascalCase name to snake_case
	if snake_case_mapping.has(pascal_case_name):
		return snake_case_mapping[pascal_case_name]
	
	# If not in the mapping, convert it algorithmically
	var result = ""
	for i in range(pascal_case_name.length()):
		var character = pascal_case_name[i]
		if i > 0 and character == character.to_upper() and character.is_valid_identifier():
			result += "_" + character.to_lower()
		else:
			result += character.to_lower()
	
	return result

func add_snake_case_mapping(pascal_case_name, snake_case_name = ""):
	# Add a new mapping to the snake_case dictionary
	# If snake_case_name is not provided, it will be generated
	
	if snake_case_name.empty():
		snake_case_name = get_snake_case(pascal_case_name)
	
	snake_case_mapping[pascal_case_name] = snake_case_name
	emit_signal("snake_case_applied", pascal_case_name, snake_case_name)
	
	return snake_case_name

func synchronize_systems():
	# Synchronize all turn systems to be in the same state
	
	# First, determine which system should be the source of truth
	var source_system = "none"
	var current_turn = 1
	var current_dimension = 1
	
	if turn_controller:
		source_system = "turn_controller"
		current_turn = turn_controller.current_turn
		# Try to get dimension from color system
		if dimensional_color_system and dimensional_color_system.has_method("get_current_dimension"):
			current_dimension = dimensional_color_system.get_current_dimension()
	elif turn_system:
		source_system = "turn_system"
		current_turn = turn_system.current_turn
		current_dimension = turn_system.current_dimension
	elif turn_priority_system:
		source_system = "turn_priority_system"
		var turn_components = turn_priority_system.current_turn
		current_turn = turn_components[0]
		current_dimension = turn_components[1]
	
	print("Synchronizing systems using " + source_system + " as source of truth")
	print("Current turn: " + str(current_turn) + ", Current dimension: " + str(current_dimension))
	
	# Now synchronize all systems to this state
	if turn_system and source_system != "turn_system":
		turn_system.current_turn = current_turn
		turn_system.set_dimension(current_dimension)
	
	if turn_controller and source_system != "turn_controller":
		turn_controller.set_turn(current_turn)
		if dimensional_color_system and dimensional_color_system.has_method("set_dimension"):
			dimensional_color_system.set_dimension(current_dimension)
	
	if turn_priority_system and source_system != "turn_priority_system":
		# Keep other components of the turn intact
		var old_components = turn_priority_system.current_turn
		turn_priority_system.set_current_turn(current_turn, current_dimension, old_components[2], old_components[3])
	
	print("Systems synchronized successfully")
	return true
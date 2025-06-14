extends Node

class_name TurnSystem

# ----- TURN CONFIGURATION -----
var turn_duration = 9.0  # The sacred 9-second interval
var max_dimensions = 12
var min_dimension = 1
var max_dimension = 12

# ----- TURN STATE -----
var current_turn = 0
var current_dimension = 1
var is_running = false
var is_paused = false
var elapsed_time = 0.0

# ----- TURN SYMBOLS -----
var turn_symbols = [
	"△", # Triangle - Genesis
	"○", # Circle - Formation
	"□", # Square - Complexity
	"◇", # Diamond - Awareness
	"×", # Cross - Connection
	"⊕", # Circled Plus - Expansion
	"⊙", # Circled Dot - Mastery
	"⊗", # Circled Times - Transformation
	"⊘", # Circled Slash - Harmony
	"⊚", # Circled Circle - Integration
	"⊛", # Circled Asterisk - Ascension
	"⊜"  # Circled Equals - Completion
]

# ----- DIMENSION NAMES -----
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

# ----- SIGNALS -----
signal turn_started(turn_number)
signal turn_completed(turn_number)
signal dimension_changed(new_dimension, old_dimension)
signal sacred_interval(turn_number, symbol)
signal turn_cycle_completed(cycle_number)

# ----- INITIALIZATION -----
func _ready():
	print("TurnSystem initialized with sacred 9-second interval")

# ----- PROCESS -----
func _process(delta):
	if is_running and !is_paused:
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
		print("TurnSystem started - Sacred 9-second interval active")

func stop_turns():
	if is_running:
		is_running = false
		is_paused = false
		print("TurnSystem stopped")

func pause_turns():
	if is_running and !is_paused:
		is_paused = true
		print("TurnSystem paused")

func resume_turns():
	if is_running and is_paused:
		is_paused = false
		print("TurnSystem resumed")

func advance_turn():
	current_turn += 1
	
	# Get current symbol and dimension
	var symbol = get_turn_symbol()
	var dimension_name = get_dimension_name()
	
	print("Turn " + str(current_turn) + " | Symbol: " + symbol + " | Dimension: " + str(current_dimension) + "D - " + dimension_name)
	
	# Emit signals
	emit_signal("turn_completed", current_turn)
	emit_signal("sacred_interval", current_turn, symbol)
	
	# Check for turn cycle (12 turns)
	if current_turn % 12 == 0:
		var cycle_number = current_turn / 12
		emit_signal("turn_cycle_completed", cycle_number)
		print("Turn cycle " + str(cycle_number) + " completed")

# ----- DIMENSION MANAGEMENT -----
func set_dimension(dimension):
	if dimension < min_dimension or dimension > max_dimension:
		print("Invalid dimension: " + str(dimension) + ". Must be between " + str(min_dimension) + " and " + str(max_dimension))
		return false
	
	if dimension != current_dimension:
		var old_dimension = current_dimension
		current_dimension = dimension
		
		emit_signal("dimension_changed", current_dimension, old_dimension)
		print("Dimension changed: " + str(old_dimension) + "D → " + str(current_dimension) + "D (" + get_dimension_name() + ")")
		return true
	
	return false

func increment_dimension():
	if current_dimension < max_dimension:
		set_dimension(current_dimension + 1)
		return true
	return false

func decrement_dimension():
	if current_dimension > min_dimension:
		set_dimension(current_dimension - 1)
		return true
	return false

# ----- UTILITY FUNCTIONS -----
func get_turn_symbol():
	var index = (current_turn - 1) % turn_symbols.size()
	return turn_symbols[index]

func get_dimension_name():
	if current_dimension >= 1 and current_dimension <= dimension_names.size():
		return dimension_names[current_dimension - 1]
	return "Unknown Dimension"

func get_turn_progress():
	return elapsed_time / turn_duration

func get_time_remaining():
	return max(0, turn_duration - elapsed_time)

func get_turn_cycle():
	return (current_turn - 1) / 12 + 1

func get_cycle_turn():
	return (current_turn - 1) % 12 + 1

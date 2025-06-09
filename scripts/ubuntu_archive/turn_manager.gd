extends Node

class_name TurnManager

# ----- SIGNALS -----
signal turn_advanced(old_turn, new_turn)
signal turn_time_updated(time_remaining)
signal cycle_completed
signal turn_data_saved(turn, path)
signal quantum_tick

# ----- TURN SYSTEM SETTINGS -----
@export var turns_enabled: bool = true
@export var max_turns: int = 12
@export var current_turn: int = 3  # Start at Complexity (3D Space)
@export var time_per_turn: float = 300.0  # 5 minutes per turn
@export var auto_advance: bool = true

# ----- TIME TRACKING -----
var time_in_current_turn: float = 0.0
var total_system_time: float = 0.0
var quantum_loop_active: bool = false
var quantum_speed: float = 0.083  # 12 turns per second when in quantum mode
var last_save_time: float = 0.0
var save_interval: float = 60.0  # Save data every minute

# ----- TURN PHASES -----
var turn_phases = [
	"Genesis", 
	"Formation", 
	"Complexity", 
	"Consciousness", 
	"Awakening", 
	"Enlightenment", 
	"Manifestation", 
	"Connection", 
	"Harmony", 
	"Transcendence", 
	"Unity", 
	"Beyond"
]

# ----- TURN SYMBOLS -----
var turn_symbols = [
	"α", "β", "γ", "δ", "ε", "ζ", 
	"η", "θ", "ι", "κ", "λ", "μ"
]

# ----- TURN DIMENSIONS -----
var turn_dimensions = [
	"1D", "2D", "3D", "4D", "5D", "6D", 
	"7D", "8D", "9D", "10D", "11D", "12D"
]

# ----- TURN CONCEPTS -----
var turn_concepts = [
	"Point", "Line", "Space", "Time", "Consciousness", 
	"Connection", "Creation", "Network", "Harmony", 
	"Transcendence", "Unity", "Infinity"
]

# ----- DATA PATHS -----
var data_path = "user://turn_data"
var cache_path = "user://turn_cache"

# ----- INITIALIZATION -----
func _ready():
	# Create necessary directories
	_ensure_directories_exist()
	
	# Load previously saved turn if exists
	_load_saved_turn()
	
	print("Turn System initialized: Turn %d - %s" % [current_turn, get_current_phase_name()])

func initialize(start_turn: int = 3):
	current_turn = clamp(start_turn, 1, max_turns)
	time_in_current_turn = 0.0
	
	# Save initial turn state
	save_turn_data(current_turn)
	
	print("Turn System initialized with turn %d - %s" % [current_turn, get_current_phase_name()])

# ----- PROCESS -----
func _process(delta):
	if not turns_enabled:
		return
	
	# Update time tracking
	if quantum_loop_active:
		# Process quantum time (high-speed turns)
		_process_quantum_time(delta)
	else:
		# Process normal time
		_process_normal_time(delta)

func _process_normal_time(delta):
	# Update time tracking
	time_in_current_turn += delta
	total_system_time += delta
	
	# Check for turn advancement
	if auto_advance and time_in_current_turn >= time_per_turn:
		advance_turn()
	
	# Periodic saves
	if total_system_time - last_save_time >= save_interval:
		save_turn_data(current_turn)
		last_save_time = total_system_time
	
	# Emit time updated signal
	var time_remaining = max(0.0, time_per_turn - time_in_current_turn)
	emit_signal("turn_time_updated", time_remaining)

func _process_quantum_time(delta):
	# In quantum mode, we advance turns rapidly
	var quantum_timer = fmod(total_system_time, quantum_speed)
	total_system_time += delta
	
	# Check if we should tick to next turn
	if fmod(total_system_time, quantum_speed) < quantum_timer:
		# Time for a quantum tick
		advance_turn()
		emit_signal("quantum_tick")
	
	# Save less frequently in quantum mode
	if total_system_time - last_save_time >= save_interval * 2:
		save_turn_data(current_turn)
		last_save_time = total_system_time

# ----- TURN MANAGEMENT -----
func advance_turn():
	# Save data for current turn
	save_turn_data(current_turn)
	
	# Store old turn for signal
	var old_turn = current_turn
	
	# Advance turn
	current_turn = (current_turn % max_turns) + 1
	time_in_current_turn = 0.0
	
	# Save current turn to filesystem
	_save_current_turn()
	
	# Emit signal
	emit_signal("turn_advanced", old_turn, current_turn)
	
	# Log turn advancement
	print("Advanced to Turn %d - %s" % [current_turn, get_current_phase_name()])
	
	# If we completed a full cycle (reached turn 1 again)
	if current_turn == 1:
		on_cycle_completed()

func set_turn(turn_number: int) -> bool:
	if turn_number < 1 or turn_number > max_turns:
		return false
	
	# Save current turn data before changing
	save_turn_data(current_turn)
	
	# Set new turn
	var old_turn = current_turn
	current_turn = turn_number
	time_in_current_turn = 0.0
	
	# Save to file
	_save_current_turn()
	
	# Emit signal
	emit_signal("turn_advanced", old_turn, current_turn)
	
	return true

func set_quantum_loop(active: bool):
	quantum_loop_active = active
	
	if quantum_loop_active:
		print("Quantum Loop ACTIVATED - 12 turns per second")
	else:
		print("Quantum Loop DEACTIVATED - Standard turn progression")

func on_cycle_completed():
	print("Full cycle completed (turns 1-12)!")
	
	# Archive cycle data
	_archive_current_cycle()
	
	# Emit signal
	emit_signal("cycle_completed")

# ----- DATA MANAGEMENT -----
func save_turn_data(turn_number: int):
	# Create turn data
	var turn_data = {
		"turn": turn_number,
		"phase": turn_phases[turn_number - 1],
		"symbol": turn_symbols[turn_number - 1],
		"dimension": turn_dimensions[turn_number - 1],
		"concept": turn_concepts[turn_number - 1],
		"time_spent": time_in_current_turn,
		"timestamp": Time.get_unix_time_from_system(),
		"quantum_active": quantum_loop_active,
		"notes": []
	}
	
	# Save to JSON
	var file_path = "%s/turn_%d.json" % [data_path, turn_number]
	var json_string = JSON.stringify(turn_data, "  ")
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save turn data to %s" % file_path)
	
	last_save_time = total_system_time
	emit_signal("turn_data_saved", turn_number, file_path)

func _save_current_turn():
	var file_path = "%s/current_turn.json" % data_path
	var data = {
		"current_turn": current_turn,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save current turn to %s" % file_path)

func _load_saved_turn():
	var file_path = "%s/current_turn.json" % data_path
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error = json.parse(json_string)
			
			if error == OK:
				var data = json.get_data()
				if data.has("current_turn"):
					current_turn = clamp(data["current_turn"], 1, max_turns)
					print("Loaded saved turn: %d" % current_turn)

func _archive_current_cycle():
	var cycle_dir = "%s/cycles/cycle_%d" % [data_path, int(Time.get_unix_time_from_system())]
	
	# Create cycle directory
	var dir = DirAccess.open(data_path)
	if dir:
		if not dir.dir_exists("cycles"):
			dir.make_dir("cycles")
	
	dir = DirAccess.open("%s/cycles" % data_path)
	if dir:
		if not dir.dir_exists(cycle_dir):
			dir.make_dir_recursive(cycle_dir)
			
	# Copy all turn data to cycle directory
	for turn in range(1, max_turns + 1):
		var turn_file = "%s/turn_%d.json" % [data_path, turn]
		var cycle_file = "%s/turn_%d.json" % [cycle_dir, turn]
		
		if FileAccess.file_exists(turn_file):
			var file = FileAccess.open(turn_file, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				
				var dest_file = FileAccess.open(cycle_file, FileAccess.WRITE)
				if dest_file:
					dest_file.store_string(content)
					dest_file.close()

# ----- UTILITY FUNCTIONS -----
func _ensure_directories_exist():
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists(data_path):
			dir.make_dir(data_path)
		if not dir.dir_exists(cache_path):
			dir.make_dir(cache_path)

# ----- PUBLIC API -----
func get_current_phase_name() -> String:
	return turn_phases[current_turn - 1]

func get_current_symbol() -> String:
	return turn_symbols[current_turn - 1]

func get_current_dimension() -> String:
	return turn_dimensions[current_turn - 1]

func get_current_concept() -> String:
	return turn_concepts[current_turn - 1]

func get_turn_progress() -> float:
	return time_in_current_turn / time_per_turn

func get_total_progress() -> float:
	return float(current_turn - 1 + get_turn_progress()) / float(max_turns)

func get_time_remaining() -> float:
	return max(0.0, time_per_turn - time_in_current_turn)

func get_formatted_time_remaining() -> String:
	var seconds = int(get_time_remaining())
	var minutes = seconds / 60
	seconds = seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func get_turn_info() -> Dictionary:
	return {
		"current_turn": current_turn,
		"max_turns": max_turns,
		"phase": get_current_phase_name(),
		"symbol": get_current_symbol(),
		"dimension": get_current_dimension(),
		"concept": get_current_concept(),
		"time_remaining": get_time_remaining(),
		"progress": get_turn_progress(),
		"total_progress": get_total_progress(),
		"auto_advance": auto_advance,
		"quantum_active": quantum_loop_active
	}

func manually_advance_turn():
	advance_turn()
	return current_turn

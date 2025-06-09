extends Node

class_name TurnSystem

# ----- TURN SYSTEM SETTINGS -----
@export_category("Turn System Settings")
@export var turns_enabled: bool = true
@export var max_turns: int = 12
@export var current_turn: int = 3
@export var time_per_turn: float = 300.0  # 5 minutes per turn
@export var auto_advance: bool = true

# ----- COMPONENT REFERENCES -----
var game_controller: Node
var time_progression_system: Node
var multiverse_evolution_system: Node

# ----- TIME TRACKING -----
var time_in_current_turn: float = 0.0
var total_system_time: float = 0.0
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

# ----- DATA PATHS -----
var c_drive_path = "C:/Users/Percision 15/12_turns_system"
var d_drive_path = "D:/JSH_Turn_Data"
var screenshots_path = "C:/Users/Percision 15/Pictures/Screenshots"

# ----- SIGNALS -----
signal turn_advanced(old_turn, new_turn)
signal turn_data_saved(turn, path)
signal turn_time_updated(time_remaining)

# ----- INITIALIZATION -----
func _ready():
	# Initialize time tracking
	time_in_current_turn = 0.0
	
	# Create a timer for saving data
	var save_timer = Timer.new()
	save_timer.wait_time = save_interval
	save_timer.one_shot = false
	save_timer.autostart = true
	save_timer.connect("timeout", _on_save_timer_timeout)
	add_child(save_timer)
	
	# Make sure data directories exist
	_ensure_directories_exist()
	
	# Load current turn from file system
	_load_current_turn()
	
	# Notify of initialized state
	print("Turn System initialized: Current Turn " + str(current_turn) + " - " + get_current_phase_name())

# ----- PROCESS -----
func _process(delta):
	if not turns_enabled:
		return
	
	# Update time tracking
	time_in_current_turn += delta
	total_system_time += delta
	
	# Check for turn advancement
	if auto_advance and time_in_current_turn >= time_per_turn:
		advance_turn()
	
	# Emit time updated signal
	var time_remaining = max(0.0, time_per_turn - time_in_current_turn)
	emit_signal("turn_time_updated", time_remaining)

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
	
	# Sync with bash system if possible
	_sync_with_bash_system()
	
	# Emit signal
	emit_signal("turn_advanced", old_turn, current_turn)
	
	# Log turn advancement
	print("Advanced to Turn " + str(current_turn) + " - " + get_current_phase_name())
	
	# Apply turn effects
	apply_turn_effects()
	
	# If we completed a full cycle (reached turn 1 again)
	if current_turn == 1:
		on_cycle_completed()

func get_current_phase_name() -> String:
	return turn_phases[current_turn - 1]

func get_turn_progress() -> float:
	return time_in_current_turn / time_per_turn

func get_total_progress() -> float:
	return float(current_turn - 1 + get_turn_progress()) / float(max_turns)

# ----- DATA MANAGEMENT -----
func save_turn_data(turn_number: int):
	# Create base turn data
	var turn_data = {
		"turn": turn_number,
		"phase": turn_phases[turn_number - 1],
		"time_spent": time_in_current_turn,
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": {}
	}
	
	# Add game state if game controller exists
	if game_controller and game_controller.has_method("get_game_state"):
		turn_data.game_state = game_controller.get_game_state()
	
	# Add time system data if available
	if time_progression_system:
		turn_data.time_system = {
			"current_time": time_progression_system.get_current_time(),
			"story_segment": time_progression_system.get_current_story_segment(),
			"story_arc": time_progression_system.get_current_story_arc()
		}
	
	# Add multiverse data if available
	if multiverse_evolution_system:
		turn_data.multiverse = {
			"current_universe": multiverse_evolution_system.get_current_universe_id(),
			"universe_count": multiverse_evolution_system.get_universe_count(),
			"current_age": multiverse_evolution_system.get_current_age()
		}
	
	# Save to C drive
	var c_drive_file = c_drive_path + "/turn_" + str(turn_number) + "/data/turn_data.json"
	_save_json_file(c_drive_file, turn_data)
	
	# Also save to D drive if it exists
	var d_drive_dir = d_drive_path + "/turn_" + str(turn_number) + "/data"
	var d_drive_file = d_drive_dir + "/turn_data.json"
	
	if DirAccess.dir_exists_absolute(d_drive_path):
		if not DirAccess.dir_exists_absolute(d_drive_dir):
			DirAccess.make_dir_recursive_absolute(d_drive_dir)
		_save_json_file(d_drive_file, turn_data)
	
	# Capture screenshots
	_capture_screenshots(turn_number)
	
	# Emit signal
	emit_signal("turn_data_saved", turn_number, c_drive_file)
	
	# Update last save time
	last_save_time = total_system_time

func _save_json_file(file_path: String, data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "  ")
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save turn data to: " + file_path)

func _ensure_directories_exist():
	# Create C drive directories
	for i in range(1, max_turns + 1):
		var dir_path = c_drive_path + "/turn_" + str(i) + "/data"
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)
	
	# Create D drive base directory if D drive exists
	if DirAccess.dir_exists_absolute("D:/"):
		if not DirAccess.dir_exists_absolute(d_drive_path):
			DirAccess.make_dir_recursive_absolute(d_drive_path)

func _capture_screenshots(turn_number: int):
	# Create screenshot directory if it doesn't exist
	var screenshot_dir = screenshots_path + "/turn_" + str(turn_number)
	if not DirAccess.dir_exists_absolute(screenshot_dir):
		DirAccess.make_dir_recursive_absolute(screenshot_dir)
	
	# Capture viewport screenshot
	var image = get_viewport().get_texture().get_image()
	var time_str = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var file_name = screenshot_dir + "/turn" + str(turn_number) + "_" + time_str + ".png"
	image.save_png(file_name)

# ----- BASH INTEGRATION -----
func _sync_with_bash_system():
	# Create a bash command to sync turn numbers
	var bash_script = """
	#!/bin/bash
	echo "%d" > "%s/current_turn.txt"
	
	# Run turn manager if it exists
	if [ -x "%s/turn_manager.sh" ]; then
		"%s/turn_manager.sh"
	fi
	
	# Copy data to D drive if it exists
	if [ -d "D:" ]; then
		mkdir -p "D:/JSH_Turn_Data/turn_%d/data"
		cp -r "%s/turn_%d/data/"* "D:/JSH_Turn_Data/turn_%d/data/"
	fi
	""" % [current_turn, c_drive_path, c_drive_path, c_drive_path, current_turn, c_drive_path, current_turn, current_turn]
	
	# Execute bash command
	var output = []
	var exit_code = OS.execute("bash", ["-c", bash_script], output, true)
	if exit_code != 0:
		push_error("Failed to sync with bash system: " + str(output))

func _save_current_turn():
	# Save current turn to file
	var file_path = c_drive_path + "/current_turn.txt"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(str(current_turn))
		file.close()
	else:
		push_error("Failed to save current turn to: " + file_path)

func _load_current_turn():
	# Load current turn from file if it exists
	var file_path = c_drive_path + "/current_turn.txt"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text().strip_edges()
			if content.is_valid_int():
				current_turn = content.to_int()
				current_turn = clamp(current_turn, 1, max_turns)
			file.close()

# ----- EFFECTS -----
func apply_turn_effects():
	# Apply effects based on current turn
	match current_turn:
		1: # Genesis
			_apply_genesis_effects()
		2: # Formation
			_apply_formation_effects()
		3: # Complexity
			_apply_complexity_effects()
		4: # Consciousness
			_apply_consciousness_effects()
		5: # Awakening
			_apply_awakening_effects()
		6: # Enlightenment
			_apply_enlightenment_effects()
		7: # Manifestation
			_apply_manifestation_effects()
		8: # Connection
			_apply_connection_effects()
		9: # Harmony
			_apply_harmony_effects()
		10: # Transcendence
			_apply_transcendence_effects()
		11: # Unity
			_apply_unity_effects()
		12: # Beyond
			_apply_beyond_effects()

func _apply_genesis_effects():
	if game_controller:
		# Start with minimal entities
		if game_controller.has_method("reset_entities"):
			game_controller.reset_entities()
		
		# Set dim lighting
		if game_controller.has_method("set_ambient_light"):
			game_controller.set_ambient_light(0.2)

func _apply_formation_effects():
	if game_controller:
		# Generate basic structures
		if game_controller.has_method("generate_basic_structures"):
			game_controller.generate_basic_structures(5)
		
		# Increase light slightly
		if game_controller.has_method("set_ambient_light"):
			game_controller.set_ambient_light(0.4)

func _apply_complexity_effects():
	if game_controller:
		# Create more interconnected systems
		if game_controller.has_method("increase_system_complexity"):
			game_controller.increase_system_complexity(0.7)
		
		# Adjust time flow
		if time_progression_system:
			time_progression_system.base_time_scale = 1.2

func _apply_consciousness_effects():
	if game_controller:
		# Enable awareness and feedback
		if game_controller.has_method("enable_feedback_systems"):
			game_controller.enable_feedback_systems(true)
		
		# Increase brightness
		if game_controller.has_method("set_ambient_light"):
			game_controller.set_ambient_light(0.6)

func _apply_awakening_effects():
	if game_controller:
		# Entities become aware
		if game_controller.has_method("trigger_entity_awakening"):
			game_controller.trigger_entity_awakening()
		
		# Adjust time flow - slows during awakening
		if time_progression_system:
			time_progression_system.base_time_scale = 0.8

func _apply_enlightenment_effects():
	if game_controller:
		# Increase knowledge connections
		if game_controller.has_method("increase_knowledge_connections"):
			game_controller.increase_knowledge_connections(0.8)
		
		# Brighter light
		if game_controller.has_method("set_ambient_light"):
			game_controller.set_ambient_light(0.8)

func _apply_manifestation_effects():
	if game_controller:
		# Enable creation abilities
		if game_controller.has_method("enable_creation_mode"):
			game_controller.enable_creation_mode(true)
		
		# Faster time flow during creation
		if time_progression_system:
			time_progression_system.base_time_scale = 1.5

func _apply_connection_effects():
	if game_controller:
		# Connect all entities
		if game_controller.has_method("connect_all_entities"):
			game_controller.connect_all_entities(0.7)
		
		# Normal time flow
		if time_progression_system:
			time_progression_system.base_time_scale = 1.0

func _apply_harmony_effects():
	if game_controller:
		# Balance all systems
		if game_controller.has_method("balance_all_systems"):
			game_controller.balance_all_systems()
		
		# Calm, measured time flow
		if time_progression_system:
			time_progression_system.base_time_scale = 0.9

func _apply_transcendence_effects():
	if game_controller:
		# Enable higher dimensional effects
		if game_controller.has_method("enable_transcendence"):
			game_controller.enable_transcendence(true)
		
		# Faster time flow during transcendence
		if time_progression_system:
			time_progression_system.base_time_scale = 1.7

func _apply_unity_effects():
	if game_controller:
		# Unify all systems
		if game_controller.has_method("unify_all_systems"):
			game_controller.unify_all_systems()
		
		# Full light
		if game_controller.has_method("set_ambient_light"):
			game_controller.set_ambient_light(1.0)

func _apply_beyond_effects():
	if game_controller:
		# Prepare for the next cycle
		if game_controller.has_method("prepare_for_rebirth"):
			game_controller.prepare_for_rebirth()
		
		# Time begins to slow as cycle completes
		if time_progression_system:
			time_progression_system.base_time_scale = 0.5

func on_cycle_completed():
	# Handle cycle completion
	print("Full 12-turn cycle completed! Starting new cycle...")
	
	# Archive previous cycle data
	_archive_previous_cycle()
	
	# Reset systems while preserving key data
	if game_controller and game_controller.has_method("on_cycle_completed"):
		game_controller.on_cycle_completed()

func _archive_previous_cycle():
	# Create archive directory with timestamp
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var archive_dir = c_drive_path + "/cycles/cycle_" + timestamp
	
	# Ensure the directory exists
	if not DirAccess.dir_exists_absolute(archive_dir):
		DirAccess.make_dir_recursive_absolute(archive_dir)
	
	# Create archive bash command
	var bash_script = """
	#!/bin/bash
	timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
	archive_dir="%s/cycles/cycle_${timestamp}"
	mkdir -p "$archive_dir"
	
	# Copy all turn data to archive
	cp -r "%s/turn_"* "$archive_dir/"
	
	# Also archive to D drive if available
	if [ -d "D:" ]; then
		d_archive="D:/JSH_Turn_Data/cycles/cycle_${timestamp}"
		mkdir -p "$d_archive"
		cp -r "D:/JSH_Turn_Data/turn_"* "$d_archive/"
	fi
	
	echo "Cycle archived to: $archive_dir"
	""" % [c_drive_path, c_drive_path]
	
	# Execute bash command
	var output = []
	OS.execute("bash", ["-c", bash_script], output, true)
	print("Cycle archived: " + str(output))

# ----- EVENTS -----
func _on_save_timer_timeout():
	# Periodically save data without advancing turn
	if total_system_time - last_save_time >= save_interval:
		save_turn_data(current_turn)
		last_save_time = total_system_time

# ----- PUBLIC API -----
func manually_advance_turn():
	advance_turn()
	return current_turn

func set_turn(turn_number: int):
	if turn_number < 1 or turn_number > max_turns:
		return false
	
	# Save current turn data before changing
	save_turn_data(current_turn)
	
	# Set new turn
	var old_turn = current_turn
	current_turn = turn_number
	time_in_current_turn = 0.0
	
	# Save and sync
	_save_current_turn()
	_sync_with_bash_system()
	
	# Apply effects
	apply_turn_effects()
	
	# Emit signal
	emit_signal("turn_advanced", old_turn, current_turn)
	
	return true

func toggle_auto_advance(enabled: bool):
	auto_advance = enabled
	return auto_advance

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
		"current_phase": get_current_phase_name(),
		"time_remaining": get_time_remaining(),
		"progress": get_turn_progress(),
		"total_progress": get_total_progress(),
		"auto_advance": auto_advance
	}

func set_references(game_ctrl, time_prog, multiverse_evol):
	game_controller = game_ctrl
	time_progression_system = time_prog
	multiverse_evolution_system = multiverse_evol

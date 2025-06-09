extends Node

class_name TurnBasedGameFramework

# ----- GAME STRUCTURE SETTINGS -----
@export_category("Game Structure")
@export var min_turn_time: int = 120  # 2 minutes per turn minimum
@export var max_turns: int = 12
@export var auto_advance_turns: bool = true
@export var create_turn_folders: bool = true
@export var save_turn_state: bool = true

# ----- GAME COMPONENTS -----
var turn_system: Node = null
var time_tracker: Node = null
var memory_system: Node = null

# ----- TURN FOLDERS AND FILES -----
var turn_folders = []
var turn_scripts = []
var base_folder_path = "user://12_turns_game/"
var scripts_folder_path = "user://12_turns_game/scripts/"

# ----- TURN STATE -----
var current_turn: int = 1
var last_turn_time: int = 0
var total_game_time: int = 0
var turn_completion: Dictionary = {}
var restart_count: int = 0

# ----- TIMERS -----
var turn_timer: Timer
var auto_save_timer: Timer

# ----- SIGNALS -----
signal turn_started(turn_number)
signal turn_completed(turn_number, duration)
signal insufficient_turn_time(turn_number, actual_time, required_time)
signal game_scripts_generated()
signal game_completed()
signal game_restarted(restart_count)

# ----- INITIALIZATION -----
func _ready():
	# Set up folders
	_ensure_folders_exist()
	
	# Set up timers
	_setup_timers()
	
	# Find reference components
	_find_reference_components()
	
	# Load game state
	_load_game_state()
	
	# Generate turn scripts if needed
	if turn_scripts.size() < max_turns:
		generate_turn_scripts()
	
	# Start game if not already in progress
	if current_turn == 1 and last_turn_time == 0:
		start_game()
	else:
		resume_game()
	
	print("Turn Based Game Framework initialized - Current Turn: " + str(current_turn))

func _ensure_folders_exist():
	# Create base game folder
	if not DirAccess.dir_exists_absolute(base_folder_path):
		DirAccess.make_dir_recursive_absolute(base_folder_path)
	
	# Create scripts folder
	if not DirAccess.dir_exists_absolute(scripts_folder_path):
		DirAccess.make_dir_recursive_absolute(scripts_folder_path)
	
	# Create turn folders
	if create_turn_folders:
		for i in range(1, max_turns + 1):
			var turn_folder = base_folder_path + "turn_" + str(i) + "/"
			
			if not DirAccess.dir_exists_absolute(turn_folder):
				DirAccess.make_dir_recursive_absolute(turn_folder)
			
			turn_folders.append(turn_folder)

func _setup_timers():
	# Turn timer
	turn_timer = Timer.new()
	turn_timer.wait_time = 10  # Check every 10 seconds
	turn_timer.one_shot = false
	turn_timer.autostart = true
	turn_timer.connect("timeout", _on_turn_timer_timeout)
	add_child(turn_timer)
	
	# Auto save timer
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 60  # Save every minute
	auto_save_timer.one_shot = false
	auto_save_timer.autostart = true
	auto_save_timer.connect("timeout", _on_auto_save_timer_timeout)
	add_child(auto_save_timer)

func _find_reference_components():
	# Find turn system
	var potential_turns = get_tree().get_nodes_in_group("turn_systems")
	if potential_turns.size() > 0:
		turn_system = potential_turns[0]
		print("Found turn system: " + turn_system.name)
	else:
		turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
		if not turn_system:
			turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
	
	# Find time tracker
	var potential_trackers = get_tree().get_nodes_in_group("time_trackers")
	if potential_trackers.size() > 0:
		time_tracker = potential_trackers[0]
		print("Found time tracker: " + time_tracker.name)
	else:
		time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")
	
	# Find memory system
	memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")

func _find_node_by_class(node, class_namee):
	if node.get_class() == class_namee:
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class(child, class_namee)
		if found:
			return found
	
	return null

# ----- GAME MANAGEMENT -----
func start_game():
	# Reset game state
	current_turn = 1
	last_turn_time = Time.get_unix_time_from_system()
	total_game_time = 0
	turn_completion.clear()
	
	# Sync with turn system if available
	if turn_system and "current_turn" in turn_system:
		turn_system.current_turn = current_turn
	
	# Emit signal
	emit_signal("turn_started", current_turn)
	
	# Save game state
	_save_game_state()
	
	print("Game started - Turn 1")

func resume_game():
	# Calculate time since last save
	var current_time = Time.get_unix_time_from_system()
	var elapsed_since_save = current_time - last_turn_time
	
	# Update last turn time
	last_turn_time = current_time
	
	# Emit signal
	emit_signal("turn_started", current_turn)
	
	print("Game resumed - Turn " + str(current_turn) + " - Elapsed since last save: " + str(elapsed_since_save) + "s")

func advance_turn(force: bool = false):
	# Check if minimum time has elapsed
	var current_time = Time.get_unix_time_from_system()
	var turn_duration = current_time - last_turn_time
	
	if turn_duration < min_turn_time and not force:
		emit_signal("insufficient_turn_time", current_turn, turn_duration, min_turn_time)
		print("Cannot advance turn - Insufficient time spent on current turn")
		return false
	
	# Mark turn as completed
	turn_completion[str(current_turn)] = {
		"completed": true,
		"duration": turn_duration,
		"timestamp": current_time
	}
	
	# Update total game time
	total_game_time += turn_duration
	
	# Emit completion signal
	emit_signal("turn_completed", current_turn, turn_duration)
	
	# Check if game is complete
	if current_turn >= max_turns:
		_on_game_completed()
		return true
	
	# Advance to next turn
	current_turn += 1
	last_turn_time = current_time
	
	# Sync with turn system if available
	if turn_system and "current_turn" in turn_system:
		turn_system.current_turn = current_turn
	
	# Emit signal
	emit_signal("turn_started", current_turn)
	
	# Save game state
	_save_game_state()
	
	print("Advanced to Turn " + str(current_turn))
	
	return true

func restart_game():
	# Increment restart count
	restart_count += 1
	
	# Reset game state
	current_turn = 1
	last_turn_time = Time.get_unix_time_from_system()
	total_game_time = 0
	turn_completion.clear()
	
	# Sync with turn system if available
	if turn_system and "current_turn" in turn_system:
		turn_system.current_turn = current_turn
	
	# Emit signals
	emit_signal("game_restarted", restart_count)
	emit_signal("turn_started", current_turn)
	
	# Save game state
	_save_game_state()
	
	print("Game restarted - Restart count: " + str(restart_count))
	
	return true

# ----- SCRIPT GENERATION -----
func generate_turn_scripts():
	turn_scripts.clear()
	
	# Generate script for each turn
	for i in range(1, max_turns + 1):
		var script_path = scripts_folder_path + "turn_" + str(i) + "_script.gd"
		
		# Check if script already exists
		if FileAccess.file_exists(script_path):
			turn_scripts.append(script_path)
			continue
		
		# Generate script content based on turn number
		var script_content = _generate_script_for_turn(i)
		
		# Write script to file
		var file = FileAccess.open(script_path, FileAccess.WRITE)
		if file:
			file.store_string(script_content)
			file.close()
			
			turn_scripts.append(script_path)
			print("Generated script for Turn " + str(i))
	
	emit_signal("game_scripts_generated")
	
	return turn_scripts

func _generate_script_for_turn(turn_number: int) -> String:
	# Generate appropriate script content based on turn number
	var script_content = ""
	
	# Common header
	script_content += "extends Node\n\n"
	script_content += "# Turn " + str(turn_number) + " Game Script\n"
	script_content += "# Part of the 12 Turns Game Framework\n\n"
	
	# Class declaration
	script_content += "class_name Turn" + str(turn_number) + "Script\n\n"
	
	# Variables
	script_content += "# ----- TURN SETTINGS -----\n"
	script_content += "var turn_number = " + str(turn_number) + "\n"
	script_content += "var min_duration = 120  # 2 minutes minimum\n"
	script_content += "var turn_theme = \"" + _get_theme_for_turn(turn_number) + "\"\n\n"
	
	# References
	script_content += "# ----- REFERENCES -----\n"
	script_content += "var game_framework: Node = null\n"
	script_content += "var memory_system: Node = null\n\n"
	
	# Signals
	script_content += "# ----- SIGNALS -----\n"
	script_content += "signal turn_action_completed(action_name)\n"
	script_content += "signal turn_objective_completed(objective_name)\n\n"
	
	# Functions
	script_content += "# ----- CORE FUNCTIONS -----\n"
	
	# Initialize function
	script_content += "func initialize(framework):\n"
	script_content += "    game_framework = framework\n"
	script_content += "    memory_system = framework._find_node_by_class(framework.get_tree().root, \"IntegratedMemorySystem\")\n"
	script_content += "    print(\"Turn " + str(turn_number) + " Script initialized\")\n"
	script_content += "    _register_turn_objectives()\n\n"
	
	# Start function
	script_content += "func start():\n"
	script_content += "    print(\"Starting Turn " + str(turn_number) + " - Theme: \" + turn_theme)\n"
	script_content += "    # Store memory of turn start\n"
	script_content += "    if memory_system:\n"
	script_content += "        memory_system.store_memory(\"Started Turn " + str(turn_number) + " - \" + turn_theme, [\"turn_start\", \"turn_" + str(turn_number) + "\"], \"game_event\", " + str(turn_number) + ")\n\n"
	
	# Update function
	script_content += "func update(delta):\n"
	script_content += "    # Regular update logic for this turn\n"
	script_content += "    pass\n\n"
	
	# Complete function
	script_content += "func complete():\n"
	script_content += "    print(\"Completed Turn " + str(turn_number) + "\")\n"
	script_content += "    # Store memory of turn completion\n"
	script_content += "    if memory_system:\n"
	script_content += "        memory_system.store_memory(\"Completed Turn " + str(turn_number) + " - \" + turn_theme, [\"turn_complete\", \"turn_" + str(turn_number) + "\"], \"game_event\", " + str(turn_number) + ")\n\n"
	
	# Turn-specific functions
	script_content += "# ----- TURN-SPECIFIC FUNCTIONS -----\n"
	
	# Generate objectives based on turn number
	script_content += "func _register_turn_objectives():\n"
	
	var objectives = _get_objectives_for_turn(turn_number)
	script_content += "    # Objectives for Turn " + str(turn_number) + "\n"
	
	for i in range(objectives.size()):
		var objective = objectives[i]
		script_content += "    print(\"Objective " + str(i+1) + ": " + objective + "\")\n"
	
	script_content += "\n"
	
	# Generate turn-specific action function
	script_content += "func _perform_turn_action(action_name):\n"
	script_content += "    print(\"Performing action: \" + action_name)\n"
	script_content += "    # Implementation would go here\n"
	script_content += "    emit_signal(\"turn_action_completed\", action_name)\n\n"
	
	# Additional helper functions
	script_content += "# ----- HELPER FUNCTIONS -----\n"
	script_content += "func get_turn_info() -> Dictionary:\n"
	script_content += "    return {\n"
	script_content += "        \"turn_number\": turn_number,\n"
	script_content += "        \"turn_theme\": turn_theme,\n"
	script_content += "        \"min_duration\": min_duration\n"
	script_content += "    }\n"
	
	return script_content

func _get_theme_for_turn(turn_number: int) -> String:
	# Return a theme based on turn number
	var themes = [
		"Genesis",      # Turn 1
		"Formation",    # Turn 2
		"Complexity",   # Turn 3
		"Awareness",    # Turn 4
		"Connection",   # Turn 5
		"Expansion",    # Turn 6
		"Mastery",      # Turn 7
		"Transformation", # Turn 8
		"Harmony",      # Turn 9
		"Integration",  # Turn 10
		"Ascension",    # Turn 11
		"Completion"    # Turn 12
	]
	
	return themes[turn_number - 1]

func _get_objectives_for_turn(turn_number: int) -> Array:
	# Return objectives based on turn number
	var objectives = []
	
	match turn_number:
		1:
			objectives = [
				"Create the basic game structure",
				"Define the core game mechanics",
				"Set up the initial game state"
			]
		2:
			objectives = [
				"Implement basic player movement",
				"Create the game world foundations",
				"Add fundamental interaction logic"
			]
		3:
			objectives = [
				"Develop more complex game mechanics",
				"Add variety to the game environment",
				"Create basic AI behaviors"
			]
		4:
			objectives = [
				"Add basic awareness to game entities",
				"Implement feedback systems",
				"Develop the game's memory system"
			]
		5:
			objectives = [
				"Connect game systems together",
				"Implement network of interactions",
				"Create communication between entities"
			]
		6:
			objectives = [
				"Expand the game world",
				"Add more diverse content",
				"Create growth systems"
			]
		7:
			objectives = [
				"Refine existing mechanics",
				"Master creation of game content",
				"Implement advanced techniques"
			]
		8:
			objectives = [
				"Transform the game structure",
				"Evolve game systems to next level",
				"Implement significant changes"
			]
		9:
			objectives = [
				"Balance all game systems",
				"Create harmony between mechanics",
				"Ensure smooth gameplay flow"
			]
		10:
			objectives = [
				"Integrate all systems coherently",
				"Bring together disparate mechanics",
				"Create a unified experience"
			]
		11:
			objectives = [
				"Elevate the game to its final form",
				"Polish all aspects of the experience",
				"Prepare for completion"
			]
		12:
			objectives = [
				"Complete the game circle",
				"Finalize all systems",
				"Create connection back to the beginning"
			]
	
	return objectives

# ----- STATE MANAGEMENT -----
func _save_game_state():
	if not save_turn_state:
		return
	
	var state = {
		"current_turn": current_turn,
		"last_turn_time": last_turn_time,
		"total_game_time": total_game_time,
		"turn_completion": turn_completion,
		"restart_count": restart_count,
		"max_turns": max_turns,
		"min_turn_time": min_turn_time
	}
	
	var file = FileAccess.open(base_folder_path + "game_state.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(state, "  ")
		file.store_string(json_string)
		file.close()
		
		return true
	
	return false

func _load_game_state():
	var state_file = base_folder_path + "game_state.json"
	
	if FileAccess.file_exists(state_file):
		var file = FileAccess.open(state_file, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			
			if error == OK:
				var state = json.data
				
				current_turn = state.get("current_turn", 1)
				last_turn_time = state.get("last_turn_time", 0)
				total_game_time = state.get("total_game_time", 0)
				turn_completion = state.get("turn_completion", {})
				restart_count = state.get("restart_count", 0)
				
				# Optionally update settings
				if state.has("max_turns"):
					max_turns = state.max_turns
				
				if state.has("min_turn_time"):
					min_turn_time = state.min_turn_time
			
			file.close()
			
			return true
	
	return false

# ----- EVENT HANDLERS -----
func _on_turn_timer_timeout():
	if auto_advance_turns:
		# Check if we've spent enough time in the current turn
		var current_time = Time.get_unix_time_from_system()
		var turn_duration = current_time - last_turn_time
		
		if turn_duration >= min_turn_time:
			# Check if this is the completed turn
			if not turn_completion.has(str(current_turn)):
				print("Auto-advancing turn after " + str(turn_duration) + " seconds")
				advance_turn()
	
	# Update total game time
	total_game_time = _calculate_total_game_time()

func _on_auto_save_timer_timeout():
	_save_game_state()

func _on_game_completed():
	print("Game completed! All 12 turns finished.")
	
	# Record completion in memory system if available
	if memory_system and memory_system.has_method("store_memory"):
		memory_system.store_memory(
			"Completed all 12 turns of the game! Total time: " + format_time(total_game_time),
			["game_complete", "achievement"],
			"game_completion",
			max_turns
		)
	
	# Store extra details
	_save_completion_details()
	
	# Emit completion signal
	emit_signal("game_completed")

# ----- UTILITY FUNCTIONS -----
func _calculate_total_game_time() -> int:
	var total = 0
	
	# Sum up completed turn durations
	for turn_key in turn_completion:
		var turn_data = turn_completion[turn_key]
		if turn_data.has("duration"):
			total += turn_data.duration
	
	# Add time spent in current turn
	if last_turn_time > 0:
		var current_time = Time.get_unix_time_from_system()
		var current_turn_time = current_time - last_turn_time
		total += current_turn_time
	
	return total

func _save_completion_details():
	var completion_file = base_folder_path + "game_completion.json"
	
	var completion_data = {
		"completed_at": Time.get_datetime_string_from_system(),
		"total_time": total_game_time,
		"restart_count": restart_count,
		"turn_completion": turn_completion,
		"formatted_total_time": format_time(total_game_time)
	}
	
	var file = FileAccess.open(completion_file, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(completion_data, "  ")
		file.store_string(json_string)
		file.close()
		
		return true
	
	return false

func format_time(seconds: int) -> String:
	var hours = int(seconds / 3600)
	var minutes = int((seconds % 3600) / 60)
	var secs = int(seconds % 60)
	
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]

# ----- PUBLIC API -----
func get_current_turn() -> int:
	return current_turn

func get_turn_time_remaining() -> int:
	var current_time = Time.get_unix_time_from_system()
	var turn_duration = current_time - last_turn_time
	
	return max(0, min_turn_time - turn_duration)

func get_game_progress() -> float:
	return float(current_turn) / float(max_turns)

func get_turn_completion_percentage() -> float:
	var current_time = Time.get_unix_time_from_system()
	var turn_duration = current_time - last_turn_time
	
	return min(1.0, float(turn_duration) / float(min_turn_time))

func set_min_turn_time(seconds: int) -> bool:
	if seconds < 30:  # Don't allow less than 30 seconds
		return false
	
	min_turn_time = seconds
	return true

func has_sufficient_turn_time() -> bool:
	var current_time = Time.get_unix_time_from_system()
	var turn_duration = current_time - last_turn_time
	
	return turn_duration >= min_turn_time

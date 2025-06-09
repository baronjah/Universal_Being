extends Node

class_name TurnController

# ----- TURN SETTINGS -----
@export_category("Turn Settings")
@export var total_turns: int = 12
@export var current_turn: int = 1
@export var auto_advance_turns: bool = false
@export var turn_duration: float = 300.0  # 5 minutes per turn
@export var notify_before_turn_end: float = 30.0  # 30 seconds warning
@export var turn_indicator_path: String = "user://current_turn.txt"

# ----- POWER SCALING -----
@export_category("Power Scaling")
@export var min_power_percentage: float = 0.33  # 33%
@export var max_power_percentage: float = 0.66  # 66%
@export var current_power_percentage: float = 0.30  # 30% default
@export var power_scaling_curve: float = 1.0  # Linear scaling by default

# ----- STATE VARIABLES -----
var turn_timer: Timer
var warning_timer: Timer
var turn_data = {}
var is_turn_transitioning = false
var turn_history = []
var registered_systems = []
var color_system = null
var animation_system = null
var main_controller = null

# ----- SIGNALS -----
signal turn_started(turn_number)
signal turn_ended(turn_number)
signal turn_warning(turn_number, seconds_remaining)
signal power_percentage_changed(percentage)
signal turn_data_updated(turn_number, data)

# ----- INITIALIZATION -----
func _ready():
	# Initialize timers
	_initialize_timers()
	
	# Find core systems
	_find_systems()
	
	# Load current turn
	_load_current_turn()
	
	# Connect signals
	_connect_signals()
	
	# Start turn if auto-advance is enabled
	if auto_advance_turns:
		start_turn(current_turn)
	
	print("Turn Controller initialized")
	print("Current turn: " + str(current_turn) + "/" + str(total_turns))
	print("Power percentage: " + str(current_power_percentage * 100) + "%")

func _initialize_timers():
	# Create turn timer
	turn_timer = Timer.new()
	turn_timer.one_shot = true
	turn_timer.wait_time = turn_duration
	turn_timer.connect("timeout", Callable(self, "_on_turn_timer_timeout"))
	add_child(turn_timer)
	
	# Create warning timer
	warning_timer = Timer.new()
	warning_timer.one_shot = true
	warning_timer.wait_time = turn_duration - notify_before_turn_end
	warning_timer.connect("timeout", Callable(self, "_on_warning_timer_timeout"))
	add_child(warning_timer)

func _find_systems():
	# Find color system
	color_system = get_node_or_null("/root/ExtendedColorThemeSystem")
	if not color_system:
		color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not color_system:
		color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
	
	# Find animation system
	animation_system = get_node_or_null("/root/TaskTransitionAnimator")
	if not animation_system:
		animation_system = _find_node_by_class(get_tree().root, "TaskTransitionAnimator")
	
	# Find main controller
	main_controller = get_node_or_null("/root/MainController")
	if not main_controller:
		main_controller = _find_node_by_class(get_tree().root, "MainController")
	
	print("Systems found - Color: %s, Animation: %s, Main Controller: %s" % [
		"Yes" if color_system else "No",
		"Yes" if animation_system else "No",
		"Yes" if main_controller else "No"
	])

func _find_node_by_class(node, class_name_str):
	if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class(child, class_name_str)
		if found:
			return found
	
	return null

func _load_current_turn():
	# Load current turn from file
	var file = File.new()
	if file.file_exists(turn_indicator_path):
		file.open(turn_indicator_path, File.READ)
		var content = file.get_as_text().strip_edges()
		file.close()
		
		var turn_number = int(content)
		if turn_number >= 1 and turn_number <= total_turns:
			current_turn = turn_number
			print("Loaded current turn from file: " + str(current_turn))
	else:
		# Create file with default turn
		_save_current_turn()

func _save_current_turn():
	# Save current turn to file
	var file = File.new()
	file.open(turn_indicator_path, File.WRITE)
	file.store_string(str(current_turn))
	file.close()
	
	print("Saved current turn to file: " + str(current_turn))
	
	# Also save to display files for multi-window systems
	_update_display_files()

func _update_display_files():
	# Update display files for multiple windows/terminals
	var display_files = [
		"user://display1_turn.txt",
		"user://display2_turn.txt"
	]
	
	for display_file in display_files:
		var file = File.new()
		file.open(display_file, File.WRITE)
		file.store_string(str(current_turn))
		file.close()

func _connect_signals():
	# Connect signals from other systems if needed
	if color_system and color_system.has_signal("color_frequency_updated"):
		color_system.connect("color_frequency_updated", Callable(self, "_on_color_frequency_updated"))

# ----- TURN MANAGEMENT -----
func start_turn(turn_number: int = 0) -> bool:
	# Start a specific turn (or next turn if 0)
	
	if is_turn_transitioning:
		print("Turn transition already in progress")
		return false
	
	# If turn_number is 0, use next turn
	var new_turn = turn_number if turn_number > 0 else current_turn + 1
	
	# Validate turn number
	if new_turn < 1 or new_turn > total_turns:
		print("Invalid turn number: " + str(new_turn))
		return false
	
	print("Starting turn " + str(new_turn))
	is_turn_transitioning = true
	
	# If changing from a previous turn, end it first
	if current_turn != new_turn and current_turn >= 1 and current_turn <= total_turns:
		_end_current_turn()
	
	# Set new turn
	current_turn = new_turn
	
	# Save to file
	_save_current_turn()
	
	# Load turn data if it exists, or create new data
	_load_turn_data(current_turn)
	
	# Update power percentage based on turn
	_update_power_percentage()
	
	# Apply turn theme if color system is available
	if color_system:
		_apply_turn_theme()
	
	# Start timers
	if turn_duration > 0:
		turn_timer.wait_time = turn_duration
		turn_timer.start()
		
		if notify_before_turn_end > 0 and notify_before_turn_end < turn_duration:
			warning_timer.wait_time = turn_duration - notify_before_turn_end
			warning_timer.start()
	
	# Notify registered systems
	_notify_systems_turn_change()
	
	is_turn_transitioning = false
	
	# Emit signal
	emit_signal("turn_started", current_turn)
	
	return true

func _end_current_turn():
	# End the current turn
	print("Ending turn " + str(current_turn))
	
	# Save turn data
	_save_turn_data(current_turn)
	
	# Add to history
	turn_history.append({
		"turn": current_turn,
		"completion_time": OS.get_unix_time(),
		"data": turn_data.duplicate()
	})
	
	# Stop timers
	turn_timer.stop()
	warning_timer.stop()
	
	# Emit signal
	emit_signal("turn_ended", current_turn)

func end_turn() -> bool:
	# End current turn and start next turn
	
	if is_turn_transitioning:
		print("Turn transition already in progress")
		return false
	
	if current_turn >= total_turns:
		print("Already at last turn")
		_end_current_turn()
		return false
	
	_end_current_turn()
	return start_turn(current_turn + 1)

func set_turn(turn_number: int) -> bool:
	# Set the current turn directly
	
	if turn_number < 1 or turn_number > total_turns:
		print("Invalid turn number: " + str(turn_number))
		return false
	
	return start_turn(turn_number)

func _load_turn_data(turn_number: int):
	# Load turn data from file or create new
	var dir_name = "user://turn_" + str(turn_number)
	var manifest_path = dir_name + "/manifest.json"
	
	var dir = Directory.new()
	if not dir.dir_exists(dir_name):
		dir.make_dir_recursive(dir_name)
	
	var file = File.new()
	if file.file_exists(manifest_path):
		# Load existing data
		file.open(manifest_path, File.READ)
		var content = file.get_as_text()
		file.close()
		
		var json_result = JSON.parse(content)
		if json_result.error == OK:
			turn_data = json_result.result
			print("Loaded turn data for turn " + str(turn_number))
		else:
			print("Error parsing turn data, creating new")
			_create_default_turn_data(turn_number)
	else:
		# Create new turn data
		_create_default_turn_data(turn_number)
	
	# Ensure description file exists
	var desc_path = dir_name + "/description.txt"
	if not file.file_exists(desc_path):
		file.open(desc_path, File.WRITE)
		file.store_string("Turn " + str(turn_number) + " - Add description here")
		file.close()
	
	# Emit signal
	emit_signal("turn_data_updated", turn_number, turn_data)

func _create_default_turn_data(turn_number: int):
	# Create default data for a turn
	turn_data = {
		"turn_number": turn_number,
		"power_percentage": current_power_percentage,
		"creation_time": OS.get_unix_time(),
		"last_updated": OS.get_unix_time(),
		"theme": "turn_" + str(turn_number),
		"primary_frequency": 333 + (turn_number * 33),
		"elements": [],
		"flags": {
			"grid_enabled": true,
			"translation_enabled": true,
			"tetris_movement": turn_number > 6,
			"3d_enabled": turn_number > 4
		}
	}
	
	_save_turn_data(turn_number)
	print("Created default turn data for turn " + str(turn_number))

func _save_turn_data(turn_number: int):
	# Save turn data to file
	var dir_name = "user://turn_" + str(turn_number)
	var manifest_path = dir_name + "/manifest.json"
	
	var dir = Directory.new()
	if not dir.dir_exists(dir_name):
		dir.make_dir_recursive(dir_name)
	
	# Update last_updated timestamp
	turn_data.last_updated = OS.get_unix_time()
	
	var file = File.new()
	file.open(manifest_path, File.WRITE)
	file.store_string(JSON.print(turn_data, "  "))
	file.close()
	
	print("Saved turn data for turn " + str(turn_number))

func _update_power_percentage():
	# Update power percentage based on current turn
	var turn_progress = float(current_turn - 1) / (total_turns - 1) if total_turns > 1 else 0
	
	# Apply curve
	var curve_factor = pow(turn_progress, power_scaling_curve)
	
	# Scale between min and max
	var new_percentage = min_power_percentage + (max_power_percentage - min_power_percentage) * curve_factor
	
	# Update current and turn data
	current_power_percentage = new_percentage
	turn_data.power_percentage = new_percentage
	
	emit_signal("power_percentage_changed", current_power_percentage)
	
	print("Power percentage set to: " + str(current_power_percentage * 100) + "%")

func _apply_turn_theme():
	# Apply theme based on current turn
	
	if color_system.has_method("update_turn"):
		# For DimensionalColorSystem
		color_system.update_turn(current_turn, total_turns)
		print("Updated color system turn to " + str(current_turn))
	elif color_system.has_method("apply_theme"):
		# For ExtendedColorThemeSystem - try to find a matching theme
		var theme_name = "default"
		
		# Look for turn-specific theme
		if current_turn <= 4:
			theme_name = "default"  # Turns 1-4: Default blue theme
		elif current_turn <= 8:
			theme_name = "ethereal"  # Turns 5-8: Ethereal theme
		else:
			theme_name = "akashic"   # Turns 9-12: Akashic theme
		
		color_system.apply_theme(theme_name)
		print("Applied " + theme_name + " theme for turn " + str(current_turn))

func _notify_systems_turn_change():
	# Notify all registered systems of turn change
	for system in registered_systems:
		if is_instance_valid(system) and system.has_method("on_turn_changed"):
			system.on_turn_changed(current_turn, turn_data)

# ----- SYSTEM REGISTRATION -----
func register_system(system: Node) -> void:
	# Register a system to receive turn change notifications
	if not registered_systems.has(system):
		registered_systems.append(system)
		print("Registered system: " + system.name)

func unregister_system(system: Node) -> void:
	# Unregister a system
	if registered_systems.has(system):
		registered_systems.erase(system)
		print("Unregistered system: " + system.name)

# ----- EVENT HANDLERS -----
func _on_turn_timer_timeout():
	# Called when turn timer expires
	print("Turn " + str(current_turn) + " time expired")
	
	if auto_advance_turns:
		end_turn()

func _on_warning_timer_timeout():
	# Called when warning timer expires
	print("Turn " + str(current_turn) + " ending soon (" + str(notify_before_turn_end) + " seconds remaining)")
	
	emit_signal("turn_warning", current_turn, notify_before_turn_end)

func _on_color_frequency_updated(frequency, color):
	# Process color frequency updates if needed
	# This allows for emergent behavior when colors/frequencies change
	
	if frequency == turn_data.primary_frequency:
		# A change in the primary frequency for this turn was detected
		# Could trigger special effects or behaviors
		pass

# ----- PUBLIC API -----
func get_turn_data() -> Dictionary:
	return turn_data.duplicate()

func set_turn_flag(flag_name: String, value) -> void:
	# Set a flag in the current turn data
	if not turn_data.has("flags"):
		turn_data.flags = {}
	
	turn_data.flags[flag_name] = value
	emit_signal("turn_data_updated", current_turn, turn_data)
	
	print("Set turn flag: " + flag_name + " = " + str(value))

func get_turn_flag(flag_name: String, default_value = null):
	# Get a flag from the current turn data
	if not turn_data.has("flags") or not turn_data.flags.has(flag_name):
		return default_value
	
	return turn_data.flags[flag_name]

func get_turn_history() -> Array:
	return turn_history.duplicate()

func get_power_percentage() -> float:
	return current_power_percentage

func set_power_percentage(percentage: float) -> void:
	# Set power percentage directly
	var new_percentage = clamp(percentage, 0.0, 1.0)
	current_power_percentage = new_percentage
	turn_data.power_percentage = new_percentage
	
	emit_signal("power_percentage_changed", current_power_percentage)
	
	print("Power percentage set to: " + str(current_power_percentage * 100) + "%")

func get_remaining_time() -> float:
	# Get remaining time in current turn
	if turn_timer.is_stopped():
		return 0.0
	
	return turn_timer.time_left

func get_current_turn() -> int:
	return current_turn

func get_total_turns() -> int:
	return total_turns

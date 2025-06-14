extends Node
class_name ThermalCalibrationSystem

# Thermal Calibration System
# Manages temperature fluctuations across the memory system
# Implements 29% calibration pattern with stabilization yoyos
# Synchronizes with 12-turn cycle for 24-hour alignment
# Supports terminal commands and special Claude+ integration

# Temperature constants and parameters
const BASE_TEMPERATURE = 298.0  # Kelvin (25°C)
const TEMPERATURE_VARIANCE = 29.0  # Percent max deviation
const STABILIZATION_THRESHOLD = 3.0  # Kelvin
const SYNC_CYCLE_LENGTH = 12  # Turns
const MAX_RESTARTS_PER_DAY = 9
const DAY_CYCLE_HOURS = 25.0  # Special 25-hour cycle

# Temperature patterns (yoyo oscillators)
enum YoyoPattern {
	LINEAR,      # Smooth up-down
	SINE_WAVE,   # Sinusoidal
	STEP,        # Discrete steps
	EXPONENTIAL, # Exponential rise/fall
	RESONANT,    # Triple peak resonance
	CHAOTIC      # Pseudo-random fluctuations
}

# Terminal command prefixes
const MEMORY_COMMAND_PREFIX = "#memories"
const TERMINAL_COMMAND_PREFIX = "#"
const EDITOR_COMMAND_PREFIX = "/"

# System state
var current_temperature = BASE_TEMPERATURE
var target_temperature = BASE_TEMPERATURE
var temperature_delta = 0.0
var stabilization_active = false
var restart_count = 0
var current_cycle_position = 0.0  # 0.0-1.0 position in cycle
var yoyo_oscillators = {}
var active_patterns = []

# Timing variables
var day_timer = 0.0
var last_turn_time = 0.0
var turn_duration = 0.0
var day_start_time = 0.0
var thermal_check_timer = 0.0

# Connected systems
var memory_system
var triple_connector

# Terminal command history
var command_history = []
var command_results = {}

# Signals
signal temperature_changed(temp, delta)
signal stabilization_triggered(reason)
signal thermal_cycle_completed(cycle_number)
signal command_executed(command, result)
signal yoyo_oscillation(pattern, value)

# ===== Initialization =====

func _ready():
	# Find connected systems
	memory_system = _find_memory_system()
	triple_connector = _find_triple_connector()
	
	# Initialize oscillators
	_initialize_oscillators()
	
	# Set up initial active patterns
	_setup_active_patterns()
	
	# Record start time
	day_start_time = Time.get_unix_time_from_system()
	
	# Calculate initial temperature
	_calculate_initial_temperature()
	
	# Connect to memory system signals if available
	if memory_system:
		if memory_system.has_signal("turn_completed"):
			memory_system.connect("turn_completed", Callable(self, "_on_turn_completed"))

func _find_memory_system():
	return get_node_or_null("/root/MemoryTurnSystem") or get_node_or_null("../MemoryTurnSystem")

func _find_triple_connector():
	return get_node_or_null("/root/TripleMemoryConnector") or get_node_or_null("../TripleMemoryConnector")

func _initialize_oscillators():
	# Create all yoyo oscillator patterns
	yoyo_oscillators = {
		YoyoPattern.LINEAR: YoyoOscillator.new(YoyoPattern.LINEAR, 1.0),
		YoyoPattern.SINE_WAVE: YoyoOscillator.new(YoyoPattern.SINE_WAVE, 1.2),
		YoyoPattern.STEP: YoyoOscillator.new(YoyoPattern.STEP, 0.7),
		YoyoPattern.EXPONENTIAL: YoyoOscillator.new(YoyoPattern.EXPONENTIAL, 0.5),
		YoyoPattern.RESONANT: YoyoOscillator.new(YoyoPattern.RESONANT, 0.3),
		YoyoPattern.CHAOTIC: YoyoOscillator.new(YoyoPattern.CHAOTIC, 0.9)
	}
	
	# Initialize with different phases
	var phase = 0.0
	for pattern in yoyo_oscillators:
		yoyo_oscillators[pattern].phase = phase
		phase += 0.33

func _setup_active_patterns():
	# Initially activate 3 patterns (creating a triple yoyo system)
	active_patterns = [
		YoyoPattern.SINE_WAVE,
		YoyoPattern.EXPONENTIAL,
		YoyoPattern.RESONANT
	]

func _calculate_initial_temperature():
	# Calculate initial temperature based on active patterns
	var temp_offset = 0.0
	
	for pattern in active_patterns:
		if yoyo_oscillators.has(pattern):
			temp_offset += yoyo_oscillators[pattern].get_value(0.0) * 3.0
	
	# Apply 29% rule
	temp_offset = temp_offset * TEMPERATURE_VARIANCE / 100.0
	
	current_temperature = BASE_TEMPERATURE + temp_offset
	target_temperature = current_temperature
	
	emit_signal("temperature_changed", current_temperature, 0.0)

# ===== Temperature Calibration =====

func calibrate_temperature(delta_time: float):
	# Update oscillator cycle position
	current_cycle_position += delta_time / (DAY_CYCLE_HOURS * 3600.0)
	current_cycle_position = fmod(current_cycle_position, 1.0)
	
	# Get combined oscillator value
	var combined_value = 0.0
	var oscillator_count = active_patterns.size()
	
	for pattern in active_patterns:
		if yoyo_oscillators.has(pattern):
			var value = yoyo_oscillators[pattern].get_value(current_cycle_position)
			combined_value += value
			emit_signal("yoyo_oscillation", pattern, value)
	
	if oscillator_count > 0:
		combined_value /= oscillator_count
	
	# Calculate target temperature with 29% variance rule
	var max_deviation = BASE_TEMPERATURE * TEMPERATURE_VARIANCE / 100.0
	target_temperature = BASE_TEMPERATURE + combined_value * max_deviation
	
	# Update current temperature with inertia
	var inertia = 0.1
	temperature_delta = target_temperature - current_temperature
	
	if stabilization_active:
		inertia = 0.3  # Faster stabilization
	
	current_temperature += temperature_delta * inertia * delta_time
	
	# Check for stabilization need
	if abs(temperature_delta) > STABILIZATION_THRESHOLD and !stabilization_active:
		trigger_stabilization("thermal_drift")
	
	emit_signal("temperature_changed", current_temperature, temperature_delta)

func trigger_stabilization(reason: String):
	stabilization_active = true
	print("THERMAL STABILIZATION TRIGGERED: " + reason)
	
	# Modify oscillators to achieve stabilization
	for pattern in active_patterns:
		if yoyo_oscillators.has(pattern):
			yoyo_oscillators[pattern].dampen(0.5)  # Reduce amplitude by half
	
	# Schedule stabilization end
	get_tree().create_timer(12.0).timeout.connect(Callable(self, "_end_stabilization"))
	
	# Notify systems
	emit_signal("stabilization_triggered", reason)
	
	# Execute relevant terminal command
	execute_terminal_command(MEMORY_COMMAND_PREFIX + " stabilize " + reason)

func _end_stabilization():
	stabilization_active = false
	print("THERMAL STABILIZATION COMPLETE")
	
	# Restore oscillator behavior
	for pattern in active_patterns:
		if yoyo_oscillators.has(pattern):
			yoyo_oscillators[pattern].restore()

# ===== Turn System Integration =====

func _on_turn_completed(turn_number: int):
	var current_time = Time.get_unix_time_from_system()
	turn_duration = current_time - last_turn_time
	last_turn_time = current_time
	
	print("Turn " + str(turn_number) + " completed, duration: " + str(turn_duration) + "s")
	
	# Adjust thermal system based on turn completion
	_adjust_thermal_system_for_turn(turn_number)
	
	# Check if we need a restart
	if turn_number == SYNC_CYCLE_LENGTH and restart_count < MAX_RESTARTS_PER_DAY:
		_prepare_system_restart()

func _adjust_thermal_system_for_turn(turn_number: int):
	# Switch active patterns based on turn number
	if turn_number % 3 == 0:
		_cycle_active_patterns()
	
	# At turn 6 (halfway), perform special calibration
	if turn_number == 6:
		target_temperature = BASE_TEMPERATURE
		execute_terminal_command("#memories recalibrate mid_cycle")
	
	# Every 4th turn, apply 29% adjustment
	if turn_number % 4 == 0:
		var adjustment = BASE_TEMPERATURE * 0.29 * (turn_number / SYNC_CYCLE_LENGTH)
		target_temperature += adjustment
		
		if memory_system:
			# Adjust memory dot frequency with similar pattern
			var new_frequency = 23.0 + (turn_number / SYNC_CYCLE_LENGTH) * 29.0
			new_frequency = clamp(new_frequency, 10.0, 50.0)
			memory_system.DOT_FREQUENCY_BASE = new_frequency

func _cycle_active_patterns():
	# Rotate patterns to create the yoyo effect
	# Remove one pattern, add a different one
	if active_patterns.size() > 0:
		active_patterns.remove_at(0)
	
	# Add a new pattern that's not currently active
	var all_patterns = yoyo_oscillators.keys()
	var available_patterns = []
	
	for pattern in all_patterns:
		if !active_patterns.has(pattern):
			available_patterns.append(pattern)
	
	if available_patterns.size() > 0:
		var new_pattern = available_patterns[randi() % available_patterns.size()]
		active_patterns.append(new_pattern)
		print("New oscillation pattern activated: " + str(new_pattern))
	
	# Ensure we have 3 patterns for "triple yoyo" effect
	while active_patterns.size() < 3 and all_patterns.size() >= 3:
		for pattern in all_patterns:
			if !active_patterns.has(pattern):
				active_patterns.append(pattern)
				break
		if active_patterns.size() >= 3:
			break

func _prepare_system_restart():
	restart_count += 1
	print("Preparing system restart " + str(restart_count) + "/" + str(MAX_RESTARTS_PER_DAY))
	
	# Execute restart command
	execute_terminal_command("#memories prepare_restart")
	
	# Schedule restart in 3 seconds
	get_tree().create_timer(3.0).timeout.connect(Callable(self, "_perform_restart"))

func _perform_restart():
	print("SYSTEM RESTART")
	
	# Reset oscillators
	for pattern in yoyo_oscillators:
		yoyo_oscillators[pattern].reset()
	
	# Set up new active patterns
	_setup_active_patterns()
	
	# Reset temperature to base
	current_temperature = BASE_TEMPERATURE
	target_temperature = BASE_TEMPERATURE
	
	# If connected to memory system, trigger a new turn
	if memory_system and memory_system.has_method("start_next_turn"):
		memory_system.start_next_turn()
	
	emit_signal("temperature_changed", current_temperature, 0.0)
	execute_terminal_command("#memories restart_completed")

# ===== Terminal Command System =====

func execute_terminal_command(command: String) -> String:
	# Process terminal and memory commands
	var result = ""
	
	# Add to history
	command_history.append({
		"command": command,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	# Process based on prefix
	if command.begins_with(MEMORY_COMMAND_PREFIX):
		result = _process_memory_command(command)
	elif command.begins_with(TERMINAL_COMMAND_PREFIX):
		result = _process_terminal_command(command)
	elif command.begins_with(EDITOR_COMMAND_PREFIX):
		result = _process_editor_command(command)
	else:
		result = "Unknown command format: " + command
	
	# Store result
	command_results[command] = result
	emit_signal("command_executed", command, result)
	
	return result

func _process_memory_command(command: String) -> String:
	# Handle #memories commands
	var parts = command.split(" ")
	if parts.size() < 2:
		return "Invalid memory command format"
	
	var memory_command = parts[1]
	var result = "Memory command processed: " + memory_command
	
	match memory_command:
		"stabilize":
			# Already handled in trigger_stabilization
			result = "Stabilization protocol initiated"
		"recalibrate":
			# Recalibrate temperature
			if parts.size() > 2:
				var mode = parts[2]
				if mode == "mid_cycle":
					result = "Mid-cycle recalibration complete"
					current_temperature = BASE_TEMPERATURE
				elif mode == "full":
					result = "Full system recalibration complete"
					_calculate_initial_temperature()
				else:
					result = "Unknown recalibration mode: " + mode
			else:
				result = "Missing recalibration mode"
		"prepare_restart":
			result = "Restart preparation sequence initialized"
			# Already handled in _prepare_system_restart
		"restart_completed":
			result = "System restart " + str(restart_count) + " completed"
		"status":
			result = _get_memory_status()
		"333":
			result = _activate_333_mode()
		_:
			result = "Unknown memory command: " + memory_command
	
	return result

func _process_terminal_command(command: String) -> String:
	# Handle regular # commands
	var parts = command.split(" ")
	if parts.size() < 2:
		return "Invalid terminal command format"
	
	var term_command = parts[1]
	var result = "Terminal command processed: " + term_command
	
	match term_command:
		"temp":
			result = "Current temperature: " + str(current_temperature) + "K"
		"cycle":
			result = "Cycle position: " + str(current_cycle_position * 100.0) + "%"
		"restart":
			result = "Restart count: " + str(restart_count) + "/" + str(MAX_RESTARTS_PER_DAY)
		"patterns":
			result = "Active patterns: " + str(active_patterns)
		"day":
			var day_elapsed = Time.get_unix_time_from_system() - day_start_time
			var day_percent = day_elapsed / (DAY_CYCLE_HOURS * 3600.0) * 100.0
			result = "Day progress: " + str(day_percent) + "% (" + str(day_elapsed) + "s)"
		"clear":
			command_history.clear()
			command_results.clear()
			result = "Command history cleared"
		_:
			result = "Unknown terminal command: " + term_command
	
	return result

func _process_editor_command(command: String) -> String:
	# Handle / editor commands
	var parts = command.split(" ")
	if parts.size() < 2:
		return "Invalid editor command format"
	
	var editor_command = parts[1]
	var result = "Editor command processed: " + editor_command
	
	match editor_command:
		"claude+":
			result = "Claude+ features activated"
			_activate_claude_plus()
		"vs":
			if parts.size() > 2:
				var mode = parts[2]
				result = "VS Code mode switched to: " + mode
			else:
				result = "Missing VS Code mode parameter"
		"terminal":
			if parts.size() > 2:
				var mode = parts[2]
				result = "Terminal mode switched to: " + mode
			else:
				result = "Missing terminal mode parameter"
		"custom":
			if parts.size() > 2:
				var custom_name = parts[2]
				result = "Custom command executed: " + custom_name
			else:
				result = "Missing custom command name"
		_:
			result = "Unknown editor command: " + editor_command
	
	return result

func _get_memory_status() -> String:
	var status = "MEMORY SYSTEM STATUS:\n"
	
	if memory_system:
		status += "Turn: " + str(memory_system.current_turn) + "/" + str(memory_system.TURN_COUNT) + "\n"
		status += "Dot frequency: " + str(memory_system.DOT_FREQUENCY_BASE) + "%\n"
		status += "Screen mode: " + memory_system.screen_mode + "\n"
		status += "Memory slots: " + str(memory_system.count_active_memories()) + "/" + str(memory_system.MAX_MEMORY_SLOTS) + "\n"
	else:
		status += "Memory system not connected\n"
	
	status += "Temperature: " + str(current_temperature) + "K\n"
	status += "Thermal delta: " + str(temperature_delta) + "K\n"
	status += "Stabilization: " + str(stabilization_active) + "\n"
	status += "Active yoyos: " + str(active_patterns.size()) + "\n"
	
	return status

func _activate_333_mode() -> String:
	if triple_connector and triple_connector.has_method("activate_333_mode"):
		var success = triple_connector.activate_333_mode()
		if success:
			return "333 resonance mode activated successfully"
		else:
			return "Failed to activate 333 resonance mode (no valid patterns)"
	return "Triple connector system not available"

func _activate_claude_plus() -> void:
	# Placeholder for Claude+ features
	# This would integrate with the API in a real implementation
	print("Claude+ features activated")
	
	# Simulate Claude+ terminal connection
	var terminal_commands = [
		"#memories status",
		"#temp",
		"#cycle",
		"/custom terminal_sync"
	]
	
	# Execute them sequentially
	for cmd in terminal_commands:
		execute_terminal_command(cmd)

# ===== Processing =====

func _process(delta):
	# Update day timer
	day_timer += delta
	
	# Update thermal system
	thermal_check_timer += delta
	if thermal_check_timer >= 1.0:  # Check every second
		thermal_check_timer = 0.0
		calibrate_temperature(1.0)
	
	# Check for day cycle completion
	if day_timer >= DAY_CYCLE_HOURS * 3600.0:
		day_timer = 0.0
		day_start_time = Time.get_unix_time_from_system()
		restart_count = 0
		
		emit_signal("thermal_cycle_completed", 1)
		execute_terminal_command(MEMORY_COMMAND_PREFIX + " status")

# ===== Yoyo Oscillator Class =====

class YoyoOscillator:
	var pattern_type: int
	var amplitude: float
	var frequency: float
	var phase: float
	var original_amplitude: float
	
	func _init(p_type: int, p_freq: float, p_amp: float = 1.0, p_phase: float = 0.0):
		pattern_type = p_type
		frequency = p_freq
		amplitude = p_amp
		original_amplitude = p_amp
		phase = p_phase
	
	func get_value(position: float) -> float:
		# Calculate position with phase offset and frequency
		var pos = fmod(position * frequency + phase, 1.0)
		
		# Apply pattern-specific calculations
		match pattern_type:
			YoyoPattern.LINEAR:
				return _linear_pattern(pos)
			YoyoPattern.SINE_WAVE:
				return _sine_pattern(pos)
			YoyoPattern.STEP:
				return _step_pattern(pos)
			YoyoPattern.EXPONENTIAL:
				return _exponential_pattern(pos)
			YoyoPattern.RESONANT:
				return _resonant_pattern(pos)
			YoyoPattern.CHAOTIC:
				return _chaotic_pattern(pos)
			_:
				return 0.0
	
	func _linear_pattern(pos: float) -> float:
		# Simple triangle wave
		if pos < 0.5:
			return (pos * 2.0) * amplitude
		else:
			return (1.0 - (pos - 0.5) * 2.0) * amplitude
	
	func _sine_pattern(pos: float) -> float:
		return sin(pos * TAU) * amplitude
	
	func _step_pattern(pos: float) -> float:
		# Step function with 5 levels
		var step = int(pos * 5)
		return (step / 4.0 * 2.0 - 1.0) * amplitude
	
	func _exponential_pattern(pos: float) -> float:
		if pos < 0.5:
			return pow(pos * 2.0, 2) * amplitude
		else:
			return (1.0 - pow((pos - 0.5) * 2.0, 2)) * amplitude
	
	func _resonant_pattern(pos: float) -> float:
		# Triple peak resonance pattern - special for 333 mode
		var base = sin(pos * TAU)
		var harmonic1 = sin(pos * TAU * 3.0) * 0.33
		var harmonic2 = sin(pos * TAU * 9.0) * 0.11
		return (base + harmonic1 + harmonic2) * amplitude
	
	func _chaotic_pattern(pos: float) -> float:
		# Pseudo-random but deterministic pattern
		var value = sin(pos * 13.0) * cos(pos * 7.0) * sin(pos * 29.0)
		return value * amplitude
	
	func dampen(factor: float) -> void:
		amplitude *= factor
	
	func restore() -> void:
		amplitude = original_amplitude
	
	func reset() -> void:
		amplitude = original_amplitude
		phase = randf() * 0.5  # Random phase
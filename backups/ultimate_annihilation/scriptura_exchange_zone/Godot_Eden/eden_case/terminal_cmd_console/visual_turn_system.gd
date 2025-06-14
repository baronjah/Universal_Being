extends Node
class_name VisualTurnSystem

"""
VisualTurnSystem: Cross-platform visualization of the turn-based system
Provides graphical representation and status of turns across different
devices including PS5, iPad, and other supported platforms.
"""

# Signal declarations
signal turn_changed(old_turn, new_turn)
signal turn_phase_changed(old_phase, new_phase)
signal turn_visualized(turn_number, platform)
signal platform_connected(platform_name, status)

# Platform constants
const PLATFORMS = {
	"WINDOWS": "Windows",
	"MACOS": "macOS",
	"LINUX": "Linux",
	"PS5": "PlayStation 5",
	"XBOX": "Xbox Series",
	"IOS": "iOS",
	"ANDROID": "Android",
	"WEB": "Web"
}

# Turn constants
const MAX_TURNS = 12
const MAX_PHASES = 5
const PHASE_NAMES = [
	"Preparation",
	"Action",
	"Resolution",
	"Integration",
	"Transition"
]

# Visual representation constants
const TURN_COLORS = [
	Color(0.9, 0.3, 0.3),  # Turn 1 - Red
	Color(0.9, 0.6, 0.2),  # Turn 2 - Orange
	Color(0.9, 0.9, 0.2),  # Turn 3 - Yellow
	Color(0.4, 0.9, 0.3),  # Turn 4 - Green
	Color(0.3, 0.9, 0.8),  # Turn 5 - Teal
	Color(0.3, 0.7, 0.9),  # Turn 6 - Light Blue
	Color(0.3, 0.4, 0.9),  # Turn 7 - Blue
	Color(0.5, 0.3, 0.9),  # Turn 8 - Purple
	Color(0.8, 0.3, 0.9),  # Turn 9 - Magenta
	Color(0.9, 0.3, 0.5),  # Turn 10 - Pink
	Color(0.9, 0.3, 0.3),  # Turn 11 - Red
	Color(1.0, 1.0, 1.0),  # Turn 12 - White
]

# Platform status tracking
var connected_platforms = {}
var platform_visualizers = {}

# Turn system state
var current_turn = 1
var current_phase = 0
var turn_history = []
var turn_start_time = 0
var phase_start_time = 0
var turn_duration = 300  # 5 minutes per turn by default
var phase_durations = [60, 120, 60, 30, 30]  # Default phase durations

# Runtime variables
var visualization_mode = "standard"  # standard, minimal, detailed
var auto_advance = false
var pause_between_turns = true
var current_platform = "WINDOWS"  # Default
var phase_timer

# UI nodes (to be set by parent)
var turn_indicator
var phase_indicator 
var timer_display
var platform_indicators = {}

# Initialization
func _ready():
	_detect_current_platform()
	_initialize_turn_system()
	
	# Create phase timer
	phase_timer = Timer.new()
	phase_timer.wait_time = 1.0
	phase_timer.connect("timeout", Callable(self, "_on_phase_timer_timeout"))
	add_child(phase_timer)
	
	print("Visual Turn System initialized on %s platform" % PLATFORMS[current_platform])
	print("Starting at Turn %d, Phase: %s" % [current_turn, PHASE_NAMES[current_phase]])

# Initialize the turn system
func _initialize_turn_system():
	# Reset state
	current_turn = 1
	current_phase = 0
	turn_history = []
	
	# Record turn start
	turn_start_time = Time.get_unix_time_from_system()
	phase_start_time = turn_start_time
	
	# Add initial turn to history
	turn_history.append({
		"turn": current_turn,
		"phases": [{
			"phase": current_phase,
			"name": PHASE_NAMES[current_phase],
			"start_time": phase_start_time,
			"end_time": 0,
			"duration": phase_durations[current_phase],
			"events": []
		}],
		"start_time": turn_start_time,
		"end_time": 0,
		"platform": current_platform
	})
	
	# Start the phase timer
	phase_timer.wait_time = 1.0
	phase_timer.start()

# Detect the current platform
func _detect_current_platform():
	var os_name = OS.get_name()
	
	match os_name:
		"Windows", "UWP": current_platform = "WINDOWS"
		"macOS": current_platform = "MACOS"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD": current_platform = "LINUX"
		"iOS": current_platform = "IOS"
		"Android": current_platform = "ANDROID"
		"Web": current_platform = "WEB"
		_: current_platform = "WINDOWS"  # Default
	
	# Add to connected platforms
	connected_platforms[current_platform] = {
		"connected": true,
		"connect_time": Time.get_unix_time_from_system(),
		"status": "active"
	}
	
	emit_signal("platform_connected", current_platform, true)

# Register additional platform connections
func register_platform(platform_name, status=true):
	if not platform_name in PLATFORMS.values():
		print("Warning: Unknown platform %s" % platform_name)
		return false
	
	# Find the platform key
	var platform_key = ""
	for key in PLATFORMS:
		if PLATFORMS[key] == platform_name:
			platform_key = key
			break
	
	if platform_key == "":
		return false
	
	connected_platforms[platform_key] = {
		"connected": status,
		"connect_time": Time.get_unix_time_from_system(),
		"status": "active" if status else "disconnected"
	}
	
	emit_signal("platform_connected", platform_key, status)
	print("Platform %s %s" % [platform_name, "connected" if status else "disconnected"])
	
	return true

# Advance to the next phase
func advance_phase():
	var old_phase = current_phase
	
	# Record end time for current phase
	var current_phase_data = turn_history[turn_history.size()-1].phases[current_phase]
	current_phase_data.end_time = Time.get_unix_time_from_system()
	
	# Move to next phase
	current_phase += 1
	
	# Check if we've completed all phases
	if current_phase >= MAX_PHASES:
		advance_turn()
		return
	
	# Record start of new phase
	phase_start_time = Time.get_unix_time_from_system()
	
	turn_history[turn_history.size()-1].phases.append({
		"phase": current_phase,
		"name": PHASE_NAMES[current_phase],
		"start_time": phase_start_time,
		"end_time": 0,
		"duration": phase_durations[current_phase],
		"events": []
	})
	
	emit_signal("turn_phase_changed", old_phase, current_phase)
	print("Advanced to Phase %d: %s" % [current_phase, PHASE_NAMES[current_phase]])
	
	# Update visual display
	_update_visual_display()

# Advance to the next turn
func advance_turn():
	var old_turn = current_turn
	
	# Record end time for current turn
	turn_history[turn_history.size()-1].end_time = Time.get_unix_time_from_system()
	
	# Move to next turn
	current_turn += 1
	current_phase = 0
	
	# Handle turn wrap-around
	if current_turn > MAX_TURNS:
		current_turn = 1
		print("Completed full turn cycle, starting again at Turn 1")
	
	# Record start of new turn
	turn_start_time = Time.get_unix_time_from_system()
	phase_start_time = turn_start_time
	
	# Add new turn to history
	turn_history.append({
		"turn": current_turn,
		"phases": [{
			"phase": current_phase,
			"name": PHASE_NAMES[current_phase],
			"start_time": phase_start_time,
			"end_time": 0,
			"duration": phase_durations[current_phase],
			"events": []
		}],
		"start_time": turn_start_time,
		"end_time": 0,
		"platform": current_platform
	})
	
	emit_signal("turn_changed", old_turn, current_turn)
	print("Advanced to Turn %d, Phase %d: %s" % [current_turn, current_phase, PHASE_NAMES[current_phase]])
	
	# Update visual display
	_update_visual_display()
	
	# Visualize turn on all connected platforms
	_visualize_turn_on_platforms()

# Add an event to the current phase
func add_event(event_data):
	var current_turn_data = turn_history[turn_history.size()-1]
	var current_phase_data = current_turn_data.phases[current_phase]
	
	current_phase_data.events.append({
		"timestamp": Time.get_unix_time_from_system(),
		"data": event_data
	})
	
	print("Event added to Turn %d, Phase %d" % [current_turn, current_phase])

# Set the turn duration
func set_turn_duration(seconds):
	turn_duration = seconds
	print("Turn duration set to %d seconds" % seconds)

# Set phase durations
func set_phase_durations(durations):
	if durations.size() != MAX_PHASES:
		print("Error: Phase durations array must have %d elements" % MAX_PHASES)
		return false
	
	phase_durations = durations
	print("Phase durations updated")
	return true

# Toggle auto-advance
func toggle_auto_advance(enabled=null):
	if enabled != null:
		auto_advance = enabled
	else:
		auto_advance = !auto_advance
		
	print("Auto-advance %s" % ("enabled" if auto_advance else "disabled"))
	return auto_advance

# Set the visualization mode
func set_visualization_mode(mode):
	if mode in ["standard", "minimal", "detailed"]:
		visualization_mode = mode
		_update_visual_display()
		print("Visualization mode set to %s" % mode)
		return true
	else:
		print("Error: Unknown visualization mode %s" % mode)
		return false

# Update the visual display
func _update_visual_display():
	if turn_indicator:
		turn_indicator.text = "Turn %d/%d" % [current_turn, MAX_TURNS]
		turn_indicator.modulate = TURN_COLORS[current_turn - 1]
	
	if phase_indicator:
		phase_indicator.text = "Phase: %s" % PHASE_NAMES[current_phase]
		
		# Set progress based on phase
		var phase_progress = float(current_phase) / MAX_PHASES
		if phase_indicator.has_method("set_value"):
			phase_indicator.set_value(phase_progress * 100)
	
	if timer_display:
		var elapsed = Time.get_unix_time_from_system() - phase_start_time
		var remaining = phase_durations[current_phase] - elapsed
		
		if remaining < 0:
			remaining = 0
			
		var minutes = int(remaining) / 60
		var seconds = int(remaining) % 60
		
		timer_display.text = "%02d:%02d" % [minutes, seconds]

# Visualize the current turn on all connected platforms
func _visualize_turn_on_platforms():
	for platform in connected_platforms:
		if connected_platforms[platform].connected:
			_visualize_turn_on_platform(platform)

# Visualize the current turn on a specific platform
func _visualize_turn_on_platform(platform):
	if not platform in connected_platforms or not connected_platforms[platform].connected:
		return
	
	print("Visualizing Turn %d on %s platform" % [current_turn, PLATFORMS[platform]])
	
	# Create platform-specific visualization
	var visualization = {
		"turn": current_turn,
		"phase": current_phase,
		"color": TURN_COLORS[current_turn - 1],
		"time_remaining": phase_durations[current_phase],
		"platform": platform,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Store visualization for platform
	platform_visualizers[platform] = visualization
	
	emit_signal("turn_visualized", current_turn, platform)
	
	# Update platform indicators
	if platform in platform_indicators:
		platform_indicators[platform].modulate = TURN_COLORS[current_turn - 1]

# Phase timer timeout handler
func _on_phase_timer_timeout():
	# Update display
	_update_visual_display()
	
	# Check if phase should auto-advance
	if auto_advance:
		var elapsed = Time.get_unix_time_from_system() - phase_start_time
		
		if elapsed >= phase_durations[current_phase]:
			advance_phase()

# Get a summary of the current turn state
func get_turn_summary():
	return {
		"turn": current_turn,
		"phase": current_phase,
		"phase_name": PHASE_NAMES[current_phase],
		"time_elapsed": Time.get_unix_time_from_system() - turn_start_time,
		"phase_elapsed": Time.get_unix_time_from_system() - phase_start_time,
		"connected_platforms": connected_platforms.keys(),
		"auto_advance": auto_advance,
		"visualization_mode": visualization_mode
	}

# Export turn history to a file
func export_turn_history(file_path):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(turn_history, "  "))
		file.close()
		print("Turn history exported to %s" % file_path)
		return true
	else:
		print("Error: Could not open file %s for writing" % file_path)
		return false

# Connect to PS5 controller
func connect_ps5_controller():
	# This would be implemented with actual controller detection
	# For now, just simulate the connection
	register_platform("PlayStation 5")
	
	print("PS5 controller connected")
	return true

# Connect to iOS device
func connect_ios_device(device_name="iPad"):
	# This would be implemented with actual device detection
	# For now, just simulate the connection
	register_platform("iOS")
	
	print("iOS device '%s' connected" % device_name)
	return true

# Create a symbolic visual representation of the current turn
func create_symbolic_representation():
	var symbol = ""
	
	# Get base symbol for the current turn
	var turn_symbols = ["⚯", "⬡", "⚹", "♦", "∞", "△", "◇", "⚛", "⟡", "⦿", "⧉", "✧"]
	symbol = turn_symbols[current_turn - 1]
	
	# Add phase indicator
	var phase_indicators = ["·", "··", "···", "····", "·····"]
	symbol += phase_indicators[current_phase]
	
	# Add color information as RGB hex
	var color = TURN_COLORS[current_turn - 1]
	var color_hex = "%02X%02X%02X" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]
	
	return {
		"symbol": symbol,
		"color_hex": color_hex,
		"turn": current_turn,
		"phase": current_phase
	}

# Create an interactive turn wheel visualization
func create_turn_wheel():
	# This would create the visual turn wheel
	# For this proof of concept, we'll just return the configuration
	
	var wheel_config = {
		"current_turn": current_turn,
		"turns": [],
		"center_symbol": "◉",
		"radius": 120,
		"background_color": Color(0.1, 0.1, 0.15),
		"highlight_color": TURN_COLORS[current_turn - 1]
	}
	
	# Configure each turn on the wheel
	for i in range(1, MAX_TURNS + 1):
		wheel_config.turns.append({
			"position": i,
			"symbol": ["⚯", "⬡", "⚹", "♦", "∞", "△", "◇", "⚛", "⟡", "⦿", "⧉", "✧"][i-1],
			"color": TURN_COLORS[i-1],
			"angle": (i-1) * (360.0 / MAX_TURNS),
			"active": i == current_turn
		})
	
	print("Turn wheel visualization created")
	return wheel_config
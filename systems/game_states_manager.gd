# GAME STATES MANAGER - UNIVERSAL BEING STATE ORCHESTRATION
# Tracks all interface states, input modes, and system interactions
extends Node
class_name GameStatesManager

signal state_changed(category: String, old_state: String, new_state: String)
signal interface_toggled(interface_name: String, is_active: bool)
signal input_mode_changed(old_mode: String, new_mode: String)

# State categories
enum StateCategory {
	INTERFACE,
	INPUT,
	GAME_MODE,
	CONSCIOUSNESS,
	DEBUG
}

# Interface states
enum InterfaceState {
	MINIMIZED,
	EXPANDED,
	FULLSCREEN,
	FLOATING,
	HIDDEN
}

# Input modes
enum InputMode {
	NORMAL_3D,
	CONSOLE_INPUT,
	TEXT_EDITING,
	DEBUG_NAVIGATION,
	COSMIC_FLIGHT
}

# Game modes
enum GameMode {
	EXPLORATION,
	PROGRAMMING,
	DEBUG_CHAMBER,
	CONSOLE_WORK,
	MEDITATION
}

# Current states
var current_states: Dictionary = {}
var active_interfaces: Dictionary = {}
var input_history: Array = []
var state_history: Array = []

# Interface references
var console_3d_ref: Node3D = null
var text_editor_ref: Node3D = null
var cursor_3d_ref: Node3D = null
var debug_chamber_ref: Node3D = null

func _ready():
	print("🔄 Game States Manager: Initializing universal state tracking...")
	initialize_default_states()
	setup_state_monitoring()
	print("✅ Game States Manager: Ready to track all universal states!")

func initialize_default_states():
	"""Initialize all default states"""
	# Interface states
	current_states["console_3d"] = "minimized"
	current_states["text_editor"] = "hidden"
	current_states["cursor_system"] = "normal"
	current_states["debug_chamber"] = "hidden"
	
	# Input states
	current_states["input_mode"] = "normal_3d"
	current_states["mouse_mode"] = str(Input.MOUSE_MODE_CAPTURED)
	current_states["keyboard_focus"] = "game"
	
	# Game states
	current_states["game_mode"] = "exploration"
	current_states["consciousness_level"] = "1"
	current_states["debug_active"] = "false"
	
	# Interface activity tracking
	active_interfaces["console_3d"] = false
	active_interfaces["text_editor"] = false
	active_interfaces["cursor_system"] = true
	active_interfaces["debug_chamber"] = false

func setup_state_monitoring():
	"""Setup automatic state monitoring"""
	# Monitor input changes
	var input_timer = Timer.new()
	input_timer.wait_time = 0.1
	input_timer.timeout.connect(_monitor_input_changes)
	add_child(input_timer)
	input_timer.start()

func _monitor_input_changes():
	"""Monitor and track input state changes"""
	var current_mouse_mode = str(Input.mouse_mode)
	if current_states.get("mouse_mode", "") != current_mouse_mode:
		var old_mode = current_states.get("mouse_mode", "")
		current_states["mouse_mode"] = current_mouse_mode
		state_changed.emit("input", old_mode, current_mouse_mode)
		
		# Determine keyboard focus based on mouse mode
		var keyboard_focus = "console" if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else "game"
		if current_states.get("keyboard_focus", "") != keyboard_focus:
			var old_focus = current_states.get("keyboard_focus", "")
			current_states["keyboard_focus"] = keyboard_focus
			state_changed.emit("input", old_focus, keyboard_focus)

# Interface State Management
func set_interface_state(interface_name: String, new_state: String):
	"""Set interface state and track changes"""
	var old_state = current_states.get(interface_name, "unknown")
	current_states[interface_name] = new_state
	
	# Update active status
	active_interfaces[interface_name] = (new_state != "hidden" and new_state != "minimized")
	
	state_changed.emit("interface", old_state, new_state)
	interface_toggled.emit(interface_name, active_interfaces[interface_name])
	
	print("🔄 Interface '%s': %s → %s" % [interface_name, old_state, new_state])

func get_interface_state(interface_name: String) -> String:
	"""Get current interface state"""
	return current_states.get(interface_name, "unknown")

func is_interface_active(interface_name: String) -> bool:
	"""Check if interface is currently active"""
	return active_interfaces.get(interface_name, false)

# Input Mode Management
func set_input_mode(new_mode: String):
	"""Set input mode and track changes"""
	var old_mode = current_states.get("input_mode", "unknown")
	current_states["input_mode"] = new_mode
	
	input_mode_changed.emit(old_mode, new_mode)
	state_changed.emit("input", old_mode, new_mode)
	
	print("⌨️ Input Mode: %s → %s" % [old_mode, new_mode])

func get_input_mode() -> String:
	"""Get current input mode"""
	return current_states.get("input_mode", "normal_3d")

# Game Mode Management
func set_game_mode(new_mode: String):
	"""Set game mode and track changes"""
	var old_mode = current_states.get("game_mode", "unknown")
	current_states["game_mode"] = new_mode
	
	state_changed.emit("game_mode", old_mode, new_mode)
	print("🎮 Game Mode: %s → %s" % [old_mode, new_mode])

func get_game_mode() -> String:
	"""Get current game mode"""
	return current_states.get("game_mode", "exploration")

# Console State Management
func toggle_console():
	"""Toggle console interface state"""
	var current = get_interface_state("console_3d")
	match current:
		"minimized", "hidden":
			set_interface_state("console_3d", "expanded")
			set_input_mode("console_input")
		"expanded":
			set_interface_state("console_3d", "fullscreen")
		"fullscreen":
			set_interface_state("console_3d", "minimized")
			set_input_mode("normal_3d")

func show_console():
	"""Show console interface"""
	set_interface_state("console_3d", "expanded")
	set_input_mode("console_input")

func hide_console():
	"""Hide console interface"""
	set_interface_state("console_3d", "hidden")
	if get_input_mode() == "console_input":
		set_input_mode("normal_3d")

# Text Editor State Management
func toggle_text_editor():
	"""Toggle text editor interface"""
	var current = get_interface_state("text_editor")
	if current == "hidden" or current == "minimized":
		set_interface_state("text_editor", "expanded")
		set_input_mode("text_editing")
	else:
		set_interface_state("text_editor", "hidden")
		if get_input_mode() == "text_editing":
			set_input_mode("normal_3d")

func show_text_editor():
	"""Show text editor interface"""
	set_interface_state("text_editor", "expanded")
	set_input_mode("text_editing")

func hide_text_editor():
	"""Hide text editor interface"""
	set_interface_state("text_editor", "hidden")
	if get_input_mode() == "text_editing":
		set_input_mode("normal_3d")

# Debug Chamber State Management
func toggle_debug_chamber():
	"""Toggle debug chamber interface"""
	var current = get_interface_state("debug_chamber")
	if current == "hidden":
		set_interface_state("debug_chamber", "expanded")
		set_game_mode("debug_chamber")
		set_input_mode("debug_navigation")
	else:
		set_interface_state("debug_chamber", "hidden")
		set_game_mode("exploration")
		set_input_mode("normal_3d")

func show_debug_chamber():
	"""Show debug chamber"""
	set_interface_state("debug_chamber", "expanded")
	set_game_mode("debug_chamber")
	set_input_mode("debug_navigation")

func hide_debug_chamber():
	"""Hide debug chamber"""
	set_interface_state("debug_chamber", "hidden")
	set_game_mode("exploration")
	set_input_mode("normal_3d")

# Cursor System State Management
func set_cursor_state(new_state: String):
	"""Set cursor system state"""
	set_interface_state("cursor_system", new_state)

func toggle_cursor_visibility():
	"""Toggle cursor visibility"""
	var current = get_interface_state("cursor_system")
	if current == "hidden":
		set_cursor_state("normal")
	else:
		set_cursor_state("hidden")

# State History and Analytics
func log_state_change(category: String, old_state: String, new_state: String):
	"""Log state change for analytics"""
	var log_entry = {
		"timestamp": Time.get_ticks_msec(),
		"category": category,
		"old_state": old_state,
		"new_state": new_state
	}
	state_history.append(log_entry)
	
	# Limit history size
	if state_history.size() > 1000:
		state_history = state_history.slice(-500)

func get_state_summary() -> Dictionary:
	"""Get comprehensive state summary"""
	return {
		"interfaces": {
			"console_3d": get_interface_state("console_3d"),
			"text_editor": get_interface_state("text_editor"),
			"cursor_system": get_interface_state("cursor_system"),
			"debug_chamber": get_interface_state("debug_chamber")
		},
		"input": {
			"mode": get_input_mode(),
			"mouse_mode": current_states.get("mouse_mode", "unknown"),
			"keyboard_focus": current_states.get("keyboard_focus", "unknown")
		},
		"game": {
			"mode": get_game_mode(),
			"consciousness_level": current_states.get("consciousness_level", "1"),
			"debug_active": current_states.get("debug_active", "false")
		},
		"active_interfaces": active_interfaces,
		"history_entries": state_history.size()
	}

func get_formatted_state_report() -> String:
	"""Get formatted state report for console display"""
	var summary = get_state_summary()
	var report = "🔄 UNIVERSAL BEING STATES:\n\n"
	
	# Interface states
	report += "INTERFACES:\n"
	for interface in summary.interfaces.keys():
		var state = summary.interfaces[interface]
		var active = "✅" if active_interfaces.get(interface, false) else "⭕"
		report += "  %s %s: %s\n" % [active, interface.capitalize(), state]
	
	# Input states
	report += "\nINPUT:\n"
	for input_key in summary.input.keys():
		var value = summary.input[input_key]
		report += "  • %s: %s\n" % [input_key.capitalize(), value]
	
	# Game states
	report += "\nGAME:\n"
	for game_key in summary.game.keys():
		var value = summary.game[game_key]
		report += "  • %s: %s\n" % [game_key.capitalize(), value]
	
	report += "\n📊 State History: %d entries\n" % summary.history_entries
	
	return report

# Interface Registration
func register_interface(interface_name: String, interface_node: Node3D):
	"""Register interface for state tracking"""
	match interface_name:
		"console_3d":
			console_3d_ref = interface_node
		"text_editor":
			text_editor_ref = interface_node
		"cursor_system":
			cursor_3d_ref = interface_node
		"debug_chamber":
			debug_chamber_ref = interface_node
	
	print("📝 Registered interface: " + interface_name)

# Quick Access Functions
func is_console_active() -> bool:
	return is_interface_active("console_3d")

func is_text_editor_active() -> bool:
	return is_interface_active("text_editor")

func is_debug_chamber_active() -> bool:
	return is_interface_active("debug_chamber")

func is_in_programming_mode() -> bool:
	var mode = get_game_mode()
	return mode == "programming" or mode == "debug_chamber"

func is_input_captured() -> bool:
	var mode = get_input_mode()
	return mode == "console_input" or mode == "text_editing"

# Public API for external systems
func request_console():
	"""External request to show console"""
	show_console()

func request_text_editor():
	"""External request to show text editor"""
	show_text_editor()

func request_debug_chamber():
	"""External request to show debug chamber"""
	show_debug_chamber()

func request_normal_mode():
	"""External request to return to normal mode"""
	hide_console()
	hide_text_editor()
	hide_debug_chamber()
	set_input_mode("normal_3d")
	set_game_mode("exploration")
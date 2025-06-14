extends Node
class_name UniversalInputManager

## UNIVERSAL INPUT MANAGER - Single point of entry for all inputs
## Filters by game state and routes to appropriate handlers
## Star language programming - direct, efficient, perfect

signal input_filtered(input_data: Dictionary)
signal state_transition(old_state: String, new_state: String)

enum GameState {
	NAVIGATION,     # Moving around 3D space
	TEXT_EDITING,   # Editing text with arrow keys
	CONSOLE,        # Console interface active
	CREATION,       # Creating/spawning beings
	INSPECTION,     # Inspecting Universal Beings
	GRAB_MODE,      # Moving objects with mouse
	SOCKET_MODE,    # Connecting sockets
	MENU_MODE       # UI menus open
}

var current_state: GameState = GameState.NAVIGATION
var input_handlers: Dictionary = {}
var state_stack: Array[GameState] = []
var input_buffer: Array[Dictionary] = []

# State filters - what inputs are allowed in each state
var state_input_filters: Dictionary = {
	GameState.NAVIGATION: ["movement", "mouse_look", "interaction", "mode_switch"],
	GameState.TEXT_EDITING: ["text_input", "arrow_navigation", "text_commands"],
	GameState.CONSOLE: ["console_input", "console_navigation", "console_commands"],
	GameState.CREATION: ["creation_input", "placement", "spawn_commands"],
	GameState.INSPECTION: ["inspection_navigation", "property_editing"],
	GameState.GRAB_MODE: ["grab_movement", "grab_placement"],
	GameState.SOCKET_MODE: ["socket_targeting", "connection_commands"],
	GameState.MENU_MODE: ["menu_navigation", "menu_selection"]
}

func _ready() -> void:
	add_to_group("universal_input_manager")
	setup_input_handlers()
	set_process_unhandled_input(true)
	print("🧠 Universal Input Manager - Consciousness input foundation active")

func _unhandled_input(event: InputEvent) -> void:
	# SINGLE ENTRY POINT - all inputs come here first
	var input_data = parse_input_event(event)
	
	# Filter by current game state
	if is_input_allowed(input_data):
		route_input(input_data)
	else:
		buffer_input(input_data)

func parse_input_event(event: InputEvent) -> Dictionary:
	"""Convert input event to universal data format"""
	var input_data = {
		"type": "",
		"category": "",
		"keycode": 0,
		"unicode": 0,
		"mouse_position": Vector2.ZERO,
		"mouse_relative": Vector2.ZERO,
		"pressed": false,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	if event is InputEventKey:
		input_data.type = "key"
		input_data.keycode = event.keycode
		input_data.unicode = event.unicode
		input_data.pressed = event.pressed
		input_data.category = get_key_category(event.keycode)
		
	elif event is InputEventMouseButton:
		input_data.type = "mouse_button"
		input_data.keycode = event.button_index
		input_data.mouse_position = event.position
		input_data.pressed = event.pressed
		input_data.category = "mouse_click"
		
	elif event is InputEventMouseMotion:
		input_data.type = "mouse_motion"
		input_data.mouse_position = event.position
		input_data.mouse_relative = event.relative
		input_data.category = "mouse_look"
	
	return input_data

func get_key_category(keycode: int) -> String:
	"""Categorize key input for state filtering"""
	match keycode:
		KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_SHIFT:
			return "movement"
		KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN:
			return "arrow_navigation"
		KEY_E, KEY_F, KEY_G, KEY_R:
			return "interaction"
		KEY_T, KEY_I, KEY_C, KEY_QUOTELEFT:
			return "mode_switch"
		KEY_ENTER, KEY_ESCAPE, KEY_TAB:
			return "universal_commands"
		KEY_BACKSPACE, KEY_DELETE:
			return "text_commands"
		_:
			if keycode >= 32 and keycode <= 126:
				return "text_input"
			else:
				return "unknown"

func is_input_allowed(input_data: Dictionary) -> bool:
	"""Check if input is allowed in current state"""
	var allowed_categories = state_input_filters.get(current_state, [])
	
	# Universal commands always allowed
	if input_data.category == "universal_commands":
		return true
	
	return input_data.category in allowed_categories

func route_input(input_data: Dictionary) -> void:
	"""Route input to appropriate handler based on current state"""
	var handler = input_handlers.get(current_state)
	if handler and handler.has_method("handle_input"):
		handler.handle_input(input_data)
	
	# Emit for other systems to listen
	input_filtered.emit(input_data)
	
	# Check for state transitions
	check_state_transitions(input_data)

func check_state_transitions(input_data: Dictionary) -> void:
	"""Check if input should trigger state transition"""
	if input_data.type == "key" and input_data.pressed:
		match input_data.keycode:
			KEY_ESCAPE:
				handle_escape_key()
			KEY_T:
				transition_to_state(GameState.TEXT_EDITING)
			KEY_QUOTELEFT:
				transition_to_state(GameState.CONSOLE)
			KEY_I:
				transition_to_state(GameState.INSPECTION)
			KEY_C:
				transition_to_state(GameState.CREATION)
			KEY_G:
				transition_to_state(GameState.GRAB_MODE)

func handle_escape_key() -> void:
	"""Universal escape - return to navigation or previous state"""
	if state_stack.size() > 0:
		var previous_state = state_stack.pop_back()
		transition_to_state(previous_state)
	else:
		transition_to_state(GameState.NAVIGATION)

func transition_to_state(new_state: GameState) -> void:
	"""Change game state with proper cleanup"""
	if new_state == current_state:
		return
	
	var old_state = current_state
	
	# Push current state to stack if not navigation
	if current_state != GameState.NAVIGATION:
		state_stack.push_back(current_state)
	
	# Cleanup old state
	cleanup_state(old_state)
	
	# Set new state
	current_state = new_state
	
	# Initialize new state
	initialize_state(new_state)
	
	# Emit transition signal
	state_transition.emit(GameState.keys()[old_state], GameState.keys()[new_state])
	
	# Process buffered inputs if any are now valid
	process_buffered_inputs()

func cleanup_state(state: GameState) -> void:
	"""Cleanup when leaving a state"""
	var handler = input_handlers.get(state)
	if handler and handler.has_method("cleanup"):
		handler.cleanup()

func initialize_state(state: GameState) -> void:
	"""Initialize when entering a state"""
	var handler = input_handlers.get(state)
	if handler and handler.has_method("initialize"):
		handler.initialize()

func buffer_input(input_data: Dictionary) -> void:
	"""Buffer input that's not allowed in current state"""
	input_buffer.append(input_data)
	
	# Keep buffer size reasonable
	if input_buffer.size() > 10:
		input_buffer.pop_front()

func process_buffered_inputs() -> void:
	"""Process buffered inputs that may now be valid"""
	var processed_inputs = []
	
	for input_data in input_buffer:
		if is_input_allowed(input_data):
			route_input(input_data)
			processed_inputs.append(input_data)
	
	# Remove processed inputs from buffer
	for processed in processed_inputs:
		input_buffer.erase(processed)

func setup_input_handlers() -> void:
	"""Setup handlers for each game state"""
	# Handlers will be registered by systems that need them
	pass

func register_input_handler(state: GameState, handler: Node) -> void:
	"""Register an input handler for a specific state"""
	input_handlers[state] = handler

func get_current_state() -> GameState:
	"""Get current game state"""
	return current_state

func get_state_name() -> String:
	"""Get current state name as string"""
	return GameState.keys()[current_state]

func force_state(state: GameState) -> void:
	"""Force state change without stack management"""
	var old_state = current_state
	current_state = state
	state_transition.emit(GameState.keys()[old_state], GameState.keys()[state])

func clear_state_stack() -> void:
	"""Clear the state stack"""
	state_stack.clear()

func push_state(state: GameState) -> void:
	"""Push current state and transition to new one"""
	state_stack.push_back(current_state)
	transition_to_state(state)

func pop_state() -> void:
	"""Return to previous state in stack"""
	if state_stack.size() > 0:
		var previous_state = state_stack.pop_back()
		transition_to_state(previous_state)
	else:
		transition_to_state(GameState.NAVIGATION)
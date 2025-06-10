# ==================================================
# INPUT STATE MANAGER - Universal Being Input Surgery
# Surgeon: Claude Code (Architect Role)
# Patient: Star Navigation Game
# Purpose: Route all input through context-aware state system
# ==================================================

extends Node
class_name InputStateManager

# ===== INPUT CONTEXT SYSTEM =====

enum InputContext {
	PLASMOID_FREE_FLIGHT,     # WASD=move, mouse=camera, tab=inventory  
	PLASMOID_SOCKET_INVENTORY, # tab=close, mouse=free, drag&drop
	PLASMOID_CONSOLE_ACTIVE,   # backtick=close, keyboard=typing
	PLASMOID_MOUNTED_MECHA,    # F=dismount, different WASD behavior
	STAR_NAVIGATION_MODE,      # Special context for touching stars
	CINEMATIC_CUTSCENE        # No input except ESC
}

enum MouseMode {
	FREE_CURSOR,      # Mouse visible, can click UI
	CAMERA_CAPTURED   # Mouse captured for camera control
}

# ===== STATE VARIABLES =====

var current_context: InputContext = InputContext.PLASMOID_FREE_FLIGHT
var current_mouse_mode: MouseMode = MouseMode.FREE_CURSOR
var context_history: Array[InputContext] = []

# References to systems that need input
var trackball_camera: Camera3D = null
var plasmoid_player: Node = null  
var console_system: Node = null
var inventory_system: Node = null

# ===== SIGNALS =====

signal context_changed(old_context: InputContext, new_context: InputContext)
signal mouse_mode_changed(old_mode: MouseMode, new_mode: MouseMode)
signal input_routed(context: InputContext, event: InputEvent)

# ===== INPUT ROUTING CORE =====

func _ready() -> void:
	print("🎮 InputStateManager: Surgical implantation successful")
	
	# Set input processing priority
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	
	# Connect to universal systems
	call_deferred("_connect_to_systems")

func _connect_to_systems() -> void:
	"""Connect to trackball camera and other input systems"""
	# Find trackball camera
	var camera_nodes = get_tree().get_nodes_in_group("trackball_camera")
	if camera_nodes.size() > 0:
		trackball_camera = camera_nodes[0]
		print("🎥 Connected to trackball camera")
	
	# Find plasmoid player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		plasmoid_player = player_nodes[0]
		print("⚡ Connected to plasmoid player")
	
	# Find console system
	var console_nodes = get_tree().get_nodes_in_group("console")
	if console_nodes.size() > 0:
		console_system = console_nodes[0]
		print("🖥️ Connected to console system")

func _input(event: InputEvent) -> void:
	"""MAIN INPUT ROUTER - All input flows through here"""
	
	# PRIORITY 1: Universal emergency controls
	if _handle_emergency_input(event):
		get_viewport().set_input_as_handled()
		return
	
	# PRIORITY 2: Context-specific input routing
	match current_context:
		InputContext.PLASMOID_FREE_FLIGHT:
			_handle_free_flight_input(event)
		InputContext.PLASMOID_SOCKET_INVENTORY:
			_handle_inventory_input(event)
		InputContext.PLASMOID_CONSOLE_ACTIVE:
			_handle_console_input(event)
		InputContext.PLASMOID_MOUNTED_MECHA:
			_handle_mecha_input(event)
		InputContext.STAR_NAVIGATION_MODE:
			_handle_star_navigation_input(event)
		InputContext.CINEMATIC_CUTSCENE:
			_handle_cinematic_input(event)
	
	# Emit input routing signal for debugging
	input_routed.emit(current_context, event)

# ===== EMERGENCY INPUT HANDLING =====

func _handle_emergency_input(event: InputEvent) -> bool:
	"""Handle emergency inputs that work in ALL contexts"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_handle_emergency_escape()
				return true
			KEY_QUOTELEFT:  # Backtick - console toggle
				_toggle_console()
				return true
	
	return false

func _handle_emergency_escape() -> void:
	"""Emergency escape - return to safe state"""
	print("🚨 Emergency escape activated")
	
	# Always release mouse capture
	if current_mouse_mode == MouseMode.CAMERA_CAPTURED:
		_set_mouse_mode(MouseMode.FREE_CURSOR)
	
	# Return to appropriate context
	if current_context == InputContext.PLASMOID_CONSOLE_ACTIVE:
		_set_context(InputContext.PLASMOID_FREE_FLIGHT)
	elif current_context == InputContext.PLASMOID_SOCKET_INVENTORY:
		_set_context(InputContext.PLASMOID_FREE_FLIGHT)
	# Other contexts stay as-is but get mouse released

func _toggle_console() -> void:
	"""Toggle console context"""
	if current_context == InputContext.PLASMOID_CONSOLE_ACTIVE:
		_set_context(InputContext.PLASMOID_FREE_FLIGHT)
		print("🖥️ Console closed via backtick")
	else:
		_set_context(InputContext.PLASMOID_CONSOLE_ACTIVE)
		print("🖥️ Console opened via backtick")
	
	# Notify console system
	if console_system and console_system.has_method("toggle_console"):
		console_system.toggle_console()

# ===== CONTEXT-SPECIFIC INPUT HANDLERS =====

func _handle_free_flight_input(event: InputEvent) -> void:
	"""Handle input during free plasmoid flight"""
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_TAB:
				_set_context(InputContext.PLASMOID_SOCKET_INVENTORY)
				return
			KEY_R:
				if event.ctrl_pressed:
					_trigger_consciousness_revolution()
					return
			KEY_S:
				if event.ctrl_pressed:
					_activate_star_navigation()
					return
	
	# Mouse mode switching
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right-click toggles mouse capture
			if current_mouse_mode == MouseMode.FREE_CURSOR:
				_set_mouse_mode(MouseMode.CAMERA_CAPTURED)
			else:
				_set_mouse_mode(MouseMode.FREE_CURSOR)
			return
	
	# Route movement to plasmoid
	if _is_movement_input(event) and plasmoid_player:
		if plasmoid_player.has_method("_input"):
			plasmoid_player._input(event)
	
	# Route camera input if mouse is captured
	if current_mouse_mode == MouseMode.CAMERA_CAPTURED and trackball_camera:
		if trackball_camera.has_method("input"):
			trackball_camera.input(event)

func _handle_inventory_input(event: InputEvent) -> void:
	"""Handle input during socket inventory mode"""
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			_set_context(InputContext.PLASMOID_FREE_FLIGHT)
			return
	
	# Mouse is always free in inventory mode
	if current_mouse_mode != MouseMode.FREE_CURSOR:
		_set_mouse_mode(MouseMode.FREE_CURSOR)
	
	# Route to inventory system
	if inventory_system and inventory_system.has_method("handle_input"):
		inventory_system.handle_input(event)

func _handle_console_input(event: InputEvent) -> void:
	"""Handle input during console mode"""
	
	# Mouse is always free in console mode
	if current_mouse_mode != MouseMode.FREE_CURSOR:
		_set_mouse_mode(MouseMode.FREE_CURSOR)
	
	# Route everything to console except emergency keys
	if console_system and console_system.has_method("_input"):
		console_system._input(event)

func _handle_mecha_input(event: InputEvent) -> void:
	"""Handle input when mounted in mecha"""
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			_dismount_from_mecha()
			return
	
	# Route to mecha controller (when implemented)
	print("🤖 Mecha input: %s" % event)

func _handle_star_navigation_input(event: InputEvent) -> void:
	"""Handle input during star navigation"""
	
	# Route movement and camera normally
	_handle_free_flight_input(event)

func _handle_cinematic_input(event: InputEvent) -> void:
	"""Handle input during cutscenes - very limited"""
	
	# Only allow emergency escape and skip
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_skip_cinematic()

# ===== CONTEXT MANAGEMENT =====

func _set_context(new_context: InputContext) -> void:
	"""Change input context with proper cleanup"""
	var old_context = current_context
	
	# Add to history
	if context_history.size() > 10:
		context_history.pop_front()
	context_history.append(old_context)
	
	current_context = new_context
	
	# Context-specific setup
	match new_context:
		InputContext.PLASMOID_SOCKET_INVENTORY:
			_set_mouse_mode(MouseMode.FREE_CURSOR)
			_open_socket_inventory()
		InputContext.PLASMOID_CONSOLE_ACTIVE:
			_set_mouse_mode(MouseMode.FREE_CURSOR)
		InputContext.STAR_NAVIGATION_MODE:
			# Mouse can be either mode in star navigation
			pass
	
	context_changed.emit(old_context, new_context)
	print("🎮 Context changed: %s → %s" % [_context_to_string(old_context), _context_to_string(new_context)])

func _set_mouse_mode(new_mode: MouseMode) -> void:
	"""Change mouse mode with proper cursor management"""
	var old_mode = current_mouse_mode
	current_mouse_mode = new_mode
	
	match new_mode:
		MouseMode.FREE_CURSOR:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MouseMode.CAMERA_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	mouse_mode_changed.emit(old_mode, new_mode)
	print("🖱️ Mouse mode: %s → %s" % [_mouse_mode_to_string(old_mode), _mouse_mode_to_string(new_mode)])

# ===== UTILITY FUNCTIONS =====

func _is_movement_input(event: InputEvent) -> bool:
	"""Check if event is movement-related"""
	if event is InputEventKey:
		return event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_SHIFT]
	return false

func _context_to_string(context: InputContext) -> String:
	match context:
		InputContext.PLASMOID_FREE_FLIGHT: return "FREE_FLIGHT"
		InputContext.PLASMOID_SOCKET_INVENTORY: return "INVENTORY"
		InputContext.PLASMOID_CONSOLE_ACTIVE: return "CONSOLE"
		InputContext.PLASMOID_MOUNTED_MECHA: return "MECHA"
		InputContext.STAR_NAVIGATION_MODE: return "STAR_NAV"
		InputContext.CINEMATIC_CUTSCENE: return "CINEMATIC"
		_: return "UNKNOWN"

func _mouse_mode_to_string(mode: MouseMode) -> String:
	match mode:
		MouseMode.FREE_CURSOR: return "FREE"
		MouseMode.CAMERA_CAPTURED: return "CAPTURED"
		_: return "UNKNOWN"

# ===== GAME SYSTEM INTEGRATIONS =====

func _trigger_consciousness_revolution() -> void:
	"""Trigger Ctrl+R revolution command"""
	if console_system and console_system.has_method("trigger_consciousness_revolution"):
		console_system.trigger_consciousness_revolution()
		print("🌟 Consciousness revolution triggered via Ctrl+R")

func _activate_star_navigation() -> void:
	"""Trigger Ctrl+S star navigation"""
	if console_system and console_system.has_method("activate_star_navigation"):
		console_system.activate_star_navigation()
		_set_context(InputContext.STAR_NAVIGATION_MODE)
		print("⭐ Star navigation activated via Ctrl+S")

func _open_socket_inventory() -> void:
	"""Open socket inventory UI"""
	print("🎒 Socket inventory opened via Tab")
	# TODO: Create actual inventory UI

func _dismount_from_mecha() -> void:
	"""Dismount from mecha body"""
	_set_context(InputContext.PLASMOID_FREE_FLIGHT)
	print("🤖 Dismounted from mecha via F")

func _skip_cinematic() -> void:
	"""Skip cinematic cutscene"""
	_set_context(InputContext.PLASMOID_FREE_FLIGHT)
	print("🎬 Cinematic skipped via Space")

# ===== PUBLIC API =====

func get_current_context() -> InputContext:
	return current_context

func get_current_mouse_mode() -> MouseMode:
	return current_mouse_mode

func force_context(context: InputContext) -> void:
	"""Force context change (for external systems)"""
	_set_context(context)

func force_mouse_mode(mode: MouseMode) -> void:
	"""Force mouse mode change (for external systems)"""
	_set_mouse_mode(mode)
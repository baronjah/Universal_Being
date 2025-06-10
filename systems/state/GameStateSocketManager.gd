# ==================================================
# CORE: Game State Socket Manager
# TYPE: Universal Game State System
# PURPOSE: Socket-based state management for entire game
# ARCHITECTURE: Same as Universal Being sockets but for game-level states
# ==================================================
# res://systems/state/GameStateSocketManager.gd

extends Node
class_name GameStateSocketManager

# ===== GAME STATE SOCKETS =====

enum InputState {
	NORMAL,      # Regular movement/camera
	INTERACT,    # 'i' pressed - interact mode
	INSPECT,     # 'Ctrl+i' pressed - inspect mode  
	CONSOLE,     # Console active - all other input locked
	MENU,        # Menu open - game paused
	AI_CHAT      # Chatting with Gemma AI
}

enum CursorState {
	FREE,        # Normal movement
	LOCKED,      # Cannot move (console active)
	TARGETING,   # Selecting targets for interaction
	INSPECTING   # Hovering over objects for inspection
}

# Current states
var current_input_state: InputState = InputState.NORMAL
var current_cursor_state: CursorState = CursorState.FREE
var state_history: Array[InputState] = []

# Socket system for game states
var state_sockets: Dictionary = {}
var input_handlers: Dictionary = {}

# Console and AI systems
var console_active: bool = false
var ai_chat_active: bool = false
var console_instance: Node = null  # Store console reference
var gemma_reference: Node = null

# Shared data access (AI and Human see same data)
var shared_akashic_access: Node = null
var shared_visual_data: Dictionary = {}

signal state_changed(old_state: InputState, new_state: InputState)
signal input_locked(reason: String)
signal input_unlocked()

func _ready() -> void:
	print("🎮 Game State Socket Manager: Initializing...")
	setup_state_sockets()
	setup_input_handlers()
	connect_to_akashic_records()
	print("🎮 Game State Socket System: Active")

func setup_state_sockets() -> void:
	"""Initialize game-level sockets like Universal Being sockets"""
	
	# Input State Socket
	state_sockets["input_state"] = {
		"type": "input_control",
		"current": InputState.NORMAL,
		"handlers": [],
		"locked": false
	}
	
	# Console State Socket
	state_sockets["console_state"] = {
		"type": "console_control", 
		"active": false,
		"input_buffer": "",
		"focus_locked": false
	}
	
	# AI Communication Socket
	state_sockets["ai_comm"] = {
		"type": "ai_communication",
		"gemma_active": false,
		"chat_mode": false,
		"shared_context": {}
	}
	
	# Cursor Control Socket
	state_sockets["cursor_control"] = {
		"type": "cursor_management",
		"state": CursorState.FREE,
		"position": Vector2.ZERO,
		"target": null
	}
	
	# Shared Data Socket (AI + Human access)
	state_sockets["shared_data"] = {
		"type": "akashic_interface",
		"human_view": {},
		"ai_view": {},
		"sync_active": true
	}
	
	print("🔌 Game State Sockets: 5 sockets initialized")

func setup_input_handlers() -> void:
	"""Setup input handlers for different states"""
	
	# Normal input handler
	input_handlers[InputState.NORMAL] = func(event):
		handle_normal_input(event)
	
	# Interact mode handler  
	input_handlers[InputState.INTERACT] = func(event):
		handle_interact_input(event)
	
	# Inspect mode handler
	input_handlers[InputState.INSPECT] = func(event):
		handle_inspect_input(event)
	
	# Console mode handler (locks other input)
	input_handlers[InputState.CONSOLE] = func(event):
		handle_console_input(event)
	
	# AI chat handler
	input_handlers[InputState.AI_CHAT] = func(event):
		handle_ai_chat_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	"""Handle key input with lower priority than UI elements"""
	_input(event)

func _input(event: InputEvent) -> void:
	"""Main input router based on current state"""
	
	# Handle backtick console toggle (highest priority - always works)
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		if console_active:
			deactivate_console()
		else:
			activate_console()
		get_viewport().set_input_as_handled()
		return
	
	# Emergency unlock (always available)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		emergency_unlock()
		get_viewport().set_input_as_handled()
		return
	
	# If console is active, let console handle ALL typing input
	if current_input_state == InputState.CONSOLE:
		# Don't block any keys - let console receive everything for typing
		return
	
	# State change inputs (highest priority)
	if handle_state_change_input(event):
		get_viewport().set_input_as_handled()
		return
	
	# Route to current state handler
	var handler = input_handlers.get(current_input_state)
	if handler:
		handler.call(event)

func handle_state_change_input(event: InputEvent) -> bool:
	"""Handle input that changes game state"""
	if not event is InputEventKey or not event.pressed:
		return false
	
	# Don't handle state changes when console is active (let console handle typing)
	if current_input_state == InputState.CONSOLE:
		return false
	
	match event.keycode:
		KEY_I:
			if event.ctrl_pressed:
				change_state(InputState.INSPECT)
				return true
			else:
				change_state(InputState.INTERACT) 
				return true
		
		KEY_ENTER, KEY_KP_ENTER:
			if current_input_state != InputState.CONSOLE:
				activate_console()
				return true
		
		KEY_T:
			if event.ctrl_pressed:  # Ctrl+T for AI chat
				activate_ai_chat()
				return true
	
	return false

func handle_normal_input(event: InputEvent) -> void:
	"""Handle input in normal state - pass to player/camera"""
	# Input flows normally to player controller and camera
	# This is where Q/E camera controls would be handled
	pass

func handle_interact_input(event: InputEvent) -> void:
	"""Handle input in interact mode ('i' pressed)"""
	set_cursor_state(CursorState.TARGETING)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		perform_interaction_at_cursor()

func handle_inspect_input(event: InputEvent) -> void:
	"""Handle input in inspect mode ('Ctrl+i' pressed)"""
	set_cursor_state(CursorState.INSPECTING)
	
	if event is InputEventMouseMotion:
		update_inspection_target()

func handle_console_input(event: InputEvent) -> void:
	"""Handle console input - other input is LOCKED"""
	lock_cursor()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			deactivate_console()
		# Note: Don't close console on ENTER - let LineEdit handle command submission

func handle_ai_chat_input(event: InputEvent) -> void:
	"""Handle AI chat input"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			deactivate_ai_chat()

func change_state(new_state: InputState) -> void:
	"""Change game input state"""
	# Only change if state is actually different
	if current_input_state == new_state:
		return  # No change needed
		
	var old_state = current_input_state
	state_history.append(old_state)
	current_input_state = new_state
	
	# Update socket
	state_sockets["input_state"]["current"] = new_state
	
	# Emit signal
	state_changed.emit(old_state, new_state)
	
	print("🎮 State: %s → %s" % [InputState.keys()[old_state], InputState.keys()[new_state]])

func activate_console() -> void:
	"""Activate console and lock other inputs"""
	console_active = true
	state_sockets["console_state"]["active"] = true
	state_sockets["console_state"]["focus_locked"] = true
	
	# Load and show the console scene
	spawn_console_ui()
	
	change_state(InputState.CONSOLE)
	lock_cursor()
	
	input_locked.emit("console_active")
	print("🎮 Console activated - other inputs locked")

func deactivate_console() -> void:
	"""Deactivate console and unlock inputs"""
	console_active = false
	state_sockets["console_state"]["active"] = false
	state_sockets["console_state"]["focus_locked"] = false
	
	# Hide the console UI
	if console_instance and is_instance_valid(console_instance):
		if console_instance.has_method("set_console_visible"):
			console_instance.set_console_visible(false)
		else:
			console_instance.hide()
	
	change_state(InputState.NORMAL)
	unlock_cursor()
	
	input_unlocked.emit()
	print("🎮 Console deactivated - inputs unlocked")

func activate_ai_chat() -> void:
	"""Activate AI chat mode"""
	if not gemma_reference:
		find_gemma_ai()
	
	ai_chat_active = true
	state_sockets["ai_comm"]["chat_mode"] = true
	change_state(InputState.AI_CHAT)
	
	print("🎮 AI Chat activated - talking to Gemma")

func deactivate_ai_chat() -> void:
	"""Deactivate AI chat mode"""
	ai_chat_active = false
	state_sockets["ai_comm"]["chat_mode"] = false
	change_state(InputState.NORMAL)
	
	print("🎮 AI Chat deactivated")

func set_cursor_state(new_state: CursorState) -> void:
	"""Set cursor state"""
	# Only print if state actually changes
	if current_cursor_state != new_state:
		current_cursor_state = new_state
		state_sockets["cursor_control"]["state"] = new_state
		print("🖱️ Cursor: %s" % CursorState.keys()[new_state])
	else:
		# Update the socket without spam
		current_cursor_state = new_state
		state_sockets["cursor_control"]["state"] = new_state

func lock_cursor() -> void:
	"""Lock cursor movement"""
	set_cursor_state(CursorState.LOCKED)

func unlock_cursor() -> void:
	"""Unlock cursor movement"""
	set_cursor_state(CursorState.FREE)

func emergency_unlock() -> void:
	"""Emergency unlock all systems (ESC key)"""
	console_active = false
	ai_chat_active = false
	current_input_state = InputState.NORMAL
	current_cursor_state = CursorState.FREE
	
	# Reset all sockets
	state_sockets["console_state"]["active"] = false
	state_sockets["console_state"]["focus_locked"] = false
	state_sockets["ai_comm"]["chat_mode"] = false
	state_sockets["cursor_control"]["state"] = CursorState.FREE
	
	input_unlocked.emit()
	print("🆘 Emergency unlock - all systems reset")

func perform_interaction_at_cursor() -> void:
	"""Perform interaction in interact mode"""
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var clicked_object = result.collider
		if clicked_object.has_method("on_interact"):
			clicked_object.on_interact()
			print("🎯 Interacted with: %s" % clicked_object.name)

func update_inspection_target() -> void:
	"""Update what we're inspecting in inspect mode"""
	# Similar to interaction but for inspection
	var mouse_pos = get_viewport().get_mouse_position()
	# ... inspection logic
	# Only log occasionally, not every mouse movement
	if randf() < 0.01:  # 1% chance to log
		print("🔍 Inspecting...")

func connect_to_akashic_records() -> void:
	"""Connect to Akashic Records for shared AI-Human access"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		shared_akashic_access = SystemBootstrap.get_akashic_records()
		if shared_akashic_access:
			print("📚 Connected to Akashic Records for shared access")

func find_gemma_ai() -> void:
	"""Find Gemma AI for communication"""
	var ai_nodes = get_tree().get_nodes_in_group("ai")
	for node in ai_nodes:
		if node.name.contains("Gemma"):
			gemma_reference = node
			state_sockets["ai_comm"]["gemma_active"] = true
			print("🤖 Found Gemma AI for communication")
			break

func send_message_to_gemma(message: String) -> void:
	"""Send message to Gemma AI"""
	if gemma_reference and gemma_reference.has_method("receive_player_message"):
		gemma_reference.receive_player_message(message)
		print("📨 Sent to Gemma: %s" % message)

func get_shared_akashic_data() -> Dictionary:
	"""Get Akashic Records data that both AI and human can access"""
	if shared_akashic_access:
		return shared_akashic_access.get_all_data() if shared_akashic_access.has_method("get_all_data") else {}
	return {}

func update_shared_visual_data(key: String, value: Variant) -> void:
	"""Update shared visual data for AI-Human cooperation"""
	shared_visual_data[key] = value
	state_sockets["shared_data"]["human_view"][key] = value
	state_sockets["shared_data"]["ai_view"][key] = value
	
	# Notify Gemma of update
	if gemma_reference and gemma_reference.has_method("on_shared_data_update"):
		gemma_reference.on_shared_data_update(key, value)

# ===== AI INTERFACE FOR GEMMA =====

func ai_get_game_state() -> Dictionary:
	"""Allow Gemma to read current game state"""
	return {
		"input_state": InputState.keys()[current_input_state],
		"cursor_state": CursorState.keys()[current_cursor_state], 
		"console_active": console_active,
		"ai_chat_active": ai_chat_active,
		"state_sockets": state_sockets,
		"shared_data": shared_visual_data
	}

func ai_can_access_akashic() -> bool:
	"""Check if AI can access Akashic Records"""
	return shared_akashic_access != null

# ===== SINGLETON ACCESS =====

static func get_instance() -> GameStateSocketManager:
	var scene_root = Engine.get_main_loop().current_scene
	if scene_root:
		return scene_root.get_node_or_null("GameStateSocketManager")
	return null

func spawn_console_ui() -> void:
	"""Create and show the animated console UI"""
	# Check if we already have a console instance
	if console_instance and is_instance_valid(console_instance):
		if console_instance.has_method("set_console_visible"):
			console_instance.set_console_visible(true)
		else:
			console_instance.show()
		print("✅ Console UI reused existing instance")
		return
	
	# Clear invalid reference
	console_instance = null
	
	# Check if console exists in scene tree
	var existing_console = get_tree().get_first_node_in_group("console")
	if existing_console:
		console_instance = existing_console
		if console_instance.has_method("set_console_visible"):
			console_instance.set_console_visible(true)
		else:
			console_instance.show()
		print("✅ Console UI found existing instance")
		return
	
	# Load the console scene
	var console_scene = preload("res://scenes/console/universal_console_animated.tscn")
	if console_scene:
		console_instance = console_scene.instantiate()
		console_instance.add_to_group("console")
		
		# Add to UI layer (so it appears on top)
		get_tree().root.add_child(console_instance)
		
		# Show the console with animation
		if console_instance.has_method("set_console_visible"):
			console_instance.set_console_visible(true)
		
		print("✅ Console UI spawned successfully")
	else:
		print("❌ Failed to load console scene")

# print("🎮 Game State Socket Manager: Class loaded")

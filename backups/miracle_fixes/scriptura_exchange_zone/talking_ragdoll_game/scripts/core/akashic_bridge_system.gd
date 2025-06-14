# ==================================================
# SCRIPT NAME: akashic_bridge_system.gd
# DESCRIPTION: Two-way communication bridge between Godot and Python server
# PURPOSE: Live tutorial system, file sync, and project consciousness
# CREATED: 2025-05-28 - The Akashic Records Bridge awakens
# ==================================================

extends UniversalBeingBase
class_name AkashicBridgeSystem

# Bridge communication
signal server_connected()
signal server_disconnected()
signal tutorial_step_completed(step: String)
signal file_sync_requested(file_path: String)
signal python_command_received(command: String, data: Dictionary)

# Communication settings
var server_url: String = "http://localhost:8888"
var websocket_url: String = "ws://localhost:8889"
var connection_status: String = "disconnected"
var auto_reconnect: bool = true

# HTTP client for REST API calls
var http_request: HTTPRequest = null
var websocket: WebSocketPeer = null

# Tutorial system integration
var tutorial_steps: Array = []
var current_step: int = 0
var tutorial_active: bool = false
var step_validation_data: Dictionary = {}

# File synchronization
var monitored_files: Array = [
	"user://lists/game_rules.txt",
	"user://lists/scene_forest.txt", 
	"user://lists/tutorial_steps.txt",
	"user://lists/player_progress.txt"
]
var file_checksums: Dictionary = {}

# Project state sharing
var project_state: Dictionary = {}
var last_sync_time: float = 0.0
var sync_interval: float = 2.0  # Sync every 2 seconds

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "AkashicBridgeSystem"
	
	# Setup HTTP client
	_setup_http_client()
	
	# Setup WebSocket
	_setup_websocket()
	
	# Initialize file monitoring
	_setup_file_monitoring()
	
	# Try to connect to server
	_attempt_server_connection()
	
	_print("🌌 Akashic Bridge System initializing...")

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Handle WebSocket communication
	if websocket:
		websocket.poll()
		_process_websocket_messages()
	
	# Regular project state sync
	if Time.get_time_dict_from_system().values().back() - last_sync_time > sync_interval:
		_sync_project_state()

# ========== CONNECTION SETUP ==========

func _setup_http_client() -> void:
	"""Setup HTTP client for REST API calls"""
	http_request = HTTPRequest.new()
	http_request.name = "AkashicHTTP"
	add_child(http_request)
	http_request.request_completed.connect(_on_http_response)

func _setup_websocket() -> void:
	"""Setup WebSocket for real-time communication"""
	websocket = WebSocketPeer.new()

func _attempt_server_connection() -> void:
	"""Try to connect to Python server"""
	_print("🔌 Attempting connection to Akashic server...")
	
	# First try HTTP ping
	_send_http_request("/ping", {}, HTTPClient.METHOD_GET)

func _on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	"""Handle HTTP responses"""
	var body_text = body.get_string_from_utf8()
	_print("🔍 HTTP Response - Code: " + str(response_code) + ", Result: " + str(result) + ", Body length: " + str(body.size()) + ", Body: '" + body_text + "'")
	
	# Debug headers
	for header in headers:
		if header.contains("Content-"):
			_print("  Header: " + header)
	
	if result != HTTPRequest.RESULT_SUCCESS:
		_print("❌ HTTP request failed with result: " + str(result))
		return
	
	if response_code == 200:
		if body_text == "pong":
			# Ping successful
			connection_status = "connected"
			server_connected.emit()
			_print("✅ Connected to Akashic server!")
			
			# Try WebSocket connection
			_connect_websocket()
			
			# Register with server
			_register_with_server()
		else:
			# Registration or other response
			_print("📨 Server response: " + body_text)
			if body_text.contains("success"):
				_print("✅ Registration successful!")
	else:
		connection_status = "disconnected"
		_print("❌ Failed to connect to Akashic server (code: " + str(response_code) + ")")
		
		if auto_reconnect:
			await get_tree().create_timer(5.0).timeout
			_attempt_server_connection()

func _connect_websocket() -> void:
	"""Connect WebSocket for real-time communication"""
	var error = websocket.connect_to_url(websocket_url)
	if error == OK:
		_print("🔗 WebSocket connecting...")
	else:
		_print("❌ WebSocket connection failed")

func _process_websocket_messages() -> void:
	"""Process incoming WebSocket messages"""
	var state = websocket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while websocket.get_available_packet_count():
			var packet = websocket.get_packet()
			var message = packet.get_string_from_utf8()
			_handle_server_message(message)
	elif state == WebSocketPeer.STATE_CLOSED:
		if connection_status == "connected":
			connection_status = "disconnected"
			server_disconnected.emit()
			_print("📡 WebSocket disconnected")

# ========== SERVER COMMUNICATION ==========

func _register_with_server() -> void:
	"""Register this game instance with server"""
	var registration_data = {
		"game_id": "talking_ragdoll_" + str(Time.get_ticks_msec()),
		"project_path": OS.get_executable_path().get_base_dir(),
		"capabilities": ["tutorial", "file_sync", "project_state"],
		"monitored_files": monitored_files
	}
	
	_send_http_request("/register", registration_data, HTTPClient.METHOD_POST)

func _send_http_request(endpoint: String, data: Dictionary, method: HTTPClient.Method) -> void:
	"""Send HTTP request to server"""
	var url = server_url + endpoint
	var headers = ["Content-Type: application/json"]
	
	if method == HTTPClient.METHOD_GET:
		# For GET requests, don't send body
		http_request.request(url, headers, method)
	else:
		# For POST/PUT, send JSON body
		var json_data = JSON.stringify(data)
		http_request.request(url, headers, method, json_data)

func _send_websocket_message(message: Dictionary) -> void:
	"""Send message via WebSocket"""
	if websocket and websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_message = JSON.stringify(message)
		websocket.send_text(json_message)

func _handle_server_message(message: String) -> void:
	"""Handle incoming server messages"""
	var json = JSON.new()
	var parse_result = json.parse(message)
	
	if parse_result != OK:
		_print("❌ Failed to parse server message")
		return
	
	var data = json.data
	var command = data.get("command", "")
	
	match command:
		"tutorial_start":
			_start_tutorial(data.get("steps", []))
		"tutorial_next_step":
			_execute_tutorial_step(current_step)  # Use existing function
		"file_update":
			_handle_file_update(data.get("file_path", ""), data.get("content", ""))
		"project_state_request":
			_send_project_state()
		"python_command":
			python_command_received.emit(data.get("action", ""), data.get("params", {}))
		"execute_console_command":
			var console_cmd = data.get("console_command", "")
			_print("🎮 Executing command from server: " + console_cmd)
			_execute_console_command(console_cmd)
		_:
			_print("❓ Unknown server command: " + command)

func _execute_console_command(command: String) -> void:
	"""Execute a console command from the server"""
	_print("🔍 Looking for ConsoleManager...")
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		_print("✅ Found ConsoleManager at /root/ConsoleManager")
		# Use the correct command submission method
		if console.has_method("_on_command_submitted"):
			_print("💻 Executing via command_submitted: " + command)
			console._on_command_submitted(command)
		elif console.has_method("_on_line_edit_text_submitted"):
			_print("💻 Executing via line_edit_submitted: " + command)
			console._on_line_edit_text_submitted(command)
		else:
			_print("❌ No execution method found!")
			# List available properties
			if "commands" in console:
				_print("  Commands dict exists: " + str(console.commands.keys().slice(0, 5)))
	else:
		_print("❌ Console not found at /root/ConsoleManager")
		_print("  Available autoloads: " + str(get_tree().root.get_children().map(func(n): return n.name)))

# ========== TUTORIAL SYSTEM ==========

func _start_tutorial(steps: Array) -> void:
	"""Start interactive tutorial"""
	tutorial_steps = steps
	current_step = 0
	tutorial_active = true
	
	_print("📚 Starting tutorial with " + str(steps.size()) + " steps")
	
	# Notify console
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console("📚 [Akashic] Tutorial started!")
		console._print_to_console("  " + str(steps.size()) + " steps to complete")
	
	_execute_tutorial_step(0)

func _execute_tutorial_step(step_index: int) -> void:
	"""Execute specific tutorial step"""
	if step_index >= tutorial_steps.size():
		_complete_tutorial()
		return
	
	var step = tutorial_steps[step_index]
	var step_type = step.get("type", "")
	var step_data = step.get("data", {})
	
	_print("📖 Tutorial Step " + str(step_index + 1) + ": " + step.get("title", ""))
	
	match step_type:
		"click_button":
			_tutorial_wait_for_click(step_data)
		"spawn_object":
			_tutorial_spawn_object(step_data)
		"use_command":
			_tutorial_wait_for_command(step_data)
		"check_system":
			_tutorial_check_system(step_data)
		"file_operation":
			_print("📁 Tutorial: File operation step - " + str(step_data))
			_complete_current_step()  # Simple completion for now
		_:
			_print("❓ Unknown tutorial step type: " + step_type)

func _tutorial_wait_for_click(step_data: Dictionary) -> void:
	"""Wait for player to click specific UI element"""
	var target = step_data.get("target", "")
	var message = step_data.get("message", "Click the " + target)
	
	# Show tutorial message
	_show_tutorial_message(message)
	
	# Set up validation
	step_validation_data = step_data
	
	# Monitor for the required click
	_monitor_tutorial_action("click", target)

func _tutorial_spawn_object(step_data: Dictionary) -> void:
	"""Tutorial step to spawn object"""
	var object_type = step_data.get("object", "box")
	var position = Vector3(step_data.get("x", 0), step_data.get("y", 1), step_data.get("z", 0))
	
	# Use Universal Object Manager
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom:
		var obj = uom.create_object(object_type, position)
		if obj:
			_print("📦 Tutorial: Spawned " + object_type + " at " + str(position))
			_complete_current_step()

func _tutorial_wait_for_command(step_data: Dictionary) -> void:
	"""Wait for player to use specific console command"""
	var command = step_data.get("command", "")
	var message = step_data.get("message", "Type: " + command)
	
	_show_tutorial_message(message)
	_monitor_tutorial_action("command", command)

func _tutorial_check_system(step_data: Dictionary) -> void:
	"""Check if system is working properly"""
	var system = step_data.get("system", "")
	var check_method = step_data.get("check", "exists")
	
	var system_ok = false
	
	match check_method:
		"exists":
			system_ok = has_node("/root/" + system)
		"autoload":
			system_ok = get_node_or_null("/root/" + system) != null
		"group":
			system_ok = get_tree().get_nodes_in_group(system).size() > 0
	
	if system_ok:
		_print("✅ Tutorial: System " + system + " is working")
		_complete_current_step()
	else:
		_print("❌ Tutorial: System " + system + " needs attention")
		_show_tutorial_message("⚠️ System " + system + " needs to be fixed first")

func _show_tutorial_message(message: String) -> void:
	"""Show tutorial message to player"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console("[color=#FFD700]📚 [Tutorial] " + message + "[/color]")

func _monitor_tutorial_action(action_type: String, target: String) -> void:
	"""Monitor for specific tutorial action"""
	# This would integrate with the console and UI systems
	# For now, we'll use a simple timer-based check
	pass

func _complete_current_step() -> void:
	"""Complete current tutorial step"""
	if not tutorial_active:
		return
	
	var step = tutorial_steps[current_step]
	tutorial_step_completed.emit(step.get("title", ""))
	
	# Notify server
	_send_websocket_message({
		"command": "tutorial_step_completed",
		"step": current_step,
		"step_data": step
	})
	
	current_step += 1
	
	if current_step < tutorial_steps.size():
		await get_tree().create_timer(1.0).timeout
		_execute_tutorial_step(current_step)
	else:
		_complete_tutorial()

func _complete_tutorial() -> void:
	"""Complete entire tutorial"""
	tutorial_active = false
	_print("🎉 Tutorial completed!")
	
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console("[color=#00FF00]🎉 [Tutorial] All steps completed![/color]")
		console._print_to_console("🚀 Your talking ragdoll game is ready!")

# ========== FILE SYNCHRONIZATION ==========

func _setup_file_monitoring() -> void:
	"""Setup file monitoring for sync"""
	for file_path in monitored_files:
		_ensure_file_exists(file_path)
		_update_file_checksum(file_path)

func _ensure_file_exists(file_path: String) -> void:
	"""Ensure monitored file exists"""
	if not FileAccess.file_exists(file_path):
		var dir_path = file_path.get_base_dir()
		var dir = DirAccess.open("user://")
		if not dir.dir_exists(dir_path.replace("user://", "")):
			dir.make_dir_recursive(dir_path.replace("user://", ""))
		
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_line("# " + file_path.get_file() + " - Auto-created by Akashic Bridge")
			file.close()

func _update_file_checksum(file_path: String) -> void:
	"""Update file checksum for change detection"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		file_checksums[file_path] = content.hash()

func _check_file_changes() -> void:
	"""Check for file changes"""
	for file_path in monitored_files:
		if FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				var new_checksum = content.hash()
				
				if file_checksums.get(file_path, 0) != new_checksum:
					file_checksums[file_path] = new_checksum
					_handle_file_changed(file_path, content)

func _handle_file_changed(file_path: String, content: String) -> void:
	"""Handle when monitored file changes"""
	_print("📁 File changed: " + file_path)
	
	# Notify server
	_send_websocket_message({
		"command": "file_changed",
		"file_path": file_path,
		"content": content,
		"timestamp": Time.get_ticks_msec()
	})
	
	file_sync_requested.emit(file_path)

func _handle_file_update(file_path: String, content: String) -> void:
	"""Handle file update from server"""
	_print("📝 Updating file from server: " + file_path)
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		_update_file_checksum(file_path)

# ========== PROJECT STATE SYNC ==========

func _sync_project_state() -> void:
	"""Sync project state with server"""
	_update_project_state()
	
	if connection_status == "connected":
		_send_websocket_message({
			"command": "project_state_update",
			"state": project_state,
			"timestamp": Time.get_ticks_msec()
		})
		
		last_sync_time = Time.get_time_dict_from_system().values().back()

func _update_project_state() -> void:
	"""Update current project state"""
	project_state = {
		"scene": get_tree().current_scene.name if get_tree().current_scene != null else "none",
		"fps": Engine.get_frames_per_second(),
		"node_count": get_tree().get_node_count(),
		"tutorial_active": tutorial_active,
		"tutorial_step": current_step,
		"systems_status": _get_systems_status(),
		"objects_spawned": _count_spawned_objects(),
		"console_commands_available": _get_available_commands()
	}

func _get_systems_status() -> Dictionary:
	"""Get status of all major systems"""
	return {
		"floodgate": get_node_or_null("/root/FloodgateController") != null,
		"console": get_node_or_null("/root/ConsoleManager") != null,
		"universal_objects": get_node_or_null("/root/UniversalObjectManager") != null,
		"inspection_bridge": get_tree().get_first_node_in_group("inspection_bridge") != null
	}

func _count_spawned_objects() -> int:
	"""Count objects in scene"""
	var count = 0
	var scene = get_tree().current_scene
	if scene:
		count = _count_nodes_recursive(scene)
	return count

func _count_nodes_recursive(node: Node) -> int:
	"""Recursively count nodes"""
	var count = 1
	for child in node.get_children():
		count += _count_nodes_recursive(child)
	return count

func _get_available_commands() -> Array:
	"""Get list of available console commands"""
	var commands = []
	var console = get_node_or_null("/root/ConsoleManager")
	if console and "commands" in console:
		commands = console.commands.keys()
	return commands

func _send_project_state() -> void:
	"""Send current project state to server"""
	_update_project_state()
	_send_websocket_message({
		"command": "project_state_response",
		"state": project_state
	})

# ========== CONSOLE COMMANDS ==========


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func register_console_commands() -> void:
	"""Register Akashic Bridge console commands"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("add_command"):
		console.add_command("akashic_connect", _cmd_connect, "Connect to Akashic server")
		console.add_command("akashic_status", _cmd_status, "Show Akashic Bridge status")
		console.add_command("akashic_sync", _cmd_sync, "Force sync with server")
		console.add_command("akashic_tutorial", _cmd_tutorial, "Start tutorial mode")

func _cmd_connect(_args: Array) -> String:
	_attempt_server_connection()
	return "🔌 Attempting connection to Akashic server..."

func _cmd_status(_args: Array) -> String:
	var status = "🌌 Akashic Bridge Status:\n"
	status += "  Connection: " + connection_status + "\n"
	status += "  Server URL: " + server_url + "\n"
	status += "  Tutorial active: " + str(tutorial_active) + "\n"
	status += "  Monitored files: " + str(monitored_files.size()) + "\n"
	status += "  Last sync: " + str(Time.get_ticks_msec() - (last_sync_time * 1000)) + "ms ago"
	return status

func _cmd_sync(_args: Array) -> String:
	_sync_project_state()
	_check_file_changes()
	return "🔄 Force sync completed"

func _cmd_tutorial(_args: Array) -> String:
	if tutorial_active:
		return "📚 Tutorial already active (step " + str(current_step + 1) + "/" + str(tutorial_steps.size()) + ")"
	else:
		# Request tutorial from server
		_send_websocket_message({"command": "request_tutorial"})
		return "📚 Requesting tutorial from Akashic server..."

func _print(message: String) -> void:
	print("🌌 [AkashicBridge] " + message)

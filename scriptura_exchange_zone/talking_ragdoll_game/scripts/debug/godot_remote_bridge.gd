################################################################
# GODOT REMOTE BRIDGE - CLAUDE EXTERNAL ACCESS
# Enables Claude to connect and interact with running Godot instance
# Created: May 31st, 2025 | AI-Human Collaboration Revolution
# Location: scripts/debug/godot_remote_bridge.gd
################################################################

extends UniversalBeingBase
class_name GodotRemoteBridge

################################################################
# CORE VARIABLES
################################################################

# HTTP Server for Claude access
var http_server: TCPServer = null
var client_connections: Array[StreamPeerTCP] = []
var server_port: int = 8080
var server_active: bool = false

# Command processing
var command_queue: Array[Dictionary] = []
var response_queue: Array[Dictionary] = []
var command_processor: Timer = null

# System references
var perfect_pentagon_systems: Dictionary = {}
var gamma_controller: Node = null
var sewers_monitor: Node = null

# File-based communication backup
var claude_commands_path: String = "claude_communication/commands/"
var claude_responses_path: String = "claude_communication/responses/"
var file_monitor: Timer = null

var debug_mode: bool = true

################################################################
# SIGNALS
################################################################

signal claude_connected(connection_type: String)
signal claude_command_received(command: Dictionary)
signal claude_response_sent(response: Dictionary)
signal bridge_error(error: String)

################################################################
# INITIALIZATION
################################################################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🌉 GODOT REMOTE BRIDGE: Initializing external AI access...")
	
	# Create communication directories
	_ensure_communication_directories()
	
	# Connect to Perfect Pentagon systems
	_connect_pentagon_systems()
	
	# Set up HTTP server for Claude
	_setup_http_server()
	
	# Set up file-based backup communication
	_setup_file_communication()
	
	# Set up command processing
	_setup_command_processor()
	
	if debug_mode:
		print("✅ REMOTE BRIDGE: Ready for Claude connection on port %d" % server_port)

################################################################
# HTTP SERVER SETUP
################################################################

func _setup_http_server():
	"""Set up HTTP server for Claude to connect"""
	
	http_server = TCPServer.new()
	
	var error = http_server.listen(server_port, "127.0.0.1")
	if error != OK:
		print("🚨 REMOTE BRIDGE ERROR: Cannot start HTTP server on port %d" % server_port)
		_fallback_to_file_only()
		return
	
	server_active = true
	set_process(true)  # Enable _process for connection handling
	
	print("🌐 REMOTE BRIDGE: HTTP server listening on http://localhost:%d" % server_port)
	print("📡 CLAUDE ACCESS ENDPOINTS:")
	print("   GET  /status          - System status")
	print("   POST /gamma/message   - Send message to Gamma")
	print("   GET  /gamma/response  - Get Gamma's latest response")
	print("   GET  /sewers/status   - Sewers Monitor data")
	print("   POST /universal_being/create - Create Universal Being")
	print("   GET  /pentagon/status - Perfect Pentagon overview")

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	"""Handle HTTP connections and requests"""
	
	if not server_active:
		return
	
	# Accept new connections
	if http_server.is_connection_available():
		var client = http_server.take_connection()
		if client:
			client_connections.append(client)
			if debug_mode:
				print("🔗 REMOTE BRIDGE: Claude connected via HTTP")
			emit_signal("claude_connected", "http")
	
	# Process existing connections
	for i in range(client_connections.size() - 1, -1, -1):
		var client = client_connections[i]
		
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			client_connections.remove_at(i)
			continue
		
		# Read HTTP request
		if client.get_available_bytes() > 0:
			_handle_http_request(client)

func _handle_http_request(client: StreamPeerTCP):
	"""Handle incoming HTTP request from Claude"""
	
	var request_data = client.get_utf8_string(client.get_available_bytes())
	var response = _process_http_request(request_data)
	
	# Send HTTP response
	var http_response = "HTTP/1.1 200 OK\r\n"
	http_response += "Content-Type: application/json\r\n"
	http_response += "Access-Control-Allow-Origin: *\r\n"
	http_response += "Content-Length: %d\r\n\r\n" % response.length()
	http_response += response
	
	client.put_data(http_response.to_utf8_buffer())
	client.disconnect_from_host()

################################################################
# HTTP REQUEST PROCESSING
################################################################

func _process_http_request(request_data: String) -> String:
	"""Process HTTP request and return JSON response"""
	
	var lines = request_data.split("\r\n")
	if lines.size() == 0:
		return _error_response("Invalid request")
	
	var request_line = lines[0]
	var parts = request_line.split(" ")
	if parts.size() < 2:
		return _error_response("Invalid request line")
	
	var method = parts[0]
	var path = parts[1]
	
	if debug_mode:
		print("🌐 HTTP REQUEST: %s %s" % [method, path])
	
	# Route request
	match [method, path]:
		["GET", "/status"]:
			return _get_system_status()
		["GET", "/gamma/response"]:
			return _get_gamma_response()
		["GET", "/sewers/status"]:
			return _get_sewers_status()
		["GET", "/pentagon/status"]:
			return _get_pentagon_status()
		["POST", "/gamma/message"]:
			var body = _extract_http_body(request_data)
			return _send_gamma_message(body)
		["POST", "/universal_being/create"]:
			var body = _extract_http_body(request_data)
			return _create_universal_being(body)
		_:
			return _error_response("Endpoint not found: " + path)

func _extract_http_body(request_data: String) -> String:
	"""Extract body from HTTP request"""
	var parts = request_data.split("\r\n\r\n", false, 1)
	if parts.size() > 1:
		return parts[1]
	return ""

################################################################
# API ENDPOINTS
################################################################

func _get_system_status() -> String:
	"""GET /status - Overall system status"""
	
	var status = {
		"bridge_active": true,
		"server_port": server_port,
		"connections": client_connections.size(),
		"pentagon_systems": {},
		"gamma_status": "unknown",
		"timestamp": Time.get_ticks_msec()
	}
	
	# Check Pentagon systems
	for system_name in perfect_pentagon_systems:
		var system = perfect_pentagon_systems[system_name]
		status.pentagon_systems[system_name] = system != null
	
	# Check Gamma status
	if gamma_controller and gamma_controller.has_method("get_gamma_status"):
		status.gamma_status = gamma_controller.get_gamma_status()
	
	return JSON.stringify(status)

func _get_gamma_response() -> String:
	"""GET /gamma/response - Get Gamma's latest response"""
	
	var response_file = "ai_communication/output/Gamma.txt"
	
	if not FileAccess.file_exists(response_file):
		return _error_response("No Gamma responses found")
	
	var file = FileAccess.open(response_file, FileAccess.READ)
	if not file:
		return _error_response("Cannot read Gamma response file")
	
	var lines = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "" and not line.begins_with("#"):
			lines.append(line)
	file.close()
	
	var result = {
		"success": true,
		"latest_response": lines[-1] if lines.size() > 0 else "No responses yet",
		"total_responses": lines.size(),
		"timestamp": Time.get_ticks_msec()
	}
	
	return JSON.stringify(result)

func _send_gamma_message(body: String) -> String:
	"""POST /gamma/message - Send message to Gamma"""
	
	var json = JSON.new()
	var parse_result = json.parse(body)
	
	if parse_result != OK:
		return _error_response("Invalid JSON in request body")
	
	var data = json.data
	var message = data.get("message", "")
	
	if message == "":
		return _error_response("No message provided")
	
	# Write to Gamma's input file
	var input_file = "ai_communication/input/Gamma.txt"
	var file = FileAccess.open(input_file, FileAccess.WRITE_READ)
	
	if not file:
		return _error_response("Cannot write to Gamma input file")
	
	file.seek_end()
	file.store_line("claude_api_%d: %s" % [Time.get_ticks_msec(), message])
	file.close()
	
	var result = {
		"success": true,
		"message_sent": message,
		"timestamp": Time.get_ticks_msec(),
		"note": "Check /gamma/response in 5-10 seconds for Gamma's reply"
	}
	
	if debug_mode:
		print("💬 CLAUDE → GAMMA: " + message)
	
	return JSON.stringify(result)

func _get_sewers_status() -> String:
	"""GET /sewers/status - Sewers Monitor data"""
	
	if not sewers_monitor or not sewers_monitor.has_method("get_sewers_status"):
		return _error_response("Sewers Monitor not available")
	
	var sewers_status = sewers_monitor.get_sewers_status()
	
	var result = {
		"success": true,
		"sewers_data": sewers_status,
		"timestamp": Time.get_ticks_msec()
	}
	
	return JSON.stringify(result)

func _get_pentagon_status() -> String:
	"""GET /pentagon/status - Perfect Pentagon overview"""
	
	var pentagon_status = {}
	
	for system_name in perfect_pentagon_systems:
		var system = perfect_pentagon_systems[system_name]
		pentagon_status[system_name] = {
			"available": system != null,
			"status": "unknown"
		}
		
		if system and system.has_method("get_system_info"):
			pentagon_status[system_name]["info"] = system.get_system_info()
	
	var result = {
		"success": true,
		"pentagon_systems": pentagon_status,
		"timestamp": Time.get_ticks_msec()
	}
	
	return JSON.stringify(result)

func _create_universal_being(body: String) -> String:
	"""POST /universal_being/create - Create Universal Being"""
	
	var json = JSON.new()
	var parse_result = json.parse(body)
	
	if parse_result != OK:
		return _error_response("Invalid JSON in request body")
	
	var data = json.data
	var being_type = data.get("type", "orb")
	var position = data.get("position", [0, 1, 0])
	
	# Try to create Universal Being
	if has_node("/root/UniversalObjectManager"):
		var uom = get_node("/root/UniversalObjectManager")
		
		if uom.has_method("create_object"):
			var being = uom.create_object(being_type, Vector3(position[0], position[1], position[2]), {
				"name": "claude_created_" + being_type,
				"created_by": "claude",
				"remote_creation": true
			})
			
			if being:
				# Set position
				if being is Node3D:
					being.global_position = Vector3(position[0], position[1], position[2])
				
				# Set form
				if being.has_method("become"):
					being.become(being_type)
				
				var result = {
					"success": true,
					"being_created": being.name,
					"type": being_type,
					"position": position,
					"timestamp": Time.get_ticks_msec()
				}
				
				return JSON.stringify(result)
	
	return _error_response("Failed to create Universal Being")

func _error_response(message: String) -> String:
	"""Generate error response"""
	var error = {
		"success": false,
		"error": message,
		"timestamp": Time.get_ticks_msec()
	}
	return JSON.stringify(error)

################################################################
# FILE-BASED COMMUNICATION BACKUP
################################################################

func _setup_file_communication():
	"""Set up file-based communication as backup"""
	
	file_monitor = TimerManager.get_timer()
	file_monitor.wait_time = 1.0  # Check every second
	file_monitor.autostart = true
	file_monitor.timeout.connect(_check_file_commands)
	add_child(file_monitor)

func _check_file_commands():
	"""Check for file-based commands from Claude"""
	
	var commands_dir = claude_commands_path
	
	if not DirAccess.dir_exists_absolute(commands_dir):
		return
	
	var dir = DirAccess.open(commands_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json") and not file_name.begins_with("processed_"):
				_process_file_command(commands_dir + file_name)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

func _process_file_command(file_path: String):
	"""Process command from file"""
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(content) == OK:
		var command = json.data
		_execute_claude_command(command)
		
		# Mark as processed
		var new_path = file_path.replace(".json", "_processed.json")
		DirAccess.rename_absolute(file_path, new_path)

################################################################
# SYSTEM CONNECTION
################################################################

func _connect_pentagon_systems():
	"""Connect to Perfect Pentagon systems"""
	
	var systems = ["PerfectInit", "PerfectReady", "PerfectInput", "LogicConnector", "SewersMonitor"]
	
	for system_name in systems:
		if has_node("/root/" + system_name):
			perfect_pentagon_systems[system_name] = get_node("/root/" + system_name)
			if debug_mode:
				print("🔗 BRIDGE: Connected to " + system_name)
	
	# Find Gamma Controller
	gamma_controller = _find_gamma_controller()
	if gamma_controller:
		print("🤖 BRIDGE: Connected to Gamma Controller")
	
	# Connect to Sewers Monitor specifically
	sewers_monitor = perfect_pentagon_systems.get("SewersMonitor")

func _find_gamma_controller() -> Node:
	"""Find Gamma Controller in scene"""
	var controllers = get_tree().get_nodes_in_group("gamma_controllers")
	if controllers.size() > 0:
		return controllers[0]
	
	# Search by name
	var all_nodes = get_tree().get_nodes_in_group("gamma_ai")
	for node in all_nodes:
		if node.name.to_lower().contains("gamma"):
			return node
	
	return null

################################################################
# UTILITY FUNCTIONS
################################################################

func _ensure_communication_directories():
	"""Create communication directories"""
	
	var dirs = [claude_commands_path, claude_responses_path]
	
	for dir in dirs:
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.open("res://").make_dir_recursive(dir)

func _fallback_to_file_only():
	"""Fall back to file-only communication"""
	server_active = false
	print("📁 REMOTE BRIDGE: Using file-based communication only")

func _setup_command_processor():
	"""Set up command processing system"""
	command_processor = TimerManager.get_timer()
	command_processor.wait_time = 0.1
	command_processor.autostart = true
	command_processor.timeout.connect(_process_command_queue)
	add_child(command_processor)

func _process_command_queue():
	"""Process queued commands"""
	while command_queue.size() > 0:
		var command = command_queue.pop_front()
		_execute_claude_command(command)

func _execute_claude_command(command: Dictionary):
	"""Execute command from Claude"""
	if debug_mode:
		print("🎯 EXECUTING CLAUDE COMMAND: " + str(command))
	
	emit_signal("claude_command_received", command)

################################################################
# PUBLIC INTERFACE
################################################################


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
func get_bridge_status() -> Dictionary:
	"""Get bridge status for monitoring"""
	return {
		"server_active": server_active,
		"port": server_port,
		"connections": client_connections.size(),
		"pentagon_systems": perfect_pentagon_systems.size(),
		"gamma_connected": gamma_controller != null
	}

################################################################
# END OF GODOT REMOTE BRIDGE
################################################################
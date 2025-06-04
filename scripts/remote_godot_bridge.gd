# ==================================================
# SCRIPT NAME: remote_godot_bridge.gd
# DESCRIPTION: Bridge for remote connection to Windows Godot Engine
# PURPOSE: Enable multi-AI development via TCP connections to Godot ports
# CREATED: 2025-01-06 - Multi-AI Remote Development
# AUTHOR: JSH + Claude Code - Universal Being Remote Development
# ==================================================

@tool
extends MainLoop
class_name RemoteGodotBridge

# ===== GODOT DEBUG PORTS =====
# Standard Godot Engine debug/development ports
const GODOT_LANGUAGE_SERVER_PORT = 6005  # GDScript language server
const GODOT_DEBUG_ADAPTER_PORT = 6006    # Debug adapter server
const CURSOR_REMOTE_PORT = 6008          # Cursor's remote development port

# Connection details for Windows machine
static var WINDOWS_IP: String = "127.0.0.1"  # Can be changed to actual IP
static var connection_status: Dictionary = {}

# ===== CONNECTION MANAGEMENT =====

class RemoteConnection:
	var socket: TCPServer
	var client: StreamPeerTCP
	var port: int
	var service_name: String
	var is_connected: bool = false
	var last_activity: float = 0.0
	
	func _init(service: String, target_port: int):
		service_name = service
		port = target_port
		socket = TCPServer.new()
		last_activity = Time.get_time_dict_from_system().get("unix", 0.0)
	
	func connect_to_godot(ip: String = "127.0.0.1") -> bool:
		print("🔗 Attempting to connect to %s at %s:%d" % [service_name, ip, port])
		
		client = StreamPeerTCP.new()
		var result = client.connect_to_host(ip, port)
		
		if result == OK:
			# Wait a moment for connection
			await _wait_for_connection()
			if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				is_connected = true
				last_activity = Time.get_time_dict_from_system().get("unix", 0.0)
				print("✅ Connected to %s at %s:%d" % [service_name, ip, port])
				return true
		
		print("❌ Failed to connect to %s at %s:%d" % [service_name, ip, port])
		return false
	
	func _wait_for_connection() -> void:
		var timeout = 5.0
		var elapsed = 0.0
		while client.get_status() == StreamPeerTCP.STATUS_CONNECTING and elapsed < timeout:
			await Engine.get_main_loop().process_frame
			elapsed += 0.1
	
	func send_message(message: String) -> bool:
		if not is_connected or not client:
			return false
		
		var data = message.to_utf8_buffer()
		var bytes_sent = client.put_data(data)
		last_activity = Time.get_time_dict_from_system().get("unix", 0.0)
		
		return bytes_sent == OK
	
	func receive_message() -> String:
		if not is_connected or not client:
			return ""
		
		if client.get_available_bytes() > 0:
			var data = client.get_data(client.get_available_bytes())
			last_activity = Time.get_time_dict_from_system().get("unix", 0.0)
			
			if data[0] == OK:
				return data[1].get_string_from_utf8()
		
		return ""
	
	func disconnect_from_godot() -> void:
		if client:
			client.disconnect_from_host()
			is_connected = false
		print("🔗 Disconnected from %s" % service_name)

# ===== MAIN BRIDGE FUNCTIONS =====

static func setup_remote_connections() -> Dictionary:
	"""Setup connections to all Godot development ports"""
	print("🌐 Setting up remote connections to Windows Godot Engine...")
	
	var connections = {}
	
	# Language Server Connection (GDScript completion, hover, etc.)
	var language_server = RemoteConnection.new("GDScript Language Server", GODOT_LANGUAGE_SERVER_PORT)
	connections["language_server"] = language_server
	
	# Debug Adapter Connection (debugging, breakpoints, etc.)
	var debug_adapter = RemoteConnection.new("Debug Adapter Server", GODOT_DEBUG_ADAPTER_PORT)
	connections["debug_adapter"] = debug_adapter
	
	# Cursor Remote Connection (Cursor AI development)
	var cursor_remote = RemoteConnection.new("Cursor Remote Development", CURSOR_REMOTE_PORT)
	connections["cursor_remote"] = cursor_remote
	
	print("🔗 Remote connection objects created")
	return connections

static func test_all_connections(windows_ip: String = "127.0.0.1") -> Dictionary:
	"""Test connectivity to all Godot ports"""
	print("🔍 Testing connectivity to Windows Godot Engine at %s..." % windows_ip)
	
	var results = {
		"timestamp": Time.get_datetime_string_from_system(),
		"target_ip": windows_ip,
		"connections": {},
		"summary": {}
	}
	
	var ports_to_test = {
		"language_server": GODOT_LANGUAGE_SERVER_PORT,
		"debug_adapter": GODOT_DEBUG_ADAPTER_PORT,
		"cursor_remote": CURSOR_REMOTE_PORT
	}
	
	var successful_connections = 0
	
	for service_name in ports_to_test:
		var port = ports_to_test[service_name]
		var connection_result = await _test_single_connection(windows_ip, port, service_name)
		results.connections[service_name] = connection_result
		
		if connection_result.connected:
			successful_connections += 1
	
	results.summary = {
		"total_services": ports_to_test.size(),
		"successful_connections": successful_connections,
		"connection_rate": (successful_connections / float(ports_to_test.size())) * 100.0
	}
	
	return results

static func _test_single_connection(ip: String, port: int, service: String) -> Dictionary:
	"""Test connection to a single port"""
	print("🔗 Testing %s at %s:%d..." % [service, ip, port])
	
	var tcp = StreamPeerTCP.new()
	var start_time = Time.get_time_dict_from_system().get("unix", 0.0)
	var result = tcp.connect_to_host(ip, port)
	
	if result != OK:
		return {
			"service": service,
			"port": port,
			"connected": false,
			"error": "Connection failed immediately",
			"response_time": 0.0
		}
	
	# Wait for connection or timeout
	var timeout = 3.0
	var elapsed = 0.0
	while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING and elapsed < timeout:
		await Engine.get_main_loop().process_frame
		elapsed += 0.1
	
	var end_time = Time.get_time_dict_from_system().get("unix", 0.0)
	var response_time = end_time - start_time
	
	var connection_data = {
		"service": service,
		"port": port,
		"connected": tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED,
		"status": _get_status_string(tcp.get_status()),
		"response_time": response_time
	}
	
	if connection_data.connected:
		print("✅ %s: Connected in %.2fs" % [service, response_time])
	else:
		print("❌ %s: Failed (%s)" % [service, connection_data.status])
	
	tcp.disconnect_from_host()
	return connection_data

static func _get_status_string(status: int) -> String:
	"""Convert TCP status to readable string"""
	match status:
		StreamPeerTCP.STATUS_NONE:
			return "NONE"
		StreamPeerTCP.STATUS_CONNECTING:
			return "CONNECTING"
		StreamPeerTCP.STATUS_CONNECTED:
			return "CONNECTED"
		StreamPeerTCP.STATUS_ERROR:
			return "ERROR"
		_:
			return "UNKNOWN"

# ===== MULTI-AI COLLABORATION SETUP =====

static func setup_multi_ai_bridge() -> Dictionary:
	"""Setup bridge for multi-AI collaboration"""
	print("🤖 Setting up Multi-AI Collaboration Bridge...")
	
	var ai_bridge = {
		"timestamp": Time.get_datetime_string_from_system(),
		"ai_systems": {},
		"communication_channels": {},
		"coordination_hub": null
	}
	
	# Claude Code (Linux) - Current instance
	ai_bridge.ai_systems["claude_code"] = {
		"name": "Claude Code",
		"location": "Linux WSL",
		"role": "System Architecture & Code Generation",
		"capabilities": ["file_operations", "code_analysis", "system_design"],
		"status": "active"
	}
	
	# Claude Desktop MCP (Windows)
	ai_bridge.ai_systems["claude_desktop"] = {
		"name": "Claude Desktop MCP",
		"location": "Windows Host",
		"role": "Project Orchestration & UI Integration",
		"capabilities": ["godot_integration", "visual_debugging", "project_management"],
		"status": "available"
	}
	
	# Cursor AI (Windows)
	ai_bridge.ai_systems["cursor"] = {
		"name": "Cursor AI",
		"location": "Windows Host",
		"role": "Visual Development & Code Completion",
		"capabilities": ["code_completion", "visual_editing", "real_time_collaboration"],
		"status": "connected_via_6008"
	}
	
	# Communication channels
	ai_bridge.communication_channels = {
		"godot_language_server": {
			"port": GODOT_LANGUAGE_SERVER_PORT,
			"purpose": "GDScript language features",
			"ai_users": ["claude_code", "cursor"]
		},
		"debug_adapter": {
			"port": GODOT_DEBUG_ADAPTER_PORT,
			"purpose": "Debugging and runtime inspection",
			"ai_users": ["claude_desktop", "cursor"]
		},
		"cursor_remote": {
			"port": CURSOR_REMOTE_PORT,
			"purpose": "Remote development coordination",
			"ai_users": ["claude_code", "cursor"]
		}
	}
	
	print("🤖 Multi-AI bridge configuration complete!")
	return ai_bridge

# ===== GODOT PROJECT INTERACTION =====

static func send_gdscript_command(command: String, windows_ip: String = "127.0.0.1") -> Dictionary:
	"""Send GDScript command to remote Godot instance"""
	print("📡 Sending GDScript command to Godot: %s" % command)
	
	var connection = RemoteConnection.new("Command Sender", GODOT_LANGUAGE_SERVER_PORT)
	var result = {
		"command": command,
		"success": false,
		"response": "",
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	if await connection.connect_to_godot(windows_ip):
		var message_sent = connection.send_message(command)
		if message_sent:
			# Wait for response
			await _wait_for_response(2.0)
			var response = connection.receive_message()
			
			result.success = true
			result.response = response
			print("✅ Command sent successfully")
		else:
			print("❌ Failed to send command")
		
		connection.disconnect_from_godot()
	else:
		print("❌ Could not connect to Godot")
	
	return result

static func _wait_for_response(timeout: float) -> void:
	"""Wait for response with timeout"""
	var elapsed = 0.0
	while elapsed < timeout:
		await Engine.get_main_loop().process_frame
		elapsed += 0.1

# ===== NETWORKING UTILITIES =====

static func discover_windows_godot() -> Dictionary:
	"""Attempt to discover Windows Godot instance on network"""
	print("🔍 Discovering Windows Godot Engine on network...")
	
	var discovery_result = {
		"method": "local_network_scan",
		"timestamp": Time.get_datetime_string_from_system(),
		"candidates": [],
		"recommended_ip": WINDOWS_IP
	}
	
	# For WSL, Windows host is typically accessible via these methods:
	var ip_candidates = [
		"127.0.0.1",        # Localhost
		"localhost",        # Hostname
		"host.docker.internal",  # Docker/WSL bridge
		_get_windows_host_ip()   # WSL host IP
	]
	
	for ip in ip_candidates:
		if ip and ip != "":
			var test_result = await test_all_connections(ip)
			if test_result.summary.successful_connections > 0:
				discovery_result.candidates.append({
					"ip": ip,
					"connections": test_result.summary.successful_connections,
					"details": test_result
				})
	
	if discovery_result.candidates.size() > 0:
		# Use the IP with most successful connections
		var best_candidate = discovery_result.candidates[0]
		for candidate in discovery_result.candidates:
			if candidate.connections > best_candidate.connections:
				best_candidate = candidate
		
		discovery_result.recommended_ip = best_candidate.ip
		print("✅ Best Godot instance found at: %s" % discovery_result.recommended_ip)
	else:
		print("❌ No Godot instances discovered")
	
	return discovery_result

static func _get_windows_host_ip() -> String:
	"""Get Windows host IP from WSL environment"""
	# Try to get Windows host IP via /etc/resolv.conf (common in WSL)
	var resolv_file = FileAccess.open("/etc/resolv.conf", FileAccess.READ)
	if resolv_file:
		var content = resolv_file.get_as_text()
		resolv_file.close()
		
		var lines = content.split("\n")
		for line in lines:
			if line.begins_with("nameserver"):
				var parts = line.split(" ")
				if parts.size() > 1:
					return parts[1].strip_edges()
	
	return ""

# ===== MAIN LOOP IMPLEMENTATION =====

func _initialize():
	"""MainLoop initialization"""
	var args = OS.get_cmdline_args()
	await main()
	OS.exit()

# ===== COMMAND LINE INTERFACE =====

static func main():
	"""Entry point for remote Godot bridge"""
	var args = OS.get_cmdline_args()
	
	if "--test-connections" in args:
		var ip = "127.0.0.1"
		var ip_index = args.find("--test-connections")
		if ip_index + 1 < args.size():
			ip = args[ip_index + 1]
		
		var results = await test_all_connections(ip)
		print("\n🔍 Connection Test Results:")
		print("Target: %s" % results.target_ip)
		print("Success Rate: %.1f%% (%d/%d)" % [
			results.summary.connection_rate,
			results.summary.successful_connections,
			results.summary.total_services
		])
	
	elif "--discover" in args:
		var discovery = await discover_windows_godot()
		print("\n🌐 Discovery Results:")
		print("Found %d candidate IPs" % discovery.candidates.size())
		print("Recommended IP: %s" % discovery.recommended_ip)
	
	elif "--setup-multi-ai" in args:
		var bridge = setup_multi_ai_bridge()
		print("\n🤖 Multi-AI Bridge Setup Complete:")
		print("AI Systems: %d" % bridge.ai_systems.size())
		print("Channels: %d" % bridge.communication_channels.size())
	
	elif "--send-command" in args:
		var cmd_index = args.find("--send-command")
		if cmd_index + 1 < args.size():
			var command = args[cmd_index + 1]
			var result = await send_gdscript_command(command)
			print("Command Result: %s" % ("Success" if result.success else "Failed"))
	
	else:
		print("🌐 Remote Godot Bridge - Multi-AI Development")
		print("Connect Linux Claude Code to Windows Godot Engine")
		print("")
		print("Usage:")
		print("  --test-connections [ip]  Test connections to Godot ports")
		print("  --discover               Discover Godot instances on network")
		print("  --setup-multi-ai         Setup multi-AI collaboration bridge")
		print("  --send-command <cmd>     Send command to remote Godot")
		print("")
		print("Ports:")
		print("  6005 - GDScript Language Server")
		print("  6006 - Debug Adapter Server")
		print("  6008 - Cursor Remote Development")
		print("")
		print("🤖 Multi-AI Development: Claude Code + Claude Desktop + Cursor")
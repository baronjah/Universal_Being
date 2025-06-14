extends Node

class_name UniversalConnector

# Universal Connector System
# Creates a unified interface between applications, drives, and dimensions
# Implements global keyboard shortcuts and standardized data connections

# Constants
const CONNECTOR_VERSION = "1.0.0"
const DEFAULT_SHORTCUT = "ctrl+alt+space"
const DRIVE_PATHS = {
	"C": "/mnt/c/",
	"D": "/mnt/d/"
}
const APP_CONNECTIONS = {
	"claude": {
		"path": "/mnt/c/Users/Percision 15/claude_akashic_bridge.gd",
		"api_key_path": "user://api_keys/claude_key.enc",
		"shortcut": "ctrl+alt+c",
		"data_channels": ["text", "memory", "visualization"]
	},
	"windows": {
		"path": "user://system_bridges/windows_connector.dll",
		"shortcut": "alt+w",
		"data_channels": ["file", "clipboard", "notification"]
	},
	"godot": {
		"path": "res://",
		"shortcut": "ctrl+alt+g",
		"data_channels": ["scene", "script", "resource"]
	},
	"terminal": {
		"path": "/mnt/c/Users/Percision 15/terminal_api_bridge.gd",
		"shortcut": "ctrl+alt+t",
		"data_channels": ["command", "output", "error"]
	},
	"ethereal_engine": {
		"path": "/mnt/c/Users/Percision 15/ethereal_engine.gd",
		"shortcut": "ctrl+alt+e",
		"data_channels": ["reality", "dimension", "creation"]
	},
	"akashic_records": {
		"path": "/mnt/c/Users/Percision 15/12_turns_system/akashic_database.js",
		"shortcut": "ctrl+alt+a",
		"data_channels": ["memory", "record", "timeline"]
	}
}

# Drive connection states
var drive_connections = {
	"C_to_D": false,
	"D_to_C": false,
	"C_to_cloud": false,
	"D_to_cloud": false
}

# Active application connections
var active_connections = {}
var active_bridges = {}
var data_channels = {}

# I/O statistics
var transfer_stats = {
	"bytes_sent": 0,
	"bytes_received": 0,
	"successful_transfers": 0,
	"failed_transfers": 0
}

# Global shortcut registration system
var global_shortcuts = {}
var shortcut_handler = null

# Signals
signal connector_initialized(status)
signal app_connected(app_name)
signal app_disconnected(app_name)
signal drive_connected(source, target)
signal data_transferred(source, target, bytes)
signal shortcut_triggered(shortcut_name)

# Initialization
func _ready():
	print("Universal Connector initializing...")
	
	# Perform startup checks
	var startup_status = _check_system_requirements()
	if startup_status.success:
		print("System requirements satisfied")
	else:
		push_error("System requirements not met: " + startup_status.error)
	
	# Initialize shortcut system
	_init_shortcut_system()
	
	# Setup initial connections
	_setup_initial_connections()
	
	# Register global shortcuts
	_register_global_shortcuts()
	
	print("Universal Connector v" + CONNECTOR_VERSION + " initialized")
	emit_signal("connector_initialized", startup_status)

# Setup shortcuts
func _init_shortcut_system():
	shortcut_handler = Node.new()
	shortcut_handler.name = "ShortcutHandler"
	add_child(shortcut_handler)
	
	# Connect input handling
	set_process_input(true)

# Input handling for shortcuts
func _input(event):
	if event is InputEventKey and event.pressed:
		# Check for registered shortcuts
		for shortcut_name in global_shortcuts:
			var shortcut = global_shortcuts[shortcut_name]
			
			if _is_shortcut_match(event, shortcut):
				_trigger_shortcut(shortcut_name)
				# Prevent event propagation
				get_tree().set_input_as_handled()

# Connect to an application
func connect_app(app_name):
	if not APP_CONNECTIONS.has(app_name):
		push_error("Unknown application: " + app_name)
		return false
	
	# Check if already connected
	if active_connections.has(app_name) and active_connections[app_name]:
		print("Application already connected: " + app_name)
		return true
	
	var app_info = APP_CONNECTIONS[app_name]
	print("Connecting to " + app_name + " at " + app_info.path)
	
	# Create bridge object based on app type
	var bridge = null
	
	if app_name == "claude":
		bridge = _create_claude_bridge(app_info)
	elif app_name == "windows":
		bridge = _create_windows_bridge(app_info)
	elif app_name == "godot":
		bridge = Node.new() # Native connection
	elif app_name == "terminal":
		bridge = _create_terminal_bridge(app_info)
	elif app_name == "ethereal_engine":
		bridge = _create_ethereal_bridge(app_info)
	elif app_name == "akashic_records":
		bridge = _create_akashic_bridge(app_info)
	
	if bridge:
		# Store bridge
		active_bridges[app_name] = bridge
		add_child(bridge)
		
		# Mark as connected
		active_connections[app_name] = true
		
		# Setup data channels
		_setup_data_channels(app_name, app_info.data_channels)
		
		emit_signal("app_connected", app_name)
		print("Successfully connected to " + app_name)
		return true
	else:
		push_error("Failed to create bridge for " + app_name)
		return false

# Disconnect from an application
func disconnect_app(app_name):
	if not active_connections.has(app_name) or not active_connections[app_name]:
		print("Application not connected: " + app_name)
		return false
	
	# Close data channels
	if data_channels.has(app_name):
		for channel in data_channels[app_name]:
			data_channels[app_name][channel] = null
		data_channels.erase(app_name)
	
	# Remove bridge
	if active_bridges.has(app_name):
		var bridge = active_bridges[app_name]
		remove_child(bridge)
		bridge.queue_free()
		active_bridges.erase(app_name)
	
	# Mark as disconnected
	active_connections[app_name] = false
	
	emit_signal("app_disconnected", app_name)
	print("Disconnected from " + app_name)
	return true

# Connect drives
func connect_drives(source_drive, target_drive):
	var connection_key = source_drive + "_to_" + target_drive
	
	if not drive_connections.has(connection_key):
		push_error("Invalid drive connection: " + connection_key)
		return false
	
	# Check if already connected
	if drive_connections[connection_key]:
		print("Drives already connected: " + source_drive + " to " + target_drive)
		return true
	
	# Get drive paths
	var source_path = DRIVE_PATHS.get(source_drive, "")
	var target_path = DRIVE_PATHS.get(target_drive, "")
	
	if source_path.empty() or target_path.empty():
		push_error("Invalid drive paths")
		return false
	
	print("Connecting drive " + source_drive + " to " + target_drive)
	
	# Create symbolic link (simulation - in real implementation would require OS-specific commands)
	var success = _create_drive_connection(source_path, target_path)
	
	if success:
		drive_connections[connection_key] = true
		emit_signal("drive_connected", source_drive, target_drive)
		print("Successfully connected drive " + source_drive + " to " + target_drive)
	else:
		push_error("Failed to connect drives")
	
	return success

# Transfer data between applications
func transfer_data(source_app, target_app, channel, data):
	if not active_connections.has(source_app) or not active_connections[source_app]:
		push_error("Source application not connected: " + source_app)
		return null
	
	if not active_connections.has(target_app) or not active_connections[target_app]:
		push_error("Target application not connected: " + target_app)
		return null
	
	# Check if channel exists in both apps
	var source_channels = APP_CONNECTIONS[source_app].data_channels
	var target_channels = APP_CONNECTIONS[target_app].data_channels
	
	if not source_channels.has(channel) or not target_channels.has(channel):
		push_error("Channel " + channel + " not supported by both applications")
		return null
	
	# Calculate data size (approximate for non-string data)
	var data_size = typeof(data) == TYPE_STRING ? data.length() : data.size()
	
	print("Transferring " + str(data_size) + " bytes from " + source_app + " to " + target_app + " via " + channel)
	
	# Process data through source app's channel
	var processed_data = _process_outgoing_data(source_app, channel, data)
	
	if processed_data == null:
		transfer_stats.failed_transfers += 1
		push_error("Failed to process outgoing data")
		return null
	
	# Transfer to target app's channel
	var result = _process_incoming_data(target_app, channel, processed_data)
	
	if result != null:
		transfer_stats.bytes_sent += data_size
		transfer_stats.bytes_received += (typeof(result) == TYPE_STRING ? result.length() : result.size())
		transfer_stats.successful_transfers += 1
		
		emit_signal("data_transferred", source_app, target_app, data_size)
		print("Data transfer successful")
	else:
		transfer_stats.failed_transfers += 1
		push_error("Failed to process incoming data")
	
	return result

# Register a global shortcut
func register_shortcut(name, shortcut_str, callback_object, callback_method):
	if global_shortcuts.has(name):
		push_error("Shortcut already registered: " + name)
		return false
	
	# Parse shortcut string
	var shortcut = _parse_shortcut(shortcut_str)
	if shortcut == null:
		push_error("Invalid shortcut format: " + shortcut_str)
		return false
	
	# Store shortcut with callback info
	global_shortcuts[name] = {
		"keys": shortcut,
		"object": callback_object,
		"method": callback_method,
		"shortcut_str": shortcut_str
	}
	
	print("Registered shortcut: " + name + " (" + shortcut_str + ")")
	return true

# Trigger the universal connector (main shortcut)
func trigger_universal_connector():
	print("Universal Connector triggered!")
	
	# Show UI for selecting app connections
	_show_connection_ui()
	
	return true

# Get connector status
func get_status():
	var status = {
		"version": CONNECTOR_VERSION,
		"active_connections": active_connections.duplicate(),
		"drive_connections": drive_connections.duplicate(),
		"transfer_stats": transfer_stats.duplicate(),
		"registered_shortcuts": global_shortcuts.keys()
	}
	
	return status

# Implementation-specific methods

func _check_system_requirements():
	var requirements_met = true
	var error_message = ""
	
	# Check for required directories
	var dir = Directory.new()
	
	for drive_key in DRIVE_PATHS:
		var path = DRIVE_PATHS[drive_key]
		if not dir.dir_exists(path):
			requirements_met = false
			error_message = "Drive path not found: " + path
			break
	
	# Check for required files/applications
	for app_name in APP_CONNECTIONS:
		var app_info = APP_CONNECTIONS[app_name]
		var app_path = app_info.path
		
		# Skip checks for special apps
		if app_name == "godot" or app_name == "windows":
			continue
		
		if not dir.file_exists(app_path) and not dir.dir_exists(app_path):
			print("Warning: App path not found: " + app_path + " - will attempt to create bridge anyway")
	
	return {
		"success": requirements_met,
		"error": error_message
	}

func _setup_initial_connections():
	# Connect to core apps
	connect_app("godot") # Native connection
	
	# Try to connect to other important apps
	for app_name in ["claude", "terminal", "ethereal_engine"]:
		if APP_CONNECTIONS.has(app_name):
			connect_app(app_name)
	
	# Setup C to D drive connection if both exist
	if DRIVE_PATHS.has("C") and DRIVE_PATHS.has("D"):
		connect_drives("C", "D")
		connect_drives("D", "C")

func _register_global_shortcuts():
	# Register main universal connector shortcut
	register_shortcut("universal_connector", DEFAULT_SHORTCUT, self, "trigger_universal_connector")
	
	# Register app-specific shortcuts
	for app_name in APP_CONNECTIONS:
		var app_info = APP_CONNECTIONS[app_name]
		if app_info.has("shortcut"):
			register_shortcut(app_name + "_connector", app_info.shortcut, self, "connect_app_from_shortcut")

func _setup_data_channels(app_name, channel_list):
	if not data_channels.has(app_name):
		data_channels[app_name] = {}
	
	for channel in channel_list:
		data_channels[app_name][channel] = null

func _is_shortcut_match(event, shortcut):
	# Check if the event matches the shortcut keys
	if not shortcut.has("keys"):
		return false
	
	var keys = shortcut.keys
	
	# Check modifiers
	if keys.ctrl != event.control:
		return false
	if keys.alt != event.alt:
		return false
	if keys.shift != event.shift:
		return false
	if keys.meta != event.meta:
		return false
	
	# Check key
	if keys.key != event.scancode:
		return false
	
	return true

func _trigger_shortcut(shortcut_name):
	if not global_shortcuts.has(shortcut_name):
		return false
	
	var shortcut = global_shortcuts[shortcut_name]
	
	print("Triggered shortcut: " + shortcut_name + " (" + shortcut.shortcut_str + ")")
	emit_signal("shortcut_triggered", shortcut_name)
	
	# Call the callback function
	if shortcut.object != null and shortcut.method != "":
		if shortcut.object.has_method(shortcut.method):
			# Call the method
			var result = shortcut.object.call(shortcut.method)
			return result
	
	return false

func _parse_shortcut(shortcut_str):
	if shortcut_str.empty():
		return null
	
	var parts = shortcut_str.to_lower().split("+")
	var result = {
		"ctrl": false,
		"alt": false,
		"shift": false,
		"meta": false,
		"key": 0
	}
	
	for part in parts:
		part = part.strip_edges()
		
		match part:
			"ctrl":
				result.ctrl = true
			"alt":
				result.alt = true
			"shift":
				result.shift = true
			"meta", "cmd", "super":
				result.meta = true
			"space":
				result.key = KEY_SPACE
			"c":
				result.key = KEY_C
			"d":
				result.key = KEY_D
			"e":
				result.key = KEY_E
			"g":
				result.key = KEY_G
			"t":
				result.key = KEY_T
			"w":
				result.key = KEY_W
			"a":
				result.key = KEY_A
			_:
				# Try to parse as a key name
				if part.length() == 1:
					result.key = ord(part[0])
	
	return result

func _show_connection_ui():
	# In a real implementation, this would show a UI for selecting app connections
	print("Connection UI would appear here")
	print("Available applications:")
	
	for app_name in APP_CONNECTIONS:
		var status = "Disconnected"
		if active_connections.has(app_name) and active_connections[app_name]:
			status = "Connected"
		
		print("- " + app_name + ": " + status)
	
	print("\nDrive connections:")
	for connection in drive_connections:
		var status = "Inactive"
		if drive_connections[connection]:
			status = "Active"
		
		print("- " + connection + ": " + status)

func connect_app_from_shortcut(app_name = ""):
	# This function is called by registered shortcuts
	
	# Find which app corresponds to the triggered shortcut
	if app_name.empty():
		for name in APP_CONNECTIONS:
			var shortcut_name = name + "_connector"
			if global_shortcuts.has(shortcut_name) and global_shortcuts[shortcut_name].object == self:
				app_name = name
				break
	
	if app_name.empty():
		push_error("Could not determine app name from shortcut")
		return false
	
	# Connect or disconnect app
	if active_connections.has(app_name) and active_connections[app_name]:
		return disconnect_app(app_name)
	else:
		return connect_app(app_name)

# Bridge creation methods

func _create_claude_bridge(app_info):
	var bridge = Node.new()
	bridge.name = "ClaudeBridge"
	
	print("Created bridge to Claude")
	
	# In a real implementation, would load the claude_akashic_bridge.gd script
	# and initialize API key from app_info.api_key_path
	
	return bridge

func _create_windows_bridge(app_info):
	var bridge = Node.new()
	bridge.name = "WindowsBridge"
	
	print("Created bridge to Windows")
	
	# In a real implementation, would load the windows_connector.dll
	
	return bridge

func _create_terminal_bridge(app_info):
	var bridge = Node.new()
	bridge.name = "TerminalBridge"
	
	print("Created bridge to Terminal")
	
	# In a real implementation, would load the terminal_api_bridge.gd script
	
	return bridge

func _create_ethereal_bridge(app_info):
	var bridge = Node.new()
	bridge.name = "EtherealBridge"
	
	print("Created bridge to Ethereal Engine")
	
	# In a real implementation, would load the ethereal_engine.gd script
	
	return bridge

func _create_akashic_bridge(app_info):
	var bridge = Node.new()
	bridge.name = "AkashicBridge"
	
	print("Created bridge to Akashic Records")
	
	# In a real implementation, would load the akashic_database.js via a JS interface
	
	return bridge

func _create_drive_connection(source_path, target_path):
	# In a real implementation, this would create a symbolic link or other connection
	print("Simulating drive connection from " + source_path + " to " + target_path)
	
	# Always return success in this simplified implementation
	return true

func _process_outgoing_data(app_name, channel, data):
	print("Processing outgoing data from " + app_name + " via " + channel)
	
	# In a real implementation, would process data through app-specific adapters
	
	return data

func _process_incoming_data(app_name, channel, data):
	print("Processing incoming data to " + app_name + " via " + channel)
	
	# In a real implementation, would process data through app-specific adapters
	
	return data

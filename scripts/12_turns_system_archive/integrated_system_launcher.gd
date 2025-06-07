extends Node

# Integrated System Launcher
# This script connects all components and launches the integrated system

# System components
var akashic_bridge = null
var storage_system = null
var terminal_interface = null

# Configuration
var config = {
	"auto_initialize": true,
	"default_interface": "terminal", # terminal, notepad3d, browser
	"debug_mode": false,
	"starting_turn": 1,
	"max_wish_tokens": 10000,
	"show_welcome": true
}

# Signal for system ready
signal system_ready
signal interface_ready(interface_name)

func _ready():
	# Initialize the integrated system
	if config.auto_initialize:
		initialize_system()

func initialize_system():
	print("Initializing Integrated System...")
	
	# Ensure proper initialization order
	initialize_akashic_bridge()
	initialize_storage_system()
	initialize_terminal_interface()
	
	# Connect signals between components
	connect_signals()
	
	# Set initial interface
	set_interface(config.default_interface)
	
	# Show welcome message
	if config.show_welcome:
		show_welcome()
	
	print("Integrated System initialized successfully")
	emit_signal("system_ready")

# Component initialization
func initialize_akashic_bridge():
	akashic_bridge = ClaudeAkashicBridge.new()
	add_child(akashic_bridge)
	print("Akashic Bridge initialized")
	
	# Set firewall level based on turn
	var firewall_level = "standard"
	if config.starting_turn > 7:
		firewall_level = "divine"
	elif config.starting_turn > 3:
		firewall_level = "enhanced"
	
	akashic_bridge.update_firewall(firewall_level, {
		"dimension_access": config.starting_turn
	})

func initialize_storage_system():
	storage_system = StorageIntegrationSystem.new()
	add_child(storage_system)
	print("Storage Integration System initialized")

func initialize_terminal_interface():
	terminal_interface = UnifiedTerminalInterface.new()
	add_child(terminal_interface)
	print("Unified Terminal Interface initialized")

# Signal connections
func connect_signals():
	# Storage System signals
	if storage_system:
		storage_system.connect("storage_connected", self, "_on_storage_connected")
		storage_system.connect("wish_created", self, "_on_wish_created")
		storage_system.connect("wish_completed", self, "_on_wish_completed")
	
	# Akashic Bridge signals
	if akashic_bridge:
		akashic_bridge.connect("word_stored", self, "_on_word_stored")
		akashic_bridge.connect("gate_status_changed", self, "_on_gate_status_changed")
		akashic_bridge.connect("wish_updated", self, "_on_wish_updated")
		akashic_bridge.connect("firewall_breached", self, "_on_firewall_breached")
	
	# Terminal Interface signals
	if terminal_interface:
		terminal_interface.connect("command_executed", self, "_on_command_executed")
		terminal_interface.connect("wish_processed", self, "_on_wish_processed")
		terminal_interface.connect("interface_changed", self, "_on_interface_changed")
		terminal_interface.connect("terminal_ready", self, "_on_terminal_ready")

# Interface switching
func set_interface(interface_name):
	match interface_name:
		"terminal":
			print("Setting interface to terminal")
			# In actual implementation, this would show terminal interface
		"notepad3d":
			print("Setting interface to Notepad 3D")
			# In actual implementation, this would show 3D notepad
		"browser":
			print("Setting interface to browser")
			# In actual implementation, this would show browser interface
		_:
			print("Unknown interface: " + interface_name)
	
	emit_signal("interface_ready", interface_name)

# Welcome message
func show_welcome():
	if terminal_interface:
		# Terminal interface handles its own welcome message
		pass
	else:
		print("Welcome to the Integrated System")
		print("Current Turn: " + str(config.starting_turn))
		print("Use the terminal interface for commands")

# Process wishes
func process_wish(wish_text, priority = "normal", metadata = {}):
	if storage_system:
		var wish = storage_system.create_wish(wish_text, priority, metadata)
		
		if wish and akashic_bridge:
			# Update wish in Akashic Records
			akashic_bridge.update_wish(wish.id, "pending", {
				"text": wish_text,
				"priority": priority,
				"created": OS.get_unix_time()
			})
		
		return wish
	
	return null

# Execute terminal commands
func execute_command(command):
	if terminal_interface:
		terminal_interface.process_command(command)
	else:
		print("Terminal interface not available")

# Signal handlers
func _on_storage_connected(platform, status):
	print("Storage connected: " + platform + " - " + str(status))

func _on_wish_created(wish_id, wish_text):
	print("Wish created: " + wish_id + " - " + wish_text)

func _on_wish_completed(wish_id):
	print("Wish completed: " + wish_id)

func _on_word_stored(word, power, metadata):
	print("Word stored: " + word + " (power: " + str(power) + ")")

func _on_gate_status_changed(gate_name, status):
	print("Gate status changed: " + gate_name + " - " + str(status))

func _on_wish_updated(wish_id, new_status):
	print("Wish updated: " + wish_id + " -> " + new_status)

func _on_firewall_breached(breach_info):
	print("FIREWALL BREACH: " + breach_info.type + " - " + breach_info.message)

func _on_command_executed(command, result):
	if config.debug_mode:
		print("Command executed: " + command)

func _on_wish_processed(wish_id, result):
	print("Wish processed: " + wish_id)

func _on_interface_changed(interface_name):
	print("Interface changed to: " + interface_name)

func _on_terminal_ready():
	print("Terminal interface ready")

# Public API
func create_wish(wish_text, priority = "normal"):
	return process_wish(wish_text, priority)

func run_command(command):
	return execute_command(command)

func connect_cloud_storage(service, credentials = {}):
	if storage_system:
		return storage_system.connect_cloud_storage(service, credentials)
	return false

func get_system_status():
	var status = {
		"akashic_bridge": akashic_bridge != null,
		"storage_system": storage_system != null,
		"terminal_interface": terminal_interface != null,
		"current_turn": config.starting_turn
	}
	
	# Add storage status if available
	if storage_system:
		status["storage"] = storage_system.get_storage_status()
	
	# Add akashic status if available
	if akashic_bridge:
		status["akashic"] = akashic_bridge.get_status()
	
	return status
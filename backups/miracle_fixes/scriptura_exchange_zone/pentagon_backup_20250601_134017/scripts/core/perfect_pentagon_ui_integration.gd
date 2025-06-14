# 🏛️ Perfect Pentagon Ui Integration - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

################################################################
# PERFECT PENTAGON UI INTEGRATION SYSTEM
# Unified initialization for all UI components through Pentagon
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/core/perfect_pentagon_ui_integration.gd
################################################################

extends UniversalBeingBase
################################################################
# PERFECT PENTAGON UI COORDINATOR
################################################################

var ui_systems: Dictionary = {}
var initialization_order: Array[String] = []
var pentagon_ui_ready: bool = false

func _ready():
	print("🎨 PENTAGON UI: Coordinating UI system initialization...")
	
	# Wait for Perfect Pentagon to be ready
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_signal("all_ready_complete"):
			perfect_ready.all_ready_complete.connect(_on_pentagon_ready)
		
		# Register self with Pentagon system
		if perfect_ready.has_method("register_ready"):
			perfect_ready.register_ready("PentagonUIIntegration", _pentagon_ui_init, ["PerfectInit", "PerfectReady"])

func _pentagon_ui_init():
	"""Initialize UI integration through Perfect Pentagon"""
	print("🎯 PENTAGON UI: Perfect Pentagon initialization complete")
	pentagon_ui_ready = true
	
	# Register all UI systems
	_register_ui_systems()
	
	# Initialize UI systems in proper order
	_initialize_ui_systems()

################################################################
# UI SYSTEM REGISTRATION
################################################################

func _register_ui_systems():
	"""Register all UI systems for Perfect Pentagon coordination"""
	
	# Universal Being Creator Interface
	ui_systems["UniversalBeingCreator"] = {
		"autoload_path": "/root/UniversalBeingCreatorUI",
		"dependencies": ["UniversalObjectManager", "AISandboxSystem"],
		"initialization_method": "_perfect_pentagon_init",
		"priority": 1,
		"ui_type": "creation_interface"
	}
	
	# Gemma Vision Interface (future)
	ui_systems["GemmaVisionUI"] = {
		"autoload_path": "/root/GemmaVisionSystem", 
		"dependencies": ["AISandboxSystem", "GemmaVisionSystem"],
		"initialization_method": "_pentagon_ui_init",
		"priority": 2,
		"ui_type": "ai_interface"
	}
	
	# Console Manager (already exists, integrate better)
	ui_systems["ConsoleManager"] = {
		"autoload_path": "/root/ConsoleManager",
		"dependencies": ["PerfectInit"],
		"initialization_method": "_pentagon_integration",
		"priority": 0,
		"ui_type": "debug_interface"
	}
	
	print("🎨 PENTAGON UI: Registered %d UI systems" % ui_systems.size())

func _initialize_ui_systems():
	"""Initialize UI systems in dependency order"""
	
	# Sort by priority
	var sorted_systems = []
	for system_name in ui_systems:
		var system_data = ui_systems[system_name]
		system_data["name"] = system_name
		sorted_systems.append(system_data)
	
	sorted_systems.sort_custom(_compare_priority)
	
	# Initialize in order
	for system_data in sorted_systems:
		_initialize_single_ui_system(system_data)

func _compare_priority(a: Dictionary, b: Dictionary) -> bool:
	"""Compare UI system priorities for sorting"""
	return a.priority < b.priority

func _initialize_single_ui_system(system_data: Dictionary):
	"""Initialize a single UI system through Pentagon"""
	
	var system_name = system_data.name
	var autoload_path = system_data.autoload_path
	
	if has_node(autoload_path):
		var ui_system = get_node(autoload_path)
		var init_method = system_data.initialization_method
		
		if ui_system.has_method(init_method):
			print("🎯 PENTAGON UI: Initializing %s..." % system_name)
			ui_system.call(init_method)
			initialization_order.append(system_name)
		else:
			print("⚠️ PENTAGON UI: %s missing method %s" % [system_name, init_method])
	else:
		print("⚠️ PENTAGON UI: %s not found at %s" % [system_name, autoload_path])

################################################################
# PENTAGON INTEGRATION HELPERS
################################################################


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
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
func register_ui_system(name: String, config: Dictionary):
	"""Allow external registration of UI systems"""
	ui_systems[name] = config
	print("📝 PENTAGON UI: Registered external UI system: " + name)

func get_ui_system_status() -> Dictionary:
	"""Get status of all UI systems"""
	var status = {
		"pentagon_ready": pentagon_ready,
		"total_systems": ui_systems.size(),
		"initialized_systems": initialization_order.size(),
		"systems": {}
	}
	
	for system_name in ui_systems:
		var system_data = ui_systems[system_name]
		var autoload_path = system_data.autoload_path
		var is_ready = has_node(autoload_path) and system_name in initialization_order
		
		status.systems[system_name] = {
			"ready": is_ready,
			"type": system_data.ui_type,
			"priority": system_data.priority
		}
	
	return status

################################################################
# CONSOLE INTEGRATION
################################################################

func _on_pentagon_ready():
	"""Called when Perfect Pentagon completes initialization"""
	print("🎉 PENTAGON UI: Perfect Pentagon ready - UI systems can now initialize")
	
	# Add console commands for UI management
	_register_ui_console_commands()

func _register_ui_console_commands():
	"""Register UI management commands with console"""
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		if "commands" in console:
			console.commands["ui_status"] = _console_ui_status
			console.commands["ui_reload"] = _console_ui_reload
			console.commands["ui_list"] = _console_ui_list
			print("📝 PENTAGON UI: Registered console commands")

func _console_ui_status(_args: Array) -> String:
	"""Console command: Show UI system status"""
	var status = get_ui_system_status()
	var result = """🎨 PENTAGON UI SYSTEM STATUS
═══════════════════════════════
Pentagon Ready: %s
Total Systems: %d
Initialized: %d

UI SYSTEMS:""" % [
		"YES" if status.pentagon_ready else "NO",
		status.total_systems,
		status.initialized_systems
	]
	
	for system_name in status.systems:
		var system_status = status.systems[system_name]
		result += "\n• %s: %s (%s)" % [
			system_name,
			"READY" if system_status.ready else "PENDING",
			system_status.type
		]
	
	return result

func _console_ui_reload(_args: Array) -> String:
	"""Console command: Reload UI systems"""
	_initialize_ui_systems()
	return "🔄 Pentagon UI systems reloaded"

func _console_ui_list(_args: Array) -> String:
	"""Console command: List available UI systems"""
	var result = "🎨 AVAILABLE UI SYSTEMS:\n"
	for system_name in ui_systems:
		var system_data = ui_systems[system_name]
		result += "• %s (%s) - Priority: %d\n" % [
			system_name,
			system_data.ui_type,
			system_data.priority
		]
	return result

################################################################
# END OF PERFECT PENTAGON UI INTEGRATION
################################################################
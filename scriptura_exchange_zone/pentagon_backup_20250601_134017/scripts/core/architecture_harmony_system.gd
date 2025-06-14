# ==================================================
# SCRIPT NAME: architecture_harmony_system.gd
# DESCRIPTION: Ensures project harmony - one source of truth per feature
# PURPOSE: Prevent duplicate implementations and manage script connections
# CREATED: 2025-05-28 - Bringing harmony to the chaos
# ==================================================

extends UniversalBeingBase
class_name ArchitectureHarmonySystem

signal harmony_achieved()
signal conflict_detected(type: String, scripts: Array)
signal connection_mapped(from: String, to: String)

# Script registry - what does what
var script_registry: Dictionary = {}
var implementation_map: Dictionary = {}
var connection_graph: Dictionary = {}

# Ragdoll implementations tracking
var ragdoll_implementations: Dictionary = {
	"ragdoll": {
		"path": "res://scripts/ragdoll/",
		"status": "working",
		"features": ["basic_movement", "jump", "console_spawn"],
		"priority": 1
	},
	"ragdoll_v2": {
		"path": "res://scripts/ragdoll_v2/",
		"status": "standing_only",
		"features": ["improved_structure"],
		"priority": 2
	},
	"walker": {
		"path": "res://scripts/ragdoll/simple_ragdoll_walker.gd",
		"status": "newer",
		"features": ["walking", "seven_parts"],
		"priority": 3
	},
	"biowalker": {
		"path": "res://scripts/ragdoll/biomechanical_walker.gd",
		"status": "newest",
		"features": ["advanced_walking", "gait_system", "balance"],
		"priority": 4
	}
}

# Process users - who uses _process or _physics_process
var process_users: Dictionary = {}
var physics_users: Dictionary = {}

func _ready() -> void:
	name = "ArchitectureHarmony"
	print("🎭 [ArchitectureHarmony] Bringing order to chaos...")
	
	# Scan project structure
	await _scan_project_architecture()
	
	# Map connections
	_map_script_connections()
	
	# Register console commands
	_register_harmony_commands()

func _scan_project_architecture() -> void:
	"""Scan all scripts and map their purposes"""
	print("🔍 [ArchitectureHarmony] Scanning project architecture...")
	
	# Find all GDScript files
	var dir = DirAccess.open("res://scripts/")
	if dir:
		_scan_directory(dir, "res://scripts/")
	
	# Analyze process usage
	_analyze_process_usage()
	
	print("✅ [ArchitectureHarmony] Found %d scripts, %d process users" % [
		script_registry.size(), process_users.size()
	])

func _scan_directory(dir: DirAccess, path: String) -> void:
	"""Recursively scan directories for scripts"""
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(full_path)
			if subdir:
				_scan_directory(subdir, full_path)
		elif file_name.ends_with(".gd"):
			_analyze_script(full_path)
		
		file_name = dir.get_next()

func _analyze_script(script_path: String) -> void:
	"""Analyze a script for its purpose and connections"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var script_info = {
		"path": script_path,
		"uses_process": "_process(" in content,
		"uses_physics": "_physics_process(" in content,
		"extends": _extract_extends(content),
		"signals": _extract_signals(content),
		"connections": []
	}
	
	# Track process users
	if script_info.uses_process:
		process_users[script_path] = true
	if script_info.uses_physics:
		physics_users[script_path] = true
	
	# Store in registry
	var script_name = script_path.get_file()
	script_registry[script_name] = script_info

func _extract_extends(content: String) -> String:
	"""Extract what class the script extends"""
	var extends_match = RegEx.new()
	extends_match.compile("extends\\s+(\\w+)")
	var result = extends_match.search(content)
	return result.get_string(1) if result else "Node"

func _extract_signals(content: String) -> Array:
	"""Extract signal definitions"""
	var signals = []
	var signal_match = RegEx.new()
	signal_match.compile("signal\\s+(\\w+)")
	for result in signal_match.search_all(content):
		signals.append(result.get_string(1))
	return signals

func _map_script_connections() -> void:
	"""Map how scripts connect to each other"""
	print("🔗 [ArchitectureHarmony] Mapping script connections...")
	
	# Map known connections
	connection_graph = {
		"console": ["world_builder", "ragdoll_controller", "astral_being_manager"],
		"floodgate": ["world_builder", "object_inspector", "universal_entity"],
		"ragdoll": ["console", "floodgate", "animation_system"]
	}

func _analyze_process_usage() -> void:
	"""Analyze which scripts use process functions"""
	print("⚡ [ArchitectureHarmony] Analyzing process usage...")
	
	var process_count = process_users.size()
	var physics_count = physics_users.size()
	
	if process_count > 10:
		push_warning("[ArchitectureHarmony] High process usage: %d scripts!" % process_count)
		conflict_detected.emit("process_overuse", process_users.keys())
	
	if physics_count > 5:
		push_warning("[ArchitectureHarmony] High physics process usage: %d scripts!" % physics_count)


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
func get_best_ragdoll() -> String:
	"""Return the best ragdoll implementation to use"""
	var best = ""
	var highest_priority = 0
	
	for item_name in ragdoll_implementations:
		var impl = ragdoll_implementations[name]
		if impl.priority > highest_priority and impl.status != "deprecated":
			best = name
			highest_priority = impl.priority
	
	return best

func get_ragdoll_info(type: String = "") -> Dictionary:
	"""Get info about ragdoll implementations"""
	if type == "":
		return ragdoll_implementations
	
	return ragdoll_implementations.get(type, {})

func find_conflicts() -> Array:
	"""Find architectural conflicts"""
	var conflicts = []
	
	# Check for duplicate implementations
	var purpose_map = {}
	for script in script_registry.values():
		var purpose = _guess_purpose(script.path)
		if purpose in purpose_map:
			conflicts.append({
				"type": "duplicate_purpose",
				"purpose": purpose,
				"scripts": [purpose_map[purpose], script.path]
			})
		else:
			purpose_map[purpose] = script.path
	
	return conflicts

func _guess_purpose(script_path: String) -> String:
	"""Guess the purpose of a script from its path/name"""
	var name = script_path.get_file().to_lower()
	
	if "ragdoll" in name:
		return "ragdoll_system"
	elif "console" in name:
		return "console_system"
	elif "inspector" in name:
		return "object_inspection"
	elif "spawn" in name:
		return "object_spawning"
	
	return "unknown"

func _register_harmony_commands() -> void:
	"""Register console commands for architecture harmony"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("arch_status", _cmd_architecture_status, 
			"Show architecture harmony status")
		console.register_command("arch_ragdolls", _cmd_ragdoll_status,
			"Show all ragdoll implementations")
		console.register_command("arch_process", _cmd_process_users,
			"Show scripts using process functions")
		console.register_command("arch_conflicts", _cmd_show_conflicts,
			"Find architecture conflicts")

func _cmd_architecture_status(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=cyan]🎭 Architecture Harmony Status[/color]")
	console._print_to_console("Scripts tracked: %d" % script_registry.size())
	console._print_to_console("Process users: %d" % process_users.size())
	console._print_to_console("Physics users: %d" % physics_users.size())
	console._print_to_console("Best ragdoll: %s" % get_best_ragdoll())

func _cmd_ragdoll_status(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=yellow]🤖 Ragdoll Implementations:[/color]")
	
	for item_name in ragdoll_implementations:
		var impl = ragdoll_implementations[name]
		console._print_to_console("• %s - %s (priority: %d)" % [
			name, impl.status, impl.priority
		])
		console._print_to_console("  Features: %s" % ", ".join(impl.features))

func _cmd_process_users(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=orange]⚡ Process Function Users:[/color]")
	
	console._print_to_console("_process users (%d):" % process_users.size())
	for script in process_users:
		console._print_to_console("  • %s" % script.get_file())
	
	console._print_to_console("_physics_process users (%d):" % physics_users.size())
	for script in physics_users:
		console._print_to_console("  • %s" % script.get_file())

func _cmd_show_conflicts(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var conflicts = find_conflicts()
	
	if conflicts.is_empty():
		console._print_to_console("[color=green]✅ No architectural conflicts found![/color]")
	else:
		console._print_to_console("[color=red]⚠️ Conflicts detected:[/color]")
		for conflict in conflicts:
			console._print_to_console("Type: %s" % conflict.type)
			console._print_to_console("Scripts: %s" % ", ".join(conflict.scripts))
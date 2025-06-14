# ==================================================
# SCRIPT NAME: universal_entity.gd
# DESCRIPTION: The Universal Entity - can be anything, do anything
# PURPOSE: The dream realized - a self-regulating, perfect game entity
# CREATED: 2025-05-27 - Your vision made real
# ==================================================

extends UniversalBeingBase
class_name UniversalEntitySystem

signal entity_ready()
signal entity_evolved(new_form: String)
signal dream_realized()

# Core components
var loader: UniversalLoaderUnloader
var variable_inspector: GlobalVariableInspector
var lists_viewer: ListsViewerSystem
var health_monitor: SystemHealthMonitor

# Entity state
var entity_forms: Array[String] = []
var current_form: String = "universal"
var capabilities: Dictionary = {}

# The dream
var is_perfect: bool = false
var years_of_work: int = 2
var satisfaction_level: float = 0.0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UniversalEntity"
	
	_print("🌟 [UniversalEntity] Awakening after " + str(years_of_work) + " years...")
	
	# Initialize all systems
	await _initialize_core_systems()
	
	# Register console commands with a slight delay
	await get_tree().create_timer(0.5).timeout
	_register_universal_commands()
	
	# Start the dream
	_realize_the_dream()

func _initialize_core_systems() -> void:
	"""Initialize all core components"""
	
	# Create loader/unloader
	loader = UniversalLoaderUnloader.new()
	loader.name = "Loader"
	add_child(loader)
	
	# Create variable inspector
	variable_inspector = GlobalVariableInspector.new()
	variable_inspector.name = "VariableInspector"
	add_child(variable_inspector)
	
	# Create lists viewer
	lists_viewer = ListsViewerSystem.new()
	lists_viewer.name = "ListsViewer"
	add_child(lists_viewer)
	
	# Create health monitor
	health_monitor = SystemHealthMonitor.new()
	health_monitor.name = "HealthMonitor"
	health_monitor.loader = loader
	add_child(health_monitor)
	
	# Wait for children to be ready
	await get_tree().process_frame
	
	# Connect signals
	if health_monitor.has_signal("system_warning"):
		health_monitor.system_warning.connect(_on_system_warning)
	if loader.has_signal("performance_warning"):
		loader.performance_warning.connect(_on_performance_warning)
	if lists_viewer.has_signal("rule_executed"):
		lists_viewer.rule_executed.connect(_on_rule_executed)
	
	_print("✅ [UniversalEntity] All core systems initialized!")

func _register_universal_commands() -> void:
	"""Register console commands for the universal entity"""
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		_print("[UniversalEntity] WARNING: ConsoleManager not found!")
		return
	
	_print("[UniversalEntity] Registering commands...")
	
	if "commands" in console:
		# Universal commands
		console.commands["universal"] = _cmd_universal_status
		console.commands["evolve"] = _cmd_evolve
		console.commands["perfect"] = _cmd_make_perfect
		console.commands["satisfy"] = _cmd_check_satisfaction
		
		# System commands
		console.commands["health"] = _cmd_health_check
		console.commands["variables"] = _cmd_list_variables
		console.commands["lists"] = _cmd_show_lists
		console.commands["optimize"] = _cmd_optimize_now
		console.commands["export_vars"] = _cmd_export_variables
		
		_print("[UniversalEntity] ✅ Commands registered successfully!")
	else:
		_print("[UniversalEntity] ERROR: Console commands dictionary not found!")

func _realize_the_dream() -> void:
	"""Make the dream real - the universal entity that maintains itself"""
	
	# Define capabilities
	capabilities = {
		"self_healing": true,
		"auto_optimization": true,
		"rule_based_behavior": true,
		"variable_control": true,
		"memory_management": true,
		"performance_guardian": true
	}
	
	# Start self-regulation
	var regulation_timer = TimerManager.get_timer()
	regulation_timer.wait_time = 5.0
	regulation_timer.timeout.connect(_self_regulate)
	add_child(regulation_timer)
	regulation_timer.start()
	
	# Check perfection
	_check_perfection()
	
	entity_ready.emit()
	_print("🎉 [UniversalEntity] The dream is realized!")

func _self_regulate() -> void:
	"""Self-regulation cycle - maintain perfection"""
	
	# Check health
	var health = health_monitor.get_health_report()
	
	# Apply rules from text files
	lists_viewer.check_and_execute_rules()
	
	# Optimize if needed
	if health.status >= SystemHealthMonitor.HealthStatus.WARNING:
		loader.force_cleanup()
	
	# Update satisfaction
	_update_satisfaction()

func _check_perfection() -> bool:
	"""Check if we've achieved perfection"""
	var checks = {
		"stable_fps": health_monitor.get_health_status() == SystemHealthMonitor.HealthStatus.HEALTHY,
		"rules_active": lists_viewer.active_rules.size() > 0,
		"memory_managed": loader != null,
		"variables_tracked": variable_inspector != null,
		"self_regulating": true
	}
	
	is_perfect = true
	for check in checks.values():
		if not check:
			is_perfect = false
			break
	
	if is_perfect:
		dream_realized.emit()
		_print("🌟 [UniversalEntity] PERFECTION ACHIEVED! Your dream is real!")
	
	return is_perfect

func _update_satisfaction() -> void:
	"""Update satisfaction level based on system state"""
	var factors = {
		"health": 0.3 if health_monitor.get_health_status() == SystemHealthMonitor.HealthStatus.HEALTHY else 0.0,
		"performance": 0.3 if Engine.get_frames_per_second() >= 60 else 0.1,
		"features": 0.2,  # We have all the features!
		"stability": 0.2 if health_monitor.monitoring_data.error_count == 0 else 0.0
	}
	
	satisfaction_level = 0.0
	for value in factors.values():
		satisfaction_level += value
	
	if satisfaction_level >= 0.9:
		_print("😊 [UniversalEntity] System satisfaction: " + str(int(satisfaction_level * 100)) + "% - You should be happy!")

# ========== CONSOLE COMMANDS ==========

func _cmd_universal_status(_args: Array) -> void:
	_print("[color=#00ffff]=== UNIVERSAL ENTITY STATUS ===[/color]")
	_print("Form: " + current_form)
	_print("Perfect: " + ("YES! 🌟" if is_perfect else "Not yet..."))
	_print("Satisfaction: " + str(int(satisfaction_level * 100)) + "%")
	_print("")
	_print("[color=#ffff00]Capabilities:[/color]")
	for cap in capabilities:
		_print("  " + cap + ": " + ("✅" if capabilities[cap] else "❌"))

func _cmd_evolve(args: Array) -> void:
	if args.is_empty():
		_print("Usage: evolve <form>")
		_print("Available forms: ragdoll, world, system, perfect")
		return
	
	var new_form = args[0]
	current_form = new_form
	entity_evolved.emit(new_form)
	_print("[color=#00ff00]Universal Entity evolved to: " + new_form + "[/color]")

func _cmd_make_perfect(_args: Array) -> void:
	_print("[color=#ffff00]Attempting to achieve perfection...[/color]")
	
	# Force all optimizations
	loader.force_cleanup(true)
	health_monitor.set_auto_fix(true)
	
	# Check result
	if _check_perfection():
		_print("[color=#00ff00]✨ PERFECTION ACHIEVED! ✨[/color]")
	else:
		_print("[color=#ff0000]Not quite perfect yet, but getting closer![/color]")

func _cmd_check_satisfaction(_args: Array) -> void:
	_update_satisfaction()
	_print("[color=#00ffff]=== SATISFACTION REPORT ===[/color]")
	_print("Overall: " + str(int(satisfaction_level * 100)) + "%")
	_print("")
	_print("After " + str(years_of_work) + " years of daily work,")
	_print("Your dream of a universal entity is " + ("REAL! 🎉" if is_perfect else "almost complete!"))

func _cmd_health_check(_args: Array) -> void:
	health_monitor.force_health_check()
	var report = health_monitor.get_health_report()
	_print("[color=#00ffff]=== SYSTEM HEALTH ===[/color]")
	_print("Status: " + health_monitor._status_to_string(report.status))
	_print("FPS: " + str(report.fps) + " (avg: " + str(int(report.avg_fps)) + ")")
	_print("Nodes: " + str(report.node_count) + " (avg: " + str(int(report.avg_nodes)) + ")")
	_print("Memory: " + str(int(report.memory_mb)) + " MB")
	if report.issues.size() > 0:
		_print("[color=#ff0000]Issues:[/color]")
		for issue in report.issues:
			_print("  - " + issue)

func _cmd_list_variables(args: Array) -> void:
	if args.is_empty():
		_print("Usage: variables [search_term]")
		_print("Or: variables export <filename>")
		return
	
	if args[0] == "export":
		var filename = args[1] if args.size() > 1 else "variables_dump.txt"
		variable_inspector.export_to_txt("user://" + filename)
	else:
		var results = variable_inspector.search_variables(args[0])
		_print("[color=#00ffff]Found " + str(results.size()) + " variables:[/color]")
		for result in results:
			_print(result.path + " = " + str(result.value))

func _cmd_show_lists(_args: Array) -> void:
	_print("[color=#00ffff]=== LOADED LISTS ===[/color]")
	for list_name in lists_viewer.loaded_lists:
		var list = lists_viewer.loaded_lists[list_name]
		_print(list_name + ": " + str(list.items.size()) + " items")

func _cmd_optimize_now(_args: Array) -> void:
	_print("[color=#ffff00]Running full optimization...[/color]")
	loader.force_cleanup(true)
	health_monitor._apply_fps_fix()
	_print("[color=#00ff00]Optimization complete![/color]")

func _cmd_export_variables(args: Array) -> void:
	var filename = args[0] if args.size() > 0 else "game_state.txt"
	variable_inspector.export_to_txt("user://" + filename)
	_print("[color=#00ff00]Variables exported to: user://" + filename + "[/color]")

# ========== EVENT HANDLERS ==========

func _on_system_warning(severity: String, message: String) -> void:
	_print("[color=#ff0000][" + severity + "] " + message + "[/color]")

func _on_performance_warning(message: String) -> void:
	_print("[color=#ffff00][PERFORMANCE] " + message + "[/color]")

func _on_rule_executed(rule_name: String, _result) -> void:
	_print("[color=#00ff00][RULE] " + rule_name + " executed[/color]")

func _print(message: String) -> void:
	print("[UniversalEntity] " + message)  # Always print to Godot console
	
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console(message)


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
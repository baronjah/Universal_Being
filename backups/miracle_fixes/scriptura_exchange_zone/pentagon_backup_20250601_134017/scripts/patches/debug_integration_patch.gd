# 🏛️ Debug Integration Patch - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Debug Integration Patch
# Integrates DebugManager with all print statements

var original_print = null
var debug_manager = null

func _ready():
	# Wait for DebugManager to be available
	await get_tree().process_frame
	
	debug_manager = get_node_or_null("/root/DebugManager")
	if not debug_manager:
		push_error("DebugManager not found!")
		return
	
	print("[DebugIntegration] Patching print statements to use DebugManager")
	
	# Hook into console manager
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager:
		patch_console_manager(console_manager)
	
	# Hook into JSH systems
	patch_jsh_systems()
	
	# Add console commands
	add_debug_commands()


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
func patch_console_manager(_console: Node):
	# Hook into console output instead of trying to override methods
	# Since we can't assign callables to non-@export properties
	pass

func patch_jsh_systems():
	# Patch JSH Scene Tree System
	var jsh_tree = get_node_or_null("/root/JSHSceneTree")
	if jsh_tree:
		# Set debug_verbose to false to reduce spam
		if "debug_verbose" in jsh_tree:
			jsh_tree.debug_verbose = false
			print("[DebugIntegration] Disabled JSH tree verbose mode")
	
	# Patch Performance Guardian
	var perf_guardian = get_node_or_null("/root/PerformanceGuardian")
	if perf_guardian and perf_guardian.has_method("set_verbose"):
		perf_guardian.set_verbose(false)
		print("[DebugIntegration] Disabled Performance Guardian verbose mode")

func add_debug_commands():
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if not console_manager:
		return
	
	# Add debug command
	if not console_manager.commands.has("debug"):
		console_manager.commands["debug"] = func(args: Array):
			return debug_manager._on_console_command("debug", args)
	
	# Add spam toggle command
	if not console_manager.commands.has("spam"):
		console_manager.commands["spam"] = func(args: Array):
			return debug_manager._on_console_command("spam", args)
	
	print("[DebugIntegration] Added debug commands to console")

# Global print override
func _init():
	# This runs before _ready, so we can capture early prints
	set_process(false)
	set_physics_process(false)
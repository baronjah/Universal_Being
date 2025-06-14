# 🏛️ Startup Diagnostic - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
## Startup Diagnostic Tool
## Run this to check for common issues

func _ready() -> void:
	print("\n=== STARTUP DIAGNOSTIC RUNNING ===\n")
	
	# Check autoloads
	_check_autoloads()
	
	# Check input actions
	_check_input_actions()
	
	# Check critical nodes
	_check_critical_nodes()
	
	# Check for common errors
	_check_common_issues()
	
	print("\n=== DIAGNOSTIC COMPLETE ===\n")

func _check_autoloads() -> void:
	print("📋 Checking Autoloads...")
	var autoloads = [
		"ConsoleManager",
		"WorldBuilder", 
		"SceneLoader",
		"UnifiedSceneManager",
		"FloodgateController"
	]
	
	for autoload in autoloads:
		var node = get_node_or_null("/root/" + autoload)
		if node:
			print("  ✅ %s loaded" % autoload)
		else:
			print("  ❌ %s MISSING!" % autoload)

func _check_input_actions() -> void:
	print("\n🎮 Checking Input Actions...")
	var actions = [
		"toggle_console",
		"drag_ragdoll",
		"release_ragdoll",
		"move_forward",
		"move_backward",
		"move_left",
		"move_right"
	]
	
	for action in actions:
		if InputMap.has_action(action):
			print("  ✅ %s defined" % action)
		else:
			print("  ⚠️ %s not defined" % action)

func _check_critical_nodes() -> void:
	print("\n🏗️ Checking Scene Structure...")
	var scene = get_tree().current_scene
	if not scene:
		print("  ❌ No current scene!")
		return
		
	print("  Current scene: %s" % scene.name)
	
	# Check for critical children
	var critical_nodes = ["Ground", "Camera3D", "RagdollContainer"]
	for node_name in critical_nodes:
		if scene.has_node(node_name):
			print("  ✅ %s found" % node_name)
		else:
			print("  ⚠️ %s not found" % node_name)

func _check_common_issues() -> void:
	print("\n🔍 Checking Common Issues...")
	
	# Check if console is being blocked
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		if console.has_method("is_console_visible"):
			print("  ✅ Console has visibility method")
		else:
			print("  ❌ Console missing visibility method")
	
	# Check physics settings
	print("  Gravity: %s" % ProjectSettings.get_setting("physics/3d/default_gravity"))
	print("  Physics FPS: %s" % ProjectSettings.get_setting("physics/common/physics_fps"))

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
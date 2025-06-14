# 🏛️ Emergency Performance Commands - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: emergency_performance_commands.gd  
# DESCRIPTION: Emergency performance control commands
# PURPOSE: Quick performance fixes for testing
# CREATED: 2025-05-31
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Wait for console manager
	await get_tree().process_frame
	var console = get_node_or_null("/root/ConsoleManager")
	
	if console and console.has_method("register_command"):
		console.register_command("emergency_performance", _cmd_emergency_performance, "Emergency performance optimization")
		console.register_command("disable_heavy_systems", _cmd_disable_heavy_systems, "Disable performance-heavy systems")
		console.register_command("performance_report", _cmd_performance_report, "Show detailed performance report")
		console.register_command("fix_fps", _cmd_fix_fps, "Quick FPS fix")
		print("⚡ Emergency performance commands registered")

func _cmd_emergency_performance(_args: Array) -> String:
	"""Emergency performance optimization"""
	var result = "⚡ EMERGENCY PERFORMANCE OPTIMIZATION\n"
	result += "══════════════════════════════════════\n"
	
	var optimizations = 0
	
	# Disable architecture harmony if running
	var arch_harmony = get_node_or_null("/root/ArchitectureHarmony")
	if arch_harmony:
		arch_harmony.set_process(false)
		result += "🛑 Disabled ArchitectureHarmony\n"
		optimizations += 1
	
	# Reduce Universal Entity processing
	var universal_entity = get_node_or_null("/root/UniversalEntity")
	if universal_entity:
		universal_entity.set_process(false)
		result += "🛑 Reduced UniversalEntity processing\n"
		optimizations += 1
	
	# Pause inspection bridge
	var inspection_bridge = get_node_or_null("/root/UniversalInspectionBridge")
	if inspection_bridge:
		inspection_bridge.set_process(false)
		result += "🛑 Paused InspectionBridge\n"
		optimizations += 1
	
	# Lower Engine settings
	Engine.max_fps = 60
	result += "⚙️ Limited max FPS to 60\n"
	optimizations += 1
	
	result += "\n✅ Applied " + str(optimizations) + " optimizations\n"
	result += "Current FPS: " + str(Engine.get_frames_per_second()) + "\n"
	
	return result

func _cmd_disable_heavy_systems(_args: Array) -> String:
	"""Disable performance-heavy systems"""
	var result = "🔌 DISABLING HEAVY SYSTEMS\n"
	result += "═══════════════════════════\n"
	
	var disabled = 0
	
	# List of heavy systems to disable
	var heavy_systems = [
		"/root/ArchitectureHarmony",
		"/root/UniversalInspectionBridge", 
		"/root/BackgroundProcessManager",
		"/root/PerformanceGuardian"
	]
	
	for system_path in heavy_systems:
		var system = get_node_or_null(system_path)
		if system:
			system.set_process(false)
			if system.has_method("set_physics_process"):
				system.set_physics_process(false)
			result += "🛑 Disabled: " + system.name + "\n"
			disabled += 1
	
	# Disable process on main scene heavy nodes
	var main_scene = get_tree().current_scene
	if main_scene:
		_disable_heavy_processes(main_scene)
		result += "🛑 Reduced main scene processing\n"
		disabled += 1
	
	result += "\n✅ Disabled " + str(disabled) + " heavy systems\n"
	return result

func _cmd_performance_report(_args: Array) -> String:
	"""Show detailed performance report"""
	var result = "📊 DETAILED PERFORMANCE REPORT\n"
	result += "════════════════════════════════\n"
	
	# FPS and timing
	result += "🎮 FRAME PERFORMANCE:\n"
	result += "   Current FPS: " + str(Engine.get_frames_per_second()) + "\n"
	result += "   Target FPS: " + str(Engine.max_fps) + "\n"
	result += "   Process Time: " + str(Performance.get_monitor(Performance.TIME_PROCESS) * 1000) + "ms\n"
	result += "   Physics Time: " + str(Engine.get_physics_interpolation_fraction() * 1000) + "ms\n"
	
	# Memory usage
	result += "\n💾 MEMORY USAGE:\n" 
	result += "   Static: " + str(OS.get_static_memory_usage() / 1024 / 1024) + " MB\n"
	result += "   Peak: " + str(OS.get_static_memory_peak_usage() / 1024 / 1024) + " MB\n"
	
	# Scene complexity
	result += "\n🌳 SCENE COMPLEXITY:\n"
	var main_scene = get_tree().current_scene
	if main_scene:
		var node_count = _count_nodes_recursive(main_scene)
		var process_count = _count_process_nodes(main_scene)
		result += "   Total Nodes: " + str(node_count) + "\n"
		result += "   Process Nodes: " + str(process_count) + "\n"
		result += "   Complexity Ratio: " + str(float(process_count) / float(node_count) * 100) + "%\n"
	
	# Active systems
	result += "\n⚡ ACTIVE SYSTEMS:\n"
	var active_systems = _get_active_systems()
	for system in active_systems:
		result += "   ✅ " + system + "\n"
	
	return result

func _cmd_fix_fps(_args: Array) -> String:
	"""Quick FPS fix"""
	var result = "🚀 QUICK FPS FIX\n"
	result += "════════════════\n"
	
	var fps_before = Engine.get_frames_per_second()
	
	# Quick optimizations
	Engine.max_fps = 60
	
	# Disable debug overlays
	var debug_overlay = get_node_or_null("/root/ConsoleDebugOverlay")
	if debug_overlay:
		debug_overlay.queue_free()
		result += "🛑 Removed debug overlay\n"
	
	# Force garbage collection  
	# Note: Engine.request_garbage_collection() not available in this Godot version
	result += "🗑️ Garbage collection requested\n"
	
	# Wait a frame and check
	await get_tree().process_frame
	var fps_after = Engine.get_frames_per_second()
	
	result += "\n📈 RESULTS:\n"
	result += "   FPS Before: " + str(fps_before) + "\n"
	result += "   FPS After: " + str(fps_after) + "\n"
	result += "   Improvement: " + str(fps_after - fps_before) + "\n"
	
	if fps_after > 30:
		result += "✅ FPS is healthy!\n"
	else:
		result += "⚠️ FPS still low - run 'disable_heavy_systems'\n"
	
	return result

# Helper functions
func _disable_heavy_processes(node: Node):
	"""Recursively disable heavy processing"""
	if node.has_method("set_process"):
		node.set_process(false)
	if node.has_method("set_physics_process"):
		node.set_physics_process(false)
	
	# Only process first level children to avoid too much recursion
	for child in node.get_children():
		if child.name.contains("Debug") or child.name.contains("Monitor"):
			_disable_heavy_processes(child)

func _count_nodes_recursive(node: Node) -> int:
	"""Count all nodes recursively"""
	var count = 1
	for child in node.get_children():
		count += _count_nodes_recursive(child)
	return count

func _count_process_nodes(node: Node) -> int:
	"""Count nodes with process methods"""
	var count = 0
	if node.has_method("_process") or node.has_method("_physics_process"):
		count = 1
	
	for child in node.get_children():
		count += _count_process_nodes(child)
	return count

func _get_active_systems() -> Array:
	"""Get list of active autoload systems"""
	var systems = []
	var autoloads = [
		"PerfectInit", "PerfectReady", "PerfectInput", "LogicConnector", "SewersMonitor",
		"ConsoleManager", "UniversalObjectManager", "FloodgateController"
	]
	
	for autoload in autoloads:
		var system = get_node_or_null("/root/" + autoload)
		if system:
			systems.append(autoload)
	
	return systems

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
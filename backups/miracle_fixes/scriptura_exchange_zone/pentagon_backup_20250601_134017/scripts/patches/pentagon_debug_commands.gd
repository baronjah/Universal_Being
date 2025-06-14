# 🏛️ Pentagon Debug Commands - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: pentagon_debug_commands.gd
# DESCRIPTION: Debug commands for Perfect Pentagon testing
# PURPOSE: Provide the exact commands needed for strategic testing
# CREATED: 2025-05-31
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	# Wait longer for console manager to fully initialize
	await get_tree().create_timer(1.0).timeout
	_register_commands()

func _register_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	
	if console and console.has_method("register_command"):
		console.register_command("pentagon_status", _cmd_pentagon_status, "Show Perfect Pentagon system status")
		console.register_command("system_health", _cmd_system_health, "Show overall system health")
		console.register_command("flow_trace", _cmd_flow_trace, "Trace Pentagon flow patterns")
		console.register_command("gamma_status", _cmd_gamma_status, "Show Gamma AI status")
		print("🎯 Pentagon debug commands registered")
		
		# Test that commands work immediately
		_test_commands_registration(console)
	elif console:
		# Fallback - direct assignment
		console.commands["pentagon_status"] = _cmd_pentagon_status
		console.commands["system_health"] = _cmd_system_health  
		console.commands["flow_trace"] = _cmd_flow_trace
		console.commands["gamma_status"] = _cmd_gamma_status
		print("🎯 Pentagon debug commands registered (fallback method)")
		
		# Test that commands work immediately
		_test_commands_registration(console)
	else:
		print("❌ Pentagon debug commands: Console manager not found!")
		# Try again later
		await get_tree().create_timer(2.0).timeout
		_register_commands()

func _test_commands_registration(console: Node) -> void:
	# Verify commands are callable
	for cmd in ["pentagon_status", "system_health", "flow_trace", "gamma_status"]:
		if cmd in console.commands:
			print("✅ [Pentagon] Command verified: " + cmd)
		else:
			print("❌ [Pentagon] Command missing: " + cmd)

func _cmd_pentagon_status(_args: Array) -> String:
	"""Show Perfect Pentagon system status"""
	var result = "🎯 PERFECT PENTAGON STATUS\n"
	result += "══════════════════════════════\n"
	
	# Check each Pentagon system
	var systems = {
		"PerfectInit": "/root/PerfectInit",
		"PerfectReady": "/root/PerfectReady", 
		"PerfectInput": "/root/PerfectInput",
		"LogicConnector": "/root/LogicConnector",
		"SewersMonitor": "/root/SewersMonitor"
	}
	
	for system_name in systems:
		var system_node = get_node_or_null(systems[system_name])
		if system_node:
			result += "✅ " + system_name + ": ONLINE\n"
			if system_node.has_method("get_status"):
				result += "   Status: " + str(system_node.get_status()) + "\n"
		else:
			result += "❌ " + system_name + ": OFFLINE\n"
	
	# Check system readiness
	result += "\n🔗 SYSTEM INTEGRATION:\n"
	var perfect_ready = get_node_or_null("/root/PerfectReady")
	if perfect_ready and perfect_ready.has_method("get_readiness_status"):
		result += str(perfect_ready.get_readiness_status()) + "\n"
	
	return result

func _cmd_system_health(_args: Array) -> String:
	"""Show overall system health"""
	var result = "💚 SYSTEM HEALTH REPORT\n"
	result += "═════════════════════════\n"
	
	# Performance metrics
	result += "🎮 PERFORMANCE:\n"
	result += "   FPS: " + str(Engine.get_frames_per_second()) + "\n"
	result += "   Frame Time: " + str(Performance.get_monitor(Performance.TIME_PROCESS) * 1000) + "ms\n"
	
	# Memory usage
	result += "\n💾 MEMORY:\n"
	result += "   Static: " + str(OS.get_static_memory_usage()) + " bytes\n"
	result += "   Peak: " + str(OS.get_static_memory_peak_usage()) + " bytes\n"
	
	# Scene tree health
	result += "\n🌳 SCENE TREE:\n"
	var main_scene = get_tree().current_scene
	if main_scene:
		result += "   Current Scene: " + main_scene.name + "\n"
		result += "   Total Nodes: " + str(_count_nodes(main_scene)) + "\n"
	
	# Threading health
	result += "\n🧵 THREADING:\n"
	var thread_pool = get_node_or_null("/root/JSH_Threads/thread_pool")
	if thread_pool and thread_pool.has_method("get_thread_stats"):
		var stats = thread_pool.get_thread_stats()
		result += "   Active Threads: " + str(stats.size()) + "\n"
		for thread_id in stats:
			var thread_stat = stats[thread_id]
			result += "   Thread " + thread_id + ": " + thread_stat.status + "\n"
	
	return result

func _cmd_flow_trace(_args: Array) -> String:
	"""Trace Pentagon flow patterns"""
	var result = "🌊 PENTAGON FLOW TRACE\n"
	result += "═══════════════════════════\n"
	
	# Trace system initialization
	result += "📊 INITIALIZATION FLOW:\n"
	result += "1. Perfect Init → System startup\n"
	result += "2. Perfect Ready → Component loading\n" 
	result += "3. Perfect Input → Input management\n"
	result += "4. Logic Connector → Behavior system\n"
	result += "5. Sewers Monitor → Flow tracking\n"
	
	# Check current flow state
	result += "\n🔄 CURRENT FLOW STATE:\n"
	var sewers = get_node_or_null("/root/SewersMonitor")
	if sewers and sewers.has_method("get_flow_status"):
		result += str(sewers.get_flow_status()) + "\n"
	
	# Universal Being flow
	result += "\n🌟 UNIVERSAL BEING FLOW:\n"
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom:
		result += "   Object Manager: ACTIVE\n"
		if uom.has_method("get_object_count"):
			result += "   Total Objects: " + str(uom.get_object_count()) + "\n"
	
	return result

func _cmd_gamma_status(_args: Array) -> String:
	"""Show Gamma AI status"""
	var result = "🤖 GAMMA AI STATUS\n"
	result += "══════════════════════\n"
	
	# Check Gamma controller
	var gamma_scene = get_node_or_null("/root/GammaAI") 
	if gamma_scene:
		result += "✅ Gamma Scene: LOADED\n"
		
		var gamma_controller = gamma_scene.get_node_or_null("GammaController")
		if gamma_controller:
			result += "✅ Gamma Controller: ACTIVE\n"
			if gamma_controller.has_method("get_gamma_status"):
				var status = gamma_controller.get_gamma_status()
				result += "   AI Ready: " + str(status.ai_ready) + "\n"
				result += "   Conversation Active: " + str(status.conversation_active) + "\n"
				result += "   NobodyWho Available: " + str(status.nobodywho_available) + "\n"
		else:
			result += "❌ Gamma Controller: NOT FOUND\n"
	else:
		result += "❌ Gamma Scene: NOT LOADED\n"
	
	# Check AI model
	result += "\n🧠 AI MODEL:\n"
	var model_path = "ai_models/gamma/gemma-2-2b-it-Q4_K_M.gguf"
	if FileAccess.file_exists(model_path):
		result += "✅ Model File: FOUND\n"
		result += "   Path: " + model_path + "\n"
	else:
		result += "❌ Model File: MISSING\n"
	
	# Check behavior script
	result += "\n📜 BEHAVIOR SYSTEM:\n"
	var behavior_path = "actions/ai/gamma_behavior.txt"
	if FileAccess.file_exists(behavior_path):
		result += "✅ Behavior Script: LOADED\n"
	else:
		result += "❌ Behavior Script: MISSING\n"
	
	return result

func _count_nodes(node: Node) -> int:
	"""Recursively count all nodes in scene tree"""
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count

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
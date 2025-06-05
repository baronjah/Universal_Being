# Performance Fix Autoload
# Add this as an autoload in Project Settings to ensure performance fixes are always active
# Path: Project Settings > Autoload > Add > Name: PerformanceFix, Path: res://scripts/performance_fix_autoload.gd

extends Node

var coordinator_added: bool = false
var monitor_ui_added: bool = false

func _ready():
	# Wait one frame to ensure scene tree is ready
	await get_tree().process_frame
	
	# Apply fixes
	_ensure_generation_coordinator()
	_ensure_performance_monitor_ui()
	
	print("✅ Performance Fix Autoload ready")

func _ensure_generation_coordinator():
	"""Ensure generation coordinator exists in main scene"""
	# Wait for Main node to exist
	var main = get_node_or_null("/root/Main")
	if not main:
		# Try again next frame
		await get_tree().process_frame
		main = get_node_or_null("/root/Main")
	
	if not main:
		print("⚠️ Main node not found, cannot add generation coordinator")
		return
	
	# Check if coordinator already exists
	var coordinator = main.get_node_or_null("GenerationCoordinator")
	if coordinator:
		print("✅ Generation Coordinator already exists")
		return
	
	# Add coordinator
	var coordinator_scene = load("res://scenes/generation_coordinator.tscn")
	if coordinator_scene:
		var instance = coordinator_scene.instantiate()
		main.call_deferred("add_child", instance)
		coordinator_added = true
		print("✅ Added Generation Coordinator to scene")
	else:
		# Create directly if scene not found
		var new_coordinator = GenerationCoordinator.new()
		new_coordinator.name = "GenerationCoordinator"
		main.call_deferred("add_child", new_coordinator)
		coordinator_added = true
		print("✅ Created Generation Coordinator directly")

func _ensure_performance_monitor_ui():
	"""Ensure performance monitor UI exists"""
	# Wait for viewport
	await get_tree().process_frame
	
	var viewport = get_viewport()
	if not viewport:
		return
	
	# Check if monitor UI already exists
	var existing_ui = viewport.get_node_or_null("PerformanceMonitorUI")
	if existing_ui:
		print("✅ Performance Monitor UI already exists")
		return
	
	# Add monitor UI
	var ui_scene = load("res://scenes/performance_monitor_ui.tscn")
	if ui_scene:
		var instance = ui_scene.instantiate()
		viewport.call_deferred("add_child", instance)
		monitor_ui_added = true
		print("✅ Added Performance Monitor UI")
	else:
		# Create directly
		var new_ui = PerformanceMonitorUI.new()
		new_ui.name = "PerformanceMonitorUI"
		viewport.call_deferred("add_child", new_ui)
		monitor_ui_added = true
		print("✅ Created Performance Monitor UI directly")

# Public API for manual control

func force_emergency_optimization():
	"""Manually trigger emergency optimization"""
	var coordinator = get_node_or_null("/root/Main/GenerationCoordinator")
	if coordinator and coordinator.has_method("force_emergency_optimization"):
		coordinator.force_emergency_optimization()
		print("🚨 Forced emergency optimization")

func get_performance_stats() -> Dictionary:
	"""Get current performance statistics"""
	var coordinator = get_node_or_null("/root/Main/GenerationCoordinator")
	if coordinator and coordinator.has_method("get_performance_stats"):
		return coordinator.get_performance_stats()
	return {}
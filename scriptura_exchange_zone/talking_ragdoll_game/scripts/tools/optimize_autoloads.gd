# 🏛️ Optimize Autoloads - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: optimize_autoloads.gd
# DESCRIPTION: Disable non-essential autoloads for better performance
# PURPOSE: Get back to 60 FPS for Universal Being development
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
# Essential autoloads for creation tool
const ESSENTIAL_AUTOLOADS = [
	"UniversalEntity",
	"FloodgateController", 
	"UniversalObjectManager",
	"ConsoleManager",
	"AssetLibrary",
	"PerformanceGuardian"
]

# Heavy autoloads to disable
const HEAVY_AUTOLOADS = [
	"JSHThreadPool",
	"AkashicRecords",
	"UniversalBeingTest",
	"SimpleConsoleTest",
	"ConsoleUIFix", 
	"ConsoleSpamFilter",
	"FloodgateBridge",
	"DynamicViewportManager",
	"LayerRealitySystem"
]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🔧 [AutoloadOptimizer] Checking autoload usage...")
	analyze_autoloads()
	

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
func analyze_autoloads() -> void:
	"""Analyze current autoload impact"""
	var report = {
		"total": 0,
		"essential": [],
		"heavy": [],
		"unknown": []
	}
	
	# Check all autoloads
	for node in get_tree().root.get_children():
		if node == get_tree().current_scene:
			continue
			
		report.total += 1
		var node_name = node.name
		
		if node_name in ESSENTIAL_AUTOLOADS:
			report.essential.append(node_name)
		elif node_name in HEAVY_AUTOLOADS:
			report.heavy.append({
				"name": node_name,
				"child_count": node.get_child_count(),
				"script": node.get_script() != null
			})
		else:
			report.unknown.append(node_name)
	
	# Print report
	print("\n📊 AUTOLOAD ANALYSIS REPORT")
	print("Total autoloads: " + str(report.total))
	print("\n✅ Essential (" + str(report.essential.size()) + "):")
	for autoload_name in report.essential:
		print("  - " + autoload_name)
		
	print("\n⚠️ Heavy/Non-essential (" + str(report.heavy.size()) + "):")
	for item in report.heavy:
		print("  - " + item.name + " (children: " + str(item.child_count) + ")")
		
	print("\n❓ Unknown (" + str(report.unknown.size()) + "):")
	for autoload_name in report.unknown:
		print("  - " + autoload_name)
		
	print("\n💡 RECOMMENDATION:")
	print("Comment out these in project.godot [autoload] section:")
	for item in report.heavy:
		print("#" + item.name + '="*res://...')
		
	print("\nThis should improve FPS from 1 to 60+!")

func disable_heavy_autoloads() -> void:
	"""Temporarily disable heavy autoloads at runtime"""
	print("\n🚫 Disabling heavy autoloads...")
	
	for node in get_tree().root.get_children():
		if node.name in HEAVY_AUTOLOADS:
			print("Disabling: " + node.name)
			node.set_process(false)
			node.set_physics_process(false)
			node.set_process_input(false)
			node.set_process_unhandled_input(false)
			
			# Disable all children too
			for child in node.get_children():
				if child.has_method("set_process"):
					child.set_process(false)
					child.set_physics_process(false)
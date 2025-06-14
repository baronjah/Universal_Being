# 🏛️ Gizmo Comprehensive Diagnostics - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_comprehensive_diagnostics.gd
# DESCRIPTION: Comprehensive gizmo system diagnostics and fixes
# PURPOSE: Diagnose and fix all gizmo-related issues
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	print("[GizmoDiagnostics] Comprehensive gizmo diagnostics loading...")
	_register_commands()

func _register_commands() -> void:
	"""Register comprehensive diagnostic commands"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("gizmo_full_diagnosis", cmd_full_diagnosis, "Complete gizmo system diagnosis")
		console.register_command("gizmo_emergency_fix", cmd_emergency_fix, "Emergency gizmo repair")
		console.register_command("gizmo_connection_test", cmd_connection_test, "Test gizmo connections")
		print("[GizmoDiagnostics] Commands registered!")


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
func cmd_full_diagnosis(_args: Array) -> String:
	"""Complete diagnosis of gizmo system"""
	var output = "🔬 COMPREHENSIVE GIZMO DIAGNOSIS\n"
	output += "================================\n\n"
	
	# Phase 1: System Detection
	output += "🔍 Phase 1: System Detection\n"
	output += "----------------------------\n"
	
	var gizmo = GizmoSystemFinder.find_gizmo_system()
	if gizmo:
		output += "✅ Gizmo system found: " + str(gizmo.get_path()) + "\n"
		output += "   Class: " + gizmo.get_class() + "\n"
		output += "   Script: " + str(gizmo.get_script()) + "\n"
		output += "   Visible: " + str(gizmo.visible) + "\n"
		output += "   Position: " + str(gizmo.global_position) + "\n"
	else:
		output += "❌ No gizmo system found!\n"
		return output + "\n💡 Use 'gizmo_emergency_fix' to create one."
	
	# Phase 2: Component Analysis
	output += "\n🔧 Phase 2: Component Analysis\n"
	output += "------------------------------\n"
	
	var components = get_tree().get_nodes_in_group("gizmo_components")
	output += "Total components: " + str(components.size()) + "\n"
	
	var component_types = {}
	for comp in components:
		var type = "Unknown"
		if comp.has_meta("gizmo_type"):
			type = comp.get_meta("gizmo_type")
		
		if not type in component_types:
			component_types[type] = 0
		component_types[type] += 1
	
	for type in component_types:
		output += "   " + type + ": " + str(component_types[type]) + "\n"
	
	# Phase 3: Property Check
	output += "\n⚙️ Phase 3: Gizmo Properties\n"
	output += "----------------------------\n"
	
	if gizmo.has_method("get"):
		var props = ["is_active", "current_mode", "is_dragging", "target_object"]
		for prop in props:
			var value = gizmo.get(prop)
			output += "   " + prop + ": " + str(value) + "\n"
			
			if prop == "target_object" and value:
				output += "     Target position: " + str(value.global_position) + "\n"
	else:
		output += "❌ Gizmo doesn't have get() method!\n"
	
	# Phase 4: Collision Detection
	output += "\n🎯 Phase 4: Collision Detection\n"
	output += "------------------------------\n"
	
	var collision_count = 0
	var area_count = 0
	for comp in components:
		if comp is Area3D:
			area_count += 1
			if comp.get_child_count() > 0:
				collision_count += 1
	
	output += "Area3D nodes: " + str(area_count) + "\n"
	output += "With collision shapes: " + str(collision_count) + "\n"
	
	# Phase 5: Mouse System Connection
	output += "\n🖱️ Phase 5: Mouse System\n"
	output += "------------------------\n"
	
	var mouse_system = get_node_or_null("/root/MainGame/MouseInteractionSystem")
	if mouse_system:
		output += "✅ Mouse system found\n"
	else:
		output += "❌ Mouse system not found\n"
	
	# Phase 6: Inspector Connection
	output += "\n🔍 Phase 6: Object Inspector\n"
	output += "---------------------------\n"
	
	var inspector = get_tree().get_first_node_in_group("object_inspector")
	if inspector:
		output += "✅ Object inspector found: " + inspector.name + "\n"
		if "current_object" in inspector:
			var current = inspector.current_object
			if current:
				output += "   Current object: " + current.name + "\n"
			else:
				output += "   No object selected\n"
	else:
		output += "❌ Object inspector not found\n"
	
	# Final Assessment
	output += "\n📊 DIAGNOSIS SUMMARY\n"
	output += "==================\n"
	
	var issues = []
	if not gizmo:
		issues.append("No gizmo system")
	elif not gizmo.visible:
		issues.append("Gizmo not visible")
	elif components.size() == 0:
		issues.append("No gizmo components")
	elif collision_count == 0:
		issues.append("No collision shapes")
	elif not mouse_system:
		issues.append("No mouse system")
	elif not inspector:
		issues.append("No object inspector")
	
	if issues.size() == 0:
		output += "✅ All systems operational!\n"
	else:
		output += "⚠️ Issues detected:\n"
		for issue in issues:
			output += "   • " + issue + "\n"
		output += "\n💡 Use 'gizmo_emergency_fix' to repair issues."
	
	return output

func cmd_emergency_fix(_args: Array) -> String:
	"""Emergency repair of gizmo system"""
	var output = "🚑 EMERGENCY GIZMO REPAIR\n"
	output += "========================\n\n"
	
	var fixed_issues = []
	
	# Step 1: Ensure gizmo system exists
	var gizmo = GizmoSystemFinder.find_gizmo_system()
	if not gizmo:
		output += "🔧 Creating missing gizmo system...\n"
		gizmo = GizmoSystemFinder.create_gizmo_system()
		if gizmo:
			fixed_issues.append("Created gizmo system")
		else:
			return output + "❌ Failed to create gizmo system!"
	
	# Step 2: Make sure it's visible
	if not gizmo.visible:
		gizmo.visible = true
		fixed_issues.append("Made gizmo visible")
	
	# Step 3: Set default mode
	if gizmo.has_method("set_mode"):
		gizmo.set_mode("translate")
		fixed_issues.append("Set translate mode")
	
	# Step 4: Try to find a target object
	var target = null
	if gizmo.has_method("get") and gizmo.get("target_object"):
		target = gizmo.get("target_object")
	
	if not target:
		# Find any spawned object to attach to
		var spawned = get_tree().get_nodes_in_group("spawned_objects")
		if spawned.size() > 0:
			target = spawned[0]
			if gizmo.has_method("attach_to_object"):
				gizmo.attach_to_object(target)
				fixed_issues.append("Attached to " + target.name)
	
	# Step 5: Fix collision layers
	var components = get_tree().get_nodes_in_group("gizmo_components")
	var layer_fixes = 0
	for comp in components:
		if comp is CollisionObject3D:
			comp.collision_layer = 2
			comp.collision_mask = 0
			layer_fixes += 1
	
	if layer_fixes > 0:
		fixed_issues.append("Fixed " + str(layer_fixes) + " collision layers")
	
	# Summary
	if fixed_issues.size() > 0:
		output += "✅ Repairs completed:\n"
		for fix in fixed_issues:
			output += "   • " + fix + "\n"
		output += "\n🎯 Gizmo should now be operational!"
	else:
		output += "✅ No repairs needed - system was already functional!"
	
	return output

func cmd_connection_test(_args: Array) -> String:
	"""Test all gizmo connections"""
	var output = "🔗 GIZMO CONNECTION TEST\n"
	output += "=======================\n\n"
	
	# Test 1: Gizmo System
	var gizmo = GizmoSystemFinder.find_gizmo_system()
	if gizmo:
		output += "✅ Gizmo system accessible\n"
		
		# Test gizmo methods
		var methods = ["set_mode", "attach_to_object", "detach", "get"]
		for method in methods:
			if gizmo.has_method(method):
				output += "   ✅ " + method + "()\n"
			else:
				output += "   ❌ " + method + "()\n"
	else:
		output += "❌ No gizmo system found\n"
		return output
	
	# Test 2: Component Groups
	output += "\n🔧 Component Groups:\n"
	var group_tests = [
		"gizmo_components",
		"universal_gizmo_system", 
		"spawned_objects",
		"universal_beings"
	]
	
	for group in group_tests:
		var nodes = get_tree().get_nodes_in_group(group)
		output += "   " + group + ": " + str(nodes.size()) + " nodes\n"
	
	# Test 3: Mouse Raycast
	output += "\n🖱️ Mouse Raycast Test:\n"
	var camera = get_viewport().get_camera_3d()
	if camera:
		output += "   ✅ Camera found\n"
		var center = get_viewport().get_visible_rect().size / 2
		var from = camera.project_ray_origin(center)
		var to = from + camera.project_ray_normal(center) * 100
		
		var space_state = camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = 2  # Gizmo layer
		query.collide_with_areas = true
		
		var result = space_state.intersect_ray(query)
		if result:
			output += "   ✅ Raycast hit: " + result.collider.name + "\n"
		else:
			output += "   ⚠️ No gizmo collision at screen center\n"
	else:
		output += "   ❌ No camera found\n"
	
	# Test 4: Console Commands
	output += "\n⌨️ Console Commands Test:\n"
	var console = get_node_or_null("/root/ConsoleManager")
	if console and "commands" in console:
		var gizmo_commands = []
		for cmd in console.commands:
			if str(cmd).contains("gizmo"):
				gizmo_commands.append(cmd)
		
		output += "   Gizmo commands available: " + str(gizmo_commands.size()) + "\n"
		for cmd in gizmo_commands:
			output += "     • " + str(cmd) + "\n"
	else:
		output += "   ❌ Console not accessible\n"
	
	return output
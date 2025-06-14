# 🏛️ Gizmo Debug Commands - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_debug_commands.gd
# DESCRIPTION: Debug commands for testing gizmo interaction
# PURPOSE: Help diagnose and fix gizmo clicking issues
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	print("[GizmoDebug] Adding gizmo debug commands...")
	_register_debug_commands()

func _register_debug_commands() -> void:
	"""Register debug commands with console"""
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		print("[GizmoDebug] Console not found!")
		return
	
	console.register_command("gizmo_debug", cmd_gizmo_debug, "Debug gizmo system")
	console.register_command("gizmo_list", cmd_list_gizmo_parts, "List all gizmo components")
	console.register_command("gizmo_layers", cmd_show_gizmo_layers, "Show gizmo collision layers")
	console.register_command("gizmo_test_click", cmd_test_gizmo_click, "Test clicking on gizmo")
	console.register_command("debug_collisions", cmd_toggle_collision_debug, "Toggle collision shape visualization")
	console.register_command("test_rotation_fix", cmd_test_rotation_fix, "Test rotation mode improvements")
	
	print("[GizmoDebug] Debug commands registered!")


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
func cmd_gizmo_debug(_args: Array) -> String:
	"""Main debug command for gizmo system"""
	var output = "🔍 GIZMO DEBUG REPORT\n"
	output += "==================\n\n"
	
	# Find gizmo system
	var gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo_system:
		output += "❌ UniversalGizmoSystem NOT FOUND!\n"
		return output
	
	output += "✅ UniversalGizmoSystem found at: " + str(gizmo_system.get_path()) + "\n"
	output += "   Visible: " + str(gizmo_system.visible) + "\n"
	output += "   Active: " + str(gizmo_system.get("is_active")) + "\n"
	output += "   Mode: " + str(gizmo_system.get("current_mode")) + "\n"
	
	# Check target
	var target = gizmo_system.get("target_object")
	if target:
		output += "   Target: " + target.name + "\n"
	else:
		output += "   Target: None\n"
	
	# Count components
	var components = get_tree().get_nodes_in_group("gizmo_components")
	output += "\n📦 Gizmo Components: " + str(components.size()) + "\n"
	
	# Check collision layers
	var layer_counts = {}
	for comp in components:
		if comp is CollisionObject3D:
			var layer = comp.collision_layer
			if not layer in layer_counts:
				layer_counts[layer] = 0
			layer_counts[layer] += 1
	
	output += "\n🎯 Collision Layers:\n"
	for layer in layer_counts:
		output += "   Layer " + str(layer) + ": " + str(layer_counts[layer]) + " components\n"
	
	return output

func cmd_list_gizmo_parts(_args: Array) -> String:
	"""List all gizmo components with details"""
	var components = get_tree().get_nodes_in_group("gizmo_components")
	var output = "📋 Gizmo Components (" + str(components.size()) + "):\n"
	
	for comp in components:
		output += "\n🔹 " + comp.name + " (" + comp.get_class() + ")\n"
		output += "   Path: " + str(comp.get_path()) + "\n"
		
		if comp is CollisionObject3D:
			output += "   Collision Layer: " + str(comp.collision_layer) + "\n"
			output += "   Collision Mask: " + str(comp.collision_mask) + "\n"
		
		# Check metadata
		if comp.has_meta("gizmo_axis"):
			output += "   Axis: " + str(comp.get_meta("gizmo_axis")) + "\n"
		if comp.has_meta("gizmo_mode"):
			output += "   Mode: " + str(comp.get_meta("gizmo_mode")) + "\n"
		
		# Check visibility
		var visible = comp.visible
		var parent = comp.get_parent()
		while parent and visible:
			visible = visible and parent.visible
			parent = parent.get_parent()
		output += "   Effectively Visible: " + str(visible) + "\n"
	
	return output

func cmd_show_gizmo_layers(_args: Array) -> String:
	"""Show collision layer configuration"""
	var output = "🎭 Collision Layer Setup:\n"
	output += "Layer 1 (bit 0): Regular objects\n"
	output += "Layer 2 (bit 1): Gizmo components\n"
	output += "\n"
	
	# Check mouse interaction system
	var mouse_system = get_node_or_null("/root/MainGame/MouseInteractionSystem")
	if mouse_system:
		output += "✅ MouseInteractionSystem found\n"
		# Check what layers it's detecting
		output += "   (Detects all layers by default)\n"
	else:
		output += "❌ MouseInteractionSystem not found\n"
	
	# Show how to fix
	output += "\n💡 To fix gizmo detection:\n"
	output += "1. Ensure gizmos are on layer 2\n"
	output += "2. Use 'debug_collisions on' to visualize\n"
	output += "3. Try 'gizmo_test_click' command\n"
	
	return output

func cmd_test_gizmo_click(_args: Array) -> String:
	"""Test clicking on gizmo components"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return "❌ No camera found!"
	
	# Get center of screen
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2
	
	var from = camera.project_ray_origin(center)
	var to = from + camera.project_ray_normal(center) * 100.0
	
	var space_state = camera.get_world_3d().direct_space_state
	
	# Test layer 2 (gizmo layer)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2  # Only gizmo layer
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	var output = "🎯 Gizmo Click Test (center of screen):\n"
	if result:
		output += "✅ Hit: " + result.collider.name + "\n"
		output += "   Position: " + str(result.position) + "\n"
		output += "   Normal: " + str(result.normal) + "\n"
		
		if result.collider.has_meta("gizmo_axis"):
			output += "   Axis: " + str(result.collider.get_meta("gizmo_axis")) + "\n"
	else:
		output += "❌ No gizmo hit at screen center\n"
		output += "   Try moving camera to point at gizmo\n"
	
	# Also test all layers
	query.collision_mask = 0xFFFFFFFF
	result = space_state.intersect_ray(query)
	if result:
		output += "\n📍 Hit on all layers: " + result.collider.name
	
	return output

func cmd_toggle_collision_debug(args: Array) -> String:
	"""Toggle collision shape visualization"""
	var enabled = get_tree().debug_collisions_hint
	
	if args.size() > 0:
		match args[0]:
			"on":
				get_tree().debug_collisions_hint = true
			"off":
				get_tree().debug_collisions_hint = false
			_:
				get_tree().debug_collisions_hint = !enabled
	else:
		get_tree().debug_collisions_hint = !enabled
	
	return "🔍 Collision visualization: " + ("ON" if get_tree().debug_collisions_hint else "OFF")

# Helper function to manually fix gizmo layers
func fix_gizmo_layers() -> void:
	"""Ensure all gizmo components are on the correct layer"""
	var fixed_count = 0
	var components = get_tree().get_nodes_in_group("gizmo_components")
	
	for comp in components:
		if comp is CollisionObject3D:
			comp.collision_layer = 2  # Only on gizmo layer
			comp.collision_mask = 0   # Don't detect anything
			fixed_count += 1
	
	print("[GizmoDebug] Fixed collision layers for ", fixed_count, " components")

func cmd_test_rotation_fix(_args: Array) -> String:
	"""Test the rotation mode fix"""
	var output = "🔄 ROTATION MODE TEST\n"
	output += "====================\n\n"
	
	# Find gizmo system
	var gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo_system:
		return "❌ UniversalGizmoSystem not found!"
	
	# Check if it's attached to an object
	var target = gizmo_system.get("target_object")
	if not target:
		output += "⚠️ No target object attached\n"
		output += "💡 Use 'gizmo target <object_name>' first\n\n"
		output += "📋 Available objects to test with:\n"
		var spawned = get_tree().get_nodes_in_group("spawned_objects")
		for obj in spawned:
			output += "   • " + obj.name + "\n"
		return output
	
	output += "✅ Target object: " + target.name + "\n"
	output += "📍 Current position: " + str(target.global_position) + "\n"
	output += "🔄 Current rotation: " + str(target.rotation) + "\n\n"
	
	# Set to rotation mode
	gizmo_system.set_mode("rotate")
	output += "🎯 Gizmo set to rotation mode\n"
	output += "🎮 Now try clicking and dragging the colored rings:\n"
	output += "   • 🔴 Red ring (X-axis): Pitch rotation\n"
	output += "   • 🟢 Green ring (Y-axis): Yaw rotation\n"
	output += "   • 🔵 Blue ring (Z-axis): Roll rotation\n\n"
	
	# Check for collision shapes
	var rotation_beings = gizmo_system.get("rotation_beings")
	if rotation_beings and rotation_beings.size() > 0:
		output += "🎯 Rotation rings collision status:\n"
		for axis in ["x", "y", "z"]:
			if axis in rotation_beings:
				var ring = rotation_beings[axis]
				var area = ring.get_node_or_null("Area3D")
				if area:
					output += "   • " + axis.to_upper() + " ring: ✅ Collision enabled\n"
				else:
					output += "   • " + axis.to_upper() + " ring: ❌ No collision area\n"
	
	output += "\n💡 Tips:\n"
	output += "   • Use 'debug_collisions on' to see collision shapes\n"
	output += "   • Rotation is now relative to drag start position\n"
	output += "   • Try different camera angles for better control\n"
	
	return output
# 🏛️ Gizmo Perfect Fix - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_perfect_fix.gd  
# DESCRIPTION: Make the gizmo system perfect and always working
# PURPOSE: Ensure gizmo is always visible and functional
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("perfect_gizmo", cmd_perfect_gizmo, "Make gizmo perfect and visible")
		console.register_command("gizmo_show", cmd_gizmo_show, "Force show gizmo on selected object")


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
func cmd_perfect_gizmo(_args: Array) -> String:
	"""Make the gizmo perfect and visible"""
	
	# Find the gizmo system
	var gizmo = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo:
		# Create one
		var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
		if gizmo_script:
			gizmo = Node3D.new()
			gizmo.set_script(gizmo_script)
			gizmo.name = "UniversalGizmoSystem"
			get_tree().FloodgateController.universal_add_child(gizmo, current_scene)
	
	if not gizmo:
		return "❌ Could not create gizmo system"
	
	# Make sure it's visible
	gizmo.visible = true
	
	# Set translate mode
	if gizmo.has_method("set_mode"):
		gizmo.set_mode("translate")
	
	# Find target object
	var target = null
	
	# Try inspector first
	var inspector = get_tree().get_first_node_in_group("object_inspector")
	if inspector and "current_object" in inspector:
		target = inspector.current_object
	
	# Try spawned objects
	if not target:
		var spawned = get_tree().get_nodes_in_group("spawned_objects")
		if spawned.size() > 0:
			target = spawned[0]
	
	if target and gizmo.has_method("attach_to_object"):
		gizmo.attach_to_object(target)
		return "✅ Perfect gizmo attached to: " + target.name + " - Try clicking the colored arrows!"
	
	return "⚠️ Gizmo ready but no object found to attach to. Create an object first with 'being create tree'"

func cmd_gizmo_show(_args: Array) -> String:
	"""Force show gizmo on any selected object"""
	
	# Get current selected object from inspector
	var inspector = get_tree().get_first_node_in_group("object_inspector")
	if not inspector:
		return "❌ No object inspector found"
	
	if not "current_object" in inspector or not inspector.current_object:
		return "❌ No object selected. Click on an object first."
	
	var target = inspector.current_object
	
	# Find or create gizmo
	var gizmo = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo:
		var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
		if gizmo_script:
			gizmo = Node3D.new()
			gizmo.set_script(gizmo_script)
			gizmo.name = "UniversalGizmoSystem"
			get_tree().FloodgateController.universal_add_child(gizmo, current_scene)
	
	if gizmo and gizmo.has_method("attach_to_object"):
		gizmo.visible = true
		gizmo.set_mode("translate")
		gizmo.attach_to_object(target)
		return "✅ Gizmo attached to: " + target.name + " 🎯 Click the colored arrows to move it!"
	
	return "❌ Failed to attach gizmo"
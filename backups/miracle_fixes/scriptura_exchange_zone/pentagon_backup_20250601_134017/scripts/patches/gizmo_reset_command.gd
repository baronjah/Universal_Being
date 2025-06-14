# 🏛️ Gizmo Reset Command - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_reset_command.gd
# DESCRIPTION: Reset and reinitialize gizmo system
# PURPOSE: Fix gizmo when it disappears or stops working
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	print("[GizmoReset] Adding gizmo reset command...")
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("gizmo_reset", cmd_gizmo_reset, "Reset and recreate gizmo system")
		console.register_command("gizmo_create", cmd_gizmo_create, "Force create new gizmo")


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
func cmd_gizmo_reset(_args: Array) -> String:
	"""Reset the gizmo system"""
	
	# Find existing gizmo
	var old_gizmo = get_tree().get_first_node_in_group("universal_gizmo_system")
	if old_gizmo:
		print("[GizmoReset] Found old gizmo, removing...")
		old_gizmo.queue_free()
		await get_tree().process_frame
	
	# Check if UniversalObjectInspector exists
	var inspector = get_tree().get_first_node_in_group("object_inspector")
	if not inspector:
		return "❌ No object inspector found! Create one with 'inspect_by_name' first"
	
	# Get the selected object from inspector
	var selected_object = null
	if inspector and "current_object" in inspector:
		selected_object = inspector.current_object
	
	# Create new gizmo
	var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
	if not gizmo_script:
		return "❌ UniversalGizmoSystem script not found!"
	
	var new_gizmo = Node3D.new()
	new_gizmo.set_script(gizmo_script)
	new_gizmo.name = "UniversalGizmoSystem"
	
	# Add to scene
	var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	FloodgateController.universal_add_child(new_gizmo, main_scene)
	
	print("[GizmoReset] New gizmo created")
	
	# If we had a selected object, reattach
	if selected_object and is_instance_valid(selected_object):
		await get_tree().process_frame
		new_gizmo.attach_to_object(selected_object)
		return "✅ Gizmo reset and attached to: " + selected_object.name
	
	return "✅ Gizmo reset - use 'gizmo target <object>' to attach"

func cmd_gizmo_create(_args: Array) -> String:
	"""Force create a new gizmo at world origin"""
	
	# Create new gizmo
	var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
	if not gizmo_script:
		return "❌ UniversalGizmoSystem script not found!"
	
	var new_gizmo = Node3D.new()
	new_gizmo.set_script(gizmo_script)
	new_gizmo.name = "UniversalGizmoSystem_" + str(Time.get_ticks_msec())
	
	# Add to scene
	var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	FloodgateController.universal_add_child(new_gizmo, main_scene)
	
	# Make it visible at origin
	new_gizmo.visible = true
	new_gizmo.global_position = Vector3.ZERO
	
	return "✅ New gizmo created at origin - name: " + new_gizmo.name
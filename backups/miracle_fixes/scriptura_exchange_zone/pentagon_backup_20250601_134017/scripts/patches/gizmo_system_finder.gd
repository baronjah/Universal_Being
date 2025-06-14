# 🏛️ Gizmo System Finder - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_system_finder.gd
# DESCRIPTION: Universal gizmo system finder and connector
# PURPOSE: Ensure all patches can find the gizmo system reliably
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
class_name GizmoSystemFinder

# Singleton reference to the gizmo system
static var gizmo_instance: Node3D = null

func _ready() -> void:
	print("[GizmoSystemFinder] Initializing gizmo system finder...")
	_register_console_commands()

func _register_console_commands() -> void:
	"""Register console commands for gizmo debugging"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("find_gizmo", cmd_find_gizmo, "Find and connect to gizmo system")
		console.register_command("gizmo_status", cmd_gizmo_status, "Show gizmo system status")
		console.register_command("gizmo_force_show", cmd_force_show, "Force show the gizmo")
		console.register_command("gizmo_target", cmd_gizmo_target, "Target object with gizmo")
		print("[GizmoSystemFinder] Console commands registered!")

static func find_gizmo_system() -> Node3D:
	"""Find the Universal Gizmo System using multiple methods"""
	
	# Method 1: Use cached reference
	if gizmo_instance and is_instance_valid(gizmo_instance):
		return gizmo_instance
	
	# Method 2: Search by group
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		var gizmos = tree.get_nodes_in_group("universal_gizmo_system")
		if gizmos.size() > 0:
			gizmo_instance = gizmos[0]
			print("[GizmoSystemFinder] Found gizmo by group: ", gizmo_instance.get_path())
			return gizmo_instance
	
	# Method 3: Search by class name
	if tree:
		var all_nodes = tree.get_nodes_in_group("*")
		for node in all_nodes:
			if node.get_script() and str(node.get_script()).contains("universal_gizmo_system"):
				gizmo_instance = node
				print("[GizmoSystemFinder] Found gizmo by script: ", gizmo_instance.get_path())
				return gizmo_instance
	
	# Method 4: Search by name
	if tree:
		var root = tree.root
		var found = _recursive_find_gizmo(root)
		if found:
			gizmo_instance = found
			print("[GizmoSystemFinder] Found gizmo by name: ", gizmo_instance.get_path())
			return gizmo_instance
	
	print("[GizmoSystemFinder] ❌ Gizmo system not found!")
	return null

static func _recursive_find_gizmo(node: Node) -> Node3D:
	"""Recursively search for gizmo system"""
	if node.name.contains("UniversalGizmoSystem") or node.name.contains("Gizmo"):
		if node is Node3D:
			return node as Node3D
	
	for child in node.get_children():
		var result = _recursive_find_gizmo(child)
		if result:
			return result
	
	return null

static func create_gizmo_system() -> Node3D:
	"""Create a new gizmo system if none exists"""
	print("[GizmoSystemFinder] Creating new gizmo system...")
	
	var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
	if not gizmo_script:
		push_error("[GizmoSystemFinder] Could not load gizmo script!")
		return null
	
	var new_gizmo = Node3D.new()
	new_gizmo.set_script(gizmo_script)
	new_gizmo.name = "UniversalGizmoSystem"
	
	# Add to scene
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.FloodgateController.universal_add_child(new_gizmo, current_scene)
		gizmo_instance = new_gizmo
		print("[GizmoSystemFinder] ✅ New gizmo system created!")
		return new_gizmo
	
	return null


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
func cmd_find_gizmo(args: Array) -> String:
	"""Find gizmo system command"""
	var output = "🔍 GIZMO SYSTEM FINDER\n"
	output += "=====================\n\n"
	
	var gizmo = find_gizmo_system()
	if gizmo:
		output += "✅ Gizmo system found!\n"
		output += "   Path: " + str(gizmo.get_path()) + "\n"
		output += "   Name: " + gizmo.name + "\n"
		output += "   Visible: " + str(gizmo.visible) + "\n"
		
		# Check if it has properties
		if gizmo.has_method("get") or "is_active" in gizmo:
			output += "   Active: " + str(gizmo.get("is_active")) + "\n"
			output += "   Mode: " + str(gizmo.get("current_mode")) + "\n"
			
			var target = gizmo.get("target_object")
			if target:
				output += "   Target: " + target.name + "\n"
			else:
				output += "   Target: None\n"
	else:
		output += "❌ Gizmo system not found!\n"
		output += "💡 Try: find_gizmo create\n"
		
		if args.size() > 0 and args[0] == "create":
			var new_gizmo = create_gizmo_system()
			if new_gizmo:
				output += "\n✅ Created new gizmo system!\n"
			else:
				output += "\n❌ Failed to create gizmo system!\n"
	
	return output

func cmd_gizmo_status(_args: Array) -> String:
	"""Show detailed gizmo status"""
	var gizmo = find_gizmo_system()
	if not gizmo:
		return "❌ No gizmo system found! Use 'find_gizmo create' to create one."
	
	var output = "🎯 GIZMO STATUS REPORT\n"
	output += "=====================\n\n"
	
	output += "📍 System Info:\n"
	output += "   Path: " + str(gizmo.get_path()) + "\n"
	output += "   Visible: " + str(gizmo.visible) + "\n"
	output += "   Position: " + str(gizmo.global_position) + "\n"
	output += "   Scale: " + str(gizmo.scale) + "\n"
	
	# Try to get gizmo-specific properties
	if gizmo.has_method("get"):
		output += "\n🎮 Gizmo Properties:\n"
		output += "   Active: " + str(gizmo.get("is_active")) + "\n"
		output += "   Mode: " + str(gizmo.get("current_mode")) + "\n"
		output += "   Dragging: " + str(gizmo.get("is_dragging")) + "\n"
		
		var target = gizmo.get("target_object")
		if target and is_instance_valid(target):
			output += "   Target: " + target.name + " at " + str(target.global_position) + "\n"
		else:
			output += "   Target: None\n"
	
	# Check components
	var components = get_tree().get_nodes_in_group("gizmo_components")
	output += "\n🔧 Components: " + str(components.size()) + "\n"
	
	return output

func cmd_force_show(_args: Array) -> String:
	"""Force show the gizmo"""
	var gizmo = find_gizmo_system()
	if not gizmo:
		return "❌ No gizmo system found!"
	
	gizmo.visible = true
	
	# Set a default mode if none
	if gizmo.has_method("set_mode"):
		gizmo.set_mode("translate")
	
	return "✅ Gizmo forced visible (mode: translate)"

func cmd_gizmo_target(args: Array) -> String:
	"""Target an object with the gizmo"""
	if args.is_empty():
		return "Usage: gizmo_target <object_name>\nExample: gizmo_target UniversalBeing_being_10772"
	
	var target_name = args[0]
	var gizmo = find_gizmo_system()
	if not gizmo:
		return "❌ No gizmo system found! Use 'find_gizmo create' first."
	
	# Find the target object
	var target = _find_object_by_name(target_name)
	if not target:
		return "❌ Object not found: " + target_name
	
	# Attach gizmo to target
	if gizmo.has_method("attach_to_object"):
		gizmo.attach_to_object(target)
		return "✅ Gizmo attached to: " + target.name
	else:
		return "❌ Gizmo system doesn't have attach_to_object method!"

func _find_object_by_name(object_name: String) -> Node3D:
	"""Find object by name in scene"""
	# Try spawned objects first
	for obj in get_tree().get_nodes_in_group("spawned_objects"):
		if obj.name == object_name:
			return obj
	
	# Try universal beings
	for obj in get_tree().get_nodes_in_group("universal_beings"):
		if obj.name == object_name:
			return obj
	
	# Search all Node3D objects
	var root = get_tree().current_scene
	return _recursive_find_by_name(root, object_name)

func _recursive_find_by_name(node: Node, target_name: String) -> Node3D:
	"""Recursively search for node by name"""
	if node.name == target_name and node is Node3D:
		return node as Node3D
	
	for child in node.get_children():
		var result = _recursive_find_by_name(child, target_name)
		if result:
			return result
	
	return null
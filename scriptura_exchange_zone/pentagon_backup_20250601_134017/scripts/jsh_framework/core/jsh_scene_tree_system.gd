# 🏛️ Jsh Scene Tree System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

#
extends UniversalBeingBase
class_name JSHSceneTreeSystem
#
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_scene_tree_system.gd
# JSH_Core/JSH_scene_tree_system
#
####################
#
# JSH Scene Tree System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓         ┏┳┓        ┏┓         
#       888  `"Y8888o.   888ooooo888     ┗┓┏┏┓┏┓┏┓   ┃ ┏┓┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┗ ┛┗┗    ┻ ┛ ┗ ┗   ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                              ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Scene Tree System


signal branch_added(branch_path, branch_data)
signal branch_removed(branch_path)
signal branch_status_changed(branch_path, new_status)
# TODO: Implement branch moving functionality
# signal branch_moved(old_path, new_path)
signal tree_updated()

# Debug control
var debug_verbose: bool = false  # Set to true to see all node updates

# Main tree storage
var scene_tree_jsh = {}
var tree_mutex = Mutex.new()

# Cached branches for quick reuse
var cached_jsh_tree_branches = {}
var cached_tree_mutex = Mutex.new()

# Node path cache for handling removed nodes
var _node_path_cache = {}

# Tree visualization
var tree_data = {
	"structure": {},
	"snapshot": "",
	"timestamp": 0,
	"node_count": 0
}

# Status symbols for visualization
var status_symbol = {
	"pending": "⦿",
	"active": "✓",
	"disabled": "✗",
	"cached": "◎"
}

# Reference to main node
var main_ref

# Node type to script mapping
var node_type_scripts = {
	# Updated paths to actual location
	"datapoint": preload("res://scripts/jsh_framework/core/data_point.gd"),
	"container": preload("res://scripts/jsh_framework/core/container.gd")
}

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

#class_name TreeBlueprints #TreeBlueprints.SCENE_TREE_BLUEPRINT BRANCH_BLUEPRINT
const SCENE_TREE_BLUEPRINT = {
	"main_root": {
		"name": [],
		"type": [],
		"jsh_type": [],
		"branches": {},
		"status": "pending",  # pending/processing/complete, now i have pending, active, disabled
		"metadata": {
			"creation_time": 0,
			"priority": 0
		}
	}
}
const BRANCH_BLUEPRINT = {
	"name": [],
	"type": [],
	"jsh_type": [],
	"children": {},
	"parent": [],
	"status": "pending",
	"metadata": {
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"creation_order": 0
	}
}
# the two point o, jsh tree
const JSH_TREE = {
	"name": "",  # Root node name
	"type": "",  # Node type
	"status": "pending",
	"node": null,  # Node reference
	"nodes": {},  # All nodes by path
	"metadata": {
		"creation_time": 0,
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"collisions": [],  # Track collision related nodes
		"groups": [],
		"parent_path": "",
		"full_path": "",
		"creation_order": 0
	}
}

#
func _init():
	name = "JSH_scene_tree_system"
	
func _ready():
	# Get reference to main scene - for ragdoll game this is the current scene
	main_ref = get_tree().current_scene if get_tree() else null
	
	if not main_ref:
		print("[JSHSceneTree] Warning: No main scene found, deferring initialization")
		await get_tree().process_frame
		main_ref = get_tree().current_scene
	
	# Initialize the scene tree
	if main_ref:
		start_up_scene_tree()
		# Setup scene monitoring after tree initialization
		_setup_scene_tree_monitoring()
	else:
		print("[JSHSceneTree] Error: Could not find main scene")
	
	# Debug info
	print("JSH Scene Tree System initialized")


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
####################
# Tree Initialization
####################


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
func start_up_scene_tree():
	tree_mutex.lock()
	scene_tree_jsh = TreeBlueprints.SCENE_TREE_BLUEPRINT.duplicate(true)
	var name_to_add = "main"
	scene_tree_jsh["main_root"]["name"] = name_to_add
	scene_tree_jsh["main_root"]["type"] = "Node"
	scene_tree_jsh["main_root"]["jsh_type"] = "root"
	scene_tree_jsh["main_root"]["metadata"]["creation_time"] = Time.get_ticks_msec()
	scene_tree_jsh["main_root"]["node"] = main_ref
	scene_tree_jsh["main_root"]["status"] = "active"
	tree_mutex.unlock()
	emit_signal("tree_updated")

####################
# Branch Management
####################

func add_branch(branch_path: String, branch_data: Dictionary) -> bool:
	tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var current = scene_tree_jsh["main_root"]["branches"]
	var success = false
	var current_path = ""
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		current_path = current_path + "/" + part if current_path else part
		
		if i == path_parts.size() - 1:
			# This is the branch we want to add
			if !current.has(part):
				current[part] = branch_data
				success = true
			break
			
		if !current.has(part):
			# Create intermediate branches if needed
			var new_branch = TreeBlueprints.BRANCH_BLUEPRINT.duplicate(true)
			new_branch["name"] = part
			new_branch["type"] = "Node3D"
			new_branch["jsh_type"] = "container"
			new_branch["status"] = "pending"
			current[part] = new_branch
		
		# Move deeper into the tree
		if !current[part].has("children"):
			current[part]["children"] = {}
		current = current[part]["children"]
	
	tree_mutex.unlock()
	
	if success:
		emit_signal("branch_added", branch_path, branch_data)
		emit_signal("tree_updated")
	
	return success

func remove_branch(branch_path: String) -> bool:
	tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var parent_parts = path_parts.slice(0, -1)
	var branch_name = path_parts[-1]
	
	var current = scene_tree_jsh["main_root"]["branches"]
	var success = false
	
	# Navigate to parent branch
	for part in parent_parts:
		if !current.has(part):
			tree_mutex.unlock()
			return false
			
		if part != parent_parts[-1]:
			if !current[part].has("children"):
				tree_mutex.unlock()
				return false
			current = current[part]["children"]
		else:
			if !current[part].has("children"):
				tree_mutex.unlock()
				return false
			current = current[part]["children"]
	
	# Remove the branch
	if current.has(branch_name):
		cache_branch_data(branch_path, current[branch_name])
		success = current.erase(branch_name)
	
	tree_mutex.unlock()
	
	if success:
		emit_signal("branch_removed", branch_path)
		emit_signal("tree_updated")
	
	return success

func get_branch(branch_path: String) -> Dictionary:
	tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var current = scene_tree_jsh["main_root"]["branches"]
	var result = {}
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		
		if !current.has(part):
			tree_mutex.unlock()
			return {}
			
		if i == path_parts.size() - 1:
			result = current[part].duplicate(true)
			break
			
		if !current[part].has("children"):
			tree_mutex.unlock()
			return {}
			
		current = current[part]["children"]
	
	tree_mutex.unlock()
	return result

####################
# Status Management
####################

func set_branch_status(branch_path: String, status: String) -> bool:
	tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var current = scene_tree_jsh["main_root"]["branches"]
	var success = false
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		
		if !current.has(part):
			tree_mutex.unlock()
			return false
			
		if i == path_parts.size() - 1:
			var _old_status = current[part]["status"]
			current[part]["status"] = status
			success = true
			tree_mutex.unlock()
			
			emit_signal("branch_status_changed", branch_path, status)
			emit_signal("tree_updated")
			
			return true
			
		if !current[part].has("children"):
			tree_mutex.unlock()
			return false
			
		current = current[part]["children"]
	
	tree_mutex.unlock()
	return success

func get_branch_status(branch_path: String) -> String:
	var branch = get_branch(branch_path)
	return branch.get("status", "unknown")

func disable_branch(branch_path: String) -> bool:
	return set_branch_status(branch_path, "disabled")

func activate_branch(branch_path: String) -> bool:
	return set_branch_status(branch_path, "active")

####################
# Node Operations
####################

func set_branch_node(branch_path: String, node: Node) -> bool:
	tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var current = scene_tree_jsh["main_root"]["branches"]
	var success = false
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		
		if !current.has(part):
			tree_mutex.unlock()
			return false
			
		if i == path_parts.size() - 1:
			current[part]["node"] = node
			success = true
			break
			
		if !current[part].has("children"):
			tree_mutex.unlock()
			return false
			
		current = current[part]["children"]
	
	tree_mutex.unlock()
	
	if success:
		emit_signal("tree_updated")
	
	return success

func get_branch_node(branch_path: String) -> Node:
	var branch = get_branch(branch_path)
	return branch.get("node")

func jsh_tree_get_node(node_path: String) -> Node:
	var path_parts = node_path.split("/")
	
	tree_mutex.lock()
	var current = scene_tree_jsh["main_root"]["branches"]
	tree_mutex.unlock()
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		
		tree_mutex.lock()
		if !current.has(part):
			tree_mutex.unlock()
			return null
			
		current = current[part]
		
		if i == path_parts.size() - 1:
			var node = current.get("node")
			tree_mutex.unlock()
			return node
			
		if !current.has("children"):
			tree_mutex.unlock()
			return null
			
		current = current["children"]
		tree_mutex.unlock()
	
	return null

func validate_branch_nodes(branch_path: String) -> Array:
	var branch = get_branch(branch_path)
	var missing_nodes = []
	
	if branch.empty():
		return ["branch_not_found"]
	
	if !branch.has("node") or !is_instance_valid(branch["node"]):
		missing_nodes.append("main_node")
	
	if branch.has("children"):
		for child_name in branch["children"]:
			var child = branch["children"][child_name]
			if !child.has("node") or !is_instance_valid(child["node"]):
				missing_nodes.append(child_name)
	
	return missing_nodes

####################
# Branch Caching
####################

func cache_branch_data(branch_path: String, branch_data: Dictionary):
	cached_tree_mutex.lock()
	
	var path_parts = branch_path.split("/")
	var branch_name = path_parts[-1]
	
	# Store a copy of the branch with status changed to "cached"
	var cached_branch = branch_data.duplicate(true)
	cached_branch["status"] = "cached"
	cached_branch["node"] = null  # Don't cache node references
	
	# Clear node references in children too
	if cached_branch.has("children"):
		for child_name in cached_branch["children"]:
			cached_branch["children"][child_name]["node"] = null
			cached_branch["children"][child_name]["status"] = "cached"
	
	cached_jsh_tree_branches[branch_name] = cached_branch
	
	cached_tree_mutex.unlock()

func restore_cached_branch(branch_name: String) -> Dictionary:
	cached_tree_mutex.lock()
	
	var branch_data = {}
	
	if cached_jsh_tree_branches.has(branch_name):
		branch_data = cached_jsh_tree_branches[branch_name].duplicate(true)
		cached_jsh_tree_branches.erase(branch_name)
	
	cached_tree_mutex.unlock()
	
	return branch_data

func has_cached_branch(branch_name: String) -> bool:
	cached_tree_mutex.lock()
	var result = cached_jsh_tree_branches.has(branch_name)
	cached_tree_mutex.unlock()
	return result
#

func _append_branch_to_output(branch: Dictionary, output: String, prefix: String):
	if branch.has("children"):
		var keys = branch["children"].keys()
		for i in range(keys.size()):
			var child_name = keys[i]
			var child = branch["children"][child_name]
			var status = child.get("status", "pending")
			
			if i == keys.size() - 1:
				output += prefix + "┗━ " + child_name + " (" + child["type"] + ") " + status_symbol[status] + "\n"
				_append_branch_to_output(child, output, prefix + "   ")
			else:
				output += prefix + "┣━ " + child_name + " (" + child["type"] + ") " + status_symbol[status] + "\n"
				_append_branch_to_output(child, output, prefix + "┃  ")

func build_pretty_print(node: Node, prefix: String = "", is_last: bool = true) -> String:
	var output = ""
	output += prefix
	output += "┖╴" if is_last else "┠╴"
	output += node.name + "\n"
	
	var children = node.get_children()
	for i in range(children.size()):
		var child = children[i]
		var child_prefix = prefix + ("   " if is_last else "┃  ")
		var child_is_last = i == children.size() - 1
		output += build_pretty_print(child, child_prefix, child_is_last)
	
	return output

func capture_tree_state() -> Dictionary:
	var root = get_tree().get_root()
	tree_data.structure = capture_node_structure(root)
	tree_data.snapshot = build_pretty_print(root)
	tree_data.timestamp = Time.get_unix_time_from_system()
	tree_data.node_count = 0  # Reset counter
	return tree_data

func capture_node_structure(node: Node) -> Dictionary:
	var data = {
		"name": node.name,
		"class": node.get_class(),
		"path": str(node.get_path()),
		"children": []
	}
	
	for child in node.get_children():
		data.children.append(capture_node_structure(child))
		tree_data.node_count += 1
	
	return data

####################
# Node Type Helpers
####################

func match_node_type(type: String) -> String:
	match type:
		"flat_shape", "model", "cursor", "screen", "circle":
			return "MeshInstance3D"
		"text":
			return "Label3D"
		"button":
			return "Node3D" 
		"connection":
			return "MeshInstance3D"
		"text_mesh":
			return "MeshInstance3D"
		"datapoint":
			return "Node3D"
		"container":
			return "Node3D"
		_:
			return "Node3D"

####################
# Container Management
####################

func check_if_container_available(container: String) -> bool:
	tree_mutex.lock()
	var result = false
	
	if scene_tree_jsh["main_root"]["branches"].has(container):
		result = true
	
	tree_mutex.unlock()
	return result

func check_if_datapoint_available(container: String) -> bool:
	tree_mutex.lock()
	var result = false
	
	if scene_tree_jsh["main_root"]["branches"].has(container):
		if scene_tree_jsh["main_root"]["branches"][container].has("datapoint"):
			result = true
	
	tree_mutex.unlock()
	return result

func check_if_datapoint_node_available(container: String) -> String:
	tree_mutex.lock()
	var datapoint_path = ""
	
	if scene_tree_jsh["main_root"]["branches"].has(container):
		if scene_tree_jsh["main_root"]["branches"][container].has("datapoint"):
			datapoint_path = scene_tree_jsh["main_root"]["branches"][container]["datapoint"]["datapoint_path"]
	
	tree_mutex.unlock()
	return datapoint_path

####################
# Node Management & Instantiation
####################

func jsh_tree_get_node_status_changer(node_path: String, _node_name: String, node_to_check: Node):
	var path_parts = node_path.split("/")
	
	tree_mutex.lock()
	var current = scene_tree_jsh["main_root"]["branches"]
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		
		if !current.has(part):
			tree_mutex.unlock()
			return
		
		if i == path_parts.size() - 1:
			if node_to_check:
				current[part]["status"] = "active"
				current[part]["node"] = node_to_check
				emit_signal("branch_status_changed", node_path, "active")
			break
		
		if !current[part].has("children"):
			tree_mutex.unlock()
			return
			
		current = current[part]["children"]
	
	tree_mutex.unlock()
	emit_signal("tree_updated")
#

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

#####################
## Visualization
#####################
#
#func print_tree_pretty():
	#var output = "JSH Scene Tree Structure:\n"
	#output += "========================\n\n"
	#
	#tree_mutex.lock()
	#var root = scene_tree_jsh["main_root"]
	#tree_mutex.unlock()
	#
	#output += root["name"] + " (" + root["type"] + ") " + status_symbol[root["status"]] + "\n"
	#
	#tree_mutex.lock()
	#if root.has("branches"):
		#for branch_name in root["branches"]:
			#var branch = root["branches"][branch_name]
			#var status = branch.get("status", "pending")
			#output += "┣━ " + branch_name + " (" + branch["type"] + ") " + status_symbol[status] + "\n"
			#_append_branch_to_output(branch, output, "┃  ")
	#tree_mutex.unlock()
	#
	#print(output)
	#return output
####################
## jsh_scene_tree_system.gd
## node too, JSH_scene_tree_system
## /root/main/

# needs work
# JSH_Core/JSH_scene_tree_system
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_scene_tree_system.gd
#extends UniversalBeingBase
####################
# Branch Creation and Management
####################
#
#func the_pretender_printer(node_name: String, node_path_jsh_tree: String, godot_node_type: String, node_type: String = "Node3D"):
	#tree_mutex.lock()
	#
	#if !scene_tree_jsh.has("main_root"):
		#scene_tree_jsh = TreeBlueprints.SCENE_TREE_BLUEPRINT.duplicate(true)
		#scene_tree_jsh["main_root"]["name"] = "main"
		#scene_tree_jsh["main_root"]["type"] = "Node3D"
		#scene_tree_jsh["main_root"]["status"] = "active"
		#scene_tree_jsh["main_root"]["node"] = main_ref
	#
	#var path_parts = node_path_jsh_tree.split("/")
	#var current_branch = scene_tree_jsh["main_root"]["branches"]
	#
	#cached_tree_mutex.lock()
	#var cached_current_branch = cached_jsh_tree_branches
	#cached_tree_mutex.unlock()
	#
	#var current_full_path = ""
	#
	#for i in range(path_parts.size()):
		#var part = path_parts[i]
		#current_full_path = current_full_path + "/" + part if current_full_path else part
		#
		#if !current_branch.has(part):
			#if cached_current_branch.has(part):
				## Restore from cache
				#current_branch[part] = cached_current_branch[part]
				#cached_current_branch.erase(part)
			#else:
				## Create new branch
				#var new_branch = TreeBlueprints.BRANCH_BLUEPRINT.duplicate(true)
				#new_branch["name"] = part
				#new_branch["type"] = godot_node_type.split("|")[0] if "|" in godot_node_type else godot_node_type
				#new_branch["jsh_type"] = node_type
				#new_branch["status"] = "pending"
				#new_branch["node"] = null
				#new_branch["metadata"] = {
					#"creation_time": Time.get_ticks_msec(),
					#"full_path": current_full_path,
					#"parent_path": current_full_path.get_base_dir(),
					#"has_collision": node_type == "collision",
					#"has_area": node_type == "area"
				#}
				#
				## Special handling for datapoint
				#if node_type == "datapoint":
					#scene_tree_jsh["main_root"]["branches"][path_parts[0]]["datapoint"] = {
						#"datapoint_name": new_branch["name"],
						#"datapoint_path": new_branch["metadata"]["full_path"]
					#}
				#
				#current_branch[part] = new_branch
				#emit_signal("branch_added", current_full_path, new_branch)
		#}
		#
		#if i < path_parts.size() - 1:
			#if !current_branch[part].has("children"):
				#current_branch[part]["children"] = {}
			#
			#current_branch = current_branch[part]["children"]
			#
			#if cached_current_branch.has(part):
				#if cached_current_branch[part].has("children"):
					#cached_current_branch = cached_current_branch[part]["children"]
	#
	#tree_mutex.unlock()
	#emit_signal("tree_updated")

####################
# Utility Functions
####################
#
#func find_branch_to_unload(thing_path: String):
	#var new_path_splitter = str(thing_path).split("/")
	#
	#if new_path_splitter.size() < 2:
		#return
	#
	#tree_mutex.lock()
	#
	#if scene_tree_jsh["main_root"]["branches"].has(new_path_splitter[0]):
		#if scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"].has(new_path_splitter[1]):
			#var branch_part_to_cache = scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"][new_path_splitter[1]].duplicate(true)
			#
			## Cache the branch
			#cache_branch_data(thing_path, branch_part_to_cache)
			#
			## Remove from tree
			#scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"].erase(new_path_splitter[1])
			#emit_signal("branch_removed", thing_path)
		#}
	#}
	#
	#tree_mutex.unlock()
	#emit_signal("tree_updated")
#
#func disable_all_branches(branch_to_disable: Dictionary):
	#var branches_to_process = [branch_to_disable]
	#
	#while branches_to_process.size() > 0:
		#var current_branch = branches_to_process[0]
		#branches_to_process.remove_at(0)
		#
		#current_branch["status"] = "disabled"
		#current_branch["node"] = null
		#
		#if current_branch.has("children"):
			#for child_name in current_branch["children"]:
				#branches_to_process.append(current_branch["children"][child_name])
				#current_branch["children"][child_name]["status"] = "disabled"
				#current_branch["children"][child_name]["node"] = null
	#}
	#
	#emit_signal("tree_updated")

####################
# Scene Tree Monitoring (NEW)
####################

func _setup_scene_tree_monitoring() -> void:
	print("[JSHSceneTreeSystem] Setting up scene tree monitoring...")
	
	# Connect to Godot's scene tree signals for automatic propagation
	get_tree().node_added.connect(_on_godot_node_added)
	get_tree().node_removed.connect(_on_godot_node_removed)
	get_tree().node_renamed.connect(_on_godot_node_renamed)
	
	# Start monitoring timer for periodic sync
	var sync_timer = TimerManager.get_timer()
	sync_timer.wait_time = 1.0  # Sync every second
	sync_timer.timeout.connect(_sync_with_godot_tree)
	sync_timer.autostart = true
	add_child(sync_timer)
	
	print("[JSHSceneTreeSystem] Scene tree monitoring setup complete")

func _on_godot_node_added(node: Node) -> void:
	# When a node is added to Godot's scene tree, add it to JSH tree
	var node_path = _get_jsh_path_for_node(node)
	if node_path != "":
		var branch_data = _create_branch_data_from_node(node)
		add_branch(node_path, branch_data)
		if debug_verbose:
			print("[JSHSceneTreeSystem] Auto-added node: " + node_path)

func _on_godot_node_removed(node: Node) -> void:
	# When a node is removed from Godot's scene tree, remove it from JSH tree
	# Safety check for null/invalid nodes during removal
	if not node or not is_instance_valid(node):
		return
	
	var node_path = _get_jsh_path_for_node(node)
	if node_path != "":
		remove_branch(node_path)
		if debug_verbose:
			print("[JSHSceneTreeSystem] Auto-removed node: " + node_path)
	
	# Clean up cache for this node
	if _node_path_cache.has(node):
		_node_path_cache.erase(node)

func _on_godot_node_renamed(node: Node) -> void:
	# When a node is renamed, update JSH tree
	var node_path = _get_jsh_path_for_node(node)
	if node_path != "":
		# Update the existing branch with new name
		var branch = get_branch(node_path)
		if not branch.is_empty():
			branch["name"] = node.name
			tree_updated.emit()
		if debug_verbose:
			print("[JSHSceneTreeSystem] Auto-renamed node: " + node_path)

func _sync_with_godot_tree() -> void:
	# Periodic sync to catch any missed changes
	var current_scene = get_tree().current_scene
	if current_scene:
		_sync_node_recursive(current_scene, "main_root/scene")
	
	# Clean up stale entries from node path cache
	_cleanup_node_path_cache()

func _sync_node_recursive(node: Node, jsh_path: String) -> void:
	# Ensure this node exists in JSH tree
	var branch = get_branch(jsh_path)
	if branch.is_empty():
		var branch_data = _create_branch_data_from_node(node)
		add_branch(jsh_path, branch_data)
	else:
		# Update existing branch data
		branch["node"] = node
		branch["status"] = "active"
	
	# Sync all children
	for child in node.get_children():
		var child_path = jsh_path + "/" + child.name
		_sync_node_recursive(child, child_path)

func _get_jsh_path_for_node(node: Node) -> String:
	# Convert Godot node path to JSH path format
	if not node or not is_instance_valid(node):
		return ""
	
	var path_parts = []
	var current_node = node
	
	# Build path from node to root - use Engine for safety during node removal
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return ""
	
	# Check if node is still in tree
	if not node.is_inside_tree():
		# For nodes being removed, try to use cached path if available
		if _node_path_cache.has(node):
			return _node_path_cache[node]
		return ""
	
	while current_node and current_node != tree.root:
		path_parts.push_front(current_node.name)
		current_node = current_node.get_parent()
		if not current_node:
			break
	
	# Create JSH-style path
	if path_parts.size() > 0:
		var jsh_path = "main_root/scene/" + "/".join(path_parts)
		# Cache the path for later removal
		_node_path_cache[node] = jsh_path
		return jsh_path
	
	return ""

func _create_branch_data_from_node(node: Node) -> Dictionary:
	# Create JSH branch data structure from Godot node
	var branch_data = BRANCH_BLUEPRINT.duplicate(true)
	
	branch_data["name"] = node.name
	branch_data["type"] = node.get_class()
	branch_data["jsh_type"] = _get_jsh_type_for_node(node)
	branch_data["status"] = "active"
	branch_data["node"] = node
	
	# Add position if it's a Node3D
	if node is Node3D:
		branch_data["metadata"]["position"] = node.position
		branch_data["metadata"]["rotation"] = node.rotation
	
	# Add creation time
	branch_data["metadata"]["creation_time"] = Time.get_ticks_msec()
	
	return branch_data

func _get_jsh_type_for_node(node: Node) -> String:
	# Map Godot node types to JSH types
	if node is RigidBody3D:
		return "physics_object"
	elif node is CharacterBody3D:
		return "character"
	elif node is MeshInstance3D:
		return "mesh"
	elif node is Light3D:
		return "light"
	elif node is Camera3D:
		return "camera"
	elif node is CollisionShape3D:
		return "collision"
	elif node is Node3D:
		return "spatial"
	elif node is Control:
		return "ui"
	else:
		return "node"

# Enhanced public API for scene monitoring
func force_full_sync() -> void:
	# Force a complete resync with Godot's scene tree
	print("[JSHSceneTreeSystem] Forcing full scene tree sync...")
	tree_mutex.lock()
	scene_tree_jsh.clear()
	start_up_scene_tree()  # Use the existing initialization function
	tree_mutex.unlock()
	_sync_with_godot_tree()
	tree_updated.emit()
	print("[JSHSceneTreeSystem] Full sync completed")

func get_sync_status() -> Dictionary:
	# Get information about sync status
	var godot_node_count = _count_godot_nodes(get_tree().current_scene)
	var jsh_node_count = _count_jsh_nodes(scene_tree_jsh)
	
	return {
		"godot_nodes": godot_node_count,
		"jsh_nodes": jsh_node_count,
		"sync_ratio": float(jsh_node_count) / float(godot_node_count) if godot_node_count > 0 else 0.0,
		"last_sync": Time.get_ticks_msec()
	}

func _count_godot_nodes(node: Node) -> int:
	if not node:
		return 0
	
	var count = 1
	for child in node.get_children():
		count += _count_godot_nodes(child)
	return count

func _count_jsh_nodes(tree_dict: Dictionary) -> int:
	var count = 0
	for key in tree_dict:
		count += 1
		if tree_dict[key].has("children"):
			count += _count_jsh_nodes(tree_dict[key]["children"])
	return count

func _cleanup_node_path_cache() -> void:
	# Remove entries for nodes that are no longer valid or in tree
	var nodes_to_remove = []
	for node in _node_path_cache:
		if not is_instance_valid(node) or (is_instance_valid(node) and not node.is_inside_tree()):
			nodes_to_remove.append(node)
	
	for node in nodes_to_remove:
		_node_path_cache.erase(node)

#
extends Node
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
signal branch_moved(old_path, new_path)
signal tree_updated()

# Main tree storage
var scene_tree_jsh = {}
var tree_mutex = Mutex.new()

# Cached branches for quick reuse
var cached_jsh_tree_branches = {}
var cached_tree_mutex = Mutex.new()

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
	# code/gdscript/
	"datapoint": preload("res://code/gdscript/scripts/Menu_Keyboard_Console/data_point.gd"),
	"container": preload("res://code/gdscript/scripts/Menu_Keyboard_Console/container.gd")
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
	# Get reference to main node
	main_ref = get_node("/root/main")
	
	# Initialize the scene tree
	start_up_scene_tree()
	
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
			var old_status = current[part]["status"]
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

func jsh_tree_get_node_status_changer(node_path: String, node_name: String, node_to_check: Node):
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
#extends Node
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

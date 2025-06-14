# ==================================================
# SCRIPT NAME: scene_tree_tracker.gd
# DESCRIPTION: JSH-style scene tree tracking for floodgate
# PURPOSE: Track scene hierarchy like JSH system
# CREATED: 2025-05-24 - Scene persistence system
# ==================================================

extends UniversalBeingBase
class_name SceneTreeTracker

# Scene tree structure similar to JSH
var scene_tree_jsh: Dictionary = {}
var tree_mutex: Mutex = Mutex.new()
var cached_branches: Dictionary = {}

# Branch status symbols
var status_symbol = {
	"active": "✅",
	"pending": "⏳", 
	"disabled": "❌",
	"cached": "💾"
}

# Branch blueprint
const BRANCH_BLUEPRINT = {
	"name": "",
	"type": "",
	"jsh_type": "",
	"parent": null,
	"status": "pending",
	"node": null,
	"metadata": {
		"creation_time": 0,
		"full_path": "",
		"parent_path": "",
		"has_collision": false,
		"has_area": false
	},
	"children": {}
}

const SCENE_TREE_BLUEPRINT = {
	"main_root": {
		"name": "root",
		"type": "Node3D",
		"status": "active",
		"node": null,
		"metadata": {
			"creation_time": 0
		},
		"branches": {}
	}
}

## Initialize the tree structure
func _ready() -> void:
	start_up_scene_tree()

## Start up scene tree

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
func start_up_scene_tree():
	tree_mutex.lock()
	scene_tree_jsh = SCENE_TREE_BLUEPRINT.duplicate(true)
	var root_node = get_tree().root
	scene_tree_jsh["main_root"]["name"] = root_node.name
	scene_tree_jsh["main_root"]["type"] = root_node.get_class()
	scene_tree_jsh["main_root"]["metadata"]["creation_time"] = Time.get_ticks_msec()
	scene_tree_jsh["main_root"]["node"] = root_node
	scene_tree_jsh["main_root"]["status"] = "active"
	tree_mutex.unlock()

## Add a node to the tree
func track_node(node: Node, category: String = "") -> void:
	tree_mutex.lock()
	
	var node_path = str(node.get_path())
	var path_parts = node_path.split("/")
	
	# Remove empty parts
	var filtered_parts = []
	for part in path_parts:
		if part != "":
			filtered_parts.append(part)
	path_parts = filtered_parts
	
	var current_branch = scene_tree_jsh["main_root"]["branches"]
	var current_full_path = ""
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		current_full_path = current_full_path + "/" + part if current_full_path else part
		
		if not current_branch.has(part):
			var new_branch = BRANCH_BLUEPRINT.duplicate(true)
			new_branch["name"] = part
			new_branch["type"] = node.get_class() if i == path_parts.size() - 1 else "Node3D"
			new_branch["jsh_type"] = category
			new_branch["status"] = "pending"
			new_branch["node"] = null
			new_branch["metadata"]["creation_time"] = Time.get_ticks_msec()
			new_branch["metadata"]["full_path"] = current_full_path
			new_branch["metadata"]["parent_path"] = current_full_path.get_base_dir()
			
			current_branch[part] = new_branch
		
		# If this is the final node, update its info
		if i == path_parts.size() - 1:
			current_branch[part]["node"] = node
			current_branch[part]["status"] = "active"
			current_branch[part]["type"] = node.get_class()
			if category:
				current_branch[part]["jsh_type"] = category
		else:
			# Navigate deeper
			if not current_branch[part].has("children"):
				current_branch[part]["children"] = {}
			current_branch = current_branch[part]["children"]
	
	tree_mutex.unlock()

## Remove a node from tracking
func untrack_node(node: Node) -> void:
	tree_mutex.lock()
	var node_path = str(node.get_path())
	_remove_branch_by_path(node_path)
	tree_mutex.unlock()

## Get node by JSH path
func jsh_tree_get_node(node_path_get: String) -> Node:
	var path_parts = node_path_get.split("/")
	tree_mutex.lock()
	
	var current = scene_tree_jsh["main_root"]["branches"]
	
	for i in range(path_parts.size()):
		var part = path_parts[i]
		if current.has(part):
			if i == path_parts.size() - 1:
				# Last part - return the node
				var node = current[part].get("node")
				tree_mutex.unlock()
				return node
			else:
				# Navigate deeper
				current = current[part]
				if current.has("children"):
					current = current["children"]
				else:
					tree_mutex.unlock()
					return null
		else:
			tree_mutex.unlock()
			return null
	
	tree_mutex.unlock()
	return null

## Pretty print the tree
func build_pretty_print(start_branch: Dictionary = {}, prefix: String = "", is_last: bool = true) -> String:
	if start_branch.is_empty():
		start_branch = scene_tree_jsh["main_root"]
	
	var output = ""
	output += prefix
	output += "┖╴" if is_last else "┠╴"
	output += start_branch.name + " (" + start_branch.type + ") " + status_symbol.get(start_branch.status, "?") + "\n"
	
	var branches = start_branch.get("branches", {})
	var children = start_branch.get("children", {})
	var all_items = {}
	
	# Merge branches and children
	for key in branches:
		all_items[key] = branches[key]
	for key in children:
		all_items[key] = children[key]
	
	var keys = all_items.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var child = all_items[key]
		var child_prefix = prefix + ("   " if is_last else "┃  ")
		var child_is_last = i == keys.size() - 1
		output += build_pretty_print(child, child_prefix, child_is_last)
	
	return output

## Print tree to console
func print_tree_structure() -> void:
	print("\n=== Scene Tree Structure ===")
	print(build_pretty_print())

## Get all nodes of a type
func get_nodes_by_type(jsh_type: String) -> Array[Node]:
	var nodes: Array[Node] = []
	tree_mutex.lock()
	_collect_nodes_by_type(scene_tree_jsh["main_root"]["branches"], jsh_type, nodes)
	tree_mutex.unlock()
	return nodes

## Internal helper to collect nodes
func _collect_nodes_by_type(branches: Dictionary, jsh_type: String, nodes: Array[Node]) -> void:
	for branch_name in branches:
		var branch = branches[branch_name]
		if branch.get("jsh_type") == jsh_type and branch.get("node"):
			nodes.append(branch["node"])
		
		if branch.has("children"):
			_collect_nodes_by_type(branch["children"], jsh_type, nodes)

## Internal helper to remove branch
func _remove_branch_by_path(path: String) -> void:
	var path_parts = path.split("/")
	var filtered_parts = []
	for part in path_parts:
		if part != "":
			filtered_parts.append(part)
	
	if filtered_parts.is_empty():
		return
	
	path_parts = filtered_parts
	
	var current = scene_tree_jsh["main_root"]["branches"]
	var parent_branches = []
	
	# Navigate to the branch
	for i in range(path_parts.size() - 1):
		var part = path_parts[i]
		if current.has(part):
			parent_branches.append({"branches": current, "key": part})
			if current[part].has("children"):
				current = current[part]["children"]
			else:
				return
		else:
			return
	
	# Remove the final branch
	var final_part = path_parts[-1]
	if current.has(final_part):
		current.erase(final_part)

## Get scene statistics
func get_tree_stats() -> Dictionary:
	var stats = {
		"total_nodes": 0,
		"active_nodes": 0,
		"pending_nodes": 0,
		"disabled_nodes": 0,
		"by_type": {}
	}
	
	tree_mutex.lock()
	_collect_stats(scene_tree_jsh["main_root"]["branches"], stats)
	tree_mutex.unlock()
	
	return stats

## Internal stats collector
func _collect_stats(branches: Dictionary, stats: Dictionary) -> void:
	for branch_name in branches:
		var branch = branches[branch_name]
		stats.total_nodes += 1
		
		match branch.status:
			"active": stats.active_nodes += 1
			"pending": stats.pending_nodes += 1
			"disabled": stats.disabled_nodes += 1
		
		var jsh_type = branch.get("jsh_type", "unknown")
		if not stats.by_type.has(jsh_type):
			stats.by_type[jsh_type] = 0
		stats.by_type[jsh_type] += 1
		
		if branch.has("children"):
			_collect_stats(branch["children"], stats)

# Ragdoll tracking functionality
func has_branch(path: String) -> bool:
	tree_mutex.lock()
	var parts = path.split("/")
	var current = scene_tree_jsh
	
	for part in parts:
		if not current.has(part):
			tree_mutex.unlock()
			return false
		current = current[part]
		if current.has("children"):
			current = current["children"]
	
	tree_mutex.unlock()
	return true

func get_branch(path: String) -> Dictionary:
	tree_mutex.lock()
	var parts = path.split("/")
	var current = scene_tree_jsh
	
	for part in parts:
		if not current.has(part):
			tree_mutex.unlock()
			return {}
		current = current[part]
		if current.has("children") and part != parts[-1]:
			current = current["children"]
	
	tree_mutex.unlock()
	return current

func _set_branch_unsafe(path: String, _data: Dictionary) -> void:
	# Assumes mutex is already locked
	var parts = path.split("/")
	var current = scene_tree_jsh
	
	# Navigate to parent
	for i in range(parts.size() - 1):
		var part = parts[i]
		if not current.has(part):
			current[part] = {"children": {}}
		current = current[part]["children"]
	
	# Set the leaf node
	current[parts[-1]] = _data

func track_ragdoll_movement(ragdoll_id: String, position: Vector3, state: String) -> void:
	tree_mutex.lock()
	
	# Create or update ragdoll branch
	var ragdoll_branch_path = "world/entities/ragdolls/" + ragdoll_id
	var ragdoll_data = {
		"name": ragdoll_id,
		"type": "ragdoll",
		"jsh_type": "entity",
		"parent": "world/entities/ragdolls",
		"status": "active",
		"position": position,
		"state": state,
		"last_update": Time.get_unix_time_from_system(),
		"movement_history": []
	}
	
	# Update existing ragdoll or create new
	if has_branch(ragdoll_branch_path):
		var existing = get_branch(ragdoll_branch_path)
		if existing.has("movement_history"):
			ragdoll_data.movement_history = existing.movement_history
		ragdoll_data.movement_history.append({
			"position": position,
			"state": state,
			"timestamp": Time.get_unix_time_from_system()
		})
		# Keep only last 10 positions
		if ragdoll_data.movement_history.size() > 10:
			ragdoll_data.movement_history.pop_front()
	
	# Ensure parent structure exists
	_ensure_ragdoll_parent_structure()
	
	# Update branch
	_set_branch_unsafe(ragdoll_branch_path, ragdoll_data)
	
	tree_mutex.unlock()
	print("[SceneTreeTracker] Tracked ragdoll " + ragdoll_id + " at " + str(position) + " (" + state + ")")

func _ensure_ragdoll_parent_structure() -> void:
	# Create world branch
	if not has_branch("world"):
		_set_branch_unsafe("world", {
			"name": "world",
			"type": "container",
			"jsh_type": "world",
			"parent": null,
			"status": "active",
			"children": {}
		})
	
	# Create entities branch
	if not has_branch("world/entities"):
		_set_branch_unsafe("world/entities", {
			"name": "entities",
			"type": "container", 
			"jsh_type": "entities",
			"parent": "world",
			"status": "active",
			"children": {}
		})
	
	# Create ragdolls branch
	if not has_branch("world/entities/ragdolls"):
		_set_branch_unsafe("world/entities/ragdolls", {
			"name": "ragdolls",
			"type": "container",
			"jsh_type": "ragdolls",
			"parent": "world/entities", 
			"status": "active",
			"children": {}
		})

func get_ragdoll_status(ragdoll_id: String) -> Dictionary:
	var ragdoll_branch_path = "world/entities/ragdolls/" + ragdoll_id
	if has_branch(ragdoll_branch_path):
		return get_branch(ragdoll_branch_path)
	return {}

func get_all_ragdolls() -> Dictionary:
	if has_branch("world/entities/ragdolls"):
		var ragdolls_branch = get_branch("world/entities/ragdolls")
		return ragdolls_branch.get("children", {})
	return {}
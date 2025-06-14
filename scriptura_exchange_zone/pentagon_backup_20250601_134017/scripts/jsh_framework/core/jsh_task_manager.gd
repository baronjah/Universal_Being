# 🏛️ Jsh Task Manager - Resource management system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Resource management system
# Connection: Part of Pentagon Architecture migration

# jsh_task_manager.gd
#
# JSH_Core/JSH_task_manager
#
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_task_manager.gd
#
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_task_manager.gd
#
# root/JSH_task_manager
# JSH_Core/JSH_task_manager
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_task_manager.gd
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

extends UniversalBeingBase
var rng
var ram_data
var rom_data
var rules
# Data flow tracking
var data_flows = {}
var interaction_points = []
var scene_movements = {}
# Task list
var tasks = []
var current_task_id = 0
# Visualization nodes
var visualization_root = null
var flow_lines = []
var array_for_tasks : Array = []
var array_for_tasks_mutex = Mutex.new()
var dictionary_of_functions : Dictionary = {}
var dictionary_of_functions_mutex = Mutex.new()
# Turn Management
var current_turn := 0
var command_queue := []
var active_containers := {}  # RAM
var stored_containers := {}  # ROM
var turn_phases = ["LOAD", "PROCESS", "COMMIT", "CLEANUP"]

# Task metadata tracking
var task_metadata = {
	"mutex": Mutex.new(),
	"tasks": {},
	"categories": {},
	"dependencies": {},
	"progress": {}
}

# Code structure tracking
var code_structure = {
	"functions": {},
	"systems": {},
	"relationships": {}
}

var task_history = {
	"first_tasks": {},        # First completion of each task type
	"latest_tasks": {},       # Most recent completion of each task
	"completion_counts": {},   # How many times each task was completed
	"task_timings": {}        # Time taken for each task
}

var container_lod_settings := {
	"distances": [10.0, 20.0, 50.0],
	"detail_levels": [32, 16, 8],
	"load_radius": 100.0
}

var global_rules := {
	"inheritance": {
		"seed_variance": 0.5,
		"rule_mutation": 0.1
	},
	"pattern_detection": {
		"history_depth": 5,
		"similarity_threshold": 0.8
	}
}
# Statistics
var stats = {
	"total_tasks": 0,
	"completed_tasks": 0,
	"failed_tasks": 0,
	"avg_completion_time": 0.0
}

const MAX_TASKS = 100
const DEBUG_MODE = true
const ROM_PATH = "user://containers/"

const singular_task = {
	"task_id" : [],
	"function" : [],
	"data" : []
}

const TASK_CATEGORIES = {
	"INITIALIZATION": {
		"priority": 0,
		"dependencies": [],
		"description": "System startup and initialization tasks"
	},
	"CORE_SYSTEMS": {
		"priority": 1,
		"dependencies": ["INITIALIZATION"],
		"description": "Core system functionalities"
	},
	"DATA_MANAGEMENT": {
		"priority": 2,
		"dependencies": ["CORE_SYSTEMS"],
		"description": "Data handling and storage"
	},
	"SCENE_MANAGEMENT": {
		"priority": 3,
		"dependencies": ["CORE_SYSTEMS"],
		"description": "Scene tree and node management"
	}
}
# Task status enum
enum TaskStatus {
	PENDING,
	RUNNING,
	COMPLETED,
	FAILED
}
# Procedural Generation System
class ProceduralEngine:
	static func generate_container_mesh(container : SpatialContainer):
		var mesh := ArrayMesh.new()
		var rng = RandomNumberGenerator.new()
		rng.seed = container.seed
		
		# Generate base shape using seed
		var shape = generate_base_shape(rng)
		
		# Apply evolution rules
		shape = apply_evolutionary_rules(shape, container.history)
		
		# Apply LOD simplification
		shape = simplify_for_lod(shape, container.lod_level)
		
		return mesh

	static func generate_base_shape(_rng):
		# Implement procedural generation logic using seed
		pass

	static func apply_evolutionary_rules(shape, _history):
		# Apply shape modifications based on history
		return shape

	static func simplify_for_lod(shape, _lod_level):
		# Simplify mesh based on LOD level
		return shape

# Spatial Containers
class SpatialContainer:
	var uuid : String
	var position : Vector3
	var lod_level := 0
	var ram_data := {}
	var rom_data := {}
	var history := []
	var container_seed : int
	var rules := {}
	var children := []
	var parent : String
	
	func _init(init_seed : int, pos : Vector3):
		container_seed = init_seed
		position = pos
		uuid = str(init_seed) + "_" + str(pos).sha1_text().substr(0,8)
		

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
	func evolve(turn : int, command):
		var change = {
			"turn": turn,
			"before": ram_data.duplicate(true),
			"command": command
		}
		
		# Apply procedural rules
		var rng = RandomNumberGenerator.new()
		rng.seed = container_seed + turn
		

		# Example rule application
		if rules.has("scale_pattern"):
			apply_scale_pattern(rng)
		
		history.append(change)
	
	
	func apply_scale_pattern(data):
		print(" apply scale pattern ", data)
		
		
	func serialize():
		return {
			"uuid": uuid,
			"position": position,
			"seed": container_seed,
			"rom_data": rom_data,
			"rules": rules
		}
	

	## check time
	## last time
func _ready():

	#initialize_world_seed(OS.get_unix_time())
	initialize_task_system()
	print("JSH Task Manager initialized")
	# Create visualization container if needed
	if DEBUG_MODE:
		visualization_root = Node3D.new()
		visualization_root.name = "DataFlowVisualization"
		add_child(visualization_root)

##
# Add a new task to the manager
func add_task(task_name, priority = 0, dependencies = []):
	if tasks.size() >= MAX_TASKS:
		prune_completed_tasks()
		
	var task = {
		"id": current_task_id,
		"name": task_name,
		"status": TaskStatus.PENDING,
		"priority": priority,
		"dependencies": dependencies,
		"creation_time": Time.get_ticks_msec(),
		"start_time": 0,
		"end_time": 0,
		"data_path": []
	}
	
	tasks.append(task)
	stats.total_tasks += 1
	current_task_id += 1
	
	return task.id

# Start a task by ID
func start_task(task_id):
	var task_index = _find_task_index(task_id)
	if task_index == -1:
		return false
		
	var task = tasks[task_index]
	
	# Check dependencies
	for dep_id in task.dependencies:
		var dep_index = _find_task_index(dep_id)
		if dep_index != -1 and tasks[dep_index].status != TaskStatus.COMPLETED:
			print("Task ", task_id, " waiting for dependency: ", dep_id)
			return false
	
	task.status = TaskStatus.RUNNING
	task.start_time = Time.get_ticks_msec()
	return true

# Complete a task
func complete_task(task_id, success = true):
	var task_index = _find_task_index(task_id)
	if task_index == -1:
		return false
		
	var task = tasks[task_index]
	task.end_time = Time.get_ticks_msec()
	
	if success:
		task.status = TaskStatus.COMPLETED
		stats.completed_tasks += 1
		
		# Update average completion time
		var duration = task.end_time - task.start_time
		stats.avg_completion_time = ((stats.avg_completion_time * (stats.completed_tasks - 1)) + duration) / stats.completed_tasks
	else:
		task.status = TaskStatus.FAILED
		stats.failed_tasks += 1
	
	return true

# Track data flow between two objects
func track_data_flow(source_path, target_path, data_type, amount = 1.0):
	var flow_key = source_path + "->" + target_path
	
	if not data_flows.has(flow_key):
		data_flows[flow_key] = {
			"source": source_path,
			"target": target_path,
			"type": data_type,
			"count": 0,
			"total_amount": 0.0,
			"last_update": 0
		}
	
	data_flows[flow_key].count += 1
	data_flows[flow_key].total_amount += amount
	data_flows[flow_key].last_update = Time.get_ticks_msec()
	
	# Update visualization
	if DEBUG_MODE:
		_update_flow_visualization(flow_key)
	
	return flow_key

# Record user interaction at a specific point
func record_interaction(position, type, data = null):
	var interaction = {
		"position": position,
		"type": type,
		"time": Time.get_ticks_msec(),
		"data": data
	}
	
	interaction_points.append(interaction)
	
	# Visualize the interaction if in debug mode
	if DEBUG_MODE:
		_visualize_interaction(interaction)
	
	return interaction_points.size() - 1

# Track scene movement
func track_scene_movement(scene_path, from_position, to_position, duration):
	var movement = {
		"scene": scene_path,
		"from": from_position,
		"to": to_position,
		"start_time": Time.get_ticks_msec(),
		"duration": duration,
		"completed": false
	}
	
	if not scene_movements.has(scene_path):
		scene_movements[scene_path] = []
	
	scene_movements[scene_path].append(movement)
	
	# Add to visualization
	if DEBUG_MODE:
		_visualize_movement(scene_path, movement)
	
	return scene_movements[scene_path].size() - 1

# Update a scene movement's status
func complete_scene_movement(scene_path, movement_index):
	if scene_movements.has(scene_path) and movement_index < scene_movements[scene_path].size():
		scene_movements[scene_path][movement_index].completed = true
		return true
	return false

# Generate statistics report
func generate_statistics():
	var report = {
		"tasks": {
			"total": stats.total_tasks,
			"completed": stats.completed_tasks,
			"failed": stats.failed_tasks,
			"pending": tasks.size() - stats.completed_tasks - stats.failed_tasks,
			"avg_completion_time_ms": stats.avg_completion_time
		},
		"data_flows": {
			"total_flows": data_flows.size(),
			"active_flows": 0,
			"total_data_transferred": 0.0
		},
		"interactions": {
			"total": interaction_points.size(),
			"types": {}
		},
		"movements": {
			"total_scenes": scene_movements.size(),
			"total_movements": 0,
			"completed_movements": 0
		}
	}
	
	# Count active flows and total data
	for flow in data_flows.values():
		report.data_flows.total_data_transferred += flow.total_amount
		if Time.get_ticks_msec() - flow.last_update < 5000: # Consider flows active if updated in last 5 seconds
			report.data_flows.active_flows += 1
	
	# Count interaction types
	for interaction in interaction_points:
		if not report.interactions.types.has(interaction.type):
			report.interactions.types[interaction.type] = 0
		report.interactions.types[interaction.type] += 1
	
	# Count movements
	for scene_path in scene_movements:
		report.movements.total_movements += scene_movements[scene_path].size()
		for movement in scene_movements[scene_path]:
			if movement.completed:
				report.movements.completed_movements += 1
	
	return report

# Export data to JSON file
func export_data(file_path = "user://task_manager_data.json"):
	var data = {
		"tasks": tasks,
		"data_flows": data_flows,
		"interaction_points": interaction_points,
		"scene_movements": scene_movements,
		"stats": stats,
		"export_time": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()
		return true
	return false

# Create 3D visualization of all data paths
func create_3d_visualization(parent_node):
	if visualization_root != null:
		visualization_root.queue_free()
	
	visualization_root = Node3D.new()
	visualization_root.name = "DataFlowVisualization"
	FloodgateController.universal_add_child(visualization_root, parent_node)
	
	# Create lines for all data flows
	for flow_key in data_flows:
		_create_flow_line(flow_key)
	
	# Create points for all interactions
	for i in range(interaction_points.size()):
		_visualize_interaction(interaction_points[i])
	
	# Create movement paths
	for scene_path in scene_movements:
		for i in range(scene_movements[scene_path].size()):
			_visualize_movement(scene_path, scene_movements[scene_path][i])
	
	return visualization_root

# Private methods
func _find_task_index(task_id):
	for i in range(tasks.size()):
		if tasks[i].id == task_id:
			return i
	return -1

func prune_completed_tasks():
	var new_tasks = []
	for task in tasks:
		if task.status != TaskStatus.COMPLETED:
			new_tasks.append(task)
	tasks = new_tasks

func _update_flow_visualization(flow_key):
	if visualization_root == null:
		return
	
	# Find or create line for this flow
	var line_index = -1
	for i in range(flow_lines.size()):
		if flow_lines[i].name == "Flow_" + flow_key:
			line_index = i
			break
	
	if line_index == -1:
		_create_flow_line(flow_key)
	else:
		# Update existing line
		var _line = flow_lines[line_index]
		var _flow = data_flows[flow_key]
		
		# Update line thickness based on flow amount
		var _thickness = min(0.1 + (_flow.total_amount / 100.0), 2.0)
		# This would be implemented differently depending on how you're visualizing lines
		# For example, if using MeshInstance3D:
		# line.mesh.size.y = thickness
		# line.mesh.size.z = thickness

func _create_flow_line(flow_key):
	var flow = data_flows[flow_key]
	
	# This is a simplified visualization - in a real implementation,
	# you would need to get the actual 3D positions of the objects
	var source_node = get_node_or_null(flow.source)
	var target_node = get_node_or_null(flow.target)
	
	if source_node == null or target_node == null:
		return
	
	var source_pos = source_node.global_position
	var target_pos = target_node.global_position
	
	# Create a line (represented here as an ImmediateMesh for simplicity)
	# var line = ImmediateGeometry.new()
	# line.name = "Flow_" + flow_key
	# FloodgateController.universal_add_child(line, visualization_root)
	# 
	# # Draw line
	# line.clear()
	# line.begin(Mesh.PRIMITIVE_LINES)
	# line.add_vertex(source_pos)
	# line.add_vertex(target_pos)
	# line.end()
	# 
	# flow_lines.append(line)
	# 
	# return line
	
	# TODO: Implement proper line visualization
	return null

func _visualize_interaction(interaction):
	if visualization_root == null:
		return
	
	# Create a small sphere at the interaction point
	var sphere = MeshInstance3D.new()
	sphere.name = "Interaction_" + str(interaction.time)
	FloodgateController.universal_add_child(sphere, visualization_root)
	
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.2
	sphere.mesh = mesh
	
	# Set position
	sphere.global_position = interaction.position
	
	# Set color based on interaction type
	var material = MaterialLibrary.get_material("default")
	match interaction.type:
		"click": material.albedo_color = Color(1, 0, 0) # Red for clicks
		"drag": material.albedo_color = Color(0, 1, 0) # Green for drags
		"hover": material.albedo_color = Color(0, 0, 1) # Blue for hovers
		_: material.albedo_color = Color(1, 1, 1) # White for others
	
	sphere.material_override = material
	
	return sphere

func _visualize_movement(scene_path, movement):
	if visualization_root == null:
		return
	
	# Create a line for the movement path
	# var line = ImmediateGeometry.new()
	# line.name = "Movement_" + scene_path + "_" + str(movement.start_time)
	# FloodgateController.universal_add_child(line, visualization_root)
	# 
	# # Draw line
	# line.clear()
	# line.begin(Mesh.PRIMITIVE_LINE_STRIP)
	# line.add_vertex(movement.from)
	# 
	# # Add intermediate points for curved path
	# var curve_steps = 10
	# for i in range(1, curve_steps):
	# 	var t = float(i) / curve_steps
	# 	var mid_point = movement.from.lerp(movement.to, t)
	# 	# Add a slight arc to the path
	# 	mid_point.y += sin(PI * t) * (movement.from.distance_to(movement.to) * 0.1)
	# 	line.add_vertex(mid_point)
	# 
	# line.add_vertex(movement.to)
	# line.end()
	# 
	# # Set color based on completion status
	# var material = MaterialLibrary.get_material("default")
	# if movement.completed:
	# 	material.albedo_color = Color(0, 1, 0, 0.5) # Green for completed
	# else:
	# 	material.albedo_color = Color(1, 0.5, 0, 0.5) # Orange for in-progress
	# 
	# line.material_override = material
	# 
	# return line
	
	# TODO: Implement proper movement visualization
	return null

func new_task_appeared(task_id, function_called, data_send_to_function):
	
	array_for_tasks_mutex.lock()

	array_for_tasks.append(function_called)
	
	array_for_tasks_mutex.unlock()
	
	var info_if_new = check_if_that_task_was(str(function_called))
	
	if info_if_new == true:
	
		var new_function_found = singular_task.duplicate(true)
		if new_function_found is Dictionary:
			var new_id = str(task_id)
			var function_n = str(function_called)
			var data_n = str(data_send_to_function)
			new_function_found["task_id"] = new_id
			new_function_found["function"] = function_n
			new_function_found["data"] = data_n
			collect_tasks(str(function_called), new_function_found)

func collect_tasks(function_name, task_data):
	dictionary_of_functions_mutex.lock()
	dictionary_of_functions[function_name] = {}
	dictionary_of_functions[function_name]["first"] = task_data
	dictionary_of_functions_mutex.unlock()

func check_if_that_task_was(function_name):
	dictionary_of_functions_mutex.lock()
	if dictionary_of_functions.has(function_name):
		dictionary_of_functions_mutex.unlock()

		return false
	else:
		dictionary_of_functions_mutex.unlock()

		return true

func check_all_things():
	return true

func initialize_task_system():
	task_metadata.mutex.lock()
	# Initialize categories
	for category in TASK_CATEGORIES:
		task_metadata.categories[category] = {
			"tasks": [],
			"status": "pending",
			"priority": TASK_CATEGORIES[category].priority,
			"dependencies": TASK_CATEGORIES[category].dependencies.duplicate()
		}
	task_metadata.mutex.unlock()

func parse_code_structure(content: String) -> Dictionary:
	var structure = {
		"systems": {},
		"functions": [],
		"metadata": {}
	}
	var lines = content.split("\n")
	var current_system = ""
	var current_description = []
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("# JSH"):
			if current_system != "":
				structure.systems[current_system]["description"] = "\n".join(current_description)
			current_system = line.substr(2).strip_edges()
			structure.systems[current_system] = {
				"functions": [],
				"description": "",
				"metadata": {}
			}
			current_description = []
		elif line.begins_with("func"):
			var func_name = line.split("(")[0].substr(5).strip_edges()
			if current_system != "":
				structure.systems[current_system].functions.append(func_name)
			structure.functions.append({
				"name": func_name,
				"system": current_system,
				"line": line
			})
			
		# Collect description comments
		elif line.begins_with("##"):
			current_description.append(line.substr(2).strip_edges())
	
	return structure

# Create tasks from code structure
func create_tasks_from_structure(structure: Dictionary):
	task_metadata.mutex.lock()
	
	for system_name in structure.systems:
		var category = determine_category(system_name)
		var system_data = structure.systems[system_name]
		
		var task = {
			"id": generate_task_id(system_name),
			"name": system_name,
			"category": category,
			"description": system_data.description,
			"functions": system_data.functions,
			"status": "pending",
			"dependencies": [],
			"subtasks": []
		}
		
		# Create subtasks for functions
		for func_name in system_data.functions:
			var subtask = {
				"id": generate_task_id(func_name),
				"name": func_name,
				"parent": task.id,
				"status": "pending"
			}
			task.subtasks.append(subtask)
			task_metadata.tasks[subtask.id] = subtask
		
		task_metadata.tasks[task.id] = task
		if category in task_metadata.categories:
			task_metadata.categories[category].tasks.append(task.id)
	
	task_metadata.mutex.unlock()

# Generate unique task ID
func generate_task_id(base_name: String) -> String:
	var timestamp = Time.get_ticks_msec()
	return base_name.to_lower().replace(" ", "_") + "_" + str(timestamp)

# Determine category based on system name
func determine_category(system_name: String) -> String:
	if "initialization" in system_name.to_lower():
		return "INITIALIZATION"
	elif "system" in system_name.to_lower():
		return "CORE_SYSTEMS"
	elif "data" in system_name.to_lower() or "memor" in system_name.to_lower():
		return "DATA_MANAGEMENT"
	elif "scene" in system_name.to_lower() or "tree" in system_name.to_lower():
		return "SCENE_MANAGEMENT"
	return "CORE_SYSTEMS"

# Get task information
func get_task_info(task_id: String) -> Dictionary:
	task_metadata.mutex.lock()
	var task_info = task_metadata.tasks.get(task_id, {}).duplicate(true)
	task_metadata.mutex.unlock()
	return task_info


func update_task_status_now(task_id: String, new_status: String) -> bool:
	task_metadata.mutex.lock()
	var success = false
	
	if task_metadata.tasks.has(task_id):
		var task_data = task_metadata.tasks[task_id]
		var _old_status = task_data.status
		task_data.status = new_status
		
		# Track completion
		if new_status == "completed":
			var completion_time = Time.get_ticks_msec()
			
			# First time completion
			if !task_history.first_tasks.has(task_data.name):
				task_history.first_tasks[task_data.name] = {
					"time": completion_time,
					"task_id": task_id
				}
			
			# Latest completion
			task_history.latest_tasks[task_data.name] = {
				"time": completion_time,
				"task_id": task_id
			}
			
			# Count completions
			if !task_history.completion_counts.has(task_data.name):
				task_history.completion_counts[task_data.name] = 0
			task_history.completion_counts[task_data.name] += 1
		
		success = true
	
	task_metadata.mutex.unlock()
	return success

# Update task status
func update_task_status(task_id: String, new_status: String) -> bool:
	task_metadata.mutex.lock()
	var success = false
	
	if task_metadata.tasks.has(task_id):
		task_metadata.tasks[task_id].status = new_status
		success = true
		
		# Update category status if needed
		var category = task_metadata.tasks[task_id].category
		if category in task_metadata.categories:
			var all_complete = true
			for task in task_metadata.categories[category].tasks:
				if task_metadata.tasks[task].status != "completed":
					all_complete = false
					break
			if all_complete:
				task_metadata.categories[category].status = "completed"
	
	task_metadata.mutex.unlock()
	return success

# Get tasks by category
func get_category_tasks(category: String) -> Array:
	task_metadata.mutex.lock()
	var category_tasks = []
	
	if category in task_metadata.categories:
		for task_id in task_metadata.categories[category].tasks:
			category_tasks.append(task_metadata.tasks[task_id].duplicate(true))
	
	task_metadata.mutex.unlock()
	return category_tasks

# Generate task report
func generate_task_report() -> String:
	var report = "JSH Task Management Report\n"
	report += "==========================\n\n"
	
	task_metadata.mutex.lock()
	print(" task_metadata : " , task_metadata)
	for category in task_metadata.categories:
		report += category + ":\n"
		print(" report ", report, " and " , category)
		report += "-" * (category.length() + 1) + "\n" 
		
		var category_tasks = get_category_tasks(category)
		for task_item in category_tasks:
			report += "- " + task_item.name + " [" + task_item.status + "]\n"
			for subtask in task_item.subtasks:
				report += "  * " + subtask.name + " [" + subtask.status + "]\n"
		report += "\n"
	
	task_metadata.mutex.unlock()
	return report


func initialize_world_seed(master_seed : int):
	var rng = RandomNumberGenerator.new()
	rng.seed = master_seed
	generate_initial_containers(rng)

	
func store_container(container : SpatialContainer):
	var path = ROM_PATH + container.uuid + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(container.serialize()))
	stored_containers[container.uuid] = container

func save_container_states():
	for container in active_containers.values():
		container.rom_data = container.ram_data.duplicate(true)
		store_container(container)

func apply_scale_pattern(data, _pattern_seed):
	print(" apply scale pattern ", data)
# had some error
func load_from_rom(def):
	ram_data = rom_data.duplicate(true)
	
	var results = apply_scale_pattern(rng, def)
	if !results == null:
		var pattern = results
		#var pattern = rules.scale_pattern
		var history = check_history(def)
		if !history == null:
			var age = current_turn - history[0].turn
			var scale = check_scale(def)
			if !scale == null:
				scale = Vector3.ONE * (1 + age * pattern.scale_factor)

func check_scale(_data):
	print(" check scale of that thing")

func check_history(_data):
	print(" lets check history")

func generate_initial_rules(rng_number):
	print(" generate initial rules : ",rng_number)

func generate_initial_containers(world_rng):
	for i in 10:
		var pos = Vector3(
			world_rng.randf_range(-50, 50),
			0,
			world_rng.randf_range(-50, 50)
		)
		var container = SpatialContainer.new(world_rng.randi(), pos)
		container = check_rules_of_container(rules)#.rules = 
		generate_initial_rules(world_rng)
		store_container(container)

func check_rules_of_container(container_rules):
	print(" current container rules : " , container_rules)

func process_turn():
	current_turn += 1
	
	for phase in turn_phases:
		match phase:
			"LOAD":
				update_container_lod()
				load_required_containers()
				
			"PROCESS":
				process_commands()
				apply_procedural_rules()
				
			"COMMIT":
				save_container_states()
				
			"CLEANUP":
				unload_distant_containers()

func apply_procedural_rules():
	print(" apply procedural_rules ")
	
	
func unload_distant_containers():
	print("unload distant containers ")

func update_container_lod():
	var camera_pos = get_viewport().get_camera_3d().global_transform.origin
	
	for container in active_containers.values():
		var distance = container.position.distance_to(camera_pos)
		container.lod_level = calculate_lod(distance)
		
func calculate_lod(distance : float) -> int:
	for i in container_lod_settings.distances.size():
		if distance < container_lod_settings.distances[i]:
			return i
	return container_lod_settings.distances.size()

func load_required_containers():
	var load_area = container_lod_settings.load_radius
	var camera_pos = get_viewport().get_camera_3d().global_transform.origin
	
	for container in stored_containers.values():
		if container.position.distance_to(camera_pos) < load_area:
			if not active_containers.has(container.uuid):
				container.load_from_rom()
				active_containers[container.uuid] = container

func process_commands():
	while not command_queue.is_empty():
		var cmd = command_queue.pop_front()
		execute_command(cmd)

func execute_command(command):
	match command.type:
		"create":
			var new_container = SpatialContainer.new(
				command.seed,
				command.position
			)
			new_container.rules = inherit_rules(command.source)
			store_container(new_container)
			
		"modify":
			var container = active_containers[command.target]
			container.evolve(current_turn, command)
			
		"pattern":
			detect_repetition_patterns()
			
		"scale":
			apply_global_scale(command.factor)
			
func apply_global_scale(command):
	print("apply global scale ", command)

func inherit_rules(source_container):
	var new_rules = {}
	var rule_rng = RandomNumberGenerator.new()
	rule_rng.seed = source_container.container_seed + current_turn
	
	for rule in source_container.rules:
		if rule_rng.randf() < global_rules.inheritance.rule_mutation:
			new_rules[rule] = mutate_rule(
				source_container.rules[rule], 
				rule_rng
			)
		else:
			new_rules[rule] = source_container.rules[rule]
	
	return new_rules

func detect_repetition_patterns():
	for container in active_containers.values():
		if container.history.size() > global_rules.pattern_detection.history_depth:
			var sequence = container.history.slice(
				-global_rules.pattern_detection.history_depth
			)
			
			if check_pattern_repetition(sequence):
				apply_pattern_response(container)

func mutate_rule(data, _mutation_seed):
	print(" mutate rule ", data)
	
func check_pattern_repetition(data):
	print(" check pattern repetition ", data)

func apply_pattern_response(data):
	print(" apply pattern response " , data)

func store_container_old(container : SpatialContainer):
	var path = ROM_PATH + container.uuid + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(container.serialize()))
	stored_containers[container.uuid] = container

func save_container_states_old():
	for container in active_containers.values():
		container.rom_data = container.ram_data.duplicate(true)
		store_container(container)







###
#func _ready():
#	initialize_task_system()
###


## Usage Example
## wait, i have only one ready, and main function with delta process and input, its main.gd, we would need to make new task, and here we have task manager

#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#command_queue.append({
			#"type": "create",
			#"position": calculate_spawn_position(),
			#"seed": randi()
		#})
		#
	#if event.is_action_pressed("ui_cancel"):
		#command_queue.append({
			#"type": "pattern",
			#"action": "analyze"
		#})
#
#func _process(delta):
	#if Input.is_key_pressed(KEY_ENTER):
		#process_turn()	
	#print(" task dilema : " , task_id, function_called, data_send_to_function)	#	else:
	#		print(" we didnt get dictionary ")
#	else:
#		print(" the info was not new ")		#print(" it was there before ")		#print(" it is new function ")	#print(" JSH_task_manager check connection " , array_for_tasks , " and also dictionary : " , dictionary_of_functions)

# Core System Architecture
#class_name SpatialEvolutionSystem
#extends UniversalBeingBase
# we had one already
#func _ready():
	#initialize_world_seed(OS.get_unix_time())
	#initialize_task_system()
	

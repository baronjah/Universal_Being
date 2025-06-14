# ==================================================
# SCRIPT NAME: jsh_adapter.gd
# DESCRIPTION: Adapts JSH framework to work with ragdoll game
# PURPOSE: Bridge between complex JSH systems and simple ragdoll needs
# CREATED: 2025-05-25 - Making JSH work in new context
# ==================================================

extends UniversalBeingBase
## Initialize JSH systems with safe defaults
# INPUT: None
# PROCESS: Sets up JSH components to work without original dependencies
# OUTPUT: None
# CHANGES: JSH system states
# CONNECTION: Called on project start

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func initialize_jsh_for_ragdoll() -> void:
	print("[JSH Adapter] Initializing JSH framework for ragdoll game...")
	
	# Get the scene tree to access autoloads
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		print("[JSH Adapter] Error: No scene tree available")
		return
	
	# Ensure JSH systems don't crash on missing dependencies
	var console = tree.root.get_node_or_null("JSHConsole")
	if console and console.has_method("setup_terminal_variables"):
		console.setup_terminal_variables()
		print("[JSH Adapter] Console initialized")
	
	var scene_tree_sys = tree.root.get_node_or_null("JSHSceneTree")
	if scene_tree_sys:
		print("[JSH Adapter] Scene tree system found")
	
	var thread_pool = tree.root.get_node_or_null("JSHThreadPool")
	if thread_pool:
		print("[JSH Adapter] Thread pool found")
	
	print("[JSH Adapter] Initialization complete")

## Create simplified container system
# INPUT: Container name
# PROCESS: Creates a basic container node
# OUTPUT: Container node
# CHANGES: Scene tree
# CONNECTION: Replaces complex JSH container system
static func create_simple_container(container_name: String) -> Node3D:
	var container = Node3D.new()
	container.name = container_name
	container.add_to_group("jsh_containers")
	
	# Add basic metadata
	container.set_meta("container_type", "simple")
	container.set_meta("created_time", Time.get_ticks_msec())
	
	return container

## Create simplified datapoint
# INPUT: Data to store
# PROCESS: Creates a basic data storage node
# OUTPUT: Datapoint node
# CHANGES: None (returns node)
# CONNECTION: Replaces complex JSH datapoint system
static func create_simple_datapoint(data: Dictionary) -> Node:
	var datapoint = Node.new()
	datapoint.name = "DataPoint"
	datapoint.add_to_group("jsh_datapoints")
	
	# Store data as metadata
	for key in data:
		datapoint.set_meta(key, data[key])
	
	return datapoint

## Get scene tree summary
# INPUT: Root node (optional)
# PROCESS: Creates simple tree summary
# OUTPUT: Tree structure as string
# CHANGES: None
# CONNECTION: Simplifies JSH scene tree system
static func get_scene_tree_summary(root: Node = null) -> String:
	if not root:
		root = Engine.get_main_loop().current_scene
	
	var summary = "Scene Tree Summary:\n"
	summary += _build_tree_string(root, 0)
	return summary

static func _build_tree_string(node: Node, depth: int) -> String:
	var indent = "  ".repeat(depth)
	var line = "%s- %s" % [indent, node.name]
	
	if node is Node3D:
		line += " [3D]"
	elif node is Node2D:
		line += " [2D]"
	elif node is Control:
		line += " [UI]"
	
	line += "\n"
	
	# Add children (limit depth to prevent huge outputs)
	if depth < 5:
		for child in node.get_children():
			line += _build_tree_string(child, depth + 1)
	
	return line
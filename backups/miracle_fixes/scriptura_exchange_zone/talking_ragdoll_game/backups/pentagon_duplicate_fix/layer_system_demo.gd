# 🏛️ Layer System Demo - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Layer System Demo - Shows how entities exist across multiple reality layers

@onready var layer_system = get_node("/root/LayerRealitySystem")

# Demo entities
var demo_ragdoll: Node3D
var demo_tree: Node3D
var demo_path_points: Array = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("Starting Layer System Demo...")
	
	# Create demo entities with multi-layer support
	_create_demo_ragdoll()
	_create_demo_environment()
	_setup_demo_path()
	
	# Show instructions
	_print_instructions()

func _create_demo_ragdoll() -> void:
	# Create a ragdoll that exists in all layers
	demo_ragdoll = Node3D.new()
	demo_ragdoll.name = "DemoRagdoll"
	demo_ragdoll.set_script(load("res://scripts/components/multi_layer_entity.gd"))
	demo_ragdoll.entity_id = "player_ragdoll"
	demo_ragdoll.entity_type = "ragdoll"
	add_child(demo_ragdoll)
	
	# Add visual representation for Layer 3 (full 3D)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = CapsuleMesh.new()
	mesh_instance.mesh.height = 1.8
	mesh_instance.mesh.radius = 0.3
	FloodgateController.universal_add_child(mesh_instance, demo_ragdoll)
	
	# Set initial position
	demo_ragdoll.position = Vector3(0, 1, 0)

func _create_demo_environment() -> void:
	# Create a tree
	demo_tree = Node3D.new()
	demo_tree.name = "DemoTree"
	demo_tree.set_script(load("res://scripts/components/multi_layer_entity.gd"))
	demo_tree.entity_id = "oak_tree_01"
	demo_tree.entity_type = "tree"
	demo_tree.position = Vector3(5, 0, -3)
	add_child(demo_tree)
	
	# Tree visual
	var tree_mesh = MeshInstance3D.new()
	tree_mesh.mesh = CylinderMesh.new()
	tree_mesh.mesh.height = 4.0
	tree_mesh.mesh.top_radius = 0.1
	tree_mesh.mesh.bottom_radius = 0.5
	FloodgateController.universal_add_child(tree_mesh, demo_tree)

func _setup_demo_path() -> void:
	# Create a path for the ragdoll to follow
	demo_path_points = [
		Vector3(0, 1, 0),
		Vector3(5, 1, 0),
		Vector3(5, 1, -5),
		Vector3(0, 1, -5),
		Vector3(-5, 1, -5),
		Vector3(-5, 1, 0),
		Vector3(0, 1, 0)
	]
	
	# Add path to debug layer
	if layer_system:
		for i in range(demo_path_points.size() - 1):
			layer_system.add_debug_line(
				demo_path_points[i],
				demo_path_points[i + 1],
				Color(0.5, 0.5, 1.0, 0.5)
			)

func _print_instructions() -> void:
	var instructions = """
[color=#00ffff]=== Layer System Demo ===[/color]

[b]Keyboard Controls:[/b]
  F1 - Toggle Text/Console Layer
  F2 - Toggle 2D Map Layer
  F3 - Toggle Debug 3D Layer
  F4 - Toggle Full 3D Layer
  F5 - Cycle View Modes
  F6 - Split Screen (when 2+ layers active)
  F7 - Align layers to camera
  F8 - Reset layers to origin

[b]Console Commands:[/b]
  layer [show|hide|toggle] [text|map|debug|full]
  layers - Show all layer states
  reality - Cycle view modes
  debug_point [x] [y] [z] [color]
  debug_line [x1] [y1] [z1] [x2] [y2] [z2] [color]
  debug_clear - Clear debug drawings

[b]Current Demo:[/b]
  - Ragdoll entity moving along path
  - Tree at position (5, 0, -3)
  - Debug path visualization
  - All entities exist in multiple layers
"""
	
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		console._print_to_console(instructions)
	else:
		print(instructions)

var path_index: int = 0
var move_speed: float = 2.0


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if not demo_ragdoll:
		return
	
	# Move ragdoll along path
	var target = demo_path_points[path_index]
	var direction = (target - demo_ragdoll.position).normalized()
	
	if demo_ragdoll.position.distance_to(target) < 0.5:
		path_index = (path_index + 1) % demo_path_points.size()
		
		# Update state when reaching waypoint
		if demo_ragdoll.has_method("set_text_state"):
			demo_ragdoll.set_text_state("turning")
	else:
		demo_ragdoll.position += direction * move_speed * delta
		
		# Update state while moving
		if demo_ragdoll.has_method("set_text_state"):
			demo_ragdoll.set_text_state("walking")
	
	# Add debug visualization at ragdoll position
	if layer_system and layer_system.is_layer_visible(layer_system.Layer.DEBUG_3D):
		# Show velocity vector
		layer_system.add_debug_line(
			demo_ragdoll.position,
			demo_ragdoll.position + direction * 1.5,
			Color.GREEN
		)
		
		# Show next target
		layer_system.add_debug_line(
			demo_ragdoll.position,
			target,
			Color(1, 1, 0, 0.3)
		)

# Allow console control of demo

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
func handle_console_command(command: String, args: Array) -> String:
	match command:
		"demo_speed":
			if args.size() > 0:
				move_speed = float(args[0])
				return "Demo speed set to " + str(move_speed)
		"demo_teleport":
			if args.size() >= 3:
				demo_ragdoll.position = Vector3(
					float(args[0]),
					float(args[1]),
					float(args[2])
				)
				return "Ragdoll teleported to " + str(demo_ragdoll.position)
		"demo_reset":
			path_index = 0
			demo_ragdoll.position = demo_path_points[0]
			return "Demo reset"
	
	return "Unknown demo command"
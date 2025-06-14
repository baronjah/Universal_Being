# ==================================================
# SYSTEM: Game World Controller
# PURPOSE: Manage the game world with proper layering and Universal Being creation
# FEATURES: Layer management, being spawning, world initialization
# CREATED: 2025-06-04
# ==================================================

extends Node
class_name GameWorldController

# ===== LAYER MANAGEMENT =====
# Layer hierarchy (from docs):
# 110: Modal dialogs
# 105: Cursor (ALWAYS on top)
# 100: Inspector popup
# 95:  Console window
# 50:  Game UI elements
# 0:   3D world (background)

# World references
var world_3d: Node3D
var ui_layer: CanvasLayer
var cursor_being: Node
var console_being: Node
var player_being: Node

# Essential beings
var ground_being: Node
var sun_being: Node
var camera_controller: Camera3D

func _ready() -> void:
	name = "GameWorldController"
	print("🌌 Game World Controller: Initializing layered reality...")
	
	# Create the layered structure
	_create_world_layers()
	
	# Initialize the 3D world
	_create_game_world()
	
	# Set up UI layer
	_create_ui_layer()
	
	# Ensure cursor is always on top
	_ensure_cursor_on_top()
	
	print("🌌 Game World Controller: Reality manifested!")

func _create_world_layers() -> void:
	"""Create the proper layer structure"""
	# 3D World container (layer 0)
	world_3d = Node3D.new()
	world_3d.name = "World3D"
	add_child(world_3d)
	
	# UI Layer for 2D elements (layer 50+)
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 50
	add_child(ui_layer)

func _create_game_world() -> void:
	"""Create the 3D game world where everything is a Universal Being"""
	
	# Create environment
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.4, 0.6)
	env.ambient_light_energy = 0.3
	env.fog_enabled = true
	env.fog_light_color = Color(0.4, 0.5, 0.7)
	env.fog_density = 0.01
	world_env.environment = env
	world_3d.add_child(world_env)
	
	# Create ground (Universal Being)
	var GroundBeingClass = load("res://beings/ground_universal_being.gd")
	var ground_node = Node3D.new()
	ground_node.set_script(GroundBeingClass)
	ground_node.name = "GroundBeing"
	ground_node.position = Vector3(0, -0.5, 0)
	world_3d.add_child(ground_node)
	ground_being = ground_node
	
	# Create sun light (Universal Being)
	var LightBeingClass = load("res://beings/light_universal_being.gd")
	var sun_node = Node3D.new()
	sun_node.set_script(LightBeingClass)
	sun_node.name = "SunBeing"
	sun_node.position = Vector3(0, 10, 0)
	sun_node.set("light_type", "directional")
	sun_node.set("light_color", Color(1.0, 0.95, 0.8))
	world_3d.add_child(sun_node)
	sun_being = sun_node
	
	# Create player (Universal Being)
	var PlayerBeingClass = load("res://beings/player_universal_being.gd")
	var player_node = Node3D.new()
	player_node.set_script(PlayerBeingClass)
	player_node.name = "PlayerBeing"
	player_node.position = Vector3(0, 2, 0)
	world_3d.add_child(player_node)
	player_being = player_node
	
	# Create camera that follows player
	camera_controller = Camera3D.new()
	camera_controller.name = "MainCamera"
	camera_controller.position = Vector3(0, 5, 10)
	camera_controller.fov = 60
	world_3d.add_child(camera_controller)
	
	# Set camera orientation after adding to tree
	camera_controller.look_at(Vector3.ZERO, Vector3.UP)
	
	# Create some interactive beings
	_spawn_interactive_beings()

func _create_ui_layer() -> void:
	"""Create UI elements with proper layering"""
	
	# Create console (layer 95)
	var ConsoleClass = load("res://beings/perfect_universal_console.gd")
	var console_node = Node3D.new()
	console_node.set_script(ConsoleClass)
	console_node.name = "PerfectConsole"
	console_node.add_to_group("console")
	ui_layer.add_child(console_node)
	console_being = console_node
	
	# Cursor will be created by _ensure_cursor_on_top

func _ensure_cursor_on_top() -> void:
	"""Make sure cursor is ALWAYS on top (layer 105)"""
	# Look for existing cursor
	var cursor_nodes = get_tree().get_nodes_in_group("cursor")
	if cursor_nodes.size() > 0:
		cursor_being = cursor_nodes.front() as UniversalBeing
	else:
		cursor_being = null
	
	if not cursor_being:
		# Create cursor if it doesn't exist
		var CursorClass = load("res://beings/cursor/CursorUniversalBeing.gd")
		var cursor_node = Node3D.new()
		cursor_node.set_script(CursorClass)
		cursor_node.name = "CursorBeing"
		cursor_being = cursor_node
	
	# Ensure cursor is in UI layer with highest z_index
	if cursor_being.get_parent() != ui_layer:
		if cursor_being.get_parent():
			cursor_being.get_parent().remove_child(cursor_being)
		ui_layer.add_child(cursor_being)
	
	# Cursor is Node3D, so we use layer management differently
	if cursor_being.has_method("set_layer"):
		cursor_being.set_layer(105)
	elif cursor_being.has_method("set"):
		cursor_being.set("visual_layer", 105)
	
	print("🖱️ Cursor ensured at layer 105 (always on top)")

func _spawn_interactive_beings() -> void:
	"""Spawn some beings to interact with"""
	
	# Crystal Being
	_create_crystal_being(Vector3(5, 1, 0))
	
	# Tree Being  
	_create_tree_being(Vector3(-5, 0, -3))
	
	# Floating Orb Being
	_create_orb_being(Vector3(0, 3, -5))
	
	# Portal Being
	_create_portal_being(Vector3(8, 1, 8))

func _create_crystal_being(pos: Vector3) -> void:
	"""Create a crystal Universal Being"""
	var crystal = RigidBody3D.new()
	crystal.set_script(load("res://core/UniversalBeing.gd"))
	crystal.name = "CrystalBeing"
	crystal.position = pos
	
	# After script is set, configure being properties
	crystal.set("being_type", "crystal")
	crystal.set("being_name", "Resonating Crystal")
	crystal.set("consciousness_level", 2)
	
	# Add visual
	var mesh = MeshInstance3D.new()
	var crystal_mesh = BoxMesh.new()
	crystal_mesh.size = Vector3(1, 2, 1)
	mesh.mesh = crystal_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.8, 1.0)
	mat.metallic = 0.8
	mat.roughness = 0.2
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.6, 0.9)
	mat.emission_energy = 0.5
	mesh.material_override = mat
	crystal.add_child(mesh)
	
	# Add collision
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.size = Vector3(1, 2, 1)
	crystal.add_child(collision)
	
	# Add to world
	world_3d.add_child(crystal)

func _create_tree_being(pos: Vector3) -> void:
	"""Create a tree Universal Being"""
	var tree = StaticBody3D.new()
	tree.set_script(load("res://beings/tree_universal_being.gd"))
	tree.name = "TreeBeing"
	tree.position = pos
	world_3d.add_child(tree)

func _create_orb_being(pos: Vector3) -> void:
	"""Create a floating orb being"""
	var orb = Area3D.new()
	orb.set_script(load("res://core/UniversalBeing.gd"))
	orb.name = "OrbBeing"
	orb.position = pos
	
	orb.set("being_type", "orb")
	orb.set("being_name", "Floating Consciousness")
	orb.set("consciousness_level", 3)
	
	# Visual
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 0.5
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.3)
	mat.emission_energy = 2.0
	mesh.material_override = mat
	orb.add_child(mesh)
	
	# Collision
	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = 0.5
	orb.add_child(collision)
	
	# Float animation
	var tween = orb.create_tween()
	tween.set_loops()
	tween.tween_property(orb, "position:y", pos.y + 1, 2.0)
	tween.tween_property(orb, "position:y", pos.y, 2.0)
	
	world_3d.add_child(orb)

func _create_portal_being(pos: Vector3) -> void:
	"""Create a portal being"""
	var portal = Node3D.new()
	portal.set_script(load("res://beings/PortalUniversalBeing.gd"))
	portal.name = "PortalBeing"
	portal.position = pos
	world_3d.add_child(portal)

# ===== GAME API =====

func spawn_being_at_cursor(being_type: String) -> UniversalBeing:
	"""Spawn a being where the cursor is pointing in 3D space"""
	if not cursor_being:
		push_error("No cursor being found!")
		return null
	
	# Get cursor's 3D position if it has one
	var spawn_pos = Vector3(0, 1, 0)  # Default
	if cursor_being.has_method("get_world_position_3d"):
		spawn_pos = cursor_being.get_world_position_3d()
	
	# Create being based on type
	var new_being: UniversalBeing
	match being_type:
		"crystal":
			_create_crystal_being(spawn_pos)
		"tree":
			_create_tree_being(spawn_pos)
		"orb":
			_create_orb_being(spawn_pos)
		"portal":
			_create_portal_being(spawn_pos)
		_:
			# Generic being
			new_being = Node3D.new()
			new_being.set_script(load("res://core/UniversalBeing.gd"))
			new_being.position = spawn_pos
			world_3d.add_child(new_being)
	
	return new_being

func get_being_at_cursor() -> UniversalBeing:
	"""Get the Universal Being under the cursor"""
	if not cursor_being or not cursor_being.has_method("get_hovered_being"):
		return null
	
	return cursor_being.get_hovered_being()

func set_time_scale(scale: float) -> void:
	"""Control time flow in the game world"""
	Engine.time_scale = scale
	print("🌌 Time scale set to: %.1fx" % scale)

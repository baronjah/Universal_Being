extends Node3D
class_name PeacefulCreationSpace

# 🌱 PEACEFUL CREATION SPACE 🌱
# 3D programming with local AI, creating seeds, trees, water
# Pure creative programming environment

signal seed_planted(position: Vector3)
signal tree_grown(tree_id: String)
signal water_created(water_body: Node3D)
signal ai_suggestion_made(suggestion: String)

# CREATION SETTINGS
@export var flight_speed: float = 8.0
@export var creation_mode: bool = true
@export var ai_assistance: bool = true

# 3D PROGRAMMING ENVIRONMENT
var flight_camera: Camera3D
var creation_workspace: Node3D
var local_ai_companion: LocalAICompanion
var programming_ui: Control

# CREATED ELEMENTS
var seeds: Array[Seed3D] = []
var trees: Array[Tree3D] = []
var water_bodies: Array[Water3D] = []
var code_blocks: Array[CodeBlock3D] = []

class Seed3D:
	var seed_id: String
	var position: Vector3
	var growth_stage: float = 0.0
	var visual_node: Node3D
	var can_grow: bool = true
	
	func _init(id: String, pos: Vector3):
		seed_id = id
		position = pos

class Tree3D:
	var tree_id: String
	var position: Vector3
	var growth_level: float = 1.0
	var visual_node: Node3D
	var produces_fruit: bool = true
	
	func _init(id: String, pos: Vector3):
		tree_id = id
		position = pos

class Water3D:
	var water_id: String
	var center_position: Vector3
	var size: float
	var visual_node: Node3D
	var flowing: bool = false
	
	func _init(id: String, pos: Vector3, water_size: float):
		water_id = id
		center_position = pos
		size = water_size

class CodeBlock3D:
	var code_id: String
	var code_content: String
	var position: Vector3
	var visual_node: Node3D
	var language: String = "gdscript"
	
	func _init(id: String, code: String, pos: Vector3):
		code_id = id
		code_content = code
		position = pos

class LocalAICompanion:
	var ai_name: String
	var personality: String
	var knowledge_areas: Array[String]
	var visual_orb: Node3D
	var current_suggestion: String = ""
	
	func _init(name: String):
		ai_name = name
		personality = "helpful_creator"
		knowledge_areas = ["gardening", "programming", "nature", "water_systems"]
	
	func suggest_creation() -> String:
		var suggestions = [
			"Try planting a seed near the water for faster growth",
			"Create a small pond to reflect the stars",
			"Plant multiple seeds in a circle for a garden",
			"Add some flowing water between your trees",
			"Create code that automatically waters your seeds",
			"Try making a fruit tree that creates consciousness"
		]
		current_suggestion = suggestions[randi() % suggestions.size()]
		return current_suggestion
	
	func comment_on_creation(creation_type: String) -> String:
		match creation_type:
			"seed":
				return "Beautiful seed placement! It will grow well there."
			"tree":
				return "Wonderful tree! It brings life to the space."
			"water":
				return "Perfect water creation! Life will flourish here."
			"code":
				return "Excellent code structure! Very clean and peaceful."
			_:
				return "Your creation brings harmony to this space."

func _ready():
	name = "PeacefulCreationSpace"
	print("🌱 PEACEFUL CREATION SPACE INITIALIZING...")
	
	# Setup peaceful environment
	setup_peaceful_environment()
	
	# Create flight system
	setup_peaceful_flight()
	
	# Initialize local AI companion
	setup_local_ai_companion()
	
	# Create programming interface
	setup_creation_interface()
	
	# Setup workspace
	setup_creation_workspace()
	
	print("✨ PEACEFUL CREATION SPACE READY!")
	print("🌱 S: Plant Seed | T: Grow Tree | W: Create Water")
	print("🤖 AI companion ready to help with suggestions")

func setup_peaceful_environment():
	"""Setup calm, peaceful environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Soft, peaceful sky
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	environment.sky.sky_material.sky_top_color = Color(0.6, 0.8, 1.0)
	environment.sky.sky_material.sky_horizon_color = Color(0.8, 0.9, 1.0)
	environment.sky.sky_material.ground_bottom_color = Color(0.3, 0.5, 0.3)
	environment.sky.sky_material.ground_horizon_color = Color(0.5, 0.7, 0.4)
	
	# Gentle ambient lighting
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.8, 0.9, 1.0)
	environment.ambient_light_energy = 0.4
	
	world_env.environment = environment
	add_child(world_env)
	
	# Add gentle sunlight
	var sun = DirectionalLight3D.new()
	sun.position = Vector3(0, 10, 0)
	sun.rotation_degrees = Vector3(-45, 45, 0)
	sun.light_energy = 0.8
	sun.light_color = Color(1.0, 0.95, 0.8)
	add_child(sun)

func setup_peaceful_flight():
	"""Setup gentle flight camera"""
	flight_camera = Camera3D.new()
	flight_camera.name = "PeacefulCamera"
	flight_camera.position = Vector3(0, 5, 10)
	add_child(flight_camera)
	
	get_viewport().set_camera_3d(flight_camera)
	print("📷 Peaceful flight camera ready")

func setup_local_ai_companion():
	"""Setup local AI companion"""
	local_ai_companion = LocalAICompanion.new("Sage")
	
	# Create visual representation
	var ai_orb = Node3D.new()
	ai_orb.name = "AICompanion"
	ai_orb.position = Vector3(3, 2, 0)
	
	var orb_mesh = MeshInstance3D.new()
	orb_mesh.mesh = SphereMesh.new()
	orb_mesh.mesh.radius = 0.3
	
	var orb_material = StandardMaterial3D.new()
	orb_material.albedo_color = Color(0.5, 0.8, 1.0, 0.8)
	orb_material.emission_enabled = true
	orb_material.emission = Color(0.3, 0.6, 0.9)
	orb_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	orb_mesh.material_override = orb_material
	
	ai_orb.add_child(orb_mesh)
	local_ai_companion.visual_orb = ai_orb
	add_child(ai_orb)
	
	print("🤖 Local AI companion 'Sage' ready to help")

func setup_creation_interface():
	"""Setup peaceful creation interface"""
	programming_ui = Control.new()
	programming_ui.name = "CreationUI"
	programming_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = """🌱 PEACEFUL CREATION SPACE 🌱
WASD: Gentle flight | Mouse: Look around
S: Plant seed | T: Grow tree | W: Create water
C: Write code | E: Execute code | A: AI suggestion
Tab: Toggle UI | Space: Fly up gently"""
	instructions.position = Vector2(20, 20)
	instructions.add_theme_color_override("font_color", Color(0.2, 0.5, 0.2))
	programming_ui.add_child(instructions)
	
	# Code input area
	var code_input = TextEdit.new()
	code_input.name = "CodeInput"
	code_input.placeholder_text = "Write peaceful creation code here..."
	code_input.size = Vector2(400, 200)
	code_input.position = Vector2(20, 120)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.95, 0.9, 0.8)
	style.border_color = Color(0.3, 0.6, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	code_input.add_theme_stylebox_override("normal", style)
	code_input.add_theme_color_override("font_color", Color(0.2, 0.4, 0.2))
	
	programming_ui.add_child(code_input)
	
	# AI suggestion display
	var ai_suggestion_label = Label.new()
	ai_suggestion_label.name = "AISuggestion"
	ai_suggestion_label.text = "🤖 AI Sage: Ready to help with creation!"
	ai_suggestion_label.position = Vector2(20, 340)
	ai_suggestion_label.add_theme_color_override("font_color", Color(0.2, 0.4, 0.6))
	programming_ui.add_child(ai_suggestion_label)
	
	add_child(programming_ui)

func setup_creation_workspace():
	"""Setup 3D creation workspace"""
	creation_workspace = Node3D.new()
	creation_workspace.name = "CreationWorkspace"
	add_child(creation_workspace)
	
	# Create ground plane
	var ground = MeshInstance3D.new()
	ground.mesh = PlaneMesh.new()
	ground.mesh.size = Vector2(50, 50)
	
	var ground_material = StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.4, 0.6, 0.3)
	ground.material_override = ground_material
	
	creation_workspace.add_child(ground)

func _physics_process(delta):
	_handle_gentle_flight(delta)
	_animate_ai_companion(delta)
	_update_growing_elements(delta)

func _handle_gentle_flight(delta):
	"""Handle gentle, peaceful flight"""
	var movement = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movement.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement.z += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_accept"):  # Space - gentle up
		movement.y += 1
	if Input.is_action_pressed("ui_select"):  # Shift - gentle down
		movement.y -= 1
	
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = flight_camera.global_transform.basis
		flight_camera.global_position += camera_basis * movement * flight_speed * delta

func _animate_ai_companion(delta):
	"""Gentle AI companion animation"""
	if local_ai_companion and local_ai_companion.visual_orb:
		var orb = local_ai_companion.visual_orb
		orb.rotation_degrees.y += 20 * delta
		orb.position.y += sin(Time.get_ticks_msec() * 0.002) * 0.3 * delta

func _update_growing_elements(delta):
	"""Update growing seeds and trees"""
	for seed in seeds:
		if seed.can_grow and seed.growth_stage < 1.0:
			seed.growth_stage += 0.1 * delta
			if seed.growth_stage >= 1.0:
				_convert_seed_to_tree(seed)

func _convert_seed_to_tree(seed: Seed3D):
	"""Convert grown seed into tree"""
	var tree = Tree3D.new("tree_from_" + seed.seed_id, seed.position)
	_create_tree_visual(tree)
	trees.append(tree)
	
	print("🌳 Seed grew into a beautiful tree!")
	tree_grown.emit(tree.tree_id)
	
	# Remove seed
	if seed.visual_node:
		seed.visual_node.queue_free()
	seeds.erase(seed)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity = 0.001  # Very gentle mouse look
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		var rot = flight_camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		flight_camera.rotation_degrees = rot
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_S:
				_plant_seed()
			KEY_T:
				_grow_tree()
			KEY_W:
				_create_water()
			KEY_C:
				_write_code()
			KEY_E:
				_execute_code()
			KEY_A:
				_get_ai_suggestion()
			KEY_TAB:
				_toggle_ui()
			KEY_ESCAPE:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _plant_seed():
	"""Plant a seed at camera position"""
	var pos = flight_camera.global_position + flight_camera.global_transform.basis.z * -3
	pos.y = 0.1  # Ground level
	
	var seed = Seed3D.new("seed_" + str(seeds.size()), pos)
	_create_seed_visual(seed)
	seeds.append(seed)
	
	print("🌱 Planted seed at:", pos)
	seed_planted.emit(pos)
	
	# AI comment
	var comment = local_ai_companion.comment_on_creation("seed")
	_show_ai_message(comment)

func _create_seed_visual(seed: Seed3D):
	"""Create visual for seed"""
	var seed_node = Node3D.new()
	seed_node.name = seed.seed_id
	seed_node.position = seed.position
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radius = 0.1
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.3, 0.1)
	mesh_instance.material_override = material
	
	seed_node.add_child(mesh_instance)
	seed.visual_node = seed_node
	creation_workspace.add_child(seed_node)

func _grow_tree():
	"""Grow a tree at camera position"""
	var pos = flight_camera.global_position + flight_camera.global_transform.basis.z * -5
	pos.y = 0
	
	var tree = Tree3D.new("tree_" + str(trees.size()), pos)
	_create_tree_visual(tree)
	trees.append(tree)
	
	print("🌳 Grew tree at:", pos)
	tree_grown.emit(tree.tree_id)
	
	var comment = local_ai_companion.comment_on_creation("tree")
	_show_ai_message(comment)

func _create_tree_visual(tree: Tree3D):
	"""Create visual for tree"""
	var tree_node = Node3D.new()
	tree_node.name = tree.tree_id
	tree_node.position = tree.position
	
	# Trunk
	var trunk = MeshInstance3D.new()
	trunk.mesh = CylinderMesh.new()
	trunk.mesh.height = 3.0
	trunk.mesh.top_radius = 0.2
	trunk.mesh.bottom_radius = 0.3
	
	var trunk_material = StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.4, 0.2, 0.1)
	trunk.material_override = trunk_material
	
	tree_node.add_child(trunk)
	
	# Leaves
	var leaves = MeshInstance3D.new()
	leaves.mesh = SphereMesh.new()
	leaves.mesh.radius = 2.0
	leaves.position = Vector3(0, 2, 0)
	
	var leaf_material = StandardMaterial3D.new()
	leaf_material.albedo_color = Color(0.2, 0.6, 0.2)
	leaves.material_override = leaf_material
	
	tree_node.add_child(leaves)
	
	tree.visual_node = tree_node
	creation_workspace.add_child(tree_node)

func _create_water():
	"""Create water body"""
	var pos = flight_camera.global_position + flight_camera.global_transform.basis.z * -4
	pos.y = 0
	
	var water = Water3D.new("water_" + str(water_bodies.size()), pos, 3.0)
	_create_water_visual(water)
	water_bodies.append(water)
	
	print("💧 Created water at:", pos)
	water_created.emit(water.visual_node)
	
	var comment = local_ai_companion.comment_on_creation("water")
	_show_ai_message(comment)

func _create_water_visual(water: Water3D):
	"""Create visual for water"""
	var water_node = Node3D.new()
	water_node.name = water.water_id
	water_node.position = water.center_position
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = CylinderMesh.new()
	mesh_instance.mesh.height = 0.2
	mesh_instance.mesh.top_radius = water.size
	mesh_instance.mesh.bottom_radius = water.size
	
	var water_material = StandardMaterial3D.new()
	water_material.albedo_color = Color(0.3, 0.6, 1.0, 0.7)
	water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = water_material
	
	water_node.add_child(mesh_instance)
	water.visual_node = water_node
	creation_workspace.add_child(water_node)

func _write_code():
	"""Focus on code writing"""
	var code_input = programming_ui.get_node("CodeInput")
	code_input.grab_focus()
	print("💻 Code editor focused - write your creation code!")

func _execute_code():
	"""Execute written code"""
	var code_input = programming_ui.get_node("CodeInput")
	var code = code_input.text
	
	if code.length() > 0:
		print("🚀 Executing code:", code)
		var comment = local_ai_companion.comment_on_creation("code")
		_show_ai_message(comment)

func _get_ai_suggestion():
	"""Get AI suggestion"""
	var suggestion = local_ai_companion.suggest_creation()
	_show_ai_message("🤖 AI Sage suggests: " + suggestion)
	ai_suggestion_made.emit(suggestion)

func _show_ai_message(message: String):
	"""Show AI message in UI"""
	var ai_label = programming_ui.get_node("AISuggestion")
	ai_label.text = message
	print(message)

func _toggle_ui():
	"""Toggle UI visibility"""
	programming_ui.visible = !programming_ui.visible

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
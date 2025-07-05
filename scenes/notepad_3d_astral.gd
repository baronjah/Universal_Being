extends Node3D
class_name Notepad3DAstral

# 🌌 NOTEPAD 3D ASTRAL 🌌
# 3D programming space with floating code and astral flight
# Pure programming environment in beautiful space

signal code_created(code_block: String)
signal function_manifested(function_name: String)

# NOTEPAD 3D SETTINGS
@export var flight_speed: float = 10.0
@export var text_creation_enabled: bool = true
@export var code_blocks_visible: bool = true

# 3D PROGRAMMING SPACE
var flight_camera: Camera3D
var floating_code_blocks: Array[CodeBlock3D] = []
var programming_interface: Control
var current_code: String = ""

# ASTRAL SPACE ENVIRONMENT
var star_field: Node3D
var code_workspace: Node3D

class CodeBlock3D:
	var block_id: String
	var code_content: String
	var position: Vector3
	var visual_node: Node3D
	var language: String = "gdscript"
	
	func _init(id: String, code: String, pos: Vector3):
		block_id = id
		code_content = code
		position = pos

func _ready():
	name = "Notepad3DAstral"
	print("🌌 NOTEPAD 3D ASTRAL INITIALIZING...")
	
	# Setup astral space environment
	setup_astral_space()
	
	# Create flight camera
	setup_3d_flight()
	
	# Create programming interface
	setup_programming_interface()
	
	# Generate code workspace
	setup_code_workspace()
	
	# Create some example floating code
	create_example_code_blocks()
	
	print("✨ NOTEPAD 3D ASTRAL READY!")
	print("📝 WASD to fly, E to create code, Tab to toggle UI")

func setup_astral_space():
	"""Setup beautiful astral space environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Deep space background
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	environment.sky.sky_material.sky_top_color = Color(0.02, 0.02, 0.1)
	environment.sky.sky_material.sky_horizon_color = Color(0.05, 0.05, 0.2)
	environment.sky.sky_material.ground_bottom_color = Color(0.01, 0.01, 0.05)
	
	# Ambient lighting
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.1, 0.2)
	environment.ambient_light_energy = 0.3
	
	world_env.environment = environment
	add_child(world_env)
	
	# Create star field
	create_simple_star_field()

func create_simple_star_field():
	"""Create simple star field"""
	star_field = Node3D.new()
	star_field.name = "StarField"
	add_child(star_field)
	
	for i in range(500):
		var star = MeshInstance3D.new()
		star.mesh = SphereMesh.new()
		star.mesh.radius = randf_range(0.1, 0.5)
		
		# Random position
		var distance = randf_range(100, 300)
		star.position = Vector3(
			randf_range(-distance, distance),
			randf_range(-distance, distance),
			randf_range(-distance, distance)
		)
		
		# Star material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1, 1, 1)
		material.emission_enabled = true
		material.emission = Color(0.8, 0.8, 1.0)
		star.material_override = material
		
		star_field.add_child(star)

func setup_3d_flight():
	"""Setup 3D flight camera"""
	flight_camera = Camera3D.new()
	flight_camera.name = "FlightCamera"
	flight_camera.position = Vector3(0, 0, 10)
	add_child(flight_camera)
	
	get_viewport().set_camera_3d(flight_camera)
	print("🎮 3D flight camera ready")

func setup_programming_interface():
	"""Setup 3D programming interface"""
	programming_interface = Control.new()
	programming_interface.name = "ProgrammingUI"
	programming_interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create code input area
	var code_input = TextEdit.new()
	code_input.name = "CodeInput"
	code_input.placeholder_text = "Type your code here... Press E to create 3D code block"
	code_input.size = Vector2(400, 300)
	code_input.position = Vector2(50, 50)
	
	# Style the code input
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	style_box.border_color = Color(0.3, 0.6, 1.0)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	code_input.add_theme_stylebox_override("normal", style_box)
	code_input.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	
	programming_interface.add_child(code_input)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = """🌌 NOTEPAD 3D ASTRAL 🌌
WASD: Fly around | Mouse: Look around
E: Create 3D code block | Tab: Toggle UI
R: Run code | C: Clear all code blocks
F: Focus on nearest code block"""
	instructions.position = Vector2(50, 370)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	programming_interface.add_child(instructions)
	
	add_child(programming_interface)

func setup_code_workspace():
	"""Setup 3D code workspace"""
	code_workspace = Node3D.new()
	code_workspace.name = "CodeWorkspace"
	add_child(code_workspace)

func create_example_code_blocks():
	"""Create some example floating code blocks"""
	var example_codes = [
		"func hello_world():\n    print(\"Hello from 3D space!\")",
		"var astral_position = Vector3(0, 5, 0)\nprint(astral_position)",
		"# This is floating code in 3D space\nfor i in range(10):\n    create_star()",
		"class_name AstralBeing\nextends Node3D\n\nfunc fly():\n    position += Vector3.UP"
	]
	
	for i in range(example_codes.size()):
		var pos = Vector3(
			(i - 2) * 8,
			randf_range(-3, 3),
			randf_range(-5, 5)
		)
		create_code_block_3d(example_codes[i], pos)

func create_code_block_3d(code: String, position: Vector3):
	"""Create a 3D floating code block"""
	var block = CodeBlock3D.new("code_" + str(floating_code_blocks.size()), code, position)
	
	# Create visual representation
	var code_node = Node3D.new()
	code_node.name = block.block_id
	code_node.position = position
	
	# Create background plane
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = QuadMesh.new()
	mesh_instance.mesh.size = Vector2(6, 4)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.3, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.2, 0.4, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	code_node.add_child(mesh_instance)
	
	# Create 3D text label
	var label_3d = Label3D.new()
	label_3d.text = code
	label_3d.font_size = 24
	label_3d.modulate = Color(0.9, 0.9, 1.0)
	label_3d.position = Vector3(0, 0, 0.1)
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	code_node.add_child(label_3d)
	
	block.visual_node = code_node
	code_workspace.add_child(code_node)
	floating_code_blocks.append(block)
	
	print("📝 Created 3D code block:", block.block_id)
	code_created.emit(code)

func _physics_process(delta):
	_handle_3d_flight(delta)
	_animate_code_blocks(delta)

func _handle_3d_flight(delta):
	"""Handle 3D flight movement"""
	var movement = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movement.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement.z += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_accept"):  # Space - fly up
		movement.y += 1
	if Input.is_action_pressed("ui_select"):  # Shift - fly down
		movement.y -= 1
	
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = flight_camera.global_transform.basis
		flight_camera.global_position += camera_basis * movement * flight_speed * delta

func _animate_code_blocks(delta):
	"""Animate floating code blocks"""
	for block in floating_code_blocks:
		if block.visual_node:
			# Gentle floating animation
			block.visual_node.rotation_degrees.y += 10 * delta
			block.visual_node.position.y += sin(Time.get_ticks_msec() * 0.001 + block.position.x) * 0.5 * delta

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Mouse look
		var sensitivity = 0.002
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		var rot = flight_camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		flight_camera.rotation_degrees = rot
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				_create_code_from_input()
			KEY_TAB:
				_toggle_programming_ui()
			KEY_R:
				_run_nearest_code()
			KEY_C:
				_clear_all_code_blocks()
			KEY_F:
				_focus_nearest_code_block()
			KEY_ESCAPE:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _create_code_from_input():
	"""Create 3D code block from input"""
	var code_input = programming_interface.get_node("CodeInput")
	var code = code_input.text
	
	if code.length() > 0:
		var pos = flight_camera.global_position + flight_camera.global_transform.basis.z * -5
		create_code_block_3d(code, pos)
		code_input.text = ""
		print("✨ Created 3D code block at your position")

func _toggle_programming_ui():
	"""Toggle programming interface visibility"""
	programming_interface.visible = !programming_interface.visible
	print("🖥️ Programming UI:", "visible" if programming_interface.visible else "hidden")

func _run_nearest_code():
	"""Run the nearest code block"""
	var nearest = _find_nearest_code_block()
	if nearest:
		print("🚀 Running code:", nearest.block_id)
		print("📝 Code content:")
		print(nearest.code_content)
		# Here you could add actual code execution if needed

func _clear_all_code_blocks():
	"""Clear all floating code blocks"""
	for block in floating_code_blocks:
		if block.visual_node:
			block.visual_node.queue_free()
	
	floating_code_blocks.clear()
	print("🧹 Cleared all code blocks")

func _focus_nearest_code_block():
	"""Focus camera on nearest code block"""
	var nearest = _find_nearest_code_block()
	if nearest:
		print("📍 Focusing on:", nearest.block_id)
		# Smooth movement toward code block would go here

func _find_nearest_code_block() -> CodeBlock3D:
	"""Find nearest code block to camera"""
	var nearest: CodeBlock3D = null
	var nearest_distance = INF
	var camera_pos = flight_camera.global_position
	
	for block in floating_code_blocks:
		var distance = camera_pos.distance_to(block.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = block
	
	return nearest

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
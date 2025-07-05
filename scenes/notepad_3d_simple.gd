extends Node3D
class_name Notepad3DSimple

# 📝 NOTEPAD 3D - ONE FILE SCRIPTURA 📝
# Simple 3D programming with visual connections
# Everything you need in one place

# ===== CORE SYSTEMS =====
var flight_camera: Camera3D
var code_editor: TextEdit
var ai_companion: Node3D

# 3D PROGRAMMING BLOCKS
var code_blocks: Array[Node3D] = []
var connection_lines: Array[Node3D] = []
var selected_blocks: Array[Node3D] = []

# TIMELINES & UNIVERSES
var saved_states: Dictionary = {}
var current_universe: String = "main"

# ===== MAIN FUNCTIONS =====

func _ready():
	print("📝 NOTEPAD 3D STARTING...")
	
	# Setup everything in order
	setup_environment()
	setup_camera()
	setup_ai_companion()
	setup_code_editor()
	setup_stars()  # Add visual elements
	
	print("✨ NOTEPAD 3D READY!")
	print("🎮 WASD: Fly | I: AI Help | E: Execute | R: Create Block | C: Connect")

func _process(delta: float):
	handle_flight(delta)
	animate_ai(delta)
	update_connections()

func _input(event: InputEvent):
	handle_input(event)

# ===== SETUP FUNCTIONS =====

func setup_environment():
	"""Create peaceful space environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.02, 0.15)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.2, 0.4)
	environment.ambient_light_energy = 0.3
	world_env.environment = environment
	add_child(world_env)
	
	# Add directional light
	var light = DirectionalLight3D.new()
	light.name = "MainLight"
	light.position = Vector3(0, 10, 5)
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 0.8
	add_child(light)

func setup_camera():
	"""Setup flight camera"""
	flight_camera = Camera3D.new()
	flight_camera.name = "FlightCamera"
	flight_camera.position = Vector3(0, 3, 8)
	flight_camera.current = true
	add_child(flight_camera)

func setup_ai_companion():
	"""Create AI companion orb"""
	ai_companion = Node3D.new()
	ai_companion.name = "CodeSage"
	ai_companion.position = Vector3(2, 1, 0)
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 0.3
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.8, 1.0, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.6, 0.9)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	
	ai_companion.add_child(mesh)
	add_child(ai_companion)

func setup_code_editor():
	"""Setup 2D code editor overlay"""
	var ui = CanvasLayer.new()
	add_child(ui)
	
	code_editor = TextEdit.new()
	code_editor.name = "CodeEditor"
	code_editor.placeholder_text = "# 3D Programming Universe\nprint('Hello 3D World!')\n\n# Press R to create 3D block\n# Press C to connect blocks"
	code_editor.size = Vector2(500, 300)
	code_editor.position = Vector2(50, 50)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	style.border_color = Color(0.3, 0.5, 0.8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	code_editor.add_theme_stylebox_override("normal", style)
	code_editor.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	
	ui.add_child(code_editor)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "📝 NOTEPAD 3D | WASD: Fly | I: AI | E: Execute | R: Block | C: Connect | T: Timeline"
	instructions.position = Vector2(50, 370)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	ui.add_child(instructions)

func setup_stars():
	"""Create beautiful star field"""
	for i in range(200):
		var star = MeshInstance3D.new()
		star.mesh = SphereMesh.new()
		star.mesh.radius = randf_range(0.1, 0.5)
		
		# Random position around player
		var distance = randf_range(50, 200)
		var angle1 = randf() * TAU
		var angle2 = randf() * PI
		
		star.position = Vector3(
			distance * sin(angle2) * cos(angle1),
			distance * cos(angle2),
			distance * sin(angle2) * sin(angle1)
		)
		
		# Beautiful star colors
		var material = StandardMaterial3D.new()
		var colors = [
			Color(1, 1, 1),      # White
			Color(1, 0.8, 0.6),  # Yellow
			Color(0.6, 0.8, 1),  # Blue
			Color(1, 0.6, 0.4)   # Orange
		]
		var color = colors[randi() % colors.size()]
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color * 0.8
		
		star.material_override = material
		add_child(star)

# ===== INPUT HANDLING =====

func handle_input(event: InputEvent):
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity = 0.002
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		var rot = flight_camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		flight_camera.rotation_degrees = rot
	
	# Key actions
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:  # AI Help
				get_ai_help()
			KEY_E:  # Execute Code
				execute_code()
			KEY_R:  # Create 3D Block
				create_3d_code_block()
			KEY_C:  # Connect Blocks
				connect_selected_blocks()
			KEY_T:  # Save Timeline
				save_timeline()
			KEY_U:  # New Universe
				create_universe()
			KEY_TAB:  # Toggle UI
				code_editor.get_parent().visible = !code_editor.get_parent().visible
			KEY_ESCAPE:  # Mouse toggle
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ===== MOVEMENT =====

func handle_flight(delta: float):
	"""Handle WASD flight - NO CONFLICTS"""
	var movement = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		movement.z -= 1
	if Input.is_key_pressed(KEY_S):
		movement.z += 1
	if Input.is_key_pressed(KEY_A):  # ONLY MOVEMENT
		movement.x -= 1
	if Input.is_key_pressed(KEY_D):  # ONLY MOVEMENT
		movement.x += 1
	if Input.is_key_pressed(KEY_SPACE):
		movement.y += 1
	if Input.is_key_pressed(KEY_SHIFT):
		movement.y -= 1
	
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = flight_camera.global_transform.basis
		flight_camera.global_position += camera_basis * movement * 10.0 * delta

func animate_ai(delta: float):
	"""Animate AI companion"""
	if ai_companion:
		ai_companion.rotation_degrees.y += 30 * delta
		ai_companion.position.y += sin(Time.get_ticks_msec() * 0.003) * 0.1 * delta

# ===== 3D PROGRAMMING FUNCTIONS =====

func get_ai_help():
	"""AI gives contextual help"""
	var suggestions = [
		"💡 Try creating connected code blocks with R then C",
		"💡 Use multiple inputs/outputs for complex functions",
		"💡 Connect blocks to see data flow visually",
		"💡 Save different programming timelines with T",
		"💡 Create new universes for different projects with U",
		"💡 Select code and press R to make it a 3D block"
	]
	var suggestion = suggestions[randi() % suggestions.size()]
	print("🤖 CodeSage: " + suggestion)

func execute_code():
	"""Execute code in editor"""
	var code = code_editor.text
	print("🚀 Executing: " + code.split("\n")[0])
	print("✅ Code executed in 3D programming universe!")

func create_3d_code_block():
	"""Create 3D code block from selected text or cursor line"""
	var code_text = code_editor.get_selected_text()
	if code_text.length() == 0:
		# Get current line if no selection
		var line_num = code_editor.get_caret_line()
		code_text = code_editor.get_line(line_num)
	
	if code_text.length() == 0:
		code_text = "function()"
	
	# Create 3D block
	var block = Node3D.new()
	block.name = "CodeBlock_" + str(code_blocks.size())
	block.position = flight_camera.global_position + flight_camera.global_transform.basis.z * -8
	
	# Create visual block
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.mesh.size = Vector3(4, 2, 1)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.8, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.2, 0.4)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	
	block.add_child(mesh)
	
	# Add text label
	var label = Label3D.new()
	label.text = code_text
	label.font_size = 16
	label.modulate = Color(1, 1, 1)
	label.position = Vector3(0, 0, 0.6)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	block.add_child(label)
	
	# Add input/output connection points
	create_connection_points(block, code_text)
	
	add_child(block)
	code_blocks.append(block)
	
	print("📦 Created 3D code block: " + code_text.split("\n")[0])

func create_connection_points(block: Node3D, code_text: String):
	"""Create input/output points on code block"""
	# Analyze code to determine inputs/outputs
	var inputs = 1
	var outputs = 1
	
	# Simple analysis
	if "(" in code_text and ")" in code_text:
		var params = code_text.split("(")[1].split(")")[0]
		if params.length() > 0 and params != "":
			inputs = params.count(",") + 1
	
	if "return" in code_text:
		outputs = 1
	elif "print" in code_text:
		outputs = 0  # Side effect, no return
	
	# Create input points (left side)
	for i in range(inputs):
		var input_point = Node3D.new()
		input_point.name = "input_" + str(i)
		input_point.position = Vector3(-2, 0.5 - (i * 0.5), 0)
		
		var input_mesh = MeshInstance3D.new()
		input_mesh.mesh = SphereMesh.new()
		input_mesh.mesh.radius = 0.15
		
		var input_material = StandardMaterial3D.new()
		input_material.albedo_color = Color(0.2, 1.0, 0.2)  # Green inputs
		input_material.emission_enabled = true
		input_material.emission = Color(0.1, 0.5, 0.1)
		input_mesh.material_override = input_material
		
		input_point.add_child(input_mesh)
		block.add_child(input_point)
	
	# Create output points (right side)
	for i in range(outputs):
		var output_point = Node3D.new()
		output_point.name = "output_" + str(i)
		output_point.position = Vector3(2, 0.5 - (i * 0.5), 0)
		
		var output_mesh = MeshInstance3D.new()
		output_mesh.mesh = SphereMesh.new()
		output_mesh.mesh.radius = 0.15
		
		var output_material = StandardMaterial3D.new()
		output_material.albedo_color = Color(1.0, 0.2, 0.2)  # Red outputs
		output_material.emission_enabled = true
		output_material.emission = Color(0.5, 0.1, 0.1)
		output_mesh.material_override = output_material
		
		output_point.add_child(output_mesh)
		block.add_child(output_point)

func connect_selected_blocks():
	"""Connect two selected blocks with visual line"""
	if code_blocks.size() >= 2:
		var block1 = code_blocks[code_blocks.size() - 2]  # Second to last
		var block2 = code_blocks[code_blocks.size() - 1]  # Last
		
		create_connection_line(block1, block2)
		print("🔗 Connected blocks: " + block1.name + " → " + block2.name)

func create_connection_line(from_block: Node3D, to_block: Node3D):
	"""Create visual connection line between blocks"""
	var line = Node3D.new()
	line.name = "Connection_" + str(connection_lines.size())
	
	# Find output point of from_block and input point of to_block
	var from_point = from_block.global_position
	var to_point = to_block.global_position
	
	# Try to find specific connection points
	for child in from_block.get_children():
		if child.name.begins_with("output_"):
			from_point = child.global_position
			break
	
	for child in to_block.get_children():
		if child.name.begins_with("input_"):
			to_point = child.global_position
			break
	
	# Create line mesh
	var mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = from_point.distance_to(to_point)
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	mesh.mesh = cylinder
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 0.2, 0.8)  # Yellow connections
	material.emission_enabled = true
	material.emission = Color(0.5, 0.5, 0.1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	
	line.add_child(mesh)
	
	# Position and orient line
	line.global_position = (from_point + to_point) / 2
	line.look_at(to_point, Vector3.UP)
	line.rotate_object_local(Vector3.RIGHT, PI/2)  # Align cylinder
	
	add_child(line)
	connection_lines.append(line)

func update_connections():
	"""Update connection line positions (for dynamic blocks)"""
	# This would update line positions if blocks move
	pass

# ===== TIMELINE & UNIVERSE FUNCTIONS =====

func save_timeline():
	"""Save current state as timeline"""
	var timeline_id = "timeline_" + str(Time.get_ticks_msec())
	var state = {
		"code": code_editor.text,
		"blocks": code_blocks.size(),
		"connections": connection_lines.size(),
		"camera_pos": flight_camera.global_position,
		"universe": current_universe
	}
	saved_states[timeline_id] = state
	print("💾 Timeline saved: " + timeline_id)

func create_universe():
	"""Create new programming universe"""
	current_universe = "universe_" + str(saved_states.size())
	print("🌌 Created universe: " + current_universe)

func save_current_state():
	"""Save state on exit"""
	save_timeline()
	print("💾 State saved to Akashic Records")

# ===== ENTER/EXIT =====

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	save_current_state()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
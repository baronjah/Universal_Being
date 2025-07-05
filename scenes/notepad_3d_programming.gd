extends Node3D
class_name Notepad3DProgramming

# 📝 NOTEPAD 3D PROGRAMMING 📝
# 3D programming environment with local AI and 4D timelines
# Pure programming and creation
# Integrated with Universal Being Pentagon Architecture

signal code_executed(result: String)
signal ai_suggestion_given(suggestion: String)
signal timeline_created(timeline_id: String)

# PROGRAMMING ENVIRONMENT
var flight_camera: Camera3D
var programming_interface: Control
var local_ai: LocalAI
var timeline_system: Timeline4D

# 3D CODE BLOCKS
var floating_code: Array[CodeBlock3D] = []
var code_workspace: Node3D

# AI COMPANION
class LocalAI:
	var ai_orb: Node3D
	var ai_name: String = "CodeSage"
	var knowledge_base: Array[String] = [
		"Try creating a loop with for i in range(10)",
		"Add some 3D objects with MeshInstance3D.new()",
		"Create variables with var my_variable = value",
		"Use functions with func my_function():",
		"Connect signals with signal_name.connect(function)"
	]
	
	func _init():
		_create_ai_visual()
	
	func _create_ai_visual():
		ai_orb = Node3D.new()
		ai_orb.name = "LocalAI"
		
		var mesh = MeshInstance3D.new()
		mesh.mesh = SphereMesh.new()
		mesh.mesh.radius = 0.3
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.8, 1.0, 0.8)
		material.emission_enabled = true
		material.emission = Color(0.1, 0.6, 0.9)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh.material_override = material
		
		ai_orb.add_child(mesh)
	
	func give_suggestion() -> String:
		return knowledge_base[randi() % knowledge_base.size()]
	
	func comment_on_code(code: String) -> String:
		if "func" in code:
			return "Nice function definition! Functions are powerful."
		elif "var" in code:
			return "Good variable usage! Variables store data."
		elif "for" in code:
			return "Excellent loop! Loops repeat actions."
		else:
			return "Interesting code! Keep experimenting."

class CodeBlock3D:
	var block_id: String
	var code_text: String
	var position: Vector3
	var visual_node: Node3D
	var executable: bool = true
	
	func _init(id: String, code: String, pos: Vector3):
		block_id = id
		code_text = code
		position = pos

class Timeline4D:
	var saved_states: Dictionary = {}
	var current_timeline: String = "main"
	
	func save_state(state_id: String, code_blocks: Array, ai_position: Vector3):
		saved_states[state_id] = {
			"code_blocks": code_blocks.duplicate(),
			"ai_position": ai_position,
			"timestamp": Time.get_ticks_msec()
		}
		print("💾 Timeline saved:", state_id)
	
	func load_state(state_id: String) -> Dictionary:
		if saved_states.has(state_id):
			print("⏪ Loading timeline:", state_id)
			return saved_states[state_id]
		return {}

# PENTAGON ARCHITECTURE COMPLIANCE
func pentagon_init() -> void:
	print("📝 Pentagon Init: Notepad 3D Programming")

func pentagon_ready() -> void:
	name = "Notepad3DProgramming"
	print("📝 NOTEPAD 3D PROGRAMMING STARTING...")
	
	# Setup 3D environment
	setup_3d_environment()
	
	# Create flight camera
	setup_flight_camera()
	
	# Initialize local AI
	setup_local_ai()
	
	# Create programming interface
	setup_programming_interface()
	
	# Setup timeline system
	timeline_system = Timeline4D.new()
	
	# Create workspace
	setup_code_workspace()
	
	print("✨ NOTEPAD 3D READY!")
	print("📝 Type code, press E to execute, A for AI help")

func pentagon_process(delta: float) -> void:
	_handle_flight(delta)
	_animate_ai(delta)

func pentagon_input(event: InputEvent) -> void:
	_handle_notepad_input(event)

func pentagon_sewers() -> void:
	print("📝 Pentagon Sewers: Notepad 3D shutting down")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ready():
	pentagon_init()
	pentagon_ready()

func setup_3d_environment():
	"""Setup peaceful 3D environment"""
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.15)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.2, 0.3, 0.5)
	environment.ambient_light_energy = 0.3
	
	world_env.environment = environment
	add_child(world_env)

func setup_flight_camera():
	"""Setup 3D flight camera"""
	flight_camera = Camera3D.new()
	flight_camera.name = "ProgrammingCamera"
	flight_camera.position = Vector3(0, 2, 5)
	flight_camera.current = true
	add_child(flight_camera)

func setup_local_ai():
	"""Setup local AI companion"""
	local_ai = LocalAI.new()
	local_ai.ai_orb.position = Vector3(2, 1, 0)
	add_child(local_ai.ai_orb)
	print("🤖 Local AI 'CodeSage' ready")

func setup_programming_interface():
	"""Setup 3D programming interface"""
	programming_interface = Control.new()
	programming_interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Code editor
	var code_editor = TextEdit.new()
	code_editor.name = "CodeEditor"
	code_editor.placeholder_text = "# Write your 3D code here\nprint('Hello 3D World!')"
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
	
	programming_interface.add_child(code_editor)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = """📝 NOTEPAD 3D PROGRAMMING 📝
WASD: Fly around | Mouse: Look
E: Execute code | A: AI suggestion  
T: Save timeline | L: Load timeline
C: Create 3D code block | Tab: Toggle UI"""
	instructions.position = Vector2(50, 370)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	programming_interface.add_child(instructions)
	
	# AI status
	var ai_status = Label.new()
	ai_status.name = "AIStatus"
	ai_status.text = "🤖 CodeSage: Ready to help with 3D programming!"
	ai_status.position = Vector2(50, 450)
	ai_status.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	programming_interface.add_child(ai_status)
	
	add_child(programming_interface)

func setup_code_workspace():
	"""Setup 3D code workspace"""
	code_workspace = Node3D.new()
	code_workspace.name = "CodeWorkspace"
	add_child(code_workspace)

func _physics_process(delta):
	pentagon_process(delta)

func _handle_flight(delta):
	"""Handle 3D flight movement"""
	var movement = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		movement.z -= 1
	if Input.is_key_pressed(KEY_S):
		movement.z += 1
	if Input.is_key_pressed(KEY_A):
		movement.x -= 1
	if Input.is_key_pressed(KEY_D):
		movement.x += 1
	if Input.is_key_pressed(KEY_SPACE):
		movement.y += 1
	if Input.is_key_pressed(KEY_SHIFT):
		movement.y -= 1
	
	if movement.length() > 0:
		movement = movement.normalized()
		var camera_basis = flight_camera.global_transform.basis
		flight_camera.global_position += camera_basis * movement * 8.0 * delta

func _animate_ai(delta):
	"""Animate AI companion"""
	if local_ai and local_ai.ai_orb:
		local_ai.ai_orb.rotation_degrees.y += 30 * delta
		local_ai.ai_orb.position.y += sin(Time.get_ticks_msec() * 0.002) * 0.2 * delta

func _input(event):
	pentagon_input(event)

func _handle_notepad_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity = 0.002
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		var rot = flight_camera.rotation_degrees
		rot.x = clamp(rot.x, -90, 90)
		flight_camera.rotation_degrees = rot
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				execute_code()
			KEY_A:
				get_ai_suggestion()
			KEY_C:
				create_3d_code_block()
			KEY_T:
				save_timeline()
			KEY_L:
				load_timeline()
			KEY_TAB:
				toggle_ui()
			KEY_ESCAPE:
				toggle_mouse_capture()

func execute_code():
	"""Execute written code"""
	var code_editor = programming_interface.get_node("CodeEditor")
	var code = code_editor.text
	
	if code.length() > 0:
		print("🚀 Executing code:")
		print(code)
		
		# Simple code execution simulation
		if "print" in code:
			var result = "Code executed successfully!"
			_show_ai_message("✅ CodeSage: Great print statement!")
		elif "var" in code:
			_show_ai_message("📊 CodeSage: Nice variable declaration!")
		elif "func" in code:
			_show_ai_message("⚙️ CodeSage: Excellent function definition!")
		else:
			_show_ai_message("💡 CodeSage: Interesting code structure!")
		
		code_executed.emit(code)

func get_ai_suggestion():
	"""Get suggestion from local AI"""
	if local_ai:
		var suggestion = local_ai.give_suggestion()
		_show_ai_message("🤖 CodeSage suggests: " + suggestion)
		ai_suggestion_given.emit(suggestion)

func create_3d_code_block():
	"""Create floating 3D code block"""
	var code_editor = programming_interface.get_node("CodeEditor")
	var code = code_editor.text
	
	if code.length() > 0:
		var pos = flight_camera.global_position + flight_camera.global_transform.basis.z * -5
		var block = CodeBlock3D.new("block_" + str(floating_code.size()), code, pos)
		
		_create_code_block_visual(block)
		floating_code.append(block)
		
		print("📝 Created 3D code block")
		_show_ai_message("✨ CodeSage: Beautiful 3D code block!")

func _create_code_block_visual(block: CodeBlock3D):
	"""Create visual for 3D code block"""
	var block_node = Node3D.new()
	block_node.name = block.block_id
	block_node.position = block.position
	
	# Background
	var bg = MeshInstance3D.new()
	bg.mesh = QuadMesh.new()
	bg.mesh.size = Vector2(4, 3)
	
	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = Color(0.1, 0.2, 0.4, 0.8)
	bg_material.emission_enabled = true
	bg_material.emission = Color(0.05, 0.1, 0.3)
	bg_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg.material_override = bg_material
	
	block_node.add_child(bg)
	
	# Text
	var text_label = Label3D.new()
	text_label.text = block.code_text
	text_label.font_size = 16
	text_label.modulate = Color(0.9, 0.9, 1.0)
	text_label.position = Vector3(0, 0, 0.1)
	text_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	block_node.add_child(text_label)
	
	block.visual_node = block_node
	code_workspace.add_child(block_node)

func save_timeline():
	"""Save current state to 4D timeline"""
	var timeline_id = "timeline_" + str(Time.get_ticks_msec())
	timeline_system.save_state(timeline_id, floating_code, local_ai.ai_orb.position)
	_show_ai_message("💾 CodeSage: Timeline saved as " + timeline_id)
	timeline_created.emit(timeline_id)

func load_timeline():
	"""Load previous timeline state"""
	var states = timeline_system.saved_states.keys()
	if states.size() > 0:
		var latest_state = states[states.size() - 1]
		var state_data = timeline_system.load_state(latest_state)
		_show_ai_message("⏪ CodeSage: Timeline loaded!")
	else:
		_show_ai_message("📋 CodeSage: No timelines to load yet")

func toggle_ui():
	"""Toggle programming UI"""
	programming_interface.visible = !programming_interface.visible

func toggle_mouse_capture():
	"""Toggle mouse capture"""
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _show_ai_message(message: String):
	"""Show AI message in UI"""
	var ai_status = programming_interface.get_node("AIStatus")
	ai_status.text = message
	print(message)

func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	pentagon_sewers()
# Add these functions to your main script that handles menu interactions
#res://code/gdscript/scripts/Snake_Space_Movement/snake_controller.gd
# JSH_World/terminal
#
extends Node
class_name CharacterController
#
#extends Node3D
#class_name JSHTerminal
#
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# JSH_Terminal 1

#
# JSH Terminal System
# jsh_terminal.gd
# A terminal implementation that works with your existing code structure

# References to other systems
#

#
var text_display: Label3D
var terminal_base: MeshInstance3D
var keyboard_area: Area3D

var width = 4.0
var height = 3.0
var depth = 0.2

signal combo_detected(combo_name)
# Movement parameters
var move_speed = 5.0
var rotation_speed = 3.0


var is_moving_forward = false
var is_moving_backward = false
var is_moving_left = false
var is_moving_right = false

var camera = null

var main_node
var thread_pool
var camera_pivot
var character_model: Node3D

var turn_speed = 2.0

var smoothing = 0.2

var is_moving = false

var character_height = 1.5

var collision_shape: CollisionShape3D

var terminal_node = null
var terminal_initialized = false
var terminal_instructions_set = null
var terminal_interaction_set = null
var terminal_combo_definitions = {}

var main_system = null
var combo_system = null
var datapoint = null

# Terminal components
var terminal_mesh: MeshInstance3D
var terminal_screen: MeshInstance3D
var terminal_text: Label3D
var terminal_input: Label3D
var terminal_status: Label3D

# Terminal state
var active = false
var current_input = ""
var input_history = []
var history_index = -1
var max_history = 50
var terminal_content = []
var max_content_lines = 100
var prompt = "JSH> "
var cursor_visible = true
var cursor_blink_time = 0.5
var cursor_timer = 0

# Terminal visuals
var screen_width = 5.0
var screen_height = 3.0

var command_registry = {}
var combo_active = false
var auto_suggestions = true
var current_suggestions = []
var suggestion_index = 0
#

#
var direction = Vector3.FORWARD
var last_safe_position = Vector3.ZERO
var current_velocity = Vector3.ZERO
var target_velocity = Vector3.ZERO
var velocity = Vector3.ZERO
#
var terminal_base_color = Color(0.1, 0.1, 0.1)
var terminal_text_color = Color(0.0, 0.8, 0.0)
var terminal_highlight_color = Color(0.0, 1.0, 0.2)
var status_color = Color(0.0, 0.5, 0.0)
var cursor_color = Color(0.0, 1.0, 0.2)
#

# Current combo state tracking
var active_combo = null
var combo_stage = 0
var combo_history = []
var max_combo_history = 20

# Stores the last few commands entered
var command_history = []
var max_command_history = 10
var terminal_add_number : String = "terminal_"
var combo_add_number : String = "combo_"

# Parent reference to access sixth_dimensional_magic and other functions
var main_system_new = null
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# Signals
signal command_executed(command, result)
signal terminal_activated()
signal terminal_deactivated()


# Signals
signal combo_started(combo_name, description)
signal combo_advanced(combo_name, next_stage, description)
signal combo_completed(combo_name)
signal combo_broken(combo_name, reason)
#



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


# Define command patterns similar to how you define interactions
const terminal_command_patterns = {
	0: [
		["file_ops"],
		["ls", "cat", "grep"],
		["List files, view contents, search in file"]
	],
	1: [
		["search_system"],
		["find", "grep", "sort"],
		["Find files, search in results, sort output"]
	],
	2: [
		["git_workflow"],
		["git_status", "git_add", "git_commit", "git_push"],
		["Check status, stage files, commit, push changes"]
	],
	3: [
		["backup_sequence"],
		["ls", "tar", "mv"],
		["List files, archive them, move archive"]
	],
	4: [
		["analyze_report"],
		["scan_directory", "analyze_file", "generate_report"],
		["Scan directory, analyze files, generate report"]
	],
	5: [
		["system_check"],
		["processes", "memory", "disk"],
		["Check running processes, memory usage, disk space"]
	]
}








func update_display():
	var display_text = terminal_text
	
	# Add the current input line with cursor
	if active:
		if cursor_visible:
			display_text += prompt + current_input + "_"
		else:
			display_text += prompt + current_input + " "
	
#	text_display.text = display_text

func process_input(input_text: String):
	if input_text.strip_edges() == "":
		terminal_text += prompt + "\n"
		update_display()
		return
	
	# Add to display and history
	terminal_text += prompt + input_text + "\n"
	command_history.append(input_text)
	history_index = -1
	
	# Check for combos
	var combo_result = combo_system.process_command(input_text)
	
	if combo_result.is_combo:
		terminal_text += combo_result.message + "\n"
		emit_signal("combo_detected", combo_result.combo_name)
		
		if combo_result.action != null:
			var action_result = combo_system.execute_combo_action(combo_result.combo_name)
			terminal_text += action_result.output + "\n"
	else:
		# Process regular command
		var command_parts = input_text.split(" ", false)
		var base_command = command_parts[0].to_lower()
		var args = command_parts.slice(1)
		
		var result = execute_command(base_command, args)
		emit_signal("command_executed", base_command, result)
	
	# Reset input
	current_input = ""
	update_display()

func execute_command(base_command, args ):
	print(" execute command ", base_command, args)



























#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func _input_add(event):
	if !active:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER:
				process_input(current_input)
			KEY_ESCAPE:
				deactivate()
			KEY_BACKSPACE:
				if current_input.length() > 0:
					current_input = current_input.substr(0, current_input.length() - 1)
					update_input_display()
			KEY_UP:
				navigate_history(-1)
			KEY_DOWN:
				navigate_history(1)
			KEY_TAB:
				handle_tab_completion()
			_:
				# Handle regular character input
				if event.keycode >= 32 and event.keycode <= 126:  # ASCII printable chars
					current_input += char(event.keycode)
					update_input_display()



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func is_colliding() -> bool:
	# Simple collision check - can be expanded to use proper physics
	# For now, we're assuming a simple collision envelope
	#if position.y < 0:
	#	return true
	return false




#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# Movement commands
func move_forward():
	is_moving_forward = true

func move_backward():
	is_moving_backward = true

func move_left():
	is_moving_left = true

func move_right():
	is_moving_right = true

func stop_moving():
	is_moving_forward = false
	is_moving_backward = false
	is_moving_left = false
	is_moving_right = false

## Movement commands - these can be called from your dimensional magic
#func move_forward_snake():
	#target_velocity = -global_transform.basis.z * move_speed
	#is_moving = true
#
#func move_backward_snake():
	#target_velocity = global_transform.basis.z * move_speed
	#is_moving = true
#
#func move_left_snake():
	#target_velocity = -global_transform.basis.x * move_speed
	#is_moving = true
#
#func move_right_snake():
	#target_velocity = global_transform.basis.x * move_speed
	#is_moving = true
#
#func stop_moving_snake():
	#target_velocity = Vector3.ZERO
	#is_moving = false
#
#func turn_left(amount: float = 1.0):
	#rotate_y(turn_speed * amount)
#
#func turn_right(amount: float = 1.0):
	#rotate_y(-turn_speed * amount)

# where is start moving



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


func update_display_console():
	terminal_text.text = "\n".join(terminal_content)
	update_input_display()
	



func execute_command_console(command_text: String):
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	if command_registry.has(cmd):
		var command_data = command_registry[cmd]
		var result = command_data.target.call(command_data.method, args)
		
		if result is Dictionary and result.has("output"):
			if result.output is String and !result.output.empty():
				add_line(result.output)
		
		emit_signal("command_executed", cmd, result)
	else:
		# Try to pass to main system if available
		if main_system and main_system.has_method("terminal_command_magic"):
			var result = main_system.terminal_command_magic(cmd, args)
			
			if result is Dictionary and result.has("message"):
				add_line(result.message)
		else:
			add_line("Unknown command: " + cmd)
	
	# After executing any command, check for suggestions
	current_suggestions = combo_system.get_suggestions()
	suggestion_index = 0


func execute_command_console_command(command: String, args: Array) :
	var result = {
		"success": true,
		"output": "",
		"command": command,
		"args": args
	}
	
	# Check built-in commands first
	match command:
		"help":
			var terminal_text
			return "error"


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


func process_input_console(input_text: String):
	# Add to history and display
	if input_text.strip_edges() != "":
		input_history.append(input_text)
		if input_history.size() > max_history:
			input_history.pop_front()
		history_index = -1
		
		add_line(prompt + input_text)
		
		# First check if it's part of a combo
		var combo_result = combo_system.process_command(input_text)
		
		if combo_result.status == "completed":
			# Combo was completed, action already executed
			pass
		elif combo_result.status in ["started", "continued"]:
			# Combo is in progress, show helpful info
			var status = combo_system.get_current_combo_status()
			if status.active:
				add_line("> Combo '" + status.name + "' " + 
						 "(" + str(status.stage) + "/" + str(status.total_stages) + ") " +
						 status.description)
				if status.next_command:
					add_line("> Next: " + status.next_command)
		else:
			# Regular command execution
			execute_command_one(input_text)
	
	# Clear input
	current_input = ""
	update_display()



func execute_command_one(input_text):
	print("one command ", input_text)






































#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func _init(parent = null):
	main_system = parent

func _ready():
	# Create terminal components
	setup_terminal_components()
	
	combo_system 
	
	# Connect signals from combo system
#	combo_system.combo_started.connect(_on_combo_started)
#	combo_system.combo_advanced.connect(_on_combo_advanced)
#	combo_system.combo_completed.connect(_on_combo_completed)
#	combo_system.combo_broken.connect(_on_combo_broken)
	
	# Register built-in commands
	register_command("help", self, "_cmd_help")
	register_command("clear", self, "_cmd_clear")
	register_command("history", self, "_cmd_history")
	register_command("combos", self, "_cmd_combos")
	register_command("exit", self, "_cmd_exit")
	
	add_welcome_message()
	update_display()
	
	set_process(true)




#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#





var TerminalCombos




func setup_collision():
	# Setup collision for interaction
	keyboard_area = Area3D.new()
	keyboard_area.name = "KeyboardArea"
	
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "TerminalCollision"
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(width, height / 3, 0.5)  # Lower third is keyboard area
	collision_shape.shape = box_shape
	
	keyboard_area.add_child(collision_shape)
	
	# Position the keyboard area at the bottom of the terminal
	keyboard_area.position.y = -height / 3
	keyboard_area.position.z = 0.2
	var _on_keyboard_area_input_event
	var _on_keyboard_area_mouse_entered
	# Connect signals
	# _on_keyboard_area_mouse_exited
	var _on_keyboard_area_mouse_exited
	keyboard_area.input_event.connect(_on_keyboard_area_input_event)
	keyboard_area.mouse_entered.connect(_on_keyboard_area_mouse_entered)
	keyboard_area.mouse_exited.connect(_on_keyboard_area_mouse_exited)
	
	add_child(keyboard_area)

func setup_text_display():
	# Create 3D label for text display
	text_display = Label3D.new()
	text_display.name = "TextDisplay"
	
	# Configure text properties
	text_display.font_size = 60
	text_display.text = ""
	text_display.width = width * 100  # Larger value for more text space
	text_display.height = height * 100
	text_display.pixel_size = 0.01  # Adjust as needed for text scale
	text_display.modulate = Color(0, 1, 0)  # Green terminal text
	text_display.outline_modulate = Color(0, 0.5, 0)
	text_display.text_alignment = Label3D
	text_display
	
	
	# Position slightly in front of the screen
	text_display.position.z = 0.01
	
	# Scale text to fit screen
	text_display.scale = Vector3(0.02, 0.02, 0.02)
	
	# Adjust position for alignment
	text_display.position.x = -width / 2 + 0.2
	text_display.position.y = height / 2 - 0.2
	
	add_child(text_display)

func setup_terminal_mesh():
	# Create the main terminal screen
	terminal_screen = MeshInstance3D.new()
	terminal_screen.name = "TerminalScreen"
	
	# Create a simple plane mesh for the screen
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(width, height)
	terminal_screen.mesh = plane_mesh
	
	# Create material for the screen
	var screen_material = StandardMaterial3D.new()
	screen_material.albedo_color = Color(0.1, 0.1, 0.1)
	screen_material.roughness = 0.2
	screen_material.metallic = 0.8
	screen_material.emission_enabled = true
	screen_material.emission = Color(0.1, 0.3, 0.2)  # Slight green glow
	screen_material.emission_energy = 0.5
	terminal_screen.material_override = screen_material
	
	# Add the screen to the terminal
	add_child(terminal_screen)
	
	# Create terminal base (slightly larger than screen)
	terminal_base = MeshInstance3D.new()
	terminal_base.name = "TerminalBase"
	
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(width + 0.4, height + 0.4, depth)
	terminal_base.mesh = base_mesh
	
	# Position the base slightly behind the screen
	terminal_base.position.z = -0.1
	
	# Create material for the base
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.2, 0.2, 0.2)
	base_material.roughness = 0.7
	terminal_base.material_override = base_material
	
	# Add the base to the terminal
	add_child(terminal_base)

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#



func _ready_console():
	setup_terminal_mesh()
	setup_collision()
	setup_text_display()
	
	# Initialize combo system
	combo_system = TerminalCombos.new()
	
	# Start with terminal inactive but visible
	active = false
	update_display()
	
	# Set up cursor blinking
	set_process(true)




#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


func _ready_snake():
	# Connect to JSH systems
	main_node = get_node("/root/main")
	thread_pool = get_node("/root/thread_pool_autoload")
	
	# Create character model
	initialize_character()
	
	# Store initial position as safe
	#last_safe_position = global_position

func _ready_snake_new():
	# Find camera if it exists
	camera = get_viewport().get_camera_3d()


func initialize_character():
	# Create a simple character model
	character_model = create_character_mesh()
	add_child(character_model)
	
	# Add collision
	collision_shape = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = character_height
	collision_shape.shape = capsule
	add_child(collision_shape)
	
	# Register with JSH system
	register_with_jsh()

func create_character_mesh() -> Node3D:
	var model = Node3D.new()
	model.name = "CharacterModel"
	
	# Create body mesh
	var body = MeshInstance3D.new()
	body.name = "Body"
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.5
	capsule_mesh.height = 1.0
	body.mesh = capsule_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.8)
	material.metallic = 0.3
	material.roughness = 0.7
	body.material_override = material
	
	model.add_child(body)
	return model


































#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


func _process(delta):
	if active:
		# Handle cursor blinking
		cursor_timer += delta
		if cursor_timer >= cursor_blink_time:
			cursor_timer = 0
			cursor_visible = !cursor_visible
			update_input_display()
		



#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


func _process_console(delta):
	# Handle cursor blinking
	cursor_timer += delta
	if cursor_timer >= cursor_blink_time:
		cursor_timer = 0
		cursor_visible = !cursor_visible
		update_display()





#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#





func _process_snake(delta):
	if is_moving:
		# Smooth movement
		current_velocity = current_velocity.lerp(target_velocity, smoothing)
		#global_position += current_velocity * delta
		
		# Update camera pivot position to follow character
		if camera_pivot:
			var offset = Vector3(0, character_height, 0)
			#camera_pivot.global_position = global_position + offset
			
		# Store position as safe if not colliding
		if !is_colliding():
			last_safe_position #= global_position
		#else:
			# Return to last safe position if colliding
			#global_position = last_safe_position

func _process_snake_new(delta):
	# Calculate movement direction
	var move_direction = Vector3.ZERO
	
	if is_moving_forward:
		move_direction.z -= 1
	if is_moving_backward:
		move_direction.z += 1
	if is_moving_left:
		move_direction.x -= 1
	if is_moving_right:
		move_direction.x += 1
	
	# Normalize for consistent speed in all directions
	if move_direction.length_squared() > 0:
		move_direction = move_direction.normalized()
	
	# Apply camera orientation if available
	if camera:
		var camera_basis = camera.global_transform.basis
		move_direction = camera_basis * Vector3(move_direction.x, 0, move_direction.z)
		move_direction.y = 0
		move_direction = move_direction.normalized()
	
	# Apply movement
	velocity = move_direction * move_speed
	var global_position# += velocity * delta
	
	# Rotate character to face movement direction
	if move_direction.length_squared() > 0:
		var target_rotation = atan2(move_direction.x, move_direction.z)
		var current_rotation #= rotation.y
		
		# Smooth rotation
		var rotation#.y #= lerp_angle(current_rotation, target_rotation, rotation_speed * delta)









#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
# Can be called from your dimensional magic system

## commands
# commands
# orders

#

func teleport_to(new_position: Vector3):
	var global_position = new_position
	last_safe_position = new_position
	
	# Update camera
	if camera_pivot:
		var offset = Vector3(0, character_height, 0)
		camera_pivot.global_position = global_position + offset
#

func add_line(text: String):
	terminal_content.append(text)
	
	# Limit number of lines
	if terminal_content.size() > max_content_lines:
		terminal_content.pop_front()
	
	update_display()


func update_input_display():
	if active:
		if cursor_visible:
			terminal_input.text = prompt + current_input + "_"
		else:
			terminal_input.text = prompt + current_input + " "
	else:
		terminal_input.text = "[Terminal inactive]"

func navigate_history(direction):
	if input_history.size() == 0:
		return
		
	history_index = clamp(history_index + direction, -1, input_history.size() - 1)
	
	if history_index == -1:
		current_input = ""
	else:
		current_input = input_history[input_history.size() - 1 - history_index]
	
	update_input_display()

func handle_tab_completion():
	if current_suggestions.size() > 0:
		suggestion_index = (suggestion_index + 1) % current_suggestions.size()
		var suggestion = current_suggestions[suggestion_index]
		
		# If the user has already typed part of the command, replace it
		var parts = current_input.strip_edges().split(" ", false)
		if parts.size() > 0:
			parts[0] = suggestion.command
			current_input = " ".join(parts)
		else:
			current_input = suggestion.command
		
		update_input_display()

func activate():
	if active:
		return
		
	active = true
	add_line("")
	add_line("Terminal activated. Type 'exit' to close.")
	update_display()
	
	emit_signal("terminal_activated")

func deactivate():
	if !active:
		return
		
	active = false
	add_line("")
	add_line("Terminal deactivated.")
	update_display()
	
	emit_signal("terminal_deactivated")

# Callback functions for combo system signals
func _on_combo_started(combo_name, description):
	add_line("> Started combo: " + combo_name + " - " + description)

func _on_combo_advanced(combo_name, next_stage, description):
	var status = combo_system.get_current_combo_status()
	add_line("> Combo " + combo_name + " step " + str(status.stage) + "/" + str(status.total_stages))

func _on_combo_completed(combo_name):
	add_line("> Completed combo: " + combo_name)

func _on_combo_broken(combo_name, reason):
	add_line("> Combo " + combo_name + " broken: " + reason)

# Function that will be called when the terminal receives interaction from outside
func handle_interaction(interactor = null):
	if !active:
		activate()
		return true
	
	return false

# Initialize the terminal system and create the terminal node
func initialize_terminal_system():
	if terminal_initialized:
		return
		
	print("Initializing JSH Terminal System")
	






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

#cmd
##
## cmd
# cmd
#

#
###
# Built-in command implementations
func _cmd_help(args = []) -> Dictionary:
	var output = "Available commands:\n"
	
	for cmd in command_registry.keys():
		output += "  " + cmd + "\n"
	
	# Include any additional system commands
	if main_system and main_system.has_method("get_system_commands"):
		var system_commands = main_system.get_system_commands()
		if system_commands.size() > 0:
			output += "\nSystem commands:\n"
			for cmd in system_commands:
				output += "  " + cmd + "\n"
	
	return {
		"success": true,
		"output": output
	}

func _cmd_clear(args = []) -> Dictionary:
	terminal_content.clear()
	add_welcome_message()
	
	return {
		"success": true,
		"output": ""
	}

func _cmd_history(args = []) -> Dictionary:
	if input_history.size() == 0:
		return {
			"success": true,
			"output": "Command history is empty."
		}
	
	var output = "Command history:\n"
	var count = min(20, input_history.size())
	
	for i in range(count):
		var idx = input_history.size() - 1 - i
		output += "  " + str(i+1) + ": " + input_history[idx] + "\n"
	
	return {
		"success": true,
		"output": output
	}

func _cmd_combos(args = []) -> Dictionary:
	var output = "Available command combos:\n"
	
	for pattern_idx in combo_system.terminal_command_patterns:
		var pattern = combo_system.terminal_command_patterns[pattern_idx]
		var combo_name = pattern[0][0]
		var commands = pattern[1]
		var description = combo_system.get_combo_description(combo_name)
		
		output += "  " + combo_name + ": " + " → ".join(commands) + "\n"
		output += "    " + description + "\n"
	
	output += "\nUse TAB key for command suggestions."
	
	return {
		"success": true,
		"output": output
	}

func _cmd_exit(args = []) -> Dictionary:
	deactivate()
	
	return {
		"success": true,
		"output": "Terminal session ended."
	}



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
		
		
# terminal

##
# terminal
## terminal

#
##

func setup_terminal_components():
	# Create terminal mesh
	terminal_mesh = MeshInstance3D.new()
	terminal_mesh.name = "TerminalMesh"
	add_child(terminal_mesh)
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(screen_width + 0.4, screen_height + 0.4, 0.1)
	terminal_mesh.mesh = box_mesh
	
	var terminal_material = StandardMaterial3D.new()
	terminal_material.albedo_color = Color(0.2, 0.2, 0.2)
	terminal_mesh.material_override = terminal_material
	
	# Create screen
	terminal_screen = MeshInstance3D.new()
	terminal_screen.name = "TerminalScreen"
	add_child(terminal_screen)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(screen_width, screen_height)
	terminal_screen.mesh = plane_mesh
	terminal_screen.position.z = 0.06
	
	var screen_material = StandardMaterial3D.new()
	screen_material.albedo_color = terminal_base_color
	screen_material.emission_enabled = true
	screen_material.emission = terminal_base_color
	screen_material.emission_energy = 0.5
	terminal_screen.material_override = screen_material
	
	# Create main text display
	terminal_text = Label3D.new()
	terminal_text.name = "TerminalText"
	add_child(terminal_text)
	
	terminal_text.font_size = 16
	terminal_text.modulate = terminal_text_color
#	terminal_text.text_alignment #= str(HORIZONTAL_ALIGNMENT_LEFT)
	terminal_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	terminal_text.width = screen_width * 25  # Scaled for visibility
	terminal_text.pixel_size = 0.01
	
	# Position slightly in front of screen
	terminal_text.position.z = 0.07
	terminal_text.position.x = -screen_width/2 + 0.2
	terminal_text.position.y = screen_height/2 - 0.2
	
	# Create input display line
	terminal_input = Label3D.new()
	terminal_input.name = "TerminalInput"
	add_child(terminal_input)
	
	terminal_input.font_size = 16
	terminal_input.modulate = terminal_highlight_color
#	terminal_input.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	terminal_input.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	terminal_input.width = screen_width * 25
	terminal_input.pixel_size = 0.01
	
	# Position at bottom of screen
	terminal_input.position.z = 0.07
	terminal_input.position.x = -screen_width/2 + 0.2
	terminal_input.position.y = -screen_height/2 + 0.4
	
	# Create status line
	terminal_status = Label3D.new()
	terminal_status.name = "TerminalStatus"
	add_child(terminal_status)
	
	terminal_status.font_size = 12
	terminal_status.modulate = status_color
#	terminal_status.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
	terminal_status.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	terminal_status.width = screen_width * 25
	terminal_status.pixel_size = 0.01
	
	# Position at bottom of screen below input
	terminal_status.position.z = 0.07
	terminal_status.position.x = -screen_width/2 + 0.2
	terminal_status.position.y = -screen_height/2 + 0.2
	
	# Set collision for interaction
	var static_body = StaticBody3D.new()
	static_body.name = "TerminalBody"
	add_child(static_body)
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "TerminalCollision"
	static_body.add_child(collision_shape)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(screen_width + 0.4, screen_height + 0.4, 0.2)
	collision_shape.shape = box_shape





func add_welcome_message():
	add_line("JSH Ethereal Terminal v1.0")
	add_line("Type 'help' for available commands")
	add_line("Type 'combos' to see available command combinations")
	add_line("")

func register_command(name: String, target, method: String):
	command_registry[name] = {
		"target": target,
		"method": method
	}






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓       •           ┓ 
#       888  `"Y8888o.   888ooooo888      ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┏┓┓    ┏
#       888      `"Y88b  888     888      ┻ ┗ ┣┛ ┃ ┗┗ ┛ ┗┻┗    ┛
#       888 oo     .d8P  888     888               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# use files

# paths and combos

# history too

# with commands like call function name
# call var name and set value
# we have nice console of entire script
# TrpTIeros}

## gd script uses {} for dictionaries # for comments
# in different places we have " ' // for comments to, starts and stopes, here is just ctrl k, to moccent out and /. to stop comment no dot needed
#########################

func register_with_jsh():
	# Register with JSH tree if available
	if main_node && main_node.has_method("create_new_task"):
		main_node.create_new_task("register_character", self)
		
		# Add to scene tree dictionary if that system exists
		if main_node.has_method("jsh_tree_get_node"):
			if main_node.scene_tree_jsh.has("main_root"):
				main_node.tree_mutex.lock()
				if !main_node.scene_tree_jsh["main_root"]["branches"].has("character"):
					main_node.scene_tree_jsh["main_root"]["branches"]["character"] = {
						"branch_name": "character",
						"branch_type": "entity",
						#"branch_position": global_position,
						"datapoint": null
					}
				main_node.tree_mutex.unlock()



func process_command(command: String) -> Dictionary:
	# Add command to history
	command_history.append(command)
	if command_history.size() > max_command_history:
		command_history.pop_front()
	
	# Process command for combo detection
	return check_combo_status(command)

# Check if command continues or starts a combo
func check_combo_status(command: String) -> Dictionary:
	var result = {
		"command": command,
		"is_combo": false,
		"combo_name": "",
		"stage": 0,
		"next_command": "",
		"description": "",
		"status": "none"  # none, started, continued, completed, broken
	}
	
	var cmd_normalized = command.strip_edges().to_lower()
	
	# If we have an active combo, check if this continues it
	if active_combo != null:
		var pattern = get_pattern_by_name(active_combo)
		
		if pattern:
			var commands = pattern[1]
			var expected_command = commands[combo_stage]
			
			if expected_command in cmd_normalized:
				# Command continues combo
				combo_stage += 1
				result.is_combo = true
				result.combo_name = active_combo
				result.stage = combo_stage
				result.status = "continued"
				
				# Check if combo is completed
				if combo_stage >= commands.size():
					result.status = "completed"
					emit_signal("combo_completed", active_combo)
					
					# Record the completed combo
					combo_history.append({
						"combo": active_combo,
						"timestamp": Time.get_ticks_msec(),
						"commands": command_history.slice(-combo_stage)
					})
					
					if combo_history.size() > max_combo_history:
						combo_history.pop_front()
					
					# Reset active combo
					var completed_combo = active_combo
					active_combo = null
					combo_stage = 0
					
					# Execute completion action
					execute_combo_action(completed_combo)
				else:
					# Combo continues
					result.next_command = commands[combo_stage]
					emit_signal("combo_advanced", active_combo, combo_stage, get_combo_description(active_combo))
			else:
				# Combo broken
				emit_signal("combo_broken", active_combo, "Expected '" + expected_command + "' but got '" + command + "'")
				result.status = "broken"
				
				# Reset active combo
				active_combo = null
				combo_stage = 0
				
				# Check if this command starts a new combo
				var new_combo = find_starting_combo(cmd_normalized)
				if new_combo:
					set_active_combo(new_combo, result)
	else:
		# Check if this command starts a new combo
		var new_combo = find_starting_combo(cmd_normalized)
		if new_combo:
			set_active_combo(new_combo, result)
	
	return result

# Set a new active combo and update the result dictionary
func set_active_combo(combo_name: String, result: Dictionary) -> void:
	active_combo = combo_name
	combo_stage = 1
	
	result.is_combo = true
	result.combo_name = combo_name
	result.stage = combo_stage
	result.status = "started"
	
	var pattern = get_pattern_by_name(combo_name)
	if pattern:
		var commands = pattern[1]
		if combo_stage < commands.size():
			result.next_command = commands[combo_stage]
		result.description = get_combo_description(combo_name)
	
	emit_signal("combo_started", combo_name, result.description)

# Find if a command starts a new combo
func find_starting_combo(command: String) -> String:
	for pattern_idx in terminal_command_patterns:
		var pattern = terminal_command_patterns[pattern_idx]
		var commands = pattern[1]
		
		if commands.size() > 0 and commands[0] in command:
			return pattern[0][0]
	
	return ""

# Get pattern data by combo name
func get_pattern_by_name(combo_name: String):
	for pattern_idx in terminal_command_patterns:
		var pattern = terminal_command_patterns[pattern_idx]
		if pattern[0][0] == combo_name:
			return pattern
	
	return null

# Get combo description
func get_combo_description(combo_name: String) -> String:
	var pattern = get_pattern_by_name(combo_name)
	if pattern and pattern.size() > 2:
		return pattern
	return "No description available"

# Execute action when combo is completed
func execute_combo_action(combo_name: String) -> void:
	print("Executing combo action for: " + combo_name)
	
	if main_system:
		# Use your existing dimensional magic system to execute the combo
		main_system.sixth_dimensional_magic("call_function", self, "execute_combo_" + combo_name)

# Combo execution methods - You can customize these based on your needs
func execute_combo_file_ops():
	print("Executing file operations combo")
	# Implement files operations sequence

func execute_combo_search_system():
	print("Executing search system combo")
	# Implement search sequence

func execute_combo_git_workflow():
	print("Executing git workflow combo")
	# Implement git workflow sequence

func execute_combo_backup_sequence():
	print("Executing backup sequence combo")
	# Implement backup sequence

func execute_combo_analyze_report():
	print("Executing analyze and report combo")
	# Implement analysis sequence

func execute_combo_system_check():
	print("Executing system check combo")
	# Implement system check sequence

# Get suggestions for command completion
func get_suggestions(partial_command: String = "") -> Array:
	var suggestions = []
	
	if active_combo:
		var pattern = get_pattern_by_name(active_combo)
		if pattern:
			var commands 
	else:

		for pattern_idx in terminal_command_patterns:
			var pattern = terminal_command_patterns[pattern_idx]
			var commands = pattern[1]
			
			if commands.size() > 0:
				suggestions.append({
					"command": commands[0],
					"description": "Start " + pattern[0][0] + " combo: " + get_combo_description(pattern[0][0])
				})
	
	return suggestions

# Reset the combo state
func reset_combo_state():
	active_combo = null
	combo_stage = 0

# Get the current combo status
func get_current_combo_status() -> Dictionary:
	if active_combo == null:
		return {
			"active": false,
			"name": "",
			"stage": 0,
			"total_stages": 0
		}
	
	var pattern = get_pattern_by_name(active_combo)
	var total_stages = 0
	
	
	return {
		"active": true,
		"name": active_combo,
		"stage": combo_stage,
		"total_stages": total_stages,
		"description": get_combo_description(active_combo),
	
	}

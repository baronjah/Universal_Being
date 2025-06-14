
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

extends Control
class_name JSHConsoleUI

# res://code/gdscript/scripts/Text_Console_Window/console_window_ui.gd

####################
#
# JSH Console UI
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Console UI
#
####################

var window_mesh
var Position3D
var current_command_new := ""
var history_position_new_new := -1
var text_container_new: Node3D
var command_line_new: Node3D
var delimiter_mesh_new: MeshInstance3D
var thread_pool_new = null
var camera_new = null

signal console_submitted(text)
signal console_closed
signal console_opened

@onready var panel = $Panel
@onready var input_field = $Panel/VBox/InputField
@onready var output_text = $Panel/VBox/OutputScroll/OutputText
@onready var submit_button = $Panel/VBox/HBox/SubmitButton
@onready var clear_button = $Panel/VBox/HBox/ClearButton
@onready var close_button = $Panel/VBox/HBox/CloseButton
@onready var scroll_container = $Panel/VBox/OutputScroll

var drag_position = null
var console_history = []
var history_position = -1
var max_history = 100

# Terminal state
var terminal_text := []
var floating_words := {}
var current_command := ""
var command_history := []
var history_position_new := -1

# Visual components
var text_container: Node3D
var command_line: Node3D
var anchor_points := []
var delimiter_mesh: MeshInstance3D

# References
var thread_pool = null
var camera = null

var center_point := Vector3.ZERO
var time_accumulator := 0.0
var command_mode := "terminal"  # terminal, grid, shape
var connection_lines := []
var word_network := {}
var active_words := []
var combo_rules := {}
var combo_active := []

var grid_container: Node3D
var shape_container: Node3D
var delimiter_meshes := []
var shape_transforms := ["sphere", "cube", "flat", "helix", "wave", "spiral"]
var current_shape := "flat"

# Grid viewer properties
var grid_size := Vector3i(10, 10, 10)
var grid_cell_size := 0.5
var grid_data := {}
var grid_position := Vector3.ZERO
var grid_rotation := Vector3.ZERO
var grid_scale := Vector3.ONE
var grid_cursor_pos := Vector3i.ZERO
var grid_cells := []
var grid_highlight_new_v1 = null

# Shape viewer properties 
var current_primitive := "sphere"
var primitive_params := {"radius": 1.0, "size": Vector2(1.0, 1.0)}
var primitive_mesh: MeshInstance3D
var primitive_resolution := 32
var primitive_color := Color(0.2, 0.6, 1.0)

var material_cache := {}


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

var theme_colors = {
	"background": Color(0.1, 0.1, 0.1, 0.9),
	"text": Color(0.9, 0.9, 0.9),
	"command": Color(0.4, 0.7, 1.0),
	"error": Color(1.0, 0.3, 0.3),
	"warning": Color(1.0, 0.9, 0.2),
	"success": Color(0.2, 1.0, 0.3),
	"info": Color(0.8, 0.8, 0.8),
	"timestamp": Color(0.5, 0.5, 0.5)
}

var config := {
	"letter_scale": 0.1,
	"word_radius": 2.0,
	"time_phase": 0.0,
	"anchor_points": 8,
	"max_visible_lines": 12,
	"line_spacing": 0.5,
	"char_spacing": 0.15,
	"floating_animation": true,
	"delimiter": "|"
}

var config_new := {
	"letter_scale": 0.1,
	"word_radius": 2.0,
	"time_phase": 0.0,
	"anchor_points": 8,
	"max_visible_lines": 12,
	"line_spacing": 0.5,
	"char_spacing": 0.15,
	"floating_animation": true,
	"delimiter": "|"
}

var config_new_v1 := {
	"letter_scale": 0.1,
	"word_radius": 2.0,
	"max_visible_lines": 16,
	"line_spacing": 0.5,
	"char_spacing": 0.15,
	"delimiter": "|",
	"max_distance_value": 5.0,
	"pulse_speed": 0.5,
	"float_amount": 0.05,
	"shape_morph_time": 3.0,
	"connection_distance": 0.8,  # Maximum distance for word connections
	"connection_color": Color(0.3, 0.6, 1.0, 0.4)  # Color for connections
}

var sdf_primitives := {
	"sphere": "length(p) - radius",
	"box": "length(max(abs(p)-size,0.0))",
	"torus": "length(vec2(length(p.xz)-radius,p.y))-thickness",
	"line": "length(p-a*clamp(dot(p,a)/dot(a,a),0.0,1.0))",
	"plane": "dot(p,normal) - distance",
	"capsule": "length(p-a*clamp(dot(p,a)/dot(a,a),0.0,1.0)) - radius",
	"cylinder": "length(p.xz) - radius"
}



# terminal_manager.gd
# This would be a new script file that handles terminal functionality
#
#extends Node3D
#class_name TerminalManager

# References to important nodes
var terminal_container : Node3D
var terminal_output : Node3D  # The text_mesh for output
var terminal_input : Node3D   # The text element for input
var terminal_cursor : Node3D  # Visual cursor element

# Command history
var command_historyy = []
var history_positionn = -1
var max_historyy = 20

# Terminal state
var current_commandd = ""
var output_textt = "Console Ready...\n"
var cursor_visible = true
var cursor_blink_timer = 0
var cursor_blink_rate = 0.5

# Available commands and their descriptions
var available_commands = {
	"help": "Show list of available commands",
	"clear": "Clear terminal output",
	"history": "Show command history",
	"echo": "Display text (usage: echo [text])",
	"list": "List available objects/things",
	"create": "Create a new thing (usage: create [type] [name])",
	"delete": "Delete a thing (usage: delete [name])",
	"connect": "Connect two things (usage: connect [thing1] [thing2])",
	"show": "Show a container (usage: show [container_name])",
	"hide": "Hide a container (usage: hide [container_name])",
	"load": "Load a scene (usage: load [scene_name])",
	"unload": "Unload a scene (usage: unload [scene_name])",
	"exit": "Close the terminal"
}




















# terminal_manager.gd
# Create a new script file with this code

#extends Node3D
#class_name TerminalManager

# References to important nodes
var terminal_containerr : Node3D
var output_text_mesh : Node3D  # The text_mesh for output (thing_306)
var input_text : Node3D        # The input text element (thing_309)
var cursor : Node3D            # Visual cursor element (thing_310)
var status_text : Node3D       # Status bar text (thing_318)
var memory_text : Node3D       # Memory usage display (thing_319)

# Current scene data
var current_scene_id : int = 0

# Command history
var command_historyyy = []
var history_positionnn = -1
var max_historyt = 30

# Terminal state
var current_commanddd = ""
var output_texttt = "JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>"
var cursor_visibleee = true
var cursor_blink_timerrrr= 0
var cursor_blink_ratee = 0.5
var cursor_base_position = Vector3(-7.25, -4.0, 0.25)
var char_width = 0.15  # Approximate width of each character

# Available commands with descriptions
var available_commandssss = {
	"help": "Show list of available commands",
	"clear": "Clear terminal output",
	"history": "Show command history",
	"echo": "Display text (usage: echo [text])",
	"list": "List available objects/things",
	"create": "Create a new thing (usage: create [type] [name])",
	"delete": "Delete a thing (usage: delete [name])",
	"connect": "Connect two things (usage: connect [thing1] [thing2])",
	"show": "Show a container (usage: show [container_name])",
	"hide": "Hide a container (usage: hide [container_name])",
	"move": "Move an object (usage: move [name] [x,y,z])",
	"rotate": "Rotate an object (usage: rotate [name] [x,y,z])",
	"load": "Load a scene (usage: load [scene_name])",
	"unload": "Unload a scene (usage: unload [scene_name])",
	"find": "Search for objects (usage: find [query])",
	"status": "Display system status",
	"mem": "Show memory usage",
	"set": "Set a variable (usage: set [name] [value])",
	"get": "Get a variable value (usage: get [name])",
	"run": "Execute a script file (usage: run [filename])",
	"exit": "Close the terminal"
}

# Variables that can be set/get
var terminal_variables = {
	"prompt": ">",
	"color": "blue",
	"cursor_rate": "0.5",
	"max_history": "30",
	"debug": "false"
}

func _ready():
	# Initialize terminal
	# Actual node references would be set up when this manager is attached to the scene
	# For now we'll just set up placeholders
	
	# In a real implementation, you would find these nodes from your scene tree:
	# terminal_container = get_node("terminal_container")
	# output_text_mesh = terminal_container.find_node("thing_306")
	# input_text = terminal_container.find_node("thing_309")
	# cursor = terminal_container.find_node("thing_310")
	# status_text = terminal_container.find_node("thing_318")
	# memory_text = terminal_container.find_node("thing_319")
	
	update_output_display()
	update_input_display()
	update_status("Ready")
	update_memory_display(100)

func _process(delta):
	# Handle cursor blinking
	cursor_blink_timer += delta
	if cursor_blink_timer >= cursor_blink_rate:
		cursor_blink_timer = 0
		cursor_visible = !cursor_visible
		update_cursor()

func update_cursor():
	# Update cursor visibility and position based on input text length
	if cursor:
		cursor.visible = cursor_visible
		
		# Calculate cursor position based on text length
		var text_length = current_command.length()
		var offset = Vector3(text_length * char_width, 0, 0)
		cursor.position = cursor_base_position + offset

func update_input_display():
	# Update the input text
	if input_text:
		input_text.text = current_command
		update_cursor()

func update_output_display():
	# Update the output text mesh
	if output_text_mesh:
		# This might need to be adapted to your text_mesh implementation
		output_text_mesh.text = output_text

func update_status(status: String):
	# Update status bar text
	if status_text:
		status_text.text = status

func update_memory_display(percentage: int):
	# Update memory usage display
	if memory_text:
		memory_text.text = "MEM: " + str(percentage) + "%"

# Called when a key is pressed in the connected keyboard
func handle_key_input(key: String):
	if key == "return":
		execute_command()
	elif key == "undo":
		if current_command.length() > 0:
			current_command = current_command.substr(0, current_command.length() - 1)
	else:
		# Only add printable characters
		if key.length() == 1 or key == " ":
			current_command += key
	
	update_input_display()

# Navigate command history up (older commands)
func history_up():
	if command_history.size() > 0 and history_position < command_history.size() - 1:
		history_position += 1
		current_command = command_history[command_history.size() - 1 - history_position]
		update_input_display()

# Navigate command history down (newer commands)
func history_down():
	if history_position > 0:
		history_position -= 1
		current_command = command_history[command_history.size() - 1 - history_position]
	elif history_position == 0:
		history_position = -1
		current_command = ""
	
	update_input_display()

func execute_command():
	var command_to_execute = current_command.strip_edges()
	
	# Add command to history if not empty
	if command_to_execute != "":
		command_history.push_back(command_to_execute)
		if command_history.size() > int(terminal_variables["max_history"]):
			command_history.pop_front()
	
	# Display command in output
	output_text += terminal_variables["prompt"] + " " + command_to_execute + "\n"
	
	# Process command
	process_command(command_to_execute)
	
	# Reset input and update displays
	current_command = ""
	history_position = -1
	update_output_display()
	update_input_display()

func process_command(command_text: String):
	# Change to processing scene
	#change_to_scene(3)
	update_status("Processing...")
	update_memory_display(92)
	
	# Process the command
	var command_parts = command_text.strip_edges().split(" ", false)
	var base_command = command_parts[0].to_lower() if command_parts.size() > 0 else ""
	
	match base_command:
		#"help":
		#	show_help(command_parts)
		"clear":
			clear_terminal()
		"history":
			show_command_history()
		"echo":
			if command_parts.size() > 1:
				var echo_text = command_text.substr(command_text.find(" ") + 1)
				output_text += echo_text + "\n"
			else:
				output_text += "Usage: echo [text]\n"
		#"list":
		#	list_things(command_parts)
		"create":
			if command_parts.size() >= 3:
				create_thing(command_parts[1], command_parts[2])
			#else:



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

func _processs(delta):
	process_floating_text(delta)
	
	# Make terminal face camera
	if camera:
		var camera_pos = camera.global_position
		camera_pos.y = global_position.y  # Keep y level the same
		look_at(camera_pos, Vector3.UP)
		#rotation.z = 0  # Keep upright

func _init():
	name = "JSH_3D_text_terminal"

func _readyy():
	# Initialize UI
	setup_ui_appearance()
	setup_signals()
	
	# Hide console initially
	visible = false
	
	# Make panel slightly transparent
	panel.self_modulate = theme_colors.background
	
	add_startup_message()
	

func _input(event):
	# Handle dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if click is in the drag area (top of panel)
				var drag_rect = Rect2(panel.position, Vector2(panel.size.x, 30))
				if drag_rect.has_point(event.position):
					drag_position = event.position - panel.position
			else:
				drag_position = null
	
	# Move console when dragging
	if event is InputEventMouseMotion and drag_position != null:
		panel.position = event.position - drag_position
		
	# Handle history navigation
	if visible and input_field.has_focus():
		if event.is_action_pressed("ui_up") and console_history.size() > 0:
			navigate_history(-1)
		elif event.is_action_pressed("ui_down") and history_position >= 0:
			navigate_history(1)



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

##
func _ready_new():
	setup_terminal_container()
	setup_delimiter_mesh()
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	add_test_text()

# create mesh too maybe one time
func _process_new(delta):
	process_floating_text(delta)
	
	# Make terminal face camera
	if camera:
		var camera_pos = camera.global_position
		camera_pos.y = global_position.y  # Keep y level the same
		look_at(camera_pos, Vector3.UP)
		window_mesh.rotation.z = 0  # Keep upright
##
func _input_new(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			execute_command()
		elif event.keycode == KEY_BACKSPACE:
			remove_command_character()
		elif event.keycode == KEY_UP:
			navigate_history(-1)
		elif event.keycode == KEY_DOWN:
			navigate_history(1)
		elif event.unicode >= 32 and event.unicode <= 126:  # Printable ASCII
			add_command_character(char(event.unicode))
#

func _init_old():
	name = "JSH_3D_terminal"
	
func _ready_old():
	setup_containers()
	setup_material_cache()
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	
	# Setup combo rules
	setup_combo_rules()
	
	# Initial grid setup
	setup_grid()
	grid_container.visible = false
	
	# Initial shape setup
	setup_shape_viewer()
	shape_container.visible = false
	
	# Add welcome message
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")






func _readyyy():
	# Find references to the needed nodes
	# This would depend on your scene setup, could use get_node or find_node
	# terminal_container = get_node("terminal_container")
	# terminal_output = terminal_container.get_node("thing_203")
	# terminal_input = terminal_container.get_node("thing_205")
	# terminal_cursor = terminal_container.get_node("thing_211")
	
	# Initialize terminal
	update_output_display()
	update_input_display()

func _processss(delta):
	# Handle cursor blinking
	cursor_blink_timer += delta
	if cursor_blink_timer >= cursor_blink_rate:
		cursor_blink_timer = 0
		cursor_visible = !cursor_visible
		update_cursor()

func update_cursorr():
	# Update cursor visibility based on blink state
	if terminal_cursor:
		terminal_cursor.visible = cursor_visible

func update_input_displayyt():
	# Update the input text with current command
	if terminal_input:
		terminal_input.text = "> " + current_command

func update_output_displayty():
	# Update the output text mesh with current output text
	if terminal_output:
		# This might need to be adapted to your text_mesh implementation
		terminal_output.text = output_text

# Called when a key is pressed in the connected keyboard
func handle_key_inputt(key: String):
	if key == "return":
		execute_command()
	elif key == "undo":
		if current_command.length() > 0:
			current_command = current_command.substr(0, current_command.length() - 1)
	elif key == "up":
		navigate_history_up()
	elif key == "down":
		navigate_history_down()
	else:
		current_command += key
	
	update_input_display()

func navigate_history_up():
	if command_history.size() > 0 and history_position < command_history.size() - 1:
		history_position += 1
		current_command = command_history[command_history.size() - 1 - history_position]

func navigate_history_down():
	if history_position > 0:
		history_position -= 1
		current_command = command_history[command_history.size() - 1 - history_position]
	elif history_position == 0:
		history_position = -1
		current_command = ""

func execute_commandd():
	# Add command to history
	if current_command.strip_edges() != "":
		command_history.push_back(current_command)
		if command_history.size() > max_history:
			command_history.pop_front()
	
	# Display command in output
	output_text += "> " + current_command + "\n"
	
	# Process command
	var command_parts = current_command.strip_edges().split(" ", false)
	var base_command = command_parts[0].to_lower() if command_parts.size() > 0 else ""
	
	match base_command:
		"help":
			show_help()
		"clear":
			clear_terminal()
		"history":
			show_command_history()
		"echo":
			if command_parts.size() > 1:
				var echo_text = current_command.substr(current_command.find(" ") + 1)
				output_text += echo_text + "\n"
			else:
				output_text += "Usage: echo [text]\n"
		"list":
			list_things()
		"create":
			if command_parts.size() >= 3:
				create_thing(command_parts[1], command_parts[2])
			else:
				output_text += "Usage: create [type] [name]\n"
		"delete":
			if command_parts.size() >= 2:
				delete_thing(command_parts[1])
			else:
				output_text += "Usage: delete [name]\n"
		"connect":
			if command_parts.size() >= 3:
				connect_things(command_parts[1], command_parts[2])
			else:
				output_text += "Usage: connect [thing1] [thing2]\n"
		"show":
			if command_parts.size() >= 2:
				show_container(command_parts[1])
			else:
				output_text += "Usage: show [container_name]\n"
		"hide":
			if command_parts.size() >= 2:
				hide_container(command_parts[1])
			else:
				output_text += "Usage: hide [container_name]\n"
		"load":
			if command_parts.size() >= 2:
				load_scene(command_parts[1])
			else:
				output_text += "Usage: load [scene_name]\n"
		"unload":
			if command_parts.size() >= 2:
				unload_scene(command_parts[1])
			else:
				output_text += "Usage: unload [scene_name]\n"
		"exit":
			close_terminal()
		"":
			pass # Empty command, do nothing
		_:
			output_text += "Unknown command: " + base_command + "\n"
	
	# Reset input and update displays
	current_command = ""
	history_position = -1
	update_output_display()
	update_input_display()

func show_help():
	output_text += "Available commands:\n"
	for cmd in available_commands:
		output_text += "  " + cmd + " - " + available_commands[cmd] + "\n"

func clear_terminal():
	output_text = "Console Ready...\n"

func show_command_history():
	if command_history.size() > 0:
		output_text += "Command history:\n"
		for i in range(command_history.size()):
			output_text += "  " + str(i+1) + ": " + command_history[i] + "\n"
	else:
		output_text += "No command history.\n"

func list_things():
	# This would need to be customized based on your game's object system
	output_text += "Available things:\n"
	# Example: Loop through your RecordsBank records
	# for thing_id in RecordsBank.records_map_0:
	#     var thing_data = RecordsBank.records_map_0[thing_id]
	#     output_text += "  " + thing_data[0][0] + "\n"

func create_thing(type: String, name: String):
	# Interface with your game's object creation system
	output_text += "Creating " + type + " with name " + name + "...\n"
	# Implementation would depend on your game's architecture

func delete_thing(name: String):
	# Interface with your game's object deletion system
	output_text += "Deleting " + name + "...\n"
	# Implementation would depend on your game's architecture

func connect_things(thing1: String, thing2: String):
	# Interface with your game's object connection system
	output_text += "Connecting " + thing1 + " to " + thing2 + "...\n"
	# Implementation would depend on your game's architecture

func show_container(container_name: String):
	# Show a container
	output_text += "Showing container " + container_name + "...\n"
	# Implementation would depend on your game's architecture

func hide_container(container_name: String):
	# Hide a container
	output_text += "Hiding container " + container_name + "...\n"
	# Implementation would depend on your game's architecture

func load_scene(scene_name: String):
	# Load a scene
	output_text += "Loading scene " + scene_name + "...\n"
	# Implementation would depend on your game's architecture

func unload_scene(scene_name: String):
	# Unload a scene
	output_text += "Unloading scene " + scene_name + "...\n"
	# Implementation would depend on your game's architecture

func close_terminal():
	# Close the terminal
	output_text += "Closing terminal...\n"
	update_output_display()
	# Implementation would depend on your game's architecture
	# Might call something like:
	# get_tree().call_group("game_manager", "change_scene", "scene_2")

#
## from here we make new things,
# we understand things mostly
# remember what was global and where we went
#
# input, process, readdy are magic
# machine, we need them like commands and repeats too



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# setup grid of pixel
# position direction perspective
# scale width height window



func setup_grid():
	print("setup grid")


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# shape of window square rectangle
# rotation position transform change
# process updtade run create change




func setup_shape_viewer():
	print("setup shape viewer")



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# we had few in previous scripts that worked
# look at with horizontal gimbal gyroscole and compas from one piece
# in 3d we can add visual representation in automation with number


func look_at(data, data_0):
	print(" data", data)



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# integration of console terminal window with
# keyboard string data change
# file bank path code script segment

func setup_containers():
	# Text container
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Command line
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	text_container.add_child(command_line)
	
	# Grid container
	grid_container = Node3D.new()
	grid_container.name = "grid_container"
	grid_container.position = Vector3(0, 0, -8)
	add_child(grid_container)
	
	# Shape container
	shape_container = Node3D.new()
	shape_container.name = "shape_container"
	shape_container.position = Vector3(0, 0, -8)
	add_child(shape_container)
	
	# Create delimiter mesh prototype
	var delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_prototype"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	delimiter_mesh.visible = false
	add_child(delimiter_mesh)



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# amounts number counting folding form connect
# scaffolding fold unfold create shift code
# recalibrate calibrate connect change connections

func setup_material_cache():
	# Create some standard materials for reuse
	var base_mat = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.8, 0.8, 0.8)
	base_mat.metallic = 0.2
	base_mat.roughness = 0.3
	material_cache["default"] = base_mat
	
	var highlight_mat = StandardMaterial3D.new()
	highlight_mat.albedo_color = Color(0.2, 0.8, 1.0)
	highlight_mat.emission_enabled = true
	highlight_mat.emission = Color(0.2, 0.6, 1.0)
	highlight_mat.emission_energy = 0.5
	material_cache["highlight"] = highlight_mat
	
	var grid_mat = StandardMaterial3D.new()
	grid_mat.albedo_color = Color(0.2, 0.2, 0.3, 0.5)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["grid"] = grid_mat
	
	var connection_mat = StandardMaterial3D.new()
	connection_mat.albedo_color = config.connection_color
	connection_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["connection"] = connection_mat
	
	# Create materials for each shape transform
	for shape in shape_transforms:
		var shape_mat = StandardMaterial3D.new()
		
		match shape:
			"sphere":
				shape_mat.albedo_color = Color(0.2, 0.6, 1.0)
			"cube": 
				shape_mat.albedo_color = Color(0.8, 0.3, 0.9)
			"flat":
				shape_mat.albedo_color = Color(0.3, 0.8, 0.4)
			"helix":
				shape_mat.albedo_color = Color(1.0, 0.6, 0.2)
			"wave":
				shape_mat.albedo_color = Color(0.8, 0.8, 0.2)
			"spiral":
				shape_mat.albedo_color = Color(0.9, 0.2, 0.4)
				
		shape_mat.emission_enabled = true
		shape_mat.emission = shape_mat.albedo_color
		shape_mat.emission_energy = 0.3
		material_cache[shape] = shape_mat


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# combo segments functions name cycle process task schedule
# call set get reparent move rotate position time thread
# local global move add create change loop delta turn c#

func setup_combo_rules():
	# Define which word combinations have special effects
	combo_rules = {
		"sphere|grid": "Creates a sphere in the grid",
		"box|grid": "Creates a box in the grid",
		"wave|terminal": "Applies wave effect to all text",
		"spiral|text": "Arranges text in a spiral pattern",
		"connect|words": "Creates connections between words",
		"light|dark": "Toggles terminal lighting mode",
		"3d|2d": "Toggles dimension mode"
	}


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P


func create_delimiter_instance(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# console window lines amount of lines
# amounts of words commands strings data
# files names shapes numbers int float value

func add_text_line(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Process for keyword matches
	process_keywords(text)
	
	# Check for combo activations
	check_combos(text)
	
	# Reposition existing lines
	reposition_text_lines()
	
	# Update connections
	update_word_connections()


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# record scene amounts positions local global
# path container code script file parent node child
# get set call functions magic word function_name

func create_floating_text(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	text_container.add_child(text_node)
	text_node.position = position
	
	# Words separated by the delimiter
	var words = text.split(config.delimiter, false)
	var letter_nodes = []
	var word_nodes = []
	var all_letters = []
	
	var x_offset = 0.0
	
	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_node = Node3D.new()
		word_node.name = "word_" + str(word_idx)
		text_node.add_child(word_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			word_node.add_child(letter)
			
			# Store the letter's word for connection building
			letter.set_meta("word", word)
			letter.set_meta("word_idx", word_idx)
		
		# Store word in the network
		if not word_network.has(word):
			word_network[word] = {
				"occurrences": 0,
				"connections": [],
				"last_position": word_node.global_position
			}
		word_network[word].occurrences += 1
		word_network[word].last_position = word_node.global_position
		
		# Check if this is a known word to highlight
		if word in active_words:
			for letter_node in letter_nodes:
				var text_mesh = letter_node.get_meta("text_mesh")
				text_mesh.modulate = Color(0.4, 0.8, 1.0)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = create_delimiter_instance(Vector3(word.length() * config.char_spacing + 0.1, 0, 0))
			word_node.add_child(delim)
			delimiter_meshes.append(delim)
			x_offset += word.length() * config.char_spacing + 0.3
		else:
			x_offset += word.length() * config.char_spacing
	
	# Store reference and metadata
	floating_words[text] = {
		"node": text_node,
		"words": word_nodes,
		"letters": letter_nodes,
		"all_letters": all_letters,
		"position": position,
		"creation_time": Time.get_ticks_msec() / 1000.0,
		"shape": current_shape,
		"words_text": words
	}
	
	return text_node



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# words split too to word
# s un o i e a on u y
# start is end

func create_3d_letter(letter: String, position: Vector3) -> Node3D:
	var letter_container = Node3D.new()
	letter_container.position = position
	
	# Create both visual representations
	var text_mesh = Label3D.new()
	text_mesh.text = letter
	text_mesh.font_size = 64
	text_mesh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_mesh.no_depth_test = true
	text_mesh.scale = Vector3.ONE * config.letter_scale
	letter_container.add_child(text_mesh)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	letter_container.add_child(cube)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# words fold into dust with water and rivers
# terraform planet earth today
# with moon that is like magnes

func remove_floating_word(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		
		# Remove any connections to this word
		clean_word_connections(text)
		
		word_data.node.queue_free()
		floating_words.erase(text)


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# terraform over time with start and end of time to move in time
# combo command cmd Console 
# record scene action interaction istruction bank banks Bank Combine banks_combiner gd code script

func clean_word_connections(text_key: String):
	# Remove connections associated with this text
	for i in range(connection_lines.size()-1, -1, -1):
		if connection_lines[i].has_meta("source") and connection_lines[i].get_meta("source") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)
			
		elif connection_lines[i].has_meta("target") and connection_lines[i].get_meta("target") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# move it around in set limits and zones auras areas
# combine them like nodes and paths
# names nodes

func reposition_text_lines():
	var line_pos = Vector3(0, 0, 0)
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)

func update_letter_visuals():
	var time = Time.get_ticks_msec() / 1000.0
	
	for text in floating_words:
		var word_data = floating_words[text]
		var letters = word_data.all_letters
		var creation_time = word_data.creation_time
		var age = time - creation_time
		
		# Determine if we should change shape
		if int(age / config.shape_morph_time) % shape_transforms.size() != int((age - time_accumulator) / config.shape_morph_time) % shape_transforms.size():
			# Shape change triggered
			word_data.shape = shape_transforms[int(age / config.shape_morph_time) % shape_transforms.size()]
		
		# Process each letter
		for i in range(letters.size()):
			var letter_node = letters[i]
			var text_mesh = letter_node.get_meta("text_mesh")
			var cube = letter_node.get_meta("cube")
			var base_pos = letter_node.get_meta("base_position")
			
			# Calculate distance from center point
			var global_pos = letter_node.global_position
			var distance = global_pos.distance_to(center_point)
			var normalized_distance = clamp(distance / config.max_distance_value, 0, 1)
			letter_node.set_meta("distance_factor", normalized_distance)
			
			# Special case for active combos - override normal visuals
			var is_special = false
			if letter_node.has_meta("word") and letter_node.get_meta("word") in active_words:
				is_special = true
				text_mesh.modulate = Color(0.3, 0.8, 1.0)
				if cube.material_override:
					cube.material_override.albedo_color = Color(0.3, 0.8, 1.0)
					cube.material_override.emission = Color(0.3, 0.8, 1.0)
					cube.material_override.emission_energy = 0.8 + 0.2 * sin(time * 2.0)
			
			if not is_special:
				# Apply grayscale based on distance
				var gray_value = 1.0 - normalized_distance
				text_mesh.modulate = Color(gray_value, gray_value, gray_value)
				
				if cube.material_override:
					cube.material_override.albedo_color = Color(gray_value, gray_value, gray_value)
					cube.material_override.emission_energy = 0.5 + (gray_value * 0.5)
			
			# Apply different spatial arrangements based on the current shape
			var offset = Vector3.ZERO
			match word_data.shape:
				"sphere":
					var angle1 = (i / float(letters.size())) * 2 * PI
					var angle2 = sin(time * config.pulse_speed + i * 0.1) * 0.5
					offset = Vector3(
						cos(angle1) * sin(angle2) * config.word_radius,
						sin(angle1) * sin(angle2) * config.word_radius,
						cos(angle2) * config.word_radius * 0.5
					)
				"cube":
					var edge_length = pow(letters.size(), 1.0/3.0)
					var x = (i % int(edge_length)) - edge_length/2
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2
					var z = (i / int(edge_length * edge_length)) - edge_length/2
					offset = Vector3(x, y, z) * config.letter_scale * 10
				"helix":
					var angle = (i / float(letters.size())) * 6 * PI + time * config.pulse_speed
					var height = (i / float(letters.size()) - 0.5) * 2
					offset = Vector3(
						cos(angle) * config.word_radius,
						height * config.word_radius,
						sin(angle) * config.word_radius
					)
				"wave":
					var wave = sin(time * config.pulse_speed + i * 0.5) * config.float_amount
					offset = Vector3(0, wave, 0)
				"spiral":
					var angle = (i / float(letters.size())) * 10 * PI
					var radius = (i / float(letters.size())) * config.word_radius * 2
					offset = Vector3(
						cos(angle) * radius,
						(i / float(letters.size()) - 0.5) * config.word_radius,
						sin(angle) * radius
					)
				"flat":
					# Default position with slight floating
					var float_y = sin(time * config.pulse_speed + i * 0.2) * config.float_amount
					offset = Vector3(0, float_y, 0)
			
			# Update position with the calculated offset
			letter_node.position = base_pos + offset
			
			# Add a small random jitter
			var jitter = Vector3(
				(sin(time * 3.1 + i * 7.3) * 2 - 1) * 0.01,
				(sin(time * 2.7 + i * 6.9) * 2 - 1) * 0.01,
				(sin(time * 2.3 + i * 8.1) * 2 - 1) * 0.01
			)
			letter_node.position += jitter


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

# amounts of points of scene we made it once start
# things connect with ends we will create it again is
# npcs too starts maybe we will definitely do it again end


func update_word_connections():
	# Clean up old connections first
	for line in connection_lines:
		line.queue_free()
	connection_lines.clear()
	
	# Only build connections if we have active combos
	if active_words.size() < 2:
		return
	
	# Find and connect words that are part of active combos
	for text in floating_words:
		var word_data = floating_words[text]
		var words = word_data.words_text
		
		for i in range(words.size()):
			if words[i] in active_words:
				# Find this word's potential connections
				for other_text in floating_words:
					if text == other_text:
						continue
						
					var other_data = floating_words[other_text]
					var other_words = other_data.words_text
					
					for j in range(other_words.size()):
						if other_words[j] in active_words and words[i] != other_words[j]:
							# Create connection between these words
							create_word_connection(
								text, i, other_text, j,
								word_data.node.global_position + word_data.words[i].position,
								other_data.node.global_position + other_data.words[j].position
							)



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888  
#       888  `"Y8888o.   888ooooo888  
#       888      `"Y88b  888     888 
#       888 oo     .d8P  888     888   
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P

func create_word_connection(text1: String, word_idx1: int, text2: String, word_idx2: int, 
						   global_pos1: Vector3, global_pos2: Vector3):
	# Create a line between the two words
	var line = MeshInstance3D.new()
	line.name = "connection_line"
	
	# Create the mesh - a thin cylinder oriented between the points
	var mesh = CylinderMesh.new()
	var length = global_pos1.distance_to(global_pos2)
	mesh.height = length
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	
	line.mesh = mesh
	line.material_override = material_cache.connection
	
	# Position and orient the line
	var midpoint = (global_pos1 + global_pos2) / 2
	line.global_position = midpoint
	
	# Look at target
	var direction = global_pos2 - global_pos1
	if direction.length() > 0.001:
		var up_vector = Vector3.UP
		if abs(direction.normalized().dot(up_vector)) > 0.99:
			up_vector = Vector3.FORWARD
		line.look_at_from_position(midpoint, global_pos2, up_vector)
		
	# Rotate to align with cylinder orientation
	line.rotate_object_local(Vector3.RIGHT, PI/2)
	
	# Store metadata
	line.set_meta("source", text1)
	line.set_meta("source_word_idx", word_idx1)
	line.set_meta("target", text2) 
	line.set_meta("target_word_idx", word_idx2)
	
	add_child(line)
	connection_lines.append(line)

func process_keywords(text: String):
	# Check for keywords in the text
	var words = text.split(config.delimiter, false)
	for word in words:
		if word in sdf_primitives:
			# SDF primitive detected
			if not active_words.has(word):
				active_words.append(word)
				
		elif word in shape_transforms:
			# Shape transform detected
			if not active_words.has(word):
				active_words.append(word)
				
		elif word in ["grid", "terminal", "shape", "connect", "words"]:
			# Command mode or special word detected
			if not active_words.has(word):
				active_words.append(word)

func check_combos(text: String):
	# See if any new combos are activated
	var words = text.split(config.delimiter, false)
	
	for combo in combo_rules.keys():
		var combo_words = combo.split("|")
		
		var all_present = true
		for combo_word in combo_words:
			if not active_words.has(combo_word):
				all_present = false
				break
				
		if all_present and not combo_active.has(combo):
			combo_active.append(combo)
			activate_combo(combo)

func create_grid_primitive(shape):
	print("shape is a string ", shape)

func activate_combo(combo: String):
	add_text_line("Combo|activated:|" + combo)
	add_text_line(combo_rules[combo])
	
	var combo_words = combo.split("|")
	
	match combo:
		"sphere|grid":
			create_grid_primitive("sphere")
		"box|grid":
			create_grid_primitive("box")
		"wave|terminal":
			set_terminal_shape("wave")
		"spiral|text":
			set_terminal_shape("spiral")
		"connect|words":
			# Already handled by word connection system
			pass
		"light|dark":
			toggle_light_mode()
		"3d|2d":
			toggle_dimension_mode()

func set_terminal_shape(shape: String):
	if shape in shape_transforms:
		current_shape = shape
		add_text_line("Changed|terminal|shape|to|" + shape)

func toggle_light_mode():
	# Toggle between light and dark mode
	if material_cache.default.albedo_color.r > 0.5:
		# Currently light, switch to dark
		material_cache.default.albedo_color = Color(0.2, 0.2, 0.3)
		material_cache.default.emission_enabled = true
		material_cache.default.emission = Color(0.1, 0.1, 0.2)
		material_cache.default.emission_energy = 0.3
		add_text_line("Switched|to|dark|mode")
	else:
		# Currently dark, switch to light
		material_cache.default.albedo_color = Color(0.8, 0.8, 0.8)
		material_cache.default.emission_enabled = false
		add_text_line("Switched|to|light|mode")

func toggle_dimension_mode():
	# Toggle between 2D and 3D display mode
	add_text_line("Toggled|dimension|mode")

func add_command_character(character: String):
	current_command += character
	update_command_line()

func remove_command_character():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()

func execute_commanddd():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command (e.g., submit to main command processor)
	match command_mode:
		"terminal":
			if thread_pool and thread_pool.has_method("submit_task"):
				thread_pool.submit_task(process_terminal_command, [current_command], "terminal_command")
			else:
				process_terminal_command([current_command])
		"grid":
			process_grid_command(current_command)
		"shape":
			process_shape_command(current_command)
	
	current_command = ""
	update_command_line()

func process_grid_command(data):
	print("data " , data)

func process_shape_command(data):
	print(" data " , data)

func update_command_line():
	# Remove existing command text
	for child in command_line.get_children():
		child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = create_3d_letter(current_command[i], Vector3(i * config.char_spacing, 0, 0))
		command_line.add_child(letter)
	
	# Add blinking cursor
	var cursor = create_3d_letter("_", Vector3(current_command.length() * config.char_spacing, 0, 0))
	cursor.name = "cursor"
	command_line.add_child(cursor)

func process_terminal_command(args):
	var command = args[0]
	
	# Split by spaces for command arguments
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	var response = "Command not recognized"
	
	match cmd:
		"help":
			response = "Available|commands:|help|clear|mode|grid|shape|snake|connect|list|combo"
		"clear":
			clear_terminal()
			return {"status": "success", "command": "clear"}
		"mode":
			if parts.size() > 1:
				set_mode(parts[1])
				response = "Mode|set|to|" + parts[1]
			else:
				response = "Current|mode:|" + command_mode
		"grid":
			set_mode("grid")
			response = "Grid|mode|activated.|Type|help|for|commands."
		"shape":
			set_mode("shape")
			response = "Shape|mode|activated.|Type|help|for|commands."
		"snake":
			response = "Launching|snake|game..."
			call_deferred("launch_snake_game")
		"connect":
			if parts.size() > 2:
				response = "Connecting|" + parts[1] + "|and|" + parts[2]
				connect_words(parts[1], parts[2])
			else:
				response = "Usage:|connect|word1|word2"
		"list":
			if parts.size() > 1:
				match parts[1]:
					"words":
						response = "Active|words:|" + "|".join(active_words)
					"combos":
						response = "Active|combos:|" + "|".join(combo_active)
					"shapes":
						response = "Available|shapes:|" + "|".join(shape_transforms)
					"primitives":
						response = "Available|primitives:|" + "|".join(sdf_primitives.keys())
					_:
						response = "Unknown|list|type.|Try:|words|combos|shapes|primitives"

func set_mode(data):
	print("data ", data)
#

func connect_words(data, data_0):
	print("data ", data, data_0)

func setup_terminal_container():
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Create anchor points to maintain terminal shape
	for i in range(config.anchor_points):
		var anchor = Node3D.new()
		anchor.name = "anchor_" + str(i)
		var angle = 2 * PI * i / config.anchor_points
		var radius = 3.0
		anchor.position = Vector3(cos(angle) * radius, sin(angle) * radius, 0)
		anchor_points.append(anchor)
		text_container.add_child(anchor)
	
	# Command line (where user types)
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	text_container.add_child(command_line)

func setup_delimiter_mesh():
	delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_mesh"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	
	# Add to command line
	command_line.add_child(delimiter_mesh)
	delimiter_mesh.position = Vector3(current_command.length() * config.char_spacing, 0, 0)

func process_floating_text(delta: float):
	var time = Time.get_ticks_msec() / 1000.0
	
	for text in floating_words:
		var word_data = floating_words[text]
		var text_node = word_data.node
		
		for i in range(word_data.words.size()):
			var word_node = word_data.words[i]
			
			# Small oscillation
			if config.floating_animation:
				var phase = time + i * 0.3
				word_node.position.y = sin(phase * 1.2) * 0.03
				word_node.rotation.z = sin(phase * 0.8) * 0.01
				
				# Maintain constraints with anchor points
				for letter in word_node.get_children():
					if letter is Label3D:
						letter.modulate = Color(
							0.8 + 0.2 * sin(time + i * 0.5),
							0.8 + 0.2 * sin(time * 0.8 + i * 0.3),
							1.0,
							1.0
						)

func process_commanddd(args):
	var command = args[0]
	var response = "Command not recognized"
	
	# Handle basic commands
	if command.begins_with("snake"):
		response = "Launching snake game..."
		call_deferred("launch_snake_game")
	elif command == "help":
		response = "Available commands: help, snake, clear"
	elif command == "clear":
		clear_terminal()
		return {"status": "success", "command": "clear"}
	
	# Add response
	add_text_line(response)
	return {"status": "success", "command": command, "response": response}

func clear_terminall():
	for text in floating_words.keys():
		remove_floating_word(text)
	terminal_text.clear()

func launch_snake_game():
	var main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_method("show_snake_game"):
		main_node.show_snake_game()

func navigate_history(direction: int):
	if command_history.size() == 0:
		return
		
	history_position += direction
	history_position = clamp(history_position, 0, command_history.size())
	
	if history_position == command_history.size():
		current_command = ""
	else:
		current_command = command_history[history_position]
	
	update_command_line()


func add_test_text():
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")

func create_floating_text_new(word: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + word
	
	# Create anchor points to maintain word shape
	var anchor_points = []
	var letter_nodes = []
	
	# Create 6-10 anchor points distributed around the word
	var num_anchors = min(6 + word.length() / 2, 10)
	
	for i in range(num_anchors):
		var anchor = Position3D.new()
		var angle = 2 * PI * i / num_anchors
		var radius = 0.5 + 0.1 * word.length()
		anchor.position = Vector3(cos(angle) * radius, sin(angle) * radius, 0)
		anchor_points.append(anchor)
		text_node.add_child(anchor)
	
	# Create individual letters
	for i in range(word.length()):
		var letter = Label3D.new()
		letter.text = word[i]
		letter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
		# Position letter in circular pattern
		var angle = 2 * PI * i / word.length()
		var radius = 0.5
		letter.position = Vector3(cos(angle) * radius, sin(angle) * radius, 0)
		
		letter_nodes.append(letter)
		text_node.add_child(letter)
	
	# Add connections between letters and anchor points for stability
	text_node.set_meta("anchor_points", anchor_points)
	text_node.set_meta("letter_nodes", letter_nodes)
	text_node.set_meta("word", word)
	
	# Add animation to slightly move letters while keeping shape
	var animation_player = AnimationPlayer.new()
	text_node.add_child(animation_player)
	create_floating_text_animation(animation_player, letter_nodes, anchor_points)
	
	return text_node

func create_floating_text_animation(data_0, data_1, data_2):
	print("data ", data_0)

func setup_ui_appearance():
	# Set panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = theme_colors.background
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.3, 0.3)
	
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style for input field
	var line_edit_style = StyleBoxFlat.new()
	line_edit_style.bg_color = Color(0.15, 0.15, 0.15)
	line_edit_style.corner_radius_top_left = 4
	line_edit_style.corner_radius_top_right = 4
	line_edit_style.corner_radius_bottom_left = 4
	line_edit_style.corner_radius_bottom_right = 4
	
	input_field.add_theme_stylebox_override("normal", line_edit_style)
	input_field.add_theme_color_override("font_color", theme_colors.text)
	input_field.add_theme_color_override("caret_color", theme_colors.command)
	
	# Style for output text
	output_text.add_theme_color_override("default_color", theme_colors.text)
	output_text.add_theme_font_size_override("normal_font_size", 14)
	
	# Scroll container settings
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	# Button styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.2, 0.2)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	
	var button_hover_style = button_style.duplicate()
	button_hover_style.bg_color = Color(0.3, 0.3, 0.3)
	
	var button_pressed_style = button_style.duplicate()
	button_pressed_style.bg_color = Color(0.15, 0.15, 0.15)
	
	for button in [submit_button, clear_button, close_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_stylebox_override("pressed", button_pressed_style)
		button.add_theme_color_override("font_color", theme_colors.text)
		button.add_theme_color_override("font_pressed_color", theme_colors.command)

func setup_signals():
	input_field.text_submitted.connect(_on_input_submitted)
	submit_button.pressed.connect(_on_submit_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	close_button.pressed.connect(_on_close_pressed)

func add_startup_message():
	add_message("JSH Console System v1.0", "info")
	add_message("Type 'help' for a list of commands", "info")

func _on_input_submitted(text):
	if text.strip_edges() != "":
		process_input(text)
		input_field.text = ""

func _on_submit_pressed():
	_on_input_submitted(input_field.text)

func _on_clear_pressed():
	output_text.text = ""
	add_startup_message()

func _on_close_pressed():
	visible = false
	emit_signal("console_closed")

func process_input(text):
	# Add to history
	if console_history.size() == 0 or console_history[0] != text:
		console_history.insert(0, text)
		if console_history.size() > max_history:
			console_history.pop_back()
	
	# Reset history position
	history_position = -1
	
	# Log command
	add_message("> " + text, "command")
	
	# Emit signal for command processing
	emit_signal("console_submitted", text)

func navigate_history_new(direction):
	if console_history.size() == 0:
		return
	
	history_position += direction
	
	if history_position >= console_history.size():
		history_position = console_history.size() - 1
	
	if history_position < 0:
		history_position = -1
		input_field.text = ""
	else:
		input_field.text = console_history[history_position]
		# Move cursor to end
		input_field.caret_column = input_field.text.length()

func add_message(message, type = "info"):
	var timestamp = Time.get_datetime_string_from_system().split(" ")[1]
	var color = theme_colors[type]
	
	var formatted_message = "[color=#%s]%s[/color] [color=#%s]%s[/color]\n" % [
		theme_colors.timestamp.to_html(false),
		"[" + timestamp + "]",
		color.to_html(false),
		message
	]
	
	output_text.append_text(formatted_message)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = output_text.get_content_height()

func open_console():
	visible = true
	input_field.grab_focus()
	emit_signal("console_opened")

func close_console():
	visible = false
	emit_signal("console_closed")

func toggle_console():
	if visible:
		close_console()
	else:
		open_console()

# Public API for other systems to use
func log_info(message):
	add_message(message, "info")

func log_warning(message):
	add_message(message, "warning")

func log_error(message):
	add_message(message, "error")

func log_success(message):
	add_message(message, "success")

func log_command_result(command, result):
	add_message("Result of '" + command + "':", "info")
	add_message(str(result), "command")


func _input_new_v1(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			execute_command()
		elif event.keycode == KEY_BACKSPACE:
			remove_command_character()
		elif event.keycode == KEY_UP:
			navigate_history(-1)
		elif event.keycode == KEY_DOWN:
			navigate_history(1)
		elif event.unicode >= 32 and event.unicode <= 126:  # Printable ASCII
			add_command_character(char(event.unicode))

func process_floating_text_new(text_node: Node3D, delta: float):
	if not text_node.has_meta("letter_nodes") or not text_node.has_meta("anchor_points"):
		return
		
	var letter_nodes = text_node.get_meta("letter_nodes")
	var anchor_points = text_node.get_meta("anchor_points")
	
	# Update positions based on constraints and forces
	for i in range(letter_nodes.size()):
		var letter = letter_nodes[i]
		
		# Apply small random movement
		var random_movement = Vector3(
			(randf() - 0.5) * 0.02,
			(randf() - 0.5) * 0.02,
			(randf() - 0.5) * 0.02
		)
		
		letter.position += random_movement
		
		# Keep letters within constraints of anchor points
		var constraint_force = Vector3.ZERO
		for anchor in anchor_points:
			var dir = anchor.global_position - letter.global_position
			var distance = dir.length()
			if distance > 1.0:  # Max distance from anchor
				constraint_force += dir.normalized() * (distance - 1.0) * 0.1
		
		letter.position += constraint_force

func setup_terminal_container_new():
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Create anchor points to maintain terminal shape
	for i in range(config.anchor_points):
		var anchor = Node3D.new()
		anchor.name = "anchor_" + str(i)
		var angle = 2 * PI * i / config.anchor_points
		var radius = 3.0
		anchor.position = Vector3(cos(angle) * radius, sin(angle) * radius, 0)
		anchor_points.append(anchor)
		text_container.add_child(anchor)
	
	# Command line (where user types)
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	text_container.add_child(command_line)

func setup_delimiter_mesh_new():
	delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_mesh"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	
	# Add to command line
	command_line.add_child(delimiter_mesh)
	delimiter_mesh.position = Vector3(current_command.length() * config.char_spacing, 0, 0)

func add_text_line_new(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Reposition existing lines
	reposition_text_lines()

func create_floating_text_new_v1(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text
	text_container.add_child(text_node)
	text_node.position = position
	
	# Words separated by the delimiter
	var words = text.split(config.delimiter, false)
	var letter_nodes = []
	var word_nodes = []
	
	var x_offset = 0.0
	
	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_node = Node3D.new()
		word_node.name = "word_" + str(word_idx)
		text_node.add_child(word_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = Label3D.new()
			letter.text = word[i]
			letter.font_size = 64
			letter.modulate = Color(0.9, 0.9, 1.0)
			letter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			letter.no_depth_test = true
			letter.position = Vector3(i * config.char_spacing, 0, 0)
			letter.scale = Vector3.ONE * config.letter_scale
			
			letter_nodes.append(letter)
			word_node.add_child(letter)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = delimiter_mesh.duplicate()
			delim.position = Vector3(word.length() * config.char_spacing + 0.1, 0, 0)
			word_node.add_child(delim)
			x_offset += word.length() * config.char_spacing + 0.3
		else:
			x_offset += word.length() * config.char_spacing
	
	# Store reference and metadata
	floating_words[text] = {
		"node": text_node,
		"words": word_nodes,
		"letters": letter_nodes,
		"position": position
	}
	
	return text_node

func remove_floating_word_new(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		word_data.node.queue_free()
		floating_words.erase(text)

func reposition_text_lines_new():
	var line_pos = Vector3(0, 0, 0)
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)

func process_floating_text_new_v1(delta: float):
	var time = Time.get_ticks_msec() / 1000.0
	
	for text in floating_words:
		var word_data = floating_words[text]
		var text_node = word_data.node
		
		for i in range(word_data.words.size()):
			var word_node = word_data.words[i]
			
			# Small oscillation
			if config.floating_animation:
				var phase = time + i * 0.3
				word_node.position.y = sin(phase * 1.2) * 0.03
				word_node.rotation.z = sin(phase * 0.8) * 0.01
				
				# Maintain constraints with anchor points
				for letter in word_node.get_children():
					if letter is Label3D:
						letter.modulate = Color(
							0.8 + 0.2 * sin(time + i * 0.5),
							0.8 + 0.2 * sin(time * 0.8 + i * 0.3),
							1.0,
							1.0
						)

func add_command_character_new(character: String):
	current_command += character
	update_command_line()

func remove_command_character_new():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()

func execute_command_new():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command (e.g., submit to main command processor)
	if thread_pool and thread_pool.has_method("submit_task"):
		thread_pool.submit_task(process_command, [current_command], "terminal_command")
#	else:
	#	process_command([current_command])
	
	current_command = ""
	update_command_line()

func update_command_line_new():
	# Remove existing command text
	for child in command_line.get_children():
		if child != delimiter_mesh:
			child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = Label3D.new()
		letter.text = current_command[i]
		letter.font_size = 64
		letter.modulate = Color(0.2, 0.8, 1.0)
		letter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		letter.no_depth_test = true
		letter.position = Vector3(i * config.char_spacing, 0, 0)
		letter.scale = Vector3.ONE * config.letter_scale
		command_line.add_child(letter)
	
	# Update delimiter position
	delimiter_mesh.position = Vector3(current_command.length() * config.char_spacing, 0, 0)

func process_command_new(args):
	var command = args[0]
	var response = "Command not recognized"
	
	# Handle basic commands
	if command.begins_with("snake"):
		response = "Launching snake game..."
		call_deferred("launch_snake_game")
	elif command == "help":
		response = "Available commands: help, snake, clear"
	elif command == "clear":
		clear_terminal()
		return {"status": "success", "command": "clear"}
	
	# Add response
	add_text_line(response)
	return {"status": "success", "command": command, "response": response}

func clear_terminal_new():
	for text in floating_words.keys():
		remove_floating_word(text)
	terminal_text.clear()

func launch_snake_game_new():
	var main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_method("show_snake_game"):
		main_node.show_snake_game()

func navigate_history_new_v1(direction: int):
	if command_history.size() == 0:
		return
		
	history_position += direction
	history_position = clamp(history_position, 0, command_history.size())
	
	if history_position == command_history.size():
		current_command = ""
	else:
		current_command = command_history[history_position]
	
	update_command_line()

func add_test_text_new():
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")



## from here we wanna access to what we see and do
func add_text_line_new_v1(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Reposition existing lines
	reposition_text_lines()

func create_floating_text_new_v2(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text
	text_container.add_child(text_node)
	text_node.position = position
	
	# Words separated by the delimiter
	var words = text.split(config.delimiter, false)
	var letter_nodes = []
	var word_nodes = []
	
	var x_offset = 0.0
	
	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_node = Node3D.new()
		word_node.name = "word_" + str(word_idx)
		text_node.add_child(word_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = Label3D.new()
			letter.text = word[i]
			letter.font_size = 64
			letter.modulate = Color(0.9, 0.9, 1.0)
			letter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			letter.no_depth_test = true
			letter.position = Vector3(i * config.char_spacing, 0, 0)
			letter.scale = Vector3.ONE * config.letter_scale
			
			letter_nodes.append(letter)
			word_node.add_child(letter)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = delimiter_mesh.duplicate()
			delim.position = Vector3(word.length() * config.char_spacing + 0.1, 0, 0)
			word_node.add_child(delim)
			x_offset += word.length() * config.char_spacing + 0.3
		else:
			x_offset += word.length() * config.char_spacing
	
	# Store reference and metadata
	floating_words[text] = {
		"node": text_node,
		"words": word_nodes,
		"letters": letter_nodes,
		"position": position
	}
	
	return text_node

func remove_floating_word_new_v1(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		word_data.node.queue_free()
		floating_words.erase(text)

func reposition_text_lines_new_v1():
	var line_pos = Vector3(0, 0, 0)
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)


##

func add_command_character_new_v1(character: String):
	current_command += character
	update_command_line()

func remove_command_character_new_v1():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()

func execute_command_new_v1():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command (e.g., submit to main command processor)
	if thread_pool and thread_pool.has_method("submit_task"):
		thread_pool.submit_task(process_command, [current_command], "terminal_command")
#	else:
	#	process_command([current_command])
	
	current_command = ""
	update_command_line()

func update_command_line_new_v1():
	# Remove existing command text
	for child in command_line.get_children():
		if child != delimiter_mesh:
			child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = Label3D.new()
		letter.text = current_command[i]
		letter.font_size = 64
		letter.modulate = Color(0.2, 0.8, 1.0)
		letter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		letter.no_depth_test = true
		letter.position = Vector3(i * config.char_spacing, 0, 0)
		letter.scale = Vector3.ONE * config.letter_scale
		command_line.add_child(letter)
	
	# Update delimiter position
	delimiter_mesh.position = Vector3(current_command.length() * config.char_spacing, 0, 0)

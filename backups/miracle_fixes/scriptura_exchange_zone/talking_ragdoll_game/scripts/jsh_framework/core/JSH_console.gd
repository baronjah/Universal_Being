# 🏛️ Jsh Console - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      
extends UniversalBeingBase
class_name JSHConsoleSystem


@onready var console_gui = null  # Console GUI will be created dynamically if needed

#class_name JSHConsoleSystem

var command_history = []
var command_handlers = {}
var variable_storage = {}
var console_mutex = Mutex.new()
var max_history = 100
var max_output_lines = 500
var output_lines = []

# Mapping of command aliases
const COMMAND_ALIASES = {
	"ls": "list",
	"cd": "change_directory",
	"mv": "move",
	"rm": "remove",
	"cat": "display",
	"cls": "clear",
	"help": "show_help"
}






# JSH_terminal.gd
# JSH Ethereal Terminal System

#extends UniversalBeingBase
#class_name JSH_Terminal

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓        ┳┳┓                •    ┓
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓ ┃┃┃┏┓┏┓┏┳┓┳┓┏┓┏┓  ┏┓┏┛┏┓┏┫
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗  ┛ ┗┗┻┛ ┛┗┗┗┻┗┛┗   ┗┻┛ ┗┻┗┻
#       888 oo     .d8P  888     888                                        
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

# References to main systems
@onready var thread_pool = get_node_or_null("/root/JSHThreadPool")
@onready var task_manager = null  # Task manager not needed for ragdoll game
@onready var main_node = get_tree().current_scene if get_tree() else null

# Terminal visual nodes
var terminal_container : Node3D = null
var output_text_mesh : Label3D = null
var input_text : Label3D = null
var cursor : MeshInstance3D = null
var status_text : Label3D = null
var memory_text : Label3D = null

# Terminal state
var current_scene_id : int = 0
var is_terminal_active : bool = false
var is_processing_command : bool = false
var was_keyboard_connected : bool = false

# Command history
var command_historynew = []
var history_position = -1
var max_historyy = 30

# Terminal state
var current_command = ""
var output_text = "JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>"
var cursor_visible = true
var cursor_blink_timer = 0
var cursor_blink_rate = 0.5
var cursor_base_position = Vector3(-7.25, -4.0, 0.25)
var char_width = 0.15  # Approximate width of each character
var bracket_width = 15.0

# Data for snake game in terminal
var snake_active = false
var snake_grid_size = Vector2i(20, 10)
var snake_segments = []
var snake_direction = Vector2i(1, 0)
var snake_food_position = Vector2i(0, 0)
var snake_speed = 0.5
var snake_timer = 0
var snake_score = 0

# Command parsing
var terminal_variables = {
	"prompt": ">",
	"max_history": 100,
	"echo": true,
	"verbose": false,
	"auto_complete": true
}
var command_aliases = {}
var command_mutex = Mutex.new()

# Available commands with descriptions
var available_commands = {
	"help": "Show list of available commands",
	"clear": "Clear terminal output",
	"history": "Show command history",
	"echo": "Display text (usage: echo [text])",
	"ls": "List available objects/things",
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
	"snake": "Play snake game in terminal",
	"planet": "Create a planet (usage: planet [name] [size] [type])",
	"exit": "Close the terminal"
}

# Variables that can be set/get
var terminal_states = {
	"state": "idle",
	"debug_level": "info",
	"history_mode": "linear",
	"command_mode": "standard",
	"display_mode": "3D",
	"holographic": "true",
	"cursor_rate": "0.5",
	"max_history": "30",
	"log_commands": "true",
	"multithread": "true",
	"grid_enabled": "false",
	"frame_limit": "60",
	"display_fps": "false",
	"animation_speed": "1.0",
	"theme": "jsh_dark",
	"error_handling": "verbose"
}


# References
var thread_poool = null
var camera = null
var main_nodee = null
var task_manageer = null
var material_cache := {}
var center_point := Vector3.ZERO
var time_accumulator := 0.0
var terminal_initialized := false
var connection_lines := []

# Registered commands
var commands := {}


# Terminal state
var terminal_text := []
var floating_words := {}
var current_commasnd := ""
#var command_history := []
var history_positiion := -1
var command_mode := "terminal"
var active_words := []
var combo_active := []

# Visual components
var text_container: Node3D
var command_line: Node3D
var window_mesh: MeshInstance3D
var delimiter_meshes := []
var terminal_node: Node3D





## res://code/gdscript/scripts/Text_Console_Window/console_window_ui.gd
#

var word_network := {}
#L
var function_network := {}
var path_network := {}
var node_network := {}

var grid_container: Node3D
var shape_container: Node3D
var file_viewer: Node3D
var node_viewer: Node3D

var grid_size := Vector3i(10, 10, 10)
var grid_cell_size := 0.5
var grid_data := {}
var grid_cells := []
var grid_highlight = null

# Shape viewer properties 
var current_primitive := "sphere"
var primitive_params := {"radius": 1.0, "size": Vector2(1.0, 1.0)}
var primitive_mesh: MeshInstance3D
var primitive_resolution := 32

# Function network properties
var function_nodes := {}
var function_connections := []
var function_call_history := []

var rotation
var global_position

var console_ui: Control
var input_field: LineEdit
var output_teext: RichTextLabel
var output_container: ScrollContainer
var text_container_new: Node3D

#var max_history: int = 100
#var max_output_lines: int = 500
var history_position_new := -1
var time_accumulator_new := 0.0
var is_visible: bool = false
var thread_pool_new = null
var terminal_text_new := []
var command_history_new_v1 := []
var delimiter_meshes_new := []

var floating_words_new := {}
var combo_rules := {}
var center_point_new := Vector3.ZERO
var grid_position := Vector3.ZERO
var grid_rotation := Vector3.ZERO
var grid_scale := Vector3.ONE
var grid_cursor_pos := Vector3i.ZERO
var primitive_color := Color(0.2, 0.6, 1.0)
var current_shape_new := "flat"
var current_command_new := ""

var terminal_combo_sequence = []
var max_terminal_combo_length = 5

var process_terminal_command

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      


var config_new := {
	"letter_scale": 0.1,
	"word_radius": 2.0,
	"max_visible_lines": 16,
	"line_spacing": 0.5,
	"char_spacing": 0.15,
	"delimiter": "|",
	"max_distance_value": 5.0,  # Maximum distance for grayscale calculation
	"pulse_speed": 0.5,         # Speed of ambient pulsing
	"float_amount": 0.05,       # How much letters float
	"shape_morph_time": 3.0     # Seconds between shape transformations
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


var terminal_combo_patterns = {
	"file_search": ["ls", "grep"],
	"quick_edit": ["cat", "nano"],
	"system_check": ["df", "free", "top"],
	"file_backup": ["find", "cp", "gzip"],
	"code_commit": ["git add", "git commit", "git push"]
}

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      

signal console_toggled(visible)

var shape_transforms_new := ["sphere", "cube", "flat", "helix", "wave"]




signal command_executed(command, result)
signal terminal_toggled(visible)
signal log_added(message, type)

var current_shape := "flat"


# Shape transformations for floating text
var shape_transforms := ["sphere", "cube", "flat", "helix", "wave", "spiral"]



# 3D text configuration
var config := {
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
	"connection_distance": 0.8,
	"connection_color": Color(0.3, 0.6, 1.0, 0.4)
}

# Color settings
var colors = {
	"info": Color(0.8, 0.8, 0.8),
	"warning": Color(1.0, 0.9, 0.2),
	"error": Color(1.0, 0.3, 0.3),
	"success": Color(0.2, 1.0, 0.3),
	"command": Color(0.4, 0.7, 1.0),
	"result": Color(0.6, 0.8, 1.0),
	"timestamp": Color(0.5, 0.5, 0.5)
}



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      
enum LogType {
	INFO,
	WARNING,
	ERROR,
	SUCCESS,
	COMMAND
}


























# Add these functions to your data_point.gd script to handle terminal functionality

# Terminal state
var terminal_current_command = ""
var terminal_output_text = "JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>"
var terminal_command_history = []
var terminal_history_position = -1
var terminal_max_history = 30
var terminal_cursor_visible = true
var terminal_cursor_blink_timer = 0
var terminal_cursor_blink_rate = 0.5
var terminal_cursor_base_position = Vector3(-7.25, -4.0, 0.25)
var terminal_char_width = 0.15  # Approximate width of each character
var terminal_bracket_width = 15.0
var terminal_variabless = {}
var terminal_active_tab = 1

# Available commands with descriptions
var terminal_commands = {
	"help": "Show list of available commands",
	"clear": "Clear terminal output",
	"history": "Show command history",
	"echo": "Display text (usage: echo [text])",
	"ls": "List available objects/things",
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























# terminal_manager.gd
# Create a new script file with this code

#extends UniversalBeingBase
#class_name TerminalManager

# References to important nodes
var terminal_containerr : Node3D
var output_text_meshh : Node3D  # The text_mesh for output (thing_306)
var input_textt : Node3D        # The input text element (thing_309)
var cursorr : Node3D            # Visual cursor element (thing_310)
var status_textt : Node3D       # Status bar text (thing_318)
var memory_textt : Node3D       # Memory usage display (thing_319)

# Current scene data
var current_scene_idd : int = 0

# Command history
var command_historyy = []
var history_positionn = -1
var max_historyyy = 30

# Terminal state
var current_commandd = ""
var output_textt = "JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>"
var cursor_visiblee = true
var cursor_blink_timerr = 0
var cursor_blink_ratee = 0.5
var cursor_base_positionn = Vector3(-7.25, -4.0, 0.25)
var char_widthh = 0.15  # Approximate width of each character

# Available commands with descriptions
var available_commandss = {
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
var terminal_variablesss = {
	"prompt": ">",
	"color": "blue",
	"cursor_rate": "0.5",
	"max_history": "30",
	"debug": "false"
}

func _ready_add():
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

func _process_add(delta):
	# Handle cursor blinking
	cursor_blink_timer += delta
	if cursor_blink_timer >= cursor_blink_rate:
		cursor_blink_timer = 0
		cursor_visible = !cursor_visible
		update_cursor()


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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
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
	# in datapoints script, node path, in different records, maybe we need var names packs?
	#change_to_scene(3)
	update_status("Processing...")
	update_memory_display(92)
	
	# Process the command
	var command_parts = command_text.strip_edges().split(" ", false)
	var base_command = command_parts[0].to_lower() if command_parts.size() > 0 else ""
	
	match base_command:
		"help":
			show_help(command_parts)
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
		"list":
			list_things(command_parts)
		#"create":
			#if command_parts.size() >= 3:
			#	create_thing(command_parts[1], command_parts[2])
			#else:
			# need command create thing maybe, and we do have it in main script anyway

















func setup_terminal():
	# Initialize terminal variables
	terminal_variables = {
		"prompt": ">",
		"color": "blue",
		"cursor_rate": "0.5",
		"max_history": "30",
		"debug": "false"
	}
	
	# Set up cursor blinking timer
	var timer = TimerManager.get_timer()
	add_child(timer)
	timer.wait_time = terminal_cursor_blink_rate
	timer.timeout.connect(terminal_blink_cursor)
	timer.start()
	
	# Initialize keyboard connection for terminal
	var terminal_text_node = main_node.jsh_tree_get_node("terminal_container/thing_309")
	# missing function
	if terminal_text_node:
		print("#set_connection_target")
		#set_connection_target
		#("terminal_container", "thing_309", "thing_301")

func terminal_blink_cursor():
	terminal_cursor_visible = !terminal_cursor_visible
	var cursor_node = main_node.jsh_tree_get_node("terminal_container/thing_310")
	if cursor_node:
		cursor_node.visible = terminal_cursor_visible

func handle_terminal_key_press(key: String):
	if len(terminal_current_command) * terminal_char_width < terminal_bracket_width:
		terminal_current_command += key
		update_terminal_display()

func handle_terminal_backspace():
	if terminal_current_command.length() > 0:
		terminal_current_command = terminal_current_command.substr(0, terminal_current_command.length() - 1)
		update_terminal_display()

func update_terminal_display():
	# Update input text
	var input_text_node = main_node.jsh_tree_get_node("terminal_container/thing_309")
	if input_text_node:
		input_text_node.text = terminal_current_command
		
	# Update cursor position
	var cursor_node = main_node.jsh_tree_get_node("terminal_container/thing_310")
	if cursor_node:
		var text_length = terminal_current_command.length()
		var offset = Vector3(text_length * terminal_char_width, 0, 0)
		cursor_node.position = terminal_cursor_base_position + offset
		
	# Update output text
	var output_text_node = main_node.jsh_tree_get_node("terminal_container/thing_306")
	if output_text_node:
		output_text_node.text = terminal_output_text

func history_upp():
	if terminal_command_history.size() > 0 and terminal_history_position < terminal_command_history.size() - 1:
		terminal_history_position += 1
		terminal_current_command = terminal_command_history[terminal_command_history.size() - 1 - terminal_history_position]
		update_terminal_display()

func history_downn():
	if terminal_history_position > 0:
		terminal_history_position -= 1
		terminal_current_command = terminal_command_history[terminal_command_history.size() - 1 - terminal_history_position]
	elif terminal_history_position == 0:
		terminal_history_position = -1
		terminal_current_command = ""
	
	update_terminal_display()

func execute_commandd():
	var command_to_execute = terminal_current_command.strip_edges()
	
	# Add command to history if not empty
	if command_to_execute != "":
		terminal_command_history.push_back(command_to_execute)
		if terminal_command_history.size() > terminal_max_history:
			terminal_command_history.pop_front()

















# Terminal startup
func _readyy():
	initialize_terminal()
	setup_terminal_variables()
	setup_cursor_timer()
	register_command_aliases()
	
	# Set up a thread-safe way to execute commands in the main thread
	process_mode = Node.PROCESS_MODE_PAUSABLE






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	name = "JSH_Console_System"

func _readyyy():
	# Set up references
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	main_node = get_node_or_null("/root/main")
	
	if main_node and main_node.has_node("JSH_task_manager"):
		task_manager = main_node.get_node("JSH_task_manager")
	
	setup_terminal_container()
	setup_material_cache()
	register_default_commands()
	
	# Initial welcome message
	add_text_line("JSH|Ethereal|Engine|Console|System")
	add_text_line("Type|'help'|for|available|commands")
	
	terminal_initialized = true

func _processs(delta):
	# Update time accumulator for animations
	time_accumulator = delta
	
	# Update letter visuals
	update_letter_visuals()
	
	# Make terminal face camera
	if camera:
		var camera_pos = camera.global_position
		camera_pos.y = global_position.y  # Keep y level the same
		look_at(camera_pos, Vector3.UP)
		rotation.z = 0  # Keep upright
		
		# Update center point (used for distance calculations)
		center_point = global_position

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
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










# Process function to handle terminal updates
func _process_cmd(delta):
	if not is_terminal_active:
		return
		
	if snake_active:
		var _process_snake_game
		#_process_snake_game(delta)
		## in different file maybe?
	# Handle cursor blinking
	cursor_blink_timer += delta
	if cursor_blink_timer >= cursor_blink_rate:
		cursor_blink_timer = 0
		cursor_visible = !cursor_visible
		update_cursor()










#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      


















func initialize_terminal():
	print("[JSH_Terminal] Initializing...")
	
	# that in main node only, main.gd. main node /root/main
	#create_new_task("setup_terminal_visual_components", null)

func setup_terminal_variables():
	terminal_variables = {
		"prompt": ">",
		"color": "blue",
		"cursor_rate": "0.5",
		"max_history": "30",
		"debug": "false"
	}

func setup_cursor_timer():
	var timer = TimerManager.get_timer()
	add_child(timer)
	timer.wait_time = cursor_blink_rate
	timer.timeout.connect(blink_cursor)
	timer.start()

func register_command_aliases():
	command_aliases = {
		"?": "help",
		"cls": "clear",
		"dir": "ls",
		"list": "ls",
		"mk": "create",
		"rm": "delete",
		"del": "delete",
		"sv": "set",
		"render": "show",
		"hide": "hide",
		"mv": "move",
		"rt": "rotate",
		"exit": "exit",
		"quit": "exit",
		"inspect": "find"
	}












































# Find and set up the required terminal nodes
func setup_terminal_visual_components():
	# In a real implementation, you would find these nodes from your scene tree
	terminal_container = main_node.jsh_tree_get_node("terminal_container")
	
	if terminal_container:
		output_text_mesh = main_node.jsh_tree_get_node("terminal_container/thing_306")
		input_text = main_node.jsh_tree_get_node("terminal_container/thing_309")
		cursor = main_node.jsh_tree_get_node("terminal_container/thing_310")
		status_text = main_node.jsh_tree_get_node("terminal_container/thing_318")
		memory_text = main_node.jsh_tree_get_node("terminal_container/thing_319")
		
		# Connect keyboard to input
		if input_text and not was_keyboard_connected:
			main_node.eighth_dimensional_magic("keyboard_connection", ["terminal_container", "thing_309", "thing_301"], "")
			was_keyboard_connected = true
			
		update_output_display()
		update_input_display()
		update_status("Ready")
		update_memory_display(100)
		
		is_terminal_active = true
		print("[JSH_Terminal] Visual components initialized")
	else:
		print("[JSH_Terminal] Terminal container not found")

# Handle cursor updates
func update_cursorr():
	if not cursor or not is_terminal_active:
		return
		
	cursor.visible = cursor_visible
	
	# Calculate cursor position based on text length
	var text_length = current_command.length()
	var offset = Vector3(text_length * char_width, 0, 0)
	cursor.position = cursor_base_position + offset

# Update displays
func update_input_displayy():
	if not input_text or not is_terminal_active:
		return
		
	input_text.text = current_command
	update_cursor()

func update_output_displayy():
	if not output_text_mesh or not is_terminal_active:
		return
		
	output_text_mesh.text = output_text

func update_statuss(status: String):
	if not status_text or not is_terminal_active:
		return
		
	status_text.text = status

func update_memory_displayy(percentage: int):
	if not memory_text or not is_terminal_active:
		return
		
	memory_text.text = "MEM: " + str(percentage) + "%"

# Blink cursor - connected to timer
func blink_cursor():
	cursor_visible = !cursor_visible
	update_cursor()

# Key input handling
func handle_key_press(key: String):
	if not is_terminal_active:
		return
		
	if snake_active:
		#handle_snake_key_input(key)
		# was missing, we have snake node too
		return
		
	if len(current_command) * char_width < bracket_width:
		current_command = current_command.insert(current_command.length(), key)
		update_input_display()

func handle_backspace():
	if not is_terminal_active:
		return
		
	if snake_active:
		return
		
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_input_display()

# History navigation
func history_uppp():
	if not is_terminal_active or snake_active:
		return
		
	if command_history.size() > 0 and history_position < command_history.size() - 1:
		history_position += 1
		current_command = command_history[command_history.size() - 1 - history_position]
		update_input_display()

func history_downnn():
	if not is_terminal_active or snake_active:
		return
		
	if history_position > 0:
		history_position -= 1
		current_command = command_history[command_history.size() - 1 - history_position]
	elif history_position == 0:
		history_position = -1
		current_command = ""
	
	update_input_display()

# Command execution
func execute_commanddd():
	if not is_terminal_active:
		return
		
	if snake_active:
		snake_active = false
		update_status("Ready")
		update_output_display()
		return
		
	var command_to_execute = current_command.strip_edges()
	
	# Add command to history if not empty
	if command_to_execute != "":
		command_history.push_back(command_to_execute)
		if command_history.size() > int(terminal_variables["max_history"]):
			command_history.pop_front()
	
	# Display command in output
	output_text += terminal_variables["prompt"] + " " + command_to_execute + "\n"
	
	# Process command
	#create_new_task("process_command", command_to_execute)
	
	# Reset input and update displays
	current_command = ""
	history_position = -1
	update_input_display()
	update_output_display()

# Command processing
func process_commandddd(command_text: String):
	if is_processing_command:
		output_text += "Already processing a command. Please wait...\n"
		update_output_display()
		return
		
	is_processing_command = true
	
	# Change to processing scene
	#change_to_scene(3)
	# i didnt really played around with changing scenes and menu, are scenes different 3d spaces, or further 3d spaces?
	
	update_status("Processing...")
	update_memory_display(92)
	
	# Process the command
	var command_parts = command_text.strip_edges().split(" ", false)
	var base_command = command_parts[0].to_lower() if command_parts.size() > 0 else ""
	
	# Check for aliases
	if command_aliases.has(base_command):
		base_command = command_aliases[base_command]
	
	var result = "Command completed."
	
	match base_command:
		"help":
			result = show_help(command_parts)
		"clear":
			result = clear_terminal()
		"history":
			result = show_command_history()
		"echo":
			if command_parts.size() > 1:
				var echo_text = command_text.substr(command_text.find(" ") + 1)
				output_text += echo_text + "\n"
				result = ""
			else:
				result = "Usage: echo [text]"
		"ls":
			result = list_things(command_parts)
		"create":
			if command_parts.size() >= 3:
				result = create_thing(command_parts)
			else:
				result = "Usage: create [type] [name]"
		"delete":
			if command_parts.size() >= 2:
				result = delete_thing(command_parts[1])
			else:
				result = "Usage: delete [name]"
		"connect":
			if command_parts.size() >= 3:
				result = connect_things(command_parts[1], command_parts[2])
			else:
				result = "Usage: connect [thing1] [thing2]"
		"show":
			if command_parts.size() >= 2:
				result = show_container(command_parts[1])
			else:
				result = "Usage: show [container_name]"
		"hide":
			if command_parts.size() >= 2:
				result = hide_container(command_parts[1])
			else:
				result = "Usage: hide [container_name]"
		"move":
			if command_parts.size() >= 3:
				result = move_object(command_parts)
			else:
				result = "Usage: move [name] [x,y,z]"
		"rotate":
			if command_parts.size() >= 3:
				result = rotate_object(command_parts)
			else:
				result = "Usage: rotate [name] [x,y,z]"
		"load":
			if command_parts.size() >= 2:
				result = load_scene(command_parts[1])
			else:
				result = "Usage: load [scene_name]"
		"unload":
			if command_parts.size() >= 2:
				result = unload_scene(command_parts[1])
			else:
				result = "Usage: unload [scene_name]"
		"find":
			if command_parts.size() >= 2:
				result = find_objects(command_parts[1])
			else:
				result = "Usage: find [query]"
		"status":
			result = display_system_status()
		"mem":
			result = display_memory_usage()
		"set":
			if command_parts.size() >= 3:
				result = set_variable(command_parts[1], command_parts[2])
			else:
				result = "Usage: set [name] [value]"
		"get":
			if command_parts.size() >= 2:
				result = get_variable_value(command_parts[1])
			else:
				result = "Usage: get [name]"
		"run":
			if command_parts.size() >= 2:
				result = run_script_file(command_parts[1])
			else:
				result = "Usage: run [filename]"
		"snake":
			result = start_snake_game()
		"planet":
			if command_parts.size() >= 4:
				result = create_planet(command_parts[1], command_parts[2], command_parts[3])
			else:
				result = "Usage: planet [name] [size] [type]"
		"exit":
			result = close_terminal()
		"":
			result = ""
		_:
			result = "Unknown command: " + base_command + "\n" + "Type 'help' for a list of commands."
	
	if result != "":
		output_text += result + "\n"
	
	update_output_display()
	update_status("Ready")
	update_memory_display(100)
	#change_to_scene(0)
	
	is_processing_command = false

# Command implementations
func show_help(args: Array) -> String:
	var help_text = "Available commands:\n"
	
	if args.size() > 1:
		var cmd = args[1].to_lower()
		if available_commands.has(cmd):
			help_text = cmd + " - " + available_commands[cmd] + "\n"
			help_text += "Usage: " + get_command_usage(cmd)
		else:
			help_text = "Unknown command: " + cmd + "\n"
	else:
		for cmd in available_commands:
			help_text += "  " + cmd + " - " + available_commands[cmd] + "\n"
		help_text += "\nUse 'help [command]' for more details on a specific command."
	
	return help_text

func get_command_usage(cmd: String) -> String:
	match cmd:
		"help": return "help [command]"
		"clear": return "clear"
		"history": return "history"
		"echo": return "echo [text]"
		"ls": return "ls [directory]"
		"create": return "create [type] [name] [parameters]"
		"delete": return "delete [name]"
		"connect": return "connect [thing1] [thing2]"
		"show": return "show [container_name]"
		"hide": return "hide [container_name]"
		"move": return "move [name] [x,y,z]"
		"rotate": return "rotate [name] [x,y,z]"
		"load": return "load [scene_name]"
		"unload": return "unload [scene_name]"
		"find": return "find [query]"
		"status": return "status"
		"mem": return "mem"
		"set": return "set [name] [value]"
		"get": return "get [name]"
		"run": return "run [filename]"
		"snake": return "snake"
		"planet": return "planet [name] [size] [type]"
		"exit": return "exit"
		_: return cmd











# i used move_things_around in datapoint
# to change scene or set of points into spaces
# load unload nodes, paths names



























func clear_terminal() -> String:
	output_text = "JSH Terminal v1.0\n"
	return ""

func show_command_history() -> String:
	if command_history.size() > 0:
		var history_text = "Command history:\n"
		for i in range(command_history.size()):
			history_text += "  " + str(i+1) + ": " + command_history[i] + "\n"
		return history_text
	else:
		return "No command history."

func list_things(args: Array) -> String:
	# Customize this based on your game's object system
	var path = "/"
	if args.size() > 1:
		path = args[1]
	
	var output = "Available things in " + path + ":\n"
	var tree_data = main_node.scene_tree_jsh
	
	if path == "/":
		# List main tree branches
		if tree_data.has("main_root") and tree_data["main_root"].has("branches"):
			for branch in tree_data["main_root"]["branches"]:
				output += "  " + branch + "/\n"
	else:
		# Try to find the specified path
		var parts = path.split("/", false)
		var current = tree_data
		
		for part in parts:
			if current.has("main_root") and current["main_root"].has("branches") and current["main_root"]["branches"].has(part):
				current = current["main_root"]["branches"][part]
			else:
				return "Path not found: " + path
		
		# List contents of the found path
		if current.has("things"):
			for thing in current["things"]:
				output += "  " + thing + "\n"
		else:
			output += "  (empty)\n"
	
	return output

func create_thing(args: Array) -> String:
	var type = args[1]
	var thing_name = args[2]
	
	# Additional parameters
	var params = {}
	if args.size() > 3:
		for i in range(3, args.size()):
			var param_parts = args[i].split("=")
			if param_parts.size() == 2:
				params[param_parts[0]] = param_parts[1]
	
	# Interface with your game's object creation system
	var result = "Creating " + type + " with name " + thing_name
	if params.size() > 0:
		result += " and parameters:\n"
		for param in params:
			result += "  " + param + " = " + params[param] + "\n"
	
	main_node.create_new_task("three_stages_of_creation", type + "|" + thing_name)
	
	return result

func delete_thing(thing_name: String) -> String:
	# Interface with your game's object deletion system
	var result = "Deleting " + thing_name
	
	var thing_path = find_thing_path(thing_name)
	if thing_path.is_empty():
		return "Thing not found: " + thing_name
	
	main_node.fifth_dimensional_magic("just_node", thing_path)
	
	return result

func connect_things(thing1: String, thing2: String) -> String:
	# Interface with your game's object connection system
	var result = "Connecting " + thing1 + " to " + thing2
	
	main_node.eighth_dimensional_magic("connect_things", [thing1, thing2], "")
	
	return result

func show_container(container_name: String) -> String:
	# Show a container
	var result = "Showing container " + container_name
	
	if main_node.scene_tree_jsh["main_root"]["branches"].has(container_name):
		main_node.seventh_dimensional_magic("change_visibilty", container_name, 1)
	else:
		result = "Container not found: " + container_name
	
	return result

func hide_container(container_name: String) -> String:
	# Hide a container
	var result = "Hiding container " + container_name
	
	if main_node.scene_tree_jsh["main_root"]["branches"].has(container_name):
		main_node.seventh_dimensional_magic("change_visibilty", container_name, 0)
	else:
		result = "Container not found: " + container_name
	
	return result

func move_object(args: Array) -> String:
	var object_name = args[1]
	
	# Parse position
	var position
	if args.size() >= 5:  # Separate x, y, z arguments
		position = Vector3(float(args[2]), float(args[3]), float(args[4]))
	elif args.size() == 3:  # Vector as "x,y,z"
		var coords = args[2].split(",")
		if coords.size() == 3:
			position = Vector3(float(coords[0]), float(coords[1]), float(coords[2]))
		else:
			return "Invalid position format. Use: move [name] x,y,z or move [name] x y z"
	else:
		return "Invalid position format. Use: move [name] x,y,z or move [name] x y z"
	
	# Find the thing
	var thing_path = find_thing_path(object_name)
	if thing_path.is_empty():
		return "Thing not found: " + object_name
	
	var thing_node = main_node.jsh_tree_get_node(thing_path)
	if not thing_node:
		return "Thing node not found: " + object_name
	
	main_node.the_fourth_dimensional_magic("move", thing_node, position)
	
	return "Moving " + object_name + " to " + str(position)

func rotate_object(args: Array) -> String:
	var object_name = args[1]
	
	# Parse rotation
	var object_rotation
	if args.size() >= 5:  # Separate x, y, z arguments
		object_rotation = Vector3(float(args[2]), float(args[3]), float(args[4]))
	elif args.size() == 3:  # Vector as "x,y,z"
		var coords = args[2].split(",")
		if coords.size() == 3:
			object_rotation = Vector3(float(coords[0]), float(coords[1]), float(coords[2]))
		else:
			return "Invalid rotation format. Use: rotate [name] x,y,z or rotate [name] x y z"
	else:
		return "Invalid rotation format. Use: rotate [name] x,y,z or rotate [name] x y z"
	
	# Find the thing
	var thing_path = find_thing_path(object_name)
	if thing_path.is_empty():
		return "Thing not found: " + object_name
	
	var thing_node = main_node.jsh_tree_get_node(thing_path)
	if not thing_node:
		return "Thing node not found: " + object_name
	
	main_node.the_fourth_dimensional_magic("rotate", thing_node, object_rotation)
	
	return "Rotating " + object_name + " to " + str(object_rotation)

func load_scene(scene_name: String) -> String:
	# Load a scene
	var result = "Loading scene " + scene_name
	
	main_node.create_new_task("three_stages_of_creation", scene_name)
	
	return result

func unload_scene(scene_name: String) -> String:
	# Unload a scene
	var result = "Unloading scene " + scene_name
	
	main_node.fifth_dimensional_magic("container", scene_name)
	
	return result

func find_objects(query: String) -> String:
	# Search for objects matching the query
	var result = "Searching for objects matching '" + query + "':\n"
	var found_count = 0
	
	# Search through the scene tree
	for branch_name in main_node.scene_tree_jsh["main_root"]["branches"]:
		var branch = main_node.scene_tree_jsh["main_root"]["branches"][branch_name]
		
		if branch_name.to_lower().contains(query.to_lower()):
			result += "  Container: " + branch_name + "\n"
			found_count += 1
		
		if branch.has("things"):
			for thing_name in branch["things"]:
				if thing_name.to_lower().contains(query.to_lower()):
					result += "  Thing: " + branch_name + "/" + thing_name + "\n"
					found_count += 1
	
	if found_count == 0:
		result += "  No objects found matching the query.\n"
	else:
		result += "  Found " + str(found_count) + " object(s).\n"
	
	return result

func display_system_status() -> String:
	# Display current system status
	var status = "System Status:\n"
	
	# Get thread pool status
	var thread_count = thread_pool.get_thread_count()
	var active_tasks = thread_pool.get_active_tasks()
	var queued_tasks = thread_pool.get_queued_tasks()
	
	status += "  Threads: " + str(thread_count) + "\n"
	status += "  Active Tasks: " + str(active_tasks) + "\n"
	status += "  Queued Tasks: " + str(queued_tasks) + "\n"
	
	# Get container counts
	var container_count = 0
	var thing_count = 0
	
	for branch_name in main_node.scene_tree_jsh["main_root"]["branches"]:
		container_count += 1
		
		var branch = main_node.scene_tree_jsh["main_root"]["branches"][branch_name]
		if branch.has("things"):
			thing_count += branch["things"].size()
	
	status += "  Containers: " + str(container_count) + "\n"
	status += "  Things: " + str(thing_count) + "\n"
	
	# Get current frame rate
	var fps = Engine.get_frames_per_second()
	status += "  FPS: " + str(fps) + "\n"
	
	return status

func display_memory_usage() -> String:
	# Display memory usage
	var memory = "Memory Usage:\n"
	
	# Get Godot's internal memory stats
	var stats = Performance.get_monitor(Performance.MEMORY_STATIC)
	var stats_mb = stats / (1024.0 * 1024.0)
	
	memory += "  Static Memory: " + str(snapped(stats_mb, 0.01)) + " MB\n"
	
	# Dynamic memory
	var dynamic_mem = Performance.get_monitor(Performance.MEMORY_DYNAMIC)
	var dynamic_mb = dynamic_mem / (1024.0 * 1024.0)
	
	memory += "  Dynamic Memory: " + str(snapped(dynamic_mb, 0.01)) + " MB\n"
	
	# Objects count
	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	memory += "  Object Count: " + str(object_count) + "\n"
	
	# Node count
	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	memory += "  Node Count: " + str(node_count) + "\n"
	
	# Resource count
	var resource_count = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	memory += "  Resource Count: " + str(resource_count) + "\n"
	
	return memory

func set_variable(var_name: String, value: String) -> String:
	# Set a terminal variable
	if terminal_states.has(var_name):
		terminal_states[var_name] = value
		return "Variable '" + var_name + "' set to '" + value + "'"
	else:
		return "Unknown variable: " + var_name
	#
#func get_variable_value(name: String) -> String:
	## Get a terminal variable value
	#if terminal_states.has(name):
#










func register_command(command: String, handler_object: Object, handler_method: String):
	console_mutex.lock()
	command_handlers[command] = {
		"object": handler_object,
		"method": handler_method,
		"usage": "",
		"help": ""
	}
	console_mutex.unlock()

func set_command_help(command: String, usage: String, help_text: String):
	if not command_handlers.has(command):
		return false
		
	console_mutex.lock()
	command_handlers[command]["usage"] = usage
	command_handlers[command]["help"] = help_text
	console_mutex.unlock()
	return true

func process_command_new(command_text: String) -> Dictionary:
	# Add to history
	console_mutex.lock()
	command_history.append({
		"command": command_text,
		"timestamp": Time.get_ticks_msec()
	})
	
	if command_history.size() > max_history:
		command_history.remove_at(0)
	console_mutex.unlock()
	
	# Parse command
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return {"success": false, "message": "Empty command"}
		
	var cmd = parts[0].to_lower()
	
	# Check for alias
	if COMMAND_ALIASES.has(cmd):
		cmd = COMMAND_ALIASES[cmd]
	
	# Check if command exists
	if not command_handlers.has(cmd):
		add_output_line("Unknown command: " + cmd)
		return {"success": false, "message": "Unknown command: " + cmd}
	
	# Extract arguments
	var args = []
	if parts.size() > 1:
		args = parts.slice(1)
	
	# Execute command
	var handler = command_handlers[cmd]
	var result = handler["object"].call(handler["method"], args)
	
	# Log result
	if result is String:
		add_output_line(result)
		return {"success": true, "message": result}
	elif result is Dictionary and result.has("message"):
		add_output_line(result["message"])
		return result
	else:
		return {"success": true, "result": result}

func add_output_line(text: String):
	console_mutex.lock()
	output_lines.append({
		"text": text,
		"timestamp": Time.get_ticks_msec()
	})
	
	if output_lines.size() > max_output_lines:
		output_lines.remove_at(0)
	console_mutex.unlock()

func get_output_history(count: int = -1) -> Array:
	console_mutex.lock()
	var result
	if count < 0 or count >= output_lines.size():
		result = output_lines.duplicate()
	else:
		result = output_lines.slice(output_lines.size() - count)
	console_mutex.unlock()
	return result

func clear_output():
	console_mutex.lock()
	output_lines.clear()
	console_mutex.unlock()
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      










































#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      



func register_command_add(command_name: String, object: Object, method: String, 
					 description: String = "", args: Array = []):
	commands[command_name] = {
		"object": object,
		"method": method,
		"description": description,
		"args": args
	}

func execute_commandddd():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command
	if thread_pool and thread_pool.has_method("submit_task"):
		thread_pool.submit_task(self, "process_command", [current_command], "terminal_command")
	else:
		var test_string = "string_test"
		process_command(test_string)
		#([current_command])
	
	current_command = ""
	update_command_line()


# Terminal UI Functions
func add_command_character(character: String):
	current_command += character
	update_command_line()

func remove_command_character():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()

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

func update_command_line():
	# Remove existing command text
	var children_cmd
	if command_line:
		children_cmd = command_line.get_children()
	
	if children_cmd:
		for child in command_line.get_children():
			child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = create_3d_letter(current_command[i], Vector3(i * config.char_spacing, 0, 0))
		if command_line:
			FloodgateController.universal_add_child(letter, command_line)
	
	# Add blinking cursor
	var command_cursor = create_3d_letter("_", Vector3(current_command.length() * config.char_spacing, 0, 0))
	command_cursor.name = "cursor"
	if command_line:
		FloodgateController.universal_add_child(command_cursor, command_line)

# Text visualization and manipulation
func add_text_line(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing - 1.0, 0))
	
	# Reposition existing lines
	reposition_text_lines()

func create_delimiter_instance(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("terminal_3d/delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance




func remove_floating_word(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		
		# Remove any connections to this word
		clean_word_connections(text)
		
		word_data.node.queue_free()
		floating_words.erase(text)

func clean_word_connections(text_key: String):
	# Remove connections associated with this text
	for i in range(connection_lines.size()-1, -1, -1):
		if connection_lines[i].has_meta("source") and connection_lines[i].get_meta("source") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)
			
		elif connection_lines[i].has_meta("target") and connection_lines[i].get_meta("target") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)

func reposition_text_lines():
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			# Store target position
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)



# Public API
func toggle_visibility():
	terminal_node.visible = !terminal_node.visible
	emit_signal("terminal_toggled", terminal_node.visible)

func clear_terminall():
	for text in floating_words.keys():
		remove_floating_word(text)
	terminal_text.clear()
	
	# Add back the welcome message
	add_text_line("JSH|Ethereal|Engine|Console|System")
	add_text_line("Type|'help'|for|available|commands")

func set_terminal_shape(shape: String):
	if shape in shape_transforms:
		current_shape = shape
		add_text_line("Changed|terminal|shape|to|" + shape)

func log_message(message: String, type: int = LogType.INFO):
	var _type_color = colors.info
	match type:
		LogType.WARNING: _type_color = colors.warning
		LogType.ERROR: _type_color = colors.error
		LogType.SUCCESS: _type_color = colors.success
		LogType.COMMAND: _type_color = colors.command
	
	add_text_line(message)
	emit_signal("log_added", message, type)

# Command implementations
func _cmd_help(args: Array):
	if args.size() > 0:
		var cmd_name = args[0]
		if commands.has(cmd_name):
			var cmd = commands[cmd_name]
			var usage = cmd_name
			for arg in cmd.args:
				usage += "|<" + arg + ">"
				
			add_text_line("Command:|" + cmd_name)
			add_text_line("Description:|" + cmd.description)
			add_text_line("Usage:|" + usage)
			return "Help for: " + cmd_name
		else:
			add_text_line("Command|not|found:|" + cmd_name)
			return "Command not found"
	
	add_text_line("Available|commands:")
	var command_list = commands.keys()
	command_list.sort()
	
	for cmd in command_list:
		add_text_line("--|" + cmd + "|" + commands[cmd].description)
	
	return "Help displayed"

func _cmd_clear(_args: Array):
	clear_terminal()
	return "Console cleared"

func _cmd_shape(args: Array):
	if args.size() > 0:
		var shape_name = args[0]
		if shape_transforms.has(shape_name):
			set_terminal_shape(shape_name)
			return "Shape changed to: " + shape_name
		else:
			add_text_line("Unknown|shape:|" + shape_name)
			add_text_line("Available|shapes:|" + "|".join(shape_transforms))
			return "Unknown shape"
	else:
		add_text_line("Current|shape:|" + current_shape)
		add_text_line("Available|shapes:|" + "|".join(shape_transforms))
		return "Shape info displayed"

func _cmd_snake(_args: Array):
	add_text_line("Launching|snake|game...")
	call_deferred("launch_snake_game")
	return "Snake game launched"




#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

#
#func _cmd_list(args: Array):
	#if args.
#


# JSH_console.gd
# res://code/gdscript/scripts/Menu_Keyboard_Console/JSH_console.gd
#
# JSH_World/JSH_computer_window

# JSH Console System
#



#var terminal_initialized = false
#var terminal_node = null
## References
#var thread_pool = null
#var camera = null
#var main_node = null
#var task_manager = null
#var material_cache := {}
#var commands: Dictionary = {}






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#




#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func _ready_older():
	setup_terminal_container()
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func _ready_old():
	setup_terminal_container()
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")




# Crenqnie SiSysrtem JSH too 
func _ready_new_v1():
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





func _ready_new():
	# Set up references
	thread_pool = get_node_or_null("/root/thread_pool_autoload")
	camera = get_viewport().get_camera_3d()
	main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_node("JSH_task_manager"):
		task_manager = main_node.get_node("JSH_task_manager")
	
	setup_containers()
	setup_material_cache()
	
	# Initial container visibility
	grid_container.visible = false
	shape_container.visible = false
	file_viewer.visible = false
	node_viewer.visible = false
	
	# Load functions from main node if available
	if main_node:
		load_function_network(main_node)
	
	# Welcome message
	add_text_line("JSH|Ethereal|Engine|3D|Terminal")
	add_text_line("Type|'help'|for|available|commands")


func _ready_new_v2():
	# Setup UI components
	_setup_ui()
	
	# Connect signals
	input_field.text_submitted.connect(_on_input_submitted)
	console_ui.visibility_changed.connect(_on_visibility_changed)
	
	# Hide console initially
	console_ui.visible = false
	
	# Log startup message
	log_message("JSH Console System initialized", LogType.INFO)





#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func check_terminal_combo_pattern() -> String:
	# Check for each combo pattern
	for combo_name in terminal_combo_patterns:
		var pattern = terminal_combo_patterns[combo_name]
		
		# Pattern is longer than our current sequence
		if pattern.size() > terminal_combo_sequence.size():
			continue
		
		# Check if the end of our sequence matches the pattern
		var match_found = true
		for i in range(pattern.size()):
			var seq_index = terminal_combo_sequence.size() - pattern.size() + i
			var cmd = terminal_combo_sequence[seq_index].split(" ")[0].to_lower()
			
			if cmd != pattern[i]:
				match_found = false
				break
		
		if match_found:
			return combo_name
	
	return ""
#
func _init_new():
	name = "JSH_3D_terminal"
	



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓•  •
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛ 
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P      v
# the real functions are here too
func _init_new_v2():
	# Register default commands
	register_command("help", self, "_cmd_help")#, 
		#"Display available commands", ["command_name (optional)"])
	register_command("clear", self, "_cmd_clear")#, 
		#"Clear the console output")
	register_command("history", self, "_cmd_history")#, 
	#	"Show command history")
	register_command("echo", self, "_cmd_echo")#, 
		#"Echo text back to console", ["text"])





#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#



func _init_new_v1():
	name = "JSH_3D_terminal"


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func _init_old():
	name = "JSH_3D_terminal"
	






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# Crenqnie SiSysrtem JSH too 
























# JSH Console System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

# Crenqnie SiSysrtem JSH too 

##
#

# Crenqnie SiSysrtem JSH too 
# ready


func update_letter_visuals_new_v2():
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
					var x = (i % int(edge_length)) - edge_length/2.0
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2.0
					var z = (i / int(edge_length * edge_length)) - edge_length/2.0
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

func update_letter_visuals_new():
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
					var x = (i % int(edge_length)) - edge_length/2.0
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2.0
					var z = (i / int(edge_length * edge_length)) - edge_length/2.0
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

func update_word_connections_new_v2():
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

func update_letter_visuals_new_v1():
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
					var x = (i % int(edge_length)) - edge_length/2.0
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2.0
					var z = (i / int(edge_length * edge_length)) - edge_length/2.0
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

func update_primitive_shape(shape_type: String, params: Dictionary):
	current_primitive = shape_type
	primitive_params = params
	
	var mesh = null
	var material = material_cache[current_shape].duplicate()
	
	match shape_type:
		"sphere":
			mesh = SphereMesh.new()
			mesh.radius = params.get("radius", 1.0)
			mesh.height = params.get("radius", 1.0) * 2.0
			mesh.radial_segments = primitive_resolution
			mesh.rings = primitive_resolution / 2.0
		"box":
			mesh = BoxMesh.new()
			mesh.size = Vector3(
				params.get("size", Vector2(1.0, 1.0)).x,
				params.get("size", Vector2(1.0, 1.0)).y,
				params.get("size", Vector2(1.0, 1.0)).x
			)
		"torus":
			mesh = TorusMesh.new()
			mesh.inner_radius = params.get("inner_radius", 0.5)
			mesh.outer_radius = params.get("outer_radius", 1.0)
			mesh.rings = primitive_resolution
			mesh.ring_segments = primitive_resolution
		"cylinder":
			mesh = CylinderMesh.new()
			mesh.top_radius = params.get("radius", 1.0)
			mesh.bottom_radius = params.get("radius", 1.0)
			mesh.height = params.get("height", 2.0)
			mesh.radial_segments = primitive_resolution
		"capsule":
			mesh = CapsuleMesh.new()
			mesh.radius = params.get("radius", 1.0)
			mesh.height = params.get("height", 2.0)
			mesh.radial_segments = primitive_resolution
	
	primitive_mesh.mesh = mesh
	primitive_mesh.material_override = material

func update_command_line_new():
	# Remove existing command text
	for child in command_line.get_children():
		child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = create_3d_letter(current_command[i], Vector3(i * config.char_spacing, 0, 0))
		FloodgateController.universal_add_child(letter, command_line)
	
	# Add blinking cursor
	var input_cursor = create_3d_letter("_", Vector3(current_command.length() * config.char_spacing, 0, 0))
	input_cursor.name = "cursor"
	FloodgateController.universal_add_child(input_cursor, command_line)

func update_word_connections():
	# Clean up old connections first
	for line in connection_lines:
		line.queue_free()
	connection_lines.clear()
	
	# Connect functions that have been called or referenced together
	for func_name in function_network:
		var func_data = function_network[func_name]
		
		if func_data.has("calls") and func_data.calls.size() > 0:
			for called_func in func_data.calls:
				if function_network.has(called_func):
					create_function_connection(func_name, called_func)

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
			
			# Skip special coloring for special words
			var is_special = false
			
			if letter_node.has_meta("word"):
				var word = letter_node.get_meta("word")
				if function_network.has(word) or path_network.has(word) or node_network.has(word):
					is_special = true
					
					# Keep special coloring with slight pulsing
					if function_network.has(word):
						text_mesh.modulate = Color(
							0.8, 
							0.4 + 0.1 * sin(time * 2.0 + i * 0.2), 
							0.0
						)
					elif path_network.has(word):
						text_mesh.modulate = Color(
							0.2, 
							0.6 + 0.1 * sin(time * 2.0 + i * 0.2), 
							0.3
						)
					elif node_network.has(word):
						text_mesh.modulate = Color(
							0.6, 
							0.3, 
							0.8 + 0.1 * sin(time * 2.0 + i * 0.2)
						)
			
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
					var x = (i % int(edge_length)) - edge_length/2.0
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2.0
					var z = (i / int(edge_length * edge_length)) - edge_length/2.0
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
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# update



# commands

func remove_floating_word_new_v2(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		word_data.node.queue_free()
		floating_words.erase(text)

func reposition_text_lines_new_v2():
	var line_pos = Vector3(0, 0, 0)
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)




#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# reposition


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

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# remove

func remove_floating_word_new_v1(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		word_data.node.queue_free()
		floating_words.erase(text)


#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# update was


func launch_snake_game_new():
	var main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_method("show_snake_game"):
		main_node.show_snake_game()
	elif has_method("create_snake_game"):
		create_snake_game()

# remove

func remove_command_character_new_v1():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()





#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# execute

func execute_command_new_v3():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command (e.g., submit to main command processor)
	if thread_pool and thread_pool.has_method("submit_task"):
		thread_pool.submit_task(process_command, [current_command], "terminal_command")
	else:
		var some_string_test = "string_test"
		process_command(some_string_test)
		#([current_command])
	
	current_command = ""
	update_command_line()










#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# Crenqnie SiSysrtem JSH too 

# create

# we create a lot

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



func create_snake_game():
	var snake_scene = load("res://scripts/jsh_snake_game.gd")
	if snake_scene:
		var snake_instance = snake_scene.new()
		add_child(snake_instance)
		
		# Position the snake game 
		snake_instance.position = Vector3(0, 0, -10)
		snake_instance.rotation.y = 0
		
		print("Snake game created in terminal")
	else:
		add_text_line("Error:|Could not load snake game")


func create_3d_text_terminal(position: Vector3, size: Vector2) -> Node3D:
	var terminal_container = Node3D.new()
	terminal_container.name = "jsh_terminal_3d"
	
	# Create terminal background
	var background = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size.x, size.y)
	background.mesh = plane_mesh
	FloodgateController.universal_add_child(background, terminal_container)
	
	# Create text container
	var text_container = Node3D.new()
	text_container.name = "text_container"
	FloodgateController.universal_add_child(text_container, terminal_container)
	
	# Position the terminal
	terminal_container.global_position = position
	
	return terminal_container


func create_grid_primitive(data):
	print("data ", data)

func create_function_connection(source_func: String, target_func: String):
	# Find positions for these functions in the terminal
	var source_pos = null
	var target_pos = null
	
	# Search in current text for these functions
	for text in floating_words:
		var word_data = floating_words[text]
		
		for i in range(word_data.words_text.size()):
			var word = word_data.words_text[i]
			
			if word == source_func and source_pos == null:
				source_pos = word_data.node.global_position + word_data.words[i].position
				
			if word == target_func and target_pos == null:
				target_pos = word_data.node.global_position + word_data.words[i].position
				
			if source_pos != null and target_pos != null:
				break
		
		if source_pos != null and target_pos != null:
			break
	
	if source_pos != null and target_pos != null:
		# Create a line between the two functions
		var line = MeshInstance3D.new()
		line.name = "function_connection"
		
		# Create the mesh - a thin cylinder oriented between the points
		var mesh = CylinderMesh.new()
		var length = source_pos.distance_to(target_pos)
		mesh.height = length
		mesh.top_radius = 0.02
		mesh.bottom_radius = 0.02
		
		line.mesh = mesh
		line.material_override = material_cache.function.duplicate()
		
		# Position and orient the line
		var midpoint = (source_pos + target_pos) / 2
		line.global_position = midpoint
		
		# Look at target
		var direction = target_pos - source_pos
		if direction.length() > 0.001:
			var up_vector = Vector3.UP
			if abs(direction.normalized().dot(up_vector)) > 0.99:
				up_vector = Vector3.FORWARD
			line.look_at_from_position(midpoint, target_pos, up_vector)
			
		# Rotate to align with cylinder orientation
		line.rotate_object_local(Vector3.RIGHT, PI/2)
		
		# Store metadata
		line.set_meta("source_func", source_func)
		line.set_meta("target_func", target_func)
		
		add_child(line)
		connection_lines.append(line)




func create_delimiter_instance_new(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance

func create_floating_text_new_v2(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	FloodgateController.universal_add_child(text_node, text_container)
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
		FloodgateController.universal_add_child(word_node, text_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			FloodgateController.universal_add_child(letter, word_node)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = create_delimiter_instance(Vector3(word.length() * config.char_spacing + 0.1, 0, 0))
			FloodgateController.universal_add_child(delim, word_node)
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
		"shape": current_shape
	}
	
	return text_node

func create_3d_letter_new_v2(letter: String, position: Vector3) -> Node3D:
	var letter_container = Node3D.new()
	letter_container.position = position
	
	# Create both visual representations
	var text_mesh = Label3D.new()
	text_mesh.text = letter
	text_mesh.font_size = 64
	text_mesh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_mesh.no_depth_test = true
	text_mesh.scale = Vector3.ONE * config.letter_scale
	FloodgateController.universal_add_child(text_mesh, letter_container)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	FloodgateController.universal_add_child(cube, letter_container)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container

# we need new bracet too ?
# which one, where, do we loop

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
	FloodgateController.universal_add_child(text_mesh, letter_container)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	FloodgateController.universal_add_child(cube, letter_container)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container



func create_delimiter_instance_new_v1(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance


func create_floating_text_new_v1(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	FloodgateController.universal_add_child(text_node, text_container)
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
		FloodgateController.universal_add_child(word_node, text_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			FloodgateController.universal_add_child(letter, word_node)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = create_delimiter_instance(Vector3(word.length() * config.char_spacing + 0.1, 0, 0))
			FloodgateController.universal_add_child(delim, word_node)
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
		"shape": current_shape
	}
	
	return text_node

func create_snake_game_new():
	var snake_scene = load("res://scripts/jsh_snake_game.gd")
	if snake_scene:
		var snake_instance = snake_scene.new()
		add_child(snake_instance)
		
		# Position the snake game 
		snake_instance.position = Vector3(0, 0, -10)
		snake_instance.rotation.y = 0
		
		print("Snake game created in terminal")
	else:
		add_text_line("Error:|Could not load snake game")

func create_delimiter_instance_new_v2(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance

func create_delimiter_instance_new_v23(position: Vector3) -> MeshInstance3D:
	var prototype = get_node("delimiter_prototype")
	var instance = prototype.duplicate()
	instance.visible = true
	instance.position = position
	return instance


func create_floating_text_new(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	FloodgateController.universal_add_child(text_node, text_container)
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
		FloodgateController.universal_add_child(word_node, text_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			FloodgateController.universal_add_child(letter, word_node)
			
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
			FloodgateController.universal_add_child(delim, word_node)
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

func create_3d_letter_new(letter: String, position: Vector3) -> Node3D:
	var letter_container = Node3D.new()
	letter_container.position = position
	
	# Create both visual representations
	var text_mesh = Label3D.new()
	text_mesh.text = letter
	text_mesh.font_size = 64
	text_mesh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_mesh.no_depth_test = true
	text_mesh.scale = Vector3.ONE * config.letter_scale
	FloodgateController.universal_add_child(text_mesh, letter_container)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	FloodgateController.universal_add_child(cube, letter_container)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container


func create_3d_letter_new_v1(letter: String, position: Vector3) -> Node3D:
	var letter_container = Node3D.new()
	letter_container.position = position
	
	# Create both visual representations
	var text_mesh = Label3D.new()
	text_mesh.text = letter
	text_mesh.font_size = 64
	text_mesh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_mesh.no_depth_test = true
	text_mesh.scale = Vector3.ONE * config.letter_scale
	FloodgateController.universal_add_child(text_mesh, letter_container)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	FloodgateController.universal_add_child(cube, letter_container)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container



func create_floating_text(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	FloodgateController.universal_add_child(text_node, text_container)
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
		FloodgateController.universal_add_child(word_node, text_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			FloodgateController.universal_add_child(letter, word_node)
			
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
		
		# Check if this is a known function to highlight
		if function_network.has(word):
			for letter_node in letter_nodes:
				var text_mesh = letter_node.get_meta("text_mesh")
				text_mesh.modulate = Color(0.8, 0.4, 0.0)  # Function color
		
		# Check if this is a known path to highlight
		elif path_network.has(word):
			for letter_node in letter_nodes:
				var text_mesh = letter_node.get_meta("text_mesh")
				text_mesh.modulate = Color(0.2, 0.6, 0.3)  # File path color
		
		# Check if this is a known node to highlight
		elif node_network.has(word):
			for letter_node in letter_nodes:
				var text_mesh = letter_node.get_meta("text_mesh")
				text_mesh.modulate = Color(0.6, 0.3, 0.8)  # Node color
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = create_delimiter_instance(Vector3(word.length() * config.char_spacing + 0.1, 0, 0))
			FloodgateController.universal_add_child(delim, word_node)
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
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# where, we need console terminal window, something, i made menu

# add

func add_command_character_new(character: String):
	current_command += character
	update_command_line()

func add_command_character_new_v1(character: String):
	current_command += character
	update_command_line()

func add_text_line_new_v1(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Reposition existing lines
	reposition_text_lines()

func add_text_line_n3(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Process for keyword matches and function references
	process_keywords(text)
	
	# Find and connect functions
	process_function_references(text)
	
	# Reposition existing lines
	reposition_text_lines()
	
	# Update connections
	update_word_connections()

func add_path_to_network(data):
	print("add path to network " , data)

func add_node_to_network(data):
	print("add node to network ", data)

func add_command_character_n3(character: String):
	current_command += character
	update_command_line()

func add_log(message: String, type: int = LogType.INFO):
	log_message(message, type)

func add_text_line_new(text: String):
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

func add_text_line_new_v2(text: String):
	if terminal_text.size() >= config.max_visible_lines:
		var oldest = terminal_text.pop_front()
		if floating_words.has(oldest):
			remove_floating_word(oldest)
	
	terminal_text.append(text)
	create_floating_text(text, Vector3(0, terminal_text.size() * config.line_spacing, 0))
	
	# Reposition existing lines
	reposition_text_lines()








#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# command

func execute_command_new_v1(text):
	print("execute new command ", text)

func clear_terminal_n3():
	for text in floating_words.keys():
		remove_floating_word(text)
	terminal_text.clear()

func launch_snake_game():
	var main_node = get_node_or_null("/root/main")
	if main_node and main_node.has_method("show_snake_game"):
		main_node.show_snake_game()
	elif has_method("create_snake_game"):
		create_snake_game()






func execute_command_new():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	



func remove_command_character_n3():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()

func execute_command_new_n1():
	add_text_line("> " + current_command)
	command_history.append(current_command)
	history_position = command_history.size()
	
	# Process command (e.g., submit to main command processor)
	if thread_pool and thread_pool.has_method("submit_task"):
		thread_pool.submit_task(process_command, [current_command], "terminal_command")
	else:
		var string_test = "test_string"
		var process_command = string_test
		
		#([current_command])
	
	current_command = ""
	update_command_line()
























#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# what we maybe had before

# setup
##
func setup_grid():
	print("data setup grid")
##
func setup_shape_viewer():
	print(" setup shape viewer")

func setup_containers():
	# Text container
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Command line
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	FloodgateController.universal_add_child(command_line, text_container)
	
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
	
	# File viewer
	file_viewer = Node3D.new()
	file_viewer.name = "file_viewer"
	file_viewer.position = Vector3(0, 0, -8)
	add_child(file_viewer)
	
	# Node viewer
	node_viewer = Node3D.new()
	node_viewer.name = "node_viewer"
	node_viewer.position = Vector3(0, 0, -8)
	add_child(node_viewer)
	
	# Create delimiter mesh prototype
	var delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_prototype"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	delimiter_mesh.visible = false
	add_child(delimiter_mesh)
	
	# Setup grid
	setup_grid_viewer()
	
	# Setup shape viewer
	setup_shape_viewer()


func setup_material_cache():
	# Create standard materials for reuse
	var base_mat = MaterialLibrary.get_material("default")
	base_mat.albedo_color = Color(0.8, 0.8, 0.8)
	base_mat.metallic = 0.2
	base_mat.roughness = 0.3
	material_cache["default"] = base_mat
	
	var highlight_mat = MaterialLibrary.get_material("default")
	highlight_mat.albedo_color = Color(0.2, 0.8, 1.0)
	highlight_mat.emission_enabled = true
	highlight_mat.emission = Color(0.2, 0.6, 1.0)
	highlight_mat.emission_energy = 0.5
	material_cache["highlight"] = highlight_mat
	
	var grid_mat = MaterialLibrary.get_material("default")
	grid_mat.albedo_color = Color(0.2, 0.2, 0.3, 0.5)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["grid"] = grid_mat
	
	var connection_mat = MaterialLibrary.get_material("default")
	connection_mat.albedo_color = config.connection_color
	connection_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["connection"] = connection_mat
	
	var function_mat = MaterialLibrary.get_material("default")
	function_mat.albedo_color = Color(0.8, 0.4, 0.0)
	function_mat.emission_enabled = true
	function_mat.emission = Color(0.8, 0.4, 0.0)
	function_mat.emission_energy = 0.3
	material_cache["function"] = function_mat
	
	var file_mat = MaterialLibrary.get_material("default")
	file_mat.albedo_color = Color(0.2, 0.6, 0.3)
	file_mat.emission_enabled = true
	file_mat.emission = Color(0.2, 0.6, 0.3)
	file_mat.emission_energy = 0.3
	material_cache["file"] = file_mat
	
	var node_mat = MaterialLibrary.get_material("default")
	node_mat.albedo_color = Color(0.6, 0.3, 0.8)
	node_mat.emission_enabled = true
	node_mat.emission = Color(0.6, 0.3, 0.8)
	node_mat.emission_energy = 0.3
	material_cache["node"] = node_mat
	
	# Create materials for each shape transform
	for shape in shape_transforms:
		var shape_mat = MaterialLibrary.get_material("default")
		
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



## here we need change
## dimensional magic?
## step 2? maybe 5?
# as now i use only one core and main thread for load unload add move node to change path?
# multi threads to change and calculate data, the same for shaders to calculate
# and calculate shaders for seeeds and random numbers in limits and clamps and points of starts and rotation of galaxy

# speeds planets moons orbits rotations movements
# rivers oceans

# and Claude wanna snake and computer, even there was an apple in function name 
# vars functions
# nodes names
# files paths

# it all connects in some ways

# to get node i made tree and dictionary too, a lot of it that i tested and used
# Claude and Luminus think different
# i think in way i see when i write

# even seeing it once at one string, means we already group and collect it, then we create shapes from them
# thats what i need too, a biome creater of 3d shapes and bubbles? value of vertex x, y, or z need to change color, value was from -1 to 1 probably or 0 1 to so kinda the same
# need to multiply or 0. multiply



func setup_grid_viewer():
	# Clear existing grid
	for cell in grid_cells:
		cell.queue_free()
	grid_cells.clear()
	
	# Create grid cells
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				var cell = MeshInstance3D.new()
				cell.name = "grid_cell_%d_%d_%d" % [x, y, z]
				
				var mesh = BoxMesh.new()
				mesh.size = Vector3.ONE * grid_cell_size * 0.8
				
				cell.mesh = mesh
				cell.material_override = material_cache.grid.duplicate()
				cell.position = Vector3(
					(x - grid_size.x/2) * grid_cell_size, 
					(y - grid_size.y/2) * grid_cell_size, 
					(z - grid_size.z/2) * grid_cell_size
				)
				cell.visible = false  # Start with empty grid
				
				# Store grid position in metadata
				cell.set_meta("grid_pos", Vector3i(x, y, z))
				
				FloodgateController.universal_add_child(cell, grid_container)
				grid_cells.append(cell)
	
	# Create grid highlight cursor
	grid_highlight = MeshInstance3D.new()
	grid_highlight.name = "grid_highlight"
	
	var highlight_mesh = BoxMesh.new()
	highlight_mesh.size = Vector3.ONE * grid_cell_size
	
	grid_highlight.mesh = highlight_mesh
	grid_highlight.material_override = material_cache.highlight.duplicate()
	grid_highlight.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_highlight.material_override.albedo_color.a = 0.3
	
	FloodgateController.universal_add_child(grid_highlight, grid_container)

func setup_containers_new():
	# Text container
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Command line
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	FloodgateController.universal_add_child(command_line, text_container)
	
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
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	delimiter_mesh.visible = false
	add_child(delimiter_mesh)

func setup_material_cache_new():
	# Create some standard materials for reuse
	var base_mat = MaterialLibrary.get_material("default")
	base_mat.albedo_color = Color(0.8, 0.8, 0.8)
	base_mat.metallic = 0.2
	base_mat.roughness = 0.3
	material_cache["default"] = base_mat
	
	var highlight_mat = MaterialLibrary.get_material("default")
	highlight_mat.albedo_color = Color(0.2, 0.8, 1.0)
	highlight_mat.emission_enabled = true
	highlight_mat.emission = Color(0.2, 0.6, 1.0)
	highlight_mat.emission_energy = 0.5
	material_cache["highlight"] = highlight_mat
	
	var grid_mat = MaterialLibrary.get_material("default")
	grid_mat.albedo_color = Color(0.2, 0.2, 0.3, 0.5)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["grid"] = grid_mat
	
	var connection_mat = MaterialLibrary.get_material("default")
	connection_mat.albedo_color = config.connection_color
	connection_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["connection"] = connection_mat
	
	# Create materials for each shape transform
	for shape in shape_transforms:
		var shape_mat = MaterialLibrary.get_material("default")
		
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

func setup_terminal_container_new():
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Command line (where user types)
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	FloodgateController.universal_add_child(command_line, text_container)
	
	# Create delimiter mesh prototype
	var delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_prototype"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	delimiter_mesh.visible = false
	add_child(delimiter_mesh)


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

func setup_shape_viewer_new():
	# Create primitive mesh
	primitive_mesh = MeshInstance3D.new()
	primitive_mesh.name = "primitive_mesh"
	FloodgateController.universal_add_child(primitive_mesh, shape_container)
	
	# Set default shape
	update_primitive_shape("sphere", {"radius": 1.0})


func _setup_ui():
	# Create console UI components
	console_ui = Control.new()
	console_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	console_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_top = 10
	vbox.offset_left = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	
	output_container = ScrollContainer.new()
	output_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	output_text = RichTextLabel.new()
	output_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_text.scroll_following = true
	output_text.selection_enabled = true
	output_text.bbcode_enabled = true
	
	input_field = LineEdit.new()
	input_field.placeholder_text = "Enter command..."
	input_field.clear_button_enabled = true
	
	FloodgateController.universal_add_child(output_text, output_container)
	FloodgateController.universal_add_child(output_container, vbox)
	FloodgateController.universal_add_child(input_field, vbox)
	
	FloodgateController.universal_add_child(vbox, panel)
	FloodgateController.universal_add_child(panel, console_ui)
	
	# Add to scene
	add_child(console_ui)


func setup_terminal_container():
	text_container = Node3D.new()
	text_container.name = "text_container"
	add_child(text_container)
	
	# Command line (where user types)
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -3, 0)
	FloodgateController.universal_add_child(command_line, text_container)
	
	# Create delimiter mesh prototype
	var delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_prototype"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = MaterialLibrary.get_material("default")
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
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


# combos
# strings
# commands
# terminal
# input


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






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func set_terminal_shape_new(shape: String):
	if shape in shape_transforms:
		current_shape = shape
		add_text_line("Changed|terminal|shape|to|" + shape)





#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func clear_terminal_new():
	for text in floating_words.keys():
		remove_floating_word(text)
	terminal_text.clear()

func remove_floating_word_new(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		
		# Remove any connections to this word
		clean_word_connections(text)
		
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




#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func toggle_gravity_effects_new():
	config.float_amount = 0.05 if config.float_amount < 0.02 else 0.01

func toggle_gravity_effects():
	config.float_amount = 0.05 if config.float_amount < 0.02 else 0.01

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






















#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func remove_command_character_new():
	if current_command.length() > 0:
		current_command = current_command.substr(0, current_command.length() - 1)
		update_command_line()























































































#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# Crenqnie SiSysrtem JSH too 

func _process_new(delta):
	# Update time accumulator for animations
	time_accumulator = delta
	
	# Update letter visuals
	update_letter_visuals()
	
	# Make terminal face camera
	if camera:
		var camera_pos = camera.global_position
		camera_pos.y = global_position.y  # Keep y level the same
		look_at(camera_pos, Vector3.UP)
		rotation.z = 0  # Keep upright
		
		# Update center point (used for distance calculations)
		center_point = global_position



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func _process_old(delta):
	# Update time accumulator for animations
	time_accumulator = delta
	
	# Update letter visuals
	update_letter_visuals()
	
	# Make terminal face camera
	if camera:
		var camera_pos = camera.global_position
		camera_pos.y = global_position.y  # Keep y level the same
		look_at(camera_pos, Vector3.UP)
		rotation.z = 0  # Keep upright
		
		# Update center point (used for distance calculations)
		center_point = global_position

func _process_new_v1(_delta):
	# Check for console toggle key
	if Input.is_action_just_pressed("toggle_console"):
		toggle_console()
	
	# Handle command history navigation
	if is_visible and input_field.has_focus():
		if Input.is_action_just_pressed("ui_up") and command_history.size() > 0:
			_navigate_history(-1)
		elif Input.is_action_just_pressed("ui_down") and history_position >= 0:
			_navigate_history(1)















#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func process_terminal_command_(data):
	print("data", data)
	
func process_grid_command(data):
	print("data", data)

func process_shape_command(data):
	print("data", data)


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func process_command_add(args):
	var command = args[0]
	var response = "Command not recognized"
	
	# Handle basic commands
	if command.begins_with("snake"):
		response = "Launching snake game..."
		call_deferred("launch_snake_game")
	elif command == "help":
		response = "Available commands:|help|snake|clear|shape|color|gravity"
	elif command == "clear":
		clear_terminal()
		return {"status": "success", "command": "clear"}
	elif command.begins_with("shape"):
		var parts = command.split(" ")
		if parts.size() > 1 and shape_transforms.has(parts[1]):
			current_shape = parts[1]
			response = "Changing shape to: " + current_shape
		else:
			response = "Available shapes:|sphere|cube|flat|helix|wave"
	elif command.begins_with("color"):
		response = "Grayscale based on distance from center point"
	elif command.begins_with("gravity"):
		response = "Toggling word gravity effects"
		toggle_gravity_effects()
	
	# Add response
	add_text_line(response)
	return {"status": "success", "command": command, "response": response}

func process_command_neww(args):
	var command = args[0]
	var response = "Command not recognized"
	
	# Handle basic commands
	if command.begins_with("snake"):
		response = "Launching snake game..."
		call_deferred("launch_snake_game")
	elif command == "help":
		response = "Available commands:|help|snake|clear|shape|color|gravity"
	elif command == "clear":
		clear_terminal()
		return {"status": "success", "command": "clear"}
	elif command.begins_with("shape"):
		var parts = command.split(" ")
		if parts.size() > 1 and shape_transforms.has(parts[1]):
			current_shape = parts[1]
			response = "Changing shape to: " + current_shape
		else:
			response = "Available shapes:|sphere|cube|flat|helix|wave"
	elif command.begins_with("color"):
		response = "Grayscale based on distance from center point"
	elif command.begins_with("gravity"):
		response = "Toggling word gravity effects"
		toggle_gravity_effects()
	
	# Add response
	add_text_line(response)
	return {"status": "success", "command": command, "response": response}



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func process_keywords_new(text: String):
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






























































#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# Crenqnie SiSysrtem JSH too 

# input

func _inpu(event):
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

# JSH Console System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

# input

func _input_old(event):
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

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# command

func clean_word_connections_new(text_key: String):
	# Remove connections associated with this text
	for i in range(connection_lines.size()-1, -1, -1):
		if connection_lines[i].has_meta("source") and connection_lines[i].get_meta("source") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)
			
		elif connection_lines[i].has_meta("target") and connection_lines[i].get_meta("target") == text_key:
			connection_lines[i].queue_free()
			connection_lines.remove_at(i)
#


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func look_at(data0, data_1):
	print("data", data0, data_1)

func load_function_network(data):
	print("load function network ", data)
##









# remove


func remove_floating_wor(text: String):
	if floating_words.has(text):
		var word_data = floating_words[text]
		
		# Remove any connections to this word
		clean_word_connections(text)
		
		word_data.node.queue_free()
		floating_words.erase(text)


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func clean_word_connection(text_key: String):
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
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func reposition_text_line():
	for i in range(terminal_text.size()):
		var text = terminal_text[i]
		if floating_words.has(text):
			var target_pos = Vector3(0, (i - terminal_text.size() + 1) * config.line_spacing, 0)
			floating_words[text].position = target_pos
			# Animate to target position
			var tween = create_tween()
			tween.tween_property(floating_words[text].node, "position", target_pos, 0.3)
















#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func process_keywords(text: String):
	# Check for keywords in the text
	var words = text.split(config.delimiter, false)
	for word in words:
		# Process file paths
		if word.begins_with("res://") or word.begins_with("/root/") or word.begins_with("D:/"):
			add_path_to_network(word)
			
		# Process nodes
		elif word.find("/") != -1 and not word.begins_with("res://") and not word.begins_with("D:/"):
			add_node_to_network(word)


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            

func process_function_references(text: String):
	var words = text.split(config.delimiter, false)
	
	# Check for function calls format: function_name()
	for i in range(words.size()):
		var word = words[i]
		
		# Check if this might be a function name
		if word.ends_with("()"):
			var func_name = word.substr(0, word.length() - 2)
			#add_function_to










#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            



	# Process command (e.g., submit to main command processor)
	match command_mode:
		"terminal":
			if thread_pool and thread_pool.has_method("submit_task"):
				thread_pool.submit_task(process_terminal_command, [current_command], "terminal_command")
			else:
				process_terminal_command_new([current_command])
		"grid":
			process_grid_command(current_command)
		"shape":
			process_shape_command(current_command)
	
	current_command = ""
	update_command_line()



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func process_terminal_command_new(data):
	print("data ", data)

func register_console_commands(main: Node):
	main_node = main
	
	# Register commands that interact with the main system
	register_command("status", self, "test")#, #self, "_cmd_status", 
		#"Show system status")
	register_command("status", self, "test") 
		#Show memory usage")
	register_command("threads", self, "_cmd_threads") 
		#"Show thread information")
	register_command("create", self, "_cmd_create") 
		#"Create a new object", ["set_name"])
	register_command("unload", self, "_cmd_unload") 
		#"Unload a container", ["container_name"])
	register_command("scene", self, "_cmd_scene")
		#"Set active scene", ["scene_name"])






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            



func navigate_historyy(direction: int):
	if command_history.size() == 0:
		return
		
	var please_work
	
	# size can be in int? as it is size of array? with
	# rotation and position it can be in float? how long
	# i set max to 9 all the time
	
	#
	history_position += direction
	history_position = clamp(history_position, 0, command_history.size())
	
	if history_position == command_history.size():
		current_command = ""
	else:
		current_command = command_history[history_position]
	
	update_command_line()

## terminal
func initialize_3d_terminal():
	var terminal_scene = load("res://scripts/JSH_3D_text_terminal.gd")
	if terminal_scene:
		var terminal = terminal_scene.new()
		terminal.name = "JSH_3D_terminal"
		terminal.position = Vector3(0, 2, -5)  # Position in front of player
		add_child(terminal)
		print("✅ 3D Terminal initialized")
	else:
		print("⚠️ Could not load 3D Terminal scene")




func _on_input_submitted(text: String):
	if text.strip_edges() == "":
		return
	
	# Add to history
	if command_history.size() == 0 or command_history[0] != text:
		command_history.insert(0, text)
		if command_history.size() > max_history:
			command_history.pop_back()
	
	# Reset history position
	history_position = -1
	
	# Log command
	log_message("> " + text, LogType.COMMAND)
	
	# Execute command
	execute_command_new()
	
	# Clear input field
	input_field.text = ""




func _on_visibility_changed():
	is_visible = console_ui.visible
	emit_signal("console_toggled", is_visible)
	
	if is_visible:
		input_field.grab_focus()

func _navigate_history(direction: int):
	if command_history.size() == 0:
		return
	
	history_position += direction
	
	if history_position >= command_history.size():
		history_position = command_history.size() - 1
	
	if history_position < 0:
		history_position = -1
		input_field.text = ""
	else:
		input_field.text = command_history[history_position]
		# Move cursor to end
		input_field.caret_column = input_field.text.length()



func toggle_console():
	console_ui.visible = !console_ui.visible
	if console_ui.visible:
		input_field.grab_focus()

func register_comman(command_name: String, object: Object, method: String, 
					 description: String = "", args: Array = []):
	commands[command_name] = {
		"object": object,
		"method": method,
		"description": description,
		"args": args
	}

func execute_command_new_v2(command_text: String):
	var parts = command_text.split(" ", false)
	if parts.size() == 0:
		return
	
	var command_name = parts[0].to_lower()
	var args = parts.slice(1)
	
	if not commands.has(command_name):
		log_message("Unknown command: " + command_name, LogType.ERROR)
		return
	
	var command = commands[command_name]
	var result
	
	if command.object and command.object.has_method(command.method):
		result = command.object.call(command.method, args)
	else:
		log_message("Command implementation not found: " + command_name, LogType.ERROR)
		return
	
	emit_signal("command_executed", command_name, result)
	
	if result != null:
		log_message(str(result), LogType.INFO)




#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            



func log_messag(message: String, type: int = LogType.INFO):
	
	var log_type_info = LogType.INFO
	var type_copy = log_type_info
	print(" message : " , message)
	
	var timestamp
	var color_tag = ""

	# Trim output if too long
	if output_text.get_line_count() > max_output_lines:
		var current_text = output_text.text
		var lines = current_text.split("\n")
		var excess_lines = lines.size() - max_output_lines
		if excess_lines > 0:
			output_text.text = "\n".join(lines.slice(excess_lines))
	
	emit_signal("log_added", message, type)






#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


##cmd
# Additional commands for main system interaction
# Default command implementations
func _cmd_hel(args: Array):
	if args.size() > 0:
		var cmd_name = args[0]
		if commands.has(cmd_name):
			var cmd = commands[cmd_name]
			var usage = cmd_name
			for arg in cmd.args:
				usage += " <" + arg + ">"
				
			log_message("Command: " + cmd_name, LogType.SUCCESS)
			log_message("Description: " + cmd.description, LogType.INFO)
			log_message("Usage: " + usage, LogType.INFO)
			return
		else:
			log_message("Command not found: " + cmd_name, LogType.ERROR)
			return
	
	log_message("Available commands:", LogType.INFO)
	var command_list = commands.keys()
	command_list.sort()
	
	for cmd in command_list:
		log_message("  " + cmd + " - " + commands[cmd].description, LogType.INFO)
	
	return "Type 'help <command>' for more information"

func _cmd_clea(_args: Array):
	output_text.text = ""
	return "Console cleared"

func _cmd_history(_args: Array):
	if command_history.size() == 0:
		return "Command history is empty"
	
	log_message("Command history:", LogType.INFO)
	for i in range(command_history.size()):
		log_message("  " + str(i + 1) + ". " + command_history[i], LogType.INFO)
	
	return "Total commands: " + str(command_history.size())

## cmd
func _cmd_echo(args: Array):
	return " ".join(args)

func _cmd_status(_args: Array):
	if not main_node:
		return "Main node reference not set"
	
	var metrics = {}
	if main_node.has_method("get_system_metrics"):
		metrics = main_node.get_system_metrics()
	
	log_message("System Status:", LogType.INFO)
	for key in metrics:
		log_message("  " + key + ": " + str(metrics[key]), LogType.INFO)
	
	return "Status report complete"

func _cmd_memory(_args: Array):
	if not main_node:
		return "Main node reference not set"
	
	var memory_info = {}
	if main_node.has_method("check_memory_state"):
		memory_info = main_node.check_memory_state()
	
	log_message("Memory Usage:", LogType.INFO)
	for key in memory_info:
		log_message("  " + key + ": " + str(memory_info[key]) + " bytes", LogType.INFO)
	
	return "Memory report complete"

func _cmd_threads(_args: Array):
	if not main_node:
		return "Main node reference not set"
	
	var thread_info = {}
	if main_node.has_method("check_thread_status_type"):
		thread_info = main_node.check_thread_status_type()
	
	log_message("Thread Information:", LogType.INFO)
	# Display thread info here
	
	return "Thread report complete"

func _cmd_create(args: Array):
	if args.size() < 1:
		return "Usage: create <set_name>"
	
	if not main_node:
		return "Main node reference not set"
	
	var set_name = args[0]
	var result = null
	
	if main_node.has_method("create_new_task"):
		main_node.create_new_task("three_stages_of_creation", set_name)
		result = "Creation task started for: " + set_name
	
	return result

func _cmd_unload(args: Array):
	if args.size() < 1:
		return "Usage: unload <container_name>"
	
	if not main_node:
		return "Main node reference not set"
	
	var container_name = args[0]
	var result = null
	
	if main_node.has_method("unload_container"):
		main_node.unload_container(container_name)
		result = "Unload request sent for: " + container_name
	
	return result

func _cmd_scene(args: Array):
	if args.size() < 1:
		return "Usage: scene <scene_name>"
	
	if not main_node:
		return "Main node reference not set"
	
	var scene_name = args[0]
	var result = null
	
	# Logic to set the scene goes here
	
	return result


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            



func update_command_line_new_v1():
	# Remove existing command text
	for child in command_line.get_children():
		child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = create_3d_letter(current_command[i], Vector3(i * config.char_spacing, 0, 0))
		FloodgateController.universal_add_child(letter, command_line)
	
	# Add blinking cursor
	var cursor = create_3d_letter("_", Vector3(current_command.length() * config.char_spacing, 0, 0))
	cursor.name = "cursor"
	FloodgateController.universal_add_child(cursor, command_line)




func update_command_line_ne():
	# Remove existing command text
	for child in command_line.get_children():
		child.queue_free()
	
	# Create new command text
	for i in range(current_command.length()):
		var letter = create_3d_letter(current_command[i], Vector3(i * config.char_spacing, 0, 0))
		FloodgateController.universal_add_child(letter, command_line)
	
	# Add blinking cursor
	var cursor = create_3d_letter("_", Vector3(current_command.length() * config.char_spacing, 0, 0))
	cursor.name = "cursor"
	FloodgateController.universal_add_child(cursor, command_line)
#

## cmd stop



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P            


func navigate_history_new(direction: int):
	if command_history.size() == 0:
		return
		
	history_position += direction
	history_position = clamp(history_position, 0, command_history.size())
	
	if history_position == command_history.size():
		current_command = ""
	else:
		current_command = command_history[history_position]
	
	update_command_line()
	

func _cmd_statu(_args: Array):
	add_text_line("System|status:")
	
	# Check thread pool state
	if thread_pool:
		var thread_stats = {}
		if thread_pool.has_method("get_thread_stats"):
			thread_stats = thread_pool.get_thread_stats()
			add_text_line("Threads:|" + str(thread_stats.size()) + "|active")
	
	# Check database system state
	var db_system = get_node_or_null("/root/JSH_database_system")
	if db_system and db_system.has_method("get_parse_stats"):
		var stats = db_system.get_parse_stats()
		add_text_line("Database:|" + str(stats.files_processed) + "|files|processed")
	
	# Check task manager state
	if task_manager:
		add_text_line("Task|manager:|active")
	
	return "Status command completed"

func _cmd_load(args: Array):
	if args.size() < 1:
		add_text_line("Usage:|load|<file_path>")
		return "Invalid arguments"
	
	var file_path = args[0]
	add_text_line("Loading|file:|" + file_path)
	
	# Attempt to load the file through the main system
	if main_node and main_node.has_method("load_file"):
		var result = main_node.load_file(file_path)
		if result:
			add_text_line("File|loaded|successfully")
		else:
			add_text_line("Failed|to|load|file")
		return result
	else:
		add_text_line("Error:|Unable|to|access|file|loading|system")
		return "File loading system not available"

func _cmd_creat(args: Array):
	if args.size() < 1:
		add_text_line("Usage:|create|<type>|[name]")
		return "Invalid arguments"
	
	var type = args[0]
	var object_name = args[1] if args.size() > 1 else ""
	
	add_text_line("Creating|" + type + ("|" + object_name if object_name else ""))
	
	# Pass creation to main system
	if main_node and main_node.has_method("three_stages_of_creation"):
		var creation_string = type
		if object_name:
			creation_string += "_" + object_name
		
		main_node.three_stages_of_creation(creation_string)
		return "Creation initiated: " + creation_string
	else:
		add_text_line("Error:|Could|not|access|creation|system")
		return "Creation system not available"



# Setup functions
func setup_terminal_containe():
	# Main container for all terminal elements
	terminal_node = Node3D.new()
	terminal_node.name = "terminal_3d"
	add_child(terminal_node)
	
	# Create window background
	window_mesh = MeshInstance3D.new()
	window_mesh.name = "window_background"
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(8, 5)
	window_mesh.mesh = plane_mesh
	
	var window_material = MaterialLibrary.get_material("default")
	window_material.albedo_color = Color(0.1, 0.1, 0.2, 0.8)
	window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_mesh.material_override = window_material
	
	FloodgateController.universal_add_child(window_mesh, terminal_node)
	
	# Text container
	text_container = Node3D.new()
	text_container.name = "text_container"
	FloodgateController.universal_add_child(text_container, terminal_node)
	
	# Command line
	command_line = Node3D.new()
	command_line.name = "command_line"
	command_line.position = Vector3(0, -2.2, 0.01)  # Slightly in front of window
	FloodgateController.universal_add_child(command_line, terminal_node)
	
	# Create delimiter mesh prototype
	var delimiter_mesh = MeshInstance3D.new()
	delimiter_mesh.name = "delimiter_prototype"
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = 0.3
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 1.0
	
	delimiter_mesh.mesh = mesh
	delimiter_mesh.material_override = material
	delimiter_mesh.visible = false
	FloodgateController.universal_add_child(delimiter_mesh, terminal_node)

func setup_material_cach():
	# Create materials for reuse
	var base_mat = MaterialLibrary.get_material("default")
	base_mat.albedo_color = Color(0.8, 0.8, 0.8)
	base_mat.metallic = 0.2
	base_mat.roughness = 0.3
	material_cache["default"] = base_mat
	
	var highlight_mat = MaterialLibrary.get_material("default")
	highlight_mat.albedo_color = Color(0.2, 0.8, 1.0)
	highlight_mat.emission_enabled = true
	highlight_mat.emission = Color(0.2, 0.6, 1.0)
	highlight_mat.emission_energy = 0.5
	material_cache["highlight"] = highlight_mat
	
	var connection_mat = MaterialLibrary.get_material("default")
	connection_mat.albedo_color = config.connection_color
	connection_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_cache["connection"] = connection_mat
	
	# Create materials for each shape transform
	for shape in shape_transforms:
		var shape_mat = MaterialLibrary.get_material("default")
		
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

# Command Registration and Processing
func register_default_commands():
	register_command("help", self, "_cmd_help")#, 
	#\\\\\\\\\\\\\\\\\\\\\\3	"Display available commands", ["command_name (optional)"])
	register_command("clear", self, "_cmd_clear")#, 
	#	"Clear the console output")
	register_command("shape", self, "_cmd_shape")#, 
	#	"Change the text shape transformation", ["shape_name"])
	register_command("snake", self, "_cmd_snake")#, 
	#	"Launch the snake game")
	register_command("status", self, "_cmd_status")#, 
	#	"Display system status")
	register_command("load", self, "_cmd_load")#, 
	#	"Load a file or resource", ["file_path"])
	register_command("create", self, "_cmd_create")#, 
	#	"Create a new object or container", ["type", "name"])
	register_command("list", self, "_cmd_list")#, 
	#	"List objects of a specific type", ["type"])




func update_letter_visuals_ne():
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
					var x = (i % int(edge_length)) - edge_length/2.0
					var y = ((i / int(edge_length)) % int(edge_length)) - edge_length/2.0
					var z = (i / int(edge_length * edge_length)) - edge_length/2.0
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



func create_floating_text_ne(text: String, position: Vector3) -> Node3D:
	var text_node = Node3D.new()
	text_node.name = "floating_text_" + text.sha1_text().substr(0, 8)
	FloodgateController.universal_add_child(text_node, text_container)
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
		FloodgateController.universal_add_child(word_node, text_node)
		word_nodes.append(word_node)
		
		# Position for this word
		word_node.position.x = x_offset
		
		# Create individual letters in the word
		for i in range(word.length()):
			var letter = create_3d_letter(word[i], Vector3(i * config.char_spacing, 0, 0))
			all_letters.append(letter)
			letter_nodes.append(letter)
			FloodgateController.universal_add_child(letter, word_node)
			
			# Store the letter's word for connection building
			letter.set_meta("word", word)
			letter.set_meta("word_idx", word_idx)
		
		# Add delimiter after word (except the last word)
		if word_idx < words.size() - 1:
			var delim = create_delimiter_instance(Vector3(word.length() * config.char_spacing + 0.1, 0, 0))
			FloodgateController.universal_add_child(delim, word_node)
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

func create_3d_letter_ne(letter: String, position: Vector3) -> Node3D:
	var letter_container = Node3D.new()
	letter_container.position = position
	
	# Create both visual representations
	var text_mesh = Label3D.new()
	text_mesh.text = letter
	text_mesh.font_size = 64
	text_mesh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text_mesh.no_depth_test = true
	text_mesh.scale = Vector3.ONE * config.letter_scale
	FloodgateController.universal_add_child(text_mesh, letter_container)
	
	# Add a small cube as the letter's physical presence
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.08, 0.08, 0.08)
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.9, 0.9, 0.9)
	material.emission_enabled = true
	material.emission = Color(0.8, 0.8, 1.0)
	material.emission_energy = 0.5
	
	cube.mesh = cube_mesh
	cube.material_override = material
	cube.position = Vector3(0, 0, -0.1)  # Slightly behind the text
	FloodgateController.universal_add_child(cube, letter_container)
	
	# Set metadata
	letter_container.set_meta("letter", letter)
	letter_container.set_meta("text_mesh", text_mesh)
	letter_container.set_meta("cube", cube)
	letter_container.set_meta("base_position", position)
	letter_container.set_meta("distance_factor", 1.0)
	
	return letter_container




func process_command_ne(args):
	var command_text = args[0]
	
	# Split by spaces for command arguments
	var parts = command_text.split(" ")
	if parts.size() == 0:
		return {"status": "error", "message": "Empty command"}
		
	var cmd = parts[0].to_lower()
	var cmd_args = parts.slice(1)
	
	if commands.has(cmd):
		var command = commands[cmd]
		var result
		
		if command.object and command.object.has_method(command.method):
			result = command.object.call(command.method, cmd_args)
		else:
			add_text_line("Error:|Command|implementation|not|found:|" + cmd)
			return {"status": "error", "message": "Command implementation not found"}
		
		emit_signal("command_executed", cmd, result)
		return {"status": "success", "command": cmd, "result": result}
	else:
		add_text_line("Unknown|command:|" + cmd)
		add_text_line("Type|'help'|for|available|commands")
		return {"status": "error", "message": "Unknown command"}

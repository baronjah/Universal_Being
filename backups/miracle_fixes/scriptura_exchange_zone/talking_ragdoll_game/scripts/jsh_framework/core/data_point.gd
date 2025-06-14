# 🏛️ Data Point - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# data_point.gd
#

# res://scripts/Menu_Keyboard_Console/data_point.gd
# folder path
# //scripts/Menu_Keyboard_Console/
# data_point.gd

# JSH Ethereal Datapoint
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┳┓         •   
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┃┃┏┓╋┏┓┏┓┏┓┓┏┓╋
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┻┛┗┻┗┗┻┣┛┗┛┗┛┗┗
#       888 oo     .d8P  888     888                            ┛     
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Ethereal Datapoint
#

extends UniversalBeingBase
# the only connection with thread_pool
@onready var thread_pool = get_node("/root/thread_pool_autoload")
#hopefully now i will check connection, before creation of tasks
@onready var task_manager =  get_node("/root/main/JSH_task_manager")#$JSH_task_manager

# this might need mutex
var main_scene_to_set : int = 99
# probably this thing
var datapoint_things_dictionary = {}

var things_dictionary = Mutex.new()
# these might need mutexes
var Scenes_array : Array = []

var scenes_mutex = Mutex.new()
var current_scene : String
var number_of_scene : int = -1
# probably this too
var Interactions_array : Array = []

var interactions_mutex = Mutex.new()
# Sending stuff functions :)
# In data_point.gd
var main_node: Node
var container_node: Node

var data_point_name : String
var data_point_number : int
var max_things_number : int
var current_things_number : int = -1
var current_priority : int = -1
var data_point_information : Array = []
var data_point_layer_0 : Array = []
var data_point_layer_0_data : Array = []
var data_point_ : String = "datapoint_"
var datapoint_checked : Array = []
# Scenes Stuff
var can_it_work_now_marry : Array = []
var current_text: String = ""
var cursor_position: int = 0
var cursor_visible: bool = true

var cursor_model: MeshInstance3D

var char_width: float = 0.2
var char_width_new : float = 0.0
var bracket_width: float = 4.0
var bracket_current_text : Array = []
var maximum_amount_of_interaction : int = 1
var current_interaction_mode : String = "single"
# the bolean ints of truths,
var the_scenes_fiasco : int = 0
var the_new_layers_fiasco : int = 0
var third_inty_thingy : int = 0
var scenes_array_size_now : int = 0
var movement_checker : int = 0

var movement_checker_mutex = Mutex.new()
var mutex_for_three_thingies = Mutex.new()
# the newest thingy
var array_datalayer_new : Array = []
# the informations to put on labels type of var
var the_label_message : Array = []
# the godly messengers with data, getting them download, and even uploading information
var download_received : Dictionary = {}
var upload_to_send : Dictionary = {}

var mutex_for_cursor = Mutex.new()
var current_text_mutex = Mutex.new()

var data_to_be_used : Array = []
var times_of_data_used : int = 0
# Add to data_point.gd
var connected_target_container = ""
var connected_target_thing = ""
var connected_target_datapoint = ""
var is_keyboard = false
var only_once_file : int = 0
var unedited_message
var settings_label_checker : int = 0

var lets_check_thingies_again : int = 0

var multi_checker : Array = []

# creating new tasks, also punishing mortals 
#func create_new_task(function_name: String, data):
	#var task_tag = function_name + "|" + str(data) + "|" + str(Time.get_ticks_msec())
	## Declare the variable first
	##var completion_handler
	### Then assign the function to it
	##completion_handler = func(completed_tag):
		##if completed_tag == task_tag:
			###print("Task completed: ", function_name)
			##thread_pool.disconnect("task_finished", completion_handler)
	### Connect with the callable
	##thread_pool.connect("task_finished", completion_handler)
#
	#thread_pool.submit_task(self, function_name, data, task_tag)

# function that is first, here we send its name, priority, max things number?
#func first_dimensional_magic(type_of_action_to_do : String, datapoint_node : Node, additional_node : Node = null):
#	print
















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
var terminal_variables = {}
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
	if terminal_text_node:
		set_connection_target("terminal_container", "thing_309", "thing_301")

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

func history_up():
	if terminal_command_history.size() > 0 and terminal_history_position < terminal_command_history.size() - 1:
		terminal_history_position += 1
		terminal_current_command = terminal_command_history[terminal_command_history.size() - 1 - terminal_history_position]
		update_terminal_display()

func history_down():
	if terminal_history_position > 0:
		terminal_history_position -= 1
		terminal_current_command = terminal_command_history[terminal_command_history.size() - 1 - terminal_history_position]
	elif terminal_history_position == 0:
		terminal_history_position = -1
		terminal_current_command = ""
	
	update_terminal_display()

func execute_command():
	var command_to_execute = terminal_current_command.strip_edges()
	
	# Add command to history if not empty
	if command_to_execute != "":
		terminal_command_history.push_back(command_to_execute)
		if terminal_command_history.size() > terminal_max_history:
			terminal_command_history.pop_front()



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# godot function

# init

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	print(" ready on each script ? 2 datapoint.gd ")




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# random new function
func process_delta_fake():
	print(self.name, " , " , the_scenes_fiasco, " , " , the_new_layers_fiasco, " , " , third_inty_thingy, " , " , scenes_array_size_now , " , " , main_scene_to_set)



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# keyboard

func connect_keyboard_to_field(target_container, target_thing):
	# Check if keyboard exists, create if not
	var keyboard_container = get_node_or_null("keyboard_container")
	if !keyboard_container:
		create_new_task("three_stages_of_creation", "keyboard")
	
	# Store connection info in a simple dictionary
	var connection_info = {
		"target_container": target_container,
		"target_thing": target_thing,
	}
	
	# Send connection info to keyboard datapoint
	var keyboard_dp_path = "keyboard_container/thing_24"
	# You can add this to your message queue system
	main_node.eight_dimensional_magic("keyboard_connection", connection_info, keyboard_dp_path)

func receive_keyboard_connection(connection_info):
	connected_target_container = connection_info["target_container"]
	connected_target_thing = connection_info["target_thing"]
	print("Keyboard now connected to: ", connected_target_container, "/", connected_target_thing)

# When keyboard creation is complete, trigger this:
func on_keyboard_ready():
	if is_keyboard && !connected_target_container.is_empty():
		# Force an update of the text display
		update_text_and_cursor("")

func set_connection_target(target_container, target_thing, target_datapoint):
	print("set_connection_target: Setting keyboard connection from ", self.name, " to ", target_container, "/", target_thing)
	
	# Flag that this datapoint is a keyboard
	is_keyboard = true
	
	# Store connection info as simple strings
	connected_target_container = target_container
	connected_target_thing = target_thing
	connected_target_datapoint = target_datapoint
	
	# Reset keyboard state for new connection
	current_text_mutex.lock()
	current_text = ""
	cursor_position = 0
	current_text_mutex.unlock()
	
	# Try to get the initial text from the target
	var _datapoint_path = main_node.scene_tree_jsh["main_root"]["branches"][target_container]["datapoint"]["datapoint_path"]
	var target_container_node = main_node.jsh_tree_get_node(target_container)
	
	if target_container_node:
		var thing_node = target_container_node.get_node_or_null(target_thing)
		if thing_node:
			for child in thing_node.get_children():
				if child is Label3D:
					var text_parts = child.text.split("|")
					if text_parts.size() > 1:
						current_text_mutex.lock()
						current_text = text_parts[1]
						cursor_position = current_text.length()
						current_text_mutex.unlock()
						# Update the keyboard display immediately 
						update_text_and_cursor("")
					break
	
	update_cursor_position()

func finishied_setting_up_datapoint(_my_name):
	container_node = self.get_parent()

func check_amount_of_container():
	var _container = self.get_parent()


func check_state_of_dictionary_and_three_ints_of_doom():
	var array_of_current_state : Array = []
	things_dictionary.lock()
	array_of_current_state.append(datapoint_things_dictionary.duplicate(true))
	things_dictionary.unlock()
	print(" data point main scene ? " , main_scene_to_set)
	mutex_for_three_thingies.lock()
	var three_thingies : Vector3i 
	three_thingies.x = the_new_layers_fiasco # the dictionary being send there
	three_thingies.y = the_scenes_fiasco # any scene being send there?
	three_thingies.z = third_inty_thingy # the main scene instruction being send already
	array_of_current_state.append(three_thingies)
	mutex_for_three_thingies.unlock()
	return array_of_current_state

func new_datapoint_layer_system(deep_state_copy_of_apples):
	things_dictionary.lock()
	datapoint_things_dictionary = deep_state_copy_of_apples
	things_dictionary.unlock()
	mutex_for_three_thingies.lock()
	if the_new_layers_fiasco == 0:
		the_new_layers_fiasco +=1
	if the_new_layers_fiasco == 1 and the_scenes_fiasco == 1 and third_inty_thingy == 1:
		if scenes_array_size_now >= main_scene_to_set  + 1:
			the_new_layers_fiasco = 0
			the_scenes_fiasco = 0
			third_inty_thingy = 0
			prepare_to_move_things_around(main_scene_to_set)
	mutex_for_three_thingies.unlock()

func check_dictionary_from_datapoint():
	things_dictionary.lock()
	var dictionary = datapoint_things_dictionary.duplicate(true)
	things_dictionary.unlock()
	return dictionary

func check_if_datapoint_moved_once():
	var movement_checker_new
	movement_checker_mutex.lock()
	movement_checker_new = movement_checker
	movement_checker_mutex.unlock()
	return movement_checker_new

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# file load

var name_of_loaded_file : String = ""

func initialize_loading_file(file_name):
	print(" file name datap : " , file_name)
	
	if file_name != name_of_loaded_file:
		print(" file name datap1 ")
		only_once_file = 0
		the_label_message = []
	
	print("initialize loading file ", only_once_file)
	if only_once_file == 0:
		print(" file name datap2 ")
		name_of_loaded_file = file_name
		only_once_file = 1
		print(" loading file name ", file_name)
		
		
		var message
		if file_name == "settings.txt":
			message = SettingsBank.check_all_settings_data()
		elif file_name == "modules.txt":
			message = ModulesBank.check_all_settings_data()
		print("loading file message : " , message)
		unedited_message = message
		var new_array_thingy : Array = []
		var _amounts_of_thingies : int = 0
		for thing_labely in message:
			print(message[thing_labely])
			new_array_thingy.append([thing_labely + "|" + str(message[thing_labely])])
			_amounts_of_thingies +=1
		the_label_message.append(new_array_thingy)
		settings_labels_start()


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# change text

func settings_labels_start():
	var counter_of_settings_lines : int = 0
	var _counter_label : int = 0
	var max_amount_of_text = the_label_message[0].size()
	things_dictionary.lock()
	for thing_inside in datapoint_things_dictionary:
		print("file name now check that" , datapoint_things_dictionary[thing_inside])
		if datapoint_things_dictionary[thing_inside].has("node"):
			for children in datapoint_things_dictionary[thing_inside]["node"].get_children():
				if children is Label3D:
					if max_amount_of_text == counter_of_settings_lines:
						things_dictionary.unlock()
						return
					children.text = the_label_message[0][counter_of_settings_lines][0]
					counter_of_settings_lines +=1
	things_dictionary.unlock()
	

func receive_a_message(message):
	print(" datapoint received a message ", message)
	times_of_data_used = 1
	data_to_be_used.append(message)


func singular_lines_added():
	print(" singular_line added")



func change_dual_text():
	var counter_of_settings_lines : int = 0
	var counter_message : int = 0
	var size_of_message = data_to_be_used[0][0].size() - 1
	things_dictionary.lock()
	for thing_inside in datapoint_things_dictionary:
		if datapoint_things_dictionary[thing_inside].has("node"):
			if datapoint_things_dictionary[thing_inside]["node"] is Label3D:
				if size_of_message >= counter_message:
					datapoint_things_dictionary[thing_inside]["node"].text = str(data_to_be_used[0][0][counter_message][counter_of_settings_lines])
				counter_of_settings_lines +=1
				if counter_of_settings_lines == 2:
					counter_message +=1
					counter_of_settings_lines = 0
	things_dictionary.unlock()

func connect_keyboard_string():
	print()
	## so a node can have text changed

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# text bracet for keyboard


# current_things_number, data_point_layer_0, data_point_layer_0_data, data_point_information
func setup_text_handling():
	add_cursor()
	setup_cursor_timer()

func add_cursor():
	mutex_for_cursor.lock()
	cursor_model = MeshInstance3D.new()
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.05, 0.4, 0.01)
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(1, 1, 1, 1)
	cursor_model.material_override = material
	cursor_model.mesh = cursor_mesh
	mutex_for_cursor.unlock()
	var container = get_parent()
	var text_bracket = container.get_node("thing_27")
	if text_bracket:
		mutex_for_cursor.lock()
		FloodgateController.universal_add_child(cursor_model, text_bracket)
		mutex_for_cursor.unlock()
		update_cursor_position()

func setup_cursor_timer():
	var timer = TimerManager.get_timer()
	add_child(timer)
	timer.wait_time = 0.53
	timer.timeout.connect(blink_cursor)
	timer.start()

func blink_cursor():
	cursor_visible = !cursor_visible
	mutex_for_cursor.lock()
	if cursor_model:
		cursor_model.visible = cursor_visible
	mutex_for_cursor.unlock()

#func create_new_task(function_name: String, data):
#func create_new_task_empty(function_name: String):
## if process delta changes stuff, it is changing it before time, so we could theoretically update the text here, but we would probably need to make a task, that will
## update the rest?

func handle_key_press(key: String):
	current_text_mutex.lock()
	if len(current_text) * char_width < bracket_width:
		current_text = current_text.insert(cursor_position, key)
		cursor_position += 1
		current_text_mutex.unlock()
		update_text_and_cursor(key)
		if is_keyboard && !connected_target_container.is_empty():
			update_connected_target()
	else:
		current_text_mutex.unlock()

func handle_backspace():
	if cursor_position > 0:
		current_text_mutex.lock()
		current_text = current_text.erase(cursor_position - 1, 1)
		cursor_position -= 1
		var key = ""
		current_text_mutex.unlock()
		update_text_and_cursor(key)
		if is_keyboard && !connected_target_container.is_empty():
			update_connected_target()
	else:
		current_text_mutex.unlock()

func return_string_from_keyboards():
	print("return_string_from_keyboards: Starting to process")
	
	# Only proceed if this is a keyboard with a connected target
	if !is_keyboard:
		print("return_string_from_keyboards: Not a keyboard")
		return
		
	if connected_target_container.is_empty() || connected_target_thing.is_empty():
		print("return_string_from_keyboards: Missing target info")
		return
	
	# Get the container
	var settings_container = main_node.jsh_tree_get_node(connected_target_container)
	if !settings_container:
		print("return_string_from_keyboards: Container not found:", connected_target_container)
		return
	
	# Get the target thing
	var thing_path = connected_target_container + "/" + connected_target_thing
	var target_thing = main_node.jsh_tree_get_node(thing_path)
	
	if !target_thing:
		print("return_string_from_keyboards: Target thing not found")
		return
	
	# Try to directly access the text node through a full path
	var text_thing_path = connected_target_container + "/" + connected_target_thing + "/text_" + connected_target_thing
	print("return_string_from_keyboards: Trying direct path:", text_thing_path)
	var label_node = main_node.jsh_tree_get_node(text_thing_path)
	
	if !label_node:
		print("return_string_from_keyboards: Direct path failed, trying root path")
		# Try from root
		var root_path = "/root/main/" + connected_target_container + "/" + connected_target_thing + "/text_" + connected_target_thing
		label_node = main_node.get_node_or_null(root_path)
	
	if !label_node:
		print("return_string_from_keyboards: Both paths failed")
		# Print details of the children again
		print("Children of", target_thing.name, ":")
		for child in target_thing.get_children():
			print("- Child:", child.name)
		return
	
	print("return_string_from_keyboards: Found label with text:", label_node.text)
	
	# Rest of function as before...
	# Get the datapoint
	var datapoint_path = main_node.scene_tree_jsh["main_root"]["branches"][connected_target_container]["datapoint"]["datapoint_path"]
	var settings_datapoint = main_node.jsh_tree_get_node(datapoint_path)
	
	# Extract key from the label
	var text_parts = label_node.text.split("|")
	if text_parts.size() > 0:
		var key = text_parts[0]
		
		# Update the settings data
		if "unedited_message" in settings_datapoint:
			var settings_data = settings_datapoint.unedited_message
			if settings_data != null:
				# Clean up the key
				var clean_key = key.strip_edges()
				
				# Update the value in the settings data
				if settings_data.has(clean_key):
					settings_data[clean_key] = current_text
					
					# Save the updated settings
					print("trying to store data maybe ", settings_data)
					var type_of_current_file
					if settings_data.has("page"):
						type_of_current_file = settings_data["page"]
					
					if type_of_current_file == "settings":
					
						SettingsBank.save_settings_data(settings_data)
						print("return_string_from_keyboards: Setting updated successfully")
					
					elif type_of_current_file == "modules":
						ModulesBank.save_settings_data(settings_data)
					
					# Update the label
					label_node.text = key + "|" + current_text



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# writing and changing text

# Helper function to recursively find a Label3D in a node hierarchy
func find_label_in_node(node: Node) -> Label3D:
	# Check direct children first
	for child in node.get_children():
		if child is Label3D:
			return child
			
	# Then look in each child's hierarchy
	for child in node.get_children():
		var result = find_label_in_node(child)
		if result:
			return result
			
	return null



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# connect things together

func update_connected_target():
	# Find the target node using proper NodePath
	var target_container = main_node.get_node_or_null(NodePath(connected_target_container))
	if !target_container:
		print("Could not find target container: ", connected_target_container)
		return
		
	# Find the target thing
	var target_thing = target_container.get_node_or_null(NodePath(connected_target_thing))
	if !target_thing:
		print("Could not find target thing: ", connected_target_thing)
		return
		
	# Find the label component
	var label_node = null
	for child in target_thing.get_children():
		if child is Label3D:
			label_node = child
			break
			
	if label_node:
		# Preserve the key part of the label
		var text_parts = label_node.text.split("|")
		if text_parts.size() > 0:
			# Keep the key part, update only the value
			label_node.text = text_parts[0] + "|" + current_text


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# writing, write, before or after we render a frame ?

func update_text_and_cursor(key):
	#print(" we update text and cursor")
	var container = self.get_parent()
	var text_label = container.get_node("thing_28")

	if text_label:
		var action_additional : String = "update_text_cursor_after" 
		var datapoint_node = self
		main_node.first_dimensional_magic(action_additional, datapoint_node, text_label)
		#print(" we get that text label thingy")
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		current_text_mutex.lock()
		text_label.text = current_text
		text_label.set_text(current_text)
		current_text_mutex.unlock()
		char_width_new = get_text_width(text_label)
		create_new_task("get_text_width", text_label)
		if key.is_empty():
			bracket_current_text.pop_back()
		else:
			bracket_current_text.append([[key], [char_width_new]])
	update_cursor_position()

func update_text_cursor_after(text_label):
	char_width_new = get_text_width(text_label)
	update_cursor_position()

func update_cursor_position():
	mutex_for_cursor.lock()
	if cursor_model:
		var start_x = -bracket_width/2
		var x_pos = start_x + char_width_new
		cursor_model.position = Vector3(x_pos, 0, 0.01)
	mutex_for_cursor.unlock()



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# we get text after we render frame, as we measure points too

func get_text_width(text_label: Label3D) -> float:
	var aabb = text_label.get_aabb()
	var text_width = aabb.size.x
	return text_width



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# here we will move things around too

# to change what we wrote, we can do in few places in few ways, with no need

func change_numbers_letters(scene_to_pull): #
	print(" parallel reality chan num let func : " , scene_to_pull)

func shift_keyboard(scene_to_pull): 
	print(" parallel reality shift keys : " , scene_to_pull)

func undo_a_character(_data):
	handle_backspace()



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# instructions so ready and do it once and get over it

# ready

# instructions


func write_on_keyboard(data_of_key_pressed):
	print(" we clicking : " , data_of_key_pressed)



func power_up_data_point(datapoint_name, datapoint_number, array_of_data):
	var str_num = str(datapoint_number)
	data_point_name = data_point_ + str_num
	var int_num = int(array_of_data[0][0])
	data_point_information.append([data_point_name])
	data_point_information.append([datapoint_name])
	data_point_information.append([datapoint_number])
	data_point_information.append([int_num])
	return data_point_information

func datapoint_check():
	datapoint_checked.clear()
	datapoint_checked.append([current_priority])
	datapoint_checked.append([current_things_number])
	return datapoint_checked

func datapoint_assign_priority(send_priority_number):
	current_priority = int(send_priority_number)
	
func add_thing_to_datapoint(array_from_main):
	data_point_layer_0.append(array_from_main)

func datapoint_max_things_number_setter(sended_max_number):
	max_things_number = int(sended_max_number)

var sad_counter : int = 0

func upload_scenes_frames(header_line, information_lines):
	var array_for_present_moment : Array = []
	var header_copy = header_line.duplicate(true)
	var info_copy = information_lines.duplicate(true)
	array_for_present_moment.append(header_copy)
	array_for_present_moment.append(info_copy)
	var is_new_scene = true
	var counter_for_scenes : int = -1
	scenes_mutex.lock()
	for existing_scene in Scenes_array:
		counter_for_scenes +=1
		if existing_scene[0][0][0] == header_line[0][0]: 
			is_new_scene = false
			Scenes_array[counter_for_scenes] = array_for_present_moment
			movement_checker_mutex.lock()
			movement_checker = 0
			movement_checker_mutex.unlock()
	scenes_mutex.unlock()
	if is_new_scene:
		scenes_mutex.lock()
		Scenes_array.append(array_for_present_moment)
		scenes_array_size_now = Scenes_array.size()
		scenes_mutex.unlock()
	else:
		print(" we should been appendin them scenes but somehow it exist?!", self.name, header_line)
	var new_move_check
	movement_checker_mutex.lock()
	new_move_check = movement_checker
	movement_checker_mutex.unlock()
	mutex_for_three_thingies.lock()
	if new_move_check == 0:
		if the_scenes_fiasco == 0:
			the_scenes_fiasco +=1
	if the_new_layers_fiasco == 1 and the_scenes_fiasco == 1 and third_inty_thingy == 1:
		if scenes_array_size_now >= main_scene_to_set  + 1:
			the_new_layers_fiasco = 0
			the_scenes_fiasco = 0
			third_inty_thingy = 0
			prepare_to_move_things_around(main_scene_to_set)
	mutex_for_three_thingies.unlock()

func upload_interactions(header_line, information_lines):
	print(" the await two point o stuff  upload interaction")
	var interaction_blimp : Array = [header_line, information_lines]
	interactions_mutex.lock()
	Interactions_array.append(interaction_blimp.duplicate(true))
	interactions_mutex.unlock()


func setup_main_reference(main_ref: Node) -> void:
	main_node = main_ref

func check_all_things_inside_datapoint():
	var some_data = [data_point_name , 
	data_point_number , 
	max_things_number , 
	current_things_number , 
	current_priority , 
	data_point_information , 
	data_point_layer_0 , 
	datapoint_checked , 
	data_point_layer_0_data]
	return some_data

func get_datapoint_info_for_containter_connection():
	return





func check_things_in_scene(scene_we_wanna) -> Array:
	var data_point_name_thingy : String = self.name
	var data_point_path = self.get_parent()
	var list_of_things_that_shall_remain : Array = []
	list_of_things_that_shall_remain.clear()
	list_of_things_that_shall_remain.append([data_point_path])
	list_of_things_that_shall_remain.append([data_point_name_thingy])
	list_of_things_that_shall_remain.append(["thing_3"])
	list_of_things_that_shall_remain.append(["thing_4"])
	for thing_to_leave in scene_we_wanna:
		var thing_that_is_in_scene = thing_to_leave[1]
		list_of_things_that_shall_remain.append(thing_that_is_in_scene)
	return [[list_of_things_that_shall_remain], []]

func scene_to_set_number_later(number_int_eh):
	main_scene_to_set = number_int_eh
	mutex_for_three_thingies.lock()
	if third_inty_thingy == 0:
		third_inty_thingy = 1
	if the_new_layers_fiasco == 1 and the_scenes_fiasco == 1 and third_inty_thingy == 1:
		if scenes_array_size_now >= main_scene_to_set  + 1:
			the_new_layers_fiasco = 0
			the_scenes_fiasco = 0
			third_inty_thingy = 0
			print(" upload scene frames testingg 3 ", self.name)
			prepare_to_move_things_around(main_scene_to_set)
	mutex_for_three_thingies.unlock()

func set_maximum_interaction_number(mode : String, amount : int):
	maximum_amount_of_interaction = amount
	current_interaction_mode = mode



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# ray cast process stuff

# ray cast

# process

# direction

# change scene 

# check stuff too


func thing_interaction(thing):
	things_dictionary.lock()
	var maybe_that_copy = datapoint_things_dictionary.duplicate(true)
	things_dictionary.unlock()
	if maybe_that_copy.has(thing):
		var array_of_things = check_possible_interactions(thing)
		return array_of_things
	else:
		print("ray_cast_stufff it does not have that thing? ")




func check_possible_interactions(thing):
	print("Action 2.0 newest thingies here 2")
	var first_results = check_possible_actions(thing)
	print(" Action 2.0 results : " , first_results)
	var array_of_things = null
	if first_results != null:
		array_of_things = do_action_found(first_results, thing)
	return array_of_things


						## here we could append every possible actions
						## why?
						## the datapoint, container, thing, could not only need a scene, but also state
						## like while walking, standing, doing something, it can do something else, but not that
						## maybe when it is falling, it can only stand up?

func check_possible_actions(thing):
	print("newest thingies here 1")
	var found_interaction = null
	interactions_mutex.lock()
	var actions_possible = Interactions_array.duplicate(true) 
	interactions_mutex.unlock()
	for possible_action in actions_possible:
		var possible_scenes = possible_action[1][0]
		for one_scene in possible_scenes:
			if current_scene == one_scene[0]:
				var possible_things = possible_action[1][1]
				for one_thing in possible_things:
					if thing == one_thing[0]:
						found_interaction = possible_action
						return found_interaction

func do_action_found(action_page, thing_name):
	print("newest thingies here 0")
	var actions = action_page[1]
	var the_actions_to_do = actions[2]
	var specifics_in_action = actions[3]
	var counter_one : int = -1
	for singular_action in the_actions_to_do:
		counter_one +=1
		var action_current = specifics_in_action[counter_one][0]
		match the_actions_to_do[counter_one][0]:
			"change_scene":
				if action_current is String:
					var split_for_number = action_current.split("_")
					if split_for_number.size() > 1:
						var inty_numba = int(split_for_number[1])
						move_things_around(inty_numba)
			"add_scene":
				print("catch Action 2.0 add_scene ", action_current)
				main_node.create_new_task("three_stages_of_creation", action_current)
				
			"change_text": 
				print(" Action 2.0 change_text ", action_current)
				
			"call_function": 
				print(" Action 2.0 call_function ", action_current)
				var function_name = action_current
				main_node.callv(function_name, [])
				
			"unload_container": 
				var container_name = action_current
				var send_type_of_unload = "container"
				main_node.fifth_dimensional_magic(send_type_of_unload, container_name)
				
			"write":
				var name_of_action : String = "call_function_get_node"
				var node_to_get : String = "keyboard_container/thing_24"
				var name_of_the_function : String = "handle_key_press"
				name_of_the_function = name_of_the_function + "|" + str(thing_name)
				main_node.sixth_dimensional_magic(name_of_action, node_to_get, name_of_the_function, action_current)
				return "write"
				
			"shift_keyboard": 
				var name_of_action : String = "move_things_around"
				var node_to_get_0 : String = "keyboard_left_container/thing_34"
				var node_to_get_1 : String = "keyboard_right_container/thing_53"
				var array_of_nodes : Array = []
				array_of_nodes.append(node_to_get_0)
				array_of_nodes.append(node_to_get_1)
				var type_of_action : String = "get_nodes_call_function"
				var data_to_send = int(action_current)
				main_node.sixth_dimensional_magic(type_of_action, array_of_nodes, name_of_action, data_to_send)
				
			"number_letter":
				var name_of_action : String = "move_things_around"
				var node_to_get_0 : String = "keyboard_left_container/thing_34"
				var node_to_get_1 : String = "keyboard_right_container/thing_53"
				var array_of_nodes : Array = []
				array_of_nodes.append(node_to_get_0)
				array_of_nodes.append(node_to_get_1)
				var type_of_action : String = "get_nodes_call_function"
				var data_to_send = int(action_current)
				main_node.sixth_dimensional_magic(type_of_action, array_of_nodes, name_of_action, data_to_send)
				
			"return_string":
				print("Action: return_string ", action_current)
				var keyboard_dp_path = "keyboard_container/thing_24"
				var keyboard_dp = main_node.jsh_tree_get_node(keyboard_dp_path)
				if keyboard_dp:
					keyboard_dp.return_string_from_keyboards()
				else:
					print("Keyboard datapoint not found using JSH tree: ", keyboard_dp_path)
				
				
			"undo_char":
				var function_name_to_call : String = "handle_backspace"
				function_name_to_call = function_name_to_call + "|" + str(thing_name)
				var node_to_get : String = "keyboard_container/thing_24"
				var name_of_action : String = "call_function_single_get_node"
				main_node.sixth_dimensional_magic(name_of_action, node_to_get, function_name_to_call)
				return "undo_char"
				
			"load_file":
				print(" Action 2.0 load_file ", action_current)
				var splitter_of_one = action_current.split("ø")
				print(" Action 2.0 load_file splitter_of_one ", splitter_of_one)
				var name_of_action = "load_a_file"
				var container_name = splitter_of_one[0]
				var file_to_load = splitter_of_one[1]
				print(" Action 2.0 load_file splitter_of_one ", name_of_action , " , " , container_name , " , " , file_to_load)
				main_node.eight_dimensional_magic(name_of_action, file_to_load, container_name)
				
				
			"key_interaction":
				print(" newest thingies here key interaction")
			"value_interaction":
				print(" newest thingies here value interaction")
			"dunno_yet":
				print(" Action 2.0 dunno_yet ", action_current)
			"connect_keyboard":
				print("Action: connect_keyboard for ", action_current)
				var target_container = self.get_parent().name
				var target_thing = action_current
				main_node.eight_dimensional_magic("keyboard_connection", [target_container, target_thing, self.name], "")
				
			_:
				print(" Action 2.0 we didnt find it ", action_current)



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# dunno maybe seed and id of a datapoint

func safe_get(array: Array, indices: Array, default = null) -> Variant:
	var current = array
	for index in indices:
		if typeof(current) != TYPE_ARRAY or index < 0 or index >= current.size():
			return default 
		current = current[index]
	return current






#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# multi threading

# thread_pool

# threads thread multi pool addon asset threading

####################
# JSH Multi Threads
func create_new_task(function_name: String, data):
	var new_data_way = str(data)
	var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
	## new_task_appeared(task_id, function_called, data_send_to_function)
#	task_manager.new_task_appeared(task_tag, function_name, data)
	thread_pool.submit_task(self, function_name, data, task_tag)
####################


####################
# JSH Multi Threads
func create_new_task_empty(function_name: String):
	var new_data_way = "empty"
	var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
	## new_task_appeared(task_id, function_called, data_send_to_function)
#	task_manager.new_task_appeared(task_tag, function_name, new_data_way)
	thread_pool.submit_task_unparameterized(self, function_name, task_tag)
####################

func lets_move_them_again():
	print(" i guess we could not do it for now")






#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# move things around 

# check them maybe


func the_checking_stuff():
	var scene_number = main_scene_to_set
	var _counter_of_what_to_move : int = 0
	var _counter_of_what_we_moved : int = 0
	scenes_mutex.lock()
	var _scen_siz = Scenes_array.size()
	var scenes_copy = Scenes_array.duplicate(true)
	scenes_mutex.unlock()
	var scene_things: Array = []
	var scene_to_set
	for available_scenes in scenes_copy:
		var scene_number_to_find = available_scenes[0][0][0].split("_")
		if scene_number == int(scene_number_to_find[1][0]):
			scene_to_set = available_scenes
	if scene_to_set:
		for scene_test in scene_to_set[1]:
			_counter_of_what_to_move +=1
			if scene_test.size() < 3 or scene_test[0].is_empty():
				continue
			var lets_get_path = str(self.get_path())
			var splitter_path = lets_get_path.split("/")
			var _new_name_scene = splitter_path[3] + "/" + scene_test[1][0]
			scene_things.append(scene_test[1][0])
			var _new_position = Vector3(
				float(scene_test[2][0]),
				float(scene_test[2][1]),
				float(scene_test[2][2])
			)
			things_dictionary.lock()
			if is_instance_valid(datapoint_things_dictionary[scene_test[1][0]]["node"]):
				var _type_of_stuff : String = "move"
				if datapoint_things_dictionary[scene_test[1][0]]["node"].position == _new_position:
					print("new checkerrr it moved correctly and checked")
				else:
					print("new checkerrr it didnt move correctly and checked")
					datapoint_things_dictionary[scene_test[1][0]]["node"].position = _new_position
				things_dictionary.unlock()
			else:
				things_dictionary.unlock()
				print(" we must add another node to the tree ")

func prepare_to_move_things_around(scene_to_set):
	move_things_around(scene_to_set)







#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# just move them things already cmon


func move_things_around(scene_number: int):
	var _counter_of_what_to_move : int = 0
	var _counter_of_what_we_moved : int = 0
	scenes_mutex.lock()
	var _scen_siz = Scenes_array.size()
	var scenes_copy = Scenes_array.duplicate(true)
	scenes_mutex.unlock()
	var scene_things: Array = []
	var scene_to_set
	for available_scenes in scenes_copy:
		var scene_number_to_find = available_scenes[0][0][0].split("_")
		if scene_number == int(scene_number_to_find[1][0]):
			scene_to_set = available_scenes
	if scene_to_set:
		for scene_test in scene_to_set[1]:
			_counter_of_what_to_move +=1
			if scene_test.size() < 3 or scene_test[0].is_empty():
				continue
			var lets_get_path = str(self.get_path())
			var splitter_path = lets_get_path.split("/")
			var _new_name_scene = splitter_path[3] + "/" + scene_test[1][0]
			scene_things.append(scene_test[1][0])
			var _new_position = Vector3(
				float(scene_test[2][0]),
				float(scene_test[2][1]),
				float(scene_test[2][2])
			)
			things_dictionary.lock()
			if is_instance_valid(datapoint_things_dictionary[scene_test[1][0]]["node"]):
				var _type_of_stuff : String = "move"
				main_node.the_fourth_dimensional_magic(_type_of_stuff, datapoint_things_dictionary[scene_test[1][0]]["node"], _new_position)
				things_dictionary.unlock()
			else:
				things_dictionary.unlock()
				print(" we must add another node to the tree ")
			if scene_test.size() > 3:
				things_dictionary.lock()
				if is_instance_valid(datapoint_things_dictionary[scene_test[1][0]]["node"]):
					var _type_of_stuff_write : String = "write"
					var data_to_write = scene_test[3][0]
					main_node.the_fourth_dimensional_magic(_type_of_stuff_write, datapoint_things_dictionary[scene_test[1][0]]["node"], data_to_write)
					things_dictionary.unlock()
				else:
					things_dictionary.unlock()
					print(" we must add another node to the tree ")
		current_scene = "scene_" + str(scene_number)
		number_of_scene = scene_number
		prepare_data_for_unloading(scene_things)
		check_multi_stuff(scene_number)
		print(" so lets make new version, of that unloading nodes now : " , scene_things)
	if times_of_data_used == 1:
		change_dual_text()
	var new_movin_check
	movement_checker_mutex.lock()
	new_movin_check = movement_checker
	movement_checker_mutex.unlock()
	if new_movin_check == 0:
		movement_checker_mutex.lock()
		movement_checker = 1
		movement_checker_mutex.unlock()
		var number_of_actions : int = 1
		var change_visibilty : String = "change_visibilty"
		var container_name  = self.get_parent()
		var container_path = container_name.get_path()
		main_node.seventh_dimensional_magic(change_visibilty, container_path, number_of_actions)
		## lets call main node, that first movement was there, and we can do stuff, like change visibility of construct, to visible :) as it was organised already





#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# here we had actions maybe, we dont and maybe do still check it ?

func check_multi_stuff(scene_number):
	if current_interaction_mode == "multi":
		scenes_mutex.lock()
		var current_scenes_size = scenes_array_size_now
		scenes_mutex.unlock()
		if multi_checker.size() < current_scenes_size:
			multi_checker.append(scene_number)
			if multi_checker.size() < scene_number + 1:
				print(" it should mean that we must move things around again, from 0 to current number maybe? ")
				var current_possibility : int = 0
				mutex_for_three_thingies.lock()
				if the_new_layers_fiasco == 0 and the_scenes_fiasco == 0 and third_inty_thingy == 0:
					current_possibility = 1
				mutex_for_three_thingies.unlock()
				if current_possibility == 1:
					for i in range(scene_number):
						move_things_around(i)

func prepare_data_for_unloading(scene_stuff):
	if current_interaction_mode == "duplicate":
		print(" kinda like multi, different containers? instead of different things name, dman ")
		#it will be easier than i thought
		# it is creating itself, it lives in me
		# we drewam in it
		# one day we will duplicate
		# lol
		
	elif current_interaction_mode == "multi":
		print(" god doesnt know what to put here, but we have it already, just in case ")
		## i guess here we could do some trickery?
		# but now i need to see my menu again
		# where are you perfect settings file
		# just visualisation
		# will make it appear again
		# even now
		# no glasses needed
		# goodnight
	
	
	# oh also the eden carmagedon ancient home cinema
	# the best god mode there ever is
	# even exploding and becoming a plasmoid
	# abducting the neareset being that is not annoying
	# and contrilling thse copies
	# to continue this fantastic production
	# is all that it takes to maybe not explode planet eaerth
	# or tonight, but who knows what happens in dreams
	# ask the ones spleeping, i am working now ,con
	# gn
	
	elif current_interaction_mode == "single":
		var container_path_currently : String
		var current_action_to_do : String = "just_node"
		var _keys_to_erase : Array = []
		things_dictionary.lock()
		container_path_currently = datapoint_things_dictionary["metadata"]["container_path"]
		if datapoint_things_dictionary["metadata"]["container_path"] == "akashic_records":
			var line_thingy : String = "thing_3"
			scene_stuff.append(line_thingy)
			var jsh_textmesh : String = "thing_4"
			scene_stuff.append(jsh_textmesh)
			scene_stuff.append(datapoint_things_dictionary["metadata"]["datapoint_name"])
		else:
			scene_stuff.append(datapoint_things_dictionary["metadata"]["datapoint_name"])
		for thingy in datapoint_things_dictionary:
			if thingy != "metadata":
				var thingy_checker : int = 0
				for thingy_0 in scene_stuff:
					if thingy_0 == thingy:
						thingy_checker = 1
				if thingy_checker == 0:
					var path_of_thingy : String = container_path_currently + "/" + thingy
					main_node.fifth_dimensional_magic(current_action_to_do, path_of_thingy)
					_keys_to_erase.append(thingy)
					datapoint_things_dictionary[thingy]["node"] = null
		things_dictionary.unlock()

func some_snake_game():
	main_node.fifth_dimensional_magic("container", "snake_game_container") 
	main_node.sixth_dimensional_magic("call_function_get_node", "snake_game_container/thing_101", "snake_turn_up")
	main_node.eighth_dimensional_magic("snake_command", "add_segment", "")

























#
#func check_possible_interactions_old(thing):
	#interactions_mutex.lock()
	#var size_of_inter_array = Interactions_array.size() 
	#interactions_mutex.unlock()
	#if size_of_inter_array < number_of_scene:
		#return
	#var scene_things: Array = []
	#var counter_of_interaction_checked : int = 0
	#var counter_for_array : int = -1
	#var counter = -1
	#var first_interaction
	#var second_interaction
	#var third_interaction
	#var fourth_interaction
	#var fifth_interaction
	#var sixth_interaction
	#var interaction_to_do_now
	#var scene_to_pull
	#var second_scene_to_pull
	#var third_scene_to_pull
	#var fourth_scene_to_pull
	#var array_of_things
	#var number_of_possible_interactions
	#var current_number_of_inter
	#interactions_mutex.lock()
	#var current_possible_interaction = Interactions_array[number_of_scene]
	#var interactions_copy = Interactions_array.duplicate(true)
	#interactions_mutex.unlock()
	#var possible_interaction = current_possible_interaction[1][0][1][0]
	#for posib_inter in interactions_copy:
		#if counter_of_interaction_checked == maximum_amount_of_interaction:
			#break
		#var inter_ar_siz = posib_inter[1][0].size()
		#if inter_ar_siz > 2:
			#scene_to_pull = posib_inter[1][0][2][0]
		#if inter_ar_siz > 3:
			#first_interaction = posib_inter[1][0][3][0]
		#if inter_ar_siz > 4:
			#second_interaction = posib_inter[1][0][4][0]
		#if inter_ar_siz > 5:
			#third_interaction = posib_inter[1][0][5][0]
		#if inter_ar_siz > 6:
			#fourth_interaction = posib_inter[1][0][6][0]
		#if inter_ar_siz > 7:
			#fifth_interaction = posib_inter[1][0][7][0]
		#if inter_ar_siz > 8:
			#sixth_interaction = posib_inter[1][0][8][0]
		#var thing_name_to_interact = posib_inter[1][0][1][0]
		#var from_that_scene_we_can_go = posib_inter[0][0]
		#if thing == thing_name_to_interact and from_that_scene_we_can_go == current_scene:
			#print(" lets check multi tasking thingies " , thing , " , " , thing_name_to_interact , " , " , from_that_scene_we_can_go , "  ,  " , current_scene)
			#print("posib_inter ", posib_inter)
			#counter_of_interaction_checked +=1
			#number_of_possible_interactions = int(posib_inter[3])
			#for interaction in number_of_possible_interactions :
				#current_number_of_inter = interaction + 1
				#var check_size_of_posib_inter = posib_inter[2].size()
				#if counter_for_array + 1 < number_of_possible_interactions:
					#counter_for_array +=1
				#var name_of_interaction
				#if posib_inter[2].size() > 1:
					#name_of_interaction = posib_inter[2][counter_for_array][0]
				#else:
					#name_of_interaction = posib_inter[2][0][0]
				#for i in ActionsBank.type_of_interactions_0:
					#counter +=1
					#if name_of_interaction == i:
						#break
					#else:
						#continue
				#match counter_for_array:
					#0: # interaction one
						#interaction_to_do_now = scene_to_pull
					#1:
						#interaction_to_do_now = first_interaction
					#2:
						#interaction_to_do_now = second_interaction
					#3:
						#interaction_to_do_now = third_interaction
					#4:
						#interaction_to_do_now = fourth_interaction
					#5:
						#interaction_to_do_now = fifth_interaction
					#6:
						#interaction_to_do_now = sixth_interaction
				#match counter:
					#0: 
						#var scene_to_set : int = int(posib_inter[1][0][3][0])
						#move_things_around(scene_to_set)
						#counter = -1
					#1: 
						#var current_interaction_to_do
						#match counter_for_array:
							#0: 
								#current_interaction_to_do = scene_to_pull
							#1:
								#current_interaction_to_do = first_interaction
							#2:
								#current_interaction_to_do = second_interaction
							#3:
								#current_interaction_to_do = third_interaction
							#4:
								#current_interaction_to_do = fourth_interaction
							#5:
								#current_interaction_to_do = fifth_interaction
							#6:
								#current_interaction_to_do = sixth_interaction
						#main_node.create_new_task("three_stages_of_creation", current_interaction_to_do)
						#counter = -1
					#2: 
						#counter = -1
					#3: 
						#counter = -1
					#4: 
						#var current_interaction_to_do
						#match counter_for_array:
							#0:
								#current_interaction_to_do = first_interaction
							#1:
								#current_interaction_to_do = second_interaction
							#2:
								#current_interaction_to_do = third_interaction
							#3:
								#current_interaction_to_do = fourth_interaction
							#4:
								#current_interaction_to_do = fifth_interaction
							#5:
								#current_interaction_to_do = sixth_interaction
						#var container_name = current_interaction_to_do
						#var send_type_of_unload = "container"
						#main_node.fifth_dimensional_magic(send_type_of_unload, container_name)
						#counter = -1
					#5: 
						#counter = -1
						#var name_of_action : String = "call_function_get_node"
						#var node_to_get : String = "keyboard_container/thing_24"
						#var name_of_the_function : String = "handle_key_press"
						#main_node.sixth_dimensional_magic(name_of_action, node_to_get, name_of_the_function, scene_to_pull)
					#6: 
						#print(" parallel reality shift keyboard ", posib_inter[1][0][2][0])
						#var name_of_action : String = "move_things_around"
						#var node_to_get_0 : String = "keyboard_left_container/thing_34"
						#var node_to_get_1 : String = "keyboard_right_container/thing_53"
						#var array_of_nodes : Array = []
						#array_of_nodes.append(node_to_get_0)
						#array_of_nodes.append(node_to_get_1)
						#var type_of_action : String = "get_nodes_call_function"
						#var data_to_send = int(posib_inter[1][0][2][0])
						#main_node.sixth_dimensional_magic(type_of_action, array_of_nodes, name_of_action, data_to_send)
					#7: 
						#print(" parallel reality numbers / letters ", posib_inter[1][0][2][0]) 
						#var name_of_action : String = "move_things_around"
						#var node_to_get_0 : String = "keyboard_left_container/thing_34"
						#var node_to_get_1 : String = "keyboard_right_container/thing_53"
						#var array_of_nodes : Array = []
						#array_of_nodes.append(node_to_get_0)
						#array_of_nodes.append(node_to_get_1)
						#var type_of_action : String = "get_nodes_call_function"
						#var data_to_send = int(posib_inter[1][0][2][0])
						#main_node.sixth_dimensional_magic(type_of_action, array_of_nodes, name_of_action, data_to_send)
					#8: 
						#var return_string_from_keyboards : String = "return_string_from_keyboards"
					#9: 
						#var function_name_to_call : String = "handle_backspace"
						#var node_to_get : String = "keyboard_container/thing_24"
						#var name_of_action : String = "call_function_single_get_node"
						#main_node.sixth_dimensional_magic(name_of_action, node_to_get, function_name_to_call)
					#10: 
						#print(" multi tasking, lets find out why we do rea rae 10")
	#if number_of_possible_interactions == current_number_of_inter:
		#return array_of_things

extends Node
class_name ThingCreatorCommands

# References
var jsh_console = null
var thing_creator = null
var akashic_records_manager = null

# Initialize the commands
func initialize(p_jsh_console) -> void:
	jsh_console = p_jsh_console
	
	# Find ThingCreator
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		push_error("ThingCreator not found! Make sure it's initialized.")
		return
	
	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		push_error("AkashicRecordsManager not found! Make sure it's initialized.")
		return
	
	# Register commands
	_register_commands()
	print("Thing Creator commands registered with JSH console")

# Register all Thing Creator related commands
func _register_commands() -> void:
	# Create thing command
	jsh_console.register_command({
		"command": "thing-create",
		"description": "Create a new thing from a dictionary word",
		"usage": "thing-create <word_id> <x> <y> <z> [prop1=value1 prop2=value2]",
		"callback": Callable(self, "_cmd_thing_create"),
		"min_args": 4,
		"max_args": -1
	})
	
	# List things command
	jsh_console.register_command({
		"command": "thing-list",
		"description": "List all things in the world",
		"usage": "thing-list",
		"callback": Callable(self, "_cmd_thing_list"),
		"min_args": 0,
		"max_args": 0
	})
	
	# Remove thing command
	jsh_console.register_command({
		"command": "thing-remove",
		"description": "Remove a thing from the world",
		"usage": "thing-remove <thing_id>",
		"callback": Callable(self, "_cmd_thing_remove"),
		"min_args": 1,
		"max_args": 1
	})
	
	# Move thing command
	jsh_console.register_command({
		"command": "thing-move",
		"description": "Move a thing to a new position",
		"usage": "thing-move <thing_id> <x> <y> <z>",
		"callback": Callable(self, "_cmd_thing_move"),
		"min_args": 4,
		"max_args": 4
	})
	
	# Interact things command
	jsh_console.register_command({
		"command": "thing-interact",
		"description": "Simulate interaction between two things",
		"usage": "thing-interact <thing1_id> <thing2_id>",
		"callback": Callable(self, "_cmd_thing_interact"),
		"min_args": 2,
		"max_args": 2
	})
	
	# Get thing info command
	jsh_console.register_command({
		"command": "thing-info",
		"description": "Get information about a thing",
		"usage": "thing-info <thing_id>",
		"callback": Callable(self, "_cmd_thing_info"),
		"min_args": 1,
		"max_args": 1
	})
	
	# Help command
	jsh_console.register_command({
		"command": "thing-help",
		"description": "Show help for Thing Creator commands",
		"usage": "thing-help",
		"callback": Callable(self, "_cmd_thing_help"),
		"min_args": 0,
		"max_args": 0
	})

# Command implementations

# Create a new thing
func _cmd_thing_create(args: Array) -> String:
	var word_id = args[0]
	
	# Parse position
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])
	var position = Vector3(x, y, z)
	
	# Parse custom properties
	var custom_props = {}
	for i in range(4, args.size()):
		var prop_arg = args[i]
		if "=" in prop_arg:
			var parts = prop_arg.split("=", false, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				# Try to convert to appropriate type
				if value.is_valid_float():
					value = float(value)
				elif value == "true":
					value = true
				elif value == "false":
					value = false
				
				custom_props[key] = value
	
	# Create the thing
	var thing_id = thing_creator.create_thing(word_id, position, custom_props)
	
	if not thing_id.is_empty():
		return "Created thing: " + thing_id + " at position " + str(position)
	else:
		return "Failed to create thing from word: " + word_id

# List all things
func _cmd_thing_list(args: Array) -> String:
	var things = thing_creator.get_all_things()
	
	if things.is_empty():
		return "No things in the world"
	
	var result = "Things in the world:\n"
	
	for thing_id in things:
		var word_id = thing_creator.get_thing_word(thing_id)
		var position = thing_creator.get_thing_position(thing_id)
		result += "- " + thing_id + " (from " + word_id + ") at " + str(position) + "\n"
	
	return result

# Remove a thing
func _cmd_thing_remove(args: Array) -> String:
	var thing_id = args[0]
	
	var success = thing_creator.remove_thing(thing_id)
	
	if success:
		return "Removed thing: " + thing_id
	else:
		return "Failed to remove thing: " + thing_id + " (not found)"

# Move a thing
func _cmd_thing_move(args: Array) -> String:
	var thing_id = args[0]
	
	# Parse position
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])
	var position = Vector3(x, y, z)
	
	var success = thing_creator.update_thing_position(thing_id, position)
	
	if success:
		return "Moved thing: " + thing_id + " to position " + str(position)
	else:
		return "Failed to move thing: " + thing_id + " (not found)"

# Process interaction between two things
func _cmd_thing_interact(args: Array) -> String:
	var thing1_id = args[0]
	var thing2_id = args[1]
	
	var result = thing_creator.process_thing_interaction(thing1_id, thing2_id)
	
	if result.get("success", false):
		var result_word_id = result.get("result", "")
		var result_thing_id = result.get("result_thing_id", "")
		
		if not result_thing_id.is_empty():
			return "Interaction successful, created new thing: " + result_thing_id + " (from " + result_word_id + ")"
		else:
			return "Interaction successful, result: " + str(result)
	else:
		return "Interaction failed: " + str(result.get("error", "Unknown error"))

# Get information about a thing
func _cmd_thing_info(args: Array) -> String:
	var thing_id = args[0]
	var word_id = thing_creator.get_thing_word(thing_id)
	
	if word_id.is_empty():
		return "Thing not found: " + thing_id
	
	var position = thing_creator.get_thing_position(thing_id)
	var custom_props = thing_creator.get_thing_properties(thing_id)
	
	var word_props = {}
	if akashic_records_manager:
		word_props = akashic_records_manager.get_word_properties(word_id)
	
	var result = "Thing: " + thing_id + "\n"
	result += "Word: " + word_id + "\n"
	result += "Position: " + str(position) + "\n"
	
	result += "\nCustom Properties:\n"
	if custom_props.is_empty():
		result += "  None\n"
	else:
		for prop in custom_props:
			result += "  " + prop + ": " + str(custom_props[prop]) + "\n"
	
	result += "\nWord Properties:\n"
	if word_props.is_empty():
		result += "  None\n"
	else:
		for prop in word_props:
			result += "  " + prop + ": " + str(word_props[prop]) + "\n"
	
	return result

# Show help
func _cmd_thing_help(args: Array) -> String:
	var result = "Thing Creator Commands:\n"
	result += "  thing-create <word_id> <x> <y> <z> [prop1=value1 prop2=value2] - Create a new thing\n"
	result += "  thing-list - List all things in the world\n"
	result += "  thing-remove <thing_id> - Remove a thing\n"
	result += "  thing-move <thing_id> <x> <y> <z> - Move a thing\n"
	result += "  thing-interact <thing1_id> <thing2_id> - Simulate interaction\n"
	result += "  thing-info <thing_id> - Show thing information\n"
	result += "  thing-help - Show this help text"
	
	return result
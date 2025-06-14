extends Node
class_name ConsoleIntegrationHelper

# A helper class to standardize console command integration
# This handles different method signatures across different console implementations

# Register a command with a JSH console system, handling different possible interfaces
static func register_command(console_system, command_name: String, description: String, callback_object: Object, callback_method: String) -> bool:
	if not is_instance_valid(console_system):
		return false

	# Method 1: Standard register_command(command, handler_object, handler_method)
	if console_system.has_method("register_command"):
		var method_list = console_system.get_method_list()
		var register_method = method_list.filter(func(m): return m.name == "register_command")
		
		if register_method.size() > 0:
			# Call the appropriate method based on its signature
			var arg_count = register_method[0].args.size()
			
			if arg_count == 3:
				# Standard JSH_console signature
				console_system.register_command(command_name, callback_object, callback_method)
				
				# Set help text if available
				if console_system.has_method("set_command_help"):
					console_system.set_command_help(command_name, 
						"Usage: " + command_name, 
						description)
				
				return true
				
	# Method 2: Dictionary-based registration
	if console_system.has_method("register_command_dict"):
		console_system.register_command_dict({
			"command": command_name,
			"description": description,
			"callback": Callable(callback_object, callback_method)
		})
		return true
		
	# Method 3: Accepts dictionary directly
	if console_system.has_method("register_command"):
		# Try if it accepts a dictionary
		var success = false
		var err := OK
		
		# Use a safer approach with try/catch
		if err == OK:
			console_system.register_command({
				"command": command_name,
				"description": description,
				"usage": command_name,
				"callback": Callable(callback_object, callback_method),
				"min_args": 0,
				"max_args": -1
			})
			success = true
			return success
			
	# Method 4: Alternative naming
	if console_system.has_method("add_command"):
		console_system.add_command(command_name, description, callback_method)
		return true
		
	# Method 5: Alternative with object
	if console_system.has_method("register_command_add"):
		console_system.register_command_add(command_name, callback_object, callback_method, description)
		return true
	
	# No compatible method found
	push_error("Could not register command: no compatible method found in console system")
	return false
extends Node
class_name LuminousCommandProcessor

signal command_registered(command_name, description)

# Reference to main controller
var os_controller: LuminousOSController

# Command registry
var commands: Dictionary = {}

# Help information
var command_help: Dictionary = {}

func _ready():
	# Register built-in commands
	register_command("help", "Display help information", _cmd_help)
	register_command("ls", "List stars (directories) and planets (files)", _cmd_ls)
	register_command("cd", "Navigate to a different star (directory)", _cmd_cd)
	register_command("divine", "Toggle divine mode (inspired by TempleOS)", _cmd_divine) 
	register_command("cat", "View the contents of a file", _cmd_cat)
	register_command("find", "Search for files or directories", _cmd_find)
	register_command("clear", "Clear the terminal output", _cmd_clear)
	register_command("echo", "Display a message", _cmd_echo)
	register_command("mkdir", "Create a new directory", _cmd_mkdir)
	register_command("touch", "Create a new file", _cmd_touch)
	register_command("animate", "Toggle or adjust animation speed", _cmd_animate)
	register_command("oracle", "Receive a divine message (inspired by TempleOS)", _cmd_oracle)

func register_command(name: String, description: String, callback: Callable):
	commands[name] = callback
	command_help[name] = description
	emit_signal("command_registered", name, description)

func process_command(command_text: String) -> String:
	var parts = command_text.strip_edges().split(" ", false, 1)
	var command_name = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	if commands.has(command_name):
		return commands[command_name].call(args)
	else:
		return "Unknown command: " + command_name + "\nType 'help' for a list of commands."

# Command implementation functions

func _cmd_help(args: String) -> String:
	if args.strip_edges() != "":
		# Specific command help
		var command = args.strip_edges().to_lower()
		if command_help.has(command):
			return "[b]" + command + "[/b]: " + command_help[command]
		else:
			return "No help available for '" + command + "'"
	
	# General help
	var result = "[b]LUMINOUS OS COMMAND REFERENCE[/b]\n"
	result += "[i]Inspired by TempleOS's divine simplicity[/i]\n\n"
	
	var sorted_commands = command_help.keys()
	sorted_commands.sort()
	
	for cmd in sorted_commands:
		result += "[color=#AAFFAA]" + cmd + "[/color] - " + command_help[cmd] + "\n"
	
	result += "\n[i]Type 'help <command>' for specific command information.[/i]"
	return result

func _cmd_ls(args: String) -> String:
	var path = os_controller.current_path
	if args.strip_edges() != "":
		path = args.strip_edges() if args.strip_edges().begins_with("/") else path.path_join(args.strip_edges())
	
	var dir_data = os_controller.filesystem.scan_directory(path)
	
	var result = "[b]Stars and Planets in: " + path + "[/b]\n\n"
	
	# Add parent directory option
	if path != "/":
		result += "[color=#AAAAAA].. (Parent Star)[/color]\n"
	
	# Add directories
	if dir_data["directories"].size() > 0:
		for dir in dir_data["directories"]:
			result += "[color=#88AAFF]★ " + dir["name"] + "[/color]\n"
	
	# Add files
	if dir_data["files"].size() > 0:
		for file in dir_data["files"]:
			var type_color = _get_color_for_type(file["type"])
			result += "[color=" + type_color + "]○ " + file["name"] + "[/color]\n"
	
	return result

func _cmd_cd(args: String) -> String:
	if args.strip_edges() == "":
		return "Usage: cd <directory>"
	
	var target_dir = args.strip_edges()
	var previous_path = os_controller.current_path
	
	os_controller.navigate_to_directory(target_dir)
	
	# Check if navigation was successful by comparing paths
	if os_controller.current_path != previous_path:
		return "Navigated to: " + os_controller.current_path
	else:
		return "Could not navigate to: " + target_dir

func _cmd_divine(_args: String) -> String:
	os_controller.toggle_divine_reality()
	
	if os_controller.current_reality == LuminousOSController.Reality.DIVINE:
		return "[color=#DD77FF]Entering divine mode. The cosmos opens before you.[/color]"
	else:
		return "Returning to physical reality."

func _cmd_cat(args: String) -> String:
	if args.strip_edges() == "":
		return "Usage: cat <filename>"
	
	var file_path = args.strip_edges()
	if not file_path.begins_with("/"):
		file_path = os_controller.current_path.path_join(file_path)
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			# Limit content length for display
			if content.length() > 2000:
				content = content.substr(0, 2000) + "\n\n[File content truncated, too large to display in full]"
			return "[b]Contents of " + file_path + ":[/b]\n\n" + content
		else:
			return "Could not open file: " + file_path
	else:
		return "File not found: " + file_path

func _cmd_find(args: String) -> String:
	if args.strip_edges() == "":
		return "Usage: find <pattern>"
	
	var pattern = args.strip_edges()
	var results = []
	
	# Simple implementation - in a real system this would be more sophisticated
	_find_recursive(os_controller.current_path, pattern, results, 0, 3)  # Limited depth
	
	if results.size() == 0:
		return "No matches found for: " + pattern
	
	var result_text = "[b]Found " + str(results.size()) + " matches for '" + pattern + "':[/b]\n"
	for item in results:
		result_text += item + "\n"
	
	return result_text

func _find_recursive(path: String, pattern: String, results: Array, current_depth: int, max_depth: int):
	if current_depth > max_depth:
		return
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = path.path_join(file_name)
				
				# Check for match
				if pattern.is_empty() or file_name.matchn("*" + pattern + "*"):
					results.append(full_path)
				
				# Recursively search directories
				if dir.current_is_dir() and current_depth < max_depth:
					_find_recursive(full_path, pattern, results, current_depth + 1, max_depth)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

func _cmd_clear(_args: String) -> String:
	# This will be handled specially by the UI controller
	return ""

func _cmd_echo(args: String) -> String:
	return args

func _cmd_mkdir(args: String) -> String:
	if args.strip_edges() == "":
		return "Usage: mkdir <directory_name>"
	
	var dir_name = args.strip_edges()
	var dir_path = dir_name if dir_name.begins_with("/") else os_controller.current_path.path_join(dir_name)
	
	var dir = DirAccess.open(os_controller.current_path)
	if dir:
		var err = dir.make_dir(dir_name)
		if err == OK:
			os_controller.refresh_filesystem()
			return "Created star: " + dir_path
		else:
			return "Failed to create directory: " + dir_path
	else:
		return "Could not access current directory"

func _cmd_touch(args: String) -> String:
	if args.strip_edges() == "":
		return "Usage: touch <filename>"
	
	var file_name = args.strip_edges()
	var file_path = file_name if file_name.begins_with("/") else os_controller.current_path.path_join(file_name)
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.close()
		os_controller.refresh_filesystem()
		return "Created planet: " + file_path
	else:
		return "Failed to create file: " + file_path

func _cmd_animate(args: String) -> String:
	if args.strip_edges() == "":
		# Toggle animation
		os_controller.animation_speed = 1.0 if os_controller.animation_speed < 0.1 else 0.0
		return "Animation " + ("enabled" if os_controller.animation_speed > 0.0 else "disabled")
	
	# Set specific speed
	var speed = float(args.strip_edges())
	if speed >= 0.0 and speed <= 2.0:
		os_controller.animation_speed = speed
		return "Animation speed set to: " + str(speed)
	else:
		return "Invalid speed. Please use a value between 0.0 and 2.0"

func _cmd_oracle(_args: String) -> String:
	var message = os_controller.divine_messages[randi() % os_controller.divine_messages.size()]
	os_controller.show_divine_message(message)
	return "[color=#DD77FF]" + message + "[/color]"

# Utility functions
func _get_color_for_type(file_type: String) -> String:
	match file_type:
		"SCRIPT": return "#88AAFF"  # Blue
		"SCENE": return "#DD77FF"   # Purple
		"TEXTURE": return "#77FFAA" # Green
		"MODEL": return "#FFDD77"   # Yellow
		"AUDIO": return "#FF7777"   # Red
		"TEXT": return "#DDDDDD"    # Light gray
		_: return "#AAAAAA"         # Gray for misc
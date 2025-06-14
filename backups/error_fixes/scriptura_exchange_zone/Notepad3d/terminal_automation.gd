extends Node

class_name TerminalAutomation

# Terminal Automation System
# Provides a terminal interface for running commands and automating tasks
# Works with the visualization system to control it via terminal commands

# Terminal settings
const MAX_HISTORY = 100
const PROMPT = ">> "
const WELCOME_MESSAGE = """
=== TERMINAL AUTOMATION SYSTEM ===
Type 'help' for available commands
Type 'exit' to close the terminal
================================
"""

# Command history
var command_history = []
var history_index = -1

# Registered commands
var commands = {}

# Terminal input/output
var terminal_input = ""
var terminal_output = []

# References
var visualizer = null
var connector = null
var analyzer = null
var project_loader = null

# Status tracking
var is_active = true
var auto_execute = false
var command_queue = []

# Execution environment
var env = {
	"cwd": "/mnt/c/Users/Percision 15",
	"last_result": null,
	"variables": {},
	"status": 0
}

# Signals
signal command_executed(command, result)
signal terminal_closed()
signal automation_completed()

func _init():
	# Register built-in commands
	_register_core_commands()

func _ready():
	# Show welcome message
	output(WELCOME_MESSAGE)
	output(PROMPT)

func _process(delta):
	# Process command queue if auto-execute is enabled
	if auto_execute and command_queue.size() > 0:
		var command = command_queue.pop_front()
		execute_command(command)
		
		# If queue is empty, notify completion
		if command_queue.size() == 0:
			auto_execute = false
			emit_signal("automation_completed")

# Execute a command string
func execute_command(command_str):
	if command_str.empty():
		output(PROMPT)
		return
	
	# Add to history
	command_history.append(command_str)
	if command_history.size() > MAX_HISTORY:
		command_history.remove(0)
	history_index = command_history.size()
	
	# Echo command
	output(PROMPT + command_str)
	
	# Parse the command
	var parts = command_str.split(" ", false)
	var command_name = parts[0].to_lower()
	var args = parts.slice(1, parts.size() - 1)
	
	# Execute the command
	var result = null
	
	if commands.has(command_name):
		var command = commands[command_name]
		result = command.callback.call_func(args)
		env.status = 0  # Success by default
	else:
		result = "Unknown command: " + command_name
		env.status = 1  # Error
	
	# Store result in environment
	env.last_result = result
	
	# Output result
	if result != null:
		if result is String:
			output(result)
		else:
			output(str(result))
	
	# Show prompt for next command
	output(PROMPT)
	
	# Emit signal
	emit_signal("command_executed", command_str, result)
	
	return result

# Add a line to the terminal output
func output(text):
	terminal_output.append(text)
	print(text)  # Also print to Godot console for debugging
	
	# If connected to a visualizer, show in its console
	if visualizer != null:
		var color = "FFFF00"  # Default yellow
		
		# Use different colors based on context
		if text.begins_with("ERROR"):
			color = "FF0000"  # Red for errors
		elif text.begins_with("SUCCESS"):
			color = "00FF00"  # Green for success
		elif text.begins_with(PROMPT):
			color = "00FFFF"  # Cyan for commands
		
		visualizer.console_log(text, color)

# Connect to a visualizer
func connect_visualizer(vis):
	if vis == null:
		output("ERROR: Invalid visualizer")
		return false
	
	visualizer = vis
	output("Connected to visualizer")
	
	# Register visualizer commands
	_register_visualizer_commands()
	
	return true

# Connect to a project connector
func connect_project_connector(conn):
	if conn == null:
		output("ERROR: Invalid connector")
		return false
	
	connector = conn
	output("Connected to project connector")
	
	# Register connector commands
	_register_connector_commands()
	
	return true

# Connect to a token analyzer
func connect_token_analyzer(ana):
	if ana == null:
		output("ERROR: Invalid analyzer")
		return false
	
	analyzer = ana
	output("Connected to token analyzer")
	
	# Register analyzer commands
	_register_analyzer_commands()
	
	return true

# Connect to a project loader
func connect_project_loader(loader):
	if loader == null:
		output("ERROR: Invalid project loader")
		return false
	
	project_loader = loader
	output("Connected to project loader")
	
	# Register loader commands
	_register_loader_commands()
	
	return true

# Parse arguments with flags
func parse_args(args):
	var result = {
		"args": [],
		"flags": {}
	}
	
	var i = 0
	while i < args.size():
		var arg = args[i]
		
		if arg.begins_with("--"):
			# Long flag
			var flag_name = arg.substr(2)
			
			# Check if the flag has a value
			if i + 1 < args.size() and not args[i+1].begins_with("-"):
				result.flags[flag_name] = args[i+1]
				i += 2
			else:
				result.flags[flag_name] = true
				i += 1
		elif arg.begins_with("-"):
			# Short flag
			var flag_name = arg.substr(1)
			
			# Check if the flag has a value
			if i + 1 < args.size() and not args[i+1].begins_with("-"):
				result.flags[flag_name] = args[i+1]
				i += 2
			else:
				result.flags[flag_name] = true
				i += 1
		else:
			# Regular argument
			result.args.append(arg)
			i += 1
	
	return result

# Queue multiple commands for execution
func queue_commands(commands_array):
	for cmd in commands_array:
		command_queue.append(cmd)
	
	output("Queued " + str(commands_array.size()) + " commands")
	return command_queue.size()

# Start automated execution of queued commands
func start_automation():
	if command_queue.size() == 0:
		output("ERROR: No commands in queue")
		return false
	
	auto_execute = true
	output("Starting automation with " + str(command_queue.size()) + " commands")
	return true

# Stop automated execution
func stop_automation():
	auto_execute = false
	output("Automation stopped with " + str(command_queue.size()) + " commands remaining")
	return true

# Register a new command
func register_command(name, description, callback, min_args = 0, usage = null):
	commands[name] = {
		"name": name,
		"description": description,
		"callback": callback,
		"min_args": min_args,
		"usage": usage
	}
	
	return true

# Register the core command set
func _register_core_commands():
	# Help command
	register_command("help", "Display available commands", funcref(self, "_cmd_help"))
	
	# Echo command
	register_command("echo", "Display a message", funcref(self, "_cmd_echo"), 1, "echo <message>")
	
	# Clear command
	register_command("clear", "Clear the terminal", funcref(self, "_cmd_clear"))
	
	# Exit command
	register_command("exit", "Close the terminal", funcref(self, "_cmd_exit"))
	
	# Variable commands
	register_command("set", "Set a variable", funcref(self, "_cmd_set"), 2, "set <variable> <value>")
	register_command("get", "Get a variable value", funcref(self, "_cmd_get"), 1, "get <variable>")
	register_command("env", "Display the environment", funcref(self, "_cmd_env"))
	
	# Automation commands
	register_command("queue", "Queue a command for later execution", funcref(self, "_cmd_queue"), 1, "queue <command>")
	register_command("run", "Run queued commands", funcref(self, "_cmd_run"))
	register_command("stop", "Stop automated execution", funcref(self, "_cmd_stop"))
	register_command("list", "List queued commands", funcref(self, "_cmd_list"))
	register_command("script", "Run commands from a script file", funcref(self, "_cmd_script"), 1, "script <file_path>")
	
	# File system commands
	register_command("ls", "List files in directory", funcref(self, "_cmd_ls"))
	register_command("cd", "Change current directory", funcref(self, "_cmd_cd"), 1, "cd <directory>")
	register_command("pwd", "Print working directory", funcref(self, "_cmd_pwd"))
	register_command("cat", "Display file contents", funcref(self, "_cmd_cat"), 1, "cat <file_path>")

# Register visualizer commands
func _register_visualizer_commands():
	if visualizer == null:
		return
	
	# Visualizer commands
	register_command("viz", "Control visualizer", funcref(self, "_cmd_viz"), 1, "viz <subcommand> [args]")
	register_command("capture", "Capture a frame", funcref(self, "_cmd_capture"))
	register_command("console", "Toggle console visibility", funcref(self, "_cmd_console"))
	register_command("debug", "Toggle debug markers visibility", funcref(self, "_cmd_debug"))
	register_command("source", "Set active data source", funcref(self, "_cmd_source"), 1, "source <source_name>")

# Register connector commands
func _register_connector_commands():
	if connector == null:
		return
	
	# Connector commands
	register_command("connect", "Connect components", funcref(self, "_cmd_connect"), 2, "connect <source> <target> [type]")
	register_command("find", "Find components", funcref(self, "_cmd_find"), 1, "find <pattern>")
	register_command("topology", "Show connection topology", funcref(self, "_cmd_topology"))

# Register analyzer commands
func _register_analyzer_commands():
	if analyzer == null:
		return
	
	# Analyzer commands
	register_command("analyze", "Analyze a file", funcref(self, "_cmd_analyze"), 1, "analyze <file_path> [strategy]")
	register_command("compare", "Compare two files", funcref(self, "_cmd_compare"), 2, "compare <file1> <file2>")
	register_command("tokens", "Show tokens from a file", funcref(self, "_cmd_tokens"), 1, "tokens <file_path>")

# Register loader commands
func _register_loader_commands():
	if project_loader == null:
		return
	
	# Loader commands
	register_command("load", "Load projects", funcref(self, "_cmd_load"))
	register_command("summary", "Show project summary", funcref(self, "_cmd_summary"))
	register_command("export", "Export visualization", funcref(self, "_cmd_export"), 0, "export [output_path]")

# Command implementations

func _cmd_help(args):
	var result = "Available commands:\n"
	
	# Sort command names
	var command_names = commands.keys()
	command_names.sort()
	
	for name in command_names:
		var command = commands[name]
		result += "  " + name + " - " + command.description + "\n"
		
		if command.usage != null:
			result += "    Usage: " + command.usage + "\n"
	
	return result

func _cmd_echo(args):
	return args.join(" ")

func _cmd_clear(args):
	terminal_output.clear()
	return ""

func _cmd_exit(args):
	is_active = false
	emit_signal("terminal_closed")
	return "Closing terminal..."

func _cmd_set(args):
	if args.size() < 2:
		return "ERROR: Usage: set <variable> <value>"
	
	var var_name = args[0]
	var var_value = args.slice(1, args.size() - 1).join(" ")
	
	# Try to convert to number if possible
	if var_value.is_valid_float():
		var_value = float(var_value)
	elif var_value.is_valid_integer():
		var_value = int(var_value)
	
	env.variables[var_name] = var_value
	return "Set " + var_name + " = " + str(var_value)

func _cmd_get(args):
	if args.size() < 1:
		return "ERROR: Usage: get <variable>"
	
	var var_name = args[0]
	
	if env.variables.has(var_name):
		return var_name + " = " + str(env.variables[var_name])
	else:
		return "ERROR: Variable not found: " + var_name

func _cmd_env(args):
	var result = "Environment variables:\n"
	
	result += "  cwd = " + env.cwd + "\n"
	result += "  status = " + str(env.status) + "\n"
	
	if env.variables.size() > 0:
		result += "  Custom variables:\n"
		
		for var_name in env.variables:
			result += "    " + var_name + " = " + str(env.variables[var_name]) + "\n"
	
	return result

func _cmd_queue(args):
	if args.size() < 1:
		return "ERROR: Usage: queue <command>"
	
	var command = args.join(" ")
	command_queue.append(command)
	
	return "Queued command: " + command

func _cmd_run(args):
	if command_queue.size() == 0:
		return "ERROR: No commands in queue"
	
	start_automation()
	return "Running " + str(command_queue.size()) + " queued commands..."

func _cmd_stop(args):
	stop_automation()
	return "Automation stopped"

func _cmd_list(args):
	if command_queue.size() == 0:
		return "No commands in queue"
	
	var result = "Queued commands (" + str(command_queue.size()) + "):\n"
	
	for i in range(command_queue.size()):
		result += "  " + str(i+1) + ". " + command_queue[i] + "\n"
	
	return result

func _cmd_script(args):
	if args.size() < 1:
		return "ERROR: Usage: script <file_path>"
	
	var file_path = args[0]
	
	# If path is relative, make it absolute
	if not file_path.begins_with("/"):
		file_path = env.cwd + "/" + file_path
	
	var file = File.new()
	if not file.file_exists(file_path):
		return "ERROR: File not found: " + file_path
	
	if file.open(file_path, File.READ) != OK:
		return "ERROR: Could not open file: " + file_path
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var commands_added = 0
	
	for line in lines:
		line = line.strip_edges()
		
		# Skip empty lines and comments
		if line.empty() or line.begins_with("#"):
			continue
		
		command_queue.append(line)
		commands_added += 1
	
	return "Added " + str(commands_added) + " commands from script"

func _cmd_ls(args):
	var path = env.cwd
	
	# Check if a path was specified
	if args.size() > 0:
		path = args[0]
		
		# If path is relative, make it absolute
		if not path.begins_with("/"):
			path = env.cwd + "/" + path
	
	var dir = Directory.new()
	if not dir.dir_exists(path):
		return "ERROR: Directory not found: " + path
	
	if dir.open(path) != OK:
		return "ERROR: Could not open directory: " + path
	
	dir.list_dir_begin(true, true)
	var result = "Contents of " + path + ":\n"
	
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			result += "  [DIR] " + file_name + "\n"
		else:
			result += "  " + file_name + "\n"
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	return result

func _cmd_cd(args):
	if args.size() < 1:
		return "ERROR: Usage: cd <directory>"
	
	var path = args[0]
	
	# If path is relative, make it absolute
	if not path.begins_with("/"):
		path = env.cwd + "/" + path
	
	var dir = Directory.new()
	if not dir.dir_exists(path):
		return "ERROR: Directory not found: " + path
	
	env.cwd = path
	return "Changed directory to " + path

func _cmd_pwd(args):
	return env.cwd

func _cmd_cat(args):
	if args.size() < 1:
		return "ERROR: Usage: cat <file_path>"
	
	var file_path = args[0]
	
	# If path is relative, make it absolute
	if not file_path.begins_with("/"):
		file_path = env.cwd + "/" + file_path
	
	var file = File.new()
	if not file.file_exists(file_path):
		return "ERROR: File not found: " + file_path
	
	if file.open(file_path, File.READ) != OK:
		return "ERROR: Could not open file: " + file_path
	
	var content = file.get_as_text()
	file.close()
	
	return content

func _cmd_viz(args):
	if visualizer == null:
		return "ERROR: No visualizer connected"
	
	if args.size() < 1:
		return "ERROR: Usage: viz <subcommand> [args]"
	
	var subcommand = args[0]
	var subargs = args.slice(1, args.size() - 1)
	
	match subcommand:
		"capture":
			return _cmd_capture(subargs)
		"console":
			return _cmd_console(subargs)
		"debug":
			return _cmd_debug(subargs)
		"source":
			return _cmd_source(subargs)
		_:
			return "ERROR: Unknown subcommand: " + subcommand

func _cmd_capture(args):
	if visualizer == null:
		return "ERROR: No visualizer connected"
	
	var frame = visualizer.capture_frame()
	return "Captured frame " + str(frame)

func _cmd_console(args):
	if visualizer == null:
		return "ERROR: No visualizer connected"
	
	visualizer.toggle_console()
	return "Toggled console visibility"

func _cmd_debug(args):
	if visualizer == null:
		return "ERROR: No visualizer connected"
	
	visualizer.toggle_debug_markers()
	return "Toggled debug markers visibility"

func _cmd_source(args):
	if visualizer == null:
		return "ERROR: No visualizer connected"
	
	if args.size() < 1:
		return "ERROR: Usage: source <source_name>"
	
	var source_name = args[0]
	var success = visualizer.set_active_source(source_name)
	
	if success:
		return "Set active source to " + source_name
	else:
		return "ERROR: Failed to set source: " + source_name

func _cmd_connect(args):
	if connector == null:
		return "ERROR: No connector connected"
	
	if args.size() < 2:
		return "ERROR: Usage: connect <source> <target> [type]"
	
	var source_id = args[0]
	var target_id = args[1]
	var connection_type = 0  # Default to FILE_LINK
	
	if args.size() >= 3:
		# Try to parse connection type
		match args[2].to_lower():
			"file":
				connection_type = 0  # FILE_LINK
			"variable":
				connection_type = 1  # VARIABLE_MIRROR
			"signal":
				connection_type = 2  # SIGNAL_BRIDGE
			"system":
				connection_type = 3  # SYSTEM_LINK
			"api":
				connection_type = 4  # API_CONNECTOR
			_:
				# Try to parse as a number
				if args[2].is_valid_integer():
					connection_type = int(args[2])
	
	var success = connector.connect_components(source_id, target_id, connection_type)
	
	if success:
		return "Connected " + source_id + " to " + target_id + " (type " + str(connection_type) + ")"
	else:
		return "ERROR: Failed to connect components"

func _cmd_find(args):
	if connector == null:
		return "ERROR: No connector connected"
	
	if args.size() < 1:
		return "ERROR: Usage: find <pattern>"
	
	var pattern = args[0]
	var matches = connector.find_components(connector.MatchCriteria.NAME_PATTERN, pattern)
	
	if matches.size() == 0:
		return "No components matching pattern: " + pattern
	
	var result = "Found " + str(matches.size()) + " components matching pattern: " + pattern + "\n"
	
	for i in range(matches.size()):
		result += "  " + str(i+1) + ". " + matches[i] + "\n"
	
	return result

func _cmd_topology(args):
	if connector == null:
		return "ERROR: No connector connected"
	
	var topology = connector.get_connection_topology()
	
	var result = "Connection Topology:\n"
	result += "  Components: " + str(topology.components.size()) + "\n"
	result += "  Connections: " + str(topology.connections.size()) + "\n"
	result += "  Projects: " + str(topology.projects.size()) + "\n"
	
	return result

func _cmd_analyze(args):
	if analyzer == null:
		return "ERROR: No analyzer connected"
	
	if args.size() < 1:
		return "ERROR: Usage: analyze <file_path> [strategy]"
	
	var file_path = args[0]
	
	# If path is relative, make it absolute
	if not file_path.begins_with("/"):
		file_path = env.cwd + "/" + file_path
	
	var strategy = analyzer.TokenStrategy.CODE_TOKENS
	
	if args.size() >= 2:
		# Try to parse strategy
		match args[1].to_lower():
			"code":
				strategy = analyzer.TokenStrategy.CODE_TOKENS
			"natural":
				strategy = analyzer.TokenStrategy.NATURAL_LANGUAGE
			"semantic":
				strategy = analyzer.TokenStrategy.SEMANTIC_TOKENS
			"variable":
				strategy = analyzer.TokenStrategy.VARIABLE_NAMES
			"function":
				strategy = analyzer.TokenStrategy.FUNCTION_NAMES
			_:
				# Try to parse as a number
				if args[1].is_valid_integer():
					strategy = int(args[1])
	
	var tokens = analyzer.tokenize_file(file_path, strategy)
	
	var result = "Analyzed " + file_path + " with strategy " + str(strategy) + ":\n"
	result += "  Found " + str(tokens.size()) + " tokens\n"
	
	# Count token types
	var type_counts = {}
	for token in tokens:
		if not type_counts.has(token.type):
			type_counts[token.type] = 0
		type_counts[token.type] += 1
	
	result += "  Token types:\n"
	for type in type_counts:
		result += "    Type " + str(type) + ": " + str(type_counts[type]) + "\n"
	
	return result

func _cmd_compare(args):
	if analyzer == null:
		return "ERROR: No analyzer connected"
	
	if args.size() < 2:
		return "ERROR: Usage: compare <file1> <file2>"
	
	var file1 = args[0]
	var file2 = args[1]
	
	# If paths are relative, make them absolute
	if not file1.begins_with("/"):
		file1 = env.cwd + "/" + file1
	if not file2.begins_with("/"):
		file2 = env.cwd + "/" + file2
	
	var tokens1 = analyzer.tokenize_file(file1)
	var tokens2 = analyzer.tokenize_file(file2)
	
	var similarities = analyzer.find_similar_tokens(tokens1, tokens2)
	
	var result = "Compared " + file1 + " with " + file2 + ":\n"
	result += "  " + str(tokens1.size()) + " tokens in file 1\n"
	result += "  " + str(tokens2.size()) + " tokens in file 2\n"
	result += "  Found " + str(similarities.size()) + " similar tokens\n"
	
	if similarities.size() > 0:
		result += "  Top similar tokens:\n"
		
		for i in range(min(5, similarities.size())):
			var sim = similarities[i]
			result += "    " + sim.token1.text + " -- " + sim.token2.text + " (" + str(sim.similarity) + ")\n"
	
	return result

func _cmd_tokens(args):
	if analyzer == null:
		return "ERROR: No analyzer connected"
	
	if args.size() < 1:
		return "ERROR: Usage: tokens <file_path>"
	
	var file_path = args[0]
	
	# If path is relative, make it absolute
	if not file_path.begins_with("/"):
		file_path = env.cwd + "/" + file_path
	
	var tokens = analyzer.tokenize_file(file_path)
	
	var result = "Tokens from " + file_path + ":\n"
	
	for i in range(min(20, tokens.size())):
		var token = tokens[i]
		result += "  " + token.text + " (Type " + str(token.type) + ", Line " + str(token.line) + ")\n"
	
	if tokens.size() > 20:
		result += "  ... " + str(tokens.size() - 20) + " more tokens\n"
	
	return result

func _cmd_load(args):
	if project_loader == null:
		return "ERROR: No project loader connected"
	
	var auto_link = true
	
	# Parse flags
	var parsed = parse_args(args)
	if parsed.flags.has("no-link"):
		auto_link = false
	
	project_loader.connect_all_projects(auto_link)
	return "Loaded projects with auto-link=" + str(auto_link)

func _cmd_summary(args):
	if project_loader == null:
		return "ERROR: No project loader connected"
	
	var summary = project_loader.get_connection_summary()
	
	var result = "Project Summary:\n"
	result += "  Projects: " + str(summary.projects.size()) + "\n"
	
	result += "  Project details:\n"
	for project_name in summary.projects:
		var project = summary.projects[project_name]
		result += "    " + project_name + ": " + str(project.components) + " components, " + str(project.connections) + " connections\n"
	
	result += "  Connections: " + str(summary.connections.total) + " total, " + str(summary.connections.cross_project) + " cross-project\n"
	
	result += "  Connection types:\n"
	for type in summary.connections.by_type:
		result += "    Type " + str(type) + ": " + str(summary.connections.by_type[type]) + "\n"
	
	return result

func _cmd_export(args):
	if project_loader == null:
		return "ERROR: No project loader connected"
	
	var output_path = "/mnt/c/Users/Percision 15/project_connections.html"
	
	if args.size() >= 1:
		output_path = args[0]
	
	project_loader.export_visualization(output_path)
	return "Exported visualization to " + output_path
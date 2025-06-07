extends Node

class_name UnifiedTerminalInterface

# Terminal configuration
var config = {
	"max_lines": 500,
	"visible_lines": 25,
	"prompt": "λ> ",
	"command_history_size": 100,
	"auto_scroll": true,
	"theme": {
		"background_color": Color(0.1, 0.1, 0.12),
		"text_color": Color(0.8, 0.8, 0.9),
		"prompt_color": Color(0.4, 0.8, 0.4),
		"error_color": Color(0.9, 0.3, 0.3),
		"info_color": Color(0.4, 0.7, 0.9),
		"wish_color": Color(0.9, 0.7, 0.3),
		"highlight_color": Color(0.5, 0.8, 0.9),
		"dim_color": Color(0.5, 0.5, 0.6)
	},
	"command_timeout": 60, # Seconds
	"multiple_interfaces": false
}

# Storage for terminal lines
var terminal_lines = []
var command_history = []
var command_history_index = -1
var current_input = ""
var scroll_position = 0

# Interface windows for multi-terminal mode
var interface_windows = []
var active_window_index = 0

# System integration references
var storage_system = null
var akashic_bridge = null
var current_turn = 1

# Command execution state
var executing_command = false
var command_start_time = 0
var current_command = ""

# Wish tracking
var pending_wishes = []
var completed_wishes = []

# ASCII art for terminal headers
var ascii_headers = {
	"main": [
		"┌─────────────────────────────────────────────────────┐",
		"│  ██╗░░░██╗███╗░░██╗██╗███████╗██╗███████╗██████╗░  │",
		"│  ██║░░░██║████╗░██║██║██╔════╝██║██╔════╝██╔══██╗  │",
		"│  ██║░░░██║██╔██╗██║██║█████╗░░██║█████╗░░██║░░██║  │",
		"│  ██║░░░██║██║╚████║██║██╔══╝░░██║██╔══╝░░██║░░██║  │",
		"│  ╚██████╔╝██║░╚███║██║██║░░░░░██║███████╗██████╔╝  │",
		"│  ░╚═════╝░╚═╝░░╚══╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░  │",
		"│         TERMINAL & WISH INTERFACE SYSTEM           │",
		"└─────────────────────────────────────────────────────┘"
	],
	"notepad3d": [
		"┌─────────────────────────────────────────────────────┐",
		"│     ███╗░░██╗░█████╗░████████╗███████╗██████╗░     │",
		"│     ████╗░██║██╔══██╗╚══██╔══╝██╔════╝██╔══██╗     │",
		"│     ██╔██╗██║██║░░██║░░░██║░░░█████╗░░██████╔╝     │",
		"│     ██║╚████║██║░░██║░░░██║░░░██╔══╝░░██╔═══╝░     │",
		"│     ██║░╚███║╚█████╔╝░░░██║░░░███████╗██║░░░░░     │",
		"│     ╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░░░░     │",
		"│                      ██████╗░██████╗░               │",
		"│                      ╚════██╗██╔══██╗               │",
		"│                      ░█████╔╝██║░░██║               │",
		"│                      ░╚═══██╗██║░░██║               │",
		"│                      ██████╔╝██████╔╝               │",
		"│                      ╚═════╝░╚═════╝░               │",
		"└─────────────────────────────────────────────────────┘"
	],
	"wishes": [
		"┌─────────────────────────────────────────────────────┐",
		"│  ░██╗░░░░░░░██╗██╗░██████╗██╗░░██╗███████╗░██████╗  │",
		"│  ░██║░░██╗░░██║██║██╔════╝██║░░██║██╔════╝██╔════╝  │",
		"│  ░╚██╗████╗██╔╝██║╚█████╗░███████║█████╗░░╚█████╗░  │",
		"│  ░░████╔═████║░██║░╚═══██╗██╔══██║██╔══╝░░░╚═══██╗  │",
		"│  ░░╚██╔╝░╚██╔╝░██║██████╔╝██║░░██║███████╗██████╔╝  │",
		"│  ░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░  │",
		"│           INTERDIMENSIONAL DESIRE SYSTEM            │",
		"└─────────────────────────────────────────────────────┘"
	],
	"storage": [
		"┌─────────────────────────────────────────────────────┐",
		"│   ░██████╗████████╗░█████╗░██████╗░░█████╗░░██████╗  │",
		"│   ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝  │",
		"│   ╚█████╗░░░░██║░░░██║░░██║██████╔╝███████║██║░░██╗  │",
		"│   ░╚═══██╗░░░██║░░░██║░░██║██╔══██╗██╔══██║██║░░╚██╗ │",
		"│   ██████╔╝░░░██║░░░╚█████╔╝██║░░██║██║░░██║╚██████╔╝ │",
		"│   ╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚═════╝░ │",
		"│          MULTI-CLOUD INTEGRATION SYSTEM             │",
		"└─────────────────────────────────────────────────────┘"
	],
	"akashic": [
		"┌─────────────────────────────────────────────────────┐",
		"│   ░█████╗░██╗░░██╗░█████╗░░██████╗██╗░░██╗██╗░█████╗  │",
		"│   ██╔══██╗██║░██╔╝██╔══██╗██╔════╝██║░░██║██║██╔══██╗ │",
		"│   ███████║█████═╝░███████║╚█████╗░███████║██║██║░░╚═╝ │",
		"│   ██╔══██║██╔═██╗░██╔══██║░╚═══██╗██╔══██║██║██║░░██╗ │",
		"│   ██║░░██║██║░╚██╗██║░░██║██████╔╝██║░░██║██║╚█████╔╝ │",
		"│   ╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚═╝░╚════╝░ │",
		"│                RECORDS DATABASE SYSTEM               │",
		"└─────────────────────────────────────────────────────┘"
	]
}

# Symbol patterns for visual effects
var symbols = {
	"borders": ["┌", "┐", "└", "┘", "─", "│"],
	"fills": ["░", "▒", "▓", "█"],
	"connectors": ["┼", "┬", "┴", "┤", "├"],
	"bullets": ["•", "◦", "⦿", "◎", "◉"],
	"arrows": ["→", "←", "↑", "↓", "↕", "↔", "⇒", "⇑", "⇓", "⇐"],
	"special": ["★", "✦", "✧", "☆", "✩", "⚝", "⚫", "⚪"]
}

# Signals
signal command_executed(command, result)
signal wish_processed(wish_id, result)
signal interface_changed(interface_name)
signal terminal_ready

func _ready():
	# Initialize terminal
	initialize_terminal()
	
	# Connect to integration systems
	connect_integration_systems()
	
	# Show welcome message
	show_welcome_message()
	
	emit_signal("terminal_ready")

func initialize_terminal():
	# Reset terminal state
	terminal_lines = []
	command_history = []
	command_history_index = -1
	
	# Add header
	add_ascii_header("main")
	
	# Create interface windows for multi-terminal
	if config.multiple_interfaces:
		create_interface_windows()

func connect_integration_systems():
	# Connect to Storage System
	if ClassDB.class_exists("StorageIntegrationSystem"):
		storage_system = StorageIntegrationSystem.new()
		add_child(storage_system)
		print("Connected to Storage Integration System")
	
	# Connect to Akashic Bridge
	if ClassDB.class_exists("ClaudeAkashicBridge"):
		akashic_bridge = ClaudeAkashicBridge.new()
		add_child(akashic_bridge)
		print("Connected to Claude Akashic Bridge")
	
	# Determine current turn
	load_current_turn()

func create_interface_windows():
	# Create multiple terminal interface windows
	interface_windows = [
		{
			"name": "main",
			"title": "Main Terminal",
			"lines": [],
			"scroll_position": 0,
			"active": true
		},
		{
			"name": "wishes",
			"title": "Wish System",
			"lines": [],
			"scroll_position": 0,
			"active": false
		},
		{
			"name": "storage",
			"title": "Storage Manager",
			"lines": [],
			"scroll_position": 0,
			"active": false
		},
		{
			"name": "notepad3d",
			"title": "Notepad 3D",
			"lines": [],
			"scroll_position": 0,
			"active": false
		}
	]
	
	# Add headers to each window
	for window in interface_windows:
		window.lines.append_array(ascii_headers[window.name])
		window.lines.append("")
		window.lines.append("Welcome to " + window.title)
		window.lines.append("")

func show_welcome_message():
	add_colored_line("Welcome to the Unified Terminal Interface", config.theme.info_color)
	add_colored_line("12 Turns System - Current Turn: " + str(current_turn), config.theme.info_color)
	add_line("")
	
	add_colored_line("Terminal Status:", config.theme.highlight_color)
	
	# Add storage system status
	if storage_system:
		var storage_status = storage_system.get_storage_status()
		add_colored_line("  Storage: Connected", config.theme.text_color)
		add_colored_line("  Local Drive: " + str(int(storage_status.local.used_gb)) + " GB / " + 
			str(int(storage_status.local.total_gb)) + " GB (" + 
			str(int(storage_status.local.percentage)) + "% used)", config.theme.text_color)
		
		add_colored_line("  Wishes Today: " + str(storage_status.wishes.today) + " / " + 
			str(100 - storage_status.wishes.today) + " remaining", config.theme.wish_color)
	else:
		add_colored_line("  Storage: Not Connected", config.theme.error_color)
	
	# Add akashic status
	if akashic_bridge:
		var status = akashic_bridge.get_status()
		add_colored_line("  Akashic Bridge: Connected", config.theme.text_color)
		add_colored_line("  Firewall Level: " + status.firewall_level, config.theme.text_color)
		add_colored_line("  Dimensional Gates: " + str(status.gates), config.theme.text_color)
	else:
		add_colored_line("  Akashic Bridge: Not Connected", config.theme.error_color)
	
	add_line("")
	add_colored_line("Type 'help' for available commands", config.theme.prompt_color)
	add_line("")
	add_prompt()

# Main terminal functions
func add_line(text):
	terminal_lines.append(text)
	
	# Limit buffer size
	while terminal_lines.size() > config.max_lines:
		terminal_lines.remove(0)
	
	# Auto-scroll if enabled
	if config.auto_scroll:
		scroll_to_bottom()

func add_colored_line(text, color):
	# In actual implementation, this would apply color to the text
	# For this script, we'll just add a tag
	add_line("<color:" + color.to_html() + ">" + text + "</color>")

func add_multiline_text(text):
	var lines = text.split("\n")
	for line in lines:
		add_line(line)

func add_ascii_header(header_name):
	if ascii_headers.has(header_name):
		for line in ascii_headers[header_name]:
			add_colored_line(line, config.theme.highlight_color)
		add_line("")

func add_prompt():
	add_line(config.prompt)

func process_command(command):
	# Skip empty commands
	if command.strip_edges() == "":
		add_prompt()
		return
	
	# Add command to history
	add_colored_line(config.prompt + command, config.theme.prompt_color)
	command_history.push_front(command)
	
	# Limit history size
	while command_history.size() > config.command_history_size:
		command_history.pop_back()
	
	# Reset history navigation
	command_history_index = -1
	
	# Track command execution
	executing_command = true
	command_start_time = OS.get_unix_time()
	current_command = command
	
	# Execute the command
	var result = execute_command(command)
	
	# Command is complete
	executing_command = false
	
	# Add result to terminal
	if typeof(result) == TYPE_STRING:
		add_multiline_text(result)
	elif typeof(result) == TYPE_ARRAY:
		for line in result:
			add_line(str(line))
	
	# Emit signal
	emit_signal("command_executed", command, result)
	
	# Add new prompt unless the command is a special one that handles its own prompt
	if not is_special_command_without_prompt(command):
		add_prompt()

func execute_command(command):
	# Parse command
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	var args = parts.slice(1, parts.size() - 1)
	
	# Handle built-in commands
	match cmd:
		"help":
			return show_help(args)
		"clear":
			clear_terminal()
			return ""
		"echo":
			return " ".join(args)
		"theme":
			return change_theme(args)
		"exit":
			return handle_exit()
		"wish":
			return process_wish(args)
		"storage":
			return storage_command(args)
		"ls":
			return file_list_command(args)
		"akashic":
			return akashic_command(args)
		"gate":
			return gate_command(args)
		"firewall":
			return firewall_command(args)
		"multi":
			return multi_window_command(args)
		"turn":
			return turn_command(args)
		"interface":
			return change_interface(args)
		"notepad3d":
			return notepad3d_command(args)
		"status":
			return show_status()
		"window":
			if config.multiple_interfaces:
				return switch_window(args)
			else:
				return "Multiple interfaces not enabled. Use 'multi on' to enable."
		_:
			return run_external_command(command)
	
	return "Command not recognized: " + cmd

func run_external_command(command):
	# Simulate running an external command
	
	# Check for bash commands
	if command.begins_with("bash ") or command.begins_with("sh ") or 
	   command.begins_with("./") or command.begins_with("/"):
		# Simulate bash execution
		add_colored_line("Executing external command: " + command, config.theme.dim_color)
		add_colored_line("Command output would appear here in actual implementation", config.theme.dim_color)
		return "External command completed"
	
	# Check for game commands
	if command == "start game" or command == "run game" or command == "game":
		return launch_game()
	
	# Check if it's a wish
	if command.length() > 10 and not command.begins_with("sudo") and command.find("/") < 0:
		add_colored_line("Interpreting as wish...", config.theme.wish_color)
		return process_wish([command])
	
	return "Unknown command: " + command

# Command implementations
func show_help(args = []):
	var help_text = []
	help_text.append("=== UNIFIED TERMINAL HELP ===")
	help_text.append("")
	
	# Filter help if args provided
	var filter = ""
	if args.size() > 0:
		filter = args[0].to_lower()
		help_text.append("Help topics matching '" + filter + "':")
	else:
		help_text.append("Available commands:")
	
	help_text.append("")
	
	# Basic commands
	if filter == "" or filter == "basic" or "basic".find(filter) >= 0:
		help_text.append("BASIC COMMANDS:")
		help_text.append("  help [topic]      - Show help for all or specific commands")
		help_text.append("  clear             - Clear the terminal screen")
		help_text.append("  echo [text]       - Output text to the terminal")
		help_text.append("  exit              - Exit current session or interface")
		help_text.append("  status            - Show system status")
		help_text.append("")
	
	# Theme commands
	if filter == "" or filter == "theme" or "theme".find(filter) >= 0:
		help_text.append("THEME COMMANDS:")
		help_text.append("  theme list        - List available themes")
		help_text.append("  theme set [name]  - Change terminal theme")
		help_text.append("  theme color [name] [hex] - Change specific color")
		help_text.append("")
	
	# Wish commands
	if filter == "" or filter == "wish" or "wish".find(filter) >= 0:
		help_text.append("WISH COMMANDS:")
		help_text.append("  wish [text]       - Create a new wish")
		help_text.append("  wish list         - List all active wishes")
		help_text.append("  wish status [id]  - Check status of a wish")
		help_text.append("  wish complete [id]- Mark a wish as complete")
		help_text.append("")
	
	# Storage commands
	if filter == "" or filter == "storage" or "storage".find(filter) >= 0:
		help_text.append("STORAGE COMMANDS:")
		help_text.append("  storage status    - Show storage status")
		help_text.append("  storage connect [service] - Connect to cloud storage")
		help_text.append("  storage list      - List files in storage")
		help_text.append("  storage sync      - Sync files between storages")
		help_text.append("")
	
	# Akashic commands
	if filter == "" or filter == "akashic" or "akashic".find(filter) >= 0:
		help_text.append("AKASHIC COMMANDS:")
		help_text.append("  akashic status    - Show Akashic bridge status")
		help_text.append("  akashic search [term] - Search Akashic records")
		help_text.append("  akashic store [word] [power] - Store a word in records")
		help_text.append("")
	
	# Gate commands
	if filter == "" or filter == "gate" or "gate".find(filter) >= 0:
		help_text.append("GATE COMMANDS:")
		help_text.append("  gate status       - Show dimensional gates status")
		help_text.append("  gate open [num]   - Open a dimensional gate")
		help_text.append("  gate close [num]  - Close a dimensional gate")
		help_text.append("")
	
	# Firewall commands
	if filter == "" or filter == "firewall" or "firewall".find(filter) >= 0:
		help_text.append("FIREWALL COMMANDS:")
		help_text.append("  firewall status   - Show firewall status")
		help_text.append("  firewall set [level] - Set firewall level")
		help_text.append("  firewall log      - Show firewall log")
		help_text.append("")
	
	# Multi-window commands
	if filter == "" or filter == "multi" or "multi".find(filter) >= 0:
		help_text.append("MULTI-WINDOW COMMANDS:")
		help_text.append("  multi on          - Enable multiple interfaces")
		help_text.append("  multi off         - Disable multiple interfaces")
		help_text.append("  window [num]      - Switch to window number")
		help_text.append("  window list       - List available windows")
		help_text.append("")
	
	# Turn commands
	if filter == "" or filter == "turn" or "turn".find(filter) >= 0:
		help_text.append("TURN COMMANDS:")
		help_text.append("  turn status       - Show current turn")
		help_text.append("  turn advance      - Advance to next turn")
		help_text.append("  turn set [num]    - Set current turn")
		help_text.append("")
	
	# Interface commands
	if filter == "" or filter == "interface" or "interface".find(filter) >= 0:
		help_text.append("INTERFACE COMMANDS:")
		help_text.append("  interface list    - List available interfaces")
		help_text.append("  interface [name]  - Switch to named interface")
		help_text.append("  notepad3d         - Launch Notepad 3D interface")
		help_text.append("")
	
	help_text.append("Type any other text to have it interpreted as a wish or command")
	
	return help_text

func clear_terminal():
	terminal_lines = []
	add_ascii_header("main")

func change_theme(args):
	if args.size() == 0:
		return "Usage: theme [list|set|color]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"list":
			return ["Available themes:", 
					"  default - Default dark theme",
					"  light - Light theme",
					"  cyberpunk - High contrast neon theme",
					"  matrix - Green on black theme"]
		"set":
			if args.size() < 2:
				return "Usage: theme set [theme_name]"
			
			var theme_name = args[1].to_lower()
			# In actual implementation, this would load the theme
			return "Theme changed to: " + theme_name
		"color":
			if args.size() < 3:
				return "Usage: theme color [color_name] [hex_color]"
			
			var color_name = args[1].to_lower()
			var hex_color = args[2]
			
			# In actual implementation, this would set the color
			return "Color '" + color_name + "' set to '" + hex_color + "'"
		_:
			return "Unknown theme subcommand: " + subcommand

func handle_exit():
	if config.multiple_interfaces and active_window_index > 0:
		var current_window = interface_windows[active_window_index]
		add_colored_line("Exiting " + current_window.title, config.theme.info_color)
		
		# Switch back to main window
		active_window_index = 0
		var main_window = interface_windows[active_window_index]
		add_colored_line("Switched to " + main_window.title, config.theme.info_color)
		return ""
	else:
		return "To exit the terminal completely, close the application window."

func process_wish(args):
	if args.size() == 0:
		return "Usage: wish [text] or wish [list|status|complete]"
	
	var subcommand = args[0].to_lower()
	
	if subcommand == "list":
		return list_wishes()
	elif subcommand == "status":
		if args.size() < 2:
			return "Usage: wish status [wish_id]"
		return wish_status(args[1])
	elif subcommand == "complete":
		if args.size() < 2:
			return "Usage: wish complete [wish_id]"
		return complete_wish_command(args[1])
	else:
		# Treat all arguments as wish text
		var wish_text = " ".join(args)
		return create_wish(wish_text)

func list_wishes():
	var result = ["=== ACTIVE WISHES ==="]
	
	if storage_system:
		var status = storage_system.get_storage_status()
		result.append("Today's wishes: " + str(status.wishes.today) + " / 100")
		result.append("Remaining wishes: " + str(status.wishes.remaining))
		result.append("")
		
		if storage_system.wish_system.active_wishes.size() == 0:
			result.append("No active wishes.")
		else:
			for wish in storage_system.wish_system.active_wishes:
				result.append("ID: " + wish.id)
				result.append("  Text: " + wish.text)
				result.append("  Status: " + wish.status)
				result.append("  Priority: " + wish.priority)
				result.append("  Created: " + wish.date)
				result.append("")
	else:
		result.append("Wish system not connected")
	
	return result

func wish_status(wish_id):
	if storage_system:
		# Find the wish
		for wish in storage_system.wish_system.active_wishes:
			if wish.id == wish_id:
				var result = ["=== WISH STATUS ==="]
				result.append("ID: " + wish.id)
				result.append("Text: " + wish.text)
				result.append("Status: " + wish.status)
				result.append("Priority: " + wish.priority)
				result.append("Created: " + wish.date)
				result.append("Timestamp: " + str(wish.timestamp))
				result.append("Token Cost: " + str(wish.token_cost))
				
				if wish.has("output"):
					result.append("\nOutput:")
					result.append(wish.output)
				
				return result
		
		return "Wish not found: " + wish_id
	else:
		return "Wish system not connected"

func complete_wish_command(wish_id):
	if storage_system:
		var result = storage_system.complete_wish(wish_id, "completed", "Completed via terminal command")
		
		if result:
			return "Wish completed: " + wish_id
		else:
			return "Failed to complete wish: " + wish_id
	else:
		return "Wish system not connected"

func create_wish(wish_text):
	if storage_system:
		var wish = storage_system.create_wish(wish_text)
		
		if wish:
			# Generate terminal output for the wish
			var output = storage_system.get_terminal_output_text(wish_text, 10)
			
			# Display output
			add_colored_line("=== PROCESSING WISH ===", config.theme.wish_color)
			for line in output:
				add_colored_line(line, config.theme.wish_color)
			
			generate_wish_response(wish)
			
			return ""
		else:
			return "Failed to create wish: Daily limit reached"
	else:
		return "Wish system not connected"

func generate_wish_response(wish):
	# Generate a response to the wish
	var response = []
	
	# Add header
	response.append("")
	response.append("=== WISH RESULT ===")
	
	# Generate response based on wish text
	var wish_text = wish.text.to_lower()
	
	if wish_text.find("notepad") >= 0 or wish_text.find("3d") >= 0:
		response.append("Launching Notepad 3D interface...")
		# In actual implementation, this would launch the interface
		response.append("Interface ready for dimensional text editing")
		response.append("Use 'notepad3d open' to start editing")
	
	elif wish_text.find("terminal") >= 0 or wish_text.find("interface") >= 0:
		if wish_text.find("multi") >= 0 or wish_text.find("3") >= 0:
			response.append("Enabling multi-terminal interface")
			response.append("Configured with 3 parallel terminals")
			config.multiple_interfaces = true
			create_interface_windows()
		else:
			response.append("Terminal interface activated")
			response.append("Command set expanded to full capabilities")
	
	elif wish_text.find("game") >= 0:
		response.append("Game engine initialized")
		response.append("Use 'start game' to launch game environment")
	
	elif wish_text.find("storage") >= 0 or wish_text.find("cloud") >= 0:
		response.append("Cloud storage integration activated")
		response.append("Connected local 2TB drive to system")
		response.append("iCloud (5GB) and Google Drive ready for connection")
		response.append("Use 'storage connect [service]' to establish connection")
	
	else:
		# Generic response
		response.append("Wish processed successfully")
		response.append("System has acknowledged your request")
		response.append("Command interfaces updated accordingly")
	
	# Add ID and status
	response.append("")
	response.append("Wish ID: " + wish.id)
	response.append("Status: pending → processing")
	response.append("")
	
	# Display response
	for line in response:
		add_colored_line(line, config.theme.info_color)
	
	# Schedule wish completion
	storage_system.complete_wish(wish.id, "completed", "Wish processed successfully")
	
	return response

func storage_command(args):
	if args.size() == 0:
		return "Usage: storage [status|connect|list|sync]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"status":
			return storage_status()
		"connect":
			if args.size() < 2:
				return "Usage: storage connect [icloud|google]"
			return connect_storage(args[1])
		"list":
			return list_storage_files(args.slice(1, args.size() - 1))
		"sync":
			return sync_storage()
		_:
			return "Unknown storage subcommand: " + subcommand

func storage_status():
	if storage_system:
		var status = storage_system.get_storage_status()
		var result = ["=== STORAGE STATUS ==="]
		
		# Add local storage
		result.append("LOCAL DRIVE:")
		result.append("  Connection: " + ("Active" if status.local.connected else "Inactive"))
		result.append("  Used: " + str(int(status.local.used_gb)) + " GB")
		result.append("  Total: " + str(int(status.local.total_gb)) + " GB")
		result.append("  Free: " + str(int(status.local.total_gb - status.local.used_gb)) + " GB")
		result.append("  Usage: " + str(int(status.local.percentage)) + "%")
		result.append("")
		
		# Add iCloud
		result.append("ICLOUD:")
		result.append("  Connection: " + ("Active" if status.icloud.connected else "Inactive"))
		if status.icloud.connected:
			result.append("  Type: " + status.icloud.type.capitalize() + " (" + 
				str(int(status.icloud.total_gb)) + " GB)")
			result.append("  Used: " + str(int(status.icloud.used_gb)) + " GB")
			result.append("  Free: " + str(int(status.icloud.total_gb - status.icloud.used_gb)) + " GB")
			result.append("  Usage: " + str(int(status.icloud.percentage)) + "%")
		result.append("")
		
		# Add Google Drive
		result.append("GOOGLE DRIVE:")
		result.append("  Connection: " + ("Active" if status.google.connected else "Inactive"))
		if status.google.connected:
			result.append("  Type: " + status.google.type.capitalize() + " (" + 
				str(int(status.google.total_gb)) + " GB)")
			result.append("  Used: " + str(int(status.google.used_gb)) + " GB")
			result.append("  Free: " + str(int(status.google.total_gb - status.google.used_gb)) + " GB")
			result.append("  Usage: " + str(int(status.google.percentage)) + "%")
		
		return result
	else:
		return "Storage system not connected"

func connect_storage(service):
	if storage_system:
		if service.to_lower() == "icloud" or service.to_lower() == "google":
			var result = storage_system.connect_cloud_storage(service.to_lower())
			
			if result:
				return "Connected to " + service + " storage successfully"
			else:
				return "Failed to connect to " + service + " storage"
		else:
			return "Unknown storage service: " + service
	else:
		return "Storage system not connected"

func list_storage_files(args):
	# In actual implementation, this would list files from the storage
	var path = args.size() > 0 ? args[0] : ""
	var result = ["=== FILES ==="]
	
	# Simulate listing files
	if path == "" or path == "/":
		result.append("  12_turns_system/")
		result.append("  Desktop/")
		result.append("  Documents/")
		result.append("  Downloads/")
		result.append("  CLAUDE.md")
	elif path == "12_turns_system":
		result.append("  akashic_database.js")
		result.append("  akashic_database_connector.gd")
		result.append("  claude_akashic_bridge.gd")
		result.append("  claude_terminal_interface.sh")
		result.append("  storage_integration_system.gd")
		result.append("  unified_terminal_interface.gd")
	else:
		result.append("No files found at path: " + path)
	
	return result

func sync_storage():
	# In actual implementation, this would sync files between storages
	return ["Starting storage synchronization...",
			"Comparing file lists...",
			"Transferring files...",
			"Synchronization complete"]

func file_list_command(args):
	var path = args.size() > 0 ? args[0] : "."
	return list_storage_files([path])

func akashic_command(args):
	if args.size() == 0:
		return "Usage: akashic [status|search|store]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"status":
			return akashic_status()
		"search":
			if args.size() < 2:
				return "Usage: akashic search [term]"
			return akashic_search(args[1])
		"store":
			if args.size() < 2:
				return "Usage: akashic store [word] [power]"
			
			var word = args[1]
			var power = args.size() > 2 ? int(args[2]) : 50
			
			return akashic_store(word, power)
		_:
			return "Unknown akashic subcommand: " + subcommand

func akashic_status():
	if akashic_bridge:
		var status = akashic_bridge.get_status()
		var result = ["=== AKASHIC BRIDGE STATUS ==="]
		
		result.append("Akashic Connected: " + str(status.akashic_connected))
		result.append("Claude Connected: " + str(status.claude_connected))
		result.append("Firewall Status: " + (str(status.firewall_active) + " (Level: " + status.firewall_level + ")"))
		result.append("Dimension Access Level: " + str(status.dimension_access))
		
		result.append("\nDimensional Gates:")
		for gate in status.gates:
			result.append("  " + gate + ": " + ("OPEN" if status.gates[gate] else "CLOSED"))
		
		result.append("\nSystem Metrics:")
		result.append("  Error Count: " + str(status.errors))
		result.append("  Recovery Points: " + str(status.recovery_points))
		
		return result
	else:
		return "Akashic Bridge not connected"

func akashic_search(term):
	if akashic_bridge:
		# In actual implementation, this would search the Akashic Records
		var result = ["=== AKASHIC SEARCH RESULTS ===", 
				"Search term: " + term, ""]
		
		# Simulate search results
		if term.to_lower() == "consciousness" or term.to_lower() == "mind":
			result.append("FOUND: consciousness")
			result.append("  Power: 65")
			result.append("  Dimension: 3")
			result.append("  Category: metaphysical")
			result.append("  Origin: claude_bridge_demo")
			result.append("")
		elif term.to_lower() == "creation" or term.to_lower() == "manifestation":
			result.append("FOUND: creation")
			result.append("  Power: 85")
			result.append("  Dimension: 5")
			result.append("  Category: divine")
			result.append("")
		else:
			result.append("No direct matches found.")
			result.append("Similar terms: reality, consciousness, creation")
		
		return result
	else:
		return "Akashic Bridge not connected"

func akashic_store(word, power):
	if akashic_bridge:
		var result = akashic_bridge.store_word(word, power, {
			"origin": "terminal_interface",
			"dimension": current_turn,
			"timestamp": OS.get_unix_time()
		})
		
		if result:
			return "Word '" + word + "' stored in Akashic Records with power " + str(power)
		else:
			return "Failed to store word in Akashic Records"
	else:
		return "Akashic Bridge not connected"

func gate_command(args):
	if args.size() == 0:
		return "Usage: gate [status|open|close]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"status":
			return gate_status()
		"open":
			if args.size() < 2:
				return "Usage: gate open [0|1|2]"
			return open_gate(args[1])
		"close":
			if args.size() < 2:
				return "Usage: gate close [0|1|2]"
			return close_gate(args[1])
		_:
			return "Unknown gate subcommand: " + subcommand

func gate_status():
	if akashic_bridge:
		var status = akashic_bridge.get_status()
		var result = ["=== DIMENSIONAL GATES STATUS ==="]
		
		result.append("Current Dimension: " + str(status.dimension_access))
		result.append("")
		
		# Display gate information with descriptions
		result.append("GATE 0 (Physical Reality): " + ("OPEN" if status.gates.gate_0 else "CLOSED"))
		result.append("  Controls access to physical file system")
		result.append("")
		
		result.append("GATE 1 (Immediate Experience): " + ("OPEN" if status.gates.gate_1 else "CLOSED"))
		result.append("  Controls access to active session data")
		result.append("")
		
		result.append("GATE 2 (Transcendent State): " + ("OPEN" if status.gates.gate_2 else "CLOSED"))
		result.append("  Controls access to higher dimensions")
		result.append("  Requires divine firewall level for stable connection")
		
		return result
	else:
		return "Akashic Bridge not connected"

func open_gate(gate_num):
	if akashic_bridge:
		var gate_name = "gate_" + gate_num
		var result = akashic_bridge.open_gate(gate_name)
		
		if result:
			if gate_num == "2":
				add_colored_line("⚠️ WARNING: Opening Gate 2 (Transcendent State)", config.theme.error_color)
				add_colored_line("Dimensional stability may be affected", config.theme.error_color)
			
			return "Gate " + gate_num + " opened successfully"
		else:
			if gate_num == "2":
				return "Failed to open Gate 2. Requires divine firewall level."
			else:
				return "Failed to open gate " + gate_num
	else:
		return "Akashic Bridge not connected"

func close_gate(gate_num):
	if akashic_bridge:
		var gate_name = "gate_" + gate_num
		var result = akashic_bridge.close_gate(gate_name)
		
		if result:
			return "Gate " + gate_num + " closed successfully"
		else:
			return "Failed to close gate " + gate_num
	else:
		return "Akashic Bridge not connected"

func firewall_command(args):
	if args.size() == 0:
		return "Usage: firewall [status|set|log]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"status":
			return firewall_status()
		"set":
			if args.size() < 2:
				return "Usage: firewall set [standard|enhanced|divine]"
			return set_firewall(args[1])
		"log":
			return firewall_log()
		_:
			return "Unknown firewall subcommand: " + subcommand

func firewall_status():
	if akashic_bridge:
		var status = akashic_bridge.get_status()
		var result = ["=== FIREWALL STATUS ==="]
		
		result.append("Status: " + ("ACTIVE" if status.firewall_active else "INACTIVE"))
		result.append("Current Level: " + status.firewall_level.to_upper())
		
		# Add level descriptions
		result.append("")
		result.append("FIREWALL LEVELS:")
		result.append("  STANDARD - Basic protection, limited dimensional access")
		result.append("  ENHANCED - Improved protection, moderate dimensional access")
		result.append("  DIVINE - Maximum protection, full dimensional access")
		
		result.append("")
		result.append("Error Count: " + str(status.errors))
		result.append("Recovery Points: " + str(status.recovery_points))
		
		return result
	else:
		return "Akashic Bridge not connected"

func set_firewall(level):
	if akashic_bridge:
		level = level.to_lower()
		
		if level != "standard" and level != "enhanced" and level != "divine":
			return "Invalid firewall level. Must be standard, enhanced, or divine."
		
		var settings = {}
		
		# Adjust settings based on level
		if level == "divine":
			settings = {
				"dimension_access": min(current_turn + 2, 12),
				"gates": {"gate_0": true, "gate_1": true, "gate_2": true}
			}
		elif level == "enhanced":
			settings = {
				"dimension_access": min(current_turn, 7),
				"gates": {"gate_0": true, "gate_1": true, "gate_2": false}
			}
		else: # standard
			settings = {
				"dimension_access": min(current_turn, 3),
				"gates": {"gate_0": true, "gate_1": false, "gate_2": false}
			}
		
		var result = akashic_bridge.update_firewall(level, settings)
		
		if result:
			return "Firewall level set to " + level.to_upper()
		else:
			return "Failed to set firewall level"
	else:
		return "Akashic Bridge not connected"

func firewall_log():
	# In actual implementation, this would show the firewall log
	var result = ["=== FIREWALL LOG ==="]
	
	# Simulate log entries
	result.append("2025-05-13 14:32:21 - VALIDATION_ERROR - Invalid word: Empty or wrong type")
	result.append("2025-05-13 14:30:15 - ACCESS_DENIED - Word rejected by firewall: exec rm -rf")
	result.append("2025-05-13 14:28:07 - CLAUDE_ERROR - Token limit exceeded")
	result.append("2025-05-13 14:25:59 - ACCESS_DENIED - Query rejected by firewall: sudo /*")
	
	return result

func multi_window_command(args):
	if args.size() == 0:
		return "Usage: multi [on|off|status]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"on":
			config.multiple_interfaces = true
			create_interface_windows()
			return "Multiple interfaces enabled"
		"off":
			config.multiple_interfaces = false
			return "Multiple interfaces disabled"
		"status":
			var result = ["Multiple interfaces: " + ("ENABLED" if config.multiple_interfaces else "DISABLED")]
			
			if config.multiple_interfaces:
				result.append("\nAvailable windows:")
				for i in range(interface_windows.size()):
					result.append("  " + str(i) + ": " + interface_windows[i].title + 
						(" (ACTIVE)" if i == active_window_index else ""))
			
			return result
		_:
			return "Unknown multi subcommand: " + subcommand

func switch_window(args):
	if not config.multiple_interfaces:
		return "Multiple interfaces not enabled. Use 'multi on' to enable."
	
	if args.size() == 0:
		return "Usage: window [number] or window list"
	
	if args[0].to_lower() == "list":
		var result = ["=== TERMINAL WINDOWS ==="]
		
		for i in range(interface_windows.size()):
			result.append("  " + str(i) + ": " + interface_windows[i].title + 
				(" (ACTIVE)" if i == active_window_index else ""))
		
		return result
	
	# Try to parse window number
	var window_num = int(args[0])
	
	if window_num >= 0 and window_num < interface_windows.size():
		active_window_index = window_num
		var window = interface_windows[active_window_index]
		
		add_colored_line("Switched to " + window.title, config.theme.info_color)
		return ""
	else:
		return "Invalid window number. Use 'window list' to see available windows."

func turn_command(args):
	if args.size() == 0:
		return "Usage: turn [status|advance|set]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"status":
			return turn_status()
		"advance":
			return advance_turn()
		"set":
			if args.size() < 2:
				return "Usage: turn set [number]"
			return set_turn(int(args[1]))
		_:
			return "Unknown turn subcommand: " + subcommand

func turn_status():
	var result = ["=== TURN STATUS ==="]
	
	result.append("Current Turn: " + str(current_turn))
	
	# Get dimension name
	var dimension_name = get_dimension_name(current_turn)
	result.append("Dimension: " + dimension_name)
	
	# Create turn progression visualization
	result.append("")
	result.append("Turn Progression:")
	
	var progress = ""
	for i in range(1, 13):
		if i < current_turn:
			progress += "■ "
		elif i == current_turn:
			progress += "□ "
		else:
			progress += "· "
	
	result.append(progress)
	result.append("1 2 3 4 5 6 7 8 9101112")
	
	return result

func advance_turn():
	# Advance to next turn
	current_turn = (current_turn % 12) + 1
	
	# Save turn
	save_current_turn()
	
	var dimension_name = get_dimension_name(current_turn)
	
	return ["Advanced to Turn " + str(current_turn),
			"Dimension: " + dimension_name,
			"",
			"All systems recalibrated for new dimensional state."]

func set_turn(turn_num):
	if turn_num < 1 or turn_num > 12:
		return "Invalid turn number. Must be between 1 and 12."
	
	current_turn = turn_num
	save_current_turn()
	
	var dimension_name = get_dimension_name(current_turn)
	
	return ["Turn set to " + str(current_turn),
			"Dimension: " + dimension_name]

func save_current_turn():
	# In actual implementation, this would save the current turn
	var file = File.new()
	var turn_file = "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt"
	
	if file.open(turn_file, File.WRITE) == OK:
		file.store_string(str(current_turn))
		file.close()
	else:
		push_error("Failed to save current turn")

func load_current_turn():
	var file = File.new()
	var turn_file = "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt"
	
	if file.file_exists(turn_file) and file.open(turn_file, File.READ) == OK:
		var content = file.get_as_text()
		file.close()
		
		var turn = int(content)
		if turn >= 1 and turn <= 12:
			current_turn = turn
	else:
		current_turn = 1

func get_dimension_name(turn):
	var dimensions = [
		"1D-Point", "2D-Line", "3D-Space", "4D-Time", "5D-Consciousness", 
		"6D-Connection", "7D-Creation", "8D-Network", "9D-Harmony", 
		"10D-Unity", "11D-Transcendence", "12D-Beyond"
	]
	
	return dimensions[turn - 1]

func change_interface(args):
	if args.size() == 0:
		return "Usage: interface [list|name]"
	
	if args[0].to_lower() == "list":
		return ["Available interfaces:",
				"  main - Main terminal interface",
				"  wishes - Wish management system",
				"  akashic - Akashic Records interface",
				"  notepad3d - 3D Notepad visualization system",
				"  storage - Storage management interface"]
	
	var interface_name = args[0].to_lower()
	
	match interface_name:
		"main":
			add_ascii_header("main")
			emit_signal("interface_changed", "main")
			return "Switched to main interface"
		"wishes":
			add_ascii_header("wishes")
			emit_signal("interface_changed", "wishes")
			return "Switched to wishes interface"
		"akashic":
			add_ascii_header("akashic")
			emit_signal("interface_changed", "akashic")
			return "Switched to Akashic Records interface"
		"notepad3d":
			return notepad3d_command(["launch"])
		"storage":
			add_ascii_header("storage")
			emit_signal("interface_changed", "storage")
			return "Switched to storage interface"
		_:
			return "Unknown interface: " + interface_name

func notepad3d_command(args):
	if args.size() == 0:
		return "Usage: notepad3d [launch|open|save|close]"
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"launch":
			add_ascii_header("notepad3d")
			emit_signal("interface_changed", "notepad3d")
			return "Notepad 3D initialized"
		"open":
			if args.size() > 1:
				return "Opening file in Notepad 3D: " + args[1]
			else:
				return "New file created in Notepad 3D"
		"save":
			return "File saved in Notepad 3D"
		"close":
			add_ascii_header("main")
			emit_signal("interface_changed", "main")
			return "Notepad 3D closed"
		_:
			return "Unknown notepad3d subcommand: " + subcommand

func show_status():
	var result = ["=== SYSTEM STATUS ==="]
	
	# Add turn information
	result.append("TURN SYSTEM:")
	result.append("  Current Turn: " + str(current_turn))
	result.append("  Dimension: " + get_dimension_name(current_turn))
	result.append("")
	
	# Add connection status
	result.append("CONNECTIONS:")
	result.append("  Storage System: " + str(storage_system != null))
	result.append("  Akashic Bridge: " + str(akashic_bridge != null))
	result.append("")
	
	# Add multi-window status
	result.append("INTERFACES:")
	result.append("  Multiple Interfaces: " + str(config.multiple_interfaces))
	
	if config.multiple_interfaces:
		result.append("  Active Interface: " + interface_windows[active_window_index].title)
	
	result.append("")
	
	# Add wish status
	if storage_system:
		var status = storage_system.get_storage_status()
		result.append("WISHES:")
		result.append("  Today's Wishes: " + str(status.wishes.today) + " / 100")
		result.append("  Remaining: " + str(status.wishes.remaining))
		result.append("  Active Wishes: " + str(status.wishes.active))
	
	return result

func launch_game():
	add_colored_line("=== LAUNCHING GAME ENVIRONMENT ===", config.theme.highlight_color)
	add_colored_line("Initializing game engine...", config.theme.text_color)
	add_colored_line("Loading resources...", config.theme.text_color)
	add_colored_line("Connecting to turn system...", config.theme.text_color)
	add_colored_line("", config.theme.text_color)
	add_colored_line("Game environment ready!", config.theme.highlight_color)
	add_colored_line("Use 'notepad3d' for 3D visualization interface", config.theme.text_color)
	
	# Create wish for game
	if storage_system:
		storage_system.create_wish("Create game environment with interactive elements for Turn " + str(current_turn))
	
	return ""

# Utility functions
func scroll_to_bottom():
	scroll_position = max(0, terminal_lines.size() - config.visible_lines)

func is_special_command_without_prompt(command):
	# Some commands handle their own prompt
	return false

# Terminal navigation functions
func history_up():
	if command_history.size() == 0:
		return
	
	command_history_index += 1
	command_history_index = min(command_history_index, command_history.size() - 1)
	
	current_input = command_history[command_history_index]

func history_down():
	if command_history.size() == 0:
		return
	
	command_history_index -= 1
	
	if command_history_index < 0:
		command_history_index = -1
		current_input = ""
	else:
		current_input = command_history[command_history_index]

func get_terminal_lines():
	return terminal_lines

func get_current_input():
	return current_input
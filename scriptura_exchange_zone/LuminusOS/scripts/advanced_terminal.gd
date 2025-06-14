extends Node

class_name AdvancedTerminal

# Advanced terminal with multi-core support, word magic and game creation

signal command_executed(command, result)
signal game_created(game_name)
signal ascii_art_displayed(art_name)

@onready var multi_core_system = null
@onready var magic_system = null
@onready var magic_commands = null
@onready var word_story_system = null
@onready var automation_system = null

var command_history = []
var history_position = -1
var self_check_enabled = false
var last_command_time = 0
var reading_speed = 300 # words per minute
var device_capabilities = {
	"cores": 16,
	"memory": "16GB",
	"storage": "1TB SSD",
	"display": "1920x1080",
	"api_access": true
}

# ASCII art collection
var ascii_art = {
	"logo": """
██╗░░░░░██╗░░░██╗███╗░░░███╗██╗███╗░░██╗██╗░░░██╗░██████╗░█████╗░░██████╗
██║░░░░░██║░░░██║████╗░████║██║████╗░██║██║░░░██║██╔════╝██╔══██╗██╔════╝
██║░░░░░██║░░░██║██╔████╔██║██║██╔██╗██║██║░░░██║╚█████╗░██║░░██║╚█████╗░
██║░░░░░██║░░░██║██║╚██╔╝██║██║██║╚████║██║░░░██║░╚═══██╗██║░░██║░╚═══██╗
███████╗╚██████╔╝██║░╚═╝░██║██║██║░╚███║╚██████╔╝██████╔╝╚█████╔╝██████╔╝
╚══════╝░╚═════╝░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░░╚════╝░╚═════╝░
	""",
	"game": """
  ▄████  ▄▄▄       ███▄ ▄███▓▓█████ 
 ██▒ ▀█▒▒████▄    ▓██▒▀█▀ ██▒▓█   ▀ 
▒██░▄▄▄░▒██  ▀█▄  ▓██    ▓██░▒███   
░▓█  ██▓░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄ 
░▒▓███▀▒ ▓█   ▓██▒▒██▒   ░██▒░▒████▒
 ░▒   ▒  ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░
  ░   ░   ▒   ▒▒ ░░  ░      ░ ░ ░  ░
░ ░   ░   ░   ▒   ░      ░      ░   
      ░       ░  ░       ░      ░  ░
	""",
	"terminal": """
╔════════════════════════════════════╗
║  _____                   _         ║
║ |_   _|__ _ __ _ __ ___ (_)_ __    ║
║   | |/ _ \\ '__| '_ ` _ \\| | '_ \\   ║
║   | |  __/ |  | | | | | | | | | |  ║
║   |_|\\___|_|  |_| |_| |_|_|_| |_|  ║
║                                    ║
╚════════════════════════════════════╝
	""",
	"magic": """
  /\\\\\\      
 /  \\\\\\     
/    \\\\\\    
▒▒▒▒▒▒▒▒    
\    ///    
 \  ///     
  \\///      
	"""
}

# API limitations and documentation
var api_info = {
	"claude": {
		"limits": ["200K token context window", "Rate limits based on tier", "Some file type restrictions"],
		"strengths": ["Strong reasoning", "Follows instructions well", "Creative output", "Code generation"]
	},
	"openai": {
		"limits": ["128K token context window", "Rate limits based on tier", "API key required"],
		"strengths": ["Fast processing", "High accuracy", "Multiple model options", "Function calling"]
	},
	"anthropic": {
		"limits": ["Rate limiting on API calls", "Usage quotas based on plan", "Message history persistence limitations"],
		"strengths": ["Claude models access", "Constitutional AI approach", "Safety and alignment focus"]
	}
}

# Game templates
var game_templates = {
	"platformer": {
		"scene": "res://templates/platformer.tscn",
		"scripts": ["player.gd", "enemy.gd", "level.gd"],
		"description": "A 2D platformer game with jumping mechanics"
	},
	"puzzle": {
		"scene": "res://templates/puzzle.tscn",
		"scripts": ["puzzle_piece.gd", "board.gd", "level_manager.gd"],
		"description": "A puzzle game with draggable elements"
	},
	"rpg": {
		"scene": "res://templates/rpg.tscn",
		"scripts": ["character.gd", "inventory.gd", "quest_system.gd"],
		"description": "An RPG game with character stats and quests"
	},
	"word_game": {
		"scene": "res://templates/word_game.tscn",
		"scripts": ["word_manager.gd", "dictionary.gd", "score_system.gd"],
		"description": "A word-based game with dictionary lookup"
	}
}

func _ready():
	initialize_systems()
	print("Advanced Terminal initialized!")

func initialize_systems():
	# Initialize systems
	multi_core_system = MultiCoreSystem.new()
	magic_system = MagicSystem.new()
	magic_commands = MagicCommands.new()
	word_story_system = WordStorySystem.new()
	automation_system = AutomationSystem.new()
	
	# Add them to the scene
	add_child(multi_core_system)
	add_child(magic_system)
	add_child(magic_commands)
	add_child(word_story_system)
	add_child(automation_system)
	
	# Initialize cores
	multi_core_system.initialize_cores(device_capabilities.cores)
	multi_core_system.auto_tick_enabled = true
	
	# Connect automation system
	automation_system.initialize(multi_core_system, word_story_system, magic_system)

# Process a command
func process_command(command_text):
	# Add to history
	command_history.append(command_text)
	history_position = command_history.size()
	
	# Track command time
	last_command_time = Time.get_ticks_msec()
	
	# Parse command
	var parts = command_text.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	var result = ""
	
	# Process command
	match cmd:
		"help":
			result = show_help()
		"clear":
			result = "Screen cleared"
		"ascii":
			if args.size() > 0 and ascii_art.has(args[0]):
				result = ascii_art[args[0]]
				emit_signal("ascii_art_displayed", args[0])
			else:
				result = "Available ASCII art: " + ", ".join(ascii_art.keys())
		"cores":
			result = multi_core_system.cmd_cores(args)
		"task":
			result = multi_core_system.cmd_task(args)
		"memory":
			result = multi_core_system.cmd_memory(args)
		"magic":
			result = magic_commands.cmd_magic(args)
		"word":
			result = word_story_system.cmd_word(args)
		"story":
			result = word_story_system.cmd_story(args)
		"sudo":
			result = magic_commands.cmd_sudo(args)
		"self_check":
			result = toggle_self_check(args)
		"create_game":
			result = create_game(args)
		"api":
			result = show_api_info(args)
		"reading_speed":
			result = set_reading_speed(args)
		"device":
			result = show_device_capabilities()
		"spell":
			if args.size() > 0:
				result = magic_commands.process_spell(args[0])
			else:
				result = "Usage: spell <spell_name>"
		"exti", "vaeli", "lemi", "pelo", "zenime", "perfefic", "shune", "cade":
			result = magic_commands.process_spell(cmd)
		"godot":
			result = run_godot_command(args)
		"game":
			result = show_game_templates()
		"sh":
			result = create_shell_script(args)
		_:
			result = "Unknown command: " + cmd
	
	emit_signal("command_executed", command_text, result)
	return result

func show_help():
	var help_text = "LuminusOS Advanced Terminal Commands:\n\n"
	
	help_text += "System Commands:\n"
	help_text += "  help          - Show this help\n"
	help_text += "  clear         - Clear the screen\n"
	help_text += "  sudo          - Execute commands with elevated privileges\n"
	help_text += "  self_check    - Toggle self-checking system\n"
	help_text += "  device        - Show device capabilities\n"
	
	help_text += "\nMulti-Core System:\n"
	help_text += "  cores         - Manage cores\n"
	help_text += "  task          - Task scheduling and management\n"
	help_text += "  memory        - Shared memory operations\n"
	
	help_text += "\nWord and Story System:\n"
	help_text += "  word          - Word database operations\n"
	help_text += "  story         - Story generation and retrieval\n"
	
	help_text += "\nMagic System:\n"
	help_text += "  magic         - Magic system commands\n"
	help_text += "  spell         - Cast a specific spell\n"
	help_text += "  exti/vaeli/lemi/pelo - Direct spell casting\n"
	
	help_text += "\nGame Development:\n"
	help_text += "  create_game   - Create a new game\n"
	help_text += "  game          - Show game templates\n"
	help_text += "  godot         - Execute Godot engine commands\n"
	
	help_text += "\nVisual Elements:\n"
	help_text += "  ascii         - Display ASCII art\n"
	
	help_text += "\nAPI and Tools:\n"
	help_text += "  api           - Show API information\n"
	help_text += "  reading_speed - Set or show reading speed\n"
	help_text += "  sh            - Create a shell script\n"
	
	return help_text

func toggle_self_check(args):
	if args.size() > 0 and (args[0] == "on" or args[0] == "true"):
		self_check_enabled = true
		return "Self-check system enabled"
	elif args.size() > 0 and (args[0] == "off" or args[0] == "false"):
		self_check_enabled = false
		return "Self-check system disabled"
	else:
		self_check_enabled = !self_check_enabled
		return "Self-check system " + ("enabled" if self_check_enabled else "disabled")

func create_game(args):
	if args.size() < 1:
		return "Usage: create_game <game_name> [template_type]"
		
	var game_name = args[0]
	var template_type = "platformer"  # default
	
	if args.size() >= 2:
		template_type = args[1]
		
	if not game_templates.has(template_type):
		return "Unknown template type. Available templates: " + ", ".join(game_templates.keys())
		
	var template = game_templates[template_type]
	
	var result = "Creating new game: " + game_name + "\n"
	result += "Using template: " + template_type + " (" + template.description + ")\n"
	result += "Creating scene from " + template.scene + "\n"
	result += "Adding scripts: " + ", ".join(template.scripts) + "\n"
	result += "Game created successfully!"
	
	emit_signal("game_created", game_name)
	
	return result

func show_api_info(args):
	if args.size() < 1:
		var info = "API Information:\n\n"
		
		info += "Available APIs:\n"
		info += "- claude: Claude AI models by Anthropic\n"
		info += "- openai: GPT models by OpenAI\n"
		info += "- anthropic: Anthropic API services\n"
		
		info += "\nFor details, use: api <name>\n"
		return info
		
	var api_name = args[0].to_lower()
	
	if not api_info.has(api_name):
		return "Unknown API: " + api_name
		
	var api = api_info[api_name]
	var info = api_name.capitalize() + " API Information:\n\n"
	
	info += "Limitations:\n"
	for limit in api.limits:
		info += "- " + limit + "\n"
		
	info += "\nStrengths:\n"
	for strength in api.strengths:
		info += "- " + strength + "\n"
		
	return info

func set_reading_speed(args):
	if args.size() < 1:
		return "Current reading speed: " + str(reading_speed) + " words per minute"
		
	if args[0].is_valid_int():
		reading_speed = int(args[0])
		return "Reading speed set to " + str(reading_speed) + " words per minute"
	else:
		return "Invalid reading speed. Please provide a number."

func show_device_capabilities():
	var info = "Device Capabilities:\n\n"
	
	info += "CPU Cores: " + str(device_capabilities.cores) + "\n"
	info += "Memory: " + device_capabilities.memory + "\n"
	info += "Storage: " + device_capabilities.storage + "\n"
	info += "Display: " + device_capabilities.display + "\n"
	info += "API Access: " + ("Yes" if device_capabilities.api_access else "No") + "\n"
	
	return info

func run_godot_command(args):
	if args.size() < 1:
		return "Usage: godot <command>"
		
	var command = args[0]
	
	match command:
		"run":
			return "Running Godot project..."
		"build":
			return "Building Godot project..."
		"export":
			return "Exporting Godot project..."
		"version":
			return "Godot 4.4"
		_:
			return "Unknown Godot command: " + command

func show_game_templates():
	var info = "Available Game Templates:\n\n"
	
	for template_name in game_templates:
		var template = game_templates[template_name]
		info += "- " + template_name + ": " + template.description + "\n"
		
	info += "\nUse 'create_game <name> <template>' to create a new game"
	
	return info

func create_shell_script(args):
	if args.size() < 1:
		return "Usage: sh <script_name> [commands...]"
		
	var script_name = args[0]
	
	if args.size() < 2:
		return "Please provide commands for the script"
		
	var script_content = "#!/bin/bash\n\n"
	script_content += "# " + script_name + "\n"
	script_content += "# Generated by LuminusOS\n\n"
	
	for i in range(1, args.size()):
		script_content += args[i] + "\n"
		
	return "Shell script created: " + script_name + "\n" + "Content:\n" + script_content
extends Node

class_name GameCreator

# Game creation system for LuminusOS
# Allows creating simple games through the terminal

signal game_created(game_name, template)
signal game_exported(game_name, platform)
signal script_added(game_name, script_name)

# Template definitions
var templates = {
	"platformer": {
		"description": "A 2D platformer game with player character, platforms, and enemies",
		"scenes": ["main", "level1", "level2", "game_over"],
		"scripts": ["player", "enemy", "platform", "coin", "game_manager"],
		"resources": ["tileset", "player_sprite", "enemy_sprite", "coin_sprite"]
	},
	"puzzle": {
		"description": "A puzzle game with draggable pieces and grid-based mechanics",
		"scenes": ["main", "puzzle1", "puzzle2", "win_screen"],
		"scripts": ["puzzle_piece", "board", "level_manager", "score"],
		"resources": ["piece_sprites", "background", "victory_jingle", "click_sound"]
	},
	"rpg": {
		"description": "An RPG with character stats, dialogue, and quests",
		"scenes": ["main", "town", "dungeon", "battle"],
		"scripts": ["player", "npc", "enemy", "inventory", "quest", "dialogue", "battle_system"],
		"resources": ["character_sprites", "tileset", "items", "dialogue_database"]
	},
	"word_game": {
		"description": "A word-based game with dictionary lookup and scoring",
		"scenes": ["main", "game", "high_scores"],
		"scripts": ["word_manager", "letter_tile", "score_system", "dictionary", "timer"],
		"resources": ["letter_tiles", "background", "dictionary_data", "fonts"]
	},
	"terminal": {
		"description": "A terminal-based game with text commands and ASCII graphics",
		"scenes": ["main", "terminal"],
		"scripts": ["command_parser", "game_state", "ascii_renderer", "player"],
		"resources": ["ascii_art", "commands_database", "terminal_font"]
	}
}

# Base scripts for various game elements
var script_templates = {
	"player": """extends CharacterBody2D

# Player character controller

@export var speed = 300.0
@export var jump_strength = 600.0
@export var gravity = 980.0

var is_jumping = false

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_strength
		is_jumping = true
	
	# Get movement direction
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	
	move_and_slide()
""",
	
	"game_manager": """extends Node

# Main game manager script

signal game_over
signal level_complete
signal score_changed(new_score)

var current_level = 1
var score = 0
var lives = 3
var max_levels = 3
var game_running = false

func _ready():
	start_game()

func start_game():
	current_level = 1
	score = 0
	lives = 3
	game_running = true
	load_level(current_level)

func load_level(level_num):
	# Implementation will depend on your game structure
	print("Loading level " + str(level_num))
	
func add_score(points):
	score += points
	emit_signal("score_changed", score)

func lose_life():
	lives -= 1
	if lives <= 0:
		end_game()
	
func complete_level():
	current_level += 1
	if current_level > max_levels:
		win_game()
	else:
		emit_signal("level_complete")
		load_level(current_level)

func end_game():
	game_running = false
	emit_signal("game_over")
	
func win_game():
	game_running = false
	print("Game completed! Final score: " + str(score))
""",

	"word_manager": """extends Node

# Word management system

signal word_found(word, score)
signal invalid_word(word)

var dictionary = {}
var current_letters = []
var min_word_length = 3

func _ready():
	load_dictionary()

func load_dictionary():
	# In a real game, you'd load from a file
	dictionary = {
		"cat": true,
		"dog": true,
		"bird": true,
		"fish": true,
		"lion": true,
		"tiger": true,
		"bear": true,
		"wolf": true,
		"fox": true,
		"owl": true
	}
	
func set_available_letters(letters):
	current_letters = letters
	
func submit_word(word):
	word = word.to_lower()
	
	# Check if it's a valid word
	if word.length() < min_word_length:
		emit_signal("invalid_word", word)
		return false
		
	# Check if it's in the dictionary
	if not dictionary.has(word):
		emit_signal("invalid_word", word)
		return false
		
	# Check if it can be formed from available letters
	if not can_form_word(word):
		emit_signal("invalid_word", word)
		return false
		
	# Valid word!
	var score = calculate_score(word)
	emit_signal("word_found", word, score)
	return true
	
func can_form_word(word):
	# Implementation to check if word can be formed
	# from current_letters
	return true
	
func calculate_score(word):
	return word.length() * 10
"""
}

var created_games = {}
var current_game = ""

func _ready():
	print("Game Creator initialized")

# Create a new game using a template
func create_game(game_name, template_name="platformer"):
	if created_games.has(game_name):
		return "Game already exists: " + game_name
		
	if not templates.has(template_name):
		return "Unknown template: " + template_name
		
	var template = templates[template_name]
	
	# Create game structure
	created_games[game_name] = {
		"template": template_name,
		"description": template.description,
		"scenes": {},
		"scripts": {},
		"resources": {},
		"creation_time": Time.get_datetime_dict_from_system(),
		"status": "setup"
	}
	
	# Create initial scenes
	for scene in template.scenes:
		created_games[game_name].scenes[scene] = {
			"created": true,
			"nodes": []
		}
	
	# Create initial scripts
	for script in template.scripts:
		# Use template if available, otherwise empty
		var content = ""
		if script_templates.has(script):
			content = script_templates[script]
			
		created_games[game_name].scripts[script] = {
			"created": true,
			"content": content
		}
	
	# Add resources
	for resource in template.resources:
		created_games[game_name].resources[resource] = {
			"created": true,
		}
	
	current_game = game_name
	
	# Emit signal
	emit_signal("game_created", game_name, template_name)
	
	return "Game created: " + game_name + " (Template: " + template_name + ")"

# Add a script to an existing game
func add_script(game_name, script_name, content=""):
	if not created_games.has(game_name):
		return "Game not found: " + game_name
		
	if created_games[game_name].scripts.has(script_name):
		return "Script already exists: " + script_name
		
	# Create script
	created_games[game_name].scripts[script_name] = {
		"created": true,
		"content": content
	}
	
	emit_signal("script_added", game_name, script_name)
	
	return "Script added: " + script_name + " to " + game_name

# List all created games
func list_games():
	var result = "Created Games:\n\n"
	
	if created_games.size() == 0:
		return "No games created yet."
		
	for game_name in created_games:
		var game = created_games[game_name]
		result += "- " + game_name + " (Template: " + game.template + ")\n"
		result += "  " + game.description + "\n"
		result += "  Status: " + game.status + "\n"
		result += "  Scenes: " + str(game.scenes.size()) + "\n"
		result += "  Scripts: " + str(game.scripts.size()) + "\n"
		result += "  Resources: " + str(game.resources.size()) + "\n\n"
		
	return result

# Get details about a specific game
func get_game_details(game_name):
	if not created_games.has(game_name):
		return "Game not found: " + game_name
		
	var game = created_games[game_name]
	var result = "Game: " + game_name + "\n\n"
	
	result += "Template: " + game.template + "\n"
	result += "Description: " + game.description + "\n"
	result += "Status: " + game.status + "\n"
	
	result += "\nScenes:\n"
	for scene_name in game.scenes:
		result += "- " + scene_name + "\n"
		
	result += "\nScripts:\n"
	for script_name in game.scripts:
		result += "- " + script_name + ".gd\n"
		
	result += "\nResources:\n"
	for resource_name in game.resources:
		result += "- " + resource_name + "\n"
		
	return result

# Export a game to a specified platform
func export_game(game_name, platform="Windows"):
	if not created_games.has(game_name):
		return "Game not found: " + game_name
		
	# Update status
	created_games[game_name].status = "exported"
	
	emit_signal("game_exported", game_name, platform)
	
	return "Game exported: " + game_name + " (Platform: " + platform + ")"

# Run a game
func run_game(game_name):
	if not created_games.has(game_name):
		return "Game not found: " + game_name
		
	return "Running game: " + game_name

# Get a list of available templates
func get_templates():
	var result = "Available Game Templates:\n\n"
	
	for template_name in templates:
		var template = templates[template_name]
		result += "- " + template_name + ": " + template.description + "\n"
		
	return result

# Process game-related commands
func cmd_game(args):
	if args.size() == 0:
		return get_templates()
		
	match args[0]:
		"create":
			if args.size() < 2:
				return "Usage: game create <game_name> [template]"
				
			var template = "platformer"
			if args.size() >= 3:
				template = args[2]
				
			return create_game(args[1], template)
			
		"list":
			return list_games()
			
		"details":
			if args.size() < 2:
				return "Usage: game details <game_name>"
				
			return get_game_details(args[1])
			
		"run":
			if args.size() < 2:
				return "Usage: game run <game_name>"
				
			return run_game(args[1])
			
		"export":
			if args.size() < 2:
				return "Usage: game export <game_name> [platform]"
				
			var platform = "Windows"
			if args.size() >= 3:
				platform = args[2]
				
			return export_game(args[1], platform)
			
		"script":
			if args.size() < 3:
				return "Usage: game script <game_name> <script_name> [content]"
				
			var content = ""
			if args.size() >= 4:
				content = " ".join(args.slice(3))
				
			return add_script(args[1], args[2], content)
			
		"templates":
			return get_templates()
			
		_:
			return "Unknown game command. Try 'create', 'list', 'details', 'run', 'export', 'script', or 'templates'"
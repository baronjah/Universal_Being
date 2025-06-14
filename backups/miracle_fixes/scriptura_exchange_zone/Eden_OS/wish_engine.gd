extends Node

class_name WishEngine

signal wish_created(wish_id, wish_type, strength)
signal wish_fulfilled(wish_id, result_type, output)
signal project_merged(project_id, wish_ids, new_project_id)
signal game_created(game_id, title, genre)

# Core systems references
var turn_cycle_manager: TurnCycleManager
var dimensional_color_system: DimensionalColorSystem
var astral_entity_system: AstralEntitySystem
var letter_paint_system: LetterPaintSystem
var shape_system: ShapeSystem
var paint_system: PaintSystem

# Wish Types
enum WishType {
	CREATION,      # Creating something new
	TRANSFORMATION, # Changing something existing
	EVOLUTION,     # Growing/advancing something
	CONNECTION,    # Connecting/merging things
	MANIFESTATION, # Bringing concept into reality
	EXPLORATION,   # Discovering/learning
	DISSOLUTION,   # Removing/dissolving something
	TRANSCENDENCE, # Moving beyond current state
	INTEGRATION    # Combining disparate elements
}

# Game Genres
enum GameGenre {
	ACTION,
	ADVENTURE,
	RPG,
	STRATEGY,
	SIMULATION,
	PUZZLE,
	PLATFORMER,
	CARD_GAME,
	BOARD_GAME,
	EDUCATIONAL,
	ROGUELIKE,
	IDLE,
	WORD_GAME,
	DIMENSIONAL,
	HYBRID
}

# Result Types
enum ResultType {
	SUCCESS,       # Wish fulfilled successfully
	PARTIAL,       # Partial fulfillment
	TRANSFORMED,   # Wish transformed into something else
	DELAYED,       # Will be fulfilled later
	MERGED,        # Merged with another wish
	FAILED,        # Could not be fulfilled
	TRANSCENDED    # Fulfilled beyond expectations
}

# Account Types for merging
enum AccountType {
	PERSONAL,      # Individual user account
	PROJECT,       # Project-specific account
	SYSTEM,        # System-level account
	DIMENSIONAL,   # Accounts across dimensions
	COLLECTIVE,    # Shared/group account
	ASTRAL,        # Non-physical entity account
	TRANSIENT      # Temporary account
}

# Wish class for storing wish data
class Wish:
	var id: String
	var content: String
	var type: int # WishType
	var strength: float # 0.0 to 10.0
	var dimension: int # 1-9
	var creation_time: int
	var fulfillment_time: int = 0
	var is_fulfilled: bool = false
	var result_type: int = -1 # ResultType
	var result_output: String = ""
	var source_entities = [] # IDs of source entities
	var created_entities = [] # IDs of created entities
	var tags = []
	var properties = {}
	
	func _init(p_id: String, p_content: String, p_type: int, p_strength: float, p_dimension: int):
		id = p_id
		content = p_content
		type = p_type
		strength = p_strength
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
	
	func fulfill(p_result_type: int, p_output: String = ""):
		is_fulfilled = true
		result_type = p_result_type
		result_output = p_output
		fulfillment_time = Time.get_unix_time_from_system()
	
	func get_age() -> int:
		return Time.get_unix_time_from_system() - creation_time
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"content": content,
			"type": type,
			"strength": strength,
			"dimension": dimension,
			"creation_time": creation_time,
			"fulfillment_time": fulfillment_time,
			"is_fulfilled": is_fulfilled,
			"result_type": result_type,
			"result_output": result_output,
			"source_entities": source_entities,
			"created_entities": created_entities,
			"tags": tags,
			"properties": properties
		}
	
	static func deserialize(data: Dictionary) -> Wish:
		var wish = Wish.new(
			data.id,
			data.content,
			data.type,
			data.strength,
			data.dimension
		)
		wish.creation_time = data.creation_time
		wish.fulfillment_time = data.fulfillment_time
		wish.is_fulfilled = data.is_fulfilled
		wish.result_type = data.result_type
		wish.result_output = data.result_output
		wish.source_entities = data.source_entities
		wish.created_entities = data.created_entities
		wish.tags = data.tags
		wish.properties = data.properties
		
		return wish

# Project class for organizing related wishes
class Project:
	var id: String
	var title: String
	var description: String
	var wishes = [] # Wish IDs
	var games = [] # Game IDs
	var accounts = [] # Account IDs
	var creation_time: int
	var last_update_time: int
	var dimension: int
	var tags = []
	var properties = {}
	
	func _init(p_id: String, p_title: String, p_description: String, p_dimension: int):
		id = p_id
		title = p_title
		description = p_description
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
		last_update_time = creation_time
	
	func add_wish(wish_id: String):
		if not wish_id in wishes:
			wishes.append(wish_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func add_game(game_id: String):
		if not game_id in games:
			games.append(game_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func add_account(account_id: String):
		if not account_id in accounts:
			accounts.append(account_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"title": title,
			"description": description,
			"wishes": wishes,
			"games": games,
			"accounts": accounts,
			"creation_time": creation_time,
			"last_update_time": last_update_time,
			"dimension": dimension,
			"tags": tags,
			"properties": properties
		}
	
	static func deserialize(data: Dictionary) -> Project:
		var project = Project.new(
			data.id,
			data.title,
			data.description,
			data.dimension
		)
		project.wishes = data.wishes
		project.games = data.games
		project.accounts = data.accounts
		project.creation_time = data.creation_time
		project.last_update_time = data.last_update_time
		project.tags = data.tags
		project.properties = data.properties
		
		return project

# Account class for user/entity identification
class Account:
	var id: String
	var name: String
	var type: int # AccountType
	var creation_time: int
	var last_access_time: int
	var projects = [] # Project IDs
	var wishes = [] # Wish IDs
	var dimension: int
	var connected_accounts = [] # Account IDs
	var properties = {}
	
	func _init(p_id: String, p_name: String, p_type: int, p_dimension: int):
		id = p_id
		name = p_name
		type = p_type
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
		last_access_time = creation_time
	
	func add_project(project_id: String):
		if not project_id in projects:
			projects.append(project_id)
			last_access_time = Time.get_unix_time_from_system()
	
	func add_wish(wish_id: String):
		if not wish_id in wishes:
			wishes.append(wish_id)
			last_access_time = Time.get_unix_time_from_system()
	
	func connect_account(account_id: String):
		if not account_id in connected_accounts:
			connected_accounts.append(account_id)
			last_access_time = Time.get_unix_time_from_system()
	
	func access():
		last_access_time = Time.get_unix_time_from_system()
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"type": type,
			"creation_time": creation_time,
			"last_access_time": last_access_time,
			"projects": projects,
			"wishes": wishes,
			"dimension": dimension,
			"connected_accounts": connected_accounts,
			"properties": properties
		}
	
	static func deserialize(data: Dictionary) -> Account:
		var account = Account.new(
			data.id,
			data.name,
			data.type,
			data.dimension
		)
		account.creation_time = data.creation_time
		account.last_access_time = data.last_access_time
		account.projects = data.projects
		account.wishes = data.wishes
		account.connected_accounts = data.connected_accounts
		account.properties = data.properties
		
		return account

# Game class for created games
class Game:
	var id: String
	var title: String
	var genre: int # GameGenre
	var description: String
	var creation_time: int
	var last_update_time: int
	var dimension: int
	var source_wishes = [] # Wish IDs
	var source_projects = [] # Project IDs
	var features = [] # Game features
	var code_snippets = {} # Key code snippets
	var properties = {}
	
	func _init(p_id: String, p_title: String, p_genre: int, p_description: String, p_dimension: int):
		id = p_id
		title = p_title
		genre = p_genre
		description = p_description
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
		last_update_time = creation_time
	
	func add_feature(feature: String):
		if not feature in features:
			features.append(feature)
			last_update_time = Time.get_unix_time_from_system()
	
	func add_code_snippet(name: String, code: String):
		code_snippets[name] = code
		last_update_time = Time.get_unix_time_from_system()
	
	func add_source_wish(wish_id: String):
		if not wish_id in source_wishes:
			source_wishes.append(wish_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func add_source_project(project_id: String):
		if not project_id in source_projects:
			source_projects.append(project_id)
			last_update_time = Time.get_unix_time_from_system()
	
	func serialize() -> Dictionary:
		return {
			"id": id,
			"title": title,
			"genre": genre,
			"description": description,
			"creation_time": creation_time,
			"last_update_time": last_update_time,
			"dimension": dimension,
			"source_wishes": source_wishes,
			"source_projects": source_projects,
			"features": features,
			"code_snippets": code_snippets,
			"properties": properties
		}
	
	static func deserialize(data: Dictionary) -> Game:
		var game = Game.new(
			data.id,
			data.title,
			data.genre,
			data.description,
			data.dimension
		)
		game.creation_time = data.creation_time
		game.last_update_time = data.last_update_time
		game.source_wishes = data.source_wishes
		game.source_projects = data.source_projects
		game.features = data.features
		game.code_snippets = data.code_snippets
		game.properties = data.properties
		
		return game

# Storage
var wishes = {}  # id -> Wish
var projects = {}  # id -> Project
var accounts = {}  # id -> Account
var games = {}  # id -> Game

# Counters
var wish_id_counter = 0
var project_id_counter = 0
var account_id_counter = 0
var game_id_counter = 0

# Current active session
var active_account_id = ""
var active_project_id = ""

# Terminal output buffer
var terminal_output = []
var max_terminal_lines = 100

# Random generation parameters
var game_genres_weighted = {} # genre -> weight
var feature_templates = []    # Array of template strings
var wish_templates = []       # Array of template strings

func _ready():
	# Get references to other systems
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	astral_entity_system = get_node_or_null("/root/AstralEntitySystem")
	letter_paint_system = get_node_or_null("/root/LetterPaintSystem")
	shape_system = get_node_or_null("/root/ShapeSystem")
	paint_system = get_node_or_null("/root/PaintSystem")
	
	# Connect signals
	if turn_cycle_manager:
		turn_cycle_manager.turn_completed.connect(_on_turn_completed)
		turn_cycle_manager.cycle_completed.connect(_on_cycle_completed)
	
	# Initialize templates
	_initialize_templates()
	
	# Load saved data
	_load_data()
	
	# Create system account if it doesn't exist
	_ensure_system_account()

func _initialize_templates():
	# Initialize game genre weights
	game_genres_weighted = {
		GameGenre.ACTION: 1.0,
		GameGenre.ADVENTURE: 1.0,
		GameGenre.RPG: 1.2,
		GameGenre.STRATEGY: 0.8,
		GameGenre.SIMULATION: 0.7,
		GameGenre.PUZZLE: 0.9,
		GameGenre.PLATFORMER: 0.8,
		GameGenre.CARD_GAME: 0.6,
		GameGenre.BOARD_GAME: 0.5,
		GameGenre.EDUCATIONAL: 0.5,
		GameGenre.ROGUELIKE: 0.7,
		GameGenre.IDLE: 0.6,
		GameGenre.WORD_GAME: 1.1,
		GameGenre.DIMENSIONAL: 1.3,
		GameGenre.HYBRID: 1.2
	}
	
	# Initialize feature templates
	feature_templates = [
		"A [adj] [noun] system",
		"[adj] [noun] mechanics",
		"Dimensional [noun] integration",
		"[noun] evolution over time",
		"[adj] progression system",
		"Dynamic [noun] generation",
		"[adj] character customization",
		"Procedural [noun] creation",
		"Multi-dimensional [noun]",
		"Interactive [noun] system",
		"[adj] physics simulation",
		"Emergent [noun] behaviors",
		"[adj] story progression",
		"Player-driven [noun] creation",
		"Dynamic [noun] that evolves with [noun]",
		"[adj] [noun] that responds to player choices",
		"Time-based [noun] evolution",
		"[noun] transcendence mechanics",
		"Memory-based [noun] system",
		"[adj] dimensional shifting"
	]
	
	# Initialize wish templates
	wish_templates = [
		"Create a game about [noun] and [noun]",
		"Transform [noun] into a [adj] game",
		"Merge the concepts of [noun] and [noun]",
		"Evolve the idea of [noun] into something [adj]",
		"Manifest a [adj] game with [noun] mechanics",
		"Connect [noun] with [noun] in a game system",
		"Create a [genre] game featuring [adj] [noun]",
		"Develop a game where [noun] and [noun] interact",
		"Build a game world where [noun] is the central theme",
		"Design a game mechanism for [noun] transformation",
		"Implement [adj] [noun] in a [genre] setting",
		"Integrate [noun] and [noun] across multiple dimensions",
		"Craft a game experience centered on [noun] evolution",
		"Generate a game concept merging [genre] with [genre]",
		"Transcend traditional [genre] mechanics with [noun]",
		"Develop a [dimension]-dimensional game about [noun]",
		"Create a system where [noun] evolves through [noun]",
		"Design an interactive experience exploring [noun]",
		"Build a game framework for [adj] [noun] creation",
		"Manifest a playable concept demonstrating [noun]"
	]

func _ensure_system_account():
	var system_name = "EdenOS_System"
	var system_account_id = ""
	
	# Check if system account exists
	for account_id in accounts:
		var account = accounts[account_id]
		if account.name == system_name and account.type == AccountType.SYSTEM:
			system_account_id = account_id
			break
	
	# Create system account if it doesn't exist
	if system_account_id == "":
		system_account_id = create_account(system_name, AccountType.SYSTEM)
		
		# Create a system project
		var project_id = create_project(
			"EdenOS Core",
			"The foundational system project for EdenOS",
			system_account_id
		)
		
		# Create initial wishes
		create_wish(
			"Create a dimensional game system",
			WishType.CREATION,
			5.0,
			system_account_id,
			project_id
		)
		
		create_wish(
			"Integrate consciousness with game mechanics",
			WishType.INTEGRATION,
			7.0,
			system_account_id,
			project_id
		)
		
		add_terminal_output("System account and project initialized")
	
	return system_account_id

func create_wish(content: String, type: int, strength: float, account_id: String = "", project_id: String = "") -> String:
	var wish_id = "wish_" + str(wish_id_counter)
	wish_id_counter += 1
	
	# Set dimension based on current turn or default to 1
	var dimension = 1
	if turn_cycle_manager and turn_cycle_manager.current_turn > 0:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_cycle_manager.current_turn - 1]
		dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	var wish = Wish.new(wish_id, content, type, strength, dimension)
	wishes[wish_id] = wish
	
	# Associate with account
	if account_id != "" and accounts.has(account_id):
		accounts[account_id].add_wish(wish_id)
		# Update access time
		accounts[account_id].access()
	
	# Associate with project
	if project_id != "" and projects.has(project_id):
		projects[project_id].add_wish(wish_id)
	
	# Create an entity for the wish
	if astral_entity_system:
		var entity_type = AstralEntitySystem.EntityType.INTENTION
		var entity_id = astral_entity_system.create_entity("Wish_" + str(wish_id_counter-1), entity_type)
		var entity = astral_entity_system.get_entity(entity_id)
		
		if entity:
			# Set properties
			entity.properties["wish_content"] = content
			entity.properties["wish_id"] = wish_id
			entity.properties["wish_type"] = WishType.keys()[type]
			entity.properties["wish_strength"] = strength
			
			# Add to dimensional presence
			entity.dimensional_presence.add_dimension(dimension, 1.0)
			
			# Store entity ID
			wish.source_entities.append(entity_id)
	
	emit_signal("wish_created", wish_id, type, strength)
	_save_data()
	
	add_terminal_output("Wish created: " + content)
	
	# Auto-fulfill some wishes based on type and strength
	if type == WishType.CREATION and strength > 6.0 and content.to_lower().contains("game"):
		# Auto-create a game for high-strength creation wishes
		_fulfill_game_creation_wish(wish_id)
	
	return wish_id

func fulfill_wish(wish_id: String, result_type: int, output: String = "") -> bool:
	if not wishes.has(wish_id):
		return false
	
	var wish = wishes[wish_id]
	if wish.is_fulfilled:
		return false
	
	wish.fulfill(result_type, output)
	emit_signal("wish_fulfilled", wish_id, result_type, output)
	_save_data()
	
	add_terminal_output("Wish fulfilled: " + wish.content)
	add_terminal_output("Result: " + ResultType.keys()[result_type])
	if output != "":
		add_terminal_output(output)
	
	return true

func create_project(title: String, description: String, account_id: String = "") -> String:
	var project_id = "project_" + str(project_id_counter)
	project_id_counter += 1
	
	# Set dimension based on current turn or default to 1
	var dimension = 1
	if turn_cycle_manager and turn_cycle_manager.current_turn > 0:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_cycle_manager.current_turn - 1]
		dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	var project = Project.new(project_id, title, description, dimension)
	projects[project_id] = project
	
	# Associate with account
	if account_id != "" and accounts.has(account_id):
		accounts[account_id].add_project(project_id)
		project.add_account(account_id)
		# Update access time
		accounts[account_id].access()
	
	_save_data()
	
	add_terminal_output("Project created: " + title)
	
	return project_id

func create_account(name: String, type: int) -> String:
	var account_id = "account_" + str(account_id_counter)
	account_id_counter += 1
	
	# Set dimension based on current turn or default to 1
	var dimension = 1
	if turn_cycle_manager and turn_cycle_manager.current_turn > 0:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_cycle_manager.current_turn - 1]
		dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	var account = Account.new(account_id, name, type, dimension)
	accounts[account_id] = account
	
	_save_data()
	
	add_terminal_output("Account created: " + name)
	
	return account_id

func create_game(title: String, genre: int, description: String, source_wish_ids = [], source_project_ids = []) -> String:
	var game_id = "game_" + str(game_id_counter)
	game_id_counter += 1
	
	# Set dimension based on current turn or default to 1
	var dimension = 1
	if turn_cycle_manager and turn_cycle_manager.current_turn > 0:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_cycle_manager.current_turn - 1]
		dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	var game = Game.new(game_id, title, genre, description, dimension)
	games[game_id] = game
	
	# Link to source wishes
	for wish_id in source_wish_ids:
		if wishes.has(wish_id):
			game.add_source_wish(wish_id)
	
	# Link to source projects
	for project_id in source_project_ids:
		if projects.has(project_id):
			game.add_source_project(project_id)
			projects[project_id].add_game(game_id)
	
	# Generate random features
	var feature_count = 3 + randi() % 5  # 3-7 features
	for i in range(feature_count):
		game.add_feature(_generate_random_feature())
	
	# Generate some code snippets
	_generate_game_code_snippets(game)
	
	emit_signal("game_created", game_id, title, genre)
	_save_data()
	
	add_terminal_output("Game created: " + title)
	add_terminal_output("Genre: " + GameGenre.keys()[genre])
	add_terminal_output("Description: " + description)
	
	return game_id

func merge_projects(project_ids: Array, new_title: String, new_description: String, account_id: String = "") -> String:
	if project_ids.size() < 2:
		add_terminal_output("Need at least 2 projects to merge")
		return ""
	
	# Validate all project IDs
	for project_id in project_ids:
		if not projects.has(project_id):
			add_terminal_output("Invalid project ID: " + project_id)
			return ""
	
	# Create a new project
	var new_project_id = create_project(new_title, new_description, account_id)
	var new_project = projects[new_project_id]
	
	# Set dimension to max of source projects
	var max_dimension = 1
	for project_id in project_ids:
		max_dimension = max(max_dimension, projects[project_id].dimension)
	new_project.dimension = max_dimension
	
	# Collect all wishes from source projects
	var all_wishes = []
	var all_games = []
	var all_accounts = []
	
	for project_id in project_ids:
		var project = projects[project_id]
		
		# Merge wishes
		for wish_id in project.wishes:
			if not wish_id in all_wishes and wishes.has(wish_id):
				all_wishes.append(wish_id)
				new_project.add_wish(wish_id)
		
		# Merge games
		for game_id in project.games:
			if not game_id in all_games and games.has(game_id):
				all_games.append(game_id)
				new_project.add_game(game_id)
				games[game_id].add_source_project(new_project_id)
		
		# Merge accounts
		for account_id in project.accounts:
			if not account_id in all_accounts and accounts.has(account_id):
				all_accounts.append(account_id)
				new_project.add_account(account_id)
				accounts[account_id].add_project(new_project_id)
				
				# Notify account of merger
				if account_id != account_id:
					add_terminal_output_for_account(
						account_id, 
						"Your project " + project.title + " has been merged into " + new_title
					)
		
		# Merge tags
		for tag in project.tags:
			if not tag in new_project.tags:
				new_project.tags.append(tag)
	
	# Create a merger wish if account specified
	if account_id != "":
		var wish_content = "Merge projects into " + new_title
		create_wish(wish_content, WishType.INTEGRATION, 5.0, account_id, new_project_id)
	
	emit_signal("project_merged", project_ids, all_wishes, new_project_id)
	_save_data()
	
	add_terminal_output("Projects merged into: " + new_title)
	add_terminal_output("Merged " + str(project_ids.size()) + " projects with " + 
		str(all_wishes.size()) + " wishes and " + str(all_games.size()) + " games")
	
	return new_project_id

func merge_accounts(account_ids: Array, new_name: String, new_type: int) -> String:
	if account_ids.size() < 2:
		add_terminal_output("Need at least 2 accounts to merge")
		return ""
	
	# Validate all account IDs
	for account_id in account_ids:
		if not accounts.has(account_id):
			add_terminal_output("Invalid account ID: " + account_id)
			return ""
	
	# Create a new account
	var new_account_id = create_account(new_name, new_type)
	var new_account = accounts[new_account_id]
	
	# Set dimension to max of source accounts
	var max_dimension = 1
	for account_id in account_ids:
		max_dimension = max(max_dimension, accounts[account_id].dimension)
	new_account.dimension = max_dimension
	
	# Collect all projects, wishes, and connected accounts
	var all_projects = []
	var all_wishes = []
	var all_connections = []
	
	for account_id in account_ids:
		var account = accounts[account_id]
		
		# Merge projects
		for project_id in account.projects:
			if not project_id in all_projects and projects.has(project_id):
				all_projects.append(project_id)
				new_account.add_project(project_id)
				projects[project_id].add_account(new_account_id)
		
		# Merge wishes
		for wish_id in account.wishes:
			if not wish_id in all_wishes and wishes.has(wish_id):
				all_wishes.append(wish_id)
				new_account.add_wish(wish_id)
		
		# Merge connected accounts
		for connected_id in account.connected_accounts:
			if not connected_id in all_connections and connected_id not in account_ids and accounts.has(connected_id):
				all_connections.append(connected_id)
				new_account.connect_account(connected_id)
				accounts[connected_id].connect_account(new_account_id)
				
				# Notify account of merger
				add_terminal_output_for_account(
					connected_id, 
					"Account " + account.name + " has merged into " + new_name
				)
	
	_save_data()
	
	add_terminal_output("Accounts merged into: " + new_name)
	add_terminal_output("Merged " + str(account_ids.size()) + " accounts with " + 
		str(all_projects.size()) + " projects and " + str(all_wishes.size()) + " wishes")
	
	return new_account_id

func wish_to_game(wish_id: String) -> String:
	if not wishes.has(wish_id):
		add_terminal_output("Invalid wish ID: " + wish_id)
		return ""
	
	var wish = wishes[wish_id]
	
	# Make sure this is a game-related wish
	if not _is_game_related_wish(wish.content):
		add_terminal_output("Wish is not game-related: " + wish.content)
		return ""
	
	# Extract game details from wish
	var details = _extract_game_details_from_wish(wish.content)
	
	# Create the game
	var game_id = create_game(
		details.title,
		details.genre,
		details.description,
		[wish_id],
		[]
	)
	
	if game_id != "":
		# Fulfill the wish
		fulfill_wish(
			wish_id,
			ResultType.SUCCESS,
			"Created game: " + details.title
		)
	
	return game_id

func set_active_account(account_id: String) -> bool:
	if not accounts.has(account_id):
		add_terminal_output("Invalid account ID: " + account_id)
		return false
	
	active_account_id = account_id
	accounts[account_id].access()
	
	add_terminal_output("Active account set to: " + accounts[account_id].name)
	return true

func set_active_project(project_id: String) -> bool:
	if not projects.has(project_id):
		add_terminal_output("Invalid project ID: " + project_id)
		return false
	
	active_project_id = project_id
	
	add_terminal_output("Active project set to: " + projects[project_id].title)
	return true

func add_terminal_output(text: String):
	terminal_output.append(text)
	
	# Keep buffer to a reasonable size
	while terminal_output.size() > max_terminal_lines:
		terminal_output.pop_front()

func add_terminal_output_for_account(account_id: String, text: String):
	if not accounts.has(account_id):
		return
	
	var account_name = accounts[account_id].name
	add_terminal_output("[" + account_name + "] " + text)

func get_terminal_output() -> String:
	return "\n".join(terminal_output)

func clear_terminal():
	terminal_output.clear()
	add_terminal_output("Terminal cleared")

func execute_command(command: String) -> String:
	add_terminal_output("> " + command)
	
	var parts = command.split(" ")
	if parts.size() == 0:
		return ""
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			_cmd_help()
		"list":
			if args.size() > 0:
				_cmd_list(args[0])
			else:
				_cmd_list("all")
		"create":
			if args.size() >= 2:
				_cmd_create(args[0], args.slice(1).join(" "))
			else:
				add_terminal_output("Usage: create <type> <details>")
		"merge":
			if args.size() >= 3:
				_cmd_merge(args[0], args[1].split(","), args.slice(2).join(" "))
			else:
				add_terminal_output("Usage: merge <type> <id1,id2,...> <name>")
		"wish":
			if args.size() >= 1:
				_cmd_wish(args.join(" "))
			else:
				add_terminal_output("Usage: wish <your wish text>")
		"use":
			if args.size() >= 2:
				_cmd_use(args[0], args[1])
			else:
				add_terminal_output("Usage: use <account|project> <id>")
		"game":
			if args.size() >= 1:
				_cmd_game(args[0], args.slice(1))
			else:
				add_terminal_output("Usage: game <action> [args]")
		"clear":
			clear_terminal()
		_:
			add_terminal_output("Unknown command: " + cmd)
			add_terminal_output("Type 'help' for available commands")
	
	return get_terminal_output()

func _cmd_help():
	add_terminal_output("Available commands:")
	add_terminal_output("  help                  - Show this help")
	add_terminal_output("  list <type>           - List items (wishes, projects, accounts, games)")
	add_terminal_output("  create <type> <info>  - Create new item (project, account)")
	add_terminal_output("  merge <type> <ids> <name> - Merge items (projects, accounts)")
	add_terminal_output("  wish <text>           - Create a new wish")
	add_terminal_output("  use <type> <id>       - Set active account or project")
	add_terminal_output("  game <action> [args]  - Game-related actions")
	add_terminal_output("  clear                 - Clear terminal output")

func _cmd_list(type: String):
	match type:
		"wishes", "wish":
			add_terminal_output("Wishes:")
			for wish_id in wishes:
				var wish = wishes[wish_id]
				var status = "Pending"
				if wish.is_fulfilled:
					status = "Fulfilled: " + ResultType.keys()[wish.result_type]
				add_terminal_output(wish_id + ": " + wish.content + " (" + status + ")")
		
		"projects", "project":
			add_terminal_output("Projects:")
			for project_id in projects:
				var project = projects[project_id]
				add_terminal_output(project_id + ": " + project.title + 
					" (" + str(project.wishes.size()) + " wishes, " + 
					str(project.games.size()) + " games)")
		
		"accounts", "account":
			add_terminal_output("Accounts:")
			for account_id in accounts:
				var account = accounts[account_id]
				add_terminal_output(account_id + ": " + account.name + 
					" (" + AccountType.keys()[account.type] + ")")
		
		"games", "game":
			add_terminal_output("Games:")
			for game_id in games:
				var game = games[game_id]
				add_terminal_output(game_id + ": " + game.title + 
					" (" + GameGenre.keys()[game.genre] + ")")
		
		"all":
			_cmd_list("accounts")
			add_terminal_output("")
			_cmd_list("projects")
			add_terminal_output("")
			_cmd_list("wishes")
			add_terminal_output("")
			_cmd_list("games")
		
		_:
			add_terminal_output("Unknown list type: " + type)
			add_terminal_output("Available types: wishes, projects, accounts, games, all")

func _cmd_create(type: String, details: String):
	match type:
		"project":
			var parts = details.split(":", true, 1)
			var title = parts[0].strip_edges()
			var description = ""
			if parts.size() > 1:
				description = parts[1].strip_edges()
			
			var project_id = create_project(title, description, active_account_id)
			add_terminal_output("Created project: " + project_id)
		
		"account":
			var parts = details.split(":", true, 1)
			var name = parts[0].strip_edges()
			var type_str = "PERSONAL"
			if parts.size() > 1:
				type_str = parts[1].strip_edges().to_upper()
			
			var account_type = AccountType.PERSONAL
			if AccountType.keys().has(type_str):
				account_type = AccountType[type_str]
			
			var account_id = create_account(name, account_type)
			add_terminal_output("Created account: " + account_id)
		
		_:
			add_terminal_output("Unknown creation type: " + type)
			add_terminal_output("Available types: project, account")

func _cmd_merge(type: String, ids: Array, name: String):
	match type:
		"projects", "project":
			var parts = name.split(":", true, 1)
			var title = parts[0].strip_edges()
			var description = ""
			if parts.size() > 1:
				description = parts[1].strip_edges()
			
			var project_id = merge_projects(ids, title, description, active_account_id)
			if project_id != "":
				add_terminal_output("Created merged project: " + project_id)
		
		"accounts", "account":
			var parts = name.split(":", true, 1)
			var account_name = parts[0].strip_edges()
			var type_str = "PERSONAL"
			if parts.size() > 1:
				type_str = parts[1].strip_edges().to_upper()
			
			var account_type = AccountType.PERSONAL
			if AccountType.keys().has(type_str):
				account_type = AccountType[type_str]
			
			var account_id = merge_accounts(ids, account_name, account_type)
			if account_id != "":
				add_terminal_output("Created merged account: " + account_id)
		
		_:
			add_terminal_output("Unknown merge type: " + type)
			add_terminal_output("Available types: projects, accounts")

func _cmd_wish(wish_text: String):
	if active_account_id == "":
		add_terminal_output("No active account. Use 'use account <id>' first")
		return
	
	var wish_id = create_wish(
		wish_text, 
		_determine_wish_type_from_text(wish_text),
		_calculate_wish_strength(wish_text),
		active_account_id,
		active_project_id
	)
	
	add_terminal_output("Created wish: " + wish_id)
	
	# Try to fulfill immediately if it's a game wish
	if _is_game_related_wish(wish_text):
		add_terminal_output("This appears to be a game-related wish")
		var game_id = wish_to_game(wish_id)
		if game_id != "":
			add_terminal_output("Automatically created game: " + game_id)

func _cmd_use(type: String, id: String):
	match type:
		"account":
			if set_active_account(id):
				# List projects for this account
				add_terminal_output("Projects for this account:")
				if accounts.has(id):
					for project_id in accounts[id].projects:
						if projects.has(project_id):
							add_terminal_output("  " + project_id + ": " + projects[project_id].title)
		
		"project":
			if set_active_project(id):
				# List wishes for this project
				add_terminal_output("Wishes for this project:")
				if projects.has(id):
					for wish_id in projects[id].wishes:
						if wishes.has(wish_id):
							add_terminal_output("  " + wish_id + ": " + wishes[wish_id].content)
		
		_:
			add_terminal_output("Unknown use type: " + type)
			add_terminal_output("Available types: account, project")

func _cmd_game(action: String, args: Array):
	match action:
		"create":
			if args.size() < 2:
				add_terminal_output("Usage: game create <title> <description>")
				return
			
			var title = args[0]
			var description = args.slice(1).join(" ")
			
			# Determine genre from description
			var genre = _determine_genre_from_text(description)
			
			var game_id = create_game(title, genre, description, [], [active_project_id] if active_project_id != "" else [])
			add_terminal_output("Created game: " + game_id)
		
		"fromwish", "from":
			if args.size() < 1:
				add_terminal_output("Usage: game fromwish <wish_id>")
				return
			
			var wish_id = args[0]
			var game_id = wish_to_game(wish_id)
			if game_id != "":
				add_terminal_output("Created game from wish: " + game_id)
		
		"show", "details":
			if args.size() < 1:
				add_terminal_output("Usage: game show <game_id>")
				return
			
			var game_id = args[0]
			if games.has(game_id):
				var game = games[game_id]
				add_terminal_output("Game: " + game.title)
				add_terminal_output("Genre: " + GameGenre.keys()[game.genre])
				add_terminal_output("Description: " + game.description)
				add_terminal_output("Features:")
				for feature in game.features:
					add_terminal_output("  - " + feature)
				
				add_terminal_output("Code Snippets:")
				for snippet_name in game.code_snippets:
					add_terminal_output("  - " + snippet_name + ":")
					var code_lines = game.code_snippets[snippet_name].split("\n")
					for line in code_lines:
						add_terminal_output("    " + line)
			else:
				add_terminal_output("Unknown game ID: " + game_id)
		
		_:
			add_terminal_output("Unknown game action: " + action)
			add_terminal_output("Available actions: create, fromwish, show")

func _fulfill_game_creation_wish(wish_id: String):
	if not wishes.has(wish_id):
		return
	
	var wish = wishes[wish_id]
	
	# Extract game details
	var details = _extract_game_details_from_wish(wish.content)
	
	# Create the game
	var source_project_ids = []
	if active_project_id != "":
		source_project_ids.append(active_project_id)
	
	var game_id = create_game(
		details.title,
		details.genre,
		details.description,
		[wish_id],
		source_project_ids
	)
	
	if game_id != "":
		# Fulfill the wish
		fulfill_wish(
			wish_id,
			ResultType.SUCCESS,
			"Created game: " + details.title + " (" + game_id + ")"
		)

func _determine_wish_type_from_text(text: String) -> int:
	text = text.to_lower()
	
	if text.begins_with("create") or text.begins_with("make") or text.begins_with("develop"):
		return WishType.CREATION
	elif text.begins_with("transform") or text.begins_with("change") or text.begins_with("convert"):
		return WishType.TRANSFORMATION
	elif text.begins_with("evolve") or text.begins_with("grow") or text.begins_with("advance"):
		return WishType.EVOLUTION
	elif text.begins_with("connect") or text.begins_with("merge") or text.begins_with("link"):
		return WishType.CONNECTION
	elif text.begins_with("manifest") or text.begins_with("realize") or text.begins_with("bring"):
		return WishType.MANIFESTATION
	elif text.begins_with("explore") or text.begins_with("discover") or text.begins_with("learn"):
		return WishType.EXPLORATION
	elif text.begins_with("dissolve") or text.begins_with("remove") or text.begins_with("delete"):
		return WishType.DISSOLUTION
	elif text.begins_with("transcend") or text.begins_with("ascend") or text.begins_with("elevate"):
		return WishType.TRANSCENDENCE
	elif text.begins_with("integrate") or text.begins_with("combine") or text.begins_with("unify"):
		return WishType.INTEGRATION
	else:
		# Default to creation
		return WishType.CREATION

func _determine_genre_from_text(text: String) -> int:
	text = text.to_lower()
	
	var genre_scores = {}
	for genre in GameGenre.values():
		genre_scores[genre] = 0.0
	
	# Check for explicit genre mentions
	if "action" in text:
		genre_scores[GameGenre.ACTION] += 2.0
	if "adventure" in text:
		genre_scores[GameGenre.ADVENTURE] += 2.0
	if "rpg" in text or "role" in text or "role-playing" in text or "role playing" in text:
		genre_scores[GameGenre.RPG] += 2.0
	if "strategy" in text or "tactical" in text:
		genre_scores[GameGenre.STRATEGY] += 2.0
	if "simulation" in text or "sim" in text:
		genre_scores[GameGenre.SIMULATION] += 2.0
	if "puzzle" in text:
		genre_scores[GameGenre.PUZZLE] += 2.0
	if "platform" in text:
		genre_scores[GameGenre.PLATFORMER] += 2.0
	if "card" in text:
		genre_scores[GameGenre.CARD_GAME] += 2.0
	if "board" in text:
		genre_scores[GameGenre.BOARD_GAME] += 2.0
	if "education" in text or "learning" in text or "educational" in text:
		genre_scores[GameGenre.EDUCATIONAL] += 2.0
	if "roguelike" in text or "roguelite" in text or "rogue" in text:
		genre_scores[GameGenre.ROGUELIKE] += 2.0
	if "idle" in text or "incremental" in text or "clicker" in text:
		genre_scores[GameGenre.IDLE] += 2.0
	if "word" in text or "letter" in text or "language" in text:
		genre_scores[GameGenre.WORD_GAME] += 2.0
	if "dimension" in text or "dimensional" in text:
		genre_scores[GameGenre.DIMENSIONAL] += 2.0
	
	# Content-based hints
	if "fight" in text or "combat" in text or "battle" in text:
		genre_scores[GameGenre.ACTION] += 1.0
	if "explore" in text or "journey" in text or "quest" in text:
		genre_scores[GameGenre.ADVENTURE] += 1.0
	if "character" in text or "level up" in text or "stats" in text:
		genre_scores[GameGenre.RPG] += 1.0
	if "plan" in text or "command" in text or "manage" in text:
		genre_scores[GameGenre.STRATEGY] += 1.0
	if "realistic" in text or "physics" in text:
		genre_scores[GameGenre.SIMULATION] += 1.0
	if "solve" in text or "challenge" in text:
		genre_scores[GameGenre.PUZZLE] += 1.0
	if "jump" in text or "obstacle" in text:
		genre_scores[GameGenre.PLATFORMER] += 1.0
	if "draw" in text or "deck" in text:
		genre_scores[GameGenre.CARD_GAME] += 1.0
	if "turn-based" in text or "turns" in text or "piece" in text:
		genre_scores[GameGenre.BOARD_GAME] += 1.0
	if "teach" in text or "learn" in text:
		genre_scores[GameGenre.EDUCATIONAL] += 1.0
	if "procedural" in text or "random" in text or "permadeath" in text:
		genre_scores[GameGenre.ROGUELIKE] += 1.0
	if "progress" in text or "automatic" in text:
		genre_scores[GameGenre.IDLE] += 1.0
	if "spell" in text or "vocabulary" in text:
		genre_scores[GameGenre.WORD_GAME] += 1.0
	if "reality" in text or "transcend" in text or "world" in text:
		genre_scores[GameGenre.DIMENSIONAL] += 1.0
	
	# Apply weighted random
	for genre in genre_scores:
		genre_scores[genre] *= game_genres_weighted.get(genre, 1.0)
		genre_scores[genre] += randf()  # Add randomness
	
	# Find highest score
	var best_genre = GameGenre.ACTION
	var best_score = 0.0
	
	for genre in genre_scores:
		if genre_scores[genre] > best_score:
			best_score = genre_scores[genre]
			best_genre = genre
	
	return best_genre

func _calculate_wish_strength(text: String) -> float:
	var base_strength = 3.0 + randf() * 3.0  # Base 3-6
	
	# Longer wishes are stronger
	base_strength += min(3.0, text.length() / 20.0)
	
	# Emotional/powerful words boost strength
	var power_words = ["powerful", "incredible", "amazing", "extraordinary", 
					 "magnificent", "spectacular", "transcendent", "divine",
					 "ultimate", "perfect", "absolute", "infinite"]
	
	for word in power_words:
		if word in text.to_lower():
			base_strength += 0.5
	
	# Cap at 0-10 range
	return min(10.0, max(0.0, base_strength))

func _is_game_related_wish(text: String) -> bool:
	text = text.to_lower()
	
	var game_words = ["game", "play", "interactive", "gameplay", "player"]
	
	for word in game_words:
		if word in text:
			return true
	
	return false

func _extract_game_details_from_wish(wish_text: String) -> Dictionary:
	var title = "Untitled Game"
	var description = wish_text
	var genre = GameGenre.ACTION
	
	# Try to extract a title
	if "game" in wish_text.to_lower() or "create" in wish_text.to_lower():
		var title_patterns = [
			'create a game (about|with|featuring) "([^"]+)"',
			'create a game (about|with|featuring) ([^.,]+)',
			'a game (called|named|titled) "([^"]+)"',
			'a game (called|named|titled) ([^.,]+)',
			'create "([^"]+)" game',
			'make a "([^"]+)" game',
			'develop "([^"]+)"'
		]
		
		for pattern in title_patterns:
			var regex = RegEx.new()
			regex.compile(pattern)
			var result = regex.search(wish_text.to_lower())
			if result and result.get_string(2):
				title = result.get_string(2)
				title = title.strip_edges()
				# Capitalize first letter of each word
				var words = title.split(" ")
				for i in range(words.size()):
					if words[i].length() > 0:
						words[i] = words[i][0].to_upper() + words[i].substr(1)
				title = " ".join(words)
				break
	
	# Determine genre
	genre = _determine_genre_from_text(wish_text)
	
	# Generate a description if we just have the wish text
	description = _generate_game_description(title, genre, wish_text)
	
	return {
		"title": title,
		"genre": genre,
		"description": description
	}

func _generate_game_description(title: String, genre: int, source_text: String = "") -> String:
	# Description templates
	var desc_templates = [
		"{title} is a {genre} game where players {action}.",
		"In {title}, players {action} in a world of {setting}.",
		"{title} takes players on a journey through {setting} where they can {action}.",
		"A {genre} experience where {action}, {title} offers {feature}.",
		"Enter the world of {title}, a {genre} game about {theme} where players {action}."
	]
	
	# Actions by genre
	var actions = {
		GameGenre.ACTION: ["battle enemies", "fight for survival", "engage in fast-paced combat"],
		GameGenre.ADVENTURE: ["explore vast worlds", "embark on epic quests", "discover hidden secrets"],
		GameGenre.RPG: ["develop unique characters", "make impactful choices", "level up and customize abilities"],
		GameGenre.STRATEGY: ["command armies", "build civilizations", "outsmart opponents"],
		GameGenre.SIMULATION: ["build and manage resources", "experience realistic scenarios", "control complex systems"],
		GameGenre.PUZZLE: ["solve mind-bending challenges", "unravel mysteries", "test their logical thinking"],
		GameGenre.PLATFORMER: ["jump across obstacles", "navigate treacherous terrain", "master precise movements"],
		GameGenre.CARD_GAME: ["build powerful decks", "play strategic card combinations", "collect rare cards"],
		GameGenre.BOARD_GAME: ["take turns making strategic moves", "compete against friends", "claim territory"],
		GameGenre.EDUCATIONAL: ["learn while having fun", "acquire new knowledge", "develop skills through play"],
		GameGenre.ROGUELIKE: ["face permanent death", "overcome procedurally generated challenges", "improve with each run"],
		GameGenre.IDLE: ["watch their empire grow", "optimize automatic processes", "unlock new content over time"],
		GameGenre.WORD_GAME: ["craft words from letters", "expand their vocabulary", "master linguistic challenges"],
		GameGenre.DIMENSIONAL: ["traverse multiple dimensions", "shift between realities", "manipulate space and time"],
		GameGenre.HYBRID: ["experience genre-blending gameplay", "enjoy diverse mechanics", "engage with innovative systems"]
	}
	
	# Settings based on source text or fallbacks
	var settings = ["fantasy", "sci-fi", "magical realms", "dystopian futures", "ancient civilizations", 
					"modern cities", "alternate realities", "digital landscapes", "mysterious islands"]
	
	var themes = ["adventure", "discovery", "power", "redemption", "creation", "destruction", 
				"mystery", "transformation", "connection", "survival"]
	
	var features = ["unique gameplay mechanics", "stunning visuals", "an immersive storyline", 
				"challenging puzzles", "memorable characters", "dynamic environments"]
	
	# Extract possible theme/setting from source text
	var extracted_theme = ""
	var keywords = source_text.split(" ")
	for keyword in keywords:
		if keyword.length() > 4 and not keyword.to_lower() in ["game", "create", "make", "about", "with", "where", "that"]:
			extracted_theme = keyword
			break
	
	# Select template and fill it
	var template = desc_templates[randi() % desc_templates.size()]
	var action = actions[genre][randi() % actions[genre].size()]
	var setting = extracted_theme if extracted_theme != "" else settings[randi() % settings.size()]
	var theme = extracted_theme if extracted_theme != "" else themes[randi() % themes.size()]
	var feature = features[randi() % features.size()]
	var genre_name = GameGenre.keys()[genre].capitalize()
	
	var description = template.replace("{title}", title)
	description = description.replace("{genre}", genre_name)
	description = description.replace("{action}", action)
	description = description.replace("{setting}", setting)
	description = description.replace("{theme}", theme)
	description = description.replace("{feature}", feature)
	
	return description

func _generate_random_feature() -> String:
	var template = feature_templates[randi() % feature_templates.size()]
	
	var nouns = ["world", "character", "level", "system", "mechanic", "environment", 
				"story", "progression", "challenge", "interface", "dimension", 
				"reward", "creature", "ability", "power", "quest", "landscape"]
	
	var adjectives = ["dynamic", "procedural", "interactive", "immersive", "challenging", 
					"responsive", "adaptive", "emergent", "strategic", "tactical", 
					"creative", "intuitive", "mysterious", "evolving", "dimensional"]
	
	var result = template.replace("[noun]", nouns[randi() % nouns.size()])
	result = result.replace("[adj]", adjectives[randi() % adjectives.size()])
	return result

func _generate_game_code_snippets(game: Game):
	var code_snippets = {}
	
	# Game controller
	code_snippets["GameController"] = """
extends Node

class_name GameController

# Core game systems
var game_state = GameState.new()
var level_manager = LevelManager.new()
var player_controller = PlayerController.new()
var ui_manager = UIManager.new()

func _ready():
	# Initialize game systems
	game_state.initialize()
	level_manager.initialize(game_state)
	player_controller.initialize(game_state)
	ui_manager.initialize(game_state)
	
	# Start the game
	start_game()

func start_game():
	print("Starting game: """ + game.title + """")
	level_manager.load_level(1)
	
func _process(delta):
	# Update game systems
	game_state.update(delta)
	level_manager.update(delta)
	player_controller.update(delta)
	ui_manager.update(delta)
"""

	# Main feature
	var feature = game.features[0] if game.features.size() > 0 else "Feature System"
	var feature_name = feature.split(" ").join("")
	
	code_snippets[feature_name] = """
extends Node

class_name """ + feature_name + """

signal feature_activated(feature_data)
signal feature_completed(result)

var is_active = false
var activation_level = 0.0
var dimension = 1

func initialize(config):
	print("Initializing """ + feature + """")
	dimension = config.get("dimension", 1)
	
func activate():
	is_active = true
	activation_level = 1.0
	emit_signal("feature_activated", {
		"time": Time.get_unix_time_from_system(),
		"dimension": dimension
	})
	
func update(delta):
	if is_active:
		# Feature-specific logic here
		activation_level -= delta * 0.1
		
		if activation_level <= 0:
			is_active = false
			emit_signal("feature_completed", {
				"success": true,
				"score": 100
			})
"""

	# Game state
	code_snippets["GameState"] = """
extends Resource

class_name GameState

signal state_changed(new_state, old_state)
signal dimension_shifted(new_dimension, old_dimension)

enum GamePhase {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	VICTORY
}

var current_phase = GamePhase.MENU
var score = 0
var current_level = 1
var current_dimension = 1
var player_data = {}

func initialize():
	player_data = {
		"health": 100,
		"energy": 50,
		"inventory": []
	}
	
func update(delta):
	# Update game state logic
	pass
	
func change_phase(new_phase):
	var old_phase = current_phase
	current_phase = new_phase
	emit_signal("state_changed", new_phase, old_phase)
	
func shift_dimension(new_dimension):
	var old_dimension = current_dimension
	current_dimension = new_dimension
	emit_signal("dimension_shifted", new_dimension, old_dimension)
"""

	# Add snippets to the game
	for name in code_snippets:
		game.add_code_snippet(name, code_snippets[name])

func _on_turn_completed(turn_number):
	# Process wishes potentially fulfilled by turn change
	var current_dimension = 1
	if dimensional_color_system:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_number - 1]
		current_dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	add_terminal_output("Turn " + str(turn_number) + " completed")
	add_terminal_output("Current dimension: " + str(current_dimension))
	
	# Check unfulfilled wishes at current dimension
	for wish_id in wishes:
		var wish = wishes[wish_id]
		if not wish.is_fulfilled and wish.dimension == current_dimension:
			if randf() < 0.2:  # 20% chance per turn
				var result_type = ResultType.SUCCESS
				if randf() < 0.3:  # 30% chance of transformation
					result_type = ResultType.TRANSFORMED
				
				fulfill_wish(wish_id, result_type, "Fulfilled by dimensional energies of turn " + str(turn_number))
				
				if wish.type == WishType.CREATION and _is_game_related_wish(wish.content):
					_fulfill_game_creation_wish(wish_id)

func _on_cycle_completed():
	add_terminal_output("Cycle completed")
	
	# Create a new integrated project at the end of each cycle
	if projects.size() >= 2:
		var project_ids = []
		var i = 0
		for project_id in projects:
			project_ids.append(project_id)
			i += 1
			if i >= 3:  # Limit to 3 projects
				break
		
		var new_project_id = merge_projects(
			project_ids,
			"Cycle Integration Project",
			"Automatically integrated project from cycle completion",
			_ensure_system_account()
		)
		
		add_terminal_output("Created cycle integration project: " + new_project_id)
	
	_save_data()

func _load_data():
	if FileAccess.file_exists("user://eden_wish.save"):
		var file = FileAccess.open("user://eden_wish.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			wish_id_counter = data.wish_id_counter
			project_id_counter = data.project_id_counter
			account_id_counter = data.account_id_counter
			game_id_counter = data.game_id_counter
			
			# Load wishes
			wishes.clear()
			for wish_data in data.wishes:
				var wish = Wish.deserialize(wish_data)
				wishes[wish.id] = wish
			
			# Load projects
			projects.clear()
			for project_data in data.projects:
				var project = Project.deserialize(project_data)
				projects[project.id] = project
			
			# Load accounts
			accounts.clear()
			for account_data in data.accounts:
				var account = Account.deserialize(account_data)
				accounts[account.id] = account
			
			# Load games
			games.clear()
			for game_data in data.games:
				var game = Game.deserialize(game_data)
				games[game.id] = game

func _save_data():
	var serialized_wishes = []
	for wish_id in wishes:
		serialized_wishes.append(wishes[wish_id].serialize())
	
	var serialized_projects = []
	for project_id in projects:
		serialized_projects.append(projects[project_id].serialize())
	
	var serialized_accounts = []
	for account_id in accounts:
		serialized_accounts.append(accounts[account_id].serialize())
	
	var serialized_games = []
	for game_id in games:
		serialized_games.append(games[game_id].serialize())
	
	var data = {
		"wish_id_counter": wish_id_counter,
		"project_id_counter": project_id_counter,
		"account_id_counter": account_id_counter,
		"game_id_counter": game_id_counter,
		"wishes": serialized_wishes,
		"projects": serialized_projects,
		"accounts": serialized_accounts,
		"games": serialized_games
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_wish.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
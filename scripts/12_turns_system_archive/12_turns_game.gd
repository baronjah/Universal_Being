extends Node

# 12 Turns Game - Main Game Script
# Integrates all systems for the complete 12 turns game experience
# Terminal 1: Divine Word Genesis

class_name TwelveTurnsGame

# ----- CONFIGURATION -----
var SAVE_DIR = "/mnt/c/Users/Percision 15/12_turns_system/saves/"
var CONFIG_PATH = "/mnt/c/Users/Percision 15/12_turns_system/config.json"
var DEBUG_MODE = true

# ----- SYSTEM REFERENCES -----
var divine_word_game = null
var turn_system = null
var divine_word_processor = null
var word_salem_controller = null
var word_crimes_analysis = null
var word_comment_system = null
var word_dream_storage = null
var main_controller = null

# ----- SIGNAL CONNECTIONS -----
signal game_initialized
signal system_integrated(system_name)
signal memory_tier_accessed(tier, operation)
signal dimension_transition_complete(from_dim, to_dim)

func _ready():
	print("12 Turns Game initializing...")
	
	# Load configuration if available
	load_config()
	
	# Initialize core systems
	initialize_systems()
	
	# Connect to existing main controller if available
	connect_to_existing_systems()
	
	# Start the interface
	initialize_ui()
	
	# Start the game systems
	start_game_systems()
	
	print("12 Turns Game initialization complete")
	print("Terminal 1: Divine Word Genesis is ready")
	print("Integration with existing systems: " + ("Complete" if main_controller else "Not detected"))
	
	emit_signal("game_initialized")

func load_config():
	var file = File.new()
	
	if file.file_exists(CONFIG_PATH):
		file.open(CONFIG_PATH, File.READ)
		var content = file.get_as_text()
		file.close()
		
		var result = JSON.parse(content)
		if result.error == OK:
			var config = result.result
			
			# Apply configuration
			if config.has("debug_mode"):
				DEBUG_MODE = config.debug_mode
			
			if config.has("save_dir"):
				SAVE_DIR = config.save_dir
				
			print("Configuration loaded from: " + CONFIG_PATH)
		else:
			print("Error parsing configuration file: " + result.error_string)
	else:
		# Create default configuration
		create_default_config()

func create_default_config():
	var config = {
		"debug_mode": DEBUG_MODE,
		"save_dir": SAVE_DIR,
		"turn_duration": 9.0,  # Sacred 9-second interval
		"dimensions_enabled": 12,
		"memory_tiers": 3,
		"salem_game_enabled": true,
		"quantum_loop_enabled": true,
		"comment_system_enabled": true,
		"dream_system_enabled": true
	}
	
	var file = File.new()
	file.open(CONFIG_PATH, File.WRITE)
	file.store_string(JSON.print(config, "  "))
	file.close()
	
	print("Default configuration created at: " + CONFIG_PATH)

func initialize_systems():
	# Create directory for saves if it doesn't exist
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	# Initialize TurnSystem if not already created
	turn_system = get_node_or_null("/root/TurnSystem")
	if not turn_system:
		turn_system = TurnSystem.new()
		turn_system.name = "TurnSystem"
		get_tree().root.add_child(turn_system)
		turn_system.turn_duration = 9.0  # Sacred 9-second interval
		emit_signal("system_integrated", "TurnSystem")
	
	# Initialize DivineWordProcessor if not already created
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	if not divine_word_processor:
		divine_word_processor = DivineWordProcessor.new()
		divine_word_processor.name = "DivineWordProcessor"
		get_tree().root.add_child(divine_word_processor)
		emit_signal("system_integrated", "DivineWordProcessor")
	
	# Initialize WordCommentSystem
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	if not word_comment_system:
		word_comment_system = WordCommentSystem.new()
		word_comment_system.name = "WordCommentSystem"
		get_tree().root.add_child(word_comment_system)
		emit_signal("system_integrated", "WordCommentSystem")
	
	# Initialize WordDreamStorage
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	if not word_dream_storage:
		word_dream_storage = WordDreamStorage.new()
		word_dream_storage.name = "WordDreamStorage"
		get_tree().root.add_child(word_dream_storage)
		emit_signal("system_integrated", "WordDreamStorage")
	
	# Initialize WordSalemGameController
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	if not word_salem_controller:
		word_salem_controller = WordSalemGameController.new()
		word_salem_controller.name = "WordSalemGameController"
		get_tree().root.add_child(word_salem_controller)
		emit_signal("system_integrated", "WordSalemGameController")
	
	# Initialize WordCrimesAnalysis
	word_crimes_analysis = get_node_or_null("/root/WordCrimesAnalysis")
	if not word_crimes_analysis:
		word_crimes_analysis = WordCrimesAnalysis.new()
		word_crimes_analysis.name = "WordCrimesAnalysis"
		get_tree().root.add_child(word_crimes_analysis)
		emit_signal("system_integrated", "WordCrimesAnalysis")
	
	# Initialize DivineWordGame
	divine_word_game = get_node_or_null("/root/DivineWordGame")
	if not divine_word_game:
		divine_word_game = DivineWordGame.new()
		divine_word_game.name = "DivineWordGame"
		get_tree().root.add_child(divine_word_game)
		emit_signal("system_integrated", "DivineWordGame")

func connect_to_existing_systems():
	# Try to connect to existing main controller
	main_controller = get_node_or_null("/root/main")
	
	if main_controller:
		# Connect signals from main controller to our systems
		main_controller.connect("turn_advanced", self, "_on_main_turn_advanced")
		main_controller.connect("note_created", self, "_on_main_note_created")
		main_controller.connect("word_manifested", self, "_on_main_word_manifested")
		
		if divine_word_processor and main_controller.word_processor:
			main_controller.word_processor.connect("word_processed", divine_word_processor, "_on_word_processed_external")
			
			# Also connect to Salem controller if available
			if word_salem_controller:
				main_controller.word_processor.connect("word_processed", word_salem_controller, "_on_word_processed_external")
		
		print("Connected to existing main controller")
		emit_signal("system_integrated", "Main Controller")

func initialize_ui():
	# Create the main UI container
	var ui_container = Control.new()
	ui_container.name = "UIContainer"
	ui_container.set_anchors_preset(Control.PRESET_WIDE)
	add_child(ui_container)
	
	# Create the Divine Word UI
	var main_ui = DivineWordUI.new()
	main_ui.name = "DivineWordUI"
	main_ui.set_anchors_preset(Control.PRESET_WIDE)
	ui_container.add_child(main_ui)
	
	# Create the Word Comment UI
	var comment_ui = WordCommentUI.new()
	comment_ui.name = "WordCommentUI"
	comment_ui.set_anchors_preset(Control.PRESET_WIDE)
	comment_ui.visible = false  # Start hidden
	ui_container.add_child(comment_ui)
	
	# Create the Salem Game UI
	var salem_ui = WordSalemUI.new()
	salem_ui.name = "WordSalemUI"
	salem_ui.set_anchors_preset(Control.PRESET_WIDE)
	salem_ui.visible = false  # Start hidden
	ui_container.add_child(salem_ui)
	
	print("User interface initialized")

func start_game_systems():
	# Start the turn system
	if turn_system:
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
		turn_system.start_turns()
	
	# Start the Salem game if available
	if word_salem_controller and divine_word_game:
		# Use the player list from divine_word_game if available
		var players = divine_word_game.config.players
		if players.size() >= word_salem_controller.min_players:
			word_salem_controller.start_game(players)
	
	# Start the game
	if divine_word_game:
		divine_word_game.start_game()
	
	print("Game systems started")

func _input(event):
	# Handle UI toggling with Tab key
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_TAB:
			toggle_ui()
		elif event.scancode == KEY_QUOTELEFT:  # Backtick key
			toggle_comment_mode()

func toggle_ui():
	# Toggle between different UI screens
	var ui_container = get_node("UIContainer")
	var main_ui = ui_container.get_node("DivineWordUI")
	var comment_ui = ui_container.get_node("WordCommentUI")
	var salem_ui = ui_container.get_node("WordSalemUI")
	
	if main_ui.visible:
		main_ui.visible = false
		comment_ui.visible = true
		salem_ui.visible = false
		print("Switched to Comment UI")
	elif comment_ui.visible:
		main_ui.visible = false
		comment_ui.visible = false
		salem_ui.visible = true
		print("Switched to Salem Game UI")
	else:
		main_ui.visible = true
		comment_ui.visible = false
		salem_ui.visible = false
		print("Switched to Main Game UI")

func toggle_comment_mode():
	# Toggle dream mode in the comment UI
	var ui_container = get_node("UIContainer")
	var comment_ui = ui_container.get_node("WordCommentUI")
	
	# Make sure Comment UI is visible
	if !comment_ui.visible:
		ui_container.get_node("DivineWordUI").visible = false
		ui_container.get_node("WordSalemUI").visible = false
		comment_ui.visible = true
	
	# Toggle dream mode
	comment_ui._on_dream_toggle(!comment_ui.dream_mode)
	print("Dream mode " + ("enabled" if comment_ui.dream_mode else "disabled"))

# ----- EVENT HANDLERS -----

func _on_dimension_changed(new_dimension, old_dimension):
	# Special handling for dimension changes
	
	# Check for special dimensions
	match new_dimension:
		7:  # Dream dimension
			# Make dream storage more active
			if word_dream_storage:
				word_dream_storage.connect("dream_saved", self, "_on_dream_saved")
				print("Dream dimension activated - Dream storage enhanced")
				
				# Add comment about dimension
				if word_comment_system:
					word_comment_system.add_comment("dimension_7", 
						"Entering the dreamscape of the 7th dimension. Dreams will be stored and processed.",
						word_comment_system.CommentType.DREAM)
		
		9:  # Judgment dimension
			# Activate the Salem game if not already active
			if word_salem_controller and word_salem_controller.current_state == word_salem_controller.GameState.LOBBY:
				var players = divine_word_game.config.players if divine_word_game else ["Player"]
				if players.size() >= word_salem_controller.min_players:
					word_salem_controller.start_game(players)
					print("Judgment dimension activated - Salem game started")
				
				# Add comment about dimension
				if word_comment_system:
					word_comment_system.add_comment("dimension_9", 
						"Entering the judgment dimension. The Town of Salem word trial begins.",
						word_comment_system.CommentType.DIVINE)
		
		12: # Divine dimension
			# Activate all systems at maximum power
			if divine_word_processor:
				divine_word_processor.divine_multiplier = 12.0  # Maximum divine amplification
				print("Divine dimension activated - Word power amplified 12x")
				
				# Add comment about dimension
				if word_comment_system:
					word_comment_system.add_comment("dimension_12", 
						"Entering the divine dimension. All words reach their maximum potential.",
						word_comment_system.CommentType.DIVINE)
	
	emit_signal("dimension_transition_complete", old_dimension, new_dimension)

func _on_dream_saved(dream_id, tier):
	emit_signal("memory_tier_accessed", tier, "save_dream")
	
	# Add comment about dream
	if word_comment_system:
		word_comment_system.add_comment("dream_saved", 
			"Dream saved to memory tier " + str(tier) + " with ID: " + dream_id,
			word_comment_system.CommentType.DREAM)

# ----- INTEGRATION WITH MAIN CONTROLLER -----

func _on_main_turn_advanced(turn_number, symbol, dimension):
	# Sync with our turn system
	if turn_system:
		turn_system.set_dimension(turn_number)
		print("Synchronized with main controller: Turn " + str(turn_number) + " - Dimension " + dimension)
		
		# Add comment about dimension change
		if word_comment_system:
			word_comment_system.add_comment("dimension_change", 
				"SYNCHRONIZED: Main controller advanced to " + dimension,
				word_comment_system.CommentType.OBSERVATION)

func _on_main_note_created(note_data):
	# Process the note in our systems
	if divine_word_processor and word_comment_system:
		var power = divine_word_processor.process_word(note_data.text, "Main_" + str(note_data.id))
		
		# Add as comment
		word_comment_system.add_comment("note_" + str(note_data.id),
			"NOTE: \"" + note_data.text + "\" from main controller (Power: " + str(power) + ")",
			word_comment_system.CommentType.OBSERVATION)
		
		print("Processed note from main controller: " + note_data.text)

func _on_main_word_manifested(word, position, power):
	# Process the manifested word in our systems
	if divine_word_game and word_comment_system:
		# Process in game
		divine_word_game.process_word(word)
		
		# Add as divine comment
		word_comment_system.add_comment(word,
			"MANIFESTED: Word manifested from main controller at position " + str(position) + " with power " + str(power),
			word_comment_system.CommentType.DIVINE)
		
		print("Word manifested from main controller: " + word)

# ----- PUBLIC API -----

func process_word(word, source="API"):
	var power = 0
	
	if divine_word_processor:
		power = divine_word_processor.process_word(word, source)
	
	if divine_word_game:
		divine_word_game.process_word(word)
	
	return power

func add_comment(word, comment_text, type=0):
	if word_comment_system:
		return word_comment_system.add_comment(word, comment_text, type)
	return null

func record_dream(word, dream_text):
	if word_comment_system:
		return word_comment_system.record_dream_fragment(word, dream_text)
	return null

func save_to_tier(data, tier=1):
	if word_dream_storage:
		if data.has("dream_text"):
			return word_dream_storage.save_dream(data, tier)
		elif data.has("text"):
			return word_dream_storage.save_comment(data, tier)
		else:
			return word_dream_storage.save_dimension_record(
				turn_system.current_dimension if turn_system else 1, 
				data, 
				tier
			)
	
	return null

func register_defense(word, defense_text, defender="API"):
	if word_comment_system:
		return word_comment_system.register_defense(word, defense_text, defender)
	return null

func get_game_stats():
	if divine_word_game:
		return divine_word_game.get_game_stats()
	return {
		"score": 0,
		"level": 1,
		"dimension": turn_system.current_dimension if turn_system else 1,
		"turn_count": turn_system.current_turn if turn_system else 0
	}

func get_dimension_challenge():
	if divine_word_game:
		return divine_word_game.get_dimension_challenge()
	return null

func get_memory_by_tier(tier):
	if word_dream_storage:
		# Emit signal for memory access
		emit_signal("memory_tier_accessed", tier, "read")
		
		var memories = []
		if tier == 1:
			# RAM tier
			if word_comment_system:
				for entry in word_comment_system.comment_history:
					memories.append(entry)
		elif tier == 2:
			# C: Drive tier
			if word_dream_storage.dimension_records:
				for dim in word_dream_storage.dimension_records.keys():
					var records = word_dream_storage.load_dimension_records(dim)
					memories.append(records)
		elif tier == 3:
			# D: Drive tier
			if word_dream_storage.defense_records:
				for defense_id in word_dream_storage.defense_records.keys():
					if word_dream_storage.defense_records[defense_id].tier == 3:
						var defense = word_dream_storage.load_defense_record(defense_id)
						memories.append(defense)
		
		return memories
	
	return []
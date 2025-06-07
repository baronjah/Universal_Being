extends Node

# Divine Word Game - Main Game Controller
# Integrates all systems for the 12 turns word game
# Terminal 1: Divine Word Genesis

class_name DivineWordGame

# Game state
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state = GameState.MENU
var current_level = 1
var player_name = "Divine Judge"
var score = 0
var turn_count = 0
var dimension_unlocked = 1  # Start with 1D unlocked

# References to other systems
var turn_system = null
var divine_word_processor = null
var word_salem_controller = null
var word_crimes_analysis = null
var word_comment_system = null
var word_dream_storage = null

# Game configuration
var config = {
	"turn_duration": 9.0,  # Sacred 9-second interval
	"dimensions": 12,
	"min_power_for_level_up": 100,
	"players": [],
	"word_targets": {},
	"banned_words": [],
	"sacred_words": [],
	"dimension_challenges": {}
}

# Signals
signal game_started
signal game_paused
signal game_resumed
signal game_over(final_score)
signal level_up(new_level)
signal dimension_unlocked(dimension)
signal word_target_completed(word, power)
signal turn_cycle_completed(cycle_number)

func _ready():
	initialize_game()
	connect_signals()
	setup_config()

func initialize_game():
	# Get references to all required systems
	turn_system = get_node_or_null("/root/TurnSystem")
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	word_crimes_analysis = get_node_or_null("/root/WordCrimesAnalysis")
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	
	# Create any missing systems
	if not turn_system:
		turn_system = TurnSystem.new()
		turn_system.name = "TurnSystem"
		get_tree().root.add_child(turn_system)
	
	if not divine_word_processor:
		divine_word_processor = DivineWordProcessor.new()
		divine_word_processor.name = "DivineWordProcessor"
		get_tree().root.add_child(divine_word_processor)
	
	if not word_salem_controller:
		word_salem_controller = WordSalemGameController.new()
		word_salem_controller.name = "WordSalemGameController"
		get_tree().root.add_child(word_salem_controller)
	
	if not word_crimes_analysis:
		word_crimes_analysis = WordCrimesAnalysis.new()
		word_crimes_analysis.name = "WordCrimesAnalysis"
		get_tree().root.add_child(word_crimes_analysis)
	
	if not word_comment_system:
		word_comment_system = WordCommentSystem.new()
		word_comment_system.name = "WordCommentSystem"
		get_tree().root.add_child(word_comment_system)
	
	if not word_dream_storage:
		word_dream_storage = WordDreamStorage.new()
		word_dream_storage.name = "WordDreamStorage"
		get_tree().root.add_child(word_dream_storage)

func connect_signals():
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if word_salem_controller:
		word_salem_controller.connect("game_over", self, "_on_salem_game_over")
		word_salem_controller.connect("word_crime_detected", self, "_on_word_crime_detected")
	
	if word_crimes_analysis:
		word_crimes_analysis.connect("dangerous_pattern_detected", self, "_on_dangerous_pattern_detected")
		word_crimes_analysis.connect("cosmic_power_threshold_reached", self, "_on_cosmic_power_threshold_reached")
	
	if word_comment_system:
		word_comment_system.connect("dream_recorded", self, "_on_dream_recorded")

func setup_config():
	# Set up initial game configuration
	
	# Add sample players for the Salem game
	config.players = [
		player_name,
		"Wordsmith",
		"Etymologist",
		"Word Sheriff",
		"Scribe",
		"Linguist",
		"Word Witch",
		"Mafia Godfather",
		"Mafia Silencer"
	]
	
	# Set up dimension challenges
	config.dimension_challenges = {
		1: {
			"name": "Linear Expression",
			"description": "Create words with at least 7 letters",
			"target_words": ["dimension", "linearly", "sequence", "oneness"],
			"min_power": 15,
			"reward": 100
		},
		2: {
			"name": "Planar Reflection",
			"description": "Create palindromes (words that read the same backward)",
			"target_words": ["level", "radar", "kayak", "deified"],
			"min_power": 20,
			"reward": 200
		},
		3: {
			"name": "Spatial Construction",
			"description": "Create words related to 3D space",
			"target_words": ["cube", "volume", "sphere", "depth", "breadth"],
			"min_power": 25,
			"reward": 300
		},
		4: {
			"name": "Temporal Flow",
			"description": "Create words related to time",
			"target_words": ["moment", "eternity", "chronos", "temporal"],
			"min_power": 30,
			"reward": 400
		},
		5: {
			"name": "Probability Waves",
			"description": "Create words containing 'qu' (quantum notation)",
			"target_words": ["quantum", "quark", "qubit", "liquid"],
			"min_power": 35,
			"reward": 500
		},
		6: {
			"name": "Phase Resonance",
			"description": "Create words with repeating letters",
			"target_words": ["bubble", "summer", "coffee", "llama"],
			"min_power": 40,
			"reward": 600
		},
		7: {
			"name": "Dream Weaving",
			"description": "Create words related to dreams or sleep",
			"target_words": ["dream", "sleep", "unconscious", "astral"],
			"min_power": 45,
			"reward": 700
		},
		8: {
			"name": "Interconnection",
			"description": "Create compound words",
			"target_words": ["starlight", "moonbeam", "sunflower", "rainfall"],
			"min_power": 50,
			"reward": 800
		},
		9: {
			"name": "Divine Judgment",
			"description": "Create words related to judgment or decision",
			"target_words": ["verdict", "justice", "balance", "decision"],
			"min_power": 55,
			"reward": 900
		},
		10: {
			"name": "Harmonic Convergence",
			"description": "Create words with vowel harmony",
			"target_words": ["banana", "elegant", "harmony", "symphony"],
			"min_power": 60,
			"reward": 1000
		},
		11: {
			"name": "Conscious Reflection",
			"description": "Create words related to thought and consciousness",
			"target_words": ["awareness", "cognition", "thought", "sentient"],
			"min_power": 65,
			"reward": 1100
		},
		12: {
			"name": "Divine Manifestation",
			"description": "Create words of spiritual or divine significance",
			"target_words": ["divine", "sacred", "eternal", "transcend"],
			"min_power": 70,
			"reward": 1200
		}
	}
	
	# Set up banned words
	config.banned_words = [
		"delete",
		"crash",
		"error",
		"terminate",
		"kill",
		"destroy",
		"corrupt"
	]
	
	# Set up sacred words
	config.sacred_words = [
		"divine",
		"transcend",
		"genesis",
		"creation",
		"harmony",
		"balance",
		"eternity"
	]
	
	# Set up word targets for current level
	update_word_targets()

func update_word_targets():
	config.word_targets = {}
	
	# Add dimension-specific targets based on current dimension
	var dimension = turn_system.current_dimension if turn_system else 1
	
	if config.dimension_challenges.has(dimension):
		var challenge = config.dimension_challenges[dimension]
		for word in challenge.target_words:
			config.word_targets[word] = {
				"completed": false,
				"min_power": challenge.min_power,
				"reward": challenge.reward / challenge.target_words.size()
			}
	
	# Add level-specific targets
	var level_words = []
	match current_level:
		1: level_words = ["start", "begin", "create"]
		2: level_words = ["expand", "develop", "grow"]
		3: level_words = ["transform", "evolve", "change"]
		4: level_words = ["master", "perfect", "complete"]
		5: level_words = ["transcend", "ascend", "divine"]
	
	for word in level_words:
		config.word_targets[word] = {
			"completed": false,
			"min_power": 20 * current_level,
			"reward": 50 * current_level
		}

func start_game():
	if current_state != GameState.MENU:
		return false
	
	current_state = GameState.PLAYING
	score = 0
	turn_count = 0
	current_level = 1
	dimension_unlocked = 1
	
	# Start the turn system
	if turn_system:
		turn_system.start_turns()
	
	# Start the Salem game
	if word_salem_controller:
		word_salem_controller.start_game(config.players)
	
	emit_signal("game_started")
	return true

func pause_game():
	if current_state != GameState.PLAYING:
		return false
	
	current_state = GameState.PAUSED
	
	# Pause the turn system
	if turn_system:
		turn_system.pause_turns()
	
	emit_signal("game_paused")
	return true

func resume_game():
	if current_state != GameState.PAUSED:
		return false
	
	current_state = GameState.PLAYING
	
	# Resume the turn system
	if turn_system:
		turn_system.resume_turns()
	
	emit_signal("game_resumed")
	return true

func end_game():
	if current_state != GameState.PLAYING and current_state != GameState.PAUSED:
		return false
	
	current_state = GameState.GAME_OVER
	
	# Stop the turn system
	if turn_system:
		turn_system.stop_turns()
	
	emit_signal("game_over", score)
	return true

func process_word(word):
	if current_state != GameState.PLAYING:
		return 0
	
	var power = 0
	
	# Check for banned words
	if word.to_lower() in config.banned_words:
		# Penalty for using banned words
		score -= 50
		if word_comment_system:
			word_comment_system.add_comment(word, "BANNED WORD: Penalty applied", 
				word_comment_system.CommentType.WARNING)
		return -1
	
	# Process the word
	if divine_word_processor:
		power = divine_word_processor.process_word(word, player_name)
	
	# Check for word targets
	check_word_targets(word, power)
	
	# Check for sacred words
	if word.to_lower() in config.sacred_words:
		# Bonus for using sacred words
		var bonus = power * 2
		score += bonus
		if word_comment_system:
			word_comment_system.add_comment(word, "SACRED WORD: Bonus applied +" + str(bonus), 
				word_comment_system.CommentType.DIVINE)
	
	return power

func check_word_targets(word, power):
	if not config.word_targets.has(word.to_lower()):
		return
	
	var target = config.word_targets[word.to_lower()]
	
	if not target.completed and power >= target.min_power:
		target.completed = true
		score += target.reward
		emit_signal("word_target_completed", word, power)
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment(word, "TARGET COMPLETED: +" + str(target.reward) + " points", 
				word_comment_system.CommentType.DIVINE)
		
		# Check if all targets for this dimension are completed
		check_dimension_completion()

func check_dimension_completion():
	var all_completed = true
	var dimension = turn_system.current_dimension if turn_system else 1
	
	if not config.dimension_challenges.has(dimension):
		return
	
	var challenge = config.dimension_challenges[dimension]
	
	for word in challenge.target_words:
		if config.word_targets.has(word) and not config.word_targets[word].completed:
			all_completed = false
			break
	
	if all_completed:
		# Unlock the next dimension
		unlock_dimension(dimension + 1)
		
		# Add bonus points
		score += challenge.reward
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment("dimension_" + str(dimension), 
				"DIMENSION MASTERED: All targets completed! +" + str(challenge.reward) + " bonus points", 
				word_comment_system.CommentType.DIVINE)

func unlock_dimension(dimension):
	if dimension > 12 or dimension <= dimension_unlocked:
		return
	
	dimension_unlocked = dimension
	emit_signal("dimension_unlocked", dimension)
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("dimension_unlock", 
			"DIMENSION " + str(dimension) + " UNLOCKED: New challenges await!", 
			word_comment_system.CommentType.DIVINE)
	
	# Update targets to include new dimension challenges
	update_word_targets()

func check_level_up():
	var target_score = current_level * config.min_power_for_level_up
	
	if score >= target_score:
		current_level += 1
		emit_signal("level_up", current_level)
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment("level_up", 
				"LEVEL UP: You have reached level " + str(current_level) + "!", 
				word_comment_system.CommentType.DIVINE)
		
		# Update targets for new level
		update_word_targets()
		
		return true
	
	return false

func _on_turn_completed(turn_number):
	turn_count = turn_number
	
	# Every 12 turns, a full cycle is completed
	if turn_number % 12 == 0:
		var cycle_number = turn_number / 12
		emit_signal("turn_cycle_completed", cycle_number)
		
		# Add cycle completion bonus
		score += cycle_number * 100
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment("cycle_" + str(cycle_number), 
				"CYCLE COMPLETED: +" + str(cycle_number * 100) + " points", 
				word_comment_system.CommentType.OBSERVATION)
		
		# Check for level up
		check_level_up()

func _on_dimension_changed(new_dimension, old_dimension):
	# Update word targets when dimension changes
	update_word_targets()
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("dimension_change", 
			"DIMENSION CHANGED: From " + str(old_dimension) + "D to " + str(new_dimension) + "D", 
			word_comment_system.CommentType.OBSERVATION)

func _on_word_processed(word, power, source_player):
	# Only handle words from the player
	if source_player != player_name:
		return
	
	# Add points based on word power
	score += power
	
	# Special handling for dimension 9 (judgment dimension)
	if turn_system and turn_system.current_dimension == 9:
		# In dimension 9, words have special judgment powers
		if power >= 50:
			# High power words in dimension 9 can influence Salem game judgment
			if word_salem_controller and word_salem_controller.current_state == word_salem_controller.GameState.JUDGMENT:
				word_salem_controller.influence_judgment(word, power)
	
	# Special handling for dimension 7 (dream dimension)
	if turn_system and turn_system.current_dimension == 7:
		# In dimension 7, words can generate dreams
		if power >= 30 and word_comment_system:
			word_comment_system.generate_dream_for_word(word, power)

func _on_salem_game_over(winning_faction):
	# Add points based on winning faction
	if winning_faction == "Town":
		score += 1000
	elif winning_faction == "Mafia":
		score += 500
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("salem_game", 
			"SALEM GAME OVER: " + winning_faction + " wins!", 
			word_comment_system.CommentType.OBSERVATION)

func _on_word_crime_detected(criminal, crime_type, word_power):
	# If the player commits crimes, apply penalties
	if criminal == player_name:
		var penalty = 0
		match crime_type:
			"minor": penalty = 10
			"moderate": penalty = 25
			"major": penalty = 50
			"cosmic": penalty = 100
		
		score -= penalty
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment("crime_penalty", 
				"CRIME PENALTY: -" + str(penalty) + " points for " + crime_type + " crime", 
				word_comment_system.CommentType.WARNING)

func _on_dangerous_pattern_detected(pattern, word, power):
	# Apply penalty for dangerous patterns
	if current_state == GameState.PLAYING:
		score -= 30
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment(word, 
				"DANGEROUS PATTERN: -30 points for using pattern '" + pattern + "'", 
				word_comment_system.CommentType.WARNING)

func _on_cosmic_power_threshold_reached(word, power):
	# Apply bonus for cosmic power words
	if current_state == GameState.PLAYING:
		var bonus = power * 3
		score += bonus
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment(word, 
				"COSMIC POWER: +" + str(bonus) + " points for reaching cosmic power", 
				word_comment_system.CommentType.DIVINE)
		
		# Cosmic power words automatically unlock the next dimension if not already unlocked
		if turn_system:
			unlock_dimension(turn_system.current_dimension + 1)

func _on_dream_recorded(dream_text, power_level):
	# Apply bonus for recording dreams
	if current_state == GameState.PLAYING:
		var bonus = power_level
		score += bonus
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment("dream_bonus", 
				"DREAM RECORDED: +" + str(bonus) + " points", 
				word_comment_system.CommentType.DREAM)

# Public API for game interaction

func submit_word(word):
	if current_state != GameState.PLAYING:
		return 0
	
	return process_word(word)

func get_dimension_challenge():
	var dimension = turn_system.current_dimension if turn_system else 1
	
	if config.dimension_challenges.has(dimension):
		return config.dimension_challenges[dimension]
	
	return null

func get_current_targets():
	var targets = []
	
	for word in config.word_targets.keys():
		targets.append({
			"word": word,
			"completed": config.word_targets[word].completed,
			"min_power": config.word_targets[word].min_power,
			"reward": config.word_targets[word].reward
		})
	
	return targets

func get_game_stats():
	return {
		"player_name": player_name,
		"score": score,
		"level": current_level,
		"turn_count": turn_count,
		"dimension": turn_system.current_dimension if turn_system else 1,
		"dimension_unlocked": dimension_unlocked,
		"state": current_state
	}

func restart_game():
	end_game()
	start_game()
	return true
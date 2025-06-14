extends Node

# Word Salem Game Controller
# Integrates the Town of Salem linguistic judgment game with the 12 turns system
# Terminal 1: Divine Word Genesis

class_name WordSalemGameController

# Game state constants
enum GameState {
	LOBBY,
	DAY,
	VOTING,
	DEFENSE,
	JUDGMENT,
	NIGHT,
	RESOLUTION
}

# Role types
enum RoleType {
	TOWN,
	MAFIA,
	NEUTRAL,
	DIVINE
}

# Game configuration
var turn_duration = 9.0  # The sacred 9-second interval
var min_players = 7
var max_players = 15
var current_state = GameState.LOBBY
var current_turn = 0
var current_day = 1

# Player management
var players = {}
var living_players = []
var dead_players = []
var votes = {}
var night_actions = {}

# Word crime tracking
var word_crimes_ledger = []
var power_thresholds = {
	"minor": 10,
	"moderate": 25,
	"major": 50,
	"cosmic": 100
}

# Role distribution
var role_distribution = {
	7: {"town": 5, "mafia": 1, "neutral": 1},
	8: {"town": 5, "mafia": 2, "neutral": 1},
	9: {"town": 6, "mafia": 2, "neutral": 1},
	10: {"town": 6, "mafia": 3, "neutral": 1},
	11: {"town": 7, "mafia": 3, "neutral": 1},
	12: {"town": 8, "mafia": 3, "neutral": 1},
	13: {"town": 8, "mafia": 4, "neutral": 1},
	14: {"town": 9, "mafia": 4, "neutral": 1},
	15: {"town": 9, "mafia": 4, "neutral": 2}
}

# Signal connections
signal day_started(day_number)
signal night_started(night_number)
signal player_died(player_name, role, death_cause)
signal game_over(winning_faction)
signal word_crime_detected(criminal, crime_type, word_power)
signal trial_started(player_name)
signal defense_started(player_name)
signal judgment_rendered(player_name, guilty_votes, total_votes)
signal role_revealed(player_name, role)
signal investigation_result(target, result)
signal judgment_issued(word, verdict, punishment, criminal)
signal pardon_granted(word, reason, criminal)

# Dimension integration references
var divine_word_processor = null
var turn_system = null
var word_crimes_analysis = null
var word_comment_system = null
var word_dream_storage = null

# Salem game specific tracking
var active_trials = {}
var player_abilities = {}
var silenced_players = []
var protected_players = []
var accused_player = null
var last_lynch_jester = false
var word_crime_trials = {}
var revealed_players = []
var town_meeting_log = []
var investigation_results = {}

# Other components
var word_salem_day_night = null
var word_salem_roles = null
var word_salem_trials = null

func _ready():
	randomize()
	
	# Initialize component references
	word_salem_day_night = preload("res://12_turns_system/word_salem_day_night.gd").new()
	word_salem_roles = preload("res://12_turns_system/word_salem_roles.gd").new()
	word_salem_trials = preload("res://12_turns_system/word_salem_trials.gd").new()
	
	# Set up component references to this controller
	word_salem_day_night.controller = self
	word_salem_roles.controller = self
	word_salem_trials.controller = self
	
	# Add them as children to this node
	add_child(word_salem_day_night)
	add_child(word_salem_roles)
	add_child(word_salem_trials)
	
	connect_to_systems()

func connect_to_systems():
	# Connect to the divine word processor and turn system
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	turn_system = get_node_or_null("/root/TurnSystem")
	word_crimes_analysis = get_node_or_null("/root/WordCrimesAnalysis")
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	if word_crimes_analysis:
		word_crimes_analysis.connect("word_crime_detected", self, "_on_crime_detected")
		word_crimes_analysis.connect("dangerous_pattern_detected", self, "_on_pattern_detected")
		word_crimes_analysis.connect("judgment_issued", self, "_on_judgment_issued_external")
	
	if word_comment_system:
		word_comment_system.connect("comment_added", self, "_on_comment_added")
		word_comment_system.connect("defense_registered", self, "_on_defense_registered")

func start_game(player_names):
	if player_names.size() < min_players or player_names.size() > max_players:
		return false
		
	# Initialize players
	living_players = []
	dead_players = []
	players = {}
	current_day = 1
	current_turn = 0
	current_state = GameState.LOBBY
	
	# Generate and assign roles using the roles component
	word_salem_roles.assign_roles(player_names)
	
	# Start the game phases with the day component
	return word_salem_day_night.start_day()

# Signal handlers and core functionality
func _on_word_processed(word, power, source_player):
	# Check if the word constitutes a crime
	var crime_type = null
	
	if power >= power_thresholds.cosmic:
		crime_type = "cosmic"
	elif power >= power_thresholds.major:
		crime_type = "major"
	elif power >= power_thresholds.moderate:
		crime_type = "moderate"
	elif power >= power_thresholds.minor:
		crime_type = "minor"
	
	if crime_type:
		word_salem_trials.record_word_crime(source_player, word, power, crime_type)
		emit_signal("word_crime_detected", source_player, crime_type, power)
		
		# Update player's word power
		if players.has(source_player):
			players[source_player].word_power += power
			players[source_player].word_crimes.append({
				"word": word,
				"power": power,
				"type": crime_type,
				"turn": current_turn
			})

func _on_turn_completed(turn_number):
	current_turn = turn_number
	
	# Every 12 turns (one full cycle), process word powers
	if turn_number % 12 == 0:
		word_salem_roles.process_word_powers()

func _on_dimension_changed(new_dimension, old_dimension):
	# Apply dimension-specific effects to the game
	match new_dimension:
		1: # 1D - Words gain power based on length
			modify_word_power_calculation("length_modifier", 1.5)
		3: # 3D - Words gain physical manifestation properties
			modify_word_power_calculation("physical_modifier", 2.0)
		5: # 5D - Words connect across conversations
			enable_connection_tracing(true)
		7: # 7D - Words echo through time
			enable_temporal_echoes(true)
		9: # 9D - Words form recursive patterns (a significant number)
			apply_recursive_multiplier(1.9)
			
			# Dimension 9 is special - all cosmic word crimes get an automatic trial
			word_salem_trials.start_automatic_word_crime_trials()
		12: # 12D - Words reach maximum divine potential
			apply_divine_amplification(true)

func _on_crime_detected(criminal, crime_type, word_power):
	# If in an active game, record the crime
	if current_state != GameState.LOBBY:
		# Check if criminal is a player
		if players.has(criminal):
			var numeric_type = 0
			match crime_type.to_lower():
				"minor": numeric_type = 0
				"moderate": numeric_type = 1
				"major": numeric_type = 2
				"cosmic": numeric_type = 3
			
			players[criminal].word_crimes.append({
				"type": numeric_type,
				"power": word_power,
				"turn": current_turn
			})
			
			# If cosmic crime, create a trial
			if crime_type.to_lower() == "cosmic" and turn_system and turn_system.current_dimension == 9:
				word_salem_trials.create_word_crime_trial(criminal, "cosmic_crime", word_power, crime_type)

func _on_pattern_detected(pattern, word, power):
	# If in an active game, check pattern for game effects
	if current_state != GameState.LOBBY:
		match pattern:
			"executable":
				# Highly dangerous pattern that could execute someone randomly
				if randf() < 0.25 and living_players.size() > 0:  # 25% chance
					var random_target = living_players[randi() % living_players.size()]
					
					if word_comment_system:
						word_comment_system.add_comment("town_meeting", 
							"WARNING: Executable pattern detected! Executing random target...", 
							word_comment_system.CommentType.WARNING)
					
					word_salem_day_night.execute_player(random_target, "Executable Pattern")
			"destructive":
				# Could damage someone's word power
				if living_players.size() > 0:
					var random_target = living_players[randi() % living_players.size()]
					players[random_target].word_power = max(0, players[random_target].word_power - power)
					
					if word_comment_system:
						word_comment_system.add_comment("town_meeting", 
							"WARNING: Destructive pattern detected! " + random_target + "'s word power damaged.", 
							word_comment_system.CommentType.WARNING)
			"self_reference":
				# Could reveal someone's role
				if randf() < 0.33 and living_players.size() > 0:  # 33% chance
					var random_target = living_players[randi() % living_players.size()]
					
					if word_comment_system:
						word_comment_system.add_comment("town_meeting", 
							"A self-reference pattern has revealed " + random_target + " is a " + players[random_target].role + "!", 
							word_comment_system.CommentType.WARNING)
					
					emit_signal("role_revealed", random_target, players[random_target].role)
					players[random_target].revealed = true
					revealed_players.append(random_target)

func _on_judgment_issued_external(word, verdict, punishment):
	word_salem_trials.process_external_judgment(word, verdict, punishment)

func _on_comment_added(word, comment_text, type):
	# Process comments in the context of the Salem game
	if current_state == GameState.LOBBY:
		return
		
	# Check if it's an accusation
	if word_comment_system and type == word_comment_system.CommentType.ACCUSATION:
		word_salem_trials.process_accusation_comment(word, comment_text)

func _on_defense_registered(word, defense_text):
	word_salem_trials.process_defense_statement(word, defense_text)

# Player action handling functions
func vote(voter, target):
	if current_state == GameState.VOTING and voter in living_players:
		votes[voter] = target
		return true
	return false

func judge_vote(voter, guilty):
	if current_state == GameState.JUDGMENT and voter in living_players:
		votes[voter] = guilty
		return true
	return false

func submit_night_action(player, action_type, target):
	if current_state == GameState.NIGHT and player in living_players and target in living_players:
		night_actions[player] = {
			"type": action_type,
			"target": target
		}
		return true
	return false

func submit_word_crime_vote(voter, trial_id, guilty):
	return word_salem_trials.submit_word_crime_vote(voter, trial_id, guilty)

# Dimension effects
func modify_word_power_calculation(modifier_name, value):
	if divine_word_processor:
		divine_word_processor.set_power_modifier(modifier_name, value)

func enable_connection_tracing(enabled):
	if divine_word_processor:
		divine_word_processor.set_connection_tracing(enabled)

func enable_temporal_echoes(enabled):
	if divine_word_processor:
		divine_word_processor.set_temporal_echoes(enabled)

func apply_recursive_multiplier(value):
	if divine_word_processor:
		divine_word_processor.set_recursive_multiplier(value)

func apply_divine_amplification(enabled):
	if divine_word_processor:
		divine_word_processor.set_divine_amplification(enabled)

# Helper functions
func can_perform_action(player):
	# Check if player is blocked
	if players[player].has("blocked") and players[player].blocked:
		return false
	
	# Check if player is alive
	if not player in living_players:
		return false
		
	return true

func is_neutral_killing(role):
	return role in ["Serial Killer", "Word Witch"]
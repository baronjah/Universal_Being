extends Node

# Word Salem Trials System
# Handles the trial system and word crime judgment
# Terminal 1: Divine Word Genesis

# Reference to main controller
var controller = null

func _ready():
	pass

# WORD CRIME RECORDING
func record_word_crime(player, word, power, crime_type):
	if !controller:
		return
		
	controller.word_crimes_ledger.append({
		"player": player,
		"word": word,
		"power": power,
		"type": crime_type,
		"day": controller.current_day,
		"turn": controller.current_turn,
		"timestamp": OS.get_unix_time()
	})
	
	# If a divine judge exists and the crime is cosmic, notify them
	for player_name in controller.players:
		if player_name in controller.living_players and controller.players[player_name].role == "Divine Judge" and crime_type == "cosmic":
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player_name, 
					"A cosmic word crime has been detected: " + word + " (Power: " + str(power) + ") by " + player, 
					controller.word_comment_system.CommentType.WARNING)
	
	# Create word crime trial if we're in the right dimension
	if controller.turn_system and controller.turn_system.current_dimension == 9 and crime_type == "cosmic":
		create_word_crime_trial(player, word, power, crime_type)

# TRIAL CREATION AND MANAGEMENT
func create_word_crime_trial(criminal, word, power, crime_type):
	if !controller:
		return ""
		
	var trial_id = "trial_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	controller.word_crime_trials[trial_id] = {
		"id": trial_id,
		"criminal": criminal,
		"word": word,
		"power": power,
		"type": crime_type,
		"day": controller.current_day,
		"turn": controller.current_turn,
		"timestamp": OS.get_unix_time(),
		"votes": {},
		"status": "pending",
		"verdict": null
	}
	
	# Announce the trial
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "WORD CRIME TRIAL: " + criminal + " is accused of a " + crime_type + " linguistic crime!",
		"day": controller.current_day,
		"phase": "word_trial",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"WORD CRIME TRIAL: " + criminal + " is accused of a " + crime_type + " linguistic crime!", 
			controller.word_comment_system.CommentType.WARNING)
	
	return trial_id

func start_automatic_word_crime_trials():
	if !controller:
		return
		
	# Find all cosmic word crimes without trials
	for crime in controller.word_crimes_ledger:
		if crime.type == "cosmic" and not crime.has("trial_id"):
			var trial_id = create_word_crime_trial(crime.player, crime.word, crime.power, "cosmic")
			crime.trial_id = trial_id

func submit_word_crime_vote(voter, trial_id, guilty):
	if !controller:
		return false
		
	if not controller.word_crime_trials.has(trial_id):
		return false
		
	var trial = controller.word_crime_trials[trial_id]
	if trial.status != "pending":
		return false
		
	trial.votes[voter] = guilty
	
	# Check if majority has voted
	var guilty_votes = 0
	var innocent_votes = 0
	
	for v in trial.votes:
		if trial.votes[v]:
			guilty_votes += 1
		else:
			innocent_votes += 1
	
	if guilty_votes + innocent_votes >= controller.living_players.size() / 2:
		# Render verdict
		if guilty_votes > innocent_votes:
			judge_word_crime(trial_id, "Guilty", "Linguistic Execution")
		else:
			judge_word_crime(trial_id, "Innocent", "No Punishment")
	
	return true

func judge_word_crime(trial_id, verdict, punishment):
	if !controller:
		return false
		
	if not controller.word_crime_trials.has(trial_id):
		return false
		
	var trial = controller.word_crime_trials[trial_id]
	trial.status = "judged"
	trial.verdict = verdict
	
	controller.town_meeting_log.append({
		"type": "word_crime_judgment",
		"criminal": trial.criminal,
		"word": trial.word,
		"verdict": verdict,
		"punishment": punishment,
		"day": controller.current_day,
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"WORD CRIME JUDGMENT: " + trial.criminal + " - " + verdict + " - " + punishment, 
			controller.word_comment_system.CommentType.WARNING)
	
	controller.emit_signal("judgment_issued", trial.word, verdict, punishment, trial.criminal)
	
	if verdict == "Guilty":
		apply_punishment(trial.criminal, punishment)
	
	return true

# PUNISHMENT SYSTEM
func apply_punishment(player_name, punishment):
	if !controller:
		return
		
	if not controller.players.has(player_name):
		return
		
	match punishment.to_lower():
		"linguistic correction required":
			# Minor punishment - Silence for a day
			controller.players[player_name].silenced_tonight = true
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player_name, 
					"You have been silenced for linguistic correction!", 
					controller.word_comment_system.CommentType.WARNING)
		"word power reduction":
			# Moderate punishment - Reduce word power
			controller.players[player_name].word_power = max(0, controller.players[player_name].word_power / 2)
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player_name, 
					"Your word power has been reduced as punishment!", 
					controller.word_comment_system.CommentType.WARNING)
		"linguistic execution":
			# Major punishment - Execute player
			if player_name in controller.living_players:
				if controller.word_salem_day_night:
					controller.word_salem_day_night.execute_player(player_name, "Linguistic Judgment")
		"dimension banishment":
			# Cosmic punishment - Remove player from game entirely
			if player_name in controller.living_players:
				if controller.word_salem_day_night:
					controller.word_salem_day_night.execute_player(player_name, "Dimension Banishment")
				
				# Special effect - player is completely removed
				controller.players[player_name].banished = true
				
				controller.town_meeting_log.append({
					"type": "announcement",
					"text": player_name + " has been banished from this dimension!",
					"day": controller.current_day,
					"phase": "banishment",
					"timestamp": OS.get_unix_time()
				})
				
				if controller.word_comment_system:
					controller.word_comment_system.add_comment("town_meeting", 
						player_name + " has been banished from this dimension!", 
						controller.word_comment_system.CommentType.WARNING)

# EXTERNAL JUDGMENT HANDLING
func process_external_judgment(word, verdict, punishment):
	if !controller:
		return
		
	# Process external judgment from WordCrimesAnalysis
	# Find if this word is associated with a player crime
	for crime in controller.word_crimes_ledger:
		if crime.word == word and not crime.has("judged"):
			crime.judged = true
			crime.verdict = verdict
			crime.punishment = punishment
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("town_meeting", 
					"JUDGMENT ISSUED: " + word + " - " + verdict + " - " + punishment, 
					controller.word_comment_system.CommentType.WARNING)
			
			controller.emit_signal("judgment_issued", word, verdict, punishment, crime.player)
			
			# Apply punishment effects
			if verdict.to_lower() == "guilty":
				apply_punishment(crime.player, punishment)
			
			break

# ACCUSATION AND DEFENSE HANDLING
func process_accusation_comment(word, comment_text):
	if !controller:
		return
		
	# See if this is related to a player
	for player_name in controller.players:
		if comment_text.find(player_name) >= 0:
			# Record vote against the player
			controller.players[player_name].votes_against += 1
			
			if controller.players[player_name].votes_against >= controller.living_players.size() / 2:
				# Automatic trial for high accusations
				controller.accused_player = player_name
				
				controller.town_meeting_log.append({
					"type": "announcement",
					"text": player_name + " has been put on trial due to multiple accusations!",
					"day": controller.current_day,
					"phase": "auto_trial",
					"timestamp": OS.get_unix_time()
				})
				
				if controller.word_comment_system:
					controller.word_comment_system.add_comment("town_meeting", 
						player_name + " has been put on trial due to multiple accusations!", 
						controller.word_comment_system.CommentType.WARNING)
				
				controller.emit_signal("trial_started", player_name)
				
				# Only do this if not already in defense phase
				if controller.current_state != controller.GameState.DEFENSE and controller.current_state != controller.GameState.JUDGMENT:
					if controller.word_salem_day_night:
						controller.word_salem_day_night.start_defense(player_name)
			break

func process_defense_statement(word, defense_text):
	if !controller:
		return
		
	# Process defense statement in the context of the Salem game
	if controller.current_state != controller.GameState.DEFENSE or controller.accused_player == null:
		return
	
	# Record that the player submitted a defense
	controller.players[controller.accused_player].has_defended = true
	
	controller.town_meeting_log.append({
		"type": "defense",
		"player": controller.accused_player,
		"text": defense_text,
		"day": controller.current_day,
		"phase": "defense",
		"timestamp": OS.get_unix_time()
	})
	
	# Add defense chance bonus
	if controller.players[controller.accused_player].role == "Jester":
		# Jesters have a better chance of being found innocent to prolong the game
		for voter in controller.votes.keys():
			if randf() < 0.6:  # 60% chance for each voter to be swayed
				controller.votes[voter] = false
	elif controller.players[controller.accused_player].role_type == controller.RoleType.TOWN:
		# Town members have a slightly better chance with a good defense
		for voter in controller.votes.keys():
			if controller.players[voter].role_type == controller.RoleType.TOWN and randf() < 0.4:  # 40% chance
				controller.votes[voter] = false

# PARDON SYSTEM
func pardon_word_crime(crime_id, reason, pardoner="System"):
	if !controller:
		return false
		
	# Find the crime in the ledger
	var crime = null
	for c in controller.word_crimes_ledger:
		if c.has("id") and c.id == crime_id:
			crime = c
			break
	
	if not crime:
		return false
	
	# Apply pardon
	crime.pardoned = true
	crime.pardon_reason = reason
	crime.pardoner = pardoner
	crime.pardon_timestamp = OS.get_unix_time()
	
	# Announce pardon
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": crime.player + " has been pardoned for their word crime: " + reason,
		"day": controller.current_day,
		"phase": "pardon",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			crime.player + " has been pardoned for their word crime: " + reason, 
			controller.word_comment_system.CommentType.INFORMATION)
		
		if crime.player in controller.players and crime.player in controller.living_players:
			controller.word_comment_system.add_comment("private_" + crime.player, 
				"You have been pardoned for your word crime: " + reason, 
				controller.word_comment_system.CommentType.INFORMATION)
	
	controller.emit_signal("pardon_granted", crime.word, reason, crime.player)
	
	return true

# DIVINE JUDGMENT SYSTEM
func divine_judgment(judge_name, criminal_name, verdict, punishment):
	if !controller:
		return false
		
	# Check if the player is a Divine Judge
	if not controller.players.has(judge_name) or controller.players[judge_name].role != "Divine Judge":
		return false
		
	# Check if they have the divine judgment ability
	if not controller.players[judge_name].has("divine_judgment") or not controller.players[judge_name].divine_judgment:
		return false
		
	# Get latest crime from the criminal
	var latest_crime = null
	for crime in controller.word_crimes_ledger:
		if crime.player == criminal_name:
			if latest_crime == null or crime.timestamp > latest_crime.timestamp:
				latest_crime = crime
	
	if not latest_crime:
		return false
	
	# Apply divine judgment
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "DIVINE JUDGMENT: " + judge_name + " has passed judgment on " + criminal_name + ": " + verdict + " - " + punishment,
		"day": controller.current_day,
		"phase": "divine_judgment",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"DIVINE JUDGMENT: " + judge_name + " has passed judgment on " + criminal_name + ": " + verdict + " - " + punishment, 
			controller.word_comment_system.CommentType.WARNING)
	
	# Apply punishment if guilty
	if verdict.to_lower() == "guilty":
		apply_punishment(criminal_name, punishment)
	
	# Use up the divine judgment ability
	controller.players[judge_name].divine_judgment = false
	controller.players[judge_name].abilities["divine_judgment"].uses = 0
	
	return true

# TRIAL STATISTICS
func get_trial_statistics():
	if !controller:
		return {}
		
	var stats = {
		"total_trials": controller.word_crime_trials.size(),
		"pending_trials": 0,
		"guilty_verdicts": 0,
		"innocent_verdicts": 0,
		"cosmic_trials": 0,
		"major_trials": 0,
		"moderate_trials": 0,
		"minor_trials": 0
	}
	
	for trial_id in controller.word_crime_trials:
		var trial = controller.word_crime_trials[trial_id]
		
		if trial.status == "pending":
			stats.pending_trials += 1
		elif trial.status == "judged":
			if trial.verdict.to_lower() == "guilty":
				stats.guilty_verdicts += 1
			else:
				stats.innocent_verdicts += 1
		
		# Count by type
		match trial.type.to_lower():
			"cosmic":
				stats.cosmic_trials += 1
			"major":
				stats.major_trials += 1
			"moderate":
				stats.moderate_trials += 1
			"minor":
				stats.minor_trials += 1
	
	return stats

func get_player_crime_history(player_name):
	if !controller:
		return []
		
	var crimes = []
	
	for crime in controller.word_crimes_ledger:
		if crime.player == player_name:
			crimes.append(crime)
	
	# Sort by timestamp
	crimes.sort_custom(self, "sort_by_timestamp_descending")
	
	return crimes

func sort_by_timestamp_descending(a, b):
	return a.timestamp > b.timestamp
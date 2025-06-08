extends Node

# Word Salem Day Night System
# Handles the day/night cycle and phase transitions for the Town of Salem judgment game
# Terminal 1: Divine Word Genesis

# Reference to main controller
var controller = null

# Timers
var phase_timer = null

func _ready():
	phase_timer = Timer.new()
	phase_timer.one_shot = true
	add_child(phase_timer)
	phase_timer.connect("timeout", self, "_on_phase_timeout")

# DAY PHASE FUNCTIONS
func start_day():
	if !controller:
		return false
		
	controller.current_state = controller.GameState.DAY
	controller.silenced_players = []
	
	# Reset player states for the new day
	for player_name in controller.players:
		controller.players[player_name].silenced = false
	
	# Apply any night action effects
	apply_night_effects()
	
	# Announce day start
	announce_day_start()
	
	controller.emit_signal("day_started", controller.current_day)
	
	# Allow discussion for 9 seconds multiplied by living players
	var discussion_time = controller.turn_duration * min(controller.living_players.size(), 3)
	phase_timer.wait_time = discussion_time
	phase_timer.start()
	
	return true

func _on_phase_timeout():
	# Determine which phase to transition to based on current state
	match controller.current_state:
		controller.GameState.DAY:
			start_voting()
		controller.GameState.VOTING:
			process_votes()
		controller.GameState.DEFENSE:
			start_judgment(controller.accused_player)
		controller.GameState.JUDGMENT:
			process_judgment()
		controller.GameState.NIGHT:
			finish_night()
		controller.GameState.RESOLUTION:
			start_day()

func announce_day_start():
	var announcement = "DAY " + str(controller.current_day) + " BEGINS"
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": announcement,
		"day": controller.current_day,
		"phase": "day_start",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			announcement, 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)

func apply_night_effects():
	# Apply effects from the previous night
	for player_name in controller.players:
		var player = controller.players[player_name]
		
		# Check for silencing
		if player.has("silenced_tonight") and player.silenced_tonight:
			controller.silenced_players.append(player_name)
			player.silenced = true
			player.silenced_tonight = false
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("town_meeting", 
					player_name + " has been silenced by a Silencer!", 
					controller.word_comment_system.CommentType.WARNING)
		
		# Process investigation results
		if player.has("pending_investigation") and player.pending_investigation:
			var result = player.pending_investigation
			player.investigation_results.append(result)
			player.pending_investigation = null
			
			# Notify the investigator
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + result.investigator, 
					"Your investigation of " + player_name + " reveals: " + result.result, 
					controller.word_comment_system.CommentType.INFORMATION)

# VOTING PHASE FUNCTIONS
func start_voting():
	controller.current_state = controller.GameState.VOTING
	controller.votes = {}
	
	# Initialize votes
	for player in controller.living_players:
		controller.votes[player] = null
	
	# Announce voting phase
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "VOTING PHASE BEGINS - Vote for suspicious players",
		"day": controller.current_day,
		"phase": "voting",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"VOTING PHASE BEGINS - Vote for suspicious players", 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	# Allow voting for 9*2 seconds
	phase_timer.wait_time = controller.turn_duration * 2
	phase_timer.start()

func process_votes():
	# Count votes
	var vote_count = {}
	var max_votes = 0
	var players_with_max_votes = []
	
	for voter in controller.votes.keys():
		var vote_target = controller.votes[voter]
		if vote_target != null:
			# Check if this voter is the mayor and revealed
			var vote_power = 1
			if controller.players[voter].role == "Word Mayor" and controller.players[voter].revealed:
				vote_power = 3
			
			if not vote_count.has(vote_target):
				vote_count[vote_target] = 0
			vote_count[vote_target] += vote_power
			
			if vote_count[vote_target] > max_votes:
				max_votes = vote_count[vote_target]
				players_with_max_votes = [vote_target]
			elif vote_count[vote_target] == max_votes:
				players_with_max_votes.append(vote_target)
	
	# If tie or no votes, skip to night
	if players_with_max_votes.size() != 1 or max_votes <= controller.living_players.size() / 4:
		announce_no_trial()
		start_night()
		return
	
	# Start defense phase for the most voted player
	controller.accused_player = players_with_max_votes[0]
	
	# Announce the trial
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": controller.accused_player + " has been put on trial with " + str(max_votes) + " votes!",
		"day": controller.current_day,
		"phase": "trial",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			controller.accused_player + " has been put on trial with " + str(max_votes) + " votes!", 
			controller.word_comment_system.CommentType.WARNING)
	
	controller.emit_signal("trial_started", controller.accused_player)
	start_defense(controller.accused_player)

func announce_no_trial():
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "Not enough votes to put anyone on trial. The town will sleep for now.",
		"day": controller.current_day,
		"phase": "no_trial",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"Not enough votes to put anyone on trial. The town will sleep for now.", 
			controller.word_comment_system.CommentType.INFORMATION)

# DEFENSE & JUDGMENT PHASE FUNCTIONS
func start_defense(player_name):
	controller.current_state = controller.GameState.DEFENSE
	
	# Announce defense phase
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": player_name + " is now defending against accusations!",
		"day": controller.current_day,
		"phase": "defense",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			player_name + " is now defending against accusations!", 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	controller.emit_signal("defense_started", player_name)
	
	# Allow defense for 9 seconds
	phase_timer.wait_time = controller.turn_duration
	phase_timer.start()

func start_judgment(player_name):
	controller.current_state = controller.GameState.JUDGMENT
	controller.votes = {}
	
	# Reset votes
	for player in controller.living_players:
		if player != player_name:  # Accused can't vote
			# Check if player is blackmailed
			if not controller.players[player].has("blackmailed") or not controller.players[player].blackmailed:
				controller.votes[player] = false  # Default innocent
	
	# Announce judgment phase
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "JUDGMENT PHASE - Vote guilty or innocent for " + player_name,
		"day": controller.current_day,
		"phase": "judgment",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"JUDGMENT PHASE - Vote guilty or innocent for " + player_name, 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	# Allow voting for 9 seconds
	phase_timer.wait_time = controller.turn_duration
	phase_timer.start()

func process_judgment():
	# Count guilty votes
	var guilty_votes = 0
	var total_votes = 0
	
	for voter in controller.votes.keys():
		if controller.votes[voter] != null:  # If they voted
			total_votes += 1
			if controller.votes[voter]:  # If guilty
				guilty_votes += 1
	
	# Announce judgment
	var verdict = "Innocent"
	if guilty_votes > total_votes / 2:
		verdict = "Guilty"
		
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "The town has found " + controller.accused_player + " " + verdict + " (" + str(guilty_votes) + "/" + str(total_votes) + " guilty votes)",
		"day": controller.current_day,
		"phase": "verdict",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"The town has found " + controller.accused_player + " " + verdict + " (" + str(guilty_votes) + "/" + str(total_votes) + " guilty votes)", 
			controller.word_comment_system.CommentType.WARNING)
	
	controller.emit_signal("judgment_rendered", controller.accused_player, guilty_votes, total_votes)
	
	# Execute if majority guilty
	if guilty_votes > total_votes / 2:
		# Check if player is a Jester
		if controller.players[controller.accused_player].role == "Jester":
			controller.players[controller.accused_player].lynched = true
			controller.last_lynch_jester = true
			
			# Jester haunt will happen tonight
			select_random_haunt_target(controller.accused_player)
		
		execute_player(controller.accused_player, "Town Vote")
	
	# Move to night phase
	start_night()

func select_random_haunt_target(jester_name):
	# Get list of voters who voted guilty
	var guilty_voters = []
	for voter in controller.votes.keys():
		if controller.votes[voter] == true:  # Voted guilty
			guilty_voters.append(voter)
	
	if guilty_voters.size() > 0:
		# Randomly select one guilty voter to haunt
		var haunt_target = guilty_voters[randi() % guilty_voters.size()]
		
		controller.players[jester_name].haunt_target = haunt_target
		
		# Log the selection
		print("JESTER HAUNT: " + jester_name + " will haunt " + haunt_target + " tonight!")
	else:
		# If somehow no one voted guilty, don't haunt anyone
		print("JESTER HAUNT: No guilty voters found for " + jester_name)

# NIGHT PHASE FUNCTIONS
func start_night():
	controller.current_state = controller.GameState.NIGHT
	controller.night_actions = {}
	controller.protected_players = []
	
	# Announce night phase
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "NIGHT " + str(controller.current_day) + " FALLS - The town goes to sleep",
		"day": controller.current_day,
		"phase": "night",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"NIGHT " + str(controller.current_day) + " FALLS - The town goes to sleep", 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	controller.emit_signal("night_started", controller.current_day)
	
	# Initialize night actions for all living players
	for player in controller.living_players:
		controller.night_actions[player] = null
	
	# Allow night actions for 9*3 seconds
	phase_timer.wait_time = controller.turn_duration * 3
	phase_timer.start()

func finish_night():
	# Process night actions
	process_night_actions()
	
	# Move to day phase
	controller.current_day += 1
	resolve_night()

func resolve_night():
	controller.current_state = controller.GameState.RESOLUTION
	
	# Process jester haunt if needed
	process_jester_haunt()
	
	# Apply protection for the next day if needed
	update_protection_status()
	
	# Announce deaths
	announce_night_deaths()
	
	# Check win conditions
	if check_win_conditions():
		return
	
	# Move to next day after 9 seconds
	phase_timer.wait_time = controller.turn_duration
	phase_timer.start()

func process_jester_haunt():
	# Check for jester haunt
	if controller.last_lynch_jester:
		for player_name in controller.players:
			if not controller.players[player_name].alive and controller.players[player_name].role == "Jester" and controller.players[player_name].lynched:
				if controller.players[player_name].has("haunt_target"):
					var target = controller.players[player_name].haunt_target
					
					# Kill the target unless protected
					if not target in controller.protected_players:
						kill_player(target, "Jester's Haunt")
						
						controller.town_meeting_log.append({
							"type": "announcement",
							"text": target + " died last night to a Jester's Haunt!",
							"day": controller.current_day,
							"phase": "night_resolution",
							"timestamp": OS.get_unix_time()
						})
						
						if controller.word_comment_system:
							controller.word_comment_system.add_comment("town_meeting", 
								target + " died last night to a Jester's Haunt!", 
								controller.word_comment_system.CommentType.WARNING)
	
	# Reset for next night
	controller.last_lynch_jester = false

func update_protection_status():
	# Decrease protection counters
	for player_name in controller.players:
		if controller.players[player_name].has("protection") and controller.players[player_name].protection > 0:
			controller.players[player_name].protection -= 1

func announce_night_deaths():
	var death_message = ""
	var deaths_occurred = false
	
	for player_name in controller.players:
		if player_name in controller.dead_players and controller.players[player_name].has("death_night") and controller.players[player_name].death_night == controller.current_day - 1:
			deaths_occurred = true
			death_message += player_name + " died last night. They were a " + controller.players[player_name].role + ".\n"
	
	if deaths_occurred:
		controller.town_meeting_log.append({
			"type": "announcement",
			"text": death_message,
			"day": controller.current_day,
			"phase": "night_resolution",
			"timestamp": OS.get_unix_time()
		})
		
		if controller.word_comment_system:
			controller.word_comment_system.add_comment("town_meeting", 
				death_message, 
				controller.word_comment_system.CommentType.WARNING)
	else:
		controller.town_meeting_log.append({
			"type": "announcement",
			"text": "No one died last night.",
			"day": controller.current_day,
			"phase": "night_resolution",
			"timestamp": OS.get_unix_time()
		})
		
		if controller.word_comment_system:
			controller.word_comment_system.add_comment("town_meeting", 
				"No one died last night.", 
				controller.word_comment_system.CommentType.INFORMATION)

# NIGHT ACTION PROCESSING
func process_night_actions():
	# 1. Process role-blocks first (prevents actions)
	process_role_blocks()
	
	# 2. Process protection actions (bodyguard, doctor, vests)
	process_protection_actions()
	
	# 3. Process investigative actions (sheriff, lookout, etc.)
	process_investigation_actions()
	
	# 4. Process witch control actions (redirects other actions)
	process_control_actions()
	
	# 5. Process killing actions (mafia, serial killer, veteran, vigilante)
	process_killing_actions()
	
	# 6. Process other special actions (blackmail, silence, etc.)
	process_special_actions()
	
	# Reset night actions
	controller.night_actions = {}

func process_role_blocks():
	var blocked_players = []
	
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "block" and controller.can_perform_action(player):
			blocked_players.append(action.target)
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You successfully blocked " + action.target + " last night!", 
					controller.word_comment_system.CommentType.INFORMATION)
			
			# Check if target is on alert
			if controller.players[action.target].has("on_alert") and controller.players[action.target].on_alert:
				kill_player(player, "Veteran on Alert")
	
	# Mark players as blocked
	for blocked_player in blocked_players:
		controller.players[blocked_player].blocked = true

func process_protection_actions():
	controller.protected_players = []
	
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "protect" and controller.can_perform_action(player):
			controller.protected_players.append(action.target)
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You protected " + action.target + " last night!", 
					controller.word_comment_system.CommentType.INFORMATION)
	
	# Add self-protection (vests, etc.)
	for player_name in controller.players:
		if player_name in controller.living_players:
			# Survivor vests
			if controller.players[player_name].role == "Word Survivor" and controller.night_actions[player_name] and controller.night_actions[player_name].type == "vest" and controller.can_perform_action(player_name):
				controller.protected_players.append(player_name)
				
				# Decrease vest count
				if controller.players[player_name].abilities["vest"].uses > 0:
					controller.players[player_name].abilities["vest"].uses -= 1
				
				if controller.word_comment_system:
					controller.word_comment_system.add_comment("private_" + player_name, 
						"You wore a bulletproof vest last night! (" + str(controller.players[player_name].abilities["vest"].uses) + " remaining)", 
						controller.word_comment_system.CommentType.INFORMATION)

func process_investigation_actions():
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if not controller.can_perform_action(player):
			continue
			
		# Sheriff investigations
		if action and action.type == "investigate" and controller.players[player].role == "Word Sheriff":
			var target = action.target
			var result = ""
			
			# Determine result based on role
			if controller.players[target].role_type == controller.RoleType.TOWN or controller.players[target].role == "Mafia Godfather":
				result = "Divine"
			elif controller.players[target].role_type == controller.RoleType.MAFIA:
				result = "Corrupted"
			else:
				result = "Neutral"
			
			# Add result to player's pending investigations
			controller.players[player].pending_investigation = {
				"investigator": player,
				"target": target,
				"result": result,
				"day": controller.current_day,
				"exact": false
			}
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"Your investigation of " + target + " will be ready in the morning.", 
					controller.word_comment_system.CommentType.INFORMATION)
		
		# Consigliere exact role investigations
		elif action and action.type == "investigate_exact" and controller.players[player].role == "Mafia Consigliere":
			var target = action.target
			var result = controller.players[target].role
			
			# Add result to player's pending investigations
			controller.players[player].pending_investigation = {
				"investigator": player,
				"target": target,
				"result": "Exact role: " + result,
				"day": controller.current_day,
				"exact": true
			}
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"Your investigation of " + target + " will be ready in the morning.", 
					controller.word_comment_system.CommentType.INFORMATION)
		
		# Lookout watching
		elif action and action.type == "watch" and controller.players[player].role == "Word Lookout":
			var target = action.target
			var visitors = []
			
			# Collect all players who targeted this player
			for p in controller.night_actions.keys():
				if p != player and controller.night_actions[p] and controller.night_actions[p].target == target:
					visitors.append(p)
			
			# Add result to player's pending investigations
			controller.players[player].pending_investigation = {
				"investigator": player,
				"target": target,
				"result": visitors.size() > 0 ? target + " was visited by: " + PoolStringArray(visitors).join(", ") : "No one visited " + target + " last night.",
				"day": controller.current_day,
				"exact": false
			}
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"Your lookout results will be ready in the morning.", 
					controller.word_comment_system.CommentType.INFORMATION)
		
		# Etymologist exact role reveal
		elif action and action.type == "reveal_role" and controller.players[player].role == "Etymologist":
			var target = action.target
			
			# Reveal the role to everyone
			controller.emit_signal("role_revealed", target, controller.players[target].role)
			
			controller.town_meeting_log.append({
				"type": "announcement",
				"text": "The Etymologist has revealed that " + target + " is a " + controller.players[target].role + "!",
				"day": controller.current_day,
				"phase": "night_resolution",
				"timestamp": OS.get_unix_time()
			})
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("town_meeting", 
					"The Etymologist has revealed that " + target + " is a " + controller.players[target].role + "!", 
					controller.word_comment_system.CommentType.WARNING)
			
			# Mark player as revealed
			controller.players[target].revealed = true
			controller.revealed_players.append(target)
			
			# Use up the ability
			controller.players[player].abilities["reveal_role"].uses = 0

func process_control_actions():
	var controlled_players = {}
	
	# Identify all control actions
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "control" and controller.can_perform_action(player):
			# Store the redirection
			controlled_players[action.target] = action.redirect_target
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You controlled " + action.target + " to target " + action.redirect_target + "!", 
					controller.word_comment_system.CommentType.INFORMATION)
	
	# Modify night actions based on control
	for player in controlled_players.keys():
		if controller.night_actions[player] and controller.night_actions[player].target:
			controller.night_actions[player].target = controlled_players[player]
			
			# Let the controlled player know
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You feel that your actions were controlled last night!", 
					controller.word_comment_system.CommentType.WARNING)

func process_killing_actions():
	var killed_players = []
	
	# Process veteran alerts first
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "alert" and controller.can_perform_action(player):
			controller.players[player].on_alert = true
			
			if controller.players[player].abilities["alert"].uses > 0:
				controller.players[player].abilities["alert"].uses -= 1
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You were on alert last night! (" + str(controller.players[player].abilities["alert"].uses) + " remaining)", 
					controller.word_comment_system.CommentType.INFORMATION)
	
	# Process mafia kills
	var mafia_kill_target = null
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "order_kill" and controller.can_perform_action(player):
			mafia_kill_target = action.target
	
	if mafia_kill_target:
		# Check if target is protected
		if not mafia_kill_target in controller.protected_players:
			# Check if target is on alert
			if controller.players[mafia_kill_target].has("on_alert") and controller.players[mafia_kill_target].on_alert:
				# Find a random mafia member to kill
				var mafia_members = []
				for p in controller.living_players:
					if controller.players[p].role_type == controller.RoleType.MAFIA:
						mafia_members.append(p)
				
				if mafia_members.size() > 0:
					var killed_mafioso = mafia_members[randi() % mafia_members.size()]
					kill_player(killed_mafioso, "Veteran on Alert")
			else:
				kill_player(mafia_kill_target, "Mafia")
				killed_players.append(mafia_kill_target)
	
	# Process vigilante/serial killer kills
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if not controller.can_perform_action(player):
			continue
			
		if action and (action.type == "kill" or action.type == "stab"):
			var target = action.target
			
			# Skip already killed players
			if target in killed_players:
				continue
				
			# Check if target is protected
			if target in controller.protected_players:
				continue
				
			# Check if target is on alert
			if controller.players[target].has("on_alert") and controller.players[target].on_alert:
				kill_player(player, "Veteran on Alert")
			else:
				# Perform the kill
				if action.type == "kill" and controller.players[player].role == "Vigilante":
					kill_player(target, "Vigilante")
					killed_players.append(target)
					
					# Decrease vigilante bullet count
					if controller.players[player].abilities["kill"].uses > 0:
						controller.players[player].abilities["kill"].uses -= 1
					
					# If vigilante kills a town member, they will commit suicide the next night
					if controller.players[target].role_type == controller.RoleType.TOWN:
						controller.players[player].will_suicide = true
						
						if controller.word_comment_system:
							controller.word_comment_system.add_comment("private_" + player, 
								"You killed a town member! You will commit suicide from guilt tonight.", 
								controller.word_comment_system.CommentType.WARNING)
				elif action.type == "stab" and controller.players[player].role == "Serial Killer":
					kill_player(target, "Serial Killer")
					killed_players.append(target)
	
	# Process vigilante suicides
	for player_name in controller.players:
		if player_name in controller.living_players and controller.players[player_name].has("will_suicide") and controller.players[player_name].will_suicide:
			kill_player(player_name, "Suicide from guilt")
			controller.players[player_name].will_suicide = false

func process_special_actions():
	# Process silencer actions
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "silence" and controller.can_perform_action(player):
			controller.players[action.target].silenced_tonight = true
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You silenced " + action.target + " for tomorrow!", 
					controller.word_comment_system.CommentType.INFORMATION)
	
	# Process blackmailer actions
	for player in controller.night_actions.keys():
		var action = controller.night_actions[player]
		if action and action.type == "blackmail" and controller.can_perform_action(player):
			controller.players[action.target].blackmailed = true
			
			if controller.word_comment_system:
				controller.word_comment_system.add_comment("private_" + player, 
					"You blackmailed " + action.target + " for tomorrow!", 
					controller.word_comment_system.CommentType.INFORMATION)
				
				controller.word_comment_system.add_comment("private_" + action.target, 
					"You have been blackmailed! You cannot vote tomorrow.", 
					controller.word_comment_system.CommentType.WARNING)

# ADDITIONAL MODULES
func execute_player(player_name, cause):
	if player_name in controller.living_players:
		controller.players[player_name].alive = false
		controller.players[player_name].death_cause = cause
		controller.players[player_name].death_day = controller.current_day
		controller.living_players.erase(player_name)
		controller.dead_players.append(player_name)
		
		controller.town_meeting_log.append({
			"type": "announcement",
			"text": player_name + " has been executed! They were a " + controller.players[player_name].role + ".",
			"day": controller.current_day,
			"phase": "execution",
			"timestamp": OS.get_unix_time()
		})
		
		if controller.word_comment_system:
			controller.word_comment_system.add_comment("town_meeting", 
				player_name + " has been executed! They were a " + controller.players[player_name].role + ".", 
				controller.word_comment_system.CommentType.WARNING)
		
		controller.emit_signal("player_died", player_name, controller.players[player_name].role, cause)

func kill_player(player_name, killer_role):
	if player_name in controller.living_players:
		controller.players[player_name].alive = false
		controller.players[player_name].death_cause = killer_role
		controller.players[player_name].death_day = controller.current_day
		controller.players[player_name].death_night = controller.current_day
		controller.living_players.erase(player_name)
		controller.dead_players.append(player_name)
		
		controller.emit_signal("player_died", player_name, controller.players[player_name].role, "Killed by " + killer_role)

func check_win_conditions():
	# Count factions
	var town_count = 0
	var mafia_count = 0
	var neutral_killing_count = 0
	
	for player in controller.living_players:
		var role_type = controller.players[player].role_type
		
		match role_type:
			controller.RoleType.TOWN:
				town_count += 1
			controller.RoleType.MAFIA:
				mafia_count += 1
			controller.RoleType.NEUTRAL:
				if controller.is_neutral_killing(controller.players[player].role):
					neutral_killing_count += 1
	
	# Check win conditions
	if mafia_count == 0 and neutral_killing_count == 0 and town_count > 0:
		# Town wins
		announce_winner("Town")
		return true
	elif mafia_count >= town_count and neutral_killing_count == 0:
		# Mafia wins
		announce_winner("Mafia")
		return true
	elif town_count == 0 and mafia_count == 0 and neutral_killing_count == 1:
		# Neutral killing role wins
		announce_winner("Neutral Killer")
		return true
	elif town_count == 0 and mafia_count == 0 and neutral_killing_count == 0:
		# Draw
		announce_winner("Draw")
		return true
	
	# Check special win conditions for specific roles
	for player in controller.players.values():
		if player.role == "Jester" and player.name in controller.dead_players and player.lynched == true:
			announce_winner("Jester (" + player.name + ")")
			return true
		elif player.role == "Word Survivor" and player.name in controller.living_players:
			var all_killers_dead = true
			
			# Check if all killing roles are gone
			for p in controller.living_players:
				if p != player.name and (controller.players[p].role_type == controller.RoleType.MAFIA or controller.is_neutral_killing(controller.players[p].role)):
					all_killers_dead = false
					break
			
			if all_killers_dead and town_count == 0:
				announce_winner("Survivor (" + player.name + ")")
				return true
	
	return false

func announce_winner(faction):
	controller.town_meeting_log.append({
		"type": "announcement",
		"text": "GAME OVER - " + faction + " has won the game!",
		"day": controller.current_day,
		"phase": "game_over",
		"timestamp": OS.get_unix_time()
	})
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			"GAME OVER - " + faction + " has won the game!", 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	# List all players and their roles
	var role_reveal = "PLAYER ROLES:\n"
	for player_name in controller.players:
		role_reveal += player_name + ": " + controller.players[player_name].role + " (" + ("ALIVE" if player_name in controller.living_players else "DEAD") + ")\n"
	
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", role_reveal, controller.word_comment_system.CommentType.INFORMATION)
	
	controller.emit_signal("game_over", faction)
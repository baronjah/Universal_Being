extends Node

# Word Salem Roles System
# Handles role assignment, abilities and role-specific functionality
# Terminal 1: Divine Word Genesis

# Reference to main controller
var controller = null

func _ready():
	pass

# ROLE ASSIGNMENT FUNCTIONS
func assign_roles(player_names):
	if !controller:
		return
		
	# Get role counts based on number of players
	var role_counts = controller.role_distribution[player_names.size()]
	var available_roles = []
	
	# Add town roles
	for i in range(role_counts["town"]):
		available_roles.append({
			"name": get_town_role(i),
			"type": controller.RoleType.TOWN
		})
	
	# Add mafia roles
	for i in range(role_counts["mafia"]):
		available_roles.append({
			"name": get_mafia_role(i),
			"type": controller.RoleType.MAFIA
		})
		
	# Add neutral roles
	for i in range(role_counts["neutral"]):
		available_roles.append({
			"name": get_neutral_role(i),
			"type": controller.RoleType.NEUTRAL
		})
	
	# Add special divine role if 12+ players
	if player_names.size() >= 12:
		available_roles.append({
			"name": "Divine Judge",
			"type": controller.RoleType.DIVINE
		})
	
	# Shuffle roles
	available_roles.shuffle()
	
	# Assign roles to players
	for i in range(player_names.size()):
		var player_name = player_names[i]
		var role = available_roles[i]
		
		controller.players[player_name] = {
			"name": player_name,
			"role": role["name"],
			"role_type": role["type"],
			"alive": true,
			"word_crimes": [],
			"word_power": 0,
			"lynched": false,
			"silenced": false,
			"protected": false,
			"revealed": false,
			"abilities": initialize_abilities(role["name"]),
			"investigation_results": [],
			"votes_against": 0
		}
		
		controller.living_players.append(player_name)
	
	# Notify players of their roles
	for player_name in controller.players:
		notify_role_assignment(player_name, controller.players[player_name].role, controller.players[player_name].role_type)

func notify_role_assignment(player_name, role, role_type):
	# Add a private message to the player about their role
	var role_description = get_role_description(role)
	var alignment = ""
	
	match role_type:
		controller.RoleType.TOWN:
			alignment = "Divine Word Alignment"
		controller.RoleType.MAFIA:
			alignment = "Corrupted Word Alignment"
		controller.RoleType.NEUTRAL:
			alignment = "Neutral Alignment"
		controller.RoleType.DIVINE:
			alignment = "Divine Alignment"
	
	# Inform other mafia members if player is mafia
	if role_type == controller.RoleType.MAFIA:
		var mafia_teammates = []
		for name in controller.players:
			if controller.players[name].role_type == controller.RoleType.MAFIA and name != player_name:
				mafia_teammates.append(name + " (" + controller.players[name].role + ")")
				
		# Send mafia team information to the player
		if controller.word_comment_system and mafia_teammates.size() > 0:
			controller.word_comment_system.add_comment("private_" + player_name,
				"Your Mafia teammates are: " + PoolStringArray(mafia_teammates).join(", "),
				controller.word_comment_system.CommentType.INFORMATION)
	
	# Send role information to the player
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("private_" + player_name,
			"You are a " + role + " (" + alignment + ")\n" + role_description,
			controller.word_comment_system.CommentType.INFORMATION)
	
	# Log the role assignment to the terminal
	print("ROLE ASSIGNMENT: " + player_name + " is now " + role + " (" + alignment + ")")

# ROLE DEFINITIONS
func get_town_role(index):
	var town_roles = [
		"Wordsmith",      # Can craft powerful defensive words
		"Word Sheriff",   # Can investigate word crimes
		"Etymologist",    # Can reveal a player's true role
		"Word Doctor",    # Can protect a player from word attacks
		"Vigilante",      # Can attack suspected word criminals
		"Word Mayor",     # Vote counts as 3 votes
		"Veteran",        # Can go on alert and attack all visitors
		"Word Escort",    # Can block a player's night action
		"Word Lookout"    # Can see who visits a player at night
	]
	return town_roles[index % town_roles.size()]

func get_mafia_role(index):
	var mafia_roles = [
		"Mafia Godfather",   # Appears innocent to investigations
		"Mafia Silencer",    # Can prevent a player from using words
		"Mafia Consigliere", # Can learn exact roles
		"Mafia Blackmailer"  # Can prevent a player from voting
	]
	return mafia_roles[index % mafia_roles.size()]

func get_neutral_role(index):
	var neutral_roles = [
		"Jester",        # Wins if lynched
		"Serial Killer", # Kills one person each night, wins alone
		"Word Witch",    # Can control other players' actions
		"Amnesiac",      # Can remember a dead player's role
		"Word Survivor"  # Wins if alive at the end
	]
	return neutral_roles[index % neutral_roles.size()]

func get_role_description(role):
	match role:
		"Wordsmith":
			return "You can craft powerful defensive words. Your words have greater power than others."
		"Word Sheriff":
			return "You can investigate players to determine if they are Divine, Corrupted, or Neutral."
		"Etymologist": 
			return "You can reveal a player's exact role once per game."
		"Word Doctor":
			return "You can protect players from night attacks, including Word Crime elimination."
		"Vigilante":
			return "You can eliminate suspected corrupted players. You have 3 charges."
		"Word Mayor":
			return "Once revealed, your vote counts as 3 votes, but you cannot be protected."
		"Veteran":
			return "You can go on alert, eliminating anyone who targets you that night. You have 3 alerts."
		"Word Escort":
			return "You can prevent a player from using abilities for a night."
		"Word Lookout":
			return "You can watch a player and see who visits them at night."
		"Mafia Godfather":
			return "You lead the mafia. You appear as Divine to investigators."
		"Mafia Silencer":
			return "You can prevent a player from speaking during the day phase."
		"Mafia Consigliere":
			return "You can learn a player's exact role through investigation."
		"Mafia Blackmailer":
			return "You can prevent a player from voting during the day."
		"Jester":
			return "Your goal is to get yourself linguistically eliminated by the town. If you succeed, you win!"
		"Serial Killer":
			return "You are a lone killer who aims to eliminate everyone else. You kill one player each night."
		"Word Witch":
			return "You can control another player each night, forcing them to use their ability on a target of your choice."
		"Amnesiac":
			return "You have forgotten your role. You can remember a dead player's role once."
		"Word Survivor":
			return "Your goal is to survive until the end. You have 4 bulletproof vests to protect yourself."
		"Divine Judge":
			return "You represent divine judgment. Once per game, you can instantly judge a cosmic word crime."
		_:
			return "Role description not available."

# ABILITY MANAGEMENT
func initialize_abilities(role_name):
	var abilities = {}
	
	match role_name:
		"Wordsmith":
			abilities["craft_defensive_word"] = {"uses": -1, "description": "Create a defensive word with enhanced power"}
		"Word Sheriff":
			abilities["investigate"] = {"uses": -1, "description": "Investigate a player to determine their alignment"}
		"Etymologist":
			abilities["reveal_role"] = {"uses": 1, "description": "Reveal a player's exact role"}
		"Word Doctor":
			abilities["protect"] = {"uses": -1, "description": "Protect a player from night attacks"}
		"Vigilante":
			abilities["kill"] = {"uses": 3, "description": "Attack a suspect player at night"}
		"Word Mayor":
			abilities["reveal"] = {"uses": 1, "description": "Reveal yourself as Mayor, tripling your vote power"}
		"Veteran":
			abilities["alert"] = {"uses": 3, "description": "Go on alert, killing anyone who targets you"}
		"Word Escort":
			abilities["block"] = {"uses": -1, "description": "Block a player's night actions"}
		"Word Lookout":
			abilities["watch"] = {"uses": -1, "description": "See who visits a player at night"}
		"Mafia Godfather":
			abilities["order_kill"] = {"uses": -1, "description": "Order a Mafia kill"}
		"Mafia Silencer":
			abilities["silence"] = {"uses": -1, "description": "Prevent a player from speaking during the day"}
		"Mafia Consigliere":
			abilities["investigate_exact"] = {"uses": -1, "description": "Learn a player's exact role"}
		"Mafia Blackmailer":
			abilities["blackmail"] = {"uses": -1, "description": "Prevent a player from voting"}
		"Jester":
			abilities["confuse"] = {"uses": -1, "description": "Act suspicious to get lynched"}
		"Serial Killer":
			abilities["stab"] = {"uses": -1, "description": "Kill a player each night"}
		"Word Witch":
			abilities["control"] = {"uses": -1, "description": "Control another player's actions"}
		"Amnesiac":
			abilities["remember"] = {"uses": 1, "description": "Remember and become a dead player's role"}
		"Word Survivor":
			abilities["vest"] = {"uses": 4, "description": "Put on a bulletproof vest for the night"}
		"Divine Judge":
			abilities["divine_judgment"] = {"uses": 1, "description": "Pass instant judgment on a cosmic word crime"}
	
	return abilities

# WORD POWER PROCESSING
func process_word_powers():
	if !controller:
		return
		
	# Apply word power effects based on roles
	for player_name in controller.players.keys():
		var player = controller.players[player_name]
		if not player_name in controller.living_players:
			continue
			
		# Get total power from word crimes in the last cycle
		var recent_word_power = 0
		for crime in player.word_crimes:
			if controller.current_turn - crime.turn <= 12:
				recent_word_power += crime.power
		
		# Apply role-specific effects based on word power
		match player.role:
			"Wordsmith":
				# Wordsmith gains protection with high word power
				if recent_word_power >= controller.power_thresholds.major:
					apply_protection(player_name, 1)  # Protect for 1 night
					
					if controller.word_comment_system:
						controller.word_comment_system.add_comment("private_" + player_name, 
							"Your words have granted you protection for the next night!", 
							controller.word_comment_system.CommentType.INFORMATION)
			"Mafia Silencer":
				# Silencer can block more players with higher word power
				if recent_word_power >= controller.power_thresholds.moderate:
					player.silence_power = recent_word_power / controller.power_thresholds.moderate
					
					if controller.word_comment_system:
						controller.word_comment_system.add_comment("private_" + player_name, 
							"Your silencing power has increased to " + str(player.silence_power) + "!", 
							controller.word_comment_system.CommentType.INFORMATION)
			"Divine Judge":
				# Divine Judge can instant-kill with cosmic word power
				if recent_word_power >= controller.power_thresholds.cosmic:
					player.divine_judgment = true
					
					if controller.word_comment_system:
						controller.word_comment_system.add_comment("private_" + player_name, 
							"You have attained divine judgment capability! You can now instantly judge cosmic word crimes.", 
							controller.word_comment_system.CommentType.INFORMATION)

func apply_protection(player_name, duration):
	if !controller:
		return
		
	if controller.players.has(player_name):
		if not controller.players[player_name].has("protection"):
			controller.players[player_name].protection = 0
		controller.players[player_name].protection += duration

# SPECIAL ROLE ABILITIES
func process_amnesiac_remember(player_name, target_name):
	if !controller:
		return false
		
	# Check if player is amnesiac
	if controller.players[player_name].role != "Amnesiac":
		return false
		
	# Check if target is dead
	if not target_name in controller.dead_players:
		return false
		
	# Get role information
	var target_role = controller.players[target_name].role
	var target_role_type = controller.players[target_name].role_type
	
	# Change the player's role
	controller.players[player_name].role = target_role
	controller.players[player_name].role_type = target_role_type
	controller.players[player_name].abilities = initialize_abilities(target_role)
	
	# Announce the change
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			player_name + " has remembered they were a " + target_role + "!", 
			controller.word_comment_system.CommentType.WARNING)
		
		controller.word_comment_system.add_comment("private_" + player_name, 
			"You have remembered that you are a " + target_role + "!", 
			controller.word_comment_system.CommentType.INFORMATION)
	
	return true

func process_mayor_reveal(player_name):
	if !controller:
		return false
		
	# Check if player is mayor
	if controller.players[player_name].role != "Word Mayor":
		return false
		
	# Check if already revealed
	if controller.players[player_name].revealed:
		return false
		
	# Reveal the mayor
	controller.players[player_name].revealed = true
	controller.revealed_players.append(player_name)
	
	# Announce the reveal
	if controller.word_comment_system:
		controller.word_comment_system.add_comment("town_meeting", 
			player_name + " has revealed themselves as the Word Mayor! Their vote now counts as 3 votes.", 
			controller.word_comment_system.CommentType.ANNOUNCEMENT)
	
	return true

func get_mafia_members():
	if !controller:
		return []
		
	var mafia_players = []
	
	for player_name in controller.players:
		if controller.players[player_name].role_type == controller.RoleType.MAFIA and player_name in controller.living_players:
			mafia_players.append(player_name)
	
	return mafia_players

func get_town_members():
	if !controller:
		return []
		
	var town_players = []
	
	for player_name in controller.players:
		if controller.players[player_name].role_type == controller.RoleType.TOWN and player_name in controller.living_players:
			town_players.append(player_name)
	
	return town_players

func get_neutral_members():
	if !controller:
		return []
		
	var neutral_players = []
	
	for player_name in controller.players:
		if controller.players[player_name].role_type == controller.RoleType.NEUTRAL and player_name in controller.living_players:
			neutral_players.append(player_name)
	
	return neutral_players
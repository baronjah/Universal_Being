extends Control

# Word Salem UI
# Provides user interface for the Town of Salem linguistic judgment game
# Terminal 1: Divine Word Genesis

class_name WordSalemUI

# UI Components
var player_list_container
var phase_label
var turn_counter
var day_counter
var message_log
var vote_buttons = {}
var role_info_panel
var word_crimes_panel
var evidence_panel

# Game references
var word_salem_controller = null
var word_crimes_analysis = null
var divine_word_processor = null
var turn_system = null

# Current player info
var player_name = ""
var player_role = ""
var player_alignment = ""
var role_description = ""
var role_abilities = []

# Timer and animation
var timer_bar
var dimension_indicator
var nine_second_timer = 0.0
var dimension_colors = [
	Color(1, 0, 0),      # 1D - Red
	Color(1, 0.5, 0),    # 2D - Orange
	Color(1, 1, 0),      # 3D - Yellow
	Color(0, 1, 0),      # 4D - Green
	Color(0, 1, 1),      # 5D - Cyan
	Color(0, 0, 1),      # 6D - Blue
	Color(0.5, 0, 1),    # 7D - Purple
	Color(1, 0, 1),      # 8D - Magenta
	Color(1, 0.5, 0.5),  # 9D - Pink (significant)
	Color(0.5, 1, 0.5),  # 10D - Light Green
	Color(0.5, 0.5, 1),  # 11D - Light Blue
	Color(1, 1, 1)       # 12D - White
]

func _ready():
	initialize_ui()
	connect_signals()

func initialize_ui():
	# Set up the overall layout
	set_anchors_preset(Control.PRESET_WIDE)
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_WIDE)
	add_child(main_container)
	
	# Create top info bar
	var info_bar = HBoxContainer.new()
	main_container.add_child(info_bar)
	
	# Phase label
	phase_label = Label.new()
	phase_label.text = "LOBBY"
	phase_label.size_flags_horizontal = SIZE_EXPAND_FILL
	info_bar.add_child(phase_label)
	
	# Day counter
	day_counter = Label.new()
	day_counter.text = "Day: 1"
	day_counter.size_flags_horizontal = SIZE_EXPAND_FILL
	info_bar.add_child(day_counter)
	
	# Turn counter
	turn_counter = Label.new()
	turn_counter.text = "Turn: 0"
	turn_counter.size_flags_horizontal = SIZE_EXPAND_FILL
	info_bar.add_child(turn_counter)
	
	# Dimension indicator
	dimension_indicator = Label.new()
	dimension_indicator.text = "Dimension: 1D"
	dimension_indicator.size_flags_horizontal = SIZE_EXPAND_FILL
	info_bar.add_child(dimension_indicator)
	
	# Timer bar
	timer_bar = ProgressBar.new()
	timer_bar.max_value = 9.0  # The sacred 9-second interval
	timer_bar.min_value = 0.0
	timer_bar.value = 9.0
	main_container.add_child(timer_bar)
	
	# Main content area
	var content_container = HBoxContainer.new()
	content_container.size_flags_vertical = SIZE_EXPAND_FILL
	main_container.add_child(content_container)
	
	# Left panel - Player list
	var left_panel = VBoxContainer.new()
	left_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 0.3
	content_container.add_child(left_panel)
	
	var player_list_label = Label.new()
	player_list_label.text = "PLAYERS"
	left_panel.add_child(player_list_label)
	
	player_list_container = VBoxContainer.new()
	player_list_container.size_flags_vertical = SIZE_EXPAND_FILL
	left_panel.add_child(player_list_container)
	
	# Center panel - Game log and actions
	var center_panel = VBoxContainer.new()
	center_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	center_panel.size_flags_stretch_ratio = 0.5
	content_container.add_child(center_panel)
	
	var log_label = Label.new()
	log_label.text = "MESSAGE LOG"
	center_panel.add_child(log_label)
	
	message_log = RichTextLabel.new()
	message_log.bbcode_enabled = true
	message_log.size_flags_vertical = SIZE_EXPAND_FILL
	center_panel.add_child(message_log)
	
	var action_container = HBoxContainer.new()
	center_panel.add_child(action_container)
	
	var whisper_button = Button.new()
	whisper_button.text = "Whisper"
	whisper_button.connect("pressed", self, "_on_whisper_button_pressed")
	action_container.add_child(whisper_button)
	
	var action_button = Button.new()
	action_button.text = "Action"
	action_button.connect("pressed", self, "_on_action_button_pressed")
	action_container.add_child(action_button)
	
	# Right panel - Role info and evidence
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 0.4
	content_container.add_child(right_panel)
	
	var role_label = Label.new()
	role_label.text = "YOUR ROLE"
	right_panel.add_child(role_label)
	
	role_info_panel = RichTextLabel.new()
	role_info_panel.bbcode_enabled = true
	role_info_panel.size_flags_vertical = SIZE_EXPAND_FILL
	role_info_panel.size_flags_stretch_ratio = 0.4
	right_panel.add_child(role_info_panel)
	
	var crimes_label = Label.new()
	crimes_label.text = "WORD CRIMES"
	right_panel.add_child(crimes_label)
	
	word_crimes_panel = RichTextLabel.new()
	word_crimes_panel.bbcode_enabled = true
	word_crimes_panel.size_flags_vertical = SIZE_EXPAND_FILL
	word_crimes_panel.size_flags_stretch_ratio = 0.3
	right_panel.add_child(word_crimes_panel)
	
	var evidence_label = Label.new()
	evidence_label.text = "EVIDENCE"
	right_panel.add_child(evidence_label)
	
	evidence_panel = RichTextLabel.new()
	evidence_panel.bbcode_enabled = true
	evidence_panel.size_flags_vertical = SIZE_EXPAND_FILL
	evidence_panel.size_flags_stretch_ratio = 0.3
	right_panel.add_child(evidence_panel)

func connect_signals():
	# Connect to game systems
	word_salem_controller = get_node("/root/WordSalemGameController")
	word_crimes_analysis = get_node("/root/WordCrimesAnalysis")
	divine_word_processor = get_node("/root/DivineWordProcessor")
	turn_system = get_node("/root/TurnSystem")
	
	if word_salem_controller:
		word_salem_controller.connect("day_started", self, "_on_day_started")
		word_salem_controller.connect("night_started", self, "_on_night_started")
		word_salem_controller.connect("player_died", self, "_on_player_died")
		word_salem_controller.connect("game_over", self, "_on_game_over")
		word_salem_controller.connect("word_crime_detected", self, "_on_word_crime_detected")
	
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if word_crimes_analysis:
		word_crimes_analysis.connect("dangerous_pattern_detected", self, "_on_dangerous_pattern_detected")
		word_crimes_analysis.connect("cosmic_power_threshold_reached", self, "_on_cosmic_power_threshold_reached")
		word_crimes_analysis.connect("player_power_anomaly", self, "_on_player_power_anomaly")

func _process(delta):
	# Handle the 9-second timer
	if word_salem_controller and word_salem_controller.current_state != word_salem_controller.GameState.LOBBY:
		nine_second_timer -= delta
		
		if nine_second_timer <= 0:
			nine_second_timer = 9.0  # Reset to 9 seconds
		
		timer_bar.value = nine_second_timer
		
		# Apply color based on urgency
		if nine_second_timer < 3.0:
			timer_bar.modulate = Color(1, 0, 0)  # Red
		elif nine_second_timer < 6.0:
			timer_bar.modulate = Color(1, 1, 0)  # Yellow
		else:
			timer_bar.modulate = Color(0, 1, 0)  # Green

func set_player_role(role_name, alignment):
	player_role = role_name
	player_alignment = alignment
	
	# Set role description based on role name
	match role_name:
		"Wordsmith":
			role_description = "You are a master of words who can create powerful defensive words to protect others."
			role_abilities = [
				"Day: Analyze linguistic patterns in a player's speech",
				"Night: Use specially crafted words to protect a player"
			]
		"Word Sheriff":
			role_description = "You investigate linguistic crimes to identify wrongdoers."
			role_abilities = [
				"Day: Publicly question a player",
				"Night: Investigate a player to find out if they have committed word crimes"
			]
		"Etymologist":
			role_description = "You can trace the origin of words to reveal a player's true role."
			role_abilities = [
				"Day: Analyze a player's vocabulary",
				"Night: Reveal a player's true role"
			]
		"Mafia Godfather":
			role_description = "You lead the Mafia and appear innocent to investigations."
			role_abilities = [
				"Day: Frame other players for word crimes",
				"Night: Choose a player for the Mafia to kill"
			]
		"Mafia Silencer":
			role_description = "You prevent others from communicating effectively."
			role_abilities = [
				"Day: Create confusion in discussions",
				"Night: Silence a player (reduces their word power)"
			]
		"Jester":
			role_description = "You win if you are convicted of word crimes you didn't commit."
			role_abilities = [
				"Day: Act suspicious and contradict yourself",
				"Passive: If executed, you win the game"
			]
		"Serial Killer":
			role_description = "You kill one person each night and win alone."
			role_abilities = [
				"Day: Blend in with Town members",
				"Night: Kill a player using powerful word combinations"
			]
		_:
			role_description = "A mysterious role with unique linguistic abilities."
			role_abilities = [
				"Day: Participate in discussions and voting",
				"Night: Use your special abilities"
			]
	
	update_role_panel()

func update_role_panel():
	role_info_panel.bbcode_text = ""
	role_info_panel.bbcode_text += "[b]" + player_role + "[/b]\n"
	role_info_panel.bbcode_text += "[i]Alignment: " + player_alignment + "[/i]\n\n"
	role_info_panel.bbcode_text += role_description + "\n\n"
	role_info_panel.bbcode_text += "[u]Abilities:[/u]\n"
	
	for ability in role_abilities:
		role_info_panel.bbcode_text += "• " + ability + "\n"

func update_player_list(players_data):
	# Clear existing list
	for child in player_list_container.get_children():
		child.queue_free()
	
	vote_buttons = {}
	
	# Add players to the list
	for player_name in players_data.keys():
		var player_data = players_data[player_name]
		
		var player_container = HBoxContainer.new()
		player_list_container.add_child(player_container)
		
		var status_indicator = ColorRect.new()
		status_indicator.rect_min_size = Vector2(10, 10)
		
		if player_data.alive:
			status_indicator.color = Color(0, 1, 0)  # Green for alive
		else:
			status_indicator.color = Color(1, 0, 0)  # Red for dead
		
		player_container.add_child(status_indicator)
		
		var name_label = Label.new()
		name_label.text = player_name
		name_label.size_flags_horizontal = SIZE_EXPAND_FILL
		player_container.add_child(name_label)
		
		# Add vote button if in voting phase and player is alive
		if word_salem_controller.current_state == word_salem_controller.GameState.VOTING and player_data.alive:
			var vote_button = Button.new()
			vote_button.text = "Vote"
			vote_button.connect("pressed", self, "_on_vote_button_pressed", [player_name])
			player_container.add_child(vote_button)
			vote_buttons[player_name] = vote_button
		
		# Add detailed player information if dead or game is over
		if not player_data.alive or word_salem_controller.current_state == word_salem_controller.GameState.GAME_OVER:
			var role_label = Label.new()
			role_label.text = "(" + player_data.role + ")"
			player_container.add_child(role_label)

func update_word_crimes_panel():
	if not word_crimes_analysis:
		return
	
	word_crimes_panel.bbcode_text = ""
	
	# Get player's word crimes
	var player_crimes = word_crimes_analysis.get_player_crime_summary(player_name)
	
	word_crimes_panel.bbcode_text += "[b]Your Word Crimes: " + str(player_crimes.total_crimes) + "[/b]\n"
	
	if player_crimes.total_crimes > 0:
		word_crimes_panel.bbcode_text += "[u]Types:[/u]\n"
		
		for crime_type in player_crimes.crime_types.keys():
			word_crimes_panel.bbcode_text += "• " + crime_type + ": " + str(player_crimes.crime_types[crime_type]) + "\n"
		
		if player_crimes.highest_power_crime:
			word_crimes_panel.bbcode_text += "\n[color=red]Highest Power: " + str(player_crimes.highest_power) + "[/color]\n"
			
			if player_crimes.highest_power_crime.has("word"):
				word_crimes_panel.bbcode_text += "Word: " + player_crimes.highest_power_crime.word + "\n"
			elif player_crimes.highest_power_crime.has("combination"):
				word_crimes_panel.bbcode_text += "Combination: " + player_crimes.highest_power_crime.combination + "\n"
			
			# Add dimension information if available
			if player_crimes.highest_power_crime.has("dimension"):
				word_crimes_panel.bbcode_text += "Dimension: " + str(player_crimes.highest_power_crime.dimension) + "D\n"
	else:
		word_crimes_panel.bbcode_text += "[i]No word crimes recorded yet.[/i]\n"
	
	# Add warning based on crime count
	if player_crimes.total_crimes >= 10:
		word_crimes_panel.bbcode_text += "\n[color=red][b]WARNING: High crime count may make you a target![/b][/color]"
	elif player_crimes.total_crimes >= 5:
		word_crimes_panel.bbcode_text += "\n[color=yellow]CAUTION: Your crime count is moderate.[/color]"

func update_evidence_panel(accused_player=null):
	evidence_panel.bbcode_text = ""
	
	if not word_crimes_analysis or not accused_player:
		evidence_panel.bbcode_text = "[i]No current trial in progress.[/i]"
		return
	
	var evidence = word_crimes_analysis.get_evidence_for_trial(accused_player)
	
	evidence_panel.bbcode_text += "[b]Evidence Against: " + accused_player + "[/b]\n"
	evidence_panel.bbcode_text += "Total Crimes: " + str(evidence.summary.total_crimes) + "\n\n"
	
	if evidence.dangerous_patterns.size() > 0:
		evidence_panel.bbcode_text += "[u]Dangerous Patterns Found:[/u]\n"
		
		for i in range(min(3, evidence.dangerous_patterns.size())):
			var pattern = evidence.dangerous_patterns[i]
			evidence_panel.bbcode_text += "• \"" + pattern.word + "\" matched pattern [color=red]" + pattern.pattern + "[/color]\n"
			evidence_panel.bbcode_text += "  Power: " + str(pattern.power) + ", Dimension: " + str(pattern.dimension) + "D\n"
	
	if evidence.dimension_influence.size() > 0:
		evidence_panel.bbcode_text += "\n[u]Dimension Influence:[/u]\n"
		
		# Find the dimension with highest average power
		var highest_dim = evidence.dimension_influence[0]
		for dim in evidence.dimension_influence:
			if dim.avg_power > highest_dim.avg_power:
				highest_dim = dim
		
		evidence_panel.bbcode_text += "• Most influential: [color=yellow]" + str(highest_dim.dimension) + "D[/color]\n"
		evidence_panel.bbcode_text += "  Avg Power: " + str(highest_dim.avg_power) + ", Words: " + str(highest_dim.word_count) + "\n"
	
	# Show the most recent 3 words used
	if evidence.word_history.size() > 0:
		evidence_panel.bbcode_text += "\n[u]Recent Words:[/u]\n"
		
		# Sort by turn, descending
		evidence.word_history.sort_custom(self, "sort_by_turn_descending")
		
		for i in range(min(3, evidence.word_history.size())):
			var word_entry = evidence.word_history[i]
			evidence_panel.bbcode_text += "• \"" + word_entry.word + "\" (Power: " + str(word_entry.power) + ")\n"

func sort_by_turn_descending(a, b):
	return a.turn > b.turn

func add_message(text, color=Color(1, 1, 1)):
	var time_str = OS.get_time()
	var timestamp = "%02d:%02d:%02d" % [time_str.hour, time_str.minute, time_str.second]
	
	message_log.bbcode_text += "[color=#888888][" + timestamp + "][/color] "
	message_log.bbcode_text += "[color=#" + color.to_html(false) + "]" + text + "[/color]\n"
	
	# Scroll to bottom
	message_log.scroll_to_line(message_log.get_line_count())

func start_game(player_list):
	player_name = player_list[0]  # Current player is first in list
	
	if word_salem_controller.start_game(player_list):
		add_message("Game started with " + str(player_list.size()) + " players!", Color(0, 1, 0))
		
		# Set player's role
		var role_data = word_salem_controller.players[player_name]
		set_player_role(role_data.role, get_alignment_name(role_data.role_type))
		
		# Update player list
		update_player_list(word_salem_controller.players)
	else:
		add_message("Failed to start game. Need " + str(word_salem_controller.min_players) + "-" + 
			str(word_salem_controller.max_players) + " players.", Color(1, 0, 0))

func get_alignment_name(role_type):
	match role_type:
		word_salem_controller.RoleType.TOWN:
			return "Town"
		word_salem_controller.RoleType.MAFIA:
			return "Mafia"
		word_salem_controller.RoleType.NEUTRAL:
			return "Neutral"
		word_salem_controller.RoleType.DIVINE:
			return "Divine"
		_:
			return "Unknown"

func _on_day_started(day_number):
	phase_label.text = "DAY"
	day_counter.text = "Day: " + str(day_number)
	nine_second_timer = 9.0
	
	add_message("Day " + str(day_number) + " has begun. Discuss and find the criminals!", Color(1, 1, 0))
	update_player_list(word_salem_controller.players)

func _on_night_started(night_number):
	phase_label.text = "NIGHT"
	nine_second_timer = 9.0 * 3  # Night is 3x longer
	
	add_message("Night has fallen. Perform your night actions.", Color(0, 0, 1))
	update_player_list(word_salem_controller.players)
	
	# Show night action UI based on role
	show_night_action_ui()

func _on_player_died(player_name, role, death_cause):
	add_message(player_name + " has died. They were " + role + ". Cause: " + death_cause, Color(1, 0, 0))
	update_player_list(word_salem_controller.players)
	
	if player_name == self.player_name:
		add_message("You have died! You can still observe but cannot participate.", Color(1, 0, 0))

func _on_game_over(winning_faction):
	phase_label.text = "GAME OVER"
	
	add_message("Game Over! " + winning_faction + " wins!", Color(1, 1, 0))
	update_player_list(word_salem_controller.players)
	
	# Show final role list
	add_message("\nFinal Role List:", Color(1, 1, 1))
	
	for player in word_salem_controller.players.keys():
		var role_info = word_salem_controller.players[player]
		add_message(player + " was " + role_info.role, Color(0.8, 0.8, 0.8))

func _on_turn_completed(turn_number):
	turn_counter.text = "Turn: " + str(turn_number)
	
	# Every 12 turns, update crime panel to reflect new data
	if turn_number % 12 == 0:
		update_word_crimes_panel()

func _on_dimension_changed(new_dimension, old_dimension):
	dimension_indicator.text = "Dimension: " + str(new_dimension) + "D"
	
	# Update dimension indicator color
	var color_index = new_dimension - 1
	if color_index >= 0 and color_index < dimension_colors.size():
		dimension_indicator.modulate = dimension_colors[color_index]
	
	# Add message if significant dimension
	if new_dimension == 9:
		add_message("Entering 9D - The sacred dimension of judgment!", Color(1, 0.5, 0.5))
	elif new_dimension == 12:
		add_message("Entering 12D - The dimension of divine revelation!", Color(1, 1, 1))

func _on_word_processed(word, power, source_player):
	# Only show words from other players during the game
	if word_salem_controller.current_state != word_salem_controller.GameState.LOBBY and source_player != player_name:
		add_message(source_player + " used word \"" + word + "\" (Power: " + str(power) + ")")

func _on_word_crime_detected(criminal, crime_type, word_power):
	var color_map = {
		"minor": Color(0.5, 0.5, 1),      # Light blue
		"moderate": Color(1, 1, 0),       # Yellow
		"major": Color(1, 0.5, 0),        # Orange
		"cosmic": Color(1, 0, 0)          # Red
	}
	
	var color = Color(1, 1, 1)
	if color_map.has(crime_type):
		color = color_map[crime_type]
	
	add_message("WORD CRIME: " + criminal + " committed a " + crime_type + 
		" word crime! Power: " + str(word_power), color)
	
	update_word_crimes_panel()

func _on_dangerous_pattern_detected(pattern, word, power):
	add_message("DANGER: Word \"" + word + "\" matches dangerous pattern \"" + 
		pattern + "\"!", Color(1, 0, 0))

func _on_cosmic_power_threshold_reached(word, power):
	add_message("COSMIC POWER: Word \"" + word + "\" reached cosmic power level " + 
		str(power) + "!", Color(1, 0, 1))

func _on_player_power_anomaly(player_name, current_power, average_power):
	add_message("ANOMALY: " + player_name + " power spike " + str(current_power) + 
		" (avg: " + str(average_power) + ")", Color(1, 0.5, 0))

func _on_vote_button_pressed(target_player):
	if word_salem_controller.vote(player_name, target_player):
		add_message("You voted for " + target_player)
		
		# Disable all vote buttons after voting
		for button in vote_buttons.values():
			button.disabled = true

func _on_whisper_button_pressed():
	# TODO: Implement whisper functionality
	add_message("Whisper functionality not yet implemented", Color(0.5, 0.5, 0.5))

func _on_action_button_pressed():
	# Show night action UI based on role
	show_night_action_ui()

func show_night_action_ui():
	if word_salem_controller.current_state != word_salem_controller.GameState.NIGHT:
		add_message("You can only use special actions at night", Color(0.5, 0.5, 0.5))
		return
	
	# TODO: Implement proper night action UI
	# For now, just show a placeholder message
	match player_role:
		"Wordsmith":
			add_message("Select a player to protect with your words", Color(0, 0.7, 1))
		"Word Sheriff":
			add_message("Select a player to investigate for word crimes", Color(0, 0.7, 1))
		"Mafia Godfather":
			add_message("Select a player for the Mafia to eliminate", Color(0, 0.7, 1))
		"Serial Killer":
			add_message("Select a player to kill", Color(0, 0.7, 1))
		_:
			add_message("Use your " + player_role + " ability", Color(0, 0.7, 1))
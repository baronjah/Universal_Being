extends Control

# Divine Word UI
# Main user interface for the Divine Word Game
# Terminal 1: Divine Word Genesis

class_name DivineWordUI

# UI Components
var word_input
var submit_button
var score_label
var level_label
var dimension_label
var turn_label
var message_log
var targets_panel
var challenge_panel
var dimension_indicator

# Game references
var divine_word_game = null
var turn_system = null
var divine_word_processor = null

# Visual elements
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

# Nine-second timer
var nine_second_timer = 9.0
var timer_bar

func _ready():
	initialize_ui()
	connect_systems()

func initialize_ui():
	# Set up the main layout
	set_anchors_preset(Control.PRESET_WIDE)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_WIDE)
	add_child(main_container)
	
	# Header with game info
	var header = HBoxContainer.new()
	main_container.add_child(header)
	
	var title_label = Label.new()
	title_label.text = "DIVINE WORD GENESIS"
	title_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title_label)
	
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(score_label)
	
	level_label = Label.new()
	level_label.text = "Level: 1"
	level_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(level_label)
	
	turn_label = Label.new()
	turn_label.text = "Turn: 0"
	turn_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(turn_label)
	
	dimension_label = Label.new()
	dimension_label.text = "Dimension: 1D"
	dimension_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(dimension_label)
	
	# Timer bar for the 9-second interval
	timer_bar = ProgressBar.new()
	timer_bar.max_value = 9.0
	timer_bar.min_value = 0.0
	timer_bar.value = 9.0
	timer_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	main_container.add_child(timer_bar)
	
	# Main content area
	var content_container = HBoxContainer.new()
	content_container.size_flags_vertical = SIZE_EXPAND_FILL
	main_container.add_child(content_container)
	
	# Left panel - Dimension visualization
	var left_panel = VBoxContainer.new()
	left_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 0.3
	content_container.add_child(left_panel)
	
	var dimension_label = Label.new()
	dimension_label.text = "DIMENSIONS"
	left_panel.add_child(dimension_label)
	
	dimension_indicator = ColorRect.new()
	dimension_indicator.color = dimension_colors[0]
	dimension_indicator.size_flags_vertical = SIZE_EXPAND_FILL
	left_panel.add_child(dimension_indicator)
	
	var dimension_grid = GridContainer.new()
	dimension_grid.columns = 4
	left_panel.add_child(dimension_grid)
	
	for i in range(12):
		var dim_button = Button.new()
		dim_button.text = str(i + 1) + "D"
		dim_button.set_h_size_flags(SIZE_EXPAND_FILL)
		dim_button.connect("pressed", self, "_on_dimension_button_pressed", [i + 1])
		dimension_grid.add_child(dim_button)
	
	# Center panel - Message log and word input
	var center_panel = VBoxContainer.new()
	center_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	center_panel.size_flags_stretch_ratio = 0.4
	content_container.add_child(center_panel)
	
	var log_label = Label.new()
	log_label.text = "MESSAGE LOG"
	center_panel.add_child(log_label)
	
	message_log = RichTextLabel.new()
	message_log.bbcode_enabled = true
	message_log.size_flags_vertical = SIZE_EXPAND_FILL
	center_panel.add_child(message_log)
	
	var input_container = HBoxContainer.new()
	center_panel.add_child(input_container)
	
	word_input = LineEdit.new()
	word_input.placeholder_text = "Enter a word..."
	word_input.size_flags_horizontal = SIZE_EXPAND_FILL
	word_input.connect("text_entered", self, "_on_word_submitted")
	input_container.add_child(word_input)
	
	submit_button = Button.new()
	submit_button.text = "Submit"
	submit_button.connect("pressed", self, "_on_submit_pressed")
	input_container.add_child(submit_button)
	
	# Right panel - Challenge and targets
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 0.3
	content_container.add_child(right_panel)
	
	var challenge_label = Label.new()
	challenge_label.text = "DIMENSION CHALLENGE"
	right_panel.add_child(challenge_label)
	
	challenge_panel = RichTextLabel.new()
	challenge_panel.bbcode_enabled = true
	challenge_panel.size_flags_vertical = SIZE_EXPAND_FILL
	challenge_panel.size_flags_stretch_ratio = 0.4
	right_panel.add_child(challenge_panel)
	
	var targets_label = Label.new()
	targets_label.text = "WORD TARGETS"
	right_panel.add_child(targets_label)
	
	targets_panel = RichTextLabel.new()
	targets_panel.bbcode_enabled = true
	targets_panel.size_flags_vertical = SIZE_EXPAND_FILL
	targets_panel.size_flags_stretch_ratio = 0.6
	right_panel.add_child(targets_panel)
	
	# Game buttons
	var game_buttons = HBoxContainer.new()
	main_container.add_child(game_buttons)
	
	var start_button = Button.new()
	start_button.text = "Start Game"
	start_button.connect("pressed", self, "_on_start_button_pressed")
	game_buttons.add_child(start_button)
	
	var pause_button = Button.new()
	pause_button.text = "Pause"
	pause_button.connect("pressed", self, "_on_pause_button_pressed")
	game_buttons.add_child(pause_button)
	
	var help_button = Button.new()
	help_button.text = "Help"
	help_button.connect("pressed", self, "_on_help_button_pressed")
	game_buttons.add_child(help_button)

func connect_systems():
	divine_word_game = get_node("/root/DivineWordGame")
	turn_system = get_node("/root/TurnSystem")
	divine_word_processor = get_node("/root/DivineWordProcessor")
	
	if divine_word_game:
		divine_word_game.connect("game_started", self, "_on_game_started")
		divine_word_game.connect("game_paused", self, "_on_game_paused")
		divine_word_game.connect("game_resumed", self, "_on_game_resumed")
		divine_word_game.connect("game_over", self, "_on_game_over")
		divine_word_game.connect("level_up", self, "_on_level_up")
		divine_word_game.connect("dimension_unlocked", self, "_on_dimension_unlocked")
		divine_word_game.connect("word_target_completed", self, "_on_word_target_completed")
	
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")

func _process(delta):
	if turn_system and turn_system.is_running:
		# Update the 9-second timer
		nine_second_timer -= delta
		
		if nine_second_timer <= 0:
			nine_second_timer = 9.0  # Reset to the sacred 9-second interval
		
		timer_bar.value = nine_second_timer
		
		# Update timer bar color based on urgency
		if nine_second_timer < 3.0:
			timer_bar.modulate = Color(1, 0, 0)  # Red
		elif nine_second_timer < 6.0:
			timer_bar.modulate = Color(1, 1, 0)  # Yellow
		else:
			timer_bar.modulate = Color(0, 1, 0)  # Green
	
	# Update game stats
	if divine_word_game:
		var stats = divine_word_game.get_game_stats()
		score_label.text = "Score: " + str(stats.score)
		level_label.text = "Level: " + str(stats.level)
		
		if stats.state == divine_word_game.GameState.PAUSED:
			timer_bar.modulate = Color(0.5, 0.5, 0.5)  # Gray when paused

func _on_start_button_pressed():
	if divine_word_game:
		if divine_word_game.start_game():
			add_message("Game started!", Color(0, 1, 0))
			update_challenge_panel()
			update_targets_panel()

func _on_pause_button_pressed():
	if divine_word_game:
		var stats = divine_word_game.get_game_stats()
		
		if stats.state == divine_word_game.GameState.PLAYING:
			if divine_word_game.pause_game():
				add_message("Game paused", Color(1, 1, 0))
		elif stats.state == divine_word_game.GameState.PAUSED:
			if divine_word_game.resume_game():
				add_message("Game resumed", Color(0, 1, 0))

func _on_help_button_pressed():
	show_help()

func _on_dimension_button_pressed(dimension):
	if turn_system and divine_word_game:
		var stats = divine_word_game.get_game_stats()
		
		if stats.state == divine_word_game.GameState.PLAYING and dimension <= stats.dimension_unlocked:
			turn_system.set_dimension(dimension)
			add_message("Manually switching to dimension " + str(dimension) + "D", Color(0.5, 0.5, 1))

func _on_word_submitted(text):
	submit_word(text)

func _on_submit_pressed():
	submit_word(word_input.text)

func submit_word(text):
	if text.empty():
		return
	
	if divine_word_game:
		var power = divine_word_game.submit_word(text)
		
		if power > 0:
			add_message("Word submitted: " + text + " (Power: " + str(power) + ")", Color(0, 1, 0))
		elif power < 0:
			add_message("BANNED WORD: " + text + " - Penalty applied!", Color(1, 0, 0))
		else:
			add_message("Cannot process word right now", Color(0.5, 0.5, 0.5))
	
	# Clear the input field
	word_input.text = ""

func add_message(text, color=Color(1, 1, 1)):
	var time_str = OS.get_time()
	var timestamp = "%02d:%02d:%02d" % [time_str.hour, time_str.minute, time_str.second]
	
	message_log.bbcode_text += "[color=#888888][" + timestamp + "][/color] "
	message_log.bbcode_text += "[color=#" + color.to_html(false) + "]" + text + "[/color]\n"
	
	# Scroll to bottom
	message_log.scroll_to_line(message_log.get_line_count())

func update_challenge_panel():
	if divine_word_game:
		var challenge = divine_word_game.get_dimension_challenge()
		
		if challenge:
			challenge_panel.bbcode_text = "[b]" + challenge.name + "[/b]\n"
			challenge_panel.bbcode_text += challenge.description + "\n\n"
			challenge_panel.bbcode_text += "[u]Required Power:[/u] " + str(challenge.min_power) + "\n"
			challenge_panel.bbcode_text += "[u]Reward:[/u] " + str(challenge.reward) + " points\n"
		else:
			challenge_panel.bbcode_text = "No challenge available for this dimension."

func update_targets_panel():
	if divine_word_game:
		var targets = divine_word_game.get_current_targets()
		
		if targets.size() > 0:
			targets_panel.bbcode_text = "[b]Current Word Targets:[/b]\n"
			
			for target in targets:
				var status = target.completed ? "[color=green]✓[/color]" : "[color=yellow]◯[/color]"
				var color = target.completed ? "#88FF88" : "#FFFFFF"
				
				targets_panel.bbcode_text += status + " [color=" + color + "]" + target.word
				targets_panel.bbcode_text += " (Min Power: " + str(target.min_power) + ")[/color]\n"
		else:
			targets_panel.bbcode_text = "No word targets available."

func show_help():
	var help_text = """
[b]DIVINE WORD GENESIS - HELP[/b]

[u]Game Objective:[/u]
Create words to gain power and progress through 12 dimensions.

[u]How to Play:[/u]
1. Type words in the input field and submit them
2. Complete dimension challenges to unlock new dimensions
3. Meet word targets to gain bonus points
4. Progress through levels by earning points
5. Avoid banned words to prevent penalties

[u]Special Rules:[/u]
- The sacred 9-second interval governs turn progression
- Each dimension has unique challenges and word targets
- Sacred words provide bonus points
- Reach cosmic power levels for special rewards
- Dreams in dimension 7 have special significance
- Judgments in dimension 9 affect the Town of Salem game

[u]Dimensions:[/u]
- 1D: Linear words (one-dimensional thinking)
- 2D: Planar words (two-dimensional concepts)
- 3D: Spatial words (physical manifestation)
- 4D: Temporal words (time-related concepts)
- 5D: Probability words (quantum concepts)
- 6D: Resonance words (pattern and repetition)
- 7D: Dream words (subconscious manifestation)
- 8D: Network words (interconnected concepts)
- 9D: Judgment words (ethical evaluation)
- 10D: Harmonic words (balanced structures)
- 11D: Conscious words (awareness concepts)
- 12D: Divine words (transcendent concepts)
"""
	
	message_log.bbcode_text += help_text

func _on_game_started():
	add_message("Game started!", Color(0, 1, 0))
	update_challenge_panel()
	update_targets_panel()

func _on_game_paused():
	add_message("Game paused", Color(1, 1, 0))

func _on_game_resumed():
	add_message("Game resumed", Color(0, 1, 0))

func _on_game_over(final_score):
	add_message("Game over! Final score: " + str(final_score), Color(1, 0.5, 0))
	
	# Show game over summary
	message_log.bbcode_text += "\n[color=#FFAA00][b]GAME OVER SUMMARY[/b][/color]\n"
	
	if divine_word_game:
		var stats = divine_word_game.get_game_stats()
		message_log.bbcode_text += "Final Level: " + str(stats.level) + "\n"
		message_log.bbcode_text += "Turns Played: " + str(stats.turn_count) + "\n"
		message_log.bbcode_text += "Highest Dimension: " + str(stats.dimension_unlocked) + "D\n"
	
	message_log.bbcode_text += "\nStart a new game to play again.\n"

func _on_level_up(new_level):
	add_message("LEVEL UP! You are now level " + str(new_level), Color(1, 1, 0))
	update_targets_panel()

func _on_dimension_unlocked(dimension):
	add_message("DIMENSION UNLOCKED: You can now access " + str(dimension) + "D", Color(1, 0, 1))
	update_challenge_panel()
	update_targets_panel()

func _on_word_target_completed(word, power):
	add_message("TARGET COMPLETED: " + word + " (Power: " + str(power) + ")", Color(0, 1, 0.5))
	update_targets_panel()

func _on_turn_completed(turn_number):
	turn_label.text = "Turn: " + str(turn_number)
	
	# Every 12 turns, add a cycle completion message
	if turn_number % 12 == 0:
		var cycle_number = turn_number / 12
		add_message("CYCLE " + str(cycle_number) + " COMPLETED", Color(0.5, 0.5, 1))

func _on_dimension_changed(new_dimension, old_dimension):
	dimension_label.text = "Dimension: " + str(new_dimension) + "D"
	
	# Update dimension visualization
	if new_dimension >= 1 and new_dimension <= 12:
		dimension_indicator.color = dimension_colors[new_dimension - 1]
	
	# Update challenge and targets panels
	update_challenge_panel()
	update_targets_panel()
	
	# Add dimension change message
	add_message("Dimension changed: " + str(old_dimension) + "D → " + str(new_dimension) + "D", Color(0.5, 1, 1))

func _on_word_processed(word, power, source_player):
	# Only display messages for significant power levels
	if power >= 50:
		add_message("High power word detected: " + word + " (" + str(power) + ")", Color(1, 0.5, 0))
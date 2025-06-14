extends Control

# Word Comment UI
# Interface for the comment and dream recording system
# Terminal 1: Divine Word Genesis

class_name WordCommentUI

# UI Components
var comment_tab_container
var comment_list
var dream_list
var defense_list
var input_field
var submit_button
var word_filter
var type_filter
var current_word_label

# References to systems
var word_comment_system = null
var divine_word_processor = null
var turn_system = null

# Current view state
var current_word = ""
var current_filter_type = -1  # -1 means all types
var dream_mode = false

func _ready():
	setup_ui()
	connect_systems()

func setup_ui():
	# Main layout
	set_anchors_preset(Control.PRESET_WIDE)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_WIDE)
	add_child(main_container)
	
	# Header
	var header = HBoxContainer.new()
	main_container.add_child(header)
	
	var title_label = Label.new()
	title_label.text = "WORD COMMENT SYSTEM"
	title_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title_label)
	
	current_word_label = Label.new()
	current_word_label.text = "No word selected"
	current_word_label.size_flags_horizontal = SIZE_EXPAND_FILL
	current_word_label.align = Label.ALIGN_RIGHT
	header.add_child(current_word_label)
	
	# Filter options
	var filter_container = HBoxContainer.new()
	main_container.add_child(filter_container)
	
	var word_filter_label = Label.new()
	word_filter_label.text = "Word Filter:"
	filter_container.add_child(word_filter_label)
	
	word_filter = LineEdit.new()
	word_filter.placeholder_text = "Enter word to filter"
	word_filter.size_flags_horizontal = SIZE_EXPAND_FILL
	word_filter.connect("text_changed", self, "_on_word_filter_changed")
	filter_container.add_child(word_filter)
	
	var type_filter_label = Label.new()
	type_filter_label.text = "Type Filter:"
	filter_container.add_child(type_filter_label)
	
	type_filter = OptionButton.new()
	type_filter.add_item("All Types", -1)
	type_filter.add_item("Observations", 0)
	type_filter.add_item("Defense", 1)
	type_filter.add_item("Accusations", 2)
	type_filter.add_item("Dreams", 3)
	type_filter.add_item("Divine", 4)
	type_filter.add_item("Warnings", 5)
	type_filter.connect("item_selected", self, "_on_type_filter_selected")
	filter_container.add_child(type_filter)
	
	var dream_toggle = CheckButton.new()
	dream_toggle.text = "Dream Mode"
	dream_toggle.connect("toggled", self, "_on_dream_toggle")
	filter_container.add_child(dream_toggle)
	
	# Tabs for different views
	comment_tab_container = TabContainer.new()
	comment_tab_container.size_flags_vertical = SIZE_EXPAND_FILL
	main_container.add_child(comment_tab_container)
	
	# Comments tab
	var comments_container = VBoxContainer.new()
	comment_tab_container.add_child(comments_container)
	comment_tab_container.set_tab_title(0, "Comments")
	
	comment_list = RichTextLabel.new()
	comment_list.bbcode_enabled = true
	comment_list.size_flags_vertical = SIZE_EXPAND_FILL
	comments_container.add_child(comment_list)
	
	# Dreams tab
	var dreams_container = VBoxContainer.new()
	comment_tab_container.add_child(dreams_container)
	comment_tab_container.set_tab_title(1, "Dreams")
	
	dream_list = RichTextLabel.new()
	dream_list.bbcode_enabled = true
	dream_list.size_flags_vertical = SIZE_EXPAND_FILL
	dreams_container.add_child(dream_list)
	
	# Defense tab
	var defense_container = VBoxContainer.new()
	comment_tab_container.add_child(defense_container)
	comment_tab_container.set_tab_title(2, "Defense")
	
	defense_list = RichTextLabel.new()
	defense_list.bbcode_enabled = true
	defense_list.size_flags_vertical = SIZE_EXPAND_FILL
	defense_container.add_child(defense_list)
	
	# Input area
	var input_container = HBoxContainer.new()
	main_container.add_child(input_container)
	
	input_field = TextEdit.new()
	input_field.rect_min_size = Vector2(0, 80)
	input_field.size_flags_horizontal = SIZE_EXPAND_FILL
	input_container.add_child(input_field)
	
	submit_button = Button.new()
	submit_button.text = "Submit"
	submit_button.connect("pressed", self, "_on_submit_pressed")
	input_container.add_child(submit_button)
	
	# Help text
	var help_label = RichTextLabel.new()
	help_label.bbcode_enabled = true
	help_label.bbcode_text = "[b]Format:[/b] #word your comment\n" + \
		"[b]Examples:[/b]\n" + \
		"#crime This word has dangerous potential\n" + \
		"#justice I defend this word as necessary\n" + \
		"#reality This word appeared in my dream\n" + \
		"#warning Dangerous pattern detected"
	help_label.rect_min_size = Vector2(0, 75)
	main_container.add_child(help_label)

func connect_systems():
	word_comment_system = get_node("/root/WordCommentSystem")
	divine_word_processor = get_node("/root/DivineWordProcessor")
	turn_system = get_node("/root/TurnSystem")
	
	if word_comment_system:
		word_comment_system.connect("comment_added", self, "_on_comment_added")
		word_comment_system.connect("defense_registered", self, "_on_defense_registered")
		word_comment_system.connect("dream_recorded", self, "_on_dream_recorded")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if turn_system:
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")

func _on_word_filter_changed(new_text):
	current_word = new_text
	update_current_word_label()
	refresh_all_lists()

func _on_type_filter_selected(index):
	current_filter_type = type_filter.get_item_id(index)
	refresh_all_lists()

func _on_dream_toggle(toggled):
	dream_mode = toggled
	refresh_all_lists()
	
	if toggled:
		input_field.placeholder_text = "Enter dream fragment..."
	else:
		input_field.placeholder_text = "Enter comment..."

func _on_submit_pressed():
	var text = input_field.text.strip_edges()
	
	if text.empty():
		return
	
	if dream_mode:
		# In dream mode, create a dream entry for the current word
		if current_word.empty():
			# Select a random word from recent words
			var recent_words = []
			if divine_word_processor:
				recent_words = divine_word_processor.get_recent_words(5)
			
			if recent_words.size() > 0:
				current_word = recent_words[randi() % recent_words.size()]
			else:
				current_word = "dream"
		
		word_comment_system.record_dream_fragment(current_word, text)
	else:
		# Process the text for comments (# format)
		var comments_added = word_comment_system.process_text_for_comments(text)
		
		# If no # format comments found, treat as comment for current word
		if comments_added == 0 and !current_word.empty():
			word_comment_system.add_comment(current_word, text)
	
	# Clear the input field
	input_field.text = ""
	
	# Refresh the lists
	refresh_all_lists()

func refresh_all_lists():
	refresh_comment_list()
	refresh_dream_list()
	refresh_defense_list()

func refresh_comment_list():
	comment_list.bbcode_text = ""
	
	var comments = []
	if current_word.empty():
		comments = word_comment_system.comment_history
	else:
		var word_comments = word_comment_system.get_comments_for_word(current_word)
		for comment in word_comments:
			comments.append({"word": current_word, "comment": comment})
	
	# Filter by type if needed
	if current_filter_type >= 0:
		var filtered_comments = []
		for entry in comments:
			if entry.comment.type == current_filter_type:
				filtered_comments.append(entry)
		comments = filtered_comments
	
	# Display comments
	if comments.size() == 0:
		comment_list.bbcode_text = "[i]No comments found with current filters.[/i]"
	else:
		for entry in comments:
			add_comment_to_list(entry.word, entry.comment)

func add_comment_to_list(word, comment):
	var type_colors = {
		0: "#FFFFFF", # Observation - white
		1: "#88FF88", # Defense - green
		2: "#FF8888", # Accusation - red
		3: "#8888FF", # Dream - blue
		4: "#FFFF88", # Divine - yellow
		5: "#FF88FF"  # Warning - purple
	}
	
	var type_names = {
		0: "Observation",
		1: "Defense",
		2: "Accusation",
		3: "Dream",
		4: "Divine",
		5: "Warning"
	}
	
	var color = "#FFFFFF"
	if type_colors.has(comment.type):
		color = type_colors[comment.type]
	
	var type_name = "Comment"
	if type_names.has(comment.type):
		type_name = type_names[comment.type]
	
	var timestamp = OS.get_datetime_from_unix_time(comment.timestamp)
	var time_str = "%04d-%02d-%02d %02d:%02d:%02d" % [
		timestamp.year, timestamp.month, timestamp.day,
		timestamp.hour, timestamp.minute, timestamp.second
	]
	
	comment_list.bbcode_text += "[color=#888888][" + time_str + "][/color] "
	comment_list.bbcode_text += "[color=#AAAAFF]" + word + ":[/color] "
	comment_list.bbcode_text += "[color=" + color + "][b][" + type_name + "][/b] "
	comment_list.bbcode_text += comment.text + "[/color]\n"
	
	if comment.has("dimension") and comment.has("turn"):
		comment_list.bbcode_text += "[color=#888888]   Dimension: " + str(comment.dimension) + "D, Turn: " + str(comment.turn) + "[/color]\n"
	
	comment_list.bbcode_text += "\n"

func refresh_dream_list():
	dream_list.bbcode_text = ""
	
	var dreams = word_comment_system.dream_fragments
	
	if dreams.size() == 0:
		dream_list.bbcode_text = "[i]No dream fragments recorded yet.[/i]"
		return
	
	// Sort dreams by timestamp, newest first
	dreams.sort_custom(self, "sort_by_timestamp_descending")
	
	// Filter by word if needed
	if !current_word.empty():
		var filtered_dreams = []
		for dream in dreams:
			if dream.word == current_word:
				filtered_dreams.append(dream)
		dreams = filtered_dreams
	
	// Display dreams
	if dreams.size() == 0:
		dream_list.bbcode_text = "[i]No dreams found with current filters.[/i]"
	else:
		for dream in dreams:
			add_dream_to_list(dream)

func add_dream_to_list(dream):
	var timestamp = OS.get_datetime_from_unix_time(dream.timestamp)
	var time_str = "%04d-%02d-%02d %02d:%02d:%02d" % [
		timestamp.year, timestamp.month, timestamp.day,
		timestamp.hour, timestamp.minute, timestamp.second
	]
	
	// Power-based color
	var color = "#8888FF"  // Default blue
	if dream.power >= 75:
		color = "#FF88FF"  // Purple for high power
	elif dream.power >= 50:
		color = "#88FFFF"  // Cyan for medium-high
	elif dream.power >= 25:
		color = "#8888FF"  // Blue for medium
	
	dream_list.bbcode_text += "[color=#888888][" + time_str + "][/color] "
	dream_list.bbcode_text += "[color=#AAAAFF]" + dream.word + ":[/color] "
	dream_list.bbcode_text += "[color=" + color + "][b][Dream Power: " + str(dream.power) + "][/b]\n"
	dream_list.bbcode_text += dream.dream_text + "[/color]\n"
	
	if dream.has("dimension"):
		dream_list.bbcode_text += "[color=#888888]   Dimension: " + str(dream.dimension) + "D[/color]\n"
	
	dream_list.bbcode_text += "\n"

func refresh_defense_list():
	defense_list.bbcode_text = ""
	
	var all_defenses = []
	
	if current_word.empty():
		// Collect all defenses
		for word in word_comment_system.defense_statements.keys():
			var defenses = word_comment_system.defense_statements[word]
			for defense in defenses:
				all_defenses.append({"word": word, "defense": defense})
	else:
		// Get defenses for the current word
		var defenses = word_comment_system.get_defense_for_word(current_word)
		for defense in defenses:
			all_defenses.append({"word": current_word, "defense": defense})
	
	// Sort defenses by timestamp, newest first
	all_defenses.sort_custom(self, "sort_defense_by_timestamp_descending")
	
	// Display defenses
	if all_defenses.size() == 0:
		defense_list.bbcode_text = "[i]No defense statements recorded yet.[/i]"
	else:
		for entry in all_defenses:
			add_defense_to_list(entry.word, entry.defense)

func add_defense_to_list(word, defense):
	var timestamp = OS.get_datetime_from_unix_time(defense.timestamp)
	var time_str = "%04d-%02d-%02d %02d:%02d:%02d" % [
		timestamp.year, timestamp.month, timestamp.day,
		timestamp.hour, timestamp.minute, timestamp.second
	]
	
	var status_color = defense.accepted ? "#88FF88" : "#FFFF88"
	var status_text = defense.accepted ? "ACCEPTED" : "PENDING"
	
	defense_list.bbcode_text += "[color=#888888][" + time_str + "][/color] "
	defense_list.bbcode_text += "[color=#AAAAFF]" + word + ":[/color] "
	defense_list.bbcode_text += "[color=" + status_color + "][b][" + status_text + "][/b][/color]\n"
	defense_list.bbcode_text += "[color=#88FF88]" + defense.text + "[/color]\n"
	defense_list.bbcode_text += "[color=#888888]   Defender: " + defense.defender
	
	if defense.has("dimension") and defense.has("turn"):
		defense_list.bbcode_text += " | Dimension: " + str(defense.dimension) + "D, Turn: " + str(defense.turn)
	
	defense_list.bbcode_text += "[/color]\n\n"

func sort_by_timestamp_descending(a, b):
	return a.timestamp > b.timestamp

func sort_defense_by_timestamp_descending(a, b):
	return a.defense.timestamp > b.defense.timestamp

func update_current_word_label():
	if current_word.empty():
		current_word_label.text = "All Words"
	else:
		current_word_label.text = "Word: " + current_word

func _on_comment_added(word, comment_text, type):
	refresh_comment_list()
	
	// If it's a defense, refresh defense list
	if type == word_comment_system.CommentType.DEFENSE:
		refresh_defense_list()

func _on_defense_registered(word, defense_text):
	refresh_defense_list()

func _on_dream_recorded(dream_text, power_level):
	refresh_dream_list()

func _on_word_processed(word, power, source_player):
	// Update current word if none is selected
	if current_word.empty():
		current_word = word
		update_current_word_label()
		refresh_all_lists()

func _on_dimension_changed(new_dimension, old_dimension):
	// Special handling for dream dimension (7)
	if new_dimension == 7:
		comment_tab_container.current_tab = 1  // Switch to dreams tab
	
	// Special handling for judgment dimension (9)
	if new_dimension == 9:
		comment_tab_container.current_tab = 2  // Switch to defense tab
extends Node

# Word Comment System
# Allows attaching comments to words and storing them in the Divine Memory
# Terminal 1: Divine Word Genesis

class_name WordCommentSystem

# Comment storage structure
var word_comments = {}
var comment_history = []
var dream_fragments = []
var defense_statements = {}

# References to other systems
var divine_word_processor = null
var word_salem_controller = null
var turn_system = null
var word_dream_storage = null

# UI state
var dream_mode = false
var comment_filter = CommentType.OBSERVATION

# Comment types
enum CommentType {
	OBSERVATION,   # General observations about words
	DEFENSE,       # Defense statements for word crimes
	ACCUSATION,    # Accusations against specific words
	DREAM,         # Dream fragments and associations
	DIVINE,        # Divine revelations
	WARNING        # System warnings
}

# Dream-related settings
var dream_probability = 0.3
var dream_power_threshold = 30
var dream_words = [
	"dream", "sleep", "night", "vision", "unconscious", 
	"subconscious", "reality", "fantasy", "imagination",
	"astral", "ethereal", "surreal", "abstract", "symbol"
]

# Signals
signal comment_added(word, comment, type)
signal defense_registered(word, defense_text)
signal dream_recorded(dream_text, power_level)
signal comment_filtered(filter_type)

func _ready():
	connect_systems()
	initialize_default_comments()

func connect_systems():
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	turn_system = get_node_or_null("/root/TurnSystem")
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")

# Initialize with some starting comments
func initialize_default_comments():
	add_comment("system", 
		"Welcome to the Divine Word Genesis system. The sacred 9-second interval awaits.", 
		CommentType.DIVINE)
	
	add_comment("dimension_1", 
		"Starting in the first dimension: Linear Expression. Words exist as pure concepts in a single line of possibility.", 
		CommentType.OBSERVATION)
	
	add_comment("rules", 
		"Remember: Words spoken with divine intent have power. Sacred words multiply this power.", 
		CommentType.OBSERVATION)

func add_comment(word, comment_text, type=CommentType.OBSERVATION, author="System"):
	if not word_comments.has(word):
		word_comments[word] = []
	
	var comment = {
		"text": comment_text,
		"type": type,
		"author": author,
		"timestamp": OS.get_unix_time(),
		"turn": turn_system.current_turn if turn_system else 0,
		"dimension": turn_system.current_dimension if turn_system else 1
	}
	
	word_comments[word].append(comment)
	
	# Add to general history
	comment_history.append({
		"word": word,
		"comment": comment
	})
	
	emit_signal("comment_added", word, comment_text, type)
	
	# Special handling for DREAM type comments
	if type == CommentType.DREAM:
		record_dream_fragment(word, comment_text)
	
	# Print to console
	var type_name = get_comment_type_name(type)
	print("[%s] %s: %s" % [type_name, word, comment_text])
	
	return comment

func register_defense(word, defense_text, defender="anonymous"):
	if not defense_statements.has(word):
		defense_statements[word] = []
	
	var defense = {
		"text": defense_text,
		"defender": defender,
		"timestamp": OS.get_unix_time(),
		"turn": turn_system.current_turn if turn_system else 0,
		"dimension": turn_system.current_dimension if turn_system else 1,
		"accepted": false
	}
	
	defense_statements[word].append(defense)
	emit_signal("defense_registered", word, defense_text)
	
	# Add a regular comment as well
	add_comment(word, "DEFENSE: " + defense_text, CommentType.DEFENSE, defender)
	
	return defense

func record_dream_fragment(word, dream_text):
	var power = 0
	if divine_word_processor:
		power = divine_word_processor.calculate_word_power(word)
	
	var dream = {
		"word": word,
		"dream_text": dream_text,
		"power": power,
		"timestamp": OS.get_unix_time(),
		"turn": turn_system.current_turn if turn_system else 0,
		"dimension": turn_system.current_dimension if turn_system else 1
	}
	
	dream_fragments.append(dream)
	emit_signal("dream_recorded", dream_text, power)
	
	# Store in dream storage if available
	if word_dream_storage:
		word_dream_storage.save_dream(dream, 1)  # Store in tier 1 by default
	
	return dream

func _on_word_processed(word, power, source_player):
	# Automatically add warning comments for high-power words
	if power >= 50:
		add_comment(word, "WARNING: High power word detected.", CommentType.WARNING)
	
	# Add divine comment in dimension 12
	if turn_system and turn_system.current_dimension == 12 and power >= 30:
		add_comment(word, "DIVINE: This word resonates with the 12th dimension.", CommentType.DIVINE)
	
	# Check for dream associations in dimension 7
	if turn_system and turn_system.current_dimension == 7:
		var dream_chance = min(power / 100.0, 0.75)  # Max 75% chance
		if randf() < dream_chance:
			generate_dream_for_word(word, power)

func generate_dream_for_word(word, power):
	var dream_templates = [
		"A swirling vortex of letters forming the word %s.",
		"The word %s echoing through an endless corridor.",
		"Standing on a mountaintop, seeing %s written in the clouds.",
		"A voice whispering %s repeatedly in the darkness.",
		"The word %s transforming into a living entity.",
		"%s appearing as glowing symbols in an ancient temple.",
		"Falling through space with the letters of %s surrounding you.",
		"The word %s becoming a door to another reality."
	]
	
	var template = dream_templates[randi() % dream_templates.size()]
	var dream_text = template % word
	
	# Add more dream details based on power
	if power >= 75:
		dream_text += " The dream feels incredibly vivid and real."
	elif power >= 50:
		dream_text += " The sensation lingers even after waking."
	elif power >= 25:
		dream_text += " The memory fades quickly upon waking."
	
	record_dream_fragment(word, dream_text)

func _on_turn_completed(turn_number):
	# Every 12 turns, process dream fragments into coherent narratives
	if turn_number % 12 == 0 and dream_fragments.size() >= 3:
		consolidate_dreams()

func _on_dimension_changed(new_dimension, old_dimension):
	# Create transition comment for key dimensions
	if new_dimension == 7:
		add_comment("dimension_shift", "Entering the dreamscape of the 7th dimension.", CommentType.DREAM)
	elif new_dimension == 9:
		add_comment("dimension_shift", "The 9th dimension grants clarity of judgment.", CommentType.OBSERVATION)
	elif new_dimension == 12:
		add_comment("dimension_shift", "Divine revelation awaits in the 12th dimension.", CommentType.DIVINE)

func consolidate_dreams():
	# Only process recent dreams (from the last cycle)
	var recent_dreams = []
	var cycle_start_turn = turn_system.current_turn - 12
	
	for dream in dream_fragments:
		if dream.turn >= cycle_start_turn:
			recent_dreams.append(dream)
	
	if recent_dreams.size() < 3:
		return
	
	# Sort by power, descending
	recent_dreams.sort_custom(self, "sort_by_power_descending")
	
	# Take the three most powerful dreams
	var top_dreams = []
	for i in range(min(3, recent_dreams.size())):
		top_dreams.append(recent_dreams[i])
	
	# Create a consolidated dream narrative
	var narrative = "Dream Cycle Narrative:\n"
	var total_power = 0
	
	for dream in top_dreams:
		narrative += "- " + dream.dream_text + "\n"
		total_power += dream.power
	
	# Add meaning based on total power
	narrative += "\nInterpretation: "
	
	if total_power >= 200:
		narrative += "A prophetic vision of great significance."
	elif total_power >= 150:
		narrative += "A powerful message from the collective unconscious."
	elif total_power >= 100:
		narrative += "A meaningful pattern emerging from linguistic energies."
	else:
		narrative += "Symbolic fragments seeking connection."
	
	# Record as a special consolidated dream
	var consolidated = {
		"narrative": narrative,
		"dreams": top_dreams,
		"total_power": total_power,
		"turn_cycle": turn_system.current_turn / 12,
		"timestamp": OS.get_unix_time()
	}
	
	# Store in dream storage if available
	if word_dream_storage:
		word_dream_storage.save_dream(consolidated, 3)  # Store in tier 3 (eternal memory)
	else:
		# Fallback to local storage
		store_in_divine_memory("dream_narrative_" + str(consolidated.turn_cycle), consolidated)
	
	# Add a comment about the consolidated dream
	add_comment("dream_narrative", 
		"A consolidated dream narrative has formed from recent dreams. Total power: " + str(total_power), 
		CommentType.DREAM)

func sort_by_power_descending(a, b):
	return a.power > b.power

func store_in_divine_memory(key, data):
	# Data persistence to divine memory system
	# For now, just print the data
	print("DIVINE MEMORY: Storing " + key)
	print(data)
	
	# This is a fallback if word_dream_storage is not available

# Toggle dream mode
func _on_dream_toggle(enable):
	dream_mode = enable
	
	if dream_mode:
		add_comment("dream_mode", 
			"Dream mode activated. Words may manifest in unexpected ways.", 
			CommentType.DREAM)
	else:
		add_comment("dream_mode", 
			"Dream mode deactivated. Returning to ordinary word manifestation.", 
			CommentType.OBSERVATION)
	
	return dream_mode

# Filter comments by type
func filter_comments(type):
	comment_filter = type
	emit_signal("comment_filtered", type)
	var filtered_comments = []
	
	for entry in comment_history:
		if entry.comment.type == type:
			filtered_comments.append(entry)
	
	return filtered_comments

# Get a formatted string representation of a comment type
func get_comment_type_name(type):
	match type:
		CommentType.OBSERVATION:
			return "OBSERVATION"
		CommentType.WARNING:
			return "WARNING"
		CommentType.DIVINE:
			return "DIVINE"
		CommentType.DREAM:
			return "DREAM"
		CommentType.DEFENSE:
			return "DEFENSE"
		CommentType.ACCUSATION:
			return "ACCUSATION"
		_:
			return "UNKNOWN"

# Public interface methods

func get_comments_for_word(word):
	if word_comments.has(word):
		return word_comments[word]
	return []

func get_defense_for_word(word):
	if defense_statements.has(word):
		return defense_statements[word]
	return []

func get_dream_fragments_by_turn_range(start_turn, end_turn):
	var fragments = []
	
	for dream in dream_fragments:
		if dream.turn >= start_turn and dream.turn <= end_turn:
			fragments.append(dream)
	
	return fragments

func get_comment_history_by_type(type):
	var results = []
	
	for entry in comment_history:
		if entry.comment.type == type:
			results.append(entry)
	
	return results

func add_hash_comment(text):
	# Process comments that start with #
	if text.begins_with("#"):
		var comment_text = text.substr(1).strip_edges()
		var parts = comment_text.split(" ", true, 1)
		
		if parts.size() >= 2:
			var word = parts[0]
			var comment = parts[1]
			
			# Determine comment type based on content
			var type = CommentType.OBSERVATION
			
			if comment.to_lower().find("dream") >= 0:
				type = CommentType.DREAM
			elif comment.to_lower().find("defend") >= 0 or comment.to_lower().find("defense") >= 0:
				type = CommentType.DEFENSE
			elif comment.to_lower().find("accuse") >= 0 or comment.to_lower().find("guilty") >= 0:
				type = CommentType.ACCUSATION
			elif comment.to_lower().find("divine") >= 0 or comment.to_lower().find("revelation") >= 0:
				type = CommentType.DIVINE
			elif comment.to_lower().find("warn") >= 0 or comment.to_lower().find("danger") >= 0:
				type = CommentType.WARNING
			
			add_comment(word, comment, type, "User")
			return true
	
	return false

func process_text_for_comments(text):
	# Process entire text for comments
	var lines = text.split("\n")
	var comments_found = 0
	
	for line in lines:
		if add_hash_comment(line):
			comments_found += 1
	
	return comments_found

# Export comments to a string
func export_comments_to_string():
	var result = "# WORD COMMENT SYSTEM EXPORT\n"
	result += "Generated: " + str(OS.get_datetime()) + "\n"
	result += "Total Comments: " + str(comment_history.size()) + "\n\n"
	
	for entry in comment_history:
		var type_name = get_comment_type_name(entry.comment.type)
		var date = OS.get_datetime_from_unix_time(entry.comment.timestamp)
		var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [
			date.year, date.month, date.day,
			date.hour, date.minute, date.second
		]
		
		result += "[" + date_str + "] " + type_name + " - " + entry.word + ":\n"
		result += entry.comment.text + "\n\n"
	
	return result
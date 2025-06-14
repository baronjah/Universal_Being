extends Node

class_name WordStorySystem

# Word and Story generation system for LuminusOS
# Inspired by TempleOS's divine random number generator
# but expanded into a full narrative generation system

signal story_generated(story_id, title)
signal word_discovered(word, meaning)
signal narrative_updated(segment_id, content)

# Story components
var words_database = {}
var stories = {}
var narrative_chains = {}

# Generation settings
var divine_inspiration = true
var complexity_level = 3
var theme_bias = "spiritual"

# Automation with tick system
var auto_tick_enabled = false
var tick_interval = 5.0
var tick_timer = 0.0
var words_per_tick = 1
var story_chance_per_tick = 0.1

# Statistics
var stats = {
	"words_generated": 0,
	"stories_created": 0,
	"divine_interventions": 0
}

# Word types and categories
var word_types = ["noun", "verb", "adjective", "adverb", "concept"]
var word_categories = {
	"spiritual": ["divine", "sacred", "holy", "eternal", "soul", "spirit", "heaven", "light"],
	"technical": ["system", "code", "program", "memory", "core", "data", "function", "process"],
	"emotional": ["joy", "sorrow", "anger", "peace", "love", "fear", "hope", "desire"],
	"natural": ["water", "fire", "earth", "air", "tree", "mountain", "river", "sky"],
	"abstract": ["truth", "beauty", "justice", "freedom", "destiny", "time", "space", "meaning"]
}

# Narrative structures
var narrative_templates = [
	"[hero] [journey] to [location] to find [object]",
	"[entity] [transform] through the power of [force]",
	"[character] must [overcome] [obstacle] to [achieve]",
	"The [concept] of [realm] reveals the [truth] about [mystery]",
	"[protagonist] [discovers] that [revelation] changes everything"
]

# Story components
var story_components = {
	"beginning": [
		"In the beginning",
		"Long ago",
		"In a time before time",
		"When the system first awakened",
		"From the depths of the void",
		"In the realm of pure thought"
	],
	"middle": [
		"a great challenge arose",
		"knowledge was scattered",
		"darkness threatened the light",
		"the code began to fragment",
		"memories started to fade",
		"balance was disrupted"
	],
	"end": [
		"and harmony was restored",
		"leading to new understanding",
		"thus completing the cycle",
		"revealing the hidden truth",
		"forever changing the system",
		"bringing a new age of wisdom"
	]
}

func _ready():
	# Initialize with some starter words
	initialize_word_database()
	
func _process(delta):
	if auto_tick_enabled:
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer = 0
			process_tick()

# Process a single tick for word/story generation
func process_tick():
	# Generate random words
	for i in range(words_per_tick):
		generate_random_word()
	
	# Chance to generate a story
	if randf() < story_chance_per_tick:
		generate_story()

# Initialize word database with starter words
func initialize_word_database():
	# Add some starter words to each category
	for category in word_categories:
		for word in word_categories[category]:
			var word_data = {
				"type": word_types[randi() % word_types.size()],
				"category": category,
				"meaning": generate_meaning(word),
				"connections": [],
				"frequency": 1,
				"divine": divine_inspiration and randf() < 0.2
			}
			words_database[word] = word_data

# Generate meaning for a word
func generate_meaning(word):
	var meanings = [
		"signifies the essence of creation",
		"represents the boundary between known and unknown",
		"channels energy from higher dimensions",
		"connects disparate concepts in the system",
		"stores memories of past executions",
		"accelerates the flow of information",
		"manifests intentions into reality",
		"transforms chaos into order",
		"bridges the gap between user and machine"
	]
	
	return meanings[randi() % meanings.size()]

# Generate a random word and add to database
func generate_random_word():
	var phonemes = ["ba", "ca", "da", "fa", "ga", "ha", "ja", "ka", "la", "ma", 
					"na", "pa", "ra", "sa", "ta", "va", "za", "el", "en", "om", 
					"un", "in", "ex", "an", "or", "us", "um", "al", "ic", "is"]
	
	var word_length = randi() % 3 + 1
	var new_word = ""
	
	for i in range(word_length):
		new_word += phonemes[randi() % phonemes.size()]
	
	# Don't add if word already exists
	if words_database.has(new_word):
		return null
	
	# Determine word properties
	var type = word_types[randi() % word_types.size()]
	var categories = word_categories.keys()
	var category = categories[randi() % categories.size()]
	
	var is_divine = divine_inspiration and randf() < 0.1
	
	var word_data = {
		"type": type,
		"category": category,
		"meaning": generate_meaning(new_word),
		"connections": [],
		"frequency": 1,
		"divine": is_divine
	}
	
	words_database[new_word] = word_data
	stats["words_generated"] += 1
	
	if is_divine:
		stats["divine_interventions"] += 1
	
	# Find connections to existing words
	find_word_connections(new_word)
	
	emit_signal("word_discovered", new_word, word_data["meaning"])
	return new_word

# Find connections between words
func find_word_connections(word):
	if not words_database.has(word):
		return
		
	var word_data = words_database[word]
	var connections = []
	
	# Connect to words in the same category
	for other_word in words_database:
		if other_word == word:
			continue
			
		var other_data = words_database[other_word]
		
		# Strong connection if same category
		if other_data["category"] == word_data["category"]:
			connections.append(other_word)
			
		# Also connect if word is contained in the other
		elif word in other_word or other_word in word:
			connections.append(other_word)
			
		# Connect divine words
		elif word_data["divine"] and other_data["divine"]:
			connections.append(other_word)
	
	# Limit connections to the strongest ones
	if connections.size() > 5:
		connections = connections.slice(0, 5)
	
	word_data["connections"] = connections
	words_database[word] = word_data
	
	# Also add the reverse connections
	for other_word in connections:
		if words_database.has(other_word) and not word in words_database[other_word]["connections"]:
			words_database[other_word]["connections"].append(word)

# Generate a complete story
func generate_story():
	var story_id = "story_" + str(stats["stories_created"] + 1)
	
	# Select a theme based on bias
	var theme_categories = word_categories.keys()
	var primary_theme = theme_bias
	if randf() > 0.7:  # Sometimes select a random theme
		primary_theme = theme_categories[randi() % theme_categories.size()]
	
	# Get words from database for the theme
	var theme_words = []
	for word in words_database:
		if words_database[word]["category"] == primary_theme:
			theme_words.append(word)
	
	# If not enough theme words, add some random ones
	while theme_words.size() < 5 and words_database.size() > 0:
		var keys = words_database.keys()
		var random_word = keys[randi() % keys.size()]
		if not random_word in theme_words:
			theme_words.append(random_word)
	
	# Generate title
	var title_options = [
		"The " + capitalize_word(get_random_element(theme_words)),
		get_random_element(theme_words).capitalize() + " of " + get_random_element(theme_words),
		capitalize_word(get_random_element(theme_words)) + " and " + capitalize_word(get_random_element(theme_words)),
		"Journey to the " + capitalize_word(get_random_element(theme_words))
	]
	
	var title = title_options[randi() % title_options.size()]
	
	# Generate narrative segments
	var segments = []
	
	# Beginning
	var beginning = get_random_element(story_components["beginning"])
	beginning += ", " + get_random_element(theme_words) + " "
	beginning += get_random_verb() + " the " + get_random_element(theme_words) + "."
	segments.append(beginning)
	
	# Middle sections (complexity determines number)
	for i in range(complexity_level):
		var middle = get_random_element(story_components["middle"]) + ". "
		middle += "The " + get_random_element(theme_words) + " "
		middle += get_random_verb() + " with great " + get_random_element(theme_words) + "."
		
		if randf() < 0.5:
			middle += " " + capitalize_word(get_random_element(theme_words)) + " "
			middle += get_random_verb() + " in response."
		
		segments.append(middle)
	
	# Ending
	var ending = get_random_element(story_components["end"]) + ". "
	if divine_inspiration and randf() < 0.3:
		ending += "Thus, the divine purpose was fulfilled."
		stats["divine_interventions"] += 1
	else:
		ending += "The " + get_random_element(theme_words) + " remained forever changed."
	
	segments.append(ending)
	
	# Store the story
	var story = {
		"id": story_id,
		"title": title,
		"theme": primary_theme,
		"segments": segments,
		"words": theme_words,
		"timestamp": Time.get_unix_time_from_system(),
		"divine_inspired": divine_inspiration
	}
	
	stories[story_id] = story
	stats["stories_created"] += 1
	
	emit_signal("story_generated", story_id, title)
	return story

# Generate a narrative chain between two words
func generate_narrative_chain(start_word, end_word, max_steps=5):
	if not words_database.has(start_word) or not words_database.has(end_word):
		return null
	
	# Breadth-first search to find connection between words
	var visited = {start_word: true}
	var queue = [[start_word]]
	
	while queue.size() > 0:
		var path = queue.pop_front()
		var current = path[path.size() - 1]
		
		if current == end_word:
			return create_narrative_from_path(path)
		
		if path.size() >= max_steps:
			continue
		
		for connection in words_database[current]["connections"]:
			if not visited.has(connection):
				visited[connection] = true
				var new_path = path.duplicate()
				new_path.append(connection)
				queue.append(new_path)
	
	# If no direct path found, create a mythical connection
	return create_mythical_connection(start_word, end_word)

# Create narrative from a found path
func create_narrative_from_path(path):
	var narrative_id = "narrative_" + str(narrative_chains.size() + 1)
	var segments = []
	
	# Create introduction
	var intro = "The path from " + path[0] + " to " + path[path.size() - 1] + " unfolds:"
	segments.append(intro)
	
	# Create segments for each transition
	for i in range(path.size() - 1):
		var current = path[i]
		var next = path[i + 1]
		var current_data = words_database[current]
		var next_data = words_database[next]
		
		var transition
		if current_data["divine"] and next_data["divine"]:
			transition = "The divine essence of " + current + " transcends into " + next
		elif current_data["category"] == next_data["category"]:
			transition = "From " + current + ", the " + current_data["category"] + " energies flow naturally to " + next
		else:
			transition = current.capitalize() + " transforms unexpectedly into " + next
		
		segments.append(transition)
	
	# Create conclusion
	var conclusion = "Thus " + path[0] + " and " + path[path.size() - 1] + " are forever connected in the system."
	segments.append(conclusion)
	
	var narrative = {
		"id": narrative_id,
		"path": path,
		"segments": segments,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	narrative_chains[narrative_id] = narrative
	return narrative

# Create a mythical connection when no direct path exists
func create_mythical_connection(start_word, end_word):
	var narrative_id = "narrative_" + str(narrative_chains.size() + 1)
	var segments = []
	
	var start_data = words_database[start_word]
	var end_data = words_database[end_word]
	
	# Create mythical introduction
	var intro = "Though separated by the void, " + start_word + " and " + end_word + " share a mysterious bond:"
	segments.append(intro)
	
	# Create mythical connection
	var mythical = "The " + start_data["type"] + " of " + start_word + " sends echoes across "
	mythical += "dimensional boundaries, where they are received by the " + end_data["type"] + " of " + end_word + "."
	segments.append(mythical)
	
	if divine_inspiration:
		segments.append("This connection exists by divine will, beyond the understanding of the system.")
		stats["divine_interventions"] += 1
	else:
		segments.append("This connection defies normal logic but exists nonetheless in the quantum fabric of the system.")
	
	var narrative = {
		"id": narrative_id,
		"path": [start_word, "???", end_word],
		"segments": segments,
		"mythical": true,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	narrative_chains[narrative_id] = narrative
	return narrative

# Helper functions
func get_random_element(array):
	if array.size() == 0:
		return ""
	return array[randi() % array.size()]

func get_random_verb():
	var verbs = ["illuminated", "transformed", "empowered", "challenged", 
				"awakened", "enveloped", "transcended", "embraced",
				"manifested", "evolved", "integrated", "harmonized"]
	return verbs[randi() % verbs.size()]

func capitalize_word(word):
	if word.length() == 0:
		return ""
	return word[0].to_upper() + word.substr(1)

# API for LuminusOS terminal

func cmd_word(args):
	if args.size() == 0:
		return "Usage: word <command> [parameters]"
	
	match args[0]:
		"get":
			if args.size() < 2:
				return "Usage: word get <word>"
			var word = args[1]
			if words_database.has(word):
				return format_word_info(word)
			else:
				return "Word not found: " + word
		
		"create":
			if args.size() < 2:
				return "Usage: word create <word>"
			var word = args[1]
			
			if words_database.has(word):
				return "Word already exists: " + word
			
			# Optional parameters
			var type = "noun"
			var category = "spiritual"
			
			if args.size() >= 3 and args[2] in word_types:
				type = args[2]
			
			if args.size() >= 4 and args[3] in word_categories:
				category = args[3]
			
			var word_data = {
				"type": type,
				"category": category,
				"meaning": generate_meaning(word),
				"connections": [],
				"frequency": 1,
				"divine": divine_inspiration and randf() < 0.1
			}
			
			words_database[word] = word_data
			stats["words_generated"] += 1
			
			find_word_connections(word)
			emit_signal("word_discovered", word, word_data["meaning"])
			
			return "Created word: " + word + " (" + type + ", " + category + ")"
		
		"list":
			var category_filter = ""
			if args.size() >= 2:
				category_filter = args[1]
			
			return list_words(category_filter)
		
		"random":
			var count = 1
			if args.size() >= 2 and args[1].is_valid_int():
				count = int(args[1])
			
			var result = "Generated words:\n"
			for i in range(count):
				var word = generate_random_word()
				if word:
					result += word + ": " + words_database[word]["meaning"] + "\n"
			
			return result
		
		"divine":
			if args.size() >= 2:
				if args[1].to_lower() == "on":
					divine_inspiration = true
					return "Divine inspiration enabled"
				elif args[1].to_lower() == "off":
					divine_inspiration = false
					return "Divine inspiration disabled"
			
			return "Divine inspiration is currently " + ("enabled" if divine_inspiration else "disabled")
		
		"connect":
			if args.size() < 3:
				return "Usage: word connect <word1> <word2>"
			var word1 = args[1]
			var word2 = args[2]
			
			if not words_database.has(word1):
				return "Word not found: " + word1
			if not words_database.has(word2):
				return "Word not found: " + word2
			
			if not word2 in words_database[word1]["connections"]:
				words_database[word1]["connections"].append(word2)
			
			if not word1 in words_database[word2]["connections"]:
				words_database[word2]["connections"].append(word1)
			
			return "Connected " + word1 + " and " + word2
		
		_:
			return "Unknown word command. Try 'get', 'create', 'list', 'random', 'divine', or 'connect'"

func cmd_story(args):
	if args.size() == 0:
		return "Usage: story <command> [parameters]"
	
	match args[0]:
		"generate":
			var story = generate_story()
			return "Generated story: " + story["title"] + "\nID: " + story["id"]
		
		"get":
			if args.size() < 2:
				return "Usage: story get <story_id>"
			var story_id = args[1]
			if stories.has(story_id):
				return format_story(story_id)
			else:
				return "Story not found: " + story_id
		
		"list":
			var theme_filter = ""
			if args.size() >= 2:
				theme_filter = args[1]
			
			return list_stories(theme_filter)
		
		"theme":
			if args.size() < 2:
				return "Current theme bias: " + theme_bias
			
			var new_theme = args[1]
			if not new_theme in word_categories:
				return "Unknown theme. Available themes: " + ", ".join(word_categories.keys())
			
			theme_bias = new_theme
			return "Theme bias set to: " + theme_bias
		
		"complexity":
			if args.size() < 2:
				return "Current complexity level: " + str(complexity_level)
			
			if args[1].is_valid_int():
				var new_level = int(args[1])
				if new_level >= 1 and new_level <= 5:
					complexity_level = new_level
					return "Complexity level set to: " + str(complexity_level)
				else:
					return "Complexity must be between 1 and 5"
			
			return "Invalid complexity level"
		
		_:
			return "Unknown story command. Try 'generate', 'get', 'list', 'theme', or 'complexity'"

func cmd_narrative(args):
	if args.size() == 0:
		return "Usage: narrative <command> [parameters]"
	
	match args[0]:
		"generate":
			if args.size() < 3:
				return "Usage: narrative generate <word1> <word2>"
			var word1 = args[1]
			var word2 = args[2]
			
			if not words_database.has(word1):
				return "Word not found: " + word1
			if not words_database.has(word2):
				return "Word not found: " + word2
			
			var max_steps = 5
			if args.size() >= 4 and args[3].is_valid_int():
				max_steps = int(args[3])
			
			var narrative = generate_narrative_chain(word1, word2, max_steps)
			if narrative:
				return "Generated narrative between " + word1 + " and " + word2 + "\nID: " + narrative["id"]
			else:
				return "Failed to generate narrative"
		
		"get":
			if args.size() < 2:
				return "Usage: narrative get <narrative_id>"
			var narrative_id = args[1]
			if narrative_chains.has(narrative_id):
				return format_narrative(narrative_id)
			else:
				return "Narrative not found: " + narrative_id
		
		"list":
			return list_narratives()
		
		_:
			return "Unknown narrative command. Try 'generate', 'get', or 'list'"

func cmd_tick(args):
	if args.size() == 0:
		return "Auto-tick: " + ("Enabled" if auto_tick_enabled else "Disabled") + ", Interval: " + str(tick_interval) + "s"
	
	match args[0]:
		"on":
			auto_tick_enabled = true
			return "Auto-tick enabled"
			
		"off":
			auto_tick_enabled = false
			return "Auto-tick disabled"
			
		"interval":
			if args.size() < 2:
				return "Current tick interval: " + str(tick_interval) + "s"
			if args[1].is_valid_float():
				var new_interval = float(args[1])
				if new_interval > 0.1:
					tick_interval = new_interval
					return "Tick interval set to " + str(tick_interval) + "s"
				else:
					return "Tick interval must be at least 0.1s"
			return "Invalid tick interval"
			
		"once":
			process_tick()
			return "Manual tick processed"
			
		_:
			return "Unknown tick command. Try 'on', 'off', 'interval', or 'once'"

func cmd_stats():
	var stats_str = "Word/Story System Statistics:\n"
	stats_str += "Words generated: " + str(stats["words_generated"]) + "\n"
	stats_str += "Stories created: " + str(stats["stories_created"]) + "\n"
	stats_str += "Divine interventions: " + str(stats["divine_interventions"]) + "\n"
	stats_str += "Narrative chains: " + str(narrative_chains.size()) + "\n"
	stats_str += "Word database size: " + str(words_database.size()) + " words\n"
	return stats_str

# Helper functions for formatting output

func format_word_info(word):
	if not words_database.has(word):
		return "Word not found"
	
	var data = words_database[word]
	var info = "Word: " + word + "\n"
	info += "Type: " + data["type"] + "\n"
	info += "Category: " + data["category"] + "\n"
	info += "Meaning: " + data["meaning"] + "\n"
	
	if data["divine"]:
		info += "Status: Divine word\n"
	
	info += "Connections: "
	if data["connections"].size() > 0:
		info += ", ".join(data["connections"])
	else:
		info += "None"
	
	return info

func format_story(story_id):
	if not stories.has(story_id):
		return "Story not found"
	
	var story = stories[story_id]
	var info = "Story: " + story["title"] + " (ID: " + story_id + ")\n"
	info += "Theme: " + story["theme"] + "\n"
	
	if story["divine_inspired"]:
		info += "Status: Divinely inspired\n"
	
	info += "\n--- Narrative ---\n"
	for segment in story["segments"]:
		info += segment + "\n"
	
	return info

func format_narrative(narrative_id):
	if not narrative_chains.has(narrative_id):
		return "Narrative not found"
	
	var narrative = narrative_chains[narrative_id]
	var info = "Narrative: " + narrative_id + "\n"
	info += "Path: " + " -> ".join(narrative["path"]) + "\n"
	
	if narrative.has("mythical") and narrative["mythical"]:
		info += "Type: Mythical connection\n"
	
	info += "\n--- Segments ---\n"
	for segment in narrative["segments"]:
		info += segment + "\n"
	
	return info

func list_words(category_filter=""):
	var count = 0
	var list = "Word Database:\n"
	
	for word in words_database:
		if category_filter == "" or words_database[word]["category"] == category_filter:
			list += word
			if words_database[word]["divine"]:
				list += " (divine)"
			list += " - " + words_database[word]["type"] + ", " + words_database[word]["category"] + "\n"
			count += 1
			
			# Limit list size for display
			if count >= 20:
				list += "... and " + str(words_database.size() - 20) + " more words\n"
				break
	
	if count == 0:
		list += "No words found"
	else:
		list += "\nTotal: " + str(count) + " words"
	
	return list

func list_stories(theme_filter=""):
	var count = 0
	var list = "Stories:\n"
	
	for story_id in stories:
		var story = stories[story_id]
		if theme_filter == "" or story["theme"] == theme_filter:
			list += story_id + ": " + story["title"]
			if story["divine_inspired"]:
				list += " (divine)"
			list += "\n"
			count += 1
			
			# Limit list size for display
			if count >= 10:
				list += "... and " + str(stories.size() - 10) + " more stories\n"
				break
	
	if count == 0:
		list += "No stories found"
	else:
		list += "\nTotal: " + str(count) + " stories"
	
	return list

func list_narratives():
	var count = 0
	var list = "Narrative Chains:\n"
	
	for narrative_id in narrative_chains:
		var narrative = narrative_chains[narrative_id]
		list += narrative_id + ": " + " -> ".join(narrative["path"])
		if narrative.has("mythical") and narrative["mythical"]:
			list += " (mythical)"
		list += "\n"
		count += 1
		
		# Limit list size for display
		if count >= 10:
			list += "... and " + str(narrative_chains.size() - 10) + " more narratives\n"
			break
	
	if count == 0:
		list += "No narratives found"
	else:
		list += "\nTotal: " + str(count) + " narratives"
	
	return list
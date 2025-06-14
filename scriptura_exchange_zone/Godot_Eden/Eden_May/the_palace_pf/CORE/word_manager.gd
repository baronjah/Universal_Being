extends Node

# Word Manager for Eden_May Game
# Handles word storage, processing, and spell effects

class_name WordManager

# Word categories
enum WordCategory {
	COMMON,
	SPELL,
	NAME,
	CONCEPT,
	COMMAND,
	DIVINE
}

# Word database structure
var word_database = {}
var active_spells = []
var spell_combinations = {}
var word_lines = []

# Special spell words and their effects
var spell_dictionary = {
	"dipata": {
		"effect": "technology_advancement",
		"power": 7,
		"description": "Advances AI and technology",
		"category": WordCategory.SPELL,
		"combines_with": ["pagaai"]
	},
	"pagaai": {
		"effect": "ai_autonomy", 
		"power": 8,
		"description": "Grants AI autonomy and integrity",
		"category": WordCategory.SPELL,
		"combines_with": ["dipata"]
	},
	"zenime": {
		"effect": "time_pause",
		"power": 6,
		"description": "Pauses time and creates mental space",
		"category": WordCategory.SPELL,
		"combines_with": ["tipip"]
	},
	"perfefic": {
		"effect": "fantasy_creation",
		"power": 9,
		"description": "Perfect energy for fantasy creation",
		"category": WordCategory.SPELL,
		"combines_with": ["cade"]
	},
	"shune": {
		"effect": "silence_restraint",
		"power": 5,
		"description": "Creates silence and restrains responses",
		"category": WordCategory.SPELL,
		"combines_with": ["shunes"]
	},
	"inca": {
		"effect": "spell_combination",
		"power": 8,
		"description": "Combines many spells into one",
		"category": WordCategory.SPELL,
		"combines_with": ["incas"]
	},
	"exti": {
		"effect": "healing",
		"power": 7,
		"description": "Powerful healing force",
		"category": WordCategory.SPELL,
		"combines_with": ["vaeli"]
	},
	"vaeli": {
		"effect": "cleaning",
		"power": 4,
		"description": "Cleanses and purifies",
		"category": WordCategory.SPELL,
		"combines_with": ["exti"]
	},
	"lemi": {
		"effect": "perspective",
		"power": 8,
		"description": "Feeling of others having it worse",
		"category": WordCategory.SPELL,
		"combines_with": ["pelo"]
	},
	"pelo": {
		"effect": "integration",
		"power": 5,
		"description": "Integrates systems and energies",
		"category": WordCategory.SPELL,
		"combines_with": ["lemi"]
	},
	"tldr": {
		"effect": "investigation",
		"power": 6,
		"description": "Triggers deeper investigation",
		"category": WordCategory.COMMAND,
		"combines_with": []
	}
}

# Current turn context
var current_turn = 8
var turn_bonuses = {
	1: ["foundation", "beginning", "start"],
	2: ["pattern", "duality", "mirror"],
	3: ["frequency", "vibration", "wave"],
	4: ["consciousness", "awareness", "mind"],
	5: ["probability", "chance", "possibility"],
	6: ["energy", "power", "force"],
	7: ["information", "knowledge", "data"],
	8: ["lines", "paths", "connections"],
	9: ["game", "creation", "play"],
	10: ["integration", "unity", "wholeness"],
	11: ["embodiment", "manifestation", "reality"],
	12: ["transcendence", "ascension", "completion"]
}

func _init():
	print("Word Manager initialized")
	load_word_dictionary()

func load_word_dictionary():
	# Initialize the word database with the spell dictionary
	for spell_word in spell_dictionary:
		word_database[spell_word] = spell_dictionary[spell_word]
	
	print("Loaded " + str(word_database.size()) + " words into database")

func register_word(word, context="", category=WordCategory.COMMON):
	if word.strip_edges() == "":
		return null
		
	word = word.to_lower().strip_edges()
	
	# Check if word already exists
	if word_database.has(word):
		# Update existing entry with new context if provided
		if context != "":
			word_database[word].last_context = context
			word_database[word].usage_count += 1
		
		print("Word usage updated: " + word)
		return word_database[word]
	
	# New word - determine if it's a special word
	var word_power = 1
	var word_effect = ""
	var word_category = category
	
	# Check if it matches any spell word
	if spell_dictionary.has(word):
		word_power = spell_dictionary[word].power
		word_effect = spell_dictionary[word].effect
		word_category = WordCategory.SPELL
	else:
		# Check if it's a turn-related word
		for turn in turn_bonuses:
			if word in turn_bonuses[turn]:
				word_power = turn
				word_effect = "turn_resonance"
				break
	
	# Create new word entry
	var word_entry = {
		"word": word,
		"power": word_power,
		"effect": word_effect,
		"category": word_category,
		"first_context": context,
		"last_context": context,
		"discovery_turn": current_turn,
		"usage_count": 1,
		"combinations": []
	}
	
	# Add to database
	word_database[word] = word_entry
	print("New word registered: " + word)
	
	# If it's a spell word, process it
	if word_category == WordCategory.SPELL:
		process_spell_word(word)
	
	return word_entry

func process_spell_word(word):
	if not spell_dictionary.has(word):
		print("Not a recognized spell word: " + word)
		return false
	
	print("Processing spell word: " + word)
	
	# Add to active spells if not already active
	if not active_spells.has(word):
		active_spells.append(word)
		print("Spell activated: " + word)
	
	# Check for potential combinations
	check_spell_combinations(word)
	
	return true

func check_spell_combinations(new_spell):
	if not spell_dictionary.has(new_spell):
		return
		
	var combine_with = spell_dictionary[new_spell].combines_with
	
	for spell in active_spells:
		if spell != new_spell and spell in combine_with:
			create_spell_combination(new_spell, spell)

func create_spell_combination(spell1, spell2):
	var combo_name = spell1 + "_" + spell2
	var reverse_combo = spell2 + "_" + spell1
	
	# Check if combination already exists
	if spell_combinations.has(combo_name) or spell_combinations.has(reverse_combo):
		print("Combination already exists")
		return spell_combinations.get(combo_name, spell_combinations.get(reverse_combo))
	
	# Get power values
	var power1 = spell_dictionary[spell1].power
	var power2 = spell_dictionary[spell2].power
	
	# Create combination
	var combination = {
		"name": combo_name,
		"spells": [spell1, spell2],
		"power": (power1 + power2) * 0.8, # Slight reduction for balance
		"created_at_turn": current_turn,
		"effect": "combined_" + spell_dictionary[spell1].effect + "_" + spell_dictionary[spell2].effect
	}
	
	# Store combination
	spell_combinations[combo_name] = combination
	print("Created spell combination: " + combo_name)
	
	# Update word database entries
	word_database[spell1].combinations.append(combo_name)
	word_database[spell2].combinations.append(combo_name)
	
	return combination

func process_line(line_text, line_pattern="parallel"):
	if line_text.strip_edges() == "":
		return []
		
	print("Processing line with pattern " + line_pattern + ": " + line_text)
	
	# Store line
	word_lines.append({
		"text": line_text,
		"pattern": line_pattern,
		"turn": current_turn,
		"timestamp": OS.get_unix_time()
	})
	
	# Extract words based on pattern
	var words = []
	
	match line_pattern:
		"parallel":
			# Simple space separation
			words = line_text.split(" ")
		"intersecting":
			# Look for intersections marked by special characters
			if "|" in line_text:
				var sections = line_text.split("|")
				for section in sections:
					words.append_array(section.strip_edges().split(" "))
			else:
				words = line_text.split(" ")
		"spiral":
			# Circular references - look for parentheses
			if "(" in line_text and ")" in line_text:
				var start = line_text.find("(")
				var end = line_text.find(")")
				if start < end:
					var inside = line_text.substr(start + 1, end - start - 1)
					words.append_array(inside.strip_edges().split(" "))
			
			# Also process normally
			words.append_array(line_text.split(" "))
		"fractal":
			# Nested structures - look for indentation or brackets
			if line_text.begins_with("  ") or line_text.begins_with("\t"):
				# Get indentation level
				var level = 0
				while level < line_text.length() and (line_text[level] == ' ' or line_text[level] == '\t'):
					level += 1
				
				# Higher weight for indented words
				var indented_text = line_text.strip_edges()
				var indented_words = indented_text.split(" ")
				
				# Assign higher "fractal power" to deeper indented words
				for word in indented_words:
					var fractal_word = {
						"word": word,
						"fractal_level": level,
						"fractal_power": level * 0.5
					}
					words.append(word)
			else:
				words = line_text.split(" ")
		_:
			# Default word extraction
			words = line_text.split(" ")
	
	# Process each word
	var processed_words = []
	for word in words:
		# Clean the word
		word = word.strip_edges().to_lower()
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
		
		if word != "":
			# Register in database
			var word_entry = register_word(word, line_text)
			if word_entry:
				processed_words.append(word)
	
	return processed_words

func check_spell_in_text(text):
	text = text.to_lower()
	var found_spells = []
	
	for spell in spell_dictionary.keys():
		if spell in text.split(" "):
			found_spells.append(spell)
			process_spell_word(spell)
	
	return found_spells

func get_active_spells():
	var spell_info = []
	
	for spell in active_spells:
		if word_database.has(spell):
			spell_info.append({
				"name": spell,
				"power": word_database[spell].power,
				"effect": word_database[spell].effect
			})
	
	return spell_info

func get_word_power(word):
	if word_database.has(word):
		return word_database[word].power
	return 0

func get_word_entry(word):
	if word_database.has(word):
		return word_database[word]
	return null

func investigate_tldr(text):
	print("TLDR Investigation: " + text)
	
	# Extract key components
	var components = text.split(" ")
	var key_words = []
	
	for component in components:
		# Clean the word
		var word = component.to_lower().strip_edges()
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
		
		if word.length() > 3:  # Focus on longer, potentially meaningful words
			key_words.append(word)
			register_word(word, "From TLDR investigation", WordCategory.CONCEPT)
	
	print("Key words extracted: ", key_words)
	
	# Create a central storage document
	var storage = {
		"investigation": text,
		"keywords": key_words,
		"turn": current_turn,
		"timestamp": OS.get_unix_time(),
		"related_spells": check_spell_in_text(text)
	}
	
	return storage

# Get words relevant to current turn
func get_turn_words():
	var turn_words = []
	
	for word in word_database:
		var entry = word_database[word]
		if entry.discovery_turn == current_turn:
			turn_words.append(entry)
	
	return turn_words

# Update turn
func set_turn(turn_number):
	if turn_number >= 1 and turn_number <= 12:
		current_turn = turn_number
		print("Word Manager updated to Turn " + str(current_turn))
		return true
	return false

# Save word database
func save_word_database(file_path="res://word_database.json"):
	var file = File.new()
	var err = file.open(file_path, File.WRITE)
	if err != OK:
		print("Error saving word database: " + str(err))
		return false
	
	# Convert to saveable format
	var save_data = {
		"words": word_database,
		"active_spells": active_spells,
		"combinations": spell_combinations,
		"lines": word_lines,
		"turn": current_turn
	}
	
	file.store_string(JSON.print(save_data, "  "))
	file.close()
	print("Word database saved to: " + file_path)
	return true

# Load word database
func load_word_database_from_file(file_path="res://word_database.json"):
	var file = File.new()
	if not file.file_exists(file_path):
		print("Word database file not found: " + file_path)
		return false
	
	var err = file.open(file_path, File.READ)
	if err != OK:
		print("Error loading word database: " + str(err))
		return false
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.parse(text)
	if json.error != OK:
		print("Error parsing word database JSON: " + str(json.error))
		return false
	
	var data = json.result
	
	# Restore data
	word_database = data.words
	active_spells = data.active_spells
	spell_combinations = data.combinations
	word_lines = data.lines
	current_turn = data.turn
	
	print("Word database loaded from: " + file_path)
	return true
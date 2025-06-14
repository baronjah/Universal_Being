extends Node

class_name WordProcessor

# ----- SIGNALS -----
signal word_processed(word, power)
signal word_manifested(word, position, power, color)
signal reality_created(reality_data)
signal memory_stored(memory_data)
signal divine_level_increased(old_level, new_level)

# ----- CONSTANTS -----
const POWER_THRESHOLD = 50  # Words with power > 50 create manifestations
const REALITY_THRESHOLD = 200  # Power needed for persistent reality
const GOD_WORD_MULTIPLIER = 2.0  # Multiplier for divine words
const MAX_WORD_POWER = 100.0  # Maximum power of a single word

# ----- WORD DICTIONARIES -----
var divine_words = {
	# Core cosmic concepts
	"genesis": 90,
	"formation": 85,
	"complexity": 80,
	"consciousness": 95,
	"awakening": 90,
	"enlightenment": 95,
	"manifestation": 85,
	"connection": 75,
	"harmony": 80,
	"transcendence": 90,
	"unity": 95,
	"beyond": 100,
	
	# Divine concepts
	"divine": 85,
	"god": 90,
	"cosmic": 70,
	"eternal": 75,
	"infinite": 80,
	"omniscient": 85,
	"omnipotent": 90,
	"celestial": 70,
	"sacred": 65,
	"spirit": 60,
	"soul": 65,
	"creation": 75,
	"universe": 80,
	"reality": 75,
	"dimension": 70,
	"ascension": 75,
	"perfection": 80,
	
	# Reality types
	"physical": 60,
	"digital": 65,
	"astral": 70,
	"quantum": 75,
	"memory": 65,
	"dream": 70,
	
	# High concept words
	"zero": 50,
	"one": 45,
	"infinity": 80,
	"void": 60,
	"chaos": 70,
	"order": 65,
	"balance": 65,
	"truth": 70,
	"love": 75,
	"peace": 65,
	"wisdom": 70,
	"knowledge": 65,
	"power": 70,
	"creation": 75,
	"destruction": 70,
	"light": 60,
	"dark": 60,
	"life": 75,
	"death": 70,
	"time": 75,
	"space": 70,
	"mind": 65,
	"thought": 60,
	"energy": 65,
	"force": 60,
	"being": 65,
	"presence": 60,
	"essence": 65,
	"nature": 60,
	"symbol": 55,
	"gate": 60,
	"moon": 55,
	"sun": 60,
	"star": 55,
	"planet": 50,
	"galaxy": 65,
	"cosmos": 70
}

# ----- STATE VARIABLES -----
var active_words = {}  # Currently manifested words
var word_history = []  # History of processed words
var active_realities = []  # Currently active realities
var memories = {
	1: [],  # Tier 1: Temporary/recent
	2: [],  # Tier 2: Important
	3: []   # Tier 3: Eternal/fundamental
}

# Divine account stats
var divine_stats = {
	"level": 1,
	"words_processed": 0,
	"powerful_words": 0,
	"realities_created": 0,
	"highest_word_power": 0,
	"creation_timestamp": Time.get_unix_time_from_system()
}

# Current reality and dimension
var current_reality = "DIGITAL"
var current_dimension = 3

# ----- INITIALIZATION -----
func _ready():
	print("Divine Word Processor initializing...")
	print("Loaded %d divine words" % divine_words.size())
	
	# Load saved state if available
	_load_state()

# ----- WORD PROCESSING -----
func process_text(text: String, source: String = "user", tier: int = 1) -> Dictionary:
	# Prepare results
	var result = {
		"original_text": text,
		"words_processed": 0,
		"total_power": 0,
		"powerful_words": [],
		"source": source,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Skip empty text
	if text.strip_edges().is_empty():
		return result
		
	# Extract words
	var words = _extract_words(text)
	result.words_processed = words.size()
	
	# Process each word
	for word in words:
		var word_power = calculate_word_power(word.to_lower())
		result.total_power += word_power
		
		# Track powerful words
		if word_power > POWER_THRESHOLD / 2:
			result.powerful_words.append({
				"word": word,
				"power": word_power
			})
			
			# Update divine stats
			divine_stats.powerful_words += 1
			if word_power > divine_stats.highest_word_power:
				divine_stats.highest_word_power = word_power
		
		# Emit signal for each processed word
		emit_signal("word_processed", word, word_power)
		
		# Update word count
		divine_stats.words_processed += 1
	
	# Create memory if text has content
	if words.size() > 0:
		_create_memory(text, tier, result.total_power, result.powerful_words)
	
	# Check if we should create a reality impact
	if result.total_power > POWER_THRESHOLD:
		_create_reality_impact(text, result.powerful_words, result.total_power)
	
	# Check for divine level increase
	_check_level_increase(result.total_power)
	
	return result

func calculate_word_power(word: String) -> float:
	# Check if it's a divine word
	if divine_words.has(word):
		return divine_words[word]
	
	# Calculate power for non-divine words
	var base_power = 1.0
	
	# Longer words have slightly more power
	var length_factor = clamp(float(word.length()) / 10.0, 0.1, 1.0)
	
	# Words starting with capital letters get a small boost
	var capital_factor = 1.0
	if word.length() > 0 and word[0].to_upper() == word[0]:
		capital_factor = 1.2
	
	# Dimension factor - higher dimensions amplify word power
	var dimension_factor = 0.5 + (float(current_dimension) / 12.0)
	
	# Reality factor
	var reality_factor = 1.0
	match current_reality:
		"PHYSICAL": reality_factor = 0.8
		"DIGITAL": reality_factor = 1.0
		"ASTRAL": reality_factor = 1.3
		"QUANTUM": reality_factor = 1.5
		"MEMORY": reality_factor = 1.2
		"DREAM": reality_factor = 1.8
	
	# Calculate final power
	var power = base_power * length_factor * capital_factor * dimension_factor * reality_factor
	
	# Clamp to reasonable values
	return clamp(power, 0.1, 10.0)

func manifest_word(word: String, position: Vector3 = Vector3.ZERO) -> Dictionary:
	# Calculate word power
	var power = calculate_word_power(word.to_lower())
	
	# Generate color based on word and power
	var color = _generate_word_color(word, power)
	
	# Create word data
	var word_id = word + "_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
	var word_data = {
		"id": word_id,
		"word": word,
		"power": power,
		"position": position,
		"color": color,
		"scale": 1.0 + (power / 50.0),  # Larger scale for more powerful words
		"rotation": Vector3(randf(), randf(), randf()) * TAU,  # Random rotation
		"timestamp": Time.get_unix_time_from_system(),
		"reality": current_reality,
		"dimension": current_dimension,
		"connections": []
	}
	
	# Add to active words
	active_words[word_id] = word_data
	
	# Add to history
	word_history.append({
		"word": word,
		"power": power,
		"timestamp": Time.get_unix_time_from_system(),
		"operation": "manifest"
	})
	
	# Emit signal
	emit_signal("word_manifested", word, position, power, color)
	
	print("Word manifested: '%s' with power %.2f" % [word, power])
	return word_data

# ----- MEMORY FUNCTIONS -----
func _create_memory(text: String, tier: int, power: float, powerful_words: Array) -> Dictionary:
	# Ensure valid tier
	tier = clamp(tier, 1, 3)
	
	# Create memory data
	var memory_id = "memory_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
	var memory = {
		"id": memory_id,
		"text": text,
		"tier": tier,
		"power": power,
		"powerful_words": powerful_words,
		"timestamp": Time.get_unix_time_from_system(),
		"reality": current_reality,
		"dimension": current_dimension
	}
	
	# Store in appropriate tier
	memories[tier].append(memory)
	
	# Emit signal
	emit_signal("memory_stored", memory)
	
	# Very powerful memories automatically promote to higher tier
	if power > REALITY_THRESHOLD and tier < 3:
		var promoted_memory = memory.duplicate()
		promoted_memory.tier = 3
		promoted_memory.id = "promoted_" + memory_id
		memories[3].append(promoted_memory)
		print("Memory automatically promoted to Tier 3 due to high power (%.2f)" % power)
	
	# Memory management - limit size of lower tiers
	_manage_memory_tiers()
	
	return memory

func _manage_memory_tiers():
	# Tier 1: Keep only most recent 100
	if memories[1].size() > 100:
		memories[1].sort_custom(func(a, b): return a.timestamp > b.timestamp)
		while memories[1].size() > 100:
			memories[1].pop_back()
	
	# Tier 2: Keep only most recent 50
	if memories[2].size() > 50:
		memories[2].sort_custom(func(a, b): return a.timestamp > b.timestamp)
		while memories[2].size() > 50:
			memories[2].pop_back()
	
	# Tier 3 is eternal, keep all

# ----- REALITY FUNCTIONS -----
func _create_reality_impact(source_text: String, powerful_words: Array, total_power: float) -> Dictionary:
	# Create reality data
	var reality_id = "reality_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
	
	# Calculate persistence based on power
	var is_persistent = total_power > REALITY_THRESHOLD
	var duration = is_persistent ? -1 : int(total_power * 30)  # -1 = permanent, otherwise seconds
	
	var reality = {
		"id": reality_id,
		"source_text": source_text,
		"powerful_words": powerful_words,
		"total_power": total_power,
		"timestamp": Time.get_unix_time_from_system(),
		"is_persistent": is_persistent,
		"duration": duration,
		"active": true,
		"reality_type": current_reality,
		"dimension": current_dimension
	}
	
	# Add to realities list
	active_realities.append(reality)
	divine_stats.realities_created += 1
	
	# Log creation
	print("Reality impact created with power %.2f" % total_power)
	if is_persistent:
		print("This reality is PERSISTENT due to high power level!")
	
	# Emit signal
	emit_signal("reality_created", reality)
	
	return reality

# ----- HELPER FUNCTIONS -----
func _extract_words(text: String) -> Array:
	# Split text into words
	var words = []
	var raw_words = text.split(" ", false)
	
	for raw_word in raw_words:
		# Remove punctuation
		var word = raw_word.strip_edges()
		# Simple punctuation removal - could be improved
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "").replace("\"", "")
		
		if word.length() > 0:
			words.append(word)
	
	return words

func _generate_word_color(word: String, power: float) -> Color:
	# Generate consistent color based on word
	var hash_val = 0
	for i in range(word.length()):
		hash_val = ((hash_val << 5) - hash_val) + word.unicode_at(i)
	
	# Generate RGB values from hash
	var r = (hash_val & 0xFF) / 255.0
	var g = ((hash_val >> 8) & 0xFF) / 255.0
	var b = ((hash_val >> 16) & 0xFF) / 255.0
	
	# Adjust brightness based on power
	var brightness = clamp(0.5 + (power / 100.0), 0.5, 1.0)
	var saturation = clamp(0.5 + (power / 150.0), 0.5, 1.0)
	
	# Combine factors
	var color = Color(r, g, b, 1.0)
	
	# Convert to HSV to adjust brightness and saturation
	var hsv = color.to_hsv()
	hsv.v = brightness  # Value (brightness)
	hsv.s = saturation  # Saturation
	
	return Color.from_hsv(hsv.h, hsv.s, hsv.v, 1.0)

func _check_level_increase(power_gained: float):
	var level_increase = int(power_gained / 100)
	if level_increase > 0:
		var old_level = divine_stats.level
		divine_stats.level += level_increase
		emit_signal("divine_level_increased", old_level, divine_stats.level)
		print("Divine level increased: %d → %d" % [old_level, divine_stats.level])

# ----- STATE MANAGEMENT -----
func _save_state():
	var save_data = {
		"divine_stats": divine_stats,
		"active_words": active_words,
		"active_realities": active_realities,
		"memories": memories,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Failed to access user directory")
		return
	
	if not dir.dir_exists("word_data"):
		dir.make_dir("word_data")
	
	var file = FileAccess.open("user://word_data/word_processor_state.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Word processor state saved")
	else:
		push_error("Failed to save word processor state")

func _load_state():
	if not FileAccess.file_exists("user://word_data/word_processor_state.json"):
		return
	
	var file = FileAccess.open("user://word_data/word_processor_state.json", FileAccess.READ)
	if not file:
		push_error("Failed to load word processor state")
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		var data = json.get_data()
		divine_stats = data.get("divine_stats", divine_stats)
		active_words = data.get("active_words", {})
		active_realities = data.get("active_realities", [])
		
		# Memories need special handling to maintain the tier structure
		var saved_memories = data.get("memories", {})
		for tier in saved_memories:
			if memories.has(int(tier)):
				memories[int(tier)] = saved_memories[tier]
		
		print("Word processor state loaded")
	else:
		push_error("JSON Parse Error: " + json.get_error_message())

# ----- PUBLIC API -----
func get_active_words() -> Dictionary:
	return active_words

func get_memories_by_tier(tier: int) -> Array:
	if tier >= 1 and tier <= 3:
		return memories[tier]
	return []

func get_divine_status() -> Dictionary:
	var status = "Novice Creator"
	var level = divine_stats.level
	
	if level > 500:
		status = "Supreme Deity"
	elif level > 200:
		status = "Greater God"
	elif level > 100:
		status = "Lesser God"
	elif level > 50:
		status = "Demigod"
	elif level > 20:
		status = "Divine Aspirant"
	
	return {
		"level": level,
		"status": status,
		"words_processed": divine_stats.words_processed,
		"powerful_words": divine_stats.powerful_words,
		"realities_created": divine_stats.realities_created,
		"highest_word_power": divine_stats.highest_word_power,
		"memory_tier1": memories[1].size(),
		"memory_tier2": memories[2].size(),
		"memory_tier3": memories[3].size(),
		"active_words": active_words.size(),
		"active_realities": active_realities.size()
	}

func set_reality_context(reality: String, dimension: int):
	current_reality = reality
	current_dimension = dimension
	print("Word processor context: Reality=%s, Dimension=%d" % [reality, dimension])

func save_game() -> void:
	_save_state()
	
func create_word_at_position(word: String, position: Vector3) -> Dictionary:
	return manifest_word(word, position)
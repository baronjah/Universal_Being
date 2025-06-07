extends Node
class_name WordProcessorTasks

# Word processor functions designed for multi-threaded execution
# Each function is designed to be run as a separate task in ThreadManager
# All naming follows snake_case convention

# Constants for word power calculation
const POWER_TIERS = {
	"TRIVIAL": {"min": 0, "max": 10, "color": Color(0.5, 0.5, 0.5)},
	"MINOR": {"min": 10, "max": 50, "color": Color(0.0, 0.7, 1.0)},
	"MAJOR": {"min": 50, "max": 100, "color": Color(0.0, 1.0, 0.5)},
	"EXCEPTIONAL": {"min": 100, "max": 200, "color": Color(1.0, 0.8, 0.0)},
	"DIVINE": {"min": 200, "max": 1000, "color": Color(1.0, 1.0, 1.0)}
}

# Special word power dictionary
const WORD_POWER = {
	"god": 100,
	"divine": 75,
	"eternal": 50,
	"create": 40,
	"reality": 35,
	"energy": 30,
	"power": 25,
	"light": 20,
	"dark": 20,
	"universe": 40,
	"life": 45,
	"death": 45,
	"soul": 40,
	"mind": 35,
	"spirit": 40,
	"time": 45,
	"space": 45,
	"dimension": 50
}

# Word opposites for connection calculation
const WORD_OPPOSITES = {
	"light": "dark",
	"create": "destroy",
	"life": "death",
	"good": "evil",
	"order": "chaos",
	"above": "below",
	"open": "closed"
}

# Word evolution stages
const EVOLUTION_STAGES = {
	0: {"name": "Nascent", "multiplier": 1.0},
	1: {"name": "Forming", "multiplier": 1.5},
	2: {"name": "Manifesting", "multiplier": 2.0},
	3: {"name": "Stabilizing", "multiplier": 2.5},
	4: {"name": "Transcendent", "multiplier": 3.0}
}

# Dimension multipliers for word power
const DIMENSION_MULTIPLIERS = [
	1.0,  # 1D - Point
	1.2,  # 2D - Line
	1.5,  # 3D - Space
	1.8,  # 4D - Time
	2.0,  # 5D - Consciousness
	2.2,  # 6D - Connection
	2.5,  # 7D - Creation
	2.8,  # 8D - Network
	3.0,  # 9D - Harmony
	3.5,  # 10D - Unity
	4.0,  # 11D - Transcendence
	5.0   # 12D - Beyond
]

# Task: Calculate word power
# This can be distributed to worker threads
func calculate_word_power(params: Dictionary) -> Dictionary:
	var word = params.get("word", "")
	var dimension = params.get("dimension", 0)
	
	# Clean the word
	word = word.strip_edges().to_lower()
	
	# Get base power
	var power = _get_base_power(word)
	
	# Apply dimension modifier
	power = _apply_dimension_modifier(power, dimension)
	
	# Apply cosmic age modifier if provided
	if params.has("cosmic_age"):
		power = _apply_cosmic_age_modifier(power, params.cosmic_age)
	
	# Apply evolution stage modifier if provided
	if params.has("evolution_stage"):
		power = _apply_evolution_modifier(power, params.evolution_stage)
	
	# Get tier and color
	var tier_info = _get_power_tier(power)
	
	# Build result
	return {
		"word": word,
		"power": power,
		"tier": tier_info.tier,
		"color": tier_info.color,
		"dimension": dimension,
		"size": 0.5 + (power / 100.0),
		"mass": 0.2 + (power / 50.0)
	}

# Task: Calculate word connections
# Find potential connections between a word and existing words
func calculate_word_connections(params: Dictionary) -> Dictionary:
	var word = params.get("word", "")
	var existing_words = params.get("existing_words", [])
	
	# Clean the word
	word = word.strip_edges().to_lower()
	
	var connections = []
	
	# Check for opposites
	if WORD_OPPOSITES.has(word):
		var opposite = WORD_OPPOSITES[word]
		for existing in existing_words:
			if existing.text == opposite:
				connections.append({
					"type": "opposite",
					"word": existing.text,
					"id": existing.id,
					"strength": 0.8
				})
	
	# Check for reverse opposites
	for opposite_word in WORD_OPPOSITES:
		if WORD_OPPOSITES[opposite_word] == word:
			for existing in existing_words:
				if existing.text == opposite_word:
					connections.append({
						"type": "opposite",
						"word": existing.text,
						"id": existing.id,
						"strength": 0.8
					})
	
	# Check for words that start with the same letter
	var first_letter = ""
	if word.length() > 0:
		first_letter = word.left(1)
	
	for existing in existing_words:
		if existing.text != word and existing.text.begins_with(first_letter):
			connections.append({
				"type": "similar_start",
				"word": existing.text,
				"id": existing.id,
				"strength": 0.3
			})
	
	# Check for words with similar length (±1)
	var word_length = word.length()
	
	for existing in existing_words:
		if existing.text != word and abs(existing.text.length() - word_length) <= 1:
			connections.append({
				"type": "similar_length",
				"word": existing.text,
				"id": existing.id,
				"strength": 0.2
			})
	
	return {
		"word": word,
		"connections": connections
	}

# Task: Calculate word physics
# Determine physical properties and behavior in the current dimension
func calculate_word_physics(params: Dictionary) -> Dictionary:
	var word_data = params.get("word_data", {})
	var dimension = params.get("dimension", 0)
	
	var physics_properties = {
		"position": Vector3.ZERO,
		"velocity": Vector3.ZERO,
		"acceleration": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"angular_velocity": Vector3.ZERO,
		"mass": 1.0,
		"gravity_scale": 1.0,
		"constraints": []
	}
	
	# Set mass based on word power
	physics_properties.mass = 0.2 + (word_data.get("power", 0) / 50.0)
	
	# Generate a deterministic but seemingly random position
	var seed_value = 0
	var word = word_data.get("word", "")
	for i in range(word.length()):
		seed_value += word.unicode_at(i)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Apply dimension-specific physics
	match dimension:
		0:  # 1D - Point (constrained to origin)
			physics_properties.position = Vector3.ZERO
			physics_properties.constraints = ["x", "y", "z"]
			physics_properties.gravity_scale = 0.0
			
		1:  # 2D - Line (constrained to x-axis)
			physics_properties.position = Vector3(
				rng.randf_range(-5, 5),
				0,
				0
			)
			physics_properties.constraints = ["y", "z"]
			physics_properties.gravity_scale = 0.0
			
		2:  # 3D - Space (full 3D movement)
			physics_properties.position = Vector3(
				rng.randf_range(-5, 5),
				rng.randf_range(0, 5),
				rng.randf_range(-5, 5)
			)
			physics_properties.constraints = []
			physics_properties.gravity_scale = 1.0
			
		3:  # 4D - Time (3D with temporal effects)
			physics_properties.position = Vector3(
				rng.randf_range(-5, 5),
				rng.randf_range(0, 5),
				rng.randf_range(-5, 5)
			)
			physics_properties.constraints = []
			physics_properties.gravity_scale = 1.0
			# Add temporal fluctuation
			physics_properties.temporal_factor = 1.0
			
		_:  # Higher dimensions
			physics_properties.position = Vector3(
				rng.randf_range(-10, 10),
				rng.randf_range(0, 10),
				rng.randf_range(-10, 10)
			)
			physics_properties.constraints = []
			physics_properties.gravity_scale = 0.5
	
	# Set rotation based on word features
	physics_properties.rotation = Vector3(
		rng.randf_range(0, TAU) if dimension >= 2 else 0,
		rng.randf_range(0, TAU) if dimension >= 1 else 0,
		rng.randf_range(0, TAU) if dimension >= 3 else 0
	)
	
	return {
		"word": word_data.get("word", ""),
		"physics": physics_properties
	}

# Task: Calculate word evolution
# Determine how a word evolves over time
func calculate_word_evolution(params: Dictionary) -> Dictionary:
	var word_data = params.get("word_data", {})
	var current_stage = params.get("current_stage", 0)
	var dimension = params.get("dimension", 0)
	var cosmic_age = params.get("cosmic_age", 0)
	
	# Don't exceed maximum evolution stage
	var new_stage = min(current_stage + 1, 4)
	
	# Apply evolution multiplier
	var power = word_data.get("power", 0)
	var multiplier = EVOLUTION_STAGES[new_stage].multiplier
	
	power *= multiplier
	
	# Apply additional dimension bonus for higher stages
	if new_stage >= 3:
		power *= (1.0 + (dimension * 0.02))
	
	# Apply cosmic age bonus for final stage
	if new_stage == 4:
		power *= (1.0 + (cosmic_age * 0.01))
	
	# Update tier and color
	var tier_info = _get_power_tier(power)
	
	return {
		"word": word_data.get("word", ""),
		"power": power,
		"evolution_stage": new_stage,
		"stage_name": EVOLUTION_STAGES[new_stage].name,
		"tier": tier_info.tier,
		"color": tier_info.color,
		"size": 0.5 + (power / 100.0),
		"mass": 0.2 + (power / 50.0)
	}

# Task: Process text input
# Split text into words and prepare for processing
func process_text_input(params: Dictionary) -> Dictionary:
	var text = params.get("text", "")
	var dimension = params.get("dimension", 0)
	
	# Split text into words
	var words = text.split(" ", false)
	var processed_words = []
	
	for word in words:
		# Clean the word
		word = word.strip_edges().to_lower()
		if word.length() == 0:
			continue
		
		# Add to processed words
		processed_words.append(word)
	
	return {
		"original_text": text,
		"words": processed_words,
		"word_count": processed_words.size(),
		"dimension": dimension
	}

# Helper: Get base power for a word
func _get_base_power(word: String) -> float:
	# Check if word has a predefined power
	if WORD_POWER.has(word):
		return WORD_POWER[word]
	
	# Calculate based on word length and character values
	var power = 5.0 + (word.length() * 2.0)  # Base power from length
	
	# Add power from character values (simple hashing)
	var char_sum = 0
	for i in range(word.length()):
		char_sum += word.unicode_at(i) % 26
	
	power += char_sum * 0.2
	
	# Apply a small random factor (±10%)
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(word)
	power *= (0.9 + rng.randf() * 0.2)
	
	return power

# Helper: Apply dimension modifier to power
func _apply_dimension_modifier(power: float, dimension: int) -> float:
	# Ensure dimension is within range
	dimension = clamp(dimension, 0, DIMENSION_MULTIPLIERS.size() - 1)
	
	# Apply multiplier
	return power * DIMENSION_MULTIPLIERS[dimension]

# Helper: Apply cosmic age modifier
func _apply_cosmic_age_modifier(power: float, cosmic_age: int) -> float:
	# Each cosmic age adds a small bonus
	return power * (1.0 + (cosmic_age * 0.02))

# Helper: Apply evolution stage modifier
func _apply_evolution_modifier(power: float, stage: int) -> float:
	# Ensure stage is within range
	stage = clamp(stage, 0, EVOLUTION_STAGES.size() - 1)
	
	# Apply multiplier
	return power * EVOLUTION_STAGES[stage].multiplier

# Helper: Get power tier and color
func _get_power_tier(power: float) -> Dictionary:
	for tier_name in POWER_TIERS:
		var tier = POWER_TIERS[tier_name]
		if power >= tier.min and power < tier.max:
			return {
				"tier": tier_name,
				"color": tier.color
			}
	
	# Default to highest tier if exceeded
	return {
		"tier": "DIVINE",
		"color": POWER_TIERS.DIVINE.color
	}

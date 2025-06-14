extends Node
class_name EvolutionManager

# References
var akashic_records = null

# Evolution parameters
@export var evolution_interval: float = 60.0  # seconds between evolution cycles
@export var evolution_rate: float = 0.05      # base rate of property drift
@export var variant_threshold: int = 10       # usage count needed to generate variants
@export var variant_probability: float = 0.3  # probability of generating a variant
@export var auto_evolution: bool = true       # whether to automatically evolve

# Evolution statistics
var evolution_cycles: int = 0
var variants_generated: int = 0
var last_evolution_time: int = 0

# Timer for automatic evolution
var evolution_timer: Timer

func _ready():
	# Set up timer for automatic evolution
	if auto_evolution:
		evolution_timer = Timer.new()
		evolution_timer.one_shot = false
		evolution_timer.wait_time = evolution_interval
		evolution_timer.timeout.connect(_on_evolution_timer_timeout)
		add_child(evolution_timer)
		evolution_timer.start()

func _on_evolution_timer_timeout():
	if auto_evolution and akashic_records:
		evolve_cycle()

func evolve_cycle():
	if not akashic_records:
		return
		
	# Track that we ran a cycle
	evolution_cycles += 1
	last_evolution_time = Time.get_unix_time_from_system()
	
	# Get all words from dictionary
	var words = akashic_records.dynamic_dictionary.words
	
	# Apply evolution to each word
	for word_id in words:
		_evolve_word(words[word_id])
		
	# Try to generate variants from frequently used words
	for word_id in words:
		_try_generate_variant(words[word_id])
	
	# Emit signal or notify observers
	if akashic_records.has_signal("dictionary_changed"):
		akashic_records.emit_signal("dictionary_changed")

func _evolve_word(word: WordEntry):
	# Skip words without properties
	if word.properties.is_empty():
		return
		
	# Calculate evolution intensity based on usage
	var usage_factor = min(1.0, word.usage_count / 20.0)  # Cap at 20 uses for max effect
	var evolution_intensity = evolution_rate * (0.5 + usage_factor)
	
	# Apply random drift to each property
	for prop_name in word.properties:
		if word.properties[prop_name] is float:
			# Determine drift direction and magnitude
			var drift_direction = randf_range(-1.0, 1.0)
			var drift_magnitude = evolution_intensity * randf_range(0.5, 1.5)  # Varied intensity
			
			# Calculate new value with drift
			var new_value = word.properties[prop_name] + (drift_direction * drift_magnitude)
			
			# Clamp to reasonable range (assuming properties are normally between 0-1)
			new_value = clamp(new_value, 0.0, 1.0)
			
			# Apply the change
			word.properties[prop_name] = new_value

func _try_generate_variant(word: WordEntry):
	# Only generate variants for words used frequently
	if word.usage_count < variant_threshold:
		return
		
	# Probability check - more uses means higher chance
	var usage_bonus = min(0.5, (word.usage_count - variant_threshold) * 0.02)
	var final_probability = variant_probability + usage_bonus
	
	if randf() > final_probability:
		return  # Failed probability check
	
	# Create a variant
	var variant_properties = _create_variant_properties(word.properties)
	var variant_text = _create_variant_name(word.id)
	
	# Check if variant name already exists
	var attempt = 0
	var original_variant_text = variant_text
	while akashic_records.dynamic_dictionary.words.has(variant_text) and attempt < 5:
		attempt += 1
		variant_text = original_variant_text + str(attempt)
	
	if akashic_records.dynamic_dictionary.words.has(variant_text):
		return  # Skip if we can't generate a unique name
	
	# Add the variant to the dictionary
	var variant = akashic_records.dynamic_dictionary.generate_variant(word.id, variant_text, variant_properties)
	
	if variant:
		variants_generated += 1
		if akashic_records.has_signal("word_evolution_occurred"):
			akashic_records.emit_signal("word_evolution_occurred", word.id)

func _create_variant_properties(base_properties: Dictionary) -> Dictionary:
	# Create a new set of properties based on the parent with some mutations
	var variant_properties = base_properties.duplicate()
	
	# Mutate each property with a more significant change than regular evolution
	for prop_name in variant_properties:
		if variant_properties[prop_name] is float:
			var current_value = variant_properties[prop_name]
			
			# Variant properties change more significantly than regular evolution
			var mutation_direction = randf_range(-1.0, 1.0)
			var mutation_magnitude = randf_range(0.1, 0.3)  # 10-30% mutation
			
			# Calculate new value
			var new_value = current_value + (mutation_direction * mutation_magnitude)
			
			# Clamp to valid range
			new_value = clamp(new_value, 0.0, 1.0)
			
			# Apply the mutation
			variant_properties[prop_name] = new_value
	
	return variant_properties

func _create_variant_name(base_name: String) -> String:
	# Create a variant name based on the original
	
	# Simple approach: Add a modifier or suffix
	var prefixes = ["neo", "proto", "meta", "hyper", "sub", "ultra", "quasi"]
	var suffixes = ["prime", "plus", "wave", "flux", "form", "echo"]
	
	var result = base_name
	var variation_type = randi() % 4
	
	match variation_type:
		0:  # Add prefix
			result = prefixes[randi() % prefixes.size()] + "-" + base_name
		1:  # Add suffix
			result = base_name + "-" + suffixes[randi() % suffixes.size()]
		2:  # Modify a character
			if base_name.length() > 2:
				var pos = randi() % (base_name.length() - 2) + 1  # Don't modify first or last char
				var char_code = base_name.unicode_at(pos)
				var new_char_code = ((char_code + randi() % 5) - 97) % 26 + 97  # Stay in a-z range
				result = base_name.substr(0, pos) + String.chr(new_char_code) + base_name.substr(pos + 1)
		3:  # Number suffix
			result = base_name + str(randi() % 9 + 1)  # 1-9 suffix
	
	return result

func set_evolution_interval(new_interval: float):
	evolution_interval = new_interval
	if evolution_timer:
		evolution_timer.wait_time = new_interval
		# Only restart if already running
		if evolution_timer.time_left > 0:
			evolution_timer.start()

func set_auto_evolution(enabled: bool):
	auto_evolution = enabled
	if evolution_timer:
		if enabled and not evolution_timer.is_inside_tree():
			add_child(evolution_timer)
			evolution_timer.start()
		elif not enabled and evolution_timer.is_inside_tree():
			evolution_timer.stop()

func get_stats() -> Dictionary:
	# Return statistics about the evolution process
	return {
		"cycles": evolution_cycles,
		"variants_generated": variants_generated,
		"last_evolution_time": last_evolution_time,
		"auto_evolution": auto_evolution,
		"evolution_interval": evolution_interval,
		"evolution_rate": evolution_rate
	}

func reset_stats():
	evolution_cycles = 0
	variants_generated = 0
	last_evolution_time = 0
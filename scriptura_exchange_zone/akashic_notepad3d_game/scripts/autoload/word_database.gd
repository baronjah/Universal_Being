extends Node
## Word Database Autoload - Heptagon Evolution System
## Manages evolving word databases with adaptive rules for faster/better goal achievement
## One project → Many projects → Combined testing methodology

# Evolution signals
signal word_evolved(word_id: String, new_properties: Dictionary)
signal word_created(word_data: Dictionary)
signal database_evolved(evolution_data: Dictionary)
signal project_combination_ready(combined_data: Array)
signal heptagon_cycle_completed(cycle_data: Dictionary)

# Heptagon evolution constants (7-sided adaptive progression)
const HEPTAGON_SIDES = 7
const EVOLUTION_THRESHOLDS = [10, 25, 50, 100, 200, 400, 777]  # Adaptive thresholds
const COMBINATION_RULES = ["split", "merge", "transform", "replicate", "mutate", "bridge", "transcend"]

# Core word database
var word_entities: Dictionary = {}
var word_relationships: Dictionary = {}
var evolution_history: Array = []
var interaction_patterns: Dictionary = {}

# Project evolution tracking
var project_variations: Dictionary = {}
var combination_tests: Array = []
var scene_performance_data: Dictionary = {}
var adaptive_rule_modifications: Dictionary = {}

# Heptagon state management
var current_heptagon_side: int = 0
var heptagon_cycle_count: int = 0
var evolution_acceleration_factor: float = 1.0

# Database configuration (adaptive)
var max_words_per_level: int = 777  # Can be modified by Claude for optimization
var evolution_speed_multiplier: float = 1.0
var combination_complexity_limit: int = 5
var scene_test_duration: float = 30.0  # Seconds per test

func _ready() -> void:
	_initialize_word_database()
	_setup_evolution_system()
	_create_adaptive_rules()
	print("Word Database initialized - Heptagon Evolution System active")

func _initialize_word_database() -> void:
	# Create base word categories for evolution
	_create_word_category("cosmic", ["infinity", "void", "creation", "destruction", "transformation"])
	_create_word_category("elemental", ["fire", "water", "earth", "air", "spirit", "light", "shadow"])
	_create_word_category("conceptual", ["time", "space", "memory", "dream", "reality", "possibility"])
	_create_word_category("interactive", ["touch", "see", "hear", "feel", "think", "create", "evolve"])
	
	# Initialize relationship matrix
	_build_word_relationship_matrix()

func _setup_evolution_system() -> void:
	# Configure evolution timers and patterns
	var evolution_timer = Timer.new()
	evolution_timer.wait_time = 1.0 / evolution_speed_multiplier
	evolution_timer.timeout.connect(_process_word_evolution)
	evolution_timer.autostart = true
	add_child(evolution_timer)
	
	# Set up heptagon progression timer
	var heptagon_timer = Timer.new()
	heptagon_timer.wait_time = 10.0  # 10 seconds per heptagon side
	heptagon_timer.timeout.connect(_advance_heptagon_side)
	heptagon_timer.autostart = true
	add_child(heptagon_timer)

func _create_adaptive_rules() -> void:
	# Rules that Claude can modify for optimization
	adaptive_rule_modifications = {
		"evolution_speed": {"min": 0.1, "max": 5.0, "current": 1.0},
		"word_count_limit": {"min": 100, "max": 2000, "current": 777},
		"combination_depth": {"min": 2, "max": 10, "current": 5},
		"scene_test_time": {"min": 5.0, "max": 120.0, "current": 30.0},
		"heptagon_cycle_speed": {"min": 1.0, "max": 30.0, "current": 10.0}
	}

func create_word(text: String, position: Vector3, level: String, properties: Dictionary = {}) -> String:
	var word_id = _generate_word_id(text, level)
	
	# Generate frequency and color for each word
	var frequency = _generate_word_frequency(text)
	var color = _generate_word_color(frequency, text)
	
	var word_data = {
		"id": word_id,
		"text": text,
		"position": position,
		"level": level,
		"evolution_state": 0,
		"interaction_count": 0,
		"creation_time": Time.get_unix_time_from_system(),
		"relationships": [],
		"animation_state": "idle",
		"direction_influence": Vector3.ZERO,
		"frequency": frequency,
		"color": color,
		"base_position": position,  # Store original position
		"properties": properties
	}
	
	word_entities[word_id] = word_data
	_analyze_word_relationships(word_id)
	
	word_created.emit(word_data)
	print("Word created: ", text, " (", word_id, ")")
	return word_id

func evolve_word(word_id: String, interaction_data: Dictionary = {}) -> bool:
	if not word_entities.has(word_id):
		return false
	
	var word = word_entities[word_id]
	var old_state = word.evolution_state
	
	# Apply heptagon evolution rules
	word.evolution_state = _calculate_new_evolution_state(word, interaction_data)
	word.interaction_count += 1
	
	# Update word properties based on current heptagon side
	_apply_heptagon_evolution(word_id, current_heptagon_side)
	
	# Check for project evolution triggers
	if _should_trigger_project_evolution(word):
		_trigger_project_evolution(word_id)
	
	word_evolved.emit(word_id, word)
	_log_evolution_event(word_id, old_state, word.evolution_state)
	
	return true

func _calculate_new_evolution_state(word: Dictionary, interaction_data: Dictionary) -> int:
	var current_state = word.evolution_state
	var interaction_weight = interaction_data.get("intensity", 1.0)
	var time_factor = (Time.get_unix_time_from_system() - word.creation_time) / 60.0  # Minutes
	var relationship_bonus = word.relationships.size() * 0.1
	
	# Heptagon-influenced evolution calculation
	var heptagon_multiplier = 1.0 + (current_heptagon_side * 0.2)
	var evolution_points = (interaction_weight + time_factor + relationship_bonus) * heptagon_multiplier
	
	# Apply adaptive acceleration
	evolution_points *= evolution_acceleration_factor
	
	# Check thresholds for state advancement
	for i in range(EVOLUTION_THRESHOLDS.size()):
		if evolution_points >= EVOLUTION_THRESHOLDS[i] and current_state <= i:
			return i + 1
	
	return current_state

func _apply_heptagon_evolution(word_id: String, heptagon_side: int) -> void:
	var word = word_entities[word_id]
	var rule = COMBINATION_RULES[heptagon_side]
	
	match rule:
		"split":
			_attempt_word_splitting(word_id)
		"merge":
			_attempt_word_merging(word_id)
		"transform":
			_apply_word_transformation(word_id)
		"replicate":
			_attempt_word_replication(word_id)
		"mutate":
			_apply_word_mutation(word_id)
		"bridge":
			_create_word_bridges(word_id)
		"transcend":
			_attempt_word_transcendence(word_id)

func _advance_heptagon_side() -> void:
	current_heptagon_side = (current_heptagon_side + 1) % HEPTAGON_SIDES
	
	if current_heptagon_side == 0:
		heptagon_cycle_count += 1
		_complete_heptagon_cycle()
	
	print("Heptagon advanced to side ", current_heptagon_side, " (", COMBINATION_RULES[current_heptagon_side], ")")

func _complete_heptagon_cycle() -> void:
	var cycle_data = {
		"cycle_number": heptagon_cycle_count,
		"words_evolved": word_entities.size(),
		"combinations_tested": combination_tests.size(),
		"performance_metrics": _calculate_performance_metrics(),
		"adaptive_improvements": _generate_adaptive_improvements()
	}
	
	heptagon_cycle_completed.emit(cycle_data)
	_apply_adaptive_improvements(cycle_data.adaptive_improvements)
	print("Heptagon cycle ", heptagon_cycle_count, " completed with ", word_entities.size(), " evolved words")

func _trigger_project_evolution(word_id: String) -> void:
	var base_word = word_entities[word_id]
	var variation_count = project_variations.get(word_id, []).size()
	
	# Create new project variation
	var variation_data = {
		"original_id": word_id,
		"variation_number": variation_count + 1,
		"evolution_branch": COMBINATION_RULES[current_heptagon_side],
		"properties": base_word.duplicate(true),
		"scene_tests": [],
		"performance_score": 0.0
	}
	
	if not project_variations.has(word_id):
		project_variations[word_id] = []
	
	project_variations[word_id].append(variation_data)
	_schedule_scene_test(variation_data)
	
	print("Project evolution triggered for: ", base_word.text)

func _schedule_scene_test(variation_data: Dictionary) -> void:
	var test_data = {
		"variation": variation_data,
		"test_scene": _generate_test_scene_name(),
		"start_time": Time.get_unix_time_from_system(),
		"duration": scene_test_duration,
		"metrics": {}
	}
	
	combination_tests.append(test_data)

func _generate_test_scene_name() -> String:
	var scene_types = ["navigation", "interaction", "evolution", "combination", "transcendence"]
	var random_type = scene_types[randi() % scene_types.size()]
	return "test_scene_" + random_type + "_" + str(combination_tests.size())

func get_words_for_level(level: String) -> Array:
	var level_words = []
	for word_data in word_entities.values():
		if word_data.level == level:
			level_words.append(word_data)
	return level_words

func get_evolution_statistics() -> Dictionary:
	var stats = {
		"total_words": word_entities.size(),
		"average_evolution_state": 0.0,
		"total_interactions": 0,
		"heptagon_cycles": heptagon_cycle_count,
		"project_variations": project_variations.size(),
		"scene_tests_completed": 0
	}
	
	var total_evolution = 0
	var total_interactions = 0
	
	for word in word_entities.values():
		total_evolution += word.evolution_state
		total_interactions += word.interaction_count
	
	if word_entities.size() > 0:
		stats.average_evolution_state = float(total_evolution) / word_entities.size()
	
	stats.total_interactions = total_interactions
	stats.scene_tests_completed = combination_tests.size()
	
	return stats

# Adaptive rule modification functions (for Claude to optimize)
func modify_evolution_speed(new_speed: float) -> void:
	var rule = adaptive_rule_modifications.evolution_speed
	if new_speed >= rule.min and new_speed <= rule.max:
		rule.current = new_speed
		evolution_speed_multiplier = new_speed
		print("Evolution speed modified to: ", new_speed)

func modify_word_count_limit(new_limit: int) -> void:
	var rule = adaptive_rule_modifications.word_count_limit
	if new_limit >= rule.min and new_limit <= rule.max:
		rule.current = new_limit
		max_words_per_level = new_limit
		print("Word count limit modified to: ", new_limit)

func modify_combination_depth(new_depth: int) -> void:
	var rule = adaptive_rule_modifications.combination_depth
	if new_depth >= rule.min and new_depth <= rule.max:
		rule.current = new_depth
		combination_complexity_limit = new_depth
		print("Combination depth modified to: ", new_depth)

# Helper functions for word evolution mechanics
func _create_word_category(category: String, words: Array) -> void:
	for word in words:
		var position = Vector3(randf_range(-10, 10), randf_range(-5, 5), randf_range(-10, 10))
		create_word(word, position, "cosmic", {"category": category})

func _build_word_relationship_matrix() -> void:
	# Build semantic relationships between words
	for word_id in word_entities.keys():
		var word = word_entities[word_id]
		word_relationships[word_id] = _find_semantic_relationships(word.text)

func _find_semantic_relationships(text: String) -> Array:
	# Simple semantic analysis based on word categories and meanings
	var relationships = []
	var word_lower = text.to_lower()
	
	for other_id in word_entities.keys():
		var other_word = word_entities[other_id]
		if _are_semantically_related(word_lower, other_word.text.to_lower()):
			relationships.append(other_id)
	
	return relationships

func _are_semantically_related(word1: String, word2: String) -> bool:
	# Basic semantic relationship detection
	var related_pairs = [
		["fire", "light"], ["water", "flow"], ["earth", "ground"],
		["time", "space"], ["memory", "dream"], ["create", "evolve"],
		["touch", "feel"], ["see", "vision"], ["infinity", "void"]
	]
	
	for pair in related_pairs:
		if (word1 in pair[0] and word2 in pair[1]) or (word1 in pair[1] and word2 in pair[0]):
			return true
	
	return false

func _generate_word_id(text: String, level: String) -> String:
	var timestamp = str(Time.get_unix_time_from_system())
	return level + "_" + text + "_" + timestamp.substr(-6)

func _generate_word_frequency(text: String) -> float:
	# Generate frequency based on word characteristics
	var frequency = 1.0
	
	# Base frequency on word length and content
	frequency += text.length() * 0.1
	
	# Special frequencies for certain word types
	if text in ["infinity", "cosmos", "eternal", "void"]:
		frequency += 2.0  # High cosmic frequency
	elif text in ["fire", "water", "earth", "air"]:
		frequency += 1.5  # Medium elemental frequency
	elif text in ["time", "space", "reality", "dimension"]:
		frequency += 1.8  # High conceptual frequency
	
	# Add some randomness
	frequency += randf_range(0.1, 0.9)
	
	return clamp(frequency, 0.5, 5.0)

func _generate_word_color(frequency: float, text: String) -> Color:
	# Generate color based on frequency and word type
	var base_color = Color.WHITE
	
	# Frequency-based color shifts
	if frequency > 4.0:
		base_color = Color.GOLD  # High frequency = gold
	elif frequency > 3.0:
		base_color = Color.CYAN  # Medium-high = cyan
	elif frequency > 2.0:
		base_color = Color.LIGHT_BLUE  # Medium = light blue
	elif frequency > 1.5:
		base_color = Color.LIGHT_GREEN  # Low-medium = light green
	else:
		base_color = Color.WHITE  # Low = white
	
	# Word type color modifications
	if text in ["fire", "plasma", "solar", "fusion"]:
		base_color = base_color.lerp(Color.RED, 0.3)
	elif text in ["water", "ocean", "flow", "liquid"]:
		base_color = base_color.lerp(Color.BLUE, 0.3)
	elif text in ["earth", "ground", "terrain", "geology"]:
		base_color = base_color.lerp(Color.BROWN, 0.3)
	elif text in ["air", "wind", "atmosphere", "void"]:
		base_color = base_color.lerp(Color.LIGHT_GRAY, 0.3)
	elif text in ["infinity", "cosmos", "multiverse", "eternal"]:
		base_color = base_color.lerp(Color.PURPLE, 0.3)
	
	return base_color

func _analyze_word_relationships(word_id: String) -> void:
	var word = word_entities[word_id]
	word.relationships = _find_semantic_relationships(word.text)

func _should_trigger_project_evolution(word: Dictionary) -> bool:
	return word.evolution_state >= 3 and word.interaction_count >= 10

func _process_word_evolution() -> void:
	# Passive evolution processing
	for word_id in word_entities.keys():
		var word = word_entities[word_id]
		if randf() < 0.1:  # 10% chance per cycle
			evolve_word(word_id, {"intensity": 0.1})

func _log_evolution_event(word_id: String, old_state: int, new_state: int) -> void:
	evolution_history.append({
		"word_id": word_id,
		"old_state": old_state,
		"new_state": new_state,
		"timestamp": Time.get_unix_time_from_system(),
		"heptagon_side": current_heptagon_side
	})

# Advanced evolution functions (to be implemented based on testing)
func _attempt_word_splitting(word_id: String) -> void:
	print("Attempting word splitting for: ", word_id)

func _attempt_word_merging(word_id: String) -> void:
	print("Attempting word merging for: ", word_id)

func _apply_word_transformation(word_id: String) -> void:
	print("Applying word transformation for: ", word_id)

func _attempt_word_replication(word_id: String) -> void:
	print("Attempting word replication for: ", word_id)

func _apply_word_mutation(word_id: String) -> void:
	print("Applying word mutation for: ", word_id)

func _create_word_bridges(word_id: String) -> void:
	print("Creating word bridges for: ", word_id)

func _attempt_word_transcendence(word_id: String) -> void:
	print("Attempting word transcendence for: ", word_id)

func _calculate_performance_metrics() -> Dictionary:
	return {
		"evolution_rate": evolution_acceleration_factor,
		"word_density": word_entities.size() / 777.0,
		"interaction_efficiency": 1.0,
		"heptagon_completion_rate": 1.0
	}

func _generate_adaptive_improvements() -> Dictionary:
	return {
		"speed_adjustment": randf_range(0.9, 1.1),
		"complexity_adjustment": randi_range(-1, 1),
		"threshold_modification": randf_range(0.95, 1.05)
	}

func _apply_adaptive_improvements(improvements: Dictionary) -> void:
	if improvements.has("speed_adjustment"):
		evolution_acceleration_factor *= improvements.speed_adjustment
	print("Applied adaptive improvements: ", improvements)
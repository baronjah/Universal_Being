extends Node

class_name LetterPaintSystem

signal letter_painted(letter, dimension, power)
signal glyph_recognized(glyph_data)
signal mind_updated(update_type, strength)

# Core systems references
var paint_system: PaintSystem
var shape_system: ShapeSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager
var astral_entity_system: AstralEntitySystem

# Letter glyph database
var letter_glyphs = {}
var power_words = {}
var active_letters = []

# Mind update tracking
var mind_updates = []
var mind_update_strength = 0.0
var last_update_time = 0

# Glyph recognition settings
var recognition_threshold = 0.75
var maximum_glyph_points = 100
var minimum_glyph_points = 5

# Letter power settings
var base_letter_power = 1.0
var dimensional_power_multipliers = {
	1: 1.0,  # Foundation - base reality
	2: 1.2,  # Growth - expansion
	3: 1.5,  # Energy - activation
	4: 1.8,  # Insight - perception
	5: 2.0,  # Force - implementation
	6: 2.3,  # Vision - future sight
	7: 2.7,  # Wisdom - deepening
	8: 3.0,  # Transcendence - elevated states
	9: 3.5   # Unity - completion
}

# Letter properties by dimension
var letter_dimension_properties = {
	1: {
		"stability": 0.9,
		"persistence": 0.8,
		"manifestation": 0.3,
		"effects": ["grounding", "foundation", "stability"]
	},
	2: {
		"stability": 0.7,
		"persistence": 0.85,
		"manifestation": 0.4,
		"effects": ["growth", "expansion", "evolution"]
	},
	3: {
		"stability": 0.6,
		"persistence": 0.7,
		"manifestation": 0.6,
		"effects": ["activation", "energy", "power"]
	},
	4: {
		"stability": 0.5,
		"persistence": 0.9,
		"manifestation": 0.5,
		"effects": ["insight", "perception", "awareness"]
	},
	5: {
		"stability": 0.4,
		"persistence": 0.6,
		"manifestation": 0.8,
		"effects": ["force", "will", "direction"]
	},
	6: {
		"stability": 0.3,
		"persistence": 0.95,
		"manifestation": 0.7,
		"effects": ["foresight", "vision", "planning"]
	},
	7: {
		"stability": 0.2,
		"persistence": 0.9,
		"manifestation": 0.9,
		"effects": ["wisdom", "depth", "understanding"]
	},
	8: {
		"stability": 0.1,
		"persistence": 0.7,
		"manifestation": 1.0,
		"effects": ["transcendence", "elevation", "ascension"]
	},
	9: {
		"stability": 0.05,
		"persistence": 1.0,
		"manifestation": 1.0,
		"effects": ["unity", "completion", "oneness"]
	}
}

# Mind update types
enum MindUpdateType {
	INSIGHT,         # New understanding
	REALIZATION,     # Sudden awareness
	INTEGRATION,     # Combining concepts
	EXPANSION,       # Growing awareness
	TRANSFORMATION,  # Shift in perspective
	AWAKENING,       # Deeper consciousness
	REMEMBRANCE,     # Recalling forgotten
	REFLECTION,      # Contemplative insights
	REVELATION       # Profound truth
}

# Letter data class
class LetterData:
	var character: String
	var glyph_points = [] # Array of Vector2
	var power: float = 1.0
	var dimension: int = 1
	var color: Color
	var creation_time: int
	var properties = {}
	var stroke_ids = [] # Array of stroke_ids used to create this letter
	
	func _init(p_character: String, p_points: Array, p_dimension: int):
		character = p_character
		glyph_points = p_points
		dimension = p_dimension
		creation_time = Time.get_unix_time_from_system()
	
	func calculate_power(dimensional_multiplier: float):
		# Base power calculation
		power = base_letter_power * dimensional_multiplier
		
		# Additional factors
		if character in "AEIOU":
			power *= 1.2 # Vowels have more power
		
		# Size and complexity factors
		var glyph_size = _calculate_glyph_size()
		power *= (0.5 + (glyph_size / 200.0)) # Larger glyphs have more power
		
		# Complexity based on point count
		var point_count_factor = min(1.5, glyph_points.size() / 50.0)
		power *= point_count_factor
		
		return power
	
	func _calculate_glyph_size() -> float:
		if glyph_points.size() < 2:
			return 0.0
			
		var min_x = glyph_points[0].x
		var min_y = glyph_points[0].y
		var max_x = min_x
		var max_y = min_y
		
		for point in glyph_points:
			min_x = min(min_x, point.x)
			min_y = min(min_y, point.y)
			max_x = max(max_x, point.x)
			max_y = max(max_y, point.y)
		
		var width = max_x - min_x
		var height = max_y - min_y
		
		return max(width, height)
	
	func serialize() -> Dictionary:
		var serialized_points = []
		for point in glyph_points:
			serialized_points.append({"x": point.x, "y": point.y})
		
		return {
			"character": character,
			"glyph_points": serialized_points,
			"power": power,
			"dimension": dimension,
			"color": color.to_html(),
			"creation_time": creation_time,
			"properties": properties,
			"stroke_ids": stroke_ids
		}
	
	static func deserialize(data: Dictionary) -> LetterData:
		var points = []
		for point_data in data.glyph_points:
			points.append(Vector2(point_data.x, point_data.y))
		
		var letter = LetterData.new(data.character, points, data.dimension)
		letter.power = data.power
		letter.color = Color.from_html(data.color)
		letter.creation_time = data.creation_time
		letter.properties = data.properties
		letter.stroke_ids = data.stroke_ids
		
		return letter

# Mind update class
class MindUpdate:
	var type: int # MindUpdateType
	var strength: float
	var source_letters = [] # Array of characters
	var dimension: int
	var insight: String
	var creation_time: int
	var applied: bool = false
	
	func _init(p_type: int, p_strength: float, p_source: Array, p_dimension: int, p_insight: String = ""):
		type = p_type
		strength = p_strength
		source_letters = p_source
		dimension = p_dimension
		insight = p_insight
		creation_time = Time.get_unix_time_from_system()
	
	func serialize() -> Dictionary:
		return {
			"type": type,
			"strength": strength,
			"source_letters": source_letters,
			"dimension": dimension,
			"insight": insight,
			"creation_time": creation_time,
			"applied": applied
		}
	
	static func deserialize(data: Dictionary) -> MindUpdate:
		var update = MindUpdate.new(
			data.type,
			data.strength,
			data.source_letters,
			data.dimension,
			data.insight
		)
		update.creation_time = data.creation_time
		update.applied = data.applied
		return update

func _ready():
	# Get references to other systems
	paint_system = get_node_or_null("/root/PaintSystem")
	if not paint_system:
		paint_system = PaintSystem.new()
		add_child(paint_system)
	
	shape_system = get_node_or_null("/root/ShapeSystem")
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	astral_entity_system = get_node_or_null("/root/AstralEntitySystem")
	
	# Connect signals
	paint_system.stroke_created.connect(_on_stroke_created)
	
	if turn_cycle_manager:
		turn_cycle_manager.turn_completed.connect(_on_turn_completed)
	
	# Initialize letter glyph database
	_initialize_letter_database()
	_initialize_power_words()
	
	# Load saved data
	_load_data()

func _initialize_letter_database():
	# Initialize with basic letter shapes
	# In a full implementation, these would be learned from user input
	# or loaded from a more sophisticated database
	
	# For now, we'll use simple point arrays to represent letter shapes
	# These are simplified approximations
	
	# A
	letter_glyphs["A"] = [
		Vector2(50, 100), Vector2(75, 0), Vector2(100, 100),
		Vector2(60, 50), Vector2(90, 50)
	]
	
	# B
	letter_glyphs["B"] = [
		Vector2(50, 0), Vector2(50, 100),
		Vector2(50, 0), Vector2(75, 0), Vector2(100, 25), Vector2(75, 50), Vector2(50, 50),
		Vector2(75, 50), Vector2(100, 75), Vector2(75, 100), Vector2(50, 100)
	]
	
	# C
	letter_glyphs["C"] = [
		Vector2(100, 25), Vector2(75, 0), Vector2(50, 25), 
		Vector2(25, 50), Vector2(50, 75), Vector2(75, 100), Vector2(100, 75)
	]
	
	# Basic database for other letters would be added here
	
	# Special dimensional glyphs
	letter_glyphs["∞"] = [] # Infinity symbol - would have special properties
	letter_glyphs["Ω"] = [] # Omega - would have special properties

func _initialize_power_words():
	# Words with special power when painted as a unit
	power_words["CREATE"] = {
		"effect": "manifestation",
		"power_multiplier": 2.0,
		"dimension_boost": 1,
		"mind_update_type": MindUpdateType.TRANSFORMATION
	}
	
	power_words["EVOLVE"] = {
		"effect": "growth",
		"power_multiplier": 1.8,
		"dimension_boost": 1,
		"mind_update_type": MindUpdateType.EXPANSION
	}
	
	power_words["INSIGHT"] = {
		"effect": "perception",
		"power_multiplier": 1.5,
		"dimension_boost": 0,
		"mind_update_type": MindUpdateType.INSIGHT
	}
	
	power_words["AWAKEN"] = {
		"effect": "consciousness",
		"power_multiplier": 2.2,
		"dimension_boost": 2,
		"mind_update_type": MindUpdateType.AWAKENING
	}
	
	power_words["REMEMBER"] = {
		"effect": "memory",
		"power_multiplier": 1.7,
		"dimension_boost": 0,
		"mind_update_type": MindUpdateType.REMEMBRANCE
	}
	
	power_words["UNITY"] = {
		"effect": "integration",
		"power_multiplier": 2.5,
		"dimension_boost": 3,
		"mind_update_type": MindUpdateType.UNITY
	}

func process_stroke_as_letter(stroke_id: String) -> Dictionary:
	if not paint_system.strokes.has(stroke_id):
		return {}
	
	var stroke = paint_system.strokes[stroke_id]
	if stroke.points.size() < minimum_glyph_points:
		return {}
	
	# Sample points if there are too many
	var glyph_points = stroke.points
	if glyph_points.size() > maximum_glyph_points:
		glyph_points = _sample_points(stroke.points, maximum_glyph_points)
	
	# Normalize points for comparison
	var normalized_points = _normalize_points(glyph_points)
	
	# Try to recognize the letter
	var recognized = _recognize_letter(normalized_points)
	
	if recognized.is_empty():
		return {}
	
	# Get the dimension of the stroke
	var dimension = stroke.brush_settings.dimension
	
	# Create letter data
	var letter = LetterData.new(recognized.character, glyph_points, dimension)
	letter.color = stroke.brush_settings.color
	letter.stroke_ids.append(stroke_id)
	
	# Calculate letter power
	var dimensional_multiplier = dimensional_power_multipliers.get(dimension, 1.0)
	letter.calculate_power(dimensional_multiplier)
	
	# Add letter to active letters
	active_letters.append(letter)
	
	# Check for power words
	_check_for_power_words()
	
	# Generate a mind update if appropriate
	if randf() < 0.3: # 30% chance of generating an update
		_generate_mind_update([letter.character], dimension)
	
	# Emit signal
	emit_signal("letter_painted", letter.character, dimension, letter.power)
	
	return recognized

func _sample_points(points: Array, target_count: int) -> Array:
	var sampled = []
	var step = float(points.size()) / float(target_count)
	
	for i in range(target_count):
		var index = int(i * step)
		if index < points.size():
			sampled.append(points[index])
	
	return sampled

func _normalize_points(points: Array) -> Array:
	# Find bounding box
	var min_x = points[0].x
	var min_y = points[0].y
	var max_x = min_x
	var max_y = min_y
	
	for point in points:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
	
	var width = max_x - min_x
	var height = max_y - min_y
	var size = max(width, height)
	
	if size < 0.001:
		return points.duplicate()
	
	# Center of the bounding box
	var center_x = (min_x + max_x) / 2
	var center_y = (min_y + max_y) / 2
	
	# Normalize points to range [-0.5, 0.5] centered at origin
	var normalized = []
	for point in points:
		var nx = (point.x - center_x) / size
		var ny = (point.y - center_y) / size
		normalized.append(Vector2(nx, ny))
	
	return normalized

func _recognize_letter(normalized_points: Array) -> Dictionary:
	var best_match = ""
	var best_score = 0.0
	
	for letter in letter_glyphs.keys():
		var template_points = letter_glyphs[letter]
		if template_points.size() == 0:
			continue
		
		var score = _calculate_similarity(normalized_points, _normalize_points(template_points))
		if score > best_score:
			best_score = score
			best_match = letter
	
	if best_score >= recognition_threshold:
		return {
			"character": best_match,
			"confidence": best_score
		}
	
	return {}

func _calculate_similarity(points1: Array, points2: Array) -> float:
	# Simple distance-based similarity
	# For a real system, this would use more sophisticated recognition algorithms
	
	# Resample to make both arrays the same length
	var count = min(points1.size(), points2.size())
	var p1 = _sample_points(points1, count)
	var p2 = _sample_points(points2, count)
	
	var total_distance = 0.0
	for i in range(count):
		total_distance += p1[i].distance_to(p2[i])
	
	var avg_distance = total_distance / count
	
	# Convert distance to similarity score (0-1 range)
	return max(0.0, 1.0 - avg_distance * 2.0)

func _check_for_power_words():
	if active_letters.size() < 3:
		return
	
	# Extract the characters in sequence
	var word = ""
	for letter in active_letters:
		word += letter.character
	
	# Check if this matches any power words
	for power_word in power_words:
		if word.contains(power_word):
			_activate_power_word(power_word)
			break

func _activate_power_word(word: String):
	if not power_words.has(word):
		return
	
	var word_data = power_words[word]
	
	# Get average dimension of letters
	var total_dimension = 0
	for letter in active_letters:
		total_dimension += letter.dimension
	
	var avg_dimension = total_dimension / active_letters.size()
	var boosted_dimension = min(9, int(avg_dimension) + word_data.dimension_boost)
	
	# Calculate power
	var base_power = 0.0
	for letter in active_letters:
		base_power += letter.power
	
	var total_power = base_power * word_data.power_multiplier
	
	# Generate mind update
	var letter_chars = []
	for letter in active_letters:
		letter_chars.append(letter.character)
	
	_generate_mind_update(letter_chars, boosted_dimension, word_data.mind_update_type, total_power)
	
	# Reset active letters
	active_letters.clear()

func _generate_mind_update(source_letters: Array, dimension: int, update_type = -1, strength = -1.0, insight = ""):
	# If no specific type provided, generate one based on dimension
	if update_type == -1:
		update_type = _get_update_type_for_dimension(dimension)
	
	# Calculate strength if not provided
	if strength < 0:
		strength = (dimension / 9.0) * 5.0 + randf() * 2.0 # 0-7 scale
	
	# Generate insight if not provided
	if insight.is_empty():
		insight = _generate_insight(update_type, source_letters, dimension)
	
	# Create the update
	var update = MindUpdate.new(update_type, strength, source_letters, dimension, insight)
	mind_updates.append(update)
	
	# Update total strength
	mind_update_strength += strength * (dimension / 9.0)
	
	# Apply the update if strong enough
	if strength > 3.0:
		_apply_mind_update(update)
	
	_save_data()
	emit_signal("mind_updated", update_type, strength)

func _get_update_type_for_dimension(dimension: int) -> int:
	match dimension:
		1, 2: return MindUpdateType.INSIGHT
		3: return MindUpdateType.EXPANSION
		4: return MindUpdateType.REALIZATION
		5: return MindUpdateType.TRANSFORMATION
		6: return MindUpdateType.REFLECTION
		7: return MindUpdateType.REMEMBRANCE
		8: return MindUpdateType.AWAKENING
		9: return MindUpdateType.REVELATION
		_: return MindUpdateType.INSIGHT

func _generate_insight(update_type: int, source_letters: Array, dimension: int) -> String:
	# In a full implementation, this would generate more contextual insights
	var insights = {
		MindUpdateType.INSIGHT: [
			"New connections form in understanding",
			"A subtle pattern emerges in thought",
			"The mind glimpses a new perspective"
		],
		MindUpdateType.REALIZATION: [
			"Sudden clarity illuminates the concept",
			"A moment of understanding crystalizes",
			"The puzzle pieces click into place"
		],
		MindUpdateType.INTEGRATION: [
			"Disparate ideas merge into coherence",
			"Synthesis of concepts creates new understanding",
			"The mind unifies separate strands of thought"
		],
		MindUpdateType.EXPANSION: [
			"Awareness stretches beyond previous limits",
			"The mind's horizon broadens significantly",
			"Consciousness expands into new territory"
		],
		MindUpdateType.TRANSFORMATION: [
			"A fundamental shift in perspective occurs",
			"The mind's framework undergoes reconstruction",
			"Old patterns dissolve as new ones form"
		],
		MindUpdateType.AWAKENING: [
			"Dormant awareness stirs into consciousness",
			"A profound awakening of hidden knowledge",
			"Deep recognition activates within"
		],
		MindUpdateType.REMEMBRANCE: [
			"Ancient knowledge resurfaces into awareness",
			"The mind reclaims forgotten understanding",
			"Memory transcends time to retrieve wisdom"
		],
		MindUpdateType.REFLECTION: [
			"Deep contemplation reveals inner truth",
			"The mind mirrors itself in profound observation",
			"Introspective awareness yields clarity"
		],
		MindUpdateType.REVELATION: [
			"Transcendent truth unveils itself completely",
			"Ultimate understanding descends into awareness",
			"The veil parts to reveal fundamental reality"
		]
	}
	
	# Get dimension properties
	var dim_properties = letter_dimension_properties.get(dimension, {})
	var effects = dim_properties.get("effects", [])
	
	# Create source text
	var source_text = ""
	if source_letters.size() == 1:
		source_text = "letter " + source_letters[0]
	else:
		source_text = "word '" + "".join(source_letters) + "'"
	
	# Choose a random insight template
	var templates = insights.get(update_type, ["New understanding emerges"])
	var template = templates[randi() % templates.size()]
	
	# Add effect
	var effect = ""
	if effects.size() > 0:
		effect = effects[randi() % effects.size()]
		template += " with " + effect + " energy"
	
	return "From " + source_text + ": " + template

func _apply_mind_update(update: MindUpdate):
	if update.applied:
		return
	
	# In a fully-featured system, this would update the user's mental model
	# For demonstration purposes, we'll just mark it as applied
	update.applied = true
	
	# Create an entity to represent this mind update
	if astral_entity_system:
		var entity_name = "MindUpdate_" + MindUpdateType.keys()[update.type]
		var entity_type = AstralEntitySystem.EntityType.THOUGHT
		
		# Higher dimension updates create more advanced entity types
		if update.dimension >= 6:
			entity_type = AstralEntitySystem.EntityType.CONCEPT
		if update.dimension >= 8:
			entity_type = AstralEntitySystem.EntityType.ESSENCE
		
		var entity_id = astral_entity_system.create_entity(entity_name, entity_type)
		var entity = astral_entity_system.get_entity(entity_id)
		
		if entity:
			# Set dimensional presence
			entity.dimensional_presence.add_dimension(update.dimension, 1.0)
			
			# Add properties
			entity.properties["insight"] = update.insight
			entity.properties["source"] = update.source_letters
			entity.properties["strength"] = update.strength
			
			# Evolve entity based on update strength
			if update.strength > 5.0:
				astral_entity_system.evolve_entity(entity_id, AstralEntitySystem.EvolutionStage.GLOW)
			if update.strength > 6.0:
				astral_entity_system.evolve_entity(entity_id, AstralEntitySystem.EvolutionStage.EMBER)

func _on_stroke_created(stroke_id, color, dimension):
	# Process the stroke to see if it resembles a letter
	var letter_result = process_stroke_as_letter(stroke_id)
	
	if not letter_result.is_empty():
		emit_signal("glyph_recognized", letter_result)

func _on_turn_completed(turn_number):
	# Check for accumulating mind updates to apply
	if mind_update_strength > 10.0:
		# Major insight at the end of a turn
		_generate_mind_update(
			["Ω"], # Special character for turn-based insights
			turn_cycle_manager.turn_color_mapping[turn_number - 1], # Use turn's dimension
			MindUpdateType.INTEGRATION,
			mind_update_strength * 0.5,
			"Turn " + str(turn_number) + " integration: Consciousness evolves through cycles of awareness"
		)
		
		# Reset accumulated strength
		mind_update_strength = 0.0

func paint_letter(letter: String, position: Vector2, size: float = 100.0, dimension: int = -1) -> String:
	if not letter_glyphs.has(letter) or letter_glyphs[letter].size() == 0:
		return ""
	
	# Use current dimension if not specified
	if dimension < 1:
		if paint_system.current_brush_settings:
			dimension = paint_system.current_brush_settings.dimension
		else:
			dimension = 1
	
	# Get glyph points
	var template_points = letter_glyphs[letter]
	
	# Scale and position the glyph
	var glyph_points = []
	for point in template_points:
		glyph_points.append(Vector2(
			position.x + point.x * size / 100.0,
			position.y + point.y * size / 100.0
		))
	
	# Set brush properties
	var prev_stroke_type = paint_system.current_brush_settings.stroke_type
	var prev_size = paint_system.current_brush_settings.size
	
	paint_system.set_brush_stroke_type(PaintSystem.StrokeType.BRUSH)
	paint_system.set_brush_size(size / 20.0) # Adjust brush size based on letter size
	paint_system.set_brush_dimension(dimension)
	
	# Get color for this dimension
	if dimensional_color_system:
		var dim_color = dimensional_color_system.get_color_for_dimension(dimension)
		var color = dimensional_color_system.get_color_value(dim_color)
		paint_system.apply_color_to_current_brush(color)
	
	# Create the stroke
	var stroke_id = paint_system.start_stroke()
	
	for point in glyph_points:
		paint_system.add_point_to_stroke(point, 1.0)
	
	stroke_id = paint_system.end_stroke()
	
	# Restore previous brush settings
	paint_system.current_brush_settings.stroke_type = prev_stroke_type
	paint_system.current_brush_settings.size = prev_size
	
	return stroke_id

func paint_word(word: String, position: Vector2, size: float = 100.0, dimension: int = -1) -> Array:
	var stroke_ids = []
	var letter_spacing = size * 0.7
	
	for i in range(word.length()):
		var letter = word[i]
		var letter_pos = Vector2(position.x + i * letter_spacing, position.y)
		var stroke_id = paint_letter(letter, letter_pos, size, dimension)
		if stroke_id != "":
			stroke_ids.append(stroke_id)
	
	# Check for power words
	if word.to_upper() in power_words:
		_activate_power_word(word.to_upper())
	
	return stroke_ids

func _load_data():
	if FileAccess.file_exists("user://eden_letters.save"):
		var file = FileAccess.open("user://eden_letters.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			# Load mind updates
			mind_updates.clear()
			for update_data in data.mind_updates:
				var update = MindUpdate.deserialize(update_data)
				mind_updates.append(update)
			
			mind_update_strength = data.mind_update_strength
			last_update_time = data.last_update_time

func _save_data():
	var serialized_updates = []
	for update in mind_updates:
		serialized_updates.append(update.serialize())
	
	var data = {
		"mind_updates": serialized_updates,
		"mind_update_strength": mind_update_strength,
		"last_update_time": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_letters.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
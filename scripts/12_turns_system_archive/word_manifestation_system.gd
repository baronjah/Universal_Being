extends Node

class_name WordManifestationSystem

# ----- WORD MANIFESTATION SYSTEM -----
# Handles the creation and evolution of 3D words in the multiverse
# Words manifested in space have physical properties and behaviors

# ----- VISUALIZATION CONSTANTS -----
const WORD_BASE_SIZE = Vector3(0.5, 0.5, 0.1)
const WORD_COLORS = {
	"divine": Color(1.0, 0.8, 0.2),  # Gold
	"reality": Color(0.2, 0.8, 1.0),  # Cyan
	"creation": Color(0.2, 1.0, 0.5),  # Green
	"void": Color(0.1, 0.1, 0.3),  # Dark blue
	"light": Color(1.0, 1.0, 0.8),  # Bright yellow
	"energy": Color(1.0, 0.5, 0.0),  # Orange
	"space": Color(0.5, 0.0, 1.0),  # Purple
	"time": Color(0.0, 0.5, 0.8),  # Blue
	"consciousness": Color(1.0, 0.2, 0.8),  # Pink
	"default": Color(0.8, 0.8, 0.8)  # Light gray
}

# ----- PHYSICS CONSTANTS -----
const GRAVITY_FACTOR = 9.8
const WORD_MASS_BASE = 1.0
const POWER_MASS_FACTOR = 0.1  # Mass increases with power
const MAX_WORDS_PER_DIMENSION = 100

# ----- SYSTEM STATE -----
var manifested_words = {}
var word_connections = []
var dimension_word_counts = {}
var total_manifested_power = 0
var manifestation_enabled = true

# ----- TURN SYSTEM REFERENCE -----
var current_turn = 3
var current_dimension = "3D"
var current_symbol = "γ"
var word_processor = null

# ----- SIGNALS -----
signal word_manifested(word_data)
signal word_evolved(word_id, from_state, to_state)
signal words_connected(word1_id, word2_id)
signal connection_broken(connection_id)

# ----- INITIALIZATION -----
func _ready():
	print("Word Manifestation System initialized")
	initialize_dimension_counts()

# ----- PROCESS -----
func _process(delta):
	# Process physics for manifested words
	if manifested_words.size() > 0:
		process_word_physics(delta)
		
	# Process connections
	process_connections(delta)
	
	# Occasionally evolve words
	if randf() < 0.01:  # 1% chance per frame
		evolve_random_word()

# ----- CORE FUNCTIONALITY -----
func manifest_word(word_text, position=null, power=null, source="manual"):
	# Skip if manifestation is disabled
	if not manifestation_enabled:
		return null
		
	# Process through word processor if available
	if word_processor != null and power == null:
		var result = word_processor.process_text(word_text, "manifestation", 2)
		power = result.total_power
		word_text = result.corrected
	
	# Default power calculation
	if power == null:
		power = calculate_word_power(word_text)
	
	# Default position
	if position == null:
		position = Vector3(
			rand_range(-5, 5),
			rand_range(0, 5),
			rand_range(-5, 5)
		)
	
	# Generate unique ID
	var word_id = "word_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Calculate properties based on power
	var size = WORD_BASE_SIZE * (1.0 + (power / 100.0))
	var mass = WORD_MASS_BASE + (power * POWER_MASS_FACTOR)
	var color = get_word_color(word_text)
	var lifespan = power > 50 ? -1 : 60.0 + (power * 2.0)  # -1 = permanent
	
	# Create word data structure
	var word_data = {
		"id": word_id,
		"text": word_text,
		"position": position,
		"velocity": Vector3(0, 0, 0),
		"rotation": Vector3(0, 0, 0),
		"angular_velocity": Vector3(
			rand_range(-0.5, 0.5),
			rand_range(-0.5, 0.5),
			rand_range(-0.5, 0.5)
		),
		"size": size,
		"mass": mass,
		"power": power,
		"color": color,
		"creation_time": OS.get_unix_time(),
		"lifespan": lifespan,
		"dimension": current_dimension,
		"turn": current_turn,
		"symbol": current_symbol,
		"evolution_stage": 1,
		"connections": [],
		"source": source
	}
	
	# Store in manifested words dictionary
	manifested_words[word_id] = word_data
	
	# Update dimension counts
	increment_dimension_count(current_dimension)
	
	# Update total power
	total_manifested_power += power
	
	# Emit signal
	emit_signal("word_manifested", word_data)
	
	print("Word manifested: '%s' with power %d in %s" % [word_text, power, current_dimension])
	
	# Check if we need to cull words in this dimension
	check_dimension_limit(current_dimension)
	
	return word_data

func connect_words(word1_id, word2_id, connection_strength=1.0):
	# Verify both words exist
	if not manifested_words.has(word1_id) or not manifested_words.has(word2_id):
		return null
	
	# Check if connection already exists
	for connection in word_connections:
		if (connection.word1_id == word1_id and connection.word2_id == word2_id) or \
		   (connection.word1_id == word2_id and connection.word2_id == word1_id):
			# Connection already exists, increase strength
			connection.strength += connection_strength * 0.5
			return connection
	
	# Calculate natural connection strength based on words
	var word1 = manifested_words[word1_id]
	var word2 = manifested_words[word2_id]
	var word_affinity = calculate_word_affinity(word1.text, word2.text)
	var natural_strength = connection_strength * word_affinity
	
	# Create connection
	var connection_id = "conn_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	var connection = {
		"id": connection_id,
		"word1_id": word1_id,
		"word2_id": word2_id,
		"creation_time": OS.get_unix_time(),
		"strength": natural_strength,
		"ideal_distance": word1.size.length() + word2.size.length() + 0.5,
		"color": Color.from_hsv(randf(), 0.7, 0.9),
		"active": true
	}
	
	# Add to connections list
	word_connections.append(connection)
	
	# Add connection reference to each word
	manifested_words[word1_id].connections.append(connection_id)
	manifested_words[word2_id].connections.append(connection_id)
	
	# Emit signal
	emit_signal("words_connected", word1_id, word2_id)
	
	print("Connected words: '%s' and '%s' with strength %.2f" % [word1.text, word2.text, natural_strength])
	
	return connection

func evolve_word(word_id):
	# Verify word exists
	if not manifested_words.has(word_id):
		return false
	
	var word = manifested_words[word_id]
	var old_state = word.duplicate()
	
	# Can only evolve if not at max stage
	if word.evolution_stage >= 5:
		return false
	
	# Increase evolution stage
	word.evolution_stage += 1
	
	# Enhance word based on new stage
	match word.evolution_stage:
		2: # Growth stage
			word.size *= 1.2
			word.power *= 1.1
			word.color = word.color.lightened(0.1)
		3: # Stability stage
			word.angular_velocity *= 0.5
			word.power *= 1.2
			word.color = word.color.darkened(0.1)
		4: # Radiance stage
			word.power *= 1.3
			word.color = word.color.lightened(0.2)
		5: # Transcendence stage
			word.power *= 1.5
			word.lifespan = -1  # Permanent
			word.color = Color(1, 1, 1).linear_interpolate(word.color, 0.5)
	
	# Update total power
	total_manifested_power += (word.power - old_state.power)
	
	# Emit signal
	emit_signal("word_evolved", word_id, old_state, word)
	
	print("Word evolved: '%s' to stage %d with power %.1f" % [word.text, word.evolution_stage, word.power])
	
	return true

func delete_word(word_id):
	# Verify word exists
	if not manifested_words.has(word_id):
		return false
	
	var word = manifested_words[word_id]
	
	# Remove connections first
	var connections_to_remove = []
	for connection_id in word.connections:
		connections_to_remove.append(connection_id)
	
	for connection_id in connections_to_remove:
		delete_connection(connection_id)
	
	# Update total power
	total_manifested_power -= word.power
	
	# Update dimension counts
	decrement_dimension_count(word.dimension)
	
	# Remove word
	manifested_words.erase(word_id)
	
	print("Word deleted: '%s'" % word.text)
	
	return true

func delete_connection(connection_id):
	# Find connection
	var connection_idx = -1
	for i in range(word_connections.size()):
		if word_connections[i].id == connection_id:
			connection_idx = i
			break
	
	if connection_idx == -1:
		return false
	
	var connection = word_connections[connection_idx]
	
	# Remove connection references from words
	if manifested_words.has(connection.word1_id):
		manifested_words[connection.word1_id].connections.erase(connection_id)
	
	if manifested_words.has(connection.word2_id):
		manifested_words[connection.word2_id].connections.erase(connection_id)
	
	# Emit signal
	emit_signal("connection_broken", connection_id)
	
	# Remove connection
	word_connections.remove(connection_idx)
	
	return true

# ----- PHYSICS FUNCTIONS -----
func process_word_physics(delta):
	# Process physics for each word
	for word_id in manifested_words:
		var word = manifested_words[word_id]
		
		# Skip non-physical processing in some dimensions
		if word.dimension == "1D" or word.dimension == "10D":
			continue
		
		# Apply gravity in physical dimensions (3D, 4D)
		if word.dimension == "3D" or word.dimension == "4D":
			word.velocity.y -= GRAVITY_FACTOR * delta
		
		# Update position
		word.position += word.velocity * delta
		
		# Update rotation
		word.rotation += word.angular_velocity * delta
		
		# Basic boundary check to keep words in visible space
		var boundary = 20.0
		
		if abs(word.position.x) > boundary:
			word.position.x = sign(word.position.x) * boundary
			word.velocity.x *= -0.8
		
		if abs(word.position.z) > boundary:
			word.position.z = sign(word.position.z) * boundary
			word.velocity.z *= -0.8
		
		# Floor collision
		if word.position.y < 0:
			word.position.y = 0
			word.velocity.y *= -0.5
			word.velocity.x *= 0.9
			word.velocity.z *= 0.9
		
		# Apply damping
		word.velocity *= 0.99
		word.angular_velocity *= 0.99
		
		# Check lifespan
		if word.lifespan > 0:
			word.lifespan -= delta
			if word.lifespan <= 0:
				# Mark for deletion
				delete_word(word_id)

func process_connections(delta):
	# Process physics for connections between words
	for connection in word_connections:
		# Skip if either word doesn't exist anymore
		if not manifested_words.has(connection.word1_id) or not manifested_words.has(connection.word2_id):
			continue
		
		var word1 = manifested_words[connection.word1_id]
		var word2 = manifested_words[connection.word2_id]
		
		# Calculate spring force
		var dir = word1.position.direction_to(word2.position)
		var distance = word1.position.distance_to(word2.position)
		var extension = distance - connection.ideal_distance
		
		# Spring force (stronger for strong connections)
		var spring_constant = 2.0 * connection.strength
		var force_magnitude = extension * spring_constant
		
		# Apply force to both words (equal and opposite)
		var force = dir * force_magnitude
		
		# Inverse mass gives proper acceleration
		var inv_mass1 = 1.0 / word1.mass
		var inv_mass2 = 1.0 / word2.mass
		
		# Apply acceleration
		word1.velocity += force * inv_mass1 * delta
		word2.velocity -= force * inv_mass2 * delta

# ----- HELPER FUNCTIONS -----
func calculate_word_power(word):
	# Basic power calculation based on length and composition
	var base_power = 10 + word.length() * 2
	
	# Bonus for special characters
	for c in word:
		if not c.is_valid_identifier():
			base_power += 3
	
	# Random factor
	base_power *= (0.8 + randf() * 0.4)
	
	return base_power

func get_word_color(word):
	# Check if word has a predefined color
	word = word.to_lower()
	for key in WORD_COLORS:
		if word.find(key) >= 0:
			return WORD_COLORS[key]
	
	# Use default color
	return WORD_COLORS.default

func calculate_word_affinity(word1, word2):
	# Calculate how well words connect together
	var affinity = 1.0
	
	# Contrasting words have higher affinity
	var w1 = word1.to_lower()
	var w2 = word2.to_lower()
	
	# Opposite concepts have high affinity
	var opposites = [
		["light", "dark"],
		["up", "down"],
		["good", "evil"],
		["hot", "cold"],
		["big", "small"],
		["fast", "slow"],
		["open", "closed"],
		["create", "destroy"]
	]
	
	for pair in opposites:
		if (w1.find(pair[0]) >= 0 and w2.find(pair[1]) >= 0) or \
		   (w1.find(pair[1]) >= 0 and w2.find(pair[0]) >= 0):
			affinity *= 2.0
	
	# Similar length words have increased affinity
	var length_diff = abs(word1.length() - word2.length())
	if length_diff <= 2:
		affinity *= 1.2
	
	# Randomness factor
	affinity *= (0.8 + randf() * 0.4)
	
	return affinity

func evolve_random_word():
	# Randomly evolve a word if possible
	if manifested_words.empty():
		return
	
	# Get random word
	var word_ids = manifested_words.keys()
	var random_word_id = word_ids[randi() % word_ids.size()]
	var word = manifested_words[random_word_id]
	
	# Higher chance of evolution for powerful words
	var evolution_chance = 0.1 + (word.power / 500.0)
	if randf() < evolution_chance:
		evolve_word(random_word_id)

func initialize_dimension_counts():
	# Initialize counts for all dimensions
	for i in range(1, 13):
		var dim = str(i) + "D"
		dimension_word_counts[dim] = 0

func increment_dimension_count(dimension):
	if dimension_word_counts.has(dimension):
		dimension_word_counts[dimension] += 1

func decrement_dimension_count(dimension):
	if dimension_word_counts.has(dimension) and dimension_word_counts[dimension] > 0:
		dimension_word_counts[dimension] -= 1

func check_dimension_limit(dimension):
	if not dimension_word_counts.has(dimension):
		return
	
	if dimension_word_counts[dimension] > MAX_WORDS_PER_DIMENSION:
		cull_oldest_words(dimension)

func cull_oldest_words(dimension):
	# Remove oldest words when dimension gets too crowded
	print("Dimension %s exceeded limit - culling oldest words" % dimension)
	
	# Collect all words in this dimension
	var dimension_words = []
	for word_id in manifested_words:
		if manifested_words[word_id].dimension == dimension:
			dimension_words.append(manifested_words[word_id])
	
	# Sort by creation time (oldest first)
	dimension_words.sort_custom(self, "_sort_words_by_age")
	
	# Delete oldest words until under limit
	var to_delete = dimension_words.size() - MAX_WORDS_PER_DIMENSION
	for i in range(min(to_delete, dimension_words.size())):
		# Don't delete evolved words
		if dimension_words[i].evolution_stage <= 2:
			delete_word(dimension_words[i].id)

func _sort_words_by_age(a, b):
	return a.creation_time < b.creation_time

# ----- TURN SYSTEM INTEGRATION -----
func update_dimension(turn, dimension, symbol):
	current_turn = turn
	current_dimension = dimension
	current_symbol = symbol
	print("Word Manifestation System now operating in dimension: %s (Turn %d: %s)" % [dimension, turn, symbol])

# ----- PUBLIC API -----
func get_word_list():
	return manifested_words

func get_connection_list():
	return word_connections

func get_word_count_in_dimension(dimension):
	if dimension_word_counts.has(dimension):
		return dimension_word_counts[dimension]
	return 0

func get_total_word_count():
	return manifested_words.size()

func get_total_power():
	return total_manifested_power

func set_word_processor(processor):
	word_processor = processor

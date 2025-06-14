extends Node

# Dream State Processor for JSH Ethereal Engine
# Creates and manages dream narratives across the multiverse
# Translates abstract concepts into visual stories and shapes

# Configuration
export var dream_density: float = 0.5  # How many dreams appear (0.0-1.0)
export var dream_persistence: float = 3.0  # How long dreams last in minutes
export var dream_connection_radius: float = 10.0  # How far dreams can connect
export var enable_story_generation: bool = true  # Enable procedural stories
export var dream_influence_reality: bool = true  # Dreams can affect physical reality

# Dream libraries
var dream_themes = [
	"creation", "destruction", "transformation", 
	"journey", "discovery", "loss", 
	"connection", "isolation", "transcendence"
]

var dream_locations = [
	"forgotten city", "crystal forest", "infinite ocean", 
	"memory palace", "void expanse", "light spiral", 
	"thought nexus", "concept field", "timeless plateau"
]

var dream_characters = [
	"guardian", "seeker", "creator", 
	"observer", "wanderer", "messenger", 
	"shadow", "reflection", "ancient one"
]

# Dream state tracking
var active_dreams = {}  # dream_id -> dream_data
var dream_connections = {}  # dream_id -> [connected_dream_ids]
var dream_influence_points = []  # Points where dreams affect reality
var current_dream_state = "dormant"  # dormant, active, lucid, nightmare, prophetic

# System references
var shape_visualizer = null
var multiverse_system = null
var player_controller = null

# Signals
signal dream_created(dream_id, dream_data)
signal dream_connected(source_id, target_id, connection_strength)
signal dream_state_changed(old_state, new_state)
signal dream_story_advanced(dream_id, story_fragment)
signal reality_influenced_by_dream(dream_id, influence_point, effect)

# ========== Initialization ==========

func _ready():
	initialize_system()
	
	# Start dream processing
	if enable_story_generation:
		_start_dream_cycle()

func initialize_system():
	# Find required systems in the scene tree
	shape_visualizer = get_node_or_null("/root/MultiverseShapeVisualizer")
	if not shape_visualizer:
		shape_visualizer = get_node_or_null("../MultiverseShapeVisualizer")
	
	multiverse_system = get_node_or_null("/root/MultiverseSystemIntegration")
	if not multiverse_system:
		multiverse_system = get_node_or_null("../MultiverseSystemIntegration")
	
	player_controller = get_node_or_null("/root/PlayerController")
	if not player_controller:
		player_controller = get_node_or_null("../PlayerController")
	
	if shape_visualizer:
		print("JSH Dream State Processor: Connected to Shape Visualizer")
	else:
		print("JSH Dream State Processor: Warning - Shape Visualizer not found")
	
	# Initialize dream state
	change_dream_state("dormant")

func _start_dream_cycle():
	# Start generating dreams at random intervals
	var timer = Timer.new()
	timer.wait_time = 10.0  # Initial delay
	timer.one_shot = true
	timer.connect("timeout", self, "_on_dream_cycle_timer")
	add_child(timer)
	timer.start()

func _on_dream_cycle_timer():
	# Generate a dream
	var dice_roll = randf()
	if dice_roll < dream_density:
		create_random_dream()
	
	# Process existing dreams
	process_active_dreams()
	
	# Schedule next cycle
	var next_time = 20.0 + (randf() * 40.0)  # 20-60 seconds between dream events
	var timer = Timer.new()
	timer.wait_time = next_time
	timer.one_shot = true
	timer.connect("timeout", self, "_on_dream_cycle_timer")
	add_child(timer)
	timer.start()

# ========== Dream Creation and Management ==========

func create_random_dream():
	# Generate basic dream components
	var theme = dream_themes[randi() % dream_themes.size()]
	var location = dream_locations[randi() % dream_locations.size()]
	var character = dream_characters[randi() % dream_characters.size()]
	
	# Create a story seed
	var story_seed = "A " + character + " in the " + location + " experiences " + theme
	
	# Generate a position based on player location if available
	var position = Vector3(0, 0, 0)
	if player_controller:
		position = player_controller.global_position
		position += Vector3(
			(randf() * 10.0) - 5.0,
			(randf() * 5.0),
			(randf() * 10.0) - 5.0
		)
	
	# Create the dream
	create_dream(story_seed, position)

func create_dream(story_seed: String, position: Vector3):
	# Create unique dream ID
	var dream_id = "dream_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
	
	# Build dream data structure
	var dream_data = {
		"id": dream_id,
		"story_seed": story_seed,
		"position": position,
		"created_time": OS.get_unix_time(),
		"expiry_time": OS.get_unix_time() + int(dream_persistence * 60),
		"narrative_fragments": [story_seed],
		"intensity": randf(),
		"reality_influence": randf() if dream_influence_reality else 0.0
	}
	
	# Store the dream
	active_dreams[dream_id] = dream_data
	
	# Create visual representation if shape visualizer is available
	if shape_visualizer:
		var dream_shape = shape_visualizer.create_dream_shape_from_story(story_seed, position)
		if dream_shape:
			dream_data["shape_node"] = dream_shape
	
	# Check for nearby dreams to connect
	connect_to_nearby_dreams(dream_id, position, dream_connection_radius)
	
	# Emit signal
	emit_signal("dream_created", dream_id, dream_data)
	
	# Schedule story advancement
	_schedule_story_advancement(dream_id)
	
	print("JSH Dream State Processor: Created dream '" + dream_id + "' - " + story_seed)
	
	return dream_id

func connect_to_nearby_dreams(dream_id: String, position: Vector3, radius: float):
	if not dream_connections.has(dream_id):
		dream_connections[dream_id] = []
	
	# Check all other active dreams for proximity
	for other_id in active_dreams:
		if other_id == dream_id:
			continue
		
		var other_dream = active_dreams[other_id]
		var distance = position.distance_to(other_dream.position)
		
		if distance <= radius:
			# Create connection
			dream_connections[dream_id].append(other_id)
			
			# Ensure the other dream has a connections list
			if not dream_connections.has(other_id):
				dream_connections[other_id] = []
			
			# Add reverse connection if not already present
			if not other_id in dream_connections[dream_id]:
				dream_connections[other_id].append(dream_id)
			
			# Calculate connection strength (closer = stronger)
			var connection_strength = 1.0 - (distance / radius)
			
			# Create visual connection if shape visualizer is available
			if shape_visualizer and active_dreams[dream_id].has("shape_node") and active_dreams[other_id].has("shape_node"):
				# This would require a method in shape_visualizer to create connections
				# For now we'll just emit the signal
				pass
			
			# Emit signal
			emit_signal("dream_connected", dream_id, other_id, connection_strength)
			
			print("JSH Dream State Processor: Connected dream '" + dream_id + "' to '" + other_id + "'")

func _schedule_story_advancement(dream_id: String):
	if not enable_story_generation or not active_dreams.has(dream_id):
		return
	
	# Schedule next story fragment
	var timer = Timer.new()
	timer.wait_time = 30.0 + (randf() * 60.0)  # 30-90 seconds between story advancements
	timer.one_shot = true
	timer.connect("timeout", self, "_on_story_advancement_timer", [dream_id])
	add_child(timer)
	timer.start()

func _on_story_advancement_timer(dream_id: String):
	if not active_dreams.has(dream_id):
		return
	
	# Generate next story fragment
	advance_dream_story(dream_id)
	
	# Schedule next advancement if dream still exists
	if active_dreams.has(dream_id):
		_schedule_story_advancement(dream_id)

func advance_dream_story(dream_id: String):
	if not active_dreams.has(dream_id):
		return false
	
	var dream_data = active_dreams[dream_id]
	var last_fragment = dream_data.narrative_fragments[dream_data.narrative_fragments.size() - 1]
	
	# Generate next story fragment based on the previous one
	var next_fragment = generate_story_continuation(last_fragment, dream_data)
	
	# Add to narrative fragments
	dream_data.narrative_fragments.append(next_fragment)
	
	# Update visual representation if shape visualizer is available
	if shape_visualizer and dream_data.has("shape_node"):
		# Transform the shape based on new story
		# This would require a method in shape_visualizer to update dream shapes
		# For now we'll just emit the signal
		pass
	
	# Check for reality influence
	if dream_influence_reality and dream_data.reality_influence > 0.3:
		apply_dream_to_reality(dream_id, next_fragment)
	
	# Emit signal
	emit_signal("dream_story_advanced", dream_id, next_fragment)
	
	print("JSH Dream State Processor: Advanced story for dream '" + dream_id + "'")
	return true

func generate_story_continuation(previous_fragment: String, dream_data: Dictionary) -> String:
	# Generate next part of the dream narrative
	
	# Extract core elements from previous fragment
	var words = previous_fragment.split(" ")
	var key_elements = []
	
	for word in words:
		if word.length() > 4:  # Only consider significant words
			key_elements.append(word)
	
	# Choose a random path for the story
	var story_directions = [
		"discovers", "encounters", "transforms into", 
		"merges with", "escapes from", "creates",
		"destroys", "journeys to", "remembers"
	]
	
	var direction = story_directions[randi() % story_directions.size()]
	
	# Choose elements to include
	var element_pool = dream_themes + dream_locations + dream_characters
	var new_element = element_pool[randi() % element_pool.size()]
	
	# Build new fragment
	var protagonist = ""
	if key_elements.size() > 0:
		protagonist = key_elements[randi() % key_elements.size()]
	else:
		protagonist = "entity"
	
	var next_fragment = "The " + protagonist + " " + direction + " the " + new_element
	
	# Add emotional tone
	var emotions = [
		"with wonder", "fearfully", "joyously", 
		"mysteriously", "reluctantly", "inevitably"
	]
	
	if randf() > 0.5:  # 50% chance to add emotion
		next_fragment += " " + emotions[randi() % emotions.size()]
	
	return next_fragment

func apply_dream_to_reality(dream_id: String, story_fragment: String):
	if not active_dreams.has(dream_id):
		return
	
	var dream_data = active_dreams[dream_id]
	
	# Calculate influence point
	var influence_position = dream_data.position
	
	# Modify position based on player if available
	if player_controller:
		influence_position = player_controller.global_position + Vector3(
			(randf() * 20.0) - 10.0,
			0,
			(randf() * 20.0) - 10.0
		)
	
	# Create influence record
	var influence_data = {
		"position": influence_position,
		"dream_id": dream_id,
		"story_fragment": story_fragment,
		"intensity": dream_data.reality_influence,
		"time_created": OS.get_unix_time(),
		"duration": 300 + (int(randf() * 300))  # 5-10 minutes
	}
	
	dream_influence_points.append(influence_data)
	
	# Create reality effect if multiverse system is available
	if multiverse_system:
		# In a full implementation, this would trigger universe properties to change
		# or create anomalies in reality based on the dream
		pass
	
	# Create visual manifestation if shape visualizer is available
	if shape_visualizer:
		# Create a shape at the influence point
		# This would be a method in shape_visualizer to create reality anomalies
		# For now we'll just emit the signal
		pass
	
	# Emit signal
	emit_signal("reality_influenced_by_dream", dream_id, influence_position, story_fragment)
	
	print("JSH Dream State Processor: Dream '" + dream_id + "' influenced reality")
	
	return influence_data

func process_active_dreams():
	var current_time = OS.get_unix_time()
	var dreams_to_remove = []
	
	# Check for expired dreams
	for dream_id in active_dreams:
		var dream_data = active_dreams[dream_id]
		
		if dream_data.expiry_time <= current_time:
			dreams_to_remove.append(dream_id)
	
	# Remove expired dreams
	for dream_id in dreams_to_remove:
		remove_dream(dream_id)
		
	# Process connections for remaining dreams
	for dream_id in active_dreams:
		if dream_connections.has(dream_id):
			var connections = dream_connections[dream_id]
			var valid_connections = []
			
			# Keep only valid connections
			for connected_id in connections:
				if active_dreams.has(connected_id):
					valid_connections.append(connected_id)
			
			dream_connections[dream_id] = valid_connections
	
	# Process reality influence points
	process_influence_points()

func remove_dream(dream_id: String):
	if not active_dreams.has(dream_id):
		return
	
	var dream_data = active_dreams[dream_id]
	
	# Remove visual representation if it exists
	if dream_data.has("shape_node") and is_instance_valid(dream_data.shape_node):
		dream_data.shape_node.queue_free()
	
	# Remove connections
	if dream_connections.has(dream_id):
		# Remove this dream from other dreams' connections
		for connected_id in dream_connections[dream_id]:
			if dream_connections.has(connected_id):
				var idx = dream_connections[connected_id].find(dream_id)
				if idx >= 0:
					dream_connections[connected_id].remove(idx)
		
		# Remove this dream's connections
		dream_connections.erase(dream_id)
	
	# Remove dream data
	active_dreams.erase(dream_id)
	
	print("JSH Dream State Processor: Removed dream '" + dream_id + "'")

func process_influence_points():
	var current_time = OS.get_unix_time()
	var points_to_remove = []
	
	# Check for expired influence points
	for i in range(dream_influence_points.size()):
		var influence = dream_influence_points[i]
		
		if influence.time_created + influence.duration <= current_time:
			points_to_remove.append(i)
	
	# Remove expired points (in reverse order to maintain indices)
	points_to_remove.sort()
	points_to_remove.reverse()
	
	for idx in points_to_remove:
		dream_influence_points.remove(idx)

# ========== Dream State Management ==========

func change_dream_state(new_state: String):
	var old_state = current_dream_state
	current_dream_state = new_state
	
	# Apply effects based on new state
	match new_state:
		"dormant":
			dream_density = 0.1
			dream_persistence = 2.0
		"active":
			dream_density = 0.5
			dream_persistence = 3.0
		"lucid":
			dream_density = 0.7
			dream_persistence = 5.0
			dream_influence_reality = true
		"nightmare":
			dream_density = 0.9
			dream_persistence = 2.0
			dream_influence_reality = true
		"prophetic":
			dream_density = 0.3
			dream_persistence = 10.0
			dream_influence_reality = true
	
	# Emit signal
	emit_signal("dream_state_changed", old_state, new_state)
	
	print("JSH Dream State Processor: Changed dream state from '" + old_state + "' to '" + new_state + "'")
	
	return true

func get_dream_state() -> String:
	return current_dream_state

func get_active_dream_count() -> int:
	return active_dreams.size()

func get_dream_by_id(dream_id: String) -> Dictionary:
	if active_dreams.has(dream_id):
		return active_dreams[dream_id]
	return {}

func get_dreams_at_position(position: Vector3, radius: float) -> Array:
	var nearby_dreams = []
	
	for dream_id in active_dreams:
		var dream = active_dreams[dream_id]
		var distance = position.distance_to(dream.position)
		
		if distance <= radius:
			nearby_dreams.append(dream)
	
	return nearby_dreams

func get_nearest_dream(position: Vector3) -> Dictionary:
	var nearest_dream = null
	var nearest_distance = INF
	
	for dream_id in active_dreams:
		var dream = active_dreams[dream_id]
		var distance = position.distance_to(dream.position)
		
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_dream = dream
	
	if nearest_dream:
		return nearest_dream
	return {}

# ========== Player Interaction ==========

func enter_dream(dream_id: String):
	if not active_dreams.has(dream_id):
		return false
	
	var dream_data = active_dreams[dream_id]
	
	# Change state to lucid
	change_dream_state("lucid")
	
	# Notify multiverse system if available
	if multiverse_system:
		# This would trigger a transition to a dream universe
		# In a full implementation, this would be a method in multiverse_system
		pass
	
	# Notify player controller if available
	if player_controller:
		# This would switch player movement mode to dream navigation
		# In a full implementation, this would be a method in player_controller
		pass
	
	print("JSH Dream State Processor: Entered dream '" + dream_id + "'")
	
	return true

func exit_dream():
	# Return from dream state
	change_dream_state("active")
	
	# Notify multiverse system if available
	if multiverse_system:
		# This would trigger a transition back to the physical universe
		# In a full implementation, this would be a method in multiverse_system
		pass
	
	# Notify player controller if available
	if player_controller:
		# This would switch player movement mode back to normal
		# In a full implementation, this would be a method in player_controller
		pass
	
	print("JSH Dream State Processor: Exited dream state")
	
	return true

func get_full_dream_narrative(dream_id: String) -> String:
	if not active_dreams.has(dream_id):
		return ""
	
	var dream_data = active_dreams[dream_id]
	var narrative = ""
	
	for fragment in dream_data.narrative_fragments:
		narrative += fragment + "\n"
	
	return narrative
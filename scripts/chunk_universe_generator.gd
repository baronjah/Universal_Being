# ==================================================
# SYSTEM: Chunk Universe Generator
# PURPOSE: Generate infinite cosmos with heightmaps, stars, galaxies, planets
# FEATURES: 3D chunk grid where each chunk center is a Universal Being
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name ChunkUniverseGenerator

# ===== UNIVERSE GENERATION PROPERTIES =====
@export var chunk_size: Vector3 = Vector3(100, 100, 100)
@export var max_view_distance: float = 1000.0
@export var heightmap_resolution: int = 256
@export var universe_scale: float = 1.0

# Chunk management
var active_chunks: Dictionary = {}  # Vector3i -> ChunkUniversalBeing
var chunk_queue: Array[Vector3i] = []
var generation_thread: Thread

# Universe types and rules
enum UniverseType {
	FLAT_WORLD,     # Heightmaps for terrain, clouds, water
	PLANET,         # Spherical world with gravity
	ASTEROID_FIELD, # Scattered objects in space
	STAR_SYSTEM,    # Central star with orbiting bodies
	GALAXY,         # Collection of star systems
	COSMOS          # Multiple galaxies
}

var universe_rules: Dictionary = {
	"type": UniverseType.FLAT_WORLD,
	"gravity": Vector3(0, -9.8, 0),
	"atmosphere": true,
	"water_level": 0.0,
	"cloud_height": 50.0,
	"time_scale": 1.0,
	"physics_rules": "standard"
}

# Heightmap layers for flat worlds
var terrain_heightmap: ImageTexture
var water_heightmap: ImageTexture
var cloud_heightmap: ImageTexture

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "chunk_universe_generator"
	being_name = "Infinite Cosmos Generator"
	consciousness_level = 4  # Enlightened universe creator
	
	# Set up universe generation
	_initialize_generation_system()
	
	print("🌌 %s: Pentagon Init - Reality generator awakens" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to player mover for chunk generation
	_connect_to_player()
	
	# Start generation thread
	generation_thread = Thread.new()
	
	print("🌌 %s: Pentagon Ready - Infinite cosmos awaits" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update active chunks
	_update_chunk_system(delta)
	
	# Process generation queue
	_process_generation_queue()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	if generation_thread and generation_thread.is_started():
		generation_thread.wait_to_finish()
	print("🌌 %s: Universe generator returning to void..." % being_name)
	super.pentagon_sewers()

# ===== UNIVERSE GENERATION SYSTEM =====

func _initialize_generation_system() -> void:
	"""Initialize the universe generation system"""
	# Generate base heightmaps
	_generate_base_heightmaps()
	
	# Set up chunk generation rules
	_setup_generation_rules()

func _generate_base_heightmaps() -> void:
	"""Generate base heightmaps for terrain, water, clouds"""
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.01
	
	# Terrain heightmap
	var terrain_image = Image.create(heightmap_resolution, heightmap_resolution, false, Image.FORMAT_RF)
	for x in range(heightmap_resolution):
		for y in range(heightmap_resolution):
			var height = noise.get_noise_2d(x, y) * 0.5 + 0.5
			terrain_image.set_pixel(x, y, Color(height, height, height, 1))
	
	terrain_heightmap = ImageTexture.new()
	terrain_heightmap.set_image(terrain_image)
	
	# Water heightmap (slightly different)
	noise.frequency = 0.005
	var water_image = Image.create(heightmap_resolution, heightmap_resolution, false, Image.FORMAT_RF)
	for x in range(heightmap_resolution):
		for y in range(heightmap_resolution):
			var height = (noise.get_noise_2d(x, y) * 0.3 + 0.7) * 0.2  # Lower and flatter
			water_image.set_pixel(x, y, Color(height, height, height, 1))
	
	water_heightmap = ImageTexture.new()
	water_heightmap.set_image(water_image)
	
	# Cloud heightmap (more turbulent)
	noise.frequency = 0.02
	var cloud_image = Image.create(heightmap_resolution, heightmap_resolution, false, Image.FORMAT_RF)
	for x in range(heightmap_resolution):
		for y in range(heightmap_resolution):
			var height = (noise.get_noise_2d(x, y) * 0.4 + 0.6) * 0.8 + 0.2  # Higher and varied
			cloud_image.set_pixel(x, y, Color(height, height, height, 1))
	
	cloud_heightmap = ImageTexture.new()
	cloud_heightmap.set_image(cloud_image)
	
	print("🌍 Generated base heightmaps for universe")

func _setup_generation_rules() -> void:
	"""Set up rules for different universe types"""
	# Rules can be modified via console interfaces
	set_meta("universe_rules", universe_rules)

func _connect_to_player() -> void:
	"""Connect to player for chunk generation around them"""
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("movement_started"):
		player.movement_started.connect(_on_player_moved)

# ===== CHUNK MANAGEMENT =====

func _update_chunk_system(delta: float) -> void:
	"""Update the chunk system around player"""
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var player_pos = player.global_position
	var player_chunk = _world_to_chunk_coords(player_pos)
	
	# Generate chunks around player
	_ensure_chunks_around(player_chunk, 3)  # 3 chunk radius
	
	# Unload distant chunks
	_unload_distant_chunks(player_chunk, 5)  # Unload beyond 5 chunks

func _ensure_chunks_around(center: Vector3i, radius: int) -> void:
	"""Ensure chunks exist around center coordinate"""
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			for z in range(center.z - radius, center.z + radius + 1):
				var chunk_coord = Vector3i(x, y, z)
				if not active_chunks.has(chunk_coord):
					_generate_chunk_at(chunk_coord)

func _generate_chunk_at(coords: Vector3i) -> void:
	"""Generate a chunk at specific coordinates"""
	# Create chunk Universal Being
	var ChunkBeingClass = load("res://systems/chunks/luminus_chunk_universal_being.gd")
	var chunk_being = Node3D.new()
	chunk_being.set_script(ChunkBeingClass)
	chunk_being.name = "Chunk_%d_%d_%d" % [coords.x, coords.y, coords.z]
	
	# Position chunk
	var world_pos = _chunk_to_world_coords(coords)
	chunk_being.position = world_pos
	
	# Set chunk properties
	chunk_being.set("coords", coords)
	chunk_being.set("chunk_size", chunk_size)
	chunk_being.set("generator", self)
	
	# Add to scene
	add_child(chunk_being)
	active_chunks[coords] = chunk_being
	
	# Generate content based on universe type
	_populate_chunk(chunk_being, coords)
	
	print("🌌 Generated chunk at %s" % coords)

func _populate_chunk(chunk: Node, coords: Vector3i) -> void:
	"""Populate chunk with content based on universe rules"""
	match universe_rules.type:
		UniverseType.FLAT_WORLD:
			_populate_flat_world_chunk(chunk, coords)
		UniverseType.PLANET:
			_populate_planet_chunk(chunk, coords)
		UniverseType.STAR_SYSTEM:
			_populate_star_system_chunk(chunk, coords)
		UniverseType.GALAXY:
			_populate_galaxy_chunk(chunk, coords)

func _populate_planet_chunk(chunk: Node, coords: Vector3i) -> void:
	"""Populate chunk for planet-type universe"""
	# Create spherical terrain
	print("🪐 Generating planet chunk at %s" % coords)

func _populate_star_system_chunk(chunk: Node, coords: Vector3i) -> void:
	"""Populate chunk for star system"""
	# Create star and orbiting bodies
	print("⭐ Generating star system chunk at %s" % coords)

func _populate_galaxy_chunk(chunk: Node, coords: Vector3i) -> void:
	"""Populate chunk for galaxy"""
	# Create multiple star systems
	print("🌌 Generating galaxy chunk at %s" % coords)

func _populate_flat_world_chunk(chunk: Node, coords: Vector3i) -> void:
	"""Populate chunk for flat world with heightmaps"""
	# Generate terrain at different heights
	_generate_terrain_layer(chunk, coords, 0.0, terrain_heightmap)
	
	# Generate water layer
	if universe_rules.water_level > 0:
		_generate_water_layer(chunk, coords, universe_rules.water_level, water_heightmap)
	
	# Generate cloud layer
	if universe_rules.cloud_height > 0:
		_generate_cloud_layer(chunk, coords, universe_rules.cloud_height, cloud_heightmap)

func _generate_terrain_layer(chunk: Node, coords: Vector3i, base_height: float, heightmap: ImageTexture) -> void:
	"""Generate terrain using heightmap"""
	# Create terrain mesh from heightmap
	var terrain_being = _create_terrain_being(coords, base_height, heightmap)
	chunk.add_child(terrain_being)

func _generate_water_layer(chunk: Node, coords: Vector3i, water_level: float, heightmap: ImageTexture) -> void:
	"""Generate water layer"""
	var water_being = _create_water_being(coords, water_level, heightmap)
	chunk.add_child(water_being)

func _generate_cloud_layer(chunk: Node, coords: Vector3i, cloud_height: float, heightmap: ImageTexture) -> void:
	"""Generate cloud layer"""
	var cloud_being = _create_cloud_being(coords, cloud_height, heightmap)
	chunk.add_child(cloud_being)

func _create_terrain_being(coords: Vector3i, height: float, heightmap: ImageTexture) -> UniversalBeing:
	"""Create a terrain Universal Being"""
	var terrain = load("res://beings/ground_universal_being.gd").new()
	terrain.name = "TerrainBeing_%d_%d_%d" % [coords.x, coords.y, coords.z]
	terrain.being_type = "terrain"
	terrain.being_name = "Living Terrain"
	terrain.consciousness_level = 1
	terrain.position.y = height
	return terrain

func _create_water_being(coords: Vector3i, height: float, heightmap: ImageTexture) -> UniversalBeing:
	"""Create a water Universal Being"""
	var water = Node3D.new()
	water.set_script(load("res://core/UniversalBeing.gd"))
	water.name = "WaterBeing_%d_%d_%d" % [coords.x, coords.y, coords.z]
	water.set("being_type", "water")
	water.set("being_name", "Conscious Waters")
	water.set("consciousness_level", 2)
	water.position.y = height
	return water

func _create_cloud_being(coords: Vector3i, height: float, heightmap: ImageTexture) -> UniversalBeing:
	"""Create a cloud Universal Being"""
	var cloud = Node3D.new()
	cloud.set_script(load("res://core/UniversalBeing.gd"))
	cloud.name = "CloudBeing_%d_%d_%d" % [coords.x, coords.y, coords.z]
	cloud.set("being_type", "cloud")
	cloud.set("being_name", "Sky Consciousness")
	cloud.set("consciousness_level", 2)
	cloud.position.y = height
	return cloud

func _unload_distant_chunks(center: Vector3i, max_distance: int) -> void:
	"""Unload chunks that are too far from center"""
	var to_remove: Array[Vector3i] = []
	
	for coords in active_chunks.keys():
		var distance = (coords - center).length()
		if distance > max_distance:
			to_remove.append(coords)
	
	for coords in to_remove:
		var chunk = active_chunks[coords]
		# Save to Akashic Records before removing
		if chunk.has_method("save_to_akashic"):
			chunk.save_to_akashic()
		chunk.queue_free()
		active_chunks.erase(coords)

# ===== COORDINATE CONVERSION =====

func _world_to_chunk_coords(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinates"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size.x)),
		int(floor(world_pos.y / chunk_size.y)),
		int(floor(world_pos.z / chunk_size.z))
	)

func _chunk_to_world_coords(chunk_coords: Vector3i) -> Vector3:
	"""Convert chunk coordinates to world position"""
	return Vector3(
		chunk_coords.x * chunk_size.x,
		chunk_coords.y * chunk_size.y,
		chunk_coords.z * chunk_size.z
	)

# ===== UNIVERSE RULE INTERFACES =====

func set_universe_type(new_type: UniverseType) -> void:
	"""Set universe generation type"""
	universe_rules.type = new_type
	print("🌌 Universe type set to: %s" % UniverseType.keys()[new_type])

func set_gravity(gravity: Vector3) -> void:
	"""Set universe gravity"""
	universe_rules.gravity = gravity

func set_water_level(level: float) -> void:
	"""Set water level for flat worlds"""
	universe_rules.water_level = level

func set_cloud_height(height: float) -> void:
	"""Set cloud layer height"""
	universe_rules.cloud_height = height

func set_time_scale(scale: float) -> void:
	"""Set universe time scale"""
	universe_rules.time_scale = scale
	Engine.time_scale = scale

# ===== CONSOLE INTERFACE =====

func ai_interface() -> Dictionary:
	"""AI interface for console commands"""
	var base = super.ai_interface()
	
	base.commands.merge({
		"set_universe_type": "Change universe generation type",
		"set_gravity": "Set gravity vector",
		"set_water_level": "Set water height for flat worlds",
		"set_cloud_height": "Set cloud layer height",
		"generate_around": "Generate chunks around position",
		"regenerate_heightmaps": "Regenerate terrain heightmaps"
	})
	
	base.state.merge({
		"universe_type": UniverseType.keys()[universe_rules.type],
		"active_chunks": active_chunks.size(),
		"water_level": universe_rules.water_level,
		"cloud_height": universe_rules.cloud_height,
		"time_scale": universe_rules.time_scale
	})
	
	return base

# ===== EVENT HANDLERS =====

func _on_player_moved(target: Vector3) -> void:
	"""Handle player movement for chunk generation"""
	var chunk_coord = _world_to_chunk_coords(target)
	_ensure_chunks_around(chunk_coord, 2)

func _process_generation_queue() -> void:
	"""Process the chunk generation queue"""
	if chunk_queue.size() > 0:
		var coords = chunk_queue.pop_front()
		_generate_chunk_at(coords)

# ===== UNIVERSE RULES EDITOR INTEGRATION =====

func set_universe_rules(rules_data: Dictionary) -> void:
	"""Set universe rules from the Universe Rules Editor"""
	if rules_data.has("rules"):
		var new_rules = rules_data.rules
		print("🌌 Applying %d universe rules from editor" % new_rules.size())
		
		# Apply each rule to universe generation
		for rule in new_rules:
			_apply_generation_rule(rule)
	
	if rules_data.has("layer_interactions"):
		var interactions = rules_data.layer_interactions
		print("🌌 Applying layer interactions: %s" % interactions)
		
		# Store interaction settings
		set_meta("layer_interactions", interactions)
		
		# Apply interaction rules to existing chunks if needed
		_update_chunk_interactions(interactions)
	
	print("🌌 Universe rules successfully applied to chunk generator")

func _apply_generation_rule(rule: Dictionary) -> void:
	"""Apply a single generation rule"""
	var rule_name = rule.get("name", "Unnamed Rule")
	var layer_type = rule.get("type", 0)
	var height_from = rule.get("height_from", 0)
	var height_to = rule.get("height_to", 10)
	var density = rule.get("density", 50)
	
	# Convert editor rule to internal format
	var internal_rule = {
		"name": rule_name,
		"layer_type": _convert_layer_type(layer_type),
		"height_range": Vector2(height_from, height_to),
		"density": density / 100.0,  # Convert percentage to 0-1
		"active": true
	}
	
	# Store in universe rules
	if not universe_rules.has("custom_rules"):
		universe_rules.custom_rules = []
	
	# Update existing rule or add new one
	var rule_updated = false
	for i in range(universe_rules.custom_rules.size()):
		if universe_rules.custom_rules[i].name == rule_name:
			universe_rules.custom_rules[i] = internal_rule
			rule_updated = true
			break
	
	if not rule_updated:
		universe_rules.custom_rules.append(internal_rule)
	
	print("🌌 Applied rule: %s (Type: %s, Height: %d-%d, Density: %d%%)" % [
		rule_name, 
		internal_rule.layer_type,
		height_from,
		height_to,
		density
	])

func _convert_layer_type(type_index: int) -> String:
	"""Convert editor layer type index to internal string"""
	var layer_types = [
		"terrain",      # 0: Terrain/Ground
		"water",        # 1: Water Layer
		"clouds",       # 2: Cloud Layer
		"atmosphere",   # 3: Atmosphere
		"volcanic",     # 4: Volcanic
		"ice",          # 5: Ice/Snow
		"vegetation"    # 6: Vegetation
	]
	
	if type_index >= 0 and type_index < layer_types.size():
		return layer_types[type_index]
	else:
		return "terrain"

func _update_chunk_interactions(interactions: Dictionary) -> void:
	"""Update existing chunks with new interaction rules"""
	var water_over_ground = interactions.get("water_over_ground", true)
	var sun_evaporation = interactions.get("sun_evaporation", true)
	var rain_generation = interactions.get("rain_generation", true)
	var cloud_wind = interactions.get("cloud_wind", true)
	
	# Apply to all active chunks
	for coords in active_chunks.keys():
		var chunk = active_chunks[coords]
		if chunk.has_method("apply_layer_interactions"):
			chunk.apply_layer_interactions({
				"water_over_ground": water_over_ground,
				"sun_evaporation": sun_evaporation,
				"rain_generation": rain_generation,
				"cloud_wind": cloud_wind
			})
	
	print("🌌 Updated %d active chunks with new interaction rules" % active_chunks.size())

func get_current_rules() -> Dictionary:
	"""Get current universe rules for the editor"""
	var rules_array = []
	
	if universe_rules.has("custom_rules"):
		for rule in universe_rules.custom_rules:
			var editor_rule = {
				"name": rule.name,
				"type": _get_layer_type_index(rule.layer_type),
				"height_from": int(rule.height_range.x),
				"height_to": int(rule.height_range.y),
				"density": int(rule.density * 100)
			}
			rules_array.append(editor_rule)
	
	var interactions = get_meta("layer_interactions", {
		"water_over_ground": true,
		"sun_evaporation": true,
		"rain_generation": true,
		"cloud_wind": true
	})
	
	return {
		"rules": rules_array,
		"layer_interactions": interactions
	}

func _get_layer_type_index(layer_type: String) -> int:
	"""Convert internal layer type to editor index"""
	var layer_types = ["terrain", "water", "clouds", "atmosphere", "volcanic", "ice", "vegetation"]
	var index = layer_types.find(layer_type)
	return index if index >= 0 else 0
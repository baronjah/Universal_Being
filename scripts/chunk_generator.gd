# ChunkGenerator - Simple content generation for chunks based on Y-layer rules
# Combines JSH's detailed approach with Luminus's elegance

extends Object
class_name ChunkGenerator

# ===== Y-LAYER RULES =====
const TERRAIN_LAYERS = [-5, 10]        # Surface terrain
const SKY_LAYERS = [11, 50]            # Sky and clouds  
const SPACE_LAYERS = [51, 200]         # Near space
const COSMIC_LAYERS = [201, 1000]      # Deep space
const UNDERGROUND_LAYERS = [-100, -6]  # Underground

# ===== GENERATION PROBABILITIES =====
static var generation_rules = {
	"terrain": {
		"vegetation_chance": 0.7,
		"structure_chance": 0.2,
		"water_chance": 0.3
	},
	"sky": {
		"cloud_chance": 0.5,
		"flying_being_chance": 0.1,
		"platform_chance": 0.1
	},
	"space": {
		"star_chance": 0.3,
		"asteroid_chance": 0.1,
		"cosmic_being_chance": 0.05
	},
	"underground": {
		"cave_chance": 0.4,
		"mineral_chance": 0.6,
		"underground_being_chance": 0.1
	}
}

# ===== PUBLIC API =====

static func populate(chunk: ChunkUniversalBeing) -> void:
	"""Populate chunk based on Y-layer rules - Luminus approach with JSH detail"""
	var y_layer = chunk.coords.y
	var layer_type = get_layer_type(y_layer)
	
	print("🎨 Populating chunk %s (Y:%d, Type:%s)" % [chunk.name, y_layer, layer_type])
	
	match layer_type:
		"underground":
			_populate_underground(chunk)
		"terrain":
			_populate_terrain(chunk)
		"sky":
			_populate_sky(chunk)
		"space":
			_populate_space(chunk)
		"cosmic":
			_populate_cosmic(chunk)

static func ensure_chunks_around(pos: Vector3) -> void:
	"""Ensure chunks are loaded around position - Luminus pattern"""
	if not ChunkGridManager:
		return
		
	var center = ChunkGridManager._world_to_chunk_coords(pos)
	ChunkGridManager._stream_around(center)

static func get_layer_type(y_coord: int) -> String:
	"""Get the layer type for a Y coordinate"""
	if y_coord >= UNDERGROUND_LAYERS[0] and y_coord <= UNDERGROUND_LAYERS[1]:
		return "underground"
	elif y_coord >= TERRAIN_LAYERS[0] and y_coord <= TERRAIN_LAYERS[1]:
		return "terrain"
	elif y_coord >= SKY_LAYERS[0] and y_coord <= SKY_LAYERS[1]:
		return "sky"
	elif y_coord >= SPACE_LAYERS[0] and y_coord <= SPACE_LAYERS[1]:
		return "space"
	else:
		return "cosmic"

# ===== LAYER-SPECIFIC GENERATION =====

static func _populate_underground(chunk: ChunkUniversalBeing) -> void:
	"""Generate underground content"""
	var rules = generation_rules.underground
	
	# Caves
	if randf() < rules.cave_chance:
		_create_cave_system(chunk)
	
	# Minerals
	if randf() < rules.mineral_chance:
		_create_mineral_deposits(chunk)
	
	# Underground beings
	if randf() < rules.underground_being_chance:
		_create_underground_being(chunk)

static func _populate_terrain(chunk: ChunkUniversalBeing) -> void:
	"""Generate surface terrain content"""
	var rules = generation_rules.terrain
	
	# Always generate basic terrain
	_create_basic_terrain(chunk)
	
	# Vegetation
	if randf() < rules.vegetation_chance:
		_create_vegetation(chunk)
	
	# Structures
	if randf() < rules.structure_chance:
		_create_structures(chunk)
	
	# Water features
	if randf() < rules.water_chance:
		_create_water_features(chunk)

static func _populate_sky(chunk: ChunkUniversalBeing) -> void:
	"""Generate sky layer content"""
	var rules = generation_rules.sky
	
	# Clouds
	if randf() < rules.cloud_chance:
		_create_clouds(chunk)
	
	# Flying beings
	if randf() < rules.flying_being_chance:
		_create_flying_being(chunk)
	
	# Floating platforms
	if randf() < rules.platform_chance:
		_create_floating_platform(chunk)

static func _populate_space(chunk: ChunkUniversalBeing) -> void:
	"""Generate space layer content"""
	var rules = generation_rules.space
	
	# Stars
	if randf() < rules.star_chance:
		_create_star_system(chunk)
	
	# Asteroids
	if randf() < rules.asteroid_chance:
		_create_asteroid(chunk)
	
	# Cosmic beings
	if randf() < rules.cosmic_being_chance:
		_create_cosmic_being(chunk)

static func _populate_cosmic(chunk: ChunkUniversalBeing) -> void:
	"""Generate deep cosmic content"""
	# Rare cosmic phenomena
	if randf() < 0.1:
		_create_cosmic_phenomenon(chunk)
	
	# Dimensional rifts
	if randf() < 0.05:
		_create_dimensional_rift(chunk)

# ===== CONTENT CREATION METHODS =====

static func _create_basic_terrain(chunk: ChunkUniversalBeing) -> void:
	"""Create basic terrain features"""
	chunk.stored_data["terrain_type"] = "basic_surface"
	chunk.stored_data["elevation"] = randf_range(-2.0, 5.0)
	print("🏔️ Generated basic terrain in %s" % chunk.name)

static func _create_vegetation(chunk: ChunkUniversalBeing) -> void:
	"""Create vegetation beings"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var plant = SystemBootstrap.create_universal_being()
		if plant:
			plant.being_type = "plant"
			plant.being_name = "Chunk Plant"
			plant.consciousness_level = 1
			chunk.add_being_to_chunk(plant)
			print("🌱 Generated vegetation in %s" % chunk.name)

static func _create_structures(chunk: ChunkUniversalBeing) -> void:
	"""Create structure beings"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var structure = SystemBootstrap.create_universal_being()
		if structure:
			structure.being_type = "structure"
			structure.being_name = "Chunk Structure"
			structure.consciousness_level = 1
			chunk.add_being_to_chunk(structure)
			print("🏗️ Generated structure in %s" % chunk.name)

static func _create_water_features(chunk: ChunkUniversalBeing) -> void:
	"""Create water features"""
	chunk.stored_data["water_type"] = ["stream", "pond", "spring"][randi() % 3]
	print("💧 Generated water features in %s" % chunk.name)

static func _create_cave_system(chunk: ChunkUniversalBeing) -> void:
	"""Create cave systems"""
	chunk.stored_data["cave_system"] = {
		"type": "natural_cave",
		"depth": randf_range(5.0, 20.0),
		"connections": randi_range(1, 4)
	}
	print("🕳️ Generated cave system in %s" % chunk.name)

static func _create_mineral_deposits(chunk: ChunkUniversalBeing) -> void:
	"""Create mineral deposits"""
	var minerals = ["iron", "crystal", "rare_earth", "gemstone"]
	chunk.stored_data["minerals"] = minerals[randi() % minerals.size()]
	print("💎 Generated mineral deposits in %s" % chunk.name)

static func _create_underground_being(chunk: ChunkUniversalBeing) -> void:
	"""Create underground dweller"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.being_type = "underground_dweller"
			being.being_name = "Cave Dweller"
			being.consciousness_level = 2
			chunk.add_being_to_chunk(being)
			print("🦇 Generated underground being in %s" % chunk.name)

static func _create_clouds(chunk: ChunkUniversalBeing) -> void:
	"""Create cloud formations"""
	chunk.stored_data["cloud_type"] = ["cumulus", "stratus", "cirrus"][randi() % 3]
	print("☁️ Generated clouds in %s" % chunk.name)

static func _create_flying_being(chunk: ChunkUniversalBeing) -> void:
	"""Create flying creatures"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.being_type = "flying_creature"
			being.being_name = "Sky Dweller"
			being.consciousness_level = 3
			chunk.add_being_to_chunk(being)
			print("🦅 Generated flying being in %s" % chunk.name)

static func _create_floating_platform(chunk: ChunkUniversalBeing) -> void:
	"""Create floating platforms"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var platform = SystemBootstrap.create_universal_being()
		if platform:
			platform.being_type = "floating_platform"
			platform.being_name = "Sky Platform"
			platform.consciousness_level = 2
			chunk.add_being_to_chunk(platform)
			print("🏝️ Generated floating platform in %s" % chunk.name)

static func _create_star_system(chunk: ChunkUniversalBeing) -> void:
	"""Create star systems"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var star = SystemBootstrap.create_universal_being()
		if star:
			star.being_type = "star"
			star.being_name = "Chunk Star"
			star.consciousness_level = 4
			chunk.add_being_to_chunk(star)
			print("⭐ Generated star system in %s" % chunk.name)

static func _create_asteroid(chunk: ChunkUniversalBeing) -> void:
	"""Create asteroids"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var asteroid = SystemBootstrap.create_universal_being()
		if asteroid:
			asteroid.being_type = "asteroid"
			asteroid.being_name = "Space Rock"
			asteroid.consciousness_level = 1
			chunk.add_being_to_chunk(asteroid)
			print("🪨 Generated asteroid in %s" % chunk.name)

static func _create_cosmic_being(chunk: ChunkUniversalBeing) -> void:
	"""Create cosmic entities"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.being_type = "cosmic_entity"
			being.being_name = "Cosmic Wanderer"
			being.consciousness_level = 5
			chunk.add_being_to_chunk(being)
			print("👽 Generated cosmic being in %s" % chunk.name)

static func _create_cosmic_phenomenon(chunk: ChunkUniversalBeing) -> void:
	"""Create cosmic phenomena"""
	var phenomena = ["nebula", "black_hole", "wormhole", "cosmic_storm"]
	chunk.stored_data["cosmic_phenomenon"] = phenomena[randi() % phenomena.size()]
	print("🌌 Generated cosmic phenomenon in %s" % chunk.name)

static func _create_dimensional_rift(chunk: ChunkUniversalBeing) -> void:
	"""Create dimensional rifts"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var rift = SystemBootstrap.create_universal_being()
		if rift:
			rift.being_type = "dimensional_rift"
			rift.being_name = "Reality Tear"
			rift.consciousness_level = 5
			chunk.add_being_to_chunk(rift)
			print("🌀 Generated dimensional rift in %s" % chunk.name)

# ===== UTILITY FUNCTIONS =====

static func set_generation_probability(layer_type: String, feature: String, probability: float) -> void:
	"""Adjust generation probabilities"""
	if layer_type in generation_rules:
		var feature_key = feature + "_chance"
		if feature_key in generation_rules[layer_type]:
			generation_rules[layer_type][feature_key] = probability
			print("🎛️ Set %s.%s probability to %.2f" % [layer_type, feature, probability])

static func get_layer_info(y_coord: int) -> Dictionary:
	"""Get information about a Y layer"""
	return {
		"layer_type": get_layer_type(y_coord),
		"y_coordinate": y_coord,
		"features": get_layer_features(get_layer_type(y_coord))
	}

static func get_layer_features(layer_type: String) -> Array:
	"""Get possible features for a layer type"""
	match layer_type:
		"underground":
			return ["caves", "minerals", "underground_beings"]
		"terrain":
			return ["vegetation", "structures", "water", "terrain"]
		"sky":
			return ["clouds", "flying_beings", "platforms"]
		"space":
			return ["stars", "asteroids", "cosmic_beings"]
		"cosmic":
			return ["phenomena", "rifts", "cosmic_entities"]
		_:
			return []
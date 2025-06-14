extends Resource
class_name PlanetSystem

# Planet Types
enum PlanetType {
	ROCKY,
	GAS_GIANT,
	ICE_GIANT,
	WATER_WORLD,
	LAVA_WORLD,
	TERRESTRIAL,
	DESERT,
	BARREN
}

# Planet type parameters
var planet_type_params = {
	PlanetType.ROCKY: {
		"size_range": [0.3, 1.0],
		"atmosphere_chance": 0.3,
		"color_palette": ["brown", "gray", "red"],
		"resource_types": ["minerals", "metals"],
		"elements": {
			"fire": 30,
			"water": 10, 
			"wood": 5,
			"ash": 40
		}
	},
	PlanetType.GAS_GIANT: {
		"size_range": [5.0, 12.0],
		"atmosphere_chance": 1.0,
		"color_palette": ["orange", "yellow", "blue", "red"],
		"resource_types": ["gases", "helium3"],
		"elements": {
			"fire": 5,
			"water": 0, 
			"wood": 0,
			"ash": 5
		}
	},
	PlanetType.ICE_GIANT: {
		"size_range": [2.5, 5.0],
		"atmosphere_chance": 1.0,
		"color_palette": ["blue", "teal", "light_blue"],
		"resource_types": ["water_ice", "methane"],
		"elements": {
			"fire": 5,
			"water": 60, 
			"wood": 5,
			"ash": 10
		}
	},
	PlanetType.WATER_WORLD: {
		"size_range": [0.9, 2.5],
		"atmosphere_chance": 0.9,
		"color_palette": ["blue", "teal", "dark_blue"],
		"resource_types": ["water", "organics"],
		"elements": {
			"fire": 5,
			"water": 80, 
			"wood": 10,
			"ash": 5
		}
	},
	PlanetType.LAVA_WORLD: {
		"size_range": [0.5, 1.5],
		"atmosphere_chance": 0.7,
		"color_palette": ["red", "orange", "dark_red"],
		"resource_types": ["metals", "rare_metals"],
		"elements": {
			"fire": 80,
			"water": 0, 
			"wood": 0,
			"ash": 20
		}
	},
	PlanetType.TERRESTRIAL: {
		"size_range": [0.8, 1.3],
		"atmosphere_chance": 0.95,
		"color_palette": ["blue", "green", "white"],
		"resource_types": ["water", "life", "gases"],
		"elements": {
			"fire": 20,
			"water": 40,
			"wood": 30,
			"ash": 10
		}
	},
	PlanetType.DESERT: {
		"size_range": [0.6, 1.2],
		"atmosphere_chance": 0.8,
		"color_palette": ["tan", "orange", "brown"],
		"resource_types": ["minerals", "metals"],
		"elements": {
			"fire": 60,
			"water": 5,
			"wood": 5,
			"ash": 30
		}
	},
	PlanetType.BARREN: {
		"size_range": [0.2, 0.8],
		"atmosphere_chance": 0.1,
		"color_palette": ["gray", "tan", "white"],
		"resource_types": ["minerals", "water_ice"],
		"elements": {
			"fire": 10,
			"water": 10,
			"wood": 0,
			"ash": 80
		}
	}
}

# Planet properties
var id: int
var planet_name: String
var seed_value: int
var planet_type: int
var orbit_distance: float
var orbit_period: float
var size: float
var mass: float
var rotation_period: float
var axial_tilt: float
var temperature: float
var atmosphere: bool
var has_life: bool
var resources: Dictionary = {}
var moons: Array = []
var element_composition: Dictionary = {}
var surface_features: Array = []

func _init(planet_data: Dictionary = {}):
	if planet_data.empty():
		return
		
	# Set basic properties from data
	if planet_data.has("id"):
		id = planet_data.id
	if planet_data.has("planet_type"):
		planet_type = planet_data.planet_type
	if planet_data.has("orbit_distance"):
		orbit_distance = planet_data.orbit_distance
	if planet_data.has("orbit_period"):
		orbit_period = planet_data.orbit_period
	if planet_data.has("size"):
		size = planet_data.size
	if planet_data.has("mass"):
		mass = planet_data.mass
	if planet_data.has("rotation_period"):
		rotation_period = planet_data.rotation_period
	if planet_data.has("axial_tilt"):
		axial_tilt = planet_data.axial_tilt
	if planet_data.has("temperature"):
		temperature = planet_data.temperature
	if planet_data.has("atmosphere"):
		atmosphere = planet_data.atmosphere
	if planet_data.has("has_life"):
		has_life = planet_data.has_life
	if planet_data.has("resources"):
		resources = planet_data.resources
	if planet_data.has("moons"):
		moons = planet_data.moons
		
	# Generate extra properties if not provided
	seed_value = id if id != 0 else randi()
	if not planet_data.has("planet_name"):
		planet_name = generate_planet_name()
		
	# Generate element composition based on planet type
	if not planet_data.has("element_composition") and planet_type_params.has(planet_type):
		element_composition = planet_type_params[planet_type].elements.duplicate()
		
	# Generate surface features if applicable
	if not planet_data.has("surface_features") and can_have_surface_features():
		generate_surface_features()

# Check if planet can have surface features
func can_have_surface_features() -> bool:
	# Gas giants and ice giants don't have solid surfaces
	if planet_type == PlanetType.GAS_GIANT or planet_type == PlanetType.ICE_GIANT:
		return false
	return true

# Generate surface features
func generate_surface_features() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	surface_features = []
	
	# Number of features depends on planet size
	var feature_count = int(size * rng.randf_range(5, 15))
	
	# Different feature types by planet type
	var possible_features = []
	
	match planet_type:
		PlanetType.ROCKY:
			possible_features = ["crater", "mountain", "canyon", "plateau", "ridge"]
		PlanetType.WATER_WORLD:
			possible_features = ["island", "reef", "trench", "sea", "ocean"]
		PlanetType.LAVA_WORLD:
			possible_features = ["volcano", "lava_lake", "caldera", "lava_flow", "ash_plain"]
		PlanetType.TERRESTRIAL:
			possible_features = ["mountain", "ocean", "forest", "desert", "canyon", "glacier", "volcano", "island"]
		PlanetType.DESERT:
			possible_features = ["dune", "mesa", "canyon", "crater", "dry_lake", "plateau"]
		PlanetType.BARREN:
			possible_features = ["crater", "ridge", "plain", "canyon", "mountain"]
	
	# Generate features
	for i in range(feature_count):
		var feature_type = possible_features[rng.randi() % possible_features.size()]
		var feature_size = rng.randf_range(0.1, 1.0)
		var feature = {
			"type": feature_type,
			"size": feature_size,
			"position": {
				"lat": rng.randf_range(-90, 90),
				"long": rng.randf_range(-180, 180)
			}
		}
		surface_features.append(feature)

# Generate planet name
func generate_planet_name() -> String:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Different naming schemes
	var naming_scheme = rng.randi() % 4
	
	match naming_scheme:
		0:  # Mythological names
			var names = ["Zeus", "Ares", "Apollo", "Athena", "Hermes", "Hades", "Poseidon", 
						"Thor", "Odin", "Isis", "Osiris", "Shiva", "Vishnu", "Krishna", 
						"Quetzalcoatl", "Tlaloc", "Marduk", "Ishtar", "Enlil", "Enki"]
			return names[rng.randi() % names.size()]
			
		1:  # Earth-like naming (after people, places)
			var prefixes = ["New ", ""]
			var bases = ["Terra", "Earth", "Gaia", "Eden", "Elysium", "Arcadia", "Avalon", 
						"Atlantis", "Shangri-La", "Hyperborea", "Lemuria", "Asgard", "Olympus"]
			var prefix = prefixes[rng.randi() % prefixes.size()]
			var base = bases[rng.randi() % bases.size()]
			return prefix + base
			
		2:  # Designation with number
			var letters = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Theta", 
						  "Iota", "Kappa", "Lambda", "Sigma", "Omega", "Omicron", "Tau"]
			var letter = letters[rng.randi() % letters.size()]
			var number = rng.randi_range(1, 999)
			return letter + "-" + str(number)
			
		3:  # Exoplanet-style naming
			var base = "Kepler"
			var number = rng.randi_range(1, 9999)
			var suffix = ["b", "c", "d", "e", "f", "g", "h", "i", "j", "k"][rng.randi() % 10]
			return base + "-" + str(number) + suffix
	
	# Default fallback
	return "Planet-" + str(seed_value % 1000)

# Calculate gravitational parameters
func calculate_gravity() -> float:
	# Gravity relative to Earth
	return mass / (size * size)

# Get orbital position at a given time
func get_orbital_position(time: float) -> Vector2:
	# Calculate angular position based on orbital period
	var angle = fmod(time / orbit_period * TAU, TAU)
	
	# Simple circular orbit
	var x = orbit_distance * cos(angle)
	var z = orbit_distance * sin(angle)
	
	return Vector2(x, z)

# Get habitable status
func is_habitable() -> bool:
	# Check if planet is potentially habitable
	if not atmosphere:
		return false
		
	# Temperature should be moderate
	if temperature < 250 or temperature > 320:
		return false
		
	# Check planet type
	return planet_type == PlanetType.TERRESTRIAL or planet_type == PlanetType.WATER_WORLD

# Get basic planet info
func get_info() -> Dictionary:
	return {
		"id": id,
		"name": planet_name,
		"type": planet_type,
		"size": size,
		"orbit": orbit_distance,
		"has_life": has_life,
		"moon_count": moons.size(),
		"habitable": is_habitable()
	}

# Get resource info
func get_resources() -> Dictionary:
	return resources

# Serialize planet data for saving
func serialize() -> Dictionary:
	return {
		"id": id,
		"name": planet_name,
		"seed": seed_value,
		"planet_type": planet_type,
		"orbit_distance": orbit_distance,
		"orbit_period": orbit_period,
		"size": size,
		"mass": mass,
		"rotation_period": rotation_period,
		"axial_tilt": axial_tilt,
		"temperature": temperature,
		"atmosphere": atmosphere,
		"has_life": has_life,
		"resources": resources,
		"moons": moons,
		"element_composition": element_composition,
		"surface_features": surface_features
	}

# Deserialize from saved data
func deserialize(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("name"):
		planet_name = data.name
	if data.has("seed"):
		seed_value = data.seed
	if data.has("planet_type"):
		planet_type = data.planet_type
	if data.has("orbit_distance"):
		orbit_distance = data.orbit_distance
	if data.has("orbit_period"):
		orbit_period = data.orbit_period
	if data.has("size"):
		size = data.size
	if data.has("mass"):
		mass = data.mass
	if data.has("rotation_period"):
		rotation_period = data.rotation_period
	if data.has("axial_tilt"):
		axial_tilt = data.axial_tilt
	if data.has("temperature"):
		temperature = data.temperature
	if data.has("atmosphere"):
		atmosphere = data.atmosphere
	if data.has("has_life"):
		has_life = data.has_life
	if data.has("resources"):
		resources = data.resources
	if data.has("moons"):
		moons = data.moons
	if data.has("element_composition"):
		element_composition = data.element_composition
	if data.has("surface_features"):
		surface_features = data.surface_features
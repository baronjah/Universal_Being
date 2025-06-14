extends Resource
class_name StarSystem

# Star Types
enum StarType {
	O_TYPE,    # Blue, extremely hot and bright
	B_TYPE,    # Blue-white, very hot
	A_TYPE,    # White, hot
	F_TYPE,    # Yellow-white
	G_TYPE,    # Yellow (like our Sun)
	K_TYPE,    # Orange
	M_TYPE,    # Red, cool
	RED_GIANT,
	WHITE_DWARF,
	NEUTRON,
	BLACK_HOLE
}

# Star type parameters
var star_type_params = {
	StarType.O_TYPE: {
		"temperature_range": [30000, 50000],
		"size_range": [15.0, 90.0],
		"color": Color(0.5, 0.5, 1.0),
		"habitable_zone": [50.0, 100.0],
		"planets_range": [0, 3],
		"life_chance": 0.01,
		"rarity": 0.00003  # 0.003%
	},
	StarType.B_TYPE: {
		"temperature_range": [10000, 30000],
		"size_range": [4.0, 15.0],
		"color": Color(0.6, 0.6, 1.0),
		"habitable_zone": [30.0, 60.0],
		"planets_range": [0, 5],
		"life_chance": 0.05,
		"rarity": 0.001  # 0.1%
	},
	StarType.A_TYPE: {
		"temperature_range": [7500, 10000],
		"size_range": [1.5, 4.0],
		"color": Color(0.8, 0.8, 1.0),
		"habitable_zone": [20.0, 30.0],
		"planets_range": [1, 7],
		"life_chance": 0.1,
		"rarity": 0.006  # 0.6%
	},
	StarType.F_TYPE: {
		"temperature_range": [6000, 7500],
		"size_range": [1.1, 1.5],
		"color": Color(1.0, 1.0, 0.9),
		"habitable_zone": [1.5, 2.5],
		"planets_range": [2, 9],
		"life_chance": 0.2,
		"rarity": 0.03  # 3%
	},
	StarType.G_TYPE: {
		"temperature_range": [5000, 6000],
		"size_range": [0.8, 1.2],
		"color": Color(1.0, 1.0, 0.8),
		"habitable_zone": [0.8, 1.5],
		"planets_range": [4, 12],
		"life_chance": 0.4,
		"rarity": 0.076  # 7.6%
	},
	StarType.K_TYPE: {
		"temperature_range": [3500, 5000],
		"size_range": [0.6, 0.9],
		"color": Color(1.0, 0.8, 0.5),
		"habitable_zone": [0.4, 0.8],
		"planets_range": [3, 10],
		"life_chance": 0.3,
		"rarity": 0.12  # 12%
	},
	StarType.M_TYPE: {
		"temperature_range": [2000, 3500],
		"size_range": [0.1, 0.6],
		"color": Color(1.0, 0.6, 0.4),
		"habitable_zone": [0.1, 0.4],
		"planets_range": [1, 8],
		"life_chance": 0.1,
		"rarity": 0.7645  # 76.45%
	},
	StarType.RED_GIANT: {
		"temperature_range": [3000, 5000],
		"size_range": [20.0, 200.0],
		"color": Color(1.0, 0.4, 0.3),
		"habitable_zone": [10.0, 30.0],
		"planets_range": [2, 6],
		"life_chance": 0.05,
		"rarity": 0.001  # 0.1%
	},
	StarType.WHITE_DWARF: {
		"temperature_range": [8000, 40000],
		"size_range": [0.01, 0.05],  # Earth-sized
		"color": Color(0.9, 0.9, 1.0),
		"habitable_zone": [0.01, 0.05],
		"planets_range": [0, 3],
		"life_chance": 0.01,
		"rarity": 0.001  # 0.1%
	},
	StarType.NEUTRON: {
		"temperature_range": [500000, 1000000],
		"size_range": [0.0001, 0.001],  # 10-20 km
		"color": Color(0.7, 0.7, 1.0),
		"habitable_zone": [0.0, 0.0],  # No habitable zone
		"planets_range": [0, 2],
		"life_chance": 0.0,
		"rarity": 0.0004  # 0.04%
	},
	StarType.BLACK_HOLE: {
		"temperature_range": [0, 0],  # No temperature
		"size_range": [0.0001, 0.01],  # Event horizon
		"color": Color(0.1, 0.1, 0.1),
		"habitable_zone": [0.0, 0.0],  # No habitable zone
		"planets_range": [0, 3],
		"life_chance": 0.0,
		"rarity": 0.0001  # 0.01%
	}
}

# Star system properties
var id: int
var system_name: String
var seed_value: int
var position: Vector3
var star_type: int
var star_params: Dictionary
var planets: Array = []
var moons: Dictionary = {}  # Planet ID -> Array of moons

func _init(p_seed: int = 0, p_position: Vector3 = Vector3.ZERO, p_type: int = -1):
	seed_value = p_seed
	position = p_position
	
	if seed_value != 0:
		# Generate unique ID
		id = seed_value + int(position.x * 1000) + int(position.y * 1000000) + int(position.z * 1000000000)
		
		# Set star type or determine it
		if p_type != -1 and star_type_params.has(p_type):
			star_type = p_type
		else:
			star_type = determine_star_type(seed_value)
			
		# Generate star parameters
		star_params = generate_star_parameters(star_type, seed_value)
		
		# Generate name
		var rng = RandomNumberGenerator.new()
		rng.seed = seed_value
		system_name = generate_star_name(rng)

# Determine star type based on probabilities
func determine_star_type(seed_value: int) -> int:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Distribution of star types (approximate real distribution)
	var roll = rng.randf()
	var cumulative_probability = 0.0
	
	# Check each star type in order of rarity
	for type in star_type_params:
		cumulative_probability += star_type_params[type].rarity
		if roll < cumulative_probability:
			return type
	
	# Fallback to M-type (most common)
	return StarType.M_TYPE

# Generate star parameters
func generate_star_parameters(star_type: int, seed_value: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	var params = {}
	var type_data = star_type_params[star_type]
	
	# Generate parameters from ranges
	params.temperature = rng.randf_range(type_data.temperature_range[0], type_data.temperature_range[1])
	params.size = rng.randf_range(type_data.size_range[0], type_data.size_range[1])
	params.color = type_data.color
	params.habitable_inner = type_data.habitable_zone[0]
	params.habitable_outer = type_data.habitable_zone[1]
	
	# Determine number of planets
	params.planet_count = rng.randi_range(type_data.planets_range[0], type_data.planets_range[1])
	
	# Special parameters for special star types
	match star_type:
		StarType.RED_GIANT:
			params.expansion_stage = rng.randf_range(0.2, 0.9)  # How far along in expansion
			params.core_pulse_rate = rng.randf_range(0.2, 0.5)  # Pulsation rate
		StarType.WHITE_DWARF:
			params.age = rng.randf_range(0.5, 8.0)  # Billions of years
			params.brightness_factor = rng.randf_range(0.8, 1.2)
		StarType.NEUTRON:
			params.spin_rate = rng.randf_range(0.1, 10.0)  # Rotations per second
			params.magnetic_field = rng.randf_range(1.0, 100.0)  # Magnetic field strength
			params.pulsar = rng.randf() < 0.7  # 70% chance it's a pulsar
		StarType.BLACK_HOLE:
			params.mass = rng.randf_range(5.0, 50.0)  # Solar masses
			params.has_accretion_disk = rng.randf() < 0.4  # 40% chance it has visible disk
			params.rotation = rng.randf_range(0.0, 0.95)  # Kerr parameter (0 = not rotating)
	
	return params

# Generate star name
func generate_star_name(rng: RandomNumberGenerator) -> String:
	var prefixes = ["Alpha", "Beta", "Delta", "Epsilon", "Eta", "Gamma", "Iota", "Kappa", "Lambda", 
					"Mu", "Nu", "Omega", "Omicron", "Phi", "Pi", "Psi", "Rho", "Sigma", "Tau", 
					"Theta", "Upsilon", "Xi", "Zeta"]
	var catalogs = ["HIP", "HD", "BD", "GJ", "LHS", "WISE", "2MASS", "Kepler", "TOI", "PSR"]
	var constellations = ["Andromedae", "Antliae", "Apodis", "Aquarii", "Aquilae", "Arae", "Arietis", 
						 "Aurigae", "Bootis", "Caeli", "Camelopardalis", "Cancri", "Canum", "Capricorni", 
						 "Carinae", "Cassiopeiae", "Centauri", "Cephei", "Ceti", "Chameleontis", "Circini", 
						 "Columbae", "Comae", "Coronae", "Corvi", "Crateris", "Crucis", "Cygni", "Delphini", 
						 "Doradus", "Draconis", "Equulei", "Eridani", "Fornacis", "Geminorum", "Gruis", 
						 "Herculis", "Horologii", "Hydrae", "Lacertae", "Leonis", "Leporis", "Librae", 
						 "Lupi", "Lyncis", "Lyrae", "Mensae", "Microscopii", "Monocerotis", "Muscae", 
						 "Normae", "Octantis", "Ophiuchi", "Orionis", "Pavonis", "Pegasi", "Persei", 
						 "Phoenicis", "Pictoris", "Piscium", "Puppis", "Pyxidis", "Reticuli", "Sagittae", 
						 "Sagittarii", "Scorpii", "Sculptoris", "Scuti", "Serpentis", "Sextantis", "Tauri", 
						 "Telescopii", "Trianguli", "Tucanae", "Ursae", "Velorum", "Virginis", "Volantis", 
						 "Vulpeculae"]
	
	# Determine naming style
	var name_style = rng.randi() % 5
	
	match name_style:
		0:  # Greek letter + constellation (e.g., Alpha Centauri)
			var prefix = prefixes[rng.randi() % prefixes.size()]
			var constellation = constellations[rng.randi() % constellations.size()]
			return prefix + " " + constellation
		1:  # Proper name (e.g., Sirius, Vega)
			var proper_names = ["Sirius", "Vega", "Antares", "Arcturus", "Canopus", "Capella", "Altair", 
								"Aldebaran", "Spica", "Pollux", "Fomalhaut", "Deneb", "Regulus", "Castor", 
								"Procyon", "Achernar", "Betelgeuse", "Rigel", "Bellatrix", "Elnath", "Algol"]
			return proper_names[rng.randi() % proper_names.size()]
		2:  # Catalog + number (e.g., HD 209458)
			var catalog = catalogs[rng.randi() % catalogs.size()]
			var number = rng.randi_range(1000, 999999)
			return catalog + " " + str(number)
		3:  # Constellation + number (e.g., Kepler-186)
			var catalog = catalogs[rng.randi() % catalogs.size()]
			var number = rng.randi_range(1, 1000)
			return catalog + "-" + str(number)
		4:  # System name + star letter (e.g., Tau Ceti f)
			var prefix = prefixes[rng.randi() % prefixes.size()]
			var constellation = constellations[rng.randi() % constellations.size()]
			return prefix + " " + constellation
	
	# Fallback
	return "Star " + str(seed_value % 10000)

# Add a planet to this star system
func add_planet(planet_data: Dictionary) -> void:
	planets.append(planet_data)
	
	# If this planet has moons, register them
	if planet_data.has("moons") and planet_data.has("id"):
		moons[planet_data.id] = planet_data.moons

# Get basic star system info
func get_info() -> Dictionary:
	return {
		"id": id,
		"name": system_name,
		"position": position,
		"star_type": star_type,
		"star_params": star_params,
		"planet_count": planets.size()
	}

# Serialize star system data for saving
func serialize() -> Dictionary:
	var data = {
		"id": id,
		"seed": seed_value,
		"name": system_name,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"star_type": star_type,
		"star_params": star_params,
		"planets": planets,
		"moons": moons
	}
	
	return data

# Deserialize from saved data
func deserialize(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("seed"):
		seed_value = data.seed
	if data.has("name"):
		system_name = data.name
	if data.has("position"):
		position = Vector3(data.position.x, data.position.y, data.position.z)
	if data.has("star_type"):
		star_type = data.star_type
	if data.has("star_params"):
		star_params = data.star_params
	if data.has("planets"):
		planets = data.planets
	if data.has("moons"):
		moons = data.moons
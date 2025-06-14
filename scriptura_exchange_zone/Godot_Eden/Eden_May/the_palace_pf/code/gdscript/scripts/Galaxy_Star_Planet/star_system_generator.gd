extends Resource
class_name StarSystemGenerator

# Calculate orbital distances based on modified Titus-Bode law
const TITUS_BODE_BASE = 0.4
const TITUS_BODE_MULTIPLIER = 0.3

# Reference to StarSystem for accessing types
var StarSystem = load("res://code/gdscript/scripts/Galaxy_Star_Planet/star_system.gd")

# Generate a complete star system
func generate_star_system(seed_value: int, galaxy_position: Vector3, distance_from_center: float) -> StarSystem:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Calculate position in the galaxy
	var position = calculate_position_in_galaxy(galaxy_position, distance_from_center, seed_value)
	
	# Create the star system
	var star_system = StarSystem.new(seed_value, position)
	var star_type = star_system.star_type
	var star_params = star_system.star_params
	
	# Generate planets
	var planets = []
	var planet_count = star_params.planet_count
	
	for i in range(planet_count):
		var planet_seed = seed_value + i + 1
		var distance = calculate_orbit_distance(i, star_type)
		var planet = generate_planet(planet_seed, star_type, distance)
		planets.append(planet)
		star_system.add_planet(planet)
	
	return star_system

# Calculate position in galaxy based on distance from center
func calculate_position_in_galaxy(galaxy_position: Vector3, distance_from_center: float, seed_value: int) -> Vector3:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# For spiral galaxies, place stars along spiral arms
	var angle = rng.randf() * TAU
	var spiral_factor = rng.randf_range(0.1, 0.3)
	var spiral_offset = spiral_factor * distance_from_center * 10.0
	
	# Randomize to create a natural distribution
	angle += spiral_offset
	distance_from_center += rng.randf_range(-0.1, 0.1) * distance_from_center
	
	# Convert polar coordinates to cartesian
	var x = cos(angle) * distance_from_center
	var y = rng.randf_range(-0.1, 0.1) * distance_from_center 
	var z = sin(angle) * distance_from_center
	
	# Add to galaxy position
	return galaxy_position + Vector3(x, y, z)

# Calculate orbital distance for planet
func calculate_orbit_distance(planet_index: int, star_type: int) -> float:
	# Modified Titus-Bode Law
	var distance = TITUS_BODE_BASE
	if planet_index > 0:
		distance = TITUS_BODE_BASE + TITUS_BODE_MULTIPLIER * pow(2, planet_index - 1)
	
	# Adjust based on star type
	var type_data = StarSystem.star_type_params[star_type]
	var habitable_zone_mid = (type_data.habitable_zone[0] + type_data.habitable_zone[1]) / 2.0
	var scale_factor = habitable_zone_mid / 1.0  # Scale factor (1.0 = Earth's distance)
	
	return distance * scale_factor

# Generate planet parameters
func generate_planet(seed_value: int, star_type: int, orbit_distance: float) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Determine planet type based on distance and star type
	var planet_type = determine_planet_type(seed_value, orbit_distance, star_type)
	
	# Get star parameters (needed for temperature calculation)
	var star_data = StarSystem.star_type_params[star_type]
	var star_temp = (star_data.temperature_range[0] + star_data.temperature_range[1]) / 2.0
	
	# Calculate base temperature based on star and distance
	var temp_factor = star_temp / (orbit_distance * orbit_distance)
	var base_temp = clamp(278.0 * sqrt(temp_factor / 278.0), 50.0, 700.0)
	
	# Generate planet parameters
	var planet = {
		"id": seed_value,
		"planet_type": planet_type,
		"orbit_distance": orbit_distance,
		"orbit_period": calculate_orbit_period(orbit_distance, star_type),
		"size": generate_planet_size(planet_type, rng),
		"mass": 0.0,  # Will calculate based on size and type
		"rotation_period": rng.randf_range(0.2, 5.0) * 24.0,  # In hours
		"axial_tilt": rng.randf_range(0.0, 45.0),
		"temperature": base_temp,
		"atmosphere": rng.randf() < get_atmosphere_chance(planet_type),
		"has_life": false,
		"resources": {},
		"moons": []
	}
	
	# Calculate mass based on size and planet type
	planet.mass = calculate_planet_mass(planet.size, planet_type)
	
	# Check for life
	var life_chance = calculate_life_chance(planet, star_type)
	planet.has_life = rng.randf() < life_chance
	
	# Generate moons
	var moon_count = determine_moon_count(planet_type, planet.size, rng)
	for i in range(moon_count):
		var moon_seed = seed_value * 100 + i
		var moon = generate_moon(moon_seed, planet, i, rng)
		planet.moons.append(moon)
	
	# Generate resources
	planet.resources = generate_planet_resources(planet_type, planet.size, rng)
	
	return planet

# Determine planet type based on distance and star
func determine_planet_type(seed_value: int, distance_from_star: float, star_type: int):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Get star parameters
	var star_data = StarSystem.star_type_params[star_type]
	var star_temp = (star_data.temperature_range[0] + star_data.temperature_range[1]) / 2.0
	
	# Adjustment for star type
	var scale_factor = 1.0
	match star_type:
		StarSystem.StarType.O_TYPE, StarSystem.StarType.B_TYPE, StarSystem.StarType.A_TYPE:
			scale_factor = 5.0
		StarSystem.StarType.F_TYPE:
			scale_factor = 2.0
		StarSystem.StarType.K_TYPE, StarSystem.StarType.M_TYPE:
			scale_factor = 0.5
	
	# Calculate temperature factor
	var temp_factor = star_temp / (distance_from_star * distance_from_star) * scale_factor
	
	# Planet type enum equivalent to documentation
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
	
	# Determine planet type based on temperature and random factors
	var random_factor = rng.randf()
	
	if temp_factor > 100:
		return PlanetType.LAVA_WORLD
	elif temp_factor > 50:
		return random_factor < 0.7 ? PlanetType.ROCKY : PlanetType.DESERT
	elif temp_factor > 20:
		return random_factor < 0.5 ? PlanetType.TERRESTRIAL : PlanetType.ROCKY
	elif temp_factor > 5:
		return random_factor < 0.7 ? PlanetType.WATER_WORLD : PlanetType.TERRESTRIAL
	elif temp_factor > 1:
		return random_factor < 0.6 ? PlanetType.ICE_GIANT : PlanetType.ROCKY
	else:
		return random_factor < 0.7 ? PlanetType.GAS_GIANT : PlanetType.ICE_GIANT

# Generate planet size based on type
func generate_planet_size(planet_type, rng: RandomNumberGenerator) -> float:
	# Size in Earth radii
	match planet_type:
		0:  # ROCKY
			return rng.randf_range(0.3, 1.0)
		1:  # GAS_GIANT
			return rng.randf_range(5.0, 12.0)
		2:  # ICE_GIANT
			return rng.randf_range(2.5, 5.0)
		3:  # WATER_WORLD
			return rng.randf_range(0.9, 2.5)
		4:  # LAVA_WORLD
			return rng.randf_range(0.5, 1.5)
		5:  # TERRESTRIAL
			return rng.randf_range(0.8, 1.3)
		6:  # DESERT
			return rng.randf_range(0.6, 1.2)
		7:  # BARREN
			return rng.randf_range(0.2, 0.8)
	
	# Default
	return rng.randf_range(0.5, 1.5)

# Calculate planet mass based on size and type
func calculate_planet_mass(size: float, planet_type) -> float:
	# Mass in Earth masses
	var density_factor = 1.0
	
	match planet_type:
		0:  # ROCKY
			density_factor = 1.1
		1:  # GAS_GIANT
			density_factor = 0.3
		2:  # ICE_GIANT
			density_factor = 0.5
		3:  # WATER_WORLD
			density_factor = 0.8
		4:  # LAVA_WORLD
			density_factor = 1.2
		5:  # TERRESTRIAL
			density_factor = 1.0
		6:  # DESERT
			density_factor = 0.9
		7:  # BARREN
			density_factor = 0.7
	
	# Mass scales approximately with cube of radius and density
	return pow(size, 3) * density_factor

# Calculate orbital period (in Earth days)
func calculate_orbit_period(orbit_distance: float, star_type: int) -> float:
	# Get star mass (approximate from size)
	var star_data = StarSystem.star_type_params[star_type]
	var star_size = (star_data.size_range[0] + star_data.size_range[1]) / 2.0
	var star_mass = pow(star_size, 3)  # Approximate mass from size
	
	# Simple Kepler's third law approximation
	# Period^2 proportional to Orbit^3
	# For Earth: 1 AU, 365.25 days, Sun mass of 1
	return sqrt(pow(orbit_distance, 3) / star_mass) * 365.25

# Determine atmosphere chance based on planet type
func get_atmosphere_chance(planet_type) -> float:
	match planet_type:
		0:  # ROCKY
			return 0.3
		1:  # GAS_GIANT
			return 1.0
		2:  # ICE_GIANT
			return 1.0
		3:  # WATER_WORLD
			return 0.9
		4:  # LAVA_WORLD
			return 0.7
		5:  # TERRESTRIAL
			return 0.95
		6:  # DESERT
			return 0.8
		7:  # BARREN
			return 0.1
	
	return 0.5

# Calculate chance of life
func calculate_life_chance(planet: Dictionary, star_type: int) -> float:
	var star_data = StarSystem.star_type_params[star_type]
	var base_chance = star_data.life_chance
	
	# If planet is terrestrial or water world and in habitable zone, increase chances
	if planet.planet_type == 5 or planet.planet_type == 3:  # TERRESTRIAL or WATER_WORLD
		if planet.orbit_distance >= star_data.habitable_zone[0] and planet.orbit_distance <= star_data.habitable_zone[1]:
			base_chance *= 10.0
	
	# Other factors
	if planet.atmosphere:
		base_chance *= 2.0
	
	# Temperature considerations
	if planet.temperature > 373 or planet.temperature < 173:  # Too hot or too cold
		base_chance *= 0.1
	
	return clamp(base_chance, 0.0, 0.8)  # Cap at 80% chance

# Determine number of moons
func determine_moon_count(planet_type, planet_size: float, rng: RandomNumberGenerator) -> int:
	var base_count = 0
	
	match planet_type:
		0:  # ROCKY
			base_count = round(planet_size * 1.5)
		1:  # GAS_GIANT
			base_count = round(planet_size * 1.0)
		2:  # ICE_GIANT
			base_count = round(planet_size * 0.8)
		3, 4, 5, 6:  # WATER_WORLD, LAVA_WORLD, TERRESTRIAL, DESERT
			base_count = round(planet_size * 0.5)
		7:  # BARREN
			base_count = round(planet_size * 0.3)
	
	# Add randomness
	base_count += rng.randi_range(-2, 2)
	
	return max(0, base_count)

# Generate a moon
func generate_moon(moon_seed: int, planet: Dictionary, index: int, rng: RandomNumberGenerator) -> Dictionary:
	# Moon size is based on planet size
	var max_moon_size = planet.size * 0.5
	
	var moon = {
		"id": moon_seed,
		"orbit_distance": 0.001 + (0.001 * index),  # In AU, very close to planet
		"orbit_period": rng.randf_range(0.1, 30.0),  # In Earth days
		"size": rng.randf_range(0.01, max_moon_size),
		"mass": 0.0,
		"rotation_period": rng.randf_range(1.0, 28.0),  # In Earth days
		"axial_tilt": rng.randf_range(0.0, 10.0),
		"is_captured": rng.randf() < 0.2  # 20% chance it's a captured body
	}
	
	# Calculate mass (simple approximation)
	moon.mass = pow(moon.size, 3) * 0.8  # Moons are less dense than planets
	
	return moon

# Generate planet resources
func generate_planet_resources(planet_type, planet_size: float, rng: RandomNumberGenerator) -> Dictionary:
	var resources = {}
	
	# Define resource probabilities by planet type
	var resource_types = {
		0: {  # ROCKY
			"metals": 0.8,
			"minerals": 0.9,
			"rare_metals": 0.4,
			"radioactives": 0.3
		},
		1: {  # GAS_GIANT
			"gases": 1.0,
			"helium3": 0.7,
			"volatiles": 0.8
		},
		2: {  # ICE_GIANT
			"water_ice": 0.9,
			"methane": 0.8,
			"ammonia": 0.7,
			"volatiles": 0.6
		},
		3: {  # WATER_WORLD
			"water": 1.0,
			"minerals": 0.5,
			"organics": 0.7
		},
		4: {  # LAVA_WORLD
			"metals": 0.9,
			"rare_metals": 0.7,
			"radioactives": 0.5,
			"exotic_minerals": 0.4
		},
		5: {  # TERRESTRIAL
			"water": 0.9,
			"metals": 0.7,
			"minerals": 0.8,
			"organics": 0.8,
			"gases": 0.7
		},
		6: {  # DESERT
			"minerals": 0.8,
			"metals": 0.6,
			"radioactives": 0.2,
			"water": 0.1
		},
		7: {  # BARREN
			"minerals": 0.7,
			"metals": 0.4,
			"water_ice": 0.3
		}
	}
	
	# Generate resources based on probabilities
	var type_resources = resource_types[planet_type]
	for resource in type_resources:
		if rng.randf() < type_resources[resource]:
			# Resource abundance based on planet size and random factor
			resources[resource] = rng.randf_range(0.1, 1.0) * planet_size
	
	return resources
extends Node
class_name CelestialPhysics

# Gravitational constant (scaled for game)
const G = 6.67430e-11 * 1e9  # Scale up for better gameplay

# Interaction types
enum InteractionType {
	GRAVITATIONAL,
	TIDAL,
	MAGNETIC,
	RADIATION,
	PARTICLE_TRANSFER,
	RESONANCE
}

# Orbital parameters
class OrbitalParameters:
	var semi_major_axis: float = 0.0  # Distance from central body (AU)
	var eccentricity: float = 0.0  # Orbital eccentricity (0 = circular, 1 = parabolic)
	var inclination: float = 0.0  # Orbital inclination (radians)
	var longitude_of_ascending_node: float = 0.0  # Radians
	var argument_of_periapsis: float = 0.0  # Radians
	var mean_anomaly: float = 0.0  # Initial position (radians)
	var period: float = 0.0  # Orbital period (days)
	var central_body_mass: float = 1.0  # Mass of the central body (solar masses)
	
	func _init(a: float = 1.0, e: float = 0.0, inc: float = 0.0, 
			   node: float = 0.0, peri: float = 0.0, 
			   anomaly: float = 0.0, mass: float = 1.0):
		semi_major_axis = a
		eccentricity = e
		inclination = inc
		longitude_of_ascending_node = node
		argument_of_periapsis = peri
		mean_anomaly = anomaly
		central_body_mass = mass
		
		# Calculate period using Kepler's third law
		# P² = 4π²a³/(GM)
		if semi_major_axis > 0.0 and central_body_mass > 0.0:
			period = 2.0 * PI * sqrt(pow(semi_major_axis, 3) / (G * central_body_mass))
	
	# Get position at a given time
	func get_position_at_time(time: float) -> Vector3:
		# Calculate mean anomaly at current time
		var mean_anomaly_now = mean_anomaly + (2.0 * PI * time / period)
		mean_anomaly_now = fmod(mean_anomaly_now, 2.0 * PI)
		
		# Solve Kepler's equation to get eccentric anomaly
		var eccentric_anomaly = _solve_kepler(mean_anomaly_now, eccentricity)
		
		# Calculate position in orbital plane
		var x = semi_major_axis * (cos(eccentric_anomaly) - eccentricity)
		var y = semi_major_axis * sqrt(1.0 - pow(eccentricity, 2)) * sin(eccentric_anomaly)
		
		# Rotate to the correct orbital orientation
		# This is a simplified version - a full implementation would use the orbital elements
		var position = Vector3(x, 0, y)
		
		# Apply inclination
		var rotation = Quaternion(Vector3(1, 0, 0), inclination)
		position = rotation * position
		
		# Apply longitude of ascending node
		rotation = Quaternion(Vector3(0, 1, 0), longitude_of_ascending_node)
		position = rotation * position
		
		# Apply argument of periapsis
		rotation = Quaternion(Vector3(0, 0, 1), argument_of_periapsis)
		position = rotation * position
		
		return position
	
	# Solve Kepler's equation using Newton-Raphson method
	func _solve_kepler(mean_anomaly: float, eccentricity: float) -> float:
		# For circular orbits, eccentric anomaly equals mean anomaly
		if eccentricity < 0.001:
			return mean_anomaly
		
		# For highly eccentric orbits, limit iterations
		var max_iterations = 50 if eccentricity < 0.9 else 100
		
		# Initial guess
		var eccentric_anomaly = mean_anomaly
		
		# Newton-Raphson iteration
		for i in range(max_iterations):
			var delta = (eccentric_anomaly - eccentricity * sin(eccentric_anomaly) - mean_anomaly) / (1.0 - eccentricity * cos(eccentric_anomaly))
			eccentric_anomaly -= delta
			
			if abs(delta) < 1e-8:
				break
		
		return eccentric_anomaly

# Calculate gravitational force between two bodies
func calculate_gravitational_force(mass1: float, mass2: float, distance: float) -> float:
	if distance <= 0.0:
		return 0.0  # Avoid division by zero
	
	return G * mass1 * mass2 / (distance * distance)

# Generate orbital parameters for a body around a central mass
func generate_orbital_parameters(
	distance: float,
	central_mass: float,
	random_factor: float = 0.1,
	seed_value: int = 0
) -> OrbitalParameters:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000)
	
	# Base orbit with random variation
	var semi_major_axis = distance * (1.0 + rng.randf_range(-random_factor, random_factor))
	
	# Eccentricity (more randomized for outer orbits)
	var max_eccentricity = min(0.2 + distance * 0.05, 0.8)  # Higher eccentricity far from star
	var eccentricity = rng.randf_range(0.0, max_eccentricity)
	
	# Random inclination (usually small)
	var inclination = rng.randf_range(0.0, 0.2)  # Radians (up to ~11 degrees)
	
	# Random other orbital elements
	var longitude_of_ascending_node = rng.randf_range(0.0, 2.0 * PI)
	var argument_of_periapsis = rng.randf_range(0.0, 2.0 * PI)
	var mean_anomaly = rng.randf_range(0.0, 2.0 * PI)
	
	return OrbitalParameters.new(
		semi_major_axis,
		eccentricity,
		inclination,
		longitude_of_ascending_node,
		argument_of_periapsis,
		mean_anomaly,
		central_mass
	)

# Determine if two bodies are in resonance
func are_in_resonance(period1: float, period2: float, tolerance: float = 0.01) -> Dictionary:
	if period1 <= 0.0 or period2 <= 0.0:
		return {"in_resonance": false}
	
	# Check common resonances
	var resonances = [
		{"ratio": "1:1", "p": 1, "q": 1},
		{"ratio": "2:1", "p": 2, "q": 1},
		{"ratio": "3:2", "p": 3, "q": 2},
		{"ratio": "4:3", "p": 4, "q": 3},
		{"ratio": "5:3", "p": 5, "q": 3},
		{"ratio": "3:1", "p": 3, "q": 1},
	]
	
	for resonance in resonances:
		var p = float(resonance.p)
		var q = float(resonance.q)
		
		var ratio1 = period1 / period2
		var ratio2 = p / q
		
		if abs(ratio1 - ratio2) < tolerance:
			return {
				"in_resonance": true, 
				"ratio": resonance.ratio,
				"strength": 1.0 - abs(ratio1 - ratio2) / tolerance
			}
	
	return {"in_resonance": false}

# Calculate tidal force strength
func calculate_tidal_force(mass1: float, radius1: float, mass2: float, distance: float) -> float:
	if distance <= 0.0 or radius1 <= 0.0:
		return 0.0
	
	# Tidal acceleration formula: 2 * G * M * r / d³
	return 2.0 * G * mass2 * radius1 / pow(distance, 3)

# Calculate Hill sphere radius (region of gravitational influence)
func calculate_hill_sphere(semi_major_axis: float, eccentricity: float, 
						  planet_mass: float, star_mass: float) -> float:
	if star_mass <= 0.0:
		return 0.0
	
	var periapsis = semi_major_axis * (1.0 - eccentricity)
	return periapsis * pow(planet_mass / (3.0 * star_mass), 1.0/3.0)

# Calculate Roche limit (minimum orbit before tidal forces break apart a satellite)
func calculate_roche_limit(primary_radius: float, primary_density: float, 
						  satellite_density: float) -> float:
	if satellite_density <= 0.0:
		return 0.0
	
	return primary_radius * 2.44 * pow(primary_density / satellite_density, 1.0/3.0)

# Calculate radiation intensity at a given distance
func calculate_radiation_intensity(luminosity: float, distance: float) -> float:
	if distance <= 0.0:
		return 0.0
	
	# Inverse square law
	return luminosity / (4.0 * PI * distance * distance)

# Calculate temperature of a body based on stellar radiation
func calculate_equilibrium_temperature(
	stellar_luminosity: float, 
	stellar_temperature: float,
	orbit_distance: float,
	albedo: float = 0.3
) -> float:
	if orbit_distance <= 0.0 or stellar_temperature <= 0.0:
		return 0.0
	
	# Stefan-Boltzmann based equilibrium temperature
	var absorption = 1.0 - albedo
	return stellar_temperature * sqrt(sqrt(stellar_luminosity * absorption / (16.0 * PI * orbit_distance * orbit_distance)))

# Simulate N-body interactions (simplified)
func simulate_n_body_step(
	positions: Array, 
	velocities: Array, 
	masses: Array, 
	delta_time: float
) -> Dictionary:
	var body_count = positions.size()
	if body_count != velocities.size() or body_count != masses.size():
		return {"error": "Array size mismatch"}
	
	var new_positions = positions.duplicate()
	var new_velocities = velocities.duplicate()
	
	# Calculate accelerations from gravitational forces
	for i in range(body_count):
		var acceleration = Vector3.ZERO
		
		for j in range(body_count):
			if i == j:
				continue
			
			var direction = positions[j] - positions[i]
			var distance = direction.length()
			
			if distance > 0.001:  # Avoid extremely close bodies
				var force = calculate_gravitational_force(masses[i], masses[j], distance)
				acceleration += direction.normalized() * force / masses[i]
		
		# Update velocity using calculated acceleration
		new_velocities[i] += acceleration * delta_time
	
	# Update positions using updated velocities
	for i in range(body_count):
		new_positions[i] += new_velocities[i] * delta_time
	
	return {
		"positions": new_positions,
		"velocities": new_velocities
	}

# Generate moon orbits around a planet
func generate_moon_orbits(
	planet_mass: float,
	planet_radius: float,
	moon_count: int,
	min_distance_factor: float = 1.5,  # Multiples of planet radius
	max_distance_factor: float = 20.0,
	seed_value: int = 0
) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000)
	
	var orbits = []
	var min_distance = planet_radius * min_distance_factor
	var max_distance = planet_radius * max_distance_factor
	
	# Ensure moons are spaced out
	var available_space = max_distance - min_distance
	var avg_spacing = available_space / max(1, moon_count)
	
	for i in range(moon_count):
		# Determine distance with some randomization
		var base_distance = min_distance + i * avg_spacing
		var distance = base_distance * rng.randf_range(0.8, 1.2)
		
		# Generate orbital parameters
		var orbit = generate_orbital_parameters(
			distance,
			planet_mass,
			0.2,  # Higher random factor for moons
			seed_value + i * 1000
		)
		
		orbits.append(orbit)
	
	return orbits

# Generate asteroid belt
func generate_asteroid_belt(
	inner_radius: float,
	outer_radius: float,
	central_mass: float,
	asteroid_count: int,
	seed_value: int = 0
) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000)
	
	var asteroids = []
	
	for i in range(asteroid_count):
		# Random radius within belt
		var radius = rng.randf_range(inner_radius, outer_radius)
		
		# More eccentric orbits for asteroids
		var orbit = generate_orbital_parameters(
			radius,
			central_mass,
			0.3,  # High random factor for asteroids
			seed_value + i
		)
		
		# Force higher inclination variation
		orbit.inclination = rng.randf_range(0.0, 0.5)  # Up to ~28 degrees
		
		# Random size (relatively small)
		var size = rng.randf_range(0.0001, 0.01)  # From 100m to 10km
		
		asteroids.append({
			"orbit": orbit,
			"size": size,
			"rotation_period": rng.randf_range(0.1, 2.0)  # In Earth days
		})
	
	return asteroids

# Calculate Lagrange points for a two-body system
func calculate_lagrange_points(
	primary_mass: float,
	secondary_mass: float,
	orbit_distance: float
) -> Dictionary:
	var mass_ratio = secondary_mass / (primary_mass + secondary_mass)
	
	# L1: On the line between the two bodies, inside the orbit
	var l1_distance = orbit_distance * (1.0 - pow(mass_ratio / 3.0, 1.0/3.0))
	var l1 = Vector3(l1_distance, 0, 0)
	
	# L2: On the line between the two bodies, outside the orbit
	var l2_distance = orbit_distance * (1.0 + pow(mass_ratio / 3.0, 1.0/3.0))
	var l2 = Vector3(l2_distance, 0, 0)
	
	# L3: Opposite side of primary from secondary
	var l3_distance = -orbit_distance * (1.0 - 5.0 * mass_ratio / 12.0)
	var l3 = Vector3(l3_distance, 0, 0)
	
	# L4 and L5: Equilateral triangle with both masses (60 degrees ahead and behind)
	var l4 = Vector3(orbit_distance * 0.5, 0, orbit_distance * sqrt(3.0) / 2.0)
	var l5 = Vector3(orbit_distance * 0.5, 0, -orbit_distance * sqrt(3.0) / 2.0)
	
	return {
		"L1": l1,
		"L2": l2,
		"L3": l3,
		"L4": l4,
		"L5": l5
	}

# Calculate stable orbital zones around a star
func calculate_stable_orbit_zones(
	star_mass: float,
	star_luminosity: float,
	existing_planets: Array = []
) -> Dictionary:
	# Habitable zone based on temperature where liquid water can exist
	var inner_habitable = sqrt(star_luminosity / 1.1)  # Inner edge (hotter than Earth)
	var outer_habitable = sqrt(star_luminosity / 0.53)  # Outer edge (Mars-like)
	
	# Calculate instability zones from existing planets
	var instability_zones = []
	
	for planet_data in existing_planets:
		var semi_major_axis = planet_data.orbit_distance if planet_data.has("orbit_distance") else 1.0
		var planet_mass = planet_data.mass if planet_data.has("mass") else 0.1
		
		# Calculate Hill radius
		var hill_radius = calculate_hill_sphere(
			semi_major_axis,
			planet_data.get("eccentricity", 0.0),
			planet_mass,
			star_mass
		)
		
		# Region around planet where orbits are unstable
		var inner_unstable = semi_major_axis - hill_radius * 3.0
		var outer_unstable = semi_major_axis + hill_radius * 3.0
		
		instability_zones.append({
			"inner": max(0.1, inner_unstable),  # Avoid negative or tiny values
			"outer": outer_unstable
		})
	
	# Find stable regions between unstable zones
	var stable_regions = []
	var current_inner = 0.1  # Minimum stable orbit near star
	
	# Sort instability zones by inner boundary
	instability_zones.sort_custom(Callable(self, "_sort_zones_by_inner"))
	
	for zone in instability_zones:
		if zone.inner > current_inner:
			stable_regions.append({
				"inner": current_inner,
				"outer": zone.inner,
				"habitable": _regions_overlap(current_inner, zone.inner, inner_habitable, outer_habitable)
			})
		current_inner = max(current_inner, zone.outer)
	
	# Add final stable region beyond all planets
	if current_inner < 50.0:  # Arbitrary outer limit of system
		stable_regions.append({
			"inner": current_inner,
			"outer": 50.0,
			"habitable": _regions_overlap(current_inner, 50.0, inner_habitable, outer_habitable)
		})
	
	return {
		"habitable_zone": {
			"inner": inner_habitable,
			"outer": outer_habitable
		},
		"stable_regions": stable_regions
	}

# Helper function for sorting
func _sort_zones_by_inner(a, b):
	return a.inner < b.inner

# Helper function to check if two ranges overlap
func _regions_overlap(a_min: float, a_max: float, b_min: float, b_max: float) -> bool:
	return max(a_min, b_min) <= min(a_max, b_max)

# Generate a system of resonant planets
func generate_resonant_system(
	star_mass: float,
	planet_count: int,
	base_distance: float = 1.0,
	seed_value: int = 0
) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000)
	
	var planets = []
	
	# Common resonance ratios (a:b means inner planet orbits a times for every b orbits of outer planet)
	var resonance_ratios = [
		{"name": "2:1", "inner_to_outer": 2.0/1.0},
		{"name": "3:2", "inner_to_outer": 3.0/2.0},
		{"name": "4:3", "inner_to_outer": 4.0/3.0},
		{"name": "5:3", "inner_to_outer": 5.0/3.0},
		{"name": "3:1", "inner_to_outer": 3.0/1.0}
	]
	
	# Start with an initial planet
	var first_planet = {
		"distance": base_distance,
		"mass": rng.randf_range(0.01, 0.1),  # Earth masses (small to super-Earth)
		"period": 2.0 * PI * sqrt(pow(base_distance, 3) / (G * star_mass))
	}
	planets.append(first_planet)
	
	# Add resonant planets
	for i in range(1, planet_count):
		# Choose a resonance pattern
		var resonance = resonance_ratios[rng.randi() % resonance_ratios.size()]
		var inner_period = planets[i-1].period
		
		# Calculate outer period based on resonance
		var outer_period = inner_period * resonance.inner_to_outer
		
		# Calculate semi-major axis from period
		var semi_major_axis = pow(outer_period * outer_period * G * star_mass / (4.0 * PI * PI), 1.0/3.0)
		
		var planet = {
			"distance": semi_major_axis,
			"mass": rng.randf_range(0.01, 0.1),
			"period": outer_period,
			"resonance_with_previous": resonance.name
		}
		planets.append(planet)
	
	# Now generate full orbital parameters
	var orbital_planets = []
	for i in range(planet_count):
		var planet = planets[i]
		var orbital_params = generate_orbital_parameters(
			planet.distance,
			star_mass,
			0.05,  # Low randomness to maintain resonance
			seed_value + i * 100
		)
		
		orbital_planets.append({
			"orbit": orbital_params,
			"mass": planet.mass,
			"resonance": planet.get("resonance_with_previous", "none")
		})
	
	return orbital_planets

# Calculate the stability of a multi-planet system
func calculate_system_stability(planets: Array, star_mass: float) -> Dictionary:
	var planet_count = planets.size()
	if planet_count < 2:
		return {"stability_index": 1.0, "stable": true}
	
	var stability_issues = []
	var overall_stability = 1.0
	
	# Check spacing between planets
	for i in range(planet_count - 1):
		var inner_planet = planets[i]
		var outer_planet = planets[i + 1]
		
		var inner_a = inner_planet.orbit.semi_major_axis
		var outer_a = outer_planet.orbit.semi_major_axis
		
		var inner_mass = inner_planet.mass
		var outer_mass = outer_planet.mass
		
		# Check Hill sphere overlap
		var inner_hill = calculate_hill_sphere(
			inner_a, 
			inner_planet.orbit.eccentricity,
			inner_mass, 
			star_mass
		)
		
		var outer_hill = calculate_hill_sphere(
			outer_a, 
			outer_planet.orbit.eccentricity,
			outer_mass, 
			star_mass
		)
		
		var separation = outer_a - inner_a
		var hill_stability = separation / (inner_hill + outer_hill)
		
		if hill_stability < 5.0:
			var issue = {
				"type": "hill_sphere_overlap",
				"planets": [i, i+1],
				"severity": 1.0 - hill_stability / 5.0
			}
			stability_issues.append(issue)
			overall_stability -= issue.severity * 0.2
		
		# Check for crossing orbits
		var inner_ap = inner_a * (1.0 + inner_planet.orbit.eccentricity)  # Apoapsis
		var outer_pe = outer_a * (1.0 - outer_planet.orbit.eccentricity)  # Periapsis
		
		if inner_ap > outer_pe:
			var issue = {
				"type": "orbit_crossing",
				"planets": [i, i+1],
				"severity": (inner_ap - outer_pe) / inner_a
			}
			stability_issues.append(issue)
			overall_stability -= issue.severity * 0.4
	
	# Check for resonances (some are stabilizing, some are destabilizing)
	for i in range(planet_count - 1):
		var inner_period = planets[i].orbit.period
		var outer_period = planets[i + 1].orbit.period
		
		var resonance = are_in_resonance(inner_period, outer_period)
		if resonance.in_resonance:
			# Some resonances can stabilize, others destabilize
			var stabilizing = ["2:1", "3:2"]
			var destabilizing = ["1:1", "5:2"]
			
			if resonance.ratio in stabilizing:
				overall_stability += 0.1 * resonance.strength
			elif resonance.ratio in destabilizing:
				overall_stability -= 0.2 * resonance.strength
				stability_issues.append({
					"type": "destabilizing_resonance",
					"planets": [i, i+1],
					"resonance": resonance.ratio,
					"severity": resonance.strength * 0.5
				})
	
	# Clamp stability index
	overall_stability = clamp(overall_stability, 0.0, 1.0)
	
	return {
		"stability_index": overall_stability,
		"stable": overall_stability > 0.5,
		"issues": stability_issues
	}

# Calculate eclipses between celestial bodies
func calculate_eclipse(
	primary_radius: float, 
	primary_position: Vector3,
	occulter_radius: float,
	occulter_position: Vector3,
	viewer_position: Vector3
) -> Dictionary:
	# Direction vectors
	var primary_to_viewer = viewer_position - primary_position
	var occulter_to_viewer = viewer_position - occulter_position
	var primary_to_occulter = occulter_position - primary_position
	
	var primary_distance = primary_to_viewer.length()
	var occulter_distance = occulter_to_viewer.length()
	
	# Angular sizes
	var primary_angular_size = 2.0 * asin(primary_radius / primary_distance)
	var occulter_angular_size = 2.0 * asin(occulter_radius / occulter_distance)
	
	# Calculate angular separation
	var angle = primary_to_viewer.angle_to(occulter_to_viewer)
	
	# Determine eclipse type
	var total_radius = primary_angular_size / 2.0 + occulter_angular_size / 2.0
	
	if angle > total_radius:
		# No eclipse
		return {
			"eclipse": false,
			"type": "none",
			"coverage": 0.0
		}
	else:
		# Some type of eclipse/transit
		var eclipse_type = "partial"
		var coverage = 0.0
		
		if occulter_angular_size >= primary_angular_size:
			# Potential total eclipse (occulter covers primary)
			if angle < (occulter_angular_size - primary_angular_size) / 2.0:
				eclipse_type = "total"
				coverage = 1.0
			else:
				coverage = (total_radius - angle) / primary_angular_size
		else:
			# Potential annular eclipse (primary partially covered)
			if angle < (primary_angular_size - occulter_angular_size) / 2.0:
				eclipse_type = "annular"
				coverage = pow(occulter_radius / primary_radius, 2)
			else:
				coverage = (total_radius - angle) / primary_angular_size
		
		return {
			"eclipse": true,
			"type": eclipse_type,
			"coverage": clamp(coverage, 0.0, 1.0)
		}
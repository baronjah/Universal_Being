# stellar_progression_system.gd
extends Node
class_name StellarProgressionSystem

signal system_discovered(system_data: Dictionary)
signal star_chart_updated(new_systems: Array)
signal warp_drive_upgraded(level: int)

# Stellar map data
var discovered_systems: Dictionary = {}
var current_system: String = "Sol"
var visited_systems: Array[String] = ["Sol"]

# Progression mechanics
var warp_drive_level: int = 1
var stellar_knowledge: float = 0.0
var navigation_skill: float = 1.0

# Star system generator
var star_system_seed: int = 12345
var galaxy_size: Vector3 = Vector3(10000, 1000, 10000)

class StarSystem:
	var name: String
	var position: Vector3
	var star_type: String
	var planets: Array = []
	var resources: Dictionary = {}
	var consciousness_resonance: float
	var discovered: bool = false
	
	func _init(p_name: String, p_position: Vector3):
		name = p_name
		position = p_position
		consciousness_resonance = randf_range(0.1, 1.0)

func _ready():
	generate_local_cluster()
	
func generate_local_cluster():
	# Generate nearby star systems
	var rng = RandomNumberGenerator.new()
	rng.seed = star_system_seed
	
	# Create Sol system
	var sol = StarSystem.new("Sol", Vector3.ZERO)
	sol.star_type = "G-Type"
	sol.discovered = true
	discovered_systems["Sol"] = sol
	
	# Generate nearby systems
	for i in range(20):
		var angle = (i / 20.0) * TAU
		var distance = rng.randf_range(10, 100)
		var height = rng.randf_range(-20, 20)
		
		var position = Vector3(
			cos(angle) * distance,
			height,
			sin(angle) * distance
		)
		
		var system = generate_star_system(position, rng)
		discovered_systems[system.name] = system
		
func generate_star_system(position: Vector3, rng: RandomNumberGenerator) -> StarSystem:
	var star_names = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta"]
	var constellations = ["Centauri", "Draconis", "Ursae", "Aquarii", "Phoenicis"]
	
	var name = star_names[rng.randi() % star_names.size()] + " " + constellations[rng.randi() % constellations.size()]
	var system = StarSystem.new(name, position)
	
	# Star type distribution
	var type_roll = rng.randf()
	if type_roll < 0.7:
		system.star_type = "M-Type"  # Red dwarf
	elif type_roll < 0.85:
		system.star_type = "K-Type"  # Orange dwarf
	elif type_roll < 0.95:
		system.star_type = "G-Type"  # Yellow dwarf
	else:
		system.star_type = "F-Type"  # Yellow-white
		
	# Generate planets
	var planet_count = rng.randi_range(0, 8)
	for i in range(planet_count):
		var planet = {
			"name": system.name + " " + ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"][i],
			"type": ["Rocky", "Gas Giant", "Ice", "Desert", "Ocean"][rng.randi() % 5],
			"resources": generate_planet_resources(rng),
			"consciousness_artifact": rng.randf() < 0.1  # 10% chance
		}
		system.planets.append(planet)
		
	return system
	
func generate_planet_resources(rng: RandomNumberGenerator) -> Dictionary:
	var resources = {}
	var resource_types = ["Helium-3", "Rare Metals", "Crystals", "Organic Compounds", "Dark Matter"]
	
	for resource in resource_types:
		if rng.randf() < 0.4:  # 40% chance for each resource
			resources[resource] = rng.randf_range(10, 1000)
			
	return resources
	
func travel_to_system(system_name: String) -> Dictionary:
	if not discovered_systems.has(system_name):
		return {"success": false, "reason": "System not discovered"}
		
	var target_system = discovered_systems[system_name]
	var current = discovered_systems[current_system]
	
	var distance = current.position.distance_to(target_system.position)
	var max_range = warp_drive_level * 50.0
	
	if distance > max_range:
		return {"success": false, "reason": "System out of range"}
		
	# Travel successful
	current_system = system_name
	if system_name not in visited_systems:
		visited_systems.append(system_name)
		stellar_knowledge += 10.0
		system_discovered.emit({"name": system_name, "data": target_system})
		
	return {"success": true, "travel_time": distance / (warp_drive_level * 10.0)}
	
func scan_nearby_systems(scan_radius: float) -> Array:
	var current_pos = discovered_systems[current_system].position
	var nearby_systems = []
	
	for system_name in discovered_systems:
		if system_name == current_system:
			continue
			
		var system = discovered_systems[system_name]
		var distance = current_pos.distance_to(system.position)
		
		if distance <= scan_radius:
			system.discovered = true
			nearby_systems.append({
				"name": system_name,
				"distance": distance,
				"star_type": system.star_type
			})
			
	if nearby_systems.size() > 0:
		star_chart_updated.emit(nearby_systems)
		
	return nearby_systems
	
func upgrade_warp_drive():
	warp_drive_level += 1
	warp_drive_upgraded.emit(warp_drive_level)
	
func find_consciousness_artifacts() -> Array:
	var artifacts = []
	
	for system_name in visited_systems:
		var system = discovered_systems[system_name]
		for planet in system.planets:
			if planet.get("consciousness_artifact", false):
				artifacts.append({
					"location": planet["name"],
					"system": system_name,
					"type": "Ancient Consciousness Relic"
				})
				
	return artifacts

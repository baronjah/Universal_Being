extends Resource
class_name GalaxyData

var id: int
var seed_value: int
var galaxy_type: int
var position: Vector3
var rotation: Vector3
var size: float
var parameters: Dictionary
var star_systems: Dictionary
var resources: Dictionary
var name: String

func _init(p_seed: int = 0, p_position: Vector3 = Vector3.ZERO):
	seed_value = p_seed
	position = p_position
	
	if seed_value != 0:
		# Generate unique ID
		id = seed_value + int(position.x * 1000) + int(position.y * 1000000) + int(position.z * 1000000000)
		
		# Generate name
		var rng = RandomNumberGenerator.new()
		rng.seed = seed_value
		name = generate_galaxy_name(rng)
		
		# Create empty containers
		star_systems = {}
		resources = {}

# Generate a galaxy name based on seed
func generate_galaxy_name(rng: RandomNumberGenerator) -> String:
	var prefixes = ["Alpha", "Beta", "Gamma", "Delta", "Omega", "Nova", "Orion", "Andromeda", 
					"Centauri", "Proxima", "Sirius", "Arcturus", "Vega", "Rigel", "Antares", "Pegasus"]
	var middles = ["Prime", "Major", "Minor", "Maxima", "Cluster", "Nebula", "Cloud", "Core", 
				  "Arm", "Vortex", "Stream", "Current", "Rift", "Void", "Field", "Web"]
	var suffixes = ["I", "II", "III", "IV", "V", "A", "B", "C", "Prime", "Alpha", "Beta", 
				   "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	
	var has_suffix = rng.randf() > 0.3
	var has_middle = rng.randf() > 0.5
	
	var prefix = prefixes[rng.randi() % prefixes.size()]
	var name_parts = [prefix]
	
	if has_middle:
		var middle = middles[rng.randi() % middles.size()]
		name_parts.append(middle)
	
	if has_suffix:
		var suffix = suffixes[rng.randi() % suffixes.size()]
		name_parts.append(suffix)
	
	return " ".join(name_parts)

# Add a star system to this galaxy
func add_star_system(star_system_data: Dictionary) -> void:
	if star_system_data.has("id"):
		star_systems[star_system_data.id] = star_system_data

# Get star systems in this galaxy
func get_star_systems() -> Dictionary:
	return star_systems

# Get basic galaxy info
func get_info() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"position": position,
		"size": size,
		"type": galaxy_type,
		"star_count": star_systems.size()
	}

# Serialize galaxy data for saving
func serialize() -> Dictionary:
	var data = {
		"id": id,
		"seed": seed_value,
		"type": galaxy_type,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"rotation": {
			"x": rotation.x,
			"y": rotation.y,
			"z": rotation.z
		},
		"size": size,
		"parameters": parameters,
		"name": name,
		"star_systems": {},
		"resources": resources
	}
	
	# Serialize star systems
	for system_id in star_systems:
		if star_systems[system_id] is Dictionary:
			data.star_systems[system_id] = star_systems[system_id]
	
	return data

# Deserialize from saved data
func deserialize(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("seed"):
		seed_value = data.seed
	if data.has("type"):
		galaxy_type = data.type
	if data.has("position"):
		position = Vector3(data.position.x, data.position.y, data.position.z)
	if data.has("rotation"):
		rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	if data.has("size"):
		size = data.size
	if data.has("parameters"):
		parameters = data.parameters
	if data.has("name"):
		name = data.name
	if data.has("star_systems"):
		star_systems = data.star_systems
	if data.has("resources"):
		resources = data.resources
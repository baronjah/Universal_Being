# world_database.gd
extends Node

class_name WorldDatabase

# File path for saving the world
const SAVE_FILE_PATH = "user://luminus_world.json"

func save_world(world) -> bool:
	var data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"dimensions": {
			"width": world.width,
			"height": world.height
		},
		"environment_layers": {
			"moisture": serialize_layer(world.moisture_layer),
			"temperature": serialize_layer(world.temperature_layer),
			"nutrients": serialize_layer(world.nutrient_layer),
			"sunlight": serialize_layer(world.sunlight_layer)
		},
		"entities": []
	}
	
	# Save all entities
	for x in range(world.width):
		for y in range(world.height):
			var cell_entities = world.get_entities_at(x, y)
			for entity in cell_entities:
				data.entities.append(entity.to_dict())
	
	# Save to file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		print("Error opening file for writing: ", FileAccess.get_open_error())
		return false
	
	file.store_string(JSON.stringify(data, "  "))
	return true

func load_world(world) -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		print("Save file not found or error opening: ", FileAccess.get_open_error())
		return false
		
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return false
		
	var data = json.get_data()
	
	# Resize world if needed
	world.width = data.dimensions.width
	world.height = data.dimensions.height
	
	# Clear existing world
	world.clear()
	
	# Load environment layers
	world.moisture_layer = deserialize_layer(data.environment_layers.moisture)
	world.temperature_layer = deserialize_layer(data.environment_layers.temperature)
	world.nutrient_layer = deserialize_layer(data.environment_layers.nutrients)
	world.sunlight_layer = deserialize_layer(data.environment_layers.sunlight)
	
	# Load entities
	for entity_data in data.entities:
		var entity = create_entity_from_data(entity_data)
		if entity != null:
			world.add_entity(entity, entity_data.position.x, entity_data.position.y)
	
	return true

func serialize_layer(layer):
	# For larger worlds, we can use compression algorithms here
	return layer

func deserialize_layer(data):
	return data

func create_entity_from_data(data):
	var entity = null
	
	# Create appropriate entity type
	match data.type:
		"plant":
			entity = load("res://entities/Plant.tscn").instantiate()
		"animal":
			entity = load("res://entities/Animal.tscn").instantiate()
		# Add more entity types
	
	if entity != null:
		entity.from_dict(data)
	
	return entity

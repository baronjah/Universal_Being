extends Node
class_name SnakeSpawner

# Add this to your main scene tree to enable snake spawning
# Use the AkashicRecordsManager to register the snake as a special entity

var akashic_records_manager = null
var active_snakes = {}
var is_spawning = false  # Protection flag to prevent infinite recursion

func _ready():
	# Find references
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		akashic_records_manager = AkashicRecordsManagerA.get_instance()
		
	if not akashic_records_manager:
		print("ERROR: Could not find AkashicRecordsManager. Snake spawning disabled.")
		return
	
	# Initialize by registering snake word in the dictionary
	register_snake_word()
	
	# Connect to global event system
	akashic_records_manager.entity_created.connect(_on_entity_created)

func register_snake_word():
	# Create a new word for the snake
	var snake_word_data = {
		"id": "space_snake",
		"display_name": "Space Snake",
		"category": "cosmic",
		"parent": "",
		"description": "A mystical snake that travels through the void, bringing cosmic energy to all it passes.",
		"properties": {
			"speed": 2.0,
			"segments": 10,
			"cosmic_energy": 100.0,
			"follow_player": true
		},
		"states": {
			"available": ["hunting", "passive", "resting"],
			"current": "passive"
		},
		"interactions": {
			"water": {
				"result": "energy_boost",
				"conditions": {}
			},
			"fire": {
				"result": "speed_boost",
				"conditions": {}
			},
			"void": {
				"result": "multiply",
				"conditions": {
					"snake_energy": "> 50"
				}
			}
		}
	}
	
	# Register in the dictionary
	var success = akashic_records_manager.create_word("space_snake", snake_word_data)
	if success:
		print("Space Snake registered in Akashic Records!")
	else:
		print("Failed to register Space Snake word.")

func spawn_snake(position: Vector3) -> SpaceSnake:
	# Protection against infinite recursion
	if is_spawning:
		print("Spawn already in progress, skipping to avoid recursion")
		return null
		
	is_spawning = true
	
	# Create the snake entity
	var snake_id = "snake_" + str(randi())
	var snake = SpaceSnake.new()
	snake.name = snake_id
	snake.global_position = position
	
	# Add to scene
	add_child(snake)
	
	# Register in AkashicRecords
	var properties = {
		"speed": snake.speed,
		"segments": snake.segment_count,
		"cosmic_energy": 100.0
	}
	
	var snake_entity_id = "entity_" + snake_id
	var success = akashic_records_manager.create_entity(
		snake_entity_id,
		"space_snake",
		position,
		properties
	)
	
	if success:
		print("Snake entity created in AkashicRecords: " + snake_entity_id)
		# Store reference
		active_snakes[snake_entity_id] = snake
	else:
		print("Failed to register snake in AkashicRecords.")
	
	# Reset protection flag
	is_spawning = false
	return snake

func _on_entity_created(entity_id: String):
	# Check if the entity is a snake
	var entity = akashic_records_manager.get_entity(entity_id)
	if entity != null and entity.has("type") and entity.type == "space_snake":
		# If the entity was created elsewhere, spawn the visual representation
		# Skip if we're already spawning or if we already know about this snake
		if not is_spawning and not active_snakes.has(entity_id):
			var position = Vector3(
				entity.position.x,
				entity.position.y,
				entity.position.z
			)
			
			# Just register the entity instead of spawning again
			print("Registering external snake entity: " + entity_id)
			active_snakes[entity_id] = null  # Mark as known but not spawned by us
			
			# We don't call spawn_snake() here to avoid recursion

# Call this to spawn a snake from your code or UI
func spawn_snake_at_player():
	var camera = get_viewport().get_camera_3d()
	if camera:
		var position = camera.global_position + camera.global_transform.basis.z * -5.0
		spawn_snake(position)
		print("Spawned snake at player position!")
	else:
		var fallback_pos = Vector3(0, 0, 0)
		spawn_snake(fallback_pos)
		print("Camera not found, spawned snake at origin.")

# Add this to your UI handler to allow snake spawning
func register_snake_command():
	if has_node("/root/CommandConsole"):
		var console = get_node("/root/CommandConsole")
		console.register_command("spawn_snake", self, "spawn_snake_at_player", 
			"Spawns a cosmic space snake at your position")
	else:
		print("Console not found, snake command not registered.")

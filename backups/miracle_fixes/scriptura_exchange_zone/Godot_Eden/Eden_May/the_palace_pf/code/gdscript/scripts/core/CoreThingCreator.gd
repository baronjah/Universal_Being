extends Node
class_name CoreThingCreator

# Singleton pattern
static var _instance = null

static func get_instance() -> CoreThingCreator:
	if not _instance:
		_instance = CoreThingCreator.new()
	return _instance

# Referenced components
var universal_entity_class = null
var word_manifestor = null
var akashic_records_manager = null

# Entity tracking
var active_entities = {}
var entity_patterns = {}

# Signals
signal entity_created(entity_id, word, position)
signal entity_transformed(entity_id, old_form, new_form)
signal entity_evolved(entity_id, old_stage, new_stage)
signal entity_connected(entity_id, target_id, connection_type)
signal pattern_created(pattern_id, entities)

func _init():
	name = "CoreThingCreator"

func _ready():
	print("CoreThingCreator initializing...")
	
	# Load required classes
	_load_required_classes()
	
	# Initialize Akashic Records integration
	_initialize_akashic_records()
	
	print("CoreThingCreator initialization complete")

func _load_required_classes():
	# Load the CoreUniversalEntity class
	universal_entity_class = load("res://code/gdscript/scripts/core/CoreUniversalEntity.gd")
	if not universal_entity_class:
		push_error("CoreUniversalEntity class not found!")
	
	# Find or create word manifestor
	var word_manifestor_script = load("res://code/gdscript/scripts/core/CoreWordManifestor.gd")
	if word_manifestor_script:
		word_manifestor = word_manifestor_script.new()
	else:
		push_error("CoreWordManifestor script not found!")

func _initialize_akashic_records():
	# Find or load AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		var akashic_class = load("res://code/gdscript/scripts/core/core_akashic_records_manager.gd")
		if akashic_class:
			akashic_records_manager = akashic_class.new()
			akashic_records_manager.name = "AkashicRecordsManager"
			get_tree().root.add_child(akashic_records_manager)
		else:
			# Try alternate path
			akashic_class = load("res://code/gdscript/scripts/akashic_records/core_akashic_records_manager.gd")
			if akashic_class:
				akashic_records_manager = akashic_class.new()
				akashic_records_manager.name = "AkashicRecordsManager"
				get_tree().root.add_child(akashic_records_manager)
			else:
				push_error("Could not find AkashicRecordsManager script!")

# Create an entity from a word
func create_entity(word: String, position: Vector3, evolution_stage: int = 0) -> String:
	if not universal_entity_class:
		push_error("Cannot create entity: CoreUniversalEntity class not loaded")
		return ""
	
	# Create a new universal entity
	var entity = universal_entity_class.new()
	entity.name = "Entity_" + word
	
	# Manifest it from the word
	entity.manifest_from_word(word)
	
	# Set position
	entity.global_position = position
	
	# Set initial evolution stage if specified
	if evolution_stage > 0:
		for i in range(evolution_stage):
			entity.evolve(0.2)
	
	# Add to scene
	get_tree().current_scene.add_child(entity)
	
	# Generate a unique ID
	var entity_id = word + "_" + str(randi())
	
	# Store in active entities
	active_entities[entity_id] = entity
	
	# Register with Akashic Records if available
	if akashic_records_manager:
		akashic_records_manager.create_entity(entity_id, "universal_entity", position, {
			"word": word,
			"evolution_stage": evolution_stage
		})
	
	# Connect to entity signals
	entity.connect("entity_transformed", _on_entity_transformed.bind(entity_id))
	entity.connect("entity_evolved", _on_entity_evolved.bind(entity_id))
	
	# Emit signal
	emit_signal("entity_created", entity_id, word, position)
	
	return entity_id

# Remove an entity
func remove_entity(entity_id: String) -> bool:
	if not active_entities.has(entity_id):
		return false
	
	var entity = active_entities[entity_id]
	
	# Remove from scene
	entity.queue_free()
	
	# Remove from storage
	active_entities.erase(entity_id)
	
	# Remove from Akashic Records if registered
	if akashic_records_manager:
		akashic_records_manager.remove_entity_from_zones(entity_id)
	
	return true

# Get all active entities
func get_all_entities() -> Array:
	return active_entities.keys()

# Get an entity by ID
func get_entity(entity_id: String):
	return active_entities.get(entity_id)

# Connect two entities
func connect_entities(entity1_id: String, entity2_id: String, connection_type: String = "default") -> bool:
	if not active_entities.has(entity1_id) or not active_entities.has(entity2_id):
		return false
	
	var entity1 = active_entities[entity1_id]
	var entity2 = active_entities[entity2_id]
	
	var success = entity1.connect_to(entity2, connection_type)
	
	if success:
		emit_signal("entity_connected", entity1_id, entity2_id, connection_type)
	
	return success

# Transform an entity to a different form
func transform_entity(entity_id: String, new_form: String, transformation_time: float = 1.0) -> bool:
	if not active_entities.has(entity_id):
		return false
	
	var entity = active_entities[entity_id]
	var old_form = entity.current_form
	
	entity.transform_to(new_form, transformation_time)
	
	return true

# Evolve an entity
func evolve_entity(entity_id: String, evolution_factor: float = 0.2) -> bool:
	if not active_entities.has(entity_id):
		return false
	
	var entity = active_entities[entity_id]
	var old_stage = entity.evolution_stage
	
	entity.evolve(evolution_factor)
	
	return true

# Create a pattern of entities
func create_pattern(
	word: String, 
	pattern_type: String = "circle", 
	position: Vector3 = Vector3.ZERO, 
	count: int = 5, 
	radius: float = 5.0
) -> String:
	# Generate pattern ID
	var pattern_id = "pattern_" + pattern_type + "_" + word + "_" + str(randi())
	
	# Array to store created entities
	var pattern_entities = []
	
	# Create entities in different patterns
	match pattern_type:
		"circle":
			# Create entities in a circle
			for i in range(count):
				var angle = 2 * PI * i / count
				var x = position.x + radius * cos(angle)
				var z = position.z + radius * sin(angle)
				var entity_pos = Vector3(x, position.y, z)
				
				var entity_id = create_entity(word, entity_pos)
				if not entity_id.is_empty():
					pattern_entities.append(entity_id)
		
		"grid":
			# Create entities in a grid
			var grid_size = int(ceil(sqrt(count)))
			var spacing = radius / max(1, grid_size - 1)
			
			var start_x = position.x - (spacing * (grid_size - 1)) / 2
			var start_z = position.z - (spacing * (grid_size - 1)) / 2
			
			for i in range(count):
				var x = start_x + (i % int(grid_size)) * spacing
				var z = start_z + floor(i / grid_size) * spacing
				var entity_pos = Vector3(x, position.y, z)
				
				var entity_id = create_entity(word, entity_pos)
				if not entity_id.is_empty():
					pattern_entities.append(entity_id)
		
		"random":
			# Create entities in random positions
			for i in range(count):
				var x = position.x + randf_range(-radius, radius)
				var z = position.z + randf_range(-radius, radius)
				var entity_pos = Vector3(x, position.y, z)
				
				var entity_id = create_entity(word, entity_pos)
				if not entity_id.is_empty():
					pattern_entities.append(entity_id)
					
		"sphere":
			# Create entities in a sphere
			for i in range(count):
				# Spherical coordinates
				var phi = randf() * 2 * PI
				var theta = acos(2 * randf() - 1)
				
				# Convert to Cartesian
				var x = position.x + radius * sin(theta) * cos(phi)
				var y = position.y + radius * sin(theta) * sin(phi)
				var z = position.z + radius * cos(theta)
				
				var entity_pos = Vector3(x, y, z)
				
				var entity_id = create_entity(word, entity_pos)
				if not entity_id.is_empty():
					pattern_entities.append(entity_id)
	
	# Store pattern for tracking
	entity_patterns[pattern_id] = pattern_entities
	
	# Emit signal
	emit_signal("pattern_created", pattern_id, pattern_entities)
	
	return pattern_id

# Process interaction between two entities
func process_entity_interaction(entity1_id: String, entity2_id: String) -> Dictionary:
	if not active_entities.has(entity1_id) or not active_entities.has(entity2_id):
		return {"success": false, "error": "Entities not found"}
	
	# Get entities
	var entity1 = active_entities[entity1_id]
	var entity2 = active_entities[entity2_id]
	
	# Process interaction
	var result = entity1.interact_with(entity2)
	
	# If interaction creates a new entity
	if result.get("success", false) and result.has("result_type"):
		var result_word = result.get("result_type", "")
		var pos1 = entity1.global_position
		var pos2 = entity2.global_position
		var midpoint = (pos1 + pos2) / 2
		
		# Create a new entity at the midpoint
		if not result_word.is_empty():
			var new_entity_id = create_entity(result_word, midpoint)
			result["result_entity_id"] = new_entity_id
	
	return result

# Signal handlers
func _on_entity_transformed(entity, old_form, new_form, entity_id):
	emit_signal("entity_transformed", entity_id, old_form, new_form)

func _on_entity_evolved(entity, old_stage, new_stage, entity_id):
	emit_signal("entity_evolved", entity_id, old_stage, new_stage)
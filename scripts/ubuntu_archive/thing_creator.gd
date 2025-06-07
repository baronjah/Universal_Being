extends Node
class_name ThingCreatorA

# Singleton pattern
static var _instance: ThingCreatorA = null

# Static function to get the singleton instance
static func get_instance() -> ThingCreatorA:
    if not _instance:
        _instance = ThingCreatorA.new()
    return _instance

# Entity creation parameters
var next_entity_id: int = 1000
var default_properties: Dictionary = {
    "energy": 10,
    "intensity": 1,
    "stability": 0.7
}

# Signals
signal entity_created(entity)
signal entity_template_created(template_id, properties)

func _ready() -> void:
    print("ThingCreator: Ready")

# Create a new entity based on a type and properties
func create_entity(type: String = "primordial", custom_properties: Dictionary = {}) -> Node:
    print("ThingCreator: Creating entity of type: ", type)
    
    # Load the UniversalEntity class
    var UniversalEntity = load("res://universal_entity.gd")
    
    # Prepare properties (combine default with custom)
    var properties = default_properties.duplicate()
    for key in custom_properties:
        properties[key] = custom_properties[key]
    
    # Create entity ID
    var entity_id = "entity_" + str(next_entity_id)
    next_entity_id += 1
    
    # Create the entity
    var entity = UniversalEntity.new(entity_id, type, properties)
    
    # Emit signal
    emit_signal("entity_created", entity)
    
    return entity

# Create a template for entities
func create_entity_template(type: String, base_properties: Dictionary = {}) -> String:
    print("ThingCreator: Creating entity template for type: ", type)
    
    # Generate template ID
    var template_id = type + "_template_" + str(randi() % 1000)
    
    # Store template properties
    var template_properties = base_properties.duplicate()
    template_properties["entity_type"] = type
    
    # Emit signal
    emit_signal("entity_template_created", template_id, template_properties)
    
    return template_id

# Create a new entity based on a template
func create_entity_from_template(template_id: String, custom_properties: Dictionary = {}) -> Node:
    print("ThingCreator: Creating entity from template: ", template_id)
    
    # In a real implementation, you would look up the template
    # For now, just extract the type from the template ID
    var type = "primordial"
    if template_id.find("_template_") >= 0:
        type = template_id.split("_template_")[0]
    
    # Create the entity
    return create_entity(type, custom_properties)

# Helper functions for entity creation
func create_fire_entity(intensity: int = 3) -> Node:
    return create_entity("fire", {"intensity": intensity})

func create_water_entity(fluidity: int = 5) -> Node:
    return create_entity("water", {"fluidity": fluidity})

func create_earth_entity(mass: int = 8) -> Node:
    return create_entity("earth", {"mass": mass})

func create_air_entity(volume: int = 4) -> Node:
    return create_entity("air", {"volume": volume})

# Create a random entity of a basic type
func create_random_entity() -> Node:
    var types = ["primordial", "fire", "water", "earth", "air", "wood", "metal", "ash"]
    var type = types[randi() % types.size()]
    
    var properties = {
        "energy": randi() % 10 + 1,
        "intensity": randi() % 3 + 1,
        "created_randomly": true
    }
    
    return create_entity(type, properties)
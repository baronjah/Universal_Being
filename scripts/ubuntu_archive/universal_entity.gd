extends Node
class_name UniversalEntity

# Entity core properties
var entity_id: String = ""
var entity_type: String = "primordial"
var properties: Dictionary = {}
var creation_timestamp: String = ""
var transformation_history: Array = []
var references: Dictionary = {}

# Signals
signal transformed(old_type, new_type)
signal property_changed(property_name, old_value, new_value)
signal interacted(other_entity, result)

func _init(id: String = "", type: String = "primordial", init_properties: Dictionary = {}) -> void:
    if id.empty():
        entity_id = generate_entity_id()
    else:
        entity_id = id
        
    entity_type = type
    properties = init_properties.duplicate()
    creation_timestamp = Time.get_datetime_string_from_system()
    
    # Add initial transformation record
    add_transformation_record("creation", "none", entity_type)

func _ready() -> void:
    name = entity_type + "_" + entity_id.substr(0, 8)

# Core entity methods
func generate_entity_id() -> String:
    # Generate a unique ID using a UUID-like format
    var id_parts = []
    
    # Use current time (microseconds)
    id_parts.append(str(Time.get_ticks_usec()))
    
    # Add some random bits
    id_parts.append(str(randi() % 1000000).pad_zeros(6))
    
    # Combine everything
    var full_id = id_parts.join("_")
    
    return full_id

func transform(new_type: String) -> bool:
    # Don't transform if already this type
    if new_type == entity_type:
        return false
        
    var old_type = entity_type
    
    # Record the transformation
    add_transformation_record("transform", old_type, new_type)
    
    # Update the type
    entity_type = new_type
    
    # Update the node name to reflect the new type
    name = entity_type + "_" + entity_id.substr(0, 8)
    
    # Emit signal
    emit_signal("transformed", old_type, new_type)
    
    return true

func add_transformation_record(action: String, from_type: String, to_type: String) -> void:
    var record = {
        "action": action,
        "from_type": from_type,
        "to_type": to_type,
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    transformation_history.append(record)

func set_property(property_name: String, value) -> void:
    var old_value = null
    if properties.has(property_name):
        old_value = properties[property_name]
        
    properties[property_name] = value
    emit_signal("property_changed", property_name, old_value, value)

func get_property(property_name: String, default_value = null):
    if properties.has(property_name):
        return properties[property_name]
    return default_value

func interact_with(other_entity: UniversalEntity) -> Dictionary:
    # Get the interaction result based on both entity types
    # This should be determined by the interaction matrix
    var result = {
        "success": false,
        "effect": "none",
        "source_entity": self,
        "target_entity": other_entity,
        "source_type": entity_type,
        "target_type": other_entity.entity_type if other_entity else "none"
    }
    
    # Signal that interaction happened
    emit_signal("interacted", other_entity, result)
    
    return result

func add_reference(reference_type: String, target_entity_id: String) -> void:
    if not references.has(reference_type):
        references[reference_type] = []
    
    # Avoid duplicates
    if not target_entity_id in references[reference_type]:
        references[reference_type].append(target_entity_id)

func remove_reference(reference_type: String, target_entity_id: String) -> bool:
    if not references.has(reference_type):
        return false
    
    var index = references[reference_type].find(target_entity_id)
    if index >= 0:
        references[reference_type].remove_at(index)
        return true
    
    return false

# Serialization
func to_dict() -> Dictionary:
    return {
        "entity_id": entity_id,
        "entity_type": entity_type,
        "properties": properties,
        "creation_timestamp": creation_timestamp,
        "transformation_history": transformation_history,
        "references": references
    }

func from_dict(data: Dictionary) -> bool:
    if not data.has("entity_id") or not data.has("entity_type"):
        return false
    
    entity_id = data["entity_id"]
    entity_type = data["entity_type"]
    
    if data.has("properties"):
        properties = data["properties"].duplicate()
    
    if data.has("creation_timestamp"):
        creation_timestamp = data["creation_timestamp"]
    
    if data.has("transformation_history"):
        transformation_history = data["transformation_history"].duplicate()
    
    if data.has("references"):
        references = data["references"].duplicate()
    
    # Update node name
    name = entity_type + "_" + entity_id.substr(0, 8)
    
    return true

# Getter methods for property access
func get_id() -> String:
    return entity_id

func get_type() -> String:
    return entity_type

func get_creation_timestamp() -> String:
    return creation_timestamp

func get_transformation_history() -> Array:
    return transformation_history

func get_properties() -> Dictionary:
    return properties

func get_references() -> Dictionary:
    return references
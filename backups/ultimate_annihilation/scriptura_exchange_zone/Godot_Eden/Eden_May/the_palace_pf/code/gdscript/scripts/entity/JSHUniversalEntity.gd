extends UniversalEntity
class_name JSHUniversalEntity

# Constants for entity complexity thresholds
const COMPLEXITY_THRESHOLD_LOW = 10
const COMPLEXITY_THRESHOLD_MED = 50
const COMPLEXITY_THRESHOLD_HIGH = 100

# Additional properties for JSH entities
var complexity: float = 0.0
var evolution_stage: int = 0
var parent_entities: Array = []
var child_entities: Array = []
var last_processed_time: int = 0
var should_split: bool = false
var metadata: Dictionary = {}
var zones: Array = []
var tags: Array = []

# Specialized signals
signal complexity_changed(old_value, new_value)
signal evolution_stage_changed(old_stage, new_stage)
signal entity_split(original_entity, new_entities)
signal entity_merged(source_entities, new_entity)

# Extension of the initialization method
func _init(id: String = "", type: String = "primordial", init_properties: Dictionary = {}) -> void:
    # Call parent initialization
    super(id, type, init_properties)
    
    # Set up JSH-specific properties
    if init_properties.has("complexity"):
        complexity = init_properties.complexity
    else:
        complexity = calculate_initial_complexity()
    
    if init_properties.has("evolution_stage"):
        evolution_stage = init_properties.evolution_stage
    
    if init_properties.has("parent_entities"):
        parent_entities = init_properties.parent_entities.duplicate()
    
    if init_properties.has("metadata"):
        metadata = init_properties.metadata.duplicate()
    
    if init_properties.has("tags"):
        tags = init_properties.tags.duplicate()
    
    last_processed_time = Time.get_ticks_msec()

# Complexity calculation methods
func calculate_initial_complexity() -> float:
    var base_complexity = 1.0
    
    # Type-based complexity
    match entity_type:
        "primordial":
            base_complexity = 1.0
        "fire", "water", "air", "earth", "metal", "wood", "ash":
            base_complexity = 2.5
        "fused":
            base_complexity = 5.0
        "transformed":
            base_complexity = 4.0
        _:
            # For custom types, assume medium complexity
            base_complexity = 3.0
    
    # Property-based complexity - more properties = more complex
    base_complexity += properties.size() * 0.5
    
    # Reference-based complexity - more connections = more complex
    for ref_type in references:
        base_complexity += references[ref_type].size() * 0.3
    
    # Round to 2 decimal places
    return snappedf(base_complexity, 0.01)

func update_complexity() -> void:
    var old_complexity = complexity
    var new_complexity = calculate_complexity()
    
    if new_complexity != old_complexity:
        complexity = new_complexity
        emit_signal("complexity_changed", old_complexity, new_complexity)
        
        # Check if we need to update evolution stage
        check_evolution_stage()
        
        # Check if we should split due to high complexity
        check_split_threshold()

func calculate_complexity() -> float:
    # Start with the base calculation
    var current_complexity = calculate_initial_complexity()
    
    # Time factor - longer-lived entities are more complex
    var time_alive_ms = Time.get_ticks_msec() - last_processed_time
    current_complexity += (time_alive_ms / 60000.0) * 0.1  # Add 0.1 per minute
    
    # Transformation history factor - more transformations = more complex
    current_complexity += transformation_history.size() * 0.2
    
    # Child entity factor - more children = more complex
    current_complexity += child_entities.size() * 0.5
    
    # Metadata factor
    current_complexity += metadata.size() * 0.3
    
    # Round to 2 decimal places
    return snappedf(current_complexity, 0.01)

# Evolution stage methods
func check_evolution_stage() -> void:
    var old_stage = evolution_stage
    var new_stage = calculate_evolution_stage()
    
    if new_stage != old_stage:
        evolution_stage = new_stage
        emit_signal("evolution_stage_changed", old_stage, new_stage)
        
        # Add transformation record for stage change
        add_transformation_record("evolution", "stage_" + str(old_stage), "stage_" + str(new_stage))

func calculate_evolution_stage() -> int:
    if complexity < COMPLEXITY_THRESHOLD_LOW:
        return 0
    elif complexity < COMPLEXITY_THRESHOLD_MED:
        return 1
    elif complexity < COMPLEXITY_THRESHOLD_HIGH:
        return 2
    else:
        return 3

# Splitting and merging functionality
func check_split_threshold() -> void:
    if complexity > COMPLEXITY_THRESHOLD_HIGH and evolution_stage >= 2:
        should_split = true

func attempt_split() -> Array:
    if not should_split:
        return []
    
    print("JSHUniversalEntity: Attempting to split entity " + entity_id)
    
    # Create new entities from this one
    var new_entities = []
    
    # Decide how to split based on entity type and properties
    var split_count = 2
    if complexity > COMPLEXITY_THRESHOLD_HIGH * 2:
        split_count = 3
    
    # Distribute properties among the new entities
    var property_keys = properties.keys()
    
    for i in range(split_count):
        var new_properties = {}
        
        # Distribute some properties to each new entity
        for j in range(property_keys.size()):
            if j % split_count == i:
                var key = property_keys[j]
                new_properties[key] = properties[key]
        
        # Add parent reference and basic metadata
        new_properties["parent_entities"] = [entity_id]
        new_properties["complexity"] = complexity / split_count
        new_properties["evolution_stage"] = evolution_stage - 1
        
        # Create new entity with same type but derived
        var new_entity = JSHUniversalEntity.new("", "derived_" + entity_type, new_properties)
        
        # Track this new entity as a child
        child_entities.append(new_entity.get_id())
        
        # Add to result list
        new_entities.append(new_entity)
    }
    
    # Reset split flag and reduce complexity of this entity
    should_split = false
    complexity /= 2
    
    # Emit signal about the split
    emit_signal("entity_split", self, new_entities)
    
    return new_entities

static func merge_entities(entities: Array) -> JSHUniversalEntity:
    if entities.size() < 2:
        print("JSHUniversalEntity: Need at least 2 entities to merge")
        return null
    
    print("JSHUniversalEntity: Merging " + str(entities.size()) + " entities")
    
    # Calculate merged properties
    var merged_properties = {}
    var total_complexity = 0.0
    var parent_ids = []
    var all_tags = []
    
    for entity in entities:
        if not entity is JSHUniversalEntity:
            continue
        
        # Add parent ID
        parent_ids.append(entity.get_id())
        
        # Sum complexities
        total_complexity += entity.complexity
        
        # Merge properties
        for key in entity.properties:
            if not merged_properties.has(key):
                merged_properties[key] = entity.properties[key]
            elif typeof(merged_properties[key]) == TYPE_FLOAT or typeof(merged_properties[key]) == TYPE_INT:
                merged_properties[key] += entity.properties[key]
            
        # Collect tags
        for tag in entity.tags:
            if not tag in all_tags:
                all_tags.append(tag)
    
    # Set up the merged entity properties
    merged_properties["parent_entities"] = parent_ids
    merged_properties["complexity"] = total_complexity * 0.8  # Slight reduction in complexity
    merged_properties["evolution_stage"] = 2  # Start at medium evolution stage
    merged_properties["tags"] = all_tags
    
    # Create merged entity
    var merged_type = "merged"
    if entities.size() > 0:
        merged_type = "merged_" + entities[0].get_type()
    
    var merged_entity = JSHUniversalEntity.new("", merged_type, merged_properties)
    
    # For each original entity, add the merged entity as a child
    for entity in entities:
        if entity is JSHUniversalEntity:
            entity.child_entities.append(merged_entity.get_id())
    
    # Emit signal from the new entity about the merge
    merged_entity.emit_signal("entity_merged", entities, merged_entity)
    
    return merged_entity

# Zone management
func add_to_zone(zone_id: String) -> bool:
    if zone_id in zones:
        return false  # Already in this zone
    
    zones.append(zone_id)
    return true

func remove_from_zone(zone_id: String) -> bool:
    var index = zones.find(zone_id)
    if index >= 0:
        zones.remove_at(index)
        return true
    return false

func get_zones() -> Array:
    return zones.duplicate()

# Tag management
func add_tag(tag: String) -> bool:
    if tag in tags:
        return false
    
    tags.append(tag)
    return true

func remove_tag(tag: String) -> bool:
    var index = tags.find(tag)
    if index >= 0:
        tags.remove_at(index)
        return true
    return false

func has_tag(tag: String) -> bool:
    return tag in tags

func get_tags() -> Array:
    return tags.duplicate()

# Metadata management
func set_metadata(key: String, value) -> void:
    metadata[key] = value

func get_metadata(key: String, default_value = null):
    if metadata.has(key):
        return metadata[key]
    return default_value

func remove_metadata(key: String) -> bool:
    if metadata.has(key):
        metadata.erase(key)
        return true
    return false

# Lifecycle management
func process(delta: float) -> void:
    # Update since last processed
    var current_time = Time.get_ticks_msec()
    var time_since_last = current_time - last_processed_time
    
    # Only process if enough time has passed
    if time_since_last > 100:  # 100ms minimum between processing
        # Update complexity
        update_complexity()
        
        # Check if we should split
        if should_split:
            var new_entities = attempt_split()
            # Note: The entity that splits should usually be handled by an entity manager
        
        # Update last processed time
        last_processed_time = current_time

# Extended serialization
func to_dict() -> Dictionary:
    # Get base serialization
    var data = super.to_dict()
    
    # Add JSH-specific data
    data["complexity"] = complexity
    data["evolution_stage"] = evolution_stage
    data["parent_entities"] = parent_entities.duplicate()
    data["child_entities"] = child_entities.duplicate()
    data["metadata"] = metadata.duplicate()
    data["zones"] = zones.duplicate()
    data["tags"] = tags.duplicate()
    data["last_processed_time"] = last_processed_time
    data["should_split"] = should_split
    
    return data

func from_dict(data: Dictionary) -> bool:
    # Apply base deserialization
    var success = super.from_dict(data)
    if not success:
        return false
    
    # Apply JSH-specific data
    if data.has("complexity"):
        complexity = data["complexity"]
    
    if data.has("evolution_stage"):
        evolution_stage = data["evolution_stage"]
    
    if data.has("parent_entities"):
        parent_entities = data["parent_entities"].duplicate()
    
    if data.has("child_entities"):
        child_entities = data["child_entities"].duplicate()
    
    if data.has("metadata"):
        metadata = data["metadata"].duplicate()
    
    if data.has("zones"):
        zones = data["zones"].duplicate()
    
    if data.has("tags"):
        tags = data["tags"].duplicate()
    
    if data.has("last_processed_time"):
        last_processed_time = data["last_processed_time"]
    
    if data.has("should_split"):
        should_split = data["should_split"]
    
    return true
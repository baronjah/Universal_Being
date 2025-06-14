extends Node
class_name JSHEntityManager

# Singleton pattern
static var _instance: JSHEntityManager = null

static func get_instance() -> JSHEntityManager:
    if not _instance:
        _instance = JSHEntityManager.new()
    return _instance

# Entity tracking
var entities: Dictionary = {}
var entities_by_type: Dictionary = {}
var entities_by_tag: Dictionary = {}
var entities_by_zone: Dictionary = {}

# Processing configuration
var auto_process: bool = true
var process_batch_size: int = 20
var process_interval_ms: int = 100
var last_process_time: int = 0
var process_queue: Array = []

# Thresholds and limits
var max_entities: int = 10000
var max_entities_per_zone: int = 1000
var complexity_limit: float = JSHUniversalEntity.COMPLEXITY_THRESHOLD_HIGH * 2

# Signals
signal entity_created(entity)
signal entity_destroyed(entity_id)
signal entity_split(original_entity, new_entities)
signal entity_merged(source_entities, new_entity)
signal entity_updated(entity)
signal entity_moved(entity, old_zone, new_zone)
signal processing_completed(processed_count)
signal entity_limit_reached(current_count)

func _init() -> void:
    if _instance == null:
        _instance = self
        name = "JSHEntityManager"
        print("JSHEntityManager: Initialized")

func _process(delta: float) -> void:
    if auto_process:
        process_entity_batch()

# Entity creation and registration
func create_entity(type: String = "primordial", properties: Dictionary = {}) -> JSHUniversalEntity:
    # Check if we're at the entity limit
    if entities.size() >= max_entities:
        print("JSHEntityManager: Entity limit reached (" + str(max_entities) + ")")
        emit_signal("entity_limit_reached", entities.size())
        return null
    
    # Create the entity
    var entity = JSHUniversalEntity.new("", type, properties)
    
    # Register the entity
    register_entity(entity)
    
    # Emit signal
    emit_signal("entity_created", entity)
    
    print("JSHEntityManager: Created entity of type " + type + " with ID " + entity.get_id())
    return entity

func register_entity(entity: JSHUniversalEntity) -> bool:
    if entity == null:
        print("JSHEntityManager: Cannot register null entity")
        return false
    
    var entity_id = entity.get_id()
    
    # Check if already registered
    if entities.has(entity_id):
        print("JSHEntityManager: Entity already registered: " + entity_id)
        return false
    
    # Add to main entity dictionary
    entities[entity_id] = entity
    
    # Register by type
    var entity_type = entity.get_type()
    if not entities_by_type.has(entity_type):
        entities_by_type[entity_type] = []
    entities_by_type[entity_type].append(entity_id)
    
    # Register by tags
    for tag in entity.get_tags():
        if not entities_by_tag.has(tag):
            entities_by_tag[tag] = []
        entities_by_tag[tag].append(entity_id)
    
    # Register by zones
    for zone_id in entity.get_zones():
        if not entities_by_zone.has(zone_id):
            entities_by_zone[zone_id] = []
        entities_by_zone[zone_id].append(entity_id)
    
    # Connect signals
    entity.connect("transformed", Callable(self, "_on_entity_transformed").bind(entity))
    entity.connect("property_changed", Callable(self, "_on_entity_property_changed").bind(entity))
    entity.connect("complexity_changed", Callable(self, "_on_entity_complexity_changed").bind(entity))
    entity.connect("evolution_stage_changed", Callable(self, "_on_entity_evolution_stage_changed").bind(entity))
    entity.connect("entity_split", Callable(self, "_on_entity_split").bind(entity))
    
    # Add to process queue
    add_to_process_queue(entity_id)
    
    return true

func unregister_entity(entity_id: String) -> bool:
    if not entities.has(entity_id):
        print("JSHEntityManager: Cannot unregister non-existent entity: " + entity_id)
        return false
    
    var entity = entities[entity_id]
    
    # Disconnect signals
    if entity.is_connected("transformed", Callable(self, "_on_entity_transformed")):
        entity.disconnect("transformed", Callable(self, "_on_entity_transformed"))
    
    if entity.is_connected("property_changed", Callable(self, "_on_entity_property_changed")):
        entity.disconnect("property_changed", Callable(self, "_on_entity_property_changed"))
    
    if entity.is_connected("complexity_changed", Callable(self, "_on_entity_complexity_changed")):
        entity.disconnect("complexity_changed", Callable(self, "_on_entity_complexity_changed"))
    
    if entity.is_connected("evolution_stage_changed", Callable(self, "_on_entity_evolution_stage_changed")):
        entity.disconnect("evolution_stage_changed", Callable(self, "_on_entity_evolution_stage_changed"))
    
    if entity.is_connected("entity_split", Callable(self, "_on_entity_split")):
        entity.disconnect("entity_split", Callable(self, "_on_entity_split"))
    
    # Unregister from type dictionary
    var entity_type = entity.get_type()
    if entities_by_type.has(entity_type):
        var index = entities_by_type[entity_type].find(entity_id)
        if index >= 0:
            entities_by_type[entity_type].remove_at(index)
    
    # Unregister from tag dictionaries
    for tag in entity.get_tags():
        if entities_by_tag.has(tag):
            var index = entities_by_tag[tag].find(entity_id)
            if index >= 0:
                entities_by_tag[tag].remove_at(index)
    
    # Unregister from zone dictionaries
    for zone_id in entity.get_zones():
        if entities_by_zone.has(zone_id):
            var index = entities_by_zone[zone_id].find(entity_id)
            if index >= 0:
                entities_by_zone[zone_id].remove_at(index)
    
    # Remove from process queue
    var queue_index = process_queue.find(entity_id)
    if queue_index >= 0:
        process_queue.remove_at(queue_index)
    
    # Remove from main dictionary
    entities.erase(entity_id)
    
    # Emit signal
    emit_signal("entity_destroyed", entity_id)
    
    print("JSHEntityManager: Unregistered entity: " + entity_id)
    return true

# Entity processing
func add_to_process_queue(entity_id: String) -> void:
    if not entities.has(entity_id):
        return
    
    if not entity_id in process_queue:
        process_queue.append(entity_id)

func process_entity_batch() -> int:
    var current_time = Time.get_ticks_msec()
    
    # Only process if enough time has passed
    if current_time - last_process_time < process_interval_ms:
        return 0
    
    last_process_time = current_time
    
    var processed_count = 0
    var batch_size = min(process_batch_size, process_queue.size())
    
    for i in range(batch_size):
        if process_queue.size() == 0:
            break
        
        # Get entity to process
        var entity_id = process_queue[0]
        process_queue.remove_at(0)
        
        # Process the entity
        if entities.has(entity_id):
            var entity = entities[entity_id]
            entity.process(0.0)  # Delta is handled internally in the entity
            
            # Check if entity wants to split
            if entity.should_split:
                handle_entity_split(entity)
            
            # Add back to end of queue for next cycle
            process_queue.append(entity_id)
            
            processed_count += 1
        
    # Emit signal if we processed any entities
    if processed_count > 0:
        emit_signal("processing_completed", processed_count)
    
    return processed_count

# Entity transformation handling
func handle_entity_split(entity: JSHUniversalEntity) -> void:
    # Attempt to split the entity
    var new_entities = entity.attempt_split()
    
    if new_entities.size() > 0:
        print("JSHEntityManager: Entity " + entity.get_id() + " split into " + str(new_entities.size()) + " new entities")
        
        # Register new entities
        for new_entity in new_entities:
            register_entity(new_entity)
        
        # Emit signal
        emit_signal("entity_split", entity, new_entities)
    
    # Update the parent entity
    emit_signal("entity_updated", entity)

func merge_entities(entity_ids: Array) -> JSHUniversalEntity:
    if entity_ids.size() < 2:
        print("JSHEntityManager: Need at least 2 entities to merge")
        return null
    
    # Get entity objects from IDs
    var entities_to_merge = []
    for id in entity_ids:
        if entities.has(id):
            entities_to_merge.append(entities[id])
    
    if entities_to_merge.size() < 2:
        print("JSHEntityManager: Not enough valid entities to merge")
        return null
    
    # Perform the merge
    var merged_entity = JSHUniversalEntity.merge_entities(entities_to_merge)
    
    if merged_entity:
        # Register the new entity
        register_entity(merged_entity)
        
        # Emit signal
        emit_signal("entity_merged", entities_to_merge, merged_entity)
        
        print("JSHEntityManager: Merged " + str(entities_to_merge.size()) + " entities into " + merged_entity.get_id())
    
    return merged_entity

# Zone management
func add_entity_to_zone(entity_id: String, zone_id: String) -> bool:
    if not entities.has(entity_id):
        print("JSHEntityManager: Cannot add non-existent entity to zone: " + entity_id)
        return false
    
    var entity = entities[entity_id]
    
    # Check if already in this zone
    if zone_id in entity.get_zones():
        return true
    
    # Check zone entity limit
    if entities_by_zone.has(zone_id) and entities_by_zone[zone_id].size() >= max_entities_per_zone:
        print("JSHEntityManager: Zone entity limit reached for zone: " + zone_id)
        return false
    
    # Track old zones for signal
    var old_zones = entity.get_zones()
    
    # Add entity to zone
    if entity.add_to_zone(zone_id):
        # Update zone tracking
        if not entities_by_zone.has(zone_id):
            entities_by_zone[zone_id] = []
        entities_by_zone[zone_id].append(entity_id)
        
        # Emit signal
        emit_signal("entity_moved", entity, old_zones, entity.get_zones())
        emit_signal("entity_updated", entity)
        
        return true
    
    return false

func remove_entity_from_zone(entity_id: String, zone_id: String) -> bool:
    if not entities.has(entity_id):
        print("JSHEntityManager: Cannot remove non-existent entity from zone: " + entity_id)
        return false
    
    var entity = entities[entity_id]
    
    # Check if in this zone
    if not zone_id in entity.get_zones():
        return false
    
    # Track old zones for signal
    var old_zones = entity.get_zones()
    
    # Remove entity from zone
    if entity.remove_from_zone(zone_id):
        # Update zone tracking
        if entities_by_zone.has(zone_id):
            var index = entities_by_zone[zone_id].find(entity_id)
            if index >= 0:
                entities_by_zone[zone_id].remove_at(index)
        
        # Emit signal
        emit_signal("entity_moved", entity, old_zones, entity.get_zones())
        emit_signal("entity_updated", entity)
        
        return true
    
    return false

# Entity retrieval methods
func get_entity(entity_id: String) -> JSHUniversalEntity:
    if entities.has(entity_id):
        return entities[entity_id]
    return null

func get_entities_by_type(type: String) -> Array:
    var result = []
    
    if entities_by_type.has(type):
        for id in entities_by_type[type]:
            if entities.has(id):
                result.append(entities[id])
    
    return result

func get_entities_by_tag(tag: String) -> Array:
    var result = []
    
    if entities_by_tag.has(tag):
        for id in entities_by_tag[tag]:
            if entities.has(id):
                result.append(entities[id])
    
    return result

func get_entities_in_zone(zone_id: String) -> Array:
    var result = []
    
    if entities_by_zone.has(zone_id):
        for id in entities_by_zone[zone_id]:
            if entities.has(id):
                result.append(entities[id])
    
    return result

func find_entities(criteria: Dictionary) -> Array:
    var result = []
    var candidate_ids = []
    
    # Start with all entities or a subset based on a primary criterion
    if criteria.has("type"):
        if entities_by_type.has(criteria.type):
            candidate_ids = entities_by_type[criteria.type].duplicate()
        else:
            return []  # No entities of this type
    elif criteria.has("tag"):
        if entities_by_tag.has(criteria.tag):
            candidate_ids = entities_by_tag[criteria.tag].duplicate()
        else:
            return []  # No entities with this tag
    elif criteria.has("zone"):
        if entities_by_zone.has(criteria.zone):
            candidate_ids = entities_by_zone[criteria.zone].duplicate()
        else:
            return []  # No entities in this zone
    else:
        candidate_ids = entities.keys()
    
    # Filter based on additional criteria
    for id in candidate_ids:
        if not entities.has(id):
            continue
            
        var entity = entities[id]
        var matches = true
        
        # Check each criterion
        for key in criteria:
            match key:
                "type":
                    if entity.get_type() != criteria.type:
                        matches = false
                        break
                "tag":
                    if not criteria.tag in entity.get_tags():
                        matches = false
                        break
                "zone":
                    if not criteria.zone in entity.get_zones():
                        matches = false
                        break
                "min_complexity":
                    if entity.complexity < criteria.min_complexity:
                        matches = false
                        break
                "max_complexity":
                    if entity.complexity > criteria.max_complexity:
                        matches = false
                        break
                "evolution_stage":
                    if entity.evolution_stage != criteria.evolution_stage:
                        matches = false
                        break
                "min_evolution_stage":
                    if entity.evolution_stage < criteria.min_evolution_stage:
                        matches = false
                        break
                "property":
                    if not criteria.has("property_value"):
                        continue
                    if entity.get_property(criteria.property) != criteria.property_value:
                        matches = false
                        break
                "property_exists":
                    if not entity.properties.has(criteria.property_exists):
                        matches = false
                        break
        
        if matches:
            result.append(entity)
    
    return result

# Signal handlers
func _on_entity_transformed(old_type: String, new_type: String, entity: JSHUniversalEntity) -> void:
    # Update type registration
    if entities_by_type.has(old_type):
        var old_index = entities_by_type[old_type].find(entity.get_id())
        if old_index >= 0:
            entities_by_type[old_type].remove_at(old_index)
    
    if not entities_by_type.has(new_type):
        entities_by_type[new_type] = []
    entities_by_type[new_type].append(entity.get_id())
    
    # Update entity processing priority
    add_to_process_queue(entity.get_id())
    
    # Emit signal
    emit_signal("entity_updated", entity)

func _on_entity_property_changed(property_name: String, old_value, new_value, entity: JSHUniversalEntity) -> void:
    # Emit signal
    emit_signal("entity_updated", entity)

func _on_entity_complexity_changed(old_value: float, new_value: float, entity: JSHUniversalEntity) -> void:
    # If complexity goes over threshold, prioritize processing
    if new_value > JSHUniversalEntity.COMPLEXITY_THRESHOLD_HIGH:
        add_to_process_queue(entity.get_id())
    
    # Emit signal
    emit_signal("entity_updated", entity)

func _on_entity_evolution_stage_changed(old_stage: int, new_stage: int, entity: JSHUniversalEntity) -> void:
    # Higher evolution stages get processing priority
    if new_stage > old_stage:
        add_to_process_queue(entity.get_id())
    
    # Emit signal
    emit_signal("entity_updated", entity)

func _on_entity_split(original_entity: JSHUniversalEntity, new_entities: Array, entity: JSHUniversalEntity) -> void:
    # Already handled in handle_entity_split
    pass

# Statistics and debug information
func get_statistics() -> Dictionary:
    var stats = {
        "total_entities": entities.size(),
        "by_type": {},
        "by_tag": {},
        "by_zone": {},
        "by_evolution_stage": {
            "0": 0,
            "1": 0,
            "2": 0,
            "3": 0
        },
        "process_queue_size": process_queue.size(),
        "highest_complexity": 0.0,
        "average_complexity": 0.0
    }
    
    # Count by type
    for type in entities_by_type:
        stats.by_type[type] = entities_by_type[type].size()
    
    # Count by tag
    for tag in entities_by_tag:
        stats.by_tag[tag] = entities_by_tag[tag].size()
    
    # Count by zone
    for zone in entities_by_zone:
        stats.by_zone[zone] = entities_by_zone[zone].size()
    
    # Calculate complexity stats and count by evolution stage
    var total_complexity = 0.0
    for id in entities:
        var entity = entities[id]
        total_complexity += entity.complexity
        
        if entity.complexity > stats.highest_complexity:
            stats.highest_complexity = entity.complexity
        
        var stage_key = str(entity.evolution_stage)
        if stats.by_evolution_stage.has(stage_key):
            stats.by_evolution_stage[stage_key] += 1
    
    if entities.size() > 0:
        stats.average_complexity = total_complexity / entities.size()
    
    return stats
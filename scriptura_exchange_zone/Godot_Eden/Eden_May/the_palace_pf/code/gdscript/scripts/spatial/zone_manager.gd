extends Node
class_name ZoneManager

# Dictionary of all zones
var zones: Dictionary = {}

# Signals
signal zone_created(zone_id)
signal zone_updated(zone_id)
signal zone_removed(zone_id)
signal entity_added_to_zone(entity_id, zone_id)
signal entity_removed_from_zone(entity_id, zone_id)

# Singleton instance
static var _instance = null

static func get_instance() -> ZoneManager:
    if _instance == null:
        _instance = ZoneManager.new()
    return _instance

func _init() -> void:
    # Only create if this is not the singleton
    if _instance == null:
        _instance = self
    
    # Create default zone
    if not zones.has("default"):
        create_zone("default", "Default Zone", {
            "min_x": -1000, "max_x": 1000,
            "min_y": -1000, "max_y": 1000,
            "min_z": -1000, "max_z": 1000
        })

# Creates a new zone with given ID and boundaries
func create_zone(zone_id: String, zone_name: String, boundaries: Dictionary, properties: Dictionary = {}) -> bool:
    if zones.has(zone_id):
        print("ZoneManager: Zone already exists: ", zone_id)
        return false
    
    zones[zone_id] = {
        "id": zone_id,
        "name": zone_name,
        "entities": [],
        "boundaries": boundaries,
        "properties": properties
    }
    
    emit_signal("zone_created", zone_id)
    print("ZoneManager: Created zone: ", zone_id)
    return true

# Updates an existing zone's properties
func update_zone(zone_id: String, zone_name: String = "", boundaries: Dictionary = {}, properties: Dictionary = {}) -> bool:
    if not zones.has(zone_id):
        print("ZoneManager: Cannot update non-existent zone: ", zone_id)
        return false
    
    if not zone_name.empty():
        zones[zone_id]["name"] = zone_name
    
    if not boundaries.is_empty():
        zones[zone_id]["boundaries"] = boundaries
    
    if not properties.is_empty():
        # Merge properties
        for key in properties:
            zones[zone_id]["properties"][key] = properties[key]
    
    emit_signal("zone_updated", zone_id)
    print("ZoneManager: Updated zone: ", zone_id)
    return true

# Removes a zone
func remove_zone(zone_id: String) -> bool:
    if not zones.has(zone_id) or zone_id == "default":
        print("ZoneManager: Cannot remove default or non-existent zone: ", zone_id)
        return false
    
    zones.erase(zone_id)
    emit_signal("zone_removed", zone_id)
    print("ZoneManager: Removed zone: ", zone_id)
    return true

# Adds an entity to a zone
func add_entity_to_zone(entity_id: String, zone_id: String) -> bool:
    if not zones.has(zone_id):
        print("ZoneManager: Cannot add entity to non-existent zone: ", zone_id)
        return false
    
    # Check if entity is already in the zone
    if entity_id in zones[zone_id]["entities"]:
        print("ZoneManager: Entity already in zone: ", entity_id, " in ", zone_id)
        return true
    
    # Check if entity is in another zone
    for z_id in zones:
        var entity_index = zones[z_id]["entities"].find(entity_id)
        if entity_index >= 0:
            # Remove from current zone
            zones[z_id]["entities"].remove_at(entity_index)
            emit_signal("entity_removed_from_zone", entity_id, z_id)
    
    # Add to new zone
    zones[zone_id]["entities"].append(entity_id)
    emit_signal("entity_added_to_zone", entity_id, zone_id)
    emit_signal("zone_updated", zone_id)
    
    print("ZoneManager: Added entity ", entity_id, " to zone ", zone_id)
    return true

# Removes an entity from a zone
func remove_entity_from_zone(entity_id: String, zone_id: String) -> bool:
    if not zones.has(zone_id):
        print("ZoneManager: Cannot remove entity from non-existent zone: ", zone_id)
        return false
    
    var entity_index = zones[zone_id]["entities"].find(entity_id)
    if entity_index < 0:
        print("ZoneManager: Entity not in zone: ", entity_id, " in ", zone_id)
        return false
    
    zones[zone_id]["entities"].remove_at(entity_index)
    emit_signal("entity_removed_from_zone", entity_id, zone_id)
    emit_signal("zone_updated", zone_id)
    
    print("ZoneManager: Removed entity ", entity_id, " from zone ", zone_id)
    return true

# Gets the zone of an entity
func get_entity_zone(entity_id: String) -> String:
    for zone_id in zones:
        if entity_id in zones[zone_id]["entities"]:
            return zone_id
    return ""

# Gets all entities in a zone
func get_entities_in_zone(zone_id: String) -> Array:
    if not zones.has(zone_id):
        return []
    return zones[zone_id]["entities"].duplicate()

# Gets a zone by ID
func get_zone(zone_id: String) -> Dictionary:
    if not zones.has(zone_id):
        return {}
    return zones[zone_id].duplicate()

# Gets all zones
func get_all_zones() -> Array:
    return zones.keys()

# Checks if a position is within a zone's boundaries
func is_position_in_zone(position: Vector3, zone_id: String) -> bool:
    if not zones.has(zone_id):
        return false
    
    var boundaries = zones[zone_id]["boundaries"]
    
    return (
        position.x >= boundaries["min_x"] and position.x <= boundaries["max_x"] and
        position.y >= boundaries["min_y"] and position.y <= boundaries["max_y"] and
        position.z >= boundaries["min_z"] and position.z <= boundaries["max_z"]
    )

# Finds the zone containing a position
func find_zone_for_position(position: Vector3) -> String:
    for zone_id in zones:
        if is_position_in_zone(position, zone_id):
            return zone_id
    return "default"  # Default zone is the fallback
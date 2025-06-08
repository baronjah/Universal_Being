extends Node
class_name JSHSpatialManager

# Singleton pattern
static var _instance: JSHSpatialManager = null

static func get_instance() -> JSHSpatialManager:
    if not _instance:
        _instance = JSHSpatialManager.new()
    return _instance

# Systems references
var entity_manager: JSHEntityManager = null
var database_manager: JSHDatabaseManager = null

# Zone tracking
var zones: Dictionary = {}
var zone_hierarchy: Dictionary = {}  # parent-child relationships
var zone_entities: Dictionary = {}
var zone_transitions: Dictionary = {}

# Entity position tracking
var entity_positions: Dictionary = {}
var entities_by_position: Dictionary = {}  # Spatial hash grid for quick lookups

# Spatial partitioning
var spatial_grid: JSHSpatialGrid = null
var spatial_tree: JSHOctree = null

# Active zones and visibility
var active_zone: String = ""
var visible_zones: Array = []
var culling_enabled: bool = true
var culling_distance: float = 1000.0

# Zone loading/unloading
var auto_load_zones: bool = true
var zone_load_distance: float = 500.0
var load_in_progress: bool = false
var pending_zone_loads: Array = []

# Statistics and performance
var stats: Dictionary = {
    "total_zones": 0,
    "loaded_zones": 0,
    "visible_entities": 0,
    "entity_positions": 0,
    "spatial_queries": 0,
    "zone_transitions": 0
}

# Signals
signal zone_created(zone_id, zone_data)
signal zone_updated(zone_id, zone_data)
signal zone_deleted(zone_id)
signal zone_loaded(zone_id)
signal zone_unloaded(zone_id)
signal entity_moved(entity_id, old_position, new_position)
signal entity_added_to_zone(entity_id, zone_id)
signal entity_removed_from_zone(entity_id, zone_id)
signal entity_transitioned(entity_id, source_zone, target_zone)
signal active_zone_changed(old_zone, new_zone)

func _init() -> void:
    if _instance == null:
        _instance = self
        name = "JSHSpatialManager"
        print("JSHSpatialManager: Instance created")

func _ready() -> void:
    # Initialize spatial partitioning
    spatial_grid = JSHSpatialGrid.new()
    add_child(spatial_grid)
    
    spatial_tree = JSHOctree.new()
    add_child(spatial_tree)
    
    # Connect to entity and database managers
    entity_manager = JSHEntityManager.get_instance()
    if entity_manager:
        print("JSHSpatialManager: Connected to EntityManager")
        entity_manager.connect("entity_created", Callable(self, "_on_entity_created"))
        entity_manager.connect("entity_destroyed", Callable(self, "_on_entity_destroyed"))
        entity_manager.connect("entity_updated", Callable(self, "_on_entity_updated"))
    
    database_manager = JSHDatabaseManager.get_instance()
    if database_manager:
        print("JSHSpatialManager: Connected to DatabaseManager")
    
    # Create default zone if it doesn't exist
    if not zone_exists("default"):
        create_zone("default", {
            "name": "Default Zone",
            "bounds": {
                "min_x": -1000, "max_x": 1000,
                "min_y": -1000, "max_y": 1000,
                "min_z": -1000, "max_z": 1000
            },
            "is_root": true,
            "level": 0,
            "autoload": true
        })
        
        set_active_zone("default")

func _process(delta: float) -> void:
    # Process pending zone loads
    _process_pending_zone_loads()
    
    # Update visibility based on active zone
    if auto_load_zones and not active_zone.is_empty():
        _update_zone_visibility(delta)

# Zone operations
func create_zone(zone_id: String, zone_data: Dictionary) -> bool:
    print("JSHSpatialManager: Creating zone " + zone_id)
    
    # Ensure required fields
    if not zone_data.has("bounds"):
        zone_data.bounds = {
            "min_x": -100, "max_x": 100,
            "min_y": -100, "max_y": 100,
            "min_z": -100, "max_z": 100
        }
    
    if not zone_data.has("name"):
        zone_data.name = zone_id
    
    if not zone_data.has("level"):
        zone_data.level = 0
    
    if not zone_data.has("parent_zone"):
        zone_data.parent_zone = ""
    
    if not zone_data.has("is_root"):
        zone_data.is_root = zone_data.parent_zone.is_empty()
    
    if not zone_data.has("autoload"):
        zone_data.autoload = false
    
    if not zone_data.has("properties"):
        zone_data.properties = {}
    
    # Add to zones dictionary
    zones[zone_id] = zone_data
    
    # Add to zone hierarchy
    if zone_data.is_root:
        zone_hierarchy[zone_id] = {
            "parent": "",
            "children": []
        }
    else:
        var parent_zone = zone_data.parent_zone
        
        # Add to parent's children list
        if not zone_hierarchy.has(parent_zone):
            zone_hierarchy[parent_zone] = {
                "parent": "",
                "children": []
            }
        
        zone_hierarchy[parent_zone].children.append(zone_id)
        
        # Set parent for this zone
        zone_hierarchy[zone_id] = {
            "parent": parent_zone,
            "children": []
        }
    
    # Initialize entity tracking for this zone
    zone_entities[zone_id] = []
    
    # Add to spatial partitioning
    var bounds = _get_zone_bounds(zone_data.bounds)
    spatial_tree.insert_zone(zone_id, bounds)
    
    # Save to database if available
    if database_manager:
        database_manager.save_zone(zone_id, zone_data)
    
    # Update statistics
    stats.total_zones += 1
    
    # Emit signal
    emit_signal("zone_created", zone_id, zone_data)
    
    return true

func delete_zone(zone_id: String) -> bool:
    if not zones.has(zone_id) or zone_id == "default":
        return false
    
    print("JSHSpatialManager: Deleting zone " + zone_id)
    
    # Handle any entities in this zone
    if zone_entities.has(zone_id):
        var entities = zone_entities[zone_id].duplicate()
        for entity_id in entities:
            remove_entity_from_zone(entity_id, zone_id)
    
    # Update hierarchy
    if zone_hierarchy.has(zone_id):
        var hierarchy = zone_hierarchy[zone_id]
        
        # Remove from parent's children list
        if not hierarchy.parent.is_empty() and zone_hierarchy.has(hierarchy.parent):
            var parent_children = zone_hierarchy[hierarchy.parent].children
            var index = parent_children.find(zone_id)
            if index >= 0:
                parent_children.remove_at(index)
        
        # Reassign children to parent
        var parent = hierarchy.parent
        for child in hierarchy.children:
            if zone_hierarchy.has(child):
                zone_hierarchy[child].parent = parent
                
                if not parent.is_empty() and zone_hierarchy.has(parent):
                    zone_hierarchy[parent].children.append(child)
        
        # Remove from hierarchy
        zone_hierarchy.erase(zone_id)
    }
    
    # Remove from spatial partitioning
    spatial_tree.remove_zone(zone_id)
    
    # Remove from zones list
    zones.erase(zone_id)
    
    # Remove from entity tracking
    zone_entities.erase(zone_id)
    
    # Remove from transitions
    if zone_transitions.has(zone_id):
        zone_transitions.erase(zone_id)
    
    # Remove from visible zones if present
    var index = visible_zones.find(zone_id)
    if index >= 0:
        visible_zones.remove_at(index)
    
    # If this was the active zone, set default
    if active_zone == zone_id:
        set_active_zone("default")
    
    # Delete from database if available
    if database_manager:
        database_manager.delete_zone(zone_id)
    
    # Update statistics
    stats.total_zones -= 1
    if stats.loaded_zones > 0:
        stats.loaded_zones -= 1
    
    # Emit signal
    emit_signal("zone_deleted", zone_id)
    
    return true

func update_zone(zone_id: String, zone_data: Dictionary) -> bool:
    if not zones.has(zone_id):
        return false
    
    print("JSHSpatialManager: Updating zone " + zone_id)
    
    # Update zone data
    var original_data = zones[zone_id]
    for key in zone_data:
        original_data[key] = zone_data[key]
    
    # Check if bounds changed, if so update spatial partitioning
    if zone_data.has("bounds"):
        var bounds = _get_zone_bounds(zone_data.bounds)
        spatial_tree.update_zone(zone_id, bounds)
    
    # Check for parent zone changes
    if zone_data.has("parent_zone") and zone_hierarchy.has(zone_id):
        var old_parent = zone_hierarchy[zone_id].parent
        var new_parent = zone_data.parent_zone
        
        if old_parent != new_parent:
            # Remove from old parent's children
            if not old_parent.is_empty() and zone_hierarchy.has(old_parent):
                var old_parent_children = zone_hierarchy[old_parent].children
                var index = old_parent_children.find(zone_id)
                if index >= 0:
                    old_parent_children.remove_at(index)
            
            # Add to new parent's children
            if not new_parent.is_empty():
                if not zone_hierarchy.has(new_parent):
                    zone_hierarchy[new_parent] = {
                        "parent": "",
                        "children": []
                    }
                
                zone_hierarchy[new_parent].children.append(zone_id)
            
            # Update zone's parent
            zone_hierarchy[zone_id].parent = new_parent
        }
    }
    
    # Save to database if available
    if database_manager:
        database_manager.save_zone(zone_id, zones[zone_id])
    
    # Emit signal
    emit_signal("zone_updated", zone_id, zones[zone_id])
    
    return true

func zone_exists(zone_id: String) -> bool:
    return zones.has(zone_id)

func get_zone(zone_id: String) -> Dictionary:
    if zones.has(zone_id):
        return zones[zone_id].duplicate()
    return {}

func get_all_zones() -> Array:
    return zones.keys()

func get_zones_in_radius(position: Vector3, radius: float) -> Array:
    var result = []
    
    # Use octree for efficient zone lookup
    var candidate_zones = spatial_tree.query_sphere(position, radius)
    
    # Verify each zone actually contains the point
    for zone_id in candidate_zones:
        if zone_contains_point(zone_id, position, radius):
            result.append(zone_id)
    
    return result

func get_zones_in_box(min_bounds: Vector3, max_bounds: Vector3) -> Array:
    # Use octree for efficient zone lookup
    return spatial_tree.query_box(min_bounds, max_bounds)

func zone_contains_point(zone_id: String, position: Vector3, buffer: float = 0.0) -> bool:
    if not zones.has(zone_id):
        return false
    
    var bounds = zones[zone_id].bounds
    
    return (
        position.x >= bounds.min_x - buffer and position.x <= bounds.max_x + buffer and
        position.y >= bounds.min_y - buffer and position.y <= bounds.max_y + buffer and
        position.z >= bounds.min_z - buffer and position.z <= bounds.max_z + buffer
    )

# Entity zone management
func add_entity_to_zone(entity_id: String, zone_id: String) -> bool:
    if not zones.has(zone_id):
        print("JSHSpatialManager: Zone does not exist: " + zone_id)
        return false
    
    if not entity_manager or not entity_manager.get_entity(entity_id):
        print("JSHSpatialManager: Entity does not exist: " + entity_id)
        return false
    
    print("JSHSpatialManager: Adding entity " + entity_id + " to zone " + zone_id)
    
    # Check if already in this zone
    if zone_entities.has(zone_id) and entity_id in zone_entities[zone_id]:
        return true  # Already in this zone
    
    # Add to zone entities
    if not zone_entities.has(zone_id):
        zone_entities[zone_id] = []
    
    zone_entities[zone_id].append(entity_id)
    
    # Update entity's zone list
    var entity = entity_manager.get_entity(entity_id)
    if entity:
        entity.add_to_zone(zone_id)
    
    # Add to spatial grid if position is known
    if entity_positions.has(entity_id):
        var position = entity_positions[entity_id]
        spatial_grid.insert_entity(entity_id, position, zone_id)
    
    # Emit signal
    emit_signal("entity_added_to_zone", entity_id, zone_id)
    
    return true

func remove_entity_from_zone(entity_id: String, zone_id: String) -> bool:
    if not zone_entities.has(zone_id):
        return false
    
    print("JSHSpatialManager: Removing entity " + entity_id + " from zone " + zone_id)
    
    # Remove from zone entities
    var index = zone_entities[zone_id].find(entity_id)
    if index >= 0:
        zone_entities[zone_id].remove_at(index)
    else:
        return false  # Not in this zone
    
    # Update entity's zone list
    var entity = entity_manager.get_entity(entity_id)
    if entity:
        entity.remove_from_zone(zone_id)
    
    # Remove from spatial grid
    spatial_grid.remove_entity(entity_id, zone_id)
    
    # Emit signal
    emit_signal("entity_removed_from_zone", entity_id, zone_id)
    
    return true

func get_entity_zones(entity_id: String) -> Array:
    var result = []
    
    var entity = entity_manager.get_entity(entity_id)
    if entity:
        return entity.get_zones()
    
    # Fallback to scanning all zones
    for zone_id in zone_entities:
        if entity_id in zone_entities[zone_id]:
            result.append(zone_id)
    
    return result

func get_entities_in_zone(zone_id: String) -> Array:
    if zone_entities.has(zone_id):
        var entity_ids = zone_entities[zone_id]
        var entities = []
        
        for id in entity_ids:
            var entity = entity_manager.get_entity(id)
            if entity:
                entities.append(entity)
        
        return entities
    
    return []

# Entity position management
func set_entity_position(entity_id: String, position: Vector3) -> bool:
    print("JSHSpatialManager: Setting entity " + entity_id + " position to " + str(position))
    
    var old_position = Vector3.ZERO
    if entity_positions.has(entity_id):
        old_position = entity_positions[entity_id]
    
    # Update position
    entity_positions[entity_id] = position
    
    # Update spatial partitioning
    var zones = get_entity_zones(entity_id)
    for zone_id in zones:
        spatial_grid.update_entity(entity_id, position, zone_id)
    
    # Update entity metadata
    var entity = entity_manager.get_entity(entity_id)
    if entity:
        entity.set_metadata("position", {
            "x": position.x,
            "y": position.y,
            "z": position.z
        })
    
    # Emit signal
    emit_signal("entity_moved", entity_id, old_position, position)
    
    # Update statistics
    if not entity_positions.has(entity_id):
        stats.entity_positions += 1
    
    return true

func get_entity_position(entity_id: String) -> Vector3:
    if entity_positions.has(entity_id):
        return entity_positions[entity_id]
    
    # Try to get from entity metadata
    var entity = entity_manager.get_entity(entity_id)
    if entity:
        var pos_data = entity.get_metadata("position")
        if pos_data and pos_data.has("x") and pos_data.has("y") and pos_data.has("z"):
            var position = Vector3(pos_data.x, pos_data.y, pos_data.z)
            
            # Update our cache
            entity_positions[entity_id] = position
            
            return position
    
    return Vector3.ZERO

func move_entity(entity_id: String, new_position: Vector3) -> bool:
    # Get current zones
    var current_zones = get_entity_zones(entity_id)
    
    # Set the new position
    if not set_entity_position(entity_id, new_position):
        return false
    
    # Check if moved to a new zone
    var zones_at_new_pos = get_zones_containing_point(new_position)
    
    # Determine zones to add to and remove from
    for zone_id in zones_at_new_pos:
        if not zone_id in current_zones:
            add_entity_to_zone(entity_id, zone_id)
    
    return true

func get_zones_containing_point(position: Vector3) -> Array:
    var result = []
    
    # Use octree for efficient zone lookup
    var candidate_zones = spatial_tree.query_point(position)
    
    # Verify each zone actually contains the point
    for zone_id in candidate_zones:
        if zone_contains_point(zone_id, position):
            result.append(zone_id)
    
    # If no zones found, use default
    if result.is_empty() and zones.has("default"):
        result.append("default")
    
    return result

# Spatial queries
func get_entities_in_radius(position: Vector3, radius: float, filter: Dictionary = {}) -> Array:
    stats.spatial_queries += 1
    
    var result = []
    
    # Use spatial grid for efficient entity lookup
    var entity_ids = spatial_grid.query_sphere(position, radius)
    
    # Filter entities
    for entity_id in entity_ids:
        var entity = entity_manager.get_entity(entity_id)
        if not entity:
            continue
        
        var matches = true
        
        # Filter by type
        if filter.has("type") and entity.get_type() != filter.type:
            matches = false
        
        # Filter by tag
        if filter.has("tag") and not entity.has_tag(filter.tag):
            matches = false
        
        # Filter by zone
        if filter.has("zone"):
            var entity_zones = entity.get_zones()
            if not filter.zone in entity_zones:
                matches = false
        
        # Filter by custom property
        if filter.has("property") and filter.has("property_value"):
            if entity.get_property(filter.property) != filter.property_value:
                matches = false
        
        if matches:
            result.append(entity)
    
    return result

func get_entities_in_box(min_bounds: Vector3, max_bounds: Vector3, filter: Dictionary = {}) -> Array:
    stats.spatial_queries += 1
    
    var result = []
    
    # Use spatial grid for efficient entity lookup
    var entity_ids = spatial_grid.query_box(min_bounds, max_bounds)
    
    # Filter entities
    for entity_id in entity_ids:
        var entity = entity_manager.get_entity(entity_id)
        if not entity:
            continue
        
        var matches = true
        
        # Filter by type
        if filter.has("type") and entity.get_type() != filter.type:
            matches = false
        
        # Filter by tag
        if filter.has("tag") and not entity.has_tag(filter.tag):
            matches = false
        
        # Filter by zone
        if filter.has("zone"):
            var entity_zones = entity.get_zones()
            if not filter.zone in entity_zones:
                matches = false
        
        # Filter by custom property
        if filter.has("property") and filter.has("property_value"):
            if entity.get_property(filter.property) != filter.property_value:
                matches = false
        
        if matches:
            result.append(entity)
    
    return result

func get_nearest_entities(position: Vector3, count: int, max_distance: float = -1, filter: Dictionary = {}) -> Array:
    stats.spatial_queries += 1
    
    var candidates = []
    
    # Get entities within radius
    if max_distance > 0:
        candidates = get_entities_in_radius(position, max_distance, filter)
    else:
        # Use a large radius if none specified
        candidates = get_entities_in_radius(position, 10000.0, filter)
    
    # Sort by distance
    candidates.sort_custom(func(a, b):
        var pos_a = get_entity_position(a.get_id())
        var pos_b = get_entity_position(b.get_id())
        var dist_a = position.distance_to(pos_a)
        var dist_b = position.distance_to(pos_b)
        return dist_a < dist_b
    )
    
    # Return requested count
    if candidates.size() <= count:
        return candidates
    else:
        return candidates.slice(0, count)

func cast_ray(start: Vector3, end: Vector3, filter: Dictionary = {}) -> Dictionary:
    stats.spatial_queries += 1
    
    var result = {
        "hit": false,
        "entity": null,
        "position": Vector3.ZERO,
        "normal": Vector3.ZERO,
        "distance": 0.0
    }
    
    # Calculate ray direction and length
    var direction = end - start
    var length = direction.length()
    if length > 0:
        direction /= length
    else:
        return result
    
    # Find all potential entities along ray path
    var ray_box_min = Vector3(
        min(start.x, end.x),
        min(start.y, end.y),
        min(start.z, end.z)
    )
    
    var ray_box_max = Vector3(
        max(start.x, end.x),
        max(start.y, end.y),
        max(start.z, end.z)
    )
    
    var candidates = get_entities_in_box(ray_box_min, ray_box_max, filter)
    
    var closest_hit = null
    var closest_distance = length
    
    # Loop through entities to find ray intersection
    for entity in candidates:
        var entity_id = entity.get_id()
        var entity_pos = get_entity_position(entity_id)
        
        # Simple sphere intersection test
        # This is a simplified collision test - a real implementation would use proper collision shapes
        var collision_radius = entity.get_property("collision_radius", 1.0)
        
        var closest_point = _closest_point_on_line(start, end, entity_pos)
        var distance_to_line = entity_pos.distance_to(closest_point)
        
        if distance_to_line <= collision_radius:
            # Calculate entry point to sphere
            var dir_to_center = entity_pos - start
            var proj_length = dir_to_center.dot(direction)
            
            if proj_length <= 0:
                continue  # Behind the ray start
            
            var proj_point = start + direction * proj_length
            var distance_to_center = entity_pos.distance_to(proj_point)
            
            if distance_to_center > collision_radius:
                continue  # No intersection
            
            var offset = sqrt(collision_radius * collision_radius - distance_to_center * distance_to_center)
            var hit_distance = proj_length - offset
            
            if hit_distance < 0:
                hit_distance = 0  # Inside the sphere
            
            if hit_distance < closest_distance:
                closest_distance = hit_distance
                closest_hit = entity
    
    if closest_hit:
        result.hit = true
        result.entity = closest_hit
        result.position = start + direction * closest_distance
        result.normal = (result.position - get_entity_position(closest_hit.get_id())).normalized()
        result.distance = closest_distance
    
    return result

func _closest_point_on_line(line_start: Vector3, line_end: Vector3, point: Vector3) -> Vector3:
    var line_direction = line_end - line_start
    var line_length = line_direction.length()
    if line_length < 0.0001:
        return line_start  # Line is too short
    
    line_direction /= line_length
    
    var v = point - line_start
    var d = v.dot(line_direction)
    d = clamp(d, 0, line_length)
    
    return line_start + line_direction * d

# Visibility and culling
func set_active_zone(zone_id: String) -> bool:
    if not zones.has(zone_id):
        return false
    
    var old_zone = active_zone
    active_zone = zone_id
    
    print("JSHSpatialManager: Active zone set to " + zone_id)
    
    # Update visible zones
    _update_visible_zones()
    
    # Emit signal
    emit_signal("active_zone_changed", old_zone, zone_id)
    
    return true

func get_active_zone() -> String:
    return active_zone

func set_visible_zones(zone_ids: Array) -> bool:
    var valid_zones = []
    
    for zone_id in zone_ids:
        if zones.has(zone_id):
            valid_zones.append(zone_id)
    
    visible_zones = valid_zones
    
    # Update entity visibility
    _update_entity_visibility()
    
    return true

func get_visible_zones() -> Array:
    return visible_zones.duplicate()

func is_entity_visible(entity_id: String) -> bool:
    var entity_zones = get_entity_zones(entity_id)
    
    for zone_id in entity_zones:
        if zone_id in visible_zones:
            return true
    
    return false

func _update_visible_zones() -> void:
    if active_zone.is_empty():
        visible_zones = []
        return
    
    # Start with active zone
    visible_zones = [active_zone]
    
    # Add parent zones
    var current = active_zone
    while zone_hierarchy.has(current) and not zone_hierarchy[current].parent.is_empty():
        current = zone_hierarchy[current].parent
        visible_zones.append(current)
    
    # Add child zones
    _add_child_zones_recursive(active_zone)
    
    # Add connected zones
    if zone_transitions.has(active_zone):
        for transition in zone_transitions[active_zone]:
            if not transition.target_zone in visible_zones:
                visible_zones.append(transition.target_zone)
    
    # Update entity visibility
    _update_entity_visibility()
    
    print("JSHSpatialManager: Updated visible zones: " + str(visible_zones))

func _add_child_zones_recursive(zone_id: String) -> void:
    if not zone_hierarchy.has(zone_id):
        return
    
    for child in zone_hierarchy[zone_id].children:
        if not child in visible_zones:
            visible_zones.append(child)
            _add_child_zones_recursive(child)

func _update_entity_visibility() -> void:
    stats.visible_entities = 0
    
    # Count visible entities
    for zone_id in visible_zones:
        if zone_entities.has(zone_id):
            stats.visible_entities += zone_entities[zone_id].size()

func _update_zone_visibility(delta: float) -> void:
    # Load zones within distance of active zone
    if not active_zone.is_empty() and zones.has(active_zone):
        var active_zone_data = zones[active_zone]
        var active_zone_center = _get_zone_center(active_zone_data.bounds)
        
        # Find zones within loading distance
        var nearby_zones = get_zones_in_radius(active_zone_center, zone_load_distance)
        
        for zone_id in nearby_zones:
            if not zone_id in visible_zones:
                # Queue for loading
                if not zone_id in pending_zone_loads:
                    pending_zone_loads.append(zone_id)
        
        # Find zones to unload (those outside loading distance and not connected to active)
        var zones_to_unload = []
        for zone_id in visible_zones:
            if zone_id == active_zone:
                continue  # Don't unload active zone
            
            if zone_id in nearby_zones:
                continue  # Zone is nearby
            
            # Check if zone is connected to active zone
            var connected = false
            if zone_transitions.has(active_zone):
                for transition in zone_transitions[active_zone]:
                    if transition.target_zone == zone_id:
                        connected = true
                        break
            
            if not connected:
                zones_to_unload.append(zone_id)
        
        # Unload zones
        for zone_id in zones_to_unload:
            _unload_zone(zone_id)

func _process_pending_zone_loads() -> void:
    if load_in_progress or pending_zone_loads.is_empty():
        return
    
    load_in_progress = true
    
    # Load first pending zone
    var zone_id = pending_zone_loads[0]
    pending_zone_loads.remove_at(0)
    
    _load_zone(zone_id)
    
    load_in_progress = false

func _load_zone(zone_id: String) -> void:
    if not zones.has(zone_id):
        return
    
    print("JSHSpatialManager: Loading zone " + zone_id)
    
    # Add to visible zones if not already there
    if not zone_id in visible_zones:
        visible_zones.append(zone_id)
    
    # Load entities from database if available
    if database_manager:
        var zone_entities_from_db = database_manager.get_entities_in_zone(zone_id)
        
        for entity_data in zone_entities_from_db:
            # Check if entity is already loaded
            var entity_id = entity_data.get_id()
            var entity = entity_manager.get_entity(entity_id)
            
            if not entity:
                # Create entity
                entity = entity_manager.create_entity(
                    entity_data.get_type(),
                    entity_data.properties
                )
                
                # Copy metadata and other properties
                if entity:
                    # Set ID to match stored entity
                    entity.entity_id = entity_id
                    
                    # Set position if available
                    var pos_data = entity_data.get_metadata("position")
                    if pos_data and pos_data.has("x") and pos_data.has("y") and pos_data.has("z"):
                        var position = Vector3(pos_data.x, pos_data.y, pos_data.z)
                        set_entity_position(entity_id, position)
            
            # Add to zone
            add_entity_to_zone(entity_id, zone_id)
    
    # Update statistics
    stats.loaded_zones += 1
    
    # Emit signal
    emit_signal("zone_loaded", zone_id)

func _unload_zone(zone_id: String) -> void:
    if not zones.has(zone_id) or zone_id == active_zone:
        return
    
    print("JSHSpatialManager: Unloading zone " + zone_id)
    
    # Remove from visible zones
    var index = visible_zones.find(zone_id)
    if index >= 0:
        visible_zones.remove_at(index)
    
    # Save entities to database if available
    if database_manager and zone_entities.has(zone_id):
        for entity_id in zone_entities[zone_id]:
            var entity = entity_manager.get_entity(entity_id)
            if entity:
                database_manager.save_entity(entity)
    
    # Update statistics
    if stats.loaded_zones > 0:
        stats.loaded_zones -= 1
    
    # Emit signal
    emit_signal("zone_unloaded", zone_id)

# Zone subdivision and merging
func subdivide_zone(zone_id: String, divisions: Vector3i) -> Array:
    if not zones.has(zone_id):
        return []
    
    print("JSHSpatialManager: Subdividing zone " + zone_id)
    
    var zone_data = zones[zone_id]
    var bounds = zone_data.bounds
    
    var min_pos = Vector3(bounds.min_x, bounds.min_y, bounds.min_z)
    var max_pos = Vector3(bounds.max_x, bounds.max_y, bounds.max_z)
    var size = max_pos - min_pos
    
    var div_size = Vector3(
        size.x / divisions.x,
        size.y / divisions.y,
        size.z / divisions.z
    )
    
    var child_zones = []
    
    # Create child zones
    for x in range(divisions.x):
        for y in range(divisions.y):
            for z in range(divisions.z):
                var child_min = Vector3(
                    min_pos.x + x * div_size.x,
                    min_pos.y + y * div_size.y,
                    min_pos.z + z * div_size.z
                )
                
                var child_max = Vector3(
                    min_pos.x + (x + 1) * div_size.x,
                    min_pos.y + (y + 1) * div_size.y,
                    min_pos.z + (z + 1) * div_size.z
                )
                
                var child_id = zone_id + "_" + str(x) + "_" + str(y) + "_" + str(z)
                
                var child_data = {
                    "name": zone_data.name + " Section " + str(x) + "," + str(y) + "," + str(z),
                    "bounds": {
                        "min_x": child_min.x,
                        "min_y": child_min.y,
                        "min_z": child_min.z,
                        "max_x": child_max.x,
                        "max_y": child_max.y,
                        "max_z": child_max.z
                    },
                    "parent_zone": zone_id,
                    "level": zone_data.level + 1,
                    "is_root": false,
                    "autoload": zone_data.autoload,
                    "properties": zone_data.properties.duplicate()
                }
                
                create_zone(child_id, child_data)
                child_zones.append(child_id)
                
                # Distribute entities
                if zone_entities.has(zone_id):
                    for entity_id in zone_entities[zone_id]:
                        var pos = get_entity_position(entity_id)
                        
                        if (
                            pos.x >= child_min.x and pos.x <= child_max.x and
                            pos.y >= child_min.y and pos.y <= child_max.y and
                            pos.z >= child_min.z and pos.z <= child_max.z
                        ):
                            add_entity_to_zone(entity_id, child_id)
    
    # Update parent zone
    zone_data.is_subdivided = true
    update_zone(zone_id, { "is_subdivided": true })
    
    return child_zones

func merge_zones(zone_ids: Array) -> String:
    if zone_ids.size() < 2:
        return ""
    
    print("JSHSpatialManager: Merging zones: " + str(zone_ids))
    
    # Check if all zones exist
    for zone_id in zone_ids:
        if not zones.has(zone_id):
            return ""
    
    # Get bounds encompassing all zones
    var min_bounds = Vector3(INF, INF, INF)
    var max_bounds = Vector3(-INF, -INF, -INF)
    
    for zone_id in zone_ids:
        var bounds = zones[zone_id].bounds
        min_bounds.x = min(min_bounds.x, bounds.min_x)
        min_bounds.y = min(min_bounds.y, bounds.min_y)
        min_bounds.z = min(min_bounds.z, bounds.min_z)
        max_bounds.x = max(max_bounds.x, bounds.max_x)
        max_bounds.y = max(max_bounds.y, bounds.max_y)
        max_bounds.z = max(max_bounds.z, bounds.max_z)
    
    # Determine parent - use parent of first zone
    var parent_zone = ""
    var level = 0
    
    if zone_hierarchy.has(zone_ids[0]):
        parent_zone = zone_hierarchy[zone_ids[0]].parent
        level = zones[zone_ids[0]].level
    
    # Create new merged zone
    var merged_zone_id = "merged_" + zone_ids[0] + "_" + str(Time.get_unix_time_from_system())
    
    var merged_data = {
        "name": "Merged Zone",
        "bounds": {
            "min_x": min_bounds.x,
            "min_y": min_bounds.y,
            "min_z": min_bounds.z,
            "max_x": max_bounds.x,
            "max_y": max_bounds.y,
            "max_z": max_bounds.z
        },
        "parent_zone": parent_zone,
        "level": level,
        "is_root": parent_zone.is_empty(),
        "autoload": false,
        "properties": {},
        "merged_from": zone_ids.duplicate()
    }
    
    create_zone(merged_zone_id, merged_data)
    
    # Move all entities to new zone
    for zone_id in zone_ids:
        if zone_entities.has(zone_id):
            for entity_id in zone_entities[zone_id]:
                add_entity_to_zone(entity_id, merged_zone_id)
        
        # Delete old zone - skip if it's the default zone
        if zone_id != "default":
            delete_zone(zone_id)
    
    return merged_zone_id

func get_parent_zone(zone_id: String) -> String:
    if zone_hierarchy.has(zone_id):
        return zone_hierarchy[zone_id].parent
    return ""

func get_child_zones(zone_id: String) -> Array:
    if zone_hierarchy.has(zone_id):
        return zone_hierarchy[zone_id].children.duplicate()
    return []

# Zone transition
func register_zone_transition(source_zone: String, target_zone: String, transition_data: Dictionary = {}) -> bool:
    if not zones.has(source_zone) or not zones.has(target_zone):
        return false
    
    print("JSHSpatialManager: Registering transition from " + source_zone + " to " + target_zone)
    
    # Initialize if needed
    if not zone_transitions.has(source_zone):
        zone_transitions[source_zone] = []
    
    # Set default values if not provided
    if not transition_data.has("position"):
        transition_data.position = _get_nearest_point_between_zones(source_zone, target_zone)
    
    if not transition_data.has("type"):
        transition_data.type = "portal"
    
    if not transition_data.has("bidirectional"):
        transition_data.bidirectional = true
    
    # Add transition
    zone_transitions[source_zone].append({
        "source_zone": source_zone,
        "target_zone": target_zone,
        "position": transition_data.position,
        "type": transition_data.type,
        "data": transition_data
    })
    
    # Add reverse transition if bidirectional
    if transition_data.bidirectional:
        if not zone_transitions.has(target_zone):
            zone_transitions[target_zone] = []
        
        zone_transitions[target_zone].append({
            "source_zone": target_zone,
            "target_zone": source_zone,
            "position": transition_data.position,
            "type": transition_data.type,
            "data": transition_data
        })
    }
    
    # Update statistics
    stats.zone_transitions += 1
    
    return true

func get_zone_transitions(zone_id: String) -> Array:
    if zone_transitions.has(zone_id):
        return zone_transitions[zone_id].duplicate()
    return []

func transition_entity(entity_id: String, target_zone: String) -> bool:
    if not zones.has(target_zone):
        return false
    
    var entity = entity_manager.get_entity(entity_id)
    if not entity:
        return false
    
    print("JSHSpatialManager: Transitioning entity " + entity_id + " to zone " + target_zone)
    
    var current_zones = get_entity_zones(entity_id)
    var source_zone = ""
    
    if current_zones.size() > 0:
        source_zone = current_zones[0]
    
    # Get entity position
    var position = get_entity_position(entity_id)
    
    # If transition has a specific target position, use it
    if source_zone != "" and zone_transitions.has(source_zone):
        for transition in zone_transitions[source_zone]:
            if transition.target_zone == target_zone:
                # If transition specifies a target position, use it
                if transition.data.has("target_position"):
                    position = transition.data.target_position
                break
    
    # If no specific position, find a suitable position in target zone
    if not zone_contains_point(target_zone, position):
        var target_zone_data = zones[target_zone]
        position = _get_zone_center(target_zone_data.bounds)
    
    # Update position
    set_entity_position(entity_id, position)
    
    # Remove from current zones
    for zone_id in current_zones:
        remove_entity_from_zone(entity_id, zone_id)
    
    # Add to target zone
    add_entity_to_zone(entity_id, target_zone)
    
    # Emit signal
    emit_signal("entity_transitioned", entity_id, source_zone, target_zone)
    
    return true

func _get_nearest_point_between_zones(zone1: String, zone2: String) -> Vector3:
    if not zones.has(zone1) or not zones.has(zone2):
        return Vector3.ZERO
    
    var bounds1 = _get_zone_bounds(zones[zone1].bounds)
    var bounds2 = _get_zone_bounds(zones[zone2].bounds)
    
    # Check if zones overlap
    if (
        bounds1.position.x - bounds1.size.x/2 <= bounds2.position.x + bounds2.size.x/2 and
        bounds1.position.x + bounds1.size.x/2 >= bounds2.position.x - bounds2.size.x/2 and
        bounds1.position.y - bounds1.size.y/2 <= bounds2.position.y + bounds2.size.y/2 and
        bounds1.position.y + bounds1.size.y/2 >= bounds2.position.y - bounds2.size.y/2 and
        bounds1.position.z - bounds1.size.z/2 <= bounds2.position.z + bounds2.size.z/2 and
        bounds1.position.z + bounds1.size.z/2 >= bounds2.position.z - bounds2.size.z/2
    ):
        # Zones overlap, use midpoint of overlap
        var overlap_min = Vector3(
            max(bounds1.position.x - bounds1.size.x/2, bounds2.position.x - bounds2.size.x/2),
            max(bounds1.position.y - bounds1.size.y/2, bounds2.position.y - bounds2.size.y/2),
            max(bounds1.position.z - bounds1.size.z/2, bounds2.position.z - bounds2.size.z/2)
        )
        
        var overlap_max = Vector3(
            min(bounds1.position.x + bounds1.size.x/2, bounds2.position.x + bounds2.size.x/2),
            min(bounds1.position.y + bounds1.size.y/2, bounds2.position.y + bounds2.size.y/2),
            min(bounds1.position.z + bounds1.size.z/2, bounds2.position.z + bounds2.size.z/2)
        )
        
        return (overlap_min + overlap_max) / 2
    
    # Zones don't overlap, find closest points
    var closest_point1 = Vector3(
        clamp(bounds2.position.x, bounds1.position.x - bounds1.size.x/2, bounds1.position.x + bounds1.size.x/2),
        clamp(bounds2.position.y, bounds1.position.y - bounds1.size.y/2, bounds1.position.y + bounds1.size.y/2),
        clamp(bounds2.position.z, bounds1.position.z - bounds1.size.z/2, bounds1.position.z + bounds1.size.z/2)
    )
    
    var closest_point2 = Vector3(
        clamp(bounds1.position.x, bounds2.position.x - bounds2.size.x/2, bounds2.position.x + bounds2.size.x/2),
        clamp(bounds1.position.y, bounds2.position.y - bounds2.size.y/2, bounds2.position.y + bounds2.size.y/2),
        clamp(bounds1.position.z, bounds2.position.z - bounds2.size.z/2, bounds2.position.z + bounds2.size.z/2)
    )
    
    return (closest_point1 + closest_point2) / 2

# Statistics and optimization
func get_zone_statistics(zone_id: String = "") -> Dictionary:
    var result = {}
    
    if zone_id.is_empty():
        # Global statistics
        result = {
            "total_zones": stats.total_zones,
            "loaded_zones": stats.loaded_zones,
            "visible_entities": stats.visible_entities,
            "active_zone": active_zone,
            "visible_zones": visible_zones.size(),
            "entity_positions": stats.entity_positions,
            "spatial_queries": stats.spatial_queries,
            "zone_transitions": stats.zone_transitions
        }
    else:
        # Zone-specific statistics
        if zones.has(zone_id):
            var entity_count = 0
            if zone_entities.has(zone_id):
                entity_count = zone_entities[zone_id].size()
            
            var bounds = zones[zone_id].bounds
            var size = Vector3(
                bounds.max_x - bounds.min_x,
                bounds.max_y - bounds.min_y,
                bounds.max_z - bounds.min_z
            )
            var volume = size.x * size.y * size.z
            
            var transition_count = 0
            if zone_transitions.has(zone_id):
                transition_count = zone_transitions[zone_id].size()
            
            var child_count = 0
            if zone_hierarchy.has(zone_id):
                child_count = zone_hierarchy[zone_id].children.size()
            
            result = {
                "id": zone_id,
                "name": zones[zone_id].name,
                "entity_count": entity_count,
                "is_active": zone_id == active_zone,
                "is_visible": zone_id in visible_zones,
                "level": zones[zone_id].level,
                "size": size,
                "volume": volume,
                "entity_density": entity_count / max(volume, 0.0001),
                "transition_count": transition_count,
                "child_count": child_count,
                "parent_zone": get_parent_zone(zone_id)
            }
        }
    
    return result

func optimize_zone_partitioning() -> bool:
    print("JSHSpatialManager: Optimizing zone partitioning")
    
    # Find zones with too many entities
    var zones_to_subdivide = []
    var entities_per_zone_threshold = 100  # Example threshold
    
    for zone_id in zones:
        if zone_entities.has(zone_id) and zone_entities[zone_id].size() > entities_per_zone_threshold:
            zones_to_subdivide.append(zone_id)
    
    # Subdivide zones with too many entities
    for zone_id in zones_to_subdivide:
        subdivide_zone(zone_id, Vector3i(2, 2, 2))
    
    # Rebuild spatial partitioning structures
    _rebuild_spatial_partitioning()
    
    return true

func _rebuild_spatial_partitioning() -> void:
    # Clear existing structures
    spatial_grid.clear()
    spatial_tree.clear()
    
    # Re-add all zones to octree
    for zone_id in zones:
        var bounds = _get_zone_bounds(zones[zone_id].bounds)
        spatial_tree.insert_zone(zone_id, bounds)
    
    # Re-add all entities to grid
    for entity_id in entity_positions:
        var position = entity_positions[entity_id]
        var entity_zones = get_entity_zones(entity_id)
        
        for zone_id in entity_zones:
            spatial_grid.insert_entity(entity_id, position, zone_id)

# Helper functions
func _get_zone_bounds(bounds_dict: Dictionary) -> Dictionary:
    return {
        "position": Vector3(
            (bounds_dict.min_x + bounds_dict.max_x) / 2,
            (bounds_dict.min_y + bounds_dict.max_y) / 2,
            (bounds_dict.min_z + bounds_dict.max_z) / 2
        ),
        "size": Vector3(
            bounds_dict.max_x - bounds_dict.min_x,
            bounds_dict.max_y - bounds_dict.min_y,
            bounds_dict.max_z - bounds_dict.min_z
        )
    }

func _get_zone_center(bounds_dict: Dictionary) -> Vector3:
    return Vector3(
        (bounds_dict.min_x + bounds_dict.max_x) / 2,
        (bounds_dict.min_y + bounds_dict.max_y) / 2,
        (bounds_dict.min_z + bounds_dict.max_z) / 2
    )

# Entity manager callbacks
func _on_entity_created(entity: JSHUniversalEntity) -> void:
    # Get entity ID
    var entity_id = entity.get_id()
    
    # Add to default zone if not in any zone
    var entity_zones = entity.get_zones()
    if entity_zones.is_empty() and zones.has("default"):
        add_entity_to_zone(entity_id, "default")

func _on_entity_destroyed(entity_id: String) -> void:
    # Remove from all zones
    var entity_zones = get_entity_zones(entity_id)
    for zone_id in entity_zones:
        remove_entity_from_zone(entity_id, zone_id)
    
    # Clear position tracking
    if entity_positions.has(entity_id):
        entity_positions.erase(entity_id)
        stats.entity_positions -= 1

func _on_entity_updated(entity: JSHUniversalEntity) -> void:
    # Update position if metadata changed
    var pos_data = entity.get_metadata("position")
    if pos_data and pos_data.has("x") and pos_data.has("y") and pos_data.has("z"):
        var position = Vector3(pos_data.x, pos_data.y, pos_data.z)
        
        # Only update if position changed
        if not entity_positions.has(entity.get_id()) or entity_positions[entity.get_id()] != position:
            set_entity_position(entity.get_id(), position)
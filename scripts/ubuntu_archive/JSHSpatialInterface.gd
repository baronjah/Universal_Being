extends RefCounted
class_name JSHSpatialInterface

# Spatial interface defines standard methods that all spatial management systems should implement

# Zone operations
func create_zone(zone_id: String, zone_data: Dictionary) -> bool:
    push_error("JSHSpatialInterface: create_zone() method must be implemented by subclass")
    return false

func delete_zone(zone_id: String) -> bool:
    push_error("JSHSpatialInterface: delete_zone() method must be implemented by subclass")
    return false

func update_zone(zone_id: String, zone_data: Dictionary) -> bool:
    push_error("JSHSpatialInterface: update_zone() method must be implemented by subclass")
    return false

func zone_exists(zone_id: String) -> bool:
    push_error("JSHSpatialInterface: zone_exists() method must be implemented by subclass")
    return false

func get_zone(zone_id: String) -> Dictionary:
    push_error("JSHSpatialInterface: get_zone() method must be implemented by subclass")
    return {}

func get_all_zones() -> Array:
    push_error("JSHSpatialInterface: get_all_zones() method must be implemented by subclass")
    return []

func get_zones_in_radius(position: Vector3, radius: float) -> Array:
    push_error("JSHSpatialInterface: get_zones_in_radius() method must be implemented by subclass")
    return []

func get_zones_in_box(min_bounds: Vector3, max_bounds: Vector3) -> Array:
    push_error("JSHSpatialInterface: get_zones_in_box() method must be implemented by subclass")
    return []

# Entity zone management
func add_entity_to_zone(entity_id: String, zone_id: String) -> bool:
    push_error("JSHSpatialInterface: add_entity_to_zone() method must be implemented by subclass")
    return false

func remove_entity_from_zone(entity_id: String, zone_id: String) -> bool:
    push_error("JSHSpatialInterface: remove_entity_from_zone() method must be implemented by subclass")
    return false

func get_entity_zones(entity_id: String) -> Array:
    push_error("JSHSpatialInterface: get_entity_zones() method must be implemented by subclass")
    return []

func get_entities_in_zone(zone_id: String) -> Array:
    push_error("JSHSpatialInterface: get_entities_in_zone() method must be implemented by subclass")
    return []

# Entity position management
func set_entity_position(entity_id: String, position: Vector3) -> bool:
    push_error("JSHSpatialInterface: set_entity_position() method must be implemented by subclass")
    return false

func get_entity_position(entity_id: String) -> Vector3:
    push_error("JSHSpatialInterface: get_entity_position() method must be implemented by subclass")
    return Vector3.ZERO

func move_entity(entity_id: String, new_position: Vector3) -> bool:
    push_error("JSHSpatialInterface: move_entity() method must be implemented by subclass")
    return false

# Spatial queries
func get_entities_in_radius(position: Vector3, radius: float, filter: Dictionary = {}) -> Array:
    push_error("JSHSpatialInterface: get_entities_in_radius() method must be implemented by subclass")
    return []

func get_entities_in_box(min_bounds: Vector3, max_bounds: Vector3, filter: Dictionary = {}) -> Array:
    push_error("JSHSpatialInterface: get_entities_in_box() method must be implemented by subclass")
    return []

func get_nearest_entities(position: Vector3, count: int, max_distance: float = -1, filter: Dictionary = {}) -> Array:
    push_error("JSHSpatialInterface: get_nearest_entities() method must be implemented by subclass")
    return []

func cast_ray(start: Vector3, end: Vector3, filter: Dictionary = {}) -> Dictionary:
    push_error("JSHSpatialInterface: cast_ray() method must be implemented by subclass")
    return {}

# Visibility and culling
func set_active_zone(zone_id: String) -> bool:
    push_error("JSHSpatialInterface: set_active_zone() method must be implemented by subclass")
    return false

func get_active_zone() -> String:
    push_error("JSHSpatialInterface: get_active_zone() method must be implemented by subclass")
    return ""

func set_visible_zones(zone_ids: Array) -> bool:
    push_error("JSHSpatialInterface: set_visible_zones() method must be implemented by subclass")
    return false

func get_visible_zones() -> Array:
    push_error("JSHSpatialInterface: get_visible_zones() method must be implemented by subclass")
    return []

func is_entity_visible(entity_id: String) -> bool:
    push_error("JSHSpatialInterface: is_entity_visible() method must be implemented by subclass")
    return false

# Zone subdivision and merging
func subdivide_zone(zone_id: String, divisions: Vector3i) -> Array:
    push_error("JSHSpatialInterface: subdivide_zone() method must be implemented by subclass")
    return []

func merge_zones(zone_ids: Array) -> String:
    push_error("JSHSpatialInterface: merge_zones() method must be implemented by subclass")
    return ""

func get_parent_zone(zone_id: String) -> String:
    push_error("JSHSpatialInterface: get_parent_zone() method must be implemented by subclass")
    return ""

func get_child_zones(zone_id: String) -> Array:
    push_error("JSHSpatialInterface: get_child_zones() method must be implemented by subclass")
    return []

# Zone transition
func register_zone_transition(source_zone: String, target_zone: String, transition_data: Dictionary) -> bool:
    push_error("JSHSpatialInterface: register_zone_transition() method must be implemented by subclass")
    return false

func get_zone_transitions(zone_id: String) -> Array:
    push_error("JSHSpatialInterface: get_zone_transitions() method must be implemented by subclass")
    return []

func transition_entity(entity_id: String, target_zone: String) -> bool:
    push_error("JSHSpatialInterface: transition_entity() method must be implemented by subclass")
    return false

# Statistics and optimization
func get_zone_statistics(zone_id: String = "") -> Dictionary:
    push_error("JSHSpatialInterface: get_zone_statistics() method must be implemented by subclass")
    return {}

func optimize_zone_partitioning() -> bool:
    push_error("JSHSpatialInterface: optimize_zone_partitioning() method must be implemented by subclass")
    return false
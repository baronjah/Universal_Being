extends Node
class_name JSHOctree

# Octree for efficient spatial partitioning
# Used for zone/region queries rather than individual entities

class OctreeNode:
    var center: Vector3 = Vector3.ZERO
    var size: Vector3 = Vector3.ONE
    var depth: int = 0
    var zones: Array = []
    var children: Array = []  # 8 child octants
    var is_leaf: bool = true
    var max_depth: int = 8
    var min_zones_per_node: int = 4
    
    func _init(p_center: Vector3, p_size: Vector3, p_depth: int, p_max_depth: int = 8, p_min_zones_per_node: int = 4) -> void:
        center = p_center
        size = p_size
        depth = p_depth
        max_depth = p_max_depth
        min_zones_per_node = p_min_zones_per_node
    
    func contains_point(point: Vector3) -> bool:
        return (
            point.x >= center.x - size.x/2 and
            point.x <= center.x + size.x/2 and
            point.y >= center.y - size.y/2 and
            point.y <= center.y + size.y/2 and
            point.z >= center.z - size.z/2 and
            point.z <= center.z + size.z/2
        )
    
    func intersects_box(box_center: Vector3, box_size: Vector3) -> bool:
        # Check if this octree node's bounding box intersects with the given box
        var node_min = center - size/2
        var node_max = center + size/2
        var box_min = box_center - box_size/2
        var box_max = box_center + box_size/2
        
        return (
            node_min.x <= box_max.x and
            node_max.x >= box_min.x and
            node_min.y <= box_max.y and
            node_max.y >= box_min.y and
            node_min.z <= box_max.z and
            node_max.z >= box_min.z
        )
    
    func intersects_sphere(sphere_center: Vector3, radius: float) -> bool:
        # Check if this octree node's bounding box intersects with the given sphere
        # Find the closest point on the box to the sphere center
        var closest = Vector3(
            clamp(sphere_center.x, center.x - size.x/2, center.x + size.x/2),
            clamp(sphere_center.y, center.y - size.y/2, center.y + size.y/2),
            clamp(sphere_center.z, center.z - size.z/2, center.z + size.z/2)
        )
        
        # Check if the closest point is within the sphere's radius
        return sphere_center.distance_to(closest) <= radius
    
    func intersects_frustum(planes: Array) -> bool:
        # Check if this octree node's bounding box intersects with the view frustum
        # TODO: Implement frustum culling
        return true
    
    func subdivide() -> void:
        if not is_leaf or depth >= max_depth:
            return
        
        is_leaf = false
        children.clear()
        
        var half_size = size / 2
        var quarter_size = size / 4
        
        # Create 8 children (octants)
        for i in range(8):
            var x_offset = 1 if i & 1 else -1
            var y_offset = 1 if i & 2 else -1
            var z_offset = 1 if i & 4 else -1
            
            var child_center = center + Vector3(
                quarter_size.x * x_offset,
                quarter_size.y * y_offset,
                quarter_size.z * z_offset
            )
            
            var child = OctreeNode.new(child_center, half_size, depth + 1, max_depth, min_zones_per_node)
            children.append(child)
        
        # Distribute zones to children
        var remaining_zones = []
        
        for zone in zones:
            var distributed = false
            
            for child in children:
                if child.contains_zone(zone.center, zone.size):
                    child.insert_zone(zone.id, zone)
                    distributed = true
                    break
            
            # If zone doesn't fit cleanly in a child (spans multiple children), keep it at this level
            if not distributed:
                remaining_zones.append(zone)
        
        zones = remaining_zones
    
    func contains_zone(zone_center: Vector3, zone_size: Vector3) -> bool:
        var zone_min = zone_center - zone_size/2
        var zone_max = zone_center + zone_size/2
        var node_min = center - size/2
        var node_max = center + size/2
        
        # Check if the zone is fully contained in this node
        return (
            zone_min.x >= node_min.x and
            zone_max.x <= node_max.x and
            zone_min.y >= node_min.y and
            zone_max.y <= node_max.y and
            zone_min.z >= node_min.z and
            zone_max.z <= node_max.z
        )
    
    func insert_zone(zone_id: String, zone_bounds: Dictionary) -> void:
        # Zone bounds should have position and size
        var zone_data = {
            "id": zone_id,
            "center": zone_bounds.position, 
            "size": zone_bounds.size
        }
        
        # If this is a leaf node or at max depth, add zone to this node
        if is_leaf:
            zones.append(zone_data)
            
            # Check if we need to subdivide
            if depth < max_depth and zones.size() > min_zones_per_node:
                subdivide()
        } else {
            # Try to insert into a child
            var inserted = false
            
            for child in children:
                if child.contains_zone(zone_data.center, zone_data.size):
                    child.insert_zone(zone_id, zone_bounds)
                    inserted = true
                    break
            
            # If doesn't fit in any child, add to this node
            if not inserted:
                zones.append(zone_data)
        }
    
    func remove_zone(zone_id: String) -> bool:
        # Remove from this node
        for i in range(zones.size()):
            if zones[i].id == zone_id:
                zones.remove_at(i)
                return true
        
        # Try to remove from children
        if not is_leaf:
            for child in children:
                if child.remove_zone(zone_id):
                    return true
        
        return false
    
    func update_zone(zone_id: String, zone_bounds: Dictionary) -> bool:
        # First remove the zone
        if remove_zone(zone_id):
            # Then reinsert it
            insert_zone(zone_id, zone_bounds)
            return true
        
        return false
    
    func query_point(point: Vector3) -> Array:
        var result = []
        
        # Check if the point is in this node at all
        if not contains_point(point):
            return result
        
        # Add zones from this node that contain the point
        for zone in zones:
            var zone_min = zone.center - zone.size/2
            var zone_max = zone.center + zone.size/2
            
            if (
                point.x >= zone_min.x and
                point.x <= zone_max.x and
                point.y >= zone_min.y and
                point.y <= zone_max.y and
                point.z >= zone_min.z and
                point.z <= zone_max.z
            ):
                result.append(zone.id)
        
        # Check children if not a leaf
        if not is_leaf:
            for child in children:
                if child.contains_point(point):
                    result.append_array(child.query_point(point))
        
        return result
    
    func query_box(min_bounds: Vector3, max_bounds: Vector3) -> Array:
        var result = []
        
        var box_center = (min_bounds + max_bounds) / 2
        var box_size = max_bounds - min_bounds
        
        # Check if the box intersects this node
        if not intersects_box(box_center, box_size):
            return result
        
        # Add zones from this node that intersect the box
        for zone in zones:
            var zone_min = zone.center - zone.size/2
            var zone_max = zone.center + zone.size/2
            
            if (
                zone_min.x <= max_bounds.x and
                zone_max.x >= min_bounds.x and
                zone_min.y <= max_bounds.y and
                zone_max.y >= min_bounds.y and
                zone_min.z <= max_bounds.z and
                zone_max.z >= min_bounds.z
            ):
                result.append(zone.id)
        
        # Check children if not a leaf
        if not is_leaf:
            for child in children:
                if child.intersects_box(box_center, box_size):
                    result.append_array(child.query_box(min_bounds, max_bounds))
        
        return result
    
    func query_sphere(center: Vector3, radius: float) -> Array:
        var result = []
        
        # Check if the sphere intersects this node
        if not intersects_sphere(center, radius):
            return result
        
        # Add zones from this node that intersect the sphere
        for zone in zones:
            # Find the closest point on the zone to the sphere center
            var closest = Vector3(
                clamp(center.x, zone.center.x - zone.size.x/2, zone.center.x + zone.size.x/2),
                clamp(center.y, zone.center.y - zone.size.y/2, zone.center.y + zone.size.y/2),
                clamp(center.z, zone.center.z - zone.size.z/2, zone.center.z + zone.size.z/2)
            )
            
            # Check if the closest point is within the sphere's radius
            if center.distance_to(closest) <= radius:
                result.append(zone.id)
        
        # Check children if not a leaf
        if not is_leaf:
            for child in children:
                if child.intersects_sphere(center, radius):
                    result.append_array(child.query_sphere(center, radius))
        
        return result
    
    func query_frustum(planes: Array) -> Array:
        var result = []
        
        # Check if this node intersects the frustum
        if not intersects_frustum(planes):
            return result
        
        # Add all zones from this node (frustum culling could be more precise here)
        for zone in zones:
            result.append(zone.id)
        
        # Check children if not a leaf
        if not is_leaf:
            for child in children:
                result.append_array(child.query_frustum(planes))
        
        return result
    
    func get_zone_count() -> int:
        var count = zones.size()
        
        if not is_leaf:
            for child in children:
                count += child.get_zone_count()
        
        return count
    
    func get_node_count() -> int:
        var count = 1  # This node
        
        if not is_leaf:
            for child in children:
                count += child.get_node_count()
        
        return count
    
    func get_max_depth() -> int:
        if is_leaf:
            return depth
        
        var max_child_depth = depth
        for child in children:
            max_child_depth = max(max_child_depth, child.get_max_depth())
        
        return max_child_depth

# Root node
var root: OctreeNode = null
var world_size: Vector3 = Vector3(2000, 2000, 2000)
var world_center: Vector3 = Vector3.ZERO
var max_depth: int = 8
var min_zones_per_node: int = 4

# Statistics
var stats: Dictionary = {
    "total_zones": 0,
    "total_nodes": 0,
    "max_depth": 0,
    "zone_operations": 0
}

func _init(p_world_size: Vector3 = Vector3(2000, 2000, 2000), p_world_center: Vector3 = Vector3.ZERO) -> void:
    world_size = p_world_size
    world_center = p_world_center
    
    # Create root node
    root = OctreeNode.new(world_center, world_size, 0, max_depth, min_zones_per_node)
    print("JSHOctree: Initialized with world size " + str(world_size))

# Zone operations
func insert_zone(zone_id: String, zone_bounds: Dictionary) -> void:
    if root:
        root.insert_zone(zone_id, zone_bounds)
        stats.total_zones += 1
        stats.zone_operations += 1
        _update_stats()

func remove_zone(zone_id: String) -> bool:
    if root and root.remove_zone(zone_id):
        stats.total_zones -= 1
        stats.zone_operations += 1
        _update_stats()
        return true
    
    return false

func update_zone(zone_id: String, zone_bounds: Dictionary) -> bool:
    if root and root.update_zone(zone_id, zone_bounds):
        stats.zone_operations += 1
        _update_stats()
        return true
    
    return false

# Queries
func query_point(point: Vector3) -> Array:
    if root:
        return root.query_point(point)
    
    return []

func query_box(min_bounds: Vector3, max_bounds: Vector3) -> Array:
    if root:
        return root.query_box(min_bounds, max_bounds)
    
    return []

func query_sphere(center: Vector3, radius: float) -> Array:
    if root:
        return root.query_sphere(center, radius)
    
    return []

func query_frustum(planes: Array) -> Array:
    if root:
        return root.query_frustum(planes)
    
    return []

# Maintenance
func clear() -> void:
    # Create new root node
    root = OctreeNode.new(world_center, world_size, 0, max_depth, min_zones_per_node)
    
    # Reset statistics
    stats = {
        "total_zones": 0,
        "total_nodes": 0,
        "max_depth": 0,
        "zone_operations": 0
    }
    
    print("JSHOctree: Cleared all data")

func rebuild() -> void:
    # TODO: Implement octree rebuilding for better balance
    pass

# Statistics
func _update_stats() -> void:
    if root:
        stats.total_nodes = root.get_node_count()
        stats.max_depth = root.get_max_depth()

func get_statistics() -> Dictionary:
    return stats.duplicate()
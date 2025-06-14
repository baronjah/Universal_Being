extends Node
class_name JSHSpatialGrid

# Spatial grid for efficient spatial queries
# Based on a uniform grid for fast entity position lookup

# Grid parameters
var cell_size: Vector3 = Vector3(10, 10, 10)  # Size of each grid cell
var grid: Dictionary = {}  # Maps cell coordinates to lists of entities
var entity_cells: Dictionary = {}  # Maps entity IDs to their cell coordinates
var zone_grids: Dictionary = {}  # Separate grids for each zone

# Grid size tracking
var min_bounds: Vector3 = Vector3(INF, INF, INF)
var max_bounds: Vector3 = Vector3(-INF, -INF, -INF)

# Statistics
var stats: Dictionary = {
    "total_cells": 0,
    "total_entities": 0,
    "max_entities_per_cell": 0,
    "num_zones": 0
}

func _init(cell_size_param: Vector3 = Vector3(10, 10, 10)) -> void:
    cell_size = cell_size_param
    print("JSHSpatialGrid: Initialized with cell size " + str(cell_size))

# Grid operations
func insert_entity(entity_id: String, position: Vector3, zone_id: String = "") -> void:
    # Get cell coordinates
    var cell_coords = get_cell_coords(position)
    
    # Handle zone-specific grid
    if not zone_id.is_empty():
        if not zone_grids.has(zone_id):
            zone_grids[zone_id] = {}
            stats.num_zones += 1
        
        var zone_grid = zone_grids[zone_id]
        
        # Get cell in zone grid
        var cell_key = str(cell_coords.x) + "," + str(cell_coords.y) + "," + str(cell_coords.z)
        if not zone_grid.has(cell_key):
            zone_grid[cell_key] = []
        
        # Add entity to cell if not already there
        if not entity_id in zone_grid[cell_key]:
            zone_grid[cell_key].append(entity_id)
        
        # Track which cells this entity is in
        if not entity_cells.has(entity_id):
            entity_cells[entity_id] = {}
        
        if not entity_cells[entity_id].has(zone_id):
            entity_cells[entity_id][zone_id] = []
        
        if not cell_key in entity_cells[entity_id][zone_id]:
            entity_cells[entity_id][zone_id].append(cell_key)
    
    # Also add to global grid
    var cell_key = str(cell_coords.x) + "," + str(cell_coords.y) + "," + str(cell_coords.z)
    if not grid.has(cell_key):
        grid[cell_key] = []
        stats.total_cells += 1
    
    # Add entity to cell if not already there
    if not entity_id in grid[cell_key]:
        grid[cell_key].append(entity_id)
        
        # Update statistics
        stats.max_entities_per_cell = max(stats.max_entities_per_cell, grid[cell_key].size())
    
    # Track entity in global cells
    if not entity_cells.has(entity_id):
        entity_cells[entity_id] = {}
        stats.total_entities += 1
    
    if not entity_cells[entity_id].has("global"):
        entity_cells[entity_id]["global"] = []
    
    if not cell_key in entity_cells[entity_id]["global"]:
        entity_cells[entity_id]["global"].append(cell_key)
    
    # Update bounds
    min_bounds.x = min(min_bounds.x, position.x)
    min_bounds.y = min(min_bounds.y, position.y)
    min_bounds.z = min(min_bounds.z, position.z)
    max_bounds.x = max(max_bounds.x, position.x)
    max_bounds.y = max(max_bounds.y, position.y)
    max_bounds.z = max(max_bounds.z, position.z)

func update_entity(entity_id: String, position: Vector3, zone_id: String = "") -> void:
    # Remove from old cells
    remove_entity(entity_id, zone_id)
    
    # Insert at new position
    insert_entity(entity_id, position, zone_id)

func remove_entity(entity_id: String, zone_id: String = "") -> void:
    if not entity_cells.has(entity_id):
        return
    
    # Handle zone-specific removal
    if not zone_id.is_empty() and entity_cells[entity_id].has(zone_id):
        var zone_grid = zone_grids[zone_id]
        var cell_keys = entity_cells[entity_id][zone_id]
        
        for cell_key in cell_keys:
            if zone_grid.has(cell_key):
                var index = zone_grid[cell_key].find(entity_id)
                if index >= 0:
                    zone_grid[cell_key].remove_at(index)
                
                # Remove empty cells
                if zone_grid[cell_key].is_empty():
                    zone_grid.erase(cell_key)
        
        # Clear entity's cell tracking for this zone
        entity_cells[entity_id].erase(zone_id)
        
        # If no more entities in this zone, remove the zone grid
        var empty = true
        for cell_key in zone_grid:
            if not zone_grid[cell_key].is_empty():
                empty = false
                break
        
        if empty:
            zone_grids.erase(zone_id)
            stats.num_zones -= 1
    }
    
    # Also remove from global grid
    if entity_cells[entity_id].has("global"):
        var cell_keys = entity_cells[entity_id]["global"]
        
        for cell_key in cell_keys:
            if grid.has(cell_key):
                var index = grid[cell_key].find(entity_id)
                if index >= 0:
                    grid[cell_key].remove_at(index)
                
                # Remove empty cells
                if grid[cell_key].is_empty():
                    grid.erase(cell_key)
                    stats.total_cells -= 1
        
        # Clear entity's global cell tracking
        entity_cells[entity_id].erase("global")
    }
    
    # If entity has no more cells, remove it entirely
    if entity_cells[entity_id].is_empty():
        entity_cells.erase(entity_id)
        stats.total_entities -= 1

# Spatial queries
func query_point(position: Vector3, zone_id: String = "") -> Array:
    var cell_coords = get_cell_coords(position)
    var cell_key = str(cell_coords.x) + "," + str(cell_coords.y) + "," + str(cell_coords.z)
    
    if zone_id.is_empty():
        # Query global grid
        if grid.has(cell_key):
            return grid[cell_key].duplicate()
        return []
    else:
        # Query zone grid
        if zone_grids.has(zone_id) and zone_grids[zone_id].has(cell_key):
            return zone_grids[zone_id][cell_key].duplicate()
        return []

func query_box(min_pos: Vector3, max_pos: Vector3, zone_id: String = "") -> Array:
    var min_cell = get_cell_coords(min_pos)
    var max_cell = get_cell_coords(max_pos)
    
    var result = []
    
    for x in range(min_cell.x, max_cell.x + 1):
        for y in range(min_cell.y, max_cell.y + 1):
            for z in range(min_cell.z, max_cell.z + 1):
                var cell_key = str(x) + "," + str(y) + "," + str(z)
                
                if zone_id.is_empty():
                    # Query global grid
                    if grid.has(cell_key):
                        for entity_id in grid[cell_key]:
                            if not entity_id in result:
                                result.append(entity_id)
                } else {
                    # Query zone grid
                    if zone_grids.has(zone_id) and zone_grids[zone_id].has(cell_key):
                        for entity_id in zone_grids[zone_id][cell_key]:
                            if not entity_id in result:
                                result.append(entity_id)
                }
    
    return result

func query_sphere(center: Vector3, radius: float, zone_id: String = "") -> Array:
    # Convert sphere to bounding box for initial broad phase
    var min_pos = center - Vector3(radius, radius, radius)
    var max_pos = center + Vector3(radius, radius, radius)
    
    var candidates = query_box(min_pos, max_pos, zone_id)
    var result = []
    
    # Filter candidates by actual distance to center
    for entity_id in candidates:
        if entity_cells.has(entity_id):
            # Check if entity's cell(s) are close enough to the sphere
            var within_radius = false
            
            if zone_id.is_empty():
                # Check global cells
                if entity_cells[entity_id].has("global"):
                    for cell_key in entity_cells[entity_id]["global"]:
                        var cell_parts = cell_key.split(",")
                        var cell_x = int(cell_parts[0])
                        var cell_y = int(cell_parts[1])
                        var cell_z = int(cell_parts[2])
                        
                        var cell_center = Vector3(
                            cell_x * cell_size.x + cell_size.x / 2,
                            cell_y * cell_size.y + cell_size.y / 2,
                            cell_z * cell_size.z + cell_size.z / 2
                        )
                        
                        var cell_radius = cell_size.length() / 2
                        var dist = center.distance_to(cell_center)
                        
                        if dist <= radius + cell_radius:
                            within_radius = true
                            break
            } else {
                # Check zone-specific cells
                if entity_cells[entity_id].has(zone_id):
                    for cell_key in entity_cells[entity_id][zone_id]:
                        var cell_parts = cell_key.split(",")
                        var cell_x = int(cell_parts[0])
                        var cell_y = int(cell_parts[1])
                        var cell_z = int(cell_parts[2])
                        
                        var cell_center = Vector3(
                            cell_x * cell_size.x + cell_size.x / 2,
                            cell_y * cell_size.y + cell_size.y / 2,
                            cell_z * cell_size.z + cell_size.z / 2
                        )
                        
                        var cell_radius = cell_size.length() / 2
                        var dist = center.distance_to(cell_center)
                        
                        if dist <= radius + cell_radius:
                            within_radius = true
                            break
            }
            
            if within_radius:
                result.append(entity_id)
        }
    
    return result

# Helper functions
func get_cell_coords(position: Vector3) -> Vector3i:
    return Vector3i(
        floor(position.x / cell_size.x),
        floor(position.y / cell_size.y),
        floor(position.z / cell_size.z)
    )

func clear() -> void:
    grid.clear()
    entity_cells.clear()
    zone_grids.clear()
    
    min_bounds = Vector3(INF, INF, INF)
    max_bounds = Vector3(-INF, -INF, -INF)
    
    stats = {
        "total_cells": 0,
        "total_entities": 0,
        "max_entities_per_cell": 0,
        "num_zones": 0
    }
    
    print("JSHSpatialGrid: Cleared all data")

func get_statistics() -> Dictionary:
    return {
        "total_cells": stats.total_cells,
        "total_entities": stats.total_entities,
        "max_entities_per_cell": stats.max_entities_per_cell,
        "num_zones": stats.num_zones,
        "min_bounds": min_bounds,
        "max_bounds": max_bounds,
        "cell_size": cell_size
    }
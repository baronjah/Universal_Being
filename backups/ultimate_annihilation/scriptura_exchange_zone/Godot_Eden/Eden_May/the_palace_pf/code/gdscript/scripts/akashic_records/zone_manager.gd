extends Node
class_name ZoneManager

# Zones
var zones = {}
var active_zones = []
var max_active_zones = 5

# Zone limits
var max_entities_per_zone = 100
var splitting_threshold = 80
var merging_threshold = 30

# File paths
var zones_dir = "res://dictionary/zones/"

signal zone_created(zone_id)
signal zone_removed(zone_id)
signal zone_split(parent_zone_id, child_zone_ids)
signal zone_merged(child_zone_ids, parent_zone_id)

func _ready():
	# Create directories if they don't exist
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(zones_dir):
		dir.make_dir_recursive(zones_dir)

func create_zone(zone_id: String, bounds: AABB) -> Dictionary:
	if zones.has(zone_id):
		return zones[zone_id]
	
	var zone = {
		"id": zone_id,
		"bounds": bounds,
		"entities": {},
		"child_zones": [],
		"parent_zone": "",
		"entity_count": 0,
		"active": false
	}
	
	zones[zone_id] = zone
	emit_signal("zone_created", zone_id)
	
	return zone

func remove_zone(zone_id: String) -> bool:
	if not zones.has(zone_id):
		return false
	
	var zone = zones[zone_id]
	
	# Remove from active zones
	if active_zones.has(zone_id):
		active_zones.erase(zone_id)
	
	# Remove from parent
	if not zone.parent_zone.is_empty() and zones.has(zone.parent_zone):
		zones[zone.parent_zone].child_zones.erase(zone_id)
	
	# Remove child zones
	for child_id in zone.child_zones.duplicate():
		remove_zone(child_id)
	
	# Remove the zone
	zones.erase(zone_id)
	
	emit_signal("zone_removed", zone_id)
	return true

func add_entity_to_zone(zone_id: String, entity_id: String, position: Vector3) -> bool:
	if not zones.has(zone_id):
		return false
	
	var zone = zones[zone_id]
	
	# Check if entity already exists in this zone
	if zone.entities.has(entity_id):
		# Update position
		zone.entities[entity_id] = position
		return true
	
	# Add entity
	zone.entities[entity_id] = position
	zone.entity_count += 1
	
	# Check if zone needs splitting
	if zone.entity_count > splitting_threshold and zone.child_zones.is_empty():
		_split_zone(zone_id)
	
	return true

func remove_entity_from_zone(zone_id: String, entity_id: String) -> bool:
	if not zones.has(zone_id):
		return false
	
	var zone = zones[zone_id]
	
	# Check if entity exists in this zone
	if not zone.entities.has(entity_id):
		return false
	
	# Remove entity
	zone.entities.erase(entity_id)
	zone.entity_count -= 1
	
	# Check if zone needs merging
	if zone.entity_count < merging_threshold and not zone.parent_zone.is_empty():
		_merge_zones(zone.parent_zone)
	
	return true

func get_entities_in_zone(zone_id: String) -> Dictionary:
	if not zones.has(zone_id):
		return {}
	
	return zones[zone_id].entities

func get_entities_at_position(position: Vector3, radius: float) -> Array:
	var result = []
	
	# Check each active zone
	for zone_id in active_zones:
		var zone = zones[zone_id]
		
		# Skip zone if position is outside bounds
		if not zone.bounds.has_point(position):
			continue
		
		# Check each entity
		for entity_id in zone.entities:
			var entity_pos = zone.entities[entity_id]
			
			# Check if entity is within radius
			if entity_pos.distance_to(position) <= radius:
				result.append(entity_id)
	
	return result

func activate_zone(zone_id: String) -> bool:
	if not zones.has(zone_id):
		return false
	
	# Skip if already active
	if active_zones.has(zone_id):
		return true
	
	# Add to active zones
	active_zones.append(zone_id)
	zones[zone_id].active = true
	
	# Ensure we don't exceed max active zones
	while active_zones.size() > max_active_zones:
		var oldest_zone_id = active_zones[0]
		active_zones.remove_at(0)
		zones[oldest_zone_id].active = false
	
	return true

func deactivate_zone(zone_id: String) -> bool:
	if not zones.has(zone_id) or not active_zones.has(zone_id):
		return false
	
	# Remove from active zones
	active_zones.erase(zone_id)
	zones[zone_id].active = false
	
	return true

func _split_zone(zone_id: String) -> bool:
	if not zones.has(zone_id):
		return false
	
	var zone = zones[zone_id]
	
	# Skip if zone already has children
	if not zone.child_zones.is_empty():
		return false
	
	# Calculate child zone bounds
	var bounds = zone.bounds
	var center = bounds.get_center()
	
	# Create 8 child zones (octants)
	var child_ids = []
	var child_bounds = []
	
	for x in range(2):
		for y in range(2):
			for z in range(2):
				var min_pos = Vector3(
					bounds.position.x + (x * bounds.size.x / 2),
					bounds.position.y + (y * bounds.size.y / 2),
					bounds.position.z + (z * bounds.size.z / 2)
				)
				var size = bounds.size / 2
				var child_bound = AABB(min_pos, size)
				child_bounds.append(child_bound)
				
				var child_id = zone_id + "_" + str(x) + str(y) + str(z)
				child_ids.append(child_id)
				
				create_zone(child_id, child_bound)
				zones[child_id].parent_zone = zone_id
				zone.child_zones.append(child_id)
	
	# Redistribute entities to child zones
	for entity_id in zone.entities:
		var entity_pos = zone.entities[entity_id]
		
		for i in range(child_bounds.size()):
			if child_bounds[i].has_point(entity_pos):
				add_entity_to_zone(child_ids[i], entity_id, entity_pos)
				break
	
	# Clear entities from parent zone
	zone.entities.clear()
	zone.entity_count = 0
	
	emit_signal("zone_split", zone_id, child_ids)
	
	return true

func _merge_zones(parent_zone_id: String) -> bool:
	if not zones.has(parent_zone_id):
		return false
	
	var parent_zone = zones[parent_zone_id]
	
	# Skip if no child zones
	if parent_zone.child_zones.is_empty():
		return false
	
	# Count total entities in child zones
	var total_entities = 0
	for child_id in parent_zone.child_zones:
		if zones.has(child_id):
			total_entities += zones[child_id].entity_count
	
	# Skip if too many entities
	if total_entities > max_entities_per_zone:
		return false
	
	# Collect child zone IDs
	var child_ids = parent_zone.child_zones.duplicate()
	
	# Merge entities from children to parent
	for child_id in child_ids:
		if zones.has(child_id):
			for entity_id in zones[child_id].entities:
				parent_zone.entities[entity_id] = zones[child_id].entities[entity_id]
			
			# Remove child zone
			remove_zone(child_id)
	
	# Update parent zone
	parent_zone.child_zones.clear()
	parent_zone.entity_count = parent_zone.entities.size()
	
	emit_signal("zone_merged", child_ids, parent_zone_id)
	
	return true

func save_zone(zone_id: String) -> bool:
	if not zones.has(zone_id):
		return false
	
	var file_path = zones_dir + zone_id + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		return false
	
	file.store_string(JSON.stringify(zones[zone_id], "  "))
	return true

func load_zone(zone_id: String) -> bool:
	var file_path = zones_dir + zone_id + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return false
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error != OK:
		return false
	
	var data = json.data
	zones[zone_id] = data
	
	return true
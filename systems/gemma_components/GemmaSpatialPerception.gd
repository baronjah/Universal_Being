# ==================================================
# SCRIPT NAME: GemmaSpatialPerception.gd
# DESCRIPTION: Gemma AI Spatial Perception System - 3D world understanding
# PURPOSE: Give Gemma spatial awareness and 3D navigation capabilities
# CREATED: 2025-06-04 - Gemma Spatial System
# AUTHOR: JSH + Claude Code + Gemma AI
# ==================================================
extends Node
class_name GemmaSpatialPerception

# Spatial analysis components
var spatial_memory: Dictionary = {}
var universal_beings_map: Dictionary = {}
var spatial_relationships: Array[Dictionary] = []

# Perception settings
@export var perception_radius: float = 50.0
@export var update_frequency: float = 0.5
@export var track_movement: bool = true
@export var analyze_relationships: bool = true

# 3D world data
var world_bounds: AABB
var current_focus_point: Vector3
var spatial_grid: Dictionary = {}

signal spatial_map_updated(map_data: Dictionary)
signal being_moved(being_id: String, old_pos: Vector3, new_pos: Vector3)
signal spatial_relationship_discovered(relationship: Dictionary)

func _ready():
	_initialize_spatial_systems()
	_start_spatial_monitoring()

func _initialize_spatial_systems():
	"""Initialize Gemma's spatial perception"""
	print("🗺️ GemmaSpatialPerception: Initializing spatial awareness...")
	
	# Initialize spatial grid for efficient tracking
	spatial_grid = {}
	spatial_memory = {
		"universal_beings": {},
		"interfaces": {},
		"structures": {},
		"boundaries": {}
	}
	
	# Set initial world bounds
	world_bounds = AABB(Vector3(-100, -100, -100), Vector3(200, 200, 200))
	current_focus_point = Vector3.ZERO
	
	print("🗺️ GemmaSpatialPerception: Spatial systems ready")

func _start_spatial_monitoring():
	"""Start continuous spatial monitoring"""
	var timer = Timer.new()
	timer.wait_time = update_frequency
	timer.autostart = true
	timer.timeout.connect(_update_spatial_perception)
	add_child(timer)

func _update_spatial_perception():
	"""Update spatial perception of the world"""
	var spatial_snapshot = _capture_spatial_snapshot()
	_process_spatial_data(spatial_snapshot)
	_analyze_spatial_relationships()

func _capture_spatial_snapshot() -> Dictionary:
	"""Capture current spatial state"""
	var beings_in_range = _scan_for_universal_beings()
	var interfaces_in_range = _scan_for_interfaces()
	
	return {
		"timestamp": Time.get_datetime_string_from_system(),
		"focus_point": current_focus_point,
		"perception_radius": perception_radius,
		"universal_beings": beings_in_range,
		"interfaces": interfaces_in_range,
		"spatial_density": _calculate_spatial_density(beings_in_range),
		"world_bounds": world_bounds
	}

func _scan_for_universal_beings() -> Array[Dictionary]:
	"""Scan for Universal Beings in perception range"""
	var detected_beings = []
	
	# Get all nodes in the scene
	var root = get_tree().current_scene
	if root:
		_recursive_scan_for_beings(root, detected_beings)
	
	return detected_beings

func _recursive_scan_for_beings(node: Node, detected_beings: Array):
	"""Recursively scan nodes for Universal Beings"""
	# Check if this node is a Universal Being
	if node.has_method("pentagon_init"):
		var being_data = _analyze_universal_being(node)
		if being_data:
			detected_beings.append(being_data)
	
	# Scan children
	for child in node.get_children():
		_recursive_scan_for_beings(child, detected_beings)

func _analyze_universal_being(being_node: Node) -> Dictionary:
	"""Analyze a Universal Being's spatial properties"""
	var spatial_data = {
		"id": being_node.name,
		"type": being_node.get_script().get_path() if being_node.get_script() else "unknown",
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"scale": Vector3.ONE,
		"bounds": AABB(),
		"is_interface": being_node.has_method("is_interface"),
		"socket_count": 0
	}
	
	# Get 3D transform data if available
	if being_node.has_method("get_global_transform"):
		var transform = being_node.get_global_transform()
		spatial_data.position = transform.origin
		spatial_data.rotation = transform.basis.get_euler()
	elif being_node is Node3D:
		spatial_data.position = being_node.global_position
		spatial_data.rotation = being_node.rotation
		spatial_data.scale = being_node.scale
	
	# Calculate bounds
	spatial_data.bounds = _calculate_being_bounds(being_node)
	
	# Check for sockets (Logic Connector integration)
	if being_node.has_method("get_socket_count"):
		spatial_data.socket_count = being_node.get_socket_count()
	
	return spatial_data

func _scan_for_interfaces() -> Array[Dictionary]:
	"""Scan for interface elements in perception range"""
	var detected_interfaces = []
	
	# Look for UniversalBeingInterface instances
	var root = get_tree().current_scene
	if root:
		_recursive_scan_for_interfaces(root, detected_interfaces)
	
	return detected_interfaces

func _recursive_scan_for_interfaces(node: Node, detected_interfaces: Array):
	"""Recursively scan for interface elements"""
	if node.has_method("is_interface") and node.is_interface():
		var interface_data = {
			"id": node.name,
			"type": "interface",
			"position": _get_interface_position(node),
			"size": _get_interface_size(node),
			"is_movable": node.get("is_movable") if node.has_method("get") else false,
			"is_resizable": node.get("is_resizable") if node.has_method("get") else false
		}
		detected_interfaces.append(interface_data)
	
	# Scan children
	for child in node.get_children():
		_recursive_scan_for_interfaces(child, detected_interfaces)

func _get_interface_position(interface_node: Node) -> Vector2:
	"""Get interface position (2D for UI elements)"""
	if interface_node is Control:
		return interface_node.global_position
	elif interface_node is Node3D:
		var pos_3d = interface_node.global_position
		return Vector2(pos_3d.x, pos_3d.z)  # Project to 2D
	return Vector2.ZERO

func _get_interface_size(interface_node: Node) -> Vector2:
	"""Get interface size"""
	if interface_node is Control:
		return interface_node.size
	return Vector2(100, 100)  # Default size

func _calculate_being_bounds(being_node: Node) -> AABB:
	"""Calculate bounding box for a Universal Being"""
	var bounds = AABB()
	
	if being_node is Node3D:
		# Start with the being's position
		bounds = AABB(being_node.global_position, Vector3(1, 1, 1))
		
		# Expand bounds to include all 3D children
		_expand_bounds_for_children(being_node, bounds)
	
	return bounds

func _expand_bounds_for_children(node: Node, bounds: AABB):
	"""Expand bounds to include all 3D children"""
	for child in node.get_children():
		if child is Node3D:
			bounds = bounds.expand(child.global_position)
		_expand_bounds_for_children(child, bounds)

func _calculate_spatial_density(beings: Array) -> float:
	"""Calculate spatial density of Universal Beings"""
	if beings.is_empty():
		return 0.0
	
	var total_volume = 0.0
	for being in beings:
		total_volume += being.bounds.get_volume()
	
	var perception_volume = (4.0 / 3.0) * PI * pow(perception_radius, 3)
	return total_volume / perception_volume

func _process_spatial_data(spatial_data: Dictionary):
	"""Process captured spatial data"""
	# Update spatial memory
	_update_spatial_memory(spatial_data)
	
	# Detect movement
	if track_movement:
		_detect_movement_changes(spatial_data)
	
	# Emit update signal
	spatial_map_updated.emit(spatial_data)

func _update_spatial_memory(spatial_data: Dictionary):
	"""Update spatial memory with new data"""
	# Update Universal Beings memory
	for being in spatial_data.universal_beings:
		var being_id = being.id
		var old_data = spatial_memory.universal_beings.get(being_id, {})
		spatial_memory.universal_beings[being_id] = being
		
		# Check for position changes
		if old_data.has("position") and old_data.position != being.position:
			being_moved.emit(being_id, old_data.position, being.position)

func _detect_movement_changes(spatial_data: Dictionary):
	"""Detect significant movement changes"""
	for being in spatial_data.universal_beings:
		var being_id = being.id
		if spatial_memory.universal_beings.has(being_id):
			var old_pos = spatial_memory.universal_beings[being_id].position
			var new_pos = being.position
			var distance = old_pos.distance_to(new_pos)
			
			if distance > 1.0:  # Significant movement threshold
				print("🗺️ Gemma detected movement: %s moved %.2f units" % [being_id, distance])

func _analyze_spatial_relationships():
	"""Analyze spatial relationships between Universal Beings"""
	if not analyze_relationships:
		return
	
	var beings = spatial_memory.universal_beings.values()
	spatial_relationships.clear()
	
	# Analyze proximity relationships
	for i in range(beings.size()):
		for j in range(i + 1, beings.size()):
			var relationship = _analyze_being_relationship(beings[i], beings[j])
			if relationship:
				spatial_relationships.append(relationship)

func _analyze_being_relationship(being1: Dictionary, being2: Dictionary) -> Dictionary:
	"""Analyze relationship between two Universal Beings"""
	var distance = being1.position.distance_to(being2.position)
	
	if distance < 5.0:  # Close proximity
		var relationship = {
			"being1": being1.id,
			"being2": being2.id,
			"type": "proximity",
			"distance": distance,
			"strength": 1.0 - (distance / 5.0),
			"timestamp": Time.get_datetime_string_from_system()
		}
		
		# Check for potential interactions
		if being1.socket_count > 0 and being2.socket_count > 0:
			relationship.type = "potential_connection"
			relationship.connection_potential = "high"
		
		return relationship
	
	return {}

func get_spatial_summary() -> Dictionary:
	"""Get summary of current spatial understanding"""
	var beings_count = spatial_memory.universal_beings.size()
	var interfaces_count = spatial_memory.interfaces.size()
	var active_relationships = spatial_relationships.size()
	
	return {
		"beings_tracked": beings_count,
		"interfaces_tracked": interfaces_count,
		"active_relationships": active_relationships,
		"perception_radius": perception_radius,
		"focus_point": current_focus_point,
		"world_bounds": world_bounds,
		"spatial_density": _calculate_current_density()
	}

func _calculate_current_density() -> float:
	"""Calculate current spatial density"""
	return _calculate_spatial_density(spatial_memory.universal_beings.values())

func focus_on_position(position: Vector3):
	"""Focus Gemma's spatial attention on a specific position"""
	current_focus_point = position
	print("🗺️ Gemma focusing on position: %s" % position)

func get_beings_near_position(position: Vector3, radius: float = 10.0) -> Array:
	"""Get Universal Beings near a specific position"""
	var nearby_beings = []
	
	for being in spatial_memory.universal_beings.values():
		if being.position.distance_to(position) <= radius:
			nearby_beings.append(being)
	
	return nearby_beings

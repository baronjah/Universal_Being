# Dynamic LOD System with Time-Based Transitions
# JSH #memories
extends Node3D
class_name DynamicLODSystem

signal lod_changed(entity: Node3D, new_lod: LODLevel)
signal entity_frozen(entity: Node3D)
signal entity_disappeared(entity: Node3D)

enum LODLevel {
	FULL_3D,      # Close - full detail
	SIMPLE_3D,    # Medium - cube/sphere
	BILLBOARD_2D, # Far - 2D sprite + label
	FROZEN,       # Very far + time - stops moving
	HIDDEN        # Too far/long - disappears
}

# LOD settings (configurable from debug room)
var lod_distances = {
	LODLevel.FULL_3D: 10.0,
	LODLevel.SIMPLE_3D: 25.0,
	LODLevel.BILLBOARD_2D: 50.0,
	LODLevel.FROZEN: 75.0,
	LODLevel.HIDDEN: 100.0
}

var time_thresholds = {
	"freeze_after": 5.0,      # Seconds before freezing
	"disappear_after": 10.0   # Seconds before hiding
}

# Tracked entities
var entities = {}
var camera: Camera3D

# Debug room connection
var debug_room_settings = {
	"enable_lod": true,
	"show_transitions": true,
	"auto_cleanup": true,
	"buffer_zone": 5.0  # Transition buffer distance
}

func _ready():
	print("🔄 Dynamic LOD System initialized")
	find_camera()
	set_process(true)

func find_camera():
	camera = get_viewport().get_camera_3d()
	if not camera:
		push_error("No camera found for LOD system")

func register_entity(entity: Node3D, initial_mode: String = "auto"):
	"""Register an entity for LOD management"""
	var entity_data = {
		"node": entity,
		"original_mesh": null,
		"simple_mesh": null,
		"billboard": null,
		"label": null,
		"current_lod": LODLevel.FULL_3D,
		"last_update": Time.get_ticks_msec() / 1000.0,
		"time_at_distance": 0.0,
		"frozen": false,
		"original_position": entity.global_position,
		"animation_player": null
	}
	
	# Store original mesh if exists
	if entity.has_node("MeshInstance3D"):
		entity_data.original_mesh = entity.get_node("MeshInstance3D")
	
	# Create simple mesh (cube/sphere)
	entity_data.simple_mesh = create_simple_mesh(entity)
	
	# Create billboard for 2D mode
	entity_data.billboard = create_billboard(entity)
	
	# Find animation player if exists
	if entity.has_node("AnimationPlayer"):
		entity_data.animation_player = entity.get_node("AnimationPlayer")
	
	entities[entity.get_instance_id()] = entity_data

func create_simple_mesh(entity: Node3D) -> MeshInstance3D:
	"""Create simplified cube/sphere mesh"""
	var simple = MeshInstance3D.new()
	
	# Determine shape based on entity name or type
	if "sphere" in entity.name.to_lower() or "planet" in entity.name.to_lower():
		simple.mesh = SphereMesh.new()
		simple.mesh.radial_segments = 8
		simple.mesh.rings = 4
	else:
		simple.mesh = BoxMesh.new()
	
	# Match size to original
	if entity.has_node("MeshInstance3D"):
		var original = entity.get_node("MeshInstance3D")
		simple.mesh.size = original.get_aabb().size
	
	simple.visible = false
	entity.add_child(simple)
	return simple

func create_billboard(entity: Node3D) -> Node3D:
	"""Create 2D billboard with label"""
	var billboard_container = Node3D.new()
	billboard_container.name = "BillboardLOD"
	
	# Create sprite
	var sprite = Sprite3D.new()
	sprite.texture = preload("res://icon.svg") # Default icon
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.modulate.a = 0.8
	billboard_container.add_child(sprite)
	
	# Create label
	var label = Label3D.new()
	label.text = entity.name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 1.0
	label.modulate = Color.WHITE
	billboard_container.add_child(label)
	
	billboard_container.visible = false
	entity.add_child(billboard_container)
	return billboard_container

func _process(delta):
	if not camera or not debug_room_settings.enable_lod:
		return
	
	var camera_pos = camera.global_position
	
	for entity_id in entities:
		var data = entities[entity_id]
		if not is_instance_valid(data.node):
			entities.erase(entity_id)
			continue
		
		update_entity_lod(data, camera_pos, delta)

func update_entity_lod(data: Dictionary, camera_pos: Vector3, delta: float):
	"""Update LOD level based on distance and time"""
	var entity = data.node
	var distance = entity.global_position.distance_to(camera_pos)
	
	# Determine target LOD based on distance
	var target_lod = LODLevel.FULL_3D
	for lod in LODLevel.values():
		if distance > lod_distances[lod]:
			target_lod = lod
		else:
			break
	
	# Time-based modifications
	if target_lod >= LODLevel.BILLBOARD_2D:
		data.time_at_distance += delta
		
		# Check for freeze
		if data.time_at_distance > time_thresholds.freeze_after and not data.frozen:
			target_lod = LODLevel.FROZEN
			freeze_entity(data)
		
		# Check for disappear
		if data.time_at_distance > time_thresholds.disappear_after:
			target_lod = LODLevel.HIDDEN
	else:
		data.time_at_distance = 0.0
		if data.frozen:
			unfreeze_entity(data)
	
	# Apply LOD with buffer zone
	if target_lod != data.current_lod:
		if should_transition(data.current_lod, target_lod, distance):
			apply_lod_level(data, target_lod)

func should_transition(current: LODLevel, target: LODLevel, distance: float) -> bool:
	"""Check if we should transition (with buffer zone)"""
	if not debug_room_settings.show_transitions:
		return true
	
	# Add hysteresis to prevent flickering
	var current_threshold = lod_distances[current]
	var target_threshold = lod_distances[target]
	var buffer = debug_room_settings.buffer_zone
	
	if target > current:  # Moving to lower detail
		return distance > target_threshold + buffer
	else:  # Moving to higher detail
		return distance < current_threshold - buffer

func apply_lod_level(data: Dictionary, new_lod: LODLevel):
	"""Apply new LOD level to entity"""
	var entity = data.node
	
	# Hide all representations first
	if data.original_mesh:
		data.original_mesh.visible = false
	if data.simple_mesh:
		data.simple_mesh.visible = false
	if data.billboard:
		data.billboard.visible = false
	
	# Show appropriate representation
	match new_lod:
		LODLevel.FULL_3D:
			if data.original_mesh:
				data.original_mesh.visible = true
		
		LODLevel.SIMPLE_3D:
			if data.simple_mesh:
				data.simple_mesh.visible = true
		
		LODLevel.BILLBOARD_2D:
			if data.billboard:
				data.billboard.visible = true
		
		LODLevel.FROZEN:
			if data.billboard:
				data.billboard.visible = true
		
		LODLevel.HIDDEN:
			entity.visible = false
	
	# Update state
	data.current_lod = new_lod
	lod_changed.emit(entity, new_lod)
	
	# Restore visibility if coming back from hidden
	if new_lod != LODLevel.HIDDEN and not entity.visible:
		entity.visible = true

func freeze_entity(data: Dictionary):
	"""Freeze entity animation and movement"""
	data.frozen = true
	data.frozen_position = data.node.global_position
	
	# Pause animations
	if data.animation_player:
		data.animation_player.pause()
	
	# Disable physics if applicable
	if data.node.has_method("set_physics_process"):
		data.node.set_physics_process(false)
	
	entity_frozen.emit(data.node)

func unfreeze_entity(data: Dictionary):
	"""Unfreeze entity"""
	data.frozen = false
	
	# Resume animations
	if data.animation_player:
		data.animation_player.play()
	
	# Re-enable physics
	if data.node.has_method("set_physics_process"):
		data.node.set_physics_process(true)

func update_settings(new_settings: Dictionary):
	"""Update LOD settings from debug room"""
	for key in new_settings:
		if key in debug_room_settings:
			debug_room_settings[key] = new_settings[key]
		elif key in lod_distances:
			lod_distances[key] = new_settings[key]
		elif key in time_thresholds:
			time_thresholds[key] = new_settings[key]

# Manual control functions for debug room
func force_lod_level(entity: Node3D, level: LODLevel):
	"""Force specific LOD level for testing"""
	var entity_id = entity.get_instance_id()
	if entity_id in entities:
		apply_lod_level(entities[entity_id], level)

func get_entity_info(entity: Node3D) -> Dictionary:
	"""Get current LOD info for entity"""
	var entity_id = entity.get_instance_id()
	if entity_id in entities:
		var data = entities[entity_id]
		return {
			"current_lod": LODLevel.keys()[data.current_lod],
			"distance": entity.global_position.distance_to(camera.global_position),
			"time_at_distance": data.time_at_distance,
			"frozen": data.frozen
		}
	return {}
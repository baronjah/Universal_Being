# ==================================================
# UNIVERSAL BEING: OcclusionCullingSystem
# TYPE: performance optimization
# PURPOSE: Bring peace to Akashic Records through intelligent occlusion
# COMPONENTS: LOD management, distance culling, frustum culling
# ==================================================

extends Node
class_name OcclusionCullingSystem

## Performance Settings
@export var max_visible_distance: float = 100.0
@export var lod_distance_near: float = 20.0  
@export var lod_distance_far: float = 50.0
@export var update_frequency: float = 0.2  # Update every 0.2 seconds

## Culling State
var camera: Camera3D
var cullable_objects: Array = []
var last_update_time: float = 0.0
var culling_active: bool = true

## Peace Statistics
var objects_culled: int = 0
var objects_visible: int = 0
var akashic_peace_level: float = 1.0

signal peace_achieved(peace_level: float)

func _ready():
	set_process(true)
	add_to_group("performance_systems")

func _process(delta):
	if not culling_active:
		return
		
	var current_time = Time.get_ticks_msec() * 0.001
	if current_time - last_update_time < update_frequency:
		return
	
	last_update_time = current_time
	update_occlusion_culling()

func initialize_with_camera(target_camera: Camera3D):
	"""Initialize occlusion culling with target camera"""
	camera = target_camera
	gather_cullable_objects()
	calculate_initial_peace()

func gather_cullable_objects():
	"""Find all objects that can be culled for performance"""
	cullable_objects.clear()
	
	# Find all Universal Beings and 3D objects
	var scene_tree = get_tree().current_scene
	gather_objects_recursive(scene_tree)
	
	print("🕊️ OcclusionCulling: Found ", cullable_objects.size(), " objects to manage")

func gather_objects_recursive(node: Node):
	"""Recursively gather all cullable objects"""
	if node is MeshInstance3D or node is Label3D or node is GPUParticles3D:
		if not node.has_meta("occlusion_exempt"):  # Allow objects to opt out
			cullable_objects.append({
				"node": node,
				"original_visible": node.visible,
				"distance": 0.0,
				"culled": false,
				"lod_level": 0
			})
	
	for child in node.get_children():
		gather_objects_recursive(child)

func update_occlusion_culling():
	"""Main occlusion culling update loop"""
	if not camera:
		return
	
	var camera_pos = camera.global_position
	var camera_transform = camera.global_transform
	objects_culled = 0
	objects_visible = 0
	
	for obj_data in cullable_objects:
		var node = obj_data.node
		if not is_instance_valid(node):
			continue
		
		var distance = camera_pos.distance_to(node.global_position)
		obj_data.distance = distance
		
		# Distance culling
		if distance > max_visible_distance:
			cull_object(obj_data, "distance")
			continue
		
		# Frustum culling (basic implementation)
		if not is_in_camera_frustum(node, camera_transform):
			cull_object(obj_data, "frustum")
			continue
		
		# LOD management
		apply_lod_level(obj_data, distance)
		
		# Object is visible
		uncull_object(obj_data)
		objects_visible += 1
	
	# Calculate peace level based on culling efficiency
	calculate_akashic_peace()

func is_in_camera_frustum(node: Node3D, camera_transform: Transform3D) -> bool:
	"""Basic frustum culling check"""
	var to_object = node.global_position - camera_transform.origin
	var forward = -camera_transform.basis.z
	
	# Simple dot product check for forward direction
	var dot = to_object.normalized().dot(forward)
	return dot > -0.5  # Allow wide field of view

func cull_object(obj_data: Dictionary, reason: String):
	"""Hide object to save performance"""
	var node = obj_data.node
	if node.visible:
		node.visible = false
		obj_data.culled = true
		objects_culled += 1

func uncull_object(obj_data: Dictionary):
	"""Show object again"""
	var node = obj_data.node
	if not node.visible and obj_data.original_visible:
		node.visible = true
		obj_data.culled = false

func apply_lod_level(obj_data: Dictionary, distance: float):
	"""Apply Level of Detail based on distance"""
	var node = obj_data.node
	var lod_level = 0
	
	if distance > lod_distance_far:
		lod_level = 2  # Lowest detail
	elif distance > lod_distance_near:
		lod_level = 1  # Medium detail
	else:
		lod_level = 0  # Full detail
	
	obj_data.lod_level = lod_level
	
	# Apply LOD effects
	match lod_level:
		0:  # Full detail
			if node is Label3D:
				node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		1:  # Medium detail  
			if node is Label3D:
				node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		2:  # Low detail
			if node is Label3D:
				node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			# Could reduce mesh complexity, disable shadows, etc.

func calculate_akashic_peace():
	"""Calculate peace level based on performance optimization"""
	var total_objects = cullable_objects.size()
	if total_objects == 0:
		akashic_peace_level = 1.0
		return
	
	var culling_efficiency = float(objects_culled) / float(total_objects)
	var performance_factor = 1.0 - (float(objects_visible) / 100.0)  # Assume 100 is max comfortable
	
	akashic_peace_level = (culling_efficiency * 0.7) + (performance_factor * 0.3)
	akashic_peace_level = clamp(akashic_peace_level, 0.0, 1.0)
	
	peace_achieved.emit(akashic_peace_level)

func calculate_initial_peace():
	"""Calculate initial peace level"""
	akashic_peace_level = 1.0
	peace_achieved.emit(akashic_peace_level)

func get_peace_report() -> Dictionary:
	"""Get detailed peace report"""
	return {
		"total_objects": cullable_objects.size(),
		"objects_visible": objects_visible,
		"objects_culled": objects_culled,
		"peace_level": akashic_peace_level,
		"culling_active": culling_active,
		"camera_position": camera.global_position if camera else Vector3.ZERO
	}

func set_culling_active(active: bool):
	"""Enable/disable occlusion culling"""
	culling_active = active
	if not active:
		# Restore all objects
		for obj_data in cullable_objects:
			uncull_object(obj_data)

func bring_peace_to_akashic_records():
	"""Special function to optimize all Akashic Records for peace"""
	print("🕊️ Bringing peace to Akashic Records...")
	
	# Find all record-related objects
	var record_objects = []
	for obj_data in cullable_objects:
		var node = obj_data.node
		if node.has_meta("semantic_id") or node.has_meta("akashic_record"):
			record_objects.append(obj_data)
	
	# Apply peaceful optimization
	for obj_data in record_objects:
		if obj_data.distance > lod_distance_far:
			# Transform to peaceful icon representation
			apply_peaceful_lod(obj_data)
	
	print("🕊️ Peace brought to ", record_objects.size(), " Akashic Records")

func apply_peaceful_lod(obj_data: Dictionary):
	"""Apply peaceful LOD transformation"""
	var node = obj_data.node
	
	# For distant objects, apply peaceful effects
	if node is MeshInstance3D:
		var material = node.material_override as StandardMaterial3D
		if material:
			# Reduce emission for distant objects (peaceful dimming)
			material.emission_energy *= 0.5
	
	elif node is Label3D:
		# Fade distant text peacefully
		node.modulate.a = 0.7
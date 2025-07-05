extends Node
class_name TransparencyAwareOcclusionCuller

# 🌟 TRANSPARENCY-AWARE OCCLUSION CULLING 🌟
# Handles occlusion where transparent objects don't block visibility
# But limits depth checking to prevent infinite ray-checking (max 3 objects behind)

signal object_occluded(object: Node3D, occluder: Node3D)
signal object_revealed(object: Node3D, was_occluded_by: Node3D)
signal transparency_depth_limit_reached(object: Node3D, depth: int)

# Occlusion culling parameters
@export var max_transparency_depth: int = 3  # Max objects to check behind transparent ones
@export var transparency_threshold: float = 0.8  # Alpha below this = transparent
@export var occlusion_distance_threshold: float = 0.1  # How close = occluded
@export var enabled: bool = true

# Culling state
var culled_objects: Dictionary = {}  # object -> occluder info
var transparency_cache: Dictionary = {}  # object -> transparency info
var occlusion_queries: Array[Dictionary] = []
var camera_position: Vector3 = Vector3.ZERO
var camera_direction: Vector3 = Vector3.FORWARD

# Performance optimization
var frame_counter: int = 0
var update_frequency: int = 3  # Update every 3 frames for performance

func _ready():
	name = "TransparencyAwareOcclusionCuller"
	print("👁️ Transparency-Aware Occlusion Culler initialized")

func _process(delta: float):
	if not enabled:
		return
	
	frame_counter += 1
	if frame_counter % update_frequency == 0:
		update_camera_info()
		perform_occlusion_culling()

func update_camera_info():
	"""Update camera position and direction for occlusion calculations"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		camera_position = camera.global_position
		camera_direction = -camera.global_transform.basis.z.normalized()

func perform_occlusion_culling():
	"""Perform transparency-aware occlusion culling on all registered objects"""
	if not get_tree() or not get_tree().current_scene:
		return
	
	var scene_objects = find_cullable_objects()
	
	# Clear previous culling state
	var previously_culled = culled_objects.keys()
	culled_objects.clear()
	
	# Test each object for occlusion
	for target_object in scene_objects:
		if not is_instance_valid(target_object):
			continue
		
		var occlusion_result = test_object_occlusion(target_object, scene_objects)
		
		if occlusion_result.is_occluded:
			# Object is occluded
			culled_objects[target_object] = occlusion_result
			target_object.visible = false
			
			if target_object not in previously_culled:
				object_occluded.emit(target_object, occlusion_result.occluder)
		else:
			# Object is visible
			target_object.visible = true
			
			if target_object in previously_culled:
				object_revealed.emit(target_object, previously_culled[target_object])

func find_cullable_objects() -> Array[Node3D]:
	"""Find all objects that can be occlusion culled"""
	var objects: Array[Node3D] = []
	
	if not get_tree().current_scene:
		return objects
	
	# Find all MeshInstance3D nodes in the scene
	var stack = [get_tree().current_scene]
	
	while stack.size() > 0:
		var current = stack.pop_back()
		
		if current is MeshInstance3D:
			objects.append(current)
		
		for child in current.get_children():
			if child is Node3D:
				stack.append(child)
	
	return objects

func test_object_occlusion(target: Node3D, all_objects: Array[Node3D]) -> Dictionary:
	"""Test if target object is occluded by other objects"""
	var target_position = target.global_position
	var camera_to_target = target_position - camera_position
	var target_distance = camera_to_target.length()
	
	if target_distance < 0.1:  # Too close to camera
		return {"is_occluded": false}
	
	var ray_direction = camera_to_target.normalized()
	
	# Find potential occluders between camera and target
	var potential_occluders = []
	
	for other_object in all_objects:
		if other_object == target or not is_instance_valid(other_object):
			continue
		
		var other_position = other_object.global_position
		var camera_to_other = other_position - camera_position
		var other_distance = camera_to_other.length()
		
		# Skip objects behind the target
		if other_distance >= target_distance:
			continue
		
		# Check if object is in the ray path
		if is_object_in_ray_path(camera_position, ray_direction, target_distance, other_object):
			potential_occluders.append({
				"object": other_object,
				"distance": other_distance,
				"transparency": get_object_transparency(other_object)
			})
	
	# Sort occluders by distance (closest first)
	potential_occluders.sort_custom(func(a, b): return a.distance < b.distance)
	
	# Test occlusion with transparency awareness
	return test_transparency_aware_occlusion(target, potential_occluders, ray_direction)

func is_object_in_ray_path(ray_origin: Vector3, ray_direction: Vector3, ray_distance: float, object: Node3D) -> bool:
	"""Check if object intersects with the camera-to-target ray"""
	var object_position = object.global_position
	var object_bounds = get_object_bounds(object)
	
	# Simple sphere-ray intersection for performance
	var ray_to_object = object_position - ray_origin
	var projected_distance = ray_to_object.dot(ray_direction)
	
	# Object behind camera or beyond target
	if projected_distance < 0 or projected_distance > ray_distance:
		return false
	
	var closest_point_on_ray = ray_origin + ray_direction * projected_distance
	var distance_to_ray = object_position.distance_to(closest_point_on_ray)
	
	# Check if object bounds intersect ray
	return distance_to_ray <= object_bounds.radius

func get_object_bounds(object: Node3D) -> Dictionary:
	"""Get object bounding information"""
	var bounds = {"radius": 1.0, "center": object.global_position}
	
	if object is MeshInstance3D:
		var mesh_instance = object as MeshInstance3D
		if mesh_instance.mesh:
			var aabb = mesh_instance.get_aabb()
			bounds.radius = aabb.size.length() * 0.5
			bounds.center = object.global_position + aabb.get_center()
	
	return bounds

func get_object_transparency(object: Node3D) -> float:
	"""Get object transparency level (0.0 = opaque, 1.0 = fully transparent)"""
	if transparency_cache.has(object):
		return transparency_cache[object]
	
	var transparency = 0.0  # Default: opaque
	
	if object is MeshInstance3D:
		var mesh_instance = object as MeshInstance3D
		var material = mesh_instance.get_surface_override_material(0)
		
		if not material:
			material = mesh_instance.material_override
		
		if material is StandardMaterial3D:
			var std_material = material as StandardMaterial3D
			
			# Check if material is transparent
			if std_material.flags_transparent:
				transparency = 1.0 - std_material.albedo_color.a
			
			# Additional transparency checks
			if std_material.flags_use_point_size:
				transparency = max(transparency, 0.3)  # Point materials are somewhat transparent
	
	# Cache the result
	transparency_cache[object] = transparency
	
	return transparency

func test_transparency_aware_occlusion(target: Node3D, occluders: Array, ray_direction: Vector3) -> Dictionary:
	"""Test occlusion with transparency awareness and depth limits"""
	var opaque_occluders = []
	var transparent_occluders = []
	var depth_checked = 0
	
	# Separate opaque and transparent occluders
	for occluder_info in occluders:
		var transparency = occluder_info.transparency
		
		if transparency < transparency_threshold:
			# Opaque object
			opaque_occluders.append(occluder_info)
		else:
			# Transparent object
			transparent_occluders.append(occluder_info)
			depth_checked += 1
			
			# CRITICAL: Limit transparency depth checking to max 3 objects
			if depth_checked >= max_transparency_depth:
				transparency_depth_limit_reached.emit(target, depth_checked)
				break
	
	# If any opaque object is in the way, target is occluded
	if opaque_occluders.size() > 0:
		var closest_opaque = opaque_occluders[0]
		return {
			"is_occluded": true,
			"occluder": closest_opaque.object,
			"occluder_type": "opaque",
			"occluder_distance": closest_opaque.distance,
			"transparency_depth": depth_checked
		}
	
	# Check if multiple transparent objects create effective occlusion
	if transparent_occluders.size() >= 2:
		# Multiple transparent objects can create cumulative occlusion
		var cumulative_opacity = 0.0
		var effective_occluders = []
		
		for i in range(min(transparent_occluders.size(), max_transparency_depth)):
			var occluder = transparent_occluders[i]
			var opacity = 1.0 - occluder.transparency
			cumulative_opacity += opacity * (1.0 - cumulative_opacity)  # Cumulative opacity formula
			effective_occluders.append(occluder)
			
			# If cumulative opacity is high enough, consider occluded
			if cumulative_opacity > 0.9:
				return {
					"is_occluded": true,
					"occluder": effective_occluders[0].object,
					"occluder_type": "cumulative_transparent",
					"occluder_count": effective_occluders.size(),
					"cumulative_opacity": cumulative_opacity,
					"transparency_depth": i + 1
				}
	
	# Object is visible
	return {
		"is_occluded": false,
		"transparency_depth": depth_checked,
		"transparent_objects_in_path": transparent_occluders.size()
	}

func clear_transparency_cache():
	"""Clear the transparency cache (call when materials change)"""
	transparency_cache.clear()
	print("👁️ Transparency cache cleared")

func set_transparency_threshold(threshold: float):
	"""Set the threshold for what constitutes transparent"""
	transparency_threshold = clamp(threshold, 0.0, 1.0)
	clear_transparency_cache()  # Recalculate with new threshold
	print("👁️ Transparency threshold updated: %.2f" % transparency_threshold)

func set_max_transparency_depth(depth: int):
	"""Set maximum depth for checking behind transparent objects"""
	max_transparency_depth = max(1, depth)
	print("👁️ Max transparency depth updated: %d" % max_transparency_depth)

func get_occlusion_stats() -> Dictionary:
	"""Get occlusion culling statistics"""
	return {
		"total_culled_objects": culled_objects.size(),
		"transparency_cache_size": transparency_cache.size(),
		"max_transparency_depth": max_transparency_depth,
		"transparency_threshold": transparency_threshold,
		"enabled": enabled,
		"update_frequency": update_frequency
	}

func force_occlusion_update():
	"""Force immediate occlusion update (bypass frame timing)"""
	update_camera_info()
	perform_occlusion_culling()
	print("👁️ Forced occlusion update complete")

# ===== DEBUG FUNCTIONS =====

func debug_draw_occlusion_rays():
	"""Debug visualization of occlusion rays (would need DebugDraw3D)"""
	print("👁️ Debug: Camera at %s, direction %s" % [camera_position, camera_direction])
	
	for target in culled_objects:
		var occlusion_info = culled_objects[target]
		print("  🚫 %s occluded by %s (%s)" % [
			target.name, 
			occlusion_info.get("occluder", {}).get("name", "unknown"),
			occlusion_info.get("occluder_type", "unknown")
		])

func debug_transparency_info():
	"""Debug transparency information for all cached objects"""
	print("👁️ Transparency Cache:")
	for object in transparency_cache:
		print("  💎 %s: %.2f transparency" % [object.name, transparency_cache[object]])

# 🌟 TRANSPARENCY-AWARE OCCLUSION CULLING COMPLETE! 🌟
# Ready to handle transparent objects without blocking visibility while limiting depth checks!
extends Node3D
class_name TerrainWarper

# Handles terrain easing and warping for memory-influenced reality distortions
# "The land remembers, and memory changes the shape of reality"

signal terrain_warped(center: Vector3, radius: float, intensity: float)
signal easing_applied(area: AABB, softness: float)

# Warping parameters
@export var max_warp_intensity: float = 2.0
@export var warp_falloff_distance: float = 10.0
@export var memory_influence_strength: float = 0.5
@export var temporal_warp_decay: float = 0.1

# Terrain modification
var warp_fields: Array[Dictionary] = []
var easing_zones: Array[Dictionary] = []
var original_terrain_data: Dictionary = {}

# Physics and rendering
var terrain_bodies: Array[StaticBody3D] = []
var terrain_meshes: Array[MeshInstance3D] = []

func _ready():
	# Find existing terrain in scene
	_discover_terrain()

func _process(delta):
	_update_warp_fields(delta)
	_apply_active_warps()

func _discover_terrain():
	# Find terrain objects in the scene
	var terrain_nodes = get_tree().get_nodes_in_group("terrain")
	
	for node in terrain_nodes:
		if node is StaticBody3D:
			terrain_bodies.append(node)
			_store_original_terrain_data(node)
		elif node is MeshInstance3D:
			terrain_meshes.append(node)
			_store_original_mesh_data(node)

func _store_original_terrain_data(body: StaticBody3D):
	var id = body.get_instance_id()
	original_terrain_data[id] = {
		"position": body.global_position,
		"rotation": body.global_rotation,
		"scale": body.scale
	}

func _store_original_mesh_data(mesh_instance: MeshInstance3D):
	var id = mesh_instance.get_instance_id()
	if mesh_instance.mesh:
		original_terrain_data[id] = {
			"mesh": mesh_instance.mesh.duplicate(),
			"position": mesh_instance.global_position,
			"scale": mesh_instance.scale
		}

# Memory-influenced terrain warping
func warp_from_memory(notepad: Notepad3D, center: Vector3, influence_radius: float = 5.0):
	if not notepad:
		return
	
	# Find memories near the center point
	var center_int = Vector3i(center)
	var warp_vector = Vector3.ZERO
	var emotion_accumulator = 0.0
	var memory_count = 0
	
	# Sample memories in a radius around center
	for x in range(-int(influence_radius), int(influence_radius) + 1):
		for y in range(-int(influence_radius), int(influence_radius) + 1):
			for z in range(-int(influence_radius), int(influence_radius) + 1):
				var sample_pos = center_int + Vector3i(x, y, z)
				var distance = Vector3(x, y, z).length()
				
				if distance <= influence_radius:
					var memory = notepad.get_cell(sample_pos)
					if not memory.is_empty():
						var memory_warp = memory.get("warp", Vector3.ZERO)
						var emotion = memory.get("emotion", 0.5)
						var fade = memory.get("fade", 1.0)
						
						# Weight by distance and fade
						var weight = (1.0 - distance / influence_radius) * fade
						warp_vector += memory_warp * weight * emotion
						emotion_accumulator += emotion * weight
						memory_count += 1
	
	if memory_count > 0:
		# Average the warp effects
		warp_vector /= memory_count
		emotion_accumulator /= memory_count
		
		# Apply the memory-influenced warp
		apply_warp_field(center, influence_radius, warp_vector, emotion_accumulator)

func apply_warp_field(center: Vector3, radius: float, warp_vector: Vector3, intensity: float = 1.0):
	var warp_field = {
		"center": center,
		"radius": radius,
		"warp_vector": warp_vector * memory_influence_strength,
		"intensity": clamp(intensity, 0.0, max_warp_intensity),
		"creation_time": Time.get_time_dict_from_system()["unix"],
		"active": true
	}
	
	warp_fields.append(warp_field)
	terrain_warped.emit(center, radius, intensity)
	
	print("🌀 Terrain warp applied at ", center, " with intensity ", intensity)

func apply_easing_zone(area: AABB, softness: float, duration: float = -1.0):
	var easing_zone = {
		"area": area,
		"softness": clamp(softness, 0.0, 1.0),
		"duration": duration,
		"creation_time": Time.get_time_dict_from_system()["unix"],
		"active": true
	}
	
	easing_zones.append(easing_zone)
	easing_applied.emit(area, softness)
	
	print("🌊 Easing zone applied: ", area, " softness: ", softness)

func _update_warp_fields(delta: float):
	var current_time = Time.get_time_dict_from_system()["unix"]
	
	# Update and expire warp fields
	for i in range(warp_fields.size() - 1, -1, -1):
		var field = warp_fields[i]
		var age = current_time - field["creation_time"]
		
		# Natural decay over time
		field["intensity"] *= (1.0 - temporal_warp_decay * delta)
		
		# Remove if intensity too low
		if field["intensity"] < 0.01:
			warp_fields.remove_at(i)
	
	# Update easing zones
	for i in range(easing_zones.size() - 1, -1, -1):
		var zone = easing_zones[i]
		var age = current_time - zone["creation_time"]
		
		# Check if duration expired
		if zone["duration"] > 0 and age > zone["duration"]:
			easing_zones.remove_at(i)

func _apply_active_warps():
	# Apply warps to terrain bodies
	for body in terrain_bodies:
		if is_instance_valid(body):
			_apply_warps_to_body(body)
	
	# Apply warps to mesh instances
	for mesh_instance in terrain_meshes:
		if is_instance_valid(mesh_instance):
			_apply_warps_to_mesh(mesh_instance)

func _apply_warps_to_body(body: StaticBody3D):
	var id = body.get_instance_id()
	var original = original_terrain_data.get(id, {})
	
	if original.is_empty():
		return
	
	var total_warp = Vector3.ZERO
	var total_intensity = 0.0
	
	# Calculate cumulative warp effect
	for field in warp_fields:
		var distance = body.global_position.distance_to(field["center"])
		if distance <= field["radius"]:
			var influence = 1.0 - (distance / field["radius"])
			influence = influence * influence  # Quadratic falloff
			
			total_warp += field["warp_vector"] * influence * field["intensity"]
			total_intensity += influence * field["intensity"]
	
	# Apply warp to position and rotation
	if total_intensity > 0.01:
		var base_position = original.get("position", body.global_position)
		var warped_position = base_position + total_warp
		
		# Smooth interpolation to avoid jittering
		body.global_position = body.global_position.lerp(warped_position, 0.1)
		
		# Apply slight rotation based on warp direction
		if total_warp.length() > 0.1:
			var warp_rotation = total_warp.normalized() * total_intensity * 0.1
			body.global_rotation += warp_rotation * 0.1

func _apply_warps_to_mesh(mesh_instance: MeshInstance3D):
	var id = mesh_instance.get_instance_id()
	var original = original_terrain_data.get(id, {})
	
	if original.is_empty() or not mesh_instance.mesh:
		return
	
	# Check if this mesh is affected by any warp fields
	var affected = false
	var total_warp = Vector3.ZERO
	
	for field in warp_fields:
		var distance = mesh_instance.global_position.distance_to(field["center"])
		if distance <= field["radius"]:
			affected = true
			var influence = 1.0 - (distance / field["radius"])
			total_warp += field["warp_vector"] * influence * field["intensity"]
	
	if affected:
		# Apply vertex-level warping for detailed terrain deformation
		_warp_mesh_vertices(mesh_instance, total_warp)

func _warp_mesh_vertices(mesh_instance: MeshInstance3D, warp_vector: Vector3):
	# This is a simplified version - real implementation would modify vertex data
	# For now, we'll use scale and position adjustments
	
	var warp_strength = warp_vector.length()
	if warp_strength > 0.01:
		# Apply subtle scale warping
		var scale_factor = 1.0 + warp_strength * 0.1
		var target_scale = mesh_instance.scale * scale_factor
		mesh_instance.scale = mesh_instance.scale.lerp(target_scale, 0.05)
		
		# Apply position offset
		var offset = warp_vector * 0.1
		mesh_instance.global_position += offset * 0.05

# Procedural terrain modification
func create_hill(center: Vector3, radius: float, height: float):
	# Create a hill using constructive terrain modification
	var hill_field = {
		"center": center,
		"radius": radius,
		"warp_vector": Vector3(0, height, 0),
		"intensity": 1.0,
		"creation_time": Time.get_time_dict_from_system()["unix"],
		"active": true,
		"type": "hill"
	}
	
	warp_fields.append(hill_field)
	print("⛰️ Hill created at ", center, " height: ", height)

func create_valley(center: Vector3, radius: float, depth: float):
	# Create a valley using destructive terrain modification
	var valley_field = {
		"center": center,
		"radius": radius,
		"warp_vector": Vector3(0, -depth, 0),
		"intensity": 1.0,
		"creation_time": Time.get_time_dict_from_system()["unix"],
		"active": true,
		"type": "valley"
	}
	
	warp_fields.append(valley_field)
	print("🕳️ Valley created at ", center, " depth: ", depth)

func soften_terrain_area(center: Vector3, radius: float, softness: float = 0.8):
	# Create a soft terrain area that's easier to modify
	var area = AABB(center - Vector3.ONE * radius, Vector3.ONE * radius * 2)
	apply_easing_zone(area, softness)

func crystallize_terrain_area(center: Vector3, radius: float):
	# Make terrain harder and more resistant to change
	var area = AABB(center - Vector3.ONE * radius, Vector3.ONE * radius * 2)
	apply_easing_zone(area, 0.1)  # Very hard

# Dream-influenced terrain effects
func apply_dream_distortion(center: Vector3, dream_intensity: float, surreal_factor: float):
	# Dreams cause reality to bend in impossible ways
	var dream_warp = Vector3(
		sin(Time.get_time_dict_from_system()["unix"] + center.x) * surreal_factor,
		cos(Time.get_time_dict_from_system()["unix"] + center.y) * surreal_factor,
		sin(Time.get_time_dict_from_system()["unix"] + center.z) * surreal_factor
	) * dream_intensity
	
	apply_warp_field(center, 3.0, dream_warp, dream_intensity)

func create_memory_resonance(memories: Array, base_position: Vector3):
	# Multiple memories create resonance patterns in terrain
	if memories.size() < 2:
		return
	
	var resonance_center = base_position
	var total_emotion = 0.0
	
	# Calculate resonance center and intensity
	for memory in memories:
		var pos = memory.get("position", base_position)
		var emotion = memory.get("data", {}).get("emotion", 0.5)
		resonance_center += Vector3(pos) * emotion
		total_emotion += emotion
	
	if total_emotion > 0:
		resonance_center /= total_emotion
		
		# Create standing wave pattern
		var wave_amplitude = total_emotion * 0.5
		var wave_frequency = memories.size() * 0.1
		
		# Apply multiple small warp fields in a pattern
		for i in range(8):  # 8-point resonance pattern
			var angle = (PI * 2.0 * i) / 8.0
			var offset = Vector3(cos(angle), 0, sin(angle)) * 2.0
			var warp_pos = resonance_center + offset
			
			var wave_warp = Vector3(0, sin(angle * wave_frequency) * wave_amplitude, 0)
			apply_warp_field(warp_pos, 1.0, wave_warp, 0.3)

# Utility functions
func reset_terrain():
	# Reset all terrain to original state
	warp_fields.clear()
	easing_zones.clear()
	
	for body in terrain_bodies:
		if is_instance_valid(body):
			var id = body.get_instance_id()
			var original = original_terrain_data.get(id, {})
			if not original.is_empty():
				body.global_position = original.get("position", body.global_position)
				body.global_rotation = original.get("rotation", body.global_rotation)
				body.scale = original.get("scale", body.scale)

func get_warp_intensity_at(position: Vector3) -> float:
	var total_intensity = 0.0
	
	for field in warp_fields:
		var distance = position.distance_to(field["center"])
		if distance <= field["radius"]:
			var influence = 1.0 - (distance / field["radius"])
			total_intensity += influence * field["intensity"]
	
	return total_intensity

func get_terrain_softness_at(position: Vector3) -> float:
	var softness = 0.5  # Default terrain softness
	
	for zone in easing_zones:
		if zone["area"].has_point(position):
			softness = zone["softness"]
			break  # Use the first matching zone
	
	return softness

func get_active_effects_count() -> Dictionary:
	return {
		"warp_fields": warp_fields.size(),
		"easing_zones": easing_zones.size(),
		"total_terrain_objects": terrain_bodies.size() + terrain_meshes.size()
	}
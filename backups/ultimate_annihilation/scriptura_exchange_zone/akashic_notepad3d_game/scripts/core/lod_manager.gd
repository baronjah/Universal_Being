extends Node
## LOD (Level of Detail) Manager
## Manages word display detail based on camera distance and viewing angle
class_name LODManager

# LOD distance thresholds
const LOD_CLOSE = 15.0      # High detail - full text, glow, animation
const LOD_MEDIUM = 30.0     # Medium detail - text visible, reduced effects
const LOD_FAR = 50.0        # Low detail - simple shapes, no text
const LOD_VERY_FAR = 80.0   # Minimal detail - tiny dots or hidden

# Camera reference
var camera: Camera3D
var word_entities: Array = []

# LOD settings
var enable_distance_lod: bool = true
var enable_angle_lod: bool = true
var enable_frustum_culling: bool = true

func initialize(camera_node: Camera3D) -> void:
	camera = camera_node
	print("LOD Manager initialized")

func register_word_entity(word_entity: WordEntity) -> void:
	if word_entity not in word_entities:
		word_entities.append(word_entity)

func unregister_word_entity(word_entity: WordEntity) -> void:
	word_entities.erase(word_entity)

func update_lod_system(delta: float) -> void:
	if not camera:
		return
	
	var camera_pos = camera.global_position
	var camera_forward = -camera.global_transform.basis.z
	
	for word_entity in word_entities:
		if not is_instance_valid(word_entity):
			continue
			
		_update_word_lod(word_entity, camera_pos, camera_forward)

func _update_word_lod(word_entity: WordEntity, camera_pos: Vector3, camera_forward: Vector3) -> void:
	var word_pos = word_entity.global_position
	var distance = camera_pos.distance_to(word_pos)
	
	# Calculate viewing angle
	var to_word = (word_pos - camera_pos).normalized()
	var angle_factor = camera_forward.dot(to_word)
	
	# Determine LOD level
	var lod_level = _calculate_lod_level(distance, angle_factor)
	
	# Apply LOD settings
	_apply_lod_to_word(word_entity, lod_level, distance, angle_factor)

func _calculate_lod_level(distance: float, angle_factor: float) -> int:
	# Angle factor affects effective distance
	var effective_distance = distance
	if enable_angle_lod:
		# Words at edge of view seem farther
		effective_distance *= (2.0 - angle_factor)
	
	# Determine LOD level based on distance
	if effective_distance <= LOD_CLOSE:
		return 0  # High detail
	elif effective_distance <= LOD_MEDIUM:
		return 1  # Medium detail
	elif effective_distance <= LOD_FAR:
		return 2  # Low detail
	else:
		return 3  # Very low detail / hidden

func _apply_lod_to_word(word_entity: WordEntity, lod_level: int, distance: float, angle_factor: float) -> void:
	if not word_entity.has_method("set_lod_level"):
		return
	
	# Apply LOD settings based on level
	match lod_level:
		0:  # High detail - close up
			word_entity.set_lod_level({
				"text_visible": true,
				"font_size": 32,
				"mesh_visible": true,
				"emission_enabled": true,
				"animation_enabled": true,
				"transparency": 0.3
			})
		1:  # Medium detail - readable distance
			word_entity.set_lod_level({
				"text_visible": true,
				"font_size": 24,
				"mesh_visible": true,
				"emission_enabled": true,
				"animation_enabled": true,
				"transparency": 0.4
			})
		2:  # Low detail - far but visible
			word_entity.set_lod_level({
				"text_visible": true,
				"font_size": 16,
				"mesh_visible": true,
				"emission_enabled": false,
				"animation_enabled": false,
				"transparency": 0.6
			})
		3:  # Very low detail - barely visible
			word_entity.set_lod_level({
				"text_visible": false,
				"font_size": 8,
				"mesh_visible": true,
				"emission_enabled": false,
				"animation_enabled": false,
				"transparency": 0.8
			})

# Auto-frame camera to see all words
func auto_frame_words() -> void:
	if not camera or word_entities.size() == 0:
		return
	
	# Calculate bounding box of all words
	var min_pos = Vector3(INF, INF, INF)
	var max_pos = Vector3(-INF, -INF, -INF)
	
	for word_entity in word_entities:
		if is_instance_valid(word_entity):
			var pos = word_entity.global_position
			min_pos = Vector3(min(min_pos.x, pos.x), min(min_pos.y, pos.y), min(min_pos.z, pos.z))
			max_pos = Vector3(max(max_pos.x, pos.x), max(max_pos.y, pos.y), max(max_pos.z, pos.z))
	
	# Calculate center and size
	var center = (min_pos + max_pos) * 0.5
	var size = max_pos - min_pos
	var max_dimension = max(size.x, max(size.y, size.z))
	
	# Position camera to frame all words
	var distance = max_dimension * 1.5  # Distance multiplier for good framing
	var height_offset = max_dimension * 0.8  # Height above center
	
	var target_pos = center + Vector3(0, height_offset, distance)
	
	# Smooth camera movement to target position
	var tween = create_tween()
	tween.tween_property(camera, "global_position", target_pos, 1.0)
	
	# Look at center of words
	var look_target = center
	camera.look_at(look_target, Vector3.UP)
	
	print("Auto-framed camera to show all words")

# Debug function to show LOD information
func debug_lod_info() -> Dictionary:
	var lod_counts = {"high": 0, "medium": 0, "low": 0, "hidden": 0}
	var camera_pos = camera.global_position if camera else Vector3.ZERO
	
	for word_entity in word_entities:
		if not is_instance_valid(word_entity):
			continue
		
		var distance = camera_pos.distance_to(word_entity.global_position)
		var lod_level = _calculate_lod_level(distance, 1.0)
		
		match lod_level:
			0: lod_counts.high += 1
			1: lod_counts.medium += 1
			2: lod_counts.low += 1
			3: lod_counts.hidden += 1
	
	return {
		"total_words": word_entities.size(),
		"lod_distribution": lod_counts,
		"camera_position": camera_pos
	}
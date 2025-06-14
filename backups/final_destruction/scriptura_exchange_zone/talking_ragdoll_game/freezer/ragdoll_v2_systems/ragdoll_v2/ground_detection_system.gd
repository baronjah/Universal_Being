# ==================================================
# SCRIPT NAME: ground_detection_system.gd
# DESCRIPTION: Advanced ground detection for ragdoll feet and balance
# PURPOSE: Detect ground height, slopes, edges, and safe foot placements
# CREATED: 2025-05-26 - Complete ragdoll system overhaul
# ==================================================

extends UniversalBeingBase
class_name GroundDetectionSystem

# Ground info structure
class GroundInfo:
	var hit: bool = false
	var position: Vector3 = Vector3.ZERO
	var normal: Vector3 = Vector3.UP
	var distance: float = INF
	var slope_angle: float = 0.0
	var material: String = "default"
	var is_edge: bool = false
	var is_stable: bool = true

# Detection parameters
const RAY_LENGTH: float = 2.0
const FOOT_RAY_COUNT: int = 5  # Rays per foot for better detection
const EDGE_CHECK_RADIUS: float = 0.3
const MAX_WALKABLE_SLOPE: float = 45.0  # Degrees

# Ray configuration for each foot
var foot_rays: Dictionary = {
	"left_foot": [],
	"right_foot": []
}

# Edge detection rays
var edge_rays: Array[RayCast3D] = []

# Ground check results cache
var ground_cache: Dictionary = {}
var cache_time: float = 0.0
const CACHE_DURATION: float = 0.1  # Update every 100ms

# Body parts references
var left_foot: RigidBody3D
var right_foot: RigidBody3D
var pelvis: RigidBody3D

# Visualization
var debug_enabled: bool = true
var debug_markers: Array[MeshInstance3D] = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[GroundDetection] Initializing advanced ground detection system...")
	
	# Wait for parent setup
	await get_tree().process_frame
	
	# Setup ray arrays
	_setup_foot_rays()
	_setup_edge_detection()
	
	# Create debug visualization
	if debug_enabled:
		_create_debug_markers()
	
	print("[GroundDetection] System ready!")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_body_parts(parts: Dictionary) -> void:
	"""Set references to ragdoll body parts"""
	left_foot = parts.get("left_foot")
	right_foot = parts.get("right_foot")
	pelvis = parts.get("pelvis")
	
	# Position rays relative to feet
	_position_rays()

func _setup_foot_rays() -> void:
	"""Create multiple rays per foot for accurate ground detection"""
	var _patterns = [
		Vector3.ZERO,  # Center
		Vector3(0.1, 0, 0),   # Right
		Vector3(-0.1, 0, 0),  # Left
		Vector3(0, 0, 0.1),   # Forward
		Vector3(0, 0, -0.1),  # Back
	]
	
	for foot_name in foot_rays:
		foot_rays[foot_name] = []
		for i in range(FOOT_RAY_COUNT):
			var ray = RayCast3D.new()
			ray.enabled = true
			ray.target_position = Vector3.DOWN * RAY_LENGTH
			ray.collision_mask = 1  # Ground layer
			add_child(ray)
			foot_rays[foot_name].append(ray)

func _setup_edge_detection() -> void:
	"""Create rays for edge/cliff detection"""
	var edge_positions = [
		Vector3(EDGE_CHECK_RADIUS, 0, 0),
		Vector3(-EDGE_CHECK_RADIUS, 0, 0),
		Vector3(0, 0, EDGE_CHECK_RADIUS),
		Vector3(0, 0, -EDGE_CHECK_RADIUS)
	]
	
	for pos in edge_positions:
		var ray = RayCast3D.new()
		ray.enabled = true
		ray.target_position = Vector3.DOWN * (RAY_LENGTH * 1.5)
		ray.position = pos
		ray.collision_mask = 1
		add_child(ray)
		edge_rays.append(ray)

func _position_rays() -> void:
	"""Position rays relative to feet"""
	if not left_foot or not right_foot:
		return
	
	# Position foot rays in a pattern around each foot
	var patterns = [
		Vector3.ZERO,
		Vector3(0.05, 0, 0),
		Vector3(-0.05, 0, 0),
		Vector3(0, 0, 0.05),
		Vector3(0, 0, -0.05)
	]
	
	for i in range(FOOT_RAY_COUNT):
		if i < patterns.size():
			foot_rays["left_foot"][i].position = patterns[i]
			foot_rays["right_foot"][i].position = patterns[i]

func get_ground_info(world_position: Vector3, use_cache: bool = true) -> GroundInfo:
	"""Get detailed ground information at a world position"""
	var cache_key = str(world_position.snapped(Vector3.ONE * 0.1))
	
	# Check cache if enabled
	if use_cache and cache_key in ground_cache:
		var cached = ground_cache[cache_key]
		if Time.get_ticks_msec() / 1000.0 - cached.time < CACHE_DURATION:
			return cached.info
	
	# Perform ground check
	var info = _perform_ground_check(world_position)
	
	# Cache result
	if use_cache:
		ground_cache[cache_key] = {
			"info": info,
			"time": Time.get_ticks_msec() / 1000.0
		}
	
	return info

func _perform_ground_check(world_pos: Vector3) -> GroundInfo:
	"""Perform actual ground detection"""
	var info = GroundInfo.new()
	var space_state = get_world_3d().direct_space_state
	
	# Main ground ray
	var from = world_pos + Vector3.UP * 0.5
	var to = world_pos + Vector3.DOWN * RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(from, to, 1)
	var result = space_state.intersect_ray(query)
	
	if result:
		info.hit = true
		info.position = result.position
		info.normal = result.normal
		info.distance = from.distance_to(result.position)
		
		# Calculate slope
		info.slope_angle = rad_to_deg(acos(info.normal.dot(Vector3.UP)))
		info.is_stable = info.slope_angle <= MAX_WALKABLE_SLOPE
		
		# Check for edges
		info.is_edge = _check_for_edge(world_pos)
		
		# Get material info (if collider has metadata)
		var collider = result.collider
		if collider and collider.has_meta("ground_material"):
			info.material = collider.get_meta("ground_material")
	
	return info

func _check_for_edge(world_pos: Vector3) -> bool:
	"""Check if position is near an edge or cliff"""
	var space_state = get_world_3d().direct_space_state
	var edge_found = false
	
	# Check around the position
	for offset in [Vector3(0.2, 0, 0), Vector3(-0.2, 0, 0), 
				   Vector3(0, 0, 0.2), Vector3(0, 0, -0.2)]:
		var from = world_pos + offset + Vector3.UP * 0.1
		var to = from + Vector3.DOWN * 1.0
		
		var query = PhysicsRayQueryParameters3D.create(from, to, 1)
		var result = space_state.intersect_ray(query)
		
		if not result:
			edge_found = true
			break
	
	return edge_found

func get_foot_ground_info(foot_name: String) -> GroundInfo:
	"""Get averaged ground info for a specific foot"""
	if not foot_name in foot_rays:
		return GroundInfo.new()
	
	var foot_body = left_foot if foot_name == "left_foot" else right_foot
	if not foot_body:
		return GroundInfo.new()
	
	var combined_info = GroundInfo.new()
	var hit_count = 0
	var avg_position = Vector3.ZERO
	var avg_normal = Vector3.ZERO
	var min_distance = INF
	
	# Check all rays for this foot
	for ray in foot_rays[foot_name]:
		# Update ray position to match foot
		ray.global_position = foot_body.global_position + ray.position
		ray.force_raycast_update()
		
		if ray.is_colliding():
			hit_count += 1
			avg_position += ray.get_collision_point()
			avg_normal += ray.get_collision_normal()
			var dist = ray.global_position.distance_to(ray.get_collision_point())
			min_distance = min(min_distance, dist)
	
	if hit_count > 0:
		combined_info.hit = true
		combined_info.position = avg_position / hit_count
		combined_info.normal = avg_normal.normalized()
		combined_info.distance = min_distance
		combined_info.slope_angle = rad_to_deg(acos(combined_info.normal.dot(Vector3.UP)))
		combined_info.is_stable = combined_info.slope_angle <= MAX_WALKABLE_SLOPE
		combined_info.is_edge = _check_for_edge(foot_body.global_position)
	
	return combined_info

func get_safe_foot_placement(current_pos: Vector3, desired_direction: Vector3, step_length: float) -> Vector3:
	"""Calculate safe foot placement position"""
	var test_position = current_pos + desired_direction * step_length
	var ground_info = get_ground_info(test_position)
	
	# If initial position is not safe, search for alternatives
	if not ground_info.hit or not ground_info.is_stable or ground_info.is_edge:
		# Try shorter steps
		for factor in [0.8, 0.6, 0.4]:
			test_position = current_pos + desired_direction * step_length * factor
			ground_info = get_ground_info(test_position)
			if ground_info.hit and ground_info.is_stable and not ground_info.is_edge:
				break
		
		# If still no safe spot, try slightly different angles
		if not ground_info.hit or not ground_info.is_stable:
			for angle in [-15, 15, -30, 30]:
				var rotated_dir = desired_direction.rotated(Vector3.UP, deg_to_rad(angle))
				test_position = current_pos + rotated_dir * step_length * 0.7
				ground_info = get_ground_info(test_position)
				if ground_info.hit and ground_info.is_stable and not ground_info.is_edge:
					break
	
	# Return the ground position (adjusted for height)
	if ground_info.hit:
		return ground_info.position + Vector3.UP * 0.05  # Slight offset above ground
	else:
		return current_pos  # Stay in place if no safe spot found

func get_balance_assessment() -> Dictionary:
	"""Assess current balance state based on foot positions"""
	var left_info = get_foot_ground_info("left_foot")
	var right_info = get_foot_ground_info("right_foot")
	
	var assessment = {
		"both_feet_grounded": left_info.hit and right_info.hit,
		"left_grounded": left_info.hit,
		"right_grounded": right_info.hit,
		"height_difference": 0.0,
		"average_slope": 0.0,
		"on_edge": left_info.is_edge or right_info.is_edge,
		"stable": true
	}
	
	if assessment.both_feet_grounded:
		assessment.height_difference = abs(left_info.position.y - right_info.position.y)
		assessment.average_slope = (left_info.slope_angle + right_info.slope_angle) / 2.0
		assessment.stable = left_info.is_stable and right_info.is_stable and assessment.height_difference < 0.3
	else:
		assessment.stable = false
	
	return assessment

func _create_debug_markers() -> void:
	"""Create visual debug markers"""
	# Ground hit markers
	for i in range(10):
		var marker = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.02
		sphere.height = 0.04
		marker.mesh = sphere
		
		var material = MaterialLibrary.get_material("default")
		material.albedo_color = Color.GREEN
		material.emission_enabled = true
		material.emission = Color.GREEN * 0.5
		marker.material_override = material
		
		add_child(marker)
		debug_markers.append(marker)
		marker.visible = false

func update_debug_visualization() -> void:
	"""Update debug marker positions"""
	if not debug_enabled or debug_markers.is_empty():
		return
	
	var marker_index = 0
	
	# Show foot ray hits
	for foot_name in foot_rays:
		for ray in foot_rays[foot_name]:
			if ray.is_colliding() and marker_index < debug_markers.size():
				var marker = debug_markers[marker_index]
				marker.global_position = ray.get_collision_point()
				marker.visible = true
				
				# Color based on slope
				var normal = ray.get_collision_normal()
				var slope = rad_to_deg(acos(normal.dot(Vector3.UP)))
				if slope > MAX_WALKABLE_SLOPE:
					marker.material_override.albedo_color = Color.RED
				elif slope > MAX_WALKABLE_SLOPE * 0.7:
					marker.material_override.albedo_color = Color.YELLOW
				else:
					marker.material_override.albedo_color = Color.GREEN
				
				marker_index += 1


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Update debug visualization
	if debug_enabled:
		update_debug_visualization()
	
	# Clean old cache entries
	if ground_cache.size() > 100:
		var current_time = Time.get_ticks_msec() / 1000.0
		var keys_to_remove = []
		for key in ground_cache:
			if current_time - ground_cache[key].time > CACHE_DURATION * 2:
				keys_to_remove.append(key)
		for key in keys_to_remove:
			ground_cache.erase(key)
# DISTANCE-BASED LOD SYSTEM
# Calculates optimal generation zones between Player and Gemma
# "One ball of max, into two balls" with mathematical precision
extends Node3D
class_name DistanceBasedLOD

signal lod_zones_updated(player_zone: Dictionary, gemma_zone: Dictionary)
signal performance_optimized(fps_target: int, current_fps: float)

# LOD Configuration
@export var target_fps: int = 120  # Target 60-120 FPS as requested
@export var max_generation_radius: float = 200.0  # "One ball of max"
@export var min_generation_radius: float = 20.0
@export var overlap_factor: float = 0.3  # Zone overlap percentage

# Player and Gemma references
var player_ref: Node3D = null
var gemma_ref: Node3D = null

# Generation zones
var player_zone: Dictionary = {}
var gemma_zone: Dictionary = {}
var distance_between: float = 0.0

# Performance tracking
var fps_history: Array = []
var current_fps: float = 60.0

func _ready():
	print("🧮 Distance-Based LOD: Initializing mathematical generation zones...")
	_find_player_and_gemma()
	set_process(true)

func _process(delta: float):
	_update_fps_tracking(delta)
	_calculate_generation_zones()
	_optimize_performance()

func _find_player_and_gemma():
	"""Find player and Gemma in the scene"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if being.has_method("get") and being.get("being_type") == "player":
			player_ref = being
		elif being.has_method("get") and being.get("being_name") and being.get("being_name").contains("Gemma"):
			gemma_ref = being
	
	if player_ref:
		print("✅ Found player at: %v" % player_ref.global_position)
	if gemma_ref:
		print("✅ Found Gemma at: %v" % gemma_ref.global_position)

func _calculate_generation_zones():
	"""Calculate optimal generation zones based on distance"""
	if not player_ref or not gemma_ref:
		return
	
	# Get current positions
	var player_pos = player_ref.global_position
	var gemma_pos = gemma_ref.global_position
	distance_between = player_pos.distance_to(gemma_pos)
	
	# MATHEMATICAL SOLUTION: "One ball of max, into two balls"
	var total_available_radius = max_generation_radius
	var zones = _calculate_two_ball_distribution(player_pos, gemma_pos, total_available_radius)
	
	player_zone = zones.player
	gemma_zone = zones.gemma
	
	# Emit zone updates
	lod_zones_updated.emit(player_zone, gemma_zone)

func _calculate_two_ball_distribution(pos1: Vector3, pos2: Vector3, max_radius: float) -> Dictionary:
	"""Mathematical solution: Distribute one max ball into two optimal balls"""
	
	var distance = pos1.distance_to(pos2)
	var midpoint = (pos1 + pos2) / 2.0
	
	# Case 1: Very close together (distance < max_radius/2)
	if distance < max_radius * 0.5:
		var shared_radius = max_radius * 0.6  # Shared generation zone
		return {
			"player": {
				"center": pos1,
				"radius": shared_radius,
				"priority": 1.0,
				"chunk_density": 1.0
			},
			"gemma": {
				"center": pos2,
				"radius": shared_radius,
				"priority": 0.8,
				"chunk_density": 0.8
			}
		}
	
	# Case 2: Moderate distance (overlap zones)
	elif distance < max_radius * 1.5:
		var overlap_distance = distance * overlap_factor
		var player_radius = (max_radius * 0.6) + overlap_distance
		var gemma_radius = (max_radius * 0.4) + overlap_distance
		
		return {
			"player": {
				"center": pos1,
				"radius": player_radius,
				"priority": 1.0,
				"chunk_density": _calculate_density_by_fps()
			},
			"gemma": {
				"center": pos2,
				"radius": gemma_radius,
				"priority": 0.7,
				"chunk_density": _calculate_density_by_fps() * 0.7
			}
		}
	
	# Case 3: Far apart (separate zones)
	else:
		var player_ratio = 0.65  # Player gets slightly more
		var gemma_ratio = 0.35
		
		# Adjust based on performance
		var performance_modifier = _get_performance_modifier()
		
		return {
			"player": {
				"center": pos1,
				"radius": max_radius * player_ratio * performance_modifier,
				"priority": 1.0,
				"chunk_density": _calculate_density_by_fps()
			},
			"gemma": {
				"center": pos2,
				"radius": max_radius * gemma_ratio * performance_modifier,
				"priority": 0.6,
				"chunk_density": _calculate_density_by_fps() * 0.6
			}
		}

func _calculate_density_by_fps() -> float:
	"""Calculate chunk density based on current FPS"""
	if current_fps >= target_fps:
		return 1.0  # Full density
	elif current_fps >= target_fps * 0.8:
		return 0.8  # Reduced density
	elif current_fps >= target_fps * 0.6:
		return 0.6  # Low density
	else:
		return 0.4  # Minimal density

func _get_performance_modifier() -> float:
	"""Get performance-based radius modifier"""
	var fps_ratio = current_fps / float(target_fps)
	
	if fps_ratio >= 1.0:
		return 1.2  # Above target - can increase generation
	elif fps_ratio >= 0.8:
		return 1.0  # On target
	elif fps_ratio >= 0.6:
		return 0.8  # Below target - reduce generation
	else:
		return 0.6  # Well below target - minimal generation

func _update_fps_tracking(delta: float):
	"""Track FPS for performance optimization"""
	current_fps = 1.0 / delta
	
	# Keep rolling average of last 10 frames
	fps_history.append(current_fps)
	if fps_history.size() > 10:
		fps_history.pop_front()
	
	# Calculate average FPS
	var total_fps = 0.0
	for fps in fps_history:
		total_fps += fps
	current_fps = total_fps / fps_history.size()

func _optimize_performance():
	"""Optimize performance based on FPS"""
	if current_fps < target_fps * 0.7:  # Below 70% of target
		print("⚠️ Performance issue detected: %d FPS (target: %d)" % [current_fps, target_fps])
		_reduce_generation_complexity()
	elif current_fps > target_fps * 1.1:  # Above 110% of target
		_increase_generation_quality()

func _reduce_generation_complexity():
	"""Reduce generation complexity to improve FPS"""
	max_generation_radius *= 0.9  # Reduce by 10%
	max_generation_radius = max(max_generation_radius, min_generation_radius)
	print("🔧 Reduced generation radius to: %.1f" % max_generation_radius)

func _increase_generation_quality():
	"""Increase generation quality when FPS allows"""
	max_generation_radius *= 1.05  # Increase by 5%
	max_generation_radius = min(max_generation_radius, 300.0)  # Cap at 300

# API Methods
func get_player_zone() -> Dictionary:
	return player_zone

func get_gemma_zone() -> Dictionary:
	return gemma_zone

func get_distance_between() -> float:
	return distance_between

func set_target_fps(new_target: int):
	target_fps = new_target
	print("🎯 Target FPS updated to: %d" % target_fps)

func get_zone_overlap_area() -> float:
	"""Calculate overlapping area between zones"""
	if player_zone.is_empty() or gemma_zone.is_empty():
		return 0.0
	
	var p_center = player_zone.center
	var p_radius = player_zone.radius
	var g_center = gemma_zone.center
	var g_radius = gemma_zone.radius
	
	var distance = p_center.distance_to(g_center)
	
	# If zones don't overlap
	if distance >= p_radius + g_radius:
		return 0.0
	
	# If one zone is inside the other
	if distance <= abs(p_radius - g_radius):
		var smaller_radius = min(p_radius, g_radius)
		return PI * smaller_radius * smaller_radius
	
	# Calculate intersection area (complex geometry)
	var r1_sq = p_radius * p_radius
	var r2_sq = g_radius * g_radius
	var d_sq = distance * distance
	
	var area1 = r1_sq * acos((d_sq + r1_sq - r2_sq) / (2 * distance * p_radius))
	var area2 = r2_sq * acos((d_sq + r2_sq - r1_sq) / (2 * distance * g_radius))
	var area3 = 0.5 * sqrt((-distance + p_radius + g_radius) * (distance + p_radius - g_radius) * (distance - p_radius + g_radius) * (distance + p_radius + g_radius))
	
	return area1 + area2 - area3

func _get_class_info():
	print("🧮 DistanceBasedLOD: Mathematical generation zones ready!")
# Time-Free Animation System with 5 Keypose Interpolation
# JSH #memories
extends Node
class_name TimeFreeAnimationSystem

signal animation_speed_changed(new_speed: float)
signal keypose_reached(pose_index: int)
signal animation_completed(animation_name: String)

# Core animation properties
var time_scale := 1.0  # Global time multiplier
var animation_data = {}  # Store all animations
var active_animations = []  # Currently playing
var os_tick_based := true  # Use OS tick instead of delta

# 5 Keypose system
const KEYPOSE_COUNT = 5
const AUTO_INTERPOLATION_FRAMES = 10

class Animation5Pose:
	var name: String
	var keyposes: Array = []  # 5 key positions
	var durations: Array = []  # Time between poses
	var current_pose := 0
	var interpolation_progress := 0.0
	var total_distance := 0.0
	var speeds: Array = []  # Calculated speeds between poses
	
	func calculate_distances():
		"""Calculate distances and speeds between keyposes"""
		for i in range(keyposes.size() - 1):
			var dist = keyposes[i].distance_to(keyposes[i + 1])
			speeds.append(dist / durations[i] if durations[i] > 0 else 1.0)
			total_distance += dist

func _ready():
	print("⏰ Time-Free Animation System initialized")
	setup_time_controls()

func setup_time_controls():
	"""Create time control interface"""
	# This connects to HUD/GUI slider and garden lever/sign
	pass

func create_5pose_animation(name: String, poses: Array, base_duration: float = 1.0) -> Animation5Pose:
	"""Create animation from 5 keyposes"""
	var anim = Animation5Pose.new()
	anim.name = name
	
	# Ensure we have exactly 5 poses
	if poses.size() < KEYPOSE_COUNT:
		push_error("Need exactly 5 keyposes, got %d" % poses.size())
		return null
	
	anim.keyposes = poses.slice(0, KEYPOSE_COUNT)
	
	# Calculate durations based on distances
	for i in range(KEYPOSE_COUNT - 1):
		var dist = poses[i].distance_to(poses[i + 1])
		anim.durations.append(base_duration * (dist / 10.0))  # Normalize
	
	anim.calculate_distances()
	animation_data[name] = anim
	return anim

func play_animation(name: String, target: Node3D, speed_override: float = -1.0):
	"""Play a 5-pose animation on target"""
	if not animation_data.has(name):
		push_error("Animation '%s' not found" % name)
		return
	
	var anim_instance = {
		"animation": animation_data[name],
		"target": target,
		"start_time": get_time_tick(),
		"speed": speed_override if speed_override > 0 else time_scale,
		"current_segment": 0,
		"segment_progress": 0.0
	}
	
	active_animations.append(anim_instance)

func get_time_tick() -> float:
	"""Get time based on OS tick or game time"""
	if os_tick_based:
		return Time.get_ticks_msec() / 1000.0
	else:
		return Time.get_ticks_msec() / 1000.0 * Engine.time_scale

func _process(_delta):
	"""Update all active animations (delta-independent)"""
	var current_time = get_time_tick()
	
	for i in range(active_animations.size() - 1, -1, -1):
		var anim = active_animations[i]
		if update_animation(anim, current_time):
			active_animations.remove_at(i)
			animation_completed.emit(anim.animation.name)

func update_animation(anim_instance: Dictionary, current_time: float) -> bool:
	"""Update single animation, return true if completed"""
	var anim = anim_instance.animation
	var target = anim_instance.target
	var speed = anim_instance.speed * time_scale
	
	# Calculate time elapsed since start
	var elapsed = (current_time - anim_instance.start_time) * speed
	
	# Find which segment we're in
	var accumulated_time = 0.0
	var current_segment = -1
	
	for i in range(anim.durations.size()):
		if elapsed <= accumulated_time + anim.durations[i]:
			current_segment = i
			anim_instance.segment_progress = (elapsed - accumulated_time) / anim.durations[i]
			break
		accumulated_time += anim.durations[i]
	
	# Animation complete
	if current_segment == -1:
		target.position = anim.keyposes[-1]
		return true
	
	# Interpolate between poses
	var from_pose = anim.keyposes[current_segment]
	var to_pose = anim.keyposes[current_segment + 1]
	var t = smooth_interpolation(anim_instance.segment_progress)
	
	# Apply interpolated position
	target.position = from_pose.lerp(to_pose, t)
	
	# Check for keypose reached
	if current_segment != anim_instance.current_segment:
		anim_instance.current_segment = current_segment
		keypose_reached.emit(current_segment + 1)
	
	return false

func smooth_interpolation(t: float) -> float:
	"""Smooth interpolation function"""
	# Smoothstep for natural movement
	return t * t * (3.0 - 2.0 * t)

func auto_generate_between_frames(pose1: Vector3, pose2: Vector3, frame_count: int = AUTO_INTERPOLATION_FRAMES) -> Array:
	"""Generate intermediate frames between two poses"""
	var frames = []
	
	for i in range(frame_count):
		var t = float(i) / float(frame_count - 1)
		var smooth_t = smooth_interpolation(t)
		frames.append(pose1.lerp(pose2, smooth_t))
	
	return frames

func set_time_scale(new_scale: float):
	"""Set global time scale (from HUD slider or garden lever)"""
	time_scale = clamp(new_scale, 0.0, 10.0)
	animation_speed_changed.emit(time_scale)
	print("⏰ Time scale set to: %.2fx" % time_scale)

func create_test_animations():
	"""Create test animations for debugging"""
	# Floating animation
	var float_poses = [
		Vector3(0, 0, 0),
		Vector3(0, 2, 0),
		Vector3(2, 3, 0),
		Vector3(4, 2, 0),
		Vector3(4, 0, 0)
	]
	create_5pose_animation("float_loop", float_poses, 2.0)
	
	# Orbit animation
	var orbit_poses = []
	for i in range(KEYPOSE_COUNT):
		var angle = (TAU / KEYPOSE_COUNT) * i
		orbit_poses.append(Vector3(cos(angle) * 5, 0, sin(angle) * 5))
	create_5pose_animation("orbit", orbit_poses, 1.5)
	
	# Zigzag animation
	var zigzag_poses = [
		Vector3(-5, 0, 0),
		Vector3(-2.5, 0, 5),
		Vector3(0, 0, 0),
		Vector3(2.5, 0, -5),
		Vector3(5, 0, 0)
	]
	create_5pose_animation("zigzag", zigzag_poses, 1.0)

# Integration with garden interaction system
func create_time_control_sign() -> Node3D:
	"""Create interactive sign in garden for time control"""
	var sign = preload("res://scenes/interactive_sign.tscn").instantiate()
	sign.text = "Time Flow"
	sign.interaction_callback = _on_time_sign_interact
	return sign

func _on_time_sign_interact():
	"""Handle time control sign interaction"""
	# Cycle through preset speeds
	var speeds = [0.25, 0.5, 1.0, 2.0, 4.0]
	var current_index = speeds.find(time_scale)
	var next_index = (current_index + 1) % speeds.size()
	set_time_scale(speeds[next_index])

# Advanced features
func create_dynamic_animation(target: Node3D, destination: Vector3, obstacles: Array = []):
	"""Create dynamic 5-pose path avoiding obstacles"""
	var start = target.position
	var poses = [start]
	
	# Generate 3 intermediate points
	for i in range(3):
		var t = (i + 1) / 4.0
		var base_point = start.lerp(destination, t)
		
		# Avoid obstacles
		for obstacle in obstacles:
			var dist = base_point.distance_to(obstacle.position)
			if dist < 2.0:
				var avoid_dir = (base_point - obstacle.position).normalized()
				base_point += avoid_dir * (2.0 - dist)
		
		poses.append(base_point)
	
	poses.append(destination)
	
	# Create and play animation
	var anim_name = "dynamic_%d" % Time.get_ticks_msec()
	create_5pose_animation(anim_name, poses, 1.0)
	play_animation(anim_name, target)

# Save/Load animations
func save_animation(name: String, file_path: String):
	"""Save animation to file"""
	if not animation_data.has(name):
		return
	
	var anim = animation_data[name]
	var save_data = {
		"name": anim.name,
		"keyposes": [],
		"durations": anim.durations
	}
	
	for pose in anim.keyposes:
		save_data.keyposes.append({
			"x": pose.x,
			"y": pose.y,
			"z": pose.z
		})
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_animation(file_path: String) -> Animation5Pose:
	"""Load animation from file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return null
	
	var data = json.data
	var poses = []
	
	for pose_data in data.keyposes:
		poses.append(Vector3(pose_data.x, pose_data.y, pose_data.z))
	
	return create_5pose_animation(data.name, poses)
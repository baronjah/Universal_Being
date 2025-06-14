# ==================================================
# SCRIPT NAME: keypoint_animation_system.gd
# DESCRIPTION: Keypoint-based procedural animation for ragdoll
# PURPOSE: Define movement goals for each limb with animation cycles
# CREATED: 2025-05-26 - Complete ragdoll system overhaul
# ==================================================

extends UniversalBeingBase
class_name KeypointAnimationSystem

# Keypoint for tracking limb goals
class LimbKeypoint:
	var name: String = ""
	var rest_position: Vector3 = Vector3.ZERO  # Relative to parent
	var current_goal: Vector3 = Vector3.ZERO   # World space target
	var goal_weight: float = 1.0               # How strongly to pursue (0-1)
	var ground_contact: bool = false           # Should maintain ground contact?
	var last_ground_pos: Vector3 = Vector3.ZERO
	var velocity: Vector3 = Vector3.ZERO       # For smooth motion
	var is_support: bool = false               # Is this a support point?

# Animation keyframe
class AnimationKeyframe:
	var time: float = 0.0  # Normalized time (0-1)
	var limb_goals: Dictionary = {}  # {limb_name: Vector3 offset}
	var easing: String = "ease_in_out"
	var events: Array = []  # Trigger events at this frame

# Animation cycle definition
class AnimationCycle:
	var name: String = ""
	var duration: float = 1.0
	var keyframes: Array[AnimationKeyframe] = []
	var loop: bool = true
	var blend_in_time: float = 0.2
	var blend_out_time: float = 0.2
	

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

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
	func get_frame_at_time(normalized_time: float) -> Dictionary:
		"""Get interpolated frame data at specific time"""
		# Find surrounding keyframes
		var prev_frame: AnimationKeyframe = null
		var next_frame: AnimationKeyframe = null
		
		for i in range(keyframes.size()):
			if keyframes[i].time <= normalized_time:
				prev_frame = keyframes[i]
			if keyframes[i].time > normalized_time and next_frame == null:
				next_frame = keyframes[i]
				break
		
		# Handle edge cases
		if prev_frame == null:
			prev_frame = keyframes[0]
		if next_frame == null:
			next_frame = keyframes[0] if loop else keyframes[-1]
		
		# Interpolate between frames
		var t = 0.0
		if next_frame.time > prev_frame.time:
			t = (normalized_time - prev_frame.time) / (next_frame.time - prev_frame.time)
		
		# Apply easing
		t = _apply_easing(t, prev_frame.easing)
		
		# Blend limb goals
		var blended_goals = {}
		for limb in prev_frame.limb_goals:
			if limb in next_frame.limb_goals:
				blended_goals[limb] = prev_frame.limb_goals[limb].lerp(
					next_frame.limb_goals[limb], t
				)
			else:
				blended_goals[limb] = prev_frame.limb_goals[limb]
		
		return blended_goals
	
	func _apply_easing(t: float, easing: String) -> float:
		match easing:
			"linear":
				return t
			"ease_in":
				return t * t
			"ease_out":
				return 1.0 - (1.0 - t) * (1.0 - t)
			"ease_in_out":
				if t < 0.5:
					return 2.0 * t * t
				else:
					return 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0
			_:
				return t

# Limb tracking
var limb_keypoints: Dictionary = {}  # {limb_name: LimbKeypoint}

# Animation state
var current_cycle: AnimationCycle = null
var cycle_time: float = 0.0
var is_transitioning: bool = false
var transition_from_cycle: AnimationCycle = null
var transition_time: float = 0.0
var transition_duration: float = 0.3

# Body parts references
var body_parts: Dictionary = {}
var ground_detection: GroundDetectionSystem

# Animation cycles library
var animation_cycles: Dictionary = {}

# Cycle parameters
var playback_speed: float = 1.0
var mirror_animation: bool = false  # For left/right symmetry

func _ready() -> void:
	print("[KeypointAnimation] Initializing keypoint animation system...")
	
	# Initialize default keypoints
	_setup_default_keypoints()
	
	# Create built-in animation cycles
	_create_animation_cycles()
	
	print("[KeypointAnimation] System ready!")

func set_body_parts(parts: Dictionary) -> void:
	"""Set references to ragdoll body parts"""
	body_parts = parts
	
	# Update keypoint rest positions based on actual skeleton
	_update_rest_positions()

func set_ground_detection(detector: GroundDetectionSystem) -> void:
	"""Set reference to ground detection system"""
	ground_detection = detector

func _setup_default_keypoints() -> void:
	"""Create keypoints for each limb"""
	var default_keypoints = [
		"pelvis", "spine", "head",
		"left_thigh", "left_shin", "left_foot",
		"right_thigh", "right_shin", "right_foot",
		"left_upper_arm", "left_forearm", "left_hand",
		"right_upper_arm", "right_forearm", "right_hand"
	]
	
	for limb_name in default_keypoints:
		var keypoint = LimbKeypoint.new()
		keypoint.name = limb_name
		limb_keypoints[limb_name] = keypoint

func _update_rest_positions() -> void:
	"""Update rest positions from actual body parts"""
	for limb_name in limb_keypoints:
		if limb_name in body_parts and body_parts[limb_name]:
			var limb = body_parts[limb_name]
			limb_keypoints[limb_name].rest_position = limb.position

func _create_animation_cycles() -> void:
	"""Create built-in animation cycles"""
	# IDLE CYCLE
	var idle = AnimationCycle.new()
	idle.name = "idle"
	idle.duration = 3.0
	idle.loop = true
	
	var idle_frame1 = AnimationKeyframe.new()
	idle_frame1.time = 0.0
	idle_frame1.limb_goals = {
		"spine": Vector3(0, 0.02, 0),
		"head": Vector3(0, 0.01, 0)
	}
	idle.keyframes.append(idle_frame1)
	
	var idle_frame2 = AnimationKeyframe.new()
	idle_frame2.time = 0.5
	idle_frame2.limb_goals = {
		"spine": Vector3(0, -0.02, 0),
		"head": Vector3(0, -0.01, 0)
	}
	idle.keyframes.append(idle_frame2)
	
	var idle_frame3 = AnimationKeyframe.new()
	idle_frame3.time = 1.0
	idle_frame3.limb_goals = {
		"spine": Vector3(0, 0.02, 0),
		"head": Vector3(0, 0.01, 0)
	}
	idle.keyframes.append(idle_frame3)
	
	animation_cycles["idle"] = idle
	
	# WALK CYCLE
	var walk = AnimationCycle.new()
	walk.name = "walk"
	walk.duration = 1.0
	walk.loop = true
	
	# Frame 1: Left foot forward, right foot back
	var walk_frame1 = AnimationKeyframe.new()
	walk_frame1.time = 0.0
	walk_frame1.limb_goals = {
		"left_foot": Vector3(0, 0.1, 0.3),      # Lift and forward
		"right_foot": Vector3(0, 0.0, -0.2),    # On ground, back
		"left_thigh": Vector3(0, 0, 0.1),       # Slight forward rotation
		"right_thigh": Vector3(0, 0, -0.1),     # Slight back rotation
		"pelvis": Vector3(0, 0, 0.05),          # Slight forward lean
		"spine": Vector3(0, 0, -0.02)           # Counter rotation
	}
	walk_frame1.events = ["left_foot_lift"]
	walk.keyframes.append(walk_frame1)
	
	# Frame 2: Left foot down, right foot lifting
	var walk_frame2 = AnimationKeyframe.new()
	walk_frame2.time = 0.25
	walk_frame2.limb_goals = {
		"left_foot": Vector3(0, 0.0, 0.2),      # On ground, forward
		"right_foot": Vector3(0, 0.05, -0.1),   # Starting to lift
		"left_thigh": Vector3(0, 0, 0.05),
		"right_thigh": Vector3(0, 0, -0.05),
		"pelvis": Vector3(0, 0.02, 0),
		"spine": Vector3(0, 0, 0)
	}
	walk_frame2.events = ["left_foot_down", "right_foot_prepare"]
	walk.keyframes.append(walk_frame2)
	
	# Frame 3: Right foot forward, left foot back
	var walk_frame3 = AnimationKeyframe.new()
	walk_frame3.time = 0.5
	walk_frame3.limb_goals = {
		"left_foot": Vector3(0, 0.0, -0.2),     # On ground, back
		"right_foot": Vector3(0, 0.1, 0.3),     # Lift and forward
		"left_thigh": Vector3(0, 0, -0.1),
		"right_thigh": Vector3(0, 0, 0.1),
		"pelvis": Vector3(0, 0, 0.05),
		"spine": Vector3(0, 0, 0.02)
	}
	walk_frame3.events = ["right_foot_lift"]
	walk.keyframes.append(walk_frame3)
	
	# Frame 4: Right foot down, left foot lifting
	var walk_frame4 = AnimationKeyframe.new()
	walk_frame4.time = 0.75
	walk_frame4.limb_goals = {
		"left_foot": Vector3(0, 0.05, -0.1),    # Starting to lift
		"right_foot": Vector3(0, 0.0, 0.2),     # On ground, forward
		"left_thigh": Vector3(0, 0, -0.05),
		"right_thigh": Vector3(0, 0, 0.05),
		"pelvis": Vector3(0, 0.02, 0),
		"spine": Vector3(0, 0, 0)
	}
	walk_frame4.events = ["right_foot_down", "left_foot_prepare"]
	walk.keyframes.append(walk_frame4)
	
	# Frame 5: Loop back to start
	var walk_frame5 = AnimationKeyframe.new()
	walk_frame5.time = 1.0
	walk_frame5.limb_goals = walk_frame1.limb_goals.duplicate()
	walk.keyframes.append(walk_frame5)
	
	animation_cycles["walk"] = walk
	
	# Add more cycles...
	_create_run_cycle()
	_create_turn_cycle()
	_create_crouch_cycle()

func _create_run_cycle() -> void:
	"""Create running animation cycle"""
	var run = AnimationCycle.new()
	run.name = "run"
	run.duration = 0.6  # Faster than walk
	run.loop = true
	
	# Similar to walk but with:
	# - Higher foot lift
	# - Longer strides
	# - More body lean
	# - Both feet off ground briefly
	
	# TODO: Implement run cycle keyframes
	animation_cycles["run"] = run

func _create_turn_cycle() -> void:
	"""Create turning animation cycle"""
	var turn = AnimationCycle.new()
	turn.name = "turn"
	turn.duration = 0.8
	turn.loop = false
	
	# TODO: Implement turn cycle keyframes
	animation_cycles["turn"] = turn

func _create_crouch_cycle() -> void:
	"""Create crouching animation cycle"""
	var crouch = AnimationCycle.new()
	crouch.name = "crouch"
	crouch.duration = 0.5
	crouch.loop = false
	
	# TODO: Implement crouch cycle keyframes
	animation_cycles["crouch"] = crouch

func play_cycle(cycle_name: String, transition_duration_param: float = 0.3) -> void:
	"""Start playing an animation cycle"""
	if not cycle_name in animation_cycles:
		push_error("Animation cycle not found: " + cycle_name)
		return
	
	var new_cycle = animation_cycles[cycle_name]
	
	# If same cycle, just continue
	if current_cycle == new_cycle and not is_transitioning:
		return
	
	# Start transition
	if current_cycle and transition_duration_param > 0:
		is_transitioning = true
		transition_from_cycle = current_cycle
		transition_duration = transition_duration_param
		transition_time = 0.0
	
	current_cycle = new_cycle
	cycle_time = 0.0
	
	print("[KeypointAnimation] Playing cycle: ", cycle_name)

func update_animation(delta: float) -> void:
	"""Update animation state and keypoint goals"""
	if not current_cycle:
		return
	
	# Update cycle time
	cycle_time += delta * playback_speed
	
	# Handle looping
	if current_cycle.loop:
		cycle_time = fmod(cycle_time, current_cycle.duration)
	else:
		cycle_time = min(cycle_time, current_cycle.duration)
	
	# Get normalized time (0-1)
	var normalized_time = cycle_time / current_cycle.duration
	
	# Get current frame goals
	var frame_goals = current_cycle.get_frame_at_time(normalized_time)
	
	# Handle transition blending
	if is_transitioning and transition_from_cycle:
		transition_time += delta
		var blend_factor = transition_time / transition_duration
		
		if blend_factor >= 1.0:
			is_transitioning = false
			transition_from_cycle = null
		else:
			# Blend with previous cycle
			var old_time = fmod(transition_time, transition_from_cycle.duration)
			var old_normalized = old_time / transition_from_cycle.duration
			var old_goals = transition_from_cycle.get_frame_at_time(old_normalized)
			
			# Blend goals
			for limb in frame_goals:
				if limb in old_goals:
					frame_goals[limb] = old_goals[limb].lerp(frame_goals[limb], blend_factor)
	
	# Apply goals to keypoints
	_apply_frame_goals(frame_goals)
	
	# Process animation events
	_process_animation_events(normalized_time)

func _apply_frame_goals(goals: Dictionary) -> void:
	"""Apply animation goals to limb keypoints"""
	for limb_name in goals:
		if limb_name in limb_keypoints:
			var keypoint = limb_keypoints[limb_name]
			var body_part = body_parts.get(limb_name)
			
			if body_part:
				# Calculate world space goal
				var parent_transform = body_part.get_parent().global_transform
				var local_goal = keypoint.rest_position + goals[limb_name]
				keypoint.current_goal = parent_transform * local_goal
				
				# Special handling for feet - maintain ground contact
				if limb_name.ends_with("_foot") and ground_detection:
					var ground_info = ground_detection.get_ground_info(keypoint.current_goal)
					if ground_info.hit and keypoint.ground_contact:
						keypoint.current_goal.y = ground_info.position.y + 0.05

func _process_animation_events(_normalized_time: float) -> void:
	"""Process events triggered by animation"""
	# TODO: Implement event processing
	pass

func get_limb_goal(limb_name: String) -> Vector3:
	"""Get current goal position for a limb"""
	if limb_name in limb_keypoints:
		return limb_keypoints[limb_name].current_goal
	return Vector3.ZERO

func set_limb_goal_weight(limb_name: String, weight: float) -> void:
	"""Set how strongly a limb pursues its goal"""
	if limb_name in limb_keypoints:
		limb_keypoints[limb_name].goal_weight = clamp(weight, 0.0, 1.0)

func is_foot_in_support_phase(foot_name: String) -> bool:
	"""Check if foot should be supporting weight"""
	if foot_name in limb_keypoints:
		return limb_keypoints[foot_name].is_support
	return false

func get_animation_state() -> Dictionary:
	"""Get current animation state info"""
	return {
		"current_cycle": current_cycle.name if current_cycle else "none",
		"cycle_time": cycle_time,
		"normalized_time": cycle_time / current_cycle.duration if current_cycle else 0.0,
		"is_transitioning": is_transitioning,
		"playback_speed": playback_speed
	}
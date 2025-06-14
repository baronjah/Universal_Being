extends Camera3D
class_name SpaceCameraController

# Camera states
enum CameraState {
	FREE,
	FOLLOW,
	TRANSITION,
	ORBIT
}

# Camera properties
@export var move_speed: float = 10.0
@export var zoom_speed: float = 1.0
@export var rotation_speed: float = 0.5
@export var smooth_factor: float = 0.1
@export var orbit_height: float = 3.0
@export var orbit_distance: float = 10.0

var current_state = CameraState.FREE
var follow_target = null
var orbit_angle: float = 0.0

# Input actions
var input_actions = {
	"move_forward": "ui_up",
	"move_backward": "ui_down",
	"move_left": "ui_left",
	"move_right": "ui_right",
	"move_up": "space",
	"move_down": "ctrl",
	"orbit_rotate": "mouse_right",
	"zoom_in": "mouse_wheel_up",
	"zoom_out": "mouse_wheel_down"
}

# Transition properties
var transition_start_pos = Vector3.ZERO
var transition_end_pos = Vector3.ZERO
var transition_start_rot = Quaternion.IDENTITY
var transition_end_rot = Quaternion.IDENTITY
var transition_progress = 0.0
var transition_duration = 1.0
var is_transitioning = false

# Scale transition properties
var scale_transition_start = 1.0
var scale_transition_end = 1.0
var current_scale = 1.0

func _ready():
	# Initialize camera
	current_state = CameraState.FREE

func _process(delta):
	match current_state:
		CameraState.FREE:
			process_free_camera(delta)
		CameraState.FOLLOW:
			process_follow_camera(delta)
		CameraState.TRANSITION:
			process_transition(delta)
		CameraState.ORBIT:
			process_orbit_camera(delta)

func process_free_camera(delta):
	# Handle direct camera movement with input
	var input_dir = get_input_direction()
	
	if input_dir.length_squared() > 0.1:
		# Apply movement in camera's local space
		global_position += global_transform.basis * input_dir * move_speed * delta
	
	# Handle rotation with right mouse button
	if Input.is_action_pressed(input_actions.orbit_rotate):
		var mouse_motion = Input.get_last_mouse_velocity() * delta * rotation_speed
		rotate_y(-mouse_motion.x * 0.01)
		rotate_object_local(Vector3.RIGHT, -mouse_motion.y * 0.01)
		
	# Handle zooming with mouse wheel
	var zoom_input = Input.get_action_strength(input_actions.zoom_in) - Input.get_action_strength(input_actions.zoom_out)
	if abs(zoom_input) > 0.1:
		# Adjust FOV for zoom effect
		fov = clamp(fov - zoom_input * zoom_speed * 10.0, 30, 90)

func process_follow_camera(delta):
	if not follow_target or not is_instance_valid(follow_target):
		current_state = CameraState.FREE
		return
		
	# Smoothly move toward target
	var target_pos = follow_target.global_position
	var target_offset = global_transform.basis * Vector3(0, 0, orbit_distance)
	
	global_position = global_position.lerp(target_pos - target_offset, smooth_factor)
	
	# Look at target
	look_at(target_pos, Vector3.UP)

func process_orbit_camera(delta):
	if not follow_target or not is_instance_valid(follow_target):
		current_state = CameraState.FREE
		return
	
	# Update orbit angle
	if Input.is_action_pressed(input_actions.orbit_rotate):
		var mouse_motion = Input.get_last_mouse_velocity() * delta * rotation_speed
		orbit_angle -= mouse_motion.x * 0.01
	
	# Calculate position in orbit
	var target_pos = follow_target.global_position
	var orbit_pos = target_pos + Vector3(
		cos(orbit_angle) * orbit_distance,
		orbit_height,
		sin(orbit_angle) * orbit_distance
	)
	
	# Smoothly move to orbit position
	global_position = global_position.lerp(orbit_pos, smooth_factor)
	
	# Look at target
	look_at(target_pos, Vector3.UP)
	
	# Handle zooming with mouse wheel
	var zoom_input = Input.get_action_strength(input_actions.zoom_in) - Input.get_action_strength(input_actions.zoom_out)
	if abs(zoom_input) > 0.1:
		# Adjust orbit distance
		orbit_distance = clamp(orbit_distance - zoom_input * zoom_speed * 5.0, 2.0, 50.0)

func begin_transition_to(target_pos, target_rot, duration = 1.0):
	transition_start_pos = global_position
	transition_end_pos = target_pos
	transition_start_rot = Quaternion(global_transform.basis)
	transition_end_rot = Quaternion(target_rot)
	transition_progress = 0.0
	transition_duration = duration
	current_state = CameraState.TRANSITION
	is_transitioning = true

func process_transition(delta):
	if !is_transitioning:
		return
		
	transition_progress += delta / transition_duration
	
	if transition_progress >= 1.0:
		# Transition complete
		global_position = transition_end_pos
		global_transform.basis = Basis(transition_end_rot)
		is_transitioning = false
		
		# Return to appropriate state
		if follow_target:
			current_state = CameraState.FOLLOW
		else:
			current_state = CameraState.FREE
		return
	
	# Apply smooth transition
	var t = ease(transition_progress, 0.5)  # Smooth easing
	global_position = transition_start_pos.lerp(transition_end_pos, t)
	
	# Spherical interpolation for rotation
	var current_rot = transition_start_rot.slerp(transition_end_rot, t)
	global_transform.basis = Basis(current_rot)
	
	# Handle scale transition if applicable
	if scale_transition_end != scale_transition_start:
		current_scale = lerp(scale_transition_start, scale_transition_end, t)
		emit_signal("scale_changed", current_scale)

func start_follow(target):
	if not target:
		return
		
	follow_target = target
	current_state = CameraState.FOLLOW

func start_orbit(target, initial_angle = 0.0):
	if not target:
		return
		
	follow_target = target
	orbit_angle = initial_angle
	current_state = CameraState.ORBIT

func set_orbit_parameters(distance: float, height: float):
	orbit_distance = distance
	orbit_height = height

func stop_follow():
	follow_target = null
	current_state = CameraState.FREE

func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed(input_actions.move_forward):
		direction -= Vector3.FORWARD
	if Input.is_action_pressed(input_actions.move_backward):
		direction += Vector3.FORWARD
	if Input.is_action_pressed(input_actions.move_left):
		direction -= Vector3.RIGHT
	if Input.is_action_pressed(input_actions.move_right):
		direction += Vector3.RIGHT
	if Input.is_action_pressed(input_actions.move_up):
		direction += Vector3.UP
	if Input.is_action_pressed(input_actions.move_down):
		direction -= Vector3.UP
		
	return direction.normalized()

func setup_for_scale(scale_name: String):
	match scale_name:
		"universe":
			move_speed = 100.0
			orbit_distance = 100.0
			orbit_height = 30.0
			fov = 70.0
		"galaxy":
			move_speed = 50.0
			orbit_distance = 50.0
			orbit_height = 15.0
			fov = 60.0
		"star_system":
			move_speed = 10.0
			orbit_distance = 10.0
			orbit_height = 5.0
			fov = 50.0
		"planet":
			move_speed = 1.0
			orbit_distance = 3.0
			orbit_height = 1.0
			fov = 45.0
		"element":
			move_speed = 0.1
			orbit_distance = 0.5
			orbit_height = 0.2
			fov = 40.0

func transition_to_scale(target_scale: String, target_pos: Vector3, target_rot: Basis, duration: float = 2.0):
	# Store scale transition data
	scale_transition_start = current_scale
	
	match target_scale:
		"universe":
			scale_transition_end = 1.0
		"galaxy":
			scale_transition_end = 0.1
		"star_system":
			scale_transition_end = 0.01
		"planet":
			scale_transition_end = 0.001
		"element":
			scale_transition_end = 0.0001
	
	# Start position/rotation transition
	begin_transition_to(target_pos, target_rot, duration)
	
	# Set up parameters for new scale
	setup_for_scale(target_scale)

func get_frustum():
	var frustum = []
	
	# Calculate frustum planes
	var near_height = tan(deg_to_rad(fov) * 0.5) * near
	var near_width = near_height * get_viewport().size.x / get_viewport().size.y
	
	var far_height = tan(deg_to_rad(fov) * 0.5) * far
	var far_width = far_height * get_viewport().size.x / get_viewport().size.y
	
	var near_center = global_position - global_transform.basis.z * near
	var far_center = global_position - global_transform.basis.z * far
	
	var right = global_transform.basis.x
	var up = global_transform.basis.y
	var forward = -global_transform.basis.z
	
	# Calculate 8 corners of frustum
	var near_top_left = near_center + up * near_height - right * near_width
	var near_top_right = near_center + up * near_height + right * near_width
	var near_bottom_left = near_center - up * near_height - right * near_width
	var near_bottom_right = near_center - up * near_height + right * near_width
	
	var far_top_left = far_center + up * far_height - right * far_width
	var far_top_right = far_center + up * far_height + right * far_width
	var far_bottom_left = far_center - up * far_height - right * far_width
	var far_bottom_right = far_center - up * far_height + right * far_width
	
	# Calculate planes
	frustum.append(Plane(near_top_left, near_top_right, near_bottom_right))  # Near
	frustum.append(Plane(far_top_right, far_top_left, far_bottom_left))  # Far
	frustum.append(Plane(near_top_left, near_bottom_left, far_bottom_left))  # Left
	frustum.append(Plane(near_top_right, far_top_right, far_bottom_right))  # Right
	frustum.append(Plane(near_top_left, far_top_left, far_top_right))  # Top
	frustum.append(Plane(near_bottom_left, near_bottom_right, far_bottom_right))  # Bottom
	
	return frustum

func is_point_in_frustum(point: Vector3) -> bool:
	var frustum = get_frustum()
	
	for plane in frustum:
		if plane.distance_to(point) < 0:
			return false
			
	return true
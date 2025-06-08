extends Camera3D
class_name UltimateCameraSystem

# The camera that sees all dimensions
var reality_rotation = Vector2.ZERO
var consciousness_speed = 20.0
var perception_sensitivity = 0.002
var dream_mode = false
var cosmic_zoom = 1.0

# Advanced camera modes
enum CameraMode {
	HUMAN_PERSPECTIVE,
	AI_VISION,
	COSMIC_OVERVIEW,
	CODE_MICROSCOPE,
	DREAM_FLOAT
}

var current_mode = CameraMode.HUMAN_PERSPECTIVE
var mode_transitions = {}

func _ready():
	print("🎥 ULTIMATE CAMERA SYSTEM ONLINE")
	setup_mode_transitions()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		reality_rotation.x -= event.relative.x * perception_sensitivity
		reality_rotation.y = clamp(reality_rotation.y - event.relative.y * perception_sensitivity, -1.5, 1.5)
		rotation = Vector3(reality_rotation.y, reality_rotation.x, 0)
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	
	# Camera mode switching
	if Input.is_key_pressed(KEY_1):
		switch_to_mode(CameraMode.HUMAN_PERSPECTIVE)
	elif Input.is_key_pressed(KEY_2):
		switch_to_mode(CameraMode.AI_VISION)
	elif Input.is_key_pressed(KEY_3):
		switch_to_mode(CameraMode.COSMIC_OVERVIEW)
	elif Input.is_key_pressed(KEY_4):
		switch_to_mode(CameraMode.CODE_MICROSCOPE)
	elif Input.is_key_pressed(KEY_5):
		switch_to_mode(CameraMode.DREAM_FLOAT)

func _process(delta):
	handle_movement(delta)
	update_camera_mode(delta)
	
	# Zoom with mouse wheel
	if Input.is_action_just_pressed("cam_zoom_in"):
		cosmic_zoom = clamp(cosmic_zoom - 0.1, 0.1, 5.0)
		fov = 75 + (cosmic_zoom - 1.0) * 30
	elif Input.is_action_just_pressed("cam_zoom_out"):
		cosmic_zoom = clamp(cosmic_zoom + 0.1, 0.1, 5.0)
		fov = 75 + (cosmic_zoom - 1.0) * 30

func handle_movement(delta):
	var input_vector = Vector3()
	
	# Movement based on camera mode
	var speed_multiplier = get_speed_for_mode()
	
	if Input.is_action_pressed("move_forward"):
		input_vector.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_vector.z += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y += 1
	if Input.is_action_pressed("move_down"):
		input_vector.y -= 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		input_vector = global_transform.basis * input_vector
		global_position += input_vector * consciousness_speed * speed_multiplier * delta

func switch_to_mode(new_mode: CameraMode):
	if current_mode == new_mode:
		return
		
	print("📹 Camera mode: " + get_mode_name(new_mode))
	current_mode = new_mode
	
	# Trigger mode transition effect
	create_mode_transition_effect()

func update_camera_mode(delta):
	match current_mode:
		CameraMode.HUMAN_PERSPECTIVE:
			# Standard human view
			consciousness_speed = 20.0
			perception_sensitivity = 0.002
			
		CameraMode.AI_VISION:
			# AI-like scanning vision
			consciousness_speed = 15.0
			perception_sensitivity = 0.001
			add_ai_vision_effect(delta)
			
		CameraMode.COSMIC_OVERVIEW:
			# High-speed cosmic travel
			consciousness_speed = 100.0
			perception_sensitivity = 0.0005
			add_cosmic_trail_effect(delta)
			
		CameraMode.CODE_MICROSCOPE:
			# Precise code inspection
			consciousness_speed = 5.0
			perception_sensitivity = 0.005
			add_code_focus_effect(delta)
			
		CameraMode.DREAM_FLOAT:
			# Floating dream-like movement
			consciousness_speed = 8.0
			perception_sensitivity = 0.0008
			add_dream_float_effect(delta)

func get_speed_for_mode() -> float:
	match current_mode:
		CameraMode.COSMIC_OVERVIEW: return 5.0
		CameraMode.CODE_MICROSCOPE: return 0.3
		CameraMode.DREAM_FLOAT: return 1.5
		_: return 1.0

func get_mode_name(mode: CameraMode) -> String:
	match mode:
		CameraMode.HUMAN_PERSPECTIVE: return "👁️ Human Perspective"
		CameraMode.AI_VISION: return "🤖 AI Vision"
		CameraMode.COSMIC_OVERVIEW: return "🌌 Cosmic Overview"
		CameraMode.CODE_MICROSCOPE: return "🔬 Code Microscope"
		CameraMode.DREAM_FLOAT: return "💭 Dream Float"
		_: return "Unknown"

func add_ai_vision_effect(delta):
	# Subtle scanning line effect
	var time = Time.get_ticks_msec() * 0.001
	var scan_intensity = sin(time * 3.0) * 0.1 + 0.9
	# Would add post-processing shader here

func add_cosmic_trail_effect(delta):
	# Motion blur and particle trails
	var velocity = global_position - get_meta("last_position", global_position)
	set_meta("last_position", global_position)
	# Would add velocity-based effects here

func add_code_focus_effect(delta):
	# Enhanced focus on nearby programmable points
	var time = Time.get_ticks_msec() * 0.001
	var focus_pulse = sin(time * 2.0) * 0.05 + 1.0
	# Would highlight nearby code objects

func add_dream_float_effect(delta):
	# Gentle floating motion
	var time = Time.get_ticks_msec() * 0.001
	var float_offset = Vector3(
		sin(time * 0.5) * 0.1,
		cos(time * 0.3) * 0.05,
		sin(time * 0.7) * 0.08
	)
	global_position += float_offset * delta

func create_mode_transition_effect():
	# Visual feedback for mode switching
	var effect_node = Node3D.new()
	effect_node.position = global_position
	get_parent().add_child(effect_node)
	
	# Create transition particles
	var particles = GPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 1.0
	particles.emitting = true
	
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 0, 0)
	particle_mat.initial_velocity_min = 5.0
	particle_mat.initial_velocity_max = 10.0
	particle_mat.gravity = Vector3.ZERO
	particle_mat.scale_min = 0.1
	particle_mat.scale_max = 0.3
	particle_mat.color = Color.CYAN
	particles.process_material = particle_mat
	
	effect_node.add_child(particles)
	
	# Clean up after effect
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): effect_node.queue_free())
	effect_node.add_child(timer)
	timer.start()

func setup_mode_transitions():
	# Define smooth transitions between modes
	pass

# AI can call these methods to control camera
func ai_look_at_point(target: Vector3):
	var direction = (target - global_position).normalized()
	var target_rotation = direction.get_euler()
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", target_rotation, 1.0)

func ai_move_to_position(target: Vector3, speed: float = 1.0):
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, speed)

func ai_set_fov(new_fov: float):
	var tween = create_tween()
	tween.tween_property(self, "fov", new_fov, 0.5)
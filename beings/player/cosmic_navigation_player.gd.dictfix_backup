# COSMIC NAVIGATION PLAYER - FOR 3D SCRIPTURA EXPLORATION
# Smooth movement through the debug chamber and cosmic environments
extends CharacterBody3D
class_name CosmicNavigationPlayer

signal player_moved(new_position: Vector3)
signal interaction_detected(object: Node3D, distance: float)
signal cosmic_portal_entered(portal_name: String)

# Movement configuration
@export var base_speed: float = 15.0
@export var sprint_speed: float = 30.0
@export var cosmic_speed: float = 100.0  # For large cosmic distances
@export var mouse_sensitivity: float = 0.002
@export var smooth_factor: float = 10.0

# Camera and view
@onready var camera: Camera3D = $CosmicCamera
@onready var interaction_ray: RayCast3D = $CosmicCamera/InteractionRay

# Navigation state
var current_speed: float = 15.0
var is_cosmic_mode: bool = false
var is_flying: bool = true  # Always flying in cosmic space
var target_object: Node3D = null
var auto_pilot: bool = false

# Interaction system
var nearby_objects: Array = []
var interaction_range: float = 10.0

func _ready():
	print("🚀 Cosmic Navigation Player initialized")
	setup_camera()
	setup_interaction_system()
	
	# Capture mouse for 3D navigation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func setup_camera():
	"""Setup the cosmic camera for optimal 3D navigation"""
	if not camera:
		camera = Camera3D.new()
		camera.name = "CosmicCamera"
		add_child(camera)
	
	camera.fov = 75  # Wide field of view for cosmic exploration
	camera.position = Vector3(0, 1.8, 0)  # Eye level

func setup_interaction_system():
	"""Setup interaction detection system"""
	if not interaction_ray:
		interaction_ray = RayCast3D.new()
		interaction_ray.name = "InteractionRay"
		camera.add_child(interaction_ray)
	
	interaction_ray.target_position = Vector3(0, 0, -20)  # 20 units forward
	interaction_ray.enabled = true

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event.relative)
	elif event is InputEventKey and event.pressed:
		handle_key_input(event)

func handle_mouse_look(relative_motion: Vector2):
	"""Handle mouse look for 3D navigation"""
	# Rotate player horizontally
	rotate_y(-relative_motion.x * mouse_sensitivity)
	
	# Rotate camera vertically (with limits)
	camera.rotation.x = clamp(
		camera.rotation.x - relative_motion.y * mouse_sensitivity,
		-PI/2, PI/2
	)

func handle_key_input(event: InputEvent):
	"""Handle keyboard shortcuts for cosmic navigation"""
	match event.keycode:
		KEY_ESCAPE:
			toggle_mouse_mode()
		KEY_SHIFT:
			# Enter cosmic speed mode
			is_cosmic_mode = true
			current_speed = cosmic_speed
			print("🌌 COSMIC SPEED ACTIVATED")
		KEY_C:
			# Toggle cosmic/normal mode
			toggle_cosmic_mode()
		KEY_F:
			# Fly to nearest interesting object
			fly_to_nearest_object()
		KEY_R:
			# Reset to center of debug chamber
			reset_to_cosmic_center()

func _physics_process(delta):
	handle_movement(delta)
	handle_interactions()
	
	# Emit position updates
	player_moved.emit(global_position)

func handle_movement(delta):
	"""Handle 3D movement with smooth acceleration"""
	var input_vector = Vector3.ZERO
	
	# Get input directions
	if Input.is_action_pressed("move_forward"):
		input_vector -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_vector += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_vector -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_vector += transform.basis.x
	
	# Vertical movement (flying in cosmic space)
	if Input.is_action_pressed("move_up"):
		input_vector += Vector3.UP
	if Input.is_action_pressed("move_down"):
		input_vector -= Vector3.UP
	
	# Determine movement speed
	var target_speed = base_speed
	if Input.is_action_pressed("sprint") or is_cosmic_mode:
		target_speed = cosmic_speed if is_cosmic_mode else sprint_speed
	
	# Reset cosmic mode after shift release
	if not Input.is_action_pressed("sprint"):
		is_cosmic_mode = false
		current_speed = base_speed
	
	# Apply movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = velocity.lerp(input_vector * target_speed, smooth_factor * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, smooth_factor * delta)
	
	# Move the player
	move_and_slide()

func handle_interactions():
	"""Handle detection and interaction with cosmic objects"""
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		var distance = global_position.distance_to(interaction_ray.get_collision_point())
		
		if collider != target_object:
			target_object = collider
			interaction_detected.emit(collider, distance)
			
			# Show interaction hint
			show_interaction_hint(collider, distance)

func show_interaction_hint(object: Node3D, distance: float):
	"""Show floating interaction hint for detected objects"""
	var hint_text = get_interaction_hint_text(object)
	
	if hint_text != "":
		var hint = Label3D.new()
		hint.text = hint_text + "\\n[Distance: %.1fm]" % distance
		hint.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		hint.position = object.global_position + Vector3(0, 2, 0)
		hint.modulate = Color.CYAN
		hint.pixel_size = 0.01
		get_parent().add_child(hint)
		
		# Auto-remove hint after 3 seconds
		var timer = Timer.new()
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(hint.queue_free)
		get_parent().add_child(timer)
		timer.start()

func get_interaction_hint_text(object: Node3D) -> String:
	"""Get appropriate interaction hint text based on object type"""
	if object.has_meta("script_path"):
		return "⭐ SCRIPT STAR\\nClick to analyze: %s" % object.get_meta("script_path", "").get_file()
	elif object.has_meta("md_path"):
		return "📝 DOCUMENTATION\\nClick to read: %s" % object.get_meta("md_path", "").get_file()
	elif "Cinema" in object.name:
		return "🎬 SCRIPTURA CINEMA\\nEnter for code analysis"
	elif "Debug" in object.name:
		return "🔍 DEBUG CHAMBER\\nEnter cosmic debugging mode"
	else:
		return "🎯 COSMIC OBJECT\\nPress E to interact"

func toggle_mouse_mode():
	"""Toggle between captured and visible mouse mode"""
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("🖱️ Mouse released - UI mode")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("🎮 Mouse captured - navigation mode")

func toggle_cosmic_mode():
	"""Toggle between normal and cosmic navigation speeds"""
	is_cosmic_mode = not is_cosmic_mode
	current_speed = cosmic_speed if is_cosmic_mode else base_speed
	
	var mode_text = "COSMIC" if is_cosmic_mode else "NORMAL"
	print("🌌 Navigation mode: %s (Speed: %.1f)" % [mode_text, current_speed])

func fly_to_nearest_object():
	"""Automatically fly to the nearest interesting object"""
	var nearest_object = find_nearest_interesting_object()
	if nearest_object:
		start_auto_pilot(nearest_object.global_position)
		print("🚀 Flying to: %s" % nearest_object.name)

func find_nearest_interesting_object() -> Node3D:
	"""Find the nearest script star, documentation, or debug object"""
	var nearest: Node3D = null
	var min_distance: float = 1000.0
	
	# Search in parent scene for interesting objects
	if get_parent():
		for child in get_parent().get_children():
			if has_interesting_metadata(child):
				var distance = global_position.distance_to(child.global_position)
				if distance < min_distance:
					min_distance = distance
					nearest = child
	
	return nearest

func has_interesting_metadata(object: Node3D) -> bool:
	"""Check if an object has interesting metadata for navigation"""
	return (object.has_meta("script_path") or 
			object.has_meta("md_path") or
			"Star_" in object.name or
			"Cinema" in object.name or
			"Debug" in object.name)

func start_auto_pilot(target_position: Vector3):
	"""Start auto-pilot to fly to a specific position"""
	auto_pilot = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position + Vector3(0, 5, 5), 2.0)
	tween.tween_callback(func(): auto_pilot = false)

func reset_to_cosmic_center():
	"""Reset player to the center of the cosmic debug chamber"""
	global_position = Vector3(0, 50, 100)
	rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	print("🌌 Returned to cosmic center")

# Public interface for external systems
func teleport_to_position(position: Vector3, look_at_target: Vector3 = Vector3.ZERO):
	"""Teleport player to a specific position"""
	global_position = position
	if look_at_target != Vector3.ZERO:
		look_at(look_at_target, Vector3.UP)
	
	print("⚡ Teleported to: %v" % position)

func set_navigation_speed(speed: float):
	"""Set navigation speed for external control"""
	current_speed = speed
	base_speed = speed

func get_camera_position() -> Vector3:
	"""Get current camera world position"""
	return camera.global_position

func get_camera_forward() -> Vector3:
	"""Get camera forward direction"""
	return -camera.global_transform.basis.z

func enable_cosmic_navigation():
	"""Enable cosmic-scale navigation for large environments"""
	is_cosmic_mode = true
	current_speed = cosmic_speed
	print("🌌 Cosmic navigation enabled - exploring at light speed!")

func disable_cosmic_navigation():
	"""Return to normal navigation speed"""
	is_cosmic_mode = false
	current_speed = base_speed
	print("🚶 Normal navigation restored")
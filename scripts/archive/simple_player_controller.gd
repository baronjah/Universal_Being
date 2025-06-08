# ==================================================
# UNIVERSAL BEING: Simple Player Controller
# TYPE: player
# PURPOSE: Basic player that can move and interact with 3D objects
# ==================================================

extends UniversalBeing
class_name SimplePlayerController

# ===== MOVEMENT PROPERTIES =====
@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var interaction_range: float = 3.0

# Player components
var camera: Camera3D
var interaction_ray: RayCast3D
var cursor_mesh: MeshInstance3D

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "player"
	being_name = "Player"
	consciousness_level = 1

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Set up camera (look for camera_point.tscn in socket)
	var camera_point = find_child("CameraPoint")
	if not camera_point:
		# Create camera if not found
		camera = Camera3D.new()
		add_child(camera)
		camera.position = Vector3(0, 1.6, 0)
	else:
		camera = camera_point.find_child("Camera3D")
	
	# Set up interaction ray
	interaction_ray = RayCast3D.new()
	if camera:
		camera.add_child(interaction_ray)
	else:
		add_child(interaction_ray)
	interaction_ray.target_position = Vector3(0, 0, -interaction_range)
	interaction_ray.collision_mask = 1
	
	# Set up cursor visual
	cursor_mesh = find_child("CursorMesh") as MeshInstance3D
	
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Handle movement
	var input_vector = Vector2()
	if Input.is_action_pressed("move_forward"):
		input_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	
	# Move based on camera direction
	if input_vector.length() > 0 and camera:
		var direction = (camera.global_transform.basis * Vector3(input_vector.x, 0, -input_vector.y)).normalized()
		direction.y = 0  # Keep movement horizontal
		global_position += direction * move_speed * delta
	
	# Check for interactions
	if interaction_ray and interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		# Highlight what we're looking at
		if cursor_mesh:
			cursor_mesh.visible = true
			cursor_mesh.global_position = interaction_ray.get_collision_point()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if camera:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			# Clamp vertical look
			camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	
	# Interact on click
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_try_interact()
	
	# Toggle mouse capture
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pentagon_sewers() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	super.pentagon_sewers()

# ===== INTERACTION METHODS =====

func _try_interact() -> void:
	if not interaction_ray or not interaction_ray.is_colliding():
		return
	
	var collider = interaction_ray.get_collider()
	if not collider:
		return
	
	# Check if it's an Area3D (for button interaction)
	if collider is Area3D:
		var parent = collider.get_parent()
		if parent:
			# Check up the tree for a UniversalBeing
			var current = parent
			while current:
				if current is UniversalBeing:
					print("🎯 Player interacting with: ", current.being_name)
					# Trigger click if it's a button
					if current.has_method("_on_button_clicked"):
						current._on_button_clicked()
					break
				current = current.get_parent()

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base = super.ai_interface()
	base.player_state = {
		"position": global_position,
		"looking_at": interaction_ray.get_collision_point() if interaction_ray and interaction_ray.is_colliding() else null
	}
	return base

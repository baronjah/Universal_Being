# ==================================================
# STAR NAVIGATION PLAYER - Cosmic Script Exploration
# Surgeon: Claude Code (Programmer Role) 
# Patient: COSMIC_STAR_NAVIGATION scene
# Purpose: WASD movement + mouse camera + star interaction
# ==================================================

extends CharacterBody3D
class_name StarNavigationPlayer

# ===== MOVEMENT PROPERTIES =====
@export var move_speed: float = 8.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var air_acceleration: float = 5.0
@export var jump_velocity: float = 8.0

# Camera and interaction
var camera: Camera3D = null
var mouse_sensitivity: float = 0.002
var is_mouse_captured: bool = false

# Star interaction
var interaction_range: float = 5.0
var highlighted_star: Node3D = null

# UI elements
var fps_display: Label = null
var velocity_display: Label = null
var crosshair: Control = null

# Input state manager reference
var input_manager: Node = null

# ===== INITIALIZATION =====

func _ready() -> void:
	add_to_group("player")
	
	# Set up camera
	_setup_camera()
	
	# Create UI overlay
	_create_ui_overlay()
	
	# Connect to input manager
	_connect_to_input_manager()
	
	# Enable input processing
	set_physics_process(true)
	
	print("🌟 StarNavigationPlayer ready for cosmic exploration")

func _setup_camera() -> void:
	"""Set up camera for first-person star navigation"""
	camera = get_node_or_null("CameraPlasmoid")
	if camera:
		camera.current = true
		print("🎥 Camera connected for star navigation")
	else:
		# Create basic camera if none exists
		camera = Camera3D.new()
		camera.name = "CameraPlasmoid"
		camera.position = Vector3(0, 1.6, 0)  # Eye level
		add_child(camera)
		camera.current = true
		print("🎥 Created basic camera for star navigation")

func _create_ui_overlay() -> void:
	"""Create UI overlay with FPS, velocity, and crosshair"""
	
	# Create UI container
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "StarNavUI"
	add_child(ui_layer)
	
	# FPS Display (top-left, blue theme)
	fps_display = Label.new()
	fps_display.position = Vector2(10, 10)
	fps_display.add_theme_font_size_override("font_size", 16)
	fps_display.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	fps_display.text = "FPS: --"
	ui_layer.add_child(fps_display)
	
	# Velocity Display (top-left, purple theme)
	velocity_display = Label.new()
	velocity_display.position = Vector2(10, 35)
	velocity_display.add_theme_font_size_override("font_size", 14)
	velocity_display.add_theme_color_override("font_color", Color(0.8, 0.5, 1.0))
	velocity_display.text = "Velocity: 0.0"
	ui_layer.add_child(velocity_display)
	
	# Crosshair (center, bright cyan)
	crosshair = Control.new()
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var crosshair_label = Label.new()
	crosshair_label.text = "+"
	crosshair_label.add_theme_font_size_override("font_size", 24)
	crosshair_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	crosshair_label.position = Vector2(-8, -12)  # Center the + symbol
	crosshair.add_child(crosshair_label)
	
	ui_layer.add_child(crosshair)
	
	print("🎯 Star navigation UI created with blue/purple theme")

func _connect_to_input_manager() -> void:
	"""Connect to the input state manager"""
	# For now, we'll handle input directly until InputStateManager is integrated
	print("🎮 Direct input handling active (InputStateManager integration pending)")

# ===== PHYSICS AND MOVEMENT =====

func _physics_process(delta: float) -> void:
	# Update UI
	_update_ui_display()
	
	# COSMIC SPACE NAVIGATION - No gravity, pure plasmoid flight
	# Handle movement in zero-G space
	_handle_movement(delta)
	
	# Move the plasmoid through space
	move_and_slide()
	
	# Check for star interactions
	_check_star_interaction()

func _handle_movement(delta: float) -> void:
	"""Handle 6DOF plasmoid movement in cosmic space"""
	var input_dir = Vector3.ZERO
	
	# Get input direction - full 6 degrees of freedom
	if Input.is_action_pressed("move_forward"):  # W
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"): # S
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):     # A
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):    # D
		input_dir.x += 1
	if Input.is_action_pressed("ui_accept"):     # Space - up
		input_dir.y += 1
	if Input.is_action_pressed("ui_cancel"):     # Shift - down
		input_dir.y -= 1
	
	# Normalize diagonal movement
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		
		# Transform movement relative to camera (full 3D)
		if camera:
			var cam_transform = camera.global_transform
			var forward = -cam_transform.basis.z
			var right = cam_transform.basis.x
			var up = cam_transform.basis.y
			
			# Calculate movement direction in full 3D space
			var move_direction = (forward * -input_dir.z + right * input_dir.x + up * input_dir.y)
			
			# Apply acceleration - smooth plasmoid flight
			var target_velocity = move_direction * move_speed
			
			velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
			velocity.y = move_toward(velocity.y, target_velocity.y, acceleration * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	else:
		# Apply space friction when no input - plasmoids drift gently to stop
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.y = move_toward(velocity.y, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

# ===== MOUSE AND CAMERA =====

func _input(event: InputEvent) -> void:
	"""Handle mouse camera control and interaction"""
	
	# Mouse capture toggle
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_toggle_mouse_capture()
	
	# Mouse camera control when captured
	if is_mouse_captured and event is InputEventMouseMotion and camera:
		_handle_mouse_camera(event.relative)
	
	# Star interaction
	if event.is_action_pressed("interact"):
		_interact_with_highlighted_star()

func _handle_mouse_camera(relative_motion: Vector2) -> void:
	"""Handle mouse camera rotation"""
	if not camera:
		return
	
	# Horizontal rotation (Y-axis)
	rotate_y(-relative_motion.x * mouse_sensitivity)
	
	# Vertical rotation (X-axis) - limit to prevent over-rotation
	var vertical_rotation = -relative_motion.y * mouse_sensitivity
	var current_x_rotation = camera.rotation.x
	var new_x_rotation = clamp(current_x_rotation + vertical_rotation, -PI/2 + 0.1, PI/2 - 0.1)
	camera.rotation.x = new_x_rotation

func _toggle_mouse_capture() -> void:
	"""Toggle mouse capture for camera control"""
	is_mouse_captured = !is_mouse_captured
	
	if is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("🖱️ Mouse captured for camera control")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("🖱️ Mouse released for cursor interaction")

# ===== STAR INTERACTION SYSTEM =====

func _check_star_interaction() -> void:
	"""Check for nearby stars to interact with"""
	if not camera:
		return
	
	# Cast ray from camera forward
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * interaction_range)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	# Clear previous highlight
	_clear_star_highlight()
	
	if result and result.collider:
		var hit_object = result.collider
		
		# Check if it's a star (part of bucket constellation system)
		if _is_star_object(hit_object):
			_highlight_star(hit_object)

func _is_star_object(object: Node) -> bool:
	"""Check if object is a navigable star"""
	# Stars are likely created by BucketConstellationManager
	return object.name.contains("Star") or object.name.contains("Script") or object.has_method("get_script_info")

func _highlight_star(star: Node3D) -> void:
	"""Highlight a star for interaction"""
	highlighted_star = star
	
	# Visual highlight (change material if possible)
	if star.has_method("set_highlighted"):
		star.set_highlighted(true)
	
	# Update crosshair to show interaction
	if crosshair:
		var crosshair_label = crosshair.get_child(0)
		crosshair_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))  # Yellow when targeting
		crosshair_label.text = "✦"  # Star symbol

func _clear_star_highlight() -> void:
	"""Clear star highlighting"""
	if highlighted_star:
		if highlighted_star.has_method("set_highlighted"):
			highlighted_star.set_highlighted(false)
		highlighted_star = null
	
	# Reset crosshair
	if crosshair:
		var crosshair_label = crosshair.get_child(0)
		crosshair_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))  # Cyan default
		crosshair_label.text = "+"

func _interact_with_highlighted_star() -> void:
	"""Interact with the currently highlighted star"""
	if not highlighted_star:
		return
	
	print("⭐ Interacting with star: %s" % highlighted_star.name)
	
	# Get script information if available
	if highlighted_star.has_method("get_script_info"):
		var script_info = highlighted_star.get_script_info()
		_display_script_info(script_info)
	
	# Navigate to script if possible
	if highlighted_star.has_method("navigate_to_script"):
		highlighted_star.navigate_to_script()

func _display_script_info(script_info: Dictionary) -> void:
	"""Display script information in console or UI"""
	print("📜 Script Info: %s" % script_info)
	
	# Send to console if available
	var console_nodes = get_tree().get_nodes_in_group("console")
	if console_nodes.size() > 0:
		var console = console_nodes[0]
		if console.has_method("display_message"):
			console.display_message("📜 Script: %s" % script_info.get("name", "Unknown"))
			console.display_message("📁 Path: %s" % script_info.get("path", "Unknown"))

# ===== UI UPDATES =====

func _update_ui_display() -> void:
	"""Update FPS and velocity displays"""
	if fps_display:
		var fps = Engine.get_frames_per_second()
		var color = Color.GREEN if fps >= 60 else Color.YELLOW if fps >= 45 else Color.RED
		fps_display.add_theme_color_override("font_color", color)
		fps_display.text = "FPS: %d" % fps
	
	if velocity_display:
		var speed = Vector3(velocity.x, 0, velocity.z).length()
		velocity_display.text = "Speed: %.1f" % speed

# ===== PUBLIC API =====

func teleport_to(position: Vector3) -> void:
	"""Teleport player to position"""
	global_position = position
	velocity = Vector3.ZERO

func set_mouse_captured(captured: bool) -> void:
	"""Set mouse capture state (for external control)"""
	is_mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE

func get_camera() -> Camera3D:
	"""Get the player's camera"""
	return camera

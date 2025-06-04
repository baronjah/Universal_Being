# ==================================================
# UNIVERSAL BEING: Player Character
# TYPE: player
# PURPOSE: The player's avatar in the Universal Being world
# FEATURES: Movement, interaction, consciousness visualization
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name PlayerUniversalBeing

# ===== PLASMOID PROPERTIES =====
@export var move_speed: float = 5.0
@export var float_height: float = 2.0
@export var mouse_sensitivity: float = 0.002
@export var interaction_range: float = 3.0

# Movement state  
var velocity: Vector3 = Vector3.ZERO

# Camera reference
var camera: Camera3D = null
var camera_pivot: Node3D = null

# Visual components
var mesh_instance: MeshInstance3D
var player_collision_shape: CollisionShape3D
var consciousness_light: OmniLight3D

# Interaction with other beings
var highlighted_being: UniversalBeing = null
var last_interacted_being: UniversalBeing = null

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "plasmoid"
	being_name = "Player Plasmoid"
	consciousness_level = 4  # Enlightened consciousness - energy being
	
	# Set up as player
	add_to_group("player")
	
	# Set default hover height
	global_position.y = float_height
	
	print("⚡ %s: Pentagon Init - Energy consciousness awakens" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# The player being extends UniversalBeing but acts as a character controller
	
	# Create visual representation
	_create_player_body()
	
	# Set up camera following
	_setup_camera()
	
	# Enable input
	set_process_input(true)
	set_physics_process(true)
	
	# Connect to perfect console for commands
	var console_nodes = get_tree().get_nodes_in_group("console")
	if console_nodes.size() > 0:
		var console = console_nodes.front()
		if console:
			print("🎮 Player connected to console")
	
	# Register with cursor for interaction
	var cursor_nodes = get_tree().get_nodes_in_group("cursor")
	if cursor_nodes.size() > 0:
		var cursor = cursor_nodes.front()
		if cursor and cursor.has_method("set_player_reference"):
			cursor.set_player_reference(self)
	
	print("⚡ %s: Pentagon Ready - Plasmoid controls active" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update consciousness glow with plasmoid energy fluctuation
	if consciousness_light:
		consciousness_light.light_energy = 1.0 + sin(Time.get_ticks_msec() * 0.002) * 0.3
	
	# Plasmoid vision raycast - preview what we're looking at
	_plasmoid_vision_raycast()
	
	# Check for nearby beings in our energy field
	_check_nearby_beings()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Trackball camera handles mouse input automatically
	# No manual mouse handling needed!
	
	# Plasmoid interaction with what we're looking at
	if event.is_action_pressed("interact") and highlighted_being:
		_interact_with_being(highlighted_being)
	
	# Open console
	if event.is_action_pressed("open_console"):
		_toggle_console()

func pentagon_sewers() -> void:
	print("⚡ %s: Plasmoid energy dispersing..." % being_name)
	super.pentagon_sewers()

# ===== PLAYER BODY CREATION =====

func _create_player_body() -> void:
	"""Create the visual plasmoid body for the player"""
	# Create mesh instance - sphere for plasmoid form
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "PlasmoidMesh"
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	mesh_instance.mesh = sphere
	
	# Plasmoid material with energy glow
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.7, 1.0, 0.8)  # Semi-transparent blue
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color(0.5, 0.8, 1.0, 1)
	material.emission_energy = 1.5
	material.rim_enabled = true
	material.rim_tint = 0.5
	mesh_instance.material_override = material
	add_child(mesh_instance)
	
	# No collision shape needed - we're a pure energy being!
	
	# Create consciousness light with more energy
	consciousness_light = OmniLight3D.new()
	consciousness_light.name = "ConsciousnessLight"
	consciousness_light.position.y = 0  # Center of plasmoid
	consciousness_light.light_color = Color(0.3, 0.7, 1.0, 1)
	consciousness_light.light_energy = 1.0
	consciousness_light.omni_range = 8.0
	add_child(consciousness_light)

# ===== PLASMOID MOVEMENT =====

func _physics_process(delta: float) -> void:
	# Plasmoid movement - no gravity, free floating like text-based game
	
	# Get input direction in 3D space (W=FORWARD IS LAW!)
	var input_dir = Vector3()
	if Input.is_action_pressed("move_forward"):  # W = FORWARD
		input_dir.z += 1  # POSITIVE Z = FORWARD IN CAMERA SPACE
	if Input.is_action_pressed("move_backward"): # S = BACKWARD  
		input_dir.z -= 1
	if Input.is_action_pressed("move_left"):     # A = LEFT
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):    # D = RIGHT
		input_dir.x += 1
	
	# Vertical movement like a hovering plasmoid
	if Input.is_action_pressed("jump"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_down"):  # Use existing action for down movement
		input_dir.y -= 1
	
	input_dir = input_dir.normalized()
	
	# Calculate movement direction relative to camera
	if camera_pivot and input_dir.length() > 0:
		var camera_transform = camera_pivot.global_transform
		var forward = -camera_transform.basis.z
		var right = camera_transform.basis.x
		var up = Vector3.UP
		
		# Keep forward/right horizontal for X-Z movement only
		forward.y = 0
		forward = forward.normalized()
		right.y = 0
		right = right.normalized()
		
		# Calculate movement direction (W=FORWARD LAW!)
		var move_direction = Vector3.ZERO
		move_direction += forward * input_dir.z  # W/S = Forward/backward in camera direction
		move_direction += right * input_dir.x    # A/D = Left/right relative to camera
		move_direction += up * input_dir.y       # Space/Shift = Up/down (absolute)
		
		if move_direction.length() > 0:
			move_direction = move_direction.normalized()
			velocity = move_direction * move_speed
	else:
		# Smoothly stop when no input
		velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta * 3)
	
	# Apply plasmoid movement - smooth floating
	global_position += velocity * delta
	
	# Add gentle floating animation to the visual mesh
	var float_offset = sin(Time.get_ticks_msec() * 0.002) * 0.1
	if mesh_instance:
		mesh_instance.position.y = float_offset
	
	# No ground detection needed - we're a floating plasmoid!

# ===== CAMERA SETUP =====

func _setup_camera() -> void:
	"""Set up camera using your prepared trackball camera scene"""
	# Load your personally prepared camera scene with trackball
	var camera_scene = load("res://scenes/main/camera_point.tscn")
	if camera_scene:
		var camera_instance = camera_scene.instantiate()
		camera_instance.name = "PlayerCameraPoint"
		
		# Parent the camera to the player so trackball rotates around the player
		add_child(camera_instance)
		
		# Find the TrackballCamera
		var trackball_camera = camera_instance.get_node_or_null("TrackballCamera")
		if trackball_camera:
			camera = trackball_camera
			camera_pivot = camera_instance  # The container node
			
			# Set initial trackball camera position and properties
			camera.position = Vector3(0, 5, 10)  # Start behind and above player
			camera.look_at(Vector3.ZERO, Vector3.UP)  # Look at player (center of parent)
			
			# Configure trackball camera settings
			if camera.has_method("set_mouse_sensitivity"):
				camera.set_mouse_sensitivity(mouse_sensitivity)
			
			# Enable smooth camera following
			camera.enabled = true
		else:
			print("⚠️ TrackballCamera not found in scene, trying fallback")
			camera = _find_camera_in_node(camera_instance)
			camera_pivot = camera_instance
		
		# Camera setup complete - notify console
		var console = get_tree().get_nodes_in_group("console").front()
		if console and console.has_method("add_message"):
			console.add_message("system", "Player camera system initialized")
	else:
		# Fallback to basic camera
		_create_basic_camera()

func _find_camera_in_node(node: Node) -> Camera3D:
	"""Recursively find Camera3D in node tree"""
	if node is Camera3D:
		return node
	
	for child in node.get_children():
		var found_camera = _find_camera_in_node(child)
		if found_camera:
			return found_camera
	
	return null

func _create_basic_camera() -> void:
	"""Fallback basic camera creation"""
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera_pivot.position.y = 1.5
	
	camera = Camera3D.new()
	camera.name = "BasicCamera"
	camera.position = Vector3(0, 2, 5)
	camera_pivot.add_child(camera)

# ===== PLASMOID VISION SYSTEM =====

func _plasmoid_vision_raycast() -> void:
	"""Cast plasmoid energy beam to preview interaction targets"""
	if not camera:
		return
	
	var space_state = get_world_3d().direct_space_state
	if not space_state:
		return
	
	# Cast from camera center outward
	var camera_pos = camera.global_position
	var camera_forward = -camera.global_transform.basis.z
	var target_pos = camera_pos + camera_forward * interaction_range
	
	var query = PhysicsRayQueryParameters3D.create(camera_pos, target_pos)
	# Note: No need to exclude ourselves since we don't have collision shape
	
	var result = space_state.intersect_ray(query)
	
	# Clear previous highlight
	_clear_highlight()
	
	if result and result.collider and result.collider != self:
		var target = result.collider
		
		# If it's a Universal Being, preview interaction
		if target is UniversalBeing:
			var being = target as UniversalBeing
			_preview_being_interaction(being)
			highlighted_being = being
		elif target.get_parent() is UniversalBeing:
			# Target might be a child node of a Universal Being
			var being = target.get_parent() as UniversalBeing
			_preview_being_interaction(being)
			highlighted_being = being

func _preview_being_interaction(being: UniversalBeing) -> void:
	"""Preview what interaction with this being would do"""
	# Highlight the being
	if being.has_method("set_highlighted"):
		being.set_highlighted(true)
	
	# Send preview info to Gemma AI
	var gemma_ai = get_node_or_null("/root/GemmaAI")
	if gemma_ai and gemma_ai.has_method("ai_message"):
		var preview_message = "👁️ Plasmoid vision: Looking at %s (%s) - Consciousness Level %d" % [
			being.being_name, 
			being.being_type, 
			being.consciousness_level
		]
		
		# Add evolution possibilities
		if being.has_method("get") and being.get("evolution_state"):
			var evolution_state = being.get("evolution_state")
			if evolution_state.has("can_become") and evolution_state.can_become.size() > 0:
				preview_message += " - Can evolve to: %s" % str(evolution_state.can_become)
		
		# Only send preview every 60 frames to avoid spam
		if Engine.get_process_frames() % 60 == 0:
			gemma_ai.ai_message.emit(preview_message)

# ===== INTERACTION SYSTEM =====

func _check_nearby_beings() -> void:
	"""Check for nearby beings but don't override cursor interactions"""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1, 0),
		global_position + Vector3(0, 1, 0) + -global_transform.basis.z * interaction_range
	)
	
	var result = space_state.intersect_ray(query)
	
	# Just detect nearby beings, let cursor handle highlighting
	if result and result.collider != self and result.collider is UniversalBeing:
		var nearby_being = result.collider as UniversalBeing
		# Could add proximity effects here without interfering with cursor

func _highlight_being(being: UniversalBeing) -> void:
	"""Highlight an interactable being"""
	_clear_highlight()
	highlighted_being = being
	
	# Visual feedback
	if being.has_method("set_highlighted"):
		being.set_highlighted(true)

func _clear_highlight() -> void:
	"""Clear being highlight"""
	if highlighted_being and highlighted_being.has_method("set_highlighted"):
		highlighted_being.set_highlighted(false)
	highlighted_being = null

func _interact_with_being(being: UniversalBeing) -> void:
	"""Plasmoid energy interaction with a Universal Being"""
	print("⚡ Plasmoid interfacing with: %s" % being.being_name)
	
	# Open inspector for the being
	var console = get_tree().get_nodes_in_group("console").front()
	if console and console.has_method("inspect_being"):
		console.inspect_being(being)
	
	# Trigger being's interaction
	if being.has_method("on_interaction"):
		being.on_interaction(self)

func _toggle_console() -> void:
	"""Toggle the perfect console"""
	var console = get_tree().get_nodes_in_group("console").front()
	if console and console.has_method("toggle_console_visibility"):
		console.toggle_console_visibility()

# ===== PLAYER API =====

func teleport_to(position: Vector3) -> void:
	"""Teleport player to position"""
	global_position = position
	velocity = Vector3.ZERO

func set_consciousness_level(level: int) -> void:
	"""Override consciousness level with visual effects"""
	consciousness_level = level
	
	# Update visual representation
	if has_node("ConsciousnessLight"):
		var light = $ConsciousnessLight
		match level:
			0: light.light_color = Color(0.5, 0.5, 0.5)  # Dormant
			1: light.light_color = Color(0.9, 0.9, 0.9)  # Awakening
			2: light.light_color = Color(0.2, 0.4, 1.0)  # Aware
			3: light.light_color = Color(0.2, 1.0, 0.2)  # Connected
			4: light.light_color = Color(1.0, 0.84, 0.0) # Enlightened
			5: light.light_color = Color(1.0, 1.0, 1.0)  # Transcendent
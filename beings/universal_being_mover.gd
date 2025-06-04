# ==================================================
# SCRIPT NAME: universal_being_mover.gd
# DESCRIPTION: Universal Being Mover - Locomotion slot/socket for human player
# PURPOSE: Move, rotate, look, reparent Universal Beings - connected to 3D chunk system
# CREATED: 2025-06-04 - Human Player Locomotion System
# AUTHOR: JSH + Claude Code + Movement Revolution
# ==================================================

extends UniversalBeing
class_name UniversalBeingMover

# ===== DEBUG META CONFIGURATION =====
const DEBUG_META := {
	"show_vars": ["movement_speed", "rotation_speed", "current_mode", "attached_being", "chunk_coordinates", "consciousness_level"],
	"edit_vars": ["movement_speed", "rotation_speed", "look_sensitivity", "auto_pathfinding"],
	"actions": {
		"Look Forward": "look_forward",
		"Move Forward": "move_forward_action",
		"Attach Being": "attach_random_being", 
		"Generate Path": "generate_ground_path",
		"Switch Mode": "cycle_movement_mode",
		"Inspect": "inspect_mover_state"
	}
}

# ===== MOVEMENT PROPERTIES =====
@export var movement_speed: float = 5.0
@export var rotation_speed: float = 2.0
@export var look_sensitivity: float = 1.0
@export var auto_pathfinding: bool = true
@export var ground_detection_range: float = 10.0

# Movement Modes
enum MovementMode { 
	GROUND_WALK,     # Walking on surfaces with Path3D
	FREE_FLY,        # Flying in space/air
	SPACESHIP,       # Vehicle-based movement
	ATTACHED,        # Attached to another being
	TELEPORT         # Instant movement between chunks
}

var current_mode: MovementMode = MovementMode.FREE_FLY
var movement_enabled: bool = true

# ===== BEING ATTACHMENT SYSTEM =====
var attached_being: UniversalBeing = null
var attachment_offset: Vector3 = Vector3.ZERO
var attachment_rotation: Vector3 = Vector3.ZERO

# Socket system for player slots
var camera_socket: Node3D = null
var body_socket: Node3D = null  
var pointer_socket: Node3D = null
var tool_socket: Node3D = null

# ===== CHUNK SYSTEM INTEGRATION =====
var chunk_manager: Node = null
var current_chunk_coords: Vector3i = Vector3i.ZERO
var generation_radius: int = 2  # Chunks to generate around player
var chunk_size: Vector3 = Vector3(10.0, 10.0, 10.0)

# ===== PATHFINDING SYSTEM =====
var ground_path: Path3D = null
var path_follow: PathFollow3D = null
var path_progress: float = 0.0
var ground_surfaces: Array[Node3D] = []

# Movement state
var velocity: Vector3 = Vector3.ZERO
var look_direction: Vector3 = Vector3.FORWARD
var target_position: Vector3 = Vector3.ZERO
var mover_target: Vector3 = Vector3.ZERO

# Signals for movement system
signal being_attached(being: UniversalBeing)
signal being_detached(being: UniversalBeing)
signal movement_mode_changed(new_mode: MovementMode)
signal chunk_entered(chunk_coords: Vector3i)
signal ground_path_generated(path: Path3D)
signal movement_started(target: Vector3)
signal movement_stopped()

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Universal Being Mover"
	being_type = "player_locomotion_system"
	consciousness_level = 3  # Connected consciousness that moves through reality
	
	# Initialize movement systems
	initialize_socket_system()
	initialize_pathfinding()
	connect_to_chunk_system()
	
	print("🚀 Universal Being Mover: Locomotion system initialized")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Setup default sockets
	create_player_sockets()
	
	# Enable input handling
	movement_enabled = true
	
	# Start in appropriate mode based on environment
	detect_environment_and_set_mode()
	
	print("🚀 Universal Being Mover: Ready for human player control")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update movement based on current mode
	update_movement_system(delta)
	
	# Update chunk generation around player
	update_chunk_generation()
	
	# Update pathfinding if active
	update_pathfinding_system(delta)
	
	# Update attached being if any
	update_attached_being(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if not movement_enabled:
		return
	
	# Handle movement input
	handle_movement_input(event)
	
	# Handle mode switching
	handle_mode_switching_input(event)
	
	# Handle being attachment
	handle_attachment_input(event)

func pentagon_sewers() -> void:
	# Cleanup before destruction
	if attached_being:
		detach_being()
	
	if ground_path:
		ground_path.queue_free()
	
	cleanup_sockets()
	
	super.pentagon_sewers()

# ===== SOCKET SYSTEM =====

func initialize_socket_system() -> void:
	"""Initialize the socket system for player components"""
	print("🔌 Initializing player socket system...")

func create_player_sockets() -> void:
	"""Create sockets for camera, body, pointer, tools"""
	
	# Camera socket (for player view)
	camera_socket = Node3D.new()
	camera_socket.name = "CameraSocket"
	camera_socket.position = Vector3(0, 1.8, 0)  # Eye level
	add_child(camera_socket)
	
	# Body socket (for player representation)
	body_socket = Node3D.new()
	body_socket.name = "BodySocket"
	body_socket.position = Vector3(0, 0, 0)  # Center
	add_child(body_socket)
	
	# Pointer socket (for cursor/interaction)
	pointer_socket = Node3D.new()
	pointer_socket.name = "PointerSocket"
	pointer_socket.position = Vector3(0, 1.6, -0.5)  # In front of eyes
	add_child(pointer_socket)
	
	# Tool socket (for held tools/objects)
	tool_socket = Node3D.new()
	tool_socket.name = "ToolSocket"
	tool_socket.position = Vector3(0.3, 1.4, -0.3)  # Hand position
	add_child(tool_socket)
	
	print("🔌 Player sockets created: Camera, Body, Pointer, Tool")

func attach_to_socket(socket_name: String, being: UniversalBeing) -> bool:
	"""Attach a Universal Being to a specific socket"""
	var socket = get_player_socket(socket_name)
	if not socket or not being:
		return false
	
	# Reparent being to socket
	if being.get_parent():
		being.get_parent().remove_child(being)
	
	socket.add_child(being)
	being.position = Vector3.ZERO
	being.rotation = Vector3.ZERO
	
	print("🔌 Attached %s to %s socket" % [being.being_name, socket_name])
	return true

func get_player_socket(socket_name: String) -> Node3D:
	"""Get player socket by name"""
	match socket_name.to_lower():
		"camera":
			return camera_socket
		"body":
			return body_socket
		"pointer":
			return pointer_socket
		"tool":
			return tool_socket
		_:
			return null

func cleanup_sockets() -> void:
	"""Cleanup all sockets"""
	if camera_socket:
		camera_socket.queue_free()
	if body_socket:
		body_socket.queue_free()
	if pointer_socket:
		pointer_socket.queue_free()
	if tool_socket:
		tool_socket.queue_free()

# ===== BEING ATTACHMENT SYSTEM =====

func attach_being(being: UniversalBeing, offset: Vector3 = Vector3.ZERO) -> bool:
	"""Attach and reparent a Universal Being to this mover"""
	if not being or attached_being == being:
		return false
	
	# Detach previous being if any
	if attached_being:
		detach_being()
	
	# Store original parent for potential restoration
	var original_parent = being.get_parent()
	
	# Reparent being to this mover
	if original_parent:
		original_parent.remove_child(being)
	
	add_child(being)
	
	# Set attachment properties
	attached_being = being
	attachment_offset = offset
	being.position = offset
	
	# Store original parent info in being
	being.set_meta("original_parent", original_parent)
	being.set_meta("attached_to_mover", true)
	
	being_attached.emit(being)
	print("🔗 Attached being: %s" % being.being_name)
	
	return true

func detach_being() -> UniversalBeing:
	"""Detach the currently attached being"""
	if not attached_being:
		return null
	
	var being = attached_being
	var original_parent = being.get_meta("original_parent", null)
	
	# Remove from this mover
	remove_child(being)
	
	# Restore to original parent or add to scene root
	if original_parent and is_instance_valid(original_parent):
		original_parent.add_child(being)
	else:
		get_tree().current_scene.add_child(being)
	
	# Clear attachment
	being.remove_meta("original_parent")
	being.remove_meta("attached_to_mover")
	attached_being = null
	
	being_detached.emit(being)
	print("🔗 Detached being: %s" % being.being_name)
	
	return being

func attach_random_being() -> void:
	"""Debug action: Attach a random nearby being"""
	var nearby_beings = find_nearby_beings(5.0)
	if nearby_beings.size() > 0:
		var random_being = nearby_beings[randi() % nearby_beings.size()]
		attach_being(random_being, Vector3(0, 2, 0))

func find_nearby_beings(radius: float) -> Array[UniversalBeing]:
	"""Find Universal Beings within radius"""
	var nearby: Array[UniversalBeing] = []
	
	# Get all beings from FloodGates if available
	if SystemBootstrap and SystemBootstrap.get_flood_gates():
		var all_beings = SystemBootstrap.get_flood_gates().get_all_beings()
		
		for being in all_beings:
			if being != self and being.has_method("get_global_position"):
				var distance = global_position.distance_to(being.global_position)
				if distance <= radius:
					nearby.append(being)
	
	return nearby

# ===== MOVEMENT SYSTEM =====

func update_movement_system(delta: float) -> void:
	"""Update movement based on current mode"""
	match current_mode:
		MovementMode.GROUND_WALK:
			update_ground_walking(delta)
		MovementMode.FREE_FLY:
			update_free_flying(delta)
		MovementMode.SPACESHIP:
			update_spaceship_movement(delta)
		MovementMode.ATTACHED:
			update_attached_movement(delta)
		MovementMode.TELEPORT:
			update_teleport_movement(delta)

func update_ground_walking(delta: float) -> void:
	"""Update ground walking with Path3D"""
	if ground_path and path_follow:
		# Move along path if we have one
		if mover_target != Vector3.ZERO:
			path_progress += movement_speed * delta
			path_follow.progress = path_progress
			global_position = path_follow.global_position

func update_free_flying(delta: float) -> void:
	"""Update free flight movement"""
	if mover_target != Vector3.ZERO:
		var direction = (mover_target - global_position).normalized()
		velocity = direction * movement_speed
		global_position += velocity * delta
		
		# Stop when close to target
		if global_position.distance_to(mover_target) < 0.1:
			mover_target = Vector3.ZERO
			velocity = Vector3.ZERO
			movement_stopped.emit()

func update_spaceship_movement(delta: float) -> void:
	"""Update spaceship-style movement"""
	# Similar to free flying but with momentum
	if mover_target != Vector3.ZERO:
		var direction = (mover_target - global_position).normalized()
		velocity = velocity.lerp(direction * movement_speed, delta * 2.0)
		global_position += velocity * delta

func update_attached_movement(delta: float) -> void:
	"""Update movement when attached to another being"""
	if attached_being:
		# Follow the attached being
		global_position = attached_being.global_position + attachment_offset

func update_teleport_movement(delta: float) -> void:
	"""Update teleport movement (instant)"""
	if mover_target != Vector3.ZERO:
		global_position = movement_target
		mover_target = Vector3.ZERO
		movement_stopped.emit()

# ===== CHUNK SYSTEM INTEGRATION =====

func connect_to_chunk_system() -> void:
	"""Connect to the 3D chunk generation system"""
	# Try to find chunk manager in scene
	chunk_manager = get_tree().get_first_node_in_group("chunk_managers")
	
	if not chunk_manager:
		# Look for unified chunk system
		chunk_manager = get_tree().get_first_node_in_group("unified_chunk_systems")
	
	if chunk_manager:
		print("🌌 Connected to chunk system: %s" % chunk_manager.name)
	else:
		print("🌌 No chunk system found - will create basic generation")

func update_chunk_generation() -> void:
	"""Update chunk generation around player position"""
	var new_chunk_coords = world_position_to_chunk_coordinates(global_position)
	
	if new_chunk_coords != current_chunk_coords:
		current_chunk_coords = new_chunk_coords
		chunk_entered.emit(current_chunk_coords)
		
		# Trigger chunk generation if manager available
		if chunk_manager and chunk_manager.has_method("ensure_chunks_around_position"):
			chunk_manager.ensure_chunks_around_position(global_position, generation_radius)
		
		print("🌌 Entered chunk: %s" % current_chunk_coords)

func world_position_to_chunk_coordinates(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinates"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size.x)),
		int(floor(world_pos.y / chunk_size.y)),
		int(floor(world_pos.z / chunk_size.z))
	)

# ===== PATHFINDING SYSTEM =====

func initialize_pathfinding() -> void:
	"""Initialize pathfinding system"""
	print("🛤️ Initializing pathfinding system...")

func generate_ground_path() -> void:
	"""Generate Path3D on detected ground surfaces"""
	detect_ground_surfaces()
	
	if ground_surfaces.size() > 0:
		create_path3d_on_ground()
	else:
		print("🛤️ No ground surfaces detected - staying in fly mode")

func detect_ground_surfaces() -> void:
	"""Detect ground surfaces within range"""
	ground_surfaces.clear()
	
	# Raycast downward to find ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * ground_detection_range
	)
	
	var result = space_state.intersect_ray(query)
	if result:
		var ground_node = result.get("collider")
		if ground_node:
			ground_surfaces.append(ground_node)
			print("🛤️ Ground surface detected: %s" % ground_node.name)

func create_path3d_on_ground() -> void:
	"""Create Path3D on the detected ground"""
	if ground_path:
		ground_path.queue_free()
	
	# Create new path
	ground_path = Path3D.new()
	ground_path.name = "GroundPath"
	add_child(ground_path)
	
	# Create path follow
	path_follow = PathFollow3D.new()
	path_follow.name = "PathFollow"
	ground_path.add_child(path_follow)
	
	# Generate simple path curve
	var curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.FORWARD * 10)
	ground_path.curve = curve
	
	path_progress = 0.0
	ground_path_generated.emit(ground_path)
	print("🛤️ Ground path generated")

func update_pathfinding_system(delta: float) -> void:
	"""Update pathfinding system"""
	if current_mode == MovementMode.GROUND_WALK and auto_pathfinding:
		# Auto-generate paths as needed
		if not ground_path and mover_target != Vector3.ZERO:
			generate_ground_path()

func update_attached_being(delta: float) -> void:
	"""Update attached being position and rotation"""
	if attached_being:
		# Keep attached being in sync
		attached_being.look_at(global_position + look_direction, Vector3.UP)

# ===== ENVIRONMENT DETECTION =====

func detect_environment_and_set_mode() -> void:
	"""Detect environment and set appropriate movement mode"""
	# Check if we're in space (no ground nearby)
	detect_ground_surfaces()
	
	if ground_surfaces.size() > 0:
		set_movement_mode(MovementMode.GROUND_WALK)
	else:
		set_movement_mode(MovementMode.FREE_FLY)

func set_movement_mode(new_mode: MovementMode) -> void:
	"""Set movement mode and update systems"""
	if current_mode == new_mode:
		return
	
	var old_mode = current_mode
	current_mode = new_mode
	
	# Update systems based on new mode
	match current_mode:
		MovementMode.GROUND_WALK:
			if auto_pathfinding:
				generate_ground_path()
		MovementMode.FREE_FLY:
			if ground_path:
				ground_path.queue_free()
				ground_path = null
	
	movement_mode_changed.emit(current_mode)
	print("🚀 Movement mode: %s → %s" % [MovementMode.keys()[old_mode], MovementMode.keys()[current_mode]])

func cycle_movement_mode() -> void:
	"""Cycle through movement modes"""
	var modes = MovementMode.values()
	var current_index = modes.find(current_mode)
	var next_index = (current_index + 1) % modes.size()
	set_movement_mode(modes[next_index])

# ===== INPUT HANDLING =====

func handle_movement_input(event: InputEvent) -> void:
	"""Handle movement input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W:
				move_forward()
			KEY_S:
				move_backward()
			KEY_A:
				move_left()
			KEY_D:
				move_right()
			KEY_Q:
				move_up()
			KEY_E:
				move_down()
			KEY_SPACE:
				# Jump or ascend
				if current_mode == MovementMode.GROUND_WALK:
					move_up()

func handle_mode_switching_input(event: InputEvent) -> void:
	"""Handle mode switching input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				# Toggle between fly and walk
				if current_mode == MovementMode.FREE_FLY:
					set_movement_mode(MovementMode.GROUND_WALK)
				else:
					set_movement_mode(MovementMode.FREE_FLY)
			KEY_TAB:
				cycle_movement_mode()

func handle_attachment_input(event: InputEvent) -> void:
	"""Handle being attachment input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:
				# Grab nearby being
				attach_random_being()
			KEY_R:
				# Release attached being
				detach_being()

# ===== MOVEMENT ACTIONS =====

func move_forward() -> void:
	"""Move forward in current direction"""
	var forward_target = global_position + look_direction * 5.0
	move_to_position(forward_target)

func move_backward() -> void:
	"""Move backward"""
	var backward_target = global_position - look_direction * 5.0
	move_to_position(backward_target)

func move_left() -> void:
	"""Move left"""
	var right_vector = look_direction.cross(Vector3.UP).normalized()
	var left_target = global_position - right_vector * 5.0
	move_to_position(left_target)

func move_right() -> void:
	"""Move right"""
	var right_vector = look_direction.cross(Vector3.UP).normalized()
	var right_target = global_position + right_vector * 5.0
	move_to_position(right_target)

func move_up() -> void:
	"""Move up"""
	var up_target = global_position + Vector3.UP * 3.0
	move_to_position(up_target)

func move_down() -> void:
	"""Move down"""
	var down_target = global_position + Vector3.DOWN * 3.0
	move_to_position(down_target)

func move_forward_action() -> void:
	"""Debug action: Move forward"""
	move_forward()

func move_to_position(target: Vector3) -> void:
	"""Move to specific position"""
	mover_target = target
	movement_started.emit(target)
	print("🚀 Moving to: %s" % target)

func look_at_direction(direction: Vector3) -> void:
	"""Look in specific direction"""
	look_direction = direction.normalized()
	
	# Update rotation to face direction
	if direction.length() > 0:
		look_at(global_position + direction, Vector3.UP)

func look_forward() -> void:
	"""Debug action: Look forward"""
	look_at_direction(Vector3.FORWARD)

# ===== DEBUG AND INSPECTION =====

func inspect_mover_state() -> void:
	"""Inspect current mover state"""
	print("\n🚀 === UNIVERSAL BEING MOVER STATE ===")
	print("🚀 Position: %s" % global_position)
	print("🚀 Chunk: %s" % current_chunk_coords)
	print("🚀 Mode: %s" % MovementMode.keys()[current_mode])
	print("🚀 Look Direction: %s" % look_direction)
	print("🚀 Movement Speed: %.1f" % movement_speed)
	print("🚀 Attached Being: %s" % (attached_being.being_name if attached_being else "None"))
	print("🚀 Ground Path: %s" % ("Yes" if ground_path else "No"))
	print("🚀 Sockets: Camera=%s, Body=%s, Pointer=%s, Tool=%s" % [
		"Yes" if camera_socket else "No",
		"Yes" if body_socket else "No", 
		"Yes" if pointer_socket else "No",
		"Yes" if tool_socket else "No"
	])
	print("🚀 =====================================")

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
	"""AI interface for Gemma and other AIs"""
	var base = super.ai_interface()
	
	base.commands.merge({
		"move_to": "Move to specific coordinates",
		"attach_being": "Attach a Universal Being to mover",
		"detach_being": "Release attached being",
		"set_mode": "Change movement mode",
		"look_at": "Look in specific direction",
		"generate_path": "Generate ground path for walking",
		"inspect": "Show current mover state"
	})
	
	base.state.merge({
		"position": global_position,
		"chunk_coordinates": current_chunk_coords,
		"movement_mode": MovementMode.keys()[current_mode],
		"attached_being": attached_being.being_name if attached_being else null,
		"movement_speed": movement_speed,
		"has_ground_path": ground_path != null
	})
	
	return base
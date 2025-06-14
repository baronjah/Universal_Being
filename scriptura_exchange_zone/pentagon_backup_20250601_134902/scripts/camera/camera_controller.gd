# ==================================================
# SCRIPT NAME: camera_controller.gd
# DESCRIPTION: Advanced camera management for Perfect Pentagon Architecture
# PURPOSE: Create trackball camera orbiting around a central target node
# CREATED: 2025-05-31 - Camera system integration
# ==================================================

extends UniversalBeingBase
class_name CameraMovementSystem

# Camera components
var camera_target: Node3D = null
var trackball_camera: Camera3D = null
var camera_mount: Node3D = null

# Camera settings
@export var default_distance: float = 15.0
@export var look_at_center: Vector3 = Vector3.ZERO
@export var camera_enabled: bool = true

# Movement settings
@export var movement_speed: float = 10.0
@export var movement_acceleration: float = 20.0
@export var movement_friction: float = 15.0
@export var fast_movement_multiplier: float = 3.0

# Movement state
var movement_velocity: Vector3 = Vector3.ZERO
var movement_input: Vector3 = Vector3.ZERO

# World offset system for infinite movement
var world_offset: Vector3 = Vector3.ZERO
var max_target_distance: float = 15.0  # Reset when target gets this far from origin

signal camera_ready(camera: Camera3D)
signal camera_moved(position: Vector3, rotation: Vector3)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "CameraMovementSystem"
	print("📷 [CameraMovementSystem] Starting initialization...")
	print("📷 [CameraMovementSystem] Node name: " + str(name))
	print("📷 [CameraMovementSystem] In tree: " + str(is_inside_tree()))
	
	# Disable any existing scene camera first
	print("📷 [CameraMovementSystem] Step 1: Disabling scene camera...")
	_disable_scene_camera()
	
	# Create the proper hierarchy
	print("📷 [CameraMovementSystem] Step 2: Creating camera target...")
	_create_camera_target()
	print("📷 [CameraMovementSystem] Target created: " + str(camera_target != null))
	
	print("📷 [CameraMovementSystem] Step 3: Creating trackball camera...")
	_create_trackball_camera()
	print("📷 [CameraMovementSystem] Camera created: " + str(trackball_camera != null))
	
	print("📷 [CameraMovementSystem] Step 4: Setting up camera properties...")
	_setup_camera_properties()
	
	print("📷 [CameraMovementSystem] Step 5: Registering commands...")
	_register_camera_commands()
	
	print("📷 [CameraMovementSystem] Step 6: Creating cursor...")
	_create_cursor_universal_being()
	
	print("✅ [CameraMovementSystem] Initialization complete!")
	print("🎮 [CameraMovementSystem] WASD movement: W=Forward, S=Back, A=Left, D=Right, Shift=Fast")
	print("🏗️ [CameraMovementSystem] Hierarchy: MovementSystem → Target → Camera")
	
	if trackball_camera:
		print("📷 [CameraMovementSystem] Camera current: " + str(trackball_camera.current))
		camera_ready.emit(trackball_camera)
	else:
		print("❌ [CameraMovementSystem] ERROR: No trackball camera created!")

func _disable_scene_camera() -> void:
	"""Check for existing scene camera"""
	# Look for scene camera in parent (MainGame)
	var parent_node = get_parent()
	if parent_node:
		var scene_camera = parent_node.get_node_or_null("Camera3D")
		if scene_camera and scene_camera is Camera3D:
			print("📷 [CameraMovementSystem] Found scene Camera3D at: " + str(scene_camera.global_position))
			print("📷 [CameraMovementSystem] Scene Camera3D current: " + str(scene_camera.current))
			# Don't disable it yet - let our camera take over when ready
			print("📷 [CameraMovementSystem] Scene camera will be disabled when trackball camera is ready")

func _disable_scene_camera_final() -> void:
	"""Disable scene camera after our camera is ready"""
	var parent_node = get_parent()
	if parent_node:
		var scene_camera = parent_node.get_node_or_null("Camera3D")
		if scene_camera and scene_camera is Camera3D and scene_camera.current:
			scene_camera.current = false
			print("📷 [CameraMovementSystem] Scene Camera3D disabled - trackball camera now active")
		else:
			print("📷 [CameraMovementSystem] No scene camera to disable or already disabled")

var _process_counter: int = 0

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_process_counter += 1
	
	# Log every 60 frames (once per second at 60fps) to track if _process is running
	if _process_counter % 60 == 0:
		print("🔄 [CameraMovementSystem] _process() running - frame: " + str(_process_counter))
	
	# AGGRESSIVE PROTECTION: Force enable ALL camera processes
	_ensure_camera_system_protection()
	
	if camera_enabled:
		_handle_movement_input()
		_update_movement(delta)

func _ensure_camera_system_protection() -> void:
	"""Aggressively protect camera system from any interference"""
	
	# Force enable camera system
	if not camera_enabled:
		camera_enabled = true
		print("🛡️ [CameraMovementSystem] Camera force re-enabled!")
	
	# Force enable ALL process types for this node
	if not is_processing():
		set_process(true)
		print("🛡️ [CameraMovementSystem] Process force enabled!")
	
	if not is_physics_processing():
		set_physics_process(true)
		print("🛡️ [CameraMovementSystem] Physics process force enabled!")
	
	if not is_processing_input():
		set_process_input(true)
		print("🛡️ [CameraMovementSystem] Input process force enabled!")
	
	if not is_processing_unhandled_input():
		set_process_unhandled_input(true)
		print("🛡️ [CameraMovementSystem] Unhandled input process force enabled!")
	
	# Ensure trackball camera stays current and active
	if trackball_camera:
		if is_instance_valid(trackball_camera):
			if not trackball_camera.current:
				trackball_camera.current = true
				print("🛡️ [CameraMovementSystem] Trackball camera reactivated!")
			
			# Protect trackball camera from freezing
			if not trackball_camera.is_processing():
				trackball_camera.set_process(true)
				print("🛡️ [CameraMovementSystem] Trackball camera process restored!")
			
			if not trackball_camera.is_processing_input():
				trackball_camera.set_process_input(true)
				print("🛡️ [CameraMovementSystem] Trackball camera input restored!")
		else:
			print("⚠️ [CameraMovementSystem] Trackball camera invalid - may need recreation!")
	
	# Ensure camera target is valid
	if not is_instance_valid(camera_target):
		print("🚨 [CameraMovementSystem] Camera target invalid - system compromised!")
		# Could attempt to recreate here if needed

func _create_camera_target() -> void:
	"""Create camera target as a simple Node3D with visual indicator"""
	print("📍 [CameraMovementSystem] Creating orbit center...")
	
	# Create simple target (most reliable approach)
	camera_target = Node3D.new()
	camera_target.name = "CameraTarget"
	camera_target.position = look_at_center
	add_child(camera_target)
	print("📍 [CameraMovementSystem] Camera target node created")
	
	# Add basic visual indicator to see the orbit center
	var target_visual = MeshInstance3D.new()
	target_visual.name = "TargetVisual"
	target_visual.mesh = SphereMesh.new()
	target_visual.mesh.radius = 0.15
	target_visual.mesh.height = 0.3
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color.YELLOW
	material.emission = Color.YELLOW
	material.emission_energy = 1.0
	material.no_depth_test = true  # Always visible
	target_visual.material_override = material
	
	FloodgateController.universal_add_child(target_visual, camera_target)
	print("📍 [CameraMovementSystem] Yellow orbit center sphere created")
	print("🎯 [CameraMovementSystem] Camera target ready: " + str(camera_target != null))

func _create_trackball_camera() -> void:
	"""Create the trackball camera as a child of the target - this orbits around the target"""
	print("📷 [CameraMovementSystem] Creating trackball camera...")
	
	trackball_camera = Camera3D.new()
	trackball_camera.name = "TrackballCamera"
	
	print("📷 [CameraMovementSystem] Loading trackball script...")
	var trackball_script = load("res://scripts/camera/trackball_camera.gd")
	if trackball_script:
		trackball_camera.set_script(trackball_script)
		print("✅ [CameraMovementSystem] Trackball script loaded successfully")
	else:
		print("❌ [CameraMovementSystem] Failed to load trackball script!")
		return
	
	# Position camera at default distance from the target
	trackball_camera.position = Vector3(0, 0, default_distance)
	print("📷 [CameraMovementSystem] Camera positioned at: " + str(trackball_camera.position))
	
	# CRITICAL: Add camera as child of target so it orbits around target
	if camera_target:
		FloodgateController.universal_add_child(trackball_camera, camera_target)
		print("📷 [CameraMovementSystem] Camera added as child of target")
	else:
		print("❌ [CameraMovementSystem] No camera target to attach to!")
		return
	
	# Make trackball camera the default active camera (will be set in _setup_camera_properties)
	print("📷 [CameraMovementSystem] Camera will be set as current after configuration")
	
	print("✅ [CameraMovementSystem] Trackball camera setup complete!")
	print("🎯 [CameraMovementSystem] Mouse: orbit rotation, WASD: move orbit center")

func _setup_camera_properties() -> void:
	"""Configure the trackball camera properties"""
	if not trackball_camera:
		print("❌ [CameraMovementSystem] No trackball camera to configure!")
		return
	
	print("⚙️ [CameraMovementSystem] Configuring trackball camera properties...")
	
	# Wait a frame for script to initialize before checking methods
	await get_tree().process_frame
	
	# Check if the trackball script is properly loaded
	if not trackball_camera.has_method("input"):
		print("❌ [CameraMovementSystem] Trackball script not properly loaded!")
		print("🔍 [CameraMovementSystem] Available methods: " + str(trackball_camera.get_method_list()))
		return
	
	print("✅ [CameraMovementSystem] Trackball script methods available")
	
	# Enable mouse controls
	trackball_camera.mouse_enabled = true
	trackball_camera.mouse_strength = 1.5
	print("🖱️ [CameraMovementSystem] Mouse controls enabled")
	
	# Enable zoom
	trackball_camera.zoom_enabled = true
	trackball_camera.zoom_minimum = 2.0
	trackball_camera.zoom_maximum = 50.0
	trackball_camera.zoom_strength = 2.0
	print("🔍 [CameraMovementSystem] Zoom controls enabled")
	
	# Enable inertia for smooth movement
	trackball_camera.inertia_enabled = true
	trackball_camera.inertia_strength = 1.2
	trackball_camera.friction = 0.08
	print("🌊 [CameraMovementSystem] Inertia enabled")
	
	# Enable orbit controls
	trackball_camera.orbit_strength = 1.0
	print("🔄 [CameraMovementSystem] Orbit controls enabled")
	
	# Disable action controls to avoid conflicts with our WASD system
	trackball_camera.action_enabled = false
	print("🎮 [CameraMovementSystem] Trackball action controls disabled (WASD handled by movement system)")
	
	# Configure input actions - use the ones you created
	# These properties now exist because the trackball script is loaded and initialized
	if trackball_camera.has_method("get_property_list"):
		trackball_camera.action_barrel_roll = ""  # Not needed
		trackball_camera.action_free_horizon = ""  # Not needed
		trackball_camera.action_zoom_in = "scroll_up"    # Use your input mapping
		trackball_camera.action_zoom_out = "scroll_down"  # Use your input mapping
		print("🔕 [CameraMovementSystem] Input actions configured: scroll_up/scroll_down for zoom")
	else:
		print("⚠️ [CameraMovementSystem] Action properties not available yet - warnings may appear")
	
	# Finally, make this the current camera after all configuration is done
	trackball_camera.current = true
	print("📷 [CameraMovementSystem] Camera set as current: " + str(trackball_camera.current))
	
	# Now that our camera is ready, disable any scene camera
	_disable_scene_camera_final()
	
	print("✅ [CameraMovementSystem] Camera properties configured successfully")

func _create_cursor_universal_being() -> void:
	"""Create a simple cursor indicator"""
	print("🖱️ [CameraMovementSystem] Creating cursor indicator...")
	
	# Create simple cursor sphere for visibility  
	var cursor = MeshInstance3D.new()
	cursor.name = "CameraCursor"
	cursor.mesh = SphereMesh.new()
	cursor.mesh.radius = 0.1
	cursor.mesh.height = 0.2
	
	var cursor_material = MaterialLibrary.get_material("default")
	cursor_material.albedo_color = Color.CYAN
	cursor_material.emission = Color.CYAN
	cursor_material.emission_energy = 0.8
	cursor_material.no_depth_test = true  # Always visible
	cursor.material_override = cursor_material
	
	# Position cursor near the camera target
	cursor.position = Vector3(2, 1, 0)
	add_child(cursor)
	
	print("🎯 [CameraMovementSystem] Cyan cursor sphere created for visibility")
	print("📍 [CameraMovementSystem] Cursor position: " + str(cursor.global_position))

func _register_camera_commands() -> void:
	"""Register camera control commands with the console"""
	print("🎮 [CameraMovementSystem] Looking for console manager...")
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		print("❌ [CameraMovementSystem] Console manager not found!")
		return
		
	print("✅ [CameraMovementSystem] Console manager found: " + str(console))
	
	if console.has_method("register_command"):
		print("🎮 [CameraMovementSystem] Console has register_command method")
		console.register_command("camera_reset", _cmd_camera_reset, "Reset camera to default position")
		console.register_command("camera_distance", _cmd_camera_distance, "Set camera distance: camera_distance <value>")
		console.register_command("camera_target", _cmd_camera_target, "Set camera target position: camera_target <x> <y> <z>")
		console.register_command("camera_info", _cmd_camera_info, "Show camera information")
		console.register_command("camera_follow", _cmd_camera_follow, "Make camera follow an object: camera_follow <object_name>")
		console.register_command("camera_movement", _cmd_camera_movement, "Set movement speed: camera_movement <speed>")
		console.register_command("camera_help", _cmd_camera_help, "Show camera controls help")
		console.register_command("camera_debug", _cmd_camera_debug, "Debug camera movement system")
		console.register_command("camera_test_input", _cmd_camera_test_input, "Test WASD input detection")
		console.register_command("camera_create_cursor", _cmd_camera_create_cursor, "Create cursor Universal Being")
		console.register_command("camera_reactivate", _cmd_camera_reactivate, "Reactivate camera movement system")
		console.register_command("camera_reset_offset", _cmd_camera_reset_offset, "Reset world offset to zero")
		console.register_command("camera_set_threshold", _cmd_camera_set_threshold, "Set world offset threshold: camera_set_threshold <distance>")
		console.register_command("camera_unfreeze", _cmd_camera_unfreeze, "Unfreeze camera system if it was disabled by performance optimization")
		console.register_command("camera_trigger_offset", _cmd_camera_trigger_offset, "Manually trigger world offset system to test infinite precision")
		print("✅ [CameraMovementSystem] All camera commands registered!")
	elif "commands" in console:
		print("🎮 [CameraMovementSystem] Using direct console.commands access")
		console.commands["camera_debug"] = _cmd_camera_debug
		console.commands["camera_test_input"] = _cmd_camera_test_input
		console.commands["camera_reset"] = _cmd_camera_reset
		console.commands["camera_info"] = _cmd_camera_info
		console.commands["camera_help"] = _cmd_camera_help
		console.commands["camera_create_cursor"] = _cmd_camera_create_cursor
		console.commands["camera_reactivate"] = _cmd_camera_reactivate
		console.commands["camera_reset_offset"] = _cmd_camera_reset_offset
		console.commands["camera_set_threshold"] = _cmd_camera_set_threshold
		console.commands["camera_unfreeze"] = _cmd_camera_unfreeze
		console.commands["camera_trigger_offset"] = _cmd_camera_trigger_offset
		print("✅ [CameraMovementSystem] Commands added directly to console.commands!")
	else:
		print("❌ [CameraMovementSystem] Console doesn't have register_command or commands property!")

# === MOVEMENT SYSTEM ===

func _handle_movement_input() -> void:
	"""Handle WASD movement input based on camera orientation"""
	# Safety checks with detailed logging
	if not is_instance_valid(trackball_camera):
		print("🔴 [CameraMovementSystem] Trackball camera invalid!")
		return
		
	if not is_instance_valid(camera_target):
		print("🔴 [CameraMovementSystem] Camera target invalid!")
		return
	
	if not trackball_camera.current:
		print("🔴 [CameraMovementSystem] Trackball camera not current! Current: " + str(trackball_camera.current))
		return
	
	if not camera_enabled:
		print("🔴 [CameraMovementSystem] Camera disabled! Enabled: " + str(camera_enabled))
		return
	
	# Reset movement input
	movement_input = Vector3.ZERO
	
	# Get camera's GLOBAL orientation for direction calculations
	if not trackball_camera.is_inside_tree():
		print("❌ [CameraMovementSystem] Camera not in tree for input handling!")
		return
	
	var camera_global_transform = trackball_camera.global_transform
	var camera_forward = -camera_global_transform.basis.z.normalized()
	var camera_right = camera_global_transform.basis.x.normalized()
	var camera_up = camera_global_transform.basis.y.normalized()
	
	# Use multiple input detection methods for reliability
	var has_input = false
	var debug_keys = []
	
	# Log input detection attempt every 30 frames when keys might be pressed
	if _process_counter % 30 == 0:
		var any_key_pressed = (Input.is_physical_key_pressed(KEY_W) or 
							   Input.is_physical_key_pressed(KEY_A) or 
							   Input.is_physical_key_pressed(KEY_S) or 
							   Input.is_physical_key_pressed(KEY_D))
		if any_key_pressed:
			print("🎮 [CameraMovementSystem] Input check - WASD detection active")
	
	# Forward/Back (W/S) - Try multiple detection methods
	if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_W):
		movement_input += camera_forward
		has_input = true
		debug_keys.append("W")
	if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_S):
		movement_input -= camera_forward
		has_input = true
		debug_keys.append("S")
	
	# Left/Right (A/D)
	if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_A):
		movement_input -= camera_right
		has_input = true
		debug_keys.append("A")
	if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_D):
		movement_input += camera_right
		has_input = true
		debug_keys.append("D")
	
	# Up/Down (Q/E)
	if Input.is_physical_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_Q):
		movement_input -= camera_up
		has_input = true
		debug_keys.append("Q")
	if Input.is_physical_key_pressed(KEY_E) or Input.is_key_pressed(KEY_E):
		movement_input += camera_up
		has_input = true
		debug_keys.append("E")
	
	# Debug: Print when we have input
	if has_input:
		print("🎮 [CameraMovementSystem] Keys: " + str(debug_keys) + " Input: " + str(movement_input))
	
	# Normalize to prevent faster diagonal movement
	if movement_input.length() > 1.0:
		movement_input = movement_input.normalized()
	
	# Apply speed multiplier for fast movement (Shift)
	var speed_multiplier = 1.0
	if Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_SHIFT):
		speed_multiplier = fast_movement_multiplier
		if has_input:
			print("⚡ [CameraMovementSystem] Fast movement active! Multiplier: " + str(speed_multiplier))

	movement_input *= speed_multiplier
	
	# Final debug
	if has_input:
		print("🎯 [CameraMovementSystem] Final movement input: " + str(movement_input))

func _update_movement(delta: float) -> void:
	"""Update camera target position based on movement input with world offset system"""
	if not is_instance_valid(camera_target):
		print("❌ [CameraMovementSystem] No valid camera target for movement!")
		return
	
	if not camera_target.is_inside_tree():
		print("❌ [CameraMovementSystem] Camera target not in tree!")
		return
	
	# Apply movement acceleration
	if movement_input.length() > 0.0:
		var target_velocity = movement_input * movement_speed
		movement_velocity = movement_velocity.move_toward(
			target_velocity,
			movement_acceleration * delta
		)
		print("🏃 [CameraMovementSystem] Target Velocity: " + str(target_velocity))
		print("🏃 [CameraMovementSystem] Current Velocity: " + str(movement_velocity))
		print("🏃 [CameraMovementSystem] Acceleration: " + str(movement_acceleration))
		print("🏃 [CameraMovementSystem] Delta: " + str(delta))
	else:
		# Apply friction when no input
		if movement_velocity.length() > 0.01:
			movement_velocity = movement_velocity.move_toward(
				Vector3.ZERO,
				movement_friction * delta
			)
	
	# Apply movement using world offset system for infinite precision
	if movement_velocity.length() > 0.01:
		var movement_delta = movement_velocity * delta
		
		print("🌍 [CameraMovementSystem] World movement...")
		print("  Movement delta: " + str(movement_delta))
		print("  Current world offset: " + str(world_offset))
		print("  Current target local position: " + str(camera_target.position))
		
		# Move target locally (small movements for precision)
		var old_local_position = camera_target.position
		var new_local_position = old_local_position + movement_delta
		camera_target.position = new_local_position
		
		# Check if target has drifted too far from local origin
		if camera_target.position.length() > max_target_distance:
			print("🔄 [CameraMovementSystem] Resetting target to origin, updating world offset")
			# Move the offset and reset target to origin to maintain precision
			world_offset += camera_target.position
			camera_target.position = Vector3.ZERO
			print("  New total world offset: " + str(world_offset))
			print("  Target reset to: " + str(camera_target.position))
		
		# Calculate effective global position (for other systems)
		var effective_global_position = world_offset + camera_target.position
		look_at_center = effective_global_position
		
		print("✅ [CameraMovementSystem] Infinite precision movement applied!")
		print("  Local target: " + str(camera_target.position))
		print("  Effective global: " + str(effective_global_position))
		
		# Emit movement signal for other systems to track
		if trackball_camera:
			camera_moved.emit(effective_global_position, trackball_camera.rotation)

# === CONSOLE COMMANDS ===

func _cmd_camera_reset(_args: Array) -> String:
	"""Reset camera to default position"""
	if not trackball_camera:
		return "❌ Camera not available"
		
	trackball_camera.position = Vector3(0, 0, default_distance)
	trackball_camera.rotation = Vector3.ZERO
	
	return "📷 Camera reset to default position"

func _cmd_camera_distance(args: Array) -> String:
	"""Set camera distance from target"""
	if args.size() == 0:
		return "❌ Usage: camera_distance <value>"
		
	if not trackball_camera:
		return "❌ Camera not available"
		
	var distance = float(args[0])
	if distance < 1.0 or distance > 100.0:
		return "❌ Distance must be between 1.0 and 100.0"
		
	# Move camera to new distance while preserving direction
	var direction = trackball_camera.position.normalized()
	trackball_camera.position = direction * distance
	
	return "📷 Camera distance set to " + str(distance)

func _cmd_camera_target(args: Array) -> String:
	"""Set camera target position"""
	if args.size() < 3:
		return "❌ Usage: camera_target <x> <y> <z>"
		
	if not camera_target:
		return "❌ Camera target not available"
		
	var new_position = Vector3(float(args[0]), float(args[1]), float(args[2]))
	camera_target.position = new_position
	look_at_center = new_position
	
	return "📍 Camera target moved to " + str(new_position)

func _cmd_camera_info(_args: Array) -> String:
	"""Show camera information"""
	if not trackball_camera or not camera_target:
		return "❌ Camera system not available"
	
	var result = "📷 CAMERA SYSTEM INFO\n"
	result += "═══════════════════════\n"
	result += "🎯 Target Local Position: " + str(camera_target.position) + "\n"
	result += "🌍 World Offset: " + str(world_offset) + "\n"
	result += "🌐 Effective Global Position: " + str(world_offset + camera_target.position) + "\n"
	result += "📷 Camera Position: " + str(trackball_camera.global_position) + "\n"
	result += "📐 Camera Rotation: " + str(trackball_camera.rotation_degrees) + "\n"
	result += "📏 Distance to Target: " + str(trackball_camera.get_distance_to_target()) + "\n"
	result += "🖱️ Mouse Enabled: " + str(trackball_camera.mouse_enabled) + "\n"
	result += "🔄 Inertia Enabled: " + str(trackball_camera.inertia_enabled) + "\n"
	result += "🔍 Zoom Range: " + str(trackball_camera.zoom_minimum) + " - " + str(trackball_camera.zoom_maximum) + "\n"
	result += "🎮 Movement Speed: " + str(movement_speed) + "\n"
	result += "⚡ Fast Multiplier: " + str(fast_movement_multiplier) + "x\n"
	result += "🏃 Current Velocity: " + str(movement_velocity.length()) + "\n"
	
	return result

func _cmd_camera_follow(args: Array) -> String:
	"""Make camera follow a specific object"""
	if args.size() == 0:
		return "❌ Usage: camera_follow <object_name>"
		
	var object_name = args[0]
	var target_node = get_tree().get_first_node_in_group(object_name)
	
	if not target_node:
		# Try to find by name in the scene
		target_node = get_tree().current_scene.find_child(object_name, true, false)
	
	if not target_node:
		return "❌ Object not found: " + object_name
		
	if not target_node is Node3D:
		return "❌ Object is not a 3D node: " + object_name
		
	# Move camera target to follow the object
	camera_target.position = target_node.global_position
	look_at_center = target_node.global_position
	
	return "📷 Camera now following: " + object_name + " at " + str(target_node.global_position)

func _cmd_camera_movement(args: Array) -> String:
	"""Set camera movement speed"""
	if args.size() == 0:
		return "❌ Usage: camera_movement <speed>"
		
	var speed = float(args[0])
	if speed < 0.1 or speed > 100.0:
		return "❌ Speed must be between 0.1 and 100.0"
		
	movement_speed = speed
	return "🎮 Camera movement speed set to " + str(speed)

func _cmd_camera_help(_args: Array) -> String:
	"""Show camera controls help"""
	var result = "🎮 CAMERA CONTROLS HELP\n"
	result += "═══════════════════════════\n"
	result += "🖱️ MOUSE CONTROLS:\n"
	result += "• Middle-click drag: Orbit around target\n"
	result += "• Scroll wheel: Zoom in/out\n\n"
	result += "⌨️ KEYBOARD MOVEMENT:\n"
	result += "• W: Move forward (camera direction)\n"
	result += "• S: Move backward\n"
	result += "• A: Move left\n"
	result += "• D: Move right\n"
	result += "• Q: Move down\n"
	result += "• E: Move up\n"
	result += "• Shift: Fast movement (3x speed)\n\n"
	result += "📷 CONSOLE COMMANDS:\n"
	result += "• camera_switch: Toggle trackball/stationary\n"
	result += "• camera_movement <speed>: Set movement speed\n"
	result += "• camera_distance <value>: Set orbit distance\n"
	result += "• camera_target <x> <y> <z>: Set orbit center\n"
	result += "• camera_info: Show detailed camera info\n"
	result += "• camera_reset: Reset to default position\n\n"
	result += "💡 TIP: Movement follows camera orientation!\n"
	result += "   Point camera where you want to go, then use WASD\n"
	
	return result

func _cmd_camera_debug(_args: Array) -> String:
	"""Debug camera movement system"""
	print("🔧 [CameraMovementSystem] Camera debug command called!")
	
	var result = "🔧 CAMERA DEBUG INFO\n"
	result += "═══════════════════════\n"
	result += "System Node Name: " + str(name) + "\n"
	result += "System Valid: " + str(is_instance_valid(self)) + "\n"
	result += "In Scene Tree: " + str(is_inside_tree()) + "\n\n"
	
	if trackball_camera:
		if is_instance_valid(trackball_camera):
			result += "📷 Camera Global Position: " + str(trackball_camera.global_position) + "\n"
			result += "📷 Camera Global Rotation: " + str(trackball_camera.global_rotation_degrees) + "\n"
			result += "📷 Camera Current: " + str(trackball_camera.current) + "\n"
			result += "📷 Camera In Tree: " + str(trackball_camera.is_inside_tree()) + "\n"
			
			if trackball_camera.is_inside_tree():
				var cam_transform = trackball_camera.global_transform
				var cam_forward = -cam_transform.basis.z.normalized()
				var cam_right = cam_transform.basis.x.normalized()
				var cam_up = cam_transform.basis.y.normalized()
				
				result += "➡️ Camera Forward: " + str(cam_forward) + "\n"
				result += "⬅️ Camera Right: " + str(cam_right) + "\n"
				result += "⬆️ Camera Up: " + str(cam_up) + "\n"
			else:
				result += "❌ Camera not in scene tree!\n"
		else:
			result += "❌ Camera instance invalid!\n"
	else:
		result += "❌ No trackball camera!\n"
	
	if camera_target:
		if is_instance_valid(camera_target):
			result += "🎯 Target Position: " + str(camera_target.global_position) + "\n"
			result += "🎯 Target Local Position: " + str(camera_target.position) + "\n"
			result += "🎯 Target In Tree: " + str(camera_target.is_inside_tree()) + "\n"
		else:
			result += "❌ Camera target instance invalid!\n"
	else:
		result += "❌ No camera target!\n"
	
	result += "🏃 Movement Velocity: " + str(movement_velocity) + "\n"
	result += "🎮 Movement Input: " + str(movement_input) + "\n"
	result += "⚡ Movement Speed: " + str(movement_speed) + "\n"
	result += "🎛️ Camera Enabled: " + str(camera_enabled) + "\n"
	result += "🌍 World Offset: " + str(world_offset) + "\n"
	result += "📏 Target Distance from Origin: " + str(camera_target.position.length()) + "\n"
	result += "🎯 World Offset Threshold: " + str(max_target_distance) + "\n"
	
	# Test input states
	result += "\n🎮 CURRENT INPUT STATES:\n"
	result += "W: " + str(Input.is_key_pressed(KEY_W)) + "\n"
	result += "A: " + str(Input.is_key_pressed(KEY_A)) + "\n"
	result += "S: " + str(Input.is_key_pressed(KEY_S)) + "\n"
	result += "D: " + str(Input.is_key_pressed(KEY_D)) + "\n"
	result += "Shift: " + str(Input.is_key_pressed(KEY_SHIFT)) + "\n"
	
	print("🔧 [CameraMovementSystem] Debug result length: " + str(result.length()))
	print("🔧 [CameraMovementSystem] Debug content:\n" + result)
	return result

func _cmd_camera_test_input(_args: Array) -> String:
	"""Test input detection in real-time"""
	print("🎮 [CameraMovementSystem] Input test command called!")
	
	var result = "🎮 INPUT TEST (Hold keys while reading)\n"
	result += "═══════════════════════════════════════\n"
	result += "W: " + str(Input.is_physical_key_pressed(KEY_W)) + " | "
	result += "A: " + str(Input.is_physical_key_pressed(KEY_A)) + " | "
	result += "S: " + str(Input.is_physical_key_pressed(KEY_S)) + " | "
	result += "D: " + str(Input.is_physical_key_pressed(KEY_D)) + "\n"
	result += "Q: " + str(Input.is_physical_key_pressed(KEY_Q)) + " | "
	result += "E: " + str(Input.is_physical_key_pressed(KEY_E)) + " | "
	result += "Shift: " + str(Input.is_physical_key_pressed(KEY_SHIFT)) + "\n\n"
	
	result += "System Status:\n"
	result += "Camera Enabled: " + str(camera_enabled) + "\n"
	if trackball_camera:
		result += "Camera Current: " + str(trackball_camera.current) + "\n"
		result += "Camera Valid: " + str(is_instance_valid(trackball_camera)) + "\n"
	else:
		result += "Camera: NULL\n"
	
	result += "Target Exists: " + str(camera_target != null) + "\n"
	if camera_target:
		result += "Target Valid: " + str(is_instance_valid(camera_target)) + "\n"
	
	result += "Movement Input: " + str(movement_input) + "\n"
	result += "Movement Velocity: " + str(movement_velocity) + "\n"
	result += "Process Running: " + str(camera_enabled) + "\n"
	
	result += "\n💡 TIP: Run this command again while holding WASD keys!"
	print("🎮 [CameraMovementSystem] Input test result length: " + str(result.length()))
	return result

func _cmd_camera_create_cursor(_args: Array) -> String:
	"""Create cursor Universal Being manually"""
	print("🖱️ [CameraMovementSystem] Manual cursor creation command called!")
	
	var universal_manager = get_node_or_null("/root/UniversalObjectManager")
	if not universal_manager:
		return "❌ Universal Object Manager not found"
	
	if not universal_manager.has_method("create_object"):
		return "❌ Universal Object Manager doesn't have create_object method"
	
	var cursor_properties = {
		"name": "DivineCursor_Manual",
		"size": 0.2,  # Even larger for visibility
		"color": Color.CYAN,
		"consciousness_level": 4,
		"special_role": "divine_cursor",
		"always_visible": true,
		"description": "Manually created divine cursor capsule"
	}
	
	# Create cursor near the camera for easy visibility
	var cursor_position = Vector3(0, 2, 3)  # In front of camera
	if trackball_camera and camera_target:
		# Position relative to camera target
		cursor_position = camera_target.global_position + Vector3(2, 1, 0)
	
	var cursor_being = universal_manager.create_object("magical_orb", cursor_position, cursor_properties)
	
	if cursor_being:
		return "✨ Divine cursor Universal Being created at " + str(cursor_position) + "!\n🎯 Look for cyan sphere - that's your cursor!"
	else:
		return "❌ Failed to create cursor Universal Being"

func _cmd_camera_reactivate(_args: Array) -> String:
	"""Reactivate camera movement system after performance issues"""
	print("🔄 [CameraMovementSystem] Manual camera reactivation requested!")
	
	var result = "🔄 CAMERA REACTIVATION REPORT\n"
	result += "═══════════════════════════════\n"
	
	# Force enable camera system
	camera_enabled = true
	result += "✅ Camera system enabled: " + str(camera_enabled) + "\n"
	
	# Reactivate trackball camera if it exists
	if trackball_camera:
		if is_instance_valid(trackball_camera):
			trackball_camera.current = true
			result += "✅ Trackball camera reactivated: " + str(trackball_camera.current) + "\n"
			result += "📷 Camera position: " + str(trackball_camera.global_position) + "\n"
		else:
			result += "❌ Trackball camera is invalid\n"
	else:
		result += "❌ No trackball camera found\n"
	
	# Check target
	if camera_target:
		if is_instance_valid(camera_target):
			result += "✅ Camera target valid: " + str(camera_target.global_position) + "\n"
		else:
			result += "❌ Camera target is invalid\n"
	else:
		result += "❌ No camera target found\n"
	
	# Disable any scene camera that might be interfering
	_disable_scene_camera_final()
	result += "🔄 Scene camera check completed\n"
	
	result += "\n💡 Try moving with WASD keys now!"
	result += "\n💡 Middle-click drag to orbit around yellow sphere"
	
	return result

func _cmd_camera_reset_offset(_args: Array) -> String:
	"""Reset world offset to zero - useful for debugging"""
	print("🔄 [CameraMovementSystem] Resetting world offset...")
	
	var old_offset = world_offset
	var old_target_pos = camera_target.position
	var old_effective_pos = world_offset + camera_target.position
	
	# Move everything back to origin
	world_offset = Vector3.ZERO
	camera_target.position = old_effective_pos
	
	var result = "🔄 WORLD OFFSET RESET\n"
	result += "═════════════════════\n"
	result += "Old world offset: " + str(old_offset) + "\n"
	result += "Old target position: " + str(old_target_pos) + "\n"
	result += "Old effective position: " + str(old_effective_pos) + "\n\n"
	result += "New world offset: " + str(world_offset) + "\n"
	result += "New target position: " + str(camera_target.position) + "\n"
	result += "New effective position: " + str(world_offset + camera_target.position) + "\n\n"
	result += "📍 Camera should be at the same position but with reset coordinates"
	
	return result

func _cmd_camera_set_threshold(args: Array) -> String:
	"""Set world offset threshold distance"""
	if args.size() == 0:
		return "❌ Usage: camera_set_threshold <distance>\nCurrent threshold: " + str(max_target_distance)
		
	var new_threshold = float(args[0])
	if new_threshold < 1.0 or new_threshold > 1000.0:
		return "❌ Threshold must be between 1.0 and 1000.0"
		
	var old_threshold = max_target_distance
	max_target_distance = new_threshold
	
	var result = "🔧 WORLD OFFSET THRESHOLD UPDATED\\n"
	result += "═════════════════════════════════\\n"
	result += "Old threshold: " + str(old_threshold) + "\\n"
	result += "New threshold: " + str(new_threshold) + "\\n\\n"
	
	if camera_target:
		var current_distance = camera_target.position.length()
		result += "Current target distance: " + str(current_distance) + "\\n"
		
		if current_distance > new_threshold:
			result += "⚠️ Current distance exceeds new threshold!\\n"
			result += "World offset reset will trigger on next movement\\n"
		else:
			result += "✅ Current distance within new threshold\\n"
	
	result += "\\n💡 Lower threshold = more frequent resets (better precision)\\n"
	result += "💡 Higher threshold = fewer resets (better performance)"
	
	return result

func _cmd_camera_unfreeze(_args: Array) -> String:
	"""Unfreeze camera system if it was disabled by performance optimization"""
	print("🔓 [CameraMovementSystem] Emergency camera unfreeze requested!")
	
	var result = "🔓 CAMERA SYSTEM UNFREEZE\\n"
	result += "═══════════════════════════\\n"
	
	# Force enable all camera processes
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	
	# Force enable camera properties
	camera_enabled = true
	result += "✅ Camera movement enabled: " + str(camera_enabled) + "\\n"
	
	# Ensure trackball camera is active
	if trackball_camera:
		if is_instance_valid(trackball_camera):
			trackball_camera.current = true
			trackball_camera.set_process(true)
			trackball_camera.set_process_input(true)
			result += "✅ Trackball camera unfrozen: " + str(trackball_camera.current) + "\\n"
		else:
			result += "❌ Trackball camera invalid\\n"
	else:
		result += "❌ No trackball camera found\\n"
	
	# Disable any scene camera that might be interfering
	_disable_scene_camera_final()
	result += "✅ Scene camera interference cleared\\n"
	
	# Reset movement velocity to ensure fresh start
	movement_velocity = Vector3.ZERO
	movement_input = Vector3.ZERO
	result += "✅ Movement state reset\\n"
	
	result += "\\n🔥 CAMERA SYSTEM FORCE REACTIVATED!\\n"
	result += "💡 Try WASD movement now - it should work!\\n"
	result += "💡 If still not working, check if camera was removed from scene tree"
	
	return result

func _cmd_camera_trigger_offset(_args: Array) -> String:
	"""Manually trigger world offset system to test infinite precision"""
	if not camera_target:
		return "❌ No camera target found"
	
	print("🚀 [CameraMovementSystem] Manually triggering world offset system...")
	
	var current_distance = camera_target.position.length()
	var result = "🚀 MANUAL WORLD OFFSET TRIGGER\\n"
	result += "════════════════════════════════\\n"
	result += "Current target position: " + str(camera_target.position) + "\\n"
	result += "Current distance: " + str(current_distance) + "\\n"
	result += "Current threshold: " + str(max_target_distance) + "\\n"
	result += "Current world offset: " + str(world_offset) + "\\n\\n"
	
	if current_distance < max_target_distance:
		result += "⚠️ Distance below threshold - forcing trigger anyway!\\n\\n"
	
	# Force trigger the world offset system
	var old_target_pos = camera_target.position
	var old_world_offset = world_offset
	
	# Apply the world offset logic
	world_offset += camera_target.position
	camera_target.position = Vector3.ZERO
	
	result += "🔄 WORLD OFFSET RESET APPLIED:\\n"
	result += "Old target position: " + str(old_target_pos) + "\\n"
	result += "Old world offset: " + str(old_world_offset) + "\\n"
	result += "New target position: " + str(camera_target.position) + "\\n"
	result += "New world offset: " + str(world_offset) + "\\n"
	result += "Effective global position: " + str(world_offset + camera_target.position) + "\\n\\n"
	
	result += "✅ INFINITE PRECISION ENGAGED!\\n"
	result += "🎮 Camera should be at the same location but with reset coordinates\\n"
	result += "🚀 Now you can move infinitely far in any direction!"
	
	return result

# === PUBLIC API ===


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func get_camera() -> Camera3D:
	"""Get the trackball camera"""
	return trackball_camera

func get_target() -> Node3D:
	"""Get the camera target"""
	return camera_target

func set_camera_distance(distance: float) -> void:
	"""Set distance from camera to target"""
	if trackball_camera:
		var direction = trackball_camera.position.normalized()
		trackball_camera.position = direction * distance

func set_camera_target_position(position: Vector3) -> void:
	"""Set the position the camera orbits around"""
	if camera_target:
		camera_target.position = position
		look_at_center = position

func enable_camera(enabled: bool) -> void:
	"""Enable or disable camera controls"""
	camera_enabled = enabled
	if trackball_camera:
		trackball_camera.mouse_enabled = enabled
		trackball_camera.action_enabled = enabled

func get_camera_info() -> Dictionary:
	"""Get detailed camera information"""
	if not trackball_camera or not camera_target:
		return {}
		
	return {
		"target_position": camera_target.position,
		"camera_position": trackball_camera.global_position,
		"camera_rotation": trackball_camera.rotation_degrees,
		"distance_to_target": trackball_camera.get_distance_to_target(),
		"mouse_enabled": trackball_camera.mouse_enabled,
		"inertia_enabled": trackball_camera.inertia_enabled,
		"zoom_range": [trackball_camera.zoom_minimum, trackball_camera.zoom_maximum]
	}
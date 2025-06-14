extends Node3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🎬 DUAL CAMERA SYSTEM - PLAYER & SCENE SEPARATION 🎬
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/dual_camera_system.gd
# 🎯 FILE GOAL: Separate player camera for interaction and scene camera for presentation
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (camera management)
#    - core/camera_controller.gd (player movement)
#    - scenes/main_game.tscn (camera node references)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Player Camera: First-person interaction and movement
#    - Scene Camera: Cinematic overview and presentation modes
#    - Smooth transitions between camera modes
#    - Independent control systems for each camera
#    - Perfect integration with existing crosshair and word systems
#
# 🎮 USER EXPERIENCE: Seamless switching between interaction and presentation modes
# ═══════════════════════════════════════════════════════════════════════════════════════════════

## Dual Camera System class for player/scene separation
class_name DualCameraSystem

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CAMERA REFERENCES AND STATE
# ─────────────────────────────────────────────────────────────────────────────────

@onready var player_camera: Camera3D
@onready var scene_camera: Camera3D
@onready var camera_transition_tween: Tween

var active_camera_mode: String = "player"  # "player" or "scene"
var is_transitioning: bool = false

# Camera positions and rotations for different modes
var player_positions: Dictionary = {
	"default": Vector3(0, 5, 25),
	"interaction": Vector3(0, 3, 15),
	"creation": Vector3(0, 8, 30)
}

var scene_positions: Dictionary = {
	"overview": Vector3(0, 50, 100),
	"cosmic": Vector3(0, 30, 80),
	"garden": Vector3(20, 30, 50),
	"presentation": Vector3(0, 25, 60)
}

signal camera_mode_changed(new_mode: String)
signal transition_completed(camera_mode: String)

# ─────────────────────────────────────────────────────────────────────────────────
# 🎬 INITIALIZATION AND SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Camera node references from main game controller
# PROCESS: Sets up dual camera system with proper positioning
# OUTPUT: Fully functional dual camera system
# CHANGES: Establishes player and scene camera separation
# CONNECTION: Integrates with existing camera controller and crosshair system
# ─────────────────────────────────────────────────────────────────────────────────
func initialize(existing_camera: Camera3D, parent_node: Node3D) -> void:
	# Set up player camera (use existing camera)
	player_camera = existing_camera
	player_camera.name = "PlayerCamera"
	
	# Create scene camera
	scene_camera = Camera3D.new()
	scene_camera.name = "SceneCamera"
	parent_node.add_child(scene_camera)
	
	# Configure cameras
	_setup_camera_properties()
	
	# Start with player camera active
	_set_active_camera("player")
	
	print("🎬 Dual Camera System initialized")
	print("📷 Player Camera: Active for interaction")
	print("🎭 Scene Camera: Ready for presentation modes")

func _setup_camera_properties() -> void:
	# Configure player camera for close interaction
	player_camera.fov = 75.0
	player_camera.near = 0.1
	player_camera.far = 1000.0
	
	# Configure scene camera for cinematic views
	scene_camera.fov = 60.0  # Slightly narrower for cinematic feel
	scene_camera.near = 0.1
	scene_camera.far = 2000.0  # Further range for cosmic views
	
	# Set initial positions
	player_camera.global_position = player_positions.default
	scene_camera.global_position = scene_positions.overview

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CAMERA MODE SWITCHING
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Camera mode string ("player" or "scene")
# PROCESS: Switches active camera with smooth transition
# OUTPUT: Camera mode change with visual transition
# CHANGES: Active camera reference and viewport rendering
# CONNECTION: Notifies other systems of camera mode change
# ─────────────────────────────────────────────────────────────────────────────────
func switch_to_camera_mode(mode: String, position_key: String = "") -> void:
	if is_transitioning:
		print("⚠️ Camera transition in progress - ignoring switch request")
		return
	
	if mode == active_camera_mode:
		print("ℹ️ Already in ", mode, " camera mode")
		return
	
	print("🎬 Switching to ", mode, " camera mode")
	is_transitioning = true
	
	var target_camera = player_camera if mode == "player" else scene_camera
	var target_position: Vector3
	var target_rotation: Vector3 = Vector3.ZERO
	
	# Determine target position
	if mode == "player":
		if position_key.is_empty():
			position_key = "default"
		target_position = player_positions.get(position_key, player_positions.default)
	else:  # scene mode
		if position_key.is_empty():
			position_key = "overview"
		target_position = scene_positions.get(position_key, scene_positions.overview)
		# Scene camera looks down slightly for better overview
		target_rotation = Vector3(-15, 0, 0)
	
	# Smooth transition
	_perform_camera_transition(target_camera, target_position, target_rotation, mode)

func _perform_camera_transition(target_camera: Camera3D, target_pos: Vector3, target_rot: Vector3, mode: String) -> void:
	# Create transition tween
	if camera_transition_tween:
		camera_transition_tween.kill()
	
	camera_transition_tween = create_tween()
	camera_transition_tween.set_parallel(true)
	
	# Get current active camera
	var current_camera = get_active_camera()
	
	# Transition position and rotation
	camera_transition_tween.tween_property(current_camera, "global_position", target_pos, 1.0)
	camera_transition_tween.tween_property(current_camera, "rotation_degrees", target_rot, 1.0)
	
	# If switching camera types, fade between them
	if (mode == "player" and active_camera_mode == "scene") or (mode == "scene" and active_camera_mode == "player"):
		# Cross-fade effect
		camera_transition_tween.tween_callback(_set_active_camera.bind(mode)).set_delay(0.5)
	
	# Complete transition
	camera_transition_tween.tween_callback(_on_transition_complete.bind(mode)).set_delay(1.0)

func _on_transition_complete(mode: String) -> void:
	is_transitioning = false
	active_camera_mode = mode
	camera_mode_changed.emit(mode)
	transition_completed.emit(mode)
	print("✅ Camera transition to ", mode, " mode complete")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CAMERA MANAGEMENT UTILITIES
# ─────────────────────────────────────────────────────────────────────────────────
func _set_active_camera(mode: String) -> void:
	if mode == "player":
		player_camera.current = true
		scene_camera.current = false
	else:
		player_camera.current = false
		scene_camera.current = true
	
	active_camera_mode = mode

func get_active_camera() -> Camera3D:
	return player_camera if active_camera_mode == "player" else scene_camera

func get_player_camera() -> Camera3D:
	return player_camera

func get_scene_camera() -> Camera3D:
	return scene_camera

func is_player_mode() -> bool:
	return active_camera_mode == "player"

func is_scene_mode() -> bool:
	return active_camera_mode == "scene"

# ─────────────────────────────────────────────────────────────────────────────────
# 🎬 PRESET CAMERA POSITIONS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Preset name for quick camera positioning
# PROCESS: Moves camera to predefined position for specific use cases
# OUTPUT: Camera positioned for optimal viewing of specific content
# CHANGES: Camera position and rotation
# CONNECTION: Optimized for different interaction and presentation scenarios
# ─────────────────────────────────────────────────────────────────────────────────
func set_interaction_mode() -> void:
	switch_to_camera_mode("player", "interaction")

func set_creation_mode() -> void:
	switch_to_camera_mode("player", "creation")

func set_overview_mode() -> void:
	switch_to_camera_mode("scene", "overview")

func set_cosmic_mode() -> void:
	switch_to_camera_mode("scene", "cosmic")

func set_garden_mode() -> void:
	switch_to_camera_mode("scene", "garden")

func set_presentation_mode() -> void:
	switch_to_camera_mode("scene", "presentation")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CUSTOM POSITION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
func add_custom_position(mode: String, position_name: String, position: Vector3) -> void:
	if mode == "player":
		player_positions[position_name] = position
	else:
		scene_positions[position_name] = position
	
	print("📍 Added custom ", mode, " position: ", position_name, " at ", position)

func get_current_position_info() -> Dictionary:
	var active_cam = get_active_camera()
	return {
		"mode": active_camera_mode,
		"position": active_cam.global_position,
		"rotation": active_cam.rotation_degrees,
		"is_transitioning": is_transitioning
	}

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 INPUT HANDLING FOR CAMERA SWITCHING
# ─────────────────────────────────────────────────────────────────────────────────
func handle_camera_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_P:  # P key for Player camera mode
				set_interaction_mode()
				return true
			KEY_O:  # O key for Overview (scene) mode
				set_overview_mode()
				return true
			KEY_K:  # K key for cosmic (scene) mode
				set_cosmic_mode()
				return true
			# J key removed - handled by main controller for garden perspective
	
	return false  # Input not handled

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 DEBUG AND INFORMATION DISPLAY
# ─────────────────────────────────────────────────────────────────────────────────
func get_debug_info() -> String:
	var info = "🎬 DUAL CAMERA SYSTEM STATUS 🎬\n"
	info += "Active Mode: " + active_camera_mode + "\n"
	info += "Player Camera: " + str(player_camera.global_position) + "\n"
	info += "Scene Camera: " + str(scene_camera.global_position) + "\n"
	info += "Transitioning: " + str(is_transitioning) + "\n"
	info += "Controls: P(Player), O(Overview), K(Cosmic), J(Garden)\n"
	return info
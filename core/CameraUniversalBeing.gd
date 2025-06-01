# ==================================================
# SCRIPT NAME: CameraUniversalBeing.gd
# DESCRIPTION: Universal Being specialization for camera control
# PURPOSE: Pentagon Architecture integration with trackball camera addon
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends UniversalBeing
class_name CameraUniversalBeing

# ===== CAMERA UNIVERSAL BEING =====

## Camera Control
var trackball_camera: Camera3D = null
var camera_script: Script = null
var camera_target: Node3D = null

## Pentagon Camera State
var pentagon_camera_active: bool = true
var camera_input_enabled: bool = true

# ===== PENTAGON ARCHITECTURE OVERRIDE =====

func pentagon_init() -> void:
	# Call parent init first
	super()
	
	# Set camera-specific properties
	being_type = "camera"
	consciousness_level = 2
	
	print("🎥 CameraUniversalBeing: Pentagon camera initialization")

func pentagon_ready() -> void:
	# Call parent ready
	super()
	
	# Find and setup trackball camera
	setup_trackball_camera()

func pentagon_process(delta: float) -> void:
	# Call parent process
	super(delta)
	
	# Camera-specific processing
	if trackball_camera and pentagon_camera_active:
		update_camera_state(delta)

func pentagon_input(event: InputEvent) -> void:
	# Call parent input
	super(event)
	
	# Forward camera input to trackball script
	if trackball_camera and camera_input_enabled and pentagon_camera_active:
		forward_input_to_camera(event)

func pentagon_sewers() -> void:
	# Camera cleanup
	if trackball_camera:
		print("🎥 CameraUniversalBeing: Cleaning up camera")
	
	# Call parent cleanup
	super()

# ===== CAMERA SETUP =====

func setup_trackball_camera() -> void:
	"""Find and configure the trackball camera in loaded scene"""
	if not controlled_scene:
		push_error("🎥 CameraUniversalBeing: No controlled scene found")
		return
	
	# Find the trackball camera node
	trackball_camera = find_trackball_camera_recursive(controlled_scene)
	
	if trackball_camera:
		print("🎥 CameraUniversalBeing: Trackball camera found - %s" % trackball_camera.name)
		
		# Get the trackball script
		camera_script = trackball_camera.get_script()
		if camera_script:
			print("🎥 CameraUniversalBeing: Trackball script detected")
		
		# Make this camera current
		trackball_camera.current = true
		
		# Find camera target (the object it looks at)
		find_camera_target()
		
		print("🎥 CameraUniversalBeing: Camera setup complete!")
		print("🎥 Controls: Mouse wheel (zoom), Q/E (roll), Middle mouse (orbit)")
	else:
		push_error("🎥 CameraUniversalBeing: No trackball camera found in scene")

func find_trackball_camera_recursive(node: Node) -> Camera3D:
	"""Recursively find trackball camera in scene"""
	if node is Camera3D and node.get_script():
		var script_path = node.get_script().resource_path
		if "trackball" in script_path.to_lower():
			return node
	
	for child in node.get_children():
		var result = find_trackball_camera_recursive(child)
		if result:
			return result
	
	return null

func find_camera_target() -> void:
	"""Find what the camera should look at"""
	if not controlled_scene:
		return
	
	# Look for a MeshInstance3D or similar target
	camera_target = find_node_recursive(controlled_scene, "MeshInstance3D")
	if camera_target:
		print("🎥 CameraUniversalBeing: Camera target found - %s" % camera_target.name)

func find_node_recursive(node: Node, type_name: String) -> Node:
	"""Recursively find node of specific type"""
	if node.get_class() == type_name:
		return node
	
	for child in node.get_children():
		var result = find_node_recursive(child, type_name)
		if result:
			return result
	
	return null

# ===== INPUT FORWARDING =====

func forward_input_to_camera(event: InputEvent) -> void:
	"""Forward input events to the trackball camera script"""
	if not trackball_camera or not camera_script:
		return
	
	# Check if the trackball camera script has input methods
	if trackball_camera.has_method("_input"):
		trackball_camera._input(event)
	elif trackball_camera.has_method("_unhandled_input"):
		trackball_camera._unhandled_input(event)

# ===== CAMERA CONTROL =====

func update_camera_state(delta: float) -> void:
	"""Update camera state each frame"""
	# Camera-specific updates can go here
	pass

func set_camera_enabled(enabled: bool) -> void:
	"""Enable/disable camera input"""
	camera_input_enabled = enabled
	pentagon_camera_active = enabled
	
	if trackball_camera:
		trackball_camera.current = enabled
	
	print("🎥 CameraUniversalBeing: Camera %s" % ("enabled" if enabled else "disabled"))

func get_camera_info() -> Dictionary:
	"""Get camera information for AI/debug"""
	var info = {
		"has_camera": trackball_camera != null,
		"camera_current": trackball_camera.current if trackball_camera else false,
		"input_enabled": camera_input_enabled,
		"pentagon_active": pentagon_camera_active
	}
	
	if trackball_camera:
		info["camera_position"] = trackball_camera.global_position
		info["camera_rotation"] = trackball_camera.global_rotation
	
	if camera_target:
		info["target_name"] = camera_target.name
		info["target_position"] = camera_target.global_position
	
	return info

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Enhanced AI interface for camera beings"""
	var base_interface = super()
	
	# Add camera-specific information
	base_interface["camera_info"] = get_camera_info()
	base_interface["capabilities"] = [
		"3D camera control",
		"Trackball orbit",
		"Zoom control", 
		"Barrel roll",
		"Target tracking"
	]
	
	return base_interface

# ===== DEBUG FUNCTIONS =====

func debug_camera_info() -> String:
	"""Get camera debug information"""
	var info = []
	info.append("=== Camera Universal Being Debug ===")
	info.append("Camera Found: %s" % str(trackball_camera != null))
	info.append("Pentagon Active: %s" % str(pentagon_camera_active))
	info.append("Input Enabled: %s" % str(camera_input_enabled))
	
	if trackball_camera:
		info.append("Camera Current: %s" % str(trackball_camera.current))
		info.append("Camera Position: %s" % str(trackball_camera.global_position))
	
	if camera_target:
		info.append("Target: %s at %s" % [camera_target.name, str(camera_target.global_position)])
	
	return "\n".join(info)
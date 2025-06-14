extends Node
class_name VRManager

# Singleton instance
static var _instance = null

# Signals
signal scale_transition_requested(from_scale, to_scale)
signal interaction_triggered(object, interaction_type)
signal controller_gesture_detected(controller, gesture_type, gesture_data)
signal teleport_requested(position)
signal vr_initialized
signal vr_status_changed(is_active)

# VR specific
var vr_interface: XRInterface
var xr_origin: XROrigin3D
var left_controller: XRController3D
var right_controller: XRController3D
var is_vr_active: bool = false
var is_vr_initialized: bool = false

# Scale system
var current_scale = "universe"
var scale_levels = ["universe", "galaxy", "star_system", "planet", "element"]
var scale_transition_active = false
var reference_point = Vector3.ZERO

# Interaction system
var selected_object = null
var grab_mode = false
var menu_active = false

# Gesture recognition
var gesture_recognizer = null

# Get singleton instance
static func get_instance():
	if not _instance:
		_instance = VRManager.new()
	return _instance

# Initialize VR system
func initialize():
	print("Initializing VR Manager...")
	
	# Initialize XR interface
	vr_interface = XRServer.find_interface("OpenXR")
	
	if vr_interface and vr_interface.is_initialized():
		print("VR headset found and initialized")
		is_vr_initialized = true
		_setup_vr_environment()
		is_vr_active = true
		emit_signal("vr_status_changed", true)
		emit_signal("vr_initialized")
	else:
		print("No VR headset found or initialization failed")
		is_vr_initialized = false
		# Set up non-VR fallback
		_setup_non_vr_fallback()
	
	# Initialize common systems
	_initialize_gesture_recognizer()
	
	return is_vr_initialized

# Setup VR environment with proper origin and controllers
func _setup_vr_environment():
	# Setup XR Origin if not already in scene
	if not get_viewport().get_camera_3d() is XRCamera3D:
		# Create XR origin
		xr_origin = XROrigin3D.new()
		xr_origin.name = "XROrigin"
		
		# Create XR camera
		var xr_camera = XRCamera3D.new()
		xr_camera.name = "XRCamera"
		xr_origin.add_child(xr_camera)
		
		# Create controllers
		left_controller = XRController3D.new()
		left_controller.name = "LeftController"
		left_controller.tracker = "left_hand" 
		
		right_controller = XRController3D.new()
		right_controller.name = "RightController"
		right_controller.tracker = "right_hand"
		
		# Add visual models to controllers
		_add_controller_visuals(left_controller)
		_add_controller_visuals(right_controller)
		
		# Add controllers to origin
		xr_origin.add_child(left_controller)
		xr_origin.add_child(right_controller)
		
		# Add origin to scene
		get_tree().get_root().add_child(xr_origin)
		
		# Connect controller signals
		_connect_controller_signals()
	else:
		# Find existing XR setup in scene
		var cameras = get_tree().get_nodes_in_group("xr_camera")
		if cameras.size() > 0:
			var cam = cameras[0]
			xr_origin = cam.get_parent()
			
		# Find controllers
		var controllers = get_tree().get_nodes_in_group("xr_controller")
		for controller in controllers:
			if controller.tracker == "left_hand":
				left_controller = controller
			elif controller.tracker == "right_hand":
				right_controller = controller
				
		if left_controller and right_controller:
			_connect_controller_signals()
	
	# Activate VR mode
	get_viewport().use_xr = true

# Add visual models to controllers
func _add_controller_visuals(controller: XRController3D):
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.05, 0.1, 0.2)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.8, 0.8, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	controller.add_child(mesh_instance)
	
	# Add controller ray
	var ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -10) # 10 meters forward
	ray.collision_mask = 1 # Set to your interaction layer
	controller.add_child(ray)

# Setup non-VR fallback mode
func _setup_non_vr_fallback():
	# We'll still create a minimal controller setup for testing
	print("Setting up non-VR fallback mode")
	
	# We don't need to create a new camera if one exists
	var camera = get_viewport().get_camera_3d()
	if not camera:
		camera = Camera3D.new()
		camera.name = "MainCamera"
		camera.current = true
		get_tree().get_root().add_child(camera)
	
	# We can simulate some controller functionality with keyboard/mouse

# Connect controller signals
func _connect_controller_signals():
	if left_controller:
		if not left_controller.is_connected("button_pressed", Callable(self, "_on_left_controller_button_pressed")):
			left_controller.connect("button_pressed", Callable(self, "_on_left_controller_button_pressed"))
		if not left_controller.is_connected("button_released", Callable(self, "_on_left_controller_button_released")):
			left_controller.connect("button_released", Callable(self, "_on_left_controller_button_released"))
	
	if right_controller:
		if not right_controller.is_connected("button_pressed", Callable(self, "_on_right_controller_button_pressed")):
			right_controller.connect("button_pressed", Callable(self, "_on_right_controller_button_pressed"))
		if not right_controller.is_connected("button_released", Callable(self, "_on_right_controller_button_released")):
			right_controller.connect("button_released", Callable(self, "_on_right_controller_button_released"))

# Initialize gesture recognizer
func _initialize_gesture_recognizer():
	# Here we would load or create a gesture recognition system
	# For now, we'll use a placeholder
	gesture_recognizer = Node.new()
	gesture_recognizer.name = "GestureRecognizer"
	add_child(gesture_recognizer)

# Process function - called every frame
func _process(delta):
	if is_vr_active:
		_process_controller_movement(delta)
		_process_gestures(delta)

# Process controller movements for gesture recognition
func _process_controller_movement(delta):
	if not left_controller or not right_controller:
		return
	
	# Track movement for gesture recognition
	if left_controller.get_is_active() and right_controller.get_is_active():
		var left_pos = left_controller.global_position
		var right_pos = right_controller.global_position
		var distance = left_pos.distance_to(right_pos)
		
		# Example: Detect pinch gesture for scaling
		if distance < 0.1:  # Close together
			if not scale_transition_active:
				# Pinch gesture might trigger scale down
				_detect_scale_gesture("pinch", distance)
		elif distance > 0.5:  # Far apart
			# Wide gesture might trigger scale up
			_detect_scale_gesture("spread", distance)

# Process gestures based on controller movement
func _process_gestures(delta):
	# This would be where we track movement patterns over time
	pass

# Detect scale change gestures
func _detect_scale_gesture(gesture_type, value):
	var current_index = scale_levels.find(current_scale)
	
	if gesture_type == "pinch" and current_index < scale_levels.size() - 1:
		# Pinch gesture = scale down (zoom in)
		request_scale_transition(scale_levels[current_index + 1])
	elif gesture_type == "spread" and current_index > 0:
		# Spread gesture = scale up (zoom out)
		request_scale_transition(scale_levels[current_index - 1])

# Handle left controller button events
func _on_left_controller_button_pressed(button_name):
	match button_name:
		"trigger":
			# Handle element interaction
			_handle_interaction()
		"grip":
			# Handle grabbing objects
			_toggle_grab_mode(true)
		"primary":
			# Handle scale transition up (zoom out)
			var current_index = scale_levels.find(current_scale)
			if current_index > 0:
				request_scale_transition(scale_levels[current_index - 1])
		"ax_button":
			# Special action button
			_handle_special_action("left")

# Handle left controller button release events
func _on_left_controller_button_released(button_name):
	match button_name:
		"grip":
			# Release grabbed objects
			_toggle_grab_mode(false)

# Handle right controller button events
func _on_right_controller_button_pressed(button_name):
	match button_name:
		"trigger":
			# Handle element creation/selection
			_handle_selection()
		"grip":
			# Handle menu activation
			_toggle_menu()
		"primary":
			# Handle scale transition down (zoom in)
			var current_index = scale_levels.find(current_scale)
			if current_index < scale_levels.size() - 1:
				request_scale_transition(scale_levels[current_index + 1])
		"by_button":
			# Special action button
			_handle_special_action("right")

# Handle right controller button release events
func _on_right_controller_button_released(button_name):
	match button_name:
		"grip":
			# Hide menu if released
			if menu_active:
				_toggle_menu()

# Handle object interaction (trigger)
func _handle_interaction():
	if not is_vr_active:
		return
	
	var ray = left_controller.get_node("RayCast3D") if left_controller else null
	if ray and ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			emit_signal("interaction_triggered", collider, "interact")

# Handle object selection (right trigger)
func _handle_selection():
	if not is_vr_active:
		return
	
	var ray = right_controller.get_node("RayCast3D") if right_controller else null
	if ray and ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			selected_object = collider
			emit_signal("interaction_triggered", collider, "select")

# Toggle grab mode
func _toggle_grab_mode(is_active):
	grab_mode = is_active
	if is_active and selected_object:
		# Start grabbing the selected object
		_start_grab(selected_object)
	else:
		# Release the grabbed object
		_end_grab()

# Start grabbing an object
func _start_grab(object):
	if not object or not object is Node3D:
		return
	
	# Logic to attach object to controller
	# This would typically set the object as a child of the controller
	# or use a joint to connect them
	print("Grabbing object: ", object.name)

# End grabbing an object
func _end_grab():
	if not selected_object:
		return
	
	# Logic to release the grabbed object
	print("Releasing object: ", selected_object.name)
	selected_object = null

# Toggle menu display
func _toggle_menu():
	menu_active = !menu_active
	# Logic to show/hide the VR menu
	print("Menu state: ", menu_active)

# Handle special actions
func _handle_special_action(controller_side):
	print("Special action from ", controller_side, " controller")
	# This could be for summoning tools, changing modes, etc.

# Request a scale transition
func request_scale_transition(new_scale):
	if new_scale == current_scale or scale_transition_active:
		return
		
	scale_transition_active = true
	print("Requesting scale transition from ", current_scale, " to ", new_scale)
	emit_signal("scale_transition_requested", current_scale, new_scale)
	current_scale = new_scale

# Called when a scale transition completes
func complete_scale_transition():
	scale_transition_active = false
	print("Scale transition completed to ", current_scale)

# Update the reference point (for world-centered approach)
func update_reference_point(new_point):
	reference_point = new_point
	
# Transform local coordinates to world coordinates
func get_world_point_from_local(local_point):
	# Transform local coordinates to world coordinates based on scale
	var scale_factor = get_scale_factor(current_scale)
	return (local_point - reference_point) * scale_factor
	
# Transform world coordinates to local coordinates
func get_local_point_from_world(world_point):
	# Transform world coordinates to local coordinates based on scale
	var scale_factor = get_scale_factor(current_scale)
	return (world_point / scale_factor) + reference_point

# Get scale factor for current scale level
func get_scale_factor(scale_name):
	match scale_name:
		"universe": return 1.0
		"galaxy": return 0.001
		"star_system": return 0.000001
		"planet": return 0.000000001
		"element": return 0.000000000001
	return 1.0

# Request teleportation to a position
func request_teleport(position):
	emit_signal("teleport_requested", position)
	
# Execute teleportation
func execute_teleport(position):
	if not is_vr_active or not xr_origin:
		return
		
	# Calculate offset
	var camera_pos = Vector3.ZERO
	var xr_camera = xr_origin.get_node("XRCamera")
	if xr_camera:
		camera_pos = xr_camera.transform.origin
	
	# Calculate new origin position to place camera at target
	xr_origin.global_position = position - camera_pos
	print("Teleported to ", position)

# Get VR status
func get_vr_status():
	return {
		"is_vr_active": is_vr_active,
		"is_vr_initialized": is_vr_initialized,
		"current_scale": current_scale,
		"controllers_active": left_controller != null and right_controller != null,
		"menu_active": menu_active,
		"grab_mode": grab_mode
	}
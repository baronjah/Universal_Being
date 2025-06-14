extends Node
class_name PS5ControllerInterface

# PS5 Controller Interface for Space Game
# Provides specialized handling for PS5/DualSense controllers
# Supports adaptive triggers, haptic feedback, and touchpad features
# Integrates with memory systems and visual interfaces

# Controller state
var is_connected = false
var controller_id = -1
var last_battery_level = 1.0

# Button states dictionary for tracking press/release events
var button_states = {}

# Touchpad tracking
var touchpad_position = Vector2.ZERO
var touchpad_last_position = Vector2.ZERO
var is_touching = false

# Color/light management for controller light bar
var current_color = Color(0.0, 0.5, 1.0)  # Default blue
var pulse_active = false
var pulse_speed = 1.0

# Haptic feedback settings
var haptic_intensity = 0.5  # 0-1 range
var trigger_resistance = 0.3  # 0-1 range

# Controller button mapping for space game functions
var function_mapping = {
	# Navigation controls
	"left_stick": "navigate_space",
	"right_stick": "camera_control",
	
	# Game actions
	"cross": "select_celestial",
	"circle": "cancel_or_back",
	"triangle": "open_menu",
	"square": "scan_object",
	
	# Resource management
	"l1": "prev_resource",
	"r1": "next_resource",
	"l2": "decrease_extraction",
	"r2": "increase_extraction",
	
	# Special functions
	"create": "create_memory",
	"options": "open_settings",
	"touchpad_press": "toggle_map",
	"touchpad_touch": "interact_map",
	"ps_button": "system_menu",
	
	# D-pad
	"dpad_up": "increase_speed",
	"dpad_down": "decrease_speed",
	"dpad_left": "prev_target",
	"dpad_right": "next_target"
}

# Memory system interface
var memory_system
var triple_connector

# Signals
signal controller_connected(controller_id)
signal controller_disconnected(controller_id)
signal button_pressed(button_name, pressure)
signal button_released(button_name)
signal touchpad_moved(position, delta)
signal battery_level_changed(level)

# ===== Initialization =====

func _ready():
	# Register for joystick connection events
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Initialize button states
	_initialize_button_states()
	
	# Check for already connected controllers
	_check_for_controllers()
	
	# Try to find memory systems
	_find_memory_systems()

func _initialize_button_states():
	# Reset all button states
	button_states = {
		"cross": false,
		"circle": false,
		"square": false,
		"triangle": false,
		"l1": false,
		"r1": false,
		"l2": false,
		"r2": false,
		"l3": false,
		"r3": false,
		"create": false,
		"options": false,
		"ps_button": false,
		"touchpad_press": false,
		"dpad_up": false,
		"dpad_down": false,
		"dpad_left": false,
		"dpad_right": false
	}

func _check_for_controllers():
	# Check all connected joypads
	var joy_count = Input.get_connected_joypads().size()
	
	for i in range(joy_count):
		var name = Input.get_joy_name(i).to_lower()
		if "ps5" in name or "dualsense" in name:
			_connect_ps5_controller(i)
			break

func _find_memory_systems():
	# Find the memory turn system
	memory_system = get_node_or_null("/root/MemoryTurnSystem")
	if !memory_system:
		var parent = get_parent()
		while parent and !memory_system:
			memory_system = parent.get_node_or_null("MemoryTurnSystem")
			parent = parent.get_parent()
	
	# Find the triple memory connector
	triple_connector = get_node_or_null("/root/TripleMemoryConnector")
	if !triple_connector:
		var parent = get_parent()
		while parent and !triple_connector:
			triple_connector = parent.get_node_or_null("TripleMemoryConnector")
			parent = parent.get_parent()
	
	if memory_system:
		print("Found memory system")
	if triple_connector:
		print("Found triple connector")

# ===== Controller Connection Management =====

func _on_joy_connection_changed(device_id: int, connected: bool):
	var name = "Unknown"
	if connected:
		name = Input.get_joy_name(device_id).to_lower()
		
	if connected and ("ps5" in name or "dualsense" in name):
		_connect_ps5_controller(device_id)
	elif !connected and device_id == controller_id:
		_disconnect_ps5_controller()

func _connect_ps5_controller(device_id: int):
	if is_connected:
		_disconnect_ps5_controller()
	
	controller_id = device_id
	is_connected = true
	
	print("PS5 controller connected: " + Input.get_joy_name(device_id))
	
	# Reset button states
	_initialize_button_states()
	
	# Set initial color
	set_controller_color(current_color)
	
	# Read initial battery level
	update_battery_level()
	
	# Send welcome vibration
	vibrate(0.3, 0.3, 0.5)
	
	emit_signal("controller_connected", controller_id)

func _disconnect_ps5_controller():
	if !is_connected:
		return
	
	print("PS5 controller disconnected")
	
	var old_id = controller_id
	is_connected = false
	controller_id = -1
	
	emit_signal("controller_disconnected", old_id)

# ===== Input Processing =====

func _process(delta):
	if !is_connected:
		return
	
	# Process button states
	_process_button_states()
	
	# Process touchpad
	_process_touchpad()
	
	# Update battery periodically
	if Engine.get_frames_drawn() % 300 == 0:  # Every ~5 seconds
		update_battery_level()
	
	# Process pulse effect if active
	if pulse_active:
		_process_pulse_effect(delta)

func _process_button_states():
	# Check all buttons for state changes
	for button in button_states.keys():
		var is_pressed = _is_button_pressed(button)
		
		if is_pressed != button_states[button]:
			button_states[button] = is_pressed
			
			if is_pressed:
				var pressure = 1.0
				if button == "l2" or button == "r2":
					pressure = _get_trigger_value(button)
				
				emit_signal("button_pressed", button, pressure)
				_handle_button_press(button, pressure)
			else:
				emit_signal("button_released", button)
				_handle_button_release(button)

func _process_touchpad():
	if !is_connected:
		return
	
	# Check if touchpad is being touched
	var new_touching = Input.is_joy_button_pressed(controller_id, JOY_BUTTON_TOUCHPAD)
	
	if new_touching:
		if !is_touching:
			# Touch started
			is_touching = true
		
		# Get touchpad position
		# Note: Not all engines support this directly - this is pseudocode
		# You would need to implement platform-specific code for this
		touchpad_last_position = touchpad_position
		touchpad_position = _get_touchpad_position()
		
		if touchpad_position != touchpad_last_position:
			var delta = touchpad_position - touchpad_last_position
			emit_signal("touchpad_moved", touchpad_position, delta)
			_handle_touchpad_movement(touchpad_position, delta)
	
	elif is_touching:
		# Touch ended
		is_touching = false

func _handle_button_press(button: String, pressure: float):
	# Call corresponding function based on mapping
	if function_mapping.has(button):
		var function = function_mapping[button]
		
		# These function calls would trigger appropriate game functions
		match function:
			"select_celestial":
				_handle_select_action()
			"cancel_or_back":
				_handle_cancel_action()
			"open_menu":
				_handle_menu_action()
			"scan_object":
				_handle_scan_action()
			"increase_extraction":
				_handle_extraction_change(pressure)
			"decrease_extraction":
				_handle_extraction_change(-pressure)
			"create_memory":
				_handle_create_memory()
			"toggle_map":
				_handle_toggle_map()
			"system_menu":
				_handle_system_menu()
	
	# Give haptic feedback for button press
	if button == "cross" or button == "triangle" or button == "square" or button == "circle":
		vibrate(0.2, 0.0, 0.1)  # Light vibration for face buttons
	elif button == "l1" or button == "r1":
		vibrate(0.1, 0.1, 0.1)  # Light vibration for bumpers
	elif button == "options" or button == "create" or button == "ps_button":
		vibrate(0.3, 0.0, 0.15)  # Medium vibration for system buttons

func _handle_button_release(button: String):
	# Handle release events if needed
	pass

func _handle_touchpad_movement(position: Vector2, delta: Vector2):
	# Use touchpad for map navigation or UI interaction
	if memory_system and memory_system.screen_mode == "CENTER":
		# Use touchpad for special memory navigation in center mode
		var memory_index = int((position.x / 1920) * memory_system.MAX_MEMORY_SLOTS)
		print("Touchpad selecting memory: " + str(memory_index))
	
	if triple_connector:
		# Use touchpad for adjusting triple connection strength
		var strength_change = int(delta.y * -10)  # Vertical movement
		if strength_change != 0:
			var new_strength = clamp(triple_connector.connection_strength + strength_change, 1, 9)
			triple_connector.connection_strength = new_strength
			print("Connection strength: " + str(new_strength))
			
			# Provide feedback
			vibrate(0.1 * new_strength / 9.0, 0.0, 0.1)

# ===== Handler Functions for Game Actions =====

func _handle_select_action():
	# Handle selection action (cross button)
	print("Select action triggered")
	
	# Example: If memory system exists, store a spatial memory
	if memory_system:
		var data = {
			"position": Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)),
			"description": "Position marked with controller"
		}
		
		var memory_id = memory_system.store_memory(memory_system.MemoryType.SPATIAL, data)
		if memory_id != -1:
			print("Stored spatial memory: " + str(memory_id))
			
			# Vibrate with success pattern
			vibrate(0.3, 0.2, 0.3)
			set_controller_color(Color(0, 1, 0))  # Green for success
			start_pulse_effect(1.0)

func _handle_cancel_action():
	# Handle cancel action (circle button)
	print("Cancel action triggered")
	
	# Example: Reset current selection
	set_controller_color(Color(1, 0.3, 0.3))  # Red for cancel

func _handle_menu_action():
	# Handle menu action (triangle button)
	print("Menu action triggered")
	
	# Example: If we have a triple connector, activate 333 mode
	if triple_connector:
		var success = triple_connector.activate_333_mode()
		
		if success:
			set_controller_color(Color(0.7, 0.9, 1.0))  # Ethereal blue
			start_pulse_effect(3.33)  # Special pulse rate for 333
		else:
			vibrate(0.1, 0.1, 0.2)  # Error pattern

func _handle_scan_action():
	# Handle scan action (square button)
	print("Scan action triggered")
	
	# Example: Use haptic feedback to indicate scanning
	var scan_duration = 2.0
	var scan_vibration = 0.2
	
	# Start a pulsing pattern for the scan duration
	for i in range(10):
		vibrate(scan_vibration, 0.0, 0.05)
		await get_tree().create_timer(scan_duration / 10).timeout
	
	# Vibrate when scan completes
	vibrate(0.5, 0.0, 0.2)

func _handle_extraction_change(amount: float):
	# Handle resource extraction rate change (triggers)
	print("Extraction rate change: " + str(amount))
	
	# Example: Set trigger resistance based on extraction difficulty
	if amount > 0:
		set_trigger_resistance("r2", amount)
	else:
		set_trigger_resistance("l2", -amount)

func _handle_create_memory():
	# Handle create memory action (create button)
	print("Create memory triggered")
	
	if memory_system and triple_connector:
		# Create a special 333 triple pattern
		var memories = []
		
		# Get 3 random memories to connect
		var memory_count = memory_system.count_active_memories()
		if memory_count >= 3:
			var indices = []
			while indices.size() < 3:
				var idx = randi() % memory_system.MAX_MEMORY_SLOTS
				if memory_system.memory_slots[idx] != null and not idx in indices:
					indices.append(idx)
					memories.append(memory_system.memory_slots[idx])
			
			if memories.size() == 3:
				var pattern = triple_connector.create_333_resonance(memories)
				if !pattern.is_empty():
					print("Created 333 pattern: " + str(pattern.id))
					
					# Special vibration pattern and color
					vibrate(0.3, 0.3, 0.3)
					await get_tree().create_timer(0.3).timeout
					vibrate(0.3, 0.3, 0.3)
					await get_tree().create_timer(0.3).timeout
					vibrate(0.3, 0.3, 0.3)
					
					set_controller_color(Color(0.7, 0.9, 1.0))  # Ethereal blue
					start_pulse_effect(3.33)  # Special pulse rate for 333
				else:
					print("Failed to create 333 pattern")

func _handle_toggle_map():
	# Handle map toggle action (touchpad press)
	print("Map toggle triggered")
	
	# Example: Change screen mode in memory system
	if memory_system:
		var modes = ["FULL", "HALF", "CENTER"]
		var current_index = modes.find(memory_system.screen_mode)
		var next_index = (current_index + 1) % modes.size()
		
		memory_system.screen_mode = modes[next_index]
		memory_system.emit_signal("screen_mode_changed", memory_system.screen_mode)
		
		print("Screen mode changed to: " + memory_system.screen_mode)
		
		# Update controller color based on mode
		match memory_system.screen_mode:
			"FULL":
				set_controller_color(Color(0.0, 0.5, 1.0))  # Blue
			"HALF":
				set_controller_color(Color(0.5, 0.0, 1.0))  # Purple
			"CENTER":
				set_controller_color(Color(1.0, 0.5, 0.0))  # Orange

func _handle_system_menu():
	# Handle system menu action (PS button)
	print("System menu triggered")
	
	# Example: Reset everything
	if memory_system:
		memory_system.start_next_turn()
		
	set_controller_color(Color(1.0, 1.0, 1.0))  # White for reset
	vibrate(0.5, 0.5, 0.5)  # Strong vibration for system action

# ===== Controller Feedback Functions =====

func vibrate(low_freq: float, high_freq: float, duration: float):
	if !is_connected:
		return
		
	# Scale by global intensity
	low_freq *= haptic_intensity
	high_freq *= haptic_intensity
	
	# Input.start_joy_vibration is the standard API, but PS5 has more capabilities
	# This is simplified, and in a real implementation, you'd use a platform-specific API
	Input.start_joy_vibration(controller_id, low_freq, high_freq, duration)

func set_trigger_resistance(trigger: String, resistance: float):
	if !is_connected:
		return
	
	trigger_resistance = clamp(resistance, 0.0, 1.0)
	
	# In a real implementation, you would use platform-specific code
	# to set adaptive trigger resistance on the PS5 controller
	print("Setting " + trigger + " resistance to " + str(resistance))

func set_controller_color(color: Color):
	if !is_connected:
		return
	
	current_color = color
	
	# In a real implementation, you would use platform-specific code
	# to set the light bar color on the PS5 controller
	print("Setting controller color to: " + str(color))

func start_pulse_effect(speed: float = 1.0):
	pulse_active = true
	pulse_speed = speed
	
	# Pulse effect is processed in _process

func stop_pulse_effect():
	pulse_active = false
	
	# Reset to normal color
	set_controller_color(current_color)

func _process_pulse_effect(delta: float):
	if !pulse_active:
		return
	
	# Create a pulsing effect by modulating the color brightness
	var time_factor = Time.get_ticks_msec() / 1000.0 * pulse_speed
	var pulse_value = (sin(time_factor * TAU) + 1.0) / 2.0
	
	var pulsed_color = current_color
	pulsed_color.v = pulse_value * 0.5 + 0.5  # Pulse between 50% and 100% brightness
	
	set_controller_color(pulsed_color)

func update_battery_level() -> float:
	if !is_connected:
		return 0.0
	
	# In a real implementation, you would use platform-specific code
	# to get the battery level from the PS5 controller
	# This is a placeholder that simulates a battery level
	var battery = 0.75  # Placeholder value
	
	if abs(battery - last_battery_level) > 0.05:
		last_battery_level = battery
		emit_signal("battery_level_changed", battery)
	
	return battery

# ===== Helper Functions =====

func _is_button_pressed(button: String) -> bool:
	if !is_connected:
		return false
	
	var button_index = -1
	
	match button:
		"cross": button_index = JOY_BUTTON_A
		"circle": button_index = JOY_BUTTON_B
		"square": button_index = JOY_BUTTON_X
		"triangle": button_index = JOY_BUTTON_Y
		"l1": button_index = JOY_BUTTON_LEFT_SHOULDER
		"r1": button_index = JOY_BUTTON_RIGHT_SHOULDER
		"l3": button_index = JOY_BUTTON_LEFT_STICK
		"r3": button_index = JOY_BUTTON_RIGHT_STICK
		"create": button_index = JOY_BUTTON_BACK
		"options": button_index = JOY_BUTTON_START
		"ps_button": button_index = JOY_BUTTON_GUIDE
		"touchpad_press": button_index = JOY_BUTTON_TOUCHPAD
		"dpad_up": button_index = JOY_BUTTON_DPAD_UP
		"dpad_down": button_index = JOY_BUTTON_DPAD_DOWN
		"dpad_left": button_index = JOY_BUTTON_DPAD_LEFT
		"dpad_right": button_index = JOY_BUTTON_DPAD_RIGHT
		"l2", "r2": return _get_trigger_value(button) > 0.5
	
	if button_index == -1:
		return false
	
	return Input.is_joy_button_pressed(controller_id, button_index)

func _get_trigger_value(trigger: String) -> float:
	if !is_connected:
		return 0.0
	
	var axis = -1
	
	match trigger:
		"l2": axis = JOY_AXIS_TRIGGER_LEFT
		"r2": axis = JOY_AXIS_TRIGGER_RIGHT
	
	if axis == -1:
		return 0.0
	
	return Input.get_joy_axis(controller_id, axis)

func _get_touchpad_position() -> Vector2:
	# This is a placeholder since direct touchpad position access 
	# is not available in all engines without platform-specific code
	
	# In a real implementation, you would use platform-specific code
	# to get the touchpad position on the PS5 controller
	
	# Simulate touchpad position using analog sticks
	var x = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
	
	# Scale to simulated touchpad resolution (0-1920, 0-1080)
	return Vector2((x + 1.0) / 2.0 * 1920, (y + 1.0) / 2.0 * 1080)

# ===== Public Interface =====

func is_ps5_controller_connected() -> bool:
	return is_connected

func get_battery_percentage() -> float:
	return last_battery_level * 100.0

func has_button_mapping(button: String) -> bool:
	return function_mapping.has(button)

func get_button_function(button: String) -> String:
	if function_mapping.has(button):
		return function_mapping[button]
	return ""

func set_button_function(button: String, function: String) -> bool:
	if button_states.has(button):
		function_mapping[button] = function
		return true
	return false

func set_haptic_intensity(intensity: float) -> void:
	haptic_intensity = clamp(intensity, 0.0, 1.0)

func get_ps5_controller_id() -> int:
	return controller_id
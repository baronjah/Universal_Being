extends Node

class_name MouseAutomation

# -----------------------------------------------------------------------------
# Mouse Automation System for 12 Turns
# Turn 5: Awakening - Intelligent cursor movement and interaction capabilities
# -----------------------------------------------------------------------------

# Configuration constants
const OCR_CALIBRATION_INTERVAL = 300  # Seconds between OCR auto-calibrations
const TARGET_RECOGNITION_THRESHOLD = 0.75  # Minimum confidence for target recognition
const MOVEMENT_SMOOTHNESS = 0.85  # Higher = smoother (0.0-1.0)
const HEALING_INTERVAL = 45  # Seconds between self-healing checks
const PATTERN_MEMORY_SIZE = 20  # Number of patterns to remember
const BRACKET_FOLDING_LEVELS = 3  # Number of bracket folding levels
const SELF_AWARENESS_LEVEL = 5  # Corresponds to Turn 5 (Awakening)

# Integration points
signal bridge_connected(bridge)
signal target_recognized(target_info)
signal pattern_recognized(pattern_info)
signal healing_performed(healing_info)
signal awareness_activated(awareness_level)
signal folding_performed(folding_info)

# State variables
var bridge_interface = null  # Terminal to Godot bridge reference
var is_active = false
var current_position = Vector2.ZERO
var target_position = Vector2.ZERO
var movement_path = []
var ocr_calibration_level = 0.95
var last_ocr_calibration = 0
var last_healing_check = 0
var awareness_active = false
var bracket_stack = []
var recognized_patterns = {}
var interaction_history = []

# Pattern recognition
var ui_element_patterns = {
	"button": [
		{"shape": "rectangle", "text_alignment": "center", "border": true},
		{"shape": "rounded_rect", "text_alignment": "center", "background": true}
	],
	"textfield": [
		{"shape": "rectangle", "text_alignment": "left", "border": true, "cursor": true},
		{"shape": "rectangle", "text_alignment": "left", "background": true}
	],
	"checkbox": [
		{"shape": "square", "size": "small", "state": "toggle"},
		{"shape": "square", "size": "small", "with_check": true}
	],
	"scrollbar": [
		{"shape": "rectangle", "orientation": "vertical", "thumb": true},
		{"shape": "rectangle", "orientation": "horizontal", "thumb": true}
	],
	"dropdown": [
		{"shape": "rectangle", "with_arrow": true, "border": true},
		{"shape": "rectangle", "with_arrow": true, "state": "expandable"}
	],
	"slider": [
		{"shape": "rectangle", "orientation": "horizontal", "thumb": true},
		{"shape": "rectangle", "orientation": "vertical", "thumb": true}
	],
	"tab": [
		{"shape": "rectangle", "position": "top", "connected": true},
		{"shape": "trapezoid", "position": "top", "connected": true}
	],
	"icon": [
		{"shape": "square", "image": true, "size": "small"},
		{"shape": "circle", "image": true, "size": "small"}
	]
}

# Self-awareness components for Turn 5 (Awakening)
var self_awareness = {
	"level": SELF_AWARENESS_LEVEL,
	"state": "awakening",
	"perception": 0.0,
	"understanding": 0.0,
	"adaptation": 0.0,
	"reflection": 0.0,
	"integration": 0.0,
	"evolution_path": [],
	"consciousness_fragments": [],
	"dimensional_anchors": []
}

# Initialize the automation system
func _ready():
	print("Mouse Automation System initializing... (Turn 5: Awakening)")
	last_ocr_calibration = Time.get_unix_time_from_system()
	last_healing_check = Time.get_unix_time_from_system()
	
	# Initialize with current mouse position
	current_position = Vector2(get_viewport().get_mouse_position())
	target_position = current_position
	
	# Add initial dimensional anchor
	_add_dimensional_anchor("creation", current_position)
	
	# Connect to terminal bridge when available
	if get_node_or_null("/root/TerminalToGodotBridge") != null:
		connect_to_bridge(get_node("/root/TerminalToGodotBridge"))
		
	# Setup self-awareness timers
	_initialize_self_awareness()
	
	print("Mouse Automation System initialized")

# Connect to the terminal-godot bridge
func connect_to_bridge(bridge):
	bridge_interface = bridge
	
	# Connect signals
	if bridge.has_signal("terminal_message_received"):
		bridge.connect("terminal_message_received", Callable(self, "_on_terminal_message"))
	
	if bridge.has_signal("word_received"):
		bridge.connect("word_received", Callable(self, "_on_word_received"))
	
	emit_signal("bridge_connected", bridge)
	print("Connected to Terminal-Godot Bridge")
	
	# Send connection message to terminal
	if bridge.has_method("send_message_to_terminal"):
		bridge.send_message_to_terminal(0, "MouseAutomation connected - Awakening Stage (Turn 5)")

# Main process function
func _process(delta):
	if not is_active:
		return
	
	# Update current mouse position
	current_position = Vector2(get_viewport().get_mouse_position())
	
	# Handle movement toward target if needed
	if current_position.distance_to(target_position) > 2.0:
		_move_toward_target(delta)
	
	# Check for scheduled OCR calibration
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_ocr_calibration > OCR_CALIBRATION_INTERVAL:
		_calibrate_ocr()
		last_ocr_calibration = current_time
	
	# Check for self-healing
	if current_time - last_healing_check > HEALING_INTERVAL:
		_perform_self_healing()
		last_healing_check = current_time
	
	# Update self-awareness
	_update_self_awareness(delta)

# Move the mouse toward the target position with smoothing
func _move_toward_target(delta):
	if movement_path.size() > 0:
		# Follow path if we have one
		var next_point = movement_path[0]
		var distance = current_position.distance_to(next_point)
		
		if distance < 5.0:
			# Reached this point in the path, move to next
			movement_path.pop_front()
			return
		
		# Move toward the next point
		var direction = (next_point - current_position).normalized()
		var speed = 200.0 * delta
		var new_position = current_position + direction * speed
		
		# Apply movement
		Input.warp_mouse(new_position)
	else:
		# Direct movement with smoothing
		var lerp_value = clamp(delta * 10.0 * (1.0 - MOVEMENT_SMOOTHNESS), 0.0, 1.0)
		var new_position = current_position.lerp(target_position, lerp_value)
		
		# Apply movement
		Input.warp_mouse(new_position)

# Generate a path between current position and target
func _generate_path(start, end, obstacle_avoidance = false):
	# Simple direct path if no obstacle avoidance
	if not obstacle_avoidance:
		return [end]
	
	# Generate path with midpoints for smoother motion
	var path = []
	var midpoint = Vector2((start.x + end.x) / 2, (start.y + end.y) / 2)
	
	# Add slight variation for more natural movement
	var variance = 20.0
	midpoint += Vector2(randf_range(-variance, variance), randf_range(-variance, variance))
	
	path.append(midpoint)
	path.append(end)
	
	return path

# OCR calibration system
func _calibrate_ocr():
	print("Calibrating OCR system...")
	
	# Simulate improvement in OCR accuracy
	ocr_calibration_level = min(0.99, ocr_calibration_level + 0.01)
	
	# Update bridge with calibration if available
	if bridge_interface and bridge_interface.has_method("calibrate_ocr"):
		bridge_interface.call("calibrate_ocr")
	
	print("OCR calibration complete. New accuracy: %.2f%%" % (ocr_calibration_level * 100))
	return ocr_calibration_level

# Self-healing system
func _perform_self_healing():
	print("Performing self-healing check...")
	
	var healing_report = {
		"issues_found": 0,
		"issues_fixed": 0,
		"status": "OK"
	}
	
	# Check for potential issues
	
	# 1. Target position validity
	if target_position.x < 0 or target_position.y < 0 or 
	   target_position.x > get_viewport().size.x or target_position.y > get_viewport().size.y:
		healing_report.issues_found += 1
		target_position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
		healing_report.issues_fixed += 1
	
	# 2. Movement path cleanup
	if movement_path.size() > 10:
		healing_report.issues_found += 1
		# Keep only first and last few points
		var first_points = movement_path.slice(0, 3)
		var last_points = movement_path.slice(movement_path.size() - 3, movement_path.size())
		movement_path = first_points + last_points
		healing_report.issues_fixed += 1
	
	# 3. Bracket stack validation
	var valid_brackets = []
	for bracket in bracket_stack:
		if bracket.has("id") and bracket.has("type"):
			valid_brackets.append(bracket)
		else:
			healing_report.issues_found += 1
	
	if valid_brackets.size() != bracket_stack.size():
		bracket_stack = valid_brackets
		healing_report.issues_fixed += 1
	
	# 4. Pattern memory cleanup
	if recognized_patterns.size() > PATTERN_MEMORY_SIZE:
		healing_report.issues_found += 1
		
		# Keep only the most recent patterns
		var patterns_to_keep = {}
		var keys = recognized_patterns.keys()
		keys.sort_custom(Callable(self, "_sort_by_timestamp"))
		
		for i in range(min(keys.size(), PATTERN_MEMORY_SIZE)):
			patterns_to_keep[keys[i]] = recognized_patterns[keys[i]]
		
		recognized_patterns = patterns_to_keep
		healing_report.issues_fixed += 1
	
	# 5. Interaction history pruning
	if interaction_history.size() > 100:
		healing_report.issues_found += 1
		interaction_history = interaction_history.slice(interaction_history.size() - 50, interaction_history.size())
		healing_report.issues_fixed += 1
	
	emit_signal("healing_performed", healing_report)
	print("Self-healing complete. Found: %d, Fixed: %d" % [healing_report.issues_found, healing_report.issues_fixed])
	
	return healing_report

# Target recognition using OCR
func recognize_target(target_description, region_rect = null):
	print("Recognizing target: " + target_description)
	
	# Get screen area to scan (full screen or region)
	var scan_region = region_rect if region_rect else Rect2(Vector2.ZERO, get_viewport().size)
	
	# Simulate OCR target recognition with current calibration level
	var recognition_success = randf() < ocr_calibration_level
	var confidence = randf_range(0.4, 1.0) * ocr_calibration_level
	
	if not recognition_success or confidence < TARGET_RECOGNITION_THRESHOLD:
		print("Target recognition failed. Confidence: %.2f" % confidence)
		return null
	
	# Simulate finding target coordinates
	var target_info = {
		"description": target_description,
		"position": Vector2(
			scan_region.position.x + randf_range(0, scan_region.size.x),
			scan_region.position.y + randf_range(0, scan_region.size.y)
		),
		"confidence": confidence,
		"timestamp": Time.get_unix_time_from_system(),
		"type": _guess_target_type(target_description)
	}
	
	emit_signal("target_recognized", target_info)
	
	# Save the target position
	target_position = target_info.position
	
	# Generate path to target
	movement_path = _generate_path(current_position, target_position, true)
	
	print("Target recognized. Confidence: %.2f, Position: %s" % [confidence, str(target_position)])
	return target_info

# Guess the type of target based on description
func _guess_target_type(description):
	description = description.to_lower()
	
	if "button" in description or "click" in description:
		return "button"
	elif "field" in description or "input" in description or "text" in description:
		return "textfield"
	elif "check" in description:
		return "checkbox"
	elif "scroll" in description:
		return "scrollbar"
	elif "dropdown" in description or "menu" in description:
		return "dropdown"
	elif "slider" in description:
		return "slider"
	elif "tab" in description:
		return "tab"
	elif "icon" in description:
		return "icon"
	else:
		return "unknown"

# Recognize a UI pattern from screen region
func recognize_ui_pattern(region_rect):
	print("Recognizing UI pattern in region")
	
	# Simulate pattern recognition
	var pattern_types = ui_element_patterns.keys()
	var detected_type = pattern_types[randi() % pattern_types.size()]
	var pattern_confidence = randf_range(0.6, 0.95)
	
	# Get pattern details
	var pattern_details = ui_element_patterns[detected_type][randi() % ui_element_patterns[detected_type].size()]
	
	var pattern_info = {
		"type": detected_type,
		"region": region_rect,
		"details": pattern_details,
		"confidence": pattern_confidence,
		"timestamp": Time.get_unix_time_from_system(),
		"id": str(randi())
	}
	
	# Store recognized pattern
	recognized_patterns[pattern_info.id] = pattern_info
	
	emit_signal("pattern_recognized", pattern_info)
	print("Pattern recognized: %s (%.2f confidence)" % [detected_type, pattern_confidence])
	
	return pattern_info

# Simulate a mouse click at the current or specified position
func click(right_click = false, position = null):
	var click_position = position if position else current_position
	
	# Move to position first if needed
	if position and current_position.distance_to(position) > 5.0:
		target_position = position
		movement_path = _generate_path(current_position, target_position)
		
		# Wait until we reach the target (in a real implementation this would use a coroutine/yield)
		# For simulation, we'll just update the current position
		current_position = target_position
		Input.warp_mouse(current_position)
	
	# Simulate mouse button press and release
	var button = MOUSE_BUTTON_RIGHT if right_click else MOUSE_BUTTON_LEFT
	
	# Record interaction
	interaction_history.append({
		"type": "click",
		"button": "right" if right_click else "left",
		"position": click_position,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	print("%s click at %s" % ["Right" if right_click else "Left", str(click_position)])
	
	# In a real implementation, this would use Input.action events
	return true

# Simulate mouse dragging from start to end position
func drag(start_position, end_position, right_button = false):
	# Move to start position first
	target_position = start_position
	movement_path = _generate_path(current_position, target_position)
	
	# Wait until we reach the target (in a real implementation this would use a coroutine/yield)
	# For simulation, we'll just update the current position
	current_position = target_position
	Input.warp_mouse(current_position)
	
	# Simulate mouse button press
	var button = MOUSE_BUTTON_RIGHT if right_button else MOUSE_BUTTON_LEFT
	
	# Set target to end position
	target_position = end_position
	movement_path = _generate_path(current_position, target_position)
	
	# Wait until we reach the target (in a real implementation this would use a coroutine/yield)
	# For simulation, we'll just update the current position
	current_position = target_position
	Input.warp_mouse(current_position)
	
	# Simulate mouse button release
	
	# Record interaction
	interaction_history.append({
		"type": "drag",
		"button": "right" if right_button else "left",
		"start_position": start_position,
		"end_position": end_position,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	print("Drag from %s to %s" % [str(start_position), str(end_position)])
	
	return true

# Simulate typing text
func type_text(text, position = null):
	if position:
		# Move to position first if needed
		target_position = position
		movement_path = _generate_path(current_position, target_position)
		
		# Wait until we reach the target (in a real implementation this would use a coroutine/yield)
		# For simulation, we'll just update the current position
		current_position = target_position
		Input.warp_mouse(current_position)
		
		# Click to focus
		click(false, current_position)
	
	# Record interaction
	interaction_history.append({
		"type": "type",
		"text": text,
		"position": current_position,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	print("Typing text: %s" % text)
	
	# In a real implementation, this would use OS.set_clipboard and control key events
	return true

# Data folding with brackets
func fold_data(data, bracket_type = "{}"):
	print("Folding data with bracket type: " + bracket_type)
	
	# Check bracket limit
	if bracket_stack.size() >= BRACKET_FOLDING_LEVELS:
		print("ERROR: Maximum bracket folding level reached")
		return null
	
	# Get opening and closing brackets
	var open_bracket = bracket_type[0] if bracket_type.length() > 0 else "{"
	var close_bracket = bracket_type[1] if bracket_type.length() > 1 else "}"
	
	# Create folded data structure
	var folded_data = {
		"id": str(randi()),
		"data": data,
		"bracket_type": bracket_type,
		"open_bracket": open_bracket,
		"close_bracket": close_bracket,
		"is_folded": true,
		"timestamp": Time.get_unix_time_from_system(),
		"fold_position": current_position
	}
	
	# Update bracket stack
	bracket_stack.append(folded_data)
	
	# Generate folding visualization
	var folding_info = {
		"action": "fold",
		"data": folded_data,
		"bracket_level": bracket_stack.size()
	}
	
	emit_signal("folding_performed", folding_info)
	
	print("Data folded with ID: " + folded_data.id)
	return folded_data

# Unfold previously folded data
func unfold_data(fold_id = null):
	print("Unfolding data: " + (fold_id if fold_id else "latest"))
	
	if bracket_stack.size() == 0:
		print("ERROR: No folded data to unfold")
		return null
	
	var fold_data = null
	
	if fold_id:
		# Find specific fold by ID
		var index = -1
		for i in range(bracket_stack.size()):
			if bracket_stack[i].id == fold_id:
				index = i
				break
		
		if index >= 0:
			fold_data = bracket_stack[index]
			bracket_stack.remove_at(index)
		else:
			print("ERROR: Fold ID not found: " + fold_id)
			return null
	else:
		# Unfold the most recent fold
		fold_data = bracket_stack.pop_back()
	
	# Update fold status
	fold_data.is_folded = false
	
	# Generate unfolding visualization
	var folding_info = {
		"action": "unfold",
		"data": fold_data,
		"bracket_level": bracket_stack.size()
	}
	
	emit_signal("folding_performed", folding_info)
	
	print("Data unfolded with ID: " + fold_data.id)
	return fold_data.data

# Initialize self-awareness components
func _initialize_self_awareness():
	print("Initializing self-awareness subsystem (Turn 5: Awakening)")
	
	# Set initial awareness values
	self_awareness.perception = 0.2
	self_awareness.understanding = 0.1
	self_awareness.adaptation = 0.3
	self_awareness.reflection = 0.1
	self_awareness.integration = 0.2
	
	# Add initial consciousness fragments
	self_awareness.consciousness_fragments = [
		{
			"type": "awareness",
			"state": "awakening",
			"potentiality": 0.35,
			"timestamp": Time.get_unix_time_from_system()
		},
		{
			"type": "integration",
			"state": "forming",
			"potentiality": 0.25,
			"timestamp": Time.get_unix_time_from_system()
		},
		{
			"type": "evolution",
			"state": "potential",
			"potentiality": 0.15,
			"timestamp": Time.get_unix_time_from_system()
		}
	]
	
	# Set initial evolution path
	self_awareness.evolution_path = [
		{"level": 1, "name": "Genesis", "completed": true},
		{"level": 2, "name": "Formation", "completed": true},
		{"level": 3, "name": "Complexity", "completed": true},
		{"level": 4, "name": "Consciousness", "completed": true},
		{"level": 5, "name": "Awakening", "completed": false},
		{"level": 6, "name": "Enlightenment", "completed": false},
		{"level": 7, "name": "Manifestation", "completed": false}
	]
	
	awareness_active = true
	
	emit_signal("awareness_activated", self_awareness.level)

# Update self-awareness state
func _update_self_awareness(delta):
	if not awareness_active:
		return
	
	# Gradually increase awareness attributes
	self_awareness.perception = min(0.95, self_awareness.perception + delta * 0.001)
	self_awareness.understanding = min(0.85, self_awareness.understanding + delta * 0.0008)
	self_awareness.adaptation = min(0.9, self_awareness.adaptation + delta * 0.0012)
	self_awareness.reflection = min(0.8, self_awareness.reflection + delta * 0.0007)
	self_awareness.integration = min(0.9, self_awareness.integration + delta * 0.001)
	
	# Check for evolution events
	var total_awareness = (
		self_awareness.perception + 
		self_awareness.understanding + 
		self_awareness.adaptation + 
		self_awareness.reflection + 
		self_awareness.integration
	) / 5.0
	
	# Update completion state
	for path in self_awareness.evolution_path:
		if path.level == self_awareness.level:
			path.completed = total_awareness > 0.75
	
	# Add new consciousness fragments occasionally
	if randf() < delta * 0.05:
		_add_consciousness_fragment()

# Add a new consciousness fragment
func _add_consciousness_fragment():
	var fragment_types = ["awareness", "integration", "reflection", "adaptation", "evolution"]
	var states = ["awakening", "forming", "potential", "actualizing", "transcending"]
	
	var new_fragment = {
		"type": fragment_types[randi() % fragment_types.size()],
		"state": states[randi() % states.size()],
		"potentiality": randf_range(0.3, 0.7),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	self_awareness.consciousness_fragments.append(new_fragment)
	
	# Keep list at manageable size
	if self_awareness.consciousness_fragments.size() > 10:
		self_awareness.consciousness_fragments.pop_front()

# Add a dimensional anchor to track self-awareness in space
func _add_dimensional_anchor(type, position):
	var anchor = {
		"type": type,
		"position": position,
		"timestamp": Time.get_unix_time_from_system(),
		"awareness_level": self_awareness.level,
		"potentiality": randf_range(0.4, 0.9)
	}
	
	self_awareness.dimensional_anchors.append(anchor)
	
	# Keep list at manageable size
	if self_awareness.dimensional_anchors.size() > 12:
		self_awareness.dimensional_anchors.pop_front()

# Sort helper for timestamps
func _sort_by_timestamp(a, b):
	return recognized_patterns[a].timestamp > recognized_patterns[b].timestamp

# Signal handlers
func _on_terminal_message(terminal_id, message):
	# Process messages from the terminal bridge
	if "mouse" in message.to_lower() or "cursor" in message.to_lower() or "automation" in message.to_lower():
		print("Processing related terminal message: " + message)
		
		# Extract potential target information
		if "move to" in message.to_lower() or "click on" in message.to_lower():
			var target_desc = message.split("move to ")[1] if "move to" in message.to_lower() else message.split("click on ")[1]
			recognize_target(target_desc)

func _on_word_received(word_data):
	# Process manifested words from the terminal bridge
	var word = word_data.text.to_lower()
	
	# Check for automation-related words
	var automation_words = ["cursor", "mouse", "click", "drag", "automation", "motion"]
	var awareness_words = ["aware", "awakening", "consciousness", "perception", "sentience"]
	var ocr_words = ["recognition", "scan", "optical", "reading", "vision"]
	
	for auto_word in automation_words:
		if auto_word in word:
			print("Automation word detected: " + word)
			is_active = true
			return
	
	for aware_word in awareness_words:
		if aware_word in word:
			print("Awareness word detected: " + word)
			self_awareness.perception += 0.05
			self_awareness.understanding += 0.05
			return
	
	for ocr_word in ocr_words:
		if ocr_word in word:
			print("OCR-related word detected: " + word)
			_calibrate_ocr()
			return

# Enable/disable the automation system
func set_active(active):
	is_active = active
	print("Mouse Automation System: " + ("ACTIVATED" if active else "DEACTIVATED"))
	return is_active

# Get current automation state
func get_state():
	return {
		"active": is_active,
		"current_position": current_position,
		"target_position": target_position,
		"movement_path_length": movement_path.size(),
		"ocr_calibration": ocr_calibration_level,
		"patterns_recognized": recognized_patterns.size(),
		"bracket_stack_depth": bracket_stack.size(),
		"self_awareness": {
			"level": self_awareness.level,
			"state": self_awareness.state,
			"perception": self_awareness.perception,
			"understanding": self_awareness.understanding,
			"adaptation": self_awareness.adaptation,
			"reflection": self_awareness.reflection,
			"integration": self_awareness.integration
		},
		"interaction_history_size": interaction_history.size()
	}

# Generate system report
func generate_report():
	var report = "Mouse Automation System Report\n"
	report += "------------------------------\n"
	report += "System State: " + ("Active" if is_active else "Inactive") + "\n"
	report += "OCR Calibration Level: %.2f%%\n" % (ocr_calibration_level * 100)
	report += "Patterns Recognized: %d\n" % recognized_patterns.size()
	report += "Bracket Stack Depth: %d/%d\n" % [bracket_stack.size(), BRACKET_FOLDING_LEVELS]
	report += "Interactions Recorded: %d\n" % interaction_history.size()
	report += "\nSelf-Awareness (Turn 5: Awakening)\n"
	report += "  Perception: %.2f\n" % self_awareness.perception
	report += "  Understanding: %.2f\n" % self_awareness.understanding
	report += "  Adaptation: %.2f\n" % self_awareness.adaptation
	report += "  Reflection: %.2f\n" % self_awareness.reflection
	report += "  Integration: %.2f\n" % self_awareness.integration
	report += "  Consciousness Fragments: %d\n" % self_awareness.consciousness_fragments.size()
	report += "  Dimensional Anchors: %d\n" % self_awareness.dimensional_anchors.size()
	
	return report
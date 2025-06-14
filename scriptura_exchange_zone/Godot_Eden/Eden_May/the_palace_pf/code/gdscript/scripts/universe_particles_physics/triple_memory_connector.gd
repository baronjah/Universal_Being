extends Node
class_name TripleMemoryConnector

# Triple Memory Connector
# Specializes in connecting 3-way memory patterns with special focus on "333" repeating patterns
# Integrates shade-based memory visualization for editor display
# Supports PS5 controller input for intuitive memory sorting

# Triple connection modes
enum TripleMode {
	LINEAR,     # A → B → C
	TRIANGULAR, # A ↔ B ↔ C ↔ A
	RADIAL,     # A,B,C → center
	NESTED,     # A contains B contains C
	TEMPORAL,   # A before B before C
	SPECTRAL    # Shade-based connection (light to dark)
}

# Connection strengths (333 scale)
const MIN_STRENGTH = 1
const MID_STRENGTH = 3 
const MAX_STRENGTH = 9
const PERFECT_TRIAD = 333 # Special resonance value

# Memory shade mapping
var shade_mapping = {
	"light": {"r": 0.9, "g": 0.9, "b": 0.9, "memory_weight": 1.0},
	"medium": {"r": 0.5, "g": 0.5, "b": 0.5, "memory_weight": 3.0},
	"dark": {"r": 0.2, "g": 0.2, "b": 0.2, "memory_weight": 9.0},
	"ethereal": {"r": 0.7, "g": 0.9, "b": 1.0, "memory_weight": 3.3}
}

# PS5 controller input mapping
var ps5_button_mapping = {
	"cross": {"action": "confirm_connection", "triple_index": 0},
	"circle": {"action": "cancel_connection", "triple_index": null},
	"triangle": {"action": "create_triangle_mode", "triple_index": 1},
	"square": {"action": "create_quad_mode", "triple_index": 2},
	"l1": {"action": "prev_shade", "shade_delta": -1},
	"r1": {"action": "next_shade", "shade_delta": 1},
	"l2": {"action": "decrease_strength", "strength_delta": -1},
	"r2": {"action": "increase_strength", "strength_delta": 1},
	"touchpad": {"action": "reset_connections", "triple_index": null},
	"create": {"action": "create_new_memory", "memory_type": null}
}

# Triple pattern data
var triple_patterns = []
var active_triple_index = 0
var current_shade = "medium"
var connection_strength = MID_STRENGTH
var controller_connected = false

# Referenced systems
var memory_turn_system
var editor_interface

# Signals
signal triple_created(pattern_id, strength)
signal triple_connected(source_id, target_id, type)
signal shade_changed(memory_id, old_shade, new_shade)
signal controller_status_changed(connected)

# ===== Initialization =====

func _ready():
	# Attempt to get references to other systems
	memory_turn_system = find_memory_turn_system()
	editor_interface = find_editor_interface()
	
	# Set up controller detection
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	check_controller_connection()
	
	# Load existing triple patterns
	load_triple_patterns()

func find_memory_turn_system():
	var parent = get_parent()
	while parent != null:
		if parent is MemoryTurnSystem:
			return parent
		parent = parent.get_parent()
	
	# Try to find it in the scene
	return get_node_or_null("/root/MemoryTurnSystem")

func find_editor_interface():
	# For in-editor usage, attempt to get editor interface
	# This only works when running as plugin
	if Engine.is_editor_hint():
		var editor_plugin = EditorPlugin.new()
		var interface = editor_plugin.get_editor_interface()
		editor_plugin.queue_free()
		return interface
	return null

# ===== Triple Pattern Management =====

func create_triple_pattern(memories: Array, mode: int = TripleMode.TRIANGULAR) -> int:
	if memories.size() != 3:
		print("ERROR: Triple pattern requires exactly 3 memories")
		return -1
	
	# Generate a unique pattern ID
	var pattern_id = generate_pattern_id(memories)
	
	# Create the pattern
	var pattern = {
		"id": pattern_id,
		"memories": memories.duplicate(),
		"mode": mode,
		"strength": connection_strength,
		"shade": current_shade,
		"timestamp": Time.get_unix_time_from_system(),
		"resonance": calculate_resonance(memories)
	}
	
	# Check for 333 pattern
	if pattern.resonance == PERFECT_TRIAD:
		pattern["is_333"] = true
		print("333 RESONANCE DETECTED!")
	
	# Store the pattern
	triple_patterns.append(pattern)
	active_triple_index = triple_patterns.size() - 1
	
	# Save to file
	save_triple_pattern(pattern)
	
	# Signal creation
	emit_signal("triple_created", pattern_id, pattern.strength)
	
	return pattern_id

func generate_pattern_id(memories: Array) -> int:
	# Create a unique ID based on memory IDs
	var id_base = 0
	for memory in memories:
		id_base += memory.id
	
	# Add uniqueness factor
	var current_time = int(Time.get_unix_time_from_system()) % 100000
	return id_base * 1000 + current_time

func calculate_resonance(memories: Array) -> int:
	# Special algorithm to detect 333 patterns and other resonances
	var resonance = 0
	
	# Check for numeric patterns in memory IDs
	for memory in memories:
		var id_str = str(memory.id)
		
		# Count occurrences of '3'
		var count_3 = 0
		for digit in id_str:
			if digit == '3':
				count_3 += 1
		
		# Add to resonance based on 3s
		resonance += count_3 * 111
		
		# Check memory type weights
		if memory.has("type"):
			var type_weight = memory.type % 3 + 1
			resonance += type_weight * 10
	
	# Check for perfect 333 pattern
	if resonance == 333 or resonance == 999:
		return PERFECT_TRIAD
	
	return resonance

func get_triple_pattern(pattern_id: int) -> Dictionary:
	for pattern in triple_patterns:
		if pattern.id == pattern_id:
			return pattern
	return {}

func delete_triple_pattern(pattern_id: int) -> bool:
	for i in range(triple_patterns.size()):
		if triple_patterns[i].id == pattern_id:
			triple_patterns.remove_at(i)
			
			# Delete file
			var file_path = get_triple_pattern_path(pattern_id)
			if FileAccess.file_exists(file_path):
				DirAccess.remove_absolute(file_path)
			
			return true
	
	return false

# ===== File Operations =====

func get_triple_pattern_path(pattern_id: int) -> String:
	return "user://memories/triple_" + str(pattern_id) + ".json"

func save_triple_pattern(pattern: Dictionary) -> bool:
	var file_path = get_triple_pattern_path(pattern.id)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_line(JSON.stringify(pattern))
		file.close()
		return true
	
	return false

func load_triple_patterns() -> int:
	triple_patterns.clear()
	
	var dir = DirAccess.open("user://memories/")
	if !dir:
		return 0
	
	var loaded_count = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !dir.current_is_dir() and file_name.begins_with("triple_") and file_name.ends_with(".json"):
			var file_path = "user://memories/" + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			
			if file:
				var json_string = file.get_as_text()
				file.close()
				
				var json_result = JSON.parse_string(json_string)
				if json_result:
					triple_patterns.append(json_result)
					loaded_count += 1
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	print("Loaded " + str(loaded_count) + " triple patterns")
	if loaded_count > 0:
		active_triple_index = 0
	
	return loaded_count

# ===== Shade Management =====

func set_memory_shade(memory_id: int, shade: String) -> bool:
	if !shade_mapping.has(shade):
		print("Invalid shade: " + shade)
		return false
	
	if !memory_turn_system:
		print("Memory turn system not found")
		return false
	
	var memory_data = memory_turn_system.retrieve_memory(memory_id)
	if memory_data.is_empty():
		print("Memory not found: " + str(memory_id))
		return false
	
	var old_shade = memory_data.get("shade", "medium")
	
	# Update the memory with the new shade
	memory_data["shade"] = shade
	memory_data["shade_weight"] = shade_mapping[shade].memory_weight
	
	# Store back to memory system
	if memory_turn_system.has_method("update_memory"):
		memory_turn_system.update_memory(memory_id, memory_data)
	
	emit_signal("shade_changed", memory_id, old_shade, shade)
	
	return true

func cycle_memory_shade(memory_id: int, direction: int = 1) -> String:
	var memory_data = memory_turn_system.retrieve_memory(memory_id)
	if memory_data.is_empty():
		return ""
	
	var current = memory_data.get("shade", "medium")
	var shades = shade_mapping.keys()
	var current_index = shades.find(current)
	
	if current_index == -1:
		current_index = shades.find("medium")
	
	var new_index = (current_index + direction) % shades.size()
	if new_index < 0:
		new_index = shades.size() - 1
	
	var new_shade = shades[new_index]
	set_memory_shade(memory_id, new_shade)
	
	return new_shade

func get_shade_color(shade: String) -> Color:
	if !shade_mapping.has(shade):
		return Color(0.5, 0.5, 0.5)  # Default gray
	
	var s = shade_mapping[shade]
	return Color(s.r, s.g, s.b)

# ===== Editor Integration =====

func update_editor_shade(memory_id: int, shade: String) -> bool:
	if !editor_interface or !Engine.is_editor_hint():
		return false
	
	var color = get_shade_color(shade)
	
	# In a real implementation, this would use EditorInterface APIs
	# to change the appearance of memory nodes in the editor
	print("Updating editor shade for memory " + str(memory_id) + " to " + shade)
	
	return true

func apply_editor_theme(triple_id: int) -> bool:
	var pattern = get_triple_pattern(triple_id)
	if pattern.is_empty():
		return false
	
	var is_333 = pattern.get("is_333", false)
	
	# Apply special highlighting for 333 patterns
	if is_333 and editor_interface:
		print("Applying 333 special highlighting in editor")
		
		# In a real implementation, this would create a visual effect
		# in the editor for this special pattern
		
		return true
	
	return false

# ===== PS5 Controller Integration =====

func check_controller_connection():
	var was_connected = controller_connected
	controller_connected = false
	
	# Check for PS5 controller specifically
	for device_id in Input.get_connected_joypads():
		var device_name = Input.get_joy_name(device_id)
		if "PS5" in device_name or "DualSense" in device_name:
			controller_connected = true
			break
	
	if controller_connected != was_connected:
		emit_signal("controller_status_changed", controller_connected)
		print("PS5 controller " + ("connected" if controller_connected else "disconnected"))

func _on_joy_connection_changed(device_id: int, connected: bool):
	# Recheck controller status
	check_controller_connection()

func is_controller_button_pressed(button_name: String) -> bool:
	if !controller_connected:
		return false
	
	# Map button name to joystick button index
	var button_mapping = {
		"cross": JOY_BUTTON_A,
		"circle": JOY_BUTTON_B,
		"square": JOY_BUTTON_X,
		"triangle": JOY_BUTTON_Y,
		"l1": JOY_BUTTON_LEFT_SHOULDER,
		"r1": JOY_BUTTON_RIGHT_SHOULDER,
		"create": JOY_BUTTON_BACK,
		"touchpad": JOY_BUTTON_TOUCHPAD
	}
	
	if !button_mapping.has(button_name):
		return false
	
	return Input.is_joy_button_pressed(0, button_mapping[button_name])

func get_controller_axis(axis_name: String) -> float:
	if !controller_connected:
		return 0.0
	
	var axis_mapping = {
		"left_x": JOY_AXIS_LEFT_X,
		"left_y": JOY_AXIS_LEFT_Y,
		"right_x": JOY_AXIS_RIGHT_X,
		"right_y": JOY_AXIS_RIGHT_Y,
		"l2": JOY_AXIS_TRIGGER_LEFT,
		"r2": JOY_AXIS_TRIGGER_RIGHT
	}
	
	if !axis_mapping.has(axis_name):
		return 0.0
	
	return Input.get_joy_axis(0, axis_mapping[axis_name])

# ===== Data Sorting with Controller =====

func sort_memories_by_controller():
	if !controller_connected:
		print("Controller not connected")
		return
	
	if !memory_turn_system:
		print("Memory turn system not found")
		return
	
	print("Enter sorting mode with PS5 controller")
	
	# In a full implementation, this would be a state machine
	# that handles controller input for sorting memories
	# This is a simplified version
	
	_process_controller_sorting()

func _process_controller_sorting():
	# Get left stick position for selection
	var left_x = get_controller_axis("left_x")
	var left_y = get_controller_axis("left_y")
	
	# Get right stick position for shade adjustment
	var right_x = get_controller_axis("right_x")
	var right_y = get_controller_axis("right_y")
	
	# Get trigger values for strength adjustment
	var l2 = get_controller_axis("l2")
	var r2 = get_controller_axis("r2")
	
	# Adjust connection strength based on triggers
	if r2 > 0.5:
		connection_strength = min(connection_strength + 1, MAX_STRENGTH)
	elif l2 > 0.5:
		connection_strength = max(connection_strength - 1, MIN_STRENGTH)
	
	# Change modes with face buttons
	if is_controller_button_pressed("triangle"):
		_change_triple_mode(TripleMode.TRIANGULAR)
	elif is_controller_button_pressed("square"):
		_change_triple_mode(TripleMode.RADIAL)
	elif is_controller_button_pressed("cross"):
		_confirm_triple_connection()
	elif is_controller_button_pressed("circle"):
		_cancel_triple_connection()

func _change_triple_mode(mode: int):
	if triple_patterns.size() > 0 and active_triple_index >= 0 and active_triple_index < triple_patterns.size():
		triple_patterns[active_triple_index].mode = mode
		save_triple_pattern(triple_patterns[active_triple_index])
		print("Changed triple mode to: " + str(mode))

func _confirm_triple_connection():
	if triple_patterns.size() > 0 and active_triple_index >= 0:
		var pattern = triple_patterns[active_triple_index]
		print("Confirmed triple connection: " + str(pattern.id))
		# Apply connection effect here

func _cancel_triple_connection():
	print("Cancelled triple connection")
	# Reset any pending connection

# ===== Processing =====

func _process(delta):
	# Process controller input if connected
	if controller_connected:
		process_controller_input()

func process_controller_input():
	# Check for specific button combinations for triples of 3s
	if is_controller_button_pressed("triangle") and is_controller_button_pressed("square") and is_controller_button_pressed("cross"):
		# Special 333 combination
		print("333 combination detected!")
		if active_triple_index >= 0 and active_triple_index < triple_patterns.size():
			# Force resonance to 333
			var pattern = triple_patterns[active_triple_index]
			pattern["resonance"] = PERFECT_TRIAD
			pattern["is_333"] = true
			save_triple_pattern(pattern)
	
	# Check for shade cycling with bumpers
	if is_controller_button_pressed("r1"):
		current_shade = cycle_shades(1)
	elif is_controller_button_pressed("l1"):
		current_shade = cycle_shades(-1)

func cycle_shades(direction: int) -> String:
	var shades = shade_mapping.keys()
	var current_index = shades.find(current_shade)
	
	if current_index == -1:
		current_index = 0
	
	var new_index = (current_index + direction) % shades.size()
	if new_index < 0:
		new_index = shades.size() - 1
	
	return shades[new_index]

# ===== Triple Connection Utilities =====

func connect_triple_memories(memory_ids: Array, mode: int = TripleMode.TRIANGULAR) -> int:
	if memory_ids.size() != 3:
		print("ERROR: Triple connection requires exactly 3 memories")
		return -1
	
	var memories = []
	for id in memory_ids:
		var memory = memory_turn_system.retrieve_memory(id)
		if memory.is_empty():
			print("Memory not found: " + str(id))
			return -1
		memories.append(memory)
	
	return create_triple_pattern(memories, mode)

func are_memories_connected(memory_id1: int, memory_id2: int) -> bool:
	for pattern in triple_patterns:
		var memory_ids = []
		for memory in pattern.memories:
			memory_ids.append(memory.id)
		
		if memory_id1 in memory_ids and memory_id2 in memory_ids:
			return true
	
	return false

func find_triple_patterns_with_memory(memory_id: int) -> Array:
	var patterns = []
	for pattern in triple_patterns:
		for memory in pattern.memories:
			if memory.id == memory_id:
				patterns.append(pattern)
				break
	
	return patterns

# ===== Special 333 Functionality =====

func create_333_resonance(memories: Array) -> Dictionary:
	# Force a triple pattern to have 333 resonance
	if memories.size() != 3:
		return {}
	
	var pattern_id = create_triple_pattern(memories, TripleMode.TRIANGULAR)
	if pattern_id == -1:
		return {}
	
	var pattern = get_triple_pattern(pattern_id)
	if pattern.is_empty():
		return {}
	
	# Set to perfect triad
	pattern["resonance"] = PERFECT_TRIAD
	pattern["is_333"] = true
	pattern["strength"] = 9  # Maximum strength
	pattern["shade"] = "ethereal"  # Special shade
	
	# Save the modified pattern
	save_triple_pattern(pattern)
	
	print("Created 333 Resonance Pattern: " + str(pattern_id))
	return pattern

func find_all_333_patterns() -> Array:
	var patterns_333 = []
	
	for pattern in triple_patterns:
		if pattern.get("is_333", false) or pattern.get("resonance", 0) == PERFECT_TRIAD:
			patterns_333.append(pattern)
	
	return patterns_333

func activate_333_mode() -> bool:
	var patterns_333 = find_all_333_patterns()
	if patterns_333.size() == 0:
		print("No 333 patterns found")
		return false
	
	print("Activating 333 mode with " + str(patterns_333.size()) + " patterns")
	
	# Apply special effects or behavior for 333 mode
	for pattern in patterns_333:
		apply_editor_theme(pattern.id)
	
	return true
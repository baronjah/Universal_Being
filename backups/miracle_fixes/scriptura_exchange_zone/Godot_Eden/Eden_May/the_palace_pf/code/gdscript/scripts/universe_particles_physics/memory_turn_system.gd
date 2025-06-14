extends Node
class_name MemoryTurnSystem

# Memory Turn System
# Manages memory across 12 turns in a cyclic pattern
# Controls file operations, screen modes and thread management
# Implements the spatial-temporal dot frequency model

# Memory types and their weights
enum MemoryType {
	SPATIAL,       # Space-related memories
	TEMPORAL,      # Time-related memories
	CONNECTION,    # Connection between entities
	RESOURCE,      # Resource information
	CALCULATION,   # Calculation results
	WARP,          # Teleportation/warp information
	SHAPE,         # Shape information
	COLOR,         # Color information
	DIMENSION,     # Dimensional data
	ANIMATION,     # Animation data
	SCRIPT,        # Script execution memory
	META          # Memory about memory
}

# Memory storage constants
const MAX_MEMORY_SLOTS = 38
const TURN_COUNT = 12
const MEMORY_FILE_EXTENSION = ".mem"
const MEMORY_PATH = "user://memories/"
const DOT_FREQUENCY_BASE = 23  # Base dot frequency percentage

# Memory allocation mapping
var memory_allocations = {
	MemoryType.SPATIAL: 0.15,       # 15%
	MemoryType.TEMPORAL: 0.10,      # 10%
	MemoryType.CONNECTION: 0.12,    # 12%
	MemoryType.RESOURCE: 0.08,      # 8%
	MemoryType.CALCULATION: 0.05,   # 5%
	MemoryType.WARP: 0.07,          # 7%
	MemoryType.SHAPE: 0.10,         # 10%
	MemoryType.COLOR: 0.08,         # 8%
	MemoryType.DIMENSION: 0.06,     # 6%
	MemoryType.ANIMATION: 0.09,     # 9%
	MemoryType.SCRIPT: 0.05,        # 5%
	MemoryType.META: 0.05           # 5%
}

# Current state variables
var current_turn = 0
var memory_slots = []
var active_dots = []
var screen_mode = "FULL"  # FULL, HALF, CENTER
var is_processing = false
var file_open_count = 0

# Thread management
var threads = []
var max_threads = 4
var thread_processing = false

# Signals
signal turn_completed(turn_number)
signal memory_stored(memory_type, memory_id)
signal dot_frequency_changed(new_frequency)
signal screen_mode_changed(new_mode)

# ===== Initialization =====

func _ready():
	# Create directory for memory storage
	var dir = DirAccess.open("user://")
	if !dir.dir_exists(MEMORY_PATH):
		dir.make_dir(MEMORY_PATH)
	
	# Initialize memory slots
	initialize_memory_slots()
	
	# Initialize dot frequency
	initialize_dot_system()
	
	# Start first turn
	start_next_turn()

func initialize_memory_slots():
	memory_slots.clear()
	for i in range(MAX_MEMORY_SLOTS):
		memory_slots.append(null)
	
	# Load any existing memories
	load_all_memories()

func initialize_dot_system():
	active_dots.clear()
	
	# Create dot pattern based on frequency
	var dot_count = int(MAX_MEMORY_SLOTS * DOT_FREQUENCY_BASE / 100.0)
	for i in range(dot_count):
		active_dots.append(i)
	
	# Shuffle to randomize
	active_dots.shuffle()
	
	# Emit signal about current frequency
	emit_signal("dot_frequency_changed", DOT_FREQUENCY_BASE)

# ===== Turn Management =====

func start_next_turn():
	# Complete current turn
	if current_turn > 0:
		emit_signal("turn_completed", current_turn)
	
	# Move to next turn
	current_turn = (current_turn % TURN_COUNT) + 1
	
	# Perform turn initialization
	print("Starting turn " + str(current_turn) + " of " + str(TURN_COUNT))
	
	# For even turns, open all memory files
	# For odd turns, close all memory files
	if current_turn % 2 == 0:
		open_memory_files()
	else:
		close_memory_files()
	
	# Update screen mode based on turn
	update_screen_mode()
	
	# Every 3rd turn, reallocate memory
	if current_turn % 3 == 0:
		reallocate_memory()
	
	# Every 4th turn, change dot frequency
	if current_turn % 4 == 0:
		change_dot_frequency()
	
	# Save turn data
	save_turn_data()

func complete_turn():
	if is_processing:
		print("Cannot complete turn: still processing")
		return
	
	# Process any remaining memories
	process_pending_memories()
	
	# Start next turn
	start_next_turn()

func save_turn_data():
	var turn_data = {
		"turn_number": current_turn,
		"timestamp": Time.get_unix_time_from_system(),
		"memory_count": count_active_memories(),
		"dot_frequency": DOT_FREQUENCY_BASE,
		"screen_mode": screen_mode,
		"active_threads": threads.size()
	}
	
	var file_path = MEMORY_PATH + "turn_" + str(current_turn) + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(turn_data))
		file.close()

# ===== Memory Management =====

func store_memory(memory_type: int, data: Dictionary):
	if !MemoryType.values().has(memory_type):
		print("Invalid memory type: " + str(memory_type))
		return -1
	
	# Find an available slot based on memory type allocation
	var slot_index = find_available_slot(memory_type)
	
	if slot_index == -1:
		print("No available memory slots for type: " + str(memory_type))
		return -1
	
	# Calculate memory identifier
	var memory_id = current_turn * 1000 + slot_index
	
	# Add timestamp
	data["timestamp"] = Time.get_unix_time_from_system()
	data["memory_type"] = memory_type
	data["memory_id"] = memory_id
	data["turn"] = current_turn
	
	# Store in memory slot
	memory_slots[slot_index] = {
		"type": memory_type,
		"id": memory_id,
		"data": data
	}
	
	# Save to file
	save_memory_to_file(slot_index)
	
	# Emit signal
	emit_signal("memory_stored", memory_type, memory_id)
	
	return memory_id

func find_available_slot(memory_type: int) -> int:
	# Calculate how many slots should be allocated to this memory type
	var type_allocation = int(MAX_MEMORY_SLOTS * memory_allocations[memory_type])
	var type_count = 0
	
	# First, count how many slots are already used by this type
	for i in range(MAX_MEMORY_SLOTS):
		if memory_slots[i] != null and memory_slots[i].type == memory_type:
			type_count += 1
	
	# If we've reached allocation, check if we can overwrite oldest
	if type_count >= type_allocation:
		return find_oldest_memory_slot(memory_type)
	
	# Otherwise, find a free slot
	for i in range(MAX_MEMORY_SLOTS):
		if memory_slots[i] == null and is_dot_active(i):
			return i
	
	# If no free slot with active dot, try any free slot
	for i in range(MAX_MEMORY_SLOTS):
		if memory_slots[i] == null:
			return i
	
	# If no free slots, find the oldest one of any type
	return find_oldest_memory_slot(-1)

func find_oldest_memory_slot(memory_type: int) -> int:
	var oldest_timestamp = Time.get_unix_time_from_system()
	var oldest_index = -1
	
	for i in range(MAX_MEMORY_SLOTS):
		if memory_slots[i] != null:
			var slot_type = memory_slots[i].type
			var timestamp = memory_slots[i].data.timestamp
			
			if (memory_type == -1 or slot_type == memory_type) and timestamp < oldest_timestamp:
				oldest_timestamp = timestamp
				oldest_index = i
	
	return oldest_index

func retrieve_memory(memory_id: int) -> Dictionary:
	for i in range(MAX_MEMORY_SLOTS):
		if memory_slots[i] != null and memory_slots[i].id == memory_id:
			return memory_slots[i].data
	
	# If not found in memory, try loading from file
	var file_path = MEMORY_PATH + str(memory_id) + MEMORY_FILE_EXTENSION
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json_result = JSON.parse_string(json_string)
			if json_result:
				return json_result
	
	return {}

func count_active_memories() -> int:
	var count = 0
	for slot in memory_slots:
		if slot != null:
			count += 1
	return count

func save_memory_to_file(slot_index: int):
	if slot_index < 0 or slot_index >= memory_slots.size() or memory_slots[slot_index] == null:
		return
	
	var memory = memory_slots[slot_index]
	var file_path = MEMORY_PATH + str(memory.id) + MEMORY_FILE_EXTENSION
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(memory.data))
		file.close()

func load_memory_from_file(memory_id: int) -> Dictionary:
	var file_path = MEMORY_PATH + str(memory_id) + MEMORY_FILE_EXTENSION
	
	if !FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if !file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json_result = JSON.parse_string(json_string)
	if json_result:
		return json_result
	
	return {}

func load_all_memories():
	var dir = DirAccess.open(MEMORY_PATH)
	if !dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(MEMORY_FILE_EXTENSION):
			var memory_id = file_name.replace(MEMORY_FILE_EXTENSION, "").to_int()
			var memory_data = load_memory_from_file(memory_id)
			
			if !memory_data.is_empty() and memory_data.has("memory_type") and memory_data.has("memory_id"):
				var slot_index = find_available_slot(memory_data.memory_type)
				
				if slot_index != -1:
					memory_slots[slot_index] = {
						"type": memory_data.memory_type,
						"id": memory_data.memory_id,
						"data": memory_data
					}
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# ===== Dot System =====

func is_dot_active(index: int) -> bool:
	return index in active_dots

func change_dot_frequency():
	# Adjust dot frequency by a random amount between -5 and +5 percent
	var change = randi_range(-5, 5)
	DOT_FREQUENCY_BASE = clamp(DOT_FREQUENCY_BASE + change, 10, 50)
	
	# Recalculate active dots
	active_dots.clear()
	var dot_count = int(MAX_MEMORY_SLOTS * DOT_FREQUENCY_BASE / 100.0)
	
	for i in range(dot_count):
		active_dots.append(randi() % MAX_MEMORY_SLOTS)
	
	# Remove duplicates
	var unique_dots = []
	for dot in active_dots:
		if not dot in unique_dots:
			unique_dots.append(dot)
	
	active_dots = unique_dots
	
	print("Dot frequency changed to: " + str(DOT_FREQUENCY_BASE) + "% (" + str(active_dots.size()) + " dots)")
	emit_signal("dot_frequency_changed", DOT_FREQUENCY_BASE)

# ===== File Operations =====

func open_memory_files():
	file_open_count = 0
	
	for i in range(memory_slots.size()):
		if memory_slots[i] != null and is_dot_active(i):
			var memory_id = memory_slots[i].id
			var file_path = MEMORY_PATH + str(memory_id) + MEMORY_FILE_EXTENSION
			
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				file_open_count += 1
				# We immediately close the file after opening it, 
				# since we're just simulating file operations
				file.close()
	
	print("Opened " + str(file_open_count) + " memory files")

func close_memory_files():
	print("Closed all memory files")
	file_open_count = 0

# ===== Screen Mode Management =====

func update_screen_mode():
	var modes = ["FULL", "HALF", "CENTER"]
	
	# Deterministic pattern based on turn number
	match current_turn % 3:
		0: screen_mode = "FULL"
		1: screen_mode = "HALF"
		2: screen_mode = "CENTER"
	
	print("Screen mode changed to: " + screen_mode)
	emit_signal("screen_mode_changed", screen_mode)

func get_screen_coordinates() -> Rect2:
	var viewport_size = get_viewport().size
	
	match screen_mode:
		"FULL":
			return Rect2(0, 0, viewport_size.x, viewport_size.y)
		"HALF":
			return Rect2(0, 0, viewport_size.x / 2, viewport_size.y)
		"CENTER":
			var half_width = viewport_size.x / 4
			var half_height = viewport_size.y / 4
			return Rect2(viewport_size.x / 2 - half_width, 
						viewport_size.y / 2 - half_height,
						half_width * 2, half_height * 2)
		_:
			return Rect2(0, 0, viewport_size.x, viewport_size.y)

# ===== Thread Management =====

func start_thread(function_name: String, args: Array = []):
	if threads.size() >= max_threads:
		print("Maximum thread count reached")
		return false
	
	var thread = Thread.new()
	var err = thread.start(Callable(self, function_name), args)
	
	if err != OK:
		print("Error starting thread: " + str(err))
		return false
	
	threads.append(thread)
	return true

func process_pending_memories():
	# Simulate processing memories in a separate thread
	thread_processing = true
	
	# Process 23% of memories (based on dot frequency base)
	var process_count = int(count_active_memories() * 0.23)
	
	for i in range(process_count):
		# Simulate processing
		await get_tree().create_timer(0.01).timeout
	
	thread_processing = false

# ===== Memory Reallocation =====

func reallocate_memory():
	# Reallocate memory by adjusting memory type allocations
	var reallocation_factor = 0.05  # 5% change
	
	# Randomly select 3 memory types to boost and 3 to reduce
	var types = MemoryType.values()
	types.shuffle()
	
	for i in range(3):
		var boost_type = types[i]
		var reduce_type = types[i + 3]
		
		# Adjust allocations
		memory_allocations[boost_type] += reallocation_factor
		memory_allocations[reduce_type] -= reallocation_factor
		
		# Ensure allocations are reasonable
		memory_allocations[boost_type] = clamp(memory_allocations[boost_type], 0.05, 0.20)
		memory_allocations[reduce_type] = clamp(memory_allocations[reduce_type], 0.05, 0.20)
	
	print("Memory allocations rebalanced: " + str(memory_allocations))

# ===== Warp/Teleport Functions =====

func warp_to_location(location_id: int) -> bool:
	# Placeholder function for teleporting/warping
	print("Warping to location: " + str(location_id))
	
	# Store memory of warp
	var warp_data = {
		"location_id": location_id,
		"warp_type": "standard",
		"source_turn": current_turn
	}
	
	var memory_id = store_memory(MemoryType.WARP, warp_data)
	return memory_id != -1

func teleport_home() -> bool:
	return warp_to_location(0)  # Home is location 0

func tp(location_name: String) -> bool:
	var location_mapping = {
		"home": 0,
		"c": 1,  # Drive C
		"d": 2,  # Drive D
		"entrance": 3,
		"warp": 4,
		"start": 5
	}
	
	if location_mapping.has(location_name.to_lower()):
		return warp_to_location(location_mapping[location_name.to_lower()])
	else:
		print("Unknown location: " + location_name)
		return false

# ===== Utility Functions =====

func calculate_memory_stats() -> Dictionary:
	var stats = {}
	
	# Count memories by type
	for type in MemoryType.values():
		stats[type] = 0
	
	for slot in memory_slots:
		if slot != null:
			stats[slot.type] += 1
	
	# Calculate other statistics
	stats["total_memories"] = count_active_memories()
	stats["usage_percent"] = float(count_active_memories()) / MAX_MEMORY_SLOTS * 100.0
	stats["dot_frequency"] = DOT_FREQUENCY_BASE
	stats["active_dots"] = active_dots.size()
	stats["current_turn"] = current_turn
	
	return stats

func generate_memory_report() -> String:
	var stats = calculate_memory_stats()
	var report = "=== Memory Turn System Report ===\n"
	
	report += "Turn: " + str(current_turn) + " / " + str(TURN_COUNT) + "\n"
	report += "Memory usage: " + str(stats.total_memories) + " / " + str(MAX_MEMORY_SLOTS) + " slots (" + str(stats.usage_percent) + "%)\n"
	report += "Dot frequency: " + str(DOT_FREQUENCY_BASE) + "% (" + str(stats.active_dots) + " active dots)\n"
	report += "Screen mode: " + screen_mode + "\n\n"
	
	report += "Memory allocation by type:\n"
	for type in MemoryType.keys():
		var type_enum = MemoryType[type]
		report += "- " + type + ": " + str(stats[type_enum]) + " / " + str(int(MAX_MEMORY_SLOTS * memory_allocations[type_enum])) + " allocated\n"
	
	return report

# Process method for realtime updates
func _process(delta):
	# Add any realtime processing here
	pass
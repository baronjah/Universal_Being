extends Node
## Akashic Navigator Autoload
## Manages navigation through the 11-level akashic records hierarchy
## Based on: Multiverses → Multiverse → Universes → Universe → Galaxies → Galaxy → Milky_way_Galaxy → Stars → Star → Celestial_Bodies → Planets

# Navigation signals
signal navigation_changed(new_level: String)
signal word_data_loaded(word_data: Array)
signal level_transition_started(from_level: String, to_level: String)
signal level_transition_completed(level: String)

# Navigation hierarchy definition
const NAVIGATION_HIERARCHY = [
	"Multiverses",
	"Multiverse", 
	"Universes",
	"Universe",
	"Galaxies",
	"Galaxy",
	"Milky_way_Galaxy",
	"Stars",
	"Star",
	"Celestial_Bodies",
	"Planets"
]

# Current navigation state
var current_level_index: int = 0
var current_level_name: String = "Multiverses"
var navigation_history: Array[String] = []
var lateral_position: int = 0
var max_lateral_positions: Dictionary = {}

# Navigation data cache
var level_data_cache: Dictionary = {}
var point_files_cache: Dictionary = {}
var wall_files_cache: Dictionary = {}

# File system paths
var akashic_records_path: String = ""
var desktop_claude_path: String = ""

func _ready() -> void:
	_initialize_navigation_system()
	_load_navigation_hierarchy_data()
	print("Akashic Navigator initialized - Starting at: ", current_level_name)

func _initialize_navigation_system() -> void:
	# Set up file system paths
	akashic_records_path = "/mnt/c/Users/Percision 15/Desktop/claude_desktop/kamisama_tests/Eden/AkashicRecord/AkashicRecords"
	desktop_claude_path = "/mnt/c/Users/Percision 15/Desktop/claude_desktop"
	
	# Initialize lateral position tracking
	for level in NAVIGATION_HIERARCHY:
		max_lateral_positions[level] = 9  # 0-9 for each level (point_0.txt to point_9.txt)
	
	# Start navigation history
	navigation_history.append(current_level_name)

func _load_navigation_hierarchy_data() -> void:
	# Load master navigation index
	var master_index_path = akashic_records_path + "/MASTER_NAVIGATION_INDEX.md"
	if FileAccess.file_exists(master_index_path):
		var file = FileAccess.open(master_index_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			print("Master Navigation Index loaded")
	
	# Cache initial level data
	_cache_level_data(current_level_name)

func navigate_to_level(level_name: String) -> bool:
	if level_name in NAVIGATION_HIERARCHY:
		var old_level = current_level_name
		var new_index = NAVIGATION_HIERARCHY.find(level_name)
		
		level_transition_started.emit(old_level, level_name)
		
		current_level_index = new_index
		current_level_name = level_name
		lateral_position = 0
		
		_add_to_navigation_history(level_name)
		_cache_level_data(level_name)
		_load_word_data_for_level(level_name)
		
		navigation_changed.emit(level_name)
		level_transition_completed.emit(level_name)
		
		print("Navigated to: ", level_name, " (Index: ", new_index, ")")
		return true
	
	print("Invalid navigation level: ", level_name)
	return false

func navigate_up() -> bool:
	if current_level_index > 0:
		var new_index = current_level_index - 1
		var new_level = NAVIGATION_HIERARCHY[new_index]
		return navigate_to_level(new_level)
	
	print("Already at top level: ", current_level_name)
	return false

func navigate_down() -> bool:
	if current_level_index < NAVIGATION_HIERARCHY.size() - 1:
		var new_index = current_level_index + 1
		var new_level = NAVIGATION_HIERARCHY[new_index]
		return navigate_to_level(new_level)
	
	print("Already at bottom level: ", current_level_name)
	return false

func navigate_lateral(direction: int) -> bool:
	var new_position = lateral_position + direction
	var max_pos = max_lateral_positions.get(current_level_name, 9)
	
	if new_position >= 0 and new_position <= max_pos:
		lateral_position = new_position
		_load_point_data_for_position(lateral_position)
		print("Moved laterally to position: ", lateral_position, " in ", current_level_name)
		return true
	
	print("Cannot move laterally - at boundary (Position: ", lateral_position, ", Max: ", max_pos, ")")
	return false

func get_current_level_name() -> String:
	return current_level_name

func get_current_level_index() -> int:
	return current_level_index

func get_lateral_position() -> int:
	return lateral_position

func get_navigation_history() -> Array[String]:
	return navigation_history.duplicate()

func can_navigate_up() -> bool:
	return current_level_index > 0

func can_navigate_down() -> bool:
	return current_level_index < NAVIGATION_HIERARCHY.size() - 1

func can_navigate_lateral(direction: int) -> bool:
	var new_position = lateral_position + direction
	var max_pos = max_lateral_positions.get(current_level_name, 9)
	return new_position >= 0 and new_position <= max_pos

func _cache_level_data(level_name: String) -> void:
	var level_path = akashic_records_path + "/" + level_name
	
	if not DirAccess.dir_exists_absolute(level_path):
		print("Level directory does not exist: ", level_path)
		return
	
	# Cache navigation stitch file
	var stitch_path = level_path + "/NAVIGATION_STITCH.md"
	if FileAccess.file_exists(stitch_path):
		var file = FileAccess.open(stitch_path, FileAccess.READ)
		if file:
			level_data_cache[level_name + "_stitch"] = file.get_as_text()
			file.close()
	
	# Cache point files (0-9)
	for i in range(10):
		var point_path = level_path + "/point_" + str(i) + ".txt"
		if FileAccess.file_exists(point_path):
			var file = FileAccess.open(point_path, FileAccess.READ)
			if file:
				point_files_cache[level_name + "_point_" + str(i)] = file.get_as_text()
				file.close()
	
	# Cache wall files (0-9)
	for i in range(10):
		var wall_path = level_path + "/wall_" + str(i) + ".txt"
		if FileAccess.file_exists(wall_path):
			var file = FileAccess.open(wall_path, FileAccess.READ)
			if file:
				wall_files_cache[level_name + "_wall_" + str(i)] = file.get_as_text()
				file.close()
	
	print("Cached data for level: ", level_name)

func _load_word_data_for_level(level_name: String) -> void:
	var word_data_array: Array = []
	
	# Generate word data based on cached point and wall files
	for i in range(10):
		var point_key = level_name + "_point_" + str(i)
		var wall_key = level_name + "_wall_" + str(i)
		
		if point_files_cache.has(point_key):
			var point_content = point_files_cache[point_key]
			var word_data = _create_word_data_from_content(point_content, "point", i, level_name)
			word_data_array.append(word_data)
		
		if wall_files_cache.has(wall_key):
			var wall_content = wall_files_cache[wall_key]
			var word_data = _create_word_data_from_content(wall_content, "wall", i, level_name)
			word_data_array.append(word_data)
	
	# Add level-specific generated words
	word_data_array.append_array(_generate_level_specific_words(level_name))
	
	word_data_loaded.emit(word_data_array)
	print("Loaded ", word_data_array.size(), " word entities for level: ", level_name)

func _create_word_data_from_content(content: String, type: String, index: int, level: String) -> Dictionary:
	# Extract meaningful words from content
	var words = content.split(" ")
	var primary_word = "unknown"
	
	# Find the first meaningful word (more than 2 characters)
	for word in words:
		word = word.strip_edges().to_lower()
		if word.length() > 2 and word.is_valid_identifier():
			primary_word = word
			break
	
	# If no meaningful word found, use type + index
	if primary_word == "unknown":
		primary_word = type + "_" + str(index)
	
	# Generate STABLE grid position (FIX: organized layout)
	var position = _calculate_stable_grid_position(index, level)
	
	return {
		"id": level + "_" + type + "_" + str(index) + "_" + primary_word,
		"text": primary_word,
		"type": type,
		"index": index,
		"level": level,
		"position": position,
		"evolution_state": 0,
		"content_source": content,
		"creation_time": Time.get_unix_time_from_system()
	}

func _calculate_stable_grid_position(index: int, level: String) -> Vector3:
	# Create organized layout optimized for camera viewing (FIX: better visibility)
	var grid_width = 8  # 8 words across X axis
	var grid_depth = 4  # 4 words across Z axis (less depth for better visibility)
	var spacing_x = 4.0  # Space between words on X axis
	var spacing_z = 5.0  # More space on Z axis to avoid front/back overlap
	var base_height = 1.0  # Base height for words
	
	# Calculate grid coordinates
	var grid_x = index % grid_width
	var grid_z = index / grid_width
	
	# Convert to world position with centered grid
	var world_x = (grid_x - grid_width / 2.0 + 0.5) * spacing_x
	var world_z = (grid_z - grid_depth / 2.0 + 0.5) * spacing_z
	var world_y = base_height + (current_level_index * 0.3)  # Less height variation
	
	return Vector3(world_x, world_y, world_z)

func _generate_level_specific_words(level_name: String) -> Array:
	var level_words: Array = []
	
	# Generate words based on level characteristics
	match level_name:
		"Multiverses":
			level_words = _create_cosmic_words(["infinity", "possibility", "reality", "dimension", "multiverse", "cosmos", "eternal", "boundless"])
		"Universe":
			level_words = _create_cosmic_words(["space", "time", "matter", "energy", "gravity", "quantum", "void", "expansion"])
		"Galaxy":
			level_words = _create_cosmic_words(["stars", "nebula", "spiral", "gravity", "cluster", "orbit", "cosmic", "stellar"])
		"Star":
			level_words = _create_cosmic_words(["fusion", "light", "plasma", "radiation", "nova", "solar", "nuclear", "luminous"])
		"Planets":
			level_words = _create_cosmic_words(["world", "atmosphere", "surface", "orbit", "terrain", "biosphere", "geology", "climate"])
		_:
			level_words = _create_cosmic_words(["entity", "form", "essence", "structure", "pattern", "flow", "harmony", "balance"])
	
	return level_words

func _create_cosmic_words(word_list: Array) -> Array:
	var cosmic_words: Array = []
	var base_index = 20  # Start after point/wall words
	
	for i in range(word_list.size()):
		var word = word_list[i]
		var total_index = base_index + i
		
		# Use same stable grid system for cosmic words
		var position = _calculate_stable_grid_position(total_index, current_level_name)
		
		cosmic_words.append({
			"id": current_level_name + "_cosmic_" + str(i) + "_" + word,
			"text": word,
			"type": "cosmic",
			"index": i,
			"level": current_level_name,
			"position": position,
			"evolution_state": randi() % 3,  # Random initial evolution
			"content_source": "Generated cosmic word for " + current_level_name,
			"creation_time": Time.get_unix_time_from_system()
		})
	
	return cosmic_words

func _load_point_data_for_position(position: int) -> void:
	var point_key = current_level_name + "_point_" + str(position)
	var wall_key = current_level_name + "_wall_" + str(position)
	
	if point_files_cache.has(point_key):
		print("Point ", position, " data: ", point_files_cache[point_key].substr(0, 100), "...")
	
	if wall_files_cache.has(wall_key):
		print("Wall ", position, " data: ", wall_files_cache[wall_key].substr(0, 100), "...")

func _add_to_navigation_history(level_name: String) -> void:
	if navigation_history.size() == 0 or navigation_history[-1] != level_name:
		navigation_history.append(level_name)
		
		# Keep history to reasonable size
		if navigation_history.size() > 20:
			navigation_history.pop_front()

func get_level_data(level_name: String, data_type: String) -> String:
	var key = level_name + "_" + data_type
	if level_data_cache.has(key):
		return level_data_cache[key]
	return ""

func get_point_data(level_name: String, index: int) -> String:
	var key = level_name + "_point_" + str(index)
	if point_files_cache.has(key):
		return point_files_cache[key]
	return ""

func get_wall_data(level_name: String, index: int) -> String:
	var key = level_name + "_wall_" + str(index)
	if wall_files_cache.has(key):
		return wall_files_cache[key]
	return ""

# Debug and utility functions
func print_navigation_state() -> void:
	print("=== Akashic Navigation State ===")
	print("Current Level: ", current_level_name, " (", current_level_index, ")")
	print("Lateral Position: ", lateral_position)
	print("Can Navigate Up: ", can_navigate_up())
	print("Can Navigate Down: ", can_navigate_down())
	print("Navigation History: ", navigation_history)
	print("Cached Levels: ", level_data_cache.keys())
	print("================================")

func reset_navigation() -> void:
	current_level_index = 0
	current_level_name = "Multiverses"
	lateral_position = 0
	navigation_history.clear()
	navigation_history.append(current_level_name)
	navigation_changed.emit(current_level_name)
	print("Navigation reset to: ", current_level_name)
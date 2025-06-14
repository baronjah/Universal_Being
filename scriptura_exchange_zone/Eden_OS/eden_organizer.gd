extends Node

class_name EdenOrganizer

signal directory_cleaned(path, files_processed)
signal file_categorized(file_path, category)
signal dimensional_scan_completed(dimension, results)

# Core directory structure for Eden
const EDEN_ROOT_PATH = "D:/Eden"
const DIRECTORY_STRUCTURE = {
	"Pathways": {
		"Singularity": {},
		"Transcendence": {},
		"Evolution": {},
		"Reflection": {}
	},
	"Dimensions": {
		"D1_Foundation": {},
		"D2_Growth": {},
		"D3_Energy": {},
		"D4_Insight": {},
		"D5_Force": {},
		"D6_Vision": {},
		"D7_Wisdom": {},
		"D8_Transcendence": {},
		"D9_Unity": {}
	},
	"Entities": {
		"Thoughts": {},
		"Memories": {},
		"Concepts": {},
		"Essences": {},
		"Dreams": {},
		"Words": {},
		"Intentions": {},
		"Emotions": {},
		"Creations": {},
		"Presences": {}
	},
	"Cycles": {
		"Archives": {},
		"Current": {},
		"Projection": {}
	},
	"System": {
		"Config": {},
		"Logs": {},
		"Backup": {}
	}
}

# File categorization patterns
var categorization_patterns = {
	"word": ["*.word", "*.term", "*.dict", "*.vocab"],
	"concept": ["*.concept", "*.idea", "*.theory", "*.model"],
	"memory": ["*.memory", "*.recall", "*.record", "*.history"],
	"essence": ["*.essence", "*.core", "*.identity", "*.self"],
	"creation": ["*.creation", "*.manifest", "*.generate", "*.form"],
	"system": ["*.config", "*.log", "*.sys", "*.backup"]
}

var dimensional_color_system: DimensionalColorSystem
var astral_entity_system: AstralEntitySystem
var turn_cycle_manager: TurnCycleManager

func _ready():
	dimensional_color_system = DimensionalColorSystem.new()
	add_child(dimensional_color_system)
	
	# Try to locate other systems in the scene
	astral_entity_system = get_node_or_null("/root/AstralEntitySystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Create directory structure if it doesn't exist
	_ensure_directory_structure()

func _ensure_directory_structure():
	# Check if Eden root exists
	var dir = DirAccess.open("D:/")
	if not dir or not dir.dir_exists("Eden"):
		print("Creating Eden root directory")
		dir.make_dir("Eden")
	
	# Create the full directory structure
	_create_directories(EDEN_ROOT_PATH, DIRECTORY_STRUCTURE)

func _create_directories(base_path: String, structure: Dictionary):
	var dir = DirAccess.open(base_path)
	if not dir:
		print("Failed to open directory: " + base_path)
		return
	
	for dir_name in structure.keys():
		var path = base_path + "/" + dir_name
		if not dir.dir_exists(dir_name):
			print("Creating directory: " + path)
			dir.make_dir(dir_name)
		
		# Recursively create subdirectories
		if not structure[dir_name].is_empty():
			_create_directories(path, structure[dir_name])

func clean_directory(path: String = EDEN_ROOT_PATH) -> int:
	var dir = DirAccess.open(path)
	if not dir:
		print("Failed to open directory: " + path)
		return 0
	
	var files_processed = 0
	
	# Process all files in this directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir():
				# Recursively clean subdirectories
				files_processed += clean_directory(full_path)
			else:
				# Process and categorize the file
				if _process_file(full_path):
					files_processed += 1
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	emit_signal("directory_cleaned", path, files_processed)
	return files_processed

func _process_file(file_path: String) -> bool:
	# Determine the appropriate category for this file
	var category = _categorize_file(file_path)
	
	if category == "":
		return false
	
	# Get appropriate destination based on category
	var destination = _get_destination_for_category(category, file_path)
	
	if destination == "":
		return false
	
	# Move the file to its destination
	var dir = DirAccess.open("res://")
	if dir.file_exists(file_path):
		var file_name = file_path.get_file()
		var result = dir.copy(file_path, destination + "/" + file_name)
		
		if result == OK:
			# If copy succeeded, remove the original
			dir.remove(file_path)
			emit_signal("file_categorized", file_path, category)
			return true
	
	return false

func _categorize_file(file_path: String) -> String:
	var file_extension = file_path.get_extension().to_lower()
	
	# Check against known patterns
	for category in categorization_patterns:
		for pattern in categorization_patterns[category]:
			if pattern.ends_with(file_extension):
				return category
	
	# If no match in extension, try to determine by content analysis
	var content_category = _analyze_file_content(file_path)
	if content_category != "":
		return content_category
	
	# Default to no category
	return ""

func _analyze_file_content(file_path: String) -> String:
	# Simple content-based categorization
	if not FileAccess.file_exists(file_path):
		return ""
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return ""
	
	# Read up to first 1000 bytes for analysis
	var content = file.get_buffer(min(1000, file.get_length()))
	var text_content = content.get_string_from_utf8()
	
	# Simple keyword-based categorization
	var keyword_categories = {
		"word": ["word", "term", "language", "vocabulary", "dictionary"],
		"concept": ["concept", "idea", "theory", "framework", "model"],
		"memory": ["memory", "recall", "record", "history", "remember"],
		"essence": ["essence", "core", "identity", "self", "being"],
		"creation": ["creation", "manifest", "generate", "form", "create"],
		"system": ["config", "log", "system", "backup", "settings"]
	}
	
	for category in keyword_categories:
		for keyword in keyword_categories[category]:
			if text_content.to_lower().contains(keyword):
				return category
	
	return ""

func _get_destination_for_category(category: String, file_path: String) -> String:
	# Map categories to destination directories
	var category_destinations = {
		"word": EDEN_ROOT_PATH + "/Entities/Words",
		"concept": EDEN_ROOT_PATH + "/Entities/Concepts",
		"memory": EDEN_ROOT_PATH + "/Entities/Memories",
		"essence": EDEN_ROOT_PATH + "/Entities/Essences",
		"creation": EDEN_ROOT_PATH + "/Entities/Creations",
		"system": EDEN_ROOT_PATH + "/System"
	}
	
	# Check if we have a mapping for this category
	if category_destinations.has(category):
		return category_destinations[category]
	
	# For unknown categories, determine based on file attributes
	var file_stat = FileAccess.get_modified_time(file_path)
	
	# Newer files go to Current cycle, older to Archives
	if Time.get_unix_time_from_system() - file_stat < 604800:  # 7 days
		return EDEN_ROOT_PATH + "/Cycles/Current"
	else:
		return EDEN_ROOT_PATH + "/Cycles/Archives"

func assign_file_to_dimension(file_path: String, dimension: int) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	
	# Ensure dimension is valid (1-9)
	if dimension < 1 or dimension > 9:
		return false
	
	# Get the destination directory for this dimension
	var dimension_dir = EDEN_ROOT_PATH + "/Dimensions/D" + str(dimension) + "_"
	
	# Map dimension number to name
	var dimension_names = {
		1: "Foundation",
		2: "Growth",
		3: "Energy",
		4: "Insight",
		5: "Force",
		6: "Vision",
		7: "Wisdom",
		8: "Transcendence",
		9: "Unity"
	}
	
	dimension_dir += dimension_names[dimension]
	
	# Move the file to the dimension directory
	var dir = DirAccess.open("res://")
	if dir.file_exists(file_path):
		var file_name = file_path.get_file()
		var result = dir.copy(file_path, dimension_dir + "/" + file_name)
		
		if result == OK:
			# If copy succeeded, remove the original
			dir.remove(file_path)
			return true
	
	return false

func color_file_by_dimension(file_path: String, dimension: int) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	
	# Get the color for this dimension
	var color = dimensional_color_system.get_color_for_dimension(dimension)
	
	# We'll add color metadata to the file
	# Since we can't actually change the color of files directly in the OS,
	# we'll create a metadata file that contains color information
	
	var metadata_path = file_path + ".color"
	var color_hex = dimensional_color_system.get_color_value(color).to_html()
	
	var file = FileAccess.open(metadata_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify({
			"color": color_hex,
			"dimension": dimension,
			"name": DimensionalColorSystem.DimColor.keys()[color]
		}))
		file.close()
		return true
	
	return false

func scan_dimension(dimension: int, deep: bool = false) -> Dictionary:
	# Scan files in a specific dimension
	var dimension_dir = EDEN_ROOT_PATH + "/Dimensions/D" + str(dimension) + "_"
	
	# Map dimension number to name
	var dimension_names = {
		1: "Foundation",
		2: "Growth",
		3: "Energy",
		4: "Insight",
		5: "Force",
		6: "Vision",
		7: "Wisdom",
		8: "Transcendence",
		9: "Unity"
	}
	
	dimension_dir += dimension_names[dimension]
	
	var results = {
		"dimension": dimension,
		"name": dimension_names[dimension],
		"files": [],
		"entities": [],
		"color": dimensional_color_system.get_color_for_dimension(dimension)
	}
	
	var dir = DirAccess.open(dimension_dir)
	if not dir:
		return results
	
	# Scan all files in this dimension
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != ".." and not dir.current_is_dir():
			var full_path = dimension_dir + "/" + file_name
			
			# Ignore color metadata files
			if not file_name.ends_with(".color"):
				var file_info = {
					"name": file_name,
					"path": full_path,
					"size": FileAccess.get_file_as_bytes(full_path).size(),
					"modified": FileAccess.get_modified_time(full_path)
				}
				
				# For deep scan, try to analyze file content
				if deep:
					file_info["category"] = _categorize_file(full_path)
					
					if astral_entity_system:
						# Try to find or create a corresponding entity
						var entity_name = file_name.get_basename()
						var entity_type = AstralEntitySystem.EntityType.CONCEPT
						
						if file_info.has("category"):
							match file_info["category"]:
								"word":
									entity_type = AstralEntitySystem.EntityType.WORD
								"memory":
									entity_type = AstralEntitySystem.EntityType.MEMORY
								"essence":
									entity_type = AstralEntitySystem.EntityType.ESSENCE
								"creation":
									entity_type = AstralEntitySystem.EntityType.CREATION
						
						var entity_id = astral_entity_system.create_entity(entity_name, entity_type)
						var entity = astral_entity_system.get_entity(entity_id)
						
						if entity:
							entity.dimensional_presence.add_dimension(dimension, 1.0)
							entity.properties["file_path"] = full_path
							results["entities"].append(entity_id)
				
				results["files"].append(file_info)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	emit_signal("dimensional_scan_completed", dimension, results)
	return results

func process_file_by_turn(file_path: String) -> bool:
	if not turn_cycle_manager or not FileAccess.file_exists(file_path):
		return false
	
	# Get the current turn's color
	var current_turn = turn_cycle_manager.current_turn
	var current_color = turn_cycle_manager.turn_color_mapping[current_turn - 1]
	
	# Determine dimension from color
	var dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	# Assign the file to this dimension
	return assign_file_to_dimension(file_path, dimension)

func create_turn_specific_file(content: String, file_name: String) -> String:
	if not turn_cycle_manager:
		return ""
	
	# Get current turn and cycle information
	var current_turn = turn_cycle_manager.current_turn
	var total_cycles = turn_cycle_manager.total_cycles_completed
	
	# Create filename with turn and cycle information
	var full_file_name = "T" + str(current_turn) + "_C" + str(total_cycles) + "_" + file_name
	
	# Determine the appropriate directory based on turn's color
	var current_color = turn_cycle_manager.turn_color_mapping[current_turn - 1]
	var dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	var dimension_dir = EDEN_ROOT_PATH + "/Dimensions/D" + str(dimension) + "_"
	
	# Map dimension number to name
	var dimension_names = {
		1: "Foundation",
		2: "Growth",
		3: "Energy",
		4: "Insight",
		5: "Force",
		6: "Vision",
		7: "Wisdom",
		8: "Transcendence",
		9: "Unity"
	}
	
	dimension_dir += dimension_names[dimension]
	
	# Create the file
	var file_path = dimension_dir + "/" + full_file_name
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(content)
		file.close()
		
		# Add color metadata
		color_file_by_dimension(file_path, dimension)
		
		return file_path
	
	return ""

func create_dimensional_backup() -> bool:
	# Create a backup of the entire dimensional structure
	var backup_dir = EDEN_ROOT_PATH + "/System/Backup/Dimensions_" + str(Time.get_unix_time_from_system())
	
	# Create the backup directory
	var dir = DirAccess.open("res://")
	if dir.make_dir_recursive(backup_dir) != OK:
		return false
	
	# Copy all dimension directories
	for dimension in range(1, 10):
		var dimension_dir = EDEN_ROOT_PATH + "/Dimensions/D" + str(dimension) + "_"
		
		# Map dimension number to name
		var dimension_names = {
			1: "Foundation",
			2: "Growth",
			3: "Energy",
			4: "Insight",
			5: "Force",
			6: "Vision",
			7: "Wisdom",
			8: "Transcendence",
			9: "Unity"
		}
		
		dimension_dir += dimension_names[dimension]
		
		var target_dir = backup_dir + "/D" + str(dimension) + "_" + dimension_names[dimension]
		
		# Copy all files from the dimension
		_copy_directory_contents(dimension_dir, target_dir)
	
	return true

func _copy_directory_contents(source_dir: String, target_dir: String) -> bool:
	var dir = DirAccess.open("res://")
	if dir.make_dir_recursive(target_dir) != OK:
		return false
	
	var src_dir = DirAccess.open(source_dir)
	if not src_dir:
		return false
	
	# Copy all files
	src_dir.list_dir_begin()
	var file_name = src_dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var source_path = source_dir + "/" + file_name
			var target_path = target_dir + "/" + file_name
			
			if src_dir.current_is_dir():
				# Recursively copy subdirectories
				_copy_directory_contents(source_path, target_path)
			else:
				# Copy the file
				dir.copy(source_path, target_path)
		
		file_name = src_dir.get_next()
	
	src_dir.list_dir_end()
	return true
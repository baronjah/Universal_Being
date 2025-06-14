extends Node
class_name TripleDriveConnector

"""
TripleDriveConnector: System for connecting and organizing data across
three separate drive locations with dimensional synchronization and importance-based
data management for the Ethereal Engine.
"""

# Drive location constants
const DRIVE_LOCATIONS = {
	"C": "/mnt/c/Users/Percision 15/",
	"D": "/mnt/d/GodotEden/",
	"E": "/mnt/e/LuminusOS/"
}

# Signal declarations
signal drive_connected(drive_letter, status)
signal data_synchronized(source_drive, target_drive, file_count)
signal importance_sorted(drive_letter, category, file_count)

# Importance categories
const IMPORTANCE_CATEGORIES = {
	"CRITICAL": 5,    # Essential system files and core data
	"HIGH": 4,        # Important application files and user data
	"MEDIUM": 3,      # Regular application files
	"LOW": 2,         # Easily recoverable or cached data
	"ARCHIVE": 1      # Historical or rarely accessed data
}

# Data categories with dimension mappings
const DATA_CATEGORIES = {
	"ethereal_engine": {
		"importance": "CRITICAL",
		"dimension": 12,  # Transcendence
		"file_types": ["*.gd", "*.tscn", "*.tres", "*.res", "*.shader"]
	},
	"game_systems": {
		"importance": "HIGH",
		"dimension": 10,  # Manifestation
		"file_types": ["*.gd", "*.tscn", "*.cs", "*.json"]
	},
	"ui_components": {
		"importance": "MEDIUM", 
		"dimension": 8,   # Reflection
		"file_types": ["*.tscn", "*.gd", "*.tres", "*.material"]
	},
	"assets": {
		"importance": "MEDIUM",
		"dimension": 6,   # Balance
		"file_types": ["*.png", "*.jpeg", "*.ogg", "*.wav", "*.mp3", "*.obj", "*.glb"]
	},
	"docs": {
		"importance": "LOW",
		"dimension": 4,   # Stability
		"file_types": ["*.md", "*.txt", "*.pdf", "*.html"]
	},
	"archive": {
		"importance": "ARCHIVE",
		"dimension": 2,   # Duality
		"file_types": ["*.zip", "*.tar.gz", "*.bak", "*.old"]
	}
}

# Drive connection status
var drive_status = {
	"C": false,
	"D": false, 
	"E": false
}

# Runtime variables
var connected_drives = []
var active_sync_paths = {}
var dimensional_bridges = {}
var file_registry = {}
var importance_index = {}

# Initialization
func _ready():
	# Check initial drive connections
	for drive in DRIVE_LOCATIONS.keys():
		check_drive_connection(drive)
	
	# Set up dimensional bridges between drives
	setup_dimensional_bridges()
	
	print("Triple Drive Connector initialized")
	print("Connected drives: ", connected_drives)

# Check if a drive is connected
func check_drive_connection(drive_letter):
	var path = DRIVE_LOCATIONS[drive_letter]
	var dir = DirAccess.open(path)
	
	if dir:
		drive_status[drive_letter] = true
		if not drive_letter in connected_drives:
			connected_drives.append(drive_letter)
		emit_signal("drive_connected", drive_letter, true)
		print("Drive %s connected at %s" % [drive_letter, path])
		return true
	else:
		drive_status[drive_letter] = false
		connected_drives.erase(drive_letter)
		emit_signal("drive_connected", drive_letter, false)
		print("Drive %s not connected at %s" % [drive_letter, path])
		return false

# Set up dimensional bridges between drives
func setup_dimensional_bridges():
	dimensional_bridges = {}
	
	# Create bridges between each pair of connected drives
	for i in range(connected_drives.size()):
		for j in range(i + 1, connected_drives.size()):
			var drive1 = connected_drives[i]
			var drive2 = connected_drives[j]
			
			var bridge_id = "%s-%s" % [drive1, drive2]
			dimensional_bridges[bridge_id] = {
				"source": drive1,
				"target": drive2,
				"active": true,
				"dimension": (i + j + 1) % 12 + 1, # Dimensional assignment
				"sync_paths": {},
				"last_sync": 0
			}
			
			print("Dimensional bridge created: %s (Dimension: %d)" % 
				[bridge_id, dimensional_bridges[bridge_id].dimension])

# Connect a directory path between two drives
func connect_paths(source_drive, source_path, target_drive, target_path):
	if not source_drive in connected_drives or not target_drive in connected_drives:
		print("Error: Cannot connect paths - one or more drives not connected")
		return false
	
	# Create full paths
	var full_source_path = DRIVE_LOCATIONS[source_drive] + source_path
	var full_target_path = DRIVE_LOCATIONS[target_drive] + target_path
	
	# Check if directories exist
	var source_dir = DirAccess.open(full_source_path)
	if not source_dir:
		print("Error: Source path does not exist: %s" % full_source_path)
		# Try to create it
		var parent_dir = full_source_path.get_base_dir()
		var parent = DirAccess.open(parent_dir)
		if parent:
			parent.make_dir(full_source_path.get_file())
			print("Created source directory: %s" % full_source_path)
		else:
			return false
	
	var target_dir = DirAccess.open(full_target_path)
	if not target_dir:
		print("Error: Target path does not exist: %s" % full_target_path)
		# Try to create it
		var parent_dir = full_target_path.get_base_dir()
		var parent = DirAccess.open(parent_dir)
		if parent:
			parent.make_dir(full_target_path.get_file())
			print("Created target directory: %s" % full_target_path)
		else:
			return false
	
	# Register the path connection in the appropriate bridge
	var bridge_id = "%s-%s" % [source_drive, target_drive]
	if bridge_id in dimensional_bridges:
		dimensional_bridges[bridge_id].sync_paths[source_path] = target_path
	else:
		bridge_id = "%s-%s" % [target_drive, source_drive] # Try the reverse order
		if bridge_id in dimensional_bridges:
			dimensional_bridges[bridge_id].sync_paths[target_path] = source_path
	
	print("Connected paths: %s on %s → %s on %s" % 
		[source_path, source_drive, target_path, target_drive])
	
	# Add to active sync paths
	var sync_key = "%s:%s-%s:%s" % [source_drive, source_path, target_drive, target_path]
	active_sync_paths[sync_key] = {
		"source_drive": source_drive,
		"source_path": source_path,
		"target_drive": target_drive,
		"target_path": target_path,
		"last_sync": 0,
		"auto_sync": true
	}
	
	return true

# Synchronize data between two connected paths
func synchronize_paths(source_drive, source_path, target_drive, target_path):
	# Create full paths
	var full_source_path = DRIVE_LOCATIONS[source_drive] + source_path
	var full_target_path = DRIVE_LOCATIONS[target_drive] + target_path
	
	print("Synchronizing: %s → %s" % [full_source_path, full_target_path])
	
	# Check if directories exist
	var source_dir = DirAccess.open(full_source_path)
	if not source_dir:
		print("Error: Source path does not exist: %s" % full_source_path)
		return false
	
	var target_dir = DirAccess.open(full_target_path)
	if not target_dir:
		print("Error: Target path does not exist: %s" % full_target_path)
		return false
	
	# Get list of files in source directory
	var files = []
	source_dir.list_dir_begin()
	var file_name = source_dir.get_next()
	
	while file_name != "":
		if not source_dir.current_is_dir() and not file_name.begins_with("."):
			files.append(file_name)
		file_name = source_dir.get_next()
	
	source_dir.list_dir_end()
	
	# Copy files to target directory
	var copied_count = 0
	for file in files:
		var source_file = full_source_path.path_join(file)
		var target_file = full_target_path.path_join(file)
		
		# Skip if the target file is newer
		if FileAccess.file_exists(target_file):
			var source_time = FileAccess.get_modified_time(source_file)
			var target_time = FileAccess.get_modified_time(target_file)
			
			if target_time >= source_time:
				continue
		
		# Copy the file
		var err = FileAccess.copy(source_file, target_file)
		if err == OK:
			copied_count += 1
			print("Copied: %s → %s" % [source_file, target_file])
		else:
			print("Error copying file: %s" % file)
	
	# Update sync time
	var sync_key = "%s:%s-%s:%s" % [source_drive, source_path, target_drive, target_path]
	if sync_key in active_sync_paths:
		active_sync_paths[sync_key].last_sync = Time.get_unix_time_from_system()
	
	# Emit signal
	emit_signal("data_synchronized", source_drive, target_drive, copied_count)
	
	print("Synchronization complete. Copied %d files." % copied_count)
	return true

# Organize files by importance category
func organize_by_importance(drive_letter, root_path=""):
	if not drive_letter in connected_drives:
		print("Error: Drive %s not connected" % drive_letter)
		return false
	
	var base_path = DRIVE_LOCATIONS[drive_letter]
	var full_path = base_path
	
	if root_path != "":
		full_path = base_path + root_path
	
	print("Organizing files by importance on drive %s at %s" % [drive_letter, full_path])
	
	# Create importance directories if they don't exist
	for category in IMPORTANCE_CATEGORIES.keys():
		var category_path = full_path.path_join(category.to_lower())
		var dir = DirAccess.open(category_path)
		
		if not dir:
			# Create the directory
			var parent_dir = DirAccess.open(full_path)
			if parent_dir:
				parent_dir.make_dir(category.to_lower())
				print("Created directory: %s" % category_path)
	
	# Scan files and categorize by importance
	var categorized_files = {
		"CRITICAL": [],
		"HIGH": [],
		"MEDIUM": [],
		"LOW": [],
		"ARCHIVE": []
	}
	
	# Find files and determine their importance
	scan_directory_for_importance(full_path, categorized_files, drive_letter)
	
	# Move files to their importance directories
	var moved_count = 0
	for category in categorized_files.keys():
		var category_path = full_path.path_join(category.to_lower())
		
		for file_path in categorized_files[category]:
			var file_name = file_path.get_file()
			var target_path = category_path.path_join(file_name)
			
			# Skip if the file is already in the correct directory
			if file_path.begins_with(category_path):
				continue
			
			# Move the file
			var dir = DirAccess.open(file_path.get_base_dir())
			if dir:
				var err = dir.rename(file_path, target_path)
				if err == OK:
					moved_count += 1
					print("Moved: %s → %s" % [file_path, target_path])
				else:
					print("Error moving file: %s" % file_path)
		
		emit_signal("importance_sorted", drive_letter, category, categorized_files[category].size())
		print("Category %s: %d files" % [category, categorized_files[category].size()])
	
	print("Organization complete. Moved %d files." % moved_count)
	return true

# Scan a directory recursively and categorize files by importance
func scan_directory_for_importance(dir_path, categorized_files, drive_letter):
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != ".." and not file_name.begins_with("."):
			var full_path = dir_path.path_join(file_name)
			
			if dir.current_is_dir():
				# Skip importance category directories
				var is_category_dir = false
				for category in IMPORTANCE_CATEGORIES.keys():
					if file_name.to_upper() == category:
						is_category_dir = true
						break
				
				if not is_category_dir:
					scan_directory_for_importance(full_path, categorized_files, drive_letter)
			else:
				# Determine file importance
				var importance = determine_file_importance(full_path)
				categorized_files[importance].append(full_path)
				
				# Register file in importance index
				if not importance in importance_index:
					importance_index[importance] = {}
				
				importance_index[importance][full_path] = {
					"drive": drive_letter,
					"path": full_path.replace(DRIVE_LOCATIONS[drive_letter], ""),
					"size": FileAccess.file_exists(full_path) ? FileAccess.get_file_as_bytes(full_path).size() : 0,
					"modified": FileAccess.get_modified_time(full_path)
				}
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# Determine the importance category of a file
func determine_file_importance(file_path):
	var extension = file_path.get_extension().to_lower()
	
	# Check each data category
	for category_name in DATA_CATEGORIES.keys():
		var category = DATA_CATEGORIES[category_name]
		
		for pattern in category.file_types:
			if pattern == "*." + extension:
				return category.importance
	
	# Default importance based on creation/modification time
	var mod_time = FileAccess.get_modified_time(file_path)
	var current_time = Time.get_unix_time_from_system()
	var age_days = (current_time - mod_time) / 86400
	
	if age_days < 7:
		return "HIGH"
	elif age_days < 30:
		return "MEDIUM"
	elif age_days < 180:
		return "LOW"
	else:
		return "ARCHIVE"

# Create a symbolic dimension bridge between two directories
func create_dimensional_bridge(source_drive, source_path, target_drive, target_path, dimension):
	if not source_drive in connected_drives or not target_drive in connected_drives:
		print("Error: Cannot create dimensional bridge - one or more drives not connected")
		return false
	
	# Create full paths
	var full_source_path = DRIVE_LOCATIONS[source_drive] + source_path
	var full_target_path = DRIVE_LOCATIONS[target_drive] + target_path
	
	print("Creating dimensional bridge (dimension %d): %s → %s" % 
		[dimension, full_source_path, full_target_path])
	
	# Check if directories exist
	var source_dir = DirAccess.open(full_source_path)
	if not source_dir:
		print("Error: Source path does not exist: %s" % full_source_path)
		return false
	
	var target_dir = DirAccess.open(full_target_path)
	if not target_dir:
		print("Error: Target path does not exist: %s" % full_target_path)
		return false
	
	# Create metadata dimension file in both directories
	var dimension_name = ""
	if dimension >= 1 and dimension <= 12:
		dimension_name = ["GENESIS", "DUALITY", "EXPRESSION", "STABILITY",
			"TRANSFORMATION", "BALANCE", "ILLUMINATION", "REFLECTION",
			"HARMONY", "MANIFESTATION", "INTEGRATION", "TRANSCENDENCE"][dimension-1]
	
	var metadata = {
		"dimension": dimension,
		"dimension_name": dimension_name,
		"source_drive": source_drive,
		"source_path": source_path,
		"target_drive": target_drive,
		"target_path": target_path,
		"created_time": Time.get_unix_time_from_system(),
		"bridge_symbol": get_dimension_symbol(dimension)
	}
	
	# Write metadata to source directory
	var source_meta_path = full_source_path.path_join(".dimensional_bridge.json")
	var source_file = FileAccess.open(source_meta_path, FileAccess.WRITE)
	if source_file:
		source_file.store_string(JSON.stringify(metadata, "  "))
		source_file.close()
	
	# Write metadata to target directory
	var target_meta_path = full_target_path.path_join(".dimensional_bridge.json")
	var target_file = FileAccess.open(target_meta_path, FileAccess.WRITE)
	if target_file:
		target_file.store_string(JSON.stringify(metadata, "  "))
		target_file.close()
	
	# Create a .bridge file with the dimensional symbol
	var bridge_content = """
DIMENSIONAL BRIDGE: %s

Source: %s:%s
Target: %s:%s
Dimension: %d - %s
Symbol: %s

This file represents a dimensional bridge in the Ethereal Engine
system. Files across this bridge are synchronized and share the
same dimensional energy.

Created: %s
"""

	var timestamp = Time.get_datetime_string_from_system()
	bridge_content = bridge_content % [
		metadata.bridge_symbol,
		source_drive, source_path,
		target_drive, target_path,
		dimension, dimension_name,
		metadata.bridge_symbol,
		timestamp
	]
	
	var source_bridge_path = full_source_path.path_join(".bridge")
	var source_bridge_file = FileAccess.open(source_bridge_path, FileAccess.WRITE)
	if source_bridge_file:
		source_bridge_file.store_string(bridge_content)
		source_bridge_file.close()
	
	var target_bridge_path = full_target_path.path_join(".bridge")
	var target_bridge_file = FileAccess.open(target_bridge_path, FileAccess.WRITE)
	if target_bridge_file:
		target_bridge_file.store_string(bridge_content)
		target_bridge_file.close()
	
	print("Dimensional bridge created with symbol: %s" % metadata.bridge_symbol)
	return true

# Get a symbol representing a dimension
func get_dimension_symbol(dimension):
	var symbols = ["⬡", "◉", "⚹", "♦", "∞", "△", "◇", "⚛", "⟡", "⦿", "⧉", "✧"]
	
	if dimension >= 1 and dimension <= 12:
		return symbols[dimension - 1]
	else:
		return "○"

# Initialize the standard LuminusOS directory structure on a drive
func initialize_luminusos_structure(drive_letter):
	if not drive_letter in connected_drives:
		print("Error: Drive %s not connected" % drive_letter)
		return false
	
	var base_path = DRIVE_LOCATIONS[drive_letter]
	print("Initializing LuminusOS directory structure on drive %s" % drive_letter)
	
	# Define the directory structure with dimensional mappings
	var structure = {
		"LuminusOS": {
			"dimension": 12,  # Transcendence
			"subdirs": {
				"core": {
					"dimension": 10,  # Manifestation
					"subdirs": {
						"ethereal_engine": {"dimension": 12},  # Transcendence
						"command_system": {"dimension": 8},    # Reflection
						"data_system": {"dimension": 6},       # Balance
						"memory_system": {"dimension": 4}      # Stability
					}
				},
				"modules": {
					"dimension": 9,  # Harmony
					"subdirs": {
						"ethereal_engine": {"dimension": 12},  # Transcendence
						"turn_system": {"dimension": 7},       # Illumination
						"word_system": {"dimension": 5},       # Transformation
						"blessing_system": {"dimension": 3}    # Expression
					}
				},
				"game": {
					"dimension": 8,  # Reflection
					"subdirs": {
						"eden_may": {"dimension": 11},  # Integration
						"divine_word": {"dimension": 9},  # Harmony
						"memory_realm": {"dimension": 5}  # Transformation
					}
				},
				"docs": {
					"dimension": 3,  # Expression
					"subdirs": {
						"guides": {"dimension": 2},  # Duality
						"reference": {"dimension": 4},  # Stability
						"examples": {"dimension": 6}  # Balance
					}
				},
				"assets": {
					"dimension": 6,  # Balance
					"subdirs": {
						"icons": {"dimension": 7},  # Illumination
						"sounds": {"dimension": 3},  # Expression
						"models": {"dimension": 5},  # Transformation
						"textures": {"dimension": 4}  # Stability
					}
				}
			}
		}
	}
	
	# Create the directory structure
	var created_count = create_directory_structure(base_path, structure)
	
	print("LuminusOS structure initialized on drive %s. Created %d directories." % 
		[drive_letter, created_count])
	return true

# Recursively create a directory structure
func create_directory_structure(base_path, structure, count=0):
	var created_count = count
	
	for dir_name in structure.keys():
		var dir_path = base_path.path_join(dir_name)
		var dir = DirAccess.open(dir_path)
		
		if not dir:
			# Create the directory
			var parent_dir = DirAccess.open(base_path)
			if parent_dir:
				parent_dir.make_dir(dir_name)
				print("Created directory: %s" % dir_path)
				created_count += 1
				
				# If this directory has a dimension, create a dimension marker
				if "dimension" in structure[dir_name]:
					var dimension = structure[dir_name].dimension
					create_dimension_marker(dir_path, dimension)
		
		# Create subdirectories
		if "subdirs" in structure[dir_name]:
			created_count = create_directory_structure(
				dir_path, 
				structure[dir_name].subdirs, 
				created_count
			)
	
	return created_count

# Create a dimension marker file in a directory
func create_dimension_marker(dir_path, dimension):
	var dimension_name = ""
	if dimension >= 1 and dimension <= 12:
		dimension_name = ["GENESIS", "DUALITY", "EXPRESSION", "STABILITY",
			"TRANSFORMATION", "BALANCE", "ILLUMINATION", "REFLECTION",
			"HARMONY", "MANIFESTATION", "INTEGRATION", "TRANSCENDENCE"][dimension-1]
	
	var symbol = get_dimension_symbol(dimension)
	
	var content = """
DIMENSION: %d - %s
SYMBOL: %s

This directory exists in dimension %d of the LuminusOS Ethereal Engine.
Files in this directory resonate with the %s dimensional energy.

Created: %s
"""

	var timestamp = Time.get_datetime_string_from_system()
	content = content % [
		dimension, dimension_name,
		symbol,
		dimension, dimension_name.to_lower(),
		timestamp
	]
	
	var marker_path = dir_path.path_join(".dimension")
	var file = FileAccess.open(marker_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("Created dimension marker in %s: Dimension %d (%s)" % 
			[dir_path, dimension, dimension_name])

# List all connected drives and their status
func list_drives():
	var drive_info = []
	
	for drive in DRIVE_LOCATIONS.keys():
		drive_info.append({
			"letter": drive,
			"path": DRIVE_LOCATIONS[drive],
			"connected": drive_status[drive],
			"free_space": get_drive_free_space(drive)
		})
	
	return drive_info

# Get approximate free space on a drive
func get_drive_free_space(drive_letter):
	if not drive_letter in connected_drives:
		return 0
		
	# Simplified free space check
	var path = DRIVE_LOCATIONS[drive_letter]
	var tmp_file_path = path.path_join(".space_check_tmp")
	
	# Try to write a small file
	var file = FileAccess.open(tmp_file_path, FileAccess.WRITE)
	if not file:
		return 0
		
	# Write some data
	var test_size = 1024 * 1024  # 1 MB
	var data = PackedByteArray()
	data.resize(test_size)
	
	file.store_buffer(data)
	file.close()
	
	# Get file size
	var size = 0
	if FileAccess.file_exists(tmp_file_path):
		size = FileAccess.get_file_as_bytes(tmp_file_path).size()
		# Delete the temporary file
		var dir = DirAccess.open(path)
		if dir:
			dir.remove(tmp_file_path.get_file())
	
	# If we could write 1 MB, assume at least 1 GB free
	# This is a very simplified check
	if size >= test_size:
		return 1024 * 1024 * 1024  # 1 GB
	else:
		return size * 1000  # Approximate based on what we could write
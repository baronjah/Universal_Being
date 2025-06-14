extends Node
# Godot File Automator
# Bridges Windows folders and files with Godot project
# Automatically processes files for use in Godot projects

# Configuration - Change these to match your system
const WINDOWS_SOURCE_DIR = "C:/Users/Percision 15/12_turns_system"
const GODOT_PROJECT_DIR = "res://"

# File extensions to monitor
const MONITORED_EXTENSIONS = [".txt", ".md", ".gd", ".tscn", ".json", ".csv"]

# Initialization 
func _ready():
	print("Godot File Automator initialized")
	print("Monitoring source directory: " + WINDOWS_SOURCE_DIR)
	print("Target Godot directory: " + GODOT_PROJECT_DIR)
	
	# Ensure the required directories exist
	_ensure_directories()
	
	# Initial scan to display what we're monitoring
	var initial_files = scan_source_directory()
	print("Found " + str(initial_files.size()) + " files to monitor")
	
	# Set up a timer to check for changes periodically
	var timer = Timer.new()
	timer.wait_time = 5.0  # Check every 5 seconds
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

# Ensure required directories exist
func _ensure_directories():
	# Convert Windows path to a path format that DirAccess can use
	var unix_path = WINDOWS_SOURCE_DIR.replace("C:/", "/mnt/c/").replace("\\", "/")
	
	# Check if directory exists
	if not DirAccess.dir_exists_absolute(unix_path):
		print("WARNING: Source directory does not exist: " + unix_path)
		return
		
	# Create Godot directories if they don't exist
	var godot_data_dir = GODOT_PROJECT_DIR + "imported_data"
	if not DirAccess.dir_exists_absolute(godot_data_dir):
		DirAccess.make_dir_recursive_absolute(godot_data_dir)
		print("Created directory: " + godot_data_dir)

# Timer callback to check for file changes
func _on_timer_timeout():
	print("Checking for file changes...")
	var files = scan_source_directory()
	
	# Check for changes and process files
	for file_path in files:
		var modified_time = FileAccess.get_modified_time(file_path)
		
		# Get the last stored modification time from metadata
		var prev_modified_time = _get_file_metadata(file_path, "last_modified", 0)
		
		if modified_time > prev_modified_time:
			print("Changes detected in file: " + file_path)
			process_file(file_path)
			
			# Update metadata
			_set_file_metadata(file_path, "last_modified", modified_time)

# Scan the source directory for files to monitor
func scan_source_directory():
	var files = []
	
	# Convert Windows path to a path format that DirAccess can use
	var unix_path = WINDOWS_SOURCE_DIR.replace("C:/", "/mnt/c/").replace("\\", "/")
	
	# Process all files in the directory recursively
	_scan_directory_recursive(unix_path, files)
	
	return files

# Recursively scan directories for files with monitored extensions
func _scan_directory_recursive(path, files):
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Skip . and .. directories
			if file_name != "." and file_name != "..":
				var full_path = path.path_join(file_name)
				
				if dir.current_is_dir():
					# Recursively scan subdirectories
					_scan_directory_recursive(full_path, files)
				else:
					# Check if the file has a monitored extension
					for ext in MONITORED_EXTENSIONS:
						if file_name.ends_with(ext):
							files.append(full_path)
							break
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + path)

# Process a file based on its type
func process_file(file_path):
	print("Processing file: " + file_path)
	
	# Determine file type based on extension
	var extension = file_path.get_extension().to_lower()
	
	match extension:
		"txt", "md":
			_process_text_file(file_path)
		"gd":
			_process_godot_script(file_path)
		"json", "csv":
			_process_data_file(file_path)
		"tscn":
			_process_scene_file(file_path)
		_:
			print("Unsupported file type: " + extension)

# Process text files (txt, md)
func _process_text_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Generate a Godot-friendly file name
		var file_name = file_path.get_file()
		var godot_path = GODOT_PROJECT_DIR + "imported_data/" + file_name
		
		# Save to Godot project
		var godot_file = FileAccess.open(godot_path, FileAccess.WRITE)
		if godot_file:
			godot_file.store_string(content)
			print("File imported to Godot: " + godot_path)
		else:
			print("Failed to write to Godot file: " + godot_path)

# Process Godot script files (gd)
func _process_godot_script(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Generate a Godot-friendly file name
		var file_name = file_path.get_file()
		var godot_path = GODOT_PROJECT_DIR + "imported_scripts/" + file_name
		
		# Ensure the scripts directory exists
		if not DirAccess.dir_exists_absolute(GODOT_PROJECT_DIR + "imported_scripts"):
			DirAccess.make_dir_recursive_absolute(GODOT_PROJECT_DIR + "imported_scripts")
		
		# Save to Godot project
		var godot_file = FileAccess.open(godot_path, FileAccess.WRITE)
		if godot_file:
			godot_file.store_string(content)
			print("Script imported to Godot: " + godot_path)
		else:
			print("Failed to write to Godot script: " + godot_path)

# Process data files (json, csv)
func _process_data_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Generate a Godot-friendly file name
		var file_name = file_path.get_file()
		var godot_path = GODOT_PROJECT_DIR + "imported_data/" + file_name
		
		# Ensure the data directory exists
		if not DirAccess.dir_exists_absolute(GODOT_PROJECT_DIR + "imported_data"):
			DirAccess.make_dir_recursive_absolute(GODOT_PROJECT_DIR + "imported_data")
		
		# Save to Godot project
		var godot_file = FileAccess.open(godot_path, FileAccess.WRITE)
		if godot_file:
			godot_file.store_string(content)
			print("Data file imported to Godot: " + godot_path)
		else:
			print("Failed to write to Godot data file: " + godot_path)
		
		# If it's a JSON file, try to parse it
		if file_path.ends_with(".json"):
			_parse_json_file(godot_path)

# Process scene files (tscn)
func _process_scene_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Generate a Godot-friendly file name
		var file_name = file_path.get_file()
		var godot_path = GODOT_PROJECT_DIR + "imported_scenes/" + file_name
		
		# Ensure the scenes directory exists
		if not DirAccess.dir_exists_absolute(GODOT_PROJECT_DIR + "imported_scenes"):
			DirAccess.make_dir_recursive_absolute(GODOT_PROJECT_DIR + "imported_scenes")
		
		# Save to Godot project
		var godot_file = FileAccess.open(godot_path, FileAccess.WRITE)
		if godot_file:
			godot_file.store_string(content)
			print("Scene imported to Godot: " + godot_path)
		else:
			print("Failed to write to Godot scene: " + godot_path)

# Parse a JSON file and create a Resource
func _parse_json_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		
		if error == OK:
			var data = json.data
			print("JSON parsed successfully: " + str(data))
			
			# Create a resource from the JSON data
			var resource = _create_resource_from_json(data, file_path.get_file().get_basename())
			
			# Save the resource
			if resource:
				var resource_path = GODOT_PROJECT_DIR + "imported_resources/" + file_path.get_file().get_basename() + ".tres"
				
				# Ensure the resources directory exists
				if not DirAccess.dir_exists_absolute(GODOT_PROJECT_DIR + "imported_resources"):
					DirAccess.make_dir_recursive_absolute(GODOT_PROJECT_DIR + "imported_resources")
				
				var error = ResourceSaver.save(resource, resource_path)
				if error == OK:
					print("Resource saved: " + resource_path)
				else:
					print("Failed to save resource: " + str(error))
		else:
			print("JSON parse error: " + str(error) + " at line " + str(json.get_error_line()))

# Create a Resource from JSON data
func _create_resource_from_json(json_data, resource_name):
	# Create a custom resource
	var resource = Resource.new()
	resource.resource_name = resource_name
	
	# Store the JSON data as properties in the resource
	for key in json_data.keys():
		if json_data[key] is Dictionary or json_data[key] is Array:
			# For complex types, convert to JSON string
			resource.set_meta(key, JSON.stringify(json_data[key]))
		else:
			# For simple types, store directly
			resource.set_meta(key, json_data[key])
	
	return resource

# Helper function to get file metadata
func _get_file_metadata(file_path, key, default_value):
	var metadata_path = GODOT_PROJECT_DIR + "imported_metadata.json"
	var metadata = {}
	
	# Load existing metadata if it exists
	if FileAccess.file_exists(metadata_path):
		var file = FileAccess.open(metadata_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(content)
			
			if error == OK:
				metadata = json.data
	
	# Create an entry for this file if it doesn't exist
	if not metadata.has(file_path):
		metadata[file_path] = {}
	
	# Return the requested value or the default if not found
	if metadata[file_path].has(key):
		return metadata[file_path][key]
	else:
		return default_value

# Helper function to set file metadata
func _set_file_metadata(file_path, key, value):
	var metadata_path = GODOT_PROJECT_DIR + "imported_metadata.json"
	var metadata = {}
	
	# Load existing metadata if it exists
	if FileAccess.file_exists(metadata_path):
		var file = FileAccess.open(metadata_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(content)
			
			if error == OK:
				metadata = json.data
	
	# Create an entry for this file if it doesn't exist
	if not metadata.has(file_path):
		metadata[file_path] = {}
	
	# Set the value
	metadata[file_path][key] = value
	
	# Save the updated metadata
	var file = FileAccess.open(metadata_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(metadata, "  "))
extends Node
class_name AkashicDatabaseIntegrator

# This class integrates the Akashic Records with JSH databases
# It handles automatic splitting and organization of data

# === References ===
var akashic_records_manager = null
var jsh_data_splitter = null
var jsh_records_system = null
var jsh_database_system = null

# === Configuration ===
var config = {
	"auto_split_threshold": 100, # Number of entries before splitting
	"max_file_size_kb": 500,     # Max file size before splitting in KB
	"base_data_path": "user://akashic_records/data/",
	"check_interval": 30.0       # Seconds between split checks
}

# === Status ===
var is_initialized = false
var dictionary_stats = {
	"total_words": 0,
	"total_files": 0,
	"total_size_kb": 0,
	"splits_performed": 0
}

# === File Tracking ===
var file_registry = {}
var pending_splits = []
var last_check_time = 0.0

# === Signals ===
signal database_split(original_file, new_files)
signal database_merged(files, merged_file)
signal file_size_warning(file_path, size_kb)

# Initialize the integrator
func initialize(records_manager, data_splitter, records_system, database_system) -> bool:
	if is_initialized:
		return true
		
	print("Initializing Akashic Database Integrator...")
	
	# Set references
	akashic_records_manager = records_manager
	jsh_data_splitter = data_splitter
	jsh_records_system = records_system
	jsh_database_system = database_system
	
	# Create base directories if they don't exist
	_ensure_directories()
	
	# Initialize registry
	_initialize_registry()
	
	# Start timer
	var timer = Timer.new()
	timer.name = "CheckTimer"
	timer.wait_time = config.check_interval
	timer.autostart = true
	timer.timeout.connect(Callable(self, "_on_check_timer_timeout"))
	add_child(timer)
	
	is_initialized = true
	print("Akashic Database Integrator initialized")
	
	return true

# Create base directories
func _ensure_directories() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("akashic_records"):
			dir.make_dir("akashic_records")
			
		if not dir.dir_exists("akashic_records/data"):
			dir.make_dir("akashic_records/data")
			
		if not dir.dir_exists("akashic_records/data/words"):
			dir.make_dir("akashic_records/data/words")
			
		if not dir.dir_exists("akashic_records/data/entities"):
			dir.make_dir("akashic_records/data/entities")
			
		if not dir.dir_exists("akashic_records/data/zones"):
			dir.make_dir("akashic_records/data/zones")
	else:
		print("ERROR: Could not access user directory")

# Initialize file registry
func _initialize_registry() -> void:
	# Reset registry
	file_registry = {
		"words": {},
		"entities": {},
		"zones": {}
	}
	
	# Scan directories for existing files
	_scan_directory("user://akashic_records/data/words", "words")
	_scan_directory("user://akashic_records/data/entities", "entities")
	_scan_directory("user://akashic_records/data/zones", "zones")
	
	print("File registry initialized: " + str(dictionary_stats.total_files) + " files")

# Scan directory for files
func _scan_directory(path: String, category: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				# Add to registry
				var file_path = path + "/" + file_name
				var file_info = {
					"path": file_path,
					"size": _get_file_size(file_path),
					"last_modified": _get_file_modification_time(file_path),
					"entries": _count_entries(file_path),
					"category": category,
					"split_from": "",
					"children": []
				}
				
				file_registry[category][file_name] = file_info
				dictionary_stats.total_files += 1
				dictionary_stats.total_size_kb += file_info.size
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("ERROR: Could not open directory: " + path)

# Get file size in KB
func _get_file_size(path: String) -> float:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var size_bytes = file.get_length()
		return size_bytes / 1024.0
	return 0.0

# Get file modification time
func _get_file_modification_time(path: String) -> int:
	return FileAccess.get_modified_time(path)

# Count entries in a JSON file
func _count_entries(path: String) -> int:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			if data is Dictionary and data.has("entries"):
				return data.entries.size()
	
	return 0

# Check for files that need splitting
func check_for_splits() -> void:
	last_check_time = Time.get_ticks_msec()
	
	# Check word dictionary first
	if akashic_records_manager:
		var stats = akashic_records_manager.get_dictionary_stats()
		if stats.has("total_words"):
			dictionary_stats.total_words = stats.total_words
		
		# Check if root dictionary needs splitting
		_check_dictionary_for_split()
	
	# Check file registry for size-based splits
	for category in file_registry:
		for file_name in file_registry[category]:
			var file_info = file_registry[category][file_name]
			
			# Check size threshold
			if file_info.size > config.max_file_size_kb:
				_add_file_to_split_queue(file_info)
			
			# Check entry count threshold
			if file_info.entries > config.auto_split_threshold:
				_add_file_to_split_queue(file_info)
	
	# Process pending splits
	if pending_splits.size() > 0:
		_process_splits()

# Check if the main dictionary needs splitting
func _check_dictionary_for_split() -> void:
	if akashic_records_manager and jsh_data_splitter:
		# Get dictionary info
		var root_dict = akashic_records_manager.dynamic_dictionary
		if root_dict and root_dict.get_word_count() > config.auto_split_threshold:
			print("Dictionary reaching split threshold: " + str(root_dict.get_word_count()) + " words")
			
			# Use existing dictionary splitter if available
			var dictionary_splitter = akashic_records_manager.dictionary_splitter
			if dictionary_splitter:
				dictionary_splitter.analyze_and_split()
			else:
				# Use JSH data splitter to help
				var dict_data = _get_dictionary_data()
				
				if dict_data.size() > 0 and jsh_data_splitter.has_method("split_data"):
					var split_result = jsh_data_splitter.split_data(dict_data, {
						"max_entries": config.auto_split_threshold,
						"split_rules": _get_split_rules()
					})
					
					if split_result.has("success") and split_result.success:
						_apply_dictionary_split(split_result)

# Get dictionary data for splitting
func _get_dictionary_data() -> Dictionary:
	# This would extract data from the dictionary in a format suitable for JSH data splitter
	var result = {
		"entries": {},
		"metadata": {
			"type": "akashic_dictionary",
			"version": "1.0",
			"timestamp": Time.get_ticks_msec()
		}
	}
	
	if akashic_records_manager and akashic_records_manager.dynamic_dictionary:
		# Get all word IDs
		var word_ids = akashic_records_manager.dynamic_dictionary.get_all_word_ids()
		
		# Add each word to entries
		for word_id in word_ids:
			var word = akashic_records_manager.get_word(word_id)
			if word.size() > 0:
				result.entries[word_id] = word
	
	return result

# Get split rules for dictionary
func _get_split_rules() -> Dictionary:
	return {
		"category_split": true,       # Split by category
		"parent_child_split": true,   # Keep parent/child together
		"complexity_split": true,     # Split complex entries
		"force_root_entries": [       # Entries that should stay in root dictionary
			"primordial", 
			"fire", 
			"water", 
			"wood", 
			"ash"
		]
	}

# Apply dictionary split
func _apply_dictionary_split(split_result: Dictionary) -> void:
	if not split_result.has("splits"):
		return
	
	var splits = split_result.splits
	print("Applying dictionary split: " + str(splits.size()) + " splits")
	
	# For each split, create a new file
	for split_id in splits:
		var split_data = splits[split_id]
		
		if split_data.has("entries") and split_data.entries.size() > 0:
			var file_name = "dictionary_" + split_id + ".json"
			var file_path = "user://akashic_records/data/words/" + file_name
			
			# Save split to file
			_save_split_to_file(file_path, split_data)
			
			# Update registry
			file_registry.words[file_name] = {
				"path": file_path,
				"size": _get_file_size(file_path),
				"last_modified": _get_file_modification_time(file_path),
				"entries": split_data.entries.size(),
				"category": "words",
				"split_from": "root_dictionary",
				"children": []
			}
			
			# Update stats
			dictionary_stats.total_files += 1
			dictionary_stats.total_size_kb += file_registry.words[file_name].size
			dictionary_stats.splits_performed += 1
	
	emit_signal("database_split", "root_dictionary", splits.keys())

# Save split data to file
func _save_split_to_file(file_path: String, data: Dictionary) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		return true
	
	print("ERROR: Could not save split to file: " + file_path)
	return false

# Add file to split queue
func _add_file_to_split_queue(file_info: Dictionary) -> void:
	# Check if already in queue
	for item in pending_splits:
		if item.path == file_info.path:
			return
	
	pending_splits.append(file_info)
	print("Added file to split queue: " + file_info.path)

# Process pending splits
func _process_splits() -> void:
	print("Processing " + str(pending_splits.size()) + " pending splits")
	
	for file_info in pending_splits:
		# Split file
		_split_file(file_info)
	
	pending_splits.clear()

# Split a file into smaller chunks
func _split_file(file_info: Dictionary) -> void:
	var file_path = file_info.path
	print("Splitting file: " + file_path)
	
	# Read file content
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("ERROR: Could not open file for splitting: " + file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("ERROR: Could not parse JSON: " + file_path)
		return
	
	var data = json.get_data()
	if not data is Dictionary or not data.has("entries"):
		print("ERROR: Invalid data format: " + file_path)
		return
	
	var entries = data.entries
	
	# Determine split strategy
	var split_count = ceil(float(entries.size()) / config.auto_split_threshold)
	if split_count <= 1:
		# No need to split
		return
	
	print("Splitting into " + str(split_count) + " files")
	
	# Create splits
	var splits = {}
	var entry_keys = entries.keys()
	var entries_per_split = ceil(float(entry_keys.size()) / split_count)
	
	for i in range(split_count):
		var split_id = str(i+1)
		var start_idx = i * entries_per_split
		var end_idx = min(start_idx + entries_per_split, entry_keys.size())
		
		var split_entries = {}
		for j in range(start_idx, end_idx):
			var key = entry_keys[j]
			split_entries[key] = entries[key]
		
		splits[split_id] = {
			"entries": split_entries,
			"metadata": {
				"type": data.get("metadata", {}).get("type", "unknown"),
				"split_id": split_id,
				"original_file": file_info.get("path", ""),
				"timestamp": Time.get_ticks_msec()
			}
		}
	
	# Create split files
	var new_files = []
	var base_name = file_path.get_basename()
	
	for split_id in splits:
		var new_file_path = base_name + "_split_" + split_id + ".json"
		
		# Save split
		if _save_split_to_file(new_file_path, splits[split_id]):
			new_files.append(new_file_path)
			
			# Update registry
			var new_file_name = new_file_path.get_file()
			file_registry[file_info.category][new_file_name] = {
				"path": new_file_path,
				"size": _get_file_size(new_file_path),
				"last_modified": _get_file_modification_time(new_file_path),
				"entries": splits[split_id].entries.size(),
				"category": file_info.category,
				"split_from": file_path,
				"children": []
			}
			
			# Update original file info
			file_registry[file_info.category][file_path.get_file()].children.append(new_file_path)
			
			# Update stats
			dictionary_stats.total_files += 1
			dictionary_stats.total_size_kb += file_registry[file_info.category][new_file_name].size
	
	if new_files.size() > 0:
		dictionary_stats.splits_performed += 1
		emit_signal("database_split", file_path, new_files)
		
		# Update original data file to include references to splits
		data.metadata = data.get("metadata", {})
		data.metadata.split_files = new_files
		data.metadata.split_timestamp = Time.get_ticks_msec()
		
		# Empty entries to just keep references
		if jsh_data_splitter and jsh_data_splitter.has_method("create_reference_file"):
			var ref_data = jsh_data_splitter.create_reference_file(data, new_files)
			_save_split_to_file(file_path, ref_data)
		else:
			# Simple reference file creation
			var ref_data = {
				"metadata": data.metadata,
				"entries": {},
				"split_references": {}
			}
			
			for split_id in splits:
				var split_entries = splits[split_id].entries.keys()
				for entry in split_entries:
					ref_data.split_references[entry] = base_name + "_split_" + split_id + ".json"
			
			_save_split_to_file(file_path, ref_data)

# Timer callback to check for splits
func _on_check_timer_timeout() -> void:
	check_for_splits()

# Update file registry with new information
func update_registry() -> void:
	_initialize_registry()

# Get file information
func get_file_info(path: String) -> Dictionary:
	var file_name = path.get_file()
	var category = "unknown"
	
	if path.find("words") != -1:
		category = "words"
	elif path.find("entities") != -1:
		category = "entities"
	elif path.find("zones") != -1:
		category = "zones"
	
	if file_registry.has(category) and file_registry[category].has(file_name):
		return file_registry[category][file_name]
	
	return {}

# Get statistics
func get_stats() -> Dictionary:
	return dictionary_stats.duplicate()

# Process a data split from JSH system
func process_external_split(data: Dictionary, options: Dictionary = {}) -> Dictionary:
	if not jsh_data_splitter:
		return {"success": false, "reason": "data_splitter_not_available"}
	
	if jsh_data_splitter.has_method("split_data"):
		var split_result = jsh_data_splitter.split_data(data, options)
		
		if split_result.has("success") and split_result.success:
			# Process the split result
			var category = options.get("category", "words")
			var base_path = "user://akashic_records/data/" + category + "/"
			var base_name = options.get("base_name", "data_" + str(Time.get_ticks_msec()))
			
			# Save splits to files
			for split_id in split_result.splits:
				var split_data = split_result.splits[split_id]
				var file_path = base_path + base_name + "_" + split_id + ".json"
				
				_save_split_to_file(file_path, split_data)
			
			# Update registry
			update_registry()
		
		return split_result
	
	return {"success": false, "reason": "split_method_not_found"}

# Get word data from a specific file or from multiple files
func get_word_data(word_id: String) -> Dictionary:
	if akashic_records_manager:
		# Try simple lookup first
		var word = akashic_records_manager.get_word(word_id)
		if word.size() > 0:
			return word
	
	# Search in registry
	for file_name in file_registry.words:
		var file_info = file_registry.words[file_name]
		
		var file = FileAccess.open(file_info.path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error = json.parse(content)
			if error == OK:
				var data = json.get_data()
				
				if data is Dictionary:
					# Check direct entries
					if data.has("entries") and data.entries.has(word_id):
						return data.entries[word_id]
					
					# Check split references
					if data.has("split_references") and data.split_references.has(word_id):
						var ref_file = data.split_references[word_id]
						return _get_word_from_file(ref_file, word_id)
	
	return {}

# Get word from a specific file
func _get_word_from_file(file_path: String, word_id: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			
			if data is Dictionary and data.has("entries") and data.entries.has(word_id):
				return data.entries[word_id]
	
	return {}

# Integrate with JSH records system
func integrate_with_jsh_records() -> bool:
	if not jsh_records_system:
		return false
	
	print("Integrating with JSH Records System...")
	
	# Register akashic data sets with JSH records system
	if jsh_records_system.has_method("register_record_set"):
		jsh_records_system.register_record_set("akashic_words", {
			"auto_split": true,
			"max_size": config.auto_split_threshold,
			"base_path": "user://akashic_records/data/words/"
		})
		
		jsh_records_system.register_record_set("akashic_entities", {
			"auto_split": true,
			"max_size": config.auto_split_threshold,
			"base_path": "user://akashic_records/data/entities/"
		})
		
		jsh_records_system.register_record_set("akashic_zones", {
			"auto_split": true,
			"max_size": config.auto_split_threshold,
			"base_path": "user://akashic_records/data/zones/"
		})
		
		print("Registered Akashic record sets with JSH Records System")
		return true
	
	return false
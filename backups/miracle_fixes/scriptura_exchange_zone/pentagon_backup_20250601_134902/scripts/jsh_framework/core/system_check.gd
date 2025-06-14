# 🏛️ System Check - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# system_check.gd
#
#
## res://code/gdscript/scripts/Menu_Keyboard_Console/system_check.gd
#
# JSH_Patch/Godot_connections/system_check
#
# root/system_check
# system_check : Node

# init check

# ready check 
## [0] = is it debug build
## [1] = what system it is
## [2] = main.gd read line
## [3] = res folder
## [4] = scene tree at launch
## [5] = Eden folder
## [6] = Eden_Backup folder
## [7] = mutexes check
## [8] = settings file at start
## [9] = camera node of viewport
## [10] = viewport
## [11] = scene tree, check if we have branches
## [12] = timers system
## [13] = thread status

# nodes connection to main, done by a function
## [0] = JSH_records_system = JSH_records_system
## [1] = JSH_task_manager = task_manager
## [2] = JSH_ThreadPool_Manager = JSH_Threads
## [3] = JSH_data_splitter = data_splitter
## [4] = system_check = JSH_system_check

###
# Usage:
# var data_center = DataCenter.new()
# data_center.create_zip_archive("backup_001", "path/to/source")
# data_center.extract_zip_archive("path/to/backup_001.zip", "path/to/extract")
# var file_path = data_center.get_file_by_word("abc")

###
## have not used yet any of these functions, but what do we need
###


########
##the alien message of self repair for machines
##the memories full self check
##the system for rom memory, of one metadata file
##the load of few very specific and main files metadata
##maybe lets seriously ese these nodes
##the aliens hidden in my computer are telling me too
########

###
## Configuration_file
###

###
## Basic_function check
###

###
## Database_parts
###

###
## The_signal_of_each_script
## attach signal in each script, maybe we can ping it if we wanna easily doing so?
## we first check godot change tree
## then we
###

###
## godot core functions check
## the signal of godot tree change, shall always do some kind of task
## we will track times
## for key presses xD
###

extends UniversalBeingBase
signal system_verified(system_name, status)
signal verification_phase_complete(phase_number)

# TODO: Emit these signals when appropriate functionality is implemented
# signal system_ready
# signal system_verification_complete
# signal system_error


var initialization_sequence = {
	"current_stage": -1,
	"stages": [
		"system_check",
		"data_center",
		"timers",
		"tree",
		"records"
	],
	"dependencies": {
		"data_center": ["system_check"],
		"timers": ["system_check"],
		"tree": ["system_check", "data_center"],
		"records": ["data_center", "tree"]
	}
}

# State tracking 
var system_health := {
	"mutex": Mutex.new(),
	"core_checks": {
		"file_system": {"status": false, "last_check": 0},
		"memory": {"status": false, "last_check": 0},
		"threads": {"status": false, "last_check": 0}
	},
	"repair_log": [],
	"recovery_attempts": {}
}

# Parser System
var parser_system := {
	"delimiters": {
		"primary": "|",
		"brackets": ["<>", "[]", "{}", "()"],
		"special": ["=", "#", "@"]
	},
	"patterns": {
		"status": "[status]=*",
		"command": "<command>*</command>",
		"data": "{data}*{/data}"
	}
}


###
## the Claude idea before i touched it
###

# Word-based data organization
const WORD_LENGTH = 3  # Three letter system
var word_database = {}
var word_mappings = {}

# Storage paths
var storage_paths = {
	"user": "user://",
	"eden": "D:/Eden/",
	"system": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"temp": OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
}

# Zip management
var current_archive = null
var extracted_files = {}

# Word generation and management
var used_words = []
var word_templates = [
	"abc", "def", "ghi", "jkl", "mno",
	"pqr", "stu", "vwx", "yz0", "123"
]


###
## here i started touching
###


func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func check_all_things():
	print(" JSH_systems_checker, check connection")
	return true


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	print(" ready on each script ? new system_check.gd ")
	scan_available_storage()
	initialize_word_system()
# In system_check.gd

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Connect all system signals
	for system in system_status.components:
		if has_node("../" + system):
			var node = get_node("../" + system)
			if node.has_signal("ready"):
				node.connect("ready", _on_system_ready.bind(system))


# Parser Functions
func find_matching_symbols(text: String, start_symbol: String, end_symbol: String) -> Array:
	var matches = []
	var depth = 0
	var start_pos = -1
	
	for i in range(text.length()):
		if text.substr(i, 1) == start_symbol:
			if depth == 0:
				start_pos = i
			depth += 1
		elif text.substr(i, 1) == end_symbol:
			depth -= 1
			if depth == 0 and start_pos != -1:
				matches.append([start_pos, i])
				start_pos = -1
				
	return matches

# Basic verification
func verify_system_component(_component_name: String) -> Dictionary:
	var verification = {
		"time": Time.get_ticks_msec(),
		"status": false,
		"repairs_needed": [],
		"repairs_attempted": []
	}
	
	system_health.mutex.lock()
	# Verification logic here
	system_health.mutex.unlock()
	
	return verification


func _on_system_ready(system_name: String):
	system_status.mutex.lock()
	system_status.components[system_name].ready = true
	system_status.components[system_name].time = Time.get_ticks_msec()
	system_status.mutex.unlock()

var system_status = {
	"mutex": Mutex.new(),
	"components": {
		"data_center": {"ready": false, "time": 0},
		"timers": {"ready": false, "time": 0},
		"tree": {"ready": false, "time": 0},
		"records": {"ready": false, "time": 0}
	},
	"verification_log": []
}



func verify_system(system_name: String) -> Dictionary:
	var result = {
		"system": system_name,
		"status": false,
		"details": {},
		"timestamp": Time.get_ticks_msec()
	}
	
	# Verification logic here
	
	emit_signal("system_verified", system_name, result)
	return result




func get_data_structure_size(data) -> int:
	# Early return for null data
	if data == null:
		return 0
		
	match typeof(data):
		TYPE_DICTIONARY:
			var total_size = 0
			for key in data:
				# Add key size
				total_size += var_to_bytes(key).size()
				# Add value size recursively
				if data[key] != null:
					total_size += get_data_structure_size(data[key])
			return total_size
			
		TYPE_ARRAY:
			var total_size = 0
			for item in data:
				if item != null:
					total_size += get_data_structure_size(item)
			return total_size
			
		TYPE_OBJECT:
			# Handle special cases like Nodes
			if data is Node:
				return 8  # Base pointer size
			return var_to_bytes(data).size()
			
		TYPE_STRING:
			return data.length() * 2  # Approximate UTF-16 size
			
		TYPE_INT:
			return 4
			
		TYPE_FLOAT:
			return 8
			
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return 8
			
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return 12
			
		_:
			# Default fallback using var_to_bytes
			return var_to_bytes(data).size()

var memory_metadata

# Helper function to safely get property
func get_jsh(property_name: String):
	if property_name in self:
		return self[property_name]
	return null

func check_memory_state():
	var _current_time = Time.get_ticks_msec()
	var sizes = {}
	
	# Check arrays
	for array_name in memory_metadata["arrays"].keys():
		if get_jsh(array_name) != null:
			var array_size = get_data_structure_size(get_jsh(array_name))
			sizes[array_name] = array_size
			
			if array_size > memory_metadata["cleanup_thresholds"]["array_max"]:
				clean_array(array_name)
	
	# Check dictionaries
	for dict_name in memory_metadata["dictionaries"].keys():
		if get_jsh(dict_name) != null:
			var dict_size = get_data_structure_size(get_jsh(dict_name))
			sizes[dict_name] = dict_size
			
			# Convert to MB
			var size_mb = dict_size / (1024.0 * 1024.0)
			if size_mb > memory_metadata["cleanup_thresholds"]["dict_max_mb"]:
				clean_dictionary(dict_name)
	
	print("\nMemory State:")
	for size_name in sizes:
		print("%s: %s bytes" % [size_name, sizes[size_name]])
		
	return sizes

var cached_record_sets
var dictionary_of_mistakes
var stored_delta_memory
var blimp_of_time
var array_with_no_mutex

func clean_dictionary(dict_name: String):
	match dict_name:
		"cached_record_sets":
			# Clean old cached records
			var current_time = Time.get_ticks_msec()
			for key in cached_record_sets.keys():
				if current_time - cached_record_sets[key].get("timestamp", 0) > 3600000: # 1 hour
					cached_record_sets.erase(key)
					
		"dictionary_of_mistakes":
			# Clean resolved errors
			for key in dictionary_of_mistakes.keys():
				if dictionary_of_mistakes[key].get("status") == "resolved":
					dictionary_of_mistakes.erase(key)

func clean_array(array_name: String):
	match array_name:
		"stored_delta_memory":
			# Keep only last 100 entries
			if stored_delta_memory.size() > 100:
				stored_delta_memory = stored_delta_memory.slice(-100)
				
		"blimp_of_time":
			if blimp_of_time.size() > 50:
				blimp_of_time = blimp_of_time.slice(-50)
		
		"array_with_no_mutex":
			# Clean old errors
			var current_time = Time.get_ticks_msec()
			array_with_no_mutex = array_with_no_mutex.filter(
				func(error): return current_time - error.time < 300000 # 5 minutes
			)


###
## probably not there yet
###





func scan_available_storage():
	# Scan Windows drives
	if OS.get_name() == "Windows":
		for ascii in range(67, 91):  # C to Z
			var drive = char(ascii) + ":/"
			if DirAccess.dir_exists_absolute(drive):
				storage_paths[drive.substr(0, 1).to_lower()] = drive

func initialize_word_system():
	# Initialize consonants and vowels for word generation
	var consonants = ['b','c','d','f','g','h','j','k','l','m','n','p','q','r','s','t','v','w','x','y','z']
	var vowels = ['a','e','i','o','u']
	
	# Generate initial word combinations
	for c1 in consonants:
		for v in vowels:
			for c2 in consonants:
				var word = c1 + v + c2
				if !word_database.has(word):
					word_database[word] = {
						"used": false,
						"data_type": "",
						"creation_time": 0,
						"last_access": 0,
						"reference_count": 0
					}

func get_next_word() -> String:
	for word in word_database:
		if !word_database[word]["used"]:
			word_database[word]["used"] = true
			word_database[word]["creation_time"] = Time.get_ticks_msec()
			used_words.append(word)
			return word
	return ""  # No words available

func map_data_to_word(data_type: String, data_path: String) -> String:
	var word = get_next_word()
	if word != "":
		word_mappings[word] = {
			"type": data_type,
			"path": data_path,
			"creation_time": Time.get_ticks_msec(),
			"access_count": 0
		}
	return word

func create_zip_archive(archive_name: String, source_path: String) -> bool:
	var success = false
	
	# Create zip directory if it doesn't exist
	var zip_dir = storage_paths["eden"] + "zips/"
	if !DirAccess.dir_exists_absolute(zip_dir):
		DirAccess.make_dir_recursive_absolute(zip_dir)
	
	# Create primary and backup paths
	var primary_path = zip_dir + archive_name + ".zip"
	var backup_path = zip_dir + archive_name + "_backup.zip"
	
	# Create zip files
	_create_zip_file(primary_path, source_path)
	_create_zip_file(backup_path, source_path)  # Backup copy
	
	return success

func _create_zip_file(zip_path: String, source_path: String):
	# Create file handles
	var zip_file = FileAccess.open(zip_path, FileAccess.WRITE)
	if zip_file:
		# Write header
		var header = {
			"creation_time": Time.get_ticks_msec(),
			"source_path": source_path,
			"word_count": used_words.size()
		}
		zip_file.store_var(header)
		
		# Iterate through directory
		var dir = DirAccess.open(source_path)
		if dir:
			for file in dir.get_files():
				var file_path = source_path + "/" + file
				var content = FileAccess.get_file_as_bytes(file_path)
				if content:
					# Map file to word
					var word = map_data_to_word("file", file_path)
					if word != "":
						# Store file data
						zip_file.store_var({
							"word": word,
							"name": file,
							"size": content.size(),
							"data": content
						})

func extract_zip_archive(zip_path: String, extract_path: String) -> bool:
	var success = false
	
	var zip_file = FileAccess.open(zip_path, FileAccess.READ)
	if zip_file:
		# Read header
		var _header = zip_file.get_var()
		
		# Create extraction directory
		if !DirAccess.dir_exists_absolute(extract_path):
			DirAccess.make_dir_recursive_absolute(extract_path)
		
		# Extract files
		while !zip_file.eof_reached():
			var file_data = zip_file.get_var()
			if file_data:
				var extract_file_path = extract_path + "/" + file_data["name"]
				var output_file = FileAccess.open(extract_file_path, FileAccess.WRITE)
				if output_file:
					output_file.store_buffer(file_data["data"])
					extracted_files[file_data["word"]] = extract_file_path
					success = true
	
	return success

func get_file_by_word(word: String) -> String:
	if word_mappings.has(word):
		word_mappings[word]["access_count"] += 1
		return word_mappings[word]["path"]
	return ""

func generate_word_report() -> String:
	var report = "Word System Status Report\n"
	report += "========================\n"
	report += "Total Words: %d\n" % word_database.size()
	report += "Used Words: %d\n" % used_words.size()
	report += "\nMost Accessed Files:\n"
	
	# Sort words by access count
	var sorted_words = []
	for word in word_mappings:
		sorted_words.append({
			"word": word,
			"count": word_mappings[word]["access_count"]
		})
	
	sorted_words.sort_custom(func(a, b): return a["count"] > b["count"])
	
	# Add top 10 to report
	for i in range(min(10, sorted_words.size())):
		var word_data = sorted_words[i]
		report += "%s: %d accesses\n" % [word_data["word"], word_data["count"]]
	
	return report

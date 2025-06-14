# 🏛️ Jsh Data Splitter - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# jsh_data_splitter.gd

# root/JSH_data_splitter

extends UniversalBeingBase
# nodes move over time but might appear as branch even if
# before were containers
# they are names like nodes


signal parsing_completed(stats: Dictionary)
# signal error_detected(error: Dictionary)  # Currently unused

const SPLIT_RULES = {
	"LEVEL_0": ["[", "]"],    # Main blocks
	"LEVEL_1": ["="],         # Section separators
	"LEVEL_2": ["|"],         # Data separators
	"LEVEL_3": [",", "."]     # Content separators
}

const STORAGE_RULES = {
	"MAX_LINE_LENGTH": 80,
	"MAX_FUNCTION_SIZE": 1000,
	"REQUIRED_TAGS": ["name", "version", "status"],
	"ALLOWED_SYMBOLS": ["[", "]", "=", "|", "#"]
}


const JSH_FILE_FORMAT = {
	"line_separator": "|",
	"block_start": "[",
	"block_end": "]",
	"dict_marker": "=",
	"version_marker": "#"
}

var parse_stats = {
	"files_processed": 0,
	"successful_parses": 0,
	"failed_parses": 0,
	"total_blocks": 0,
	"mutex_states": {},
	"last_processed": ""
}

# Example line storage:
var line_storage = """
[HEADER]=[version=#0|type=dictionary|lines=10]|
[DATA]=[line_0=hello world|line_1={key:value}|line_2=[1,2,3]]|
[METADATA]=[previous=version_0|changes=added_lines|timestamp=1234]|
"""


const MAX_LINES_PER_BLOCK = 10
const MAX_WORDS_PER_LINE = 10

var _settings_data: Dictionary
var _mutex = Mutex.new()

############################

func _ready():
	# Load settings on startup
	if SettingsBank:
		_settings_data = SettingsBank.check_all_settings_data()
		initialize_parser()

###############################

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

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
	print(" JSH file parser check connection")
	return true

###############################


func initialize_parser() -> void:
	if _settings_data.is_empty():
		push_error("Settings data not available")
		return
		
	# Initialize mutex states tracking
	parse_stats.mutex_states = {
		"file_access": true,
		"parsing": true,
		"stats": true
	}
	
	
func process_directory(path: String = "") -> Dictionary:
	if path.is_empty() and _settings_data.has("directory_path"):
		path = _settings_data.directory_path
		
	var result = {
		"processed_files": [],
		"failed_files": [],
		"stats": parse_stats.duplicate()
	}
	
	_mutex.lock()
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.get_extension() == "txt":
				var full_path = path.path_join(file_name)
				if process_file(full_path):
					result.processed_files.append(file_name)
				else:
					result.failed_files.append(file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	_mutex.unlock()
	
	emit_signal("parsing_completed", result)
	return result

func process_file(file_path: String) -> bool:
	_mutex.lock()
	var success = false
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed = parse_jsh_file(content)
			if !parsed.is_empty():
				update_parse_stats(true, file_path)
				success = true
			else:
				update_parse_stats(false, file_path)
	
	_mutex.unlock()
	return success

func update_parse_stats(success: bool, file_path: String) -> void:
	parse_stats.files_processed += 1
	if success:
		parse_stats.successful_parses += 1
	else:
		parse_stats.failed_parses += 1
	parse_stats.last_processed = file_path

func get_parse_stats() -> Dictionary:
	_mutex.lock()
	var stats = parse_stats.duplicate()
	_mutex.unlock()
	return stats

# Enhanced JSH file parsing
func parse_jsh_file(content: String) -> Dictionary:
	var blocks = {}
	var current_block = ""
	var lines = content.split(JSH_FILE_FORMAT.line_separator)
	
	for line in lines:
		if line.is_empty():
			continue
			
		if line.begins_with(JSH_FILE_FORMAT.block_start):
			var parts = line.split(JSH_FILE_FORMAT.dict_marker)
			if parts.size() >= 2:
				current_block = parts[0].trim_prefix(JSH_FILE_FORMAT.block_start).trim_suffix(JSH_FILE_FORMAT.block_end)
				blocks[current_block] = {
					"content": [],
					"metadata": parse_block_metadata(parts[1])
				}
		elif current_block != "":
			if blocks.has(current_block):
				blocks[current_block].content.append(line)
	
	parse_stats.total_blocks = blocks.size()
	return blocks

func parse_block_metadata(metadata_str: String) -> Dictionary:
	var metadata = {}
	var parts = metadata_str.split(JSH_FILE_FORMAT.line_separator)
	
	for part in parts:
		var kv = part.split("=")
		if kv.size() == 2:
			metadata[kv[0].strip_edges()] = kv[1].strip_edges()
			
	return metadata

# Function for checking file format validity
func validate_file_format(content: String) -> Dictionary:
	var validation = {
		"valid": true,
		"errors": []
	}
	
	if !content.begins_with("[# JSH Ethereal Engine]"):
		validation.valid = false
		validation.errors.append("Missing JSH header")
		
	for rule in STORAGE_RULES.REQUIRED_TAGS:
		if !content.contains("[" + rule):
			validation.valid = false
			validation.errors.append("Missing required tag: " + rule)
			
	return validation

# Stats collection for system check integration
func collect_system_stats() -> Dictionary:
	return {
		"parser_status": {
			"active": parse_stats.files_processed > 0,
			"success_rate": float(parse_stats.successful_parses) / max(parse_stats.files_processed, 1),
			"mutex_states": parse_stats.mutex_states
		},
		"format_stats": {
			"total_blocks": parse_stats.total_blocks,
			"recent_file": parse_stats.last_processed
		}
	}
##########################


func analyze_file_content(content: String) -> Dictionary:
	var analysis = {
		"total_chars": content.length(),
		"char_counts": {},
		"symbol_counts": {},
		"word_counts": {},
		"splits": []
	}
	
	for c in content:
		if !analysis.char_counts.has(c):
			analysis.char_counts[c] = 0
		analysis.char_counts[c] += 1

	var splits = content.split("[")
	for split in splits:
		if split.contains("]"):
			analysis.splits.append(split.split("]")[0])
			
	return analysis

func split_by_rules(content: String, level: String) -> Array:
	var splits = []
	if SPLIT_RULES.has(level):
		for symbol in SPLIT_RULES[level]:
			splits.append_array(content.split(symbol))
	return splits

func parse_function_data(function_content: String) -> Dictionary:
	return {
		"name": get_function_name(function_content),
		"inputs": get_function_inputs(function_content),
		"content": get_function_body(function_content),
		"analysis": analyze_file_content(function_content)
	}


# Function parsing helpers
func get_function_name(function_content: String) -> String:
	var lines = function_content.split("\n")
	for line in lines:
		if line.begins_with("func "):
			# Remove 'func ' and everything after '('
			var func_name = line.substr(5).split("(")[0].strip_edges()
			return func_name
	return ""

func get_function_inputs(function_content: String) -> Array:
	var inputs = []
	var lines = function_content.split("\n")
	for line in lines:
		if line.begins_with("func "):
			# Get everything between ( and )
			var params = line.split("(")[1].split(")")[0]
			if params.strip_edges() != "":
				for param in params.split(","):
					var param_parts = param.strip_edges().split(":")
					inputs.append({
						"name": param_parts[0].strip_edges(),
						"type": param_parts[1].strip_edges() if param_parts.size() > 1 else "Variant"
					})
			break
	return inputs

func get_function_body(function_content: String) -> String:
	var lines = function_content.split("\n")
	var body = []
	var in_body = false
	
	for line in lines:
		if line.begins_with("func "):
			in_body = true
			continue
		if in_body:
			body.append(line)
	
	return "\n".join(body)

# Line processing
func process_with_limits(content: String) -> Dictionary:
	var processed = {
		"lines": [],
		"word_count": 0,
		"line_count": 0
	}
	
	var lines = content.split("\n")
	for line in lines:
		if processed.line_count >= MAX_LINES_PER_BLOCK:
			break
			
		var words = line.split(" ")
		if words.size() <= MAX_WORDS_PER_LINE:
			processed.lines.append(line)
			processed.word_count += words.size()
			processed.line_count += 1
			
	return processed

# Version tracking
func generate_ender_version(content: String) -> String:
	var lines = content.split("\n")
	var ender = []
	for line in lines:
		var stripped = line.strip_edges()
		if stripped != "":
			ender.append(stripped)
	return "\n".join(ender)


func compare_versions(old_content: String, new_content: String) -> Dictionary:
	var diff = {
		"added_lines": [],
		"removed_lines": [],
		"modified_lines": []
	}
	
	var old_blocks = parse_jsh_file(old_content)
	var new_blocks = parse_jsh_file(new_content)
	
	# Compare blocks
	for block in old_blocks:
		if new_blocks.has(block):
			# Compare lines within block
			var old_lines = old_blocks[block]
			var new_lines = new_blocks[block]
			for i in range(old_lines.size()):
				if old_lines[i] != new_lines[i]:
					diff.modified_lines.append([block, i, old_lines[i], new_lines[i]])
	
	return diff

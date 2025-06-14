# ==================================================
# SCRIPT NAME: lists_viewer_system.gd
# DESCRIPTION: Program the game using text files - the dream system
# PURPOSE: Allow game rules and behavior to be defined in simple text
# CREATED: 2025-05-27 - The Universal Entity Core
# ==================================================

extends UniversalBeingBase
class_name ListsViewerSystem

signal rule_loaded(rule_name: String)
signal rule_executed(rule_name: String, result)
signal list_updated(list_name: String)

# Rule and list storage
var loaded_lists: Dictionary = {}
var active_rules: Dictionary = {}
var rule_processors: Dictionary = {}
var execution_history: Array = []

# Control flags
var rules_enabled: bool = false  # Disable automatic rule execution by default

# File monitoring
var watched_files: Dictionary = {}
var file_check_timer: Timer

# Paths
const LISTS_DIR = "user://lists/"
const RULES_DIR = "user://rules/"

var console: Node
var floodgate: FloodgateController

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "ListsViewerSystem"
	
	console = get_node_or_null("/root/ConsoleManager")
	floodgate = get_node_or_null("/root/FloodgateController")
	
	# Create directories
	_ensure_directories()
	
	# Setup file monitoring
	file_check_timer = TimerManager.get_timer()
	file_check_timer.wait_time = 1.0
	file_check_timer.timeout.connect(_check_file_changes)
	add_child(file_check_timer)
	file_check_timer.start()
	
	# Create example files
	_create_example_files()
	
	# Load all lists and rules
	load_all_lists()
	load_all_rules()
	
	_print("[ListsViewerSystem] Ready! Edit .txt files to program the game!")

# ========== FILE MANAGEMENT ==========

func _ensure_directories() -> void:
	"""Create necessary directories"""
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("lists"):
		dir.make_dir("lists")
	if not dir.dir_exists("rules"):
		dir.make_dir("rules")

func _create_example_files() -> void:
	"""Create example list and rule files"""
	
	# Example spawn list
	if not FileAccess.file_exists(LISTS_DIR + "spawn_patterns.txt"):
		var file = FileAccess.open(LISTS_DIR + "spawn_patterns.txt", FileAccess.WRITE)
		file.store_line("# Spawn Patterns List")
		file.store_line("# Format: object_type x y z [properties]")
		file.store_line("")
		file.store_line("# Circle pattern")
		file.store_line("pattern:circle")
		file.store_line("tree 5 0 0")
		file.store_line("tree 3.5 0 3.5")
		file.store_line("tree 0 0 5")
		file.store_line("tree -3.5 0 3.5")
		file.store_line("tree -5 0 0")
		file.store_line("tree -3.5 0 -3.5")
		file.store_line("tree 0 0 -5")
		file.store_line("tree 3.5 0 -3.5")
		file.store_line("")
		file.store_line("# Grid pattern")
		file.store_line("pattern:grid")
		file.store_line("box -5 0 -5")
		file.store_line("box 0 0 -5")
		file.store_line("box 5 0 -5")
		file.store_line("box -5 0 0")
		file.store_line("box 0 0 0")
		file.store_line("box 5 0 0")
		file.store_line("box -5 0 5")
		file.store_line("box 0 0 5")
		file.store_line("box 5 0 5")
		file.close()
	
	# Example rules file
	if not FileAccess.file_exists(RULES_DIR + "game_rules.txt"):
		var file = FileAccess.open(RULES_DIR + "game_rules.txt", FileAccess.WRITE)
		file.store_line("# Game Rules")
		file.store_line("# Format: WHEN condition THEN action")
		file.store_line("")
		file.store_line("# Performance rules")
		file.store_line("WHEN fps < 30 THEN unload_distant_objects")
		file.store_line("WHEN node_count > 500 THEN optimize_scene")
		file.store_line("WHEN memory > 400MB THEN force_cleanup")
		file.store_line("")
		file.store_line("# Spawning rules")
		file.store_line("WHEN objects < 10 THEN spawn_from_list spawn_patterns.txt")
		file.store_line("WHEN player_near tree THEN make_tree_talk")
		file.store_line("")
		file.store_line("# Time-based rules")
		file.store_line("EVERY 30s THEN check_performance")
		file.store_line("EVERY 60s THEN save_game_state")
		file.close()

# ========== LIST LOADING ==========


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
func load_all_lists() -> void:
	"""Load all .txt files from lists directory"""
	var dir = DirAccess.open(LISTS_DIR)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".txt"):
			load_list(file_name)
		file_name = dir.get_next()

func load_list(filename: String) -> Dictionary:
	"""Load a list file and parse it"""
	var filepath = LISTS_DIR + filename
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return {}
	
	var list_data = {
		"name": filename.trim_suffix(".txt"),
		"patterns": {},
		"items": [],
		"metadata": {}
	}
	
	var current_pattern = ""
	var line_num = 0
	
	while not file.eof_reached():
		line_num += 1
		var line = file.get_line().strip_edges()
		
		# Skip comments and empty lines
		if line.begins_with("#") or line.is_empty():
			continue
		
		# Pattern definition
		if line.begins_with("pattern:"):
			current_pattern = line.split(":")[1]
			list_data.patterns[current_pattern] = []
			continue
		
		# Parse line data
		var parsed = _parse_list_line(line)
		if parsed:
			if current_pattern:
				list_data.patterns[current_pattern].append(parsed)
			else:
				list_data.items.append(parsed)
	
	file.close()
	
	# Store and monitor file
	loaded_lists[list_data.name] = list_data
	watched_files[filepath] = FileAccess.get_modified_time(filepath)
	
	list_updated.emit(list_data.name)
	_print("[LISTS] Loaded: " + filename + " (" + str(list_data.items.size()) + " items)")
	
	return list_data

func _parse_list_line(line: String) -> Dictionary:
	"""Parse a single line from a list file"""
	var parts = line.split(" ", false)
	if parts.is_empty():
		return {}
	
	var result = {
		"type": parts[0]
	}
	
	# Position data
	if parts.size() >= 4:
		result.position = Vector3(
			parts[1].to_float(),
			parts[2].to_float(),
			parts[3].to_float()
		)
	
	# Additional properties
	for i in range(4, parts.size()):
		if "=" in parts[i]:
			var kv = parts[i].split("=")
			result[kv[0]] = kv[1]
	
	return result

# ========== RULE LOADING ==========

func load_all_rules() -> void:
	"""Load all rule files"""
	var dir = DirAccess.open(RULES_DIR)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".txt"):
			load_rules(file_name)
		file_name = dir.get_next()

func load_rules(filename: String) -> void:
	"""Load and parse a rules file"""
	var filepath = RULES_DIR + filename
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return
	
	var rule_count = 0
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# Skip comments and empty lines
		if line.begins_with("#") or line.is_empty():
			continue
		
		# Parse rule
		var rule = _parse_rule(line)
		if rule:
			var rule_id = filename + "_" + str(rule_count)
			active_rules[rule_id] = rule
			rule_count += 1
	
	file.close()
	
	# Monitor file
	watched_files[filepath] = FileAccess.get_modified_time(filepath)
	
	_print("[RULES] Loaded " + str(rule_count) + " rules from " + filename)

func _parse_rule(line: String) -> Dictionary:
	"""Parse a rule line"""
	var rule = {}
	
	# WHEN condition THEN action
	if "WHEN" in line and "THEN" in line:
		var parts = line.split("THEN")
		var condition = parts[0].replace("WHEN", "").strip_edges()
		var action = parts[1].strip_edges()
		
		rule = {
			"type": "conditional",
			"condition": _parse_condition(condition),
			"action": action
		}
	
	# EVERY interval THEN action
	elif "EVERY" in line and "THEN" in line:
		var parts = line.split("THEN")
		var interval = parts[0].replace("EVERY", "").strip_edges()
		var action = parts[1].strip_edges()
		
		rule = {
			"type": "periodic",
			"interval": _parse_interval(interval),
			"action": action,
			"last_executed": 0.0
		}
	
	return rule

func _parse_condition(condition_str: String) -> Dictionary:
	"""Parse a condition string"""
	var condition = {}
	
	# fps < 30
	if "fps" in condition_str:
		var parts = condition_str.split(" ")
		condition = {
			"type": "fps",
			"operator": parts[1],
			"value": parts[2].to_float()
		}
	
	# node_count > 500
	elif "node_count" in condition_str:
		var parts = condition_str.split(" ")
		condition = {
			"type": "node_count",
			"operator": parts[1],
			"value": parts[2].to_int()
		}
	
	# memory > 400MB
	elif "memory" in condition_str:
		var parts = condition_str.split(" ")
		var value = parts[2].replace("MB", "")
		condition = {
			"type": "memory",
			"operator": parts[1],
			"value": value.to_float()
		}
	
	# objects < 10
	elif "objects" in condition_str:
		var parts = condition_str.split(" ")
		condition = {
			"type": "object_count",
			"operator": parts[1],
			"value": parts[2].to_int()
		}
	
	# player_near object_type
	elif "player_near" in condition_str:
		var parts = condition_str.split(" ")
		condition = {
			"type": "proximity",
			"target": parts[1] if parts.size() > 1 else "any"
		}
	
	return condition

func _parse_interval(interval_str: String) -> float:
	"""Parse interval string to seconds"""
	var value = 0.0
	
	if "s" in interval_str:
		value = interval_str.replace("s", "").to_float()
	elif "m" in interval_str:
		value = interval_str.replace("m", "").to_float() * 60.0
	elif "h" in interval_str:
		value = interval_str.replace("h", "").to_float() * 3600.0
	
	return value

# ========== RULE EXECUTION ==========

func check_and_execute_rules() -> void:
	"""Check all rules and execute if conditions are met"""
	if not rules_enabled:
		return  # Skip rule execution if disabled
		
	var current_time = Time.get_ticks_msec() / 1000.0
	
	for rule_id in active_rules:
		var rule = active_rules[rule_id]
		
		if rule.type == "conditional":
			if _check_condition(rule.condition):
				_execute_action(rule.action, rule_id)
		
		elif rule.type == "periodic":
			if current_time - rule.last_executed >= rule.interval:
				_execute_action(rule.action, rule_id)
				rule.last_executed = current_time

func _check_condition(condition: Dictionary) -> bool:
	"""Check if a condition is met"""
	match condition.type:
		"fps":
			var fps = Engine.get_frames_per_second()
			return _compare_values(fps, condition.operator, condition.value)
		
		"node_count":
			var count = get_tree().get_node_count()
			return _compare_values(count, condition.operator, condition.value)
		
		"memory":
			var memory_mb = OS.get_static_memory_usage() / 1048576.0
			return _compare_values(memory_mb, condition.operator, condition.value)
		
		"object_count":
			if floodgate:
				var count = floodgate.tracked_objects.size()
				return _compare_values(count, condition.operator, condition.value)
			return false
		
		"proximity":
			return _check_proximity(condition.target)
		
		_:
			return false

func _compare_values(value1, operator: String, value2) -> bool:
	"""Compare two values with an operator"""
	match operator:
		"<": return value1 < value2
		">": return value1 > value2
		"<=": return value1 <= value2
		">=": return value1 >= value2
		"==": return value1 == value2
		"!=": return value1 != value2
		_: return false

func _check_proximity(target_type: String) -> bool:
	"""Check if player is near a target type"""
	# Get player node (assuming it exists)
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	# Check objects near player
	if floodgate:
		for obj in floodgate.tracked_objects:
			if target_type == "any" or obj.type == target_type:
				var distance = player.global_position.distance_to(obj.node.global_position)
				if distance < 5.0:  # 5 units proximity
					return true
	
	return false

func _execute_action(action: String, rule_id: String) -> void:
	"""Execute a rule action"""
	_print("[RULE] Executing: " + action)
	
	match action:
		"unload_distant_objects":
			if has_node("/root/UniversalEntity"):
				var player = get_tree().get_first_node_in_group("player")
				var center = player.global_position if player else Vector3.ZERO
				get_node("/root/UniversalEntity").loader.unload_nodes_by_distance(center, 30.0)
		
		"optimize_scene":
			if has_node("/root/UniversalEntity"):
				get_node("/root/UniversalEntity").loader.force_cleanup()
		
		"force_cleanup":
			if has_node("/root/UniversalEntity"):
				get_node("/root/UniversalEntity").loader.force_cleanup(true)
		
		"check_performance":
			if has_node("/root/UniversalEntity"):
				get_node("/root/UniversalEntity").health_monitor.force_health_check()
		
		"save_game_state":
			_save_game_state()
		
		"make_tree_talk":
			_make_nearby_tree_talk()
		
		_:
			# Check if it's a spawn action
			if action.begins_with("spawn_from_list"):
				var list_name = action.split(" ")[1]
				_spawn_from_list(list_name)
	
	# Record execution
	execution_history.append({
		"rule_id": rule_id,
		"action": action,
		"time": Time.get_ticks_msec() / 1000.0
	})
	
	rule_executed.emit(rule_id, true)

# ========== ACTION IMPLEMENTATIONS ==========

func _spawn_from_list(list_filename: String) -> void:
	"""Spawn objects from a list file"""
	var list_name = list_filename.trim_suffix(".txt")
	
	if not loaded_lists.has(list_name):
		load_list(list_filename)
	
	if loaded_lists.has(list_name):
		var list_data = loaded_lists[list_name]
		
		# Spawn items
		for item in list_data.items:
			_spawn_object(item)
		
		# Spawn patterns
		for pattern_name in list_data.patterns:
			for item in list_data.patterns[pattern_name]:
				_spawn_object(item)

func _spawn_object(item: Dictionary) -> void:
	"""Spawn a single object using the perfect unified system"""
	var obj_type = item.get("type", "box")
	var position = item.get("position", Vector3.ZERO)
	var properties = {}
	
	# Parse additional properties from the item
	for key in item:
		if key not in ["type", "position"]:
			properties[key] = item[key]
	
	# Check if UniversalObjectManager is available
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom:
		# Perfect path - uses StandardizedObjects with colors and materials!
		var obj = uom.create_object(obj_type, position, properties)
		if obj:
			_print("[SPAWN] Created " + obj_type + " through Universal Object Manager")
		else:
			_print("[SPAWN] Failed to create " + obj_type)
	else:
		# Fallback - try StandardizedObjects directly
		_print("[WARNING] UniversalObjectManager not found! Using StandardizedObjects...")
		var obj = StandardizedObjects.create_object(obj_type, position, properties)
		if obj:
			get_tree().FloodgateController.universal_add_child(obj, get_tree().current_scene)
			_print("[SPAWN] Created " + obj_type + " with StandardizedObjects")
			
			# Manual registration with systems
			var floodgate_node = get_node_or_null("/root/FloodgateController")
			if floodgate:
				floodgate.second_dimensional_magic(0, obj.name, obj)
			
			# Connect to Universal Inspection Bridge for clicking
			var bridge = get_node_or_null("/root/UniversalInspectionBridge") 
			if not bridge:
				bridge = get_tree().get_first_node_in_group("inspection_bridge")
			if bridge and bridge.has_method("make_object_inspectable"):
				bridge.make_object_inspectable(obj, "lists_viewer")
				_print("[LISTS] Made " + obj.name + " clickable through bridge")
			
			var world_builder = get_node_or_null("/root/WorldBuilder")
			if world_builder and "spawned_objects" in world_builder:
				world_builder.spawned_objects.append(obj)

func _spawn_object_old_method(item: Dictionary) -> void:
	"""Old spawning method - kept as fallback"""
	if not has_node("/root/UniversalEntity"):
		return
	
	var loader = get_node("/root/UniversalEntity").loader
	var obj_type = item.get("type", "box")
	var position = item.get("position", Vector3.ZERO)
	
	var scene_path = "res://scenes/objects/" + obj_type + ".tscn"
	var instance = loader.load_node_immediate(scene_path, get_tree().current_scene)
	if instance:
		instance.position = position

func _save_game_state() -> void:
	"""Save current game state to file"""
	var save_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"loaded_lists": loaded_lists.keys(),
		"active_rules": active_rules.size(),
		"execution_history": execution_history.size()
	}
	
	var file = FileAccess.open("user://game_state.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		_print("[SAVE] Game state saved")

func _make_nearby_tree_talk() -> void:
	"""Make nearby trees talk (example action)"""
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Find nearby trees
	var trees = get_tree().get_nodes_in_group("trees")
	for tree in trees:
		if tree.global_position.distance_to(player.global_position) < 5.0:
			# Make it talk (example implementation)
			if console:
				console._print_to_console("[Tree] Hello there, traveler!")

# ========== FILE MONITORING ==========

func _check_file_changes() -> void:
	"""Check if any watched files have changed"""
	for filepath in watched_files:
		var current_time = FileAccess.get_modified_time(filepath)
		if current_time > watched_files[filepath]:
			watched_files[filepath] = current_time
			_reload_file(filepath)

func _reload_file(filepath: String) -> void:
	"""Reload a changed file"""
	_print("[RELOAD] File changed: " + filepath)
	
	if filepath.begins_with(LISTS_DIR):
		var filename = filepath.replace(LISTS_DIR, "")
		load_list(filename)
	elif filepath.begins_with(RULES_DIR):
		var filename = filepath.replace(RULES_DIR, "")
		# Clear old rules from this file
		var keys_to_remove = []
		for rule_id in active_rules:
			if rule_id.begins_with(filename):
				keys_to_remove.append(rule_id)
		
		for key in keys_to_remove:
			active_rules.erase(key)
		
		# Reload rules
		load_rules(filename)

# ========== UTILITY ==========

func _print(message: String) -> void:
	if console and console.has_method("_print_to_console"):
		console._print_to_console(message)
	else:
		print(message)

func get_list(list_name: String) -> Dictionary:
	"""Get a loaded list by name"""
	return loaded_lists.get(list_name, {})

func add_rule(rule_text: String, rule_id: String = "") -> void:
	"""Add a rule programmatically"""
	var rule = _parse_rule(rule_text)
	if rule:
		if rule_id.is_empty():
			rule_id = "dynamic_" + str(active_rules.size())
		active_rules[rule_id] = rule
		rule_loaded.emit(rule_id)

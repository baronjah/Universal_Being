# ==================================================
# SCRIPT NAME: global_variable_inspector.gd
# DESCRIPTION: Inspect and modify all global variables in the game
# PURPOSE: Complete control over game state for the universal entity
# CREATED: 2025-05-27 - The Universal Entity Core
# ==================================================

extends UniversalBeingBase
class_name GlobalVariableInspector

signal variable_changed(path: String, old_value, new_value)
signal variable_tracked(path: String, value)  # Emitted when starting to track a variable

# Variable tracking
var tracked_variables: Dictionary = {}
var variable_history: Dictionary = {}
var variable_watchers: Dictionary = {}

# Categories
var variable_categories = {
	"autoloads": {},
	"singletons": {},
	"project_settings": {},
	"engine_settings": {},
	"scene_variables": {},
	"node_properties": {}
}

var console: Node

func _ready() -> void:
	name = "GlobalVariableInspector"
	console = get_node_or_null("/root/ConsoleManager")
	
	# Initial scan
	scan_all_variables()
	
	_print("[GlobalVariableInspector] Ready to inspect all variables!")

# ========== SCANNING ==========


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
func scan_all_variables() -> void:
	"""Scan and catalog all accessible variables"""
	_scan_autoloads()
	_scan_project_settings()
	_scan_engine_settings()
	_scan_scene_variables()

func _scan_autoloads() -> void:
	"""Scan all autoload singletons"""
	variable_categories.autoloads.clear()
	
	# Get all autoloads from project settings
	var autoloads = {}
	for property in ProjectSettings.get_property_list():
		if property.name.begins_with("autoload/"):
			var autoload_name = property.name.trim_prefix("autoload/")
			var node = get_node_or_null("/root/" + autoload_name)
			if node:
				autoloads[autoload_name] = _scan_node_properties(node)
	
	variable_categories.autoloads = autoloads

func _scan_project_settings() -> void:
	"""Scan all project settings"""
	variable_categories.project_settings.clear()
	
	for property in ProjectSettings.get_property_list():
		if not property.name.begins_with("autoload/"):
			variable_categories.project_settings[property.name] = {
				"value": ProjectSettings.get_setting(property.name),
				"type": property.type,
				"hint": property.hint
			}

func _scan_engine_settings() -> void:
	"""Scan engine-level settings"""
	variable_categories.engine_settings = {
		"fps": Engine.get_frames_per_second(),
		"target_fps": Engine.max_fps,
		"time_scale": Engine.time_scale,
		"physics_ticks": Engine.physics_ticks_per_second,
		"print_error_messages": Engine.print_error_messages
	}

func _scan_scene_variables() -> void:
	"""Scan current scene for interesting variables"""
	variable_categories.scene_variables.clear()
	
	var current_scene = get_tree().current_scene
	if current_scene:
		variable_categories.scene_variables = _scan_node_recursive(current_scene)

func _scan_node_properties(node: Node) -> Dictionary:
	"""Get all properties of a node"""
	var properties = {}
	
	for property in node.get_property_list():
		# Skip built-in properties we don't care about
		if property.name in ["_import_path", "script", "process_priority"]:
			continue
			
		var value = node.get(property.name)
		if value != null:
			properties[property.name] = {
				"value": value,
				"type": property.type,
				"class": property.class_name
			}
	
	return properties

func _scan_node_recursive(node: Node, max_depth: int = 3, current_depth: int = 0) -> Dictionary:
	"""Recursively scan node tree"""
	if current_depth >= max_depth:
		return {}
	
	var result = {
		"_node_info": {
			"name": node.name,
			"class": node.get_class(),
			"path": node.get_path()
		},
		"_properties": _scan_node_properties(node),
		"_children": {}
	}
	
	for child in node.get_children():
		result._children[child.name] = _scan_node_recursive(child, max_depth, current_depth + 1)
	
	return result

# ========== INSPECTION ==========

func get_variable(path: String):
	"""Get a variable by path (e.g., 'autoloads/ConsoleManager/is_visible')"""
	var parts = path.split("/")
	var current = variable_categories
	
	for part in parts:
		if current is Dictionary and current.has(part):
			current = current[part]
		else:
			return null
	
	if current is Dictionary and current.has("value"):
		return current.value
	return current

func set_variable(path: String, value) -> bool:
	"""Set a variable by path"""
	var parts = path.split("/")
	var category = parts[0]
	
	match category:
		"autoloads":
			return _set_autoload_variable(parts, value)
		"project_settings":
			return _set_project_setting(parts, value)
		"engine_settings":
			return _set_engine_setting(parts, value)
		_:
			return false

func _set_autoload_variable(parts: Array, value) -> bool:
	"""Set an autoload variable"""
	if parts.size() < 3:
		return false
	
	var autoload_name = parts[1]
	var property_path = "/".join(parts.slice(2))
	
	var node = get_node_or_null("/root/" + autoload_name)
	if node:
		var old_value = node.get(property_path)
		node.set(property_path, value)
		variable_changed.emit("/".join(parts), old_value, value)
		return true
	
	return false

func _set_project_setting(parts: Array, value) -> bool:
	"""Set a project setting"""
	if parts.size() < 2:
		return false
	
	var setting_name = "/".join(parts.slice(1))
	var old_value = ProjectSettings.get_setting(setting_name)
	ProjectSettings.set_setting(setting_name, value)
	variable_changed.emit("/".join(parts), old_value, value)
	return true

func _set_engine_setting(parts: Array, value) -> bool:
	"""Set an engine setting"""
	if parts.size() < 2:
		return false
	
	var setting = parts[1]
	var old_value = null
	
	match setting:
		"target_fps":
			old_value = Engine.max_fps
			Engine.max_fps = value
		"time_scale":
			old_value = Engine.time_scale
			Engine.time_scale = value
		"physics_ticks":
			old_value = Engine.physics_ticks_per_second
			Engine.physics_ticks_per_second = value
		"print_error_messages":
			old_value = Engine.print_error_messages
			Engine.print_error_messages = value
		_:
			return false
	
	variable_changed.emit("/".join(parts), old_value, value)
	return true

# ========== WATCHING ==========

func watch_variable(path: String, callback: Callable) -> void:
	"""Watch a variable for changes"""
	if not variable_watchers.has(path):
		variable_watchers[path] = []
	variable_watchers[path].append(callback)

func unwatch_variable(path: String, callback: Callable) -> void:
	"""Stop watching a variable"""
	if variable_watchers.has(path):
		variable_watchers[path].erase(callback)

# ========== EXPORT ==========

func export_to_txt(filepath: String) -> void:
	"""Export all variables to a text file"""
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		_print("[ERROR] Cannot create file: " + filepath)
		return
	
	file.store_line("# GLOBAL VARIABLE DUMP")
	file.store_line("# Generated: " + Time.get_datetime_string_from_system())
	file.store_line("# ================================")
	file.store_line("")
	
	for category in variable_categories:
		file.store_line("[" + category.to_upper() + "]")
		_write_variables_recursive(file, variable_categories[category], "")
		file.store_line("")
	
	file.close()
	_print("[GlobalVariableInspector] Exported to: " + filepath)

func _write_variables_recursive(file: FileAccess, data: Dictionary, indent: String) -> void:
	"""Recursively write variables to file"""
	for key in data:
		if key.begins_with("_"):
			continue
			
		var value = data[key]
		if value is Dictionary:
			if value.has("value"):
				file.store_line(indent + key + " = " + str(value.value))
			else:
				file.store_line(indent + key + ":")
				_write_variables_recursive(file, value, indent + "  ")
		else:
			file.store_line(indent + key + " = " + str(value))

# ========== PUBLIC API ==========

func get_all_variables() -> Dictionary:
	"""Get all tracked variables"""
	return variable_categories

func search_variables(search_term: String) -> Array:
	"""Search for variables by name"""
	var results = []
	_search_recursive(variable_categories, "", search_term.to_lower(), results)
	return results

func _search_recursive(data: Dictionary, path: String, search: String, results: Array) -> void:
	"""Recursive search helper"""
	for key in data:
		var current_path = path + "/" + key if path else key
		
		if key.to_lower().contains(search):
			results.append({
				"path": current_path,
				"value": data[key].value if data[key] is Dictionary and data[key].has("value") else data[key]
			})
		
		if data[key] is Dictionary:
			_search_recursive(data[key], current_path, search, results)

func _print(message: String) -> void:
	if console and console.has_method("_print_to_console"):
		console._print_to_console(message)
	else:
		print(message)

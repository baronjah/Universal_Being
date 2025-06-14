# 🏛️ Universal Being 3D Blueprint Parser - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: universal_being_3d_blueprint_parser.gd
# DESCRIPTION: Parse TXT blueprints for 3D Universal Being interfaces
# PURPOSE: Convert human-readable blueprints into 3D interface elements
# ==================================================

extends UniversalBeingBase
class_name UniversalBeing3DBlueprintParser

# Blueprint data structure
var parsed_blueprint: Dictionary = {}
var blueprint_elements: Array = []


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func parse_blueprint_file(file_path: String) -> Dictionary:
	"""Parse a 3D blueprint file and return structured data"""
	
	if not FileAccess.file_exists(file_path):
		print("[BlueprintParser] Blueprint file not found: ", file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("[BlueprintParser] Failed to open blueprint file: ", file_path)
		return {}
	
	blueprint_elements.clear()
	var line_number = 0
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		line_number += 1
		
		# Skip comments and empty lines
		if line.begins_with("#") or line.is_empty():
			continue
		
		# Parse element line
		var element = _parse_element_line(line, line_number)
		if element:
			blueprint_elements.append(element)
	
	file.close()
	
	parsed_blueprint = {
		"elements": blueprint_elements,
		"total_elements": blueprint_elements.size(),
		"file_path": file_path
	}
	
	print("[BlueprintParser] Parsed ", blueprint_elements.size(), " elements from ", file_path)
	return parsed_blueprint

func _parse_element_line(line: String, line_number: int) -> Dictionary:
	"""Parse a single element line into structured data"""
	
	var parts = line.split("|")
	if parts.size() < 8:
		print("[BlueprintParser] Invalid line ", line_number, ": ", line)
		return {}
	
	var element = {
		"type": parts[0].strip_edges(),
		"position": Vector3(parts[1].to_float(), parts[2].to_float(), parts[3].to_float()),
		"size": Vector2(parts[4].to_float(), parts[5].to_float()),
		"rotation": parts[6].to_float(),
		"text": parts[7].strip_edges(),
		"color": parts[8].strip_edges() if parts.size() > 8 else "white",
		"properties": _parse_properties(parts[9] if parts.size() > 9 else ""),
		"line_number": line_number
	}
	
	return element

func _parse_properties(properties_string: String) -> Dictionary:
	"""Parse properties string like 'transparent:0.9,rounded:10,glow:true'"""
	
	var properties = {}
	if properties_string.is_empty():
		return properties
	
	var prop_pairs = properties_string.split(",")
	for pair in prop_pairs:
		var key_value = pair.split(":")
		if key_value.size() == 2:
			var key = key_value[0].strip_edges()
			var value_str = key_value[1].strip_edges()
			
			# Convert values to appropriate types
			var value = _convert_property_value(value_str)
			properties[key] = value
	
	return properties

func _convert_property_value(value_str: String) -> Variant:
	"""Convert string property values to appropriate types"""
	
	# Boolean values
	if value_str.to_lower() == "true":
		return true
	elif value_str.to_lower() == "false":
		return false
	
	# Numeric values
	elif value_str.is_valid_float():
		return value_str.to_float()
	elif value_str.is_valid_int():
		return value_str.to_int()
	
	# String values (default)
	else:
		return value_str

func get_elements_by_type(element_type: String) -> Array:
	"""Get all elements of a specific type"""
	
	var filtered_elements = []
	for element in blueprint_elements:
		if element.type == element_type:
			filtered_elements.append(element)
	
	return filtered_elements

func get_element_by_text(text: String) -> Dictionary:
	"""Find first element with matching text"""
	
	for element in blueprint_elements:
		if element.text == text:
			return element
	
	return {}

func create_default_blueprint(interface_type: String) -> Dictionary:
	"""Create a default blueprint when file doesn't exist"""
	
	match interface_type:
		"asset_creator":
			return _create_default_asset_creator()
		"console":
			return _create_default_console()
		"inspector":
			return _create_default_inspector()
		_:
			return _create_generic_blueprint(interface_type)

func _create_default_asset_creator() -> Dictionary:
	"""Default asset creator blueprint"""
	
	return {
		"elements": [
			{
				"type": "panel",
				"position": Vector3(0, 0, 0),
				"size": Vector2(4, 3),
				"rotation": 0,
				"text": "Asset Creator",
				"color": "dark_blue",
				"properties": {"transparent": 0.9, "rounded": 10}
			},
			{
				"type": "button_3d",
				"position": Vector3(-1, 0.5, 0.1),
				"size": Vector2(1.5, 0.4),
				"rotation": 0,
				"text": "Create Cube",
				"color": "orange",
				"properties": {"action": "create_cube", "glow": "orange"}
			},
			{
				"type": "button_3d",
				"position": Vector3(1, 0.5, 0.1),
				"size": Vector2(1.5, 0.4),
				"rotation": 0,
				"text": "Create Sphere",
				"color": "green",
				"properties": {"action": "create_sphere", "glow": "green"}
			}
		],
		"total_elements": 3,
		"file_path": "default"
	}

func _create_default_console() -> Dictionary:
	"""Default console blueprint"""
	
	return {
		"elements": [
			{
				"type": "panel",
				"position": Vector3(0, 0, 0),
				"size": Vector2(5, 3),
				"rotation": 0,
				"text": "Console",
				"color": "dark_green",
				"properties": {"transparent": 0.85, "rounded": 5}
			},
			{
				"type": "button_3d",
				"position": Vector3(-1.5, 0, 0.1),
				"size": Vector2(1, 0.3),
				"rotation": 0,
				"text": "Help",
				"color": "cyan",
				"properties": {"action": "help_command"}
			},
			{
				"type": "button_3d",
				"position": Vector3(1.5, 0, 0.1),
				"size": Vector2(1, 0.3),
				"rotation": 0,
				"text": "Clear",
				"color": "yellow",
				"properties": {"action": "clear_console"}
			}
		],
		"total_elements": 3,
		"file_path": "default"
	}

func _create_default_inspector() -> Dictionary:
	"""Default inspector blueprint"""
	
	return {
		"elements": [
			{
				"type": "panel",
				"position": Vector3(0, 0, 0),
				"size": Vector2(3, 4),
				"rotation": 0,
				"text": "Inspector",
				"color": "dark_purple",
				"properties": {"transparent": 0.9, "rounded": 8}
			},
			{
				"type": "text_3d",
				"position": Vector3(0, 1.5, 0.1),
				"size": Vector2(2.5, 0.3),
				"rotation": 0,
				"text": "Object Inspector",
				"color": "white",
				"properties": {"font_size": 18, "glow": true}
			}
		],
		"total_elements": 2,
		"file_path": "default"
	}

func _create_generic_blueprint(interface_type: String) -> Dictionary:
	"""Generic blueprint for unknown interface types"""
	
	return {
		"elements": [
			{
				"type": "panel",
				"position": Vector3(0, 0, 0),
				"size": Vector2(3, 2),
				"rotation": 0,
				"text": interface_type.capitalize(),
				"color": "gray",
				"properties": {"transparent": 0.8, "rounded": 5}
			},
			{
				"type": "text_3d",
				"position": Vector3(0, 0.5, 0.1),
				"size": Vector2(2.5, 0.3),
				"rotation": 0,
				"text": interface_type.capitalize() + " Interface",
				"color": "white",
				"properties": {"font_size": 16}
			},
			{
				"type": "button_3d",
				"position": Vector3(0, -0.5, 0.1),
				"size": Vector2(1.5, 0.3),
				"rotation": 0,
				"text": "Close",
				"color": "red",
				"properties": {"action": "close_interface"}
			}
		],
		"total_elements": 3,
		"file_path": "default"
	}
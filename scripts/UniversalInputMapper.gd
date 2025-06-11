# UNIVERSAL INPUT MAPPER - CUSTOMIZABLE 3D PROGRAMMING CONTROLS
# Store any button combo for any function in user:// directory
extends Node
class_name UniversalInputMapper

signal input_mapping_changed(action_name: String, new_key: int)
signal settings_loaded()

# Default input mappings - can be overridden by user settings
var default_mappings = {
	"interact": KEY_E,
	"create_text": KEY_T, 
	"rename_object": KEY_R,
	"edit_function": KEY_F,
	"delete_object": KEY_X,
	"duplicate_object": KEY_D,
	"grab_move": KEY_G,
	"show_help": KEY_H,
	"manipulation_mode": KEY_M,
	"visual_debug": KEY_V,
	"new_function": KEY_B,
	"quick_spawn": KEY_SPACE,
	"settings_menu": KEY_TAB,
	"escape_cancel": KEY_ESCAPE,
	"create_word": KEY_C,
	"notepad_toggle": KEY_N
}

# Current active mappings (loaded from user settings or defaults)
var current_mappings = {}

# Combo support - for multi-key combinations
var combo_mappings = {}

# Settings file path
const SETTINGS_FILE = "user://input_settings.json"
const COMBO_SETTINGS_FILE = "user://input_combos.json"

func _ready():
	print("🎮 Universal Input Mapper: Initializing customizable controls...")
	load_user_settings()

func load_user_settings():
	"""Load user input settings from persistent storage"""
	current_mappings = default_mappings.duplicate()
	
	# Load single key mappings
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var result = json.parse(json_text)
			
			if result == OK and json.data is Dictionary:
				var user_mappings = json.data
				# Merge user settings with defaults
				for action in user_mappings:
					if action in default_mappings:
						current_mappings[action] = user_mappings[action]
				print("📂 Loaded user input settings: %d mappings" % user_mappings.size())
			else:
				print("⚠️ Failed to parse input settings, using defaults")
	
	# Load combo mappings
	if FileAccess.file_exists(COMBO_SETTINGS_FILE):
		var file = FileAccess.open(COMBO_SETTINGS_FILE, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var result = json.parse(json_text)
			
			if result == OK and json.data is Dictionary:
				combo_mappings = json.data
				print("🎯 Loaded combo mappings: %d combinations" % combo_mappings.size())
	
	settings_loaded.emit()
	print("✅ Input Mapper ready - %d actions mapped" % current_mappings.size())

func save_user_settings():
	"""Save current input mappings to persistent storage"""
	# Save single key mappings
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(current_mappings))
		file.close()
		print("💾 Saved input settings to user://")
	
	# Save combo mappings
	var combo_file = FileAccess.open(COMBO_SETTINGS_FILE, FileAccess.WRITE)
	if combo_file:
		var json = JSON.new()
		combo_file.store_string(json.stringify(combo_mappings))
		combo_file.close()
		print("💾 Saved combo settings to user://")

func remap_action(action_name: String, new_key: int):
	"""Change the key mapping for an action"""
	if action_name in current_mappings:
		var old_key = current_mappings[action_name]
		current_mappings[action_name] = new_key
		save_user_settings()
		input_mapping_changed.emit(action_name, new_key)
		print("🔄 Remapped '%s': %s -> %s" % [action_name, OS.get_keycode_string(old_key), OS.get_keycode_string(new_key)])
		return true
	return false

func add_combo_mapping(combo_name: String, key_sequence: Array):
	"""Add a multi-key combination mapping"""
	combo_mappings[combo_name] = key_sequence
	save_user_settings()
	print("🎯 Added combo '%s': %s" % [combo_name, _format_key_sequence(key_sequence)])

func remove_combo_mapping(combo_name: String):
	"""Remove a combo mapping"""
	if combo_name in combo_mappings:
		combo_mappings.erase(combo_name)
		save_user_settings()
		print("🗑️ Removed combo: %s" % combo_name)

func get_key_for_action(action_name: String) -> int:
	"""Get the current key mapped to an action"""
	return current_mappings.get(action_name, KEY_NONE)

func get_action_for_key(keycode: int) -> String:
	"""Find which action is mapped to a specific key"""
	for action in current_mappings:
		if current_mappings[action] == keycode:
			return action
	return ""

func is_action_pressed(action_name: String, event: InputEvent) -> bool:
	"""Check if an action's key is pressed"""
	if event is InputEventKey and event.pressed:
		var mapped_key = get_key_for_action(action_name)
		return event.keycode == mapped_key
	return false

func check_combo_input(event: InputEvent) -> String:
	"""Check if a key combo is being executed"""
	# This would need a more sophisticated combo detection system
	# For now, return empty string
	return ""

func reset_to_defaults():
	"""Reset all mappings to default values"""
	current_mappings = default_mappings.duplicate()
	combo_mappings.clear()
	save_user_settings()
	print("🔄 Reset all inputs to defaults")

func get_all_mappings() -> Dictionary:
	"""Get all current mappings for display in settings UI"""
	return current_mappings.duplicate()

func get_all_combos() -> Dictionary:
	"""Get all combo mappings"""
	return combo_mappings.duplicate()

func _format_key_sequence(keys: Array) -> String:
	"""Format a key sequence for display"""
	var formatted = []
	for key in keys:
		formatted.append(OS.get_keycode_string(key))
	return " + ".join(formatted)

func export_settings() -> String:
	"""Export settings as JSON string for sharing"""
	var export_data = {
		"single_keys": current_mappings,
		"combos": combo_mappings,
		"exported_at": Time.get_datetime_string_from_system()
	}
	var json = JSON.new()
	return json.stringify(export_data)

func import_settings(json_string: String) -> bool:
	"""Import settings from JSON string"""
	var json = JSON.new()
	var result = json.parse(json_string)
	
	if result == OK and json.data is Dictionary:
		var import_data = json.data
		
		if "single_keys" in import_data:
			# Validate imported keys
			for action in import_data.single_keys:
				if action in default_mappings:
					current_mappings[action] = import_data.single_keys[action]
		
		if "combos" in import_data:
			combo_mappings = import_data.combos
		
		save_user_settings()
		print("📥 Imported input settings successfully")
		return true
	
	print("❌ Failed to import settings - invalid format")
	return false

func get_settings_summary() -> String:
	"""Get a formatted summary of current settings"""
	var summary = "🎮 INPUT SETTINGS SUMMARY\n\n"
	
	summary += "SINGLE KEY MAPPINGS:\n"
	for action in current_mappings:
		var key_name = OS.get_keycode_string(current_mappings[action])
		summary += "  %s = %s\n" % [action.to_upper(), key_name]
	
	if combo_mappings.size() > 0:
		summary += "\nCOMBO MAPPINGS:\n"
		for combo in combo_mappings:
			summary += "  %s = %s\n" % [combo.to_upper(), _format_key_sequence(combo_mappings[combo])]
	
	return summary

# Static helper functions
static func keycode_to_string(keycode: int) -> String:
	"""Convert keycode to readable string"""
	return OS.get_keycode_string(keycode)

static func string_to_keycode(key_string: String) -> int:
	"""Convert string to keycode (basic implementation)"""
	# This would need a comprehensive lookup table
	match key_string.to_upper():
		"A": return KEY_A
		"B": return KEY_B
		"C": return KEY_C
		"D": return KEY_D
		"E": return KEY_E
		"F": return KEY_F
		"G": return KEY_G
		"H": return KEY_H
		"M": return KEY_M
		"N": return KEY_N
		"R": return KEY_R
		"T": return KEY_T
		"V": return KEY_V
		"X": return KEY_X
		"TAB": return KEY_TAB
		"SPACE": return KEY_SPACE
		"ESCAPE": return KEY_ESCAPE
		_: return KEY_NONE
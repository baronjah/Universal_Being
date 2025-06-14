extends Node
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🔧 MODULAR FUNCTIONS - CODE REUSE WITH STRING PARAMETERS 🔧
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/modular_functions.gd
# 🎯 FILE GOAL: Reusable functions with string-based parameters for code variations
# 🔗 CONNECTED FILES:
#    - core/debug_scene_manager.gd (debug window creation)
#    - core/main_game_controller.gd (controller integration)
#    - ALL systems (universal function patterns)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - String-based function parameters for dynamic behavior
#    - Modular code creation with templates
#    - Dynamic data splitting and processing
#    - Universal function patterns for any system
#
# 🎮 USER EXPERIENCE: Accelerated development through code reuse
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name ModularFunctions

# ─────────────────────────────────────────────────────────────────────────────────
# 🔧 STRING-BASED DATA PROCESSORS - UNIVERSAL PATTERNS
# ─────────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────────
# 📝 PROCESS WORD DATA - STRING SPLITTING WITH CUSTOM SEPARATORS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: String data with custom separator for splitting
# PROCESS: Splits data and processes each part according to type
# OUTPUT: Array of processed elements ready for use
# CHANGES: Converts raw string data into structured game objects
# CONNECTION: Used by word system, UI system, and any data import
# ─────────────────────────────────────────────────────────────────────────────────
static func process_words(input_data: String, separator: String = ",") -> Array:
	var parts = input_data.split(separator)
	var processed = []
	for part in parts:
		var clean_word = part.strip_edges()
		if clean_word.length() > 0:
			processed.append({
				"text": clean_word,
				"length": clean_word.length(),
				"frequency": 1.0,
				"evolution_stage": 0
			})
	return processed

static func process_coordinates(input_data: String, separator: String = ",") -> Array:
	var parts = input_data.split(separator)
	var processed = []
	for i in range(0, parts.size(), 3):
		if i + 2 < parts.size():
			var x = parts[i].strip_edges().to_float()
			var y = parts[i + 1].strip_edges().to_float()
			var z = parts[i + 2].strip_edges().to_float()
			processed.append(Vector3(x, y, z))
	return processed

static func process_colors(input_data: String, separator: String = ",") -> Array:
	var parts = input_data.split(separator)
	var processed = []
	for part in parts:
		var color_str = part.strip_edges()
		if color_str.begins_with("#"):
			processed.append(Color.html(color_str))
		elif color_str.contains(" "):
			var rgb = color_str.split(" ")
			if rgb.size() >= 3:
				processed.append(Color(rgb[0].to_float(), rgb[1].to_float(), rgb[2].to_float()))
	return processed

# ─────────────────────────────────────────────────────────────────────────────────
# 🎛️ SETTINGS PROCESSORS - DYNAMIC CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────────
static func process_settings(input_data: String, separator: String = ";") -> Dictionary:
	var parts = input_data.split(separator)
	var settings = {}
	for part in parts:
		var key_value = part.split("=")
		if key_value.size() == 2:
			var key = key_value[0].strip_edges()
			var value = key_value[1].strip_edges()
			# Auto-detect value type
			if value.is_valid_float():
				settings[key] = value.to_float()
			elif value.to_lower() in ["true", "false"]:
				settings[key] = value.to_lower() == "true"
			else:
				settings[key] = value
	return settings

static func process_function_calls(input_data: String, separator: String = "|") -> Array:
	var parts = input_data.split(separator)
	var function_calls = []
	for part in parts:
		var func_parts = part.split(":")
		if func_parts.size() >= 2:
			var func_name = func_parts[0].strip_edges()
			var params = func_parts[1].split(",")
			var clean_params = []
			for param in params:
				clean_params.append(param.strip_edges())
			function_calls.append({
				"function": func_name,
				"parameters": clean_params
			})
	return function_calls

# ─────────────────────────────────────────────────────────────────────────────────
# 🪟 DEBUG WINDOW CREATORS - MODULAR UI GENERATION
# ─────────────────────────────────────────────────────────────────────────────────

static func create_debug_window_camera(target_camera: Camera3D, debug_manager: DebugSceneManager) -> Control:
	var window = debug_manager._create_debug_panel("camera_debug", "Camera Debug", Vector2(300, 250))
	var content = window.find_child("ContentArea")
	
	# Camera position controls
	var pos_label = Label.new()
	pos_label.text = "📍 Position"
	content.add_child(pos_label)
	
	var pos_inputs = HBoxContainer.new()
	content.add_child(pos_inputs)
	
	for coord in ["X", "Y", "Z"]:
		var input = SpinBox.new()
		input.name = coord + "_Position"
		input.value = target_camera.global_position[coord.to_lower()]
		input.step = 0.1
		input.allow_greater = true
		input.allow_lesser = true
		input.value_changed.connect(_on_camera_position_changed.bind(target_camera, coord.to_lower()))
		pos_inputs.add_child(input)
	
	# Camera rotation controls
	var rot_label = Label.new()
	rot_label.text = "🔄 Rotation"
	content.add_child(rot_label)
	
	var rot_inputs = HBoxContainer.new()
	content.add_child(rot_inputs)
	
	for coord in ["X", "Y", "Z"]:
		var input = SpinBox.new()
		input.name = coord + "_Rotation"
		input.value = rad_to_deg(target_camera.rotation[coord.to_lower()])
		input.step = 1.0
		input.allow_greater = true
		input.allow_lesser = true
		input.value_changed.connect(_on_camera_rotation_changed.bind(target_camera, coord.to_lower()))
		rot_inputs.add_child(input)
	
	return window

static func create_debug_window_word_entity(target_word: WordEntity, debug_manager: DebugSceneManager) -> Control:
	var window = debug_manager._create_debug_panel("word_debug", "Word Entity Debug", Vector2(350, 300))
	var content = window.find_child("ContentArea")
	
	# Word properties
	var text_label = Label.new()
	text_label.text = "📝 Word: " + target_word.get_word_text()
	content.add_child(text_label)
	
	var evolution_label = Label.new()
	evolution_label.text = "⚡ Evolution: " + str(target_word.evolution_state)
	content.add_child(evolution_label)
	
	# Evolution controls
	var evolution_slider = HSlider.new()
	evolution_slider.min_value = 0
	evolution_slider.max_value = 5
	evolution_slider.value = target_word.evolution_state
	evolution_slider.step = 1
	evolution_slider.value_changed.connect(_on_word_evolution_changed.bind(target_word))
	content.add_child(evolution_slider)
	
	# Visual controls
	var glow_check = CheckBox.new()
	glow_check.text = "✨ Glow Effect"
	glow_check.button_pressed = target_word.evolution_state > 2
	content.add_child(glow_check)
	
	return window

static func create_debug_window_notepad(target_notepad: Notepad3DEnvironment, debug_manager: DebugSceneManager) -> Control:
	var window = debug_manager._create_debug_panel("notepad_debug", "Notepad 3D Debug", Vector2(400, 350))
	var content = window.find_child("ContentArea")
	
	# Layer controls
	var layer_label = Label.new()
	layer_label.text = "📚 Layer Controls"
	content.add_child(layer_label)
	
	for i in range(5):
		var layer_container = HBoxContainer.new()
		content.add_child(layer_container)
		
		var layer_name = Label.new()
		layer_name.text = "Layer " + str(i) + ":"
		layer_name.custom_minimum_size.x = 80
		layer_container.add_child(layer_name)
		
		var visibility_check = CheckBox.new()
		visibility_check.text = "Visible"
		visibility_check.button_pressed = true
		layer_container.add_child(visibility_check)
		
		var depth_spin = SpinBox.new()
		depth_spin.value = [5.0, 8.0, 12.0, 16.0, 20.0][i]
		depth_spin.step = 0.5
		layer_container.add_child(depth_spin)
	
	return window

# ─────────────────────────────────────────────────────────────────────────────────
# 📡 SIGNAL HANDLERS FOR DEBUG WINDOWS
# ─────────────────────────────────────────────────────────────────────────────────
static func _on_camera_position_changed(camera: Camera3D, coord: String, value: float) -> void:
	var pos = camera.global_position
	match coord:
		"x": pos.x = value
		"y": pos.y = value
		"z": pos.z = value
	camera.global_position = pos
	print("📍 Camera position updated: ", coord, " = ", value)

static func _on_camera_rotation_changed(camera: Camera3D, coord: String, value: float) -> void:
	var rot = camera.rotation
	var rad_value = deg_to_rad(value)
	match coord:
		"x": rot.x = rad_value
		"y": rot.y = rad_value
		"z": rot.z = rad_value
	camera.rotation = rot
	print("🔄 Camera rotation updated: ", coord, " = ", value, "°")

static func _on_word_evolution_changed(word: WordEntity, value: float) -> void:
	word.evolution_state = int(value)
	word.update_properties({"evolution_state": int(value)})
	print("⚡ Word evolution updated: ", word.get_word_text(), " = ", int(value))

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 VISUAL DEBUG FUNCTIONS - GLOW AND WIREFRAMES
# ─────────────────────────────────────────────────────────────────────────────────
static func add_wireframe_to_object(object: Node3D, color: Color = Color.CYAN) -> void:
	# Add wireframe visualization to any 3D object
	var wireframe_material = StandardMaterial3D.new()
	wireframe_material.flags_unshaded = true
	wireframe_material.wireframe = true
	wireframe_material.albedo_color = color
	
	if object is MeshInstance3D:
		var mesh_instance = object as MeshInstance3D
		mesh_instance.material_overlay = wireframe_material

static func add_glow_to_object(object: Node3D, glow_color: Color = Color.WHITE, intensity: float = 1.0) -> void:
	# Add glow effect to any 3D object
	if object is MeshInstance3D:
		var mesh_instance = object as MeshInstance3D
		var material = mesh_instance.get_surface_override_material(0)
		if not material:
			material = StandardMaterial3D.new()
			mesh_instance.set_surface_override_material(0, material)
		
		if material is StandardMaterial3D:
			var std_material = material as StandardMaterial3D
			std_material.emission = glow_color
			std_material.emission_energy = intensity

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 FUNCTION INSPECTION UTILITIES
# ─────────────────────────────────────────────────────────────────────────────────
static func get_object_function_list(object: Object) -> Array:
	var function_list = []
	var method_list = object.get_method_list()
	
	for method in method_list:
		# Filter out built-in Godot methods
		if not method.name.begins_with("_") and not method.name in ["get", "set", "connect", "disconnect"]:
			function_list.append({
				"name": method.name,
				"parameters": method.args,
				"return_type": method.return.type if method.has("return") else "void"
			})
	
	return function_list

static func call_function_with_string_params(object: Object, function_name: String, param_string: String, separator: String = ",") -> Variant:
	var params = param_string.split(separator)
	var clean_params = []
	
	for param in params:
		var clean_param = param.strip_edges()
		# Try to convert to appropriate type
		if clean_param.is_valid_float():
			clean_params.append(clean_param.to_float())
		elif clean_param.to_lower() in ["true", "false"]:
			clean_params.append(clean_param.to_lower() == "true")
		else:
			clean_params.append(clean_param)
	
	# Call the function with converted parameters
	return object.callv(function_name, clean_params)
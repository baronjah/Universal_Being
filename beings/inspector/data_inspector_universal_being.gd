# DATA INSPECTOR UNIVERSAL BEING - THE SPIRIT WHISPER OF DATA
# Examines any data and reports what it truly is
extends UniversalBeing
class_name DataInspectorUniversalBeing

signal data_examined(data_info: Dictionary)
signal type_detected(data_type: String, details: Dictionary)
signal whisper_spoken(message: String)

# Data examination tools
var inspection_results: Array = []
var data_history: Array = []
var whisper_messages: Array = []

# Visual elements
var inspection_sphere: MeshInstance3D = null
var data_display: Label3D = null
var whisper_bubbles: Array = []

# Pentagon lifecycle
func pentagon_init():
	super.pentagon_init()
	being_type = "data_inspector"
	being_name = "Data Inspector Universal Being"
	consciousness_level = 5
	print("👁️ Data Inspector: Awakening the spirit whisper of data...")

func pentagon_ready():
	super.pentagon_ready()
	create_inspection_interface()
	print("✨ Data Inspector: Ready to whisper the secrets of data!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	update_inspection_display(delta)

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			inspect_nearby_data()

func pentagon_sewers():
	save_inspection_history()
	super.pentagon_sewers()

func create_inspection_interface():
	"""Create the data inspection interface"""
	print("🔍 Creating data inspection interface...")
	
	# Central inspection sphere
	inspection_sphere = MeshInstance3D.new()
	inspection_sphere.name = "InspectionSphere"
	var sphere = SphereMesh.new()
	sphere.radius = 2.0
	inspection_sphere.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.8, 1.0, 0.7)
	material.emission_enabled = true
	material.emission = Color.CYAN * 2.0
	material.emission_energy = 1.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inspection_sphere.material_override = material
	add_child(inspection_sphere)
	
	# Data display
	data_display = Label3D.new()
	data_display.name = "DataDisplay"
	data_display.text = "👁️ DATA INSPECTOR\nReady to examine..."
	data_display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	data_display.position = Vector3(0, 4, 0)
	data_display.modulate = Color.CYAN
	data_display.pixel_size = 0.015
	add_child(data_display)

func inspect_data(data: Variant) -> Dictionary:
	"""The main inspection function - examines any data and whispers its secrets"""
	var inspection = {}
	
	# Basic type information using Godot's typeof()
	var type_id = typeof(data)
	var type_name = _get_type_name(type_id)
	
	inspection["type_id"] = type_id
	inspection["type_name"] = type_name
	inspection["raw_data"] = data
	
	# Use Godot's var_to_str() to get string representation
	inspection["string_representation"] = var_to_str(data)
	
	# Deep inspection based on type
	match type_id:
		TYPE_NIL:
			inspection.merge(_inspect_nil(data))
		TYPE_BOOL:
			inspection.merge(_inspect_bool(data))
		TYPE_INT:
			inspection.merge(_inspect_int(data))
		TYPE_FLOAT:
			inspection.merge(_inspect_float(data))
		TYPE_STRING:
			inspection.merge(_inspect_string(data))
		TYPE_VECTOR2:
			inspection.merge(_inspect_vector2(data))
		TYPE_VECTOR2I:
			inspection.merge(_inspect_vector2i(data))
		TYPE_RECT2:
			inspection.merge(_inspect_rect2(data))
		TYPE_RECT2I:
			inspection.merge(_inspect_rect2i(data))
		TYPE_VECTOR3:
			inspection.merge(_inspect_vector3(data))
		TYPE_VECTOR3I:
			inspection.merge(_inspect_vector3i(data))
		TYPE_TRANSFORM2D:
			inspection.merge(_inspect_transform2d(data))
		TYPE_VECTOR4:
			inspection.merge(_inspect_vector4(data))
		TYPE_VECTOR4I:
			inspection.merge(_inspect_vector4i(data))
		TYPE_PLANE:
			inspection.merge(_inspect_plane(data))
		TYPE_QUATERNION:
			inspection.merge(_inspect_quaternion(data))
		TYPE_AABB:
			inspection.merge(_inspect_aabb(data))
		TYPE_BASIS:
			inspection.merge(_inspect_basis(data))
		TYPE_TRANSFORM3D:
			inspection.merge(_inspect_transform3d(data))
		TYPE_PROJECTION:
			inspection.merge(_inspect_projection(data))
		TYPE_COLOR:
			inspection.merge(_inspect_color(data))
		TYPE_STRING_NAME:
			inspection.merge(_inspect_string_name(data))
		TYPE_NODE_PATH:
			inspection.merge(_inspect_node_path(data))
		TYPE_RID:
			inspection.merge(_inspect_rid(data))
		TYPE_OBJECT:
			inspection.merge(_inspect_object(data))
		TYPE_CALLABLE:
			inspection.merge(_inspect_callable(data))
		TYPE_SIGNAL:
			inspection.merge(_inspect_signal(data))
		TYPE_DICTIONARY:
			inspection.merge(_inspect_dictionary(data))
		TYPE_ARRAY:
			inspection.merge(_inspect_array(data))
		TYPE_PACKED_BYTE_ARRAY:
			inspection.merge(_inspect_packed_byte_array(data))
		TYPE_PACKED_INT32_ARRAY:
			inspection.merge(_inspect_packed_int32_array(data))
		TYPE_PACKED_INT64_ARRAY:
			inspection.merge(_inspect_packed_int64_array(data))
		TYPE_PACKED_FLOAT32_ARRAY:
			inspection.merge(_inspect_packed_float32_array(data))
		TYPE_PACKED_FLOAT64_ARRAY:
			inspection.merge(_inspect_packed_float64_array(data))
		TYPE_PACKED_STRING_ARRAY:
			inspection.merge(_inspect_packed_string_array(data))
		TYPE_PACKED_VECTOR2_ARRAY:
			inspection.merge(_inspect_packed_vector2_array(data))
		TYPE_PACKED_VECTOR3_ARRAY:
			inspection.merge(_inspect_packed_vector3_array(data))
		TYPE_PACKED_COLOR_ARRAY:
			inspection.merge(_inspect_packed_color_array(data))
		_:
			inspection.merge(_inspect_unknown(data))
	
	# Additional meta-inspection
	inspection["size_in_memory"] = _estimate_memory_size(data)
	inspection["is_reference_type"] = _is_reference_type(type_id)
	inspection["godot_class"] = _get_godot_class_name(data)
	
	# Store inspection result
	inspection_results.append(inspection)
	data_history.append(data)
	
	# Create spirit whisper
	var whisper = create_spirit_whisper(inspection)
	speak_whisper(whisper)
	
	# Emit signals
	data_examined.emit(inspection)
	type_detected.emit(type_name, inspection)
	
	return inspection

func _get_type_name(type_id: int) -> String:
	"""Convert Godot type ID to human-readable name"""
	match type_id:
		TYPE_NIL: return "Nil"
		TYPE_BOOL: return "Boolean"
		TYPE_INT: return "Integer"
		TYPE_FLOAT: return "Float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_VECTOR4: return "Vector4"
		TYPE_VECTOR4I: return "Vector4i"
		TYPE_PLANE: return "Plane"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_PROJECTION: return "Projection"
		TYPE_COLOR: return "Color"
		TYPE_STRING_NAME: return "StringName"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return "Object"
		TYPE_CALLABLE: return "Callable"
		TYPE_SIGNAL: return "Signal"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		TYPE_PACKED_BYTE_ARRAY: return "PackedByteArray"
		TYPE_PACKED_INT32_ARRAY: return "PackedInt32Array"
		TYPE_PACKED_INT64_ARRAY: return "PackedInt64Array"
		TYPE_PACKED_FLOAT32_ARRAY: return "PackedFloat32Array"
		TYPE_PACKED_FLOAT64_ARRAY: return "PackedFloat64Array"
		TYPE_PACKED_STRING_ARRAY: return "PackedStringArray"
		TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array"
		TYPE_PACKED_VECTOR3_ARRAY: return "PackedVector3Array"
		TYPE_PACKED_COLOR_ARRAY: return "PackedColorArray"
		_: return "Unknown"

# Specialized inspection functions for each type
func _inspect_nil(data) -> Dictionary:
	return {
		"spirit_message": "The void whispers... nothingness incarnate",
		"is_empty": true,
		"philosophical_note": "Existence undefined, potential infinite"
	}

func _inspect_bool(data: bool) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Truth speaks: " + ("YES" if data else "NO"),
		"binary_representation": "1" if data else "0",
		"philosophical_note": "Duality embodied in singular choice"
	}

func _inspect_int(data: int) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Number consciousness: " + str(data),
		"is_negative": data < 0,
		"is_zero": data == 0,
		"is_power_of_two": data > 0 and (data & (data - 1)) == 0,
		"binary": bin(data),
		"hex": "0x" + ("%X" % data),
		"absolute_value": abs(data),
		"mathematical_properties": _analyze_number_properties(data)
	}

func _inspect_float(data: float) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Floating essence: " + str(data),
		"is_finite": is_finite(data),
		"is_inf": is_inf(data),
		"is_nan": is_nan(data),
		"integer_part": int(data),
		"fractional_part": data - int(data),
		"scientific_notation": "%.2e" % data
	}

func _inspect_string(data: String) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Words carry power: '" + data.substr(0, 20) + ("..." if data.length() > 20 else "") + "'",
		"length": data.length(),
		"is_empty": data.is_empty(),
		"hash": data.hash(),
		"first_char": data[0] if data.length() > 0 else "",
		"last_char": data[-1] if data.length() > 0 else "",
		"contains_numbers": data.is_valid_int() or data.is_valid_float(),
		"is_valid_filename": data.is_valid_filename(),
		"character_analysis": _analyze_string_characters(data)
	}

func _inspect_vector3(data: Vector3) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "3D soul coordinates: " + str(data),
		"x": data.x,
		"y": data.y,
		"z": data.z,
		"length": data.length(),
		"length_squared": data.length_squared(),
		"normalized": data.normalized(),
		"is_normalized": data.is_normalized(),
		"distance_from_origin": data.distance_to(Vector3.ZERO),
		"angle_with_up": data.angle_to(Vector3.UP),
		"dimensional_dominance": _get_dominant_axis(data)
	}

func _inspect_color(data: Color) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Color aura resonates: " + str(data),
		"r": data.r,
		"g": data.g,
		"b": data.b,
		"a": data.a,
		"html": data.to_html(),
		"hsv": _color_to_hsv(data),
		"luminance": data.get_luminance(),
		"brightness": (data.r + data.g + data.b) / 3.0,
		"is_transparent": data.a < 1.0,
		"is_grayscale": abs(data.r - data.g) < 0.01 and abs(data.g - data.b) < 0.01
	}

func _inspect_object(data: Object) -> Dictionary:
	var obj_info = {
		"spirit_message": "Living entity detected: " + data.get_class(),
		"class_name": data.get_class(),
		"instance_id": data.get_instance_id(),
		"is_valid": is_instance_valid(data),
		"script_attached": data.get_script() != null
	}
	
	# If it's a Node, get additional info
	if data is Node:
		var node = data as Node
		obj_info["node_name"] = node.name
		obj_info["node_path"] = str(node.get_path())
		obj_info["children_count"] = node.get_child_count()
		obj_info["is_in_tree"] = node.is_inside_tree()
	
	# If it's a Universal Being, get consciousness info
	if data.has_method("get_consciousness_level"):
		obj_info["consciousness_level"] = data.call("get_consciousness_level")
		obj_info["being_type"] = data.get("being_type") if data.has_method("get") else "unknown"
	
	return obj_info

func _inspect_array(data: Array) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Collection of " + str(data.size()) + " elements",
		"size": data.size(),
		"is_empty": data.is_empty(),
		"first_element": data[0] if data.size() > 0 else null,
		"last_element": data[-1] if data.size() > 0 else null,
		"element_types": _analyze_array_types(data),
		"has_duplicates": _has_duplicates(data),
		"is_sorted": _is_array_sorted(data)
	}

func _inspect_dictionary(data: Dictionary) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Key-value realm with " + str(data.size()) + " mappings",
		"size": data.size(),
		"is_empty": data.is_empty(),
		"keys": data.keys(),
		"values": data.values(),
		"key_types": _analyze_array_types(data.keys()),
		"value_types": _analyze_array_types(data.values())
	}

# Helper analysis functions
func _analyze_number_properties(num: int) -> Dictionary:
	return {
		"is_prime": _is_prime(num),
		"is_even": num % 2 == 0,
		"is_perfect_square": sqrt(num) == int(sqrt(num)),
		"digit_count": str(abs(num)).length()
	}

func _analyze_string_characters(text: String) -> Dictionary:
	var alpha_count = 0
	var digit_count = 0
	var space_count = 0
	var special_count = 0
	
	for i in range(text.length()):
		var char = text[i]
		if char.is_valid_identifier() or char.to_lower() != char.to_upper():
			alpha_count += 1
		elif char.is_valid_int():
			digit_count += 1
		elif char == " ":
			space_count += 1
		else:
			special_count += 1
	
	return {
		"alphabetic": alpha_count,
		"digits": digit_count,
		"spaces": space_count,
		"special": special_count
	}

func _get_dominant_axis(vec: Vector3) -> String:
	var abs_x = abs(vec.x)
	var abs_y = abs(vec.y)
	var abs_z = abs(vec.z)
	
	if abs_x >= abs_y and abs_x >= abs_z:
		return "X"
	elif abs_y >= abs_z:
		return "Y"
	else:
		return "Z"

func _color_to_hsv(color: Color) -> Dictionary:
	var max_val = max(color.r, max(color.g, color.b))
	var min_val = min(color.r, min(color.g, color.b))
	var delta = max_val - min_val
	
	var h = 0.0
	var s = 0.0 if max_val == 0 else delta / max_val
	var v = max_val
	
	if delta != 0:
		if max_val == color.r:
			h = ((color.g - color.b) / delta)
		elif max_val == color.g:
			h = 2 + (color.b - color.r) / delta
		else:
			h = 4 + (color.r - color.g) / delta
		h *= 60
		if h < 0:
			h += 360
	
	return {"hue": h, "saturation": s, "value": v}

func _analyze_array_types(arr: Array) -> Dictionary:
	var type_counts = {}
	for item in arr:
		var type_name = _get_type_name(typeof(item))
		type_counts[type_name] = type_counts.get(type_name, 0) + 1
	return type_counts

func _has_duplicates(arr: Array) -> bool:
	var seen = {}
	for item in arr:
		var key = var_to_str(item)
		if seen.has(key):
			return true
		seen[key] = true
	return false

func _is_array_sorted(arr: Array) -> bool:
	for i in range(1, arr.size()):
		if typeof(arr[i-1]) == typeof(arr[i]):
			if arr[i-1] > arr[i]:
				return false
	return true

func _is_prime(num: int) -> bool:
	if num < 2:
		return false
	for i in range(2, int(sqrt(num)) + 1):
		if num % i == 0:
			return false
	return true

func _estimate_memory_size(data: Variant) -> int:
	"""Estimate memory size of data"""
	match typeof(data):
		TYPE_NIL: return 1
		TYPE_BOOL: return 1
		TYPE_INT: return 8
		TYPE_FLOAT: return 8
		TYPE_STRING: return data.length() * 4 + 16
		TYPE_ARRAY: return data.size() * 8 + 32
		TYPE_DICTIONARY: return data.size() * 16 + 32
		_: return 16  # Default estimate

func _is_reference_type(type_id: int) -> bool:
	"""Check if type is reference or value type"""
	return type_id in [TYPE_OBJECT, TYPE_ARRAY, TYPE_DICTIONARY]

func _get_godot_class_name(data: Variant) -> String:
	"""Get Godot class name if applicable"""
	if data is Object:
		return data.get_class()
	return "N/A"

func create_spirit_whisper(inspection: Dictionary) -> String:
	"""Create a spirit whisper message about the data"""
	var whisper = "👁️ " + inspection.get("spirit_message", "Data examined")
	var type_name = inspection.get("type_name", "Unknown")
	
	# Add context based on type
	match type_name:
		"Vector3":
			whisper += " | 3D essence flows in digital space"
		"String":
			whisper += " | Language carries consciousness"
		"Integer":
			whisper += " | Numerical truth crystallized"
		"Object":
			whisper += " | Living digital entity detected"
		"Array":
			whisper += " | Collection of possibilities"
		"Dictionary":
			whisper += " | Mapped knowledge realm"
	
	return whisper

func speak_whisper(whisper: String):
	"""Display spirit whisper in 3D space"""
	whisper_messages.append(whisper)
	
	# Create whisper bubble
	var bubble = create_whisper_bubble(whisper)
	whisper_bubbles.append(bubble)
	add_child(bubble)
	
	# Update data display
	if data_display:
		data_display.text = whisper
	
	whisper_spoken.emit(whisper)
	print("👁️ SPIRIT WHISPER: " + whisper)

func create_whisper_bubble(message: String) -> Node3D:
	"""Create floating whisper bubble"""
	var bubble = Node3D.new()
	bubble.name = "WhisperBubble"
	bubble.position = Vector3(randf_range(-3, 3), randf_range(3, 6), randf_range(-3, 3))
	
	# Bubble visual
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.5
	mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 0.8, 0.6)
	material.emission_enabled = true
	material.emission = Color.YELLOW * 0.5
	material.emission_energy = 0.8
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	bubble.add_child(mesh)
	
	# Whisper text
	var label = Label3D.new()
	label.text = message
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 2)
	label.modulate = Color.WHITE
	label.pixel_size = 0.008
	bubble.add_child(label)
	
	# Animate bubble
	var tween = create_tween()
	tween.parallel().tween_property(bubble, "position:y", bubble.position.y + 5, 8.0)
	tween.parallel().tween_property(bubble, "modulate:a", 0.0, 8.0)
	tween.tween_callback(bubble.queue_free)
	
	return bubble

func inspect_nearby_data():
	"""Inspect data from nearby objects"""
	print("🔍 Scanning nearby cosmic data...")
	
	# Example inspections
	inspect_data(Vector3(1, 2, 3))
	inspect_data("Hello cosmic consciousness!")
	inspect_data(42)
	inspect_data(Color.CYAN)
	inspect_data([1, "two", Vector3.UP])
	inspect_data({"meaning": 42, "color": Color.MAGENTA})

func update_inspection_display(delta: float):
	"""Update visual inspection effects"""
	if inspection_sphere:
		var time = Time.get_ticks_msec() * 0.002
		inspection_sphere.rotation.y += delta
		var pulse = 1.0 + sin(time) * 0.2
		inspection_sphere.scale = Vector3.ONE * pulse

func save_inspection_history():
	"""Save inspection history"""
	print("💾 Saving %d inspection records..." % inspection_results.size())

# Public interface for other systems
func examine_data(data: Variant) -> Dictionary:
	"""Public interface for data examination"""
	return inspect_data(data)

func get_inspection_history() -> Array:
	"""Get history of all inspections"""
	return inspection_results

func clear_inspection_history():
	"""Clear inspection history"""
	inspection_results.clear()
	data_history.clear()
	whisper_messages.clear()

# Additional inspection functions for remaining types
func _inspect_vector2(data: Vector2) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "2D coordinates dance: " + str(data),
		"x": data.x,
		"y": data.y,
		"length": data.length(),
		"angle": data.angle(),
		"normalized": data.normalized()
	}

func _inspect_callable(data: Callable) -> Dictionary:
	return {
		"spirit_message": "Function essence captured",
		"is_valid": data.is_valid(),
		"object": data.get_object(),
		"method": data.get_method()
	}

func _inspect_node_path(data: NodePath) -> Dictionary:
	return {
		"value": data,
		"spirit_message": "Path through the node cosmos: " + str(data),
		"is_absolute": data.is_absolute(),
		"is_empty": data.is_empty(),
		"name_count": data.get_name_count()
	}

# Stub implementations for other types
func _inspect_vector2i(data): return {"spirit_message": "2D integer coordinates"}
func _inspect_rect2(data): return {"spirit_message": "2D rectangle bounds"}
func _inspect_rect2i(data): return {"spirit_message": "2D integer rectangle"}
func _inspect_vector3i(data): return {"spirit_message": "3D integer coordinates"}
func _inspect_transform2d(data): return {"spirit_message": "2D transformation matrix"}
func _inspect_vector4(data): return {"spirit_message": "4D vector essence"}
func _inspect_vector4i(data): return {"spirit_message": "4D integer vector"}
func _inspect_plane(data): return {"spirit_message": "Infinite plane definition"}
func _inspect_quaternion(data): return {"spirit_message": "Rotation quaternion"}
func _inspect_aabb(data): return {"spirit_message": "3D bounding box"}
func _inspect_basis(data): return {"spirit_message": "3D transformation basis"}
func _inspect_transform3d(data): return {"spirit_message": "3D transformation matrix"}
func _inspect_projection(data): return {"spirit_message": "Projection matrix"}
func _inspect_string_name(data): return {"spirit_message": "Optimized string name"}
func _inspect_rid(data): return {"spirit_message": "Resource identifier"}
func _inspect_signal(data): return {"spirit_message": "Signal connection"}
func _inspect_packed_byte_array(data): return {"spirit_message": "Packed bytes array"}
func _inspect_packed_int32_array(data): return {"spirit_message": "32-bit integer array"}
func _inspect_packed_int64_array(data): return {"spirit_message": "64-bit integer array"}
func _inspect_packed_float32_array(data): return {"spirit_message": "32-bit float array"}
func _inspect_packed_float64_array(data): return {"spirit_message": "64-bit float array"}
func _inspect_packed_string_array(data): return {"spirit_message": "String array"}
func _inspect_packed_vector2_array(data): return {"spirit_message": "Vector2 array"}
func _inspect_packed_vector3_array(data): return {"spirit_message": "Vector3 array"}
func _inspect_packed_color_array(data): return {"spirit_message": "Color array"}
func _inspect_unknown(data): return {"spirit_message": "Unknown data type detected"}
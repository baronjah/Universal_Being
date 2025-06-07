extends Node3D
class_name FloatingKeyboard

var keyboard_active: bool = false
var keys: Array[Node3D] = []
var current_text: String = ""

signal text_entered(text: String)
signal key_pressed(key: String)

func _ready():
	setup_keyboard_layout()

func _input(event):
	if event.is_action_pressed("toggle_keyboard"): # K key
		toggle_keyboard()

func toggle_keyboard():
	if keyboard_active:
		hide_keyboard()
	else:
		show_keyboard()
	keyboard_active = !keyboard_active

func setup_keyboard_layout():
	var qwerty_rows = [
		["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
		["A", "S", "D", "F", "G", "H", "J", "K", "L"],
		["Z", "X", "C", "V", "B", "N", "M"]
	]
	
	for row_index in range(qwerty_rows.size()):
		for key_index in range(qwerty_rows[row_index].size()):
			var key_text = qwerty_rows[row_index][key_index]
			var key_pos = Vector3(key_index * 1.2 - 5, -row_index * 1.2, 0)
			var key_node = create_floating_key(key_text, key_pos)
			keys.append(key_node)
			add_child(key_node)

func create_floating_key(key_text: String, position: Vector3) -> Node3D:
	var key = Node3D.new()
	key.position = position
	key.set_meta("key_text", key_text)
	
	# Key visual
	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1, 1, 0.2)
	mesh_instance.mesh = box
	
	# Key material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.2)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.3, 0.5)
	material.emission_energy = 0.3
	mesh_instance.material_override = material
	
	key.add_child(mesh_instance)
	
	# Key label
	var label = Label3D.new()
	label.text = key_text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.2)
	label.modulate = Color(1, 1, 1)
	key.add_child(label)
	
	# Collision for clicking
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 1, 0.5)
	collision.shape = shape
	area.add_child(collision)
	key.add_child(area)
	
	# Connect click signal
	area.input_event.connect(_on_key_clicked.bind(key_text))
	
	return key

func show_keyboard():
	visible = true
	# Position keyboard in front of camera
	var camera = get_viewport().get_camera_3d()
	if camera:
		global_position = camera.global_position + camera.global_transform.basis.z * -5
		global_position.y -= 2

func hide_keyboard():
	visible = false

func _on_key_clicked(viewport, event, click_position, click_normal, shape_idx, key_text):
	if event is InputEventMouseButton and event.pressed:
		press_key(key_text)

func press_key(key_text: String):
	# Add wobble animation
	var key_node = null
	for key in keys:
		if key.get_meta("key_text") == key_text:
			key_node = key
			break
	
	if key_node:
		var tween = create_tween()
		tween.tween_property(key_node, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
		tween.tween_property(key_node, "scale", Vector3(1, 1, 1), 0.1)
	
	# Handle text input
	if key_text == "SPACE":
		current_text += " "
	elif key_text == "ENTER":
		text_entered.emit(current_text)
		current_text = ""
	elif key_text == "BACK":
		if current_text.length() > 0:
			current_text = current_text.substr(0, current_text.length() - 1)
	else:
		current_text += key_text.to_lower()
	
	key_pressed.emit(key_text)

func get_current_text() -> String:
	return current_text
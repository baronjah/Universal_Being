# 3D SETTINGS INTERFACE - FLOATING SETTINGS IN SPACE
# Customize input mappings in true 3D environment
extends Node3D
class_name Settings3DInterface

signal settings_closed()
signal input_remapped(action: String, new_key: int)

var input_mapper: UniversalInputMapper = null
var camera_ref: Camera3D = null
var setting_panels: Array = []
var current_remapping_action: String = ""
var is_waiting_for_input: bool = false

# Visual elements
var main_panel: Node3D = null
var action_buttons: Dictionary = {}
var instruction_label: Label3D = null

func _ready():
	print("⚙️ 3D Settings Interface: Creating spatial controls...")
	
	# Get input mapper
	input_mapper = UniversalInputMapper.new()
	add_child(input_mapper)
	
	# Wait for input mapper to load settings
	input_mapper.settings_loaded.connect(_on_settings_loaded)

func _on_settings_loaded():
	"""Called when input mapper finishes loading user settings"""
	create_3d_settings_interface()

func show_settings(camera: Camera3D):
	"""Display the 3D settings interface in front of camera"""
	camera_ref = camera
	
	if not main_panel:
		create_3d_settings_interface()
	
	# Position in front of camera
	var camera_transform = camera.global_transform
	var forward = -camera_transform.basis.z
	global_position = camera.global_position + (forward * 8.0)
	
	# Face the camera
	look_at(camera.global_position, Vector3.UP)
	
	visible = true
	print("⚙️ 3D Settings Interface opened")

func hide_settings():
	"""Hide the settings interface"""
	visible = false
	is_waiting_for_input = false
	current_remapping_action = ""
	settings_closed.emit()
	print("⚙️ Settings interface closed")

func create_3d_settings_interface():
	"""Create the complete 3D settings interface"""
	# Create main panel
	main_panel = Node3D.new()
	main_panel.name = "SettingsMainPanel"
	add_child(main_panel)
	
	# Create background plane
	var background = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(12, 16)
	background.mesh = plane
	
	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = Color(0.1, 0.1, 0.2, 0.9)
	bg_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_material.emission_enabled = true
	bg_material.emission = Color(0.2, 0.2, 0.4)
	bg_material.emission_energy = 0.3
	background.material_override = bg_material
	main_panel.add_child(background)
	
	# Create title
	var title = Label3D.new()
	title.text = "🎮 3D PROGRAMMING CONTROLS"
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 7, 0.1)
	title.modulate = Color.GOLD
	title.pixel_size = 0.02
	main_panel.add_child(title)
	
	# Create instruction label
	instruction_label = Label3D.new()
	instruction_label.text = "Click any button to remap its key"
	instruction_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	instruction_label.position = Vector3(0, 6, 0.1)
	instruction_label.modulate = Color.CYAN
	instruction_label.pixel_size = 0.01
	main_panel.add_child(instruction_label)
	
	# Create action buttons
	create_action_buttons()
	
	# Create control buttons
	create_control_buttons()

func create_action_buttons():
	"""Create buttons for each mappable action"""
	var mappings = input_mapper.get_all_mappings()
	var button_count = mappings.size()
	var columns = 3
	var rows = ceil(button_count / float(columns))
	
	var start_y = 4.5
	var button_spacing_x = 3.5
	var button_spacing_y = 1.2
	
	var index = 0
	for action in mappings:
		var row = index / columns
		var col = index % columns
		
		var button_pos = Vector3(
			(col - 1) * button_spacing_x,
			start_y - (row * button_spacing_y),
			0.2
		)
		
		var button = create_action_button(action, mappings[action], button_pos)
		action_buttons[action] = button
		main_panel.add_child(button)
		
		index += 1

func create_action_button(action_name: String, keycode: int, position: Vector3) -> Node3D:
	"""Create a single action remapping button"""
	var button_container = Node3D.new()
	button_container.name = "Button_" + action_name
	button_container.position = position
	
	# Button visual
	var button_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(3.0, 0.8, 0.2)
	button_mesh.mesh = box
	
	var button_material = StandardMaterial3D.new()
	button_material.albedo_color = Color(0.3, 0.3, 0.6)
	button_material.emission_enabled = true
	button_material.emission = Color(0.4, 0.4, 0.8)
	button_material.emission_energy = 0.5
	button_mesh.material_override = button_material
	button_container.add_child(button_mesh)
	
	# Action name label
	var action_label = Label3D.new()
	action_label.text = action_name.replace("_", " ").to_upper()
	action_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	action_label.position = Vector3(0, 0.3, 0.15)
	action_label.modulate = Color.WHITE
	action_label.pixel_size = 0.008
	button_container.add_child(action_label)
	
	# Key display label
	var key_label = Label3D.new()
	key_label.text = OS.get_keycode_string(keycode)
	key_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	key_label.position = Vector3(0, -0.2, 0.15)
	key_label.modulate = Color.YELLOW
	key_label.pixel_size = 0.012
	key_label.name = "KeyLabel"
	button_container.add_child(key_label)
	
	# Add click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3.0, 0.8, 0.5)
	collision.shape = shape
	area.add_child(collision)
	button_container.add_child(area)
	
	# Connect click event
	area.input_event.connect(_on_action_button_clicked.bind(action_name))
	
	# Store references
	button_container.set_meta("action_name", action_name)
	button_container.set_meta("key_label", key_label)
	button_container.set_meta("button_mesh", button_mesh)
	
	return button_container

func create_control_buttons():
	"""Create control buttons (save, reset, close, etc.)"""
	var button_data = [
		{"name": "SAVE", "pos": Vector3(-3, -6, 0.2), "color": Color.GREEN},
		{"name": "RESET", "pos": Vector3(0, -6, 0.2), "color": Color.ORANGE},
		{"name": "CLOSE", "pos": Vector3(3, -6, 0.2), "color": Color.RED}
	]
	
	for data in button_data:
		var button = create_control_button(data.name, data.pos, data.color)
		main_panel.add_child(button)

func create_control_button(text: String, position: Vector3, color: Color) -> Node3D:
	"""Create a control button (save, reset, close)"""
	var button = Node3D.new()
	button.name = "Control_" + text
	button.position = position
	
	# Button mesh
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2.5, 0.8, 0.2)
	mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 0.6
	mesh.material_override = material
	button.add_child(mesh)
	
	# Button label
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.15)
	label.modulate = Color.WHITE
	label.pixel_size = 0.012
	button.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2.5, 0.8, 0.5)
	collision.shape = shape
	area.add_child(collision)
	button.add_child(area)
	
	# Connect click
	area.input_event.connect(_on_control_button_clicked.bind(text))
	
	return button

func _on_action_button_clicked(action_name: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on an action button to remap it"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_key_remapping(action_name)

func _on_control_button_clicked(button_name: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on control buttons"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match button_name:
			"SAVE":
				save_settings()
			"RESET":
				reset_to_defaults()
			"CLOSE":
				hide_settings()

func start_key_remapping(action_name: String):
	"""Start the process of remapping a key"""
	current_remapping_action = action_name
	is_waiting_for_input = true
	
	instruction_label.text = "Press any key to remap '%s'" % action_name.replace("_", " ").to_upper()
	instruction_label.modulate = Color.RED
	
	# Highlight the button being remapped
	if action_name in action_buttons:
		var button = action_buttons[action_name]
		var mesh = button.get_meta("button_mesh")
		var material = mesh.material_override as StandardMaterial3D
		material.emission = Color.RED
		material.emission_energy = 1.0
	
	print("🔄 Waiting for key input to remap: %s" % action_name)

func _input(event: InputEvent):
	"""Handle input for key remapping"""
	if not is_waiting_for_input or current_remapping_action == "":
		return
	
	if event is InputEventKey and event.pressed:
		# Remap the action
		var success = input_mapper.remap_action(current_remapping_action, event.keycode)
		
		if success:
			# Update the button display
			update_action_button_display(current_remapping_action, event.keycode)
			
			instruction_label.text = "Key remapped! Click any button to remap its key"
			instruction_label.modulate = Color.GREEN
			
			input_remapped.emit(current_remapping_action, event.keycode)
		else:
			instruction_label.text = "Failed to remap key! Try again."
			instruction_label.modulate = Color.RED
		
		# Reset remapping state
		finish_key_remapping()

func update_action_button_display(action_name: String, new_keycode: int):
	"""Update the visual display of a remapped button"""
	if action_name in action_buttons:
		var button = action_buttons[action_name]
		var key_label = button.get_meta("key_label") as Label3D
		var button_mesh = button.get_meta("button_mesh")
		
		# Update key display
		key_label.text = OS.get_keycode_string(new_keycode)
		
		# Reset button color
		var material = button_mesh.material_override as StandardMaterial3D
		material.emission = Color(0.4, 0.4, 0.8)
		material.emission_energy = 0.5

func finish_key_remapping():
	"""Finish the key remapping process"""
	current_remapping_action = ""
	is_waiting_for_input = false

func save_settings():
	"""Save current settings"""
	input_mapper.save_user_settings()
	instruction_label.text = "Settings saved to user:// directory!"
	instruction_label.modulate = Color.GREEN
	print("💾 Settings saved successfully")

func reset_to_defaults():
	"""Reset all settings to defaults"""
	input_mapper.reset_to_defaults()
	
	# Update all button displays
	var mappings = input_mapper.get_all_mappings()
	for action in mappings:
		update_action_button_display(action, mappings[action])
	
	instruction_label.text = "All settings reset to defaults!"
	instruction_label.modulate = Color.ORANGE
	print("🔄 Settings reset to defaults")

func get_settings_export() -> String:
	"""Export settings for sharing"""
	return input_mapper.export_settings()

func import_settings(json_string: String) -> bool:
	"""Import settings from string"""
	var success = input_mapper.import_settings(json_string)
	
	if success:
		# Refresh button displays
		var mappings = input_mapper.get_all_mappings()
		for action in mappings:
			update_action_button_display(action, mappings[action])
		
		instruction_label.text = "Settings imported successfully!"
		instruction_label.modulate = Color.GREEN
	else:
		instruction_label.text = "Failed to import settings!"
		instruction_label.modulate = Color.RED
	
	return success
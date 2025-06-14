# 🏛️ Asset Creator Panel - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingUI
class_name AssetCreatorPanel

# In-Game Asset Creator Panel
# Allows creating new asset types dynamically without coding

signal asset_created(asset_name: String, properties: Dictionary)
signal panel_closed()

# UI references (created dynamically, not from scene)
var name_input: LineEdit = null
var type_option: OptionButton = null
var mesh_option: OptionButton = null
var color_picker = null  # Will be HSlider for spectrum
var size_x: SpinBox = null
var size_y: SpinBox = null
var size_z: SpinBox = null
var mass_input: SpinBox = null
var category_input: LineEdit = null
var tags_input: LineEdit = null
var preview_viewport: SubViewport = null
var preview_camera: Camera3D = null

var preview_object: Node3D = null

# Cosmic color spectrum system - from black holes to stars to all colors! 🌌

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
func get_spectrum_color(value: float) -> Color:
	# Ensure value is between 0 and 1
	value = clamp(value, 0.0, 1.0)
	
	# Map 0-1 to our 10 color points  
	var color_index = value * 10  # 10 segments for 11 colors
	
	# Define our cosmic color points - from black holes to stars to all colors!
	var colors = [
		Color(0.0, 0.0, 0.0),      # 1. Black (void)
		Color(1.0, 1.0, 1.0),      # 2. White (stars)
		Color(0.0, 0.0, 0.0),      # 3. Black (space)
		Color(0.45, 0.25, 0.0),    # 4. Brown (planets)
		Color(1.0, 0.0, 0.0),      # 5. Red (fire)
		Color(1.0, 0.5, 0.0),      # 6. Orange (sunset)
		Color(1.0, 1.0, 0.0),      # 7. Yellow (sun)
		Color(1.0, 1.0, 1.0),      # 8. White (light)
		Color(0.0, 1.0, 0.0),      # 9. Green (life)
		Color(0.0, 0.0, 1.0),      # 10. Blue (ocean)
		Color(0.5, 0.0, 0.5)       # 11. Purple (cosmic energy)
	]
	
	# Find the two colors to interpolate between
	var lower_index = int(floor(color_index))
	var upper_index = int(ceil(color_index))
	
	# Ensure indices are in bounds
	lower_index = clamp(lower_index, 0, colors.size() - 1)
	upper_index = clamp(upper_index, 0, colors.size() - 1)
	
	# Get interpolation factor between these two colors
	var t = color_index - floor(color_index)
	return colors[lower_index].lerp(colors[upper_index], t)

func _on_spectrum_changed(value: float, color_preview: Panel) -> void:
	"""Update color preview when spectrum slider changes"""
	var color = get_spectrum_color(value)
	
	# Create a style box for the color preview
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color.WHITE
	color_preview.add_theme_stylebox_override("panel", style_box)
	
	# Update preview object if it exists
	if preview_object:
		_update_preview_mesh()

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_setup_ui()
	_create_preview()
	visible = false

func _setup_ui():
	# Create UI structure if not in editor
	if not name_input:
		_create_ui_elements()
	
	# Setup type options
	type_option.add_item("Static (Non-movable)")
	type_option.add_item("Rigid (Physics)")
	type_option.add_item("Character (Complex)")
	
	# Setup mesh options
	mesh_option.add_item("Box")
	mesh_option.add_item("Sphere")
	mesh_option.add_item("Cylinder")
	mesh_option.add_item("Capsule")
	mesh_option.add_item("Cone")
	mesh_option.add_item("Torus")
	
	# Connect signals
	type_option.item_selected.connect(_on_type_changed)
	mesh_option.item_selected.connect(_on_mesh_changed)
	# Note: spectrum slider connection handled in _setup_ui()
	size_x.value_changed.connect(_on_size_changed)
	size_y.value_changed.connect(_on_size_changed)
	size_z.value_changed.connect(_on_size_changed)

func _create_ui_elements():
	# Create full UI programmatically
	set_custom_minimum_size(Vector2(400, 600))
	set_anchors_preset(Control.PRESET_CENTER)
	
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	
	# Add scroll container to make content scrollable
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(scroll, panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(vbox, scroll)
	
	# Title
	var title = Label.new()
	title.text = "Asset Creator"
	title.add_theme_font_size_override("font_size", 20)
	FloodgateController.universal_add_child(title, vbox)
	
	# Name input
	var name_label = Label.new()
	name_label.text = "Asset Name:"
	FloodgateController.universal_add_child(name_label, vbox)
	
	name_input = LineEdit.new()
	name_input.placeholder_text = "my_asset"
	FloodgateController.universal_add_child(name_input, vbox)
	
	# Type selection
	var type_label = Label.new()
	type_label.text = "Type:"
	FloodgateController.universal_add_child(type_label, vbox)
	
	type_option = OptionButton.new()
	FloodgateController.universal_add_child(type_option, vbox)
	
	# Mesh selection
	var mesh_label = Label.new()
	mesh_label.text = "Shape:"
	FloodgateController.universal_add_child(mesh_label, vbox)
	
	mesh_option = OptionButton.new()
	FloodgateController.universal_add_child(mesh_option, vbox)
	
	# Cosmic color spectrum slider 🌌
	var color_label = Label.new()
	color_label.text = "Cosmic Color Spectrum:"
	FloodgateController.universal_add_child(color_label, vbox)
	
	# Create spectrum slider container
	var spectrum_container = VBoxContainer.new()
	FloodgateController.universal_add_child(spectrum_container, vbox)
	
	# Spectrum slider
	var spectrum_slider = HSlider.new()
	spectrum_slider.min_value = 0.0
	spectrum_slider.max_value = 1.0
	spectrum_slider.step = 0.01
	spectrum_slider.value = 0.5  # Start in middle (yellow sun)
	spectrum_slider.custom_minimum_size = Vector2(200, 30)
	FloodgateController.universal_add_child(spectrum_slider, spectrum_container)
	
	# Color preview panel
	var color_preview = Panel.new()
	color_preview.custom_minimum_size = Vector2(200, 40)
	FloodgateController.universal_add_child(color_preview, spectrum_container)
	
	# Update color preview when slider changes
	spectrum_slider.value_changed.connect(_on_spectrum_changed.bind(color_preview))
	
	# Initialize color preview
	_on_spectrum_changed(0.5, color_preview)
	
	# Store reference for later use
	color_picker = spectrum_slider  # Reuse existing variable name
	
	# Size inputs
	var size_label = Label.new()
	size_label.text = "Size (X, Y, Z):"
	FloodgateController.universal_add_child(size_label, vbox)
	
	var size_container = HBoxContainer.new()
	FloodgateController.universal_add_child(size_container, vbox)
	
	size_x = SpinBox.new()
	size_x.value = 1.0
	size_x.step = 0.1
	size_x.min_value = 0.1
	size_x.max_value = 10.0
	FloodgateController.universal_add_child(size_x, size_container)
	
	size_y = SpinBox.new()
	size_y.value = 1.0
	size_y.step = 0.1
	size_y.min_value = 0.1
	size_y.max_value = 10.0
	FloodgateController.universal_add_child(size_y, size_container)
	
	size_z = SpinBox.new()
	size_z.value = 1.0
	size_z.step = 0.1
	size_z.min_value = 0.1
	size_z.max_value = 10.0
	FloodgateController.universal_add_child(size_z, size_container)
	
	# Mass input
	var mass_label = Label.new()
	mass_label.text = "Mass (for physics objects):"
	FloodgateController.universal_add_child(mass_label, vbox)
	
	mass_input = SpinBox.new()
	mass_input.value = 1.0
	mass_input.step = 0.1
	mass_input.min_value = 0.1
	mass_input.max_value = 100.0
	FloodgateController.universal_add_child(mass_input, vbox)
	
	# Category
	var category_label = Label.new()
	category_label.text = "Category:"
	FloodgateController.universal_add_child(category_label, vbox)
	
	category_input = LineEdit.new()
	category_input.placeholder_text = "props"
	FloodgateController.universal_add_child(category_input, vbox)
	
	# Tags
	var tags_label = Label.new()
	tags_label.text = "Tags (comma separated):"
	FloodgateController.universal_add_child(tags_label, vbox)
	
	tags_input = LineEdit.new()
	tags_input.placeholder_text = "physics, outdoor, decorative"
	FloodgateController.universal_add_child(tags_input, vbox)
	
	# Preview
	var preview_label = Label.new()
	preview_label.text = "Preview:"
	FloodgateController.universal_add_child(preview_label, vbox)
	
	var preview_container = SubViewportContainer.new()
	preview_container.custom_minimum_size = Vector2(300, 200)
	FloodgateController.universal_add_child(preview_container, vbox)
	
	preview_viewport = SubViewport.new()
	preview_viewport.size = Vector2(300, 200)
	FloodgateController.universal_add_child(preview_viewport, preview_container)
	
	preview_camera = Camera3D.new()
	preview_camera.position = Vector3(3, 3, 3)
	preview_camera.look_at(Vector3.ZERO, Vector3.UP)
	FloodgateController.universal_add_child(preview_camera, preview_viewport)
	
	# Buttons
	var button_container = HBoxContainer.new()
	FloodgateController.universal_add_child(button_container, vbox)
	
	var create_button = Button.new()
	create_button.text = "Create Asset"
	create_button.pressed.connect(_on_create_pressed)
	FloodgateController.universal_add_child(create_button, button_container)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_cancel_pressed)
	FloodgateController.universal_add_child(cancel_button, button_container)

func _create_preview():
	if preview_object:
		preview_object.queue_free()
	
	preview_object = MeshInstance3D.new()
	_update_preview_mesh()
	FloodgateController.universal_add_child(preview_object, preview_viewport)
	
	# Add light for better preview
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -45, 0)
	FloodgateController.universal_add_child(light, preview_viewport)

func _update_preview_mesh():
	if not preview_object:
		return
	
	var mesh_instance = preview_object as MeshInstance3D
	var selected_mesh = mesh_option.get_selected_id()
	
	match selected_mesh:
		0: # Box
			mesh_instance.mesh = BoxMesh.new()
		1: # Sphere
			mesh_instance.mesh = SphereMesh.new()
		2: # Cylinder
			mesh_instance.mesh = CylinderMesh.new()
		3: # Capsule
			mesh_instance.mesh = CapsuleMesh.new()
		4: # Cone
			var cone = CylinderMesh.new()
			cone.top_radius = 0.0
			mesh_instance.mesh = cone
		5: # Torus
			mesh_instance.mesh = TorusMesh.new()
	
	# Update size
	if mesh_instance.mesh:
		if mesh_instance.mesh is BoxMesh:
			mesh_instance.mesh.size = Vector3(size_x.value, size_y.value, size_z.value)
		elif mesh_instance.mesh is SphereMesh:
			mesh_instance.mesh.radius = size_x.value / 2.0
			mesh_instance.mesh.height = size_y.value
		elif mesh_instance.mesh is CylinderMesh:
			mesh_instance.mesh.top_radius = size_x.value / 2.0
			mesh_instance.mesh.bottom_radius = size_x.value / 2.0
			mesh_instance.mesh.height = size_y.value
	
	# Update material with spectrum color
	var asset_material = MaterialLibrary.get_material("default")
	asset_material.albedo_color = get_spectrum_color(color_picker.value)  # color_picker is now the slider
	mesh_instance.material_override = asset_material

func _on_type_changed(index: int):
	# Enable/disable mass based on type
	mass_input.editable = index == 1  # Only for rigid bodies

func _on_mesh_changed(_index: int):
	_update_preview_mesh()

func _on_size_changed(_value: float):
	_update_preview_mesh()

func _on_create_pressed():
	var asset_name = name_input.text.strip_edges()
	if asset_name.is_empty():
		push_error("Asset name cannot be empty")
		return
	
	# Build properties dictionary
	var properties = {
		"type": ["static", "rigid", "character"][type_option.selected],
		"mesh": ["box", "sphere", "cylinder", "capsule", "cone", "torus"][mesh_option.selected],
		"colors": [get_spectrum_color(color_picker.value)],
		"size": Vector3(size_x.value, size_y.value, size_z.value),
		"mass": mass_input.value,
		"category": category_input.text if not category_input.text.is_empty() else "custom",
		"tags": Array(tags_input.text.split(",")) if not tags_input.text.is_empty() else [],
		"actions": []
	}
	
	# Add to StandardizedObjects autoload
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if std_objects:
		std_objects.add_custom_asset(asset_name, properties)
		print("[AssetCreator] Created new asset: %s" % asset_name)
		
		# Also add to AssetLibrary if available
		var asset_lib = get_node_or_null("/root/AssetLibrary")
		if asset_lib:
			asset_lib.asset_catalog["objects"][asset_name] = {
				"path": "dynamic://" + asset_name,
				"type": "procedural",
				"category": properties.category,
				"spawn_height": 0.0,
				"tags": properties.tags,
				"preview": ""
			}
	
	asset_created.emit(asset_name, properties)
	_on_cancel_pressed()

func _on_cancel_pressed():
	visible = false
	panel_closed.emit()

func show_panel():
	visible = true
	name_input.text = ""
	name_input.grab_focus()
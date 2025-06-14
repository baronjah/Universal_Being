extends Control
class_name SpaceNavigationUI

# Reference to controllers
var universe_controller = null
var camera_controller = null
var selection_system = null

# UI components
var minimap: TextureRect
var coordinates_label: Label
var scale_indicator: ProgressBar
var target_info_panel: Panel
var scale_labels: Array
var transition_buttons: Dictionary
var resource_display: Panel

# Signals
signal transition_requested(target_scale, focus_object)

func _ready():
	# Find controllers
	await get_tree().process_frame
	universe_controller = get_node_or_null("/root/SpaceGame/UniverseController")
	camera_controller = get_viewport().get_camera_3d()
	selection_system = get_node_or_null("/root/SpaceGame/SpaceSelectionSystem")
	
	# Connect signals
	if selection_system:
		selection_system.connect("object_selected", Callable(self, "_on_object_selected"))
		selection_system.connect("object_hovered", Callable(self, "_on_object_hovered"))
		selection_system.connect("selection_cleared", Callable(self, "_on_selection_cleared"))
	
	if universe_controller:
		universe_controller.connect("scale_changed", Callable(self, "_on_scale_changed"))
	
	# Set up UI
	setup_ui_components()

func _process(delta):
	# Update coordinates
	if camera_controller:
		update_coordinates(camera_controller.global_position)
	
	# Update minimap
	update_minimap()
	
	# Update resource display if needed
	if resource_display and resource_display.visible:
		update_resource_display()

func setup_ui_components():
	# Create the overall container
	var container = Panel.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	
	# Create minimap
	minimap = TextureRect.new()
	minimap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	minimap.expand = true
	minimap.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var minimap_container = Panel.new()
	minimap_container.name = "MinimapContainer"
	minimap_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	minimap_container.anchor_right = 0.2
	minimap_container.anchor_bottom = 0.2
	minimap_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_container.add_child(minimap)
	container.add_child(minimap_container)
	
	# Create coordinates label
	coordinates_label = Label.new()
	coordinates_label.text = "Coordinates: 0, 0, 0"
	coordinates_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	coordinates_label.anchor_top = 0.95
	coordinates_label.anchor_right = 0.5
	coordinates_label.anchor_bottom = 1.0
	container.add_child(coordinates_label)
	
	# Create scale indicator
	var scale_container = Panel.new()
	scale_container.name = "ScaleContainer"
	scale_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	scale_container.anchor_left = 0.8
	scale_container.anchor_bottom = 0.1
	scale_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(scale_container)
	
	# Add vertical layout for scale indicator
	var scale_vbox = VBoxContainer.new()
	scale_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	scale_container.add_child(scale_vbox)
	
	# Add label for scale indicator
	var scale_title = Label.new()
	scale_title.text = "SCALE"
	scale_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scale_vbox.add_child(scale_title)
	
	# Create scale indicator
	scale_indicator = ProgressBar.new()
	scale_indicator.min_value = 0
	scale_indicator.max_value = 4  # 5 scales
	scale_indicator.step = 1.0
	scale_indicator.value = 0  # Default: universe scale
	scale_indicator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_indicator.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scale_vbox.add_child(scale_indicator)
	
	# Add scale labels
	var scale_labels_hbox = HBoxContainer.new()
	scale_labels_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_vbox.add_child(scale_labels_hbox)
	
	scale_labels = []
	var scale_names = ["Universe", "Galaxy", "Star", "Planet", "Element"]
	
	for i in range(scale_names.size()):
		var label = Label.new()
		label.text = scale_names[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.custom_minimum_size = Vector2(50, 0)
		scale_labels_hbox.add_child(label)
		scale_labels.append(label)
	
	# Create target info panel (initially hidden)
	target_info_panel = Panel.new()
	target_info_panel.name = "TargetInfoPanel"
	target_info_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	target_info_panel.anchor_left = 0.75
	target_info_panel.anchor_top = 0.75
	target_info_panel.anchor_right = 0.99
	target_info_panel.anchor_bottom = 0.99
	target_info_panel.visible = false
	container.add_child(target_info_panel)
	
	# Add content to target info panel
	var info_vbox = VBoxContainer.new()
	info_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_vbox.add_theme_constant_override("separation", 5)
	target_info_panel.add_child(info_vbox)
	
	var info_title = Label.new()
	info_title.name = "TitleLabel"
	info_title.text = "OBJECT INFO"
	info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_vbox.add_child(info_title)
	
	var info_content = RichTextLabel.new()
	info_content.name = "ContentLabel"
	info_content.text = "No object selected"
	info_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_vbox.add_child(info_content)
	
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.add_child(button_container)
	
	var zoom_button = Button.new()
	zoom_button.name = "ZoomButton"
	zoom_button.text = "Zoom To"
	zoom_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(zoom_button)
	zoom_button.connect("pressed", Callable(self, "_on_zoom_button_pressed"))
	
	var scale_button = Button.new()
	scale_button.name = "ScaleButton"
	scale_button.text = "Change Scale"
	scale_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(scale_button)
	scale_button.connect("pressed", Callable(self, "_on_scale_button_pressed"))
	
	# Create resource display (initially hidden)
	resource_display = Panel.new()
	resource_display.name = "ResourceDisplay"
	resource_display.set_anchors_preset(Control.PRESET_TOP_LEFT)
	resource_display.anchor_left = 0.0
	resource_display.anchor_top = 0.2
	resource_display.anchor_right = 0.2
	resource_display.anchor_bottom = 0.4
	resource_display.visible = false
	container.add_child(resource_display)
	
	# Add content to resource display
	var resource_vbox = VBoxContainer.new()
	resource_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	resource_vbox.add_theme_constant_override("separation", 5)
	resource_display.add_child(resource_vbox)
	
	var resource_title = Label.new()
	resource_title.text = "RESOURCES"
	resource_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resource_vbox.add_child(resource_title)
	
	var resource_content = RichTextLabel.new()
	resource_content.name = "ResourceList"
	resource_content.text = "No resources available"
	resource_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	resource_vbox.add_child(resource_content)
	
	# Add transition buttons
	add_transition_buttons(container)

func add_transition_buttons(container):
	transition_buttons = {}
	
	# Create button container
	var button_container = Panel.new()
	button_container.name = "TransitionButtonContainer"
	button_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	button_container.anchor_left = 0.5
	button_container.anchor_top = 0.9
	button_container.anchor_right = 0.99
	button_container.anchor_bottom = 0.99
	button_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(button_container)
	
	# Add HBox for buttons
	var button_hbox = HBoxContainer.new()
	button_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 10)
	button_container.add_child(button_hbox)
	
	# Create transition buttons for each scale
	var scale_names = ["Universe", "Galaxy", "Star", "Planet", "Element"]
	
	for i in range(scale_names.size()):
		var button = Button.new()
		button.text = scale_names[i]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.visible = true  # Will be updated based on current scale
		button_hbox.add_child(button)
		
		var scale_key = scale_names[i].to_lower()
		transition_buttons[scale_key] = button
		
		# Connect button signal
		button.connect("pressed", Callable(self, "_on_transition_button_pressed").bind(scale_key))

func update_coordinates(position):
	if coordinates_label:
		coordinates_label.text = "Coordinates: %.2f, %.2f, %.2f" % [position.x, position.y, position.z]

func update_minimap():
	# This would ideally be implemented with a proper minimap rendering system
	# For now, we'll use a placeholder
	if not minimap.texture:
		# Create a placeholder texture
		var image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 1))
		
		# Draw some grid lines
		for x in range(0, 256, 32):
			for y in range(0, 256, 32):
				for i in range(32):
					image.set_pixel(x + i, y, Color(0.2, 0.2, 0.2, 1))
					image.set_pixel(x, y + i, Color(0.2, 0.2, 0.2, 1))
		
		# Draw a point at the center
		for x in range(-3, 4):
			for y in range(-3, 4):
				if x*x + y*y <= 9:
					image.set_pixel(128 + x, 128 + y, Color(1, 1, 1, 1))
		
		var texture = ImageTexture.create_from_image(image)
		minimap.texture = texture

func update_resource_display():
	if resource_display and resource_display.visible:
		var resource_list = resource_display.get_node("ResourceList")
		if resource_list:
			var selected_object = selection_system.current_selection
			
			if not selected_object or not is_instance_valid(selected_object):
				resource_list.text = "No resources available"
				return
				
			# Get resources based on object type
			var resources = {}
			
			if selected_object.has_method("get_resources"):
				resources = selected_object.get_resources()
			elif selected_object.has_method("get_star_resources"):
				resources = selected_object.get_star_resources()
			elif selected_object.has_method("get_planet_resources"):
				resources = selected_object.get_planet_resources()
			elif selected_object.has_method("get_element_resources"):
				resources = selected_object.get_element_resources()
			
			if resources.empty():
				resource_list.text = "No resources available"
				return
			
			# Format resource list
			var text = ""
			for resource in resources:
				var amount = resources[resource]
				text += resource.capitalize() + ": " + str(amount) + "\n"
			
			resource_list.text = text

func _on_object_selected(object):
	if not is_instance_valid(object):
		target_info_panel.visible = false
		return
	
	# Show target info panel
	target_info_panel.visible = true
	
	# Set panel title
	var title_label = target_info_panel.get_node("TitleLabel")
	if title_label:
		title_label.text = object.name.to_upper()
	
	# Set panel content based on object type
	var content_label = target_info_panel.get_node("ContentLabel")
	if content_label:
		var info_text = ""
		
		if object.is_in_group("galaxies"):
			info_text = get_galaxy_info(object)
		elif object.is_in_group("stars"):
			info_text = get_star_info(object)
		elif object.is_in_group("planets"):
			info_text = get_planet_info(object)
		elif object.is_in_group("elements"):
			info_text = get_element_info(object)
		else:
			info_text = "Unknown object type"
		
		content_label.text = info_text
	
	# Show resource display if applicable
	if object.has_method("get_resources") or object.has_method("get_star_resources") or object.has_method("get_planet_resources") or object.has_method("get_element_resources"):
		resource_display.visible = true
		update_resource_display()
	else:
		resource_display.visible = false

func _on_object_hovered(object):
	# Could be used for hover tooltips
	pass

func _on_selection_cleared():
	target_info_panel.visible = false
	resource_display.visible = false

func _on_scale_changed(scale_name, transition_progress):
	# Update scale indicator
	var scale_index = 0
	match scale_name:
		"universe": scale_index = 0
		"galaxy": scale_index = 1
		"star_system": scale_index = 2
		"planet": scale_index = 3
		"element": scale_index = 4
	
	scale_indicator.value = scale_index
	
	# Update scale labels
	for i in range(scale_labels.size()):
		if i == scale_index:
			scale_labels[i].add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			scale_labels[i].add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	# Update transition buttons
	update_transition_buttons(scale_name)

func update_transition_buttons(current_scale):
	# Hide current scale button and show adjacent scales
	for scale in transition_buttons:
		transition_buttons[scale].visible = false
	
	match current_scale:
		"universe":
			transition_buttons["galaxy"].visible = true
		"galaxy":
			transition_buttons["universe"].visible = true
			transition_buttons["star"].visible = true
		"star_system":
			transition_buttons["galaxy"].visible = true
			transition_buttons["planet"].visible = true
		"planet":
			transition_buttons["star"].visible = true
			transition_buttons["element"].visible = true
		"element":
			transition_buttons["planet"].visible = true

func _on_transition_button_pressed(scale_name):
	# Request scale transition
	emit_signal("transition_requested", scale_name, selection_system.current_selection)

func _on_zoom_button_pressed():
	if camera_controller and is_instance_valid(selection_system.current_selection):
		# Request camera to focus on selected object
		if camera_controller.has_method("start_orbit"):
			camera_controller.start_orbit(selection_system.current_selection)

func _on_scale_button_pressed():
	if is_instance_valid(selection_system.current_selection):
		var target_scale = ""
		
		if selection_system.current_selection.is_in_group("galaxies"):
			target_scale = "galaxy"
		elif selection_system.current_selection.is_in_group("stars"):
			target_scale = "star_system"
		elif selection_system.current_selection.is_in_group("planets"):
			target_scale = "planet"
		elif selection_system.current_selection.is_in_group("elements"):
			target_scale = "element"
		
		if target_scale:
			emit_signal("transition_requested", target_scale, selection_system.current_selection)

func get_galaxy_info(galaxy) -> String:
	var info = ""
	
	if galaxy.has_meta("galaxy_type"):
		var type_names = ["Spiral", "Elliptical", "Irregular", "Ring", "Dwarf"]
		var type_index = galaxy.get_meta("galaxy_type")
		if type_index >= 0 and type_index < type_names.size():
			info += "Type: " + type_names[type_index] + "\n"
	
	if galaxy.has_method("get_galaxy_id"):
		info += "ID: " + str(galaxy.get_galaxy_id()) + "\n"
	
	info += "Position: %.2f, %.2f, %.2f\n" % [
		galaxy.global_position.x,
		galaxy.global_position.y,
		galaxy.global_position.z
	]
	
	info += "Distance: %.2f\n" % galaxy.global_position.distance_to(camera_controller.global_position)
	
	# Add more galaxy info as needed
	return info

func get_star_info(star) -> String:
	var info = ""
	
	if star.has_method("get_star_type"):
		var type_names = ["O-Type", "B-Type", "A-Type", "F-Type", "G-Type", "K-Type", "M-Type", 
						 "Red Giant", "White Dwarf", "Neutron", "Black Hole"]
		var type_index = star.get_star_type()
		if type_index >= 0 and type_index < type_names.size():
			info += "Type: " + type_names[type_index] + "\n"
	
	if star.has_method("get_star_properties"):
		var props = star.get_star_properties()
		if props.has("temperature"):
			info += "Temperature: " + str(int(props.temperature)) + " K\n"
		if props.has("size"):
			info += "Size: " + str(props.size) + " solar radii\n"
		if props.has("planet_count"):
			info += "Planets: " + str(props.planet_count) + "\n"
	
	info += "Position: %.2f, %.2f, %.2f\n" % [
		star.global_position.x,
		star.global_position.y,
		star.global_position.z
	]
	
	return info

func get_planet_info(planet) -> String:
	var info = ""
	
	if planet.has_method("get_planet_type"):
		var type_names = ["Rocky", "Gas Giant", "Ice Giant", "Water World", 
						 "Lava World", "Terrestrial", "Desert", "Barren"]
		var type_index = planet.get_planet_type()
		if type_index >= 0 and type_index < type_names.size():
			info += "Type: " + type_names[type_index] + "\n"
	
	if planet.has_method("get_planet_properties"):
		var props = planet.get_planet_properties()
		
		if props.has("size"):
			info += "Size: " + str(props.size) + " Earth radii\n"
		if props.has("mass"):
			info += "Mass: " + str(props.mass) + " Earth masses\n"
		if props.has("temperature"):
			info += "Temperature: " + str(int(props.temperature)) + " K\n"
		if props.has("orbit_distance"):
			info += "Orbit: " + str(props.orbit_distance) + " AU\n"
		if props.has("has_life"):
			info += "Life: " + ("Yes" if props.has_life else "No") + "\n"
		if props.has("atmosphere"):
			info += "Atmosphere: " + ("Yes" if props.atmosphere else "No") + "\n"
		if props.has("moon_count"):
			info += "Moons: " + str(props.moon_count) + "\n"
	
	return info

func get_element_info(element) -> String:
	var info = ""
	
	if element.has_method("get_element_type"):
		info += "Type: " + element.get_element_type() + "\n"
	
	if element.has_method("get_element_properties"):
		var props = element.get_element_properties()
		
		if props.has("fire"):
			info += "Fire: " + str(props.fire) + "\n"
		if props.has("water"):
			info += "Water: " + str(props.water) + "\n"
		if props.has("wood"):
			info += "Wood: " + str(props.wood) + "\n"
		if props.has("ash"):
			info += "Ash: " + str(props.ash) + "\n"
	
	return info

func create_minimap_texture():
	# This function would normally generate a proper minimap texture
	# For now, we'll create a placeholder
	var image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 1))
	
	# Draw some grid lines
	for x in range(0, 256, 32):
		for y in range(0, 256, 32):
			for i in range(32):
				image.set_pixel(x + i, y, Color(0.2, 0.2, 0.2, 1))
				image.set_pixel(x, y + i, Color(0.2, 0.2, 0.2, 1))
	
	# Draw a point at the center
	for x in range(-3, 4):
		for y in range(-3, 4):
			if x*x + y*y <= 9:
				image.set_pixel(128 + x, 128 + y, Color(1, 1, 1, 1))
	
	return ImageTexture.create_from_image(image)
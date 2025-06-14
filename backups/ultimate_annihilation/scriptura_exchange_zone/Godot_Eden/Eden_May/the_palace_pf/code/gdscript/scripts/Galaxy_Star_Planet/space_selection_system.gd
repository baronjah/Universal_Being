extends Node
class_name SpaceSelectionSystem

signal object_selected(object)
signal object_hovered(object)
signal selection_cleared

# Selection properties
var current_selection = null
var hover_object = null
var selection_mask = 0  # Will be set based on current scale
var max_selection_distance = 1000.0
var camera = null

# Scale-specific masks
var scale_masks = {
	"universe": 1,  # Galaxies
	"galaxy": 2,    # Stars
	"star_system": 4,  # Planets
	"planet": 8     # Surface features
}

# Hover hint properties
var hover_hint = null
var hover_timeout = 0.5
var hover_timer = 0.0

# Interactive objects by type
var galaxies = []
var stars = []
var planets = []
var elements = []

func _ready():
	# Find camera
	await get_tree().process_frame
	camera = get_viewport().get_camera_3d()
	
	# Create hover hint
	create_hover_hint()

func _process(delta):
	# Check for selection via raycast each frame
	if camera and Input.is_action_just_pressed("select"):
		select_object_under_cursor()
	
	# Update hover object
	update_hover_object(delta)

func select_object_under_cursor():
	var object = get_object_under_cursor()
	
	if object:
		select_object(object)
	else:
		clear_selection()

func get_object_under_cursor():
	if not camera:
		return null
		
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * max_selection_distance
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = selection_mask
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		return result.collider
	
	return null

func update_hover_object(delta):
	var new_hover = get_object_under_cursor()
	
	if new_hover != hover_object:
		hover_object = new_hover
		emit_signal("object_hovered", hover_object)
		hover_timer = 0.0
		
		if hover_hint:
			hover_hint.visible = false
	
	# Update hover hint timer
	if hover_object and hover_hint:
		hover_timer += delta
		if hover_timer >= hover_timeout and not hover_hint.visible:
			show_hover_hint(hover_object)

func select_object(object):
	# Ignore if same object already selected
	if current_selection == object:
		return
	
	# Deselect previous object if any
	if current_selection and is_instance_valid(current_selection):
		if current_selection.has_method("set_selected"):
			current_selection.set_selected(false)
	
	# Select new object
	current_selection = object
	
	# Call object's selection method if available
	if current_selection and current_selection.has_method("set_selected"):
		current_selection.set_selected(true)
	
	# Emit selection signal
	emit_signal("object_selected", current_selection)

func clear_selection():
	if current_selection and is_instance_valid(current_selection):
		if current_selection.has_method("set_selected"):
			current_selection.set_selected(false)
	
	current_selection = null
	emit_signal("selection_cleared")

func set_scale_mask(scale_name):
	if scale_masks.has(scale_name):
		selection_mask = scale_masks[scale_name]

func create_hover_hint():
	# Create a hint label for hovering
	hover_hint = Label3D.new()
	hover_hint.name = "HoverHint"
	hover_hint.text = ""
	hover_hint.font_size = 12
	hover_hint.modulate = Color(1, 1, 1, 0.8)
	hover_hint.billboard = true
	hover_hint.no_depth_test = true
	hover_hint.visible = false
	
	add_child(hover_hint)

func show_hover_hint(object):
	if not is_instance_valid(object) or not hover_hint:
		return
	
	# Position hint above object
	hover_hint.global_position = object.global_position + Vector3(0, 1, 0)
	
	# Set hint text based on object type
	var hint_text = ""
	
	if object.is_in_group("galaxies"):
		hint_text = get_galaxy_hint(object)
	elif object.is_in_group("stars"):
		hint_text = get_star_hint(object)
	elif object.is_in_group("planets"):
		hint_text = get_planet_hint(object)
	elif object.is_in_group("elements"):
		hint_text = get_element_hint(object)
	else:
		hint_text = object.name
	
	hover_hint.text = hint_text
	hover_hint.visible = true

func get_galaxy_hint(galaxy) -> String:
	var hint = galaxy.name
	
	if galaxy.has_method("get_galaxy_id"):
		hint += "\nID: " + str(galaxy.get_galaxy_id())
	
	if galaxy.has_meta("galaxy_type"):
		var type_names = ["Spiral", "Elliptical", "Irregular", "Ring", "Dwarf"]
		var type_index = galaxy.get_meta("galaxy_type")
		if type_index >= 0 and type_index < type_names.size():
			hint += "\nType: " + type_names[type_index]
	
	return hint

func get_star_hint(star) -> String:
	var hint = star.name
	
	if star.has_method("get_star_type"):
		var type_names = ["O-Type", "B-Type", "A-Type", "F-Type", "G-Type", "K-Type", "M-Type", 
						 "Red Giant", "White Dwarf", "Neutron", "Black Hole"]
		var type_index = star.get_star_type()
		if type_index >= 0 and type_index < type_names.size():
			hint += "\nType: " + type_names[type_index]
	
	return hint

func get_planet_hint(planet) -> String:
	var hint = planet.name
	
	if planet.has_method("get_planet_type"):
		var type_names = ["Rocky", "Gas Giant", "Ice Giant", "Water World", 
						 "Lava World", "Terrestrial", "Desert", "Barren"]
		var type_index = planet.get_planet_type()
		if type_index >= 0 and type_index < type_names.size():
			hint += "\nType: " + type_names[type_index]
	
	return hint

func get_element_hint(element) -> String:
	var hint = element.name
	
	if element.has_method("get_element_type"):
		hint += "\nType: " + element.get_element_type()
	
	return hint

func register_object(object, object_type):
	match object_type:
		"galaxy":
			if not galaxies.has(object):
				galaxies.append(object)
				object.add_to_group("galaxies")
		"star":
			if not stars.has(object):
				stars.append(object)
				object.add_to_group("stars")
		"planet":
			if not planets.has(object):
				planets.append(object)
				object.add_to_group("planets")
		"element":
			if not elements.has(object):
				elements.append(object)
				object.add_to_group("elements")

func unregister_object(object, object_type):
	match object_type:
		"galaxy":
			var index = galaxies.find(object)
			if index != -1:
				galaxies.remove_at(index)
				object.remove_from_group("galaxies")
		"star":
			var index = stars.find(object)
			if index != -1:
				stars.remove_at(index)
				object.remove_from_group("stars")
		"planet":
			var index = planets.find(object)
			if index != -1:
				planets.remove_at(index)
				object.remove_from_group("planets")
		"element":
			var index = elements.find(object)
			if index != -1:
				elements.remove_at(index)
				object.remove_from_group("elements")

func get_objects_by_type(object_type):
	match object_type:
		"galaxy":
			return galaxies
		"star":
			return stars
		"planet":
			return planets
		"element":
			return elements
	
	return []
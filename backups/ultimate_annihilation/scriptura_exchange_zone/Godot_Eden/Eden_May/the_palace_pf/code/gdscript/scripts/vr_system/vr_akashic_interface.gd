extends Node
class_name VRAkashicInterface

# References to managers
var vr_manager = null
var akashic_records = null

# UI elements
var dictionary_ui = null
var word_detail_panel = null

# Interaction state
var selected_word = null
var dragging_word = null
var interaction_mode = "view" # view, create, connect, delete
var active_controller = "right"
var virtual_keyboard = null

# Visual representation
var word_scene: PackedScene
var connection_scene: PackedScene
var word_nodes = {}
var connection_nodes = {}

# Layout settings
var layout_type = "radial" # radial, hierarchical, force_directed
var layout_settings = {
	"radial_spacing": 1.5,
	"hierarchical_spacing": 1.0,
	"force_strength": 0.5,
	"repulsion": 1.0
}

# Visualization root
var visualization_root: Node3D

# Signals
signal word_selected(word_id)
signal word_connection_created(parent_id, child_id)
signal word_created(word_id, word_data)
signal word_deleted(word_id)
signal visualization_updated

# Initialize the VR interface for Akashic Records
func initialize():
	print("Initializing VR interface for Akashic Records...")
	
	# Get manager instances
	vr_manager = VRManager.get_instance()
	akashic_records = AkashicRecordsManager.get_instance()
	
	# Initialize Akashic Records if not already done
	if not akashic_records.is_initialized:
		akashic_records.initialize()
	
	# Create visualization root
	visualization_root = Node3D.new()
	visualization_root.name = "AkashicVisualization"
	add_child(visualization_root)
	
	# Load scenes for word and connection visualization
	_load_visualization_resources()
	
	# Connect signals from VR manager
	vr_manager.connect("interaction_triggered", Callable(self, "_on_vr_interaction"))
	vr_manager.connect("controller_gesture_detected", Callable(self, "_on_controller_gesture"))
	
	# Setup initial UI
	_setup_ui()
	
	# Create initial visualization based on the Akashic Records data
	create_visualization()
	
	print("VR interface for Akashic Records initialized")
	return true

# Load visualization resources
func _load_visualization_resources():
	# Load or create word visualization scene
	word_scene = _create_default_word_scene()
	
	# Load or create connection visualization scene
	connection_scene = _create_default_connection_scene()

# Create default word visualization if none is available
func _create_default_word_scene() -> PackedScene:
	var scene = PackedScene.new()
	
	# Create a node structure for representing a word
	var word_root = Node3D.new()
	word_root.name = "WordVisual"
	
	# Add a sphere mesh for the word
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	mesh_instance.mesh = sphere
	
	# Add a material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.9, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.3, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	# Add label
	var label_3d = Label3D.new()
	label_3d.pixel_size = 0.01
	label_3d.font_size = 64
	label_3d.modulate = Color(1, 1, 1, 1)
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.position = Vector3(0, 0.3, 0)
	
	# Add collision shape for interaction
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.25
	collision_shape.shape = sphere_shape
	
	# Add static body for physics interaction
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 1
	static_body.collision_mask = 1
	static_body.add_child(collision_shape)
	
	# Assemble the node structure
	word_root.add_child(mesh_instance)
	word_root.add_child(label_3d)
	word_root.add_child(static_body)
	
	# Pack the scene
	scene.pack(word_root)
	return scene

# Create default connection visualization
func _create_default_connection_scene() -> PackedScene:
	var scene = PackedScene.new()
	
	# Create a node structure for representing a connection
	var connection_root = Node3D.new()
	connection_root.name = "ConnectionVisual"
	
	# Create a simple line mesh
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	mesh_instance.mesh = immediate_mesh
	
	# Add a material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 1.0, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	# Assemble the node structure
	connection_root.add_child(mesh_instance)
	
	# Pack the scene
	scene.pack(connection_root)
	return scene

# Setup UI elements
func _setup_ui():
	# Create UI root in 3D space
	var ui_root = Node3D.new()
	ui_root.name = "AkashicUI"
	add_child(ui_root)
	
	# Create dictionary browser panel
	dictionary_ui = _create_dictionary_browser()
	ui_root.add_child(dictionary_ui)
	dictionary_ui.position = Vector3(0, 1.5, -2)
	
	# Create word detail panel
	word_detail_panel = _create_word_detail_panel()
	ui_root.add_child(word_detail_panel)
	word_detail_panel.position = Vector3(1.5, 1.5, -1.5)
	word_detail_panel.rotation.y = -PI/4
	
	# Create virtual keyboard for text input
	virtual_keyboard = _create_virtual_keyboard()
	ui_root.add_child(virtual_keyboard)
	virtual_keyboard.position = Vector3(0, 1.0, -1.0)
	virtual_keyboard.visible = false

# Create a dictionary browser panel
func _create_dictionary_browser() -> Node3D:
	var browser = Node3D.new()
	browser.name = "DictionaryBrowser"
	
	# Add a background panel
	var panel_mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(1.0, 0.7)
	panel_mesh.mesh = quad
	
	var panel_material = StandardMaterial3D.new()
	panel_material.albedo_color = Color(0.1, 0.1, 0.2, 0.7)
	panel_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mesh.material_override = panel_material
	
	browser.add_child(panel_mesh)
	
	# Add title
	var title = Label3D.new()
	title.text = "Akashic Records"
	title.font_size = 48
	title.position = Vector3(0, 0.3, 0.01)
	browser.add_child(title)
	
	# Add interactive surface for menu
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1.0, 0.7, 0.05)
	collision_shape.shape = box_shape
	
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 1
	static_body.collision_mask = 1
	static_body.add_child(collision_shape)
	browser.add_child(static_body)
	
	return browser

# Create a word detail panel
func _create_word_detail_panel() -> Node3D:
	var panel = Node3D.new()
	panel.name = "WordDetailPanel"
	
	# Add a background panel
	var panel_mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(0.8, 1.0)
	panel_mesh.mesh = quad
	
	var panel_material = StandardMaterial3D.new()
	panel_material.albedo_color = Color(0.1, 0.2, 0.1, 0.7)
	panel_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mesh.material_override = panel_material
	
	panel.add_child(panel_mesh)
	
	# Add title
	var title = Label3D.new()
	title.text = "Word Details"
	title.font_size = 36
	title.position = Vector3(0, 0.45, 0.01)
	panel.add_child(title)
	
	# Add interactive surface
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.8, 1.0, 0.05)
	collision_shape.shape = box_shape
	
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 1
	static_body.collision_mask = 1
	static_body.add_child(collision_shape)
	panel.add_child(static_body)
	
	return panel

# Create a virtual keyboard for text input
func _create_virtual_keyboard() -> Node3D:
	var keyboard = Node3D.new()
	keyboard.name = "VirtualKeyboard"
	
	# Add a background panel
	var panel_mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(1.2, 0.4)
	panel_mesh.mesh = quad
	
	var panel_material = StandardMaterial3D.new()
	panel_material.albedo_color = Color(0.2, 0.2, 0.2, 0.8)
	panel_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mesh.material_override = panel_material
	
	keyboard.add_child(panel_mesh)
	
	# Create a simple 3x10 grid of keys
	var key_size = 0.1
	var key_spacing = 0.02
	var start_x = -0.55
	var start_y = 0.15
	
	var keys = [
		["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
		["A", "S", "D", "F", "G", "H", "J", "K", "L", "DEL"],
		["Z", "X", "C", "V", "B", "N", "M", "SPC", "DONE"]
	]
	
	for row in range(keys.size()):
		var y_pos = start_y - row * (key_size + key_spacing)
		for col in range(keys[row].size()):
			var key_text = keys[row][col]
			var x_pos = start_x + col * (key_size + key_spacing)
			
			var key = _create_keyboard_key(key_text, key_size)
			key.position = Vector3(x_pos, y_pos, 0.01)
			keyboard.add_child(key)
	
	return keyboard

# Create a single keyboard key
func _create_keyboard_key(key_text: String, size: float) -> Node3D:
	var key = Node3D.new()
	key.name = "Key_" + key_text
	
	# Add key background
	var key_mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(size, size)
	key_mesh.mesh = quad
	
	var key_material = StandardMaterial3D.new()
	key_material.albedo_color = Color(0.7, 0.7, 0.7, 0.9)
	key_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	key_mesh.material_override = key_material
	
	key.add_child(key_mesh)
	
	# Add key text
	var label = Label3D.new()
	label.text = key_text
	label.font_size = 24
	label.position = Vector3(0, 0, 0.01)
	key.add_child(label)
	
	# Add collision for interaction
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size, size, 0.02)
	collision_shape.shape = box_shape
	
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 1
	static_body.collision_mask = 1
	# Store the key text as metadata
	static_body.set_meta("key_text", key_text)
	static_body.add_child(collision_shape)
	key.add_child(static_body)
	
	return key

# Create a visualization of the dictionary
func create_visualization():
	print("Creating Akashic Records visualization...")
	
	# Clear previous visualization
	for node in word_nodes.values():
		if node and is_instance_valid(node):
			node.queue_free()
	
	for node in connection_nodes.values():
		if node and is_instance_valid(node):
			node.queue_free()
			
	word_nodes.clear()
	connection_nodes.clear()
	
	# Get dictionary data
	var words = _get_all_words()
	
	# Create word nodes first
	for word_id in words:
		var word_data = words[word_id]
		_create_word_node(word_id, word_data)
	
	# Then create connections
	for word_id in words:
		var word_data = words[word_id]
		if "children" in word_data and word_data.children.size() > 0:
			for child_id in word_data.children:
				_create_connection_node(word_id, child_id)
	
	# Apply layout
	_apply_layout()
	
	emit_signal("visualization_updated")
	print("Visualization created with " + str(words.size()) + " words")

# Get all words from the dictionary
func _get_all_words() -> Dictionary:
	var words = {}
	var stats = akashic_records.get_dictionary_stats()
	var word_count = stats.get("word_count", 0)
	
	if word_count > 0:
		var roots = akashic_records.dynamic_dictionary.get_root_words()
		
		for root_id in roots:
			words[root_id] = akashic_records.get_word(root_id)
			_gather_word_children(root_id, words)
	
	return words

# Recursively gather word children
func _gather_word_children(word_id: String, words_dict: Dictionary):
	var children = akashic_records.get_word_children(word_id)
	
	for child_id in children:
		if not words_dict.has(child_id):
			words_dict[child_id] = akashic_records.get_word(child_id)
			_gather_word_children(child_id, words_dict)

# Create a visual node for a word
func _create_word_node(word_id: String, word_data: Dictionary):
	if word_nodes.has(word_id):
		return
	
	var word_instance = word_scene.instantiate()
	word_instance.name = "Word_" + word_id
	
	# Set the label text
	var label = word_instance.get_node("Label3D")
	if label:
		label.text = word_id
	
	# Customize appearance based on word type/category
	var mesh_instance = word_instance.get_node("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override
		
		if word_data.has("category"):
			match word_data.category:
				"element":
					material.albedo_color = Color(1.0, 0.5, 0.2, 0.8)
					material.emission = Color(0.5, 0.2, 0.1)
				"cosmic":
					material.albedo_color = Color(0.2, 0.4, 0.8, 0.8)
					material.emission = Color(0.1, 0.2, 0.4)
				"scale":
					material.albedo_color = Color(0.5, 0.5, 0.5, 0.8)
					material.emission = Color(0.2, 0.2, 0.2)
				_:
					material.albedo_color = Color(0.7, 0.7, 0.7, 0.8)
					material.emission = Color(0.3, 0.3, 0.3)
	
	# Store word data as metadata
	word_instance.set_meta("word_id", word_id)
	word_instance.set_meta("word_data", word_data)
	
	# Add to visualization root
	visualization_root.add_child(word_instance)
	
	# Store reference
	word_nodes[word_id] = word_instance

# Create a visual connection between two words
func _create_connection_node(parent_id: String, child_id: String):
	var connection_key = parent_id + "_" + child_id
	
	if connection_nodes.has(connection_key) or not word_nodes.has(parent_id) or not word_nodes.has(child_id):
		return
	
	var connection_instance = connection_scene.instantiate()
	connection_instance.name = "Connection_" + connection_key
	
	# Store connection data
	connection_instance.set_meta("parent_id", parent_id)
	connection_instance.set_meta("child_id", child_id)
	
	# Add to visualization root
	visualization_root.add_child(connection_instance)
	
	# Store reference
	connection_nodes[connection_key] = connection_instance
	
	# Update the visual line
	_update_connection_line(connection_instance, parent_id, child_id)

# Update a connection line between two words
func _update_connection_line(connection_node, parent_id, child_id):
	if not word_nodes.has(parent_id) or not word_nodes.has(child_id):
		return
	
	var parent_pos = word_nodes[parent_id].global_position
	var child_pos = word_nodes[child_id].global_position
	
	var mesh_instance = connection_node.get_node("MeshInstance3D")
	if mesh_instance and mesh_instance.mesh is ImmediateMesh:
		var immediate_mesh = mesh_instance.mesh
		immediate_mesh.clear()
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		immediate_mesh.surface_add_vertex(parent_pos)
		immediate_mesh.surface_add_vertex(child_pos)
		immediate_mesh.surface_end()

# Apply a layout to the visualization
func _apply_layout():
	match layout_type:
		"radial":
			_apply_radial_layout()
		"hierarchical":
			_apply_hierarchical_layout()
		"force_directed":
			_apply_force_directed_layout()

# Apply a radial layout to the visualization
func _apply_radial_layout():
	# Find root words (those without parents or with parent=null)
	var roots = []
	
	for word_id in word_nodes:
		var node = word_nodes[word_id]
		var is_root = true
		
		if node.has_meta("word_data"):
			var word_data = node.get_meta("word_data")
			if word_data.has("parent") and word_data.parent != null and word_data.parent != "":
				is_root = false
		
		if is_root:
			roots.append(word_id)
	
	# Position root nodes in a circle
	var root_count = roots.size()
	var radius = 2.0 * layout_settings.radial_spacing
	var center = Vector3.ZERO
	
	for i in range(root_count):
		var angle = (2 * PI * i) / root_count
		var x = center.x + radius * cos(angle)
		var z = center.z + radius * sin(angle)
		
		var root_id = roots[i]
		word_nodes[root_id].global_position = Vector3(x, center.y, z)
		
		# Position children in concentric circles
		_layout_children_radial(root_id, Vector3(x, center.y, z), radius * 0.5, 1)
	
	# Update all connection lines
	for connection_key in connection_nodes:
		var connection = connection_nodes[connection_key]
		var parent_id = connection.get_meta("parent_id")
		var child_id = connection.get_meta("child_id")
		_update_connection_line(connection, parent_id, child_id)

# Recursively layout children in a radial pattern
func _layout_children_radial(parent_id, parent_pos, radius, level):
	var children = []
	
	# Find all children of this parent
	for word_id in word_nodes:
		var node = word_nodes[word_id]
		
		if node.has_meta("word_data"):
			var word_data = node.get_meta("word_data")
			if word_data.has("parent") and word_data.parent == parent_id:
				children.append(word_id)
	
	var child_count = children.size()
	if child_count == 0:
		return
	
	# Position children in a circle around the parent
	for i in range(child_count):
		var angle = (2 * PI * i) / child_count
		var child_radius = radius * (1 + 0.5 * level)
		var x = parent_pos.x + child_radius * cos(angle)
		var z = parent_pos.z + child_radius * sin(angle)
		
		var child_id = children[i]
		var child_pos = Vector3(x, parent_pos.y, z)
		word_nodes[child_id].global_position = child_pos
		
		# Recursively layout this child's children
		_layout_children_radial(child_id, child_pos, radius * 0.5, level + 1)

# Apply a hierarchical layout
func _apply_hierarchical_layout():
	# Implementation would be similar to radial but with rows instead of circles
	pass

# Apply a force-directed layout
func _apply_force_directed_layout():
	# This would implement a physics-based layout algorithm
	pass

# Handle VR interaction with the visualization
func _on_vr_interaction(object, interaction_type):
	if not object:
		return
	
	# Check if it's a word in our visualization
	var parent = object
	while parent and not parent.has_meta("word_id") and parent.get_parent() != null:
		parent = parent.get_parent()
	
	if parent and parent.has_meta("word_id"):
		var word_id = parent.get_meta("word_id")
		
		match interaction_type:
			"interact":
				_handle_word_interaction(word_id)
			"select":
				_handle_word_selection(word_id)
	
	# Check if it's a UI element
	elif object.get_parent() and object.get_parent().name == "VirtualKeyboard" and object.has_meta("key_text"):
		_handle_keyboard_input(object.get_meta("key_text"))

# Handle controller gesture detection
func _on_controller_gesture(controller, gesture_type, gesture_data):
	match gesture_type:
		"pinch":
			# Could be used to create connections between words
			if selected_word and gesture_data.has("target_word"):
				_create_word_connection(selected_word, gesture_data.target_word)
		"swipe":
			# Could be used to change visualization mode
			if gesture_data.has("direction"):
				match gesture_data.direction:
					"left": _cycle_layout_prev()
					"right": _cycle_layout_next()
					"up": _increase_layout_spacing()
					"down": _decrease_layout_spacing()

# Handle word interaction (left controller)
func _handle_word_interaction(word_id):
	print("Interacting with word: ", word_id)
	
	match interaction_mode:
		"view":
			_show_word_details(word_id)
		"create":
			_create_child_word(word_id)
		"connect":
			if selected_word and selected_word != word_id:
				_create_word_connection(selected_word, word_id)
		"delete":
			_confirm_delete_word(word_id)

# Handle word selection (right controller)
func _handle_word_selection(word_id):
	print("Selecting word: ", word_id)
	
	# Deselect previous word if any
	if selected_word and word_nodes.has(selected_word):
		var selected_node = word_nodes[selected_word]
		var mesh = selected_node.get_node("MeshInstance3D")
		if mesh and mesh.material_override:
			mesh.material_override.emission_energy = 1.0
	
	# Set new selection
	selected_word = word_id
	
	# Highlight selected word
	if word_nodes.has(word_id):
		var selected_node = word_nodes[word_id]
		var mesh = selected_node.get_node("MeshInstance3D")
		if mesh and mesh.material_override:
			mesh.material_override.emission_energy = 2.0
	
	emit_signal("word_selected", word_id)
	_show_word_details(word_id)

# Show word details in the detail panel
func _show_word_details(word_id):
	if not akashic_records or not word_detail_panel:
		return
	
	var word_data = akashic_records.get_word(word_id)
	if word_data.is_empty():
		return
	
	# Clear previous details
	for child in word_detail_panel.get_children():
		if child is Label3D and child.name != "Title":
			child.queue_free()
	
	# Update panel title
	var title = word_detail_panel.get_node("Label3D")
	if title:
		title.text = word_id
	
	# Create property labels
	var y_pos = 0.3
	var properties = [
		"Category: " + str(word_data.get("category", "Unknown")),
		"Parent: " + str(word_data.get("parent", "None")),
		"Children: " + str(word_data.get("children", []).size()),
		"Properties: " + str(word_data.get("properties", {}).size())
	]
	
	for prop_text in properties:
		var prop_label = Label3D.new()
		prop_label.text = prop_text
		prop_label.font_size = 24
		prop_label.position = Vector3(0, y_pos, 0.01)
		word_detail_panel.add_child(prop_label)
		y_pos -= 0.1

# Create a child word for a parent
func _create_child_word(parent_id):
	print("Creating child word for: ", parent_id)
	
	# Show virtual keyboard for input
	virtual_keyboard.visible = true
	
	# Setup state for creation when keyboard is done
	# In a real implementation, this would collect input and then create the word

# Create a connection between two words
func _create_word_connection(parent_id, child_id):
	print("Creating connection from ", parent_id, " to ", child_id)
	
	if parent_id == child_id:
		print("Cannot connect a word to itself")
		return
	
	# Update dictionary data
	var parent_data = akashic_records.get_word(parent_id)
	if parent_data.is_empty():
		print("Parent word not found")
		return
	
	var child_data = akashic_records.get_word(child_id)
	if child_data.is_empty():
		print("Child word not found")
		return
	
	# Check if connection already exists
	if "children" in parent_data and parent_data.children.has(child_id):
		print("Connection already exists")
		return
	
	# Create the connection in the dictionary
	akashic_records.create_word_relation(parent_id, child_id)
	
	# Update visualization
	var connection_key = parent_id + "_" + child_id
	if not connection_nodes.has(connection_key):
		_create_connection_node(parent_id, child_id)
	
	emit_signal("word_connection_created", parent_id, child_id)

# Confirm deletion of a word
func _confirm_delete_word(word_id):
	print("Confirm deletion of word: ", word_id)
	
	# In a real implementation, this would show a confirmation UI
	# For now, we'll just proceed with deletion
	_delete_word(word_id)

# Delete a word from the dictionary and visualization
func _delete_word(word_id):
	print("Deleting word: ", word_id)
	
	# Remove from dictionary
	akashic_records.delete_word(word_id)
	
	# Remove from visualization
	if word_nodes.has(word_id):
		var node = word_nodes[word_id]
		if node and is_instance_valid(node):
			node.queue_free()
		word_nodes.erase(word_id)
	
	# Remove connections
	var connections_to_remove = []
	for connection_key in connection_nodes:
		var connection = connection_nodes[connection_key]
		var parent_id = connection.get_meta("parent_id")
		var child_id = connection.get_meta("child_id")
		
		if parent_id == word_id or child_id == word_id:
			connections_to_remove.append(connection_key)
			if connection and is_instance_valid(connection):
				connection.queue_free()
	
	for key in connections_to_remove:
		connection_nodes.erase(key)
	
	emit_signal("word_deleted", word_id)
	
	# If this was the selected word, clear selection
	if selected_word == word_id:
		selected_word = null

# Handle keyboard input
func _handle_keyboard_input(key_text):
	print("Keyboard input: ", key_text)
	
	match key_text:
		"DONE":
			virtual_keyboard.visible = false
			# Process the collected input
		"DEL":
			# Delete last character of input
			pass
		"SPC":
			# Add space to input
			pass
		_:
			# Add character to input
			pass

# Cycle to the previous layout
func _cycle_layout_prev():
	var layouts = ["radial", "hierarchical", "force_directed"]
	var current_index = layouts.find(layout_type)
	if current_index > 0:
		layout_type = layouts[current_index - 1]
	else:
		layout_type = layouts[layouts.size() - 1]
	
	_apply_layout()

# Cycle to the next layout
func _cycle_layout_next():
	var layouts = ["radial", "hierarchical", "force_directed"]
	var current_index = layouts.find(layout_type)
	if current_index < layouts.size() - 1:
		layout_type = layouts[current_index + 1]
	else:
		layout_type = layouts[0]
	
	_apply_layout()

# Increase layout spacing
func _increase_layout_spacing():
	match layout_type:
		"radial":
			layout_settings.radial_spacing *= 1.2
		"hierarchical":
			layout_settings.hierarchical_spacing *= 1.2
		"force_directed":
			layout_settings.force_strength *= 1.2
	
	_apply_layout()

# Decrease layout spacing
func _decrease_layout_spacing():
	match layout_type:
		"radial":
			layout_settings.radial_spacing *= 0.8
		"hierarchical":
			layout_settings.hierarchical_spacing *= 0.8
		"force_directed":
			layout_settings.force_strength *= 0.8
	
	_apply_layout()

# Save changes to the dictionary
func save_dictionary():
	if akashic_records:
		akashic_records.dynamic_dictionary.save_root_dictionary()
		print("Dictionary saved")
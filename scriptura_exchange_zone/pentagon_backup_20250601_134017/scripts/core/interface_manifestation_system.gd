# 🏛️ Interface Manifestation System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: interface_manifestation_system.gd
# DESCRIPTION: Bridge between Eden Records and Universal Being 3D interfaces
# PURPOSE: Convert blueprint definitions into living 3D UI elements
# ==================================================

extends UniversalBeingBase
class_name InterfaceManifestationSystem

# References to Eden Records banks
var records_bank: Node = null
var actions_bank: Node = null
var banks_combiner: Node = null

func _ready() -> void:
	# Get references to Eden Records components
	_initialize_eden_records_references()

func _initialize_eden_records_references() -> void:
	"""Initialize connections to Eden Records system"""
	# Try to get Eden Records components
	records_bank = get_node_or_null("/root/RecordsBank")
	actions_bank = get_node_or_null("/root/ActionsBank") 
	banks_combiner = get_node_or_null("/root/BanksCombiner")
	
	# If not autoloaded, try to load directly
	if not records_bank:
		var records_script = load("res://scripts/jsh_framework/core/records_bank.gd")
		if records_script:
			records_bank = Node.new()
			records_bank.set_script(records_script)
	
	if not actions_bank:
		var actions_script = load("res://scripts/jsh_framework/core/actions_bank.gd")
		if actions_script:
			actions_bank = Node.new()
			actions_bank.set_script(actions_script)

# ===== MAIN INTERFACE CREATION FUNCTIONS =====


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
func create_3d_interface_from_eden_records(interface_type: String, properties: Dictionary = {}) -> Node3D:
	"""Main function to create 3D interface from Universal Being 3D blueprints"""
	
	print("[InterfaceManifestationSystem] Creating 3D interface: ", interface_type)
	
	# Try to load 3D blueprint first
	var blueprint_data = _load_3d_blueprint(interface_type)
	if blueprint_data.is_empty():
		print("[InterfaceManifestationSystem] No 3D blueprint found, using fallback for: ", interface_type)
		return _create_fallback_interface(interface_type)
	
	# Create the 3D interface from blueprint
	var interface_3d = _create_3d_interface_from_blueprint(blueprint_data, interface_type)
	if not interface_3d:
		print("[InterfaceManifestationSystem] Blueprint creation failed, using fallback for: ", interface_type)
		return _create_fallback_interface(interface_type)
	
	print("[InterfaceManifestationSystem] Successfully created 3D interface: ", interface_type)
	return interface_3d

func _load_3d_blueprint(interface_type: String) -> Dictionary:
	"""Load 3D blueprint from TXT file"""
	print("[InterfaceManifestationSystem] 📋 Loading blueprint for: ", interface_type)
	
	# Try to load specific blueprint file
	var blueprint_path = "res://data/universal_being_3d_blueprints/" + interface_type + "_3d.txt"
	print("[InterfaceManifestationSystem] 📁 Looking for blueprint at: ", blueprint_path)
	
	# Check if file exists
	if not FileAccess.file_exists(blueprint_path):
		print("[InterfaceManifestationSystem] ❌ Blueprint file not found: ", blueprint_path)
		print("[InterfaceManifestationSystem] 🔄 Using default blueprint instead")
		var parser = load("res://scripts/core/universal_being_3d_blueprint_parser.gd").new()
		return parser.create_default_blueprint(interface_type)
	
	var parser = load("res://scripts/core/universal_being_3d_blueprint_parser.gd").new()
	var blueprint_data = parser.parse_blueprint_file(blueprint_path)
	
	if blueprint_data.is_empty():
		print("[InterfaceManifestationSystem] ❌ Failed to parse blueprint, using default for: ", interface_type)
		blueprint_data = parser.create_default_blueprint(interface_type)
	else:
		print("[InterfaceManifestationSystem] ✅ Successfully loaded blueprint with ", blueprint_data.get("total_elements", 0), " elements")
	
	return blueprint_data

func _create_3d_interface_from_blueprint(blueprint_data: Dictionary, interface_type: String) -> Node3D:
	"""Create 3D interface from parsed blueprint data"""
	
	var interface_3d = Node3D.new()
	interface_3d.name = interface_type.capitalize() + "Interface3D"
	
	var elements = blueprint_data.get("elements", [])
	print("[InterfaceManifestationSystem] Creating ", elements.size(), " elements for ", interface_type)
	
	# Create each element from blueprint
	for element in elements:
		var element_node = _create_element_from_blueprint(element)
		if element_node:
			FloodgateController.universal_add_child(element_node, interface_3d)
	
	# Add interaction area
	var area3d = _create_interaction_area(interface_type)
	FloodgateController.universal_add_child(area3d, interface_3d)
	
	# Add soul effects
	var soul_effects = _create_interface_soul_effects(interface_type)
	FloodgateController.universal_add_child(soul_effects, interface_3d)
	
	return interface_3d

func _create_element_from_blueprint(element: Dictionary) -> Node3D:
	"""Create a single 3D element from blueprint data"""
	
	var element_type = element.get("type", "")
	var position = element.get("position", Vector3.ZERO)
	var size = element.get("size", Vector2(1, 1))
	var text = element.get("text", "")
	var color = element.get("color", "white")
	var properties = element.get("properties", {})
	
	match element_type:
		"panel":
			return _create_3d_panel(position, size, text, color, properties)
		"button_3d":
			return _create_3d_button(position, size, text, color, properties)
		"text_3d":
			return _create_3d_text(position, size, text, color, properties)
		"slider_3d":
			return _create_3d_slider(position, size, text, color, properties)
		"particles_3d":
			return _create_3d_particles(position, size, text, color, properties)
		_:
			print("[InterfaceManifestationSystem] Unknown element type: ", element_type)
			return null

func _create_3d_panel(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary) -> Node3D:
	"""Create a 3D panel background"""
	
	var panel_node = Node3D.new()
	panel_node.name = "Panel_" + text.replace(" ", "_")
	panel_node.position = position
	
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(size.x, size.y, 0.1)
	mesh_instance.mesh = mesh
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = _get_color_from_string(color)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = properties.get("transparent", 0.9)
	
	if properties.get("rounded", 0) > 0:
		material.flags_use_point_size = true
	
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, panel_node)
	
	return panel_node

func _create_3d_button(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary) -> Node3D:
	"""Create a 3D button"""
	
	var button_node = Node3D.new()
	button_node.name = "Button_" + text.replace(" ", "_")
	button_node.position = position
	
	# Button mesh
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(size.x, size.y, 0.15)
	mesh_instance.mesh = mesh
	
	# Button material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = _get_color_from_string(color)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.3
	
	if properties.has("glow"):
		material.emission = _get_color_from_string(properties.glow) * 0.5
	
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, button_node)
	
	# Add text label
	var label = Label3D.new()
	label.text = text
	label.position = Vector3(0, 0, 0.1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Fix font issue - assign default font
	var default_font = ThemeDB.fallback_font
	if default_font:
		label.font = default_font
		label.font_size = 32
	
	FloodgateController.universal_add_child(label, button_node)
	
	# Add click area
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(size.x, size.y, 0.2)
	collision.shape = shape
	FloodgateController.universal_add_child(collision, area)
	FloodgateController.universal_add_child(area, button_node)
	
	# Store action in metadata
	if properties.has("action"):
		button_node.set_meta("action", properties.action)
	
	return button_node

func _create_3d_text(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary) -> Node3D:
	"""Create 3D text label"""
	
	var text_node = Node3D.new()
	text_node.name = "Text_" + text.replace(" ", "_")
	text_node.position = position
	
	var label = Label3D.new()
	label.text = text
	label.modulate = _get_color_from_string(color)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Fix font issue - assign default font
	var default_font = ThemeDB.fallback_font
	if default_font:
		label.font = default_font
		label.font_size = 32
	
	if properties.has("font_size"):
		label.pixel_size = properties.font_size * 0.001
		if default_font:
			label.font_size = properties.font_size
	
	if properties.get("glow", false):
		var material = MaterialLibrary.get_material("default")
		material.flags_unshaded = true
		material.emission_enabled = true
		material.emission = _get_color_from_string(color) * 0.5
		label.material_override = material
	
	FloodgateController.universal_add_child(label, text_node)
	return text_node

func _create_3d_slider(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary) -> Node3D:
	"""Create 3D slider control"""
	
	var slider_node = Node3D.new()
	slider_node.name = "Slider_" + text.replace(" ", "_")
	slider_node.position = position
	
	# Slider track
	var track = MeshInstance3D.new()
	var track_mesh = BoxMesh.new()
	track_mesh.size = Vector3(size.x, 0.1, 0.05)
	track.mesh = track_mesh
	
	var track_material = MaterialLibrary.get_material("default")
	track_material.albedo_color = Color.GRAY
	track.material_override = track_material
	FloodgateController.universal_add_child(track, slider_node)
	
	# Slider handle
	var handle = MeshInstance3D.new()
	var handle_mesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.2, 0.3, 0.1)
	handle.mesh = handle_mesh
	
	var handle_material = MaterialLibrary.get_material("default")
	handle_material.albedo_color = _get_color_from_string(color)
	handle.material_override = handle_material
	
	# Position handle based on default value
	var default_val = properties.get("default", 0.5)
	var min_val = properties.get("min", 0.0)
	var max_val = properties.get("max", 1.0)
	var normalized = (default_val - min_val) / (max_val - min_val)
	handle.position.x = (normalized - 0.5) * size.x
	
	FloodgateController.universal_add_child(handle, slider_node)
	return slider_node

func _create_3d_particles(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary) -> Node3D:
	"""Create 3D particle effects"""
	
	var particles_node = Node3D.new()
	particles_node.name = "Particles_" + text.replace(" ", "_")
	particles_node.position = position
	
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = properties.get("count", 20)
	particles.lifetime = properties.get("lifetime", 2.0)
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 0.3
	material.initial_velocity_max = 0.8
	material.gravity = Vector3(0, -0.3, 0)
	material.scale_min = 0.05
	material.scale_max = 0.15
	material.color = _get_color_from_string(color)
	
	particles.process_material = material
	particles.draw_pass_1 = QuadMesh.new()
	
	FloodgateController.universal_add_child(particles, particles_node)
	return particles_node

func _get_color_from_string(color_name: String) -> Color:
	"""Convert color name to Color object"""
	
	match color_name.to_lower():
		"red": return Color.RED
		"green": return Color.GREEN
		"blue": return Color.BLUE
		"yellow": return Color.YELLOW
		"orange": return Color.ORANGE
		"purple": return Color.PURPLE
		"cyan": return Color.CYAN
		"white": return Color.WHITE
		"black": return Color.BLACK
		"gray", "grey": return Color.GRAY
		"dark_blue": return Color(0.1, 0.1, 0.4)
		"dark_green": return Color(0.1, 0.4, 0.1)
		"dark_purple": return Color(0.4, 0.1, 0.4)
		"brown": return Color(0.6, 0.4, 0.2)
		_: return Color.WHITE

func _get_records_map_for_interface(interface_type: String) -> Dictionary:
	"""Get the appropriate Eden Records map for the interface type"""
	if not records_bank:
		return {}
	
	# Map interface types to Eden Records maps
	match interface_type:
		"menu", "main_menu":
			if records_bank.has("records_map_2"):
				return records_bank.records_map_2
			else:
				return {}
		"keyboard":
			if records_bank.has("records_map_4"):
				return records_bank.records_map_4
			else:
				return {}
		"things_creation", "asset_creator":
			if records_bank.has("records_map_7"):
				return records_bank.records_map_7
			else:
				return {}
		_:
			# Try to find a generic interface definition
			return _create_generic_interface_records(interface_type)

func _create_ui_from_records(records_map: Dictionary, interface_type: String) -> Control:
	"""Convert Eden Records blueprint into 2D UI"""
	var main_container = Control.new()
	main_container.name = interface_type.capitalize() + "UI"
	main_container.size = Vector2(1024, 768)
	
	# Create background panel
	var bg_panel = PanelContainer.new()
	bg_panel.size = main_container.size
	bg_panel.position = Vector2.ZERO
	
	# Style the background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.2, 0.9)  # Dark blue with transparency
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.4, 0.6, 1.0)  # Blue border
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	bg_panel.add_theme_stylebox_override("panel", style_box)
	
	FloodgateController.universal_add_child(bg_panel, main_container)
	
	# Add title
	var title_label = Label.new()
	title_label.text = interface_type.capitalize() + " Interface"
	title_label.position = Vector2(20, 10)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(title_label, main_container)
	
	# Create buttons/elements from records
	_create_elements_from_records(main_container, records_map, interface_type)
	
	return main_container

func _create_elements_from_records(container: Control, records_map: Dictionary, interface_type: String) -> void:
	"""Create UI elements from Eden Records definitions"""
	var y_offset = 60  # Start below title
	
	# Parse records and create elements
	for record_id in records_map:
		var record = records_map[record_id]
		if record is Array and record.size() >= 4:
			var element_info = record[0][0] if record[0] is Array and record[0].size() > 0 else ""
			var container_name = record[1][0] if record[1] is Array and record[1].size() > 0 else ""
			var display_text = record[2][0] if record[2] is Array and record[2].size() > 0 else "Button"
			var position_data = record[3][0] if record[3] is Array and record[3].size() > 0 else "0.1|0.1"
			
			# Create button element
			var button = Button.new()
			button.text = display_text
			button.size = Vector2(200, 40)
			
			# Parse position (format: "x|y" as 0-1 normalized)
			var pos_parts = position_data.split("|")
			if pos_parts.size() >= 2:
				var x_norm = pos_parts[0].to_float()
				var y_norm = pos_parts[1].to_float()
				button.position = Vector2(x_norm * 800 + 20, y_norm * 600 + 60)
			else:
				button.position = Vector2(20, y_offset)
				y_offset += 50
			
			# Style the button
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = Color(0.2, 0.4, 0.8)
			button_style.corner_radius_top_left = 5
			button_style.corner_radius_top_right = 5
			button_style.corner_radius_bottom_left = 5
			button_style.corner_radius_bottom_right = 5
			button.add_theme_stylebox_override("normal", button_style)
			button.add_theme_color_override("font_color", Color.WHITE)
			
			# Connect button signal (will be enhanced later)
			button.pressed.connect(_on_interface_button_pressed.bind(display_text, interface_type))
			
			FloodgateController.universal_add_child(button, container)

func _create_interaction_area(interface_type: String) -> Area3D:
	"""Create 3D interaction area for the interface"""
	var area3d = Area3D.new()
	area3d.name = "InteractionArea"
	
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	# Size based on interface type
	match interface_type:
		"console":
			box_shape.size = Vector3(5, 2, 0.1)
		"asset_creator", "things_creation":
			box_shape.size = Vector3(4, 3, 0.1)
		_:
			box_shape.size = Vector3(3, 2, 0.1)
	
	collision.shape = box_shape
	FloodgateController.universal_add_child(collision, area3d)
	
	# Connect interaction signals
	area3d.input_event.connect(_on_interface_area_clicked)
	area3d.mouse_entered.connect(_on_interface_hover_start.bind(interface_type))
	area3d.mouse_exited.connect(_on_interface_hover_end.bind(interface_type))
	
	return area3d

func _create_interface_soul_effects(interface_type: String) -> Node3D:
	"""Add soul effects - particles, glow, energy to the interface"""
	var soul_container = Node3D.new()
	soul_container.name = "SoulEffects"
	
	# Create particle system for energy
	var particles = GPUParticles3D.new()
	particles.name = "EnergyParticles"
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 2.0
	
	# Create particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 0.5
	particle_material.initial_velocity_max = 1.0
	particle_material.gravity = Vector3(0, -0.5, 0)
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.3
	
	# Color based on interface type
	match interface_type:
		"asset_creator":
			particle_material.color = Color(1.0, 0.6, 0.0, 0.7)  # Orange energy
		"console":
			particle_material.color = Color(0.0, 1.0, 1.0, 0.7)  # Cyan energy
		"grid":
			particle_material.color = Color(0.0, 1.0, 0.0, 0.7)  # Green energy
		_:
			particle_material.color = Color(0.7, 0.7, 1.0, 0.7)  # Blue energy
	
	particles.process_material = particle_material
	
	# Create particle mesh
	var particle_mesh = QuadMesh.new()
	particle_mesh.size = Vector2(0.1, 0.1)
	particles.draw_pass_1 = particle_mesh
	
	FloodgateController.universal_add_child(particles, soul_container)
	
	# Add subtle glow effect
	var glow_light = OmniLight3D.new()
	glow_light.name = "GlowLight"
	glow_light.light_energy = 0.3
	glow_light.omni_range = 3.0
	glow_light.light_color = particle_material.color
	FloodgateController.universal_add_child(glow_light, soul_container)
	
	return soul_container

func _wire_interface_interactions(interface_3d: Node3D, ui_control: Control, interface_type: String) -> void:
	"""Wire up interaction behaviors using Actions Bank definitions"""
	# Store reference to UI for interaction handling
	interface_3d.set_meta("ui_control", ui_control)
	interface_3d.set_meta("interface_type", interface_type)
	
	# TODO: Load and wire specific interactions from actions_bank
	print("[InterfaceManifestationSystem] Wired interactions for: ", interface_type)

# ===== INTERACTION HANDLERS =====

func _on_interface_button_pressed(button_text: String, interface_type: String) -> void:
	"""Handle button presses in the interface"""
	print("[InterfaceManifestationSystem] Button pressed: ", button_text, " in ", interface_type)
	
	# TODO: Route to appropriate action based on Actions Bank definitions
	match button_text.to_lower():
		"things", "create":
			_handle_creation_action()
		"settings":
			_handle_settings_action()
		"exit", "back":
			_handle_exit_action()
		_:
			print("[InterfaceManifestationSystem] Unknown button: ", button_text)

func _on_interface_area_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	"""Handle clicks on the 3D interface area"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[InterfaceManifestationSystem] Interface area clicked at: ", position)

func _on_interface_hover_start(interface_type: String) -> void:
	"""Handle mouse entering interface"""
	print("[InterfaceManifestationSystem] Hovering over: ", interface_type)

func _on_interface_hover_end(interface_type: String) -> void:
	"""Handle mouse leaving interface"""
	print("[InterfaceManifestationSystem] Stopped hovering: ", interface_type)

# ===== ACTION HANDLERS =====

func _handle_creation_action() -> void:
	"""Handle creation-related actions"""
	print("[InterfaceManifestationSystem] Handling creation action")
	# TODO: Trigger object creation through console or direct creation

func _handle_settings_action() -> void:
	"""Handle settings-related actions"""
	print("[InterfaceManifestationSystem] Handling settings action")

func _handle_exit_action() -> void:
	"""Handle exit/back actions"""
	print("[InterfaceManifestationSystem] Handling exit action")

# ===== FALLBACK FUNCTIONS =====

func _create_fallback_interface(interface_type: String) -> Node3D:
	"""Create a fallback interface when Eden Records aren't available"""
	print("[InterfaceManifestationSystem] 🔄 Creating fallback interface for: ", interface_type)
	
	var fallback = Node3D.new()
	fallback.name = "FallbackInterface_" + interface_type
	
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(3.0, 2.0, 0.2)  # Larger, more visible
	mesh_instance.mesh = mesh
	mesh_instance.name = "FallbackMesh"
	
	var material = MaterialLibrary.get_material("default")
	
	# Color based on interface type
	match interface_type:
		"asset_creator":
			material.albedo_color = Color.ORANGE
			material.emission = Color.ORANGE * 0.3
		"console":
			material.albedo_color = Color.CYAN  
			material.emission = Color.CYAN * 0.3
		"inspector":
			material.albedo_color = Color.YELLOW
			material.emission = Color.YELLOW * 0.3
		_:
			material.albedo_color = Color(0.8, 0.4, 0.8)  # Purple for unknown
			material.emission = Color(0.4, 0.2, 0.4)
	
	material.emission_enabled = true
	material.flags_unshaded = true  # Make it glow
	mesh_instance.material_override = material
	
	FloodgateController.universal_add_child(mesh_instance, fallback)
	
	# Add a text label
	var label = Label3D.new()
	label.text = interface_type.capitalize() + " Interface"
	label.position = Vector3(0, 0, 0.2)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE
	
	# Fix font issue - assign default font
	var default_font = ThemeDB.fallback_font
	if default_font:
		label.font = default_font
		label.font_size = 32
	
	FloodgateController.universal_add_child(label, fallback)
	
	print("[InterfaceManifestationSystem] ✅ Created fallback interface: ", fallback.name, " at position ", fallback.position)
	return fallback

func _create_generic_interface_records(interface_type: String) -> Dictionary:
	"""Create generic interface records when specific ones aren't found"""
	return {
		0: [
			["button|generic|button_1"],
			["main_container"],
			[interface_type.capitalize()],
			["0.5|0.3"],
			["0.3|0.1"]
		],
		1: [
			["button|generic|button_2"],
			["main_container"], 
			["Close"],
			["0.5|0.7"],
			["0.2|0.1"]
		]
	}

# ===== STATIC HELPER FUNCTIONS =====

static func create_interface_for_universal_being(being: UniversalBeing, interface_type: String, properties: Dictionary = {}) -> Node3D:
	"""Static function to create interface for a Universal Being"""
	var script = load("res://scripts/core/interface_manifestation_system.gd")
	var manifestation_system = script.new()
	return manifestation_system.create_3d_interface_from_eden_records(interface_type, properties)
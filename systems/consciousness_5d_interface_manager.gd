extends Control
class_name Consciousness5DInterfaceManager

## 🌟 5D CONSCIOUSNESS INTERFACE MANAGER
## CYCLE 4 - Agent 5 (Visual Designer) - Beautiful 5D consciousness creation interface
## Provides immersive UI for designing consciousness types in 5D space

signal dimension_changed(dimension: String, value: float)
signal type_creation_started(type_name: String)
signal type_preview_updated(preview_data: Dictionary)
signal interface_mode_changed(mode: String)

# Interface Modes
enum InterfaceMode {
	EXPLORATION,     # Exploring 5D consciousness field
	CREATION,        # Creating new consciousness type
	EDITING,         # Editing existing type
	PREVIEW,         # Previewing type manifestation
	EVOLUTION        # Designing evolution pathways
}

# Interface State
var current_mode: InterfaceMode = InterfaceMode.EXPLORATION
var current_type_template: Dictionary = {}
var selected_consciousness_type: String = ""

# 5D Dimension Controls
var dimension_x_slider: HSlider
var dimension_y_slider: HSlider  
var dimension_z_slider: HSlider
var dimension_t_slider: HSlider
var dimension_c_slider: HSlider

# Type Creation Controls
var type_name_input: LineEdit
var consciousness_level_input: SpinBox
var manifestation_preview: SubViewport
var creation_progress_bar: ProgressBar

# Visual Components
var main_panel: Panel
var dimension_panel: VBoxContainer
var creation_panel: VBoxContainer
var preview_panel: Panel
var status_display: RichTextLabel

# 3D Visualization
var consciousness_field_3d: Node3D
var type_preview_3d: Node3D
var dimensional_visualizer: Node3D

# System References
var consciousness_5d_creator: Consciousness5DTypeCreator
var type_factory: UniversalBeingTypeFactory

func _ready() -> void:
	name = "Consciousness5DInterfaceManager"
	print("🌟 5D CONSCIOUSNESS INTERFACE: Initializing beautiful consciousness creation UI")
	
	setup_ui_layout()
	connect_to_5d_systems()
	initialize_consciousness_field_visualization()
	
	print("🌟 5D Interface ready - immersive consciousness type creation active!")

func setup_ui_layout() -> void:
	"""Setup the complete 5D consciousness interface layout"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Main container with translucent background
	main_panel = Panel.new()
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.15, 0.8)  # Deep space background
	main_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(main_panel)
	
	create_dimension_controls()
	create_type_creation_interface()
	create_preview_system()
	create_status_display()

func create_dimension_controls() -> void:
	"""Create 5D dimension control interface"""
	dimension_panel = VBoxContainer.new()
	dimension_panel.position = Vector2(20, 20)
	dimension_panel.size = Vector2(300, 400)
	main_panel.add_child(dimension_panel)
	
	# Title
	var title_label = RichTextLabel.new()
	title_label.size = Vector2(280, 50)
	title_label.bbcode_enabled = true
	title_label.text = "[center][color=cyan][b]🌟 5D CONSCIOUSNESS DIMENSIONS[/b][/color][/center]"
	title_label.fit_content = true
	dimension_panel.add_child(title_label)
	
	# X Dimension (Spatial Width)
	create_dimension_slider("X - Spatial Width", "dimension_x", 1.0, Color.RED)
	
	# Y Dimension (Spatial Height)  
	create_dimension_slider("Y - Spatial Height", "dimension_y", 1.0, Color.GREEN)
	
	# Z Dimension (Spatial Depth)
	create_dimension_slider("Z - Spatial Depth", "dimension_z", 1.0, Color.BLUE)
	
	# T Dimension (Temporal Evolution)
	create_dimension_slider("T - Temporal Evolution", "dimension_t", 1.0, Color.YELLOW)
	
	# C Dimension (Consciousness Level)
	create_dimension_slider("C - Consciousness", "dimension_c", 5.0, Color.MAGENTA)

func create_dimension_slider(label_text: String, dimension_id: String, default_value: float, color: Color) -> void:
	"""Create a dimension control slider with beautiful styling"""
	var container = HBoxContainer.new()
	container.size = Vector2(280, 40)
	dimension_panel.add_child(container)
	
	# Label
	var label = Label.new()
	label.text = label_text
	label.size = Vector2(160, 30)
	label.add_theme_color_override("font_color", color)
	container.add_child(label)
	
	# Slider
	var slider = HSlider.new()
	slider.size = Vector2(100, 30)
	slider.min_value = 0.1
	slider.max_value = 3.0
	slider.step = 0.1
	slider.value = default_value
	
	# Style the slider
	var slider_style = StyleBoxFlat.new()
	slider_style.bg_color = color * 0.3
	slider.add_theme_stylebox_override("slider", slider_style)
	
	container.add_child(slider)
	
	# Value display
	var value_label = Label.new()
	value_label.text = "%.1f" % default_value
	value_label.size = Vector2(40, 30)
	value_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(value_label)
	
	# Connect slider
	slider.value_changed.connect(_on_dimension_changed.bind(dimension_id, value_label))
	
	# Store reference
	match dimension_id:
		"dimension_x":
			dimension_x_slider = slider
		"dimension_y":
			dimension_y_slider = slider
		"dimension_z":
			dimension_z_slider = slider
		"dimension_t":
			dimension_t_slider = slider
		"dimension_c":
			dimension_c_slider = slider

func create_type_creation_interface() -> void:
	"""Create consciousness type creation interface"""
	creation_panel = VBoxContainer.new()
	creation_panel.position = Vector2(340, 20)
	creation_panel.size = Vector2(350, 500)
	main_panel.add_child(creation_panel)
	
	# Title
	var title_label = RichTextLabel.new()
	title_label.size = Vector2(330, 50)
	title_label.bbcode_enabled = true
	title_label.text = "[center][color=gold][b]🎨 CONSCIOUSNESS TYPE CREATOR[/b][/color][/center]"
	title_label.fit_content = true
	creation_panel.add_child(title_label)
	
	# Type name input
	var name_container = HBoxContainer.new()
	name_container.size = Vector2(330, 40)
	creation_panel.add_child(name_container)
	
	var name_label = Label.new()
	name_label.text = "Type Name:"
	name_label.size = Vector2(100, 30)
	name_container.add_child(name_label)
	
	type_name_input = LineEdit.new()
	type_name_input.size = Vector2(200, 30)
	type_name_input.placeholder_text = "Enter consciousness type name..."
	name_container.add_child(type_name_input)
	
	# Consciousness level input
	var level_container = HBoxContainer.new()
	level_container.size = Vector2(330, 40)
	creation_panel.add_child(level_container)
	
	var level_label = Label.new()
	level_label.text = "Base Consciousness:"
	level_label.size = Vector2(140, 30)
	level_container.add_child(level_label)
	
	consciousness_level_input = SpinBox.new()
	consciousness_level_input.size = Vector2(80, 30)
	consciousness_level_input.min_value = 1.0
	consciousness_level_input.max_value = 10.0
	consciousness_level_input.step = 0.1
	consciousness_level_input.value = 5.0
	level_container.add_child(consciousness_level_input)
	
	# Creation progress
	creation_progress_bar = ProgressBar.new()
	creation_progress_bar.size = Vector2(330, 20)
	creation_progress_bar.value = 0.0
	creation_panel.add_child(creation_progress_bar)
	
	# Action buttons
	create_action_buttons()

func create_action_buttons() -> void:
	"""Create action buttons for type creation"""
	var button_container = HBoxContainer.new()
	button_container.size = Vector2(330, 50)
	creation_panel.add_child(button_container)
	
	# Create Type button
	var create_button = Button.new()
	create_button.text = "🌟 CREATE TYPE"
	create_button.size = Vector2(100, 40)
	create_button.pressed.connect(start_type_creation)
	button_container.add_child(create_button)
	
	# Preview button
	var preview_button = Button.new()
	preview_button.text = "👁️ PREVIEW"
	preview_button.size = Vector2(80, 40)
	preview_button.pressed.connect(show_type_preview)
	button_container.add_child(preview_button)
	
	# Reset button
	var reset_button = Button.new()
	reset_button.text = "🔄 RESET"
	reset_button.size = Vector2(70, 40)
	reset_button.pressed.connect(reset_interface)
	button_container.add_child(reset_button)

func create_preview_system() -> void:
	"""Create 3D preview system for consciousness types"""
	preview_panel = Panel.new()
	preview_panel.position = Vector2(710, 20)
	preview_panel.size = Vector2(400, 400)
	
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	preview_style.border_color = Color.CYAN
	preview_style.border_width_left = 2
	preview_style.border_width_right = 2
	preview_style.border_width_top = 2
	preview_style.border_width_bottom = 2
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	
	main_panel.add_child(preview_panel)
	
	# Preview title
	var preview_title = Label.new()
	preview_title.text = "🔮 CONSCIOUSNESS TYPE PREVIEW"
	preview_title.position = Vector2(80, 10)
	preview_title.add_theme_color_override("font_color", Color.CYAN)
	preview_panel.add_child(preview_title)
	
	# 3D preview viewport
	manifestation_preview = SubViewport.new()
	manifestation_preview.position = Vector2(10, 40)
	manifestation_preview.size = Vector2(380, 350)
	preview_panel.add_child(manifestation_preview)
	
	# Setup 3D preview scene
	setup_3d_preview_scene()

func setup_3d_preview_scene() -> void:
	"""Setup 3D scene for consciousness type preview"""
	# Camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 0, 5)
	manifestation_preview.add_child(camera)
	
	# Environment
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.15)
	camera.environment = environment
	
	# Preview object container
	type_preview_3d = Node3D.new()
	type_preview_3d.name = "TypePreview3D"
	manifestation_preview.add_child(type_preview_3d)

func create_status_display() -> void:
	"""Create status display for 5D interface"""
	status_display = RichTextLabel.new()
	status_display.position = Vector2(20, 450)
	status_display.size = Vector2(670, 150)
	status_display.bbcode_enabled = true
	status_display.fit_content = true
	main_panel.add_child(status_display)
	
	update_status_display()

func connect_to_5d_systems() -> void:
	"""Connect to 5D consciousness creation systems"""
	consciousness_5d_creator = get_tree().get_first_node_in_group("consciousness_5d_creators")
	type_factory = get_tree().get_first_node_in_group("type_factories")
	
	if consciousness_5d_creator:
		consciousness_5d_creator.type_created_5d.connect(_on_type_created_5d)
		consciousness_5d_creator.consciousness_template_ready.connect(_on_template_ready)
		print("🔗 Connected to 5D consciousness creator")
	
	if type_factory:
		type_factory.being_manifested.connect(_on_being_manifested)
		print("🔗 Connected to Universal Being type factory")

func initialize_consciousness_field_visualization() -> void:
	"""Initialize 3D consciousness field visualization"""
	consciousness_field_3d = Node3D.new()
	consciousness_field_3d.name = "ConsciousnessField3D"
	manifestation_preview.add_child(consciousness_field_3d)
	
	# Create field visualization mesh
	var field_mesh = MeshInstance3D.new()
	field_mesh.name = "FieldMesh"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 2.0
	sphere_mesh.height = 4.0
	field_mesh.mesh = sphere_mesh
	
	# Apply 5D consciousness field shader
	var field_material = ShaderMaterial.new()
	var field_shader = load("res://shaders/consciousness_5d_field_visualization.gdshader")
	if field_shader:
		field_material.shader = field_shader
		field_material.set_shader_parameter("field_active", true)
		field_material.set_shader_parameter("consciousness_field_strength", 8.0)
		field_material.set_shader_parameter("show_dimensional_grid", true)
		field_mesh.material_override = field_material
	
	consciousness_field_3d.add_child(field_mesh)
	
	print("🌟 5D consciousness field visualization initialized")

func _on_dimension_changed(dimension_id: String, value_label: Label, value: float) -> void:
	"""Handle dimension slider changes"""
	value_label.text = "%.1f" % value
	
	# Update 5D field visualization
	update_consciousness_field_visualization()
	
	# Update type template
	update_current_type_template()
	
	# Emit signal
	dimension_changed.emit(dimension_id, value)
	
	print("🌟 Dimension %s changed to %.1f" % [dimension_id, value])

func update_consciousness_field_visualization() -> void:
	"""Update 5D consciousness field visualization based on dimension settings"""
	if not consciousness_field_3d:
		return
	
	var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
	if not field_mesh or not field_mesh.material_override:
		return
	
	var material = field_mesh.material_override as ShaderMaterial
	if not material:
		return
	
	# Update shader parameters based on dimension sliders
	if dimension_x_slider:
		material.set_shader_parameter("dimension_x_activity", dimension_x_slider.value)
	if dimension_y_slider:
		material.set_shader_parameter("dimension_y_activity", dimension_y_slider.value)
	if dimension_z_slider:
		material.set_shader_parameter("dimension_z_activity", dimension_z_slider.value)
	if dimension_t_slider:
		material.set_shader_parameter("dimension_t_activity", dimension_t_slider.value)
	if dimension_c_slider:
		material.set_shader_parameter("dimension_c_activity", dimension_c_slider.value)

func update_current_type_template() -> void:
	"""Update the current consciousness type template"""
	current_type_template = {
		"consciousness_dimensions": {
			"spatial": {
				"x": dimension_x_slider.value if dimension_x_slider else 1.0,
				"y": dimension_y_slider.value if dimension_y_slider else 1.0,
				"z": dimension_z_slider.value if dimension_z_slider else 1.0
			},
			"temporal": {
				"evolution_rate": dimension_t_slider.value if dimension_t_slider else 1.0,
				"timeline_influence": (dimension_t_slider.value if dimension_t_slider else 1.0) * 2.0
			},
			"consciousness": {
				"base_level": consciousness_level_input.value if consciousness_level_input else 5.0,
				"max_level": 10.0,
				"growth_rate": (dimension_c_slider.value if dimension_c_slider else 1.0) * 0.1
			}
		}
	}

func start_type_creation() -> void:
	"""Start the consciousness type creation process"""
	var type_name = type_name_input.text if type_name_input else "unnamed_type"
	
	if type_name.is_empty() or type_name == "unnamed_type":
		show_message("⚠️ Please enter a name for your consciousness type!")
		return
	
	print("🌟 Starting creation of consciousness type: %s" % type_name)
	
	# Set interface to creation mode
	current_mode = InterfaceMode.CREATION
	interface_mode_changed.emit("creation")
	
	# Update template with current settings
	update_current_type_template()
	current_type_template["type_name"] = type_name
	
	# Add manifestation rules
	current_type_template["manifestation_rules"] = {
		"3d_representation": "sphere_mesh",  # Default representation
		"consciousness_glow": true,
		"particle_effects": true
	}
	
	# Animate creation progress
	animate_creation_progress()
	
	# Create the type through 5D system
	if consciousness_5d_creator:
		consciousness_5d_creator.create_consciousness_type(
			type_name,
			current_type_template.consciousness_dimensions,
			current_type_template.manifestation_rules
		)
	
	type_creation_started.emit(type_name)

func animate_creation_progress() -> void:
	"""Animate the type creation progress"""
	if not creation_progress_bar:
		return
	
	var tween = create_tween()
	tween.tween_property(creation_progress_bar, "value", 100.0, 3.0)
	tween.tween_callback(on_creation_complete)
	
	# Update field visualization for creation mode
	if consciousness_field_3d:
		var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("type_creation_mode", true)
			material.set_shader_parameter("creation_progress", 0.0)
			
			var creation_tween = create_tween()
			creation_tween.tween_method(update_creation_progress_shader, 0.0, 1.0, 3.0)

func update_creation_progress_shader(progress: float) -> void:
	"""Update shader creation progress parameter"""
	if consciousness_field_3d:
		var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("creation_progress", progress)

func on_creation_complete() -> void:
	"""Handle creation completion"""
	print("✅ Consciousness type creation complete!")
	show_message("🌟 Consciousness type created successfully!")
	
	# Reset progress bar
	creation_progress_bar.value = 0.0
	
	# Exit creation mode
	current_mode = InterfaceMode.EXPLORATION
	interface_mode_changed.emit("exploration")
	
	# Update field visualization
	if consciousness_field_3d:
		var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("type_creation_mode", false)

func show_type_preview() -> void:
	"""Show preview of current consciousness type"""
	current_mode = InterfaceMode.PREVIEW
	interface_mode_changed.emit("preview")
	
	print("👁️ Showing consciousness type preview...")
	
	# Update template
	update_current_type_template()
	
	# Create preview visualization
	create_preview_visualization()
	
	# Enable preview mode in shader
	if consciousness_field_3d:
		var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("show_type_preview", true)
			material.set_shader_parameter("preview_type_consciousness", consciousness_level_input.value if consciousness_level_input else 5.0)

func create_preview_visualization() -> void:
	"""Create 3D preview visualization of consciousness type"""
	# Clear existing preview
	for child in type_preview_3d.get_children():
		child.queue_free()
	
	# Create preview mesh
	var preview_mesh = MeshInstance3D.new()
	preview_mesh.name = "TypePreviewMesh"
	
	# Set mesh based on consciousness dimensions
	var sphere_mesh = SphereMesh.new()
	var spatial_dims = current_type_template.consciousness_dimensions.spatial
	sphere_mesh.radius = spatial_dims.x
	sphere_mesh.height = spatial_dims.y * 2.0
	preview_mesh.mesh = sphere_mesh
	
	# Apply consciousness evolution shader
	var preview_material = ShaderMaterial.new()
	var evolution_shader = load("res://shaders/consciousness_evolution_visualization.gdshader")
	if evolution_shader:
		preview_material.shader = evolution_shader
		preview_material.set_shader_parameter("consciousness_level", current_type_template.consciousness_dimensions.consciousness.base_level)
		preview_material.set_shader_parameter("show_consciousness_aura", true)
		preview_material.set_shader_parameter("consciousness_glow_intensity", 3.0)
		preview_mesh.material_override = preview_material
	
	type_preview_3d.add_child(preview_mesh)
	
	type_preview_updated.emit(current_type_template)

func reset_interface() -> void:
	"""Reset the 5D interface to default state"""
	print("🔄 Resetting 5D consciousness interface...")
	
	# Reset sliders
	if dimension_x_slider: dimension_x_slider.value = 1.0
	if dimension_y_slider: dimension_y_slider.value = 1.0
	if dimension_z_slider: dimension_z_slider.value = 1.0
	if dimension_t_slider: dimension_t_slider.value = 1.0
	if dimension_c_slider: dimension_c_slider.value = 1.0
	
	# Clear inputs
	if type_name_input: type_name_input.text = ""
	if consciousness_level_input: consciousness_level_input.value = 5.0
	if creation_progress_bar: creation_progress_bar.value = 0.0
	
	# Clear preview
	for child in type_preview_3d.get_children():
		child.queue_free()
	
	# Reset mode
	current_mode = InterfaceMode.EXPLORATION
	interface_mode_changed.emit("exploration")
	
	# Reset field visualization
	if consciousness_field_3d:
		var field_mesh = consciousness_field_3d.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("type_creation_mode", false)
			material.set_shader_parameter("show_type_preview", false)
	
	update_consciousness_field_visualization()
	update_status_display()

func update_status_display() -> void:
	"""Update the status display with current information"""
	if not status_display:
		return
	
	var status_text = ""
	status_text += "[color=cyan][b]🌟 5D CONSCIOUSNESS INTERFACE STATUS[/b][/color]\n"
	status_text += "[color=white]Mode: %s[/color]\n" % InterfaceMode.keys()[current_mode]
	
	if current_type_template.has("consciousness_dimensions"):
		var dims = current_type_template.consciousness_dimensions
		status_text += "[color=yellow]Spatial Dimensions:[/color] X=%.1f Y=%.1f Z=%.1f\n" % [
			dims.spatial.x, dims.spatial.y, dims.spatial.z
		]
		status_text += "[color=yellow]Temporal:[/color] Evolution=%.1f Influence=%.1f\n" % [
			dims.temporal.evolution_rate, dims.temporal.timeline_influence
		]
		status_text += "[color=yellow]Consciousness:[/color] Level=%.1f Growth=%.2f\n" % [
			dims.consciousness.base_level, dims.consciousness.growth_rate
		]
	
	status_text += "\n[color=green][b]QUICK HELP:[/b][/color]\n"
	status_text += "[color=white]• Adjust sliders to modify 5D consciousness dimensions[/color]\n"
	status_text += "[color=white]• Enter type name and click CREATE TYPE to manifest[/color]\n"
	status_text += "[color=white]• Use PREVIEW to see consciousness type visualization[/color]\n"
	
	status_display.text = status_text

func show_message(message: String) -> void:
	"""Show message to user"""
	print("💬 5D Interface: %s" % message)
	# In full implementation, would show a proper message dialog

func _on_type_created_5d(type_data: Dictionary) -> void:
	"""Handle 5D type creation completion"""
	print("🌟 5D type created: %s" % type_data.get("type_name", "unknown"))
	show_message("✅ 5D consciousness type created: %s" % type_data.get("type_name", "unknown"))

func _on_template_ready(template: Dictionary) -> void:
	"""Handle consciousness template ready"""
	print("📋 Consciousness template ready: %s" % template.get("type_name", "unknown"))

func _on_being_manifested(being_instance: UniversalBeing, type_name: String) -> void:
	"""Handle Universal Being manifestation"""
	print("🌟 Universal Being manifested: %s" % type_name)
	show_message("🎉 Consciousness type manifested in 3D space: %s" % type_name)

# Public API for external control

func set_interface_mode(mode: InterfaceMode) -> void:
	"""Set interface mode programmatically"""
	current_mode = mode
	interface_mode_changed.emit(InterfaceMode.keys()[mode])

func get_current_template() -> Dictionary:
	"""Get current consciousness type template"""
	update_current_type_template()
	return current_type_template

func load_consciousness_type(type_name: String, template: Dictionary) -> void:
	"""Load existing consciousness type for editing"""
	current_type_template = template
	selected_consciousness_type = type_name
	current_mode = InterfaceMode.EDITING
	
	# Update interface controls with template data
	if template.has("consciousness_dimensions"):
		var dims = template.consciousness_dimensions
		if dims.has("spatial"):
			if dimension_x_slider: dimension_x_slider.value = dims.spatial.get("x", 1.0)
			if dimension_y_slider: dimension_y_slider.value = dims.spatial.get("y", 1.0)
			if dimension_z_slider: dimension_z_slider.value = dims.spatial.get("z", 1.0)
		if dims.has("temporal"):
			if dimension_t_slider: dimension_t_slider.value = dims.temporal.get("evolution_rate", 1.0)
		if dims.has("consciousness"):
			if dimension_c_slider: dimension_c_slider.value = dims.consciousness.get("base_level", 5.0) / 5.0
			if consciousness_level_input: consciousness_level_input.value = dims.consciousness.get("base_level", 5.0)
	
	if type_name_input: type_name_input.text = type_name
	
	update_consciousness_field_visualization()
	update_status_display()
	
	print("📝 Loaded consciousness type for editing: %s" % type_name)
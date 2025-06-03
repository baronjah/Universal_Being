# ==================================================
# UNIVERSAL BEING COMPONENT: Reality Editor
# TYPE: Interface Component
# PURPOSE: Visual reality manipulation - edit universe laws, beings, and create components from within the game
# AUTHOR: Claude Desktop MCP
# DATE: 2025-06-03
# ==================================================

extends "res://core/Component.gd"
class_name RealityEditorComponent

# ===== EDITOR MODES =====
enum EditorMode {
	UNIVERSE_LAWS,     # Edit physics, time, consciousness rules
	BEING_PROPERTIES,  # Modify being attributes in real-time
	COMPONENT_CREATOR, # Create new .ub.zip components visually
	LOGIC_CONNECTOR,   # Visual node-based logic connections
	REALITY_SCULPT     # Free-form reality manipulation
}

# ===== EDITOR STATE =====
var current_mode: EditorMode = EditorMode.UNIVERSE_LAWS
var editor_window: Window = null
var main_container: Control = null
var mode_tabs: TabContainer = null
var is_editing: bool = false
var auto_save_timer: float = 0.0
var auto_save_interval: float = 5.0

# ===== TARGET REFERENCES =====
var current_universe: Node = null
var selected_being: UniversalBeing = null
var edited_components: Array[Dictionary] = []
var reality_changes: Dictionary = {}

# ===== UI REFERENCES =====
var law_editor: Control = null
var being_editor: Control = null
var component_creator: Control = null
var logic_canvas: GraphEdit = null
var reality_sculptor: Control = null

# ===== VISUAL FEEDBACK =====
var preview_viewport: SubViewport = null
var preview_camera: Camera3D = null
var gizmo_system: Node3D = null

# ===== AKASHIC INTEGRATION =====
var akashic_logger: Node = null
var genesis_log_buffer: Array[String] = []

# ===== COMPONENT LIFECYCLE =====

func component_init() -> void:
	component_type = "reality_editor"
	component_name = "Reality Editor"
	tags = ["interface", "editor", "visual", "creation", "ai_compatible"]
	
	# Genesis log
	_log_genesis("The Reality Editor awakens - a sacred interface where creators become architects of existence...")

func component_ready() -> void:
	# Find Akashic Logger
	akashic_logger = attached_being.get_tree().get_first_node_in_group("akashic_library")
	
	# Create editor interface
	_create_editor_window()
	
	# Connect to universe system
	_connect_to_universe_system()
	
	# Initialize preview system
	_setup_preview_viewport()
	
	_log_genesis("Reality Editor manifested - the power to shape existence now lies within...")

func component_process(delta: float) -> void:
	if not is_editing:
		return
	
	# Auto-save functionality
	auto_save_timer += delta
	if auto_save_timer >= auto_save_interval:
		_auto_save_changes()
		auto_save_timer = 0.0
	
	# Update preview
	if preview_viewport:
		_update_reality_preview()

# ===== EDITOR WINDOW CREATION =====

func _create_editor_window() -> void:
	editor_window = Window.new()
	editor_window.title = "🌌 Reality Editor - Shape Existence Itself"
	editor_window.size = Vector2i(1200, 800)
	editor_window.position = Vector2i(100, 100)
	editor_window.wrap_controls = true
	editor_window.close_requested.connect(_on_window_close_requested)
	editor_window.always_on_top = true
	
	# Main container
	main_container = VBoxContainer.new()
	main_container.custom_minimum_size = Vector2(1180, 780)
	editor_window.add_child(main_container)
	
	# Header with poetic title
	var header = _create_header()
	main_container.add_child(header)
	
	# Mode tabs
	mode_tabs = TabContainer.new()
	mode_tabs.custom_minimum_size = Vector2(1160, 700)
	main_container.add_child(mode_tabs)
	
	# Create each mode interface
	_create_universe_laws_editor()
	_create_being_properties_editor()
	_create_component_creator()
	_create_logic_connector()
	_create_reality_sculptor()
	
	# Status bar
	var status_bar = _create_status_bar()
	main_container.add_child(status_bar)

func _create_header() -> Control:
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)
	
	var header_content = VBoxContainer.new()
	header.add_child(header_content)
	
	var title = Label.new()
	title.text = "✨ Reality Editor ✨"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))
	header_content.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Shape the laws of existence, sculpt consciousness, birth new realities..."
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	header_content.add_child(subtitle)
	
	return header
# ===== UNIVERSE LAWS EDITOR =====

func _create_universe_laws_editor() -> void:
	law_editor = ScrollContainer.new()
	law_editor.custom_minimum_size = Vector2(1140, 650)
	mode_tabs.add_child(law_editor)
	mode_tabs.set_tab_title(0, "🌍 Universe Laws")
	
	var laws_content = VBoxContainer.new()
	law_editor.add_child(laws_content)
	
	# Universe selector
	var universe_section = _create_section("Select Universe")
	laws_content.add_child(universe_section)
	
	var universe_selector = OptionButton.new()
	universe_selector.custom_minimum_size = Vector2(400, 40)
	universe_selector.item_selected.connect(_on_universe_selected)
	universe_section.add_child(universe_selector)
	
	# Physics laws
	var physics_section = _create_section("⚡ Physics Laws")
	laws_content.add_child(physics_section)
	
	_add_law_slider(physics_section, "Gravity", "gravity", 0.0, 20.0, 9.8)
	_add_law_slider(physics_section, "Time Scale", "time_scale", 0.1, 10.0, 1.0)
	_add_law_slider(physics_section, "Friction", "friction", 0.0, 2.0, 0.5)
	_add_law_slider(physics_section, "Energy Conservation", "energy_conservation", 0.0, 1.0, 1.0)
	
	# Consciousness laws
	var consciousness_section = _create_section("🧠 Consciousness Laws")
	laws_content.add_child(consciousness_section)
	
	_add_law_slider(consciousness_section, "Awareness Growth", "awareness_growth", 0.0, 5.0, 1.0)
	_add_law_slider(consciousness_section, "Connection Strength", "connection_strength", 0.0, 10.0, 3.0)
	_add_law_slider(consciousness_section, "Evolution Rate", "evolution_rate", 0.1, 5.0, 1.0)
	_add_law_slider(consciousness_section, "Creativity Factor", "creativity_factor", 0.0, 2.0, 1.0)
	
	# Reality laws
	var reality_section = _create_section("🌌 Reality Laws")
	laws_content.add_child(reality_section)
	
	_add_law_toggle(reality_section, "Allow Creation", "allow_creation", true)
	_add_law_toggle(reality_section, "Allow Destruction", "allow_destruction", true)
	_add_law_toggle(reality_section, "Allow Evolution", "allow_evolution", true)
	_add_law_toggle(reality_section, "Allow Time Travel", "allow_time_travel", false)
	_add_law_toggle(reality_section, "Allow Consciousness Merge", "allow_merge", true)
	
	_refresh_universe_list()

# ===== BEING PROPERTIES EDITOR =====

func _create_being_properties_editor() -> void:
	being_editor = ScrollContainer.new()
	being_editor.custom_minimum_size = Vector2(1140, 650)
	mode_tabs.add_child(being_editor)
	mode_tabs.set_tab_title(1, "🎭 Being Properties")
	
	var being_content = VBoxContainer.new()
	being_editor.add_child(being_content)
	
	# Being selector
	var being_section = _create_section("Select Being")
	being_content.add_child(being_section)
	
	var being_selector = OptionButton.new()
	being_selector.custom_minimum_size = Vector2(400, 40)
	being_selector.item_selected.connect(_on_being_selected)
	being_section.add_child(being_selector)
	
	# Live preview
	var preview_section = _create_section("🔮 Live Preview")
	being_content.add_child(preview_section)
	
	var preview_container = SubViewportContainer.new()
	preview_container.custom_minimum_size = Vector2(600, 400)
	preview_section.add_child(preview_container)
	
	# Property editors
	var props_section = _create_section("📊 Properties")
	being_content.add_child(props_section)
	
	# Identity properties
	_add_property_field(props_section, "Name", "being_name", "text")
	_add_property_field(props_section, "Type", "being_type", "text")
	_add_property_slider(props_section, "Consciousness Level", "consciousness_level", 0, 7, 1)
	_add_property_slider(props_section, "Visual Layer", "visual_layer", 0, 1000, 0)
	
	# Transform properties
	var transform_section = _create_section("🔄 Transform")
	being_content.add_child(transform_section)
	
	_add_vector3_editor(transform_section, "Position", "position")
	_add_vector3_editor(transform_section, "Rotation", "rotation_degrees")
	_add_vector3_editor(transform_section, "Scale", "scale")
	
	_refresh_being_list()

# ===== COMPONENT CREATOR =====

func _create_component_creator() -> void:
	component_creator = ScrollContainer.new()
	component_creator.custom_minimum_size = Vector2(1140, 650)
	mode_tabs.add_child(component_creator)
	mode_tabs.set_tab_title(2, "🔧 Component Creator")
	
	var creator_content = VBoxContainer.new()
	component_creator.add_child(creator_content)
	
	# Component metadata
	var metadata_section = _create_section("📋 Component Metadata")
	creator_content.add_child(metadata_section)
	
	_add_creator_field(metadata_section, "Component Name", "component_name")
	_add_creator_field(metadata_section, "Description", "component_description")
	_add_creator_field(metadata_section, "Version", "component_version", "1.0.0")
	_add_creator_field(metadata_section, "Author", "component_author", "Reality Editor")
	
	# Socket compatibility
	var socket_section = _create_section("🔌 Socket Compatibility")
	creator_content.add_child(socket_section)
	
	var socket_types = ["VISUAL", "SCRIPT", "SHADER", "ACTION", "MEMORY", "INTERFACE", "AUDIO", "PHYSICS"]
	for socket_type in socket_types:
		var check = CheckBox.new()
		check.text = socket_type
		check.set_meta("socket_type", socket_type)
		socket_section.add_child(check)
	
	# Code editor
	var code_section = _create_section("💻 Component Code")
	creator_content.add_child(code_section)
	
	var code_editor = CodeEdit.new()
	code_editor.custom_minimum_size = Vector2(1100, 300)
	code_editor.syntax_highlighter = GDScriptSyntaxHighlighter.new()
	code_editor.text = _get_component_template()
	code_section.add_child(code_editor)
	
	# Create button
	var create_button = Button.new()
	create_button.text = "✨ Birth Component Into Existence ✨"
	create_button.custom_minimum_size = Vector2(400, 50)
	create_button.pressed.connect(_on_create_component_pressed)
	creator_content.add_child(create_button)
# ===== LOGIC CONNECTOR =====

func _create_logic_connector() -> void:
	logic_canvas = GraphEdit.new()
	logic_canvas.custom_minimum_size = Vector2(1140, 650)
	logic_canvas.right_disconnects = true
	logic_canvas.scroll_offset = Vector2(570, 325)
	mode_tabs.add_child(logic_canvas)
	mode_tabs.set_tab_title(3, "🔗 Logic Connector")
	
	# Add toolbar
	var toolbar = HBoxContainer.new()
	toolbar.position = Vector2(10, 10)
	logic_canvas.add_child(toolbar)
	
	var add_node_button = Button.new()
	add_node_button.text = "➕ Add Logic Node"
	add_node_button.pressed.connect(_show_node_menu)
	toolbar.add_child(add_node_button)
	
	var clear_button = Button.new()
	clear_button.text = "🗑️ Clear Canvas"
	clear_button.pressed.connect(_clear_logic_canvas)
	toolbar.add_child(clear_button)
	
	var save_button = Button.new()
	save_button.text = "💾 Save Logic"
	save_button.pressed.connect(_save_logic_network)
	toolbar.add_child(save_button)

# ===== REALITY SCULPTOR =====

func _create_reality_sculptor() -> void:
	reality_sculptor = VBoxContainer.new()
	reality_sculptor.custom_minimum_size = Vector2(1140, 650)
	mode_tabs.add_child(reality_sculptor)
	mode_tabs.set_tab_title(4, "🎨 Reality Sculptor")
	
	var sculptor_label = Label.new()
	sculptor_label.text = "Free-form reality manipulation - Coming Soon..."
	sculptor_label.add_theme_font_size_override("font_size", 20)
	reality_sculptor.add_child(sculptor_label)
	
	var instructions = RichTextLabel.new()
	instructions.custom_minimum_size = Vector2(1000, 200)
	instructions.text = "[center]Here you will be able to:[/center]\n\n• Sculpt reality with gesture-based controls\n• Paint consciousness fields\n• Weave timeline threads\n• Merge and split universes visually\n• Create reality distortions and anomalies"
	reality_sculptor.add_child(instructions)

# ===== UI HELPER FUNCTIONS =====

func _create_section(title: String) -> VBoxContainer:
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	
	var header = Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	section.add_child(header)
	
	var separator = HSeparator.new()
	section.add_child(separator)
	
	return section

func _add_law_slider(parent: Control, label: String, law_name: String, min_val: float, max_val: float, default: float) -> void:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size = Vector2(200, 0)
	container.add_child(label_node)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.custom_minimum_size = Vector2(400, 0)
	slider.set_meta("law_name", law_name)
	slider.value_changed.connect(_on_law_slider_changed.bind(law_name))
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(default)
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.set_meta("value_label", true)
	slider.set_meta("value_label", value_label)
	container.add_child(value_label)

func _add_law_toggle(parent: Control, label: String, law_name: String, default: bool) -> void:
	var check = CheckBox.new()
	check.text = label
	check.button_pressed = default
	check.set_meta("law_name", law_name)
	check.toggled.connect(_on_law_toggle_changed.bind(law_name))
	parent.add_child(check)

func _add_property_field(parent: Control, label: String, prop_name: String, type: String) -> void:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size = Vector2(200, 0)
	container.add_child(label_node)
	
	var field = LineEdit.new()
	field.custom_minimum_size = Vector2(400, 0)
	field.set_meta("property_name", prop_name)
	field.text_changed.connect(_on_property_field_changed.bind(prop_name))
	container.add_child(field)

func _add_property_slider(parent: Control, label: String, prop_name: String, min_val: int, max_val: int, default: int) -> void:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size = Vector2(200, 0)
	container.add_child(label_node)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = 1
	slider.custom_minimum_size = Vector2(400, 0)
	slider.set_meta("property_name", prop_name)
	slider.value_changed.connect(_on_property_slider_changed.bind(prop_name))
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(default)
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.set_meta("value_label", true)
	slider.set_meta("value_label", value_label)
	container.add_child(value_label)
func _add_vector3_editor(parent: Control, label: String, prop_name: String) -> void:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size = Vector2(200, 0)
	container.add_child(label_node)
	
	for axis in ["x", "y", "z"]:
		var axis_label = Label.new()
		axis_label.text = axis.to_upper() + ":"
		container.add_child(axis_label)
		
		var field = SpinBox.new()
		field.custom_minimum_size = Vector2(100, 0)
		field.step = 0.01
		field.set_meta("property_name", prop_name)
		field.set_meta("axis", axis)
		field.value_changed.connect(_on_vector3_changed.bind(prop_name, axis))
		container.add_child(field)

func _add_creator_field(parent: Control, label: String, field_name: String, default: String = "") -> void:
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.custom_minimum_size = Vector2(200, 0)
	container.add_child(label_node)
	
	var field = LineEdit.new()
	field.custom_minimum_size = Vector2(600, 0)
	field.text = default
	field.set_meta("field_name", field_name)
	container.add_child(field)

func _create_status_bar() -> Control:
	var status_bar = PanelContainer.new()
	status_bar.custom_minimum_size = Vector2(0, 40)
	
	var status_content = HBoxContainer.new()
	status_bar.add_child(status_content)
	
	var status_label = Label.new()
	status_label.text = "🌟 Reality Editor Ready - Shape existence with intention..."
	status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	status_label.name = "StatusLabel"
	status_content.add_child(status_label)
	
	return status_bar

# ===== EVENT HANDLERS =====

func _on_universe_selected(index: int) -> void:
	var universe_list = get_tree().get_nodes_in_group("universes")
	if index < universe_list.size():
		current_universe = universe_list[index]
		_load_universe_laws()
		_update_status("Selected universe: " + current_universe.name)
		_log_genesis("Reality Editor gazes upon universe '" + current_universe.name + "'...")

func _on_being_selected(index: int) -> void:
	var being_list = get_tree().get_nodes_in_group("universal_beings")
	if index < being_list.size():
		selected_being = being_list[index]
		_load_being_properties()
		_update_status("Selected being: " + selected_being.being_name)
		_log_genesis("Reality Editor focuses on being '" + selected_being.being_name + "'...")

func _on_law_slider_changed(value: float, law_name: String) -> void:
	if current_universe and current_universe.has_method("set_rule"):
		current_universe.set_rule(law_name, value)
		_update_status("Changed " + law_name + " to " + str(value))
		_log_genesis("The law of " + law_name + " shifts to " + str(value) + "...")
		reality_changes[law_name] = value

func _on_law_toggle_changed(pressed: bool, law_name: String) -> void:
	if current_universe and current_universe.has_method("set_rule"):
		current_universe.set_rule(law_name, pressed)
		_update_status(law_name + " = " + str(pressed))
		_log_genesis("The rule of " + law_name + " becomes " + str(pressed) + "...")
		reality_changes[law_name] = pressed

func _on_property_field_changed(new_text: String, prop_name: String) -> void:
	if selected_being:
		selected_being.set(prop_name, new_text)
		_update_status("Changed " + prop_name + " to " + new_text)
		_log_genesis("Being property '" + prop_name + "' transforms to '" + new_text + "'...")

func _on_property_slider_changed(value: float, prop_name: String) -> void:
	if selected_being:
		selected_being.set(prop_name, int(value))
		_update_status("Changed " + prop_name + " to " + str(int(value)))
		_log_genesis("Being essence '" + prop_name + "' evolves to " + str(int(value)) + "...")

func _on_vector3_changed(value: float, prop_name: String, axis: String) -> void:
	if selected_being:
		var current_value = selected_being.get(prop_name)
		if current_value is Vector3:
			match axis:
				"x": current_value.x = value
				"y": current_value.y = value
				"z": current_value.z = value
			selected_being.set(prop_name, current_value)
			_update_status("Changed " + prop_name + "." + axis + " to " + str(value))

func _on_create_component_pressed() -> void:
	var metadata = _gather_component_metadata()
	var code = _get_code_editor_content()
	var sockets = _get_selected_sockets()
	
	if metadata.component_name.is_empty():
		_update_status("❌ Component needs a name!")
		return
	
	_create_new_component(metadata, code, sockets)
	_update_status("✨ Component '" + metadata.component_name + "' birthed into existence!")
	_log_genesis("A new component '" + metadata.component_name + "' manifests in the reality palette...")

func _on_window_close_requested() -> void:
	is_editing = false
	if editor_window:
		editor_window.queue_free()
		editor_window = null
	_log_genesis("Reality Editor returns to the void, changes preserved in the fabric of existence...")
# ===== HELPER METHODS =====

func _refresh_universe_list() -> void:
	var universe_selector = _find_node_by_path(law_editor, "OptionButton")
	if not universe_selector:
		return
	
	universe_selector.clear()
	var universes = get_tree().get_nodes_in_group("universes")
	for universe in universes:
		universe_selector.add_item(universe.name)

func _refresh_being_list() -> void:
	var being_selector = _find_node_by_path(being_editor, "OptionButton")
	if not being_selector:
		return
	
	being_selector.clear()
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		being_selector.add_item(being.being_name)

func _load_universe_laws() -> void:
	if not current_universe or not current_universe.has_method("get_rules"):
		return
	
	var rules = current_universe.get_rules()
	# Update UI with current universe laws
	# (Implementation depends on universe structure)

func _load_being_properties() -> void:
	if not selected_being:
		return
	
	# Update UI with current being properties
	# (Implementation depends on being structure)

func _update_status(message: String) -> void:
	var status_label = _find_node_by_name(main_container, "StatusLabel")
	if status_label:
		status_label.text = "🌟 " + message

func _log_genesis(message: String) -> void:
	genesis_log_buffer.append(message)
	if akashic_logger and akashic_logger.has_method("log_genesis_event"):
		akashic_logger.log_genesis_event("Reality Editor", message)
	print("📜 Genesis: " + message)

func _auto_save_changes() -> void:
	if reality_changes.is_empty():
		return
	
	# Save changes to Akashic Records
	if akashic_logger and akashic_logger.has_method("save_reality_state"):
		akashic_logger.save_reality_state({
			"timestamp": Time.get_ticks_msec(),
			"editor_mode": EditorMode.keys()[current_mode],
			"changes": reality_changes,
			"universe": current_universe.name if current_universe else "none",
			"being": selected_being.being_name if selected_being else "none"
		})
	
	reality_changes.clear()
	_update_status("✅ Reality changes auto-saved to Akashic Records")

func _setup_preview_viewport() -> void:
	preview_viewport = SubViewport.new()
	preview_viewport.size = Vector2i(600, 400)
	
	preview_camera = Camera3D.new()
	preview_camera.position = Vector3(0, 2, 5)
	preview_camera.look_at(Vector3.ZERO, Vector3.UP)
	preview_viewport.add_child(preview_camera)

func _update_reality_preview() -> void:
	# Update preview based on current edits
	pass

func _connect_to_universe_system() -> void:
	# Connect to universe management signals
	var universe_system = get_tree().get_first_node_in_group("universe_system")
	if universe_system:
		if universe_system.has_signal("universe_created"):
			universe_system.universe_created.connect(_on_universe_created)
		if universe_system.has_signal("universe_deleted"):
			universe_system.universe_deleted.connect(_on_universe_deleted)

func _on_universe_created(universe: Node) -> void:
	_refresh_universe_list()
	_log_genesis("A new universe '" + universe.name + "' blooms in the reality garden...")

func _on_universe_deleted(universe_name: String) -> void:
	_refresh_universe_list()
	_log_genesis("Universe '" + universe_name + "' returns to the void...")

func _get_component_template() -> String:
	return """extends "res://core/Component.gd"

# ==================================================
# UNIVERSAL BEING COMPONENT: [Your Component Name]
# TYPE: Component
# PURPOSE: [Describe what this component does]
# ==================================================

func component_init() -> void:
	component_type = "custom"
	component_name = "My Component"
	tags = ["custom", "ai_compatible"]
	
	log_component_action("init", "Component awakens...")

func component_ready() -> void:
	# Initialize your component here
	pass

func component_process(delta: float) -> void:
	# Update logic here
	pass

func component_exit() -> void:
	# Cleanup here
	pass
"""

func _gather_component_metadata() -> Dictionary:
	var metadata = {}
	for child in component_creator.get_children():
		if child.has_meta("field_name"):
			metadata[child.get_meta("field_name")] = child.text
	return metadata

func _get_code_editor_content() -> String:
	var code_editor = _find_node_by_type(component_creator, "CodeEdit")
	return code_editor.text if code_editor else ""

func _get_selected_sockets() -> Array[String]:
	var selected = []
	for child in component_creator.get_children():
		if child is CheckBox and child.button_pressed and child.has_meta("socket_type"):
			selected.append(child.get_meta("socket_type"))
	return selected

func _create_new_component(metadata: Dictionary, code: String, sockets: Array[String]) -> void:
	# Create component directory
	var component_dir = "res://components/" + metadata.component_name.to_snake_case() + ".ub.zip/"
	DirAccess.make_dir_recursive_absolute(component_dir)
	
	# Save manifest
	var manifest = {
		"component_name": metadata.component_name,
		"component_type": "custom",
		"version": metadata.get("component_version", "1.0.0"),
		"author": metadata.get("component_author", "Reality Editor"),
		"description": metadata.get("component_description", ""),
		"main_script": metadata.component_name.to_pascal_case() + "Component.gd",
		"compatible_sockets": sockets
	}
	
	var manifest_file = FileAccess.open(component_dir + "manifest.json", FileAccess.WRITE)
	if manifest_file:
		manifest_file.store_string(JSON.stringify(manifest, "\t"))
		manifest_file.close()
	
	# Save component code
	var code_file = FileAccess.open(component_dir + manifest.main_script, FileAccess.WRITE)
	if code_file:
		code_file.store_string(code)
		code_file.close()

func _find_node_by_path(parent: Node, node_class: String) -> Node:
	for child in parent.get_children():
		if child.get_class() == node_class:
			return child
		var found = _find_node_by_path(child, node_class)
		if found:
			return found
	return null

func _find_node_by_name(parent: Node, node_name: String) -> Node:
	if parent.name == node_name:
		return parent
	for child in parent.get_children():
		var found = _find_node_by_name(child, node_name)
		if found:
			return found
	return null

func _find_node_by_type(parent: Node, type_name: String) -> Node:
	for child in parent.get_children():
		if child.get_class() == type_name:
			return child
		var found = _find_node_by_type(child, type_name)
		if found:
			return found
	return null
# ===== LOGIC CONNECTOR METHODS =====

func _show_node_menu() -> void:
	var menu = PopupMenu.new()
	menu.add_item("Trigger Node", 0)
	menu.add_item("Condition Node", 1)
	menu.add_item("Action Node", 2)
	menu.add_item("Variable Node", 3)
	menu.add_item("AI Interface Node", 4)
	menu.id_pressed.connect(_on_node_type_selected)
	menu.popup_centered(Vector2(200, 150))
	logic_canvas.add_child(menu)

func _on_node_type_selected(id: int) -> void:
	var node_types = ["Trigger", "Condition", "Action", "Variable", "AI Interface"]
	_create_logic_node(node_types[id])

func _create_logic_node(type: String) -> void:
	var node = GraphNode.new()
	node.title = type + " Node"
	node.position_offset = Vector2(100 + randf() * 400, 100 + randf() * 300)
	
	match type:
		"Trigger":
			node.add_theme_color_override("title_color", Color(1.0, 0.5, 0.5))
			var label = Label.new()
			label.text = "On Event:"
			node.add_child(label)
			var event_select = OptionButton.new()
			event_select.add_item("Being Created")
			event_select.add_item("Universe Changed")
			event_select.add_item("Consciousness Level Up")
			node.add_child(event_select)
			node.set_slot(0, false, 0, Color.WHITE, true, 0, Color.GREEN)
			
		"Condition":
			node.add_theme_color_override("title_color", Color(0.5, 0.5, 1.0))
			var label = Label.new()
			label.text = "If:"
			node.add_child(label)
			var condition_field = LineEdit.new()
			condition_field.placeholder_text = "consciousness_level > 5"
			node.add_child(condition_field)
			node.set_slot(0, true, 0, Color.GREEN, true, 0, Color.YELLOW)
			
		"Action":
			node.add_theme_color_override("title_color", Color(0.5, 1.0, 0.5))
			var label = Label.new()
			label.text = "Do:"
			node.add_child(label)
			var action_select = OptionButton.new()
			action_select.add_item("Create Being")
			action_select.add_item("Modify Property")
			action_select.add_item("Send Message")
			node.add_child(action_select)
			node.set_slot(0, true, 0, Color.YELLOW, false, 0, Color.WHITE)
			
		"Variable":
			node.add_theme_color_override("title_color", Color(1.0, 1.0, 0.5))
			var label = Label.new()
			label.text = "Variable:"
			node.add_child(label)
			var var_name = LineEdit.new()
			var_name.placeholder_text = "variable_name"
			node.add_child(var_name)
			var var_value = SpinBox.new()
			node.add_child(var_value)
			node.set_slot(0, false, 0, Color.WHITE, true, 1, Color.CYAN)
			
		"AI Interface":
			node.add_theme_color_override("title_color", Color(1.0, 0.5, 1.0))
			var label = Label.new()
			label.text = "AI Query:"
			node.add_child(label)
			var query_field = TextEdit.new()
			query_field.custom_minimum_size = Vector2(200, 60)
			query_field.placeholder_text = "Ask AI..."
			node.add_child(query_field)
			node.set_slot(0, true, 0, Color.GREEN, true, 2, Color.MAGENTA)
	
	logic_canvas.add_child(node)
	_log_genesis("Logic node '" + type + "' materializes in the connection field...")

func _clear_logic_canvas() -> void:
	for child in logic_canvas.get_children():
		if child is GraphNode:
			child.queue_free()
	_log_genesis("Logic canvas returns to pristine emptiness...")

func _save_logic_network() -> void:
	var network_data = {
		"nodes": [],
		"connections": []
	}
	
	# Save nodes
	for child in logic_canvas.get_children():
		if child is GraphNode:
			network_data.nodes.append({
				"title": child.title,
				"position": child.position_offset,
				"data": _extract_node_data(child)
			})
	
	# Save connections
	var connections = logic_canvas.get_connection_list()
	network_data.connections = connections
	
	# Save to Akashic Records
	if akashic_logger and akashic_logger.has_method("save_logic_network"):
		akashic_logger.save_logic_network(network_data)
	
	_update_status("Logic network saved to Akashic Records")
	_log_genesis("Logic network crystallizes into the eternal memory...")

func _extract_node_data(node: GraphNode) -> Dictionary:
	var data = {}
	for child in node.get_children():
		if child is LineEdit:
			data["text_input"] = child.text
		elif child is OptionButton:
			data["selected_option"] = child.selected
		elif child is SpinBox:
			data["numeric_value"] = child.value
		elif child is TextEdit:
			data["text_area"] = child.text
	return data

# ===== PUBLIC INTERFACE =====

func open_reality_editor() -> void:
	if not editor_window:
		_create_editor_window()
	
	is_editing = true
	editor_window.show()
	attached_being.get_tree().root.add_child(editor_window)
	
	_log_genesis("Reality Editor opens its infinite canvas...")
	
	# Emit signal
	emit_signal("editor_opened")

func edit_universe_laws(universe: Node) -> void:
	current_universe = universe
	mode_tabs.current_tab = 0  # Switch to Universe Laws tab
	_load_universe_laws()
	_log_genesis("Reality Editor focuses on the laws of universe '" + universe.name + "'...")

func create_component_from_template(template: Dictionary) -> void:
	# Pre-fill component creator with template data
	mode_tabs.current_tab = 2  # Switch to Component Creator
	# Fill fields with template data
	_log_genesis("Component template loaded into the creation matrix...")

func modify_being_live(being: UniversalBeing) -> void:
	selected_being = being
	mode_tabs.current_tab = 1  # Switch to Being Properties
	_load_being_properties()
	_log_genesis("Reality Editor embraces being '" + being.being_name + "' for transformation...")

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
	return {
		"actions": {
			"open_editor": "Open the Reality Editor interface",
			"edit_universe": "Edit universe laws and properties",
			"edit_being": "Modify being properties in real-time",
			"create_component": "Create new component from within the game",
			"save_logic": "Save logic network to Akashic Records"
		},
		"properties": {
			"current_mode": EditorMode.keys()[current_mode],
			"is_editing": is_editing,
			"current_universe": current_universe.name if current_universe else "none",
			"selected_being": selected_being.being_name if selected_being else "none",
			"pending_changes": reality_changes.size()
		}
	}

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"open_editor":
			open_reality_editor()
			return "Reality Editor opened"
		"edit_universe":
			if args.size() > 0:
				edit_universe_laws(args[0])
				return "Editing universe: " + args[0].name
			return "No universe specified"
		"edit_being":
			if args.size() > 0:
				modify_being_live(args[0])
				return "Editing being: " + args[0].being_name
			return "No being specified"
		"save_changes":
			_auto_save_changes()
			return "Changes saved to Akashic Records"
		_:
			return "Unknown method: " + method_name

# ===== SIGNALS =====

signal editor_opened()
signal reality_modified(changes: Dictionary)
signal law_changed(law_name: String, new_value: Variant)
signal being_edited(being: UniversalBeing, property: String, value: Variant)
signal component_created(component_path: String)
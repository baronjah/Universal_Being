extends CanvasLayer
class_name PerfectUniversalBeingInspector

## 🔍 UNIVERSAL BEING INSPECTOR - Point 9: ✅ Everything debuggable/changeable

signal being_inspected(being: UniversalBeing)
signal property_changed(being: UniversalBeing, property: String, old_value, new_value)
signal inspection_mode_changed(active: bool)

@export var inspector_visible: bool = false

# Inspector UI elements
var inspector_panel: Panel
var being_info_display: RichTextLabel
var property_editor: VBoxContainer
var current_being: UniversalBeing

# Inspector data
var inspected_properties: Dictionary = {}
var property_editors: Dictionary = {}

func _ready() -> void:
	name = "UniversalBeingInspector"
	add_to_group("universal_being_inspector")
	
	setup_inspector_ui()
	print("🔍 Universal Being Inspector: Ready to debug and modify everything!")

func setup_inspector_ui() -> void:
	"""Create the inspector interface"""
	# Main inspector panel
	inspector_panel = Panel.new()
	inspector_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	inspector_panel.size = Vector2(400, 600)
	inspector_panel.position = Vector2(-420, 20)
	inspector_panel.visible = false
	
	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.12, 0.2, 0.95)
	panel_style.border_color = Color(1.0, 0.8, 0.2, 1.0)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	inspector_panel.add_theme_stylebox_override("panel", panel_style)
	
	add_child(inspector_panel)
	
	# Inspector title
	var title_label = Label.new()
	title_label.text = "🔍 UNIVERSAL BEING INSPECTOR"
	title_label.position = Vector2(10, 10)
	title_label.add_theme_color_override("font_color", Color.GOLD)
	inspector_panel.add_child(title_label)
	
	# Being info display
	being_info_display = RichTextLabel.new()
	being_info_display.position = Vector2(10, 40)
	being_info_display.size = Vector2(380, 200)
	being_info_display.bbcode_enabled = true
	being_info_display.add_theme_color_override("default_color", Color.WHITE)
	inspector_panel.add_child(being_info_display)
	
	# Property editor container
	var scroll_container = ScrollContainer.new()
	scroll_container.position = Vector2(10, 250)
	scroll_container.size = Vector2(380, 320)
	inspector_panel.add_child(scroll_container)
	
	property_editor = VBoxContainer.new()
	property_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(property_editor)
	
	# Inspector controls
	var controls_container = HBoxContainer.new()
	controls_container.position = Vector2(10, 580)
	controls_container.size = Vector2(380, 20)
	inspector_panel.add_child(controls_container)
	
	var refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(_refresh_inspector)
	controls_container.add_child(refresh_button)
	
	var debug_button = Button.new()
	debug_button.text = "Debug"
	debug_button.pressed.connect(_debug_being)
	controls_container.add_child(debug_button)
	
	var modify_button = Button.new()
	modify_button.text = "Save Changes"
	modify_button.pressed.connect(_save_modifications)
	controls_container.add_child(modify_button)

func toggle() -> void:
	"""Toggle inspector visibility"""
	inspector_visible = !inspector_visible
	inspector_panel.visible = inspector_visible
	
	inspection_mode_changed.emit(inspector_visible)
	print("🔍 Inspector visibility: %s" % ("ON" if inspector_visible else "OFF"))

func inspect_being(being: UniversalBeing) -> void:
	"""Inspect a specific Universal Being"""
	if not being:
		return
	
	current_being = being
	inspector_visible = true
	inspector_panel.visible = true
	
	display_being_info()
	create_property_editors()
	
	being_inspected.emit(being)
	print("🔍 Inspecting Universal Being: %s" % being.being_name)

func display_being_info() -> void:
	"""Display comprehensive being information"""
	if not current_being:
		being_info_display.text = "[color=red]No being selected for inspection[/color]"
		return
	
	var info_text = ""
	info_text += "[color=gold]🌟 UNIVERSAL BEING ANALYSIS[/color]\n\n"
	info_text += "[color=cyan]Name:[/color] %s\n" % current_being.being_name
	info_text += "[color=cyan]Type:[/color] %s\n" % current_being.get_script().get_global_name()
	info_text += "[color=cyan]Consciousness Level:[/color] %d\n" % current_being.consciousness_level
	
	# Pentagon Architecture Status
	info_text += "\n[color=yellow]📐 PENTAGON ARCHITECTURE:[/color]\n"
	info_text += "• pentagon_init(): %s\n" % ("✅" if current_being.has_method("pentagon_init") else "❌")
	info_text += "• pentagon_ready(): %s\n" % ("✅" if current_being.has_method("pentagon_ready") else "❌")
	info_text += "• pentagon_process(): %s\n" % ("✅" if current_being.has_method("pentagon_process") else "❌")
	info_text += "• pentagon_input(): %s\n" % ("✅" if current_being.has_method("pentagon_input") else "❌")
	info_text += "• pentagon_sewers(): %s\n" % ("✅" if current_being.has_method("pentagon_sewers") else "❌")
	
	# Position and Transform
	info_text += "\n[color=green]📍 TRANSFORM DATA:[/color]\n"
	info_text += "• Position: (%.1f, %.1f, %.1f)\n" % [
		current_being.global_position.x,
		current_being.global_position.y,
		current_being.global_position.z
	]
	info_text += "• Rotation: (%.1f, %.1f, %.1f)\n" % [
		rad_to_deg(current_being.rotation.x),
		rad_to_deg(current_being.rotation.y),
		rad_to_deg(current_being.rotation.z)
	]
	
	# Children and Connections
	info_text += "\n[color=magenta]🔗 CONNECTIONS:[/color]\n"
	info_text += "• Children: %d\n" % current_being.get_child_count()
	info_text += "• Groups: %s\n" % str(current_being.get_groups())
	
	# Metadata
	var meta_list = current_being.get_meta_list()
	if meta_list.size() > 0:
		info_text += "\n[color=orange]📋 METADATA:[/color]\n"
		for meta_key in meta_list:
			info_text += "• %s: %s\n" % [meta_key, str(current_being.get_meta(meta_key))]
	
	being_info_display.text = info_text

func create_property_editors() -> void:
	"""Create editors for modifiable properties"""
	# Clear existing editors
	for child in property_editor.get_children():
		child.queue_free()
	
	property_editors.clear()
	
	if not current_being:
		return
	
	# Create sections for different property types
	create_consciousness_editors()
	create_transform_editors()
	create_pentagon_editors()
	create_metadata_editors()

func create_consciousness_editors() -> void:
	"""Create editors for consciousness properties"""
	var section_label = Label.new()
	section_label.text = "🧠 CONSCIOUSNESS PROPERTIES"
	section_label.add_theme_color_override("font_color", Color.CYAN)
	property_editor.add_child(section_label)
	
	# Consciousness Level Editor
	var consciousness_container = HBoxContainer.new()
	property_editor.add_child(consciousness_container)
	
	var consciousness_label = Label.new()
	consciousness_label.text = "Consciousness Level:"
	consciousness_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consciousness_container.add_child(consciousness_label)
	
	var consciousness_spinbox = SpinBox.new()
	consciousness_spinbox.min_value = 0
	consciousness_spinbox.max_value = 10
	consciousness_spinbox.value = current_being.consciousness_level
	consciousness_spinbox.value_changed.connect(_on_consciousness_changed)
	consciousness_container.add_child(consciousness_spinbox)
	
	property_editors["consciousness_level"] = consciousness_spinbox
	
	# Being Name Editor
	var name_container = HBoxContainer.new()
	property_editor.add_child(name_container)
	
	var name_label = Label.new()
	name_label.text = "Being Name:"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_container.add_child(name_label)
	
	var name_lineedit = LineEdit.new()
	name_lineedit.text = current_being.being_name
	name_lineedit.text_changed.connect(_on_name_changed)
	name_container.add_child(name_lineedit)
	
	property_editors["being_name"] = name_lineedit

func create_transform_editors() -> void:
	"""Create editors for transform properties"""
	var section_label = Label.new()
	section_label.text = "📍 TRANSFORM PROPERTIES"
	section_label.add_theme_color_override("font_color", Color.GREEN)
	property_editor.add_child(section_label)
	
	# Position editors
	create_vector3_editor("Position", current_being.global_position, _on_position_changed)
	
	# Rotation editors (in degrees)
	var rotation_degrees = Vector3(
		rad_to_deg(current_being.rotation.x),
		rad_to_deg(current_being.rotation.y),
		rad_to_deg(current_being.rotation.z)
	)
	create_vector3_editor("Rotation", rotation_degrees, _on_rotation_changed)

func create_vector3_editor(property_name: String, value: Vector3, callback: Callable) -> void:
	"""Create a Vector3 property editor"""
	var container = VBoxContainer.new()
	property_editor.add_child(container)
	
	var label = Label.new()
	label.text = property_name + ":"
	container.add_child(label)
	
	var vector_container = HBoxContainer.new()
	container.add_child(vector_container)
	
	# X, Y, Z spinboxes
	for i in range(3):
		var axis_label = Label.new()
		axis_label.text = ["X:", "Y:", "Z:"][i]
		vector_container.add_child(axis_label)
		
		var spinbox = SpinBox.new()
		spinbox.min_value = -1000.0
		spinbox.max_value = 1000.0
		spinbox.step = 0.1
		spinbox.value = [value.x, value.y, value.z][i]
		spinbox.value_changed.connect(callback)
		vector_container.add_child(spinbox)
		
		property_editors[property_name.to_lower() + "_" + ["x", "y", "z"][i]] = spinbox

func create_pentagon_editors() -> void:
	"""Create editors for pentagon architecture"""
	var section_label = Label.new()
	section_label.text = "📐 PENTAGON ARCHITECTURE"
	section_label.add_theme_color_override("font_color", Color.YELLOW)
	property_editor.add_child(section_label)
	
	# Pentagon method status
	var pentagon_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
	
	for method in pentagon_methods:
		var method_container = HBoxContainer.new()
		property_editor.add_child(method_container)
		
		var method_label = Label.new()
		method_label.text = method + ":"
		method_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		method_container.add_child(method_label)
		
		var status_label = Label.new()
		if current_being.has_method(method):
			status_label.text = "✅ IMPLEMENTED"
			status_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			status_label.text = "❌ MISSING"
			status_label.add_theme_color_override("font_color", Color.RED)
		
		method_container.add_child(status_label)

func create_metadata_editors() -> void:
	"""Create editors for metadata"""
	var section_label = Label.new()
	section_label.text = "📋 METADATA"
	section_label.add_theme_color_override("font_color", Color.ORANGE)
	property_editor.add_child(section_label)
	
	var meta_list = current_being.get_meta_list()
	for meta_key in meta_list:
		var meta_container = HBoxContainer.new()
		property_editor.add_child(meta_container)
		
		var meta_label = Label.new()
		meta_label.text = str(meta_key) + ":"
		meta_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		meta_container.add_child(meta_label)
		
		var meta_value = current_being.get_meta(meta_key)
		var meta_lineedit = LineEdit.new()
		meta_lineedit.text = str(meta_value)
		meta_lineedit.text_changed.connect(func(new_text): _on_metadata_changed(meta_key, new_text))
		meta_container.add_child(meta_lineedit)
		
		property_editors["meta_" + str(meta_key)] = meta_lineedit

# Property change callbacks
func _on_consciousness_changed(new_value: float) -> void:
	if current_being:
		var old_value = current_being.consciousness_level
		current_being.consciousness_level = int(new_value)
		property_changed.emit(current_being, "consciousness_level", old_value, new_value)
		print("🔍 Consciousness level changed: %d → %d" % [old_value, new_value])

func _on_name_changed(new_name: String) -> void:
	if current_being:
		var old_name = current_being.being_name
		current_being.being_name = new_name
		property_changed.emit(current_being, "being_name", old_name, new_name)
		print("🔍 Being name changed: %s → %s" % [old_name, new_name])

func _on_position_changed(_value: float) -> void:
	if current_being:
		var new_position = Vector3(
			property_editors["position_x"].value,
			property_editors["position_y"].value,
			property_editors["position_z"].value
		)
		var old_position = current_being.global_position
		current_being.global_position = new_position
		property_changed.emit(current_being, "position", old_position, new_position)

func _on_rotation_changed(_value: float) -> void:
	if current_being:
		var new_rotation = Vector3(
			deg_to_rad(property_editors["rotation_x"].value),
			deg_to_rad(property_editors["rotation_y"].value),
			deg_to_rad(property_editors["rotation_z"].value)
		)
		var old_rotation = current_being.rotation
		current_being.rotation = new_rotation
		property_changed.emit(current_being, "rotation", old_rotation, new_rotation)

func _on_metadata_changed(meta_key: String, new_value: String) -> void:
	if current_being:
		var old_value = current_being.get_meta(meta_key)
		current_being.set_meta(meta_key, new_value)
		property_changed.emit(current_being, "meta_" + meta_key, old_value, new_value)
		print("🔍 Metadata changed: %s = %s" % [meta_key, new_value])

# Control functions
func _refresh_inspector() -> void:
	"""Refresh the inspector display"""
	if current_being:
		inspect_being(current_being)
		print("🔍 Inspector refreshed")

func _debug_being() -> void:
	"""Debug the current being"""
	if current_being:
		print("🔍 DEBUGGING UNIVERSAL BEING: %s" % current_being.being_name)
		print("🔍 Script: %s" % current_being.get_script().resource_path)
		print("🔍 Node path: %s" % current_being.get_path())
		print("🔍 Global position: %s" % current_being.global_position)
		print("🔍 Groups: %s" % current_being.get_groups())
		
		# Call debug method if available
		if current_being.has_method("debug_info"):
			current_being.debug_info()

func _save_modifications() -> void:
	"""Save all modifications made in the inspector"""
	if current_being:
		print("🔍 Saving modifications to: %s" % current_being.being_name)
		
		# Trigger any update methods
		if current_being.has_method("on_inspector_update"):
			current_being.on_inspector_update()
		
		# Refresh display
		display_being_info()

# Input handling for inspector toggle
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			toggle()
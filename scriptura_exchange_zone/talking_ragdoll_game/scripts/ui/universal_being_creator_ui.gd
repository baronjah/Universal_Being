################################################################
# UNIVERSAL BEING CREATOR UI - VISUAL INTERFACE SYSTEM
# Drag-drop interface for creating Universal Beings easily
# Created: May 31st, 2025 | Interface Revolution
# Location: scripts/ui/universal_being_creator_ui.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES - UI ELEMENTS
################################################################

# Interface panels
var creator_panel: Panel
var asset_browser: ItemList
var property_editor: VBoxContainer
var preview_area: SubViewport
var creation_toolbar: HBoxContainer

# Being creation
var selected_being_type: String = "magical_orb"
var creation_position: Vector3 = Vector3.ZERO
var being_properties: Dictionary = {}
var preview_being: Node3D = null

# Asset categories
var being_categories: Dictionary = {
	"Basic": ["magical_orb", "cube", "cylinder"],
	"Nature": ["tree", "flower", "rock", "crystal"],
	"Creatures": ["bird", "butterfly", "fish"],
	"Structures": ["house", "tower", "bridge"],
	"AI Entities": ["ai_companion", "seedling_ai", "helper_bot"],
	"Interface": ["button_3d", "slider_3d", "menu_3d"]
}

# UI state
var interface_visible: bool = false
var drag_mode: bool = false
var creation_mode: String = "click"  # "click", "drag", "gesture"

# Drag functionality
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var drag_start_pos: Vector2 = Vector2.ZERO

################################################################
# SIGNALS
################################################################

signal being_created(being_type: String, position: Vector3, properties: Dictionary)
signal interface_toggled(visible: bool)
signal category_selected(category: String)
signal being_type_selected(type: String)

################################################################
# PENTAGON ARCHITECTURE COMPLIANCE
################################################################

func _init() -> void:
	pentagon_init()

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func sewers() -> void:
	pentagon_sewers()

# Pentagon function implementations
func pentagon_init() -> void:
	# Pentagon initialization for UI
	pass

func pentagon_ready() -> void:
	# Pentagon setup for UI
	pass

func pentagon_process(delta: float) -> void:
	# Pentagon processing for UI
	pass

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling for UI
	# Handle dragging
	if is_dragging and event is InputEventMouseMotion:
		var new_position = get_viewport().get_mouse_position() - drag_offset
		creator_panel.position = new_position
		return
	
	# Stop dragging on mouse release
	if is_dragging and event is InputEventMouseButton and not event.pressed:
		is_dragging = false
		print("🖱️ DRAG: Stopped dragging interface")
		return
	
	# Toggle interface with 'B' key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_B:
			toggle_interface()
		elif event.keycode == KEY_ESCAPE and interface_visible:
			_close_interface()

func pentagon_sewers() -> void:
	# Pentagon cleanup for UI
	pass

################################################################
# INITIALIZATION
################################################################

func _ready():
	pentagon_ready()
	print("🎨 UNIVERSAL BEING CREATOR UI: Initializing visual interface...")
	
	# Register with Perfect Pentagon system instead of direct initialization
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_method("register_ready"):
			perfect_ready.register_ready("UniversalBeingCreatorUI", _perfect_pentagon_init, [])
	else:
		# Fallback direct initialization
		_direct_initialization()

func _perfect_pentagon_init():
	"""Initialize through Perfect Pentagon system"""
	print("🎯 BEING CREATOR UI: Perfect Pentagon initialization...")
	_direct_initialization()

func _direct_initialization():
	"""Direct initialization (fallback or for testing)"""
	# Set up UI layout
	_create_interface_layout()
	
	# Set up input handling
	_setup_input_handling()
	
	# Connect to Universal Object Manager
	_connect_to_systems()
	
	# Start hidden
	visible = false
	
	print("✅ BEING CREATOR UI: Visual interface ready - Press 'B' to open")

################################################################
# UI LAYOUT CREATION
################################################################

func _create_interface_layout():
	"""Create the complete UI layout for Universal Being creation"""
	
	# Main container
	# TODO: Fix - This requires Control base class
	# set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Background panel
	creator_panel = Panel.new()
	creator_panel.size = Vector2(800, 600)
	
	# Position it fully visible on screen
	var viewport_size = get_viewport().size
	var center_x = (viewport_size.x - creator_panel.size.x) / 2
	var center_y = (viewport_size.y - creator_panel.size.y) / 2
	creator_panel.position = Vector2(center_x, center_y)
	
	# REMOVED MODULATE - this was causing the dark overlay!
	add_child(creator_panel)
	
	# Add a background color to the panel with HIGH CONTRAST
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.02, 0.02, 0.05, 1.0)  # Almost black background
	style_box.border_width_left = 4
	style_box.border_width_right = 4
	style_box.border_width_top = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(0.0, 1.0, 0.5, 1.0)  # Bright lime-green border
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	creator_panel.add_theme_stylebox_override("panel", style_box)
	
	# Title with HIGH CONTRAST
	var title = Label.new()
	title.text = "🌟 Universal Being Creator [DRAG ME]"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Bright gold/orange
	
	# Add title background for extra contrast (THIS IS THE DRAG AREA)
	var title_bg = ColorRect.new()
	title_bg.color = Color(0.1, 0.0, 0.2, 0.8)  # Dark purple background for title
	title_bg.position = Vector2(15, 5)
	title_bg.size = Vector2(770, 50)
	title_bg.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events
	FloodgateController.universal_add_child(title_bg, creator_panel)
	
	# Connect drag events to title background
	title_bg.gui_input.connect(_on_title_input)
	
	title.position = Vector2(20, 10)
	title.size = Vector2(760, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let events pass through to title_bg
	FloodgateController.universal_add_child(title, creator_panel)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "✕"
	close_button.position = Vector2(750, 10)
	close_button.size = Vector2(30, 30)
	close_button.pressed.connect(_close_interface)
	FloodgateController.universal_add_child(close_button, creator_panel)
	
	# Create main layout
	_create_asset_browser()
	_create_property_editor()
	_create_preview_area()
	_create_creation_toolbar()

func _create_asset_browser():
	"""Create asset browser for selecting being types"""
	
	# Asset browser label with SECTION BACKGROUND
	var browser_bg = ColorRect.new()
	browser_bg.color = Color(0.2, 0.1, 0.0, 0.9)  # Dark orange background
	browser_bg.position = Vector2(15, 55)
	browser_bg.size = Vector2(260, 340)
	FloodgateController.universal_add_child(browser_bg, creator_panel)
	
	var browser_label = Label.new()
	browser_label.text = "🎯 Select Being Type:"
	browser_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0, 1.0))  # Bright yellow
	browser_label.add_theme_font_size_override("font_size", 20)
	browser_label.position = Vector2(20, 60)
	browser_label.size = Vector2(200, 20)
	FloodgateController.universal_add_child(browser_label, creator_panel)
	
	# Category tabs
	var category_tabs = TabContainer.new()
	category_tabs.position = Vector2(20, 90)
	category_tabs.size = Vector2(250, 300)
	FloodgateController.universal_add_child(category_tabs, creator_panel)
	
	# Create category lists
	for category in being_categories:
		var item_list = ItemList.new()
		item_list.name = category
		
		for being_type in being_categories[category]:
			var display_name = being_type.replace("_", " ").capitalize()
			item_list.add_item("🌟 " + display_name)
			item_list.set_item_metadata(item_list.get_item_count() - 1, being_type)
		
		item_list.item_selected.connect(_on_being_type_selected)
		FloodgateController.universal_add_child(item_list, category_tabs)
	
	asset_browser = category_tabs.get_child(0) as ItemList

func _create_property_editor():
	"""Create property editor for customizing beings"""
	
	# Property editor label with SECTION BACKGROUND
	var properties_bg = ColorRect.new()
	properties_bg.color = Color(0.0, 0.15, 0.05, 0.9)  # Dark green background
	properties_bg.position = Vector2(285, 55)
	properties_bg.size = Vector2(230, 340)
	FloodgateController.universal_add_child(properties_bg, creator_panel)
	
	var editor_label = Label.new()
	editor_label.text = "🔧 Properties:"
	editor_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5, 1.0))  # Bright lime green
	editor_label.add_theme_font_size_override("font_size", 20)
	editor_label.position = Vector2(290, 60)
	editor_label.size = Vector2(200, 20)
	FloodgateController.universal_add_child(editor_label, creator_panel)
	
	# Property scroll container
	var property_scroll = ScrollContainer.new()
	property_scroll.position = Vector2(290, 90)
	property_scroll.size = Vector2(220, 300)
	FloodgateController.universal_add_child(property_scroll, creator_panel)
	
	# Property container
	property_editor = VBoxContainer.new()
	FloodgateController.universal_add_child(property_editor, property_scroll)
	
	# Add default property controls
	_add_property_controls()

func _add_property_controls():
	"""Add property control widgets"""
	
	# Name input
	var name_container = HBoxContainer.new()
	var name_label = Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size.x = 80
	var name_input = LineEdit.new()
	name_input.text = "MyBeing"
	name_input.custom_minimum_size.x = 120
	name_input.text_changed.connect(_on_property_changed.bind("name"))
	FloodgateController.universal_add_child(name_label, name_container)
	FloodgateController.universal_add_child(name_input, name_container)
	FloodgateController.universal_add_child(name_container, property_editor)
	
	# Size slider
	var size_container = HBoxContainer.new()
	var size_label = Label.new()
	size_label.text = "Size:"
	size_label.custom_minimum_size.x = 80
	var size_slider = HSlider.new()
	size_slider.min_value = 0.1
	size_slider.max_value = 5.0
	size_slider.value = 1.0
	size_slider.custom_minimum_size.x = 120
	size_slider.value_changed.connect(_on_property_changed.bind("size"))
	FloodgateController.universal_add_child(size_label, size_container)
	FloodgateController.universal_add_child(size_slider, size_container)
	FloodgateController.universal_add_child(size_container, property_editor)
	
	# Color picker
	var color_container = HBoxContainer.new()
	var color_label = Label.new()
	color_label.text = "Color:"
	color_label.custom_minimum_size.x = 80
	var color_picker = ColorPickerButton.new()
	color_picker.color = Color.WHITE
	color_picker.custom_minimum_size.x = 120
	color_picker.color_changed.connect(_on_property_changed.bind("color"))
	FloodgateController.universal_add_child(color_label, color_container)
	FloodgateController.universal_add_child(color_picker, color_container)
	FloodgateController.universal_add_child(color_container, property_editor)
	
	# Consciousness level (for AI beings)
	var consciousness_container = HBoxContainer.new()
	var consciousness_label = Label.new()
	consciousness_label.text = "AI Level:"
	consciousness_label.custom_minimum_size.x = 80
	var consciousness_spin = SpinBox.new()
	consciousness_spin.min_value = 1
	consciousness_spin.max_value = 5
	consciousness_spin.value = 3
	consciousness_spin.custom_minimum_size.x = 120
	consciousness_spin.value_changed.connect(_on_property_changed.bind("consciousness_level"))
	FloodgateController.universal_add_child(consciousness_label, consciousness_container)
	FloodgateController.universal_add_child(consciousness_spin, consciousness_container)
	FloodgateController.universal_add_child(consciousness_container, property_editor)

func _create_preview_area():
	"""Create 3D preview area for beings"""
	
	# Preview label with SECTION BACKGROUND
	var preview_bg = ColorRect.new()
	preview_bg.color = Color(0.15, 0.0, 0.15, 0.9)  # Dark magenta background
	preview_bg.position = Vector2(525, 55)
	preview_bg.size = Vector2(250, 340)
	FloodgateController.universal_add_child(preview_bg, creator_panel)
	
	var preview_label = Label.new()
	preview_label.text = "👁️ Preview:"
	preview_label.add_theme_color_override("font_color", Color(1.0, 0.2, 1.0, 1.0))  # Bright magenta
	preview_label.add_theme_font_size_override("font_size", 20)
	preview_label.position = Vector2(530, 60)
	preview_label.size = Vector2(200, 20)
	FloodgateController.universal_add_child(preview_label, creator_panel)
	
	# Preview viewport
	preview_area = SubViewport.new()
	preview_area.size = Vector2(240, 300)
	preview_area.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Preview container
	var preview_container = SubViewportContainer.new()
	preview_container.position = Vector2(530, 90)
	preview_container.size = Vector2(240, 300)
	FloodgateController.universal_add_child(preview_area, preview_container)
	FloodgateController.universal_add_child(preview_container, creator_panel)
	
	# Set up preview scene
	_setup_preview_scene()

func _setup_preview_scene():
	"""Set up the 3D preview scene"""
	
	# Camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 0, 3)
	FloodgateController.universal_add_child(camera, preview_area)
	# Use look_at after adding to tree
	camera.look_at_from_position(camera.position, Vector3.ZERO, Vector3.UP)
	
	# Light
	var light = DirectionalLight3D.new()
	light.position = Vector3(2, 2, 2)
	FloodgateController.universal_add_child(light, preview_area)
	# Use look_at after adding to tree
	light.look_at_from_position(light.position, Vector3.ZERO, Vector3.UP)
	
	# Environment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.2, 0.3)
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	FloodgateController.universal_add_child(world_env, preview_area)

func _create_creation_toolbar():
	"""Create toolbar with creation options"""
	
	creation_toolbar = HBoxContainer.new()
	creation_toolbar.position = Vector2(20, 410)
	creation_toolbar.size = Vector2(760, 40)
	FloodgateController.universal_add_child(creation_toolbar, creator_panel)
	
	# Creation mode buttons
	var click_mode_btn = Button.new()
	click_mode_btn.text = "🖱️ Click Mode"
	click_mode_btn.toggle_mode = true
	click_mode_btn.button_pressed = true
	click_mode_btn.pressed.connect(_set_creation_mode.bind("click"))
	FloodgateController.universal_add_child(click_mode_btn, creation_toolbar)
	
	var drag_mode_btn = Button.new()
	drag_mode_btn.text = "🤏 Drag Mode"
	drag_mode_btn.toggle_mode = true
	drag_mode_btn.pressed.connect(_set_creation_mode.bind("drag"))
	FloodgateController.universal_add_child(drag_mode_btn, creation_toolbar)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(spacer, creation_toolbar)
	
	# Action buttons
	var create_btn = Button.new()
	create_btn.text = "✨ Create Being"
	create_btn.pressed.connect(_create_being_at_cursor)
	FloodgateController.universal_add_child(create_btn, creation_toolbar)
	
	var clear_preview_btn = Button.new()
	clear_preview_btn.text = "🗑️ Clear Preview"
	clear_preview_btn.pressed.connect(_clear_preview)
	FloodgateController.universal_add_child(clear_preview_btn, creation_toolbar)

################################################################
# EVENT HANDLERS
################################################################

func _on_being_type_selected(index: int):
	"""Handle being type selection"""
	var item_list = asset_browser
	if not item_list:
		# Find the current active tab's ItemList
		var category_tabs = creator_panel.get_node_or_null("TabContainer") 
		if category_tabs:
			item_list = category_tabs.get_current_tab_control() as ItemList
	
	if item_list:
		var metadata = item_list.get_item_metadata(index)
		if metadata != null:
			selected_being_type = str(metadata)
			print("🎯 SELECTED: " + selected_being_type)
			_update_preview()
			emit_signal("being_type_selected", selected_being_type)
		else:
			print("❌ SELECTION ERROR: No metadata for index " + str(index))
			print("🔍 Item text: " + item_list.get_item_text(index))

func _on_property_changed(property_name: String, value):
	"""Handle property changes"""
	being_properties[property_name] = value
	print("🔧 PROPERTY: %s = %s" % [property_name, str(value)])
	_update_preview()

func _set_creation_mode(mode: String):
	"""Set the creation mode"""
	creation_mode = mode
	print("🎮 CREATION MODE: " + mode)

################################################################
# PREVIEW SYSTEM
################################################################

func _update_preview():
	"""Update the 3D preview"""
	
	# Clear existing preview
	_clear_preview()
	
	# Create preview being
	preview_being = _create_preview_being(selected_being_type)
	if preview_being:
		FloodgateController.universal_add_child(preview_being, preview_area)

func _create_preview_being(being_type: String) -> Node3D:
	"""Create a preview of the selected being type"""
	
	var being = Node3D.new()
	being.name = "Preview" + being_type.capitalize()
	
	# Add mesh based on type
	var mesh_instance = MeshInstance3D.new()
	
	match being_type:
		"magical_orb":
			mesh_instance.mesh = SphereMesh.new()
		"cube":
			mesh_instance.mesh = BoxMesh.new()
		"cylinder":
			mesh_instance.mesh = CylinderMesh.new()
		"tree":
			var tree_mesh = CylinderMesh.new()
			tree_mesh.height = 2.0
			tree_mesh.top_radius = 0.1
			tree_mesh.bottom_radius = 0.3
			mesh_instance.mesh = tree_mesh
		_:
			mesh_instance.mesh = SphereMesh.new()  # Default
	
	# Apply properties
	if "size" in being_properties:
		being.scale = Vector3.ONE * being_properties.size
	
	if "color" in being_properties:
		var material = MaterialLibrary.get_material("default")
		material.albedo_color = being_properties.color
		mesh_instance.material_override = material
	
	FloodgateController.universal_add_child(mesh_instance, being)
	
	# Add rotation animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_rotate_preview.bind(being), 0.0, TAU, 4.0)
	
	return being

func _rotate_preview(being: Node3D, angle: float):
	"""Rotate preview being"""
	if being and is_instance_valid(being):
		being.rotation.y = angle

func _clear_preview():
	"""Clear the preview area"""
	if preview_being and is_instance_valid(preview_being):
		preview_being.queue_free()
		preview_being = null

################################################################
# BEING CREATION
################################################################

func _create_being_at_cursor():
	"""Create being at mouse cursor position in 3D world"""
	
	# Get mouse position in 3D space
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("❌ No camera found for 3D positioning")
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100.0
	
	# Raycast to find position
	var space_state = get_viewport().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	var position = result.position if result else from + camera.project_ray_normal(mouse_pos) * 5.0
	
	# Create the being
	_create_being_at_position(position)

func _create_being_at_position(position: Vector3):
	"""Create being at specific position"""
	
	# Prepare final properties
	var final_properties = being_properties.duplicate()
	final_properties["name"] = final_properties.get("name", selected_being_type + "_created")
	
	# Create through Universal Object Manager
	if has_node("/root/UniversalObjectManager"):
		var uom = get_node("/root/UniversalObjectManager")
		var being = uom.create_object(selected_being_type, position, final_properties)
		
		if being:
			print("✨ CREATED: %s at %s" % [selected_being_type, str(position)])
			emit_signal("being_created", selected_being_type, position, final_properties)
			
			# Close interface after creation
			_close_interface()
		else:
			print("❌ FAILED: Could not create " + selected_being_type)
	else:
		print("❌ FAILED: UniversalObjectManager not found")

################################################################
# INPUT HANDLING
################################################################

func _setup_input_handling():
	"""Set up input handling for the interface"""
	pass


func _on_title_input(event: InputEvent):
	"""Handle title bar input for dragging"""
	
	if not interface_visible:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = get_viewport().get_mouse_position() - creator_panel.position
				print("🖱️ DRAG: Started dragging interface")
			else:
				# Stop dragging
				is_dragging = false
				print("🖱️ DRAG: Stopped dragging interface")

################################################################
# INTERFACE CONTROL
################################################################

func toggle_interface():
	"""Toggle the interface visibility"""
	# Safety check - ensure interface is initialized
	if not creator_panel:
		print("⚠️ INTERFACE: Not initialized yet - forcing initialization...")
		_direct_initialization()
		if not creator_panel:
			print("❌ INTERFACE: Failed to initialize - cannot open")
			return
	
	interface_visible = !interface_visible
	visible = interface_visible
	
	if interface_visible:
		# Grab focus and pause game if needed
		if creator_panel and is_instance_valid(creator_panel):
			creator_panel.grab_focus()
	
	emit_signal("interface_toggled", interface_visible)
	print("🎨 INTERFACE: %s" % ("OPENED" if interface_visible else "CLOSED"))

func _close_interface():
	"""Close the interface"""
	interface_visible = false
	visible = false
	emit_signal("interface_toggled", false)
	print("🎨 INTERFACE: CLOSED")

################################################################
# SYSTEM CONNECTIONS
################################################################

func _connect_to_systems():
	"""Connect to other game systems"""
	
	# Connect to console for commands
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		if "commands" in console:
			console.commands["open_being_creator"] = _console_open_interface
			console.commands["create_being"] = _console_create_being
			console.commands["ui_reset"] = _console_reset_interface
			console.commands["ui_force_close"] = _console_force_close
			console.commands["ui_debug"] = _console_debug_interface
			console.commands["cursor_info"] = _console_cursor_info
			console.commands["cursor_help"] = _console_cursor_help
			console.commands["debug_beings"] = _console_debug_beings
			console.commands["center_interface"] = _console_center_interface

func _console_open_interface(_args: Array) -> String:
	"""Console command to open interface"""
	if not creator_panel:
		toggle_interface()  # This will try to initialize
		if not creator_panel:
			return "❌ Failed to initialize Universal Being Creator interface"
	else:
		toggle_interface()
	
	return "✨ Universal Being Creator interface %s" % ("opened" if interface_visible else "closed")

func _console_create_being(args: Array) -> String:
	"""Console command to create being"""
	if args.size() < 1:
		return "Usage: create_being <type> [x] [y] [z]"
	
	var being_type = args[0]
	var position = Vector3.ZERO
	
	if args.size() >= 4:
		position = Vector3(float(args[1]), float(args[2]), float(args[3]))
	
	selected_being_type = being_type
	_create_being_at_position(position)
	
	return "Created " + being_type + " at " + str(position)

func _console_reset_interface(_args: Array) -> String:
	"""Console command: Emergency interface reset"""
	print("🔄 EMERGENCY RESET: Resetting Universal Being Creator UI...")
	
	# Force close and reset
	interface_visible = false
	visible = false
	
	# Clear existing interface if it exists
	if creator_panel and is_instance_valid(creator_panel):
		creator_panel.queue_free()
		creator_panel = null
	
	# Clear all UI elements
	asset_browser = null
	property_editor = null
	preview_area = null
	creation_toolbar = null
	
	# Reinitialize
	call_deferred("_direct_initialization")
	
	return "🔄 Interface reset complete - try 'B' key or 'open_being_creator'"

func _console_force_close(_args: Array) -> String:
	"""Console command: Force close interface"""
	interface_visible = false
	visible = false
	
	if creator_panel and is_instance_valid(creator_panel):
		creator_panel.visible = false
	
	return "🚪 Interface force closed"

func _console_debug_interface(_args: Array) -> String:
	"""Console command: Debug interface state"""
	var result = "🔍 INTERFACE DEBUG STATUS\n"
	result += "═══════════════════════════════\n"
	result += "interface_visible: %s\n" % str(interface_visible)
	result += "visible: %s\n" % str(visible)
	result += "creator_panel exists: %s\n" % str(creator_panel != null)
	
	if creator_panel:
		result += "creator_panel valid: %s\n" % str(is_instance_valid(creator_panel))
		result += "creator_panel visible: %s\n" % str(creator_panel.visible)
		result += "creator_panel size: %s\n" % str(creator_panel.size)
		result += "creator_panel position: %s\n" % str(creator_panel.position)
	
	result += "asset_browser exists: %s\n" % str(asset_browser != null)
	result += "property_editor exists: %s\n" % str(property_editor != null)
	result += "preview_area exists: %s\n" % str(preview_area != null)
	
	return result

func _console_cursor_info(_args: Array) -> String:
	"""Console command: Show cursor information"""
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size
	
	var result = "🖱️ CURSOR INFORMATION\n"
	result += "═══════════════════════\n"
	result += "Mouse Position: %s\n" % str(mouse_pos)
	result += "Viewport Size: %s\n" % str(viewport_size)
	result += "Interface Visible: %s\n" % str(interface_visible)
	
	if creator_panel and is_instance_valid(creator_panel):
		result += "Panel Position: %s\n" % str(creator_panel.position)
		result += "Panel Size: %s\n" % str(creator_panel.size)
	
	return result

func _console_cursor_help(_args: Array) -> String:
	"""Console command: Cursor help and tips"""
	var result = "🎯 CURSOR USAGE GUIDE\n"
	result += "═══════════════════════\n"
	result += "3D CURSOR OFFSET EXPLANATION:\n"
	result += "• Your mouse cursor = bottom tip of 3D capsule\n"
	result += "• Click point = center of 3D capsule\n"
	result += "• The 3D cursor shows where clicks will register\n\n"
	result += "TIPS:\n"
	result += "• Look at the 3D capsule center, not your mouse\n"
	result += "• The capsule center is your true click point\n"
	result += "• Use the 3D cursor as your visual guide\n\n"
	result += "COMMANDS:\n"
	result += "• cursor_info - Show detailed cursor data\n"
	result += "• ui_debug - Show interface debug info\n"
	result += "• emergency_reset - Fix any stuck interfaces\n"
	
	return result

func _console_debug_beings(_args: Array) -> String:
	"""Console command: Debug being selection lists"""
	var result = "🔍 BEING SELECTION DEBUG\n"
	result += "═══════════════════════════\n"
	result += "Selected type: " + selected_being_type + "\n\n"
	
	result += "BEING CATEGORIES:\n"
	for category in being_categories:
		result += "• " + category + ": " + str(being_categories[category]) + "\n"
	
	result += "\nINTERFACE STATE:\n"
	result += "• creator_panel exists: " + str(creator_panel != null) + "\n"
	result += "• asset_browser exists: " + str(asset_browser != null) + "\n"
	
	if creator_panel and creator_panel.has_node("TabContainer"):
		var tabs = creator_panel.get_node("TabContainer")
		result += "• Tab count: " + str(tabs.get_tab_count()) + "\n"
		result += "• Current tab: " + str(tabs.current_tab) + "\n"
		
		var current_list = tabs.get_current_tab_control() as ItemList
		if current_list:
			result += "• Items in current list: " + str(current_list.get_item_count()) + "\n"
			for i in range(current_list.get_item_count()):
				var text = current_list.get_item_text(i)
				var metadata = current_list.get_item_metadata(i)
				result += "  [" + str(i) + "] " + text + " → " + str(metadata) + "\n"
	
	return result

func _console_center_interface(_args: Array) -> String:
	"""Console command: Center the interface on screen"""
	if creator_panel:
		var viewport_size = get_viewport().size
		var center_x = (viewport_size.x - creator_panel.size.x) / 2
		var center_y = (viewport_size.y - creator_panel.size.y) / 2
		creator_panel.position = Vector2(center_x, center_y)
		return "🎯 Interface centered on screen"
	else:
		return "❌ Interface not found"

################################################################
# END OF UNIVERSAL BEING CREATOR UI
################################################################
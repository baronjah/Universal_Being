# 🏛️ Global Variable Spreadsheet - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: global_variable_spreadsheet.gd
# DESCRIPTION: See and edit EVERY variable in the game
# PURPOSE: Complete visibility into the game's soul
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
signal variable_changed(script_path: String, var_name: String, new_value: Variant)

# UI Components
var main_panel: Panel
var tab_container: TabContainer
var search_bar: LineEdit
var refresh_button: Button
var auto_refresh_check: CheckBox

# Data
var all_scripts: Dictionary = {}  # path -> script data
var all_singletons: Dictionary = {}  # name -> node
var all_nodes: Dictionary = {}  # path -> node
var filtered_data: Array = []

# Settings
var auto_refresh: bool = false
var refresh_interval: float = 1.0
var last_refresh: float = 0.0

func _ready() -> void:
	name = "GlobalVariableSpreadsheet"
	_create_ui()
	_scan_everything()
	print("📊 [GlobalVarSpreadsheet] Ready to inspect everything!")

func _create_ui() -> void:
	"""Create the spreadsheet interface"""
	
	# Main panel
	main_panel = Panel.new()
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel.visible = false
	add_child(main_panel)
	
	# Main container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_top", 10)
	vbox.add_theme_constant_override("margin_right", 10)
	vbox.add_theme_constant_override("margin_bottom", 10)
	FloodgateController.universal_add_child(vbox, main_panel)
	
	# Header
	var header = HBoxContainer.new()
	FloodgateController.universal_add_child(header, vbox)
	
	var title = Label.new()
	title.text = "🔍 Global Variable Inspector"
	title.add_theme_font_size_override("font_size", 20)
	FloodgateController.universal_add_child(title, header)
	
	header.add_spacer(false)
	
	# Controls
	search_bar = LineEdit.new()
	search_bar.placeholder_text = "Search variables..."
	search_bar.custom_minimum_size.x = 200
	search_bar.text_changed.connect(_on_search_changed)
	FloodgateController.universal_add_child(search_bar, header)
	
	auto_refresh_check = CheckBox.new()
	auto_refresh_check.text = "Auto Refresh"
	auto_refresh_check.toggled.connect(_on_auto_refresh_toggled)
	FloodgateController.universal_add_child(auto_refresh_check, header)
	
	refresh_button = Button.new()
	refresh_button.text = "🔄 Refresh"
	refresh_button.pressed.connect(_scan_everything)
	FloodgateController.universal_add_child(refresh_button, header)
	
	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.pressed.connect(hide)
	FloodgateController.universal_add_child(close_btn, header)
	
	# Tab container
	tab_container = TabContainer.new()
	FloodgateController.universal_add_child(tab_container, vbox)
	
	# Create tabs
	_create_autoloads_tab()
	_create_scene_nodes_tab()
	_create_scripts_tab()
	_create_performance_tab()

func _create_autoloads_tab() -> void:
	"""Create tab for autoload singletons"""
	var scroll = ScrollContainer.new()
	FloodgateController.universal_add_child(scroll, tab_container)
	tab_container.set_tab_title(0, "🌐 Autoloads")
	
	var container = VBoxContainer.new()
	FloodgateController.universal_add_child(container, scroll)
	
	# This will be populated by _scan_everything()

func _create_scene_nodes_tab() -> void:
	"""Create tab for scene nodes"""
	var scroll = ScrollContainer.new()
	FloodgateController.universal_add_child(scroll, tab_container)
	tab_container.set_tab_title(1, "🎬 Scene Nodes")
	
	var container = VBoxContainer.new()
	FloodgateController.universal_add_child(container, scroll)

func _create_scripts_tab() -> void:
	"""Create tab for all loaded scripts"""
	var scroll = ScrollContainer.new()
	FloodgateController.universal_add_child(scroll, tab_container)
	tab_container.set_tab_title(2, "📜 Scripts")
	
	var container = VBoxContainer.new()
	FloodgateController.universal_add_child(container, scroll)

func _create_performance_tab() -> void:
	"""Create tab for performance metrics"""
	var scroll = ScrollContainer.new()
	FloodgateController.universal_add_child(scroll, tab_container)
	tab_container.set_tab_title(3, "📊 Performance")
	
	var container = VBoxContainer.new()
	FloodgateController.universal_add_child(container, scroll)

func _scan_everything() -> void:
	"""Scan the entire game state"""
	all_scripts.clear()
	all_singletons.clear()
	all_nodes.clear()
	
	# Scan autoloads
	_scan_autoloads()
	
	# Scan scene tree
	_scan_scene_tree()
	
	# Scan loaded scripts
	_scan_scripts()
	
	# Update displays
	_update_all_displays()
	
	print("📊 [GlobalVarSpreadsheet] Scanned everything!")

func _scan_autoloads() -> void:
	"""Scan all autoload singletons"""
	var autoloads = [
		"UniversalObjectManager",
		"PerformanceGuardian",
		"FloodgateController",
		"AssetLibrary",
		"ConsoleManager",
		"WorldBuilder",
		"DialogueSystem",
		"SceneLoader",
		"JSHSceneTree",
		"AstralBeingManager"
	]
	
	for autoload_name in autoloads:
		var node = get_node_or_null("/root/" + autoload_name)
		if node:
			all_singletons[autoload_name] = {
				"node": node,
				"script": node.get_script(),
				"properties": _get_all_properties(node),
				"methods": _get_all_methods(node)
			}

func _scan_scene_tree() -> void:
	"""Scan current scene tree"""
	var root = get_tree().current_scene
	if root:
		_scan_node_recursive(root)

func _scan_node_recursive(node: Node, path: String = "") -> void:
	"""Recursively scan nodes"""
	var node_path = (path + "/" + node.name) if not path.is_empty() else node.name
	
	all_nodes[node_path] = {
		"node": node,
		"type": node.get_class(),
		"script": node.get_script(),
		"properties": _get_all_properties(node),
		"children": node.get_child_count()
	}
	
	# Limit recursion depth for performance
	if path.count("/") < 5:
		for child in node.get_children():
			_scan_node_recursive(child, node_path)

func _scan_scripts() -> void:
	"""Scan all loaded scripts"""
	# This is simplified - in a real implementation we'd use ResourceLoader
	for singleton in all_singletons.values():
		if singleton.script:
			var script_path = singleton.script.resource_path
			all_scripts[script_path] = {
				"script": singleton.script,
				"instances": 1,
				"static_vars": _get_script_static_vars(singleton.script)
			}

func _get_all_properties(obj: Object) -> Dictionary:
	"""Get all properties of an object"""
	var props = {}
	
	for prop in obj.get_property_list():
		if prop.name.begins_with("_") or prop.name.begins_with("script"):
			continue
			
		var value = obj.get(prop.name)
		props[prop.name] = {
			"type": prop.type,
			"value": value,
			"class_name": prop.class_name,
			"hint": prop.hint,
			"usage": prop.usage
		}
	
	return props

func _get_all_methods(obj: Object) -> Array:
	"""Get all methods of an object"""
	var methods = []
	
	for method in obj.get_method_list():
		if not method.name.begins_with("_"):
			methods.append(method.name)
	
	return methods

func _get_script_static_vars(_script: Script) -> Dictionary:
	"""Get static variables from a script"""
	# This is a simplified version
	return {}

func _update_all_displays() -> void:
	"""Update all tab displays"""
	_update_autoloads_display()
	_update_scene_nodes_display()
	_update_scripts_display()
	_update_performance_display()

func _update_autoloads_display() -> void:
	"""Update autoloads tab"""
	var container = tab_container.get_child(0).get_child(0)
	
	# Clear old content
	for child in container.get_children():
		child.queue_free()
	
	# Add each autoload
	for singleton_name in all_singletons:
		var singleton = all_singletons[singleton_name]
		var expander = _create_object_expander(singleton_name, singleton)
		FloodgateController.universal_add_child(expander, container)

func _update_scene_nodes_display() -> void:
	"""Update scene nodes tab"""
	var container = tab_container.get_child(1).get_child(0)
	
	# Clear old content
	for child in container.get_children():
		child.queue_free()
	
	# Add nodes (limited to avoid overwhelming)
	var count = 0
	for path in all_nodes:
		if count > 100:  # Limit display
			var label = Label.new()
			label.text = "... and " + str(all_nodes.size() - 100) + " more nodes"
			FloodgateController.universal_add_child(label, container)
			break
		
		var node_data = all_nodes[path]
		var expander = _create_node_expander(path, node_data)
		FloodgateController.universal_add_child(expander, container)
		count += 1

func _update_scripts_display() -> void:
	"""Update scripts tab"""
	var container = tab_container.get_child(2).get_child(0)
	
	# Clear old content
	for child in container.get_children():
		child.queue_free()
	
	# Add each script
	for path in all_scripts:
		var script_data = all_scripts[path]
		var label = Label.new()
		label.text = path + " (instances: " + str(script_data.instances) + ")"
		FloodgateController.universal_add_child(label, container)

func _update_performance_display() -> void:
	"""Update performance tab"""
	var container = tab_container.get_child(3).get_child(0)
	
	# Clear old content
	for child in container.get_children():
		child.queue_free()
	
	# Add performance stats
	var stats = {
		"FPS": Engine.get_frames_per_second(),
		"Process Time": Performance.get_monitor(Performance.TIME_PROCESS),
		"Physics Time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"Node Count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"Resource Count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"Render Objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		"Draw Calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"Video Mem": str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024 / 1024) + " MB"
	}
	
	for stat_name in stats:
		var hbox = HBoxContainer.new()
		FloodgateController.universal_add_child(hbox, container)
		
		var label = Label.new()
		label.text = stat_name + ":"
		label.custom_minimum_size.x = 150
		FloodgateController.universal_add_child(label, hbox)
		
		var value = Label.new()
		value.text = str(stats[stat_name])
		value.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
		FloodgateController.universal_add_child(value, hbox)

func _create_object_expander(obj_name: String, data: Dictionary) -> VBoxContainer:
	"""Create an expandable object display"""
	var container = VBoxContainer.new()
	
	# Header button
	var header = Button.new()
	header.text = "▶ " + obj_name
	header.flat = true
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	FloodgateController.universal_add_child(header, container)
	
	# Properties container
	var props_container = VBoxContainer.new()
	props_container.visible = false
	props_container.add_theme_constant_override("margin_left", 20)
	FloodgateController.universal_add_child(props_container, container)
	
	# Toggle visibility
	header.pressed.connect(func():
		props_container.visible = not props_container.visible
		header.text = ("▼ " if props_container.visible else "▶ ") + obj_name
	)
	
	# Add properties
	for prop_name in data.properties:
		var prop_data = data.properties[prop_name]
		var prop_editor = _create_property_editor(obj_name, prop_name, prop_data)
		if prop_editor:
			FloodgateController.universal_add_child(prop_editor, props_container)
	
	return container

func _create_node_expander(path: String, data: Dictionary) -> VBoxContainer:
	"""Create an expandable node display"""
	var container = VBoxContainer.new()
	
	# Header
	var header = HBoxContainer.new()
	FloodgateController.universal_add_child(header, container)
	
	var label = Label.new()
	label.text = path + " [" + data.type + "]"
	if data.script:
		label.text += " 📜"
	FloodgateController.universal_add_child(label, header)
	
	return container

func _create_property_editor(obj_name: String, prop_name: String, prop_data: Dictionary) -> Control:
	"""Create an editor for a single property"""
	var hbox = HBoxContainer.new()
	
	# Property name
	var name_label = Label.new()
	name_label.text = prop_name + ":"
	name_label.custom_minimum_size.x = 150
	FloodgateController.universal_add_child(name_label, hbox)
	
	# Property value editor
	var value = prop_data.value
	var editor: Control = null
	
	match typeof(value):
		TYPE_BOOL:
			editor = CheckBox.new()
			editor.button_pressed = value
			editor.toggled.connect(func(pressed): _on_value_changed(obj_name, prop_name, pressed))
		
		TYPE_INT, TYPE_FLOAT:
			editor = SpinBox.new()
			editor.value = value
			editor.value_changed.connect(func(val): _on_value_changed(obj_name, prop_name, val))
		
		TYPE_STRING:
			editor = LineEdit.new()
			editor.text = value
			editor.text_changed.connect(func(text): _on_value_changed(obj_name, prop_name, text))
		
		TYPE_VECTOR2:
			editor = HBoxContainer.new()
			var x_spin = SpinBox.new()
			x_spin.value = value.x
			x_spin.value_changed.connect(func(val): 
				var v = all_singletons[obj_name].node.get(prop_name)
				v.x = val
				_on_value_changed(obj_name, prop_name, v)
			)
			FloodgateController.universal_add_child(x_spin, editor)
			
			var y_spin = SpinBox.new()
			y_spin.value = value.y
			y_spin.value_changed.connect(func(val):
				var v = all_singletons[obj_name].node.get(prop_name)
				v.y = val
				_on_value_changed(obj_name, prop_name, v)
			)
			FloodgateController.universal_add_child(y_spin, editor)
		
		_:
			editor = Label.new()
			editor.text = str(value)
			editor.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	if editor:
		FloodgateController.universal_add_child(editor, hbox)
	
	return hbox

func _on_value_changed(obj_name: String, prop_name: String, value: Variant) -> void:
	"""Handle property value change"""
	if obj_name in all_singletons:
		var node = all_singletons[obj_name].node
		node.set(prop_name, value)
		variable_changed.emit(node.get_script().resource_path, prop_name, value)
		print("📝 [GlobalVarSpreadsheet] Changed " + obj_name + "." + prop_name + " to " + str(value))

func _on_search_changed(_text: String) -> void:
	"""Filter displayed content"""
	# TODO: Implement search filtering
	pass

func _on_auto_refresh_toggled(pressed: bool) -> void:
	"""Toggle auto refresh"""
	auto_refresh = pressed
	set_process(auto_refresh)

func _process(delta: float) -> void:
	"""Auto refresh if enabled"""
	if not auto_refresh:
		return
	
	last_refresh += delta
	if last_refresh > refresh_interval:
		last_refresh = 0.0
		_scan_everything()


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func toggle_visibility() -> void:
	"""Toggle spreadsheet visibility"""
	visible = not visible
	if visible:
		_scan_everything()
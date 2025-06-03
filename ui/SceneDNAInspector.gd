# ==================================================
# SCRIPT NAME: SceneDNAInspector.gd
# DESCRIPTION: Scene DNA inspector that analyzes loaded scenes for reusable patterns
# PURPOSE: Enable understanding and extraction of scene components for evolution
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Window

# ===== SCENE DNA INSPECTOR - UNDERSTANDING LOADED SCENES =====

signal pattern_extracted(pattern_data: Dictionary)
signal component_extracted(node_path: String, node_data: Dictionary)
signal template_created(template_name: String, scene_dna: Dictionary)

# Inspector state
var current_being: UniversalBeing = null
var scene_dna: Dictionary = {}
var selected_nodes: Array[String] = []

# UI References
var tree_view: Tree
var info_panel: RichTextLabel
var pattern_list: ItemList
var extract_button: Button
var template_name_input: LineEdit

func _ready() -> void:
	title = "🧬 Scene DNA Inspector"
	size = Vector2(800, 600)
	position = Vector2(300, 200)
	
	# Create UI
	_create_inspector_ui()
	
	# Connect close
	close_requested.connect(_on_close_requested)
	
	print("🧬 Scene DNA Inspector: Ready to analyze scene structures")

func _create_inspector_ui() -> void:
	"""Create the inspector interface"""
	var main_split = HSplitContainer.new()
	main_split.split_offset = 400
	add_child(main_split)
	
	# Left panel - Scene tree
	var left_panel = VBoxContainer.new()
	left_panel.add_theme_constant_override("separation", 5)
	main_split.add_child(left_panel)
	
	var tree_label = Label.new()
	tree_label.text = "🌳 Scene Structure"
	tree_label.add_theme_font_size_override("font_size", 16)
	tree_label.add_theme_color_override("font_color", Color.GREEN)
	left_panel.add_child(tree_label)
	
	tree_view = Tree.new()
	tree_view.custom_minimum_size = Vector2(0, 400)
	tree_view.select_mode = Tree.SELECT_MULTI
	tree_view.item_selected.connect(_on_node_selected)
	left_panel.add_child(tree_view)
	
	# Extract button
	extract_button = Button.new()
	extract_button.text = "🧬 Extract Selected Components"
	extract_button.disabled = true
	extract_button.pressed.connect(_extract_selected_components)
	left_panel.add_child(extract_button)
	
	# Right panel - Information
	var right_panel = VBoxContainer.new()
	right_panel.add_theme_constant_override("separation", 10)
	main_split.add_child(right_panel)
	
	# Info display
	var info_label = Label.new()
	info_label.text = "📊 Node Analysis"
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", Color.CYAN)
	right_panel.add_child(info_label)
	
	info_panel = RichTextLabel.new()
	info_panel.bbcode_enabled = true
	info_panel.custom_minimum_size = Vector2(0, 200)
	right_panel.add_child(info_panel)
	
	# Pattern list
	var pattern_label = Label.new()
	pattern_label.text = "🎨 Detected Patterns"
	pattern_label.add_theme_font_size_override("font_size", 14)
	pattern_label.add_theme_color_override("font_color", Color.YELLOW)
	right_panel.add_child(pattern_label)
	
	pattern_list = ItemList.new()
	pattern_list.custom_minimum_size = Vector2(0, 150)
	pattern_list.item_selected.connect(_on_pattern_selected)
	right_panel.add_child(pattern_list)
	
	# Template creation
	var template_container = HBoxContainer.new()
	right_panel.add_child(template_container)
	
	template_name_input = LineEdit.new()
	template_name_input.placeholder_text = "Scene template name..."
	template_name_input.custom_minimum_size = Vector2(250, 0)
	template_container.add_child(template_name_input)
	
	var save_template_btn = Button.new()
	save_template_btn.text = "💾 Save"
	save_template_btn.pressed.connect(_save_scene_template)
	template_container.add_child(save_template_btn)

func inspect_being_scene(being: UniversalBeing) -> void:
	"""Inspect a being's loaded scene"""
	current_being = being
	
	if not being.scene_is_loaded or not being.controlled_scene:
		info_panel.text = "[color=red]No scene loaded in this being[/color]"
		return
	
	# Analyze DNA
	var dna = being.get_dna_profile()
	scene_dna = {
		"being_name": being.being_name,
		"scene_path": being.scene_path,
		"node_count": dna.node_catalog.size(),
		"interaction_points": dna.interaction_points,
		"modifiable_elements": dna.modifiable_elements,
		"patterns": dna.scene_analysis.get("reusable_patterns", [])
	}
	
	# Build tree view
	_build_scene_tree(being.controlled_scene)
	
	# Detect patterns
	_detect_scene_patterns()
	
	# Update info
	_update_info_display()
	
	print("🧬 Inspecting scene: %s" % being.scene_path)

func _build_scene_tree(root_node: Node, parent_item: TreeItem = null) -> void:
	"""Build tree view of scene structure"""
	if not parent_item:
		tree_view.clear()
		parent_item = tree_view.create_item()
		parent_item.set_text(0, "🎬 " + root_node.name)
		parent_item.set_metadata(0, root_node.get_path())
	
	for child in root_node.get_children():
		var item = tree_view.create_item(parent_item)
		var icon = _get_node_icon(child)
		item.set_text(0, icon + " " + child.name)
		item.set_metadata(0, child.get_path())
		
		# Mark reusable nodes
		if _is_node_reusable(child):
			item.set_custom_color(0, Color.GREEN)
			item.set_tooltip_text(0, "Reusable component")
		
		# Mark interactive nodes
		if _is_node_interactive(child):
			item.set_custom_color(0, Color.CYAN)
			item.set_tooltip_text(0, "Interactive element")
		
		# Recurse
		if child.get_child_count() > 0:
			_build_scene_tree(child, item)

func _get_node_icon(node: Node) -> String:
	"""Get icon for node type"""
	if node.is_class("Control"):
		if node.is_class("Button"): return "🔘"
		elif node.is_class("Label"): return "📝"
		elif node.is_class("LineEdit"): return "✏️"
		elif node.is_class("Panel"): return "📋"
		else: return "🎨"
	elif node.is_class("Node3D"):
		if node.is_class("MeshInstance3D"): return "🎲"
		elif node.is_class("Camera3D"): return "📷"
		elif node.is_class("Light3D"): return "💡"
		elif node.is_class("CollisionShape3D"): return "🛡️"
		else: return "🌐"
	elif node.is_class("Node2D"):
		if node.is_class("Sprite2D"): return "🖼️"
		elif node.is_class("Area2D"): return "📍"
		else: return "🎯"
	else:
		return "📦"

func _is_node_reusable(node: Node) -> bool:
	"""Check if node is reusable for evolution"""
	var reusable_classes = [
		"Button", "Label", "LineEdit", "TextEdit", "Panel",
		"MeshInstance3D", "Camera3D", "Light3D", "Area3D",
		"Sprite2D", "Area2D", "AnimationPlayer"
	]
	
	for class_name_str in reusable_classes:
		if node.is_class(class_name_str):
			return true
	return false

func _is_node_interactive(node: Node) -> bool:
	"""Check if node is interactive"""
	var interactive_classes = [
		"Button", "LineEdit", "TextEdit", "ItemList", "Tree",
		"Area3D", "Area2D", "TouchScreenButton"
	]
	
	for class_name in interactive_classes:
		if node.is_class(class_name):
			return true
	return false

func _detect_scene_patterns() -> void:
	"""Detect reusable patterns in the scene"""
	pattern_list.clear()
	
	if not current_being or not current_being.scene_is_loaded:
		return
	
	var dna = current_being.get_dna_profile()
	var patterns = dna.scene_analysis.get("reusable_patterns", [])
	
	for pattern in patterns:
		var icon = _get_pattern_icon(pattern.pattern_type)
		pattern_list.add_item(icon + " " + pattern.pattern_name)
		
	# Additional pattern detection
	_detect_ui_patterns()
	_detect_3d_patterns()
	_detect_interaction_patterns()

func _get_pattern_icon(pattern_type: String) -> String:
	"""Get icon for pattern type"""
	match pattern_type:
		"ui_layout": return "🎨"
		"3d_visual": return "🌐"
		"interaction": return "🤝"
		"animation": return "🎬"
		"physics": return "⚡"
		_: return "🔧"

func _detect_ui_patterns() -> void:
	"""Detect UI-specific patterns"""
	if not current_being:
		return
	
	var ui_nodes = []
	_find_nodes_of_type(current_being.controlled_scene, "Control", ui_nodes)
	
	if ui_nodes.size() > 3:
		pattern_list.add_item("🎨 Complex UI System")
		
	# Check for specific UI patterns
	var has_buttons = false
	var has_inputs = false
	var has_displays = false
	
	for node in ui_nodes:
		if node.is_class("Button"): has_buttons = true
		if node.is_class("LineEdit") or node.is_class("TextEdit"): has_inputs = true
		if node.is_class("Label") or node.is_class("RichTextLabel"): has_displays = true
	
	if has_buttons and has_inputs:
		pattern_list.add_item("📝 Input Form Pattern")
	if has_buttons and has_displays:
		pattern_list.add_item("🖥️ Interactive Display")

func _detect_3d_patterns() -> void:
	"""Detect 3D-specific patterns"""
	if not current_being:
		return
	
	var mesh_nodes = []
	var light_nodes = []
	var camera_nodes = []
	
	_find_nodes_of_type(current_being.controlled_scene, "MeshInstance3D", mesh_nodes)
	_find_nodes_of_type(current_being.controlled_scene, "Light3D", light_nodes)
	_find_nodes_of_type(current_being.controlled_scene, "Camera3D", camera_nodes)
	
	if mesh_nodes.size() > 0 and light_nodes.size() > 0:
		pattern_list.add_item("💡 Lit 3D Scene")
	
	if camera_nodes.size() > 0:
		pattern_list.add_item("📷 Camera System")
	
	if mesh_nodes.size() > 5:
		pattern_list.add_item("🏗️ Complex 3D Structure")

func _detect_interaction_patterns() -> void:
	"""Detect interaction patterns"""
	if not current_being:
		return
	
	var area_nodes = []
	_find_nodes_of_type(current_being.controlled_scene, "Area3D", area_nodes)
	_find_nodes_of_type(current_being.controlled_scene, "Area2D", area_nodes)
	
	if area_nodes.size() > 0:
		pattern_list.add_item("📍 Spatial Interaction")
	
	var anim_nodes = []
	_find_nodes_of_type(current_being.controlled_scene, "AnimationPlayer", anim_nodes)
	
	if anim_nodes.size() > 0:
		pattern_list.add_item("🎬 Animated System")

func _find_nodes_of_type(root: Node, type_name: String, result_array: Array) -> void:
	"""Recursively find nodes of specific type"""
	if root.is_class(type_name):
		result_array.append(root)
	
	for child in root.get_children():
		_find_nodes_of_type(child, type_name, result_array)

func _on_node_selected() -> void:
	"""Handle node selection in tree"""
	selected_nodes.clear()
	var selected = tree_view.get_selected()
	
	if selected:
		var node_path = selected.get_metadata(0)
		selected_nodes.append(node_path)
		
		# Get all selected items (for multi-select)
		var next = tree_view.get_next_selected(selected)
		while next:
			selected_nodes.append(next.get_metadata(0))
			next = tree_view.get_next_selected(next)
		
		# Update UI
		extract_button.disabled = selected_nodes.is_empty()
		_show_node_info(selected_nodes[0])

func _show_node_info(node_path: NodePath) -> void:
	"""Show information about selected node"""
	if not current_being:
		return
	
	var node = current_being.controlled_scene.get_node_or_null(node_path)
	if not node:
		return
	
	var dna = current_being.get_dna_profile()
	var node_info = dna.node_catalog.get(str(node_path), {})
	
	var info_text = "[b]Node: %s[/b]\n" % node.name
	info_text += "Class: %s\n" % node.get_class()
	info_text += "Path: %s\n\n" % node_path
	
	if node_info.has("properties"):
		info_text += "[b]Properties:[/b]\n"
		for prop_name in node_info.properties:
			var prop_data = node_info.properties[prop_name]
			info_text += "• %s: %s\n" % [prop_name, str(prop_data.value)]
	
	if node_info.has("signals"):
		info_text += "\n[b]Signals:[/b]\n"
		for signal_name in node_info.signals:
			info_text += "• %s\n" % signal_name
	
	if _is_node_reusable(node):
		info_text += "\n[color=green]✓ Reusable Component[/color]\n"
	
	if _is_node_interactive(node):
		info_text += "[color=cyan]✓ Interactive Element[/color]\n"
	
	info_panel.text = info_text

func _on_pattern_selected(index: int) -> void:
	"""Handle pattern selection"""
	var pattern_name = pattern_list.get_item_text(index)
	info_panel.text = "[b]Pattern: %s[/b]\n\n[i]This pattern can be extracted and reused in other beings[/i]" % pattern_name

func _extract_selected_components() -> void:
	"""Extract selected components for reuse"""
	if selected_nodes.is_empty() or not current_being:
		return
	
	print("🧬 Extracting %d components..." % selected_nodes.size())
	
	for node_path in selected_nodes:
		var node = current_being.controlled_scene.get_node_or_null(node_path)
		if node and _is_node_reusable(node):
			var node_data = _extract_node_data(node)
			component_extracted.emit(str(node_path), node_data)
			print("🧬 Extracted: %s (%s)" % [node.name, node.get_class()])

func _extract_node_data(node: Node) -> Dictionary:
	"""Extract data from a node for reuse"""
	var data = {
		"name": node.name,
		"class": node.get_class(),
		"properties": {},
		"children": []
	}
	
	# Extract key properties
	var property_list = node.get_property_list()
	for prop in property_list:
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not prop.name.begins_with("_"):
			data.properties[prop.name] = node.get(prop.name)
	
	# Extract transform for spatial nodes
	if node.is_class("Node3D"):
		data.properties["transform"] = node.transform
	elif node.is_class("Control"):
		data.properties["position"] = node.position
		data.properties["size"] = node.size
	
	return data

func _save_scene_template() -> void:
	"""Save current scene analysis as template"""
	if not current_being or template_name_input.text.is_empty():
		return
	
	var template_name = template_name_input.text.strip_edges()
	var template_data = {
		"name": template_name,
		"source_scene": current_being.scene_path,
		"node_count": scene_dna.node_count,
		"patterns": scene_dna.patterns,
		"interaction_points": scene_dna.interaction_points,
		"modifiable_elements": scene_dna.modifiable_elements,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	template_created.emit(template_name, template_data)
	print("🧬 Scene template saved: %s" % template_name)
	
	# Clear input
	template_name_input.text = ""

func _update_info_display() -> void:
	"""Update main info display"""
	if not current_being:
		info_panel.text = "[i]No scene loaded[/i]"
		return
	
	info_panel.text = """[b]Scene DNA Analysis[/b]
Scene: %s
Nodes: %d
Interaction Points: %d
Modifiable Elements: %d
Detected Patterns: %d

[i]Select nodes to extract components or patterns to understand the structure[/i]""" % [
		current_being.scene_path.get_file(),
		scene_dna.node_count,
		scene_dna.interaction_points.size(),
		scene_dna.modifiable_elements.size(),
		pattern_list.get_item_count()
	]

func _on_close_requested() -> void:
	"""Handle window close"""
	hide()
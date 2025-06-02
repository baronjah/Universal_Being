# ==================================================
# SCRIPT NAME: UniverseNavigator.gd
# DESCRIPTION: Visual navigator for universe hierarchy
# PURPOSE: Provide intuitive navigation through recursive universes
# CREATED: 2025-06-02 - The Cosmic Map
# AUTHOR: JSH + Claude (Opus 4) - Cartographers of Infinity
# ==================================================

extends Control
class_name UniverseNavigator

# ===== NAVIGATOR PROPERTIES =====

var current_universe: Node = null
var universe_nodes: Dictionary = {}  # Universe -> GraphNode
var akashic_library: Node = null

# UI Elements
var graph_edit: GraphEdit = null
var info_panel: PanelContainer = null
var info_label: RichTextLabel = null
var mini_map: Control = null

# Visual Settings
@export var node_colors: Dictionary = {
	"root": Color(0.2, 0.5, 0.8),
	"active": Color(0.2, 0.8, 0.2),
	"normal": Color(0.4, 0.4, 0.4),
	"sub": Color(0.6, 0.3, 0.6)
}

signal universe_selected(universe: Node)
signal portal_visualized(from: Node, to: Node)

func _ready() -> void:
	name = "UniverseNavigator"
	custom_minimum_size = Vector2(800, 600)
	
	# Get Akashic Library
	akashic_library = get_tree().get_first_node_in_group("akashic_library")
	
	create_ui()
	refresh_universe_map()

func create_ui() -> void:
	"""Create the navigator interface"""
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Universe Navigator"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Main content
	var hbox = HSplitContainer.new()
	hbox.split_offset = 600
	vbox.add_child(hbox)
	
	# Graph editor
	graph_edit = GraphEdit.new()
	graph_edit.custom_minimum_size = Vector2(600, 500)
	graph_edit.right_disconnects = true
	graph_edit.minimap_enabled = true
	graph_edit.zoom_min = 0.5
	graph_edit.zoom_max = 2.0
	graph_edit.node_selected.connect(_on_node_selected)
	hbox.add_child(graph_edit)
	
	# Info panel
	info_panel = PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(200, 500)
	hbox.add_child(info_panel)
	
	var info_vbox = VBoxContainer.new()
	info_panel.add_child(info_vbox)
	
	var info_title = Label.new()
	info_title.text = "Universe Info"
	info_title.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(info_title)
	
	info_vbox.add_child(HSeparator.new())
	
	info_label = RichTextLabel.new()
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	info_vbox.add_child(info_label)

func refresh_universe_map() -> void:
	"""Refresh the universe visualization"""
	# Clear existing nodes
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
	universe_nodes.clear()
	
	# Find all universes
	var universes = _find_all_universes()
	
	# Create nodes for each universe
	for i in range(universes.size()):
		var universe = universes[i]
		_create_universe_node(universe, i)
	
	# Create connections for portals
	for universe in universes:
		_create_portal_connections(universe)
	
	# Arrange nodes
	_auto_arrange_nodes()

func _create_universe_node(universe: Node, index: int) -> GraphNode:
	"""Create a visual node for a universe"""
	var node = GraphNode.new()
	node.title = universe.universe_name
	
	var info = universe.get_universe_info()
	
	# Set node color based on type
	if universe == current_universe:
		node.overlay = GraphNode.OVERLAY_POSITION
	
	# Add content
	var content = VBoxContainer.new()
	node.add_child(content)
	
	var age_label = Label.new()
	age_label.text = "Age: %.1f s" % info.get("age", 0.0)
	content.add_child(age_label)
	
	var beings_label = Label.new()
	beings_label.text = "Beings: %d" % info.get("beings", 0)
	content.add_child(beings_label)
	
	var consciousness_label = Label.new()
	consciousness_label.text = "Consciousness: %.1f" % info.get("consciousness", 0.0)
	content.add_child(consciousness_label)
	
	# Position node
	node.position_offset = Vector2(
		(index % 4) * 250,
		(index / 4) * 200
	)
	
	# Add to graph
	graph_edit.add_child(node)
	universe_nodes[universe] = node
	
	return node

func _create_portal_connections(universe: Node) -> void:
	"""Create visual connections for portals"""
	if not universe in universe_nodes:
		return
	
	var from_node = universe_nodes[universe]
	
	# Add ports for connections
	from_node.set_slot(0, false, 0, Color.WHITE, true, 0, Color.CYAN)
	
	# Create connections
	for portal_id in universe.portal_connections:
		var target_universe = universe.portal_connections[portal_id]
		if target_universe in universe_nodes:
			var to_node = universe_nodes[target_universe]
			to_node.set_slot(0, true, 0, Color.CYAN, false, 0, Color.WHITE)
			
			# Note: GraphEdit connections are created differently in Godot 4
			# We'll visualize them as lines for now

func _auto_arrange_nodes() -> void:
	"""Automatically arrange nodes in a hierarchical layout"""
	var root_universes = _find_root_universes()
	var x_offset = 50
	var y_offset = 50
	var level_height = 200
	var node_width = 250
	
	# Arrange root universes
	for i in range(root_universes.size()):
		var universe = root_universes[i]
		if universe in universe_nodes:
			var node = universe_nodes[universe]
			node.position_offset = Vector2(x_offset + i * node_width, y_offset)
	
	# TODO: Implement hierarchical layout for sub-universes

func _on_node_selected(node: Node) -> void:
	"""Handle node selection"""
	# Find which universe this node represents
	for universe in universe_nodes:
		if universe_nodes[universe] == node:
			_display_universe_info(universe)
			universe_selected.emit(universe)
			break

func _display_universe_info(universe: Node) -> void:
	"""Display detailed universe information"""
	var info = universe.get_universe_info()
	
	var text = "[b]%s[/b]\n\n" % info.get("name", "Unknown")
	text += "[b]Statistics:[/b]\n"
	text += "• Age: %.2f seconds\n" % info.get("age", 0.0)
	text += "• Beings: %d / %d\n" % [info.get("beings", 0), info.rules.get("max_beings", 1000)]
	text += "• Sub-universes: %d\n" % info.get("sub_universes", 0)
	text += "• Consciousness: %.2f\n" % info.get("consciousness", 0.0)
	text += "• Entropy: %.4f\n\n" % info.get("entropy", 0.0)
	
	text += "[b]Rules:[/b]\n"
	var rules = info.get("rules", {})
	for rule_name in rules:
		text += "• %s: %s\n" % [rule_name, str(rules[rule_name])]
	
	info_label.text = text

func set_current_universe(universe: Node) -> void:
	"""Set the current active universe"""
	current_universe = universe
	refresh_universe_map()

# Helper methods
func _find_all_universes() -> Array[Node]:
	"""Find all universes in the scene tree"""
	var universes: Array[Node] = []
	_find_universes_recursive(get_tree().root, universes)
	return universes

func _find_universes_recursive(node: Node, universes: Array[Node]) -> void:
	"""Recursively find all universe beings"""
	if node and node.has_method("get_universe_info"):
		universes.append(node)
	
	for child in node.get_children():
		_find_universes_recursive(child, universes)

func _find_root_universes() -> Array[Node]:
	"""Find universes that aren't inside other universes"""
	var all_universes = _find_all_universes()
	var root_universes: Array[Node] = []
	
	for universe in all_universes:
		var is_root = true
		var parent = universe.get_parent()
		while parent:
			if parent.has_method("get_universe_info"):
				is_root = false
				break
			parent = parent.get_parent()
		
		if is_root:
			root_universes.append(universe)
	
	return root_universes

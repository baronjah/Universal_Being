# ==================================================
# SCRIPT NAME: UniverseDNAEditor.gd
# DESCRIPTION: Advanced visual editor for Universe DNA manipulation
# PURPOSE: Enable intuitive editing of universe genetic traits and inheritance
# CREATED: 2025-06-03 - Universal Being Evolution
# AUTHOR: Claude Desktop MCP
# ==================================================

extends Control
class_name UniverseDNAEditor

# ===== UNIVERSE DNA EDITOR - THE GENETIC SCULPTOR =====

signal dna_modified(universe: Node, trait: String, new_value: float)
signal template_created(template_name: String, dna: Dictionary)
signal mutation_applied(universe: Node, mutations: Dictionary)

# Visual constants
const TRAIT_COLORS = {
	"physics": Color(0.2, 0.6, 1.0),    # Blue for physics
	"time": Color(1.0, 0.8, 0.2),       # Yellow for time
	"consciousness": Color(1.0, 0.2, 1.0), # Magenta for consciousness
	"entropy": Color(1.0, 0.2, 0.2),    # Red for entropy
	"creativity": Color(0.2, 1.0, 0.6),  # Green for creativity
}

# UI References
var dna_visualization: Control
var trait_sliders: Dictionary = {}
var mutation_panel: Panel
var inheritance_tree: Tree
var preview_viewport: SubViewport
var preview_camera: Camera3D

# State
var current_universe: Node = null
var universe_dna: Dictionary = {}
var parent_dna: Dictionary = {}
var mutation_rate: float = 0.2
var is_comparing: bool = false

func _ready():
	name = "UniverseDNAEditor"
	custom_minimum_size = Vector2(800, 600)
	
	_create_ui_structure()
	_initialize_dna_traits()
	_connect_signals()
	
	_log_genesis("🧬 Universe DNA Editor manifested - the code of creation revealed...")

func _create_ui_structure():
	"""Build the complete DNA editor interface"""
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)
	
	# Header
	var header = _create_header()
	main_container.add_child(header)
	
	# Main content area
	var content_split = HSplitContainer.new()
	content_split.split_offset = 400
	main_container.add_child(content_split)
	
	# Left: DNA Visualization
	var left_panel = _create_dna_visualization_panel()
	content_split.add_child(left_panel)
	
	# Right: Controls
	var right_panel = _create_control_panel()
	content_split.add_child(right_panel)

func _create_header() -> PanelContainer:
	"""Create the header with universe selector"""
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)
	
	var hbox = HBoxContainer.new()
	header.add_child(hbox)
	
	# Title
	var title = Label.new()
	title.text = "🧬 Universe DNA Editor"
	title.add_theme_font_size_override("font_size", 24)
	hbox.add_child(title)
	
	hbox.add_spacer(false)
	
	# Universe selector
	var selector_label = Label.new()
	selector_label.text = "Target Universe:"
	hbox.add_child(selector_label)
	
	var universe_selector = OptionButton.new()
	universe_selector.custom_minimum_size = Vector2(200, 0)
	universe_selector.item_selected.connect(_on_universe_selected)
	hbox.add_child(universe_selector)
	
	# Populate with existing universes
	_populate_universe_selector(universe_selector)
	
	return header

func _create_dna_visualization_panel() -> Panel:
	"""Create the DNA visualization area"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 0)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	# DNA Helix Visualization
	dna_visualization = DNAHelixVisualizer.new()
	dna_visualization.custom_minimum_size = Vector2(0, 300)
	vbox.add_child(dna_visualization)
	
	# Trait comparison graph
	var comparison_graph = _create_trait_comparison_graph()
	vbox.add_child(comparison_graph)
	
	return panel

func _create_control_panel() -> Panel:
	"""Create the control panel with trait sliders"""
	var panel = Panel.new()
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	# Physics Traits Section
	vbox.add_child(_create_trait_section("⚛️ Physics Traits", [
		{"name": "gravity", "min": 0.0, "max": 5.0, "default": 1.0},
		{"name": "friction", "min": 0.0, "max": 2.0, "default": 1.0},
		{"name": "elasticity", "min": 0.0, "max": 2.0, "default": 1.0},
		{"name": "matter_density", "min": 0.1, "max": 10.0, "default": 1.0}
	], "physics"))
	
	# Time Traits Section
	vbox.add_child(_create_trait_section("⏰ Time Traits", [
		{"name": "time_flow", "min": 0.1, "max": 10.0, "default": 1.0},
		{"name": "causality_strength", "min": 0.0, "max": 1.0, "default": 1.0},
		{"name": "temporal_viscosity", "min": 0.0, "max": 1.0, "default": 0.1}
	], "time"))
	
	# Consciousness Traits Section
	vbox.add_child(_create_trait_section("🧠 Consciousness Traits", [
		{"name": "awareness_coefficient", "min": 0.0, "max": 10.0, "default": 1.0},
		{"name": "creativity_factor", "min": 0.0, "max": 2.0, "default": 1.0},
		{"name": "harmony_resonance", "min": 0.0, "max": 1.0, "default": 0.5},
		{"name": "evolution_rate", "min": 0.1, "max": 5.0, "default": 1.0}
	], "consciousness"))
	
	# Entropy Traits Section
	vbox.add_child(_create_trait_section("🌀 Entropy Traits", [
		{"name": "chaos_level", "min": 0.0, "max": 1.0, "default": 0.2},
		{"name": "order_tendency", "min": 0.0, "max": 1.0, "default": 0.8},
		{"name": "emergence_probability", "min": 0.0, "max": 1.0, "default": 0.5}
	], "entropy"))
	
	# Action buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var apply_btn = Button.new()
	apply_btn.text = "Apply DNA Changes"
	apply_btn.pressed.connect(_apply_dna_changes)
	button_container.add_child(apply_btn)
	
	var mutate_btn = Button.new()
	mutate_btn.text = "Random Mutation"
	mutate_btn.pressed.connect(_apply_random_mutation)
	button_container.add_child(mutate_btn)
	
	var save_template_btn = Button.new()
	save_template_btn.text = "Save as Template"
	save_template_btn.pressed.connect(_save_as_template)
	button_container.add_child(save_template_btn)
	
	return panel

func _create_trait_section(title: String, traits: Array, category: String) -> VBoxContainer:
	"""Create a section for related traits"""
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 5)
	
	# Section header
	var header = Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 18)
	header.modulate = TRAIT_COLORS.get(category, Color.WHITE)
	section.add_child(header)
	
	# Trait sliders
	for trait_def in traits:
		var trait_control = _create_trait_slider(
			trait_def.name,
			trait_def.min,
			trait_def.max,
			trait_def.default,
			category
		)
		section.add_child(trait_control)
		trait_sliders[trait_def.name] = trait_control.get_node("HBox/Slider")
	
	return section

func _create_trait_slider(trait_name: String, min_val: float, max_val: float, default: float, category: String) -> Panel:
	"""Create a single trait slider control"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 40)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)
	
	# Trait name
	var name_label = Label.new()
	name_label.text = trait_name.capitalize().replace("_", " ")
	name_label.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(name_label)
	
	# Slider
	var slider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_trait_changed.bind(trait_name))
	hbox.add_child(slider)
	
	# Value label
	var value_label = Label.new()
	value_label.text = "%.2f" % default
	value_label.custom_minimum_size = Vector2(50, 0)
	slider.value_changed.connect(func(val): value_label.text = "%.2f" % val)
	hbox.add_child(value_label)
	
	return panel

func _create_trait_comparison_graph() -> Panel:
	"""Create a radar chart for trait comparison"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 200)
	
	# This would be a custom radar chart control
	# For now, using a placeholder
	var label = Label.new()
	label.text = "DNA Trait Comparison\n(Parent vs Current)"
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.add_child(label)
	
	return panel

func _initialize_dna_traits() -> void:
	"""Initialize default DNA traits"""
	universe_dna = {
		# Physics
		"gravity": 1.0,
		"friction": 1.0,
		"elasticity": 1.0,
		"matter_density": 1.0,
		# Time
		"time_flow": 1.0,
		"causality_strength": 1.0,
		"temporal_viscosity": 0.1,
		# Consciousness
		"awareness_coefficient": 1.0,
		"creativity_factor": 1.0,
		"harmony_resonance": 0.5,
		"evolution_rate": 1.0,
		# Entropy
		"chaos_level": 0.2,
		"order_tendency": 0.8,
		"emergence_probability": 0.5
	}

func _connect_signals() -> void:
	"""Connect internal signals"""
	# Future signal connections
	pass

func edit_universe_dna(universe: Node) -> void:
	"""Load a universe's DNA for editing"""
	if not universe or not universe.has_method("get_universe_dna"):
		push_error("Invalid universe for DNA editing")
		return
	
	current_universe = universe
	universe_dna = universe.get_universe_dna()
	
	# Update all sliders with current values
	for trait_name in trait_sliders:
		if trait_name in universe_dna:
			trait_sliders[trait_name].set_value_no_signal(universe_dna[trait_name])
	
	# Update visualization
	if dna_visualization:
		dna_visualization.update_dna(universe_dna)
	
	# Load parent DNA if available
	if universe.has_method("get_parent_universe"):
		var parent = universe.get_parent_universe()
		if parent and parent.has_method("get_universe_dna"):
			parent_dna = parent.get_universe_dna()
			is_comparing = true

func _on_trait_changed(value: float, trait_name: String) -> void:
	"""Handle trait value changes"""
	universe_dna[trait_name] = value
	
	# Update visualization in real-time
	if dna_visualization:
		dna_visualization.update_trait(trait_name, value)
	
	# Preview changes if enabled
	_preview_dna_changes()

func _apply_dna_changes() -> void:
	"""Apply the modified DNA to the current universe"""
	if not current_universe:
		return
	
	for trait_name in universe_dna:
		if current_universe.has_method("set_universe_trait"):
			current_universe.set_universe_trait(trait_name, universe_dna[trait_name])
			dna_modified.emit(current_universe, trait_name, universe_dna[trait_name])
	
	_log_genesis("🧬 Universe DNA modified - new traits applied to %s" % current_universe.name)

func _apply_random_mutation() -> void:
	"""Apply random mutations based on mutation rate"""
	var mutations = {}
	
	for trait_name in universe_dna:
		if randf() < mutation_rate:
			var current_val = universe_dna[trait_name]
			var mutation_strength = randf_range(-0.3, 0.3)
			var new_val = clamp(current_val + (current_val * mutation_strength), 
				trait_sliders[trait_name].min_value,
				trait_sliders[trait_name].max_value)
			
			universe_dna[trait_name] = new_val
			trait_sliders[trait_name].set_value_no_signal(new_val)
			mutations[trait_name] = new_val
	
	if mutations.size() > 0:
		mutation_applied.emit(current_universe, mutations)
		_log_genesis("🧬 Random mutations applied: %s" % mutations.keys())

func _save_as_template() -> void:
	"""Save current DNA configuration as a template"""
	# This would open a dialog to name the template
	var template_name = "Custom_Template_%d" % Time.get_ticks_msec()
	template_created.emit(template_name, universe_dna.duplicate())
	_log_genesis("🧬 DNA template created: %s" % template_name)

func _populate_universe_selector(selector: OptionButton) -> void:
	"""Populate the universe selector dropdown"""
	selector.clear()
	
	# Find all universes in the scene
	var universes = get_tree().get_nodes_in_group("universes")
	for universe in universes:
		selector.add_item(universe.name)
		selector.set_item_metadata(selector.get_item_count() - 1, universe)

func _on_universe_selected(index: int) -> void:
	"""Handle universe selection from dropdown"""
	var selector = $VBoxContainer/Header/HBoxContainer/OptionButton
	var universe = selector.get_item_metadata(index)
	if universe:
		edit_universe_dna(universe)

func _preview_dna_changes() -> void:
	"""Preview DNA changes in real-time (if preview viewport exists)"""
	# This would update a preview viewport showing the universe with new traits
	pass

func _log_genesis(message: String) -> void:
	"""Log events in genesis style"""
	print(message)
	
	# Log to Akashic Library if available
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_genesis_event("dna_editor", message, {
				"universe": current_universe.name if current_universe else "none",
				"dna": universe_dna
			})

# ===== DNA HELIX VISUALIZER =====

class DNAHelixVisualizer extends Control:
	var dna_data: Dictionary = {}
	var animation_time: float = 0.0
	
	func _ready():
		custom_minimum_size = Vector2(300, 300)
	
	func _draw():
		# Draw DNA double helix visualization
		var center = size / 2
		var radius = min(size.x, size.y) * 0.4
		
		# Draw helix strands
		for i in range(20):
			var t = float(i) / 20.0
			var angle = t * TAU * 2 + animation_time
			var y = (t - 0.5) * size.y
			
			var x1 = center.x + cos(angle) * radius
			var x2 = center.x - cos(angle) * radius
			
			# Draw connection
			draw_line(Vector2(x1, y), Vector2(x2, y), Color(0.3, 0.7, 1.0, 0.5), 2.0)
			
			# Draw nodes
			draw_circle(Vector2(x1, y), 4, Color(0.2, 0.6, 1.0))
			draw_circle(Vector2(x2, y), 4, Color(1.0, 0.2, 0.6))
	
	func _process(delta):
		animation_time += delta
		queue_redraw()
	
	func update_dna(data: Dictionary) -> void:
		dna_data = data
		queue_redraw()
	
	func update_trait(trait_name: String, value: float) -> void:
		dna_data[trait_name] = value
		queue_redraw()

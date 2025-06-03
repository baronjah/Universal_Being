# ==================================================
# SCRIPT NAME: BlueprintToolbar.gd
# DESCRIPTION: Blueprint toolbar for quick access to DNA templates and cloning
# PURPOSE: Enable rapid creation and evolution using DNA blueprints
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Control

# ===== BLUEPRINT TOOLBAR - THE CREATION PALETTE =====

signal blueprint_selected(dna_profile: UniversalBeingDNA)
signal clone_requested(source_being: UniversalBeing, modifications: Dictionary)
signal evolution_requested(source_being: UniversalBeing, target_template: UniversalBeingDNA)
signal template_saved(template_name: String, dna_profile: UniversalBeingDNA)

# Toolbar state
var is_expanded: bool = false
var selected_being: UniversalBeing = null
var blueprint_library: Dictionary = {}  # name -> DNA profile
var recent_blueprints: Array[String] = []
var max_recent: int = 5

# UI References
var toolbar_panel: Panel
var blueprint_list: ItemList
var being_info: RichTextLabel
var action_buttons: HBoxContainer
var template_name_input: LineEdit
var modification_panel: VBoxContainer

# Visual settings
const TOOLBAR_WIDTH = 300
const COLLAPSED_WIDTH = 50
const EXPAND_SPEED = 0.3

func _ready() -> void:
	name = "BlueprintToolbar"
	set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	custom_minimum_size = Vector2(COLLAPSED_WIDTH, 600)
	
	# Create UI
	_create_toolbar_ui()
	_load_blueprint_library()
	
	# Connect to cursor for being selection
	_connect_to_cursor()
	
	print("🧬 Blueprint Toolbar: Ready for rapid DNA-based creation")

func _create_toolbar_ui() -> void:
	"""Create the toolbar interface"""
	# Main panel
	toolbar_panel = Panel.new()
	toolbar_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	panel_style.border_color = Color(0.0, 0.8, 0.8, 1.0)
	panel_style.border_width_right = 2
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_right = 10
	toolbar_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(toolbar_panel)
	
	# Expand/Collapse button
	var toggle_btn = Button.new()
	toggle_btn.text = "🧬"
	toggle_btn.custom_minimum_size = Vector2(40, 40)
	toggle_btn.position = Vector2(5, 280)
	toggle_btn.pressed.connect(_toggle_toolbar)
	toggle_btn.tooltip_text = "Toggle Blueprint Toolbar"
	toolbar_panel.add_child(toggle_btn)
	
	# Main container (hidden when collapsed)
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.set_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 10)
	main_container.visible = false
	toolbar_panel.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "🧬 DNA Blueprint Toolbar"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.CYAN)
	main_container.add_child(title)
	
	# Being info display
	var info_label = Label.new()
	info_label.text = "Selected Being:"
	info_label.add_theme_color_override("font_color", Color.YELLOW)
	main_container.add_child(info_label)
	
	being_info = RichTextLabel.new()
	being_info.bbcode_enabled = true
	being_info.fit_content = true
	being_info.custom_minimum_size = Vector2(0, 100)
	being_info.text = "[i]No being selected[/i]"
	main_container.add_child(being_info)
	
	# Blueprint library
	var library_label = Label.new()
	library_label.text = "Blueprint Library:"
	library_label.add_theme_color_override("font_color", Color.GREEN)
	main_container.add_child(library_label)
	
	blueprint_list = ItemList.new()
	blueprint_list.custom_minimum_size = Vector2(0, 200)
	blueprint_list.item_selected.connect(_on_blueprint_selected)
	main_container.add_child(blueprint_list)
	
	# Template name input
	var save_container = HBoxContainer.new()
	main_container.add_child(save_container)
	
	template_name_input = LineEdit.new()
	template_name_input.placeholder_text = "Template name..."
	template_name_input.custom_minimum_size = Vector2(180, 0)
	save_container.add_child(template_name_input)
	
	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_save_current_template)
	save_container.add_child(save_btn)
	
	# Action buttons
	var action_label = Label.new()
	action_label.text = "Quick Actions:"
	action_label.add_theme_color_override("font_color", Color.MAGENTA)
	main_container.add_child(action_label)
	
	action_buttons = HBoxContainer.new()
	main_container.add_child(action_buttons)
	
	var clone_btn = Button.new()
	clone_btn.text = "🧬 Clone"
	clone_btn.tooltip_text = "Create exact clone"
	clone_btn.pressed.connect(_request_clone)
	action_buttons.add_child(clone_btn)
	
	var evolve_btn = Button.new()
	evolve_btn.text = "🦋 Evolve"
	evolve_btn.tooltip_text = "Evolve from template"
	evolve_btn.pressed.connect(_request_evolution)
	action_buttons.add_child(evolve_btn)
	
	var analyze_btn = Button.new()
	analyze_btn.text = "🔬 Analyze"
	analyze_btn.tooltip_text = "Analyze being DNA"
	analyze_btn.pressed.connect(_analyze_current_being)
	action_buttons.add_child(analyze_btn)
	
	# Modification panel
	modification_panel = VBoxContainer.new()
	modification_panel.visible = false
	main_container.add_child(modification_panel)
	
	_create_modification_controls()

func _create_modification_controls() -> void:
	"""Create controls for modifying clones/evolution"""
	var mod_title = Label.new()
	mod_title.text = "Modifications:"
	mod_title.add_theme_color_override("font_color", Color.ORANGE)
	modification_panel.add_child(mod_title)
	
	# Consciousness modifier
	var consciousness_container = HBoxContainer.new()
	modification_panel.add_child(consciousness_container)
	
	var consciousness_label = Label.new()
	consciousness_label.text = "Consciousness:"
	consciousness_label.custom_minimum_size = Vector2(100, 0)
	consciousness_container.add_child(consciousness_label)
	
	var consciousness_slider = HSlider.new()
	consciousness_slider.name = "ConsciousnessSlider"
	consciousness_slider.min_value = -3
	consciousness_slider.max_value = 3
	consciousness_slider.value = 0
	consciousness_slider.step = 1
	consciousness_slider.custom_minimum_size = Vector2(100, 0)
	consciousness_container.add_child(consciousness_slider)
	
	var consciousness_value = Label.new()
	consciousness_value.name = "ConsciousnessValue"
	consciousness_value.text = "0"
	consciousness_value.custom_minimum_size = Vector2(30, 0)
	consciousness_container.add_child(consciousness_value)
	
	consciousness_slider.value_changed.connect(func(value): consciousness_value.text = "%+d" % int(value))
	
	# Mutation rate
	var mutation_container = HBoxContainer.new()
	modification_panel.add_child(mutation_container)
	
	var mutation_label = Label.new()
	mutation_label.text = "Mutation Rate:"
	mutation_label.custom_minimum_size = Vector2(100, 0)
	mutation_container.add_child(mutation_label)
	
	var mutation_slider = HSlider.new()
	mutation_slider.name = "MutationSlider"
	mutation_slider.min_value = 0.0
	mutation_slider.max_value = 1.0
	mutation_slider.value = 0.1
	mutation_slider.step = 0.05
	mutation_slider.custom_minimum_size = Vector2(100, 0)
	mutation_container.add_child(mutation_slider)
	
	var mutation_value = Label.new()
	mutation_value.name = "MutationValue"
	mutation_value.text = "10%"
	mutation_value.custom_minimum_size = Vector2(40, 0)
	mutation_container.add_child(mutation_value)
	
	mutation_slider.value_changed.connect(func(value): mutation_value.text = "%d%%" % int(value * 100))

func _toggle_toolbar() -> void:
	"""Toggle toolbar expansion"""
	is_expanded = !is_expanded
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_width = TOOLBAR_WIDTH if is_expanded else COLLAPSED_WIDTH
	tween.tween_property(self, "custom_minimum_size:x", target_width, EXPAND_SPEED)
	
	# Show/hide main container
	var main_container = toolbar_panel.get_node_or_null("MainContainer")
	if main_container:
		main_container.visible = is_expanded
	
	print("🧬 Blueprint Toolbar: %s" % ("Expanded" if is_expanded else "Collapsed"))

func _connect_to_cursor() -> void:
	"""Connect to cursor being for selection detection"""
	await get_tree().process_frame
	
	var main = get_tree().get_first_node_in_group("main")
	if not main:
		return
	
	# Find cursor being
	for child in main.get_children():
		if child.has_method("get") and child.get("being_type") == "cursor":
			if child.has_signal("being_inspected"):
				child.being_inspected.connect(_on_being_selected)
				print("🧬 Connected to cursor for being selection")
			break

func _on_being_selected(being: UniversalBeing) -> void:
	"""Handle being selection from cursor"""
	selected_being = being
	_update_being_info()
	
	# Auto-expand toolbar when being is selected
	if not is_expanded:
		_toggle_toolbar()

func _update_being_info() -> void:
	"""Update the being information display"""
	if not selected_being:
		being_info.text = "[i]No being selected[/i]"
		return
	
	var dna = selected_being.get_dna_profile()
	being_info.text = """[b]%s[/b]
Type: %s
Consciousness: Level %d
Components: %d
Generation: %d
Clone Count: %d
Evolution Ready: %.0f%%""" % [
		selected_being.being_name,
		selected_being.being_type,
		selected_being.consciousness_level,
		selected_being.components.size(),
		dna.generation,
		selected_being.clone_count,
		dna.evolution_potential.get("evolution_readiness", 0.0) * 100
	]

func _load_blueprint_library() -> void:
	"""Load saved blueprints from storage"""
	blueprint_list.clear()
	
	# Add default templates
	_add_default_templates()
	
	# Load saved templates from file
	var template_dir = "user://dna_templates/"
	var dir = DirAccess.open(template_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".dna"):
				var template_path = template_dir + file_name
				var dna = UniversalBeingDNA.load_from_file(template_path)
				if dna:
					var template_name = file_name.replace(".dna", "")
					blueprint_library[template_name] = dna
					blueprint_list.add_item("💾 " + template_name)
			file_name = dir.get_next()
	
	print("🧬 Loaded %d blueprints into library" % blueprint_library.size())

func _add_default_templates() -> void:
	"""Add default blueprint templates"""
	# Basic Being Template
	var basic_template = UniversalBeingDNA.new()
	basic_template.being_name = "Basic Template"
	basic_template.being_type = "template_basic"
	basic_template.consciousness_level = 1
	basic_template.species = "universal_being"
	blueprint_library["Basic Being"] = basic_template
	blueprint_list.add_item("📋 Basic Being")
	
	# Advanced Being Template
	var advanced_template = UniversalBeingDNA.new()
	advanced_template.being_name = "Advanced Template"
	advanced_template.being_type = "template_advanced"
	advanced_template.consciousness_level = 4
	advanced_template.species = "universal_being"
	advanced_template.can_create = ["offspring", "tools"]
	blueprint_library["Advanced Being"] = advanced_template
	blueprint_list.add_item("📋 Advanced Being")
	
	# Creator Template
	var creator_template = UniversalBeingDNA.new()
	creator_template.being_name = "Creator Template"
	creator_template.being_type = "template_creator"
	creator_template.consciousness_level = 6
	creator_template.species = "universal_being"
	creator_template.can_create = ["offspring", "tools", "universes"]
	blueprint_library["Creator Being"] = creator_template
	blueprint_list.add_item("📋 Creator Being")

func _on_blueprint_selected(index: int) -> void:
	"""Handle blueprint selection from list"""
	var item_text = blueprint_list.get_item_text(index)
	var template_name = item_text.substr(2)  # Remove icon
	
	if template_name in blueprint_library:
		var dna = blueprint_library[template_name]
		blueprint_selected.emit(dna)
		print("🧬 Blueprint selected: %s" % template_name)
		
		# Show DNA summary
		_show_dna_summary(dna)

func _show_dna_summary(dna: UniversalBeingDNA) -> void:
	"""Display DNA summary in info panel"""
	being_info.text = """[b]Template: %s[/b]
Type: %s
Consciousness: Level %d
Generation: %d
Total Traits: %d

[i]%s[/i]""" % [
		dna.being_name,
		dna.being_type,
		dna.consciousness_level,
		dna.generation,
		dna.get_total_trait_count(),
		"Select a being to apply this template"
	]

func _save_current_template() -> void:
	"""Save current being as template"""
	if not selected_being:
		print("🧬 No being selected to save as template")
		return
	
	var template_name = template_name_input.text.strip_edges()
	if template_name.is_empty():
		template_name = "%s_Template" % selected_being.being_name
	
	# Get DNA profile
	var dna = selected_being.get_dna_profile()
	
	# Save to library
	blueprint_library[template_name] = dna
	blueprint_list.add_item("💾 " + template_name)
	
	# Save to file
	var template_dir = "user://dna_templates/"
	DirAccess.make_dir_recursive_absolute(template_dir)
	var file_path = template_dir + template_name + ".dna"
	dna.save_to_file(file_path)
	
	# Add to recent
	_add_to_recent(template_name)
	
	template_saved.emit(template_name, dna)
	print("🧬 Template saved: %s" % template_name)
	
	# Clear input
	template_name_input.text = ""

func _add_to_recent(template_name: String) -> void:
	"""Add template to recent list"""
	if template_name in recent_blueprints:
		recent_blueprints.erase(template_name)
	
	recent_blueprints.push_front(template_name)
	
	if recent_blueprints.size() > max_recent:
		recent_blueprints.pop_back()

func _request_clone() -> void:
	"""Request clone creation"""
	if not selected_being:
		print("🧬 No being selected for cloning")
		return
	
	# Show modification panel
	modification_panel.visible = true
	
	# Get modifications
	var modifications = _get_current_modifications()
	
	# Create clone
	var clone = selected_being.clone_being(modifications)
	if clone:
		# Add to scene
		selected_being.get_parent().add_child(clone)
		
		# Position near original
		clone.position = selected_being.position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		
		clone_requested.emit(selected_being, modifications)
		print("🧬 Clone created: %s" % clone.being_name)

func _request_evolution() -> void:
	"""Request evolution from selected template"""
	if not selected_being:
		print("🧬 No being selected for evolution")
		return
	
	# Get selected template
	var selected_items = blueprint_list.get_selected_items()
	if selected_items.is_empty():
		print("🧬 No template selected for evolution")
		return
	
	var item_text = blueprint_list.get_item_text(selected_items[0])
	var template_name = item_text.substr(2)
	
	if template_name not in blueprint_library:
		return
	
	var template_dna = blueprint_library[template_name]
	
	# Get mutation rate
	var mutation_slider = modification_panel.get_node("MutationSlider")
	var mutation_rate = mutation_slider.value if mutation_slider else 0.1
	
	# Create template being from DNA
	var template_being = UniversalBeing.new()
	template_being.being_name = template_dna.being_name
	template_being.being_type = template_dna.being_type
	template_being.consciousness_level = template_dna.consciousness_level
	template_being.components = template_dna.component_list.duplicate()
	
	# Attempt evolution
	if selected_being.evolve_from_template(template_being, mutation_rate):
		evolution_requested.emit(selected_being, template_dna)
		print("🧬 Evolution successful!")
	else:
		print("🧬 Evolution failed")
	
	# Clean up template being
	template_being.queue_free()

func _analyze_current_being() -> void:
	"""Analyze current being's DNA"""
	if not selected_being:
		print("🧬 No being selected for analysis")
		return
	
	var dna = selected_being.analyze_dna()
	print("🧬 DNA Analysis:\n%s" % dna.get_summary())
	
	# Update info display
	_update_being_info()

func _get_current_modifications() -> Dictionary:
	"""Get current modification settings"""
	var mods = {}
	
	# Consciousness modification
	var consciousness_slider = modification_panel.get_node_or_null("ConsciousnessSlider")
	if consciousness_slider and consciousness_slider.value != 0:
		var new_level = selected_being.consciousness_level + int(consciousness_slider.value)
		mods["consciousness_level"] = clamp(new_level, 0, 7)
	
	return mods

func set_selected_being(being: UniversalBeing) -> void:
	"""Manually set the selected being"""
	selected_being = being
	_update_being_info()
	
	if not is_expanded:
		_toggle_toolbar()

func get_blueprint_count() -> int:
	"""Get number of blueprints in library"""
	return blueprint_library.size()

func get_selected_blueprint() -> UniversalBeingDNA:
	"""Get currently selected blueprint"""
	var selected_items = blueprint_list.get_selected_items()
	if selected_items.is_empty():
		return null
	
	var item_text = blueprint_list.get_item_text(selected_items[0])
	var template_name = item_text.substr(2)
	
	return blueprint_library.get(template_name, null)
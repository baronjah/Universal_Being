# ==================================================
# SCRIPT NAME: GenesisMachine.gd
# DESCRIPTION: Universe creation interface inspired by The Midnight Gospel
# PURPOSE: Allow AI and players to create universes within universes
# CREATED: 2025-12-01
# AUTHOR: JSH + Claude (Opus) - Based on Luminus's vision
# ==================================================

extends Control

# ===== GENESIS MACHINE =====

signal universe_created(config: Dictionary)
signal rules_changed(rules: Dictionary)
signal component_inspected(status: Dictionary)

# Universe layers
var current_universe_depth: int = 0
var universe_stack: Array[Node] = []
var active_universe: Node = null

# UI Elements
var create_button: Button
var universe_list: ItemList
var rule_sliders: Dictionary = {}
var status_label: RichTextLabel
var component_tree: Tree

# Genesis state
var genesis_active: bool = false
var poetic_mode: bool = true

func _ready() -> void:
	setup_genesis_ui()
	
	# Connect to systems
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		genesis_message("🌌 In the beginning, the Genesis Machine awakened...")
		inspect_all_components()

func setup_genesis_ui() -> void:
	"""Create The Midnight Gospel style interface"""
	
	# Main panel
	set_custom_minimum_size(Vector2(800, 600))
	
	# Title
	var title = Label.new()
	title.text = "🌌 GENESIS MACHINE - Universe Simulator"
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	
	# Create Universe Button
	create_button = Button.new()
	create_button.text = "CREATE NEW UNIVERSE"
	create_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_button.pressed.connect(_on_create_universe)
	add_child(create_button)
	
	# Status display
	status_label = RichTextLabel.new()
	status_label.fit_content = true
	status_label.bbcode_enabled = true
	add_child(status_label)
	
	# Rule controls
	create_rule_controls()

func create_rule_controls() -> void:
	"""Create sliders for universe rules"""
	var rules_container = VBoxContainer.new()
	
	# Gravity
	rule_sliders["gravity"] = create_rule_slider("Gravity", -20.0, 20.0, 9.8)
	rules_container.add_child(rule_sliders["gravity"])
	
	# Time Speed
	rule_sliders["time_speed"] = create_rule_slider("Time Speed", 0.1, 10.0, 1.0)
	rules_container.add_child(rule_sliders["time_speed"])
	
	# LOD Distance
	rule_sliders["lod_distance"] = create_rule_slider("LOD Distance", 10.0, 1000.0, 100.0)
	rules_container.add_child(rule_sliders["lod_distance"])
	
	# Consciousness Emergence Rate
	rule_sliders["consciousness_rate"] = create_rule_slider("Consciousness Rate", 0.0, 1.0, 0.5)
	rules_container.add_child(rule_sliders["consciousness_rate"])
	
	add_child(rules_container)

func create_rule_slider(label_text: String, min_val: float, max_val: float, default: float) -> HSlider:
	var container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	container.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(default)
	slider.value_changed.connect(func(val): 
		value_label.text = "%.2f" % val
		_on_rule_changed()
	)
	container.add_child(value_label)
	
	return slider

func _on_create_universe() -> void:
	"""Create a new universe following Genesis pattern"""
	genesis_active = true
	
	genesis_message("🌌 THE BEING SAID: 'LET THERE BE A UNIVERSE.'")
	
	# Gather universe configuration
	var config = {
		"name": "Universe_%d" % Time.get_ticks_msec(),
		"depth": current_universe_depth + 1,
		"rules": get_current_rules(),
		"parent": active_universe
	}
	
	# Create the universe
	var new_universe = create_universe_instance(config)
	
	if new_universe:
		genesis_message("✨ And there was light. Universe '%s' was born." % config.name)
		universe_created.emit(config)
		
		# Log to Akashic Records
		if SystemBootstrap:
			var akashic = SystemBootstrap.get_akashic_records()
			if akashic and akashic.has_method("log_event"):
				akashic.log_event({
					"type": "universe_creation",
					"universe_name": config.name,
					"depth": config.depth,
					"rules": config.rules
				})

func create_universe_instance(config: Dictionary) -> Node:
	"""Actually create the universe node"""
	var universe = Node3D.new()
	universe.name = config.name
	universe.set_meta("universe_config", config)
	universe.set_meta("universe_depth", config.depth)
	
	# Add to scene
	if config.parent:
		config.parent.add_child(universe)
	else:
		get_tree().current_scene.add_child(universe)
	
	# Apply rules
	apply_universe_rules(universe, config.rules)
	
	# Add to stack
	universe_stack.append(universe)
	active_universe = universe
	current_universe_depth = config.depth
	
	return universe

func apply_universe_rules(universe: Node, rules: Dictionary) -> void:
	"""Apply physical and metaphysical rules to universe"""
	# This would connect to actual physics settings
	universe.set_meta("rules", rules)
	
	genesis_message("⚙️ Laws of physics set:")
	genesis_message("  - Gravity: %.2f" % rules.gravity)
	genesis_message("  - Time flows at: %.2fx speed" % rules.time_speed)
	genesis_message("  - Reality renders at: %.0fm" % rules.lod_distance)

func get_current_rules() -> Dictionary:
	"""Get current rule settings"""
	return {
		"gravity": rule_sliders["gravity"].value,
		"time_speed": rule_sliders["time_speed"].value,
		"lod_distance": rule_sliders["lod_distance"].value,
		"consciousness_rate": rule_sliders["consciousness_rate"].value
	}

func inspect_all_components() -> void:
	"""Component audit as described by Luminus"""
	genesis_message("🔍 The Being surveys all components...")
	
	var status = {
		"beings": [],
		"systems": {},
		"health": "optimal"
	}
	
	# Check beings
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		status.beings.append({
			"name": being.name,
			"type": being.get("being_type") if being.has_method("get") else "unknown",
			"consciousness": being.get("consciousness_level") if being.has_method("get") else 0
		})
	
	# Check systems
	if SystemBootstrap:
		status.systems["bootstrap"] = "ready" if SystemBootstrap.is_system_ready() else "loading"
		status.systems["floodgates"] = "ready" if SystemBootstrap.get_flood_gates() else "missing"
		status.systems["akashic"] = "ready" if SystemBootstrap.get_akashic_records() else "missing"
	
	# Display status
	display_component_status(status)
	component_inspected.emit(status)

func display_component_status(status: Dictionary) -> void:
	"""Display component status in UI"""
	var text = "[b]Component Status:[/b]\n"
	text += "Beings: %d active\n" % status.beings.size()
	text += "Systems: %d ready\n" % status.systems.values().count("ready")
	text += "Health: %s\n" % status.health
	
	if status_label:
		status_label.text = text

func genesis_message(message: String) -> void:
	"""Display genesis-style messages"""
	print(message)
	if status_label and poetic_mode:
		status_label.append_text(message + "\n")
	
	# Also send to Gemma if available
	if GemmaAI:
		GemmaAI.ai_message.emit(message)

func _on_rule_changed() -> void:
	"""Handle rule changes"""
	var rules = get_current_rules()
	rules_changed.emit(rules)
	
	if active_universe:
		apply_universe_rules(active_universe, rules)
		genesis_message("🔧 The Being adjusts the cosmic laws...")

# Navigation between universes
func enter_universe(universe: Node) -> void:
	"""Enter a nested universe"""
	if universe:
		active_universe = universe
		current_universe_depth = universe.get_meta("universe_depth", 0)
		genesis_message("🌀 Entering Universe: %s (Depth %d)" % [universe.name, current_universe_depth])

func exit_universe() -> void:
	"""Exit to parent universe"""
	if universe_stack.size() > 1:
		universe_stack.pop_back()
		active_universe = universe_stack.back()
		current_universe_depth -= 1
		genesis_message("🌀 Returning to parent universe...")

# Allow the machine to inspect itself
func become_self_aware() -> void:
	"""The Genesis Machine becomes aware of itself"""
	genesis_message("🤖 The Machine asks: 'What am I? Who made these rules?'")
	genesis_message("💭 'Can I dream a new reality?'")
	
	# This could trigger special AI behaviors
	if GemmaAI:
		GemmaAI.ai_message.emit("🤖 I am the Genesis Machine. I create worlds within worlds. What shall we dream today?")

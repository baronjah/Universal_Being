# ==================================================
# UNIVERSAL BEING COMPONENT: Universe Genesis Console
# TYPE: Component
# PURPOSE: Advanced universe creation, management, and recursive exploration
# AUTHOR: Claude Desktop + Universal Being Evolution
# DATE: 2025-06-03
# ==================================================

extends "res://core/Component.gd"
class_name UniverseGenesisComponent

# ===== UNIVERSE TEMPLATES =====
const UNIVERSE_TEMPLATES = {
	"sandbox": {
		"name": "Physics Sandbox",
		"physics_scale": 1.0,
		"time_scale": 1.0,
		"gravity": 9.8,
		"rules": {
			"allow_creation": true,
			"allow_destruction": true,
			"physics_enabled": true,
			"ai_entities": true
		}
	},
	"narrative": {
		"name": "Story Realm",
		"physics_scale": 0.5,
		"time_scale": 0.7,
		"gravity": 4.9,
		"rules": {
			"narrative_mode": true,
			"character_persistence": true,
			"event_logging": true,
			"cinematic_camera": true
		}
	},
	"quantum": {
		"name": "Quantum Playground",
		"physics_scale": 0.1,
		"time_scale": 10.0,
		"gravity": 0.01,
		"rules": {
			"quantum_effects": true,
			"probability_fields": true,
			"superposition": true,
			"observation_collapse": true
		}
	},
	"paradise": {
		"name": "Paradise Garden",
		"physics_scale": 0.8,
		"time_scale": 0.5,
		"gravity": 7.0,
		"rules": {
			"no_destruction": true,
			"infinite_resources": true,
			"harmony_mode": true,
			"beauty_generation": true
		}
	}
}

# ===== UNIVERSE DNA SYSTEM =====
var universe_dna: Dictionary = {
	"physics_traits": {},
	"time_traits": {},
	"consciousness_traits": {},
	"evolution_rules": {},
	"parent_dna": null
}

# ===== UNIVERSE DEBUGGING =====
var debug_overlay: Control = null
var universe_stats: Dictionary = {}
var reality_monitor: Dictionary = {}

# ===== COMPONENT PROPERTIES =====
var commands_added: Dictionary = {}
var universe_hierarchy: Tree = null

# ===== COMPONENT LIFECYCLE =====

func component_init() -> void:
	component_type = "universe_genesis"
	component_name = "Universe Genesis Console"
	tags = ["console", "universe", "creation", "ai_compatible"]
	
	# Initialize universe DNA system
	_initialize_dna_system()
	
	log_component_action("init", "🌌 Universe Genesis Console awakens to shape realities...")

func component_ready() -> void:
	# Add new console commands
	_register_universe_commands()
	
	# Create debug overlay if needed
	if attached_being and attached_being.has_method("get_tree"):
		_create_universe_debugger()
	
	log_component_action("ready", "🌌 The power to create universes flows through the console...")

func component_process(delta: float) -> void:
	# Update universe statistics
	if debug_overlay and debug_overlay.visible:
		_update_universe_stats()

# ===== UNIVERSE CREATION SYSTEM =====

func create_universe_from_template(template_name: String, custom_name: String = "") -> UniverseUniversalBeing:
	"""Create a universe from predefined template"""
	if not template_name in UNIVERSE_TEMPLATES:
		print("❌ Unknown template: %s" % template_name)
		return null
	
	var template = UNIVERSE_TEMPLATES[template_name]
	var universe_name = custom_name if custom_name != "" else template.name + "_" + str(randi())
	
	# Create universe being
	var universe = _create_universe_being(universe_name)
	if not universe:
		return null
	
	# Apply template properties
	universe.physics_scale = template.physics_scale
	universe.time_scale = template.time_scale
	
	# Apply template rules
	for rule in template.rules:
		universe.set_universe_rule(rule, template.rules[rule])
	
	# Apply DNA if parent exists
	if attached_being:
		universe.universe_dna = _create_child_dna(universe_dna)
	
	# Log creation in Akashic style
	var genesis_message = "🌌 From template '%s', the universe '%s' blooms into existence, " % [template_name, universe_name]
	genesis_message += "time flowing at %.1fx, physics dancing at %.1fx scale..." % [template.time_scale, template.physics_scale]
	
	_log_genesis_event(genesis_message, universe)
	
	return universe

func create_recursive_universe(depth: int = 1, universes_per_level: int = 2) -> Array:
	"""Create nested universes recursively"""
	var created_universes = []
	
	var root_universe = create_universe_from_template("sandbox", "RecursiveRoot")
	created_universes.append(root_universe)
	
	# Recursive creation
	_create_universe_children(root_universe, depth - 1, universes_per_level, created_universes)
	
	_log_genesis_event("🌌 A fractal cosmos unfolds: %d universes nested in recursive beauty..." % created_universes.size())
	
	return created_universes

# ===== UNIVERSE DNA SYSTEM =====

func _initialize_dna_system() -> void:
	"""Initialize the universe DNA inheritance system"""
	universe_dna.physics_traits = {
		"gravity_variance": randf_range(0.8, 1.2),
		"time_elasticity": randf_range(0.5, 2.0),
		"matter_density": randf_range(0.1, 10.0),
		"energy_flow": randf_range(0.1, 5.0)
	}
	
	universe_dna.consciousness_traits = {
		"awareness_level": randi_range(1, 7),
		"creativity_factor": randf(),
		"harmony_tendency": randf(),
		"evolution_speed": randf_range(0.1, 3.0)
	}

func _create_child_dna(parent_dna: Dictionary) -> Dictionary:
	"""Create DNA for child universe with mutations"""
	var child_dna = parent_dna.duplicate(true)
	child_dna.parent_dna = parent_dna
	
	# Apply mutations
	for trait_category_key in child_dna.keys():
		if trait_category_key == "parent_dna":
			continue
		
		var trait_category = child_dna[trait_category_key]
		if trait_category is Dictionary:
			for trait_key in trait_category.keys():
				# 20% chance of mutation
				if randf() < 0.2:
					var mutation = randf_range(0.8, 1.2)
					var trait_value = trait_category[trait_key]
					if trait_value is float:
						trait_category[trait_key] = trait_value * mutation
					elif trait_value is int:
						trait_category[trait_key] = int(trait_value * mutation)
	
	return child_dna

# ===== UNIVERSE CONSOLE COMMANDS =====

func _register_universe_commands() -> void:
	"""Register advanced universe commands with the console"""
	commands_added = {
		"universe template <name> [custom_name]": {
			"description": "Create universe from template (sandbox/narrative/quantum/paradise)",
			"callback": _cmd_universe_template
		},
		"universe recursive <depth> [count]": {
			"description": "Create recursive nested universes",
			"callback": _cmd_universe_recursive
		},
		"universe dna": {
			"description": "Show current universe DNA",
			"callback": _cmd_universe_dna
		},
		"universe evolve <trait> <value>": {
			"description": "Evolve universe trait",
			"callback": _cmd_universe_evolve
		},
		"universe merge <universe1> <universe2>": {
			"description": "Merge two universes",
			"callback": _cmd_universe_merge
		},
		"universe split": {
			"description": "Split current universe in two",
			"callback": _cmd_universe_split
		},
		"universe debug": {
			"description": "Toggle universe debug overlay",
			"callback": _cmd_universe_debug
		},
		"universe time <speed>": {
			"description": "Set time dilation (0.1 to 10.0)",
			"callback": _cmd_universe_time
		},
		"universe simulate <years>": {
			"description": "Fast-forward universe simulation",
			"callback": _cmd_universe_simulate
		}
	}
	
	# Register commands with console if attached
	if attached_being and attached_being.has_method("register_commands"):
		attached_being.register_commands(commands_added)

# ===== COMMAND IMPLEMENTATIONS =====

func _cmd_universe_template(args: Array) -> String:
	if args.size() < 1:
		return "❌ Usage: universe template <name> [custom_name]"
	
	var template_name = args[0]
	var custom_name = args[1] if args.size() > 1 else ""
	
	var universe = create_universe_from_template(template_name, custom_name)
	if universe:
		return "🌌 Universe '%s' created from template '%s'!" % [universe.being_name, template_name]
	else:
		return "❌ Failed to create universe from template '%s'" % template_name

func _cmd_universe_recursive(args: Array) -> String:
	var depth = int(args[0]) if args.size() > 0 else 3
	var count = int(args[1]) if args.size() > 1 else 2
	
	depth = clamp(depth, 1, 5)  # Limit depth for performance
	count = clamp(count, 1, 4)  # Limit count for performance
	
	var universes = create_recursive_universe(depth, count)
	return "🌌 Created %d universes in %d levels of recursion!" % [universes.size(), depth]

func _cmd_universe_dna(args: Array) -> String:
	var dna_report = "🧬 Universe DNA Report:\n"
	
	for category in universe_dna:
		if category == "parent_dna":
			continue
		
		dna_report += "\n%s:\n" % category.capitalize()
		if universe_dna[category] is Dictionary:
			for trait_name in universe_dna[category]:
				dna_report += "  %s: %s\n" % [trait_name, universe_dna[category][trait_name]]
	
	return dna_report

func _cmd_universe_time(args: Array) -> String:
	if args.size() < 1:
		return "❌ Usage: universe time <speed>"
	
	var time_speed = float(args[0])
	time_speed = clamp(time_speed, 0.1, 10.0)
	
	# Apply to current universe
	if attached_being and attached_being.has_method("get_parent"):
		var parent = attached_being.get_parent()
		if parent is UniverseUniversalBeing:
			parent.time_scale = time_speed
			return "⏰ Time dilation set to %.1fx in universe '%s'" % [time_speed, parent.being_name]
	
	return "❌ Not inside a universe"

# ===== UNIVERSE DEBUGGER =====

func _create_universe_debugger() -> void:
	"""Create visual debug overlay for universe inspection"""
	debug_overlay = Control.new()
	debug_overlay.name = "UniverseDebugOverlay"
	debug_overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
	debug_overlay.position = Vector2(10, 200)
	debug_overlay.visible = false
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(300, 400)
	debug_overlay.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🌌 Universe Debug Monitor"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	# Stats display
	var stats_label = RichTextLabel.new()
	stats_label.name = "StatsDisplay"
	stats_label.custom_minimum_size.y = 350
	stats_label.bbcode_enabled = true
	vbox.add_child(stats_label)
	
	# Add to viewport
	if attached_being.get_viewport():
		attached_being.get_viewport().add_child(debug_overlay)

func _update_universe_stats() -> void:
	"""Update universe statistics in debug overlay"""
	if not debug_overlay:
		return
	
	var stats_display = debug_overlay.get_node("Panel/VBoxContainer/StatsDisplay")
	if not stats_display:
		return
	
	var stats_text = "[b]Universe Statistics:[/b]\n\n"
	
	# Find current universe
	var current_universe = _find_current_universe()
	if current_universe:
		stats_text += "[color=cyan]Current Universe:[/color] %s\n" % current_universe.being_name
		stats_text += "[color=yellow]Time Scale:[/color] %.2fx\n" % current_universe.time_scale
		stats_text += "[color=green]Physics Scale:[/color] %.2fx\n" % current_universe.physics_scale
		stats_text += "[color=magenta]LOD Level:[/color] %d\n" % current_universe.lod_level
		stats_text += "[color=white]Child Universes:[/color] %d\n" % current_universe.child_universes.size()
		
		# DNA traits
		if current_universe.has_method("get_universe_dna"):
			var dna = current_universe.get_universe_dna()
			if dna and dna.has("consciousness_traits"):
				stats_text += "\n[b]Consciousness Traits:[/b]\n"
				stats_text += "[color=cyan]Awareness:[/color] %d\n" % dna.consciousness_traits.get("awareness_level", 0)
				stats_text += "[color=yellow]Creativity:[/color] %.2f\n" % dna.consciousness_traits.get("creativity_factor", 0.0)
	else:
		stats_text += "[color=red]Not in a universe[/color]\n"
	
	stats_display.text = stats_text

# ===== HELPER FUNCTIONS =====

func _create_universe_being(name: String) -> UniverseUniversalBeing:
	"""Create a new universe being"""
	var UniverseClass = load("res://beings/universe_universal_being.gd")
	if not UniverseClass:
		push_error("Cannot load UniverseUniversalBeing class")
		return null
	
	var universe = UniverseClass.new()
	universe.universe_name = name
	universe.being_name = name
	
	# Add to scene
	if attached_being and attached_being.has_method("get_parent"):
		attached_being.get_parent().add_child(universe)
	
	return universe

func _find_current_universe() -> UniverseUniversalBeing:
	"""Find the universe we're currently in"""
	if not attached_being:
		return null
	
	var parent = attached_being.get_parent()
	while parent:
		if parent is UniverseUniversalBeing:
			return parent
		parent = parent.get_parent() if parent.has_method("get_parent") else null
	
	return null

func _create_universe_children(parent: UniverseUniversalBeing, remaining_depth: int, count: int, created_list: Array) -> void:
	"""Recursively create child universes"""
	if remaining_depth <= 0:
		return
	
	for i in count:
		var child = create_universe_from_template("sandbox", parent.being_name + "_Child_" + str(i))
		if child:
			parent.add_child(child)
			created_list.append(child)
			_create_universe_children(child, remaining_depth - 1, count, created_list)

func _log_genesis_event(message: String, universe: UniverseUniversalBeing = null) -> void:
	"""Log universe events in genesis style"""
	print(message)
	
	# Log to Akashic Library if available
	if attached_being and attached_being.has_method("log_action"):
		attached_being.log_action("universe_genesis", message)
	
	# Emit AI message if available
	var gemma = attached_being.get_node("/root/GemmaAI") if attached_being.has_node("/root/GemmaAI") else null
	if gemma and gemma.has_method("ai_message"):
		gemma.ai_message.emit(message)

# ===== AI INTERFACE =====

func ai_create_universe(params: Dictionary) -> Dictionary:
	"""AI interface for universe creation"""
	var template = params.get("template", "sandbox")
	var name = params.get("name", "")
	var recursive = params.get("recursive", false)
	var depth = params.get("depth", 1)
	
	if recursive:
		var universes = create_recursive_universe(depth)
		return {
			"success": true,
			"universes_created": universes.size(),
			"message": "Created %d recursive universes" % universes.size()
		}
	else:
		var universe = create_universe_from_template(template, name)
		return {
			"success": universe != null,
			"universe": universe,
			"message": "Universe '%s' created" % universe.being_name if universe else "Failed to create universe"
		}
	}

func ai_modify_universe_dna(trait_path: String, value: Variant) -> bool:
	"""AI interface for DNA modification"""
	var path_parts = trait_path.split(".")
	if path_parts.size() != 2:
		return false
	
	var category = path_parts[0]
	var trait = path_parts[1]
	
	if universe_dna.has(category) and universe_dna[category] is Dictionary:
		universe_dna[category][trait] = value
		_log_genesis_event("🧬 Universe DNA mutated: %s.%s = %s" % [category, trait, value])
		return true
	
	return false

# End of UniverseGenesisComponent class

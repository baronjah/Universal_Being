# ==================================================
# UNIVERSAL BEING: Universe
# TYPE: UniverseManager
# PURPOSE: Creates and manages nested universes with customizable physics, time, and LOD
# COMPONENTS: universe_physics.ub.zip, universe_time.ub.zip, universe_lod.ub.zip
# SCENES: res://scenes/universe/universe_template.tscn
# ==================================================

extends UniversalBeing
class_name UniverseUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var universe_name: String = "New Universe"
@export var parent_universe: NodePath = NodePath()
@export var physics_scale: float = 1.0
@export var time_scale: float = 1.0
@export var lod_level: int = 1

# Universe state
var child_universes: Array[Node] = []  # Will contain UniverseUniversalBeing instances
var universe_parameters: Dictionary = {}
var is_observable: bool = true
var is_editable: bool = true
var creation_time: float = 0.0  # Time when universe was created

# Universe DNA System - Enhanced with full genetic traits
var universe_dna: Dictionary = {
	# Physics traits
	"gravity": 1.0,
	"friction": 1.0,
	"elasticity": 1.0,
	"matter_density": 1.0,
	# Time traits
	"time_flow": 1.0,
	"causality_strength": 1.0,
	"temporal_viscosity": 0.1,
	# Consciousness traits
	"awareness_coefficient": 1.0,
	"creativity_factor": 1.0,
	"harmony_resonance": 0.5,
	"evolution_rate": 1.0,
	# Entropy traits
	"chaos_level": 0.2,
	"order_tendency": 0.8,
	"emergence_probability": 0.5
}

var parent_dna: Dictionary = {}  # DNA inherited from parent universe

# Universe rules
var universe_rules: Dictionary = {
	"allow_creation": true,
	"allow_destruction": true,
	"physics_enabled": true,
	"ai_entities": true
}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "universe"
	being_name = universe_name
	consciousness_level = 3  # High consciousness for AI interaction
	
	# Add to universes group for easy finding
	add_to_group("universes")
	
	# Record creation time
	creation_time = Time.get_ticks_msec() / 1000.0
	
	# Initialize universe components
	add_component("res://components/universe_physics.ub.zip")
	add_component("res://components/universe_time.ub.zip")
	add_component("res://components/universe_lod.ub.zip")
	
	# Log universe creation in Akashic Library
	log_universe_creation()
	
	print("🌟 Universe '%s' initialized in the great void" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load universe scene template
	load_scene("res://scenes/universe/universe_template.tscn")
	
	# Connect to parent universe if exists
	if not parent_universe.is_empty():
		var parent = get_node(parent_universe)
		if parent is UniverseUniversalBeing:
			parent.register_child_universe(self)
	
	# Initialize universe parameters
	initialize_universe_parameters()
	
	print("🌟 Universe '%s' awakens, ready to contain infinite possibilities" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process universe time and physics
	if component_data.has("universe_time"):
		component_data.universe_time.process_time(delta * time_scale)
	
	if component_data.has("universe_physics"):
		component_data.universe_physics.process_physics(delta * physics_scale)
	
	# Update LOD based on observation
	if component_data.has("universe_lod"):
		component_data.universe_lod.update_lod(lod_level)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle universe-specific input
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_edit_mode()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			handle_universe_interaction(event.position)

func pentagon_sewers() -> void:
	# Clean up child universes
	for child in child_universes:
		child.queue_free()
	
	# Log universe destruction
	log_universe_destruction()
	
	super.pentagon_sewers()
	print("🌟 Universe '%s' returns to the void" % being_name)

# ===== UNIVERSE MANAGEMENT METHODS =====

func create_child_universe(params: Dictionary = {}) -> UniverseUniversalBeing:
	"""Creates a new universe within this one"""
	var child = UniverseUniversalBeing.new()
	child.universe_name = params.get("name", "Child Universe")
	child.parent_universe = get_path()
	child.physics_scale = params.get("physics_scale", physics_scale)
	child.time_scale = params.get("time_scale", time_scale)
	child.lod_level = params.get("lod_level", lod_level + 1)
	
	add_child(child)
	child_universes.append(child)
	
	log_universe_creation(child)
	return child

func register_child_universe(child: UniverseUniversalBeing) -> void:
	"""Registers a child universe with this one"""
	if not child_universes.has(child):
		child_universes.append(child)
		log_universe_registration(child)

func initialize_universe_parameters() -> void:
	"""Sets up initial universe parameters"""
	universe_parameters = {
		"gravity": Vector3(0, -9.8, 0) * physics_scale,
		"time_dilation": time_scale,
		"spatial_scale": 1.0,
		"particle_density": 1.0,
		"quantum_fluctuation": 0.1
	}

# ===== UNIVERSE INTERACTION METHODS =====

func toggle_edit_mode() -> void:
	"""Toggles universe editability"""
	is_editable = !is_editable
	log_universe_edit_toggle()

func handle_universe_interaction(position: Vector2) -> void:
	"""Handles interaction with universe contents"""
	if is_editable:
		# TODO: Implement universe content interaction
		pass

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Enhanced AI interface for universe management"""
	var base_interface = super.ai_interface()
	base_interface.universe_commands = [
		"create_child_universe",
		"modify_physics",
		"adjust_time",
		"change_lod",
		"observe_universe"
	]
	base_interface.universe_properties = {
		"physics_scale": physics_scale,
		"time_scale": time_scale,
		"lod_level": lod_level,
		"child_count": child_universes.size()
	}
	return base_interface

# ===== AKASHIC LIBRARY INTEGRATION =====

func log_universe_creation(child: UniverseUniversalBeing = null) -> void:
	"""Logs universe creation in poetic, genesis style"""
	var target = child if child else self
	var message = "🌟 In the great void, a new universe '%s' emerges, " % target.universe_name
	message += "birthing infinite possibilities and potentialities"
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event("creation", message, {
				"universe_name": target.universe_name,
				"parent": target.parent_universe.get_concatenated_names() if target.parent_universe else "void",
				"parameters": target.universe_parameters
			})

func log_universe_destruction() -> void:
	"""Logs universe destruction in poetic, genesis style"""
	var message = "💫 Universe '%s' completes its cosmic dance, " % being_name
	message += "returning its essence to the eternal void"
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event("destruction", message, {
				"universe_name": being_name,
				"child_count": child_universes.size(),
				"lifetime": get_lifetime()
			})

func log_universe_registration(child: UniverseUniversalBeing) -> void:
	"""Logs child universe registration"""
	var message = "🌌 Universe '%s' welcomes '%s' into its cosmic embrace" % [
		being_name, child.universe_name
	]
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event("registration", message, {
				"parent": being_name,
				"child": child.universe_name
			})

func log_universe_edit_toggle() -> void:
	"""Logs universe edit mode changes"""
	var state = "opens" if is_editable else "closes"
	var message = "🔧 The cosmic forge of universe '%s' %s to creation" % [
		being_name, state
	]
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event("edit_toggle", message, {
				"universe_name": being_name,
				"is_editable": is_editable
			})

# ===== UTILITY FUNCTIONS =====

func get_lifetime() -> float:
	"""Returns how long the universe has existed in seconds"""
	return (Time.get_ticks_msec() / 1000.0) - creation_time 

# ===== UNIVERSE DNA SYSTEM =====

func set_universe_dna(dna: Dictionary) -> void:
	"""Set the universe's DNA (usually from parent)"""
	universe_dna = dna
	# Apply DNA effects
	_apply_dna_effects()

func get_universe_dna() -> Dictionary:
	"""Get the complete DNA of this universe"""
	return universe_dna.duplicate()

func _apply_dna_effects() -> void:
	"""Apply DNA traits to universe properties"""
	if universe_dna.has("physics_traits"):
		var physics = universe_dna.physics_traits
		if physics.has("gravity_variance"):
			# Apply gravity to physics components
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_gravity(9.8 * physics.gravity_variance)
		
		if physics.has("time_elasticity"):
			time_scale *= physics.time_elasticity
	
	if universe_dna.has("consciousness_traits"):
		var consciousness = universe_dna.consciousness_traits
		if consciousness.has("awareness_level"):
			# Higher awareness = more conscious beings spawn
			consciousness_level = consciousness.awareness_level

# ===== UNIVERSE RULES SYSTEM =====

func set_universe_rule(rule: String, value: Variant) -> void:
	"""Set a universe rule"""
	universe_rules[rule] = value
	_apply_rule(rule, value)
	
	# Log rule change
	var message = "⚡ Universe '%s' law changed: %s = %s" % [universe_name, rule, value]
	print(message)
	log_action("rule_change", message)

func get_universe_rule(rule: String) -> Variant:
	"""Get a universe rule value"""
	return universe_rules.get(rule, null)

func _apply_rule(rule: String, value: Variant) -> void:
	"""Apply a rule change to the universe"""
	match rule:
		"allow_creation":
			# Enable/disable being creation
			set_meta("allow_creation", value)
		"allow_destruction":
			# Enable/disable being destruction
			set_meta("allow_destruction", value)
		"physics_enabled":
			# Enable/disable physics
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_enabled(value)
		"ai_entities":
			# Enable/disable AI beings
			set_meta("ai_entities", value)
		"gravity":
			# Set gravity value
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_gravity(float(value))

# ===== DNA SYSTEM METHODS =====

func set_universe_trait(trait_name: String, value: float) -> void:
	"""Set a specific DNA trait value"""
	if trait_name in universe_dna:
		universe_dna[trait_name] = value
		_apply_dna_trait(trait_name, value)
		
		# Log DNA modification
		var message = "🧬 Universe '%s' DNA modified: %s = %.2f" % [universe_name, trait_name, value]
		print(message)
		log_action("dna_modification", message)

func get_parent_universe() -> Node:
	"""Get the parent universe if exists"""
	if not parent_universe.is_empty():
		return get_node(parent_universe)
	return null

func inherit_dna_from_parent(parent: UniverseUniversalBeing, mutation_rate: float = 0.2) -> void:
	"""Inherit DNA from parent universe with mutations"""
	if not parent:
		return
	
	parent_dna = parent.get_universe_dna()
	
	# Copy parent DNA with mutations
	for trait_name in parent_dna:
		var parent_value = parent_dna[trait_name]
		
		# Apply mutation if random chance succeeds
		if randf() < mutation_rate:
			var mutation_strength = randf_range(-0.3, 0.3)
			universe_dna[trait_name] = clamp(
				parent_value + (parent_value * mutation_strength),
				0.0, 10.0  # General bounds, specific traits may override
			)
		else:
			universe_dna[trait_name] = parent_value
	
	# Apply all DNA traits
	for trait_name in universe_dna:
		_apply_dna_trait(trait_name, universe_dna[trait_name])

func _apply_dna_trait(trait_name: String, value: float) -> void:
	"""Apply a DNA trait to universe systems"""
	match trait_name:
		# Physics traits
		"gravity":
			physics_scale = value
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_gravity(value)
		"friction":
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_friction(value)
		"elasticity":
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_elasticity(value)
		"matter_density":
			if component_data.has("universe_physics"):
				component_data.universe_physics.set_matter_density(value)
		
		# Time traits
		"time_flow":
			time_scale = value
			if component_data.has("universe_time"):
				component_data.universe_time.set_time_scale(value)
		"causality_strength":
			if component_data.has("universe_time"):
				component_data.universe_time.set_causality_strength(value)
		"temporal_viscosity":
			if component_data.has("universe_time"):
				component_data.universe_time.set_temporal_viscosity(value)
		
		# Consciousness traits
		"awareness_coefficient":
			set_meta("awareness_coefficient", value)
		"creativity_factor":
			set_meta("creativity_factor", value)
		"harmony_resonance":
			set_meta("harmony_resonance", value)
		"evolution_rate":
			set_meta("evolution_rate", value)
		
		# Entropy traits
		"chaos_level":
			set_meta("chaos_level", value)
		"order_tendency":
			set_meta("order_tendency", value)
		"emergence_probability":
			set_meta("emergence_probability", value)

func get_dna_difference(other_dna: Dictionary) -> Dictionary:
	"""Calculate the difference between this universe's DNA and another"""
	var differences = {}
	for trait_name in universe_dna:
		if trait_name in other_dna:
			var diff = universe_dna[trait_name] - other_dna[trait_name]
			if abs(diff) > 0.01:  # Significant difference threshold
				differences[trait_name] = {
					"current": universe_dna[trait_name],
					"other": other_dna[trait_name],
					"difference": diff
				}
	return differences

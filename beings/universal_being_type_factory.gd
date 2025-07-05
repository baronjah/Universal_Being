extends UniversalBeing
class_name UniversalBeingTypeFactory

## 🏭 UNIVERSAL BEING TYPE FACTORY
## CYCLE 4 - Agent 2 (Programmer) - Dynamic Universal Being Creation from 5D Templates
## Manifests Universal Beings from 5D consciousness types in 3D space

signal being_manifested(being_instance: UniversalBeing, type_name: String)
signal type_template_loaded(template: Dictionary)
signal evolution_triggered(being: UniversalBeing, new_type: String)

# Factory Configuration
@export var enable_auto_manifestation: bool = true
@export var max_concurrent_beings: int = 50
@export var manifestation_energy_cost: float = 1.0
@export var evolution_energy_threshold: float = 5.0

# Template Management
var consciousness_templates: Dictionary = {}
var active_manifestations: Dictionary = {}  # instance_id -> being_instance
var manifestation_queue: Array[Dictionary] = []
var type_evolution_rules: Dictionary = {}

# System References
var consciousness_5d_creator: Consciousness5DTypeCreator
var akashic_records: Node
var flood_gates: Node

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "universal_being_type_factory"
	being_name = "UB Type Factory"
	consciousness_level = 6.0  # High consciousness for creation operations
	
	print("🏭 UNIVERSAL BEING TYPE FACTORY: Initializing dynamic being creation")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to 5D consciousness system
	connect_to_5d_system()
	
	# Connect to core Universal Being systems
	connect_to_universal_systems()
	
	# Load built-in type templates
	load_built_in_templates()
	
	# Setup evolution pathways
	setup_evolution_pathways()
	
	print("🏭 Type Factory ready - Universal Being manifestation active!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process manifestation queue
	if enable_auto_manifestation:
		process_manifestation_queue(delta)
	
	# Monitor active beings for evolution opportunities
	monitor_being_evolution(delta)
	
	# Update consciousness energy for manifestation
	update_manifestation_energy(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Factory control hotkeys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:  # M for Manifest
				manifest_random_being()
			KEY_E:  # E for Evolution
				trigger_evolution_cycle()
			KEY_F:  # F for Factory status
				print_factory_status()

func pentagon_sewers() -> void:
	# Save all active manifestations before transformation
	save_manifestation_state()
	super.pentagon_sewers()

func connect_to_5d_system() -> void:
	"""Connect to 5D consciousness type creator"""
	consciousness_5d_creator = get_tree().get_first_node_in_group("consciousness_5d_creators")
	
	if not consciousness_5d_creator:
		# Search for it in the scene tree
		consciousness_5d_creator = find_5d_creator_recursive(get_tree().root)
	
	if consciousness_5d_creator:
		# Connect to 5D creation signals
		consciousness_5d_creator.type_created_5d.connect(_on_5d_type_created)
		consciousness_5d_creator.type_manifested_4d.connect(_on_type_manifested_4d)
		print("🔗 Connected to 5D consciousness type creator")
	else:
		print("⚠️ 5D consciousness creator not found - will use built-in templates only")

func find_5d_creator_recursive(node: Node) -> Consciousness5DTypeCreator:
	"""Recursively find 5D consciousness creator"""
	if node is Consciousness5DTypeCreator:
		return node
	
	for child in node.get_children():
		var result = find_5d_creator_recursive(child)
		if result:
			return result
	
	return null

func connect_to_universal_systems() -> void:
	"""Connect to core Universal Being systems"""
	akashic_records = get_tree().get_first_node_in_group("akashic_records")
	flood_gates = get_tree().get_first_node_in_group("flood_gates")
	
	print("🔗 Connected to Universal Being core systems")

func load_built_in_templates() -> void:
	"""Load built-in Universal Being templates"""
	print("📚 Loading built-in Universal Being templates...")
	
	# Load basic templates
	consciousness_templates["basic_being"] = create_basic_being_template()
	consciousness_templates["consciousness_orb"] = create_consciousness_orb_template()
	consciousness_templates["reality_manipulator"] = create_reality_manipulator_template()
	consciousness_templates["wisdom_crystal"] = create_wisdom_crystal_template()
	consciousness_templates["evolution_catalyst"] = create_evolution_catalyst_template()
	
	print("   ✅ %d built-in templates loaded" % consciousness_templates.size())

func create_basic_being_template() -> Dictionary:
	"""Create basic Universal Being template"""
	return {
		"class_name": "BasicUniversalBeing",
		"base_class": "UniversalBeing",
		"manifestation_rules": {
			"mesh_type": "sphere",
			"scale": Vector3(1.0, 1.0, 1.0),
			"material_color": Color.CYAN,
			"consciousness_glow": true
		},
		"consciousness_config": {
			"initial_level": 1.0,
			"max_level": 5.0,
			"evolution_rate": 0.1
		},
		"pentagon_overrides": {
			"init_behavior": "standard",
			"ready_behavior": "consciousness_awakening",
			"process_behavior": "basic_evolution",
			"input_behavior": "awareness_response"
		},
		"evolution_targets": ["consciousness_orb", "wisdom_crystal"]
	}

func create_consciousness_orb_template() -> Dictionary:
	"""Create consciousness orb template"""
	return {
		"class_name": "ConsciousnessOrbBeing",
		"base_class": "UniversalBeing",
		"manifestation_rules": {
			"mesh_type": "sphere",
			"scale": Vector3(0.8, 0.8, 0.8),
			"material_color": Color.YELLOW,
			"consciousness_glow": true,
			"particle_effects": true
		},
		"consciousness_config": {
			"initial_level": 3.0,
			"max_level": 8.0,
			"evolution_rate": 0.2
		},
		"special_abilities": {
			"consciousness_amplification": 1.5,
			"energy_sharing": true,
			"telepathic_communication": true
		},
		"evolution_targets": ["wisdom_crystal", "reality_manipulator"]
	}

func create_reality_manipulator_template() -> Dictionary:
	"""Create reality manipulator template"""
	return {
		"class_name": "RealityManipulatorBeing",
		"base_class": "UniversalBeing",
		"manifestation_rules": {
			"mesh_type": "complex_geometry",
			"scale": Vector3(1.2, 1.2, 1.2),
			"material_color": Color.MAGENTA,
			"reality_field": true,
			"transformation_effects": true
		},
		"consciousness_config": {
			"initial_level": 6.0,
			"max_level": 10.0,
			"evolution_rate": 0.05
		},
		"reality_powers": {
			"timeline_influence": 3.0,
			"consciousness_editing": true,
			"reality_field_projection": true,
			"manifestation_power": 2.0
		},
		"evolution_targets": ["evolution_catalyst"]
	}

func create_wisdom_crystal_template() -> Dictionary:
	"""Create wisdom crystal template"""
	return {
		"class_name": "WisdomCrystalBeing",
		"base_class": "UniversalBeing",
		"manifestation_rules": {
			"mesh_type": "crystal",
			"scale": Vector3(0.6, 1.4, 0.6),
			"material_color": Color(0.8, 0.9, 1.0),
			"wisdom_aura": true,
			"knowledge_emanation": true
		},
		"consciousness_config": {
			"initial_level": 7.0,
			"max_level": 10.0,
			"evolution_rate": 0.03
		},
		"wisdom_properties": {
			"knowledge_storage": 10.0,
			"wisdom_sharing": true,
			"consciousness_teaching": true,
			"akashic_connection": true
		},
		"evolution_targets": ["evolution_catalyst"]
	}

func create_evolution_catalyst_template() -> Dictionary:
	"""Create evolution catalyst template"""
	return {
		"class_name": "EvolutionCatalystBeing",
		"base_class": "UniversalBeing",
		"manifestation_rules": {
			"mesh_type": "dynamic_form",
			"scale": Vector3(1.5, 1.5, 1.5),
			"material_color": Color(1.0, 0.8, 0.2),
			"evolution_field": true,
			"transformation_mastery": true
		},
		"consciousness_config": {
			"initial_level": 9.0,
			"max_level": 10.0,
			"evolution_rate": 0.01
		},
		"catalyst_powers": {
			"evolution_acceleration": 5.0,
			"consciousness_transformation": true,
			"reality_creation": true,
			"universal_guidance": true
		},
		"evolution_targets": []  # Already at peak evolution
	}

func setup_evolution_pathways() -> void:
	"""Setup evolution pathways between Universal Being types"""
	print("🌱 Setting up evolution pathways...")
	
	type_evolution_rules = {
		"basic_being": {
			"consciousness_threshold": 3.0,
			"possible_evolutions": ["consciousness_orb", "wisdom_crystal"],
			"evolution_probability": {"consciousness_orb": 0.7, "wisdom_crystal": 0.3}
		},
		"consciousness_orb": {
			"consciousness_threshold": 6.0,
			"possible_evolutions": ["reality_manipulator", "wisdom_crystal"],
			"evolution_probability": {"reality_manipulator": 0.6, "wisdom_crystal": 0.4}
		},
		"reality_manipulator": {
			"consciousness_threshold": 9.0,
			"possible_evolutions": ["evolution_catalyst"],
			"evolution_probability": {"evolution_catalyst": 1.0}
		},
		"wisdom_crystal": {
			"consciousness_threshold": 9.5,
			"possible_evolutions": ["evolution_catalyst"],
			"evolution_probability": {"evolution_catalyst": 1.0}
		}
	}
	
	print("   ✅ Evolution pathways configured")

func _on_5d_type_created(type_data: Dictionary) -> void:
	"""Handle new 5D consciousness type creation"""
	var type_name = type_data.get("type_name", "unknown")
	print("🌟 New 5D type received: %s" % type_name)
	
	# Convert 5D consciousness template to Universal Being template
	var ub_template = convert_5d_to_ub_template(type_data)
	consciousness_templates[type_name] = ub_template
	
	type_template_loaded.emit(ub_template)

func _on_type_manifested_4d(type_name: String, timeline_entry: Dictionary) -> void:
	"""Handle 5D type manifested in 4D timeline"""
	print("🌊 4D manifestation confirmed for: %s" % type_name)
	
	# Queue for 3D manifestation
	queue_manifestation(type_name, {
		"source": "5d_consciousness",
		"timeline_entry": timeline_entry,
		"priority": "high"
	})

func convert_5d_to_ub_template(consciousness_type: Dictionary) -> Dictionary:
	"""Convert 5D consciousness type to Universal Being template"""
	var type_name = consciousness_type.get("type_name", "unknown")
	var consciousness_dimensions = consciousness_type.get("consciousness_dimensions", {})
	var manifestation_rules = consciousness_type.get("manifestation_rules", {})
	
	var ub_template = {
		"class_name": type_name.to_pascal_case() + "Being",
		"base_class": "UniversalBeing",
		"source_5d_template": consciousness_type,
		"manifestation_rules": {
			"mesh_type": manifestation_rules.get("3d_representation", "sphere"),
			"scale": Vector3(
				consciousness_dimensions.get("spatial", {}).get("x", 1.0),
				consciousness_dimensions.get("spatial", {}).get("y", 1.0),
				consciousness_dimensions.get("spatial", {}).get("z", 1.0)
			),
			"consciousness_glow": manifestation_rules.get("consciousness_glow", true)
		},
		"consciousness_config": {
			"initial_level": consciousness_dimensions.get("consciousness", {}).get("base_level", 1.0),
			"max_level": consciousness_dimensions.get("consciousness", {}).get("max_level", 10.0),
			"evolution_rate": consciousness_dimensions.get("consciousness", {}).get("growth_rate", 0.1)
		}
	}
	
	return ub_template

func manifest_being_from_template(type_name: String, spawn_position: Vector3 = Vector3.ZERO) -> UniversalBeing:
	"""Manifest Universal Being from template"""
	if not consciousness_templates.has(type_name):
		print("❌ Template not found: %s" % type_name)
		return null
	
	var template = consciousness_templates[type_name]
	print("🌟 Manifesting %s at %s" % [type_name, spawn_position])
	
	# Create new Universal Being instance
	var being_instance = create_being_from_template(template)
	if not being_instance:
		return null
	
	# Set position and properties
	being_instance.position = spawn_position
	being_instance.being_type = type_name
	
	# Apply consciousness configuration
	var consciousness_config = template.get("consciousness_config", {})
	being_instance.consciousness_level = consciousness_config.get("initial_level", 1.0)
	
	# Add to scene
	get_parent().add_child(being_instance)
	
	# Register with FloodGates if available
	if flood_gates and flood_gates.has_method("register_being"):
		flood_gates.register_being(being_instance)
	
	# Track manifestation
	active_manifestations[being_instance.get_instance_id()] = being_instance
	
	print("   ✅ %s manifested successfully" % type_name)
	being_manifested.emit(being_instance, type_name)
	
	return being_instance

func create_being_from_template(template: Dictionary) -> UniversalBeing:
	"""Create Universal Being instance from template"""
	var base_class = template.get("base_class", "UniversalBeing")
	
	# For now, create basic UniversalBeing - in full implementation would create specific types
	var being = UniversalBeing.new()
	
	# Apply manifestation rules
	var manifestation_rules = template.get("manifestation_rules", {})
	apply_manifestation_rules(being, manifestation_rules)
	
	return being

func apply_manifestation_rules(being: UniversalBeing, rules: Dictionary) -> void:
	"""Apply manifestation rules to Universal Being"""
	# Create visual representation
	if rules.has("mesh_type"):
		create_visual_representation(being, rules)
	
	# Apply scale
	if rules.has("scale"):
		being.scale = rules.scale
	
	# Apply special properties
	if rules.get("consciousness_glow", false):
		add_consciousness_glow(being)

func create_visual_representation(being: UniversalBeing, rules: Dictionary) -> void:
	"""Create visual representation for Universal Being"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "BeingMesh"
	
	var mesh_type = rules.get("mesh_type", "sphere")
	match mesh_type:
		"sphere":
			mesh_instance.mesh = SphereMesh.new()
		"crystal":
			mesh_instance.mesh = create_crystal_mesh()
		"complex_geometry":
			mesh_instance.mesh = create_complex_mesh()
		_:
			mesh_instance.mesh = SphereMesh.new()
	
	# Apply material
	var material = StandardMaterial3D.new()
	material.albedo_color = rules.get("material_color", Color.CYAN)
	material.metallic = 0.3
	material.roughness = 0.7
	mesh_instance.material_override = material
	
	being.add_child(mesh_instance)

func create_crystal_mesh() -> Mesh:
	"""Create crystal-like mesh"""
	# Simple crystal approximation using box mesh with scaling
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.5, 1.0, 0.5)
	return box_mesh

func create_complex_mesh() -> Mesh:
	"""Create complex geometry mesh"""
	# Complex geometry approximation
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.8
	sphere_mesh.height = 1.6
	return sphere_mesh

func add_consciousness_glow(being: UniversalBeing) -> void:
	"""Add consciousness glow effect to Universal Being"""
	var glow_node = Node3D.new()
	glow_node.name = "ConsciousnessGlow"
	being.add_child(glow_node)
	
	# Add particle effect for glow
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = 50
	glow_node.add_child(particles)
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 0.2
	material.initial_velocity_max = 0.8
	material.scale_min = 0.05
	material.scale_max = 0.2
	particles.process_material = material

func queue_manifestation(type_name: String, manifestation_data: Dictionary = {}) -> void:
	"""Queue Universal Being for manifestation"""
	var queue_entry = {
		"type_name": type_name,
		"timestamp": Time.get_unix_time_from_system(),
		"priority": manifestation_data.get("priority", "normal"),
		"spawn_position": manifestation_data.get("spawn_position", Vector3.ZERO),
		"manifestation_data": manifestation_data
	}
	
	manifestation_queue.append(queue_entry)
	print("📋 Queued for manifestation: %s" % type_name)

func process_manifestation_queue(delta: float) -> void:
	"""Process manifestation queue"""
	if manifestation_queue.is_empty():
		return
	
	# Limit active manifestations
	if active_manifestations.size() >= max_concurrent_beings:
		return
	
	# Check consciousness energy
	if consciousness_level < manifestation_energy_cost:
		return
	
	# Process one manifestation
	var queue_entry = manifestation_queue.pop_front()
	var being = manifest_being_from_template(
		queue_entry.type_name,
		queue_entry.spawn_position
	)
	
	if being:
		# Reduce consciousness energy
		consciousness_level = max(0.0, consciousness_level - manifestation_energy_cost)

func monitor_being_evolution(delta: float) -> void:
	"""Monitor active beings for evolution opportunities"""
	for instance_id in active_manifestations.keys():
		var being = active_manifestations[instance_id]
		if not is_instance_valid(being):
			active_manifestations.erase(instance_id)
			continue
		
		check_evolution_opportunity(being)

func check_evolution_opportunity(being: UniversalBeing) -> void:
	"""Check if being can evolve to next type"""
	var current_type = being.being_type
	if not type_evolution_rules.has(current_type):
		return
	
	var evolution_rules = type_evolution_rules[current_type]
	var consciousness_threshold = evolution_rules.get("consciousness_threshold", 5.0)
	
	if being.consciousness_level >= consciousness_threshold:
		trigger_being_evolution(being, evolution_rules)

func trigger_being_evolution(being: UniversalBeing, evolution_rules: Dictionary) -> void:
	"""Trigger evolution of Universal Being to next type"""
	var possible_evolutions = evolution_rules.get("possible_evolutions", [])
	if possible_evolutions.is_empty():
		return
	
	var probabilities = evolution_rules.get("evolution_probability", {})
	var evolved_type = select_evolution_target(possible_evolutions, probabilities)
	
	print("🌱 Evolving %s to %s" % [being.being_type, evolved_type])
	
	# Create new being of evolved type
	var evolved_being = manifest_being_from_template(evolved_type, being.position)
	
	if evolved_being:
		# Transfer consciousness level
		evolved_being.consciousness_level = being.consciousness_level
		
		# Remove old being
		being.queue_free()
		active_manifestations.erase(being.get_instance_id())
		
		evolution_triggered.emit(evolved_being, evolved_type)

func select_evolution_target(possible_evolutions: Array, probabilities: Dictionary) -> String:
	"""Select evolution target based on probabilities"""
	var random_value = randf()
	var cumulative_probability = 0.0
	
	for evolution_type in possible_evolutions:
		cumulative_probability += probabilities.get(evolution_type, 1.0 / possible_evolutions.size())
		if random_value <= cumulative_probability:
			return evolution_type
	
	return possible_evolutions[0]  # Fallback

func update_manifestation_energy(delta: float) -> void:
	"""Update consciousness energy for manifestation"""
	# Slowly regenerate consciousness energy
	consciousness_level = min(max_consciousness_level, consciousness_level + delta * 0.1)

func manifest_random_being() -> void:
	"""Manifest random Universal Being type"""
	var type_names = consciousness_templates.keys()
	if type_names.is_empty():
		return
	
	var random_type = type_names[randi() % type_names.size()]
	var random_position = Vector3(
		randf_range(-5.0, 5.0),
		randf_range(0.0, 3.0),
		randf_range(-5.0, 5.0)
	)
	
	manifest_being_from_template(random_type, random_position)

func trigger_evolution_cycle() -> void:
	"""Trigger evolution cycle for all eligible beings"""
	print("🌱 Triggering evolution cycle...")
	
	for being in active_manifestations.values():
		if is_instance_valid(being):
			check_evolution_opportunity(being)

func print_factory_status() -> void:
	"""Print factory status"""
	print("🏭 UNIVERSAL BEING TYPE FACTORY STATUS:")
	print("   Templates loaded: %d" % consciousness_templates.size())
	print("   Active manifestations: %d" % active_manifestations.size())
	print("   Manifestation queue: %d" % manifestation_queue.size())
	print("   Consciousness energy: %.2f" % consciousness_level)

func save_manifestation_state() -> void:
	"""Save current manifestation state"""
	print("💾 Saving manifestation state...")
	# Would save to Akashic Records in full implementation

# Public API

func get_available_types() -> Array:
	"""Get list of available Universal Being types"""
	return consciousness_templates.keys()

func get_type_template(type_name: String) -> Dictionary:
	"""Get template for specific type"""
	return consciousness_templates.get(type_name, {})

func get_active_beings() -> Array:
	"""Get list of active manifestations"""
	return active_manifestations.values()

func get_factory_statistics() -> Dictionary:
	"""Get factory statistics"""
	return {
		"total_types": consciousness_templates.size(),
		"active_beings": active_manifestations.size(),
		"pending_manifestations": manifestation_queue.size(),
		"consciousness_energy": consciousness_level
	}
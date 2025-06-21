extends UniversalBeing
class_name GeometricSpellCrafting

## 🔮 GEOMETRIC SPELL CRAFTING SYSTEM
## Simple magic through points, lines, shapes, and consciousness
## Perfect interfaces for fantastic spell creation

# ===== SPELL COMPONENT TYPES =====

enum SpellComponent {
	# Basic Geometric Elements
	POINT,              # Singular point in space
	LINE,               # Connection between points
	SPHERE,             # Point that grows to sphere
	CYLINDER,           # Directional area of effect
	PLANE,              # Flat surface for barriers
	
	# Advanced Shapes
	CONE,               # Expanding area effect
	SPIRAL,             # Curved energy path
	TORUS,              # Ring of energy
	HELIX,              # Twisted energy flow
	
	# Consciousness Elements
	INTENTION,          # Purpose/reason for spell
	CONNECTION,         # Link between beings
	RESONANCE,          # Harmonic frequency
	EVOLUTION           # Growth/change pattern
}

enum SpellAction {
	# Energy Actions
	GROW,               # Point → Sphere expansion
	SHRINK,             # Sphere → Point collapse
	MOVE,               # Linear motion
	ROTATE,             # Rotational motion
	BEND,               # Curve/flex due to forces
	
	# Interaction Actions
	ATTRACT,            # Pull objects/beings
	REPEL,              # Push objects/beings
	CONNECT,            # Create connections
	TRANSFORM,          # Change properties
	RESONATE,           # Match frequencies
	
	# Consciousness Actions
	OBSERVE,            # Awareness expansion
	COMMUNICATE,        # Telepathic link
	INFLUENCE,          # Gentle persuasion
	HARMONIZE           # Create balance
}

# ===== SPELL STRUCTURE =====

class SpellElement:
	var component: SpellComponent
	var position: Vector3
	var size: float = 1.0
	var direction: Vector3 = Vector3.FORWARD
	var color: Color = Color.WHITE
	var intensity: float = 1.0
	var reason: String = ""  # Why this element exists
	var actions: Array[SpellAction] = []
	
	# Physics properties
	var velocity: Vector3 = Vector3.ZERO
	var gravity_affected: bool = false
	var bendable: bool = false
	var bend_factor: float = 0.0
	
	func _init(comp: SpellComponent, pos: Vector3, sz: float = 1.0):
		component = comp
		position = pos
		size = sz

# ===== SPELL SYSTEM =====

signal spell_crafted(spell_data: Dictionary)
signal spell_cast(spell_elements: Array)
signal element_modified(element: SpellElement, modification: String)
signal spell_interaction(caster: UniversalBeing, target: UniversalBeing, effect: String)

@export var spell_crafting_enabled: bool = true
@export var max_spell_elements: int = 20
@export var spell_range: float = 50.0
@export var consciousness_required: int = 2  # Minimum consciousness level for spells

# Current spell being crafted
var current_spell: Array[SpellElement] = []
var spell_preview_mode: bool = false
var selected_component: SpellComponent = SpellComponent.POINT

# Spell templates (simple examples)
var spell_templates: Dictionary = {}

# Visual representation nodes
var spell_visualizer: Node3D
var element_nodes: Array[Node3D] = []

# External forces affecting spells
var gravity_wells: Array[Vector3] = []
var telekinetic_forces: Array[Dictionary] = []  # {position, force, source_being}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "geometric_spell_crafter"
	being_name = "Spell Geometry Master"
	consciousness_level = 3  # Connected consciousness for magic
	
	_initialize_spell_templates()
	_setup_spell_visualizer()
	
	print("🔮 Geometric Spell Crafting: Simple magic through perfect geometry")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to consciousness systems
	_connect_to_spell_networks()
	
	# Setup external force monitoring
	_setup_force_monitoring()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update spell physics
	_update_spell_physics(delta)
	
	# Check for spell interactions
	_check_spell_interactions()
	
	# Update visual representation
	_update_spell_visualization()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if not spell_crafting_enabled:
		return
	
	# Spell crafting controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:  # Point spell
				selected_component = SpellComponent.POINT
				print("🔮 Selected: POINT spell component")
			KEY_2:  # Sphere spell
				selected_component = SpellComponent.SPHERE
				print("🔮 Selected: SPHERE spell component")
			KEY_3:  # Cylinder spell
				selected_component = SpellComponent.CYLINDER
				print("🔮 Selected: CYLINDER spell component")
			KEY_F:  # Cast current spell
				cast_current_spell()
			KEY_C:  # Clear current spell
				clear_current_spell()
			KEY_P:  # Toggle preview mode
				toggle_preview_mode()
			KEY_TAB:  # Cycle through components
				cycle_spell_component()

func pentagon_sewers() -> void:
	# Save spell templates and progress
	_save_spell_crafting_data()
	super.pentagon_sewers()

# ===== SPELL CRAFTING CORE =====

func create_spell_element(component: SpellComponent, world_position: Vector3, reason: String = "") -> SpellElement:
	"""Create a new spell element with geometric properties"""
	var element = SpellElement.new(component, world_position)
	element.reason = reason
	
	# Set component-specific properties
	match component:
		SpellComponent.POINT:
			element.size = 0.1
			element.actions = [SpellAction.GROW]
			element.color = Color.YELLOW
		
		SpellComponent.SPHERE:
			element.size = 2.0
			element.actions = [SpellAction.GROW, SpellAction.MOVE]
			element.color = Color.ORANGE
			element.gravity_affected = true
		
		SpellComponent.CYLINDER:
			element.size = 1.0
			element.direction = Vector3.FORWARD
			element.actions = [SpellAction.MOVE, SpellAction.BEND]
			element.color = Color.CYAN
			element.bendable = true
		
		SpellComponent.CONE:
			element.size = 3.0
			element.direction = Vector3.FORWARD
			element.actions = [SpellAction.GROW, SpellAction.MOVE]
			element.color = Color.MAGENTA
		
		SpellComponent.SPIRAL:
			element.actions = [SpellAction.ROTATE, SpellAction.MOVE]
			element.color = Color.GREEN
			element.bendable = true
	
	print("🔮 Created %s element at %s (reason: %s)" % [SpellComponent.keys()[component], world_position, reason])
	return element

func add_element_to_spell(element: SpellElement) -> void:
	"""Add element to current spell being crafted"""
	if current_spell.size() >= max_spell_elements:
		print("🔮 Warning: Maximum spell elements reached (%d)" % max_spell_elements)
		return
	
	current_spell.append(element)
	_create_visual_representation(element)
	
	element_modified.emit(element, "added")
	print("🔮 Added element to spell (%d/%d elements)" % [current_spell.size(), max_spell_elements])

func create_fireball_spell(target_position: Vector3) -> void:
	"""Example: Simple fireball spell using point→sphere→movement"""
	print("🔥 Crafting FIREBALL spell")
	
	# Step 1: Create point at caster position
	var origin_point = create_spell_element(SpellComponent.POINT, global_position, "fireball origin")
	add_element_to_spell(origin_point)
	
	# Step 2: Grow point to sphere
	var fireball_sphere = create_spell_element(SpellComponent.SPHERE, global_position, "fireball projectile")
	fireball_sphere.size = 1.5
	fireball_sphere.color = Color.RED
	fireball_sphere.velocity = (target_position - global_position).normalized() * 15.0
	fireball_sphere.actions = [SpellAction.GROW, SpellAction.MOVE]
	add_element_to_spell(fireball_sphere)
	
	# Step 3: Create directional cylinder for guidance
	var guidance_cylinder = create_spell_element(SpellComponent.CYLINDER, global_position, "trajectory guide")
	guidance_cylinder.direction = (target_position - global_position).normalized()
	guidance_cylinder.size = 0.5
	guidance_cylinder.color = Color(1, 0.5, 0, 0.3)  # Semi-transparent orange
	guidance_cylinder.bendable = true  # Can bend due to gravity/forces
	add_element_to_spell(guidance_cylinder)
	
	print("🔥 Fireball spell crafted: Point → Sphere → Guided trajectory")

func create_telekinesis_spell(target_object: Node3D) -> void:
	"""Example: Telekinesis using invisible connections"""
	print("🧠 Crafting TELEKINESIS spell")
	
	# Create connection line from caster to target
	var connection = create_spell_element(SpellComponent.LINE, global_position, "telekinetic connection")
	connection.direction = (target_object.global_position - global_position).normalized()
	connection.color = Color(0.5, 0, 1, 0.7)  # Semi-transparent purple
	connection.actions = [SpellAction.CONNECT, SpellAction.INFLUENCE]
	add_element_to_spell(connection)
	
	# Create force field around target
	var force_field = create_spell_element(SpellComponent.SPHERE, target_object.global_position, "telekinetic field")
	force_field.size = 2.0
	force_field.color = Color(0.3, 0.3, 1, 0.2)  # Very transparent blue
	force_field.actions = [SpellAction.ATTRACT, SpellAction.MOVE]
	add_element_to_spell(force_field)
	
	print("🧠 Telekinesis spell crafted: Connection → Force field")

func create_barrier_spell(barrier_position: Vector3, barrier_normal: Vector3) -> void:
	"""Example: Protective barrier using plane geometry"""
	print("🛡️ Crafting BARRIER spell")
	
	var barrier_plane = create_spell_element(SpellComponent.PLANE, barrier_position, "protective barrier")
	barrier_plane.direction = barrier_normal.normalized()
	barrier_plane.size = 5.0
	barrier_plane.color = Color(0, 1, 1, 0.4)  # Semi-transparent cyan
	barrier_plane.actions = [SpellAction.REPEL]
	add_element_to_spell(barrier_plane)
	
	print("🛡️ Barrier spell crafted: Protective plane")

# ===== SPELL PHYSICS & INTERACTIONS =====

func _update_spell_physics(delta: float) -> void:
	"""Update physics for all spell elements"""
	for element in current_spell:
		# Apply movement
		if SpellAction.MOVE in element.actions:
			element.position += element.velocity * delta
		
		# Apply gravity if affected
		if element.gravity_affected:
			for gravity_well in gravity_wells:
				var distance = element.position.distance_to(gravity_well)
				if distance < 20.0:  # Gravity range
					var gravity_force = (gravity_well - element.position).normalized() * (10.0 / (distance + 1.0))
					element.velocity += gravity_force * delta
		
		# Apply telekinetic forces
		for tk_force in telekinetic_forces:
			var distance = element.position.distance_to(tk_force.position)
			if distance < tk_force.get("range", 15.0):
				element.velocity += tk_force.force * delta
		
		# Apply bending to bendable elements
		if element.bendable and element.velocity.length() > 0.1:
			var bend_amount = element.bend_factor * delta
			element.direction = element.direction.lerp(element.velocity.normalized(), bend_amount)
		
		# Update size for growing/shrinking elements
		if SpellAction.GROW in element.actions:
			element.size += 2.0 * delta
		elif SpellAction.SHRINK in element.actions:
			element.size = max(0.1, element.size - 2.0 * delta)

func _check_spell_interactions() -> void:
	"""Check for spell interactions with beings and objects"""
	for element in current_spell:
		# Check collision with Universal Beings
		var nearby_beings = get_tree().get_nodes_in_group("universal_beings")
		for being in nearby_beings:
			if being == self:
				continue
			
			var distance = element.position.distance_to(being.global_position)
			if distance < element.size:
				_handle_spell_interaction(element, being)

func _handle_spell_interaction(element: SpellElement, target: UniversalBeing) -> void:
	"""Handle interaction between spell element and target"""
	var effect_description = ""
	
	match element.component:
		SpellComponent.SPHERE:
			if SpellAction.GROW in element.actions:
				effect_description = "energy sphere contact"
				# Apply energy effect to target
		SpellComponent.CYLINDER:
			effect_description = "directed energy beam"
		SpellComponent.LINE:
			if SpellAction.CONNECT in element.actions:
				effect_description = "consciousness connection"
				# Establish temporary telepathic link
	
	spell_interaction.emit(self, target, effect_description)
	print("🔮 Spell interaction: %s affected by %s" % [target.being_name, effect_description])

# ===== EXTERNAL FORCES =====

func add_gravity_well(position: Vector3) -> void:
	"""Add gravity well that affects spell trajectories"""
	gravity_wells.append(position)
	print("🌍 Gravity well added at %s" % position)

func add_telekinetic_force(position: Vector3, force: Vector3, source: Node3D, range: float = 15.0) -> void:
	"""Add telekinetic force from another being"""
	var tk_force = {
		"position": position,
		"force": force,
		"source_being": source,
		"range": range
	}
	telekinetic_forces.append(tk_force)
	var source_name = source.get("being_name") if source.has_method("get") else source.name
	print("🧠 Telekinetic force added: %s from %s" % [force, source_name])

func clear_external_forces() -> void:
	"""Clear all external forces"""
	gravity_wells.clear()
	telekinetic_forces.clear()
	print("🔮 External forces cleared")

# ===== SPELL CASTING =====

func cast_current_spell() -> void:
	"""Cast the currently crafted spell"""
	if current_spell.is_empty():
		print("🔮 No spell to cast")
		return
	
	if consciousness_level < consciousness_required:
		print("🔮 Insufficient consciousness level for casting (need %d, have %d)" % [consciousness_required, consciousness_level])
		return
	
	print("🔮 CASTING SPELL with %d elements!" % current_spell.size())
	
	# Create spell data for emission
	var spell_data = {
		"caster": self,
		"elements": current_spell.duplicate(),
		"cast_time": Time.get_time_string_from_system(),
		"consciousness_level": consciousness_level
	}
	
	spell_cast.emit(current_spell)
	spell_crafted.emit(spell_data)
	
	# Apply spell effects
	_apply_spell_effects()
	
	# Clear current spell after casting
	# clear_current_spell()

func _apply_spell_effects() -> void:
	"""Apply the effects of the cast spell"""
	for element in current_spell:
		match element.component:
			SpellComponent.SPHERE:
				if SpellAction.MOVE in element.actions:
					# Launch projectile sphere
					print("🔥 Launching spell projectile from %s" % element.position)
			SpellComponent.CYLINDER:
				if element.bendable:
					print("🔮 Flexible beam spell: Can bend with forces")
			SpellComponent.LINE:
				if SpellAction.CONNECT in element.actions:
					print("🧠 Establishing consciousness connection")

func clear_current_spell() -> void:
	"""Clear the current spell being crafted"""
	current_spell.clear()
	_clear_visual_representations()
	print("🔮 Current spell cleared")

func toggle_preview_mode() -> void:
	"""Toggle spell preview visualization"""
	spell_preview_mode = !spell_preview_mode
	print("🔮 Spell preview mode: %s" % ("ON" if spell_preview_mode else "OFF"))

func cycle_spell_component() -> void:
	"""Cycle through available spell components"""
	var components = [SpellComponent.POINT, SpellComponent.SPHERE, SpellComponent.CYLINDER, SpellComponent.CONE]
	var current_index = components.find(selected_component)
	var next_index = (current_index + 1) % components.size()
	selected_component = components[next_index]
	print("🔮 Selected component: %s" % SpellComponent.keys()[selected_component])

# ===== VISUAL REPRESENTATION =====

func _setup_spell_visualizer() -> void:
	"""Setup visual representation system"""
	spell_visualizer = Node3D.new()
	spell_visualizer.name = "SpellVisualizer"
	add_child(spell_visualizer)

func _create_visual_representation(element: SpellElement) -> void:
	"""Create visual representation of spell element"""
	var visual_node = Node3D.new()
	visual_node.name = "SpellElement_%s" % SpellComponent.keys()[element.component]
	visual_node.position = element.position
	
	var mesh_instance = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = element.color
	material.emission_enabled = true
	material.emission = element.color * 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	match element.component:
		SpellComponent.POINT:
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = 0.05
		SpellComponent.SPHERE:
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = element.size
		SpellComponent.CYLINDER:
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = element.size * 4
			mesh_instance.mesh.top_radius = element.size * 0.1
			mesh_instance.mesh.bottom_radius = element.size * 0.1
		SpellComponent.CONE:
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = element.size * 2
			mesh_instance.mesh.top_radius = 0.1
			mesh_instance.mesh.bottom_radius = element.size
	
	mesh_instance.material_override = material
	visual_node.add_child(mesh_instance)
	spell_visualizer.add_child(visual_node)
	element_nodes.append(visual_node)

func _update_spell_visualization() -> void:
	"""Update visual representations of spell elements"""
	for i in range(min(current_spell.size(), element_nodes.size())):
		var element = current_spell[i]
		var visual = element_nodes[i]
		visual.position = element.position
		visual.look_at(element.position + element.direction, Vector3.UP)

func _clear_visual_representations() -> void:
	"""Clear all visual representations"""
	for node in element_nodes:
		node.queue_free()
	element_nodes.clear()

# ===== SPELL TEMPLATES =====

func _initialize_spell_templates() -> void:
	"""Initialize common spell templates"""
	spell_templates = {
		"fireball": {
			"components": [SpellComponent.POINT, SpellComponent.SPHERE, SpellComponent.CYLINDER],
			"description": "Point grows to sphere, travels along cylinder path"
		},
		"telekinesis": {
			"components": [SpellComponent.LINE, SpellComponent.SPHERE],
			"description": "Connection line with force field sphere"
		},
		"barrier": {
			"components": [SpellComponent.PLANE],
			"description": "Protective plane that repels objects"
		},
		"healing_aura": {
			"components": [SpellComponent.POINT, SpellComponent.TORUS],
			"description": "Point expands to healing ring around target"
		}
	}
	
	print("🔮 Spell templates initialized: %d templates available" % spell_templates.size())

# ===== CONNECTION HELPERS =====

func _connect_to_spell_networks() -> void:
	"""Connect to other spell casters for collaborative magic"""
	var other_casters = get_tree().get_nodes_in_group("spell_casters")
	for caster in other_casters:
		if caster != self:
			print("🔮 Connected to spell network: %s" % caster.being_name)

func _setup_force_monitoring() -> void:
	"""Setup monitoring for external forces"""
	# Monitor for Universal Beings with telekinetic abilities
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_scan_for_external_forces)
	add_child(timer)
	timer.start()

func _scan_for_external_forces() -> void:
	"""Scan for external forces that could affect spells"""
	# Clear old forces
	telekinetic_forces.clear()
	
	# Scan for beings with telekinetic influence
	var nearby_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in nearby_beings:
		if being == self:
			continue
		
		var distance = global_position.distance_to(being.global_position)
		var consciousness_level = being.get("consciousness_level") if being.has_method("get") else 1
		if distance < 20.0 and consciousness_level != null and consciousness_level >= 3:
			# High consciousness beings can affect spells
			var tk_influence = (global_position - being.global_position).normalized() * 2.0
			add_telekinetic_force(being.global_position, tk_influence, being)

# ===== PERSISTENCE =====

func _save_spell_crafting_data() -> void:
	"""Save spell crafting progress"""
	var crafting_data = {
		"known_templates": spell_templates,
		"consciousness_level": consciousness_level,
		"spells_cast": get_meta("spells_cast", 0),
		"favorite_component": SpellComponent.keys()[selected_component]
	}
	
	print("🔮 Spell crafting data saved: %s" % crafting_data)

# ===== PUBLIC INTERFACE =====

func get_spell_crafting_status() -> Dictionary:
	"""Get current spell crafting status"""
	return {
		"current_spell_elements": current_spell.size(),
		"max_elements": max_spell_elements,
		"selected_component": SpellComponent.keys()[selected_component],
		"preview_mode": spell_preview_mode,
		"consciousness_level": consciousness_level,
		"external_forces": gravity_wells.size() + telekinetic_forces.size()
	}
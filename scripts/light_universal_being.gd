# ==================================================
# UNIVERSAL BEING: Light Source
# TYPE: environment
# PURPOSE: Even light sources are conscious beings
# FEATURES: Illumination control, mood setting, consciousness pulsing
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name LightUniversalBeing

# ===== LIGHT PROPERTIES =====
@export var light_type: String = "directional"  # directional, omni, spot
@export var base_energy: float = 1.0
@export var light_color: Color = Color.WHITE
@export var pulse_rate: float = 1.0
@export var cast_shadows: bool = true

# Light components
var light_node: Light3D
var aura_mesh: MeshInstance3D

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "light"
	being_name = "Illuminating Consciousness"
	consciousness_level = 2  # Light is aware
	
	# Light can evolve
	evolution_state.can_become = ["sun_being", "moon_being", "star_cluster", "aurora_consciousness"]
	
	print("💡 %s: Pentagon Init - Light awakens" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create the appropriate light type
	_create_light_source()
	
	# Add visual representation for interaction
	_create_light_body()
	
	print("💡 %s: Pentagon Ready - Illuminating the world" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Pulse with consciousness
	if light_node:
		var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_rate)
		light_node.light_energy = base_energy + (pulse * 0.2 * consciousness_level * 0.1)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	print("💡 %s: The light fades to darkness..." % being_name)
	super.pentagon_sewers()

# ===== LIGHT CREATION =====

func _create_light_source() -> void:
	"""Create the actual light node"""
	match light_type:
		"directional":
			light_node = DirectionalLight3D.new()
			light_node.rotation_degrees = Vector3(-45, -45, 0)
			being_name = "Sun Consciousness"
		"omni":
			light_node = OmniLight3D.new()
			(light_node as OmniLight3D).omni_range = 10.0
			being_name = "Orb of Illumination"
		"spot":
			light_node = SpotLight3D.new()
			(light_node as SpotLight3D).spot_range = 15.0
			being_name = "Focused Awareness"
	
	light_node.name = "LightSource"
	light_node.light_color = light_color
	light_node.light_energy = base_energy
	light_node.shadow_enabled = cast_shadows
	add_child(light_node)

func _create_light_body() -> void:
	"""Create a physical representation for interaction"""
	# Create a glowing sphere for omni/spot lights
	if light_type != "directional":
		aura_mesh = MeshInstance3D.new()
		aura_mesh.name = "LightBody"
		var sphere = SphereMesh.new()
		sphere.radius = 0.5
		sphere.height = 1.0
		aura_mesh.mesh = sphere
		
		# Glowing material
		var mat = StandardMaterial3D.new()
		mat.albedo_color = light_color
		mat.emission_enabled = true
		mat.emission = light_color
		mat.emission_energy = 2.0
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.5
		aura_mesh.material_override = mat
		
		add_child(aura_mesh)
		
		# Add collision for interaction
		var area = Area3D.new()
		area.name = "InteractionArea"
		var shape = CollisionShape3D.new()
		shape.shape = SphereShape3D.new()
		shape.shape.radius = 1.0
		area.add_child(shape)
		add_child(area)

# ===== LIGHT BEHAVIORS =====

func set_light_energy(energy: float) -> void:
	"""Set the light intensity"""
	base_energy = energy
	if light_node:
		light_node.light_energy = energy

func set_light_color(color: Color) -> void:
	"""Change the light color"""
	light_color = color
	if light_node:
		light_node.light_color = color
	if aura_mesh and aura_mesh.material_override:
		aura_mesh.material_override.albedo_color = color
		aura_mesh.material_override.emission = color

func toggle_shadows(enabled: bool) -> void:
	"""Toggle shadow casting"""
	cast_shadows = enabled
	if light_node:
		light_node.shadow_enabled = enabled

# ===== INTERACTION =====

func on_interaction(interactor: UniversalBeing) -> void:
	"""When someone interacts with the light"""
	print("💡 %s: 'I illuminate with consciousness level %d'" % [being_name, consciousness_level])
	
	# Pulse brightly as acknowledgment
	var tween = create_tween()
	tween.tween_property(light_node, "light_energy", base_energy * 2, 0.2)
	tween.tween_property(light_node, "light_energy", base_energy, 0.3)

func set_highlighted(highlighted: bool) -> void:
	"""Visual feedback when highlighted"""
	if aura_mesh and aura_mesh.material_override:
		aura_mesh.material_override.emission_energy = 4.0 if highlighted else 2.0
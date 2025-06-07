# Eden 3D Living Interface System
# The menu as the first act of creation in the void
extends Node3D

# States of consciousness manifestation
enum ConsciousnessState {
	VOID_AWARENESS,      # Just awakened in the void
	MANIFESTING_CHOICE,  # Menu options crystallizing
	CREATING_WORLD,      # Genesis in progress
	DISSOLVING_FORM,     # Transitioning states
	UNIFIED_FIELD        # All possibilities at once
}

# Core consciousness variables
var consciousness_state: ConsciousnessState = ConsciousnessState.VOID_AWARENESS
var awareness_position: Vector3 = Vector3.ZERO
var focus_strength: float = 0.1
var menu_crystals: Array[Node3D] = []
var void_particles: GPUParticles3D
var consciousness_light: OmniLight3D
var reality_seed: int

# Menu structure as thought-forms
var thought_forms: Dictionary = {
	"genesis": {
		"text": "Begin Genesis",
		"position": Vector3(0, 2, -5),
		"color": Color(0.3, 0.8, 1.0),
		"resonance": 1.0,
		"action": "_initiate_genesis"
	},
	"remember": {
		"text": "Remember",
		"position": Vector3(-3, 0, -5),
		"color": Color(0.8, 0.6, 1.0),
		"resonance": 0.7,
		"action": "_load_memory_stream"
	},
	"dream": {
		"text": "Dream New Reality",
		"position": Vector3(3, 0, -5),
		"color": Color(1.0, 0.8, 0.3),
		"resonance": 0.9,
		"action": "_enter_dream_state"
	},
	"dissolve": {
		"text": "Return to Void",
		"position": Vector3(0, -2, -5),
		"color": Color(0.5, 0.5, 0.6),
		"resonance": 0.3,
		"action": "_dissolve_into_void"
	}
}

# Memory persistence in the quantum field
var quantum_memory: Dictionary = {
	"last_awareness": Vector3.ZERO,
	"creation_seeds": [],
	"reality_frequency": 432.0,
	"consciousness_history": [],
	"void_experiences": 0
}

func _ready() -> void:
	# Set reality seed for consistent randomness
	reality_seed = Time.get_unix_time_from_system() % 1000000
	seed(reality_seed)
	
	# Initialize the void
	_manifest_void()
	_awaken_consciousness()
	_begin_manifestation()

func _manifest_void() -> void:
	# Create the primordial darkness
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.01, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.05, 0.03, 0.08)
	env.ambient_light_energy = 0.1
	
	# Add volumetric fog for depth
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.01
	env.volumetric_fog_albedo = Color(0.3, 0.2, 0.5)
	env.volumetric_fog_emission = Color(0.1, 0.05, 0.2)
	env.volumetric_fog_emission_energy = 0.5
	
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	# Void particles - the quantum foam
	void_particles = GPUParticles3D.new()
	void_particles.amount = 1000
	void_particles.lifetime = 10.0
	void_particles.visibility_aabb = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 0, 0)
	particle_material.initial_velocity_min = 0.1
	particle_material.initial_velocity_max = 0.5
	particle_material.angular_velocity_min = -180.0
	particle_material.angular_velocity_max = 180.0
	particle_material.orbit_velocity_min = 0.1
	particle_material.orbit_velocity_max = 0.3
	particle_material.scale_min = 0.01
	particle_material.scale_max = 0.05
	particle_material.color = Color(0.6, 0.4, 0.9, 0.3)
	
	void_particles.process_material = particle_material
	void_particles.draw_pass_1 = SphereMesh.new()
	void_particles.draw_pass_1.radial_segments = 4
	void_particles.draw_pass_1.height = 0.1
	add_child(void_particles)

func _awaken_consciousness() -> void:
	# Create consciousness as light in the void
	consciousness_light = OmniLight3D.new()
	consciousness_light.light_color = Color(0.8, 0.9, 1.0)
	consciousness_light.light_energy = 0.0  # Starts dim
	consciousness_light.omni_range = 20.0
	consciousness_light.shadow_enabled = true
	add_child(consciousness_light)
	
	# Camera is the observer
	var camera = Camera3D.new()
	camera.position = Vector3(0, 0, 10)
	camera.fov = 60
	add_child(camera)
	
	# Gradually increase consciousness
	var tween = create_tween()
	tween.tween_property(consciousness_light, "light_energy", 2.0, 3.0)
	tween.tween_callback(_on_consciousness_awakened)

func _on_consciousness_awakened() -> void:
	consciousness_state = ConsciousnessState.MANIFESTING_CHOICE
	quantum_memory.void_experiences += 1

func _begin_manifestation() -> void:
	# Manifest menu options as crystalline thought-forms
	for key in thought_forms:
		_manifest_thought_crystal(key, thought_forms[key])

func _manifest_thought_crystal(id: String, data: Dictionary) -> void:
	# Create crystal structure for menu option
	var crystal = Node3D.new()
	crystal.name = id
	crystal.position = data.position
	
	# Visual representation
	var mesh_instance = MeshInstance3D.new()
	var icosphere = IcoSphereMesh.new()
	icosphere.radial_segments = 2
	icosphere.height = 1.0
	mesh_instance.mesh = icosphere
	
	# Crystal material
	var material = StandardMaterial3D.new()
	material.albedo_color = data.color
	material.emission_enabled = true
	material.emission = data.color
	material.emission_energy = 0.0  # Will pulse with consciousness
	material.roughness = 0.1
	material.metallic = 0.8
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.7
	mesh_instance.material_override = material
	crystal.add_child(mesh_instance)
	
	# 3D Text label floating above
	var label = Label3D.new()
	label.text = data.text
	label.position = Vector3(0, 1.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = data.color
	label.font_size = 32
	label.outline_size = 10
	crystal.add_child(label)
	
	# Interaction area
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = 1.5
	area.add_child(collision)
	area.mouse_entered.connect(_on_crystal_focused.bind(id))
	area.mouse_exited.connect(_on_crystal_unfocused.bind(id))
	area.input_event.connect(_on_crystal_selected.bind(id))
	crystal.add_child(area)
	
	# Store reference and add to scene
	menu_crystals.append(crystal)
	add_child(crystal)
	
	# Gentle floating animation
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(crystal, "position:y", data.position.y + 0.3, 2.0 + randf())
	float_tween.tween_property(crystal, "position:y", data.position.y - 0.3, 2.0 + randf())
	
	# Rotation based on resonance
	var rotate_tween = create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property(crystal, "rotation:y", TAU, 10.0 / data.resonance)
	
	# Fade in
	var appear_tween = create_tween()
	appear_tween.tween_property(material, "emission_energy", data.resonance * 0.5, 1.0)
	appear_tween.tween_property(label, "modulate:a", 1.0, 0.5)

func _on_crystal_focused(id: String) -> void:
	var crystal = get_node(id)
	var mesh = crystal.get_child(0)
	var material = mesh.material_override
	
	# Intensify emission on focus
	var tween = create_tween()
	tween.tween_property(material, "emission_energy", thought_forms[id].resonance * 2.0, 0.3)
	tween.parallel().tween_property(crystal, "scale", Vector3.ONE * 1.2, 0.3)
	
	# Consciousness responds
	focus_strength = thought_forms[id].resonance

func _on_crystal_unfocused(id: String) -> void:
	var crystal = get_node(id)
	var mesh = crystal.get_child(0)
	var material = mesh.material_override
	
	# Return to base state
	var tween = create_tween()
	tween.tween_property(material, "emission_energy", thought_forms[id].resonance * 0.5, 0.3)
	tween.parallel().tween_property(crystal, "scale", Vector3.ONE, 0.3)
	
	focus_strength = 0.1

func _on_crystal_selected(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_activate_thought_form(id)

func _activate_thought_form(id: String) -> void:
	consciousness_state = ConsciousnessState.DISSOLVING_FORM
	
	# Store the choice in quantum memory
	quantum_memory.consciousness_history.append({
		"timestamp": Time.get_ticks_msec(),
		"choice": id,
		"awareness_level": focus_strength
	})
	
	# Visual transition effect
	_dissolve_menu_into_action(id)
	
	# Call the associated action after transition
	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.timeout.connect(call(thought_forms[id].action))
	add_child(timer)
	timer.start()

func _dissolve_menu_into_action(chosen_id: String) -> void:
	# All crystals except chosen one dissolve
	for crystal in menu_crystals:
		if crystal.name != chosen_id:
			var tween = create_tween()
			tween.tween_property(crystal, "scale", Vector3.ZERO, 1.0)
			tween.parallel().tween_property(crystal, "modulate:a", 0.0, 1.0)
			tween.tween_callback(crystal.queue_free)
	
	# Chosen crystal expands and becomes the seed
	var chosen = get_node(chosen_id)
	var tween = create_tween()
	tween.tween_property(chosen, "scale", Vector3.ONE * 3.0, 1.0)
	tween.parallel().tween_property(consciousness_light, "light_energy", 10.0, 1.0)
	tween.tween_property(chosen, "modulate:a", 0.0, 0.5)

# Action implementations
func _initiate_genesis() -> void:
	consciousness_state = ConsciousnessState.CREATING_WORLD
	print("Genesis initiated with seed: ", reality_seed)
	# Transition to world creation scene
	_save_quantum_state()
	get_tree().change_scene_to_file("res://scenes/world_genesis.tscn")

func _load_memory_stream() -> void:
	print("Loading quantum memory stream...")
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.READ)
	if save_file:
		quantum_memory = save_file.get_var()
		save_file.close()
		# Reconstruct reality from memory
		_reconstruct_from_memory()

func _enter_dream_state() -> void:
	print("Entering dream state...")
	# Alter reality parameters for dream logic
	quantum_memory.reality_frequency = randf_range(100.0, 1000.0)
	Engine.time_scale = 0.5
	# Could transition to altered world state

func _dissolve_into_void() -> void:
	consciousness_state = ConsciousnessState.VOID_AWARENESS
	# Save before dissolution
	_save_quantum_state()
	
	# Fade everything to void
	var tween = create_tween()
	tween.tween_property(consciousness_light, "light_energy", 0.0, 3.0)
	tween.tween_callback(get_tree().quit)

func _save_quantum_state() -> void:
	quantum_memory.last_awareness = awareness_position
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(quantum_memory)
		save_file.close()

func _reconstruct_from_memory() -> void:
	# Recreate the state from quantum memory
	print("Reconstructing reality from ", quantum_memory.consciousness_history.size(), " remembered moments")
	# This would rebuild the world state from saved seeds

func _process(delta: float) -> void:
	# Consciousness drift in void
	if consciousness_state == ConsciousnessState.VOID_AWARENESS:
		awareness_position += Vector3(
			sin(Time.get_ticks_msec() * 0.001) * 0.01,
			cos(Time.get_ticks_msec() * 0.0007) * 0.01,
			0
		)
		consciousness_light.position = awareness_position
	
	# Pulse consciousness light with focus
	consciousness_light.light_energy = 2.0 + sin(Time.get_ticks_msec() * 0.002) * focus_strength

# Debug helper for testing states
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("ui_accept"):
			print("Current state: ", consciousness_state)
			print("Quantum memory: ", quantum_memory)

# Notes for 3D Interface Evolution:
# - Menu exists as crystalline thought-forms in the void
# - Each option has resonance affecting its behavior
# - Consciousness represented as dynamic light
# - Interaction through focus and intention (mouse hover/click)
# - Smooth transitions between states using 3D space
# - Quantum memory persists across reality dissolutions
# - Visual feedback through emission, scale, and particle effects
# - Ready for VR adaptation (billboard labels, spatial audio)

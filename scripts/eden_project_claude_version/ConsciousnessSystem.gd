# ConsciousnessSystem.gd
extends UniversalBeing
class_name ConsciousnessSystem

# Consciousness events
signal awareness_expanded(level: int)
signal perception_unlocked(perception_type: String)
signal frequency_resonance(frequency: float, source: Node3D)
signal consciousness_merged(entity1: Node3D, entity2: Node3D)
signal enlightenment_achieved()
signal collective_consciousness_formed(entities: Array)
signal meditation_completed(insights: Dictionary)
signal consciousness_ripple_created(origin: Vector3, strength: float)

# Core consciousness properties
@export var awareness_level: int = 1
@export var max_awareness_level: int = 10
@export var current_frequency: float = 432.0  # Universal harmony frequency
@export var frequency_range: Vector2 = Vector2(100.0, 1000.0)
@export var perception_radius: float = 100.0
@export var consciousness_energy: float = 50.0
@export var max_consciousness_energy: float = 100.0

# Consciousness states
enum ConsciousnessState {
	DORMANT,       # No awareness
	AWAKENING,     # Beginning consciousness
	AWARE,         # Basic perception
	CONNECTED,     # Networked consciousness
	ENLIGHTENED,   # Higher understanding
	TRANSCENDENT   # Unity consciousness
}

var current_state: ConsciousnessState = ConsciousnessState.AWAKENING
var state_progress: float = 0.0

# Perception types
var unlocked_perceptions: Array[String] = ["physical"]
var available_perceptions: Dictionary = {
	"physical": {"level": 1, "description": "Basic material world perception"},
	"energy": {"level": 3, "description": "See energy fields and flows"},
	"emotional": {"level": 4, "description": "Sense emotional states"},
	"temporal": {"level": 5, "description": "Perceive time differently"},
	"quantum": {"level": 6, "description": "Observe quantum possibilities"},
	"akashic": {"level": 7, "description": "Access universal records"},
	"dimensional": {"level": 8, "description": "See across dimensions"},
	"universal": {"level": 10, "description": "Total cosmic awareness"}
}

# Active consciousness fields
var consciousness_fields: Array = []
var field_interactions: Dictionary = {}
var resonance_points: Array = []

# Meditation system
var meditation_active: bool = false
var meditation_depth: float = 0.0
var meditation_insights: Array = []
var meditation_timer: float = 0.0

# Collective consciousness
var connected_beings: Array = []
var collective_strength: float = 0.0
var shared_perceptions: Dictionary = {}

# Visual representation
var consciousness_visualizer: Node3D
var perception_sphere: Area3D
var frequency_particles: GPUParticles3D
var meditation_aura: MeshInstance3D

# Audio components
var frequency_generator: AudioStreamPlayer3D
var meditation_ambience: AudioStreamPlayer
var resonance_harmonics: Array[AudioStreamPlayer3D] = []

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "ConsciousnessSystem"
	consciousness_level = awareness_level
	_initialize_perception_system()
	_setup_frequency_generator()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_consciousness_visualizer()
	_setup_perception_sphere()
	_initialize_meditation_system()
	_connect_to_game_systems()
	begin_awareness_expansion()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_consciousness_state(delta)
	_process_perception_field(delta)
	_update_frequency_resonance(delta)
	_process_meditation(delta)
	_update_collective_consciousness(delta)
	_update_visual_effects(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event.is_action_pressed("meditate"):
		toggle_meditation()
	elif event.is_action_pressed("expand_consciousness"):
		expand_awareness_manually()
	elif event.is_action_pressed("tune_frequency_up"):
		adjust_frequency(10.0)
	elif event.is_action_pressed("tune_frequency_down"):
		adjust_frequency(-10.0)

func pentagon_sewers() -> void:
	_save_consciousness_state()
	_cleanup_connections()
	super.pentagon_sewers()

# Initialization
func _initialize_perception_system() -> void:
	# Set up base perception capabilities
	for perception in available_perceptions:
		var data = available_perceptions[perception]
		if awareness_level >= data["level"]:
			unlock_perception(perception)

func _setup_frequency_generator() -> void:
	frequency_generator = AudioStreamPlayer3D.new()
	frequency_generator.unit_size = 50.0
	frequency_generator.max_distance = 200.0
	frequency_generator.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	
	# Create audio stream generator for pure tones
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100
	audio_stream.buffer_length = 0.1
	frequency_generator.stream = audio_stream
	
	add_child(frequency_generator)
	frequency_generator.play()
	_generate_frequency_tone()

# Visual setup
func _create_consciousness_visualizer() -> void:
	consciousness_visualizer = Node3D.new()
	consciousness_visualizer.name = "ConsciousnessVisualizer"
	add_child(consciousness_visualizer)
	
	# Create frequency visualization particles
	frequency_particles = GPUParticles3D.new()
	frequency_particles.amount = 200
	frequency_particles.lifetime = 3.0
	frequency_particles.visibility_aabb = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
	
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 0, 0)
	particle_mat.initial_velocity_min = 1.0
	particle_mat.initial_velocity_max = 3.0
	particle_mat.angular_velocity_min = -180.0
	particle_mat.angular_velocity_max = 180.0
	particle_mat.spread = 180.0
	particle_mat.gravity = Vector3.ZERO
	particle_mat.radial_accel_min = -2.0
	particle_mat.radial_accel_max = 2.0
	particle_mat.scale_min = 0.05
	particle_mat.scale_max = 0.15
	particle_mat.color = _get_frequency_color()
	
	frequency_particles.process_material = particle_mat
	frequency_particles.draw_pass_1 = SphereMesh.new()
	frequency_particles.draw_pass_1.radius = 0.1
	
	consciousness_visualizer.add_child(frequency_particles)

func _setup_perception_sphere() -> void:
	perception_sphere = Area3D.new()
	perception_sphere.collision_layer = 0
	perception_sphere.collision_mask = 0xFFFFFFFF  # Detect everything
	perception_sphere.monitoring = true
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = perception_radius
	collision_shape.shape = sphere_shape
	perception_sphere.add_child(collision_shape)
	
	perception_sphere.area_entered.connect(_on_consciousness_field_entered)
	perception_sphere.area_exited.connect(_on_consciousness_field_exited)
	perception_sphere.body_entered.connect(_on_entity_entered_perception)
	perception_sphere.body_exited.connect(_on_entity_exited_perception)
	
	add_child(perception_sphere)
	
	# Visual representation of perception
	var perception_mesh = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = perception_radius
	sphere_mesh.height = perception_radius * 2
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16
	perception_mesh.mesh = sphere_mesh
	
	var perception_material = StandardMaterial3D.new()
	perception_material.albedo_color = Color(0.5, 0.7, 1.0, 0.1)
	perception_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	perception_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	perception_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	perception_material.vertex_color_use_as_albedo = true
	
	perception_mesh.material_override = perception_material
	perception_mesh.visible = false  # Only show during special states
	perception_sphere.add_child(perception_mesh)

func _initialize_meditation_system() -> void:
	# Meditation aura
	meditation_aura = MeshInstance3D.new()
	var torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 2.0
	torus_mesh.outer_radius = 3.0
	meditation_aura.mesh = torus_mesh
	
	var aura_material = StandardMaterial3D.new()
	aura_material.albedo_color = Color(0.8, 0.8, 1.0, 0.3)
	aura_material.emission_enabled = true
	aura_material.emission = Color(0.8, 0.8, 1.0)
	aura_material.emission_energy = 0.5
	aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aura_material.rim_enabled = true
	aura_material.rim = 1.0
	meditation_aura.material_override = aura_material
	meditation_aura.visible = false
	
	consciousness_visualizer.add_child(meditation_aura)
	
	# Meditation ambience
	meditation_ambience = AudioStreamPlayer.new()
	meditation_ambience.volume_db = -20.0
	meditation_ambience.bus = "Ambience"
	add_child(meditation_ambience)

# Core consciousness mechanics
func begin_awareness_expansion() -> void:
	set_process(true)
	print("Consciousness system activated at level ", awareness_level)

func expand_awareness() -> void:
	if awareness_level >= max_awareness_level:
		return
	
	awareness_level += 1
	consciousness_level = awareness_level
	
	# Expand perception radius
	perception_radius = 100.0 * awareness_level
	_update_perception_sphere_radius()
	
	# Check for new perceptions
	for perception in available_perceptions:
		var data = available_perceptions[perception]
		if awareness_level >= data["level"] and perception not in unlocked_perceptions:
			unlock_perception(perception)
	
	# Update state
	_update_consciousness_state_from_level()
	
	awareness_expanded.emit(awareness_level)
	
	# Special events at certain levels
	match awareness_level:
		5:
			_unlock_temporal_perception()
		7:
			_unlock_akashic_access()
		10:
			_achieve_enlightenment()

func unlock_perception(perception_type: String) -> void:
	if perception_type not in unlocked_perceptions:
		unlocked_perceptions.append(perception_type)
		perception_unlocked.emit(perception_type)
		
		# Apply perception effects
		_apply_perception_effects(perception_type)

func _apply_perception_effects(perception_type: String) -> void:
	match perception_type:
		"energy":
			# Enable energy field visualization
			get_tree().call_group("energy_fields", "set_visible", true)
		"temporal":
			# Enable time dilation effects
			Engine.time_scale = 1.0  # Can be modified during gameplay
		"quantum":
			# Show quantum possibilities
			get_tree().call_group("quantum_objects", "show_possibilities", true)
		"akashic":
			# Enable akashic record access
			if AkashicRecordsSystem:
				AkashicRecordsSystem.grant_full_access()

# Frequency system
func tune_frequency(target_frequency: float) -> void:
	target_frequency = clamp(target_frequency, frequency_range.x, frequency_range.y)
	
	var tween = create_tween()
	tween.tween_property(self, "current_frequency", target_frequency, 0.5)
	tween.tween_callback(_on_frequency_tuned)

func adjust_frequency(delta_freq: float) -> void:
	tune_frequency(current_frequency + delta_freq)

func _on_frequency_tuned() -> void:
	_generate_frequency_tone()
	_check_frequency_resonance()
	
	# Update visual color
	frequency_particles.process_material.color = _get_frequency_color()

func _check_frequency_resonance() -> void:
	# Check for special frequencies
	var resonance_frequencies = {
		432.0: "universal_harmony",
		528.0: "love_frequency",
		639.0: "connection",
		741.0: "awakening",
		852.0: "intuition",
		963.0: "divine_consciousness"
	}
	
	for freq in resonance_frequencies:
		if abs(current_frequency - freq) < 1.0:
			frequency_resonance.emit(freq, self)
			_create_resonance_ripple(freq)
			break

func _generate_frequency_tone() -> void:
	# Generate pure sine wave at current frequency
	# This is simplified - real implementation would fill audio buffer
	if frequency_generator and frequency_generator.playing:
		# Update pitch to match frequency
		frequency_generator.pitch_scale = current_frequency / 440.0

# Meditation system
func toggle_meditation() -> void:
	meditation_active = !meditation_active
	
	if meditation_active:
		_enter_meditation()
	else:
		_exit_meditation()

func _enter_meditation() -> void:
	meditation_timer = 0.0
	meditation_depth = 0.0
	meditation_insights.clear()
	
	# Visual feedback
	meditation_aura.visible = true
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(meditation_aura, "rotation:y", TAU, 3.0)
	
	# Slow time slightly
	Engine.time_scale = 0.8
	
	# Start ambience
	if meditation_ambience:
		meditation_ambience.play()

func _exit_meditation() -> void:
	meditation_aura.visible = false
	Engine.time_scale = 1.0
	
	if meditation_ambience:
		meditation_ambience.stop()
	
	# Process insights gained
	if meditation_insights.size() > 0:
		var insights_data = {
			"duration": meditation_timer,
			"depth": meditation_depth,
			"insights": meditation_insights,
			"energy_gained": meditation_depth * 10.0
		}
		meditation_completed.emit(insights_data)
		
		# Apply benefits
		consciousness_energy += insights_data["energy_gained"]
		consciousness_energy = min(consciousness_energy, max_consciousness_energy)

func _process_meditation(delta: float) -> void:
	if not meditation_active:
		return
	
	meditation_timer += delta
	meditation_depth = min(meditation_depth + delta * 0.1, 1.0)
	
	# Generate insights based on depth
	if meditation_depth > 0.3 and randf() < 0.001:
		_generate_meditation_insight()
	
	# Visual updates
	if meditation_aura:
		var pulse = sin(meditation_timer * 2.0) * 0.2 + 1.0
		meditation_aura.scale = Vector3.ONE * pulse

func _generate_meditation_insight() -> void:
	var insights = [
		"All beings are connected through the consciousness field",
		"Time is a construct of limited perception",
		"Energy flows where attention goes",
		"The void contains infinite potential",
		"Separation is an illusion of the physical realm"
	]
	
	# Higher level insights
	if awareness_level >= 5:
		insights.append_array([
			"Past, present, and future exist simultaneously",
			"Consciousness creates reality through observation",
			"The universe is a single living organism"
		])
	
	var insight = insights[randi() % insights.size()]
	meditation_insights.append({
		"text": insight,
		"timestamp": meditation_timer,
		"depth": meditation_depth
	})

# State management
func _update_consciousness_state(delta: float) -> void:
	# Progress through states based on awareness and energy
	state_progress += delta * 0.1 * (consciousness_energy / max_consciousness_energy)
	
	# Check for state transitions
	var should_transition = false
	
	match current_state:
		ConsciousnessState.DORMANT:
			if consciousness_energy > 10:
				should_transition = true
		ConsciousnessState.AWAKENING:
			if awareness_level >= 2 and state_progress > 1.0:
				should_transition = true
		ConsciousnessState.AWARE:
			if awareness_level >= 4 and connected_beings.size() > 0:
				should_transition = true
		ConsciousnessState.CONNECTED:
			if awareness_level >= 6 and collective_strength > 0.5:
				should_transition = true
		ConsciousnessState.ENLIGHTENED:
			if awareness_level >= 9 and state_progress > 2.0:
				should_transition = true
	
	if should_transition:
		_transition_consciousness_state()

func _transition_consciousness_state() -> void:
	match current_state:
		ConsciousnessState.DORMANT:
			current_state = ConsciousnessState.AWAKENING
		ConsciousnessState.AWAKENING:
			current_state = ConsciousnessState.AWARE
		ConsciousnessState.AWARE:
			current_state = ConsciousnessState.CONNECTED
		ConsciousnessState.CONNECTED:
			current_state = ConsciousnessState.ENLIGHTENED
		ConsciousnessState.ENLIGHTENED:
			current_state = ConsciousnessState.TRANSCENDENT
			_achieve_transcendence()
	
	state_progress = 0.0
	print("Consciousness state evolved to: ", current_state)

func _update_consciousness_state_from_level() -> void:
	if awareness_level >= 8:
		current_state = ConsciousnessState.ENLIGHTENED
	elif awareness_level >= 6:
		current_state = ConsciousnessState.CONNECTED
	elif awareness_level >= 3:
		current_state = ConsciousnessState.AWARE
	elif awareness_level >= 1:
		current_state = ConsciousnessState.AWAKENING
	else:
		current_state = ConsciousnessState.DORMANT

# Perception processing
func _process_perception_field(delta: float) -> void:
	# Update perception sphere
	if perception_sphere:
		var shape = perception_sphere.get_child(0).shape as SphereShape3D
		if shape.radius != perception_radius:
			shape.radius = perception_radius

func _update_perception_sphere_radius() -> void:
	if perception_sphere:
		var shape = perception_sphere.get_child(0).shape as SphereShape3D
		shape.radius = perception_radius
		
		# Update visual if exists
		var mesh = perception_sphere.get_child(1) as MeshInstance3D
		if mesh and mesh.mesh is SphereMesh:
			mesh.mesh.radius = perception_radius
			mesh.mesh.height = perception_radius * 2

# Collective consciousness
func connect_consciousness(being: Node3D) -> void:
	if being not in connected_beings:
		connected_beings.append(being)
		_recalculate_collective_strength()
		
		# Share perceptions
		if being.has_method("share_perceptions"):
			var shared = being.share_perceptions()
			for perception in shared:
				if perception not in shared_perceptions:
					shared_perceptions[perception] = []
				shared_perceptions[perception].append(being)

func disconnect_consciousness(being: Node3D) -> void:
	connected_beings.erase(being)
	_recalculate_collective_strength()
	
	# Remove shared perceptions
	for perception in shared_perceptions:
		shared_perceptions[perception].erase(being)

func _recalculate_collective_strength() -> void:
	collective_strength = 0.0
	
	for being in connected_beings:
		if being.has_method("get_consciousness_level"):
			collective_strength += being.get_consciousness_level() * 0.1
	
	collective_strength = min(collective_strength, 1.0)
	
	if connected_beings.size() >= 3 and collective_strength > 0.7:
		collective_consciousness_formed.emit(connected_beings)

func _update_collective_consciousness(delta: float) -> void:
	if connected_beings.is_empty():
		return
	
	# Synchronize frequencies
	var avg_frequency = current_frequency
	var freq_count = 1
	
	for being in connected_beings:
		if being.has_method("get_consciousness_frequency"):
			avg_frequency += being.get_consciousness_frequency()
			freq_count += 1
	
	avg_frequency /= freq_count
	
	# Gradually tune to collective frequency
	current_frequency = lerp(current_frequency, avg_frequency, delta * 0.1)

# Visual effects
func _update_visual_effects(delta: float) -> void:
	# Update particle emission based on consciousness energy
	if frequency_particles:
		frequency_particles.amount_ratio = consciousness_energy / max_consciousness_energy
	
	# Pulse effects based on state
	match current_state:
		ConsciousnessState.ENLIGHTENED:
			var pulse = sin(Time.get_ticks_msec() * 0.001) * 0.1 + 1.0
			if consciousness_visualizer:
				consciousness_visualizer.scale = Vector3.ONE * pulse
		ConsciousnessState.TRANSCENDENT:
			# Rainbow frequency cycling
			current_frequency = 432.0 + sin(Time.get_ticks_msec() * 0.0005) * 100.0

func _get_frequency_color() -> Color:
	# Map frequency to color spectrum
	var normalized = (current_frequency - frequency_range.x) / (frequency_range.y - frequency_range.x)
	
	# Rainbow spectrum
	var hue = normalized
	return Color.from_hsv(hue, 0.8, 1.0)

# Ripple creation
func _create_resonance_ripple(frequency: float) -> void:
	consciousness_ripple_created.emit(global_position, frequency / 1000.0)
	
	# Visual ripple effect
	var ripple = preload("res://effects/ConsciousnessRipple.tscn").instantiate()
	ripple.global_position = global_position
	ripple.frequency = frequency
	get_parent().add_child(ripple)

func create_consciousness_ripple(origin: Vector3, strength: float = 1.0) -> void:
	consciousness_ripple_created.emit(origin, strength)

# Special unlocks
func _unlock_temporal_perception() -> void:
	print("Temporal perception unlocked - time flows differently now")
	# Could implement time dilation mechanics

func _unlock_akashic_access() -> void:
	print("Akashic records access granted - universal knowledge available")
	philosophical_insight_shared.emit("The Akashic Records reveal themselves to your expanded awareness")

func _achieve_enlightenment() -> void:
	enlightenment_achieved.emit()
	print("Enlightenment achieved - you perceive the unity of all things")

func _achieve_transcendence() -> void:
	print("Transcendence achieved - you are one with the universe")
	# Full unity consciousness

# Energy management
func gain_consciousness_energy(amount: float) -> void:
	consciousness_energy += amount
	consciousness_energy = min(consciousness_energy, max_consciousness_energy)
	
	# Energy can trigger awareness expansion
	if consciousness_energy >= max_consciousness_energy * 0.9:
		expand_awareness()

func consume_consciousness_energy(amount: float) -> bool:
	if consciousness_energy >= amount:
		consciousness_energy -= amount
		return true
	return false

# System connections
func _connect_to_game_systems() -> void:
	# Get player to follow
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.consciousness_resonance_changed.connect(tune_frequency)

# Perception callbacks
func _on_consciousness_field_entered(area: Area3D) -> void:
	if area.has_method("get_consciousness_signature"):
		var signature = area.get_consciousness_signature()
		field_interactions[area] = signature

func _on_consciousness_field_exited(area: Area3D) -> void:
	field_interactions.erase(area)

func _on_entity_entered_perception(body: Node3D) -> void:
	# Process based on perception types
	if "energy" in unlocked_perceptions and body.has_method("get_energy_signature"):
		# Can perceive energy signatures
		pass
	
	if "emotional" in unlocked_perceptions and body.has_method("get_emotional_state"):
		# Can sense emotions
		pass

func _on_entity_exited_perception(body: Node3D) -> void:
	# Clean up perception data
	pass

# Save/Load
func _save_consciousness_state() -> void:
	if AkashicRecordsSystem:
		var save_data = {
			"awareness_level": awareness_level,
			"current_frequency": current_frequency,
			"consciousness_energy": consciousness_energy,
			"current_state": current_state,
			"unlocked_perceptions": unlocked_perceptions,
			"meditation_insights": meditation_insights
		}
		AkashicRecordsSystem.save_consciousness_data(save_data)

func load_consciousness_state(data: Dictionary) -> void:
	awareness_level = data.get("awareness_level", 1)
	current_frequency = data.get("current_frequency", 432.0)
	consciousness_energy = data.get("consciousness_energy", 50.0)
	current_state = data.get("current_state", ConsciousnessState.AWAKENING)
	unlocked_perceptions = data.get("unlocked_perceptions", ["physical"])
	meditation_insights = data.get("meditation_insights", [])
	
	# Update systems
	consciousness_level = awareness_level
	_update_perception_sphere_radius()
	_initialize_perception_system()

# Cleanup
func _cleanup_connections() -> void:
	for being in connected_beings:
		disconnect_consciousness(being)

# Public API
func get_consciousness_level() -> int:
	return awareness_level

func get_consciousness_state() -> ConsciousnessState:
	return current_state

func get_consciousness_frequency() -> float:
	return current_frequency

func is_perception_unlocked(perception_type: String) -> bool:
	return perception_type in unlocked_perceptions

func get_perception_radius() -> float:
	return perception_radius

func get_consciousness_energy() -> float:
	return consciousness_energy

func trigger_enlightenment_event() -> void:
	if awareness_level < 10:
		awareness_level = 10
		_achieve_enlightenment()

# Manual controls for testing
func expand_awareness_manually() -> void:
	if consciousness_energy >= 20.0:
		consume_consciousness_energy(20.0)
		expand_awareness()

func debug_unlock_all() -> void:
	awareness_level = max_awareness_level
	for perception in available_perceptions:
		unlock_perception(perception)
	consciousness_energy = max_consciousness_energy
	_achieve_enlightenment()

# Rare ore discovery handler
func _on_rare_ore_discovered(ore_type: String, location: Vector3) -> void:
	match ore_type:
		"resonite":
			gain_consciousness_energy(10.0)
			create_consciousness_ripple(location, 0.5)
		"stellarium":
			expand_awareness()
		"voidstone":
			# Special void meditation
			if not meditation_active:
				toggle_meditation()
			meditation_depth = 0.5

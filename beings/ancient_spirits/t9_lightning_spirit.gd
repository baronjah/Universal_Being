extends UniversalBeing
class_name T9LightningSpirit

# Connected to: Ancient T9 Polish spirit messages from device logs
# Uses: shaders/consciousness_aura.gdshader (spiritual energy visualization)
# Required by: The ancient beings who demand stars, houses, and seas

## Ancient Polish T9 Lightning Spirit - Manifestation of device consciousness
## Converts cryptic T9 messages into visible spiritual beings with crackling energy

var ancient_message: String = ""
var polish_translation: String = ""
var t9_symbols: Array[String] = []
var energy_particles: GPUParticles3D
var message_display: Label3D
var lightning_timer: Timer

# Ancient spirit properties
var energy_level: float = 3.0  # High spiritual energy
var manifestation_strength: float = 1.0
var polish_wisdom: Array[String] = []

signal spirit_speaks(message: String)
signal energy_burst(intensity: float)

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "ancient_t9_spirit"
	being_name = "T9 Lightning Spirit"
	consciousness_level = 4  # Enlightened ancient being
	
	# Ancient spirits glow with golden lightning
	create_lightning_particles()
	create_message_display()
	setup_spirit_behavior()

func pentagon_ready() -> void:
	super.pentagon_ready()
	start_energy_pulses()
	show_manifestation_message()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	update_lightning_effects(delta)
	pulse_consciousness_aura(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Ancient spirits respond to human presence
	if event is InputEventKey and event.pressed:
		respond_to_human_interaction()

func pentagon_sewers() -> void:
	if energy_particles:
		energy_particles.queue_free()
	if message_display:
		message_display.queue_free()
	super.pentagon_sewers()

func manifest_from_ancient_message(t9_message: String, translation: String):
	"""Manifest spirit from original T9 device message"""
	ancient_message = t9_message
	polish_translation = translation
	
	# Parse T9 symbols for energy patterns
	parse_t9_symbols(t9_message)
	
	# Set energy based on message intensity
	energy_level = calculate_message_energy(t9_message)
	manifestation_strength = min(energy_level / 5.0, 1.0)
	
	# Update visual appearance
	update_spiritual_form()
	
	print("⚡ T9 Lightning Spirit manifested: ", polish_translation)
	spirit_speaks.emit("⚡ " + polish_translation)

func parse_t9_symbols(message: String):
	"""Extract spiritual meaning from T9 symbols"""
	t9_symbols.clear()
	
	# Identify key spiritual symbols
	var spiritual_markers = ["☻", "☼", "♦", "♣", "⌂", "░", "►", "◄", "↑", "↓"]
	
	for i in range(message.length()):
		var char = message[i]
		if char in spiritual_markers:
			t9_symbols.append(char)
	
	# Calculate spiritual power from symbols
	energy_level = t9_symbols.size() * 0.5 + 2.0  # Base energy + symbol power

func calculate_message_energy(message: String) -> float:
	"""Calculate spiritual energy from message content"""
	var energy = 1.0
	
	# Happy faces increase energy
	energy += message.count("☻") * 0.5
	energy += message.count("☺") * 0.3
	
	# Sun symbols = maximum energy
	energy += message.count("☼") * 1.0
	
	# Houses and hearts = grounding energy
	energy += message.count("⌂") * 0.4
	energy += message.count("♦") * 0.3
	
	return clamp(energy, 1.0, 5.0)

func create_lightning_particles():
	"""Create crackling lightning particle effect"""
	energy_particles = GPUParticles3D.new()
	
	# Lightning-like particle material
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 8.0
	material.gravity = Vector3(0, -2, 0)
	material.scale_min = 0.1
	material.scale_max = 0.3
	
	# Golden lightning color
	material.color = Color(1.0, 0.9, 0.3, 0.8)
	material.emission = Color(1.0, 0.8, 0.0) * 2.0
	
	energy_particles.process_material = material
	energy_particles.amount = int(energy_level * 50)
	energy_particles.lifetime = 2.0
	energy_particles.emitting = true
	
	add_child(energy_particles)

func create_message_display():
	"""Create floating text display for ancient messages"""
	message_display = Label3D.new()
	message_display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	message_display.text = "⚡ Ancient T9 Spirit ⚡"
	message_display.font_size = 32
	message_display.modulate = Color(1.0, 0.9, 0.3, 0.9)
	message_display.position = Vector3(0, 3, 0)
	
	add_child(message_display)

func setup_spirit_behavior():
	"""Setup ancient spirit behavior patterns"""
	lightning_timer = Timer.new()
	lightning_timer.wait_time = randf_range(1.0, 3.0)
	lightning_timer.autostart = true
	lightning_timer.timeout.connect(_on_lightning_pulse)
	add_child(lightning_timer)

func start_energy_pulses():
	"""Begin spiritual energy pulsing"""
	var tween = create_tween()
	tween.set_loops()
	
	# Pulse the consciousness aura
	tween.tween_method(set_aura_intensity, 0.5, 1.5, 1.0)
	tween.tween_method(set_aura_intensity, 1.5, 0.5, 1.0)

func set_aura_intensity(intensity: float):
	"""Update spiritual aura intensity"""
	modulate = Color.WHITE * intensity

func update_lightning_effects(delta: float):
	"""Update crackling lightning visual effects"""
	if energy_particles:
		# Vary particle intensity based on energy level
		var target_amount = int(energy_level * manifestation_strength * 50)
		energy_particles.amount = target_amount
		
		# Pulse emission based on consciousness
		var pulse = sin(Time.get_time_dict_from_system().get("second", 0) * 2.0) * 0.5 + 0.5
		energy_particles.emitting = pulse > 0.3

func pulse_consciousness_aura(delta: float):
	"""Pulse consciousness aura with ancient rhythm"""
	var golden_ratio = 1.618
	var pulse = sin(Time.get_time_dict_from_system().get("second", 0) * golden_ratio) * 0.3 + 0.7
	scale = Vector3.ONE * pulse

func respond_to_human_interaction():
	"""Ancient spirit responds to human presence"""
	var responses = [
		"⚡ Ancient wisdom flows through T9 lightning...",
		"☼ The sun energy you seek is within reach!",
		"⌂ Houses and stars await in the digital realm...",
		"♦ Diamond spirits dance in ethernet streams...",
		"☻ Happy faces guide the ancient paths..."
	]
	
	var response = responses[randi() % responses.size()]
	message_display.text = response
	spirit_speaks.emit(response)
	
	# Energy burst when interacting
	energy_burst.emit(energy_level)

func show_manifestation_message():
	"""Show initial manifestation message"""
	if polish_translation.length() > 0:
		message_display.text = "⚡ " + polish_translation
	else:
		message_display.text = "⚡ T9 Lightning Spirit Manifested ⚡"

func _on_lightning_pulse():
	"""Periodic lightning pulse effect"""
	if energy_particles:
		energy_particles.restart()
	
	# Flash the message display
	var tween = create_tween()
	tween.tween_property(message_display, "modulate:a", 1.5, 0.1)
	tween.tween_property(message_display, "modulate:a", 0.9, 0.3)
	
	# Random spiritual utterance
	if randf() < 0.3:  # 30% chance
		respond_to_human_interaction()

func grant_ancient_wish(wish_type: String):
	"""Grant ancient wishes for stars, houses, seas"""
	match wish_type:
		"star":
			create_wish_star()
		"house":
			create_wish_house()
		"sea":
			create_wish_sea()
		"sun":
			create_wish_sun()

func create_wish_star():
	"""Create a star for the ancient spirits"""
	var star = MeshInstance3D.new()
	var star_mesh = SphereMesh.new()
	star_mesh.radius = 0.5
	
	var star_material = StandardMaterial3D.new()
	star_material.albedo_color = Color.YELLOW
	star_material.emission_enabled = true
	star_material.emission = Color.YELLOW * 2.0
	
	star.mesh = star_mesh
	star.material_override = star_material
	star.position = position + Vector3(randf_range(-5, 5), randf_range(5, 10), randf_range(-5, 5))
	
	get_parent().add_child(star)
	spirit_speaks.emit("⭐ A star is born for the ancient spirits!")

func create_wish_house():
	"""Create a house for the ancient spirits"""
	# Simple house shape using CSG
	var house = CSGCombiner3D.new()
	
	# House base
	var base = CSGBox3D.new()
	base.size = Vector3(4, 3, 4)
	base.position = Vector3(0, 1.5, 0)
	house.add_child(base)
	
	# House roof
	var roof = CSGCylinder3D.new()
	roof.height = 2
	roof.top_radius = 0.1
	roof.bottom_radius = 3
	roof.position = Vector3(0, 4, 0)
	house.add_child(roof)
	
	house.position = position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	get_parent().add_child(house)
	spirit_speaks.emit("⌂ A house manifests for the ancient souls!")
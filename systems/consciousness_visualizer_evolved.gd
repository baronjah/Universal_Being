extends Node
class_name ConsciousnessVisualizerEvolved

## 🌈 EVOLVED CONSCIOUSNESS VISUALIZER - Archaeological DimensionalColorSystem wisdom
## Translates consciousness levels (0-5) into perfect visual representations
## Based on discovered 999-frequency system from scriptura_exchange_zone

signal consciousness_color_changed(being: UniversalBeing, new_color: Color)
signal consciousness_pulse_visualized(being: UniversalBeing, pulse_data: Dictionary)

# Archaeological wisdom: 999-frequency consciousness mapping
@export var consciousness_frequency_range: Vector2 = Vector2(1, 999)
@export var pulse_animation_speed: float = 2.0
@export var color_transition_speed: float = 1.5

# Color palettes from archaeological findings
enum ConsciousnessPalette {
	DEFAULT,
	ETHEREAL,
	AKASHIC,
	DIMENSIONAL,
	TRANSCENDENT
}

@export var active_palette: ConsciousnessPalette = ConsciousnessPalette.TRANSCENDENT

# Archaeological consciousness level mapping
var consciousness_level_frequencies = {
	0: 42.0,    # Dormant - Base frequency
	1: 111.0,   # Awakening - Sacred awakening frequency  
	2: 222.0,   # Aware - Double consciousness
	3: 333.0,   # Connected - Triple unity
	4: 555.0,   # Enlightened - Golden ratio derivative
	5: 888.0    # Transcendent - Infinite consciousness
}
# Color caches for performance
var consciousness_color_cache: Dictionary = {}
var pulse_effect_cache: Dictionary = {}

func _ready() -> void:
	name = "ConsciousnessVisualizerEvolved"
	add_to_group("consciousness_visualizers")
	
	initialize_frequency_mappings()
	precompute_consciousness_colors()
	
	print("🌈 Evolved Consciousness Visualizer: Archaeological wisdom activated!")


func initialize_frequency_mappings() -> void:
	"""Initialize consciousness frequency mappings with archaeological wisdom"""
	# Sacred mathematical relationships discovered in DimensionalColorSystem
	for level in range(6):
		var base_freq = consciousness_level_frequencies[level]
		var harmonic_freq = base_freq * (1.0 + sin(level * PI / 5.0) * 0.618)  # Golden ratio harmony
		consciousness_level_frequencies[level] = harmonic_freq

func precompute_consciousness_colors() -> void:
	"""Precompute all consciousness colors for perfect performance"""
	for level in range(6):
		var frequency = consciousness_level_frequencies[level]
		var color = calculate_consciousness_color(level, frequency)
		consciousness_color_cache[level] = color
		
		print("🎨 Consciousness Level %d: Frequency %.1f = %s" % [level, frequency, color])


func calculate_consciousness_color(level: int, frequency: float) -> Color:
	"""Archaeological wisdom: Convert consciousness frequency to perfect color"""
	match active_palette:
		ConsciousnessPalette.TRANSCENDENT:
			return calculate_transcendent_color(level, frequency)
		ConsciousnessPalette.ETHEREAL:
			return calculate_ethereal_color(level, frequency)
		ConsciousnessPalette.AKASHIC:
			return calculate_akashic_color(level, frequency)
		ConsciousnessPalette.DIMENSIONAL:
			return calculate_dimensional_color(level, frequency)
		_:
			return calculate_default_color(level, frequency)

func calculate_transcendent_color(level: int, frequency: float) -> Color:
	"""Perfect transcendent color mapping - archaeological wisdom"""
	match level:
		0: return Color(0.3, 0.3, 0.3, 0.8)      # Dormant Gray
		1: return Color(0.9, 0.9, 0.95, 0.85)    # Awakening White
		2: return Color(0.2, 0.4, 1.0, 0.9)      # Aware Blue
		3: return Color(0.2, 1.0, 0.2, 0.95)     # Connected Green
		4: return Color(1.0, 0.84, 0.0, 1.0)     # Enlightened Gold
		5: return Color(1.0, 1.0, 1.0, 1.0)      # Transcendent Pure White
		_: return Color.WHITE

func calculate_ethereal_color(level: int, frequency: float) -> Color:
	"""Ethereal palette with mystical properties"""
	var phase = frequency / 999.0
	var hue = fmod(phase * 360.0 + level * 60.0, 360.0) / 360.0
	var saturation = 0.7 + level * 0.05
	var value = 0.8 + level * 0.04
	return Color.from_hsv(hue, saturation, value, 0.9)

func calculate_akashic_color(level: int, frequency: float) -> Color:
	"""Akashic records color system - deep cosmic wisdom"""
	var cosmic_phase = sin(frequency * PI / 333.0) * 0.5 + 0.5
	var r = cosmic_phase * (0.5 + level * 0.1)
	var g = sin(frequency * PI / 555.0) * 0.5 + 0.5
	var b = cos(frequency * PI / 777.0) * 0.5 + 0.5
	return Color(r, g, b, 0.85 + level * 0.03)

func calculate_dimensional_color(level: int, frequency: float) -> Color:
	"""Multi-dimensional color space mapping"""
	var x = frequency / 999.0
	var y = float(level) / 5.0
	var z = sin(frequency * PI / 111.0) * 0.5 + 0.5
	
	return Color(x, y, z, 0.9)

func calculate_default_color(level: int, frequency: float) -> Color:
	"""Default consciousness color system"""
	return consciousness_color_cache.get(level, Color.WHITE)

func visualize_being_consciousness(being: UniversalBeing) -> void:
	"""Apply perfect consciousness visualization to a Universal Being"""
	if not being:
		return
	
	var consciousness_color = get_consciousness_color(being.consciousness_level)
	var mesh_instances = find_mesh_instances(being)
	
	for mesh_instance in mesh_instances:
		apply_consciousness_material(mesh_instance, consciousness_color, being.consciousness_level)
	
	# Emit signal for other systems
	consciousness_color_changed.emit(being, consciousness_color)

func get_consciousness_color(level: int) -> Color:
	"""Get cached consciousness color for perfect performance"""
	return consciousness_color_cache.get(level, Color.WHITE)

func find_mesh_instances(being: Node) -> Array[MeshInstance3D]:
	"""Find all MeshInstance3D nodes in a being"""
	var mesh_instances: Array[MeshInstance3D] = []
	
	for child in being.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)
		# Recursively search children
		mesh_instances.append_array(find_mesh_instances(child))
	
	return mesh_instances

func apply_consciousness_material(mesh_instance: MeshInstance3D, color: Color, level: int) -> void:
	"""Apply consciousness-aware material with archaeological wisdom"""
	var material: StandardMaterial3D
	
	if mesh_instance.get_surface_override_material(0):
		material = mesh_instance.get_surface_override_material(0).duplicate()
	else:
		material = StandardMaterial3D.new()
	
	# Apply consciousness color
	material.albedo_color = color
	
	# Archaeological wisdom: Higher consciousness = more emission
	if level >= 3:
		material.emission_enabled = true
		material.emission = color * 0.8
		material.emission_energy = float(level - 2) * 0.3
	
	# Archaeological wisdom: Transcendent consciousness = transparency
	if level >= 4:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.flags_transparent = true
		material.albedo_color.a = 0.85 + float(level) * 0.03
	
	# Archaeological wisdom: Perfect consciousness = metallic properties
	if level == 5:
		material.metallic = 0.8
		material.roughness = 0.1
	
	mesh_instance.set_surface_override_material(0, material)

func create_consciousness_pulse(being: UniversalBeing, pulse_intensity: float = 1.0) -> void:
	"""Create consciousness pulse visualization with archaeological wisdom"""
	var pulse_data = {
		"being": being,
		"intensity": pulse_intensity,
		"frequency": consciousness_level_frequencies[being.consciousness_level],
		"color": get_consciousness_color(being.consciousness_level),
		"timestamp": Time.get_time_string_from_system()
}
	
	# Create visual pulse effect
	create_pulse_effect(being, pulse_data)
	
	# Emit signal for other systems to react
	consciousness_pulse_visualized.emit(being, pulse_data)

func create_pulse_effect(being: UniversalBeing, pulse_data: Dictionary) -> void:
	"""Create the actual pulse visual effect"""
	var pulse_color = pulse_data.color
	var mesh_instances = find_mesh_instances(being)
	
	for mesh_instance in mesh_instances:
		var tween = create_tween()
		var original_color = mesh_instance.get_surface_override_material(0).albedo_color if mesh_instance.get_surface_override_material(0) else Color.WHITE
		var pulse_bright = pulse_color * (1.0 + pulse_data.intensity)
		
		# Pulse animation: bright -> original -> bright
		tween.tween_method(
			func(color): apply_temp_color(mesh_instance, color),
			original_color,
			pulse_bright,
			0.3
		)
		tween.tween_method(
			func(color): apply_temp_color(mesh_instance, color),
			pulse_bright,
			original_color,
			0.3
		)

func apply_temp_color(mesh_instance: MeshInstance3D, color: Color) -> void:
	"""Apply temporary color for pulse effects"""
	var material = mesh_instance.get_surface_override_material(0)
	if material:
		material.albedo_color = color

func evolve_consciousness_visualization() -> void:
	"""Evolve the consciousness visualization system with new archaeological insights"""
	# Recalculate frequencies with evolution
	for level in consciousness_level_frequencies:
		var current_freq = consciousness_level_frequencies[level]
		var evolved_freq = current_freq * (1.0 + sin(Time.get_time_string_from_system().hash()) * 0.1)
		consciousness_level_frequencies[level] = evolved_freq
	
	# Regenerate color cache
	precompute_consciousness_colors()
	
	print("🌈 Consciousness visualization evolved with new frequencies!")

# Public API for Universal Beings
func register_being_for_visualization(being: UniversalBeing) -> void:
	"""Register a Universal Being for automatic consciousness visualization"""
	visualize_being_consciousness(being)
	
	# Connect to consciousness change signals if available
	if being.has_signal("consciousness_level_changed"):
		being.consciousness_level_changed.connect(func(): visualize_being_consciousness(being))

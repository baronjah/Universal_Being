# 🏛️ Dimensional Color System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

class_name DimensionalColorSystemEffect
extends UniversalBeingBase
# ----- COLOR FREQUENCY CONSTANTS -----
const COLOR_HARMONICS = {
	"PRIMARY": {
		"frequencies": [99, 333, 555, 777, 999],
		"colors": [
			Color(0.1, 0.4, 0.9, 1.0),  # 99: Deep blue
			Color(0.0, 0.9, 0.6, 1.0),  # 333: Teal
			Color(0.9, 0.4, 0.7, 1.0),  # 555: Pink
			Color(0.9, 0.8, 0.1, 1.0),  # 777: Gold
			Color(1.0, 1.0, 1.0, 1.0)   # 999: Pure white
		]
	},
	"SECONDARY": {
		"frequencies": [120, 240, 360, 480, 600, 720, 840, 960],
		"colors": [
			Color(0.5, 0.0, 0.9, 1.0),  # 120: Purple
			Color(0.0, 0.7, 0.9, 1.0),  # 240: Cyan 
			Color(0.0, 0.9, 0.0, 1.0),  # 360: Green
			Color(0.9, 0.9, 0.0, 1.0),  # 480: Yellow
			Color(0.9, 0.5, 0.0, 1.0),  # 600: Orange
			Color(0.9, 0.0, 0.0, 1.0),  # 720: Red
			Color(0.9, 0.0, 0.9, 1.0),  # 840: Magenta
			Color(0.3, 0.6, 0.9, 1.0)   # 960: Blue
		]
	},
	"TERITARY": {
		"frequencies": [33, 66, 166, 233, 266, 299, 399, 466, 499, 533, 599, 633, 666, 699, 833, 866, 899, 933, 966],
		"colors": []  # Generated in _ready()
	}
}

# ----- MESH CONSTANTS -----
const MESH_HARMONIC_POINTS = {
	"CENTERS": [333, 666, 999],
	"EDGES": [120, 240, 480, 720, 960],
	"CORNERS": [99, 555, 777]
}

# ----- COLOR ANIMATION SETTINGS -----
const MIN_FREQUENCY = 1
const MAX_FREQUENCY = 999
const DEFAULT_ANIMATION_DURATION = 1.0 # seconds
const DEFAULT_PULSE_FREQUENCY = 4.0 # Hz
const DEFAULT_AMPLITUDE = 0.2

# ----- FREQUENCY MAPPINGS -----
var frequency_color_map = {}
var mesh_point_map = {}
var animation_timers = {}
var active_animations = {}

# ----- COLOR PALETTES -----
var color_palettes = {
	"default": [],
	"ethereal": [],
	"akashic": [],
	"dimensional": [],
	"turn_based": []
}

# ----- SYSTEM REFERENCES -----
var ethereal_bridge = null
var akashic_system = null

# ----- SIGNALS -----
signal color_frequency_updated(frequency, color)
signal animation_started(animation_id, frequency)
signal animation_completed(animation_id, frequency)
signal mesh_point_activated(point_type, frequency)

# ----- INITIALIZATION -----
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Generate tertiary colors
	_generate_tertiary_colors()
	
	# Initialize frequency color map
	_initialize_frequency_color_map()
	
	# Initialize mesh point map
	_initialize_mesh_point_map()
	
	# Generate color palettes
	_generate_color_palettes()
	
	# Find system references
	_find_systems()
	
	print("Dimensional Color System initialized with " + str(frequency_color_map.size()) + " color frequencies")

func _generate_tertiary_colors():
	# Generate colors for tertiary frequencies by interpolating between primaries and secondaries
	var tertiary_frequencies = COLOR_HARMONICS.TERITARY.frequencies
	var tertiary_colors = []
	
	for freq in tertiary_frequencies:
		# Find surrounding reference frequencies
		var lower_freq = 0
		var lower_color = Color(0, 0, 0, 1)
		var upper_freq = MAX_FREQUENCY
		var upper_color = Color(1, 1, 1, 1)
		
		# Check primary frequencies
		for i in range(COLOR_HARMONICS.PRIMARY.frequencies.size()):
			var primary_freq = COLOR_HARMONICS.PRIMARY.frequencies[i]
			if primary_freq < freq and primary_freq > lower_freq:
				lower_freq = primary_freq
				lower_color = COLOR_HARMONICS.PRIMARY.colors[i]
			elif primary_freq > freq and primary_freq < upper_freq:
				upper_freq = primary_freq
				upper_color = COLOR_HARMONICS.PRIMARY.colors[i]
		
		# Check secondary frequencies
		for i in range(COLOR_HARMONICS.SECONDARY.frequencies.size()):
			var secondary_freq = COLOR_HARMONICS.SECONDARY.frequencies[i]
			if secondary_freq < freq and secondary_freq > lower_freq:
				lower_freq = secondary_freq
				lower_color = COLOR_HARMONICS.SECONDARY.colors[i]
			elif secondary_freq > freq and secondary_freq < upper_freq:
				upper_freq = secondary_freq
				upper_color = COLOR_HARMONICS.SECONDARY.colors[i]
		
		# Calculate interpolation factor
		var factor = 0.5
		if upper_freq != lower_freq:
			factor = float(freq - lower_freq) / (upper_freq - lower_freq)
		
		# Interpolate color
		var color = lower_color.lerp(upper_color, factor)
		
		# Add to tertiary colors
		tertiary_colors.append(color)
	
	# Cannot assign to constant - store in variable instead
	var tertiary_harmonic = COLOR_HARMONICS.TERITARY
	tertiary_harmonic.colors = tertiary_colors

func _initialize_frequency_color_map():
	# Initialize map with base (black) color
	for freq in range(MIN_FREQUENCY, MAX_FREQUENCY + 1):
		var base_color = Color(0.1, 0.1, 0.1, 1.0)
		frequency_color_map[freq] = base_color
	
	# Add primary frequencies
	for i in range(COLOR_HARMONICS.PRIMARY.frequencies.size()):
		var freq = COLOR_HARMONICS.PRIMARY.frequencies[i]
		var color = COLOR_HARMONICS.PRIMARY.colors[i]
		frequency_color_map[freq] = color
	
	# Add secondary frequencies
	for i in range(COLOR_HARMONICS.SECONDARY.frequencies.size()):
		var freq = COLOR_HARMONICS.SECONDARY.frequencies[i]
		var color = COLOR_HARMONICS.SECONDARY.colors[i]
		frequency_color_map[freq] = color
	
	# Add tertiary frequencies
	for i in range(COLOR_HARMONICS.TERITARY.frequencies.size()):
		var freq = COLOR_HARMONICS.TERITARY.frequencies[i]
		var color = COLOR_HARMONICS.TERITARY.colors[i]
		frequency_color_map[freq] = color
	
	# Fill all other frequencies by interpolation
	for freq in range(MIN_FREQUENCY, MAX_FREQUENCY + 1):
		if frequency_color_map[freq].r == 0.1 and frequency_color_map[freq].g == 0.1 and frequency_color_map[freq].b == 0.1:
			# Find surrounding reference frequencies
			var lower_freq = MIN_FREQUENCY - 1
			var upper_freq = MAX_FREQUENCY + 1
			
			# Find closest lower frequency with defined color
			for ref_freq in range(freq-1, MIN_FREQUENCY-1, -1):
				if frequency_color_map.has(ref_freq) and frequency_color_map[ref_freq].r != 0.1 or frequency_color_map[ref_freq].g != 0.1 or frequency_color_map[ref_freq].b != 0.1:
					lower_freq = ref_freq
					break
			
			# Find closest upper frequency with defined color
			for ref_freq in range(freq+1, MAX_FREQUENCY+2):
				if frequency_color_map.has(ref_freq) and frequency_color_map[ref_freq].r != 0.1 or frequency_color_map[ref_freq].g != 0.1 or frequency_color_map[ref_freq].b != 0.1:
					upper_freq = ref_freq
					break
			
			# Interpolate color
			if lower_freq >= MIN_FREQUENCY and upper_freq <= MAX_FREQUENCY:
				var lower_color = frequency_color_map[lower_freq]
				var upper_color = frequency_color_map[upper_freq]
				var factor = float(freq - lower_freq) / (upper_freq - lower_freq)
				frequency_color_map[freq] = lower_color.lerp(upper_color, factor)

func _initialize_mesh_point_map():
	# Map mesh points to their frequencies
	for freq in range(MIN_FREQUENCY, MAX_FREQUENCY + 1):
		var point_types = []
		
		# Check if frequency is a center point
		if MESH_HARMONIC_POINTS.CENTERS.has(freq):
			point_types.append("center")
		
		# Check if frequency is an edge point
		if MESH_HARMONIC_POINTS.EDGES.has(freq):
			point_types.append("edge")
		
		# Check if frequency is a corner point
		if MESH_HARMONIC_POINTS.CORNERS.has(freq):
			point_types.append("corner")
		
		if point_types.size() > 0:
			mesh_point_map[freq] = point_types

func _generate_color_palettes():
	# Generate different color palettes for different systems
	
	# Default palette (full spectrum)
	color_palettes.default = [
		frequency_color_map[99],
		frequency_color_map[240],
		frequency_color_map[333],
		frequency_color_map[480],
		frequency_color_map[555],
		frequency_color_map[720],
		frequency_color_map[777],
		frequency_color_map[999]
	]
	
	# Ethereal palette (blues and cyans)
	color_palettes.ethereal = [
		frequency_color_map[99],    # Deep blue
		frequency_color_map[240],   # Cyan
		frequency_color_map[333],   # Teal
		Color(0.2, 0.5, 0.8, 1.0),  # Sky blue
		Color(0.0, 0.3, 0.7, 1.0),  # Ocean blue
		Color(0.1, 0.6, 0.8, 1.0),  # Aqua
		Color(0.4, 0.7, 0.9, 1.0),  # Light blue
		Color(0.7, 0.9, 1.0, 1.0)   # Pale blue
	]
	
	# Akashic palette (purples and magentas)
	color_palettes.akashic = [
		Color(0.3, 0.0, 0.5, 1.0),  # Deep purple
		Color(0.5, 0.0, 0.5, 1.0),  # Purple
		Color(0.7, 0.0, 0.7, 1.0),  # Magenta
		Color(0.8, 0.2, 0.8, 1.0),  # Bright magenta
		Color(0.4, 0.0, 0.8, 1.0),  # Violet
		Color(0.6, 0.3, 0.9, 1.0),  # Lavender
		Color(0.8, 0.4, 1.0, 1.0),  # Light purple
		Color(0.9, 0.7, 1.0, 1.0)   # Pale lavender
	]
	
	# Dimensional palette (greens and golds)
	color_palettes.dimensional = [
		Color(0.0, 0.5, 0.3, 1.0),  # Deep green
		Color(0.0, 0.7, 0.4, 1.0),  # Emerald
		Color(0.3, 0.8, 0.2, 1.0),  # Lime green
		Color(0.5, 0.9, 0.3, 1.0),  # Bright green
		Color(0.7, 0.8, 0.2, 1.0),  # Yellow-green
		Color(0.8, 0.7, 0.2, 1.0),  # Gold
		frequency_color_map[777],   # Gold from harmonics
		Color(1.0, 0.9, 0.5, 1.0)   # Pale gold
	]
	
	# Turn-based palette (reds and oranges)
	color_palettes.turn_based = [
		Color(0.5, 0.0, 0.0, 1.0),  # Deep red
		Color(0.7, 0.0, 0.0, 1.0),  # Red
		Color(0.9, 0.2, 0.0, 1.0),  # Bright red
		Color(0.9, 0.4, 0.0, 1.0),  # Orange-red
		Color(0.9, 0.6, 0.0, 1.0),  # Orange
		Color(1.0, 0.7, 0.2, 1.0),  # Bright orange
		Color(1.0, 0.8, 0.4, 1.0),  # Light orange
		Color(1.0, 0.9, 0.7, 1.0)   # Pale orange
	]

func _find_systems():
	# Find Ethereal Bridge
	ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
	if not ethereal_bridge:
		ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
	
	# Find Akashic System
	akashic_system = get_node_or_null("/root/AkashicNumberSystem")
	if not akashic_system:
		akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
	
	print("Systems found - Ethereal Bridge: %s, Akashic System: %s" % [
		"Yes" if ethereal_bridge else "No",
		"Yes" if akashic_system else "No"
	])

func _find_node_by_class(node, class_name_str):
	if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class(child, class_name_str)
		if found:
			return found
	
	return null

# ----- PROCESS -----
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Update animations
	_update_animations(delta)

func _update_animations(delta):
	var completed_animations = []
	
	for animation_id in active_animations:
		var animation = active_animations[animation_id]
		animation.elapsed_time += delta
		
		# Check if animation is complete
		if animation.elapsed_time >= animation.duration:
			completed_animations.append(animation_id)
			emit_signal("animation_completed", animation_id, animation.frequency)
		else:
			# Update animation
			var progress = animation.elapsed_time / animation.duration
			
			match animation.type:
				"pulse":
					_update_pulse_animation(animation, progress)
				"fade":
					_update_fade_animation(animation, progress)
				"cycle":
					_update_cycle_animation(animation, progress)
				"rainbow":
					_update_rainbow_animation(animation, progress)
				"mesh_point":
					_update_mesh_point_animation(animation, progress)
	
	# Remove completed animations
	for animation_id in completed_animations:
		active_animations.erase(animation_id)

func _update_pulse_animation(animation, progress):
	var base_color = animation.base_color
	var target_color = animation.target_color
	var frequency = animation.pulse_frequency
	var amplitude = animation.amplitude
	
	# Calculate pulse factor (0 to 1 to 0)
	var pulse_progress = sin(progress * TAU * frequency) * 0.5 + 0.5
	pulse_progress = pulse_progress * amplitude
	
	# Interpolate color
	var current_color = base_color.lerp(target_color, pulse_progress)
	
	# Update color in map
	animation.current_color = current_color
	frequency_color_map[animation.frequency] = current_color
	
	emit_signal("color_frequency_updated", animation.frequency, current_color)

func _update_fade_animation(animation, progress):
	var start_color = animation.start_color
	var end_color = animation.end_color
	
	# Interpolate color
	var current_color = start_color.lerp(end_color, progress)
	
	# Update color in map
	animation.current_color = current_color
	frequency_color_map[animation.frequency] = current_color
	
	emit_signal("color_frequency_updated", animation.frequency, current_color)

func _update_cycle_animation(animation, progress):
	var palette = animation.palette
	
	# Calculate which color in the palette to use
	var palette_size = palette.size()
	var cycle_position = fmod(progress * palette_size * animation.cycle_speed, palette_size)
	var index1 = int(cycle_position)
	var index2 = (index1 + 1) % palette_size
	var blend_factor = cycle_position - index1
	
	# Interpolate between the two colors
	var color1 = palette[index1]
	var color2 = palette[index2]
	var current_color = color1.lerp(color2, blend_factor)
	
	# Update color in map
	animation.current_color = current_color
	frequency_color_map[animation.frequency] = current_color
	
	emit_signal("color_frequency_updated", animation.frequency, current_color)

func _update_rainbow_animation(animation, progress):
	# Create a rainbow cycling effect
	var hue = fmod(progress * animation.rainbow_speed, 1.0)
	var sat = animation.saturation
	var val = animation.brightness
	
	# Convert HSV to RGB
	var current_color = Color.from_hsv(hue, sat, val)
	
	# Update color in map
	animation.current_color = current_color
	frequency_color_map[animation.frequency] = current_color
	
	emit_signal("color_frequency_updated", animation.frequency, current_color)

func _update_mesh_point_animation(animation, progress):
	var point_type = animation.point_type
	var base_color = animation.base_color
	var highlight_color = animation.highlight_color
	
	# Calculate highlight intensity (0 to 1 to 0)
	var frequency = animation.pulse_frequency
	var intensity = sin(progress * TAU * frequency) * 0.5 + 0.5
	
	# Scale intensity by point type importance
	match point_type:
		"center":
			intensity = intensity * 1.0 # Full intensity
		"corner":
			intensity = intensity * 0.8 # 80% intensity
		"edge":
			intensity = intensity * 0.6 # 60% intensity
	
	# Interpolate color
	var current_color = base_color.lerp(highlight_color, intensity)
	
	# Update color in map
	animation.current_color = current_color
	frequency_color_map[animation.frequency] = current_color
	
	emit_signal("color_frequency_updated", animation.frequency, current_color)
	
	# Emit mesh point signal periodically
	if fmod(progress * frequency * 10, 1.0) < 0.1:
		emit_signal("mesh_point_activated", point_type, animation.frequency)

# ----- COLOR MAPPING -----

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func get_color_for_frequency(frequency: int) -> Color:
	# Clamp frequency to valid range
	frequency = clamp(frequency, MIN_FREQUENCY, MAX_FREQUENCY)
	
	if frequency_color_map.has(frequency):
		return frequency_color_map[frequency]
	
	# Color not found, return default
	return Color(0.5, 0.5, 0.5, 1.0)

func get_mesh_point_type(frequency: int) -> Array:
	if mesh_point_map.has(frequency):
		return mesh_point_map[frequency]
	
	return []

func get_closest_harmonic_frequency(frequency: int) -> int:
	# Find the closest frequency in the harmonics
	var all_harmonics = []
	all_harmonics.append_array(COLOR_HARMONICS.PRIMARY.frequencies)
	all_harmonics.append_array(COLOR_HARMONICS.SECONDARY.frequencies)
	all_harmonics.append_array(COLOR_HARMONICS.TERITARY.frequencies)
	
	var closest_freq = all_harmonics[0]
	var closest_dist = abs(frequency - closest_freq)
	
	for freq in all_harmonics:
		var dist = abs(frequency - freq)
		if dist < closest_dist:
			closest_dist = dist
			closest_freq = freq
	
	return closest_freq

func get_color_palette(palette_name: String = "default") -> Array:
	if color_palettes.has(palette_name):
		return color_palettes[palette_name]
	
	return color_palettes.default

# ----- ANIMATION FUNCTIONS -----
func start_pulse_animation(frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY, amplitude: float = DEFAULT_AMPLITUDE) -> String:
	# Create a pulsing animation for a frequency
	var base_color = get_color_for_frequency(frequency)
	var harmonic_freq = get_closest_harmonic_frequency(frequency)
	var target_color = get_color_for_frequency(harmonic_freq)
	
	# Create animation ID
	var animation_id = "pulse_" + str(frequency) + "_" + str(Time.get_unix_time_from_system())
	
	# Create animation data
	active_animations[animation_id] = {
		"type": "pulse",
		"frequency": frequency,
		"duration": duration,
		"pulse_frequency": pulse_freq,
		"amplitude": amplitude,
		"base_color": base_color,
		"target_color": target_color,
		"current_color": base_color,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, frequency)
	
	return animation_id

func start_fade_animation(frequency: int, target_color: Color, duration: float = DEFAULT_ANIMATION_DURATION) -> String:
	# Create a fading animation from current color to target color
	var start_color = get_color_for_frequency(frequency)
	
	# Create animation ID
	var animation_id = "fade_" + str(frequency) + "_" + str(Time.get_unix_time_from_system())
	
	# Create animation data
	active_animations[animation_id] = {
		"type": "fade",
		"frequency": frequency,
		"duration": duration,
		"start_color": start_color,
		"end_color": target_color,
		"current_color": start_color,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, frequency)
	
	return animation_id

func start_cycle_animation(frequency: int, palette_name: String = "default", duration: float = DEFAULT_ANIMATION_DURATION, cycle_speed: float = 1.0) -> String:
	# Create a cycling animation through a color palette
	var palette = get_color_palette(palette_name)
	var start_color = get_color_for_frequency(frequency)
	
	# Create animation ID
	var animation_id = "cycle_" + str(frequency) + "_" + str(Time.get_unix_time_from_system())
	
	# Create animation data
	active_animations[animation_id] = {
		"type": "cycle",
		"frequency": frequency,
		"duration": duration,
		"palette": palette,
		"cycle_speed": cycle_speed,
		"current_color": start_color,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, frequency)
	
	return animation_id

func start_rainbow_animation(frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, rainbow_speed: float = 1.0, saturation: float = 1.0, brightness: float = 1.0) -> String:
	# Create a rainbow cycling animation
	var start_color = get_color_for_frequency(frequency)
	
	# Create animation ID
	var animation_id = "rainbow_" + str(frequency) + "_" + str(Time.get_unix_time_from_system())
	
	# Create animation data
	active_animations[animation_id] = {
		"type": "rainbow",
		"frequency": frequency,
		"duration": duration,
		"rainbow_speed": rainbow_speed,
		"saturation": saturation,
		"brightness": brightness,
		"current_color": start_color,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, frequency)
	
	return animation_id

func start_mesh_point_animation(frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY) -> String:
	# Create an animation for mesh points (centers, edges, corners)
	var point_types = get_mesh_point_type(frequency)
	
	if point_types.size() == 0:
		return ""
	
	var point_type = point_types[0] # Use first type if multiple
	var base_color = get_color_for_frequency(frequency)
	var highlight_color = Color(1.0, 1.0, 1.0, 1.0) # White highlight
	
	# Adjust highlight color based on point type
	match point_type:
		"center":
			highlight_color = Color(1.0, 1.0, 1.0, 1.0) # White
		"corner":
			highlight_color = Color(1.0, 0.9, 0.1, 1.0) # Gold
		"edge":
			highlight_color = Color(0.1, 0.9, 1.0, 1.0) # Cyan
	
	# Create animation ID
	var animation_id = "mesh_" + str(frequency) + "_" + str(Time.get_unix_time_from_system())
	
	# Create animation data
	active_animations[animation_id] = {
		"type": "mesh_point",
		"frequency": frequency,
		"duration": duration,
		"pulse_frequency": pulse_freq,
		"point_type": point_type,
		"base_color": base_color,
		"highlight_color": highlight_color,
		"current_color": base_color,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, frequency)
	emit_signal("mesh_point_activated", point_type, frequency)
	
	return animation_id

func stop_animation(animation_id: String) -> bool:
	if active_animations.has(animation_id):
		var animation = active_animations[animation_id]
		var frequency = animation.frequency
		
		# Reset color to harmonic color
		var harmonic_freq = get_closest_harmonic_frequency(frequency)
		frequency_color_map[frequency] = get_color_for_frequency(harmonic_freq)
		
		active_animations.erase(animation_id)
		return true
	
	return false

func stop_all_animations() -> void:
	# Reset all colors to their harmonic values
	for animation_id in active_animations:
		var animation = active_animations[animation_id]
		var frequency = animation.frequency
		var harmonic_freq = get_closest_harmonic_frequency(frequency)
		frequency_color_map[frequency] = get_color_for_frequency(harmonic_freq)
	
	active_animations.clear()

# ----- TEXT COLOR FUNCTIONS -----
func get_colored_text(text: String, frequency: int) -> String:
	var color = get_color_for_frequency(frequency)
	
	# Convert color to hex
	var hex_color = color.to_html(false)
	
	# Return BBCode colored text
	return "[color=#" + hex_color + "]" + text + "[/color]"

func get_gradient_text(text: String, start_freq: int, end_freq: int) -> String:
	var start_color = get_color_for_frequency(start_freq)
	var end_color = get_color_for_frequency(end_freq)
	
	# Return BBCode gradient text
	var start_hex = start_color.to_html(false)
	var end_hex = end_color.to_html(false)
	
	return "[gradient start=#" + start_hex + " end=#" + end_hex + "]" + text + "[/gradient]"

func colorize_line(line: String, base_frequency: int, symbol_boost: int = 10) -> String:
	# Colorize an entire line, with special handling for symbols
	var result = ""
	var current_freq = base_frequency
	
	for i in range(line.length()):
		var char = line[i]
		
		# Adjust frequency based on character
		match char:
			"#":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost)
			"_":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost / 2)
			"@":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost * 2)
			"$":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost * 3)
			"%":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost * 1.5)
			"&":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost * 2.5)
			"*":
				current_freq = min(MAX_FREQUENCY, current_freq + symbol_boost * 3.5)
			".":
				current_freq = max(MIN_FREQUENCY, current_freq - symbol_boost / 2)
			",":
				current_freq = max(MIN_FREQUENCY, current_freq - symbol_boost / 4)
			" ":
				current_freq = base_frequency # Reset to base
		
		# Apply color to character
		var color = get_color_for_frequency(current_freq)
		var hex_color = color.to_html(false)
		
		result += "[color=#" + hex_color + "]" + char + "[/color]"
	
	return result

func colorize_mesh_points(text: String) -> String:
	# Apply special coloring to mesh point frequencies
	var result = text
	
	# Check for numbers in text that match mesh point frequencies
	for freq in mesh_point_map.keys():
		var freq_str = str(freq)
		
		# Replace occurrences of the frequency with colored version
		var color = get_color_for_frequency(freq)
		var hex_color = color.to_html(false)
		
		# Create replacement with proper coloring
		var replacement = "[color=#" + hex_color + "]" + freq_str + "[/color]"
		
		# Replace in text (using regex to match whole words only)
		var regex = RegEx.new()
		regex.compile("\\b" + freq_str + "\\b")
		result = regex.sub(result, replacement, true)
	
	return result

# ----- LINE ANIMATION FUNCTIONS -----
func start_line_animation(line_index: int, frequency: int = 120, animation_type: String = "pulse", duration: float = DEFAULT_ANIMATION_DURATION) -> String:
	# Create an animation for a specific line
	var animation_id = ""
	
	match animation_type:
		"pulse":
			animation_id = start_pulse_animation(frequency, duration, DEFAULT_PULSE_FREQUENCY, DEFAULT_AMPLITUDE)
		"rainbow":
			animation_id = start_rainbow_animation(frequency, duration)
		"cycle":
			animation_id = start_cycle_animation(frequency, "default", duration)
		"mesh_point":
			animation_id = start_mesh_point_animation(frequency, duration)
	
	if animation_id != "":
		active_animations[animation_id].line_index = line_index
	
	return animation_id

func animate_text_typing(text: String, base_freq: int = 120, duration: float = 2.0, delay_per_char: float = 0.05) -> void:
	# Animate text appearing character by character with changing colors
	# This would typically be implemented by the rendering system
	# Here we just create the animation data
	
	var animation_id = "typing_" + str(Time.get_unix_time_from_system())
	
	active_animations[animation_id] = {
		"type": "typing",
		"text": text,
		"base_frequency": base_freq,
		"duration": duration,
		"delay_per_char": delay_per_char,
		"current_char": 0,
		"elapsed_time": 0.0
	}
	
	emit_signal("animation_started", animation_id, base_freq)

# ----- MESH VISUALIZATION HELPERS -----
func highlight_mesh_points(frequencies: Array, duration: float = 5.0) -> void:
	# Start animations for all the specified frequencies
	for freq in frequencies:
		if mesh_point_map.has(freq):
			start_mesh_point_animation(freq, duration)

func highlight_mesh_centers(duration: float = 5.0) -> void:
	highlight_mesh_points(MESH_HARMONIC_POINTS.CENTERS, duration)

func highlight_mesh_edges(duration: float = 5.0) -> void:
	highlight_mesh_points(MESH_HARMONIC_POINTS.EDGES, duration)

func highlight_mesh_corners(duration: float = 5.0) -> void:
	highlight_mesh_points(MESH_HARMONIC_POINTS.CORNERS, duration)

func get_mesh_visualization_colors() -> Dictionary:
	# Return colors for mesh visualization
	return {
		"centers": [
			get_color_for_frequency(MESH_HARMONIC_POINTS.CENTERS[0]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.CENTERS[1]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.CENTERS[2])
		],
		"edges": [
			get_color_for_frequency(MESH_HARMONIC_POINTS.EDGES[0]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.EDGES[1]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.EDGES[2]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.EDGES[3]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.EDGES[4])
		],
		"corners": [
			get_color_for_frequency(MESH_HARMONIC_POINTS.CORNERS[0]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.CORNERS[1]),
			get_color_for_frequency(MESH_HARMONIC_POINTS.CORNERS[2])
		]
	}

# ----- ETHEREAL INTEGRATION -----
func sync_with_ethereal_bridge() -> bool:
	if not ethereal_bridge:
		return false
	
	# Get dimensional data from ethereal bridge
	if ethereal_bridge.has_method("get_active_dimensions"):
		var active_dimensions = ethereal_bridge.get_active_dimensions()
		
		for dim_data in active_dimensions:
			if dim_data.has("frequency"):
				var freq = int(dim_data.frequency * 1000) # Convert 0-1 to 0-1000
				freq = clamp(freq, MIN_FREQUENCY, MAX_FREQUENCY)
				
				# Start pulse animation for this dimension
				start_pulse_animation(freq, 10.0, 0.5, 0.3)
		
		return true
	
	return false

# ----- PUBLIC API -----
func get_frequency_info(frequency: int) -> Dictionary:
	frequency = clamp(frequency, MIN_FREQUENCY, MAX_FREQUENCY)
	
	var color = get_color_for_frequency(frequency)
	var point_types = get_mesh_point_type(frequency)
	var is_harmonic = false
	var harmonic_type = ""
	
	# Check if frequency is a harmonic
	if COLOR_HARMONICS.PRIMARY.frequencies.has(frequency):
		is_harmonic = true
		harmonic_type = "primary"
	elif COLOR_HARMONICS.SECONDARY.frequencies.has(frequency):
		is_harmonic = true
		harmonic_type = "secondary"
	elif COLOR_HARMONICS.TERITARY.frequencies.has(frequency):
		is_harmonic = true
		harmonic_type = "tertiary"
	
	return {
		"frequency": frequency,
		"color": color,
		"mesh_point_types": point_types,
		"is_harmonic": is_harmonic,
		"harmonic_type": harmonic_type,
		"has_active_animation": _frequency_has_animation(frequency)
	}

func _frequency_has_animation(frequency: int) -> bool:
	for animation_id in active_animations:
		if active_animations[animation_id].frequency == frequency:
			return true
	
	return false

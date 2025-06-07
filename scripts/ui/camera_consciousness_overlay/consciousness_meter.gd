extends Control

## Camera Consciousness Meter
## Visual meter showing consciousness level progression

@onready var level_indicator: ProgressBar = $LevelIndicator
@onready var level_icon: TextureRect = $LevelIcon
@onready var level_text: Label = $LevelText
@onready var glow_effect: ColorRect = $GlowEffect

var consciousness_level: int = 0
var consciousness_progress: float = 0.0
var max_level: int = 6

# Consciousness level colors
var level_colors: Array[Color] = [
	Color(0.5, 0.5, 0.5, 0.5),  # Gray - Dormant
	Color(1, 1, 1, 0.5),        # White - Aware
	Color(0, 1, 1, 0.7),        # Cyan - Conscious
	Color(0, 1, 0, 0.8),        # Green - Awakened
	Color(1, 1, 0, 0.9),        # Yellow - Enlightened
	Color(1, 0, 1, 1),          # Magenta - Transcendent
	Color(1, 0, 0, 1)           # Red - Beyond
]

func _ready():
	update_display()

func set_consciousness_level(level: int):
	consciousness_level = clamp(level, 0, max_level)
	update_display()

func set_consciousness_progress(progress: float):
	consciousness_progress = clamp(progress, 0.0, 100.0)
	level_indicator.value = consciousness_progress
	
	# Add glow effect based on progress
	var glow_intensity = consciousness_progress / 100.0
	glow_effect.modulate.a = glow_intensity * 0.5

func update_display():
	level_text.text = str(consciousness_level)
	
	# Update color based on consciousness level
	var color_index = min(consciousness_level, level_colors.size() - 1)
	var level_color = level_colors[color_index]
	
	# Apply color to various elements
	level_indicator.modulate = level_color
	glow_effect.color = level_color
	level_text.modulate = level_color
	
	# Set progress based on level
	var base_progress = (consciousness_level * 100.0) / max_level
	set_consciousness_progress(base_progress + consciousness_progress % (100.0 / max_level))

func _process(delta):
	pass
	# Animate glow effect
	var time = Time.get_time_dict_from_system()
	var pulse = sin(time.second * 2.0 + time.millisecond * 0.01) * 0.1 + 0.9
	glow_effect.modulate.a *= pulse

func evolve_consciousness():
	if consciousness_level < max_level:
		consciousness_level += 1
		update_display()
		
		# Create evolution effect
		create_evolution_animation()

func create_evolution_animation():
	pass
	# Create a brief flash effect
	var tween = create_tween()
	var original_color = glow_effect.color
	
	glow_effect.color = Color.WHITE
	tween.tween_property(glow_effect, "color", original_color, 0.5)
	tween.tween_property(glow_effect, "modulate:a", 1.0, 0.2)
	tween.tween_property(glow_effect, "modulate:a", 0.3, 0.3)

func pulse_consciousness():
	pass
	# Create a consciousness pulse effect
	var tween = create_tween()
	tween.tween_property(glow_effect, "modulate:a", 0.8, 0.1)
	tween.tween_property(glow_effect, "modulate:a", 0.2, 0.3)
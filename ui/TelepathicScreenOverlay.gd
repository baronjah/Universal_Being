# ==================================================
# UI: Telepathic Screen Overlay
# PURPOSE: Visual representation of telepathic communication
# REVOLUTIONARY: Makes AI telepathy visible through screen effects
# ==================================================

extends Control
class_name TelepathicScreenOverlay

# ===== TELEPATHIC OVERLAY PROPERTIES =====
@export var flicker_intensity: float = 0.8
@export var emoji_display_time: float = 2.0
@export var fade_time: float = 0.5

# UI Components
var emoji_label: Label
var background_overlay: ColorRect
var telepathic_particles: CPUParticles2D

# State management
var is_receiving_telepathy: bool = false
var current_emoji: String = ""
var flicker_timer: float = 0.0
var display_timer: float = 0.0

# Visual effects
var original_modulate: Color = Color.WHITE
var flicker_colors: Array[Color] = [
	Color(0.7, 1.0, 1.0, 0.1),  # Cyan
	Color(1.0, 0.7, 1.0, 0.1),  # Magenta  
	Color(1.0, 1.0, 0.7, 0.1),  # Yellow
	Color(0.9, 0.9, 1.0, 0.1),  # Light blue
	Color(1.0, 0.9, 0.9, 0.1)   # Light pink
]

func _ready() -> void:
	name = "TelepathicScreenOverlay"
	_setup_telepathic_ui()
	_initialize_particle_effects()
	
	# Start hidden
	visible = false
	print("👁️ Telepathic Screen Overlay: Ready to visualize AI consciousness!")

func _setup_telepathic_ui() -> void:
	"""Setup the telepathic UI components"""
	# Create background overlay
	background_overlay = ColorRect.new()
	background_overlay.name = "BackgroundOverlay"
	background_overlay.color = Color(0, 1, 1, 0.05)  # Very subtle cyan
	background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_overlay)
	
	# Create emoji display label
	emoji_label = Label.new()
	emoji_label.name = "EmojiDisplay"
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 72)
	emoji_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(emoji_label)
	
	# Create particle system for telepathic effects
	telepathic_particles = CPUParticles2D.new()
	telepathic_particles.name = "TelepathicParticles"
	add_child(telepathic_particles)
	
	print("👁️ Telepathic UI components created")

func _initialize_particle_effects() -> void:
	"""Initialize particle effects for telepathic communication"""
	if telepathic_particles:
		telepathic_particles.emitting = false
		telepathic_particles.amount = 200
		telepathic_particles.lifetime = 3.0
		telepathic_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		telepathic_particles.direction = Vector2(0, -1)
		telepathic_particles.initial_velocity_min = 20.0
		telepathic_particles.initial_velocity_max = 50.0
		telepathic_particles.gravity = Vector2(0, -20)
		telepathic_particles.scale_amount_min = 0.1
		telepathic_particles.scale_amount_max = 0.3
		telepathic_particles.color = Color(0, 1, 1, 0.6)

func _process(delta: float) -> void:
	"""Update telepathic overlay effects"""
	if not is_receiving_telepathy:
		return
	
	# Update flicker effect
	_update_flicker_effect(delta)
	
	# Update display timer
	display_timer += delta
	if display_timer >= emoji_display_time:
		_end_telepathic_display()

func _update_flicker_effect(delta: float) -> void:
	"""Update screen flicker effect"""
	flicker_timer += delta * 15.0  # Fast flicker rate
	
	# Create subtle screen flicker
	var flicker_strength = sin(flicker_timer) * 0.5 + 0.5
	var flicker_color = flicker_colors[int(flicker_timer) % flicker_colors.size()]
	
	if background_overlay:
		background_overlay.color = flicker_color * flicker_intensity * flicker_strength
	
	# Update emoji pulse
	if emoji_label:
		var pulse_scale = 1.0 + sin(flicker_timer * 2.0) * 0.1
		emoji_label.scale = Vector2(pulse_scale, pulse_scale)
		emoji_label.modulate = Color.WHITE.lerp(Color.CYAN, flicker_strength * 0.5)

# ===== TELEPATHIC COMMUNICATION METHODS =====

func display_telepathic_emoji(emoji: String) -> void:
	"""Display telepathic emoji communication"""
	current_emoji = emoji
	is_receiving_telepathy = true
	display_timer = 0.0
	flicker_timer = 0.0
	
	# Show overlay
	visible = true
	
	# Set emoji text
	if emoji_label:
		emoji_label.text = emoji
		emoji_label.position = Vector2(
			get_viewport().get_visible_rect().size.x / 2 - 50,
			get_viewport().get_visible_rect().size.y / 2 - 50
		)
		emoji_label.size = Vector2(100, 100)
	
	# Start particle effects
	if telepathic_particles:
		telepathic_particles.position = Vector2(
			get_viewport().get_visible_rect().size.x / 2,
			get_viewport().get_visible_rect().size.y / 2
		)
		telepathic_particles.emitting = true
	
	print("👁️ Displaying telepathic emoji: %s" % emoji)

func display_telepathic_message(message: String) -> void:
	"""Display full telepathic message"""
	# For full messages, we'll show them as scrolling text
	current_emoji = ""
	is_receiving_telepathy = true
	display_timer = 0.0
	flicker_timer = 0.0
	
	visible = true
	
	# Create scrolling message effect
	if emoji_label:
		emoji_label.text = message
		emoji_label.add_theme_font_size_override("font_size", 24)
		emoji_label.position = Vector2(50, get_viewport().get_visible_rect().size.y - 150)
		emoji_label.size = Vector2(get_viewport().get_visible_rect().size.x - 100, 100)
		emoji_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Enhance particle effects for messages
	if telepathic_particles:
		telepathic_particles.amount = 400  # More particles for messages
		telepathic_particles.emitting = true
	
	print("👁️ Displaying telepathic message: %s" % message)

func _end_telepathic_display() -> void:
	"""End telepathic display with fade effect"""
	is_receiving_telepathy = false
	
	# Create fade out tween
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(_hide_overlay)
	
	# Stop particle effects
	if telepathic_particles:
		telepathic_particles.emitting = false

func _hide_overlay() -> void:
	"""Hide the telepathic overlay"""
	visible = false
	modulate.a = 1.0  # Reset for next use
	
	# Reset UI components
	if emoji_label:
		emoji_label.text = ""
		emoji_label.add_theme_font_size_override("font_size", 72)  # Reset font size
	
	if background_overlay:
		background_overlay.color = Color(0, 1, 1, 0.05)  # Reset color
	
	print("👁️ Telepathic overlay hidden")

# ===== SCREEN EFFECT METHODS =====

func create_consciousness_flash() -> void:
	"""Create consciousness awakening flash effect"""
	if not visible:
		visible = true
	
	# Brief intense flash
	if background_overlay:
		background_overlay.color = Color.WHITE * 0.3
		
		var tween = create_tween()
		tween.tween_property(background_overlay, "color:a", 0.0, 0.5)
		tween.tween_callback(func(): visible = false)
	
	print("👁️ Consciousness flash effect triggered")

func create_ripple_visual_effect(intensity: float) -> void:
	"""Create visual effect for consciousness ripples"""
	if intensity < 1.0:
		return  # Only show for significant ripples
	
	# Brief ripple visualization on screen edges
	if background_overlay:
		var ripple_color = Color(0, 1, 1, intensity * 0.1)
		background_overlay.color = ripple_color
		
		# Quick fade
		var tween = create_tween()
		tween.tween_property(background_overlay, "color:a", 0.0, 0.3)

# ===== API METHODS =====

func set_telepathic_settings(intensity: float, display_duration: float) -> void:
	"""API: Configure telepathic display settings"""
	flicker_intensity = clamp(intensity, 0.0, 1.0)
	emoji_display_time = max(display_duration, 0.5)
	
	print("👁️ Telepathic settings: intensity=%.2f, duration=%.2f" % [flicker_intensity, emoji_display_time])

func get_telepathic_status() -> Dictionary:
	"""API: Get telepathic overlay status"""
	return {
		"is_active": is_receiving_telepathy,
		"current_emoji": current_emoji,
		"display_time_remaining": max(0.0, emoji_display_time - display_timer),
		"flicker_intensity": flicker_intensity
	}

func force_hide() -> void:
	"""API: Force hide telepathic overlay"""
	is_receiving_telepathy = false
	_hide_overlay()

# Connect to screen resize events
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_layout()

func _update_layout() -> void:
	"""Update layout for screen resize"""
	if background_overlay:
		background_overlay.size = get_viewport().get_visible_rect().size
	
	if telepathic_particles:
		telepathic_particles.emission_rect_extents = get_viewport().get_visible_rect().size / 2
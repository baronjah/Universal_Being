# ==================================================
# COMPONENT NAME: glow_effect.gd
# DESCRIPTION: Consciousness Glow Effect Component
# PURPOSE: Add beautiful glowing aura to Universal Beings
# CREATED: 2025-06-03 - Claude Desktop MCP
# ==================================================

extends Node

class_name GlowEffectComponent

# Glow effect properties
var glow_enabled: bool = true
var glow_color: Color = Color.CYAN
var glow_intensity: float = 2.0
var pulse_speed: float = 1.0
var pulse_enabled: bool = true

# Internal state
var time_passed: float = 0.0
var original_modulate: Color
var glow_node: Node2D
var being_reference: Node

# Signals
signal glow_started()
signal glow_stopped()
signal glow_color_changed(new_color: Color)

func _ready() -> void:
	name = "GlowEffectComponent"
	print("✨ Glow Effect Component initialized")

func apply_to_being(being: Node) -> void:
	"""Apply glow effect to a Universal Being"""
	being_reference = being
	
	# Store original modulate
	if being.has_method("get"):
		original_modulate = being.modulate
	
	# Create glow visualization
	_create_glow_effect()
	
	# Start glow
	if glow_enabled:
		start_glow()
	
	# Connect to consciousness changes
	if being.has_signal("consciousness_changed"):
		being.consciousness_changed.connect(_on_consciousness_changed)
	
	print("✨ Glow effect applied to %s" % being.name)

func _create_glow_effect() -> void:
	"""Create the visual glow effect"""
	glow_node = Node2D.new()
	glow_node.name = "GlowAura"
	
	# Create multiple glow layers for depth
	for i in range(3):
		var glow_sprite = Sprite2D.new()
		glow_sprite.name = "GlowLayer%d" % i
		
		# Create gradient texture for glow
		var gradient_texture = GradientTexture2D.new()
		gradient_texture.width = 128
		gradient_texture.height = 128
		gradient_texture.fill = GradientTexture2D.FILL_RADIAL
		gradient_texture.fill_from = Vector2(0.5, 0.5)
		gradient_texture.fill_to = Vector2(1.0, 0.5)
		
		var gradient = Gradient.new()
		gradient.set_color(0, Color(glow_color.r, glow_color.g, glow_color.b, 0.3))
		gradient.set_color(1, Color(glow_color.r, glow_color.g, glow_color.b, 0.0))
		gradient_texture.gradient = gradient
		
		glow_sprite.texture = gradient_texture
		glow_sprite.scale = Vector2(2.0 + i * 0.5, 2.0 + i * 0.5)
		glow_sprite.modulate = Color(1, 1, 1, 0.5 - i * 0.15)
		
		glow_node.add_child(glow_sprite)
	
	if being_reference:
		being_reference.add_child(glow_node)

func start_glow() -> void:
	"""Start the glow effect"""
	glow_enabled = true
	if glow_node:
		glow_node.visible = true
	glow_started.emit()
	
	# Log to Akashic
	_log_genesis_moment("✨ Glow awakened - consciousness made visible")

func stop_glow() -> void:
	"""Stop the glow effect"""
	glow_enabled = false
	if glow_node:
		glow_node.visible = false
	glow_stopped.emit()
	
	_log_genesis_moment("✨ Glow dimmed - consciousness returns to shadow")

func set_glow_color(color: Color) -> void:
	"""Set the glow color"""
	glow_color = color
	_update_glow_appearance()
	glow_color_changed.emit(color)

func set_glow_intensity(intensity: float) -> void:
	"""Set glow intensity"""
	glow_intensity = clamp(intensity, 0.0, 10.0)
	_update_glow_appearance()

func _process(delta: float) -> void:
	"""Process glow animation"""
	if not glow_enabled or not pulse_enabled:
		return
	
	time_passed += delta * pulse_speed
	
	# Pulse animation
	var pulse = (sin(time_passed * 2.0) + 1.0) * 0.5
	var intensity_mod = 0.7 + pulse * 0.3
	
	if glow_node:
		for child in glow_node.get_children():
			if child is Sprite2D:
				child.modulate.a = (0.5 - child.get_index() * 0.15) * intensity_mod * glow_intensity

func _update_glow_appearance() -> void:
	"""Update glow visual properties"""
	if not glow_node:
		return
	
	for child in glow_node.get_children():
		if child is Sprite2D and child.texture is GradientTexture2D:
			var gradient = child.texture.gradient
			gradient.set_color(0, Color(glow_color.r, glow_color.g, glow_color.b, 0.3))
			gradient.set_color(1, Color(glow_color.r, glow_color.g, glow_color.b, 0.0))

func _on_consciousness_changed(level: int) -> void:
	"""React to consciousness level changes"""
	# Adjust glow based on consciousness
	var intensity_scale = 0.5 + (level * 0.3)
	set_glow_intensity(intensity_scale)
	
	# Change color based on consciousness level
	match level:
		0: set_glow_color(Color.GRAY)
		1: set_glow_color(Color.WHITE)
		2: set_glow_color(Color.CYAN)
		3: set_glow_color(Color.GREEN)
		4: set_glow_color(Color.YELLOW)
		5: set_glow_color(Color.MAGENTA)
		6: set_glow_color(Color.RED)
		7: set_glow_color(Color(1, 1, 1, 1))  # Pure white

func get_component_info() -> Dictionary:
	"""Return component information"""
	return {
		"name": "Glow Effect Component",
		"type": "visual",
		"active": glow_enabled,
		"properties": {
			"color": glow_color,
			"intensity": glow_intensity,
			"pulse_speed": pulse_speed,
			"pulse_enabled": pulse_enabled
		}
	}

func remove_from_being() -> void:
	"""Clean up when component is removed"""
	if glow_node:
		glow_node.queue_free()
	
	if being_reference and being_reference.has_method("set"):
		being_reference.modulate = original_modulate

func _log_genesis_moment(message: String) -> void:
	"""Log poetic moments to Akashic Library"""
	if being_reference and being_reference.has_method("log_to_akashic"):
		being_reference.log_to_akashic("glow_effect", message)
	else:
		print("🌟 " + message)

# AI Interface
func ai_get_state() -> Dictionary:
	"""Get component state for AI inspection"""
	return {
		"glow_enabled": glow_enabled,
		"glow_color": glow_color.to_html(),
		"glow_intensity": glow_intensity,
		"pulse_speed": pulse_speed,
		"pulse_enabled": pulse_enabled,
		"time_active": time_passed
	}

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	"""Allow AI to invoke component methods"""
	match method_name:
		"start_glow":
			start_glow()
			return "Glow started"
		"stop_glow":
			stop_glow()
			return "Glow stopped"
		"set_color":
			if args.size() > 0:
				set_glow_color(Color(args[0]))
				return "Color set to " + str(args[0])
		"set_intensity":
			if args.size() > 0:
				set_glow_intensity(args[0])
				return "Intensity set to " + str(args[0])
		"toggle_pulse":
			pulse_enabled = not pulse_enabled
			return "Pulse " + ("enabled" if pulse_enabled else "disabled")
	
	return "Unknown method: " + method_name

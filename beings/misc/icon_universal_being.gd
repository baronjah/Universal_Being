# ==================================================
# UNIVERSAL BEING: Icon Universal Being
# TYPE: icon
# PURPOSE: 3D icon that can display different symbols and interact
# ==================================================

extends UniversalBeing
class_name IconUniversalBeing

# ===== ICON PROPERTIES =====
@export var icon_name: String = "sphere"
@export var icon_category: String = "mystical"
@export var hover_scale: float = 1.2
@export var pulse_on_consciousness: bool = true
@export var clickable: bool = true

# Icon textures (can be set in inspector)
@export var icon_textures: Dictionary = {
	"black_sphere": "res://akashic_library/icons/black_sphere.png",
	"white_sphere": "res://akashic_library/icons/white_sphere.png", 
	"fire": "res://akashic_library/icons/fire.png",
	"droplet": "res://akashic_library/icons/droplet.png",
	"plant": "res://akashic_library/icons/plant.png",
	"star": "res://akashic_library/icons/star.png",
	"hexa_star": "res://akashic_library/icons/hexa_star.png",
	"infinity": "res://akashic_library/icons/infinity_symbol.png"
}

# Node references
var sprite_3d: Sprite3D
var area_3d: Area3D
var original_scale: Vector3
var is_hovered: bool = false
var click_count: int = 0

# Optional socket support
@export var enable_sockets: bool = false
var input_socket: Marker3D
var output_socket: Marker3D

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "icon"
	being_name = "%s Icon" % icon_name.capitalize()
	consciousness_level = 0

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Find components
	sprite_3d = find_child("Sprite3D") as Sprite3D
	area_3d = sprite_3d.find_child("Area3D") as Area3D if sprite_3d else null
	
	# Store original scale
	if sprite_3d:
		original_scale = sprite_3d.scale
	
	# Set initial texture if specified
	if sprite_3d and icon_textures.has(icon_name):
		var texture_path = icon_textures[icon_name]
		sprite_3d.texture = load(texture_path)
	
	# Connect interactions
	if area_3d and clickable:
		area_3d.input_event.connect(_on_area_input_event)
		area_3d.mouse_entered.connect(_on_mouse_entered)
		area_3d.mouse_exited.connect(_on_mouse_exited)
	
	# Add sockets if enabled
	if enable_sockets:
		_add_sockets()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	if not sprite_3d:
		return
	
	# Pulse effect based on consciousness
	if pulse_on_consciousness and consciousness_level > 0:
		var pulse = sin(Time.get_ticks_msec() / 1000.0 * consciousness_level) * 0.05 + 1.0
		sprite_3d.scale = original_scale * pulse
	
	# Hover effect
	if is_hovered and not pulse_on_consciousness:
		sprite_3d.scale = sprite_3d.scale.lerp(original_scale * hover_scale, delta * 10)
	elif not pulse_on_consciousness:
		sprite_3d.scale = sprite_3d.scale.lerp(original_scale, delta * 10)
	
	# Apply consciousness glow
	if consciousness_level > 0:
		sprite_3d.modulate = consciousness_aura_color
		sprite_3d.modulate.a = 1.0

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	print("🎨 %s: Total interactions: %d" % [being_name, click_count])
	super.pentagon_sewers()

# ===== ICON METHODS =====

func set_icon(new_icon_name: String) -> void:
	icon_name = new_icon_name
	being_name = "%s Icon" % icon_name.capitalize()
	
	if sprite_3d and icon_textures.has(icon_name):
		var texture_path = icon_textures[icon_name]
		sprite_3d.texture = load(texture_path)
		print("🎨 Icon changed to: %s" % icon_name)

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_icon_clicked()

func _on_icon_clicked() -> void:
	click_count += 1
	
	# Increase consciousness with interactions
	consciousness_level = mini(5, int(click_count * 0.2))
	update_consciousness_visual()
	
	print("🎨 %s clicked! Count: %d, Consciousness: %d" % [being_name, click_count, consciousness_level])
	
	# Visual feedback - spin
	if sprite_3d:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite_3d, "rotation:y", sprite_3d.rotation.y + TAU, 0.5)
	
	# Emit signal
	consciousness_awakened.emit(consciousness_level)

func _on_mouse_entered() -> void:
	is_hovered = true
	print("🎨 Hovering over: %s" % being_name)

func _on_mouse_exited() -> void:
	is_hovered = false

# ===== SOCKET SUPPORT =====

func _add_sockets() -> void:
	# Add input socket
	input_socket = Marker3D.new()
	input_socket.name = "InputSocket"
	input_socket.position = Vector3(-0.6, 0, 0)
	input_socket.set_meta("socket_type", "input")
	input_socket.set_meta("socket_name", "in")
	add_child(input_socket)
	
	# Add output socket
	output_socket = Marker3D.new()
	output_socket.name = "OutputSocket"
	output_socket.position = Vector3(0.6, 0, 0)
	output_socket.set_meta("socket_type", "output")
	output_socket.set_meta("socket_name", "out")
	add_child(output_socket)

# ===== TEXT REPRESENTATION =====

func get_text_representation() -> String:
	pass
	var text = "🎨 [ICON:%s]" % icon_name.to_upper()
	text += " CATEGORY:%s" % icon_category
	text += " CLICKS:%d" % click_count
	text += " HOVER:%s" % ("YES" if is_hovered else "NO")
	text += " CONSCIOUSNESS:%d" % consciousness_level
	
	# Add ASCII representation based on icon
	text += "\n" + get_ascii_art()
	
	return text

func get_ascii_art() -> String:
	match icon_name:
		"black_sphere", "white_sphere":
			return "  ●  "
		"fire":
			return " 🔥 "
		"droplet":
			return " 💧 "
		"plant":
			return " 🌱 "
		"star":
			return " ⭐ "
		"hexa_star":
			return " ✡️  "
		"infinity":
			return " ∞  "
		_:
			return " [?] "

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base = super.ai_interface()
	base.icon_info = {
		"name": icon_name,
		"category": icon_category,
		"interactions": click_count,
		"hovering": is_hovered,
		"available_icons": icon_textures.keys()
	}
	base.text_representation = get_text_representation()
	return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"change_icon":
			if args.size() > 0 and icon_textures.has(args[0]):
				set_icon(args[0])
				return "Icon changed to: %s" % args[0]
			return "Invalid icon name"
		"reset_clicks":
			click_count = 0
			return "Click count reset"
		_:
			return super.ai_invoke_method(method_name, args)
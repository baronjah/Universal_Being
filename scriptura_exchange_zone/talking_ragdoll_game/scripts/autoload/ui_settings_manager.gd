# ==================================================
# SCRIPT NAME: ui_settings_manager.gd
# DESCRIPTION: Manages UI scaling and user preferences
# CREATED: 2025-05-23 - Scalable UI system
# ==================================================

extends UniversalBeingBase
signal settings_changed()

# Settings file path (in user://settings/)
const SETTINGS_FILE = "user://ui_settings.cfg"

# UI Settings
var ui_scale: float = 1.0
var console_position: String = "center"  # center, top, bottom, left, right
var console_width_percent: float = 0.6  # 60% of screen width
var console_height_percent: float = 0.5  # 50% of screen height
var console_opacity: float = 0.9
var console_font_size: int = 16
var console_animation_speed: float = 0.3

# Color scheme
var console_bg_color: Color = Color(0, 0, 0, 0.9)
var console_text_color: Color = Color(1, 1, 1, 1)
var console_input_bg_color: Color = Color(0.1, 0.1, 0.1, 1)
var console_accent_color: Color = Color(0.2, 0.8, 0.2, 1)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	load_settings()
	
	# Watch for window size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
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
func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	if err != OK:
		# First time, create default settings
		save_settings()
		return
	
	# Load UI settings
	ui_scale = config.get_value("ui", "scale", 1.0)
	console_position = config.get_value("ui", "console_position", "center")
	console_width_percent = config.get_value("ui", "console_width_percent", 0.6)
	console_height_percent = config.get_value("ui", "console_height_percent", 0.5)
	console_opacity = config.get_value("ui", "console_opacity", 0.9)
	console_font_size = config.get_value("ui", "console_font_size", 16)
	console_animation_speed = config.get_value("ui", "console_animation_speed", 0.3)
	
	# Load colors
	console_bg_color = config.get_value("colors", "console_bg", Color(0, 0, 0, 0.9))
	console_text_color = config.get_value("colors", "console_text", Color(1, 1, 1, 1))
	console_input_bg_color = config.get_value("colors", "console_input_bg", Color(0.1, 0.1, 0.1, 1))
	console_accent_color = config.get_value("colors", "console_accent", Color(0.2, 0.8, 0.2, 1))
	
	emit_signal("settings_changed")

func save_settings() -> void:
	var config = ConfigFile.new()
	
	# Save UI settings
	config.set_value("ui", "scale", ui_scale)
	config.set_value("ui", "console_position", console_position)
	config.set_value("ui", "console_width_percent", console_width_percent)
	config.set_value("ui", "console_height_percent", console_height_percent)
	config.set_value("ui", "console_opacity", console_opacity)
	config.set_value("ui", "console_font_size", console_font_size)
	config.set_value("ui", "console_animation_speed", console_animation_speed)
	
	# Save colors
	config.set_value("colors", "console_bg", console_bg_color)
	config.set_value("colors", "console_text", console_text_color)
	config.set_value("colors", "console_input_bg", console_input_bg_color)
	config.set_value("colors", "console_accent", console_accent_color)
	
	# Save file
	config.save(SETTINGS_FILE)
	emit_signal("settings_changed")

func get_scaled_value(base_value: float) -> float:
	return base_value * ui_scale

func get_console_rect() -> Rect2:
	var viewport_size = get_viewport().size
	var console_width = viewport_size.x * console_width_percent
	var console_height = viewport_size.y * console_height_percent
	
	var position = Vector2.ZERO
	
	match console_position:
		"center":
			position.x = (viewport_size.x - console_width) / 2
			position.y = (viewport_size.y - console_height) / 2
		"top":
			position.x = (viewport_size.x - console_width) / 2
			position.y = 20 * ui_scale
		"bottom":
			position.x = (viewport_size.x - console_width) / 2
			position.y = viewport_size.y - console_height - (20 * ui_scale)
		"left":
			position.x = 20 * ui_scale
			position.y = (viewport_size.y - console_height) / 2
		"right":
			position.x = viewport_size.x - console_width - (20 * ui_scale)
			position.y = (viewport_size.y - console_height) / 2
	
	return Rect2(position, Vector2(console_width, console_height))

func set_ui_scale(scale: float) -> void:
	ui_scale = clamp(scale, 0.5, 2.0)
	save_settings()

func set_console_position(pos: String) -> void:
	if pos in ["center", "top", "bottom", "left", "right"]:
		console_position = pos
		save_settings()

func _on_viewport_size_changed() -> void:
	emit_signal("settings_changed")
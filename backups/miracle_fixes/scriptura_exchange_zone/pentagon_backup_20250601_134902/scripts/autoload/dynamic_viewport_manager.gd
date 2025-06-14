# ==================================================
# SCRIPT NAME: dynamic_viewport_manager.gd
# DESCRIPTION: Dynamically adjusts viewport to user's screen
# PURPOSE: Adaptive window sizing for different displays
# CREATED: 2025-05-28 - Smart viewport management
# ==================================================

extends UniversalBeingBase
signal viewport_changed(new_size: Vector2i)
signal fullscreen_toggled(is_fullscreen: bool)

var default_size: Vector2i = Vector2i(1280, 720)
var current_screen: int = 0
var is_fullscreen: bool = false

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Detect and apply optimal settings on startup
	_detect_and_apply_optimal_settings()
	
	# Register console commands
	_register_commands()
	
	print("[DynamicViewport] Display adapter initialized")

func _detect_and_apply_optimal_settings() -> void:
	# Get current screen info
	current_screen = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(current_screen)
	var screen_usable = DisplayServer.screen_get_usable_rect(current_screen)
	
	print("[DynamicViewport] Screen %d detected:" % current_screen)
	print("  Full size: %s" % screen_size)
	print("  Usable area: %s" % screen_usable)
	
	# For now, just use the project settings size
	# Let user manually adjust if needed
	print("[DynamicViewport] Using project default size: 1920x1080")
	
	# Don't auto-resize on startup to avoid confusion
	# Users can use console commands to adjust

func _register_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("viewport", _cmd_viewport_info, "Show viewport and screen information")
		console.register_command("window_size", _cmd_set_window_size, "Set window size (width height)")
		console.register_command("fullscreen", _cmd_toggle_fullscreen, "Toggle fullscreen mode")
		console.register_command("window_mode", _cmd_set_window_mode, "Set window mode (windowed/fullscreen/exclusive/borderless)")
		console.register_command("center_window", _cmd_center_window, "Center window on screen")
		console.register_command("list_screens", _cmd_list_screens, "List all available screens")
		console.register_command("move_to_screen", _cmd_move_to_screen, "Move window to specific screen")

# ================================
# WINDOW MANAGEMENT
# ================================

func _set_window_size(size: Vector2i) -> void:
	DisplayServer.window_set_size(size)
	get_window().size = size
	viewport_changed.emit(size)
	print("[DynamicViewport] Window resized to: %s" % size)

func _center_window() -> void:
	var screen_center = DisplayServer.screen_get_position(current_screen) + DisplayServer.screen_get_size(current_screen) / 2
	var window_size = DisplayServer.window_get_size()
	var window_pos = screen_center - window_size / 2
	
	DisplayServer.window_set_position(window_pos)
	print("[DynamicViewport] Window centered on screen %d" % current_screen)

func _set_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# Restore previous size when exiting fullscreen
		_detect_and_apply_optimal_settings()
	
	is_fullscreen = enabled
	fullscreen_toggled.emit(enabled)

# ================================
# CONSOLE COMMANDS
# ================================

func _cmd_viewport_info(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	console._print_to_console("[color=cyan]=== Viewport Information ===[/color]")
	
	# Current window info
	var window_size = DisplayServer.window_get_size()
	var window_pos = DisplayServer.window_get_position()
	var window_mode = DisplayServer.window_get_mode()
	
	console._print_to_console("[color=yellow]Window:[/color]")
	console._print_to_console("  Size: %s" % window_size)
	console._print_to_console("  Position: %s" % window_pos)
	console._print_to_console("  Mode: %s" % _get_window_mode_name(window_mode))
	
	# Screen info
	var screen_count = DisplayServer.get_screen_count()
	console._print_to_console("\n[color=yellow]Screen %d of %d:[/color]" % [current_screen + 1, screen_count])
	console._print_to_console("  Size: %s" % DisplayServer.screen_get_size(current_screen))
	console._print_to_console("  DPI: %d" % DisplayServer.screen_get_dpi(current_screen))
	console._print_to_console("  Scale: %.2f" % DisplayServer.screen_get_scale(current_screen))
	
	# Viewport info
	var viewport = get_viewport()
	console._print_to_console("\n[color=yellow]Viewport:[/color]")
	console._print_to_console("  Size: %s" % viewport.size)
	console._print_to_console("  Render size: %s" % viewport.get_visible_rect().size)
	
	# Performance considerations
	var aspect_ratio = float(window_size.x) / float(window_size.y)
	console._print_to_console("\n[color=yellow]Aspect Ratio:[/color] %.2f:1 (%s)" % [aspect_ratio, _get_aspect_ratio_name(aspect_ratio)])

func _cmd_set_window_size(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() < 2:
		console._print_to_console("Usage: window_size <width> <height>")
		console._print_to_console("Common sizes:")
		console._print_to_console("  1280 720  - HD (16:9)")
		console._print_to_console("  1920 1080 - Full HD (16:9)")
		console._print_to_console("  2560 1440 - QHD (16:9)")
		console._print_to_console("  1600 900  - HD+ (16:9)")
		console._print_to_console("  1366 768  - Common laptop (16:9)")
		return
	
	var width = int(args[0])
	var height = int(args[1])
	
	# Validate size
	width = clamp(width, 640, 7680)
	height = clamp(height, 480, 4320)
	
	_set_window_size(Vector2i(width, height))
	_center_window()

func _cmd_toggle_fullscreen(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() > 0:
		var mode = args[0].to_lower()
		_set_fullscreen(mode == "on" or mode == "true" or mode == "1")
	else:
		_set_fullscreen(!is_fullscreen)
	
	console._print_to_console("Fullscreen: " + ("ON" if is_fullscreen else "OFF"))

func _cmd_set_window_mode(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() == 0:
		console._print_to_console("Usage: window_mode <mode>")
		console._print_to_console("Modes: windowed, fullscreen, exclusive, borderless")
		return
	
	match args[0].to_lower():
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"exclusive":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			console._print_to_console("Unknown mode: " + args[0])
			return
	
	console._print_to_console("Window mode changed to: " + args[0])

func _cmd_center_window(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	_center_window()
	console._print_to_console("Window centered on current screen")

func _cmd_list_screens(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var screen_count = DisplayServer.get_screen_count()
	
	console._print_to_console("[color=cyan]=== Available Screens ===[/color]")
	
	for i in range(screen_count):
		var size = DisplayServer.screen_get_size(i)
		var pos = DisplayServer.screen_get_position(i)
		var dpi = DisplayServer.screen_get_dpi(i)
		var scale = DisplayServer.screen_get_scale(i)
		
		var current_marker = " [CURRENT]" if i == current_screen else ""
		console._print_to_console("Screen %d%s:" % [i, current_marker])
		console._print_to_console("  Size: %s @ %s" % [size, pos])
		console._print_to_console("  DPI: %d, Scale: %.2f" % [dpi, scale])

func _cmd_move_to_screen(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() == 0:
		console._print_to_console("Usage: move_to_screen <screen_number>")
		return
	
	var target_screen = int(args[0])
	var screen_count = DisplayServer.get_screen_count()
	
	if target_screen < 0 or target_screen >= screen_count:
		console._print_to_console("Invalid screen number. Valid range: 0-%d" % (screen_count - 1))
		return
	
	current_screen = target_screen
	DisplayServer.window_set_current_screen(target_screen)
	_center_window()
	
	console._print_to_console("Window moved to screen %d" % target_screen)

# ================================
# HELPER FUNCTIONS
# ================================

func _get_window_mode_name(mode: int) -> String:
	match mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			return "Windowed"
		DisplayServer.WINDOW_MODE_MINIMIZED:
			return "Minimized"
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			return "Maximized"
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			return "Fullscreen"
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return "Exclusive Fullscreen"
		_:
			return "Unknown"

func _get_aspect_ratio_name(ratio: float) -> String:
	# Common aspect ratios
	var ratios = {
		1.33: "4:3",
		1.6: "16:10",
		1.78: "16:9",
		2.35: "21:9",
		2.4: "21:9 Ultrawide",
		3.56: "32:9 Super Ultrawide"
	}
	
	# Find closest match
	var closest_name = "Custom"
	var min_diff = INF
	
	for r in ratios:
		var diff = abs(ratio - r)
		if diff < 0.05 and diff < min_diff:  # Within tolerance
			min_diff = diff
			closest_name = ratios[r]
	
	return closest_name

# ================================
# INPUT HANDLING
# ================================

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Alt+Enter for fullscreen toggle
	if event.is_action_pressed("ui_fullscreen"):
		_set_fullscreen(!is_fullscreen)
		get_viewport().set_input_as_handled()

# ================================
# RESPONSIVE ADJUSTMENTS
# ================================

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_SIZE_CHANGED:
			var new_size = DisplayServer.window_get_size()
			viewport_changed.emit(new_size)
			print("[DynamicViewport] Window resized by user to: %s" % new_size)
		
		NOTIFICATION_WM_DPI_CHANGE:
			var new_dpi = DisplayServer.screen_get_dpi(current_screen)
			print("[DynamicViewport] DPI changed to: %d" % new_dpi)
			# Could adjust UI scale here

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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass